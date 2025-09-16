--
-- Author: loiafeng
-- Date: 2024-04-26 09:47:47
-- Description:
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local LoadingVM = require("Game/Loading/LoadingVM")
local LoadingDefine = require("Game/Loading/LoadingDefine")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")

local LoadingCfg = require("TableCfg/LoadingCfg")
local LoadingPoolCfg = require("TableCfg/LoadingPoolCfg")
local LoadingContentCfg = require("TableCfg/LoadingContentCfg")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local SaveKey = require("Define/SaveKey")
local GameInstance = _G.UE.UFGameInstance.Get()
local UIViewID = _G.UIViewID

local USaveMgr = _G.UE.USaveMgr
local PWorldMgr ---@type PWorldMgr
local ClientVisionMgr ---@type ClientVisionMgr
local QuestMgr ---@type QuestMgr
local FishNotesMgr ---@type FishNotesMgr
local DiscoverNoteMgr ---@type DiscoverNoteMgr

---@class LoadingMgr : MgrBase
local LoadingMgr = LuaClass(MgrBase)

function LoadingMgr:OnInit() 
    self.CurrentViewID = 0
    self.CurrentWidget = nil  ---@type UIView
end

function LoadingMgr:OnBegin()
    PWorldMgr = _G.PWorldMgr
    ClientVisionMgr = _G.ClientVisionMgr
    QuestMgr = _G.QuestMgr
    FishNotesMgr = _G.FishNotesMgr
    DiscoverNoteMgr = _G.DiscoverNoteMgr

    math.randomseed(os.time())
end

function LoadingMgr:OnEnd() 
end

function LoadingMgr:OnShutdown()
end

function LoadingMgr:OnRegisterGameEvent()
    -- if not CommonUtil.IsWithEditor() then
    --     self:RegisterGameEvent(EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
    --     self:RegisterGameEvent(EventID.WorldPostLoad, self.OnGameEventWorldPostLoad)
    -- end
end

-- function LoadingMgr:OnGameEventWorldPreLoad()
--     if nil ~= self.CurrentWidget then
--         GameInstance:ShowLoadingWidget(self.CurrentWidget)
--     end
-- end

-- function LoadingMgr:OnGameEventWorldPostLoad()
--     GameInstance:HideLoadingWidget()
-- end

---ShowViewInternal
---@private
function LoadingMgr:ShowViewInternal(ViewID)
    self.CurrentViewID = ViewID
    self.CurrentWidget = _G.UIViewMgr:ShowView(ViewID)
end

---HideViewInternal
---@private
function LoadingMgr:HideViewInternal()
    if self.CurrentViewID and self.CurrentViewID > 0 then
        local ViewID = self.CurrentViewID
        self.CurrentWidget = nil
        self.CurrentViewID = 0
        -- loiafeng: Loading蓝图的OnHide中也会触发LoadingMgr:HideLoadingView()，
        --     这里需要保证 CurrentViewID=0 在UIViewMgr:HideView()之前执行
        _G.UIViewMgr:HideView(ViewID)
        return true
    end
    return false
end

---IsNewMap 是否为首次到达的地图。如果当前地图有大水晶，且水晶未激活，则视为首次到达
---@param MapResID number
---@return boolean
local function IsNewMap(MapResID)
    local CrystalCfgs =  CrystalPortalCfg:FindAllCfg(string.format(
        "MapID = %d AND Type = %d", MapResID, ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP)) or {}

    if #CrystalCfgs == 0 then
        return false
    end

    for _, Cfg in ipairs(CrystalCfgs) do
        if CrystalPortalMgr:IsExistActiveCrystal(Cfg.ID) then
            return false
        end
    end

    return true
end

---CheckContent 检查Loading内容是否允许显示
---@param Cfg table
---@return boolean
local function CheckContent(Cfg)
    if nil == Cfg then return false end

    if not ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.VersionName) then
        return false
    end

    local QuestID = Cfg.RequiredQuestID
    if QuestID > 0 and QuestMgr:GetQuestStatus(QuestID) ~= ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
        return false
    end

    if ProtoRes.LoadingType.LOADING_FISH == Cfg.LoadingType then  -- 鱼类
        local FishingholeID = Cfg.Params[1]  -- 渔场ID
        if FishingholeID and FishNotesMgr:CheckFishLocationbLock(FishingholeID) then
            return false
        end
        local FishID = Cfg.Params[2]  -- 鱼ID
        if not FishNotesMgr:CheckFishbUnLock(FishID) then
            return false
        end
    elseif ProtoRes.LoadingType.LOADING_LANDSCAPE == Cfg.LoadingType then  -- 风景
        local NoteItemID = Cfg.Params[1]  -- 探索笔记ID
        if NoteItemID and not DiscoverNoteMgr:IsNotePointPerfectActived(NoteItemID) then
            return false
        end
    end

    return true
end

---GetContentFromPool 从LoadingPool中抽选Loading内容
---@return table
local function GetContentFromPool(LoadingPoolID)
    if nil == LoadingPoolID then return nil end

    -- 抽选Loading内容
    local PoolCfg = LoadingPoolCfg:FindCfgByKey(LoadingPoolID)
    if nil == PoolCfg or nil == PoolCfg.ContentID then return nil end

    local Contents = table.clone(PoolCfg.ContentID, true)
    table.shuffle(Contents)

    local LastContentID = USaveMgr.GetInt(SaveKey.LoadingLastContentID, -1, false)
    local CachedCfg = nil

    for _, ContentID in ipairs(Contents) do
        local ContentCfg = LoadingContentCfg:FindCfgByKey(ContentID)
        if CheckContent(ContentCfg) then
            -- 尽可以避免连续显示相同内容
            if ContentID == LastContentID then
                CachedCfg = ContentCfg
            else
                return ContentCfg
            end
        end
    end

    if CachedCfg == nil then
        FLOG_INFO("LoadingMgr.GetContentFromPool: Failed to get content with PoolID: " .. LoadingPoolID)
    end

    return CachedCfg
end

---GetContent
---@return table
local function GetContent(LoadingID, bNewMap)
    if nil == LoadingID or LoadingID <= 0 then return nil end

    local Cfg = LoadingCfg:FindCfgByKey(LoadingID)
    if nil == Cfg then return nil end

    if #Cfg.PoolID ~= #Cfg.PoolWeight then
        FLOG_ERROR("GetContent: The number of PoolID is not equal to the number of PoolWeight. LoadingID: " .. LoadingID)
        return nil
    end

    local PoolCount = #Cfg.PoolID

    local PoolIDs = table.clone(Cfg.PoolID, true)
    local Weights = nil
    if bNewMap then
        Weights = {}
        for Index = 1, PoolCount do
            local MapExclusive = (LoadingPoolCfg:FindValue(Cfg.PoolID[Index], "MapExclusive") or 0) == 1
            Weights[Index] = Cfg.PoolWeight[Index] * (MapExclusive and LoadingDefine.MapExclusiveMultiplier or 1)
        end
    else
        Weights = table.clone(Cfg.PoolWeight, true)
    end

    while not table.empty(PoolIDs) do
        local WeightSum = 0
        for _, Weight in ipairs(Weights) do
            WeightSum = WeightSum + Weight
        end

        if WeightSum <= 0 then return nil end

        local RandomNum = math.random(1, WeightSum)

        local SelectedPoolIndex = 0
        for Index, Weight in ipairs(Weights) do
            RandomNum = RandomNum - Weight
            if RandomNum <= 0 then
                SelectedPoolIndex = Index
                break
            end
        end

        local Content = GetContentFromPool(PoolIDs[SelectedPoolIndex])
        if Content ~= nil then
            return Content
        end

        table.remove(PoolIDs, SelectedPoolIndex)
        table.remove(Weights, SelectedPoolIndex)
    end

    FLOG_WARNING("LoadingMgr.GetContent: Failed to get content with LoadingID: " .. LoadingID)
    return nil
end

---ShowContentInternal
---@private
---@param ContentCfg table
---@return boolean
function LoadingMgr:ShowContentInternal(ContentCfg)
    if nil == ContentCfg then
        return false
    end

    local bSuccess = LoadingVM:UpdateContent(ContentCfg)
    if not bSuccess then
        FLOG_ERROR("LoadingMgr:ShowContentInternal: Failed to show ContentID: " .. ContentCfg.ID)
        return false
    end

    FLOG_INFO("LoadingMgr:ShowContentInternal: Show ContentID: " .. ContentCfg.ID)

    if ProtoRes.LoadingUIType.LOADING_UI_MAIN_CITY ~= ContentCfg.UIType then
        LoadingVM:UpdateProf()
    end

    self:ShowViewInternal(LoadingDefine.LoadingUIMap[ContentCfg.UIType])

    USaveMgr.SetInt(SaveKey.LoadingLastContentID, ContentCfg.ID, false)
    return true
end

---ShowLoadingViewInternal
---@private
---@return boolean
function LoadingMgr:ShowLoadingViewInternal()
    local MapID = PWorldMgr:GetCurrMapResID()
    local MapCfg = PWorldMgr:GetMapTableCfg(MapID)

    if nil == MapCfg then
        return false
    end

    LoadingVM:UpdateName(MapCfg.DisplayName, MapCfg.RegionName)
    local ContentCfg = GetContent(MapCfg.LoadingID, IsNewMap(MapID))

    return self:ShowContentInternal(ContentCfg)
end




------------------------------------------------
--- Loading Interface Begin

---ShowLoadingView
---@param UseDefault boolean 显示默认的黑屏转菊花Loading
---@param ForceByUIMgr boolean （废弃）
function LoadingMgr:ShowLoadingView(UseDefault, ForceByUIMgr)
    if 0 ~= self.CurrentViewID then
        _G.FLOG_ERROR("LoadingMgr.ShowLoadingView(): Already loading!")
        return
    end

    local bSuccess = (not UseDefault) and self:ShowLoadingViewInternal()

    if not bSuccess then
        self:ShowViewInternal(UIViewID.LoadingDefault)
    end

    GameInstance:UpdateAsyncLoadingArgs(true)

    -- 切图时将环境、特效音量调低
    _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 0.2)
    _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Sfx, 0.2)
end

---HideLoadingView
function LoadingMgr:HideLoadingView()
    if self:HideViewInternal() then
        GameInstance:UpdateAsyncLoadingArgs(false)
        _G.EventMgr:SendEvent(_G.EventID.TutorialLoadingFinish)

        _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Ambient_Sound, 1)
        _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Sfx, 1)
        
        return true
    end

    FLOG_ERROR("LoadingMgr:HideLoadingView(): Not loading!")
    return false
end

---IsLoadingView
function LoadingMgr:IsLoadingView()
    return self.CurrentViewID and self.CurrentViewID > 0
end

--- Loading Interface End
------------------------------------------------



------------------------------------------------
--- Debug Interface Begin

---DebugShowLoadingPool
---@param LoadingPoolID number
---@param LoadingTime number 期望的加载时间
function LoadingMgr:DebugShowLoadingPool(LoadingPoolID, MapID, LoadingTime)
    local MapCfg = PWorldMgr:GetMapTableCfg(MapID)
    if nil ~= MapCfg then
        LoadingVM:UpdateName(MapCfg.DisplayName, MapCfg.RegionName)
    else
        LoadingVM:UpdateName("Loading测试", "Loading测试")
    end

    local ContentCfg = GetContentFromPool(LoadingPoolID)
    if self:ShowContentInternal(ContentCfg) then
        self:RegisterTimer(self.DebugOnTimerHideLoadingView, LoadingTime, 1, 1)
        self:RegisterTimer(self.DebugOnTimerSetFullProgress, LoadingTime - 0.5, 1, 1)
    end
end

---DebugShowLoadingView
---@param LoadingPoolID number
---@param LoadingTime number 期望的加载时间
function LoadingMgr:DebugShowLoadingView(ContentID, MapID, LoadingTime)
    local MapCfg = PWorldMgr:GetMapTableCfg(MapID)
    if nil ~= MapCfg then
        LoadingVM:UpdateName(MapCfg.DisplayName, MapCfg.RegionName)
    else
        LoadingVM:UpdateName("Loading测试", "Loading测试")
    end

    local ContentCfg = LoadingContentCfg:FindCfgByKey(ContentID)
    if self:ShowContentInternal(ContentCfg) then
        self:RegisterTimer(self.DebugOnTimerHideLoadingView, LoadingTime, 1, 1)
        self:RegisterTimer(self.DebugOnTimerSetFullProgress, LoadingTime - 0.5, 1, 1)
    end
end

---DebugShowMapLoading
---@param MapID number
---@param LoadingTime number 期望的加载时间
function LoadingMgr:DebugShowMapLoading(MapID, LoadingTime)
    local MapCfg = PWorldMgr:GetMapTableCfg(MapID)

    if nil == MapCfg then
        return false
    end

    LoadingVM:UpdateName(MapCfg.DisplayName, MapCfg.RegionName)
    local ContentCfg = GetContent(MapCfg.LoadingID, IsNewMap(MapID))

    if self:ShowContentInternal(ContentCfg) then
        self:RegisterTimer(self.DebugOnTimerHideLoadingView, LoadingTime, 1, 1)
        self:RegisterTimer(self.DebugOnTimerSetFullProgress, LoadingTime - 0.5, 1, 1)
    end
end

---DebugHideLoadingView
function LoadingMgr:DebugHideLoadingView()
    self:UnRegisterAllTimer()
    if 0 == self.CurrentViewID then
        return
    end
    self:HideViewInternal()
end

function LoadingMgr:DebugOnTimerHideLoadingView()
    self:DebugHideLoadingView()
end

function LoadingMgr:DebugOnTimerSetFullProgress()
    local ProBar = (self.CurrentWidget or {}).ProBar
    if nil ~= ProBar then
        ProBar:SetAnimProgress(ProBar:GetAnimProgress(), 1, 0.15)
    end
end

function LoadingMgr:DebugSimulateLoading(MapID, Count)
    USaveMgr.SetInt(SaveKey.LoadingLastContentID, 0, false)  -- 清除Loading缓存

    local MapCfg = PWorldMgr:GetMapTableCfg(MapID)

    if nil == MapCfg then
        return {}
    end

    local LoadingID = MapCfg.LoadingID
    local NewMap = IsNewMap(MapID)

    local ResultMap = {}
    for i = 1, Count do
        local ContentCfg = GetContent(LoadingID, NewMap)
        if ContentCfg ~= nil and ContentCfg.ID ~= nil then
            ResultMap[ContentCfg.ID] = ResultMap[ContentCfg.ID] and ResultMap[ContentCfg.ID] + 1 or 1
        end
    end

    local Result = {}
    for ID, Count in pairs(ResultMap) do
        table.insert(Result, {ID = ID, Count = Count})
    end
    table.sort(Result, function(a, b) return a.ID < b.ID end)

    return Result
end

--- Debug Interface End
------------------------------------------------

return LoadingMgr
