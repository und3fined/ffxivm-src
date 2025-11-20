local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local MajorUtil = require("Utils/MajorUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EstateInfoCfg = require("TableCfg/EstateInfoCfg")
local ArmyMgr = require("Game/Army/ArmyMgr")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local HouseCfg = require("TableCfg/HouseCfg")
local MapUtil = require("Game/Map/MapUtil")
local CrossWorldUtil = require("Utils/CrossWorldUtil")
local HouseUtil = require("Game/House/HouseUtil")
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_SUBMSGID_LAND
local HOUSESUB_MSG_ID = ProtoCS.CS_SUBMSGID_HOUSE

---@class HouseLandMgr : MgrBase
local HouseLandMgr = LuaClass(MgrBase)

function HouseLandMgr:OnInit()
    self.CurLandListData = {} -- 当前打开地图列表土地数据
    self.CurMapLandList = {} -- 当前打开地图土地数据
    self.CurMapData = nil -- 当前打开的地图数据
    self.CacheRoleInfos = {} -- 缓存的玩家数据
    self.ReleaseLands = {} -- 住宅区投放的小区数
    self.CurHouseBlockID = 0 -- 不处于房屋地块的时候为0
end

function HouseLandMgr:OnReset()
end

function HouseLandMgr:OnBegin()

end

function HouseLandMgr:OnEnd()
end

function HouseLandMgr:OnShutdown()
end

function HouseLandMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGIN, 0, self.OnNetMsgRoleLoginRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOOT, 0, self.OnNetMsgLoot)

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_QUERY_BUY_STATUS, self.RspQueryBuyStatus)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_QUERY_AREA, self.RspLandQueryArea)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_COLLECT_LAND, self.RspCollectLand)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_BUY_LAND, self.RspBuyLand)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_BUILD_HOUSE, self.RspBuildHouse)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_ABANDON, self.RspAbandonLand)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_DESTROY_HOUSE, self.RspDestroyHouse)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LAND, SUB_MSG_ID.CS_SUBMSGID_LAND_GET_RETURN_ASSET, self.RspGetReturnAssets)

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_HOUSE, HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_ESTATE, self.RspLandTransmit)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_HOUSE, HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_PERSONAL_ETHER, self.RspEnterPersonalEther)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_HOUSE, HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_ESTATE_BLOCK, self.RspEnterPEstateBlock)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_HOUSE, HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_PULL_ROLE_HOUSE_ADDR, self.RspPullRoleHouseAddr)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_HOUSE, HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_PULL_HOUSE_BASIC, self.RspPullHouseBasicInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_HOUSE, HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_DESTORIED_HOUSE_BC, self.RspDestroiedHouseBC)
end

function HouseLandMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.EnterOrExitHouseBlock, self.OnEnterOrExitHouseBlock)
    self:RegisterGameEvent(_G.EventID.OpenHouseOrLandInfoPanel, self.OnOpenHouseOrLandInfoPanel)
    self:RegisterGameEvent(_G.EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(_G.EventID.PWorldTransBegin, self.OnPWorldTransBegin)
    self:RegisterGameEvent(_G.EventID.PWorldMapEnter, self.OnPWorldMapEnter)
end

-- 是否跨服
function HouseLandMgr:IsVisitWorld()
    local RoleVM = MajorUtil.GetMajorRoleVM()
    if RoleVM == nil then
        return false
    end
    local RoleCurWorldID = RoleVM.CurWorldID
    if RoleCurWorldID == 0 then
        RoleCurWorldID = RoleVM.WorldID
    end
    return RoleCurWorldID ~= RoleVM.WorldID
end

-- 获取住宅区投放的小区数  拉取地图土地信息后需要重新读取一下
function HouseLandMgr:GetReleaseLand(ResidenceNumber)
    local ReleaseCnt = self.ReleaseLands[ResidenceNumber] and self.ReleaseLands[ResidenceNumber].ReleaseCount or 1
    return ReleaseCnt
end

-- 获取当前家具的HouseID
function HouseLandMgr.GetCurFurnitureHouseID()
    local HouseID = _G.HousingMgr.IndoorHouseID or 0
    if HouseID == 0 then
        local ResidenceNumber = HouseLandMgr:GetResidenceNumber(_G.MapMgr:GetMapID())
        if ResidenceNumber ~= nil then
            local AreaNumber = _G.MapMgr:GetStreetID()
            local LandNumber = _G.HousingMgr.CurrentHousingBlockId
            HouseID = _G.HousingMgr:IsHouseBuildInBlock(ResidenceNumber, AreaNumber, LandNumber)
        end
    end
    return HouseID
end

-- 获取房屋地址信息
function HouseLandMgr:GetHouseAddrStr(HouseAddr, HouseResID, HouseType, Index)
    if HouseAddr == nil then
        return ""
    end
 
    local HouseAddrStr, EstateName, HouseSize = "", "", ""
    local EstateInfo = EstateInfoCfg:FindCfgByKey(HouseAddr.EstateID)
    if EstateInfo then
        EstateName = EstateInfo.EstateName
    end

    local Area = HouseAddr.Area or 0
    local Number = HouseAddr.Number or 0
    local HouseInfo = HouseCfg:FindCfgByKey(HouseResID)
    if HouseInfo then
        HouseSize = HouseLocalDef.HouseInfoSizeStr[HouseInfo.Size]
    end
    HouseAddrStr = string.format(HouseLocalDef.LocationInfoStr.HouseAddr, EstateName, Area, Number,
        HouseSize)

    if HouseType == ProtoCS.HouseType.HouseType_HouseType_GroupMemberRoom then
        HouseAddrStr = string.format(HouseLocalDef.LocationInfoStr.RoomAddr, EstateName, HouseAddr.Area, HouseAddr.Number,
        Index or 0)
    end
    return HouseAddrStr
end

-- 获取住宅区对应的MapID
function HouseLandMgr:GetMapID(ResidenceNumber)
    local MapID = nil
    local Cfg = EstateInfoCfg:FindCfgByKey(ResidenceNumber)
    if Cfg then
        MapID = Cfg.MapID
    end
    return MapID
end

-- 获取MapID对应的住宅区
function HouseLandMgr:GetResidenceNumber(MapID)
    local ResidenceNumber = nil
    local Cfg = EstateInfoCfg:FindCfg(string.format("MapID = %d", MapID))
    if Cfg then
        ResidenceNumber = Cfg.ID
    end
    return ResidenceNumber
end

function HouseLandMgr.GetVisitPrivile(OwnerID, VisitSetting, Roommates, VisitSettingType, HouseType)
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    local IsCanVisitRoommate = table.find_by_predicate(Roommates, function(Item)
        return Item.RoleID == MajorRoleID
    end)
    local IsFriend = FriendMgr:IsFriend(OwnerID)
    local IsSameArmy = ArmyMgr.SelfArmyID == OwnerID and ArmyMgr.SelfArmyID > 0
    local IsMe = MajorRoleID == OwnerID
    local CanVisited = false
    if VisitSetting then
        local VisitNum = 1
        if VisitSettingType == ProtoCS.HouseVisitSettingType.HouseVisitSettingType_Browser then
            VisitNum = 2
        end
        for i = 1, #VisitSetting do                --防止网络包不按照顺序发
            if VisitSetting[i].Typ == VisitNum then    
                VisitNum = i
                break
            end
        end
        local VisitPrivilege =  VisitSetting[VisitNum].Value
        if VisitPrivilege == 1 then
            CanVisited = true
        elseif VisitPrivilege == 2 then
            if HouseType == HouseLocalDef.BuyHouseBelongType.Army then
                CanVisited = IsSameArmy
            else
                CanVisited = IsFriend or IsMe
            end
        elseif VisitPrivilege == 3 then
            CanVisited = IsCanVisitRoommate or IsMe
        end
    end

    return CanVisited
end

-- 设置当前打开的地图数据
---@param ResidenceNumber number @住宅区号
---@param AreaNumber number @小区号
---@param SubAreaNumber number @初始区/扩建区
function HouseLandMgr:SetCurOpenMapData(ResidenceNumber, AreaNumber, SubAreaNumber)
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
    self.CurMapData = {
        WorldID = CurWorldID or 0,
        ResidenceNumber = ResidenceNumber or 1,
        AreaNumber = AreaNumber or 1,
        SubAreaNumber = SubAreaNumber or 1
    }
    self:SendLandQueryArea(self.CurMapData.ResidenceNumber, self.CurMapData.AreaNumber, self.CurMapData.SubAreaNumber,
        0, {}, HouseLocalDef.LandQuerySceneType.MapLand)
end

-- 打开未出售土地列表界面
function HouseLandMgr:OpenLandListWin(ResidenceNumber, AreaNumber)
    local Params = {}
    Params.ResidenceNumber = ResidenceNumber or 1
    Params.AreaNumber = AreaNumber or 1
    Params.SubAreaNumber = self.CurMapData.AreaNumber or 1 
    Params.LandNumberList = nil
    UIViewMgr:ShowView(UIViewID.HouseLandListWinView, Params)
end

-- 打开最近的传送点
function HouseLandMgr:ShowWorldMapHouseLand(ResidenceNumber, AreaNumber, LandNumber)
    _G.WorldMapMgr:ShowWorldMapHouseLand(HouseLandMgr:GetMapID(ResidenceNumber), AreaNumber, LandNumber)
end

-- 打开房屋土地相关界面
---@param TabIndex:HouseTabIndex 
---@param SubTabIndex:HouseEntranceType
---@param OpenByArmy bool
function HouseLandMgr:OpenHouseLandMianPanle(TabIndex, SubTabIndex, OpenByArmy)
    local Params = {}
    Params.TabIndex = TabIndex or 1
    Params.SubTabIndex = SubTabIndex or 1
    if OpenByArmy then
        _G.HouseLandMianPanelVM:SetCurBuyConditionsBelongType(HouseLocalDef.BuyHouseBelongType.Army)
    else
        _G.HouseLandMianPanelVM:SetCurBuyConditionsBelongType(HouseLocalDef.BuyHouseBelongType.Personal)
    end

    UIViewMgr:ShowView(UIViewID.HouseLandMianPanelView, Params)
end

-- 打开房屋列表界面
function HouseLandMgr:OpenMapHouseListPanel(ResidenceNumber, IsIgnoreUnlock)
    local Params = {}
    Params.ResidenceNumber = ResidenceNumber or 1
    Params.Params = IsIgnoreUnlock
    -- 2.2版本屏蔽 UIViewMgr:ShowView(UIViewID.HouseInfoLocationPanelView, Params)
end

-- 打开房屋资料或者土地资料界面
function HouseLandMgr:OpenHouseOrLandPanel(LandInfo)
    if not LandInfo or not next(LandInfo) then
        FLOG_ERROR("Empty LandInfo OpenHouseOrLandPanel")
        return
    end

    if self:LandIsHouse(LandInfo) then
        local Params = {}
        Params.HouseID = LandInfo.HouseID
        UIViewMgr:ShowView(UIViewID.HouseOthersInfoPanelView, Params)
    else
        local Params = {}
        Params.ResidenceNumber = LandInfo.ResidenceNumber
        Params.AreaNumber = LandInfo.AreaNumber
        Params.LandNumberList = {LandInfo.LandNumber}
        Params.GroupID = LandInfo.GroupID
        UIViewMgr:ShowView(UIViewID.HouseLandInformationPanel, Params)
    end
end

-- 打开建房界面
function HouseLandMgr:OpenBuildHousePanel(LandInfo)
    local Params = {}
    Params.ResidenceNumber = LandInfo.ResidenceNumber
    Params.AreaNumber = LandInfo.AreaNumber
    Params.LandNumber = LandInfo.LandNumber
    UIViewMgr:ShowView(UIViewID.HouseStyleWinView, Params)
end

function HouseLandMgr:GetDisCountMoney(MoneyType)
    local Money = 0
    local DiscountInfo = _G.HouseLandMianPanelVM.Discount
    if DiscountInfo then
        for k, v in pairs(DiscountInfo) do
            if v.MoneyType == MoneyType then
                Money = v.Money
            end
        end
    end
    return Money
end

function HouseLandMgr:LandIsHouse(LandInfo)
    local IsHouse = LandInfo and LandInfo.HouseID ~= nil and  LandInfo.HouseID > 0
    return IsHouse
end

-- 自己的部队是否有未建房的土地
---@return IsNoBuild bool       @是否未建房
---@return SelectInfo table     @参选详情
---@return HasDestroy bool      @是否拆房了
function HouseLandMgr.GroupHasLandNoBuild()
    local CurPhaseCnt =  _G.HouseLandMianPanelVM.PhaseCnt
    local SelectInfo = _G.HouseLandMianPanelVM.LandSelectInfo and _G.HouseLandMianPanelVM.LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Army] or {}
    local LandInfo = SelectInfo.LandInfo
    local GroupID = _G.ArmyMgr:GetArmyID()
    local HasDestroyLand = _G.HouseInfoMgr:IsMajorArmyHouseDestroied()
    if not SelectInfo then return false end

    if HasDestroyLand then
        return true, SelectInfo, true
    else
        local IsNoBuild = _G.HouseInfoMgr.ArmyHouseID == 0 and SelectInfo.GroupID == GroupID and LandInfo and 
    LandInfo.GroupID == GroupID and SelectInfo.PhaseID == CurPhaseCnt and LandInfo.LandStatus >= ProtoCS.LandStatusType.LandStatusType_Public 
        return IsNoBuild, SelectInfo, false
    end
end

-- 自己是否有未建房的土地
---@return IsNoBuild bool       @是否未建房
---@return SelectInfo table     @参选详情
---@return HasDestroy bool      @是否拆房了
function HouseLandMgr.SelfHasLandNoBuild()
    local CurPhaseCnt =  _G.HouseLandMianPanelVM.PhaseCnt
    local SelectInfo = _G.HouseLandMianPanelVM.LandSelectInfo and _G.HouseLandMianPanelVM.LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Personal] or {}
    local IsPersonJoin =  _G.HouseLandMianPanelVM.CurBuyStateInfo.IsPersonJoin
    local LandInfo = SelectInfo.LandInfo
    local HasDestroyLand = _G.HouseInfoMgr:IsPersonalHouseDestroied()
    if not SelectInfo then return false end

    if HasDestroyLand then
        return true, SelectInfo, true
    else
        local IsNoBuild = IsPersonJoin and _G.HouseInfoMgr.MajorHouseID == 0 and SelectInfo.AplStatus == ProtoCS.ApplyStatus.ApplyStatus_Award 
    and SelectInfo.PhaseID == CurPhaseCnt and LandInfo and LandInfo.Owner == MajorUtil.GetMajorRoleID()
        return IsNoBuild, SelectInfo, false
    end
end

function HouseLandMgr:IsSameLandList(LandList1, LandList2)
    if LandList1 == nil or LandList2 == nil then
        return false
    end
    local IsSame = LandList1.ResidenceNumber == LandList2.ResidenceNumber and LandList1.AreaNumber ==
                       LandList2.AreaNumber and LandList1.LandNumber == LandList2.LandNumber and LandList1.WorldID ==
                       LandList2.WorldID
    return IsSame
end

-- 房屋状态信息
function HouseLandMgr:GetHouseStateInfo(LandInfo)
    local Index = 1
    local IconPath = ""
    local HouseInfo = HouseLocalDef.HouseTypeInfo[Index]
    local IsFriend = false
    local IsHouse = LandInfo.LandStatus == ProtoCS.LandStatusType.LandStatusType_Built or 
            LandInfo.LandStatus == ProtoCS.LandStatusType.LandStatusType_Destroy
    if IsHouse then
        local CanVisited = true
        local VisitPrivilege = LandInfo.VisitPrivilege
        local BeShared = LandInfo.IsRoommate or false
        local IsArmyHouse = LandInfo.GroupID > 0
        local OwnerRoleID = LandInfo.Owner
        local MajorID = MajorUtil.GetMajorRoleID()
        local IsMyArmy = ArmyMgr.SelfArmyID == LandInfo.GroupID and ArmyMgr.SelfArmyID > 0
        local IsMe = MajorID == OwnerRoleID
        local IsRoommate = LandInfo.IsRoommate -- 是否是该房屋属主的室友
        IsFriend = FriendMgr:IsFriend(OwnerRoleID)

        if VisitPrivilege == ProtoCS.HouseVisitSettingValue.HouseVisitSettingValue_All then
            CanVisited = true
        elseif VisitPrivilege == ProtoCS.HouseVisitSettingValue.HouseVisitSettingValue_Friend then
            if IsArmyHouse then
                CanVisited = IsMyArmy
            else
                CanVisited = IsFriend or IsMe
            end
        elseif VisitPrivilege == ProtoCS.HouseVisitSettingValue.HouseVisitSettingValue_Roommate then
            CanVisited = IsRoommate or IsMe
        end

        if IsMe and not IsArmyHouse then
            Index = HouseLocalDef.HouseType.MyPersonalHouse
        end
        if IsMyArmy and IsArmyHouse then
            Index = HouseLocalDef.HouseType.MyArmyHouse
        end
        if CanVisited and not IsArmyHouse and not IsMe then
            Index = HouseLocalDef.HouseType.CanVisitPersonalHouse
        end
        if CanVisited and IsArmyHouse and not IsMyArmy then
            Index = HouseLocalDef.HouseType.CanVisitArmyHouse
        end
        if not CanVisited and not IsArmyHouse then
            Index = HouseLocalDef.HouseType.CanNotVisitPersonalHouse
        end
        if not CanVisited and IsArmyHouse then
            Index = HouseLocalDef.HouseType.CanNotVisitArmyHouse
        end
        if BeShared then
            Index = HouseLocalDef.HouseType.ShareHouse
        end
        HouseInfo = HouseLocalDef.HouseTypeInfo[Index]
        IconPath = string.format(HouseLocalDef.LocationHouseIconPath, HouseLocalDef.LandSizeTypeStr[LandInfo.LandSize],
            HouseInfo.IconIndex, HouseLocalDef.LandSizeTypeStr[LandInfo.LandSize], HouseInfo.IconIndex)
    else
        Index = LandInfo.LandStatus
        HouseInfo = HouseLocalDef.HouseTypeInfo[Index]
        IconPath = string.format(HouseLocalDef.LocationLandIconPath, HouseInfo.IconIndex, HouseInfo.IconIndex)
    end
    HouseInfo.IconPath = IconPath
    HouseInfo.IsHouse = IsHouse
    HouseInfo.IsFriend = IsFriend
    HouseInfo.IsShareHouse = Index == HouseLocalDef.HouseType.ShareHouse
    HouseInfo.IsMyHouse = Index == HouseLocalDef.HouseType.MyPersonalHouse or Index ==
                              HouseLocalDef.HouseType.MyArmyHouse
    HouseInfo.IsFriendHouse = IsFriend
    return HouseInfo
end

function HouseLandMgr:OnNetMsgRoleLoginRes()
    --处理登录后需要拉取的土地数据
    self.MajorRoleID =  MajorUtil.GetMajorRoleID()
    _G.HouseLandMianPanelVM.LandSelectInfo = nil
    self:DelayQueryBuyStatus(nil, false)
end

function HouseLandMgr:OnNetMsgLoot(MsgBody)
    if MsgBody and MsgBody.Reason and (MsgBody.Reason == "role.house.buyLandReturn" or MsgBody.Reason == "house.recycle") then
        local LOOT_TYPE = ProtoCS.LOOT_TYPE
        local ItemList = {}
        for k, v in pairs(MsgBody.LootList) do
            if v.Type == LOOT_TYPE.LOOT_TYPE_ITEM then 
                table.insert(ItemList, {ResID = v.Item.ResID, Num = v.Item.Value})
            elseif v.Type == LOOT_TYPE.LOOT_TYPE_SCORE then 
                table.insert(ItemList, {ResID = v.Score.ResID, Num = v.Score.Value})
            end
        end
        if next(ItemList) then
            _G.EventMgr:SendEvent(_G.EventID.HouseReciveReturnMoney)
            UIViewMgr:ShowView(UIViewID.CommonRewardPanel, {ItemList = ItemList})
        end
    end
end

-- 协议文件参考 land.proto
------------------------------------------------Land NetMsg Start-----------------------------------------------

-- 查询小区土地列表
---@param ResidenceNumber number @住宅区号
---@param AreaNumber number @小区号
---@param SubAreaNumber number @初始区/扩建区
---@param LandNumberList number[] @土地号列表
---@param Landstatus number @房屋状态
---@param SceneType number @请求场景
function HouseLandMgr:SendLandQueryArea(ResidenceNumber, AreaNumber, SubAreaNumber, LandStatus, LandNumberList,
    SceneType)
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_QUERY_AREA
    local MsgID = CS_CMD.CS_CMD_LAND
    local MsgBody = {
        SubCmd = SubMsgID,
        GetLandList = {
            WorldID = CurWorldID,
            ResidenceNumber = ResidenceNumber,
            AreaNumber = AreaNumber,
            SubAreaNumber = SubAreaNumber or 0,
            LandStatus = LandStatus or 0,
            LandNumberList = LandNumberList or nil,
            SceneType = SceneType
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody,0,AreaNumber)
end

function HouseLandMgr:RspLandQueryArea(MsgBody)
    local LandListData = MsgBody.GetLandList.LandList or {}
    local Num = #LandListData

    local CurLandList = {}
    local SceneType = MsgBody.GetLandList.SceneType
    for i = 1, Num do
        local LandItemData = LandListData[i]
        local LandItem = LandItemData
        LandItem.LandSizeStr = HouseLocalDef.LandSizeTypeStr[LandItemData.LandSize]
        LandItem.ResidenceNumber = MsgBody.GetLandList.ResidenceNumber
        LandItem.AreaNumber = MsgBody.GetLandList.AreaNumber
        table.insert(CurLandList, LandItem)
    end

    self.ReleaseLands = MsgBody.GetLandList.ReleaseLand

    if SceneType == HouseLocalDef.LandQuerySceneType.LandList then
        self.CurLandListData = MsgBody.GetLandList
        self.CurLandListData.LandListHandleData = CurLandList
        _G.EventMgr:SendEvent(_G.EventID.HouseLandListUpdate)
    end

    if SceneType == HouseLocalDef.LandQuerySceneType.HouseList then
        self.CurLandListData = MsgBody.GetLandList
        self.CurLandListData.LandListHandleData = CurLandList
        _G.EventMgr:SendEvent(_G.EventID.HouseListLocationUpdate, CurLandList)
    end

    if self:IsSameLandList(self.CurMapData, MsgBody.GetLandList) and SceneType ==
        HouseLocalDef.LandQuerySceneType.MapLand then
        self.CurMapLandList = CurLandList
        self.CurLandListData = MsgBody.GetLandList
        self.CurLandListData.LandListHandleData = CurLandList
        _G.EventMgr:SendEvent(_G.EventID.HouseLandMapDataUpdate, CurLandList)
    end

    if SceneType == HouseLocalDef.LandQuerySceneType.LandInfo then
        if _G.HouseLandMianPanelVM.LandSelectInfo then
            for i, v in ipairs(_G.HouseLandMianPanelVM.LandSelectInfo) do
                for k, j in ipairs(MsgBody.GetLandList.LandList) do
                    if j.ResidenceNumber == v.ResidenceNumber and j.AreaNumber == v.AreaNumber and j.LandNumber == v.LandNumber then
                        _G.HouseLandMianPanelVM.LandSelectInfo[i].LandInfo = j
                        break
                    end
                end
            end
        end

        _G.EventMgr:SendEvent(_G.EventID.HouseLandInfoUpdate, MsgBody.GetLandList)
    end
end

function HouseLandMgr:DelayQueryBuyStatus(PhaseID, IsDelay)
    if IsDelay then
        self:RegisterTimer(function()
            self:SendQueryBuyStatus(PhaseID)
        end, math.random(3, 5), 0, 1)
    else
        self:SendQueryBuyStatus(PhaseID)
    end
end

-- 查询购房状态信息 PhaseID=0:查询当前期
function HouseLandMgr:SendQueryBuyStatus(PhaseID)
    local MsgID = CS_CMD.CS_CMD_LAND
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_QUERY_BUY_STATUS
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.QueryBuyStatus = {
        PhaseID = PhaseID
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function HouseLandMgr:RspQueryBuyStatus(MsgBody)
    _G.HouseLandMianPanelVM:SetBuyStatus(MsgBody.QueryBuyStatus)
    _G.EventMgr:SendEvent(_G.EventID.LandBuyStatusNotify, MsgBody.QueryBuyStatus)
end

-- 收藏/取消收藏
function HouseLandMgr:SendCollectLandReq(ResidenceNumber, AreaNumber, LandNumber, IsCollect)
    local MsgID = CS_CMD.CS_CMD_LAND
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_COLLECT_LAND
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()

    local MsgBody = {
        SubCmd = SubMsgID,
        CollectLand = {
            WorldID = CurWorldID or 0,
            ResidenceNumber = ResidenceNumber,
            AreaNumber = AreaNumber,
            LandNumber = LandNumber,
            IsCollect = IsCollect
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody,0,AreaNumber)
end

function HouseLandMgr:RspCollectLand(MsgBody)
    if MsgBody and MsgBody.CollectLand then
        local Data = MsgBody.CollectLand
        if self.CurLandListData and self.CurLandListData.LandList then
            for i, v in ipairs(self.CurLandListData.LandList) do
                if v.ResidenceNumber == Data.ResidenceNumber and v.LandNumber == Data.LandNumber and v.AreaNumber == Data.AreaNumber then
                    self.CurLandListData.LandList[i].IsCollect = not self.CurLandListData.LandList[i].IsCollect
                    _G.EventMgr:SendEvent(_G.EventID.HouseLandListUpdate)
                    break
                end
            end
        end
    end
end

-- 参选土地
function HouseLandMgr:SendBuyLandReq(ResidenceNumber, AreaNumber, LandNumber, AplType)
    local MsgID = CS_CMD.CS_CMD_LAND
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_BUY_LAND
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()

    local MsgBody = {
        SubCmd = SubMsgID,
        BuyLand = {
            WorldID = CurWorldID or 0,
            ResidenceNumber = ResidenceNumber,
            AreaNumber = AreaNumber,
            LandNumber = LandNumber,
            AplType = AplType
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody,0,AreaNumber)
end

-- message BuyLandRsp {
--     int32 WorldID = 1;  // 区服ID
--     Residence ResidenceNumber = 2;  // 住宅区号
--     int32 AreaNumber = 3;  // 小区号
--     int32 LandNumber = 4;  // 土地号
--     ApplyType AplType = 5; // 个人申请/部队申请
--     int32 ApplyNumber = 6; // 参选号码
--     int32 ApplyCount = 7; // 参选人数
--     int32 RetCode = 8; // 参选结果
--     int64 ShowTime = 9; // 公示时间
--   }
function HouseLandMgr:RspBuyLand(MsgBody)
    if MsgBody and MsgBody.BuyLand and MsgBody.BuyLand.RetCode then
        local BuyLand = MsgBody.BuyLand
        if BuyLand.RetCode == 0 then
            local Type = HouseLocalDef.BuyHouseBelongType.Personal
            local LatestApply = {
                ResidenceNumber = BuyLand.ResidenceNumber,
                AreaNumber = BuyLand.AreaNumber,
                LandNumber = BuyLand.LandNumber,
                PhaseID = _G.HouseLandMianPanelVM.PhaseCnt,
                ApplyNumber = BuyLand.ApplyNumber,
                AplStatus = ProtoCS.ApplyStatus.ApplyStatus_Apply,
                GroupID = ProtoCS.ApplyType.ApplyType_Personal == BuyLand.AplType and 0 or _G.ArmyMgr:GetArmyID()
            }
            _G.HouseLandMianPanelVM:UpdateLandSelectInfo(Type, LatestApply)
            _G.EventMgr:SendEvent(_G.EventID.HouseLandSelectRet, BuyLand)
            self:DelayQueryBuyStatus(nil, true)
        else
            if BuyLand.RetCode == 360001 and BuyLand.AplType == ProtoCS.ApplyType.ApplyType_Team then
                local ProtoRes = require("Protocol/ProtoRes")
                local IsPremission = _G.ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.PermissionTypeEstatePurchaseLandAndBuild)
                if not IsPremission then
                    _G.MsgTipsUtil.ShowTips(HouseLocalDef.GroupAplNoPermission)
                    return
                end
            end

            _G.MsgTipsUtil.ShowTipsByID(BuyLand.RetCode)
        end
    end
end

-- 建房
function HouseLandMgr:SendBuildHouseReq(Params)
    local MsgID = CS_CMD.CS_CMD_LAND
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_BUILD_HOUSE
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()

    local MsgBody = {
        SubCmd = SubMsgID,
        BuildHouse = {
            WorldID = CurWorldID or 0,
            ResidenceNumber = Params.ResidenceNumber,
            AreaNumber = Params.AreaNumber,
            LandNumber = Params.LandNumber,
            HouseType = Params.HouseType,
            ResID = Params.ResID,
            ItemID = Params.ItemID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody,0,Params.AreaNumber)
end

-- int32 WorldID = 1;  // 区服ID
-- Residence ResidenceNumber = 2;  // 住宅区号
-- int32 AreaNumber = 3;  // 小区号
-- int32 LandNumber = 4;  // 土地号
-- int32 HouseType  = 5;  // 房屋类型
-- int32 ItemID = 6;  // 消耗的房屋道具ID
-- int32 Result = 7; // 建房结果
-- uint64 HouseID = 8; // 房屋ID
function HouseLandMgr:RspBuildHouse(MsgBody)
    if MsgBody.BuildHouse.Result == 0 then
        if MsgBody.BuildHouse.HouseType == ProtoCS.HouseType.HouseType_HouseType_Personal then
            _G.HouseInfoMgr:SendHouseRoleInfo()
        else
            local ArmyID = _G.ArmyMgr:GetArmyID()
            if ArmyID and ArmyID > 0 then
                _G.HouseInfoMgr:SendGroupHouseInfo(ArmyID)
            end
        end

        local SequenceID = 21600133
        _G.StoryMgr:PlayHousingSequence(SequenceID, nil, MsgBody.BuildHouse.LandNumber)  -- 播放建房成功动画
        _G.EventMgr:SendEvent(_G.EventID.HouseBuildNotify, MsgBody.BuildHouse.HouseID)
        self:DelayQueryBuyStatus(nil, true)
        self:UpdateCahceByBuildOrAbandon(true, MsgBody.BuildHouse)
    else
        _G.MsgTipsUtil.ShowTipsByID(MsgBody.BuildHouse.Result)
    end
end

function HouseLandMgr:UpdateCahceByBuildOrAbandon(IsBuild, MsgBody)
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
    local BaseInfo = _G.PWorldMgr.BaseInfo
    if not MapUtil.IsHouseMap(BaseInfo.CurrMapResID) or not CurWorldID == MsgBody.WorldID then return end
    local HouseRegionID = HouseUtil.GetEstateID()
    local HouseAreaID = HouseUtil.GetCurrentAreaSubID()
    if HouseRegionID == MsgBody.ResidenceNumber and HouseAreaID == MsgBody.AreaNumber and self.CurLandListData and self.CurLandListData.LandList then
        for i, v in ipairs(self.CurLandListData.LandList) do
            if v.ResidenceNumber == MsgBody.ResidenceNumber and v.AreaNumber == MsgBody.AreaNumber and v.LandNumber == MsgBody.LandNumber then
                if self.CurLandListData.LandListHandleData and self.CurLandListData.LandListHandleData[i] then
                    self.CurLandListData.LandListHandleData[i].HouseID = IsBuild and MsgBody.HouseID or 0
                end

                if self.CurMapLandList and self.CurMapLandList[i] then
                    self.CurMapLandList[i].HouseID = IsBuild and MsgBody.HouseID or 0
                end

                if self.CurLandListData.LandList and self.CurLandListData.LandList[i] then
                    self.CurLandListData.LandList[i].HouseID = IsBuild and MsgBody.HouseID or 0
                end
                break
            end
        end

        if self.CurMapLandList and next(self.CurMapLandList) then
            _G.EventMgr:SendEvent(_G.EventID.HouseLandMapDataUpdate, self.CurMapLandList)
        end
    end

    self:RegisterTimer(function()
        if MapUtil.IsHouseMap(BaseInfo.CurrMapResID)then
            local StreetID = BaseInfo.OwnerID & 0xFFFF
            self:SetCurOpenMapData(HouseRegionID, StreetID, HouseAreaID)
        end
    end, math.random(3, 5), 0, 1)
end

-- int32 WorldID = 1;  // 区服ID
-- Residence ResidenceNumber = 2;  // 住宅区号
-- int32 AreaNumber = 3;  // 小区号
-- int32 LandNumber = 4;  // 土地号
-- int32 Result = 5; // 建房结果
-- 放弃土地
function HouseLandMgr:SendAbandonLandReq(Params)
    local MsgID = CS_CMD.CS_CMD_LAND
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_ABANDON

    local MsgBody = {
        SubCmd = SubMsgID,
        AbandonLand = {
            WorldID = Params.WorldID or 0,
            ResidenceNumber = Params.ResidenceNumber,
            AreaNumber = Params.AreaNumber,
            LandNumber = Params.LandNumber
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody,0,Params.AreaNumber)
end

--   int32 WorldID = 1;  // 区服ID
--   Residence ResidenceNumber = 2;  // 住宅区号
--   int32 AreaNumber = 3;  // 小区号
--   int32 LandNumber = 4;  // 土地号
--   int32 Result = 5; // 建房结果
function HouseLandMgr:RspAbandonLand(MsgBody)
    if not MsgBody.AbandonLand then return end

    local Data = MsgBody.AbandonLand
    if Data.Result == 0 then
        _G.HouseInfoMgr:SendHouseRoleInfo()
        local ArmyID = _G.ArmyMgr:GetArmyID()
        if ArmyID and ArmyID > 0 then
            _G.HouseInfoMgr:SendGroupHouseInfo(ArmyID)
        end

        local AreaNumber = _G.MapMgr:GetStreetID()
        local EstateID = HouseUtil.GetEstateID()
        if AreaNumber == Data.AreaNumber and self.CurHouseBlockID == Data.LandNumber and EstateID == Data.ResidenceNumber then
            local Params = _G.EventMgr:GetEventParams()
            local EntityID = MajorUtil.GetMajorEntityID()
            Params.ULongParam1 = EntityID
            Params.IntParam1 = _G.LuaEntranceType.Land
            _G.EventMgr:SendEvent(_G.EventID.LeaveInteractionRange, Params)
        end

        self:UpdateCahceByBuildOrAbandon(false, Data)
        self:DelayQueryBuyStatus(nil, true)
        _G.EventMgr:SendEvent(_G.EventID.HouseAbandonLand)
    else
        _G.MsgTipsUtil.ShowTipsByID(Data.Result)
    end
end

-- 拆房
function HouseLandMgr:SendDestroyHouseReq(HouseID)
    local MsgID = CS_CMD.CS_CMD_LAND
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_DESTROY_HOUSE

    local MsgBody = {
        SubCmd = SubMsgID,
        DestroyHouse = {
            HouseID = HouseID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--   uint64 HouseID = 1; // 房屋ID
--   int32 Result = 2; // 销毁结果
function HouseLandMgr:RspDestroyHouse(MsgBody)
    if MsgBody.DestroyHouse.Result == 0 then
        _G.EventMgr:SendEvent(_G.EventID.HouseDestroyNotify, MsgBody.DestroyHouse.HouseID)
        local CurlandHouseID = HouseLandMgr:GetCurLandHouseID()
        if CurlandHouseID and CurlandHouseID == MsgBody.DestroyHouse.HouseID then
            local Params = _G.EventMgr:GetEventParams()
            local EntityID = MajorUtil.GetMajorEntityID()
            Params.ULongParam1 = EntityID
            local AreaNumber = _G.MapMgr:GetStreetID()
            local EstateID = HouseUtil.GetEstateID()
            Params.IntParam1 = _G.LuaEntranceType.Land
            Params.IntParam2 = EstateID
            Params.IntParam3 = AreaNumber
            Params.IntParam4 = self.CurHouseBlockID
            _G.EventMgr:SendEvent(_G.EventID.EnterInteractionRange, Params)
        end
    else
        _G.MsgTipsUtil.ShowTipsByID(MsgBody.DestroyHouse.Result)
    end
end

-- 领取返还资产
function HouseLandMgr:SendGetReturnAssetsReq(Params)
    local MsgID = CS_CMD.CS_CMD_LAND
    local SubMsgID = SUB_MSG_ID.CS_SUBMSGID_LAND_GET_RETURN_ASSET
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()

    local MsgBody = {
        SubCmd = SubMsgID,
        GetReturnAssets = {
            WorldID = CurWorldID or 0,
            ResidenceNumber = Params.ResidenceNumber,
            AreaNumber = Params.AreaNumber,
            LandNumber = Params.LandNumber,
            ApplyTy = Params.ApplyTy
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function HouseLandMgr:RspGetReturnAssets(MsgBody)
    if MsgBody and MsgBody.GetReturnAssets then
        local Result = MsgBody.GetReturnAssets.Result
        if Result ~= 0 then
            _G.MsgTipsUtil.ShowTipsByID(Result)
        else
            _G.HouseLandMianPanelVM.ReturnInfo = nil
            local PersonalType = HouseLocalDef.BuyHouseBelongType.Personal
            if _G.HouseLandMianPanelVM.LandSelectInfo and _G.HouseLandMianPanelVM.LandSelectInfo[PersonalType] then
                _G.HouseLandMianPanelVM.LandSelectInfo[PersonalType].ReturnMoney = 0
                _G.HouseLandMianPanelVM.LandSelectInfo[PersonalType].AplStatus = ProtoCS.ApplyStatus.ApplyStatus_Return
            end

            _G.EventMgr:SendEvent(_G.EventID.HouseGetReturnAssets)
            self:DelayQueryBuyStatus(nil, true)
        end
    end
end
------------------------------------------------Land NetMsg End-----------------------------------------------

-----------------------------------------------House NetMsg Start-----------------------------------------------

local function TransByType(Type, Params, WorldID)
    if not Params then
        FLOG_ERROR('TransByType Empty Params')
        return
    end

    local MsgID = CS_CMD.CS_CMD_HOUSE
    local SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_ESTATE
    local MsgBody = {}

    if Type == HouseLocalDef.LandTransmitType.Residence then  --- 进入住宅区
        SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_ESTATE
        MsgBody.SubCmd = SubMsgID
        MsgBody.EnterEstate = {
            WorldID = WorldID,
            EstateID = Params.ResidenceNumber or Params.EstateID,
            Area = Params.AreaNumber or Params.Area
        }
    end

    if Type == HouseLocalDef.LandTransmitType.House then
        SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_PERSONAL_ETHER --- 私有水晶传送
        MsgBody.SubCmd = SubMsgID
        MsgBody.EnterPersonalEther = {
            HouseID = Params.HouseID,
            ClientTag = Params.ClientTag
        }
    end

    if Type == HouseLocalDef.LandTransmitType.Land then
        SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_ESTATE_BLOCK  --- 传送进入地块（未建房可以传送）
        MsgBody.SubCmd = SubMsgID
        MsgBody.EnterEstateBlock = {
            WorldID = WorldID,
            Addr = {
                EstateID = Params.ResidenceNumber or Params.EstateID,
                Area = Params.AreaNumber or Params.Area,
                Number = Params.LandNumber or Params.Number
            }
        }
    end

    if Type == HouseLocalDef.LandTransmitType.Room then            -- 进入房屋房间
        SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_ENTER_ROOM
        MsgBody.SubCmd = SubMsgID
        MsgBody.EnterRoom = {
            HouseID = Params.HouseID
        }
    end

    if Type ~= HouseLocalDef.LandTransmitType.Room and not Params.IgnoreSing then
        local SingFinshCallback = function (IsBreak)
            if not IsBreak then
                GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
            end
        end

        local IsTranHouseCrystal = Type == HouseLocalDef.LandTransmitType.House
        local SingID = IsTranHouseCrystal and 2 or 40
        _G.SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(SingID, SingFinshCallback)
        if IsTranHouseCrystal then
            local MajorEntityID = MajorUtil.GetMajorEntityID()
            _G.SingBarMgr:InsertSecondSingInfoManually(MajorEntityID, 40)
        end
    else
         GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

function HouseLandMgr:TransHideView()
    UIViewMgr:HideView(UIViewID.HouseLandInformationPanel)
    UIViewMgr:HideView(UIViewID.HouseOthersInfoPanelView)
    UIViewMgr:HideView(UIViewID.HouseLandMianPanelView)
    UIViewMgr:HideView(UIViewID.HouseMineMainPanelView)
    UIViewMgr:HideView(UIViewID.HouseLandListWinView)
    UIViewMgr:HideView(UIViewID.WorldMapPanel)
end

function HouseLandMgr:LeaveHouse()
    local InDoorHouseID = _G.HousingMgr:GetIndoorHouseID()
    if InDoorHouseID then
        local MsgID = CS_CMD.CS_CMD_HOUSE
        local SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_LEAVE_ROOM
        local MsgBody = {}
        MsgBody.SubCmd = SubMsgID
        MsgBody.LeaveRoom = {
            HouseID = InDoorHouseID
        }
        GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    else
        FLOG_ERROR("Empty IndoorHouseID")
    end
end

-- 土地传送
function HouseLandMgr:SendLandTransmit(Type, Params)
    if _G.PWorldMgr:CurrIsInDungeon() then
        _G.MsgTipsUtil.ShowTips(HouseLocalDef.CantTransInPworld)
        return
    end

    local WorldID = _G.PWorldMgr:GetCurrWorldID()
    if Params.HouseID and Params.HouseID ~= 0 then
        _G.HouseInfoMgr:QueryHouseDetail(Params.HouseID, function(Basic, Roommates)
            if Basic.WorldID ~= WorldID then
                WorldID = Basic.WorldID
                local Content = string.format(HouseLocalDef.OtherStr.CrossWorld, _G.LoginMgr:GetMapleNodeName(WorldID))
                CrossWorldUtil.CrossWorldWithoutCrtstal(WorldID, Content, "", nil, function()
                    self:RegisterTimer(function()
                        TransByType(Type, Params, WorldID)
                    end, 1, 0, 1)
                end)
            else
                TransByType(Type, Params, WorldID)
            end
        end)
    else
        TransByType(Type, Params, WorldID)
    end

    self:TransHideView()
end

function HouseLandMgr:RspLandTransmit(MsgBody)
    if MsgBody and MsgBody.EnterEstate then
        self:AfterTransRsp(MsgBody.EnterEstate.Area)
    end
end

function HouseLandMgr:RspEnterPEstateBlock(MsgBody)
    if MsgBody and MsgBody.EnterEstateBlock then
        local Addr = MsgBody.EnterEstateBlock.Addr
        self:AfterTransRsp(Addr.Area)
    end
end

function HouseLandMgr:RspEnterPersonalEther(MsgBody)
    if MsgBody.EnterPersonalEther then
        local Addr = MsgBody.EnterPersonalEther.Addr
        if MsgBody.EnterPersonalEther.NoEther then
            self:ShowWorldMapHouseLand(Addr.ResidenceNumber, Addr.AreaNumber, Addr.LandNumber)
        else
            self:AfterTransRsp(Addr.Area)
        end
    end
end

function HouseLandMgr:AfterTransRsp(Area)
    if Area and Area ~= 0 then
        _G.EventMgr:SendEvent(_G.EventID.HouseTransAreaChange, Area)
    end
end

-- 传送列表
function HouseLandMgr:SendTransferListReq(ResidenceNumber, AreaNumber, LandNumber, AplType)
    local MsgID = CS_CMD.CS_CMD_HOUSE
    local SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_PULL_HOUSE_DETAIL
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()

    local MsgBody = {
        SubCmd = SubMsgID,
        BuyLand = {
            WorldID = CurWorldID or 0,
            ResidenceNumber = ResidenceNumber,
            AreaNumber = AreaNumber,
            LandNumber = LandNumber,
            AplType = AplType
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function HouseLandMgr:RspTransferList(MsgBody)

end

-- 给房屋点赞
function HouseLandMgr:SendDoLikeReq(HouseID, IsLike)
    local MsgID = CS_CMD.CS_CMD_HOUSE
    local SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_DO_LINKE
    local MsgBody = {
        SubCmd = SubMsgID,
        DoLike = {
            HouseID = HouseID,
            IsLike = IsLike
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 拉取角色房屋地址（个人房、部队房、共享房)
function HouseLandMgr:SendPullRoleHouseAddr()
    local MsgID = CS_CMD.CS_CMD_HOUSE
    local SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_PULL_ROLE_HOUSE_ADDR
    local MsgBody = {
        SubCmd = SubMsgID,
        PullRoleHouseAddr = {
            GroupID = ArmyMgr.SelfArmyID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function HouseLandMgr:RspPullRoleHouseAddr(MsgBody)
    FLOG_INFO("HouseLandMgr:RspPullRoleHouseAddr")
    local RoleHouseList = {}

    if MsgBody.PullRoleHouseAddr.Personal then
        local Personal = MsgBody.PullRoleHouseAddr.Personal
        local House = {
            ID = Personal.HouseID,
            MapID = HouseLandMgr:GetMapID(Personal.Addr.EstateID),
            Type = 1,
            WorldID = Personal.WorldID,
            Addr = Personal.Addr,
            EtherGid = Personal.EtherGid
        }
        table.insert(RoleHouseList, House)
    end

    if MsgBody.PullRoleHouseAddr.Group then
        local Group = MsgBody.PullRoleHouseAddr.Group
        local House = {
            ID = Group.HouseID,
            MapID = HouseLandMgr:GetMapID(Group.ResidenceNumber),
            Type = 2,
            WorldID = Group.WorldID,
            Addr = Group.Addr,
            EtherGid = Group.EtherGid
        }
        table.insert(RoleHouseList, House)
    end

    if MsgBody.PullRoleHouseAddr.Shared then
        local Shared = MsgBody.PullRoleHouseAddr.Shared
        local House = {
            ID = Shared.HouseID,
            MapID = HouseLandMgr:GetMapID(Shared.ResidenceNumber),
            Type = 3,
            WorldID = Shared.WorldID,
            Addr = Shared.Addr,
            EtherGid = Shared.EtherGid
        }
        table.insert(RoleHouseList, House)
    end

    _G.EventMgr:SendEvent(_G.EventID.RoleHouseAddrListUpdate, RoleHouseList)
end

-- 查询房屋基础信息
function HouseLandMgr:SendPullHouseBasicInfo(HouseID)
    local MsgID = CS_CMD.CS_CMD_HOUSE
    local SubMsgID = HOUSESUB_MSG_ID.CS_SUBMSGID_HOUSE_PULL_HOUSE_BASIC
    local MsgBody = {
        SubCmd = SubMsgID,
        PullHouseBasic = {
            HouseIDs = {HouseID}
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody,0,self.MajorRoleID)
end

function HouseLandMgr:RspPullHouseBasicInfo(MsgBody)
    local HosueInfos = MsgBody.PullHouseBasic.Houses or {}
    if #HosueInfos == 1 then
        local Params = {}
        Params.VisitSetting = HosueInfos[1].VisitSetting
        Params.OwnerID = HosueInfos[1].OwnerID
        Params.HouseID = HosueInfos[1].HouseID
        local Roommates = {}
        if _G.HouseInfoMgr.SharedHouseID ~= nil and _G.HouseInfoMgr.SharedHouseID > 0 and _G.HouseInfoMgr.SharedHouseID ==
            HosueInfos[1].HouseID then
            table.insert(Roommates, {
                RoleID = MajorUtil.GetMajorRoleID()
            })
        end
        Params.CanVisited = HouseLandMgr.GetVisitPrivile(Params.OwnerID, Params.VisitSetting, Roommates,
            ProtoCS.HouseVisitSettingType.HouseVisitSettingType_Enter, HosueInfos[1].HouseType)
        _G.EventMgr:SendEvent(_G.EventID.HousePrivilegeUpdate, Params)
    end
end

--     uint64      HouseID  = 1;
--     HouseAddr   Addr     = 2;        // 房屋位置
function HouseLandMgr:RspDestroiedHouseBC(MsgBody)
    if not MsgBody or not MsgBody.DestoriedHouseBc then return end
    local HouseID = MsgBody.DestoriedHouseBc.HouseID
    local Addr = MsgBody.DestoriedHouseBc.Addr
    local Params = {
        EstateID = Addr.EstateID,
        Area = Addr.Area,
        Number = Addr.Number,
        IgnoreSing = true
    }

    local CurlandHouseID = HouseLandMgr:GetCurLandHouseID()
    if _G.PWorldMgr:CurrIsInHousingRoom() and HouseID == _G.HousingMgr.IndoorHouseID then
        self:SendLandTransmit(HouseLocalDef.LandTransmitType.Land, Params)
        _G.MsgTipsUtil.ShowTips(HouseLocalDef.HouseHadDestroied)
    elseif self.CurHouseBlockID == Addr.Number and CurlandHouseID == HouseID then
        _G.MsgTipsUtil.ShowTips(HouseLocalDef.HouseHadDestroied)
        self:SendLandTransmit(HouseLocalDef.LandTransmitType.Land, Params)
    elseif _G.HouseInfoMgr.VisitInDoorGroupID ~= 0 and _G.HouseInfoMgr.VisitInDoorGroupID == _G.ArmyMgr:GetArmyID() and _G.HouseInfoMgr.ArmyHouseID == HouseID then
        self:SendLandTransmit(HouseLocalDef.LandTransmitType.Land, Params)
       _G.MsgTipsUtil.ShowTips(HouseLocalDef.HouseHadDestroied)
    end
end
------------------------------------------------House NetMsg End-----------------------------------------------

function HouseLandMgr:OnEnterOrExitHouseBlock(Data)
    local ResidenceNumber = HouseLandMgr:GetResidenceNumber(_G.MapMgr:GetMapID())
    if not ResidenceNumber then return end
   
    self.CurHouseBlockID = Data and Data.BlockID or 0
    local GroupHasLandNoBuild, GroupLand = HouseLandMgr.GroupHasLandNoBuild()
    local SelfHasLandNoBuild, SelfLand = HouseLandMgr.SelfHasLandNoBuild()
    local HasLandNoBuild = SelfHasLandNoBuild or GroupHasLandNoBuild
    local AreaNumber = _G.MapMgr:GetStreetID()
    local Params = _G.EventMgr:GetEventParams()
    local EntityID = MajorUtil.GetMajorEntityID()
    Params.ULongParam1 = EntityID
    if Data and Data.BlockID > 0 and HasLandNoBuild then
        local LandInfo = {
            ResidenceNumber = ResidenceNumber,
            AreaNumber = AreaNumber,
            LandNumber = Data.BlockID
        }
        local IsSameLand = HouseLandMgr:IsSameLandList(LandInfo, GroupLand) or
                               HouseLandMgr:IsSameLandList(LandInfo, SelfLand)
        if IsSameLand then
            Params.IntParam1 = _G.LuaEntranceType.Land
            Params.IntParam2 = ResidenceNumber
            Params.IntParam3 = AreaNumber
            Params.IntParam4 = Data.BlockID
            _G.EventMgr:SendEvent(_G.EventID.EnterInteractionRange, Params)
        end
    else
        Params.IntParam1 = _G.LuaEntranceType.Land
        _G.EventMgr:SendEvent(_G.EventID.LeaveInteractionRange, Params)
    end

    local Major = MajorUtil.GetMajor()
    if Data and Data.BlockID > 0 then
		if Major then
            self:RegisterGameEvent(_G.EventID.MajorCollide, self.OnGameEventMajorCollide)
			Major:RegisterActorCollideEvent()
		end
    else
        if Major then
            self:UnRegisterGameEvent(_G.EventID.MajorCollide, self.OnGameEventMajorCollide)
            Major:UnRegisterActorCollideEvent()
        end
    end
end

function HouseLandMgr:OnGameEventMajorCollide(EventParams)
    local HitName = EventParams.StringParam1
    local IsInside = false
     if self.CurHouseBlockID ~= 0  then
        local AllSgActors = _G.UE.TArray(_G.UE.ASgLayoutActorBase)
        _G.UE.UGameplayStatics.GetAllActorsOfClass(FWORLD(),  _G.UE.ASgLayoutActorBase.StaticClass(), AllSgActors)
        local DynamicAssetCnt = AllSgActors:Length()
        for i = 1, DynamicAssetCnt, 1 do
            local SgActor = AllSgActors:Get(i)
            if SgActor:GetName() == HitName then
                local CollisionComponent = SgActor:GetComponentByClass(_G.UE.USgBoxComponent)
                if (CollisionComponent == nil) then return end

                local Major = MajorUtil.GetMajor()
                if (Major == nil) then return end
                -- local Radus = Major:GetCapsuleRadius()
                local MajorLocation = Major:FGetActorLocation()
                if (MajorLocation == nil) then return end

                local BoxTransform = CollisionComponent:K2_GetComponentToWorld()
                local BoxExtent  = CollisionComponent:GetScaledBoxExtent()
                local InvBoxTransform = BoxTransform:Inverse()
                local PlayerLocalLocation = InvBoxTransform:TransformPosition(MajorLocation)
                IsInside = math.abs(PlayerLocalLocation.X) <= BoxExtent.X and
                math.abs(PlayerLocalLocation.Y) <= BoxExtent.Y and
                math.abs(PlayerLocalLocation.Z) <= BoxExtent.Z
                break
            end
        end

        if IsInside then
            local Params = {
                EstateID = self.CurMapData.ResidenceNumber,
                Area = self.CurMapData.AreaNumber,
                Number =self.CurHouseBlockID,
                IgnoreSing = true
            }
            _G.MsgTipsUtil.ShowTips(HouseLocalDef.HouseHadDestroied)
            self:SendLandTransmit(HouseLocalDef.LandTransmitType.Land, Params)
        end
    end
end

function HouseLandMgr:GetCurLandHouseID()
    local ResidenceNumber = HouseLandMgr:GetResidenceNumber(_G.MapMgr:GetMapID())
    local AreaNumber = _G.MapMgr:GetStreetID()
    if self.CurHouseBlockID == 0 then
        return 0
    else
        if not next(self.CurMapLandList) then
            FLOG_ERROR("Cur Map Not Init")
        else
            for i, v in pairs(self.CurMapLandList) do
                if v.AreaNumber == AreaNumber and v.ResidenceNumber == ResidenceNumber and v.LandNumber == self.CurHouseBlockID then
                    return v.HouseID
                end
            end
        end
    end
end

local function GetHouseIDByAddr(ResidenceNumber, AreaNumber, LandNumber)
    local CurListData = HouseLandMgr.CurLandListData
    if not next(CurListData) then 
        FLOG_ERROR("GetHouseIDByAddr CurListData Error ")
        return 0 
    end

    if CurListData.ResidenceNumber == ResidenceNumber and CurListData.AreaNumber == AreaNumber  then
        for i, v in ipairs(CurListData.LandList) do
            if v.LandNumber == LandNumber then
                return v.HouseID
            end
        end
    end

    return 0
end

---- 仅作门牌交互
function HouseLandMgr:OnOpenHouseOrLandInfoPanel(Data)
    local ResidenceNumber = HouseLandMgr:GetResidenceNumber(_G.MapMgr:GetMapID())
    if ResidenceNumber == nil then
        return
    end
    local AreaNumber = _G.MapMgr:GetStreetID()
    local LandNumber = Data ~= nil and Data or 0

    local LandInfo = {
        ResidenceNumber = ResidenceNumber,
        AreaNumber = AreaNumber,
        LandNumber = LandNumber
    }

    LandInfo.HouseID = GetHouseIDByAddr(ResidenceNumber,AreaNumber,LandNumber)
    HouseLandMgr:OpenHouseOrLandPanel(LandInfo)
end

function HouseLandMgr:OnPWorldReady()
    local BaseInfo = _G.PWorldMgr.BaseInfo
    local CurrMapResID = BaseInfo.CurrMapResID
    if MapUtil.IsHouseMap(CurrMapResID)then
        local StreetID = BaseInfo.OwnerID & 0xFFFF
        local SubArea = HouseUtil.GetCurrentAreaSubID()
        local EstateID = HouseUtil.GetEstateID()
        self:SetCurOpenMapData(EstateID, StreetID, SubArea)
    end
end

function HouseLandMgr:OnPWorldTransBegin(IsOnlyChangeLocation)
    if IsOnlyChangeLocation then 
        local BaseInfo = _G.PWorldMgr.BaseInfo
        local CurrMapResID = BaseInfo.CurrMapResID
        if MapUtil.IsHouseMap(CurrMapResID)then
            local CrystalPortalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
            CrystalPortalMgr:PlayTransferInEffect(MajorUtil.GetMajorEntityID())
        end
    end
end

function HouseLandMgr:OnPWorldMapEnter()
    local BaseInfo = _G.PWorldMgr.BaseInfo
    local CrystalPortalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
    local CurrMapResID = BaseInfo.CurrMapResID
    if MapUtil.IsHouseMap(CurrMapResID) and not CrystalPortalMgr.IsCurrentTransfer  then
        CrystalPortalMgr:PlayTransferInEffect(MajorUtil.GetMajorEntityID())
    end
end

--- 当前区域主角是否拥有个人房屋
function HouseLandMgr:IsCurAreaHasMajorPersonalHouse()
    if _G.HouseInfoMgr.MajorHouseID == 0 then return false end
 
    if not _G.HouseInfoMgr.MajorHouseInfo.PersonalHouse or not _G.HouseInfoMgr.MajorHouseInfo.PersonalHouse.Basic then
        return false
    end

    local Addr = _G.HouseInfoMgr.MajorHouseInfo.PersonalHouse.Basic.Addr
    if not Addr.EstateID then return false end
    local HouseRegionID = MapUtil.GetCurrHouseRegionID()
    if Addr.EstateID ~= HouseRegionID then
        return false
    end

    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
    local WorldID = _G.HouseInfoMgr.MajorHouseInfo.PersonalHouse.Basic.WorldID
    if WorldID ~= CurWorldID then
        return false
    end

    return true
end

--- 传送至主角个人房屋
function HouseLandMgr:TransToMajorPersonalHouse()
    if not next(_G.HouseInfoMgr.MajorHouseInfo) then 
        FLOG_ERROR("HouseLandMgr:TransToMajorPersonalHouse()")
        return
    end

    local AddrData = _G.HouseInfoMgr.MajorHouseInfo.PersonalHouse.Basic.Addr
    local Params = {
        ResidenceNumber = AddrData.EstateID,
        AreaNumber = AddrData.Area,
        HouseID = _G.HouseInfoMgr.MajorHouseID,
    }
    self:SendLandTransmit(HouseLocalDef.LandTransmitType.Residence, Params)
end

--- 当前区域主角是否拥有部队房屋
function HouseLandMgr:IsCurAreaHasMajorArmyHouse()
    if _G.HouseInfoMgr.ArmyHouseID == 0 then return false end

    if not _G.HouseInfoMgr.MajorArmyHouseInfo.HouseDetail or not _G.HouseInfoMgr.MajorArmyHouseInfo.HouseDetail.Basic then
        return false
    end

    local Addr = _G.HouseInfoMgr.MajorArmyHouseInfo.HouseDetail.Basic.Addr
    if not Addr.EstateID then return false end

    local HouseRegionID = MapUtil.GetCurrHouseRegionID()
    if Addr.EstateID ~= HouseRegionID then
        return false
    end

    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
    local WorldID = _G.HouseInfoMgr.MajorArmyHouseInfo.HouseDetail.Basic.WorldID
    if WorldID ~= CurWorldID then
        return false
    end

    return true
end

--- 传送至主角部队房屋
function HouseLandMgr:TransToMajorArmyHouse()
    if not next(_G.HouseInfoMgr.MajorArmyHouseInfo) then 
        FLOG_ERROR("HouseLandMgr:TransToMajorArmyHouse()")
        return
    end

    local AddrData = _G.HouseInfoMgr.MajorArmyHouseInfo.HouseDetail.Basic.Addr
    local Params = {
        ResidenceNumber = AddrData.EstateID,
        AreaNumber = AddrData.Area,
        HouseID = _G.HouseInfoMgr.ArmyHouseID,
    }

    self:SendLandTransmit(HouseLocalDef.LandTransmitType.Residence, Params)
end

--- 根据当前地图区域 打开住宅区地图信息
function HouseLandMgr:OpenHouseInfoLocationViewByCurMap()
    local HouseRegionID = MapUtil.GetCurrHouseRegionID()
    if HouseRegionID and HouseRegionID ~= 0 then
        self:OpenMapHouseListPanel(HouseRegionID, true)
    else
        FLOG_ERROR("HouseLandMgr:OpenHouseInfoLocationViewByCurMap() 当前地图不存在住宅区映射关系")
    end
end

--- 当前最新期是否参与了土地抽选?
function HouseLandMgr:IsParticipatePersonalLandSelection(Type)
    local PhaseCnt = _G.HouseLandMianPanelVM.PhaseCnt
    if PhaseCnt == 0 or not _G.HouseLandMianPanelVM.LandSelectInfo then return false end
 
    local LandSelectionData = _G.HouseLandMianPanelVM.LandSelectInfo[Type] or {}
    if not LandSelectionData.PhaseID then return false end

    if LandSelectionData.PhaseID == PhaseCnt then
        return true
    end

    return false
end

--- 是否存在未建房后的土地回收补偿
function HouseLandMgr:IsHaveLandRecoveryCompensation(Type)
    if Type == HouseLocalDef.BuyHouseBelongType.Army then
        return false
    end

    local LandSelectionData = _G.HouseLandMianPanelVM.LandSelectInfo[Type] or {}
    if not LandSelectionData.ReturnMoney then return false end

    if LandSelectionData.ReturnMoney > 0 and LandSelectionData.AplStatus ~= ProtoCS.ApplyStatus.ApplyStatus_Return then
        return true
    end

    return false
end

--- 部队抽选是否为首抽
function HouseLandMgr:IsArmySelectionFirstJoin()
    local LandSelectionData = _G.HouseLandMianPanelVM.LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Army] or {}
    return not next(LandSelectionData)
end

--- 领取未中选返还资金
function HouseLandMgr:GetReturnAssets()
    local LandSelectInfo = _G.HouseLandMianPanelVM.LandSelectInfo
    local LatestApply = LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Personal] or {}
    if not next(LatestApply) then return end

    local IsReturn = LatestApply.ReturnMoney and LatestApply.ReturnMoney > 0 and LatestApply.AplStatus ~= ProtoCS.ApplyStatus.ApplyStatus_Return
    if IsReturn then
        local Params = {
            ResidenceNumber = LatestApply.ResidenceNumber,
            AreaNumber = LatestApply.AreaNumber,
            LandNumber = LatestApply.LandNumber,
            ApplyTy = LatestApply.GroupID == 0 and ProtoCS.ApplyType.ApplyType_Personal or ProtoCS.ApplyType.ApplyType_Team,
        }
        self:SendGetReturnAssetsReq(Params)
    else
        FLOG_ERROR("No Return")
    end
end

return HouseLandMgr
