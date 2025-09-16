local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FateGeneratorCfgTable = require("TableCfg/FateGeneratorCfg")
local FateTextCfgTable = require("TableCfg/FateTextCfg")
local FateAchievementCfgTable = require("TableCfg/FateAchievementCfg")
local FateEntityCfgTable = require("TableCfg/FateEntityCfg")
local FateModelParamCfgTable = require("TableCfg/FateModelParamCfg")
local WeatherCfgTable = require("TableCfg/WeatherCfg")
local UIBindableList = require("UI/UIBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local FateAchievementRewardCfg = require("TableCfg/FateAchievementRewardCfg")
-- local FateFinishRewardItemVM = require("Game/Fate/VM/FateFinishRewardItemVM")
local FateArchiveConditionItemVM = require("Game/FateArchive/VM/FateArchiveConditionItemVM")
local FateArchiveEventTabItemVM = require("Game/FateArchive/VM/FateArchiveEventTabItemVM")
-- local FateDefine = require("Game/Fate/FateDefine")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local AchievementType = ProtoRes.Game.FATE_ACHIEVEMENT_TYPE

local FateArchiveMainVM = LuaClass(UIViewModel)

function FateArchiveMainVM:Ctor()
    -- self.bFinished = false
    self.EventInfoList = {}
    self.EventInfoTable = {}
    self.bShowPanelPreview = false
    self.FateName = ""
    self.FateDescribe = ""
    -- self.FateMapText = ""
    self.FateCondition = ""
    self.HideConditionText = ""
    self.SwitcherInfoPanel = 0
    self.MapScale = 1
    self.MonsterResID = 0
    -- 调试参数，用于策划可视调节模型位置
    self.ModelCameraDistance = 0
    self.ModelHeightOffset = 0
    self.ModelHorizontalOffset = 0
    self.ModelRotate = 0
    self.bShowDebugUI = false
    self.FateModelParamCfg = nil
    self.ProgressText = ""
    self.ProgressPercent = 0
    self.bIsShowMap = false
    self.bHaveReward = false
    self.bShowFateSpecial = false
    self.bShowBtnViewMap = true
    self.FateSpecial = ""
    -- self.IconPath = ""
    -- self.RewardList = UIBindableList.New(FateFinishRewardItemVM)
    self.ConditionList = UIBindableList.New(FateArchiveConditionItemVM)
    self.FateEventList = UIBindableList.New(FateArchiveEventTabItemVM)
end

function FateArchiveMainVM:OnBegin()
end

function FateArchiveMainVM:OnHide()
    self.MonsterResID = 0
end

function FateArchiveMainVM:SetFateEventList(EventInfoList, SelectIndex)
    self.EventInfoList = EventInfoList
    for _, v in pairs(EventInfoList) do
        self.EventInfoTable[v.ID] = v
    end
    self.FateEventList:UpdateByValues(EventInfoList)
end

function FateArchiveMainVM:SelectEvent(ID)
    self.SelectID = ID

    local FateInfo = _G.FateMgr:GetFateInfo(ID)
    if FateInfo ~= nil or self.bForceShowAll then
        -- 初始化右边的面板
        local EventInfo = self.EventInfoTable[ID]
        local LevelStr = string.format(LSTR(10031), EventInfo.Level)
        self.FateName = string.format("%s %s", LevelStr, EventInfo.Name)
        local FateTextCfg = FateTextCfgTable:FindCfgByKey(ID)
        self.FateModelParamCfg = FateModelParamCfgTable:FindCfgByKey(ID)

        self.FateDescribe = LSTR(190125) .. FateTextCfg.StoryCh

        -- 构造创造条件文本
        local FateGeneratorCfg = FateGeneratorCfgTable:FindCfgByKey(ID)
        self.FateCondition = self:GetFateConditionText(FateGeneratorCfg)

        -- 特殊机制
        local TempStr = _G.FateMgr:GetFateSpecialTexet(ID)
        if (TempStr == nil) then
            self.bShowFateSpecial = false
        else
            self.bShowFateSpecial = true
        end
        self.FateSpecial = TempStr

        -- 初始化危命目标显示
        local Achievement = nil
        if FateInfo ~= nil then
            Achievement = FateInfo.Achievement
        end
        local ForceShow = false
        if Achievement == nil or self.bForceShowAll then
            Achievement = {
                {Progress = 1, Target = 1},
                {Progress = 1, Target = 1},
                {Progress = 1, Target = 1},
                {Progress = 1, Target = 1}
            }
            ForceShow = true
        end
        local EventCfg = FateAchievementCfgTable:FindCfgByKey(ID)
        if EventCfg ~= nil then
            if (Achievement ~= nil and #Achievement > 0) then
                for index, value in ipairs(Achievement) do
                    value.ID = EventCfg.Achievements[index].EventID
                    value.Params = EventCfg.Achievements[index].Params
                    --value.Target = EventCfg.Achievements[index].Count --这里不要写入Target,服务器下发的count用来做是否显示了，不要修改
                    value.RequireAward = EventCfg.Achievements[index].RequireAward
                    value.TableCount = EventCfg.Achievements[index].Count
                    Achievement.RequireAward = value.RequireAward
                    local IsMultiEvent = value.ID == AchievementType.FATE_ACHIEVEMENT_TYPE_GENERAL_MUTLI_EVENT
                    if (IsMultiEvent) then
                        local bTargetValid = value.Target ~= nil and value.Target > 0
                        local bProgressValid = value.Progress ~= nil and value.Progress > 0
                        local bFinished = bTargetValid and bProgressValid and value.Progress >= value.Target
                        if (bFinished) then
                            value.Progress = 1
                            value.Target = 1
                        else
                            value.Progress = 0
                        end
                    end

                    if (ForceShow) then
                        if (value.Target < 1) then
                            value.Target = 1
                        end
                        value.Progress = value.Target
                    end
                end
            else
                if (Achievement == nil) then
                    Achievement = {}
                end

                for index = 1, #EventCfg.Achievements, 1 do
                    local newData = {}
                    table.insert(Achievement, newData)
                    newData.ID = EventCfg.Achievements[index].EventID
                    -- newData.Target = 0 这里不要写Target,服务器下发的count用来做是否显示了，不要修改
                end
            end
        end
        local RevealCount = 0
        for Idx, Event in ipairs(Achievement) do
            Event.idx = Idx
            if Event.Target ~= nil and Event.Progress ~= nil and Event.Target > 0 and Event.Target == Event.Progress then
                RevealCount = RevealCount + 1
            end
        end
        self.HideConditionText = string.format(LSTR(190077), RevealCount)
        self.ConditionList:UpdateByValues(Achievement)

        -- 加载右下怪物模型
        local FateEntityCfg = FateEntityCfgTable:FindCfgByKey(ID)
        if (FateEntityCfg ~= nil) then
            self.MonsterResID = FateEntityCfg.Monsters[1].ResID
        else
            self.MonsterResID = 0
            FLOG_ERROR("FateEntityCfgTable:FindCfgByKey 为空，ID是：" .. ID)
        end

        self.bShowBtnViewMap = true
    else
        local FateCfg = _G.FateMgr:GetFateCfg(ID)
        if (FateCfg  == nil) then
            _G.FLOG_ERROR("无法获取 FATE数据，ID是 : "..tostring(ID))
            self:SwitchInfoPanel(0)
            -- 没有数据的话，报错，显示空界面
        else
            local EventInfo = self.EventInfoTable[ID]
            local LevelStr = string.format(LSTR(10031), EventInfo.Level)
            self.FateName = string.format("%s %s", LevelStr, LSTR(190115))

            self.FateDescribe = LSTR(190125) .. LSTR(190115)
            self.bShowFateSpecial = true

            -- 构造创造条件文本
            local FateGeneratorCfg = FateGeneratorCfgTable:FindCfgByKey(ID)
            self.FateCondition = self:GetFateConditionText(FateGeneratorCfg)

            self.FateSpecial = LSTR(190124)..LSTR(190115)
            
            local Achievement = {
                {Progress = -1, Target = -1},
                {Progress = -1, Target = -1},
                {Progress = -1, Target = -1},
                {Progress = -1, Target = -1}
            }

            self.ConditionList:UpdateByValues(Achievement)
            self.HideConditionText = string.format(LSTR(190077), 0)

            self.FateModelParamCfg = FateModelParamCfgTable:FindCfgByKey(ID)

            -- 加载右下怪物模型
            local FateEntityCfg = FateEntityCfgTable:FindCfgByKey(ID)
            if (FateEntityCfg ~= nil) then
                self.MonsterResID = FateEntityCfg.Monsters[1].ResID
            else
                self.MonsterResID = 0
                FLOG_ERROR("FateEntityCfgTable:FindCfgByKey 为空，ID是：" .. ID)
            end

            -- 隐藏地图展开按钮
            self.bShowBtnViewMap = false
        end        
    end

    -- 处理隐藏条目显示
    if self.bIsShowMap then
        self:SwitchInfoPanel(2)
    else
        self:SwitchInfoPanel(0)
    end
end

function FateArchiveMainVM:GetFateConditionText(Cfg)
    if (Cfg == nil) then
        FLOG_ERROR("FateArchiveMainVM:GetFateConditionText， 传入的 Cfg 为空")
        return
    end
    local Content = ""
    local FateTextCfg = nil
    if Cfg.PreFate ~= 0 then
        FateTextCfg = FateTextCfgTable:FindCfgByKey(Cfg.PreFate)
        if (FateTextCfg == nil) then
            FLOG_ERROR("FateTextCfgTable:FindCfgByKey 为空 ID是" .. Cfg.PreFate)
        end
    end
    local WeatherName = ""
    if Cfg.CurrWeather ~= 0 then
        WeatherCfg = WeatherCfgTable:FindCfgByKey(Cfg.CurrWeather)
        if (WeatherCfg) then
            WeatherName = WeatherCfg.Name
        end
    end
    
    if Cfg.PreFate ~= 0 then
        local ExistFateInfo = _G.FateMgr:GetFateInfo(Cfg.PreFate)
        if (FateTextCfg ~= nil and ExistFateInfo ~= nil ) then
            if Cfg.CurrWeather ~= 0 then
                Content = string.format(LSTR(190099), FateTextCfg.NameCh, WeatherName)
            elseif Cfg.TimeInterval ~= "" then
                Content = string.format(LSTR(190100), FateTextCfg.NameCh, Cfg.TimeInterval)
            else
                Content = string.format(LSTR(190101), FateTextCfg.NameCh)
            end
        else
            if Cfg.CurrWeather ~= 0 then
                Content = string.format(LSTR(190099), LSTR(190115), WeatherName)
            elseif Cfg.TimeInterval ~= "" then
                Content = string.format(LSTR(190100), LSTR(190115), Cfg.TimeInterval)
            else
                Content = string.format(LSTR(190101), LSTR(190115))
            end
        end
    elseif Cfg.CurrWeather ~= 0 then
        if Cfg.TimeInterval ~= "" then
            Content = string.format(LSTR(190102), WeatherName, Cfg.TimeInterval)
        else
            Content = string.format(LSTR(190103), WeatherName)
        end
    elseif Cfg.TimeInterval ~= "" then
        Content = string.format(LSTR(190104), Cfg.TimeInterval)
    else
        Content = LSTR(190105)
    end
    Content = LSTR(190106) .. Content
    return Content
end

function FateArchiveMainVM:InitRewardState()
    local MapState = _G.FateMgr:GetMapState(self.MapID)
    local RewardCfg = FateAchievementRewardCfg:FindCfgByKey(self.MapID)
    local CurProgress = 0
    if (MapState ~= nil) then
        CurProgress = MapState.CurProgress
    end
    if RewardCfg == nil then
        self.ProgressText = "0/0"
        self.ProgressPercent = 0
        self.bHaveReward = false
    else
        -- 从后台数据获取当前的进度
        local TempList = {}
        if MapState ~= nil then
            TempList = MapState.AwardedRewards
        else
            TempList = {}
        end
        self.FinishedReward = {}
        for i = 1, #TempList do
            self.FinishedReward[TempList[i] + 1] = true
        end
        self.bHaveReward = false
        local RewardCfg = FateAchievementRewardCfg:FindCfgByKey(self.MapID)
        local TempList = {}
        for k, v in pairs(RewardCfg.Rewards) do
            if v.Target ~= 0 then
                table.insert(TempList, v)
                if CurProgress >= v.Target and self.FinishedReward[k] == nil then
                    self.bHaveReward = true
                end
            end
        end
        local index = nil
        -- 找到最后一项大于当前当前进度且未领取奖励的项
        for k, v in pairs(TempList) do
            if v.Target ~= 0 then
                if v.Target >= CurProgress and self.FinishedReward[k] == nil then
                    index = k
                    break
                end
            end
        end
        -- 如果遍历完还没有相中项，则默认选取最后一项
        if index == nil then
            index = #TempList
        end
        self.CurMapRewardFinishedCount = CurProgress
        self.CurMapRewardMaxCount = TempList[#TempList].Target
        self.ProgressText = string.format("%s/%s", CurProgress, TempList[#TempList].Target)
        local PreItem = TempList[index - 1]
        if index == 1 then
            self.ProgressPercent = CurProgress / TempList[index].Target
        else
            self.ProgressPercent = (CurProgress - PreItem.Target) / (TempList[index].Target - PreItem.Target)
        end
    end
end

-- self.FateID = Params.ID
-- self.StartTimeMS = Params.StartTime
-- self.Progress = Params.Progress
-- self.State = Params.State
-- 构造一个Mark数据给地图显示
function FateArchiveMainVM:GetCurrentFate()
    local Fate = {}
    Fate.ID = self.SelectID
    Fate.StartTime = 0
    Fate.Progress = 0
    Fate.State = ProtoCS.FateState.FateState_Invalid
    Fate.IsSpecial = true
    return Fate
end

-- 在打开的时候重置一些参数
function FateArchiveMainVM:ResetOnShow()
    self.bIsShowMap = false
    self.MonsterResID = 0
    self.SelectedFateIndex = 1
end

-- Index:0是正常说明，1是未参与过面板，2是地图面板
function FateArchiveMainVM:SwitchInfoPanel(index)
    self.SwitcherInfoPanel = index
end

function FateArchiveMainVM:SetMapScale(Scale)
    self.MapScale = Scale
end

function FateArchiveMainVM:GetMapTabList(view, bNeedRegionPercent)
    local ItemTabs = {}
    -- 修改为读新的配置
    local AllCfg = MapRegionIconCfg:GetAllValidRegion()
    for _, Value in ipairs(AllCfg) do
        if bNeedRegionPercent then
            if (Value.bShow == 1) then
                local Percent = self:GetRegionPercent(view, Value.ID)
                table.insert(
                    ItemTabs,
                    {
                        IconPath = Value.Icon,
                        Name = Value.Name,
                        IsLock = false,
                        ID = Value.ID,
                        Percent = Percent,
                        IconSelect = Value.NewIconSelected,
                        IconNormal = Value.NewIconNormal,
                        IconPath = Value.Icon,
                        bShowlock = false,
                    }
                )
            end
        else
            if (Value.bShow == 1) then
                table.insert(
                    ItemTabs,
                    {
                        IconPath = Value.Icon,
                        Name = Value.Name,
                        IsLock = false,
                        ID = Value.ID,
                        IconSelect = Value.NewIconSelected,
                        IconNormal = Value.NewIconNormal,
                        IconPath = Value.Icon,
                        bShowlock = false,
                    }
                )
            end
        end
        FLOG_INFO("FateArchiveMainVM:GetMapTabList, name : %s , icon : %s", Value.Name, Value.Icon)
    end
    return ItemTabs
end

function FateArchiveMainVM:GetRegionPercent(view, RegionID)
    local FinishCount = 0
    local TotalCount = 0
    local Percent = 0
    local AreaTable = view.Region2AreaTable[RegionID]
    local FateMapInfo = view.FateMapInfo
    local Area2MapTable = view.Area2MapTable
    if (AreaTable == nil) then
        return Percent
    end

    for k, v in pairs(AreaTable) do
        local TempList = Area2MapTable[v.ID]
        if (TempList ~= nil) then
            for Key, Value in pairs(TempList) do
                local FateEventList = FateMapInfo[Value.ID]
                if FateEventList ~= nil then
                    TotalCount = TotalCount + #FateEventList * 4
                    for j = 1, #FateEventList do
                        local FateEvent = FateEventList[j]
                        local FateInfo = _G.FateMgr:GetFateInfo(FateEvent.ID)
                        if FateInfo ~= nil then
                            for k = 1, #FateInfo.Achievement do
                                local Achievement = FateInfo.Achievement[k]
                                if (Achievement ~= nil and Achievement.Target ~= nil and Achievement.Progress ~= nil) then
                                    local bFinished =
                                        Achievement.Target > 0 and Achievement.Progress >= Achievement.Target
                                    if bFinished then
                                        FinishCount = FinishCount + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if TotalCount ~= 0 then
        local Temp = (FinishCount / TotalCount) * 100
        Percent = math.ceil(Temp)
        if Temp > 99.0 and Temp < 100.0 then
            Percent = 99
        end
    end

    return Percent
end

function FateArchiveMainVM:GetAreaList(view, index)
    local AreaList = {}
    if (view == nil or view.MapTabList == nil) then
        return AreaList
    end

    local MapTabInfo = view.MapTabList[index]
    if (MapTabInfo == nil) then
        return AreaList
    end

    local TempList = view.Region2AreaTable[MapTabInfo.ID]
    if (TempList == nil) then
        return AreaList
    end

    local count = 0
    for _, AreaInfo in pairs(TempList) do
        if self:CheckAreaHaveFate(view, AreaInfo) then
            table.insert(AreaList, {Type = count, Name = AreaInfo.Name, ID = AreaInfo.ID})
            count = count + 1
        end
    end

    return AreaList
end

function FateArchiveMainVM:GetMapList(view, index)
    local MapList = {}
    if (view == nil or view.AreaList == nil) then
        return MapList
    end

    local AreaInfo = view.AreaList[index]
    if (AreaInfo == nil) then
        return MapList
    end

    local TempList = view.Area2MapTable[AreaInfo.ID]
    if (TempList == nil) then
        return MapList
    end

    local count = 0
    for _, MapInfo in pairs(TempList) do
        if view.FateMapInfo[MapInfo.ID] ~= nil then
            table.insert(MapList, {Type = count, Name = MapInfo.MapName, ID = MapInfo.ID})
            count = count + 1
        end
    end
    return MapList
end

function FateArchiveMainVM:CheckAreaHaveFate(view, AreaInfo)
    local MapList = view.Area2MapTable[AreaInfo.ID]
    if MapList == nil then
        return false
    end
    for i = 1, #MapList do
        if view.FateMapInfo[MapList[i].ID] ~= nil then
            return true
        end
    end
    return false
end

function FateArchiveMainVM:GetMapTabIndex(view, MapID)
    for i = 1, #view.MapTabList do
        local AreaList = self:GetAreaList(view, i)
        local count = 0
        view.AreaList = AreaList
        for j, v in ipairs(AreaList) do
            local MapList = self:GetMapList(view, j)
            for k = 1, #MapList do
                if MapList[k].ID == MapID then
                    return i, j, k
                end
            end
        end
    end
    return 1, 1, 1
end

--- func 返回 SelectedTabIndex, SelectedAreaIndex, SelectedMapIndex, SelectedFateIndex
---@param view any
---@param FateID any
function FateArchiveMainVM:GetMapTabIndexByFate(view, FateID)
    for i = 1, #view.MapTabList do
        local AreaList = self:GetAreaList(view, i)
        local count = 0
        view.AreaList = AreaList
        for j, v in ipairs(AreaList) do
            local MapList = self:GetMapList(view, j)
            for k = 1, #MapList do
                local FateEventList = view.FateMapInfo[MapList[k].ID]
                if FateEventList ~= nil then
                    for l = 1, #FateEventList do
                        if FateEventList[l].ID == FateID then
                            return i, j, k, l
                        end
                    end
                end
            end
        end
    end
    return 1, 1, 1, 1
end

return FateArchiveMainVM
