---
---@author Lucas
---DateTime: 2023-04-11 10:55:00
---Description:

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local WeatherUtil = require("Game/Weather/WeatherUtil")
local WeatherCfg = require("TableCfg/WeatherCfg")
local MapCfg = require("TableCfg/MapCfg")
local FishCfg = require("TableCfg/FishCfg")
local FishWeatherCfg = require("TableCfg/FishWeatherCfg")
local FishBaitCfg = require("TableCfg/FishBaitCfg")
local FishNoteClassCfg = require("TableCfg/FishNoteClassCfg")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local FishLocationCfg = require("TableCfg/FishLocationCfg")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local FishNotesClockSetWindVM = require("Game/FishNotes/FishNotesClockSetWindVM")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local TimeDefine = require("Define/TimeDefine")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local UIViewID = require("Define/UIViewID")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")
local NoteParamCfg = require("TableCfg/NoteParamCfg")
local ProtoRes = require("Protocol/ProtoRes")
local LocalizationUtil = require("Utils/LocalizationUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ScoreCfg = require("TableCfg/ScoreCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AudioUtil = require("Utils/AudioUtil")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local BitUtil = require("Utils/BitUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local MajorUtil = require("Utils/MajorUtil")
local PWorldMgr = _G.PWorldMgr
local SidebarType = SidebarDefine.SidebarType.FishClock
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_NOTE_CMD
local AozyTimeDefine = TimeDefine.AozyTimeDefine
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR

---@class FishNotesMgr : MgrBase
---@field FishList table @鱼的信息列表
---@field FactionList table @势力列表
---@field FactionIconList table @势力图标列表
---@field AreaList table @区域列表
---@field FactionList table @地点列表
---@field SearchList table @搜索列表
---@field ClockList table @闹钟列表
---@field ClockListSorted table @按窗口期排序后的闹钟列表
---@field FishWindowDataList table @鱼窗口数据列表
---@field FishHauntList table @鱼出没地点列表
---@field FishUnlockList table @解锁鱼列表
---@field FishLocationUnlockList table @解锁钓场地点列表
---@field bClockIsActive boolean @闹钟是否激活
local FishNotesMgr = LuaClass(MgrBase)

--region Inherited=======================
function FishNotesMgr:OnInit()
    self:InitData()
end

function FishNotesMgr:OnBegin()
    --用到时再加载
    --self:InitFishInfo() --FishList储存时对鱼Cfg中的数据直接引用原始配置表
    --self:InitFishingholeData() --去除FishingholeList对钓场的储存，钓场数据根据ID查表，只储存钓场解锁数据FishLocationUnlockList
    --self:InitFishingholeInfo()
    _G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_FISH, self.CheckFishUnLock)
end

function FishNotesMgr:OnEnd()
    _G.FLOG_INFO("FishNotesMgr:OnEnd")
    --self:RemoveRedDotsOnHide(true)
    self:CloceClockAlarm(true)
end

function FishNotesMgr:OnShutdown()
    self:InitData()
end

function FishNotesMgr:InitData()
    self.FishList = nil
    self.Bait2FishID = nil
    self.TickDeltaTime = 1
    self.FactionIconList = nil
    self.AreaList = nil
    self.FactionList = nil
    self.SearchList = nil
    self.ClockList = nil
    self.FishWindowDataList = nil
    self.FishHauntList = nil
    self.LocationFishList = nil
    self.StartTimeCount = 0
    self.ComingTimeCount = 0
    self.StartCountDownTime = 0
    self.ComingCountDownTime = 0
    self.FishUnlockList = nil
    self.FishLocationUnlockList = {}
    self.bClockIsActive = true
    self.SidebarNoticedFishID = nil
    self.SidebarNoticedLocationID = nil
    self.FishingholePosAdjustGM = false
    self.IsGetClockInfo = false
    self.MaxClockNum = self:GetMaxClockNum()
    self.ClockListSorted = {}
    self.NearestWindowList = {}
end

function FishNotesMgr:OnRegisterNetMsg()
    --钓场中鱼的解锁和闹钟拉取、更新、闹钟更改设置
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_FISH_GROUND_QUERY, self.OnNetMsgGetFishGroundList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CLOCK_SET, self.OnNetMsgClockSettingInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CLOCK, self.OnNetMsgClockInfo)
    --钓场解锁拉取和更新
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_HISTORY_LIST, self.OnNetMsgGetHistoryList)
	--self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_NOTIFY_HISTORY_UPDATE, self.OnNetMsgUpdateHistoryList)
    --鱼类图鉴解锁拉取和更新
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_FISH_NOTE_BOOK_LIST, self.OnNetMsgGetUnlockFishList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_FISH_NOTE_NOTIFY_FISH_UPDATE, self.OnNetMsgFishUpdate)
    --钓场红点
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_RED_POINT, self.OnNetMsgUpdateRedDot)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_FISH_GROUND_RED_POINT, self.OnNetMsgAddRedDot)
end

function FishNotesMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut)
    self:RegisterGameEvent(EventID.UpdateWeatherForecast, self.OnEventWeatherUpdate)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.EnterFishArea, self.OnEnterFishAreaSendUnlock)
end

function FishNotesMgr:OnRegisterTimer()
end
--endregion

--region DataRequest=======================
---@type 天气更新后开始请求闹钟数据
function FishNotesMgr:OnEventWeatherUpdate()
    if self.IsGetClockInfo == false then
        self:SendMsgGetFishGroundList()
    end
end

function FishNotesMgr:OnGameEventLoginRes(Params)
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDFisherNote) then
        return
    end
    self:SendMsgGetClockList()
    self:SendMsgGetUnlockFishList()
    self:SendMsgGetPlaceRedDot()
end
--endregion

--region DataBase=======================
--region 1.鱼类信息
---@type 鱼类版本筛选
function FishNotesMgr:GetFishDataListByVersion()
    local FishAllData = FishCfg:FindAllCfg()
    local FishDataList = {}
    for _, value in pairs(FishAllData) do
        if value.ID < 10000 and value.VersionName and value.VersionName ~= "" then
            if _G.ClientVisionMgr:CheckVersionByGlobalVersion(value.VersionName) then
				table.insert(FishDataList,value)
            end
        end
    end
    return FishDataList
end

function FishNotesMgr:GetFishCfg(ID)
    if type(ID) ~= "number" then return end
    return FishCfg:FindCfgByKey(ID)
end

function FishNotesMgr:GetFishName(ID)
    if type(ID) ~= "number" then return end
    return FishCfg:FindValue(ID, "Name")
end

---@type 获取指定ID鱼的信息（包含天气，时间条件）
---@param ID number 鱼ID
function FishNotesMgr:GetFishData(ID)
    if type(ID) ~= "number" then return end
    self.FishList = self.FishList or {}
    if table.is_nil_empty(self.FishList) or not self.FishList[ID] then
        local Data = self:GetFishCfg(ID)
        if Data ~= nil then
            self:AddFishList(Data)
        else
            FLOG_ERROR(string.format("GetFishData Data is nil, ID = %d", ID))
        end
    end
    return self.FishList[ID]
end

function FishNotesMgr:AddFishList(Data)
    self.FishList = self.FishList or {}
    local FishID = Data.ID
    self.FishList[FishID] = {
        Cfg = Data,
        WeatherCondition = self:GetWeatherConditionByKey(Data.CurWeatherCondition),
        PreWeatherCondition = self:GetWeatherConditionByKey(Data.PreWeatherCondition),
    }

    if type(Data.TimeCondition) == "string" and string.len(Data.TimeCondition) > 0 then
        local TimeCondition = {}
        local TimeCond = string.split(Data.TimeCondition, ",")
        local Len = #TimeCond
        for i = 1, Len, 2 do
            local StartTime = tonumber(TimeCond[i])
            local EndTime = tonumber(TimeCond[i + 1])
            table.insert(TimeCondition,{Start = StartTime, End = EndTime})
        end
        if TimeCond[1] == "0" and TimeCond[Len] == "24" then
            TimeCondition[1].Start = tonumber(TimeCond[Len - 1])
            table.remove(TimeCondition, #TimeCondition)
        end

        local TimeConditionText = ""
        for Index, value in pairs(TimeCondition) do
            if Index == 1 then
                TimeConditionText = string.format("%d:00-%d:00",value.Start, value.End)
            else
                TimeConditionText = string.format("%s,%d:00-%d:00",TimeConditionText, value.Start, value.End)
            end
        end
        self.FishList[FishID].TimeCondition = #TimeCondition > 0 and TimeCondition
        self.FishList[FishID].TimeConditionText = TimeConditionText
    end
end

function FishNotesMgr:GetFishDataByItemID(ItemID)
    local FishList = FishCfg:FindAllCfg()
    if not table.is_nil_empty(FishList) then
        for _, value in pairs(FishList) do
            if value.ItemID == ItemID then
                return self:GetFishData(value.ID)
            end
        end
    end
end

function FishNotesMgr:GetWeatherConditionByKey(WeatherConditionKey)
    if WeatherConditionKey == 0 then
        return
    end
    local WeatherList = FishWeatherCfg:FindCfgByKey(WeatherConditionKey)
    if table.is_nil_empty(WeatherList) then
        return
    end
    local WeatherCondition = {}
    for WeartherIndex, BoolValue in pairs(WeatherList.Type) do
        if WeartherIndex ~= 1 and BoolValue then
            local Weather = WeatherCfg:FindCfgByKey(WeartherIndex - 1)
            if Weather then
                table.insert(WeatherCondition,Weather)
            else
                FLOG_ERROR("FishNotesMgr:GetWeatherConditionByKey Weather FindCfgByKey is")
            end
        end
    end
    return WeatherCondition
end

---@type 获取筛选鱼类列表_鱼类图鉴
function FishNotesMgr:GetFilterFishList()
    local Result = {}
    local FishList = self:GetFishDataListByVersion()
    for _, Fish in pairs(FishList) do
        if Fish.Rarity == FishNotesDefine.FishRartyEnum.King or Fish.Rarity == FishNotesDefine.FishRartyEnum.Queen then
            table.insert(Result, Fish)
        end
    end

    return Result
end

---@type 检查鱼是否在当前钓场
function FishNotesMgr:CheckFishIsInCurLocation(FishID, LocationID)
    local LocationID = LocationID or _G.FishIngholeVM.SelectLocationID
    local LocationData = FishNotesMgr:GetFishingholeData(LocationID)
    if LocationData == nil then
        FLOG_ERROR(" FishNotesMgr:CheckFishIsInCurLocation LocationData is nil")
        return false
    end

    local FishList = self:GetLocationFishListByID(LocationID)
    if not table.is_nil_empty(FishList) then
        for _, value in pairs(FishList) do
            if value == FishID then
                return true
            end
        end
    else
        FLOG_ERROR(" FishNotesMgr:CheckFishIsInCurLocation FishList is nil")
    end
    return false
end

---@type 是否订阅了闹钟
---@param FishID 鱼的ID
function FishNotesMgr:IsFishSubscribeClock(FishID, GroundID)
    return self.ClockList and self.ClockList[FishID] and self.ClockList[FishID][GroundID] ~= nil
end
--endregion

--region 2.钓场信息
---@type 初始化渔场界面使用的数据结构
function FishNotesMgr:InitFishingholeInfo()
    self.FactionList = {}
    local FactionIconList = {}
    self.FactionIconList = {}
    self.AreaList = {}

    local IsInsertF = {}
    local IsInsertA = {}

    local FishlocationList = self:GetFishingholeList()
    local Map, MapClassID, MapIDString, Faction, Area, Region
    for _, Data in pairs(FishlocationList) do
        Map = MapCfg:FindCfgByKey(Data.MapID)
        if Map then
            Faction = Map.RegionName
            Area = Map.DisplayName

            MapIDString = tostring(Data.MapID)
            MapClassID = tonumber(string.sub(MapIDString, 1, 2))
            Region = FishNoteClassCfg:FindCfgByKey(MapClassID)
            if Region then
                Faction = Region.Name
                if IsInsertF[Faction] == nil then
                    table.insert(FactionIconList, Region)
                    IsInsertF[Faction] = 1
                end
            end
            self.FactionList[Faction] = self.FactionList[Faction] or {}
            self.FactionList[Faction][Area] = self.FactionList[Faction][Area] or {}
            table.insert(self.FactionList[Faction][Area], Data)

            if IsInsertA[Area] == nil then
                self.AreaList[Faction] = self.AreaList[Faction] or {}
                table.insert(self.AreaList[Faction], {AreaName = Area, AreaID = Data.ID * Data.MapID})
                IsInsertA[Area] = 1
            end
        else
            FLOG_WARNING(string.format("FishNotesMgr:InitFishingholeInfo Map is nil, MapID = %d", Data.MapID))
        end
    end

    table.sort(FactionIconList,function(a, b) return a.Priority < b.Priority end)
    for i = 1, #FactionIconList do
        table.insert(self.FactionIconList,FactionIconList[i].IconPath)
        table.insert(self.FactionList, FactionIconList[i].Name)
    end
    return self.FactionList
end

function FishNotesMgr:GetFishingholeList()
    return FishLocationCfg:FindAllCfg("VersionName == '2.0.0'")
end

---@type 获取钓场配置信息
---@param ID number 渔场ID
function FishNotesMgr:GetLocationNameByID(ID)
    if type(ID) ~= "number" then
        FLOG_WARNING("FishNotesMgr:GetFishingholeData(ID) ID is not number")
        return nil
    end

    return FishLocationCfg:FindValue(ID, "Name")
end

function FishNotesMgr:GetLocationFishListByID(ID)
    if type(ID) ~= "number" then
        FLOG_WARNING("FishNotesMgr:GetFishingholeData(ID) ID is not number")
        return {}
    end
    self.LocationFishList = self.LocationFishList or {}
    local FishList = self.LocationFishList[ID]
    if FishList == nil then
        FishList = {}
        local FishListCfg = FishLocationCfg:FindValue(ID, "FishID")
        if not table.is_nil_empty(FishListCfg) then
            for _, FishID in pairs(FishListCfg) do
                local FishData = self:GetFishCfg(FishID)
                if FishData ~= nil and _G.ClientVisionMgr:CheckVersionByGlobalVersion(FishData.VersionName) then
                    table.insert(FishList, FishID)
                end
            end
        end
        self.LocationFishList[ID] = FishList
    end
    return FishList
end

---@type 获取钓场配置信息
---@param ID number 渔场ID
function FishNotesMgr:GetFishingholeData(ID)
    if type(ID) ~= "number" then
        FLOG_WARNING("FishNotesMgr:GetFishingholeData(ID) ID is not number")
        return nil
    end

    return FishLocationCfg:FindCfgByKey(ID)
end

---@type 获取钓场信息
---@param PlaceID number 钓场ID
function FishNotesMgr:GetPlaceInfoByPlaceID(PlaceID)
    local FactionList = self.FactionList or self:InitFishingholeInfo()
    for FactionName, Faction in pairs(FactionList) do
        if type(Faction) == "table" then
            for AreaName, Area in pairs(Faction) do
                for _, Place in pairs(Area) do
                    if Place.ID == PlaceID then
                        return {Faction = FactionName, Area = AreaName}
                    end
                end
            end
        end
    end
end

---@type 获取钓场信息
---@param Faction string 势力
---@param Area string 区域
---@param bSearch boolean 是否搜索
function FishNotesMgr:GetPlaceInfo(Faction, Area, bSearch)
    if type(Faction) ~= "string" or type(Area) ~= "string" then
        FLOG_WARNING("FishNotesMgr:GetPlaceInfo(Faction, Area) Faction or Area is not string")
        return nil
    end
    if bSearch == nil then
        bSearch = false
    end

    if bSearch == true then
        return self.SearchList[Area]
    else
        local FactionList = self:GetFactionInfo()
        return FactionList and FactionList[Faction] and FactionList[Faction][Area]
    end
end

function FishNotesMgr:GetMapInfo(MapID)
    local IDString = tostring(MapID)
    local ID = tonumber(string.sub(IDString, 1, 2))
    return FishNoteClassCfg:FindCfgByKey(ID)
end

---@type 获取指定ID鱼的出没钓场信息
---@param ID number 鱼ID
function FishNotesMgr:GetFishHauntList(ID)
    if type(ID) ~= "number" then
        FLOG_WARNING("FishNotesMgr:GetFishHauntList(ID) ID is not number")
        return nil
    end

    self.FishHauntList = self.FishHauntList or {}
    if self.FishHauntList[ID] == nil then
        self.FishHauntList[ID] = {}
        local FishlocationList = self:GetFishingholeList()
        for _, Data in ipairs(FishlocationList) do
            local FishList = self:GetLocationFishListByID(Data.ID)
            if not table.is_nil_empty(FishList) then
                for j = 1, #FishList do
                    local FishID = Data.FishID[j]
                    if ID == FishID then
                        table.insert(self.FishHauntList[ID], Data)
                    end
                end
            end
        end
    end
    return self.FishHauntList[ID]
end

function FishNotesMgr:GetMapFishPos(PlaceID)
    local Points = PlaceID and FishLocationCfg:FindValue(PlaceID, "Points")
	return Points and Points[1]
end
--endregion

--region 3.Area
---@type 获取区域信息
---@param Name string 区域名
function FishNotesMgr:GetAreaInfo(Name)
    if type(Name) ~= "string" then
        FLOG_WARNING("FishNotesMgr:GetAreaInfoByName(Name) Name is not string")
        return nil
    end
    if self.AreaList then
        return self.AreaList[Name]
    end
    return nil
end
--endregion

--region 4.势力
---@type 获取Tab使用的势力信息
---@param Index number 势力索引, <Index == nil> 返回全部
---@return table | string 全部势力信息 or 指定下标的势力信息
function FishNotesMgr:GetFactionInfo(Index)
    local FactionList = self.FactionList or self:InitFishingholeInfo()
    if Index == nil then
        return FactionList
    end

    return FactionList[Index]
end

function FishNotesMgr:GetFactionNameByAreaName(Name)
    local FactionList = self:GetFactionInfo()
    for FactionName, Faction in pairs(FactionList) do
        if type(Faction) == "table" then
            for AreaName, _ in pairs(Faction) do
                if AreaName == Name then
                    return FactionName
                end
            end
        end
    end
end

function FishNotesMgr:GetFactionIndexByFactionName(Name)
    local FactionList = self:GetFactionInfo()
    for Index, Faction in pairs(FactionList) do
        if type(Faction) == "string" then
            if Faction == Name then
                return Index
            end
        end
    end
end

---@type 获取Tab使用的势力图标信息
---@return table | string 全部势力图标信息 or 指定下标的势力图标信息
function FishNotesMgr:TabDataList()
    local Result = {}
    for Index, Icon in ipairs(self.FactionIconList) do
        table.insert(
            Result,
            {
                IconPath = Icon,
                ID = Index,
                RedDotType = FishNotesDefine.FishNoteType
            }
        )
    end
    return Result
end

---@type 根据钓场ID获取势力图标
function FishNotesMgr:GetFactionIconByLocationID(PlaceID)
    local Place = self:GetPlaceInfoByPlaceID(PlaceID)
    local FactionIndex = FishNotesMgr:GetFactionIndexByFactionName(Place.Faction)
    return self.FactionIconList[FactionIndex] or ""
end
--endregion

--region 5.解锁获取/第一个解锁的index
---@type 获取鱼类解锁信息
---@param ID number 鱼类ID
function FishNotesMgr:GetUnlockFishData(ID)
    if self.FishUnlockList == nil or ID == nil then
        return nil
    end

    return self.FishUnlockList[ID]
end

function FishNotesMgr.CheckFishUnLock(ResID)
    local FishData = FishNotesMgr:GetFishDataByItemID(ResID)
    if FishData then
        return FishNotesMgr:GetUnlockFishData(FishData.Cfg.ID)
    end
    return false
end

---@type 鱼类图鉴是否全部激活_true表示全激活
function FishNotesMgr:GetFishGuideIsAllUnLock()
    local FishDataList = self:GetFishDataListByVersion()
    for _, Fish in pairs(FishDataList) do
        if FishNotesMgr:CheckFishbUnLock(Fish.ID) == false then
            return false
        end
    end
    return true
end

---@type 检查指定ID鱼是否解锁_鱼类图鉴用
---@param ID number 鱼类ID
---@return boolean 是否解锁
function FishNotesMgr:CheckFishbUnLock(ID)
    if ID ~= nil and self.FishUnlockList and self.FishUnlockList[ID] then
        return true
    end

    return false
end

---@type 检查指定ID钓场的指定ID鱼是否解锁
function FishNotesMgr:CheckFishUnlockInFround(FishID, GroundID)
    --return self:CheckFishLocationbLock(GroundID) == false and self:CheckFishbUnLock(FishID)
    return self:CheckFishbUnLock(FishID)
end

---@type 检查指定ID钓场是否解锁
---@param ID number 渔场ID
function FishNotesMgr:CheckFishLocationbLock(ID)
    if ID ~= nil and self.FishLocationUnlockList ~= nil and self.FishLocationUnlockList[ID] == true then
        return false
    end
    return true
end

---@type 指定ID钓场中鱼的解锁Get进度
function FishNotesMgr:GetLocationFishUnLockProgress(LocationData)
    local LocationID = LocationData.ID
    local FishList = self:GetLocationFishListByID(LocationID)
    local TotalNum = #FishList
    local UnLockNum = 0
    if self:CheckFishLocationbLock(LocationID) == false then
        for _, FishID in ipairs(FishList) do
            if self:CheckFishbUnLock(FishID) then
                UnLockNum = UnLockNum + 1
            end
        end
    end
    return UnLockNum, TotalNum
end

---@type 如果当前地图有水晶激活则为解锁
function FishNotesMgr:IsMapUnlock(MapID)
    local CrystalCfgs =  CrystalPortalCfg:FindAllCfg(string.format(
        "MapID = %d AND Type = %d", MapID, ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP)) or {}
    if #CrystalCfgs == 0 then
        return true
    end
    for _, Cfg in ipairs(CrystalCfgs) do
        if CrystalPortalMgr:IsExistActiveCrystal(Cfg.ID) then
            return true
        end
    end
    return false
end

---@type 鱼类收集度最低的钓场的地图ID_影响因素[地图解锁，钓场中鱼收集度，钓场等级]
function FishNotesMgr:GetMinUnLockProgress()
    local FishingholeList = self:GetFishingholeList()
    if table.is_nil_empty(FishingholeList) then
        FLOG_ERROR("FishNotesMgr:GetMinUnLockProgress FishingholeList is nil")
        return
    end

    local ResultMapIDList = {}
    local MapUnlockList = {}
    local ProgressList = {}
    for _, value in pairs(FishingholeList) do
        local MapID = value.MapID
        if MapUnlockList[MapID] == nil then
            MapUnlockList[MapID] = self:IsMapUnlock(MapID)
        end
        --地图未解锁的不推荐
        if MapUnlockList[MapID] == true then
            local UnLockNum, TotalNum = self:GetLocationFishUnLockProgress(value)
            local Progress = UnLockNum/TotalNum
            table.insert(ProgressList, {MapID = MapID, Progress = Progress, Level = value.Level})
        end
    end
    --收集度相等时，取等级低的
    table.sort(ProgressList, function(a, b)
        if a.Progress ~= b.Progress then
            return a.Progress < b.Progress
        end
        return a.Level < b.Level
    end )

    local NeedNum = 4
    local TempResultList = {}
    if not table.is_nil_empty(ProgressList) then
        for _, Value in pairs(ProgressList) do
            if not TempResultList[Value.MapID] then
                TempResultList[Value.MapID] = true
                table.insert(ResultMapIDList, Value.MapID)
                NeedNum = NeedNum - 1
                if NeedNum == 0 then
                    break
                end
            end
        end
    end
    return ResultMapIDList
end

---@type 获取区域锁定状态
---@param Faction string 势力
---@param Name string 区域名
---@return boolean 是否锁定
function FishNotesMgr:GetAreaIsLock(Faction, Name)
    if type(Name) ~= "string" then
        FLOG_WARNING("FishNotesMgr:GetAreaIsLock(Name) Name is not string")
        return true
    end

    local FactionList = self:GetFactionInfo()
    local PlaceList = FactionList[Faction][Name]
    for _, Place in ipairs(PlaceList) do
        if self:CheckFishLocationbLock(Place.ID) == false then
            return false
        end
    end

    return true
end

---@type 获取势力列表中解锁的第一个势力索引
function FishNotesMgr:GetFirstUnlockFactionIndex()
    local FactionList = FishNotesMgr:GetFactionInfo()
    for index, FactionName in ipairs(FactionList) do
        local AreaList = FactionList[FactionName]
        for AreaName, _ in pairs(AreaList) do
            if self:GetAreaIsLock(FactionName, AreaName) == false then
                return index
            end
        end
    end
    --return FishNotesDefine.FactionDefaultValue
end
--endregion

--region 6.窗口期
---@type 查看该钓场该鱼是否在窗口期
function FishNotesMgr:GetIsFishInWindowInLocation(LocationID, FishID)
    if self:CheckFishLocationbLock(LocationID) == true then
        return false --未发现的钓场不检测
    end

    local Begin, End = FishNotesMgr:GetFishNeasetWindowTime(FishID, LocationID)
    if Begin ~= nil and End ~= nil then
        local Now = TimeUtil.GetServerTime()
        local bActive = Now >= Begin and Now < End
        if bActive then
            return true
        end
    end
    return false
end

---@type 查看该钓场是否有鱼在窗口期
function FishNotesMgr:GetIsHaveFishInWindowInLocation(LocationID)
    if self:CheckFishLocationbLock(LocationID) == true then
        return false --未发现的钓场不检测
    end
    local FishList = self:GetLocationFishListByID(LocationID)
    if not table.is_nil_empty(FishList) then
        for _, FishID in pairs(FishList) do
            local Begin, End = FishNotesMgr:GetFishNeasetWindowTime(FishID, LocationID)
            if Begin ~= nil and End ~= nil then
                local Now = TimeUtil.GetServerTime()
                local bActive = Now >= Begin and Now < End
                if bActive then
                    return true
                end
            end
        end
    end
    return false
end

---@type 以当前时间计算窗口期起始时间
---@return number 窗口期起始时间, 时间戳
function FishNotesMgr:GetWindowBeginTime()
    local AozySec = (_G.TimeUtil.GetServerTime() + 2) * AozyTimeDefine.RealSec2AozyMin * 60
    AozySec = AozySec // 8 * 8
    local Sec, Min, Bell = TimeUtil.GetAozyDateBySec(AozySec)
    AozySec = AozySec - Sec - Min * 60 - (Bell - Bell // 8 * 8) * 60 * 60
    return AozySec / 60 * AozyTimeDefine.AozyMin2RealSec
end

function FishNotesMgr:GetBeginDayTimeByAozySec(RealSec)
    local AozySec = (RealSec + 2) * AozyTimeDefine.RealSec2AozyMin * 60
    AozySec = AozySec // 8 * 8
    local Sec, Min, Bell, Sun = TimeUtil.GetAozyDateBySec(AozySec)
    AozySec = AozySec - Sec - Min * 60 - Bell * 60 * 60
    return AozySec / 60 * AozyTimeDefine.AozyMin2RealSec
end

function FishNotesMgr:GetWindowBeginTimeAozyHour()
    local AozySec = (_G.TimeUtil.GetServerTime() + 2) * AozyTimeDefine.RealSec2AozyMin * 60
    AozySec = AozySec // 8 * 8
    local Sec, Min, Bell = TimeUtil.GetAozyDateBySec(AozySec)
    AozySec = AozySec - Sec - Min * 60 - Bell * 60 * 60
    return AozySec / 60 / 60
end

---@type 获取鱼类最近出现窗口期
---@param Fish table 鱼类数据
---@param Location table 地区数据
---@return number, number 窗口期起始时间, 窗口期结束时间
function FishNotesMgr:GetFishNeasetWindowTime(FishID, LocationID, bNeedRefreshView)
    local List = self.NearestWindowList[FishID]
    local NearestWindow = List and List[LocationID]
    local bOutTime = NearestWindow ~= nil and TimeUtil.GetServerTime() >= NearestWindow.End
    if NearestWindow == nil or bOutTime then
        local WindowsList = _G.FishIngholeVM:GetWindowsList(FishID, LocationID, bOutTime)
        if not table.is_nil_empty(WindowsList) then
            NearestWindow =  {Begin = WindowsList[1].StartTime, End = WindowsList[1].EndTime}
            self.NearestWindowList[FishID] = List or {}
            self.NearestWindowList[FishID][LocationID] = NearestWindow
        else
            return nil
        end
    end
    if bOutTime and bNeedRefreshView then
        EventMgr:SendEvent(EventID.FishNoteRefreshWindowState)
        _G.FishIngholeVM:UpdateLocationFishWindowState(FishID)
    end
    return NearestWindow.Begin, NearestWindow.End
end

---@type 指定偏移是否是窗口期天气
---@param MapID number 地图ID
---@param Offset number 偏移量
---@param FishInfo table 鱼类数据
function FishNotesMgr:WhetherIsWindowByOffset(MapID, Offset, WeatherCond)
    local Weather = WeatherUtil.GetMapWeather(MapID, Offset)
    if type(WeatherCond) == "table" then
        for i = 1, #WeatherCond do
            if tonumber(WeatherCond[i].ID) == Weather then
                return true
            end
        end
    end

    return false
end

---@type 指定偏移是否是窗口天气的前置天气
function FishNotesMgr:PreWhetherIsWindowByOffset(MapID, Offset, WeatherCond)
    local Weather = WeatherUtil.GetMapWeather(MapID, Offset)
    if type(WeatherCond) == "table" then
        for i = 1, #WeatherCond do
            if tonumber(WeatherCond[i].ID) == Weather then
                return true
            end
        end
    end

    return false
end

---@type 基于时间获取艾欧泽亚小时
---@param Time number 时间戳
function FishNotesMgr:GetAozyHourByTime(Time)
    return math.floor(Time / AozyTimeDefine.AozyHour2RealSec % FishNotesDefine.DayAllHourValue)
end

---@type 基于艾欧泽亚小时获取时间戳
---@param Time number 时间戳
---@param OffsetAozyHour number 偏移小时
function FishNotesMgr:GetServerTimeByAozy(Time, OffsetAozyHour)
    return Time + OffsetAozyHour * AozyTimeDefine.AozyHour2RealSec
end
--endregion

--region 7.鱼饵
function FishNotesMgr:GetAllBaitData(FishData, LocationID)
    local LocationID = LocationID or _G.FishIngholeVM.SelectLocationID
    if FishData == nil then
        FLOG_WARNING("FishNotesMgr:GetAllBaitData, FishData is nil")
        return nil
    end

    local BaitData
    local CurrentData = FishData
    local TotalSaveList = {}
    local SaveList = {}
    local StageIndex = 1
    while (true) do
        if CurrentData == nil then
            FLOG_WARNING("FishNotesMgr:GetAllBaitData, CurrentData is nil")
            break
        end

        --StageIndex递增，钓饵等级递减
        SaveList[StageIndex] = {}
        local NormalBait = CurrentData.NormalBait
        local NormalLiftRate = CurrentData.NormalLiftRate
        if NormalBait and #NormalBait > 0 then
            local NewSaveList = {}
            for Index1, v1 in ipairs(SaveList) do
                NewSaveList[Index1] = {}
                for Index2, v2 in ipairs(v1) do
                    NewSaveList[Index1][Index2] = v2
                end
            end
            for i, Bait in ipairs(NormalBait) do
                if Bait ~= 0 then
                    BaitData = FishBaitCfg:FindCfgByKey(Bait)
                    --平均钓饵存第一阶段
                    table.insert(SaveList[StageIndex], {
                        ID = BaitData.ID,
                        ItemID = BaitData.ItemID,
                        LiftRate = NormalLiftRate[i],
                    })
                end
            end
            table.insert(TotalSaveList, SaveList)
            if table.is_nil_empty(CurrentData.MoochBait) then
                break
            end
            SaveList = NewSaveList
        end
        local Index = self:GetMaxLiftRateBaitIndex(CurrentData, LocationID)
        if Index == nil or Index == 0 then
            break
        end

        local BaitID = CurrentData.MoochBait[Index]
        local MoochBaitFishID = self:GetFishIDByBaitID(BaitID)
        local MoochLiftRate = CurrentData.MoochLiftRate[Index]
        if MoochBaitFishID == CurrentData.ID then
            break
        end

        CurrentData = self:GetFishCfg(MoochBaitFishID)
        if CurrentData == nil then
            FLOG_WARNING("FishNotesMgr:GetAllBaitData, CurrentData is nil")
            break
        end

        --大小钓饵阶段递增存
		table.insert(SaveList[StageIndex], self:GetCopyBait(CurrentData, MoochLiftRate, LocationID))
        StageIndex = StageIndex + 1
    end

    if #TotalSaveList == 1 then
        return self:GetFishBaitList(TotalSaveList[1], FishData, LocationID)
    else
        local MaxBaitListLiftRate = 0
        local MaxBaitListIndex = 0
        for index, value in ipairs(TotalSaveList) do
            local BaitList = self:GetFishBaitList(value, FishData, LocationID)
            local BaitListLiftRate = 1
            for key, value in pairs(BaitList) do
                BaitListLiftRate = BaitListLiftRate * (value.LiftRate or 1)
            end
            if BaitListLiftRate > MaxBaitListLiftRate then
                MaxBaitListIndex = index
            end
        end
        return self:GetFishBaitList(TotalSaveList[MaxBaitListIndex], FishData, LocationID)
    end
end

function FishNotesMgr:GetFishBaitList(SaveList, FishData, LocationID)
    local BaitList = {}
    local AllBaitList = {}
    if SaveList == nil then
        return BaitList, AllBaitList
    end
    local SaveListLen = #SaveList
    local NormalBaits = SaveList[SaveListLen]
    --平均钓饵阶段的排序
    if #NormalBaits > 1 then
        table.sort(NormalBaits, function (a,b)
            if a.LiftRate == b.LiftRate then
                return a.ID < b.ID
            end
            return a.LiftRate > b.LiftRate
        end)
    end

    --详情界面显示：从最低阶段钓饵开始，每个阶段的第一个钓饵 （组一串）
    for i = #SaveList, 1, -1 do
        table.insert(BaitList, SaveList[i][1])
    end

    --钓饵界面显示
    if #SaveList > 1 then
        ----如果是大小钓饵
        if FishData.MoochBait ~= nil then
            for Index, MoochBait in pairs(FishData.MoochBait) do
                local FishID = self:GetFishIDByBaitID(MoochBait)
                if FishID and self:CheckFishIsInCurLocation(FishID, LocationID) then
                    local BaitFish = self:GetFishCfg(FishID)
                    local Data = {
                        ID = BaitFish.ID,
                        BaitID = MoochBait,
                        ItemID = BaitFish.ItemID,
                        LiftRate = FishData.MoochLiftRate[Index],
                        Num = _G.BagMgr:GetItemNum(BaitFish.ItemID),
                    }
                    table.insert(AllBaitList, Data)
                end
            end
        end
        if #AllBaitList > 1 then
            table.sort(AllBaitList, function (a,b)
                if a.LiftRate == b.LiftRate then
                    return a.BaitID < b.BaitID
                end
                return a.LiftRate > b.LiftRate
            end)
        end
    else
         --平均钓饵阶段的每个钓饵 （所有）
        for _, Data in ipairs(SaveList[1]) do
            local BaitData = {
                ID =Data.ID,
                ItemID = Data.ItemID,
                LiftRate = Data.LiftRate,
                Num = _G.BagMgr:GetItemNum(Data.ItemID),
            }
            table.insert(AllBaitList, BaitData)
        end
    end
    return BaitList, AllBaitList
end

function FishNotesMgr:GetFishIDByBaitID(BaitID)
    self.Bait2FishID = self.Bait2FishID or {}
    if not self.Bait2FishID[BaitID] then
        local FishList = FishCfg:FindAllCfg()
        for FishID, value in pairs(FishList) do
            if value.BaitID == BaitID then
                self.Bait2FishID[BaitID] = FishID
                return FishID
            end
        end
    end
    return self.Bait2FishID[BaitID]
end

function FishNotesMgr:GetCopyBait(CurrentData, MoochLiftRate, LocationID)
    local Data =
    {
        ID = CurrentData.ID,
        LocationID = LocationID,
        IsLocationFish = false,
        RodType = CurrentData.RodType,
        SpecialLift = CurrentData.SpecialLift,
        MoochBait = CurrentData.MoochBait, --用来查找该鱼最佳钓饵
        MoochLiftRate = CurrentData.MoochLiftRate, --用来查找该鱼最佳钓饵
        LiftRate = MoochLiftRate, --用来排序
        BaitID = CurrentData.BaitID, --用来排序_该鱼在钓饵表的ID
    }
    return Data
end

function FishNotesMgr:GetMaxLiftRateBaitIndex(FishData, LocationID)
    local MoochBait = FishData.MoochBait
    local MoochLiftRates = FishData.MoochLiftRate
    if table.is_nil_empty(MoochLiftRates) then
        return
    end
    local MaxIndex = 0
    local MaxRate = 0
    for index = 1, #MoochLiftRates do
        local FishID = self:GetFishIDByBaitID(MoochBait[index])
        if self:CheckFishIsInCurLocation(FishID, LocationID) and FishID ~= FishData.ID then
            local Rate = MoochLiftRates[index]
            if MaxIndex == 0 then
                MaxIndex = index
                MaxRate = Rate
            elseif Rate > MaxRate then
                MaxIndex = index
                MaxRate = Rate
            elseif Rate == MaxRate and MoochBait[index] < MoochBait[MaxIndex] then
                MaxIndex = index
                MaxRate = Rate
            end
        end
    end
    return MaxIndex
end

function FishNotesMgr:GetBaitData(ID)
    return FishBaitCfg:FindCfgByKey(ID)
end
--endregion
--endregion

--region FishClock=======================
--region 1.闹钟开启与设置信息
---@type 获取闹钟功能是否开启
function FishNotesMgr:GetClockActiveState()
    return self.bClockIsActive
end

---@type 设置闹钟功能是否开启
---@param Flag boolean 是否开启
function FishNotesMgr:SetClockActiveState(Flag)
    if Flag == nil then
        FLOG_WARNING("FishNotesMgr.SetClockActiveState, Flag is nil")
        return
    end

    self.bClockIsActive = Flag
end

---@type 获取闹钟设置信息
function FishNotesMgr:GetFishNoteClockSetting()
    return self.FishClockSetting
end
--endregion

--region 2.闹钟数量
function FishNotesMgr:GetMaxClockNum()
    local Cfg = NoteParamCfg:FindCfgByKey(ProtoRes.NoteParamCfgID.NoteFishClockMaxNum)
    if Cfg and Cfg.Value then
        return Cfg.Value[1]
    end
    return 99 --服务器也有判断
end

function FishNotesMgr:GetTotalClockNum()
    local ClockList = self.ClockList
    local Num = 0
    if ClockList ~= nil then
        for _, FishDatas in pairs(ClockList) do
            for _, _ in pairs(FishDatas) do
                Num = Num + 1
            end
        end
    end
    return Num
end
--endregion

--region 3.闹钟列表获取与排序
---@type 闹钟排序
---@param Clock1 闹钟1
---@param Clock2 闹钟2
function FishNotesMgr.ClockSortFunc(Clock1, Clock2)
    if Clock1.bActive ~= Clock2.bActive then
        return Clock1.bActive == true
    end
    if Clock1.bActive == true and Clock2.bActive == true then
        return Clock1.LeftTime < Clock2.LeftTime
    else
        if Clock1.Begin ~= nil and Clock2.Begin ~= nil and Clock1.Begin ~= Clock2.Begin then
            return Clock1.Begin < Clock2.Begin
        end
    end

    if Clock1.FishID ~= Clock2.FishID then
        return Clock1.FishID < Clock2.FishID
    end
    if FishNotesMgr:CheckFishLocationbLock(Clock1.LocationID) ~= FishNotesMgr:CheckFishLocationbLock(Clock2.LocationID) then
        return FishNotesMgr:CheckFishLocationbLock(Clock1.LocationID) == false and FishNotesMgr:CheckFishLocationbLock(Clock2.LocationID) == true
    end
    return Clock1.LocationID < Clock2.LocationID
end

---@type 获取按窗口期排序后的闹钟列表
---@param FishID number 鱼类ID
---@param LocationID number 渔场ID
function FishNotesMgr:GetClockListSorted()
    local ClockListSorted = {}
    local ClockData = self:GetClockData()
    if ClockData ~= nil then
        for _, ClockList in pairs(ClockData) do
            for _, Clock in pairs(ClockList) do
                table.insert(ClockListSorted,Clock)
            end
        end
        table.sort(ClockListSorted,self.ClockSortFunc)
    end
    return ClockListSorted
end

---@type 获取活跃中闹钟列表
function FishNotesMgr:GetActivedClockListSorted()
    local ActivedList = {}
    local Now = TimeUtil.GetServerTime()
    local FishingholeList = self:GetFishingholeList()
    if not table.is_nil_empty(FishingholeList) then
        for _, Location in pairs(FishingholeList) do
            if not self:CheckFishLocationbLock(Location.ID) then
                local FishList = self:GetLocationFishListByID(Location.ID)
                for _, FishID in pairs(FishList) do
                    local Begin, End = FishNotesMgr:GetFishNeasetWindowTime(FishID, Location.ID)
                    if Begin ~= nil and End ~= nil and Now >= Begin and Now < End then
                        local LeftTime = End - Now
                        local Data = {FishID = FishID, LocationID = Location.ID, Begin = Begin, End = End, bActive = true, LeftTime = LeftTime, Tab = 2}
                        table.insert(ActivedList,Data)
                    end
                end
            end

        end
        table.sort(ActivedList, function(a, b)
            if a.LeftTime ~= b.LeftTime then
                return a.LeftTime < b.LeftTime
            end
            return a.FishID <b.FishID
        end)
    end
    return ActivedList
end
--endregion

--region 4.设置添加闹钟
---@type 设置闹钟信息_有则改无则加
---@param ItemID number 鱼类ID
function FishNotesMgr:SetClockData(FishID, LocationID)
    self.ClockList = self.ClockList or {}
    self.ClockList[FishID] = self.ClockList[FishID] or {}
    local Clock = self.ClockList[FishID][LocationID] or {FishID = FishID, LocationID = LocationID}
    local Now = TimeUtil.GetServerTime()
    --发送添加闹钟前已经检测，如果没有窗口期则不能设置闹钟
    local Begin, End = self:GetFishNeasetWindowTime(FishID, LocationID)
    Clock.Begin = Begin
    Clock.End = End
    Clock.LeftTime = Begin ~= nil and End ~= nil and End - Begin or 0
    Clock.bActive = Begin ~= nil and End ~= nil and Now >= Clock.Begin and Now < Clock.End
    self.ClockList[FishID][LocationID] = Clock
end

---@type 获取指定钓场ID指定鱼ID的闹钟数据
---@param ItemID number 鱼类ID
function FishNotesMgr:GetClockData(FishID, LocationID)
    if self.ClockList == nil then
        return
    end
    if FishID == nil and LocationID == nil then
        return self.ClockList
    elseif FishID and LocationID and self.ClockList[FishID] then
        return self.ClockList[FishID][LocationID]
    end
    return nil
end

---@type 检查闹钟信息
---@param FishID table 鱼类ID
---@param LocationID number 地区ID
---@param NowTime number 当前时间
function FishNotesMgr:CheckClockData(FishID, LocationID, NowTime)
    if self.ClockList == nil or FishID == nil or LocationID == nil then
        return nil
    end

    local TimeList = self.ClockList[FishID]
    local ClockData = TimeList and TimeList[LocationID]
    if ClockData == nil then
        return nil
    end

    local Formmat = "%Y-%m-%d %H:%M:%S"
    local NowTimeStr = TimeUtil.GetTimeFormat(Formmat, NowTime)
    local EndTimeStr = TimeUtil.GetTimeFormat(Formmat, ClockData.End)
    FLOG_INFO(string.format("FishNotesMgr:CheckClockData NowTimeStr:%s",NowTimeStr))
    FLOG_INFO(string.format("FishNotesMgr:CheckClockData EndTimeStr:%s",EndTimeStr))
    if NowTime ~= nil and ClockData.End ~= nil and NowTime >= ClockData.End then
        FLOG_WARNING("FishNotesMgr:CheckClockData NowTime > ClockData.End")
        self:SetClockData(FishID,LocationID)--改:更新时间
        _G.FishIngholeVM:RefreshClockTabView()
    end

    return self.ClockList[FishID][LocationID]
end
--endregion

--region 5.闹钟检测_通知_关闭
---@type 闹钟提醒计时器刷新（当闹钟添加或删除，以及闹钟设置更改都会触发重新计时）
function FishNotesMgr:OnClockTimerUpdate()
	self:UnRegisterTimer(self.ClockTimerID)
    if self:IsNeedStartClockTimer() == false and self.ClockTimer then
        return
    end
    self.StartTimeCount = 0
    self.ComingTimeCount = 0
    self.StartCountDownTime = 0
    self.ComingCountDownTime = 0
    self.ComingClock = nil
    self.StartClock = nil

	self.ClockTimerID = self:RegisterTimer(self.ClockTimer,0,self.TickDeltaTime,0)
end

---@type 每秒执行闹钟计时
function FishNotesMgr:ClockTimer()
    if PWorldMgr == nil then
        return
    end
    --正在加载地图,不通知
    if PWorldMgr:IsLoadingWorld() then
        return
    end

    self:ComingNotifyTick()
    self:StartNotifyTick()
end

---@type 提前提醒计时
function FishNotesMgr:ComingNotifyTick()
    if self:SetComingNotifyCD() == false then
        --self:SetComingNotifyCD()
        return
    end

    self.ComingTimeCount = self.ComingTimeCount + self.TickDeltaTime
    if self.ComingTimeCount < self.ComingCountDownTime then
        return
    end
	FLOG_INFO(string.format("FishNotesMgr self.ComingTimeCount:%d",self.ComingTimeCount))
	FLOG_INFO(string.format("FishNotesMgr self.ComingCountDownTime:%d",self.ComingCountDownTime))
    self.ComingCountDownTime = 0
    self.ComingTimeCount = 0
    --在副本中/水晶冲突副本中
    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon() or _G.PWorldMgr:CurrIsInPVPColosseum()
    if IsInDungeon and self.FishClockSetting and self.FishClockSetting.CloseNotify == true then
        return
    end
    self:TryAddSidebarAdvanceNotice(self.ComingClock)
end

---@type 窗口期提醒计时
function FishNotesMgr:StartNotifyTick()
    if self:SetStartNotifyCD() == false then
        return
    end

    self.StartTimeCount = self.StartTimeCount + self.TickDeltaTime
    if self.StartTimeCount < self.StartCountDownTime then
        return
    end

    self.StartCountDownTime = 0
    self.StartTimeCount = 0
    --在副本中
    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    if IsInDungeon and self.FishClockSetting and self.FishClockSetting.CloseNotify == true then
        return
    end
    self:TryAddSidebarStartedNotice(self.StartClock)
end

---@type 是否满足开启闹钟计时条件
function FishNotesMgr:IsNeedStartClockTimer()
    if self.FishClockSetting == nil then
        return false
    end

    if self.FishClockSetting.Trigger == false then
        return false
    end

    if self.FishClockSetting.StartNotify == false and self.FishClockSetting.IsComingNotify == false then
        return false
    end
    --没有闹钟订阅数据
    if table.is_nil_empty(self.ClockList) then
        return false
    end
    return true
end

---@type 设置窗口期提醒闹钟倒计时
function FishNotesMgr:SetStartNotifyCD()
    if self.StartCountDownTime > 0 then
        return true
    end

    local IsStartNotify = self.FishClockSetting.StartNotify
    if IsStartNotify == false then
        return false
    end
    local function Predicate(Clock)
        local IsSameBegin = false
        if self.StartClock then
            IsSameBegin = Clock.Begin == self.StartClock.Begin
        end
        return not Clock.IsStartNotified and not IsSameBegin
    end
    self.StartClock = self:TryGetNearestNotifyClock(Predicate)
    if self.StartClock == nil then
        return false
    end

    if self.StartClock.Begin == nil or self.StartClock.Begin == 0 then
        return false
    end
    local Formmat = "%Y-%m-%d %H:%M:%S"
    local TimeStr = TimeUtil.GetTimeFormat(Formmat, self.StartClock.Begin)
	FLOG_INFO(string.format("FishNotesMgr:SetStartNotifyCD. self.StartClock.Begin:%s",TimeStr))
    local Now = TimeUtil.GetServerTime()
    local TimeStr1 = TimeUtil.GetTimeFormat(Formmat, Now)
	FLOG_INFO(string.format("FishNotesMgr:SetStartNotifyCD. Now:%s",TimeStr1))
    --鱼已经出现了
    if Now >= self.StartClock.Begin then
        self.StartCountDownTime = 0
        local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
        if IsInDungeon and self.FishClockSetting and self.FishClockSetting.CloseNotify == true then
            return false
        end
        self:TryAddSidebarStartedNotice(self.StartClock)
		FLOG_INFO(string.format("FishNotesMgr:The fish have appeared. The AozyTime is %s",TimeUtil.GetAozyTimeFormat()))
        return false
    end
    self.StartCountDownTime = self.StartClock.Begin - Now
    return true
end

---@type 设置提前提醒闹钟倒计时
function FishNotesMgr:SetComingNotifyCD()
    if self.ComingCountDownTime > 0 then
        return true
    end

    local IsComingNotify = self.FishClockSetting.IsComingNotify
    if IsComingNotify == false then
        return false
    end
    local Now = TimeUtil.GetServerTime()
    local function Predicate(Clock)
        local IsSameBegin = false
        if self.ComingClock then
            IsSameBegin = Clock.Begin == self.ComingClock.Begin
        end
		return not Clock.IsComingNotified and Clock.Begin ~= nil and Clock.Begin > Now and not IsSameBegin
    end
    self.ComingClock = self:TryGetNearestNotifyClock(Predicate)
    if self.ComingClock == nil then
        return false
    end

    if self.ComingClock.Begin == nil then
        return false
    end
    --已经出现，不需要提前通知
    local RemainTime = self.ComingClock.Begin - Now
    if RemainTime <= 0 then
        FLOG_INFO("FishNotesMgr:SetComingNotifyCD. RemainTime <= 0")
        return false
    end

    local Formmat = "%Y-%m-%d %H:%M:%S"
    local TimeStr = TimeUtil.GetTimeFormat(Formmat, self.ComingClock.Begin)
	FLOG_INFO(string.format("FishNotesMgr:SetComingNotifyCD. self.ComingClock.Begin:%s",TimeStr))
    local TimeStr1 = TimeUtil.GetTimeFormat(Formmat, Now)
	FLOG_INFO(string.format("FishNotesMgr:SetComingNotifyCD. Now:%s",TimeStr1))
    FLOG_INFO(string.format("FishNotesMgr:SetComingNotifyCD. RemainTime:%d",RemainTime))

    local ComingNotify = self.FishClockSetting.ComingNotify
    local ComingNotifySeconds = ComingNotify * 60
    FLOG_INFO(string.format("FishNotesMgr ComingNotifySeconds:%d",ComingNotifySeconds))

    self.ActualRemainApearSeconds = ComingNotifySeconds
    self.ComingCountDownTime = RemainTime - ComingNotifySeconds
    FLOG_INFO(string.format("FishNotesMgr:SetComingNotifyCD. self.ComingCountDownTime:%d",self.ComingCountDownTime))
    FLOG_INFO(string.format("FishNotesMgr:SetComingNotifyCD. self.ComingTimeCount:%d",self.ComingTimeCount))
    if self.ComingCountDownTime <= 0 then
        self.ComingCountDownTime = 0
        self.ActualRemainApearSeconds = RemainTime
        local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
        if IsInDungeon and self.FishClockSetting and self.FishClockSetting.CloseNotify == true then
            return false
        end
        self:TryAddSidebarAdvanceNotice(self.ComingClock)
        return false
    end

    return true
end

---@type 获取窗口期离现在最近的闹钟
function FishNotesMgr:TryGetNearestNotifyClock(Predicate)
    local ClockList = self:GetClockListSorted()
    if ClockList == nil or next(ClockList) == nil then
        return nil
    end

    local NearestClock = nil
    for _, Clock in pairs(ClockList) do
        if Predicate(Clock) then
            NearestClock = Clock
            break
        end
    end

    return NearestClock
end

---@type 将所有与已通知的闹钟开始时间相同的标记成已通知
---@param NotifyClock 已通知闹钟
---@param IsAdvanceNotify 是否提前通知
function FishNotesMgr:SetSameBeginClockNotified(NotifyClock, IsAdvanceNotify)
    if NotifyClock == nil then
        return
    end
    local Clock = self.ClockList[NotifyClock.FishID][NotifyClock.LocationID]
    Clock.IsComingNotified = IsAdvanceNotify
    Clock.IsStartNotified = not IsAdvanceNotify
end

---@type 弹出提前通知的测边栏提示
---@param Clock 闹钟数据
function FishNotesMgr:TryAddSidebarAdvanceNotice(Clock) 
    local RemainTime = LocalizationUtil.GetCountdownTimeForLongTime(self.ActualRemainApearSeconds or 0)
    self.ComingNotifyContent = string.format(LSTR(180099), RemainTime) --%s后出现
    local StartTime = TimeUtil.GetServerTime()
    local SidebarDuration = 60
    local FishData = string.format("%d.%d", Clock.LocationID, Clock.FishID)
    local Fish = self:GetFishCfg(Clock.FishID)
    local TransData = {IsComingNotify = true, FishData = FishData, FishName = Fish.Name, ResID = Fish.ItemID}
    SidebarMgr:AddSidebarItem(SidebarType, StartTime, SidebarDuration, TransData)
    FishNotesMgr:StartClockAlarm()
    self:SetSameBeginClockNotified(Clock, true)
end

---@type 弹出已出现的测边栏提示
---@param Clock 闹钟数据
function FishNotesMgr:TryAddSidebarStartedNotice(Clock)
    self.StartNotifyContent = LSTR(180100)--"活跃出现中"
    local StartTime = TimeUtil.GetServerTime()
    local SidebarDuration = 60
    local FishData = string.format("%d.%d", Clock.LocationID, Clock.FishID)
    local Fish = self:GetFishCfg(Clock.FishID)
    local TransData = {IsComingNotify = false, FishData = FishData, FishName = Fish.Name, ResID = Fish.ItemID}
    SidebarMgr:AddSidebarItem(SidebarType, StartTime, SidebarDuration, TransData)
    FishNotesMgr:StartClockAlarm()
    self:SetSameBeginClockNotified(Clock, false)
end

function FishNotesMgr:StartClockAlarm()
    if self.FishClockSetting and self.FishClockSetting.Sound then
        local ClockAlarmID = AudioUtil.LoadAndPlayUISound(GatheringLogDefine.ClockSoundPath)
        self.ClockAlarmList = self.ClockAlarmList or {}
        table.insert(self.ClockAlarmList, ClockAlarmID)
    end
end

function FishNotesMgr:CloceClockAlarm(CloseAll)
    if not table.is_nil_empty(self.ClockAlarmList) then
        if CloseAll then
            for _, value in pairs(self.ClockAlarmList) do
                AudioUtil.StopAsyncAudioHandle(value)
            end
        else
            local ClockAlarmID = table.remove(self.ClockAlarmList, 1)
            AudioUtil.StopAsyncAudioHandle(ClockAlarmID)
        end
    end
end

---@type 闹钟侧边栏点击关闭事件
function FishNotesMgr:ClockSidebarCloseCallBack(TransData)
    SidebarMgr:RemoveSidebarItemByParam(TransData.FishData, "FishData")
    FishNotesMgr:CloceClockAlarm()
end

---@type 闹钟侧边栏点击前往事件
function FishNotesMgr:ClockSidebarCconfirmCallBack(TransData)
    if TransData.FishData == nil then
        SidebarMgr:RemoveSidebarItem( SidebarType )
        self:CloceClockAlarm(true)
        return
    end
    local FishDatas =  string.split(TransData.FishData, ".")
    if FishDatas == nil or #FishDatas ~= 2 then
        SidebarMgr:RemoveSidebarItem( SidebarType )
        self:CloceClockAlarm(true)
        return
    end
    local LocationID = tonumber(FishDatas[1])
    local FishID = tonumber(FishDatas[2])
    self.SidebarNoticedFishID = FishID
    self.SidebarNoticedLocationID = LocationID
    --打开闹钟界面
    if _G.UIViewMgr:IsViewVisible(UIViewID.FishGuide) then
		_G.UIViewMgr:HideView(UIViewID.FishGuide)
    end
    if not _G.UIViewMgr:IsViewVisible(UIViewID.FishInghole) then
		_G.UIViewMgr:ShowView(UIViewID.FishInghole, {TabIndex = 0})
    else
        _G.FishIngholeVM:OnClickSwitch(_G.UE.EToggleButtonState.Checked)
    end

    SidebarMgr:RemoveSidebarItemByParam(TransData.FishData, "FishData")
    self:CloceClockAlarm()
    self:RegisterTimer(function()
        if self.SidebarNoticedFishID and FishID == self.SidebarNoticedFishID and self.SidebarNoticedLocationID == LocationID then
            self.SidebarNoticedFishID = nil
            self.SidebarNoticedLocationID = nil
        end
    end ,0.5,0,1)
end

---@type 打开钓鱼闹钟侧边栏
---@param StartTime 开始时间
---@param CountDown 侧边栏存在时间
function FishNotesMgr:OpenFishClockRequestSidebar(StartTime, CountDown, TransData, Type)
    if TransData == nil then
        return
    end
    local Content = TransData.IsComingNotify and self.ComingNotifyContent or self.StartNotifyContent
    local Params = {
        Title           = LSTR(180003),--钓鱼闹钟提醒
        Desc1           = TransData.FishName or "",
        Desc2           = Content or "",
        StartTime       = StartTime,
        CountDown       = CountDown,
        CBFuncObj       = self,
        CBFuncRight  = self.ClockSidebarCconfirmCallBack,
        CBFuncLeft  = self.ClockSidebarCloseCallBack,
        BtnTextRight = LSTR(70037), --查看
        BtnTextLeft = LSTR(180005),--关闭
		Type = Type,
        TransData = TransData
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.SidebarFishClock, Params)
end

---@type 闹钟提醒侧边栏Item超时
function FishNotesMgr:OnGameEventSidebarItemTimeOut(Type,TransData)
    if Type ~= SidebarType then
        return
    end

    self:ClockSidebarCloseCallBack(TransData)
end
--endregion
--endregion

--region Server Message=======================
---@type 发送解锁鱼类列表信息
function FishNotesMgr:SendMsgGetUnlockFishList()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_FISH_NOTE_BOOK_LIST
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 接收解锁鱼类列表回执
---@param MsgBody table 回执信息, MsgBody.bookList = { BookList = { [1] = {FishID = 鱼ID, Count = 历史捕获总数, Size = 捕获的最大尺寸} } }
function FishNotesMgr:OnNetMsgGetUnlockFishList(MsgBody)
    if MsgBody.bookList == nil then
        return
    end

    self.FishUnlockList = {}
    local Msg = MsgBody.bookList
    local DataList = Msg.BookList
    if DataList and #DataList > 0 then
        local Data
        for i = 1, #DataList do
            Data = DataList[i]
            self.FishUnlockList[Data.FishID] = {
                Count = Data.Count,
                Size = Data.Size,
                SizeTime = Data.SizeTime
            }
        end
    end

    EventMgr:SendEvent(EventID.FishNoteRefreshGuideList)
end

---@type 发送获取钓场鱼类闹钟和解锁信息
function FishNotesMgr:SendMsgGetFishGroundList()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_FISH_GROUND_QUERY
    local MsgBody = {}

    MsgBody.Cmd = SubMsgID
    MsgBody.clockData = {}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 进入钓场时请求解锁钓场
---@param AreaID 钓场ID
function FishNotesMgr:OnEnterFishAreaSendUnlock(GroundID)
    _G.FLOG_INFO("FishNotesMgr:OnEnterFishAreaSendUnlock GroundID is %d", GroundID or 0)
    local ProfID = MajorUtil.GetMajorProfID()
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDFisherNote) and ProfID ~= ProtoCommon.prof_type.PROF_TYPE_FISHER then --捕鱼人解锁时，笔记解锁慢职业一步
        _G.FLOG_INFO("FishNotesMgr:OnEnterFishAreaSendUnlock FishNote is Lock")
        return
    end
    if GroundID == nil or not self:CheckFishLocationbLock(GroundID) then
        return
    end
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUND_UNLOCK
    local MsgBody = {}

    MsgBody.Cmd = SubMsgID
    MsgBody.groundUnlock = {
        AreaID = GroundID
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 接收获取钓场解锁和闹钟回执
function FishNotesMgr:OnNetMsgGetFishGroundList(MsgBody)
    --只主动拉取一次，后面通过新增刷新
    if MsgBody == nil or MsgBody.fishClock == nil then
        return
    end
    local FishGroundList = MsgBody.fishClock.FishGroundList
    self.FishGroundList = FishGroundList
    for GroundID, GroundData in pairs(FishGroundList) do
        local FishDatas = GroundData.FishData
        --设置闹钟（批量增加）
        for _, FishData in pairs(FishDatas) do
            if FishData.IsSubscribe then
                self:SetClockData(FishData.FishID, GroundID)
            end
        end
        --钓场的解锁
        self.FishLocationUnlockList[GroundID] = true
        DataReportUtil.ReportSystemFlowData("FishingNotesInfo", 5, GroundID, _G.FishIngholeVM:GetCurLocationUnLockFishNum())
    end
    self:OnClockTimerUpdate()
    self.IsGetClockInfo = true
    EventMgr:SendEvent(EventID.FishNoteRefreshLocationList)
    _G.FLOG_INFO("SendEvent EventID.FishNoteRefreshLocationList")
end

---@type 发送添加闹钟信息
---@param ItemID number 鱼类ID
function FishNotesMgr:SendMsgAddClock(ItemID, GroundID)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_FISH_CLOCK_UPDATE
    local MsgBody = {}

    MsgBody.Cmd = SubMsgID
    MsgBody.fishClockUpdate = {
        GroundID = GroundID,
		FishID = ItemID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 发送取消闹钟信息
---@param ItemID number 鱼类ID
function FishNotesMgr:SendMsgCancelClock(ItemID, GroundID)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_FISH_CLOCK_CANCEL
    local MsgBody = {}

    MsgBody.Cmd = SubMsgID
    MsgBody.fishClockCancel = {
        GroundID = GroundID,
		FishID = ItemID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 添加或取消闹钟刷新
---@param MsgBody table 回执消息体, MsgBody.clockUpdate = {Result = {NoteType = 笔记枚举, ItemID = 操作的鱼类ID, IsSubscribe = 是否订阅} }
function FishNotesMgr:OnUpdateClock(FishID, GroundID, IsSubscribe)
    if self.ClockList == nil then
        self.ClockList = {}
    end
    if IsSubscribe == true then
        self:SetClockData(FishID, GroundID)--单个闹钟增
        _G.FishIngholeVM:RefreshClockTabView()
        MsgTipsUtil.ShowTips(LSTR(FishNotesDefine.ClockSetSucceedText))
    else
        if self.ClockList and self.ClockList[FishID] and self.ClockList[FishID][GroundID] then
            self.ClockList[FishID][GroundID] = nil--单个闹钟删
            _G.FishIngholeVM:RefreshClockTabView()
            local FishData = string.format("%d.%d",GroundID, FishID)
            SidebarMgr:RemoveSidebarItemByParam(FishData, "FishData")
            self:CloceClockAlarm()
        end
    end

    self:OnClockTimerUpdate()
    FishNotesClockSetWindVM:UpdateVM(self:GetFishNoteClockSetting())
    EventMgr:SendEvent(EventID.FishNoteClockSubscribeChanged, FishID, IsSubscribe)
end

---@type 请求修改闹钟设置
---@param NoteType table @笔记类型
---@param Setting table @闹钟设置
function FishNotesMgr:SendMsgClockSettinginfo(NoteType, Setting)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CLOCK_SET

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.set = {}
    MsgBody.set.NoteType = NoteType
    MsgBody.set.Setting = Setting
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 接收闹钟设置
---@param MsgBody table @闹钟设置信息
function FishNotesMgr:OnNetMsgClockSettingInfo(MsgBody)
    if MsgBody == nil then
        return
    end

    if MsgBody.set == nil then
        return
    end

    local Setting = MsgBody.set.Setting
    if Setting == nil then
        return
    end

    self.FishClockSetting = Setting
    --取消勾选“在主界面显示提醒”等前三个，主界面的钓鱼闹钟侧边栏要消失
    if Setting.Trigger == false or Setting.StartNotify == false or Setting.IsComingNotify == false
        --在副本中，钓鱼闹钟侧边栏出现后，开启“处于封闭任务时不再提示”，闹钟侧边栏消失
        or (Setting.CloseNotify == true and _G.PWorldMgr:CurrIsInDungeon()) then
            SidebarMgr:RemoveSidebarAllItem( SidebarType )
            self:CloceClockAlarm(true)
    end
    --闹钟提醒设置更新
    self:OnClockTimerUpdate()
    FishNotesClockSetWindVM:UpdateVM(self:GetFishNoteClockSetting())
end

---@type 发送获取闹钟设置信息
function FishNotesMgr:SendMsgGetClockList()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CLOCK
    local MsgBody = {}

    MsgBody.Cmd = SubMsgID
    MsgBody.clock = {
        NoteType = FishNotesDefine.FishNoteType
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function FishNotesMgr:OnNetMsgClockInfo(MsgBody)
    if MsgBody == nil or MsgBody.clock == nil then
        return
    end
    local ClockInfo = MsgBody.clock.ClockInfo
    if ClockInfo == nil or ClockInfo.NoteType ~= FishNotesDefine.FishNoteType then
        return
    end

    --闹钟提醒设置
    local ClockSetting = ClockInfo.Setting
    if ClockSetting == nil then
        return
    end
    self.FishClockSetting = {
        Trigger = ClockSetting.Trigger,
        Sound = ClockSetting.Sound,
        IsComingNotify = ClockSetting.IsComingNotify,
        ComingNotify = ClockSetting.ComingNotify,
        StartNotify = ClockSetting.StartNotify,
		CloseNotify = ClockSetting.CloseNotify,
    }
    FishNotesClockSetWindVM:UpdateVM(self:GetFishNoteClockSetting())
end

---@type 通知鱼类数据刷新
---@param MsgBody table 回执消息体, MsgBody.fishUpdate = { UpdateBook = {FishID = 鱼ID, Count = 历史捕获总数, Size = 捕获的最大尺寸} }
function FishNotesMgr:OnNetMsgFishUpdate(MsgBody)
    if MsgBody == nil then
        return
    end

    local Msg = MsgBody.fishUpdate
    local Data = Msg.UpdateBook
    local FishID = Data.FishID
    self.FishUnlockList = self.FishUnlockList or {}
    self.FishUnlockList[FishID] = {
        Count = Data.Count,
        Size = Data.Size,
        SizeTime = Data.SizeTime
    }

    EventMgr:SendEvent(EventID.FishNoteRefreshFishData, FishID)

    local FishData = self:GetFishCfg(FishID)
    if FishData then 
        DataReportUtil.ReportSystemFlowData("FishingNotesInfo", 3, FishID, FishData.Rarity, FishData.VersionName, _G.FishGuideVM.TotalFishUnLock, _G.FishGuideVM.FishKingUnlock, _G.FishGuideVM.FishQueenUnlock)
    end
end
--endregion

--region RedDot=======================
---@type 拉取红点
function FishNotesMgr:SendMsgGetPlaceRedDot()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_RED_POINT
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.redPoint = {
        Ops = ProtoCS.NoteOps.NoteOpsFishGround,
        Param = {
            NoteType = FishNotesDefine.FishNoteType,
            ProfID = 38
          }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

local function NumToBytesStr(num)
    local str = ""
	for i = 0, 7 do
		str = str .. string.char(num >> (i * 8))
	end
    return str
end

---@type 移除红点
function FishNotesMgr:SendMsgRemovePlaceRedDot(FishGroundID)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_RED_POINT
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.redPoint = {
        Ops = ProtoCS.NoteOps.NoteOpsFishGround,
        Param = {
            NoteType = FishNotesDefine.FishNoteType,
            FishGroundID = NumToBytesStr(FishGroundID),
            ProfID = 38
          }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 获取或更新钓鱼笔记获得下拉列表的红点
function FishNotesMgr:OnNetMsgUpdateRedDot(MsgBody)
    if nil == MsgBody or nil == MsgBody.redPoint or table.is_nil_empty(MsgBody.redPoint.Param) then
        return
    end
    local Param = MsgBody.redPoint.Param
    local FishGroundStr = Param.FishGroundID
    if Param.NoteType ~= FishNotesDefine.FishNoteType or string.isnilorempty(FishGroundStr) then
        return
    end
    local FishGroundByteArray = BitUtil.StringToByteArray(FishGroundStr)
    self.FishGroundRedDotByteArray = FishGroundByteArray
    local baseID = 0
    for _, Byte in ipairs(FishGroundByteArray) do
        if Byte ~= 0 then
            for Index = 0, 7 do
                if BitUtil.IsBitSet(Byte, Index, false) then
                    local PlaceID = baseID + Index
                    FLOG_INFO(string.format("501PlaceID:%d",PlaceID))
                    self:AddFishingholeRedDot(PlaceID)
                end
            end
        end
        baseID = baseID + 8
    end
end

function FishNotesMgr:OnNetMsgAddRedDot(MsgBody)
    if nil == MsgBody or nil == MsgBody.fishRedPoint then
        return
    end
    local FishGroundID = MsgBody.fishRedPoint.FishGroundID
    if FishGroundID == nil or FishGroundID == 0 then
        return
    end
    self:AddFishingholeRedDot(FishGroundID)
end

--钓场（弱）红点提醒
function FishNotesMgr:AddFishingholeRedDot(PlaceID)
    local PlaceData = self:GetPlaceInfoByPlaceID(PlaceID)
    if PlaceData then
        local Faction = PlaceData.Faction
        local Area = PlaceData.Area

        local FactionRedDotName = self:GetFishingholeRedDotName(Faction)
        if not FactionRedDotName then
            FactionRedDotName = RedDotMgr:AddRedDotByParentRedDotID(FishNotesDefine.FactionRedDotID)
            local FactionRedNode = RedDotMgr:FindRedDotNodeByName(FactionRedDotName)
            if FactionRedNode then
                FactionRedNode.Faction = Faction
                FactionRedNode.SubRedDotList = {}
            end
        end

        local AreaRedDotName = self:GetFishingholeRedDotName(Faction, Area)
        if not AreaRedDotName then
            AreaRedDotName = RedDotMgr:AddRedDotByParentRedDotName(FactionRedDotName)
            local AreaRedNode =  RedDotMgr:FindRedDotNodeByName(AreaRedDotName)
            if AreaRedNode then
                AreaRedNode.Area = Area
                AreaRedNode.SubRedDotList = {}
            end
        end

        local PlaceRedDotName = self:GetFishingholeRedDotName(Faction, Area, PlaceID)
        if not PlaceRedDotName then
            local RedDotName = string.format("%s/%s",AreaRedDotName, PlaceID)
            RedDotMgr:AddRedDotByName(RedDotName)
            local RedNode =  RedDotMgr:FindRedDotNodeByName(RedDotName)
            if RedNode then
                RedNode.PlaceID = PlaceID
            end
        end
    end
end

function FishNotesMgr:GetFishingholeRedDotName(Faction, Area, PlaceID)
    if PlaceID ~= nil and Faction == nil and Area == nil  then
        local PlaceData = self:GetPlaceInfoByPlaceID(PlaceID)
        if PlaceData == nil then
            return
        end
        Faction = PlaceData.Faction
        Area = PlaceData.Area
    end

    local FactionRedDotName = nil
    local RedNode =  RedDotMgr:FindRedDotNodeByID(FishNotesDefine.FactionRedDotID)
    if not RedNode then
        return nil
    end
    --获取该职业的红点名 及红点
    local RedNodeList = RedNode.SubRedDotList
    if RedNodeList == nil then
        return
    end
    for _, value in pairs(RedNodeList) do
        if value.Faction == Faction then
            FactionRedDotName = value.RedDotName
            break
        end
    end
    if not FactionRedDotName then
        return nil
    end

    if Area == nil then
        return FactionRedDotName
    end
    local FactionRedNode =  RedDotMgr:FindRedDotNodeByName(FactionRedDotName)
    if not FactionRedNode then
        return nil
    end
    local AreaRedDotList = FactionRedNode.SubRedDotList
    if AreaRedDotList == nil then
        return nil
    end
    local AreaRedDotNode = nil
    for _, value in pairs(AreaRedDotList) do
        if value.Area == Area then
            AreaRedDotNode = value
            break
        end
    end
    if AreaRedDotNode == nil then
        return nil
    end
    if PlaceID == nil then
        return AreaRedDotNode.RedDotName
    end

    local PlaceRedDotList = AreaRedDotNode.SubRedDotList
    if PlaceRedDotList == nil then
        return nil
    end
    for _, value in pairs(PlaceRedDotList) do
        if value.PlaceID == PlaceID then
            return value.RedDotName
        end
    end
end

function FishNotesMgr:RemoveRedDot(PlaceID, IsSever)
    if not _G.UIViewMgr:IsViewVisible(UIViewID.FishInghole) then
        --界面关闭刷新数据选中时不移除
        return
    end
    local PlaceData = self:GetPlaceInfoByPlaceID(PlaceID)
    if PlaceData == nil then
        return
    end
    local Faction = PlaceData.Faction
    local Area = PlaceData.Area

    local PlaceRedDotName = self:GetFishingholeRedDotName(Faction, Area, PlaceID)
    if PlaceRedDotName then
        if IsSever then
            self:SendMsgRemovePlaceRedDot(PlaceID)
            return
        end
        local PlaceRedNode = RedDotMgr:FindRedDotNodeByName(PlaceRedDotName)
        local AreaRedDotNode = PlaceRedNode.ParentRedDotNode
        local FactionRedDotNode = AreaRedDotNode.ParentRedDotNode
        local IsDel = RedDotMgr:DelRedDotByName(PlaceRedDotName)
        if IsDel then
            if table.is_nil_empty(AreaRedDotNode.SubRedDotList) then
                IsDel = RedDotMgr:DelRedDotByName(AreaRedDotNode.RedDotName)
                if IsDel and table.is_nil_empty(FactionRedDotNode.SubRedDotList) then
                    RedDotMgr:DelRedDotByName(FactionRedDotNode.RedDotName)
                end
            end
        end
    end
end

--关闭界面时移除已读红点
function FishNotesMgr:RemoveRedDotsOnHide()
    local ReadRedDotList = _G.FishIngholeVM.ReadRedDotList
    if not table.is_nil_empty(ReadRedDotList) then
        for key, _ in pairs(ReadRedDotList) do
            self:RemoveRedDot(key)
        end
    end
end

function FishNotesMgr:ShowDebugInfo(bShowDebugInfo)
    self.bShowDebugInfo = bShowDebugInfo
end
--endregion

--region Search=======================
---@type 搜索鱼跳转_显示鱼儿所有可钓地点
---@param FishItemID int32
function FishNotesMgr:ShowCanFishLocation(FishItemID)
    if not _G.UIViewMgr:IsViewVisible(UIViewID.FishInghole) then
		_G.UIViewMgr:ShowView(UIViewID.FishInghole)
    else
        if _G.FishIngholeVM:IsClockView() then
            _G.FishIngholeVM:OnClickSwitch(_G.UE.EToggleButtonState.UnChecked)
        end
    end
    _G.EventMgr:SendEvent(EventID.FishNoteSearchFishLocation, FishItemID)
end

---@type 钓场信息搜索
---@param Content string 搜索内容
---@param AreaName string 区域名
---@return table, boolean 搜索结果列表, 是否有鱼的搜索结果
function FishNotesMgr:SearchInfoInFishinghole(Content)
    self.SearchList = {}
    local AreaChildrenList = {}
    local AreaNameList = {}
    local IsInsertAN = {}
    local IsFish = false

    local Location, Area
    local LocationSearchResult = self:SearchLocation(Content)
    for _, Data in ipairs(LocationSearchResult) do
        Location = self:GetPlaceInfoByPlaceID(Data.ID)
        Area = Location.Area
        if IsInsertAN[Area] == nil then
            IsInsertAN[Area] = 1
            table.insert(AreaNameList, Area)
        end

        AreaChildrenList[Area] = AreaChildrenList[Area] or {}
        table.insert(AreaChildrenList[Area], Data)
    end

    if table.is_nil_empty(LocationSearchResult) then
        IsFish = true
        local FishSearchResult = self:SearchFish(Content)
        for _, Data in ipairs(FishSearchResult) do
            Location = self:GetPlaceInfoByPlaceID(Data.ID)
            Area = Location.Area
            if IsInsertAN[Area] == nil then
                IsInsertAN[Area] = 1
                table.insert(AreaNameList, Location.Area)
            end

            AreaChildrenList[Area] = AreaChildrenList[Area] or {}
            table.insert(AreaChildrenList[Area], Data)
        end
    end

    self.SearchList = AreaChildrenList
    return self.SearchList, AreaNameList, IsFish
end

---@type 鱼搜索
---@param Content string 搜索内容_未解锁也要搜到
---@param AreaName string 区域名
function FishNotesMgr:SearchFish(Content, AreaName)
    local SearchResult = {}
    local FishList
    local FishingholeList = self:GetFishingholeList()
    if not table.is_nil_empty(FishingholeList) then
        for _, Location in pairs(FishingholeList) do
            FishList = self:GetLocationFishListByID(Location.ID)
            for _, FishID in ipairs(FishList) do
                local FishName = self:GetFishName(FishID)
                if FishName == nil then
                    FLOG_WARNING(string.format("FishNotesMgr:SearchFish FishName is nil, FishID = %d", FishID))
                else
                    if string.find(FishName, Content) then
                        table.insert(SearchResult, Location)
                        break
                    end
                end
            end
        end
    end

    return SearchResult
end

---@type 钓场搜索
---@param Content string 搜索内容_未解锁也要搜到
---@param AreaName string 区域名
function FishNotesMgr:SearchLocation(Content)
    local SearchResult = {}
    local FishingholeList = self:GetFishingholeList()
    for _, Location in pairs(FishingholeList) do
        if string.find(Location.Name, Content) and not _G.FishNotesMgr:CheckFishLocationbLock(Location.ID) then
            table.insert(SearchResult, Location)
        end
    end

    return SearchResult
end

---@type 获取搜索鱼类信息
---@param Content string 搜索内容_未解锁也要搜到
function FishNotesMgr:SerachInfoInGuide(Content)
    local Result = {}
    local FishList = self:GetFishDataListByVersion()
    for _, Fish in pairs(FishList) do
        --if self:CheckFishbUnLock(Fish.ID) then
            if tonumber(Content) then
                if tonumber(Content) == Fish.ID then
                    table.insert(Result, Fish)
                end
            else
                if string.find(Fish.Name, Content) then
                    table.insert(Result, Fish)
                end
            end
        --end
    end

    return Result
end
--endregion

---@type 首次钓鱼经验的提示
function FishNotesMgr:FirstFishEXPBonus(Name, Score)
    local EXPBonus = Score.Value
    local GetRitchText = RichTextUtil.GetText(string.format("%s", LSTR(70029)), "d1ba8e", 0, nil)--70029获得了
    local ScoreInfo = ScoreCfg:FindCfgByKey(19000099)
    local IconRichText = RichTextUtil.GetTexture(ScoreInfo.IconName, 40, 40, -10)
    local ScoreRichText = RichTextUtil.GetText(string.format("[%s]", ScoreInfo.NameText), "DAB53AFF", 0, nil)
    local SoceNumRichText =
        RichTextUtil.GetText(string.format("×%s", _G.LootMgr.FormatCurrency(EXPBonus)), "d1ba8e", 0, nil)
    local Content =
        string.format("%s[%s]%s%s%s%s", LSTR(180007), Name, GetRitchText, IconRichText, ScoreRichText, SoceNumRichText) --180007首次钓起了
    if Score.Percent ~= 0 then
        Content = string.format("%s  ( + %d%s)", Content, Score.Percent, "%")
    end
    _G.MsgTipsUtil.ShowTips(Content)
    _G.ChatMgr:AddSysChatMsg(Content)
end

--在iOS平台上增加计数功能，超过40张时进行一次GC
function FishNotesMgr:SetShowCount()
    self.bShowCount = (self.bShowCount or 0) + 1
	if self.bShowCount >= 40 then
		self.bShowCount = 0
		_G.ObjectMgr:CollectGarbage(false, true, false)
	end
end
return FishNotesMgr