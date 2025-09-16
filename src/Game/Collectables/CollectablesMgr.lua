---
--- Author: Leo
--- DateTime: 2023-05-04 12:23:31
--- Description: 收藏品系统
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CollectablesDefine = require("Game/Collectables/CollectablesDefine")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local CollectInfoCfg = require("TableCfg/CollectInfoCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local BagMgr = require("Game/Bag/BagMgr")
local SaveKey = require("Define/SaveKey")
local MajorUtil = require("Utils/MajorUtil")

local USaveMgr
local RedDotMgr
local LootMgr
local ActorMgr = _G.ActorMgr
local FVector2D = _G.UE.FVector2D
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_COLLECT_CMD
---@class CollectablesMgr : MgrBase
---@field DropFilterTabData table<number, table<number, string>> @下拉等级筛选数据
---@field LastSelectData table<number, number> @上次选择的各种数据
---@field ProfessionData table<number, table> @职业数据
---@field AllCollectionData table<number, table> @所有收藏品数据
---@field CEarLTickets number @当前低级大地票数
---@field MEarLTickets number @最大低级大地票数
---@field CEarHTickets number @当前高级大地票数
---@field MEarHTickets number @最大高级大地票数
---@field CHandsLTickets number @当前低级巧手票数
---@field MHandsLTickets number @最大低级巧手票数
---@field CHandsHTickets number @当前高级巧手票数
---@field MHandsHTickets number @最大高级巧手票数
---@field bSelectIsMaxLevelCollection boolean @选择的是否是最高等级的收藏品
---@field PlayerCurProfessIndex number @玩家当前职业索引
---@field PossessCollectablesData table<number, table> @拥有的收藏品数据（从背包中获得的）
---@field ClickBtnInfoPostion FVector2D @点击打开回报列表按钮的位置
---@field ClickBtn any @点击打开回报列表按钮
---@field RecordRoleID number @选中收藏品的纪录保持者的RoleID
---@field AllRecordData table<number, table> @所有纪录数据
---@field CutVersion { X Y Z } @当前版本
---@field RedDotList table<number,string> @红点名称列表
local CollectablesMgr = LuaClass(MgrBase)

function CollectablesMgr:OnInit()
    self.DropFilterTabData = {}
    self.LastSelectData = {}
    self.ProfessionData = {}
    self.AllCollectionData = {}

    self.CEarLTickets = 0
    self.MEarLTickets = 1000
    self.CEarHTickets = 0
    self.MEarHTickets = 1000
    self.CHandsLTickets = 0
    self.MHandsLTickets = 1000
    self.CHandsHTickets = 0
    self.MHandsHTickets = 1000
    self.bSelectIsMaxLevelCollection = true

    self.PlayerCurProfessIndex = 1
    self.PossessCollectablesData = {}

    self.ClickBtnInfoPostion = FVector2D(0, 0)
    self.ClickBtn = nil

    self.RecordRoleID = 0
    self.AllRecordData = {}
    self.RedDotList = {}
    self.CutVersion = { X = 0, Y = 0, Z = 0 }
    self.CutVersionMaxLevel = 0
end

function CollectablesMgr:OnRegisterNetMsg()
    --请求交换
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLLECT, SUB_MSG_ID.CS_CMD_COLLECT_EXCHANGE, self.OnNetMsgExchangeinfo)
    --请求收藏品最高纪录
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLLECT, SUB_MSG_ID.CS_CMD_COLLECT_RECORD, self.OnNetMsgGetRecordInfo)
end

function CollectablesMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
end

function CollectablesMgr:OnMajorLevelUpdate(Params)
    local ProfID = Params.ProfID
    local OldLevel = Params.OldLevel
    if ProfID >= CollectablesDefine.MinLifeProfID and nil ~= OldLevel then
        local CutLevel = MajorUtil.GetMajorLevel() or 0
        local AllCollectionData = self:GetCollectByProfID(ProfID)
        for _, Elem in pairs(AllCollectionData) do
            if Elem.UnlockLevel > OldLevel and Elem.UnlockLevel <= CutLevel  then
                self:AddRedDot(Elem.ID)
            end
        end
    end
end

function CollectablesMgr:OnBegin()
    USaveMgr = _G.UE.USaveMgr
    RedDotMgr = _G.RedDotMgr
    LootMgr = _G.LootMgr

    local VersionCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    if nil ~= VersionCfg then
        self.CutVersion.X = VersionCfg.Value[1] or 0
        self.CutVersion.Y = VersionCfg.Value[2] or 0
        self.CutVersion.Z = VersionCfg.Value[3] or 0
    end
    local MaxLevelCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MAX_LEVEL) or {}
    self.CutVersionMaxLevel = MaxLevelCfg.Value[1] or 50

    self:InitAllData()
    self.RedDotList = {}
    local RedDotStr = USaveMgr.GetString(SaveKey.CollectionRedDot, "", true)
    local SplitStr = string.split(RedDotStr, ",")
    for _, v in ipairs(SplitStr) do
        self:AddRedDot(tonumber(v))
    end
end

function CollectablesMgr:OnEnd()
end

function CollectablesMgr:OnShutdown()
    self.DropFilterTabData = nil
    self.LastSelectData = nil
    self.ProfessionData = nil
    self.AllCollectionData = nil
    self.AllRecordData = nil

    local Str = table.concat(self.RedDotList, ",")
    USaveMgr.SetString(SaveKey.CollectionRedDot, Str, true)
end

------------- 红点
---@type 根据收藏品ID获得名称
---@param CollectID table @收藏品表中数据
---@return RedDotName string @红点名称
function CollectablesMgr:GetRedDotName(CollectID)
    local CollectCfgData = table.find_item(self.AllCollectionData, CollectID, "ID")
    if CollectCfgData ~= nil then
        local CollectionLevel = CollectCfgData.CollectionLevel or 0
        local AllDropData = CollectablesDefine.DropFilterTabData
        local DropItemName = ""
        for _, Elem in pairs(AllDropData) do
            if CollectionLevel >= Elem.MinValue and CollectionLevel <= Elem.MaxValue then
                DropItemName = tostring(Elem.MinValue)
            end
        end
        return CollectablesDefine.RedDotName ..
            "/" .. tostring(CollectCfgData.ProfessionIndex) ..
            "/" .. DropItemName .. "/" .. tostring(CollectCfgData.ID)
    end
    return ""
end

---@type 给目标收藏品加红点
---@param CollectID number @收藏品ID
function CollectablesMgr:AddRedDot(CollectID)
    if not table.contain(self.RedDotList, CollectID) then
        local RedDotName = self:GetRedDotName(CollectID)
        local CollectCfgData = table.find_item(self.AllCollectionData, CollectID, "ID")
        if CollectCfgData == nil then
            return
        end
        table.insert(self.RedDotList, CollectID)
        if RedDotName ~= "" and self:CheckCollectionDisplayed(CollectCfgData) then
            RedDotMgr:AddRedDotByName(RedDotName, 1)
        end
    end
end

---@type 移除目标收藏品红点
---@param CollectID number @收藏品ID
function CollectablesMgr:RemoveRedDot(CollectID)
    if table.contain(self.RedDotList, CollectID) then
        table.remove_item(self.RedDotList, CollectID)
        local RedDotName = self:GetRedDotName(CollectID)
        RedDotMgr:DelRedDotByName(RedDotName)
    end
end

---@type 检查目标收藏品是否有点
---@return  true 有  fasle 无
function CollectablesMgr:CheckRedDot(CollectID)
    return table.contain(self.RedDotList, CollectID)
end

---
---@type 重新刷新下已经添加的红点 （Gm中调用方便测试）
---@return  true 有  fasle 无
function CollectablesMgr:RestartRedDotLoad()
    for i = 1, #self.RedDotList do
        local CollectID = self.RedDotList[i]
        local RedDotName = self:GetRedDotName(CollectID)
        local CollectCfgData = table.find_item(self.AllCollectionData, CollectID, "ID")
        if CollectCfgData == nil then
            return
        end
        if RedDotName ~= "" and self:CheckCollectionDisplayed(CollectCfgData) then
            RedDotMgr:AddRedDotByName(RedDotName, 1)
        end
    end
end

-------------

---@type 请求交换收藏品
---@param GID number @收藏品GID
---@param CollectID number @收藏品ID
function CollectablesMgr:SendMsgExchangeinfo(GID, CollectID)
    LootMgr:SetDealyState(true)

    local MsgID = CS_CMD.CS_CMD_COLLECT
    local SubMsgID = SUB_MSG_ID.CS_CMD_COLLECT_EXCHANGE

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Exchange = {}
    MsgBody.Exchange.GID = GID
    MsgBody.Exchange.CollectID = CollectID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求获得收藏品最高纪录
---@param CollectID number @收藏品id
function CollectablesMgr:SendMsgGetRecordinfo(CollectID)
    local MsgID = CS_CMD.CS_CMD_COLLECT
    local SubMsgID = SUB_MSG_ID.CS_CMD_COLLECT_RECORD

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Record = {}
    MsgBody.Record.CollectID = CollectID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求获得交换后的信息
---@param MsgBody table @信息主体是否打破纪录
function CollectablesMgr:OnNetMsgExchangeinfo(MsgBody)
    if nil == MsgBody then
        return
    end
    local ExchangeInfo = MsgBody.Exchange
    local bIsBreakRecord = ExchangeInfo.IsBreakRecord
    if not bIsBreakRecord then
        LootMgr:SetDealyState(false)
    end
    EventMgr:SendEvent(EventID.OnExchangeRspEvent, bIsBreakRecord)
end

---@type 请求获得收藏品最高纪录
---@param MsgBody table @信息主体记录信息
function CollectablesMgr:OnNetMsgGetRecordInfo(MsgBody)
    if nil == MsgBody then
        return
    end
    local AllRecordInfo = MsgBody.Record
    self.AllRecordData = AllRecordInfo
    CollectablesMgr:UpdateRoleData()
end

---@type 初始化所有数据
function CollectablesMgr:InitAllData()
    --默认职业全部解锁
    self:UpdateProfessionData()

    local AllCollectionData = CollectInfoCfg:FindAllCfg()
    self.AllCollectionData = AllCollectionData

    --把各种工票的最大值确定好
    local ScoreType = ProtoRes.SCORE_TYPE
    local Cfg1 = ScoreCfg:FindCfgByKey(ScoreType.SCORE_TYPE_HAND_BLUE_CODE) or {}
    local Cfg2 = ScoreCfg:FindCfgByKey(ScoreType.SCORE_TYPE_HAND_RED_CODE) or {}
    local Cfg3 = ScoreCfg:FindCfgByKey(ScoreType.SCORE_TYPE_GROUND_BLUE_CODE) or {}
    local Cfg4 = ScoreCfg:FindCfgByKey(ScoreType.SCORE_TYPE_GROUND_RED_CODE) or {}
    self.MHandsLTickets = Cfg1.MaxValue or self.MHandsLTickets
    self.MHandsHTickets = Cfg2.MaxValue or self.MHandsHTickets
    self.MEarLTickets = Cfg3.MaxValue or self.MEarLTickets
    self.MEarHTickets = Cfg4.MaxValue or self.MEarHTickets
end

---@type 获取角色最新职业数据
function CollectablesMgr:UpdateProfessionData()
    local Prof = ActorMgr:GetMajorRoleDetail().Prof
    local ProfList = Prof.ProfList
    local ProfData = {}
    local OrderProfessData = CollectablesDefine.OrderProfessData
    for ProfID, Value in pairs(OrderProfessData) do
        local ExistProfData = ProfList[ProfID] or {}
        local ProfessionName = RoleInitCfg:FindRoleInitProfName(ProfID) or ""
        local Level = ExistProfData.Level or 0
        local NeedData = {}
        NeedData.ProfID = ExistProfData.ProfID or ProfID
        NeedData.Level = Level
        NeedData.IconPath = Value.IconPath 
        NeedData.SelectIcon = Value.SelectIcon 
        NeedData.ProfessionName = ProfessionName
        NeedData.IsLock = not (Level >= CollectablesDefine.MinUnLockLevel )
        NeedData.OrderID = Value.Order or 0
        table.insert(ProfData, NeedData)
    end

    if #ProfData >= 1 then
        table.sort(ProfData, self.ProfSort)
        self.ProfessionData = ProfData
    end
end

---@type 根据玩家所处的职业获取职业列表中的索引
---@param ProfessionData table @当前职业信息
---@param ProfID number @玩家所处的职业ID
function CollectablesMgr:GetProfIndexByData(ProfessionData, ProfID)
    local Data = ProfessionData
    for i = 1, #Data do
        local Elem = Data[i]
        if Elem.ProfID == ProfID then
            return i
        end
    end
end

---@type 给相对应的角色加经验
---@param ProfID number @职业ProfID
---@param ExpValue number @经验值
function CollectablesMgr:AddExpToProf(ProfID, ExpValue)
    local Prof = ActorMgr:GetMajorRoleDetail().Prof
    local ProfList = Prof.ProfList
    for _, v in pairs(ProfList) do
        local Elem = v
        if Elem.ProfID == ProfID then
            Elem.Exp = Elem.Exp + ExpValue
            break
        end
    end
end

---@type 根据职业等级获取下拉列表数据
---@param Level number @职业等级
function CollectablesMgr:GetDropFilterData(Level)
    local NeedDropFilterData = {}
    local AllDropData = CollectablesDefine.DropFilterTabData
    for _, Elem in pairs(AllDropData) do
        if Level >= Elem.OpenLevel and self.CutVersionMaxLevel > Elem.OpenLevel then
            table.insert(NeedDropFilterData, Elem)
        end
    end
    return NeedDropFilterData
end

---@type 根据职业id获取收藏品数据
---@param ProfID number @职业id
function CollectablesMgr:GetCollectByProfID(ProfID)
    local NeedCollectionData = {}
    local AllCollectionData = self.AllCollectionData
    for _, v in pairs(AllCollectionData) do
        local Elem = v
        if ProfID == Elem.ProfessionIndex then
            table.insert(NeedCollectionData, Elem)
        end
    end
    return NeedCollectionData
end

---@type 根据所选择的等级条件获取收藏品数据
---@param ProfID number @职业id
---@param DropFilterID number @下拉框数据ID
function CollectablesMgr:GetCollectByDropFilter(ProfID, DropFilterID)
    local EndCollectionData = {}
    local AllCollectionData = self:GetCollectByProfID(ProfID)
    local ProfessData = CollectablesMgr.ProfessionData
    local ProfIndex = CollectablesMgr:GetProfIndexByData(ProfessData, ProfID)
    local ProfessionLevel = ProfessData[ProfIndex].Level
    local DropFilterData = table.find_item(CollectablesDefine.DropFilterTabData, DropFilterID, "ID" )
    if DropFilterData == nil then
        return EndCollectionData
    end
    for _, v in pairs(AllCollectionData) do
        local Elem = v
        if Elem.CollectionLevel >= DropFilterData.MinValue and Elem.CollectionLevel <= DropFilterData.MaxValue
        and ProfessionLevel >= Elem.UnlockLevel and self:CheckCollectionDisplayed(Elem) then
            Elem.HoldingNum = #CollectablesMgr:GetCollectionInBag(Elem.ID)
            table.insert(EndCollectionData, Elem)
        end
    end
    table.sort(EndCollectionData, self.SortCollectByLevel)
    return EndCollectionData
end

---@type 根据等级给收藏品排序
function CollectablesMgr.SortCollectByLevel(Left, Right)
    if Left.HoldingNum ~= Right.HoldingNum then
        return Left.HoldingNum > Right.HoldingNum
    else
        if Left.CollectionLevel == Right.CollectionLevel then
            if Left.StarLevel == Right.StarLevel then
                return Left.ID < Right.ID
            else
                return Left.StarLevel > Right.StarLevel
            end
        else
            return Left.CollectionLevel > Right.CollectionLevel
        end
    end
end

---@type 通过解锁的时间排序
function CollectablesMgr.SortByOnTime(Left, Right)
    local LeftOnTime = Left.OnTime
    local RightOnTime = Right.OnTime
    if LeftOnTime ~= RightOnTime then
        return LeftOnTime < RightOnTime
    else
        return Left.ProfID < Right.ProfID
    end
end

---@type 对职业按照固定顺序排序
function CollectablesMgr.ProfSort(Left, Right)
    if not Left.IsLock then
        if Right.IsLock then 
            return true
        end
    else
        if not Right.IsLock then
           return false
        end
    end
    local LeftOrderID = Left.OrderID
    local RightOrderID = Right.OrderID
    if LeftOrderID ~= RightOrderID then
        return LeftOrderID < RightOrderID
    else
        return Left.ProfID < Right.ProfID
    end
end

---@type 得到背包中拥有的该种收藏品
---@param ID number @收藏品ID
function CollectablesMgr:GetCollectionInBag(ID)
    -- --获取背包内符合条件的收藏品
    local CollectionCfg = CollectInfoCfg:FindCfgByKey(ID)
    local MinValueIndex = 1
    local MinCollectValue = CollectionCfg.CollectValue[MinValueIndex]
    local function Predicate(Item)
        local Attr
        local Collection
        if Item ~= nil then
            Attr = Item.Attr
        else
            return false
        end
        if Attr ~= nil then
            Collection = Attr.Collection
        else
            return false
        end
        local CollectionValue
        if nil ~= Collection then
            CollectionValue = Collection.CollectionValue
        else
            return false
        end
        if nil ~= CollectionValue and Item.ResID == ID and CollectionValue >= MinCollectValue then
            return true
        end
        return false
    end
    local PossessCollectablesData = BagMgr:FilterItemByCondition(Predicate) or {}
    self.PossessCollectablesData = PossessCollectablesData
    table.sort(PossessCollectablesData, self.SortCollectByValue)

    return PossessCollectablesData
end

---@type 按照收藏价值排序
function CollectablesMgr.SortCollectByValue(Left, Right)
    local LeftAttr = Left.Attr
    local LeftCollection = LeftAttr.Collection
    local LeftValue = LeftCollection.CollectionValue
    local RightAttr = Right.Attr
    local RightCollection = RightAttr.Collection
    local RightValue = RightCollection.CollectionValue
    if LeftValue ~= RightValue then
        return LeftValue > RightValue
    else
        return Left.GID < Right.GID
    end
end

---@type 更新工票数量
function CollectablesMgr:UpdateCurAndMaxTicket()
    local ScoreType = ProtoRes.SCORE_TYPE
    local ScoreList = ScoreMgr:GetScoreValueList()
    local DefultValue = 0
    self.CEarHTickets = ScoreList[ScoreType.SCORE_TYPE_GROUND_RED_CODE] or DefultValue
    self.CHandsHTickets = ScoreList[ScoreType.SCORE_TYPE_HAND_RED_CODE] or DefultValue
    self.CEarLTickets = ScoreList[ScoreType.SCORE_TYPE_GROUND_BLUE_CODE] or DefultValue
    self.CHandsLTickets = ScoreList[ScoreType.SCORE_TYPE_HAND_BLUE_CODE] or DefultValue
end

---@type 更新一下后台角色数据
function CollectablesMgr:UpdateRoleData()
    local AllRecordInfo = self.AllRecordData
    local RecordList = AllRecordInfo.RecordList
    if nil == RecordList then
        return
    end
    for i = 1, #RecordList do
        local RecordInfo = RecordList[i]
        local RoleID = RecordInfo.RoleID
        RoleInfoMgr:FindRoleVM(RoleID)
    end
end

---@type 检查是否开启某收藏品
---@param CollectData number @收藏品数据
function CollectablesMgr:CheckCollectionDisplayed(CollectData)
    local OpenVersion = CollectData.OpenVersion or ""
    local CutVersion = self.CutVersion
    local SplitStr = string.split(OpenVersion, ".")

    local Num = tonumber(SplitStr[1] or "0")
    if CutVersion.X ~= Num then
        return CutVersion.X > Num
    end
    Num = tonumber(SplitStr[2] or "0")
    if CutVersion.Y ~= Num then
        return CutVersion.Y > Num
    end
    Num = tonumber(SplitStr[3] or "0")
    if CutVersion.Z ~= Num then
        return CutVersion.Z > Num
    end
    return true
end

return CollectablesMgr
