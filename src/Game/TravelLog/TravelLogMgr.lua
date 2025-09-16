--
-- Author: sammrli
-- Date: 2024-1-26 14:55
-- Description:旅行笔录管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")

local UIViewID = require("Define/UIViewID")
--local SequencePlayerBase = require("Game/Story/SequencePlayerBase")

local MajorUtil = require("Utils/MajorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local DataReportUtil = require("Utils/DataReportUtil")

local StoryDefine = require("Game/Story/StoryDefine")
local TravelLogCfg = require("TableCfg/TravelLogCfg")

--弱提醒,标签二级分类和收录没有层级关系
local RED_DOT_MAIN_GENRE_TAG = "Root/TravelLog/%d"    --页签红点
local RED_DOT_SUB_GENRE_TAG = "Root/TravelLog/%d"     --二级分类红点
local RED_DOT_CHILD_TAG = "Root/TravelLog/%d"         --内容红点

local UE = _G.UE
local LSTR = _G.LSTR
local TimerMgr = _G.TimerMgr
local StoryMgr = _G.StoryMgr
local UIViewMgr = _G.UIViewMgr

local TravelLogMgr = LuaClass(MgrBase)

-- ==================================================
-- 私有
-- ==================================================

function TravelLogMgr:OnInit()
    self.IsTempTest = false
    self.IsPlaying = false
end

function TravelLogMgr:OnBegin()
    self.TravelLogViewParam = nil
    ---@type table<number, SequencePlayerBase>
    --self.SequencePlayerList = {}

    self.CutSceneIDList = {}
    self.IsPlaying = false
end

function TravelLogMgr:OnEnd()
    self.TravelLogViewParam = nil
    self.CutSceneIDList = nil
    self.IsPlaying = false
    _G.WorldMsgMgr:SetPlayLoadingScreen(false)
end

function TravelLogMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldFinished, self.OnGameEventPWorldFinished)
end

function TravelLogMgr:OnGameEventPWorldFinished(PWorldResID)
    if not PWorldResID then
        return
    end
    local TravelLogCfgItem = self:FindCfgByWorldID(PWorldResID)
    if TravelLogCfgItem then
        self:AddChildMainRedDot(TravelLogCfgItem.PWorldID)
        self:AddSubGenreRedDot(TravelLogCfgItem.JournaltGenreID)
        self:AddMainGenreRedDot(math.floor(TravelLogCfgItem.JournaltGenreID / 10000))
        self:ReportCollectFlow(TravelLogCfgItem)
    end
end

---传入的其实是ChapterID，只是表格字段名是QuestID
function TravelLogMgr:FindCfgByQuestID(ChapterID)
    if not ChapterID then
        return nil
    end
    local AllCfg = TravelLogCfg:FindAllCfg()
    for _, Cfg in ipairs(AllCfg) do
        if Cfg.QuestID == ChapterID then
            return Cfg
        end
    end
    return nil
end

function TravelLogMgr:FindCfgByWorldID(PWorldID)
    if not PWorldID then
        return nil
    end
    local AllCfg = TravelLogCfg:FindAllCfg()
    for _, Cfg in ipairs(AllCfg) do
        if Cfg.PWorldID == PWorldID then
            return Cfg
        end
    end
    return nil
end

-- ==================================================
-- 外部接口
-- ==================================================

---是否旅行笔记播放
function TravelLogMgr:GetIsPlaying()
    return self.IsPlaying
end

---增加完成章节红点记录
---@param ChapterID number
function TravelLogMgr:AddFinishChapter(ChapterID)
    if not ChapterID then
        return
    end
    local TravelLogCfgItem = self:FindCfgByQuestID(ChapterID)
    if TravelLogCfgItem then
        self:AddChildMainRedDot(TravelLogCfgItem.QuestID)
        self:AddSubGenreRedDot(TravelLogCfgItem.JournaltGenreID)
        self:AddMainGenreRedDot(math.floor(TravelLogCfgItem.JournaltGenreID / 10000))
        self:ReportCollectFlow(TravelLogCfgItem)
    end
end

---播放新手动画
function TravelLogMgr:PlayNewbieCutScene(SequenceIDList, CurrentIndex, Callback)
    if not self.CutSceneIDList then
        return
    end
    if not SequenceIDList then
        return
    end
    table.clear(self.CutSceneIDList)
    for i=1, #SequenceIDList do
        table.insert(self.CutSceneIDList, SequenceIDList[i])
    end
    self.CurrentPlayIndex = CurrentIndex
    self.FinishCutSceneCallback = Callback

    _G.WorldMsgMgr:SetPlayLoadingScreen(true) --关闭地图过场

    local SequenceID = self.CutSceneIDList[self.CurrentPlayIndex]

    local function DelayPlay()
        local function FinishedCallback()
            _G.TravelLogMgr:PlayNextCutScene()
        end
        local VisionMgrInstance = UE.UVisionMgr.Get()
        if VisionMgrInstance then
            VisionMgrInstance:SetStopRefreshVisionEnable(true)
        end
        FLOG_INFO("[TravelLog] RestoreMap PlayCutSceneSequenceByID="..tostring(SequenceID))
        StoryMgr:PlayCutSceneSequenceByID(SequenceID, FinishedCallback, nil, nil, {bIsPlayNext = true})
    end
    self:RegisterTimer(DelayPlay, 0.02) --等PWorld这一帧的逻辑执行完,延迟一帧播放
end

function TravelLogMgr:RestoreMap()
    local PWorldMgrInstance = UE.UPWorldMgr:Get()
    if PWorldMgrInstance then
        PWorldMgrInstance:ResetLayersetList()
        local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
        if PWorldTableCfg then
            local CurrMapID = PWorldTableCfg.MapList[1]
            FLOG_INFO("[TravelLog] RestoreMap CurrMapID="..tostring(CurrMapID))
            local LayersetName = _G.PWorldMgr:GetMapLayersetName(CurrMapID)
            if not string.isnilorempty(LayersetName) then
                PWorldMgrInstance:AddLaysetName(LayersetName)
            end
            local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(CurrMapID)
            if MapTableCfg then
                local LevelID = MapTableCfg.LevelID or 0
                local MapResTableCfg = _G.PWorldMgr:GetMapResTableCfg(LevelID)
                if MapResTableCfg then
                    local MapPath = MapResTableCfg.PersistentLevelPath
                    FLOG_INFO("[TravelLog] RestoreMap MapPath="..tostring(MapPath))
                    local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
                    if CurrMapEditCfg and CurrMapEditCfg.MapID == CurrMapID then --播放ncut可能从切地图开始前也可能切地图结束后,这里根据关卡数据是否存在选择触发原因
                        _G.PWorldMgr:ChangeMapForCutScene(MapPath, true, UE.ELoadWorldReason.RestoreNormal, false, false)
                    else
                        _G.PWorldMgr:ChangeMapForCutScene(MapPath, true, UE.ELoadWorldReason.Normal, false, false)
                    end
                end
            end
        else
            FLOG_ERROR("[TravelLog] RestoreMap PWorldTableCfg is nil !")
        end
    end
end

function TravelLogMgr:PlayNextCutScene()
    _G.StoryMgr:ResetStatusAndCacheData()
    if not self.CutSceneIDList then
        return
    end
    self.CurrentPlayIndex = self.CurrentPlayIndex + 1
    if self.FinishCutSceneCallback then
        self.FinishCutSceneCallback(self.CurrentPlayIndex)
    end
    if self.CurrentPlayIndex > #self.CutSceneIDList then
        local VisionMgrInstance = UE.UVisionMgr.Get()
        if VisionMgrInstance then
            VisionMgrInstance:SetStopRefreshVisionEnable(false)
        end
        --恢复地图
        self:RestoreMap()
        --恢复地图过场loading
        _G.WorldMsgMgr:SetPlayLoadingScreen(false)
        --清除播放数据
        table.clear(self.CutSceneIDList)
        self.CurrentPlayIndex = 1
        self.FinishCutSceneCallback = nil
    else
        local SequenceID = self.CutSceneIDList[self.CurrentPlayIndex]
        local function DelayPlay()
            local function FinishedCallback()
                _G.TravelLogMgr:PlayNextCutScene()
            end
            local VisionMgrInstance = UE.UVisionMgr.Get()
            if VisionMgrInstance then
                VisionMgrInstance:SetStopRefreshVisionEnable(true)
            end
            _G.PWorldMgr:SetMapTravelStatusFinish() --连播断线重连MapTravel会置为loading,这里置为finish
            FLOG_INFO("[TravelLog] RestoreMap PlayCutSceneSequenceByID="..tostring(SequenceID))
            StoryMgr:PlayCutSceneSequenceByID(SequenceID, FinishedCallback, nil, nil, {bIsPlayNext = true})
        end
        _G.LoadingMgr:ShowLoadingView(true, true)
        self:RegisterTimer(DelayPlay, 0.02) --StoryMgr上一个动画的数据未清理,延迟一帧播放
    end
end

---播放动画列表
---@param SequencePathList table<string> @sequence路径列表
---@param TabIndex number @标签index
---@param ScrollOffset number @滑动偏移值
---@param SelectedLogID number @选择LogID
---@param CurrentIndex number @当前选择index
---@param SubGenreIndex number @当前二级分类
function TravelLogMgr:PlayFilmList(SequencePathList, TabIndex, ScrollOffset, SelectedLogID, CurrentIndex, SubGenreIndex)
    self.TravelLogViewParam = {}
    self.TravelLogViewParam.TabIndex = TabIndex
    self.TravelLogViewParam.ScrollOffset = ScrollOffset
    self.TravelLogViewParam.SelectedLogID = SelectedLogID
    self.TravelLogViewParam.SubGenreIndex = SubGenreIndex

    local Major = MajorUtil.GetMajor()
    if Major then
        local LastMajorPos = Major:FGetActorLocation()
        local LastMajorRot = Major:FGetActorRotation()
        _G.PWorldMgr:SetMajorLocationAndRotator(LastMajorPos, LastMajorRot.Y)
    end

    local FinishedCallback = function()
        if self.IsPlaying then
            self:RestoreMap()
            TimerMgr:AddTimer(self, self.OnDelayFinishCallback, 0.1)
            self.IsPlaying = false
        end
        _G.WorldMsgMgr:SetPlayLoadingScreen(false)
        --self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    end
    local StartPlayCallback = function(Index)
        self:ReportPlayFlow(SelectedLogID, Index)
    end
    _G.WorldMsgMgr:SetPlayLoadingScreen(true)
    UIViewMgr:HideView(UIViewID.TravelLogPanel)
    StoryMgr:PlayCutSceneSequenceByPathList(SequencePathList, FinishedCallback, CurrentIndex, StartPlayCallback)
    self.IsPlaying = true
end

---中断多段动画播放
function TravelLogMgr:ExitPlay()
    local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
    StoryMgr:PauseSequence()
	local function LeftBtnCallback()
        StoryMgr:ContinueSequence()
        _G.UIViewMgr:HideView(UIViewID.EmotionMainPanel)
	    _G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
        _G.InteractiveMgr:HideMainPanel()
        SequencePlayerVM.CanShowInteractive = false
		UIViewMgr:ShowView(UIViewID.DialogueMainPanel,{ViewType = StoryDefine.UIType.SequenceDialog})
	end
	local function RightBtnCallback()
		local SequencePlayer = StoryMgr.SequencePlayer
		if SequencePlayer then
			SequencePlayer:SetIsInterruptMultiPlay(true)
		end
		StoryMgr:StopSequence()
	end
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(530002), RightBtnCallback, LeftBtnCallback,
        LSTR(10003), LSTR(10002), {CloseClickCB = LeftBtnCallback}) --530002("是否退出这段过场动画？")
end

function TravelLogMgr:OnDelayFinishCallback()
    if _G.PWorldMgr:CurrIsInDungeon() then --如果被拉进了副本
        return
    end
    if self.TravelLogViewParam then
        UIViewMgr:ShowView(UIViewID.TravelLogPanel, {
            TabIndex = self.TravelLogViewParam.TabIndex,
            ScrollOffset = self.TravelLogViewParam.ScrollOffset,
            SelectedLogID = self.TravelLogViewParam.SelectedLogID,
            SubGenreIndex = self.TravelLogViewParam.SubGenreIndex,
        })
        self.TravelLogViewParam = nil
    end
end

function TravelLogMgr:OnGameEventEnterWorld(Params)
    if self.TravelLogViewParam then
        _G.UIViewMgr:ShowView(UIViewID.TravelLogPanel, {
            TabIndex = self.TravelLogViewParam.TabIndex,
            ScrollOffset = self.TravelLogViewParam.ScrollOffset,
            SelectedLogID = self.TravelLogViewParam.SelectedLogID,
            SubGenreIndex = self.TravelLogViewParam.SubGenreIndex,
        })
        self.TravelLogViewParam = nil
    end
    if nil ~= self.GameEventRegister then --反注册
		self.GameEventRegister:UnRegisterAll()
	end
end

---@param GeneIndex number
---@return string
function TravelLogMgr:GetMainGenreRedDotName(GeneIndex)
    return string.format(RED_DOT_MAIN_GENRE_TAG, GeneIndex)
end

---@param JournaltGenreID number
---@return string
function TravelLogMgr:GetSubGenreRedDotName(JournaltGenreID)
    local SubGenre = math.floor(JournaltGenreID / 100) --这里是除以100,到2级分类
    return string.format(RED_DOT_SUB_GENRE_TAG, SubGenre)
end

---@param ID number
---@return string
function TravelLogMgr:GetChildRedDotName(ID)
    return string.format(RED_DOT_CHILD_TAG, ID)
end

function TravelLogMgr:AddMainGenreRedDot(GeneIndex)
    local MainGenreRedDotName = self:GetMainGenreRedDotName(GeneIndex)
    _G.RedDotMgr:AddRedDotByName(MainGenreRedDotName, 1, true)
end

function TravelLogMgr:AddSubGenreRedDot(JournaltGenreID)
    local SubGenreRedDotName = self:GetSubGenreRedDotName(JournaltGenreID)
    _G.RedDotMgr:AddRedDotByName(SubGenreRedDotName, 1, true)
end

---@param ID number@可能是ChapterID可能是副本ID
function TravelLogMgr:AddChildMainRedDot(ID)
    if not ID then
        return
    end
    local ChildRedDotName = self:GetChildRedDotName(ID)
    _G.RedDotMgr:AddRedDotByName(ChildRedDotName, 1, true)
end

function TravelLogMgr:DeleteMainGenreRedDot(GeneIndex)
    local MainGenreRedDotName = self:GetMainGenreRedDotName(GeneIndex)
    _G.RedDotMgr:DelRedDotByName(MainGenreRedDotName)
end

function TravelLogMgr:DeleteSubGenreRedDot(JournaltGenreID)
    local SubGenreRedDotName = self:GetSubGenreRedDotName(JournaltGenreID)
    _G.RedDotMgr:DelRedDotByName(SubGenreRedDotName)
end

function TravelLogMgr:DeleteChildRedDot(ID)
    if not ID then
        return
    end
    local ChildRedDotName = self:GetChildRedDotName(ID)
    _G.RedDotMgr:DelRedDotByName(ChildRedDotName)
end

---收录笔记流水上报
---@param Cfg @TravelLogCfg
function TravelLogMgr:ReportCollectFlow(Cfg)
    local PathList = string.split(Cfg.CutscenID, ",")
    local Num = #PathList
    DataReportUtil.ReportData("TraveltranscriptFlow", true, false, true,
    "OpType", "1",
    "RecordGenre", tostring(Cfg.JournaltGenreID),
    "RecordID", tostring(Cfg.id),
    "RecordChapter", tostring(Num),
    "RecordChapterSum", tostring(Num))
end

---播放笔记流水上报
---@param RecordID number@笔记ID
---@param RecordChapter @第几个动画
function TravelLogMgr:ReportPlayFlow(RecordID, Index)
    local TravelLogCfgItem = TravelLogCfg:FindCfgByKey(RecordID)
    if TravelLogCfgItem then
        local PathList = string.split(TravelLogCfgItem.CutscenID, ",")
        local Num = #PathList
        DataReportUtil.ReportData("TraveltranscriptFlow", true, false, true,
        "OpType", "2",
        "RecordGenre", tostring(TravelLogCfgItem.JournaltGenreID),
        "RecordID", tostring(RecordID),
        "RecordChapter", tostring(Index),
        "RecordChapterSum", tostring(Num))
    end
end

return TravelLogMgr