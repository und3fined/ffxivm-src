--
-- Author: lydianwang
-- Date: 2022-05-30
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local BagMgr = require("Game/Bag/BagMgr")

local QuestFactory = require("Game/Quest/QuestFactory")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestRegister = require("Game/Quest/QuestRegister")
local QuestDefine = require("Game/Quest/QuestDefine")
local QuestLayerset = require("Game/Quest/QuestLayerset")
local QuestReport = require("Game/Quest/Report/QuestReport")
local OfferSequenceCollector = require("Game/Quest/OfferSequenceCollector")

-- DB
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local QuestCfg = require("TableCfg/QuestCfg")
local TargetCfg = require("TableCfg/QuestTargetCfg")
local LevelNewquestCfg = require("TableCfg/LevelNewquestCfg")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local PworldCfg = require("TableCfg/PworldCfg")

-- Proto
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProfCareerCfg = require("TableCfg/ProfCareerCfg")

local CS_CMD =          ProtoCS.CS_CMD
local QUEST_CMD =       ProtoCS.CS_QUEST_CMD
local QUEST_STATUS =    ProtoCS.CS_QUEST_STATUS
local TARGET_STATUS =   ProtoCS.CS_QUEST_NODE_STATUS
local TARGET_TYPE =     ProtoRes.QUEST_TARGET_TYPE
local CHAPTER_STATUS =  QuestDefine.CHAPTER_STATUS
local CONNECT_TYPE =    ProtoRes.target_connect_type
local BEHAVIOR_TYPE =   ProtoRes.QUEST_CLIENT_ACTION_TYPE

local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL

local LSTR = _G.LSTR
local EActorType = _G.UE.EActorType
local CommonUtil = require("Utils/CommonUtil")

-- 后台定义的错误码
local ErrorCodeFarDistance = 125002

---@class QuestMgr : MgrBase
local QuestMgr = LuaClass(MgrBase)

function QuestMgr:OnInit()
    self:InitQuestData()
    self:InitPrerequisiteEvent()
    self:InitPWorldPrerequisiteEvent()
    self.QuestLayerset = QuestLayerset.New()
end

function QuestMgr:InitQuestData()
    self.ChapterMap = {}
    self.QuestMap = {}

    self.EndChapterMap = {}
    self.EndQuestToChapterIDMap = {}
    self.EndChapterSubmitTimeMap = {}

    self.ActivatedCfgPakMap = {} -- 激活但未接取的任务

    self.bQuestDataInit = false
    self.bWaitingReconnectionUpdate = false

    self.QuestListRspCache = nil

    self.ChapterStatusChangeMap = {}
    self.TargetStatusChangeMap = {}

    self.ChapterPendingToRemove = {}
    self.QuestPendingToRemove = {}

    self.bFinalMainlineFinished = false
    self.bSubmiting = false

    self.bWaitingForGC = false

    self.FinalMainlineID = nil
    local FinalMainlineCfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_FINAL_MAINLINE)
    if FinalMainlineCfg then
        self.FinalMainlineID = FinalMainlineCfg.Value[1]
    end

    self.QuestReport = QuestReport.New()

    -- 断线重连用
    self.CacheMsgBodyList = {}
    self.ReqListTimer = nil

	-- 跳过任务剧情动画和单人本过场计数
    self.SequenceSkipCount = 0
	self.bInQuestSequence = false
end

---任务系统初始化所需的前置事件
function QuestMgr:InitPrerequisiteEvent()
    self.bPrereqEventPWorldEnter = false
end

---切地图初始化所需的前置事件
function QuestMgr:InitPWorldPrerequisiteEvent()
end

function QuestMgr:OnBegin()
    self.LoginServerTimeMS = 0 -- TODO: 有个任务目标要用，得想办法提出去
    self.QuestRegister = QuestRegister.New()
    self.OfferSequenceCollector = OfferSequenceCollector.New()
    QuestFactory.Init()
    QuestHelper.Init()

    -- 15ms左右
    self.PreloadChapterCfgs = QuestChapterCfg:FindAllCfg("QuestGenreID > 20000 AND QuestGenreID < 30000")
end

function QuestMgr:OnEnd()
    self:ClearQuests()
end

-- function QuestMgr:OnShutdown()
-- end

function QuestMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_LIST_CMD, self.OnNetMsgQuestList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_GIVEUP_CMD, self.OnNetMsgQuestGiveUp)

    -- 以下SubCmd回包类型均相同，故注册至同一函数
    local UpdateNotifySubCmdList = {
		QUEST_CMD.QUEST_ACCEPT_CMD,
		QUEST_CMD.QUEST_SUBMIT_CMD,
		QUEST_CMD.QUEST_TARGET_FINISH_CMD,
		QUEST_CMD.QUEST_UPDATE_NOTIFY_CMD,
		QUEST_CMD.QUEST_TARGET_REVERT,
    }
    for _, SubCmd in ipairs(UpdateNotifySubCmdList) do
        self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, SubCmd, self.OnNetMsgQuestUpdateNotify)
    end

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_GET_TRACK_CMD, self.OnNetMsgQuestGetTrack)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_CLEAR_CMD, self.OnNetMsgQuestClear)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_GET_DISPLAY_DATA, self.OnNetMsgUpdateDisplayData)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
end

function QuestMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnGameEventMajorLevelUpdate)
    -- self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnGameEventMajorProfSwitch)
    self:RegisterGameEvent(EventID.CounterInit, self.OnGameEventCounterInit)
    self:RegisterGameEvent(EventID.CounterUpdate, self.OnGameEventCounterUpdate)
    self:RegisterGameEvent(EventID.CounterClear, self.OnGameEventCounterClear)
	self:RegisterGameEvent(EventID.BagInit, self.OnGameEventBagInit)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnGameEventBagUpdate)
    self:RegisterGameEvent(EventID.OpsActivityUpdate, self.OnGameEventOpsActivityUpdate)
    self:RegisterGameEvent(EventID.EnterMapFinish, self.OnGameEventEnterMapFinish)
    self:RegisterGameEvent(EventID.PlayerSkipSequence, self.OnGameEventStopSequenceHalfway)
    self:RegisterGameEvent(EventID.QuestLimitTimeOver, self.OnGameEventQuestLimitTimeOver)
end

-- function QuestMgr:OnRegisterTimer()
-- end

function QuestMgr:OnQuestConditionUpdate(bKeepNpcQuest, bNeedActivateNewQuest)
    do
        -- 先处理当前地图的任务，刷新VM，发事件
        local _ <close> = CommonUtil.MakeProfileTag("OnQuestConditionUpdate_QuestsInRange")

        local QuestsInRange = {}
        self.QuestRegister:OperateCurrMapQuestList(function(ParamsList)
            for _, QuestParams in ipairs(ParamsList) do
                table.insert(QuestsInRange, QuestParams.QuestID)
				QuestParams.Icon = nil -- 作用和ClearAllQuestListIcon相同
            end
        end)

        self.QuestRegister:DeActivateQuests(bKeepNpcQuest, QuestsInRange)

        QuestMainVM:RefreshAllDataVM()
        QuestMainVM:CollectActivatedMainlineVMList()

        self:SendEventOnConditionUpdate()
    end
    _G.SlicingMgr.YieldCoroutine()

    do
        local _ <close> = CommonUtil.MakeProfileTag("OnQuestConditionUpdate_DeActivateQuests")
        self.QuestRegister:DeActivateQuests(bKeepNpcQuest)
    end
    _G.SlicingMgr.YieldCoroutine()

    if bNeedActivateNewQuest then
        self:TraverseNextActivateQuests()
        self:NewActivateQuests()
    end
    _G.SlicingMgr.YieldCoroutine()

    self.QuestRegister:ClearAllQuestListIcon()
    do
        local _ <close> = CommonUtil.MakeProfileTag("OnQuestConditionUpdate_RefreshAllDataVM")
        QuestMainVM:RefreshAllDataVM()
    end
    QuestMainVM:CollectActivatedMainlineVMList()
    self.QuestRegister:SortAllQuestList()

    if self.bWaitingForGC then
        _G.SlicingMgr.YieldCoroutine()
        self.bWaitingForGC = false
        local _ <close> = CommonUtil.MakeProfileTag("OnQuestConditionUpdate_collectgarbage")
        _G.FLOG_INFO("QuestMgr:OnQuestConditionUpdate gc")
        collectgarbage("collect")
        if QuestDefine.bShowDebugLog then
            _G.FLOG_SCREEN("QuestMgr:OnQuestConditionUpdate gc")
        end
    end
end

-- ==================================================
-- 游戏事件
-- ==================================================

function QuestMgr:SendEventOnConditionUpdate(QuestID)
    _G.EventMgr:PostEvent(EventID.UpdateQuest, {
        bOnConditionUpdate = true,
        QuestID = QuestID,
    })
end


---@param RspQuests list<Quest>|nil respond from quest.proto
function QuestMgr:SendEventOnDataUpdate(RspQuests)
    local QuestListForEvent = _G.QuestTrackMgr:ExtractQuestListForEvent()
    _G.EventMgr:PostEvent(EventID.UpdateQuest, {
        UpdatedRspQuests = RspQuests,
        UpdatedQuestList = QuestListForEvent[1],
        RemovedQuestList = QuestListForEvent[2],
    })
end

function QuestMgr:SendEventOnClear()
    _G.EventMgr:SendEvent(EventID.ClearQuest)
end

function QuestMgr:OnGameEventLoginRes(Param)
    local bReconnect = Param and Param.bReconnect

    self.LoginServerTimeMS = TimeUtil.GetServerTimeMS() -- 此行未确认是否要考虑断线重连

    local ReqList = function(bOnReconnect)
        self.bWaitingReconnectionUpdate = (bOnReconnect and self.bQuestDataInit)
        --[sammrli] 重连或未拉取过数据，都revert
        local bRevert = bOnReconnect or not self.bQuestDataInit
        self:SendReqQuestList(not bRevert)
    end

    if bReconnect then
        for _, MsgBody in ipairs(self.CacheMsgBodyList) do
            if self:CheckMsgBodyCanReSend(MsgBody) then
                self.SendQuestMsg(MsgBody)
            end
        end
        if (next(self.CacheMsgBodyList) ~= nil) then
            self.ReqListTimer = self:RegisterTimer(ReqList, 3, 0, 1, true)
        else
            local TargetID = self.QuestRegister:GetTargetNeedRevert()
            if TargetID ~= nil and TargetID > 0 and (not _G.UIViewMgr:IsViewVisible(_G.UIViewID.PWorldMainlinePanel)) then
                self:SendTargetRevert(TargetID)
            end
        end
        self.CacheMsgBodyList = {}
    end

    if self.ReqListTimer == nil then
        ReqList(bReconnect)
    end
end


function QuestMgr:CheckMsgBodyCanReSend(MsgBody)
    local TargetFinish = MsgBody.TargetFinish
    if TargetFinish then
        local QuestID = TargetFinish.QuestID
        local TargetID = TargetFinish.NodeID
        if QuestID and TargetID then
            local TargetCfgItem = QuestHelper.GetTargetCfgItem(QuestID, TargetID)
            if TargetCfgItem then
                if TargetCfgItem.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_TRIGGER then --触怪圈判断是否在圈内
                    local AreaID = tonumber(TargetCfgItem.Properties[1])
                    local MapID = tonumber(TargetCfgItem.Properties[2])
                    if _G.PWorldMgr:GetCurrMapResID() == MapID then
                        local IsIn = _G.MapAreaMgr:InMapArea(AreaID)
                        if not IsIn then
                            return false
                        end
                    end
                end
            end
        end
    end
    return true --默认返回true
end

---初次进入地图后初始化任务，此时主角已创建完毕
function QuestMgr:OnGameEventPWorldMapEnter(_)
    self.QuestRegister:OnPWorldEnter()

    if self.bPrereqEventPWorldEnter then
        self:SendEventOnConditionUpdate()
    else
        self.bPrereqEventPWorldEnter = true
        self:TryInitQuestData()
    end

    -- print("test bSeqWaitLoading = false")
    self.bSeqWaitLoading = false

    local Args = self.QuestRegister:GetSeqWaitLoadingArgs()
    if Args ~= nil then
        self.QuestRegister:UnRegisterSeqWaitLoading()
        QuestHelper.QuestPlaySequence(table.unpack(Args))
    end
end

function QuestMgr:OnGameEventPWorldMapExit(_)
    self.bSeqWaitLoading = true
    self.QuestRegister:UnRegisterTargetNeedRevert()
end

function QuestMgr:OnGameEventPWorldExit(_)
    self:InitPWorldPrerequisiteEvent()
end

function QuestMgr:OnGameEventMajorLevelUpdate(Params)
    if Params.OldLevel == nil then return end -- 排除因职业切换广播的事件。用参数判断不可靠，但等级事件还不完善(20240802)
    do
        local _ <close> = CommonUtil.MakeProfileTag("QuestMgr:OnGameEventMajorLevelUpdate")
        local co = coroutine.create(self.OnQuestConditionUpdate)
        _G.SlicingMgr:EnqueueCoroutine(co, self, false, true)
    end
    self:SendEventOnConditionUpdate()
end

-- function QuestMgr:OnGameEventMajorProfSwitch(_)
--     self:OnQuestConditionUpdate(false, true)
--     self:SendEventOnConditionUpdate()
-- end

---@return boolean
function QuestMgr:CheckPrerequisiteEvent()
    return self.bPrereqEventPWorldEnter
    and QuestMainVM.bModuleBegin
end

function QuestMgr:TryInitQuestData()
    if (not self.bQuestDataInit)
    and self:CheckPrerequisiteEvent()
    and (self.QuestListRspCache ~= nil) then
        self:AssembleQuestDataFromInitRsp(self.QuestListRspCache)
        self.QuestListRspCache = nil
    end
end

function QuestMgr:OnGameEventBagInit()
	local AllItemList = BagMgr.ItemList
	for _, Item in ipairs(AllItemList) do
        self:UpdateUseItemEntrance(Item, ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD)
	end
end

function QuestMgr:OnGameEventBagUpdate(UpdateItem)
	for _, v in ipairs(UpdateItem) do
        self:UpdateUseItemEntrance(v.PstItem, v.Type)
	end
end

function QuestMgr:OnGameEventOpsActivityUpdate()
    self:CheckNeedRemoveQuest()
end

function QuestMgr:OnGameEventEnterMapFinish()
    local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
    local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    if not PWorldDynDataMgr then
        return
    end
    local ListObstacleID = self:GetQuestObstacle(CurrMapID)
    if ListObstacleID then
        for ObstacleID, _ in pairs(ListObstacleID) do
            local DynArea = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_OBSTACLE, ObstacleID)
            if DynArea then
                DynArea:UpdateState(1)
            end
        end
    end
    local ListAreaSceneID = self:GetQuestAreaScene(CurrMapID)
    if ListAreaSceneID then
        for AreaSceneID, _ in pairs(ListAreaSceneID) do
            local DynArea = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA, AreaSceneID)
            if DynArea then
                DynArea:UpdateState(1)
            end
        end
    end
end

function QuestMgr:OnGameEventStopSequenceHalfway(bClickButtonSkip)
    -- 连续手动跳过任务剧情动画3次时，提示“设置中可以开启自动跳过任务剧情动画功能”
    if self.bInQuestSequence then
        if bClickButtonSkip then
            self:OnSkipQuestSequence()
        else
            self:ClearCountSkipQuestSequence()
        end
        self:SetInQuestSequence(false)
    end
end

function QuestMgr:OnGameEventQuestLimitTimeOver()
    local TimeLimitMap = self.QuestRegister.TimeLimitMap
    if TimeLimitMap then
        local TempMap = {}
        for QuestID, TimeLimit in pairs(TimeLimitMap) do
            TempMap[QuestID] = TimeLimit
        end
        _G.QuestCondMgr:OnQuestMsgUpdate()
        for QuestID, _ in pairs(TempMap) do
            local QuestCfgItem = QuestCfg:FindCfgByKey(QuestID)
            if QuestCfgItem then
                local ChapterCfgItem = QuestChapterCfg:FindCfgByKey(QuestCfgItem.ChapterID)
                if ChapterCfgItem then
                    if ChapterCfgItem.HideWhenCannotAccept == 1 then
                        self:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
                    end
                end
            end
        end
        do
            local _ <close> = CommonUtil.MakeProfileTag("QuestMgr:OnGameEventQuestLimitTimeOver")
            local co = coroutine.create(self.OnQuestConditionUpdate)
            _G.SlicingMgr:EnqueueCoroutine(co, self, false, true)
        end
        self:SendEventOnConditionUpdate()
    end
end

---可使用的任务物品需要在主界面显示交互项
---@param Item table common.Item
---@param UpdateType number ProtoCS.ITEM_UPDATE_TYPE
function QuestMgr:UpdateUseItemEntrance(Item, UpdateType)
    local ResID = Item.ResID
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    if (Cfg == nil) or (Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY) then return end

    local Func = FuncCfg:FindCfgByKey(Cfg.UseFunc)
    if (Func == nil) or (Func.ID == 0) then return end

    if UpdateType == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD
    or UpdateType == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_RENEW then
        self.QuestRegister:RegisterUseItemEntrance(ResID, (1 == Cfg.UsableOnlyInTarget))

    elseif UpdateType == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_DELETE and Item.Num == 0 then
        if BagMgr:GetItemByResID(ResID) == nil then -- 可能有另一堆相同物品
            self.QuestRegister:UnRegisterUseItemEntrance(ResID, (1 == Cfg.UsableOnlyInTarget))
        end
    end
end

-- ==================================================
-- 游戏事件（计数器相关）
-- ==================================================

function QuestMgr:OnGameEventCounterInit(Params)
	for CounterID, CounterValue in pairs(Params.UpdatedCounters) do
        self.QuestRegister:UpdateQuestCounterValue(CounterID, CounterValue)
	end
end

function QuestMgr:OnGameEventCounterUpdate(Params)
    _G.QuestCondMgr:OnGameEventCounter() -- 先标记counter条件有更新
    self:ProcessCounterUpdate(Params.UpdatedCounters)
end

function QuestMgr:OnGameEventCounterClear(Params)
    _G.QuestCondMgr:OnGameEventCounter() -- 先标记counter条件有更新
    self:ProcessCounterUpdate(Params.UpdatedCounters, true)
end

---@param UpdatedCounters luatable
---@param bClear boolean
function QuestMgr:ProcessCounterUpdate(UpdatedCounters, bClear)
    local bQuestModified = false

	for CounterID, CounterValue in pairs(UpdatedCounters) do
        self.QuestRegister:UpdateQuestCounterValue(CounterID, CounterValue)
        local QuestIDList = self.QuestRegister.QuestOnCounter[CounterID] or {}

        for _, QuestID in ipairs(QuestIDList) do
            local QuestCfgItem = QuestCfg:FindCfgByKey(QuestID)
            local ChapterCfgItem = QuestCfgItem and QuestChapterCfg:FindCfgByKey(QuestCfgItem.ChapterID) or nil
            --[sammrli] 副本计数
            local IsPWorldCounter = false
            if QuestCfgItem and QuestCfgItem.SceneFinish and QuestCfgItem.SceneFinish ~= 0 then
                IsPWorldCounter = true
            end
            if (bClear or CounterValue > 0)
            and self.QuestMap[QuestID] == nil
            and (CounterID == self.GetQuestCounter(QuestID, "AcceptCounterID")
            or CounterID == self.GetQuestCounter(QuestID, "SubmitCounterID")
            or IsPWorldCounter)
            and (QuestCfgItem and ChapterCfgItem) then
                self:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
                bQuestModified = true
            end
        end
	end

    if bQuestModified then
        self:SendEventOnConditionUpdate()
    end
end

---@param QuestID int32
---@param CounterStr string
---@return int32
function QuestMgr.GetQuestCounter(QuestID, CounterStr)
    local Cfg = QuestHelper.GetQuestCfgItem(QuestID)
    return Cfg and Cfg[CounterStr] or 0
end

-- ==================================================
-- 网络：接收消息
-- ==================================================

---收到任务客户端数据消息
---@param QuestUpdateRsp table
function QuestMgr:OnNetMsgQuestClientData(QuestUpdateRsp)
    local QuestClientData = QuestUpdateRsp.Display
    if QuestClientData == nil then return end

    local NPC = QuestClientData.NPCShow
    local MapBGM = QuestClientData.MapBGM
    -- local CameraTrigger = QuestClientData.CameraTriggerOn
    local EobjShow = QuestClientData.EobjShow
    local Obstacle = QuestClientData.Obstacle
    local AreaScene = QuestClientData.AreaScene
    local EobjState = QuestClientData.EobjState

    local QR = self.QuestRegister

    for NpcID, _ in pairs(QR.ClientNpc) do
        if NPC[NpcID] ~= true then
            QR:UnRegisterClientNpc(NpcID)
        end
    end
    for NpcID, bShow in pairs(NPC) do
        if bShow then
            QR:RegisterClientNpc(NpcID)
        end
    end

    for MapID, _ in pairs(QR.QuestMapBGM) do
        local RspBGM = MapBGM[MapID]
        if (RspBGM == nil) or (string.len(RspBGM) == 0) then
            QR:UnRegisterMapBGM(MapID)
        end
    end
    for MapID, BGM in pairs(MapBGM) do
        if (BGM ~= "") and (QR.QuestMapBGM[MapID] == nil) then
            QR:RegisterMapBGM(MapID, BGM)
        end
    end

    for EObjID, _ in pairs(QR.QuestEObj) do
        if EobjShow[EObjID] ~= true then
            QR:UnRegisterEObj(EObjID)
        end
    end
    for EobjID, bShow in pairs(EobjShow) do
        if bShow then
            QR:RegisterEObj(EobjID)
        end
    end

    for MapID, Obstacles in pairs(QR.QuestObstacle) do
        for ObstacleID, _ in pairs(Obstacles) do
            local AssembledID = (MapID << 32) + ObstacleID
            if Obstacle[AssembledID] ~= true then
                QR:UnRegisterObstacle(MapID, ObstacleID)
            end
        end
    end
    for MapIDObstacleID, bShow in pairs(Obstacle) do
        local MapID = MapIDObstacleID >> 32
        local ObstacleID = MapIDObstacleID - (MapID << 32)
        if bShow and ((QR.QuestMapBGM[MapID] == nil) or (QR.QuestMapBGM[MapID][ObstacleID] == nil)) then
            QR:RegisterObstacle(MapID, ObstacleID)
        end
    end

    for MapID, Areas in pairs(QR.QuestAreaScene) do
        for AreaID, _ in pairs(Areas) do
            local AssembledID = (MapID << 32) + AreaID
            if AreaScene[AssembledID] ~= true then
                QR:UnRegisterAreaScene(MapID, AreaID)
            end
        end
    end
    for MapIDAreaID, bShow in pairs(AreaScene) do
        local MapID = MapIDAreaID >> 32
        local AreaID = MapIDAreaID - (MapID << 32)
        if bShow and ((QR.QuestAreaScene[MapID] == nil) or (QR.QuestAreaScene[MapID][AreaID] == nil)) then
            QR:RegisterAreaScene(MapID, AreaID)
        end
    end

    for EObjID, _ in pairs(QR.EObjState) do
        QR:UnRegisterEObjState(EObjID)
    end
    for EObjID, State in pairs(EobjState) do
        QR:RegisterEObjState(EObjID, State)
    end
    -- 性能不友好，需优化
    if next(QR.EObjState) ~= nil then
        local AllActors = _G.UE.UActorManager:Get():GetAllActors()
        local ActorCnt = AllActors:Length()
        for i = 1, ActorCnt, 1 do
            local Actor = AllActors:Get(i)
            if Actor and Actor:GetActorType() == EActorType.EObj then
                local AttrCom = Actor:GetAttributeComponent()
                local ResID = AttrCom and AttrCom.ResID or 0
                local State = QR.EObjState[ResID] or -1
                if State >= 0 and Actor.SetSharedGroupTimelineState then
                    Actor:SetSharedGroupTimelineState(State)
                end
            end
        end
    end
end

---收到任务初始化消息
---@param MsgBody table
function QuestMgr:OnNetMsgQuestList(MsgBody)
    local QuestUpdateRsp = MsgBody.QuestUpdate
    if QuestUpdateRsp == nil then return end
    self:ClearReconnectInfo()
    
    self.bWaitingForGC = true -- 全量更新任务后gc

    self:OnNetMsgQuestClientData(QuestUpdateRsp)

    if self.bWaitingReconnectionUpdate then
        self.bWaitingReconnectionUpdate = false
        self:ReconnectionUpdateQuestData(QuestUpdateRsp)
    elseif self:CheckPrerequisiteEvent() then
        self:AssembleQuestDataFromInitRsp(QuestUpdateRsp)
    else
        self.QuestListRspCache = QuestUpdateRsp
        self:PreProcessQuestList()
    end
end

---处理任务初始化消息
---@param QuestListRsp table
function QuestMgr:AssembleQuestDataFromInitRsp(QuestListRsp)
    if QuestListRsp == nil then return end
    self:ClearReconnectInfo()
    self.QuestRegister:PreQuestUpdate()

    do
        local _ <close> = CommonUtil.MakeProfileTag("AssembleQuestDataFromInitRsp_InitEndQuests")
        self:InitEndQuests(QuestListRsp.EndQuests, QuestListRsp.EndChapters)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("AssembleQuestDataFromInitRsp_InitQuests")
        self:InitQuests(QuestListRsp.Quests)
    end
    -- counters

    _G.QuestCondMgr:OnQuestMsgUpdate()
    do
        local _ <close> = CommonUtil.MakeProfileTag("AssembleQuestDataFromInitRsp_UpdateActivateQuests")
        self:UpdateActivateQuests(QuestListRsp.EndQuests, QuestListRsp.EndChapters)
    end
    -- self:InitActivateQuests()
    do
        local _ <close> = CommonUtil.MakeProfileTag("AssembleQuestDataFromInitRsp_InitMainVM")
        QuestMainVM:InitMainVM()
    end
    self:RemoveAllPendingData()

    --QuestMainVM:CollectActivatedMainlineVMList()

    self.bQuestDataInit = true

	self:SendGetTrackQuest()

    if self.PreloadChapterCfgs ~= nil then
        local _ <close> = CommonUtil.MakeProfileTag("AssembleQuestDataFromInitRsp_PreloadChapter")

        for _, CfgItem in ipairs(self.PreloadChapterCfgs) do
            if (self.EndChapterMap[CfgItem.id] == nil) then
                local QuestCfgItem = QuestHelper.GetQuestCfgItem(CfgItem.StartQuest)
                self:TryActivateQuest(QuestCfgItem, CfgItem)
            end
        end
        self.PreloadChapterCfgs = nil
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("AssembleQuestDataFromInitRsp_OnQuestConditionUpdate")
        local co = coroutine.create(self.OnQuestConditionUpdate)
        _G.SlicingMgr:EnqueueCoroutine(co, self, true, true)
    end

    local co2 = coroutine.create(self.SendEventOnDataUpdate)
    _G.SlicingMgr:EnqueueCoroutine(co2, self, QuestListRsp.Quests)

    _G.EventMgr:SendEvent(EventID.InitQuest)

    self:CheckNeedRemoveQuest()
end

---处理断线重连
---@param QuestListRsp table
function QuestMgr:ReconnectionUpdateQuestData(QuestListRsp)
    if QuestListRsp == nil then return end
    self:ClearReconnectInfo()
    self.QuestRegister:PreQuestUpdate()

    do
        local _ <close> = CommonUtil.MakeProfileTag("ReconnectionUpdateQuestData_InitEndQuests")
        self:UpdateEndQuests(QuestListRsp.EndQuests, QuestListRsp.EndChapters)
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("ReconnectionUpdateQuestData_FixEndQuests")
        -- add by sammrli: 解决完成任务没回包进行了重连的情况,完成的任务数据没被清理
        self:FixEndQuests()
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("ReconnectionUpdateQuestData_InitQuests")
        self:UpdateQuests(QuestListRsp.Quests)
    end

    _G.QuestCondMgr:OnQuestMsgUpdate()

    do
        local _ <close> = CommonUtil.MakeProfileTag("ReconnectionUpdateQuestData_UpdateActivateQuests")
        self:UpdateActivateQuests(QuestListRsp.EndQuests, QuestListRsp.EndChapters)
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("ReconnectionUpdateQuestData_InitMainVM")
        QuestMainVM:UpdateDataVM()
    end
    self:RemoveAllPendingData()

    do
        local _ <close> = CommonUtil.MakeProfileTag("ReconnectionUpdateQuestData_OnQuestConditionUpdate")
        local co = coroutine.create(self.OnQuestConditionUpdate)
        _G.SlicingMgr:EnqueueCoroutine(co, self, true, true)
    end

    local co2 = coroutine.create(self.SendEventOnDataUpdate)
    _G.SlicingMgr:EnqueueCoroutine(co2, self, QuestListRsp.Quests)
end

---清理需要清理的任务数据
function QuestMgr:RemoveAllPendingData(bGiveUp)
    self:ClearChapterStatusChange()
    self:ClearTargetStatusChange()
    self:RemovePendingChaptersAndQuests(bGiveUp)
end

---收到放弃任务消息
---@param MsgBody table
function QuestMgr:OnNetMsgQuestGiveUp(MsgBody)
    local QuestUpdateRsp = MsgBody.QuestUpdate
    if QuestUpdateRsp == nil then return end
    self:ClearReconnectInfo()
    self.QuestRegister:PreQuestUpdate()

    self:OnNetMsgQuestClientData(QuestUpdateRsp)

    local GivenUpChapter = {}

    for _, RspQuest in ipairs(QuestUpdateRsp.Quests) do

        local QuestID = RspQuest.QuestID
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
        local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0

        local Quest = self.QuestMap[QuestID]
        if Quest then
            Quest:UpdateStatus(QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED)
        end

        local Chapter = self.ChapterMap[ChapterID]
        if Chapter and (GivenUpChapter[ChapterID] == nil) then
            GivenUpChapter[ChapterID] = true
            Chapter:UpdateStatus(QuestDefine.CHAPTER_STATUS.NOT_STARTED)
        end

        local EndChapter = self.EndChapterMap[ChapterID]
        if EndChapter and (GivenUpChapter[ChapterID] == nil) then
            GivenUpChapter[ChapterID] = true
            EndChapter:UpdateStatus(QuestDefine.CHAPTER_STATUS.NOT_STARTED)
        end
    end

    QuestMainVM:UpdateDataVM()
    self:RemoveAllPendingData(true)

    _G.QuestCondMgr:OnQuestMsgUpdate()
    
    for ChapterID, _ in pairs(GivenUpChapter) do
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
        if ChapterCfgItem then
            local QuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterCfgItem.StartQuest)
            self:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
        end
    end

    self:OnQuestConditionUpdate(true)

    self:SendEventOnDataUpdate(QuestUpdateRsp.Quests)
end

---收到任务更新消息
---@param MsgBody table
function QuestMgr:OnNetMsgQuestUpdateNotify(MsgBody)
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode and ErrorCode > 0 then
        -- 异常处理
        if _G.InteractiveMgr.bLockTimer then
            -- 正在交互中,打断
            _G.NpcDialogMgr:EndInteraction()
        end
        return
    end
    local QuestUpdateRsp = MsgBody.QuestUpdate
    if QuestUpdateRsp == nil then return end
    self:ClearReconnectInfo()
    self.QuestRegister:PreQuestUpdate()

    if MsgBody.Cmd == QUEST_CMD.QUEST_TARGET_REVERT then
        self.QuestRegister:UnRegisterTargetNeedRevert()
    end

    -- 只在任务回退时收到数据
    self:OnNetMsgQuestClientData(QuestUpdateRsp)

    if QuestUpdateRsp.Counters ~= nil then
        for CounterID, QuestCounterValue in pairs(QuestUpdateRsp.Counters) do
            self.QuestRegister:UpdateQuestCounterValue(CounterID, QuestCounterValue.RemainCount)
        end
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("OnNetMsgQuestUpdateNotify_UpdateEndQuests")
        -- 先更新已完成的任务，保证后续任务可激活
        self:UpdateEndQuests(QuestUpdateRsp.EndQuests, QuestUpdateRsp.EndChapters)
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("OnNetMsgQuestUpdateNotify_UpdateQuests")
        self:UpdateQuests(QuestUpdateRsp.Quests)
    end

    _G.QuestCondMgr:OnQuestMsgUpdate()

    do
        local _ <close> = CommonUtil.MakeProfileTag("OnNetMsgQuestUpdateNotify_UpdateActivateQuests")
        self:UpdateActivateQuests(QuestUpdateRsp.EndQuests, QuestUpdateRsp.EndChapters)
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("OnNetMsgQuestUpdateNotify_UpdateDataVM")
        QuestMainVM:UpdateDataVM()
    end
    self:RemoveAllPendingData()

    do
        local _ <close> = CommonUtil.MakeProfileTag("OnNetMsgQuestUpdateNotify_OnQuestConditionUpdate")
        self:OnQuestConditionUpdate(true)
    end

    self:SendEventOnDataUpdate(QuestUpdateRsp.Quests)

    for _, RspQuest in ipairs(QuestUpdateRsp.Quests) do
        local Cfg=ProfCareerCfg:FindCfgByEndQuestID(RspQuest.QuestID)
        if RspQuest.Status==QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT then
            if Cfg and Cfg.RewardType==ProtoRes.ProfCareerRewardType.UnlockProf then
                self.isUnlockProf = true
                _G.UIViewMgr:HideAllUI()
                _G.InteractiveMgr:ShowOrHideMainPanel(false)
                --  确保异常情况下不会出问题
                self.DelayTimer = _G.TimerMgr:AddTimer(self, function()
                    self.isUnlockProf = false
                    _G.InteractiveMgr:ShowOrHideMainPanel(true)
                    self.DelayTimer = nil
                end, 6, 0, 1)
            end
            elseif RspQuest.Status==QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                if Cfg and Cfg.RewardType==ProtoRes.ProfCareerRewardType.UnlockProf then
                    if self.DelayTimer then
                        _G.TimerMgr:CancelTimer(self.DelayTimer)
                        self.DelayTimer = nil
                    end
                    self.isUnlockProf = false
                    _G.InteractiveMgr:ShowOrHideMainPanel(true)
                end
        end
    end
end

---收到任务追踪消息
---@param MsgBody table
function QuestMgr:OnNetMsgQuestGetTrack(MsgBody)
    local ChapterID = MsgBody.GetTrack.QuestID
    if self.EndChapterMap[ChapterID] then
        ChapterID = 0
		self:SendTrackQuest(ChapterID)
    end
    QuestMainVM:SetTrackChapter(ChapterID, true)
    _G.EventMgr:SendEvent(EventID.GetQuestTrack)
end

---收到GM任务清空消息
---@param MsgBody table
function QuestMgr:OnNetMsgQuestClear(_)
    self:ClearQuests()
    _G.QuestTrackMgr:Reset()
    _G.QuestCondMgr:ClearQuestCond()
    self:SendEventOnClear()
    self:SendReqQuestList()
end

---收到表现数据更新消息（没数据不用更新）
function QuestMgr:OnNetMsgUpdateDisplayData(MsgBody)
    local QuestClientData = MsgBody.Display
    if QuestClientData == nil then return end

    local QR = self.QuestRegister

    -- 只处理区域，其他类型暂时未有更新需求，影响最小
    for MapIDAreaID, bShow in pairs(QuestClientData.AreaScene) do
        local MapID = MapIDAreaID >> 32
        local AreaID = MapIDAreaID - (MapID << 32)
        if bShow then
            QR:RegisterAreaScene(MapID, AreaID)
        else
            QR:UnRegisterAreaScene(MapID, AreaID)
        end
    end
end

function QuestMgr:OnNetMsgError(MsgBody)
	if nil == MsgBody then
		return
	end

	if MsgBody.ErrCode == ErrorCodeFarDistance then
        _G.EventMgr:SendEvent(EventID.QuestErrorFarDistance)
    end
end

-- -- ==================================================
-- -- 网络：发送请求
-- -- ==================================================

---向服务器发送任务相关请求
---@param MsgBody table
function QuestMgr.SendQuestMsg(MsgBody)
    local MsgID = CS_CMD.CS_CMD_QUEST
    local SubMsgID = MsgBody.Cmd
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---发送查询任务列表请求
function QuestMgr:SendReqQuestList(bNoRevert)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_LIST_CMD,
        List = {
            NoRevert = (bNoRevert == true)
        },
    }
    self.SendQuestMsg(MsgBody)
end

---发送接取任务请求
---@param QuestID int32
function QuestMgr:SendAcceptQuest(QuestID, ResID)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_ACCEPT_CMD,
        Accept = {
            QuestID = QuestID,
            InteractNPC = QuestHelper.MakeInteractActor(ResID),
        }
    }
    self.SendQuestMsg(MsgBody)
    self.QuestReport:ReportAccept(QuestID)
    for _, Cache in ipairs(self.CacheMsgBodyList) do
        local Accept = Cache.Accept
        if Accept then
            if Accept.QuestID == QuestID then
                if not CommonUtil.IsShipping() then
                    FLOG_INFO("[QuestMgr] sendacceptquest cache has same "..tostring(QuestID))
                end
                return
            end
        end
    end
    table.insert(self.CacheMsgBodyList, MsgBody)
end

function QuestMgr:SendAcceptTribeQuest(TribeID, QuestID)
    local MsgID = CS_CMD.CS_CMD_TRIBE
    local SubMsgID = ProtoCS.Role.Tribe.TribeCmd.TribeCmdQuestAccept
    local MsgBody = {
        Cmd = SubMsgID,
        QuestAccept = {
            Tribe = TribeID,
            QuestID = QuestID,
        }
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---发送接取任务请求，检查对话/对白分支数据
---@param QuestID int32
function QuestMgr:SendAcceptQuestWithBranchCheck(QuestID, ResID)
    local BranchUniqueID = self.QuestRegister.BranchUniqueID
    if BranchUniqueID ~= 0 then
        -- Quest==0返回，Quest~=0上报
        if QuestHelper.IsBranchChoiceQuestInvalid(BranchUniqueID)then
            QuestHelper.PrintQuestInfo("Choose #%d in quest #%d, do not send AcceptQuest",
                self.QuestRegister.DialogChoiceIndex, QuestID)
            self:SetDialogBranchInfo(0, 0)
            return
        end
        self:SetDialogBranchInfo(0, 0)
    end
    self:SendAcceptQuest(QuestID, ResID)
end

---发送完成任务目标请求
---@param QuestID int32
---@param TargetID int32
function QuestMgr:SendFinishTarget(QuestID, TargetID, ResID, CollectItem, ActorType, BranchUniqueID, ChoiceIndex)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_TARGET_FINISH_CMD,
        TargetFinish = {
            QuestID = QuestID,
            NodeID = TargetID,
            InteractNPC = QuestHelper.MakeInteractActor(ResID, ActorType),
            CollectItem = CollectItem,
            DialogID = BranchUniqueID,
            Branch = ChoiceIndex,
        }
    }
    self.SendQuestMsg(MsgBody)
    for _, Cache in ipairs(self.CacheMsgBodyList) do
        local TargetFinish = Cache.TargetFinish
        if TargetFinish then
            if TargetFinish.QuestID == QuestID and TargetFinish.NodeID == TargetID then
                if not CommonUtil.IsShipping() then
                    FLOG_INFO(string.format("[QuestMgr] sendfinishtarget cache has same %s %s", tostring(QuestID), tostring(TargetID)))
                end
                return
            end
        end
    end
    table.insert(self.CacheMsgBodyList, MsgBody)
end

---发送完成任务目标请求，检查对话/对白分支数据
---@param QuestID int32
function QuestMgr:SendFinishTargetWithBranchCheck(QuestID, TargetID, ResID, CollectItem, ActorType)
    local BranchUniqueID = self.QuestRegister.BranchUniqueID
    local ChoiceIndex = 0 -- 不涉及对白分支就不上报选项
    if BranchUniqueID ~= 0 then
        ChoiceIndex = self.QuestRegister.DialogChoiceIndex
        local TargetCfgItem = QuestHelper.GetTargetCfgItem(QuestID, TargetID)
        local bNormalTarget = (TargetCfgItem ~= nil) and (TargetCfgItem.ConnectType == CONNECT_TYPE.NONE)
        -- 普通目标，Quest==0返回，Quest~=0上报
        -- 组合目标，直接上报（Quest==0需后台回退）
        if bNormalTarget
        and QuestHelper.IsBranchChoiceQuestInvalid(BranchUniqueID)then
            QuestHelper.PrintQuestInfo("Choose #%d in quest #%d target #%d, do not send FinishTarget",
                ChoiceIndex, QuestID, TargetID)
            self:SetDialogBranchInfo(0, 0)
            return
        end
        self:SetDialogBranchInfo(0, 0)
    end
    self:SendFinishTarget(QuestID, TargetID, ResID, CollectItem, ActorType, BranchUniqueID, ChoiceIndex)
end

---发送提交任务请求
---@param QuestID int32
function QuestMgr:SendSubmitQuest(QuestID, ResID)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_SUBMIT_CMD,
        Submit = {
            QuestID = QuestID,
            InteractNPC = QuestHelper.MakeInteractActor(ResID),
            Branch = 0, -- 废弃
        }
    }
    self.SendQuestMsg(MsgBody)
    for _, Cache in ipairs(self.CacheMsgBodyList) do
        local Submit = Cache.Submit
        if Submit then
            if Submit.QuestID == QuestID then
                if not CommonUtil.IsShipping() then
                    FLOG_INFO(string.format("[QuestMgr] sendsubmitquest cache has same %s", tostring(QuestID)))
                end
                return
            end
        end
    end
    table.insert(self.CacheMsgBodyList, MsgBody)
end

---发送放弃任务请求
---@param ChapterIDList table<int32>
---@param IsActivity boolean@是否活动任务
function QuestMgr:SendGiveUpQuest(ChapterIDList, IsActivity)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_GIVEUP_CMD,
        Giveup = {
            ChapterIDs = ChapterIDList,
            IsActivityEnd = IsActivity,
        }
    }
    self.SendQuestMsg(MsgBody)
    table.insert(self.CacheMsgBodyList, MsgBody)
end

---发送追踪任务请求
---@param QuestID int32
function QuestMgr:SendTrackQuest(QuestID)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_TRACK_CMD,
        Track = {
            QuestID = QuestID,
        }
    }
    self.SendQuestMsg(MsgBody)
end

---发送获取追踪任务请求
function QuestMgr:SendGetTrackQuest()
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_GET_TRACK_CMD,
    }
    self.SendQuestMsg(MsgBody)
end

---发送回退目标请求，只有少数特殊情况会用到
---@param TargetID int32
function QuestMgr:SendTargetRevert(TargetID)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_TARGET_REVERT,
        TargetRevert = {
            TargetID = TargetID
        }
    }
    self.SendQuestMsg(MsgBody)
    table.insert(self.CacheMsgBodyList, MsgBody)
end

---发送容错节点请求
---@param QuestID int32 @容错节点ID
function QuestMgr:SendFaultTolerant(QuestID)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_FAULT_TOLERANT,
        FaultTolerant = {
            NodeID = QuestID
        }
    }
    self.SendQuestMsg(MsgBody)
end

---发送进入任务区域请求
function QuestMgr:SendAreaSceneEnter(MapID, AreaID)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_AREA_SCENE,
        AreaScene = {
            MapID = MapID,
            AreaID = AreaID,
        }
    }
    self.SendQuestMsg(MsgBody)
end

---发送触发服务器行为节点请求
---@param SvrBehaviorID int32 服务器节点ID
function QuestMgr:SendTriggerSvrBehavior(SvrBehaviorID)
    local MsgBody = {
        Cmd = QUEST_CMD.QUEST_TRIGGER_ACTION,
        TriggerAction = {
            NodeID = SvrBehaviorID
        }
    }
    self.SendQuestMsg(MsgBody)
end

-- ==================================================
-- 任务消息处理逻辑
-- ==================================================

---依赖于任务数据的预处理逻辑
function QuestMgr:PreProcessQuestList()
    if self.QuestListRspCache == nil then return end

    for _, RspQuest in ipairs(self.QuestListRspCache.Quests) do
        local QuestID = RspQuest.QuestID
        for TargetID, RspTarget in pairs(RspQuest.TargetNodes) do
            local Cfg = TargetCfg:FindCfgByKey(TargetID)
            if Cfg and (Cfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_SEQUENCE)
            and RspTarget.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS then
                local PlainTarget = QuestFactory.CreateTarget(QuestID, TargetID, RspTarget, nil, true)
                if PlainTarget and PlainTarget.bMapAutoPlay then
                    self.QuestRegister:RegisterMapAutoPlaySequence(
                        PlainTarget.MapID, PlainTarget.SequenceID, QuestID, TargetID)
                end
            end
        end
    end
end

function QuestMgr:InitEndQuests(RspEndQuests, RspEndChapters)
    local CacheChapterCfgMap = {} -- 缓存ChapterCfg以节省查表次数

    for _, RspEndChapter in ipairs(RspEndChapters) do
        local ChapterID = RspEndChapter.ChapterID
        local ChapterCfgItem = CacheChapterCfgMap[ChapterID] or QuestHelper.GetChapterCfgItem(ChapterID)

        if ChapterCfgItem ~= nil then
            for _, QuestID in ipairs(ChapterCfgItem.ChapterQuests) do
                self.EndQuestToChapterIDMap[QuestID] = ChapterID
            end

            if self.EndChapterMap[ChapterID] == nil then
                local Chapter = QuestFactory.CreateChapter(ChapterID, ChapterCfgItem, true)
                Chapter:InitEndChapterStatus(ChapterCfgItem.EndQuest, RspEndChapter.Status, RspEndChapter.SubmitTimeMS)
            end

            if self.FinalMainlineID == ChapterCfgItem.EndQuest then
                self.bFinalMainlineFinished = true
            end
        end
    end

    for _, RspEndQuest in ipairs(RspEndQuests) do
        local EndQuestID = RspEndQuest.QuestID

        local QuestCfgItem = QuestCfg:FindCfgByKey(EndQuestID)
        local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
        if ChapterID ~= 0 then
            self.EndQuestToChapterIDMap[EndQuestID] = ChapterID
        end

        if ChapterID ~= 0 and self.EndChapterMap[ChapterID] == nil then
            local ChapterCfgItem = CacheChapterCfgMap[ChapterID] or QuestHelper.GetChapterCfgItem(ChapterID)

            if QuestHelper.CheckChapterLastQuest(EndQuestID, ChapterCfgItem) then
                local Chapter = QuestFactory.CreateChapter(ChapterID, ChapterCfgItem, true)
                Chapter:InitEndChapterStatus(EndQuestID, RspEndQuest.Status, RspEndQuest.SubmitTimeMS)

            elseif ChapterCfgItem ~= nil and CacheChapterCfgMap[ChapterID] == nil then
                CacheChapterCfgMap[ChapterID] = ChapterCfgItem
            end
        end
    end
end

function QuestMgr:InitQuests(RspQuests)
    -- 把已完成的任务放在前面处理
    table.sort(RspQuests, function(RspQuest1, RspQuest2)
        return RspQuest1.Status > RspQuest2.Status
    end)

    for _, RspQuest in ipairs(RspQuests) do
        local QuestID = RspQuest.QuestID
        local Quest = QuestFactory.CreateQuest(QuestID, RspQuest, nil, true)

        if Quest then
            for _, Behavior in pairs(Quest.AcceptClientBehavior) do
                if Behavior.BehaviorType == BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HINT_TALK
                or Behavior.BehaviorType == BEHAVIOR_TYPE.QUEST_CLIENT_ACTION_HINT_TALK_BEFORE then
                    Behavior:StartBehavior()
                end
            end

            for TargetID, RspTarget in pairs(RspQuest.TargetNodes) do
                local Target = Quest.Targets[TargetID]
                if Target then
                    Target:UpdateTargetInfo(RspTarget.Status, RspTarget.Count)
                end
            end

            if self.ChapterMap[Quest.ChapterID] == nil then
                local Chapter = QuestFactory.CreateChapter(Quest.ChapterID, nil)
                Chapter:InitChapterStatus(Quest)
                if (RspQuest.ProfAccept or 0) > 0 then
                    self.QuestRegister:RegisterFixedProf(Quest.ChapterID, RspQuest.ProfAccept)
                end
                -- TODO: 不应该拿第一个碰到的Quest更新Chapter，应该整体考虑
            end
        end

        -- TODO: 待提交有对白分支的任务，要不要放对白分支？
    end
end

function QuestMgr:UpdateActivateQuests(RspEndQuests, RspEndChapters)
    for _, RspEndChapter in ipairs(RspEndChapters) do
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(RspEndChapter.ChapterID)
        local EndQuestCfgItem = nil
        if ChapterCfgItem ~= nil then
            EndQuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterCfgItem.EndQuest)
        end

        if EndQuestCfgItem ~= nil then
            local NextQuestIDs = EndQuestCfgItem.NextChapterTaskID or {}
            for _, NextQuestID in ipairs(NextQuestIDs) do -- 这里只看EndQuest，假设策划不会在中间配置后置任务
                local NextQuestCfgItem = QuestHelper.GetQuestCfgItem(NextQuestID)
                local ChapterID = NextQuestCfgItem and NextQuestCfgItem.ChapterID or 0
                local NextChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)

                self:TryActivateQuest(NextQuestCfgItem, NextChapterCfgItem)
            end
        end
    end

    for _, RspEndQuest in ipairs(RspEndQuests) do
        for _, NextQuestID in ipairs(RspEndQuest.NextQuestID) do
            local QuestCfgItem = QuestHelper.GetQuestCfgItem(NextQuestID)
            local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
            local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)

            self:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
        end
    end
end

function QuestMgr:TraverseNextActivateQuests()
    for QuestID, _ in pairs(self.EndQuestToChapterIDMap) do
        _G.SlicingMgr.YieldCoroutine()

        local EndQuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)

        if EndQuestCfgItem ~= nil then
            local NextQuestIDs = EndQuestCfgItem.NextChapterTaskID or {}
            for _, NextQuestID in ipairs(NextQuestIDs) do -- 这里只看EndQuest，假设策划不会在中间配置后置任务
                local NextQuestCfgItem = QuestHelper.GetQuestCfgItem(NextQuestID)
                local ChapterID = NextQuestCfgItem and NextQuestCfgItem.ChapterID or 0
                local NextChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)

                self:TryActivateQuest(NextQuestCfgItem, NextChapterCfgItem)
            end
        end
    end
end

---激活无前置任务的任务
function QuestMgr:NewActivateQuests()
    local MapID = _G.PWorldMgr:GetCurrMapResID()
    local Level = MajorUtil.GetTrueMajorLevel() or 0

    -- 1. 查询、尝试激活当前地图所有满足等级的任务，每查询一个任务就更新一次ChapterVM，最后发送任务更新事件
    -- 2. 同样操作一遍所有非当前地图

    local function DoActivate(CfgList)
        _G.SlicingMgr.YieldCoroutine()

        for i = #CfgList, 1, -1 do
            local Cfg = CfgList[i]
            if Cfg.Level > Level then break end

            for _, QuestID in ipairs(Cfg.NewQuests) do
                local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
                local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
                local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)

                self:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
                _G.SlicingMgr.YieldCoroutine()
            end
        end
    end

    local CurrMapConditions = string.format("MapID == %d AND Level <= %d", MapID, Level)
	local CurrMapCfgList = LevelNewquestCfg:FindAllCfg(CurrMapConditions)

    DoActivate(CurrMapCfgList)
    self:SendEventOnDataUpdate() -- 刷新一次别的系统的数据

    local OtherMapConditions = string.format("MapID != %d AND Level <= %d", MapID, Level)
	local OtherMapCfgList = LevelNewquestCfg:FindAllCfg(OtherMapConditions)

    DoActivate(OtherMapCfgList)
end

function QuestMgr:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
    if ChapterCfgItem == nil then return end
    -- local ChapterID = ChapterCfgItem.id

    -- if self.ChapterMap[ChapterID] ~= nil then return end

    -- -- TODO[lydianwang]: 后续考虑循环任务的判断
    -- if self.EndChapterMap[ChapterID] ~= nil then return end

    if QuestCfgItem then
        local QuestID = QuestCfgItem.id
        if _G.ClientVisionMgr:CheckVersionByGlobalVersion(ChapterCfgItem.VersionName)
            and (self.ActivatedCfgPakMap[QuestID] == nil) then
            local _ <close> = CommonUtil.MakeProfileTag("QuestMgr_TryActivateQuest")

            if (QuestCfgItem.id == ChapterCfgItem.StartQuest) and (ChapterCfgItem.HasOfferSequence == 1)
            and QuestHelper.CheckCanActivate(QuestID, QuestCfgItem, ChapterCfgItem, true) then
                self.OfferSequenceCollector:CreateOfferSequence(ChapterCfgItem.id, QuestCfgItem)
            end
            -- check会缓存结果，重复check不影响性能
            if QuestHelper.CheckCanActivate(QuestID, QuestCfgItem, ChapterCfgItem) then
                self:SetCfgPak(QuestID, QuestCfgItem, ChapterCfgItem)
                QuestHelper.ActivateQuest(QuestCfgItem, ChapterCfgItem)
            else
                local PWorldRestriction = QuestCfgItem.SceneFinish or {}
                if PWorldRestriction and next(PWorldRestriction) then
                    for _, PWorldID in ipairs(PWorldRestriction) do
                        local SucceedCounterID = PworldCfg:FindValue(PWorldID, "SucceedCounterID")
                        if SucceedCounterID and SucceedCounterID ~= 0 then
                            self.QuestRegister:RegisterQuestOnCounter(SucceedCounterID, QuestID)
                        end
                    end
                end
            end
        end
    end
end

---负责“已完成”任务数据更新
---@param RspEndQuests list<EndQuest>
---@param RspEndChapters list<EndChapter>
function QuestMgr:UpdateEndQuests(RspEndQuests, RspEndChapters)
    for _, RspEndChapter in ipairs(RspEndChapters) do
        local ChapterID = RspEndChapter.ChapterID
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(RspEndChapter.ChapterID)
        if ChapterCfgItem ~= nil then
            for _, QuestID in ipairs(ChapterCfgItem.ChapterQuests) do
                self.EndQuestToChapterIDMap[QuestID] = ChapterID
            end

            if self.FinalMainlineID == ChapterCfgItem.EndQuest then
                self.bFinalMainlineFinished = true
            end

            if self.EndChapterMap[ChapterID] == nil and self.ChapterMap[ChapterID] == nil then --如果完成列表里和进行列表都没有数据
                local Chapter = QuestFactory.CreateChapter(ChapterID, ChapterCfgItem, true)
                Chapter:InitEndChapterStatus(ChapterCfgItem.EndQuest, RspEndChapter.Status, RspEndChapter.SubmitTimeMS)
            end
        end
        self.EndChapterSubmitTimeMap[ChapterID] = RspEndChapter.SubmitTimeMS
    end

    for _, RspEndQuest in ipairs(RspEndQuests) do

        local EndQuestID = RspEndQuest.QuestID
        local SubmitTime = RspEndQuest.SubmitTimeMS
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(EndQuestID)

        local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
        if ChapterID ~= 0 then
            self.EndQuestToChapterIDMap[EndQuestID] = ChapterID
            self.EndChapterSubmitTimeMap[ChapterID] = SubmitTime
        end
    end
end

---@param RspQuests list<Quest>
function QuestMgr:UpdateQuests(RspQuests)
    -- 把已完成的任务放在前面处理
    table.sort(RspQuests, function(RspQuest1, RspQuest2)
        return RspQuest1.Status > RspQuest2.Status
    end)

    for _, RspQuest in ipairs(RspQuests) do

        local InQuestID = RspQuest.QuestID
        local InStatus = RspQuest.Status

        local Quest = self.QuestMap[InQuestID]
        if Quest == nil then
            Quest = QuestFactory.CreateQuest(InQuestID, RspQuest)
            if not Quest then return end
        end

        local Chapter = self.ChapterMap[Quest.ChapterID] or self.EndChapterMap[Quest.ChapterID]
        if Chapter == nil then
            Chapter = QuestFactory.CreateChapter(Quest.ChapterID)
        end

        local RspTargetList = {}
        for _, RspTarget in pairs(RspQuest.TargetNodes) do
            table.insert(RspTargetList, RspTarget)
        end
        -- 把已完成的目标放在前面处理
        table.sort(RspTargetList, function(Node1, Node2)
            if Node1.Status ~= Node2.Status then
                return Node1.Status > Node2.Status

            else
                return Node1.NodeID < Node2.NodeID
            end
        end)

        -- 调整：先update quest 再 update targets，因为quest可能是ImmediateFinish类型,保证finish behavior在start behavior之后
        do
            local _ <close> = CommonUtil.MakeProfileTag("UpdateQuests_UpdateStatus")
            Quest:UpdateStatus(InStatus)
        end

        local IsTargetChanged = false

        for _, RspTarget in ipairs(RspTargetList) do
            local Target = Quest.Targets[RspTarget.NodeID]
            -- 后台会下发全部Target数据，“检查目标更新”的工作在这里处理
            if Target and ((Target.Status ~= RspTarget.Status) or (Target.Count ~= RspTarget.Count)) then
                local _ <close> = CommonUtil.MakeProfileTag("UpdateQuests_UpdateTargetInfo")
                Target:UpdateTargetInfo(RspTarget.Status, RspTarget.Count)
                IsTargetChanged = true
            end
        end

        FLOG_INFO("QuestMgr:UpdateQuests InQuestID=%d, IsTargetChanged=%s", Quest.QuestID, tostring(IsTargetChanged))

        Quest:UpdateTargetStatus(IsTargetChanged)

        if Chapter then
            Chapter:UpdateStatusByQuest(Quest)
            if (RspQuest.ProfAccept or 0) > 0 then
                self.QuestRegister:RegisterFixedProf(Quest.ChapterID, RspQuest.ProfAccept)
            end
        end
    end

    --Fix:用了直升道具，会只收到chapter数据没有quest数据,这里校验
    if not next(RspQuests) then --性能考虑这里多判断一下直升的特性(没有update数据)
        for QuestID, Quest in pairs(self.QuestMap) do
            if self.EndQuestToChapterIDMap[QuestID] then
                local ChapterID = self.EndQuestToChapterIDMap[QuestID]
                if ChapterID then
                    FLOG_INFO("[QuestMgr] inprogress quest in endMap, finish it. questid="..tostring(QuestID))
                    local Chapter = self.ChapterMap[Quest.ChapterID]
                    if Chapter and Chapter.Cfg then
                        Chapter:UpdateStatus(CHAPTER_STATUS.FINISHED, Chapter.Cfg.EndQuest)
                    end

                    QuestMainVM:FinishChapter(ChapterID)

                    Quest:Remove() --直接清除注册在npc和地图的任务
                    self:AddQuestPendingToRemove(QuestID, ChapterID) --加入移除队列
                end
            end
        end
    end
end

function QuestMgr:FixEndQuests()
    for QuestID, Quest in pairs(self.QuestMap) do
        if self.EndQuestToChapterIDMap[QuestID] then
            if Quest.Targets then
                for _, Target in pairs(Quest.Targets) do
                    if Target then
                        Target:UpdateTargetInfo(TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
                    end
                end
            end
            Quest:UpdateStatus(QUEST_STATUS.CS_QUEST_STATUS_FINISHED)
            Quest:UpdateTargetStatus(true)

            local Chapter = self.ChapterMap[Quest.ChapterID] --还没塞入self.EndChapterMap
            if Chapter then
                Chapter:UpdateStatusByQuest(Quest)
            end
        end
    end
end

function QuestMgr:ClearQuests()
    QuestMainVM:ResetVM()
    for _, Quest in pairs(self.QuestMap) do
        for _, Target in pairs(Quest.Targets) do
            Target:ClearTarget()
        end
        for _, StateRestriction in pairs(Quest.StateRestrictions) do
            StateRestriction:ClearRestriction()
        end
        for _, FaultTolerant in pairs(Quest.FaultTolerants) do
            FaultTolerant:ClearFaultTolerant()
        end
    end
    self.QuestRegister:ResetData()
    self:InitQuestData()
end

function QuestMgr:SetCfgPak(QuestID, QuestCfgItem, ChapterCfgItem)
    self.ActivatedCfgPakMap[QuestID] = { QuestCfgItem, ChapterCfgItem }
end

function QuestMgr:AddChapterStatusChange(ChapterID, StChangeParams)
    if self.ChapterStatusChangeMap[ChapterID] == nil then
        self.ChapterStatusChangeMap[ChapterID] = {
            OldStatus = StChangeParams.OldStatus,
            NewStatus = 0,
            IsTargetChanged = true
        }
    end
    
    local StChange = self.ChapterStatusChangeMap[ChapterID]
    StChange.IsTargetChanged = StChangeParams.IsTargetChanged

    if StChangeParams.NewStatus > StChange.NewStatus then
        StChange.NewStatus = StChangeParams.NewStatus        
    end
end

function QuestMgr:GetChapterStatusChangeMap()
    return self.ChapterStatusChangeMap
end

function QuestMgr:ClearChapterStatusChange()
    self.ChapterStatusChangeMap = {}
end

function QuestMgr:AddTargetStatusChange(QuestID, TargetID, StChangeParams)
    if self.TargetStatusChangeMap[QuestID] == nil then
        self.TargetStatusChangeMap[QuestID] = {}
    end
    local TargetStChange = self.TargetStatusChangeMap[QuestID]

    if TargetStChange[TargetID] == nil then
        TargetStChange[TargetID] = {
            OldStatus = StChangeParams.OldStatus,
            NewStatus = 0,
        }
    end
    local StChange = TargetStChange[TargetID]

    if StChangeParams.NewStatus > StChange.NewStatus then
        StChange.NewStatus = StChangeParams.NewStatus
    end
end

function QuestMgr:GetTargetStatusChangeMap(QuestID)
    if self.TargetStatusChangeMap[QuestID] then
        return self.TargetStatusChangeMap[QuestID]
    end
    return nil
end

function QuestMgr:ClearTargetStatusChange()
    self.TargetStatusChangeMap = {}
end

function QuestMgr:AddChapterPendingToRemove(ChapterID)
    table.insert(self.ChapterPendingToRemove, ChapterID)
end

function QuestMgr:AddQuestPendingToRemove(QuestID, ChapterID)
    self.QuestPendingToRemove[QuestID] = ChapterID
end

function QuestMgr:RemovePendingChaptersAndQuests(bGiveUp)
    local ReActivateList = {}

    for _, ChapterID in ipairs(self.ChapterPendingToRemove) do
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)

        self.ChapterMap[ChapterID] = nil

        if ChapterCfgItem ~= nil then
            if bGiveUp then
                for _, EndQuestID in ipairs(ChapterCfgItem.ChapterQuests) do
                    self.EndQuestToChapterIDMap[EndQuestID] = nil
                end
            end

            local QuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterCfgItem.StartQuest)
            if QuestCfgItem ~= nil then
                table.insert(ReActivateList, {
                    QuestCfgItem = QuestCfgItem, ChapterCfgItem = ChapterCfgItem,
                })
            end
        end
    end
    self.ChapterPendingToRemove = {}

    local QuestCondMgr = _G.QuestCondMgr
    for QuestID, _ in pairs(self.QuestPendingToRemove) do
        self.QuestMap[QuestID] = nil
        QuestCondMgr:RemoveQuestCond(QuestID)
        self.QuestRegister:UnRegisterActivityQuest(QuestID)
    end
    self.QuestPendingToRemove = {}

    for _, CfgParams in ipairs(ReActivateList) do
        self:TryActivateQuest(CfgParams.QuestCfgItem, CfgParams.ChapterCfgItem)
    end
end

---@param ParamsList table
function QuestMgr:TryUpdateParamsListIcon(ParamsList)
    local bNeedSort = false
    for _, Params in ipairs(ParamsList) do
        local bTracking = (Params.QuestID == QuestMgr:GetTrackingQuest())
        if Params.bTracking ~= bTracking then
            bNeedSort = true
        end
        Params.bTracking = bTracking

        if (Params.Icon == nil) then
            Params.Icon = QuestMgr:GetQuestIconAtHUD(
                Params.QuestID, Params.QuestType, (Params.ActorType == EActorType.Monster))
            if self.bEnableQuestCheckInfo then
                self.QuestCheckInfo = {}
            end
            Params.LockMask = QuestHelper.CheckCanProceed(Params.QuestID) and 0 or 1
            if self.QuestCheckInfo ~= nil then
                if next(self.QuestCheckInfo) ~= nil then
                    local LogMsg = string.format("QuestCheckInfo #%d", Params.QuestID)
                    for _, Msg in ipairs(self.QuestCheckInfo) do
                        LogMsg = string.format("%s, [%s]", LogMsg, Msg)
                    end
                    QuestHelper.PrintQuestInfo(LogMsg)
                end
                self.QuestCheckInfo = nil
            end
            local QuestCfgItem = QuestHelper.GetQuestCfgItem(Params.QuestID)
            local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
            Params.ChapterStatus = QuestMgr:GetChapterStatus(ChapterID)
        end
    end
    if bNeedSort then
        table.sort(ParamsList, self.QuestRegister.NpcQuestComp)
    end
end

function QuestMgr:ClearReconnectInfo()
    self.CacheMsgBodyList = {}
    if self.ReqListTimer ~= nil then
        self:UnRegisterTimer(self.ReqListTimer)
        self.ReqListTimer = nil
    end
end

function QuestMgr.CreateClientBehavior(QuestID, BehaviorID, TargetID)
    return QuestFactory.CreateBehavior(QuestID, BehaviorID, TargetID)
end

-- ==================================================
-- 外部接口
-- ==================================================

---查询NPC身上的任务（TODO 一次交互会触发多次，需要优化）
---@param InNpcResID int32
---@return luatable
function QuestMgr:GetNPCQuestParamsList(InNpcResID)
    if not self.bQuestDataInit then return {} end
    local QuestParamsListOnNpc = self.QuestRegister.QuestParamsListOnNpc

    -- if self.QuestRegister:CheckNpcQuestUpdated(InNpcResID) then
    --     local ParamsList = QuestParamsListOnNpc[InNpcResID] or {}
    --     self:TryUpdateParamsListIcon(ParamsList)
    --     return ParamsList
    -- end

    -- local profile_tag = ProfileTag("GetNPCQuestParamsList")
    -- local StartQuestIDList = self.QuestRegister:GetStartQuestIDListOnNpc(InNpcResID)
    -- if next(StartQuestIDList) ~= nil then
    --     local profile_tag1 = ProfileTag()
    --     for _, StartQuestID in ipairs(StartQuestIDList) do
    --         profile_tag1:Begin("FindAndTryActivateQuest")
    --         local QuestCfgItem = QuestHelper.GetQuestCfgItem(StartQuestID)
    --         if QuestCfgItem ~= nil then
    --             local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    --             self:TryActivateQuest(QuestCfgItem, ChapterCfgItem)
    --         end
    --         profile_tag1:End()
    --     end
    -- end
    local _ <close> = CommonUtil.MakeProfileTag("GetNPCQuestParamsList")

    local ParamsList = QuestParamsListOnNpc[InNpcResID] or {}
    self:TryUpdateParamsListIcon(ParamsList)

    self.QuestRegister:SortQuestList(ParamsList)
    -- profile_tag:End()
    return ParamsList
end

---查询怪物身上的任务
---@param InMonResID int32
---@return luatable
function QuestMgr:GetMonsterQuestParamsList(InMonResID)
    if not self.bQuestDataInit then return {} end
    local ParamsList = self.QuestRegister.QuestParamsListOnMonster[InMonResID] or {}
    self:TryUpdateParamsListIcon(ParamsList)
    if ParamsList then
        table.sort(ParamsList, self.QuestRegister.MonsterQuestComp)
    end
    return ParamsList
end

---查询EObj身上的任务
---@param InEObjID int32
---@return luatable
function QuestMgr:GetEObjQuestParamsList(InEObjID)
    if not self.bQuestDataInit then return {} end
    local ParamsList = self.QuestRegister.QuestParamsListOnEObj[InEObjID] or {}
    self:TryUpdateParamsListIcon(ParamsList)
    return ParamsList
end

---查询NPC身上排序过的任务列表
---如果仅有一个任务，跳过默认对白，反之正常执行交互
---@param InNpcResID int32
---@return int32 | nil
function QuestMgr:GetNPCAutoInteractQuest(InNpcResID)
    local ParamsList = {}
    for _, NPCQuestParams in ipairs(self:GetNPCQuestParamsList(InNpcResID)) do
        if NPCQuestParams.bShowQuestFunction then
            table.insert(ParamsList, NPCQuestParams)
        end
    end

    local Params1 = ParamsList[1]
    if Params1 == nil or not Params1.QuestType or Params1.QuestType ~= ProtoRes.QUEST_TYPE.QUEST_TYPE_MAIN then 
        return nil
    end
    return Params1.QuestID
end

---NPC对话完成后续处理
---@param Params table 从self.QuestRegister.QuestParamsListOnNpc获取
function QuestMgr:OnQuestInteractionFinished(Params)
    -- if QuestHelper.CheckQuestNumReachLimit() then return end

    local QuestID = Params.QuestID
    local Quest = self.QuestMap[QuestID]

    -- 用Params找到对应Target，如果是提交物品则显示界面
    -- TODO[lydianwang]: 不应该放这里，提交物品可以没有对话
    -- 任务各类交互后行为应该放FunctionQuest里，由Params控制，对话只是其中一个
    if Quest ~= nil then
        local Target = Quest.Targets[Params.TargetID]
        if Target and (Target.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS) then
            if Target.Cfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_GET_ITEM then
                if Target:CheckCanFinish() then
                    Target:ShowItemSubmitView(Params.DialogOrSequenceID or 0)
                    return false
                else
                    MsgTipsUtil.ShowTips(LSTR(591004)) --591004("物品数量不足")
                    return true
                end
            elseif (Target.Cfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_EMOTION)
            and (0 ~= (Target.EmotionID or 0)) then
                -- https://tapd.woa.com/20420083/prong/stories/view/1120420083117660524 交互修改为打开表情面板
                local OpenEmoctionPanel = false
                local NpcID = Target:GetNpcID()
                local ResID = (NpcID ~= 0) and NpcID or Target:GetEObjID()
                if ResID ~= 0 then
                    local NpcActor = ActorUtil.GetActorByResID(ResID)
                    if NpcActor then
                        local AttrComp = NpcActor:GetAttributeComponent()
                        if AttrComp then
                            local EventParams = _G.EventMgr:GetEventParams()
                            EventParams.ULongParam1 = AttrComp.EntityID
                            EventParams.IntParam1 = AttrComp.ObjType
                            _G.EventMgr:SendCppEvent(EventID.ManualSelectTarget, EventParams)
                            OpenEmoctionPanel = true
                        end
                    end
                end
                if not OpenEmoctionPanel then
                    _G.EmotionMgr:SendEmotionReq(Target.EmotionID)
                end
                return true
            elseif Target.Cfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_NAME_CHOCOBO then
                Target:FinishDialog()
                return true
            end
        end
    end

    if Quest == nil then
       -- 二次保护,任务没有状态才允许接取
        if self:GetQuestStatus(QuestID) == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
            self:SendAcceptQuestWithBranchCheck(QuestID, Params.ResID)
        else
            FLOG_ERROR(string.format("[Quest] Send Accept Error, questid=%s , status=%s", tostring(QuestID), tostring(self:GetQuestStatus(QuestID))))
        end
    elseif Quest.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
        if  _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(QuestID) then
            self:SendFaultTolerant(Params.TargetID)
        else
            self:SendFinishTargetWithBranchCheck(QuestID, Params.TargetID, Params.ResID)
        end
    elseif Quest.Status == QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT then
        QuestHelper.PreFinish(QuestID, Params.ResID)
    end
    return true
end

---@param QuestID int32
---@return string
function QuestMgr:GetQuestIconAtHUD(QuestID, QuestType, bMonster)
    if _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(QuestID) then
        if not _G.QuestFaultTolerantMgr:CheckCanProceed(QuestID) then
            return QuestDefine.FaultTolerantIconUnproceed
        end
        return QuestDefine.FaultTolerantIcon
    end
    return QuestHelper.GetQuestIconInternal(QuestID, QuestType, bMonster, "HUD")
end

---@param QuestID int32
---@return string
function QuestMgr:GetQuestIconAtMap(QuestID, QuestType, bMonster)
    if _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(QuestID) then
        if not _G.QuestFaultTolerantMgr:CheckCanProceed(QuestID) then
            return QuestDefine.FaultTolerantIconUnproceed
        end
        return QuestDefine.FaultTolerantIcon
    end
    return QuestHelper.GetQuestIconInternal(QuestID, QuestType, bMonster, "MAP")
end

---@param QuestID int32
---@return string
function QuestMgr:GetQuestIconAtLog(QuestID, QuestType, bMonster)
    return QuestHelper.GetQuestIconInternal(QuestID, QuestType, bMonster, "LOG")
end

---@param ChapterID int32
---@return string
function QuestMgr:GetChapterIconAtLog(ChapterID)
    if ChapterID == nil then return "" end
    local QuestID = nil

    local EndChapter = self.EndChapterMap[ChapterID]
    if EndChapter then
        QuestID = EndChapter.CurrQuestID
    else
        local Chapter = self.ChapterMap[ChapterID]
        if Chapter then
            QuestID = Chapter.CurrQuestID
        else
            local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
            if ChapterCfgItem ~= nil then
                QuestID = ChapterCfgItem.StartQuest
            end
        end
    end

    return QuestHelper.GetQuestIconInternal(QuestID, nil, false, "LOG")
end

function QuestMgr:GetTrackingIconAtHUD(QuestID)
    return QuestHelper.GetTrackingIconInternal(QuestID, QuestDefine.SOURCE_TYPE.HUD)
end

function QuestMgr:GetTrackingIconAtMap(QuestID)
    return QuestHelper.GetTrackingIconInternal(QuestID, QuestDefine.SOURCE_TYPE.MAP)
end

---判断是否可显示客户端NPC
---@param NpcID int32
---@return boolean
function QuestMgr:CanCreateQuestNpc(NpcID)
    return self.QuestRegister.ClientNpc[NpcID]
end

---@param MapID int32
---@return string
function QuestMgr:GetQuestRequiredMapBGM(MapID)
    return self.QuestRegister.QuestMapBGM[MapID]
end

---@param MapID int32
---@return table<int32>
function QuestMgr:GetQuestObstacle(MapID)
    return self.QuestRegister.QuestObstacle[MapID]
end

---@param MapID number
---@return table<number>
function QuestMgr:GetQuestAreaScene(MapID)
    return self.QuestRegister.QuestAreaScene[MapID]
end

---@param MapID number
---@return table<number>
function QuestMgr:GetQuestEObjState(EObjID)
    return self.QuestRegister.EObjState[EObjID]
end

---判断是否可创建区域触发器
---@param AreaID int32
---@param MapID int32
---@return bool
function QuestMgr:CanCreateQuestTriggerArea(AreaID, MapID)
    local MapAreaList = self.QuestRegister.TriggerAreaList[MapID]
    return (MapAreaList ~= nil) and (MapAreaList[AreaID] == true)
end

---判断是否可显示任务EObj
---@param NpcID int32
---@return boolean
function QuestMgr:CanCreateEObj(EObjID)
    return self.QuestRegister.QuestEObj[EObjID]
end

---@param ResID int32
---@param bMoving boolean
function QuestMgr:SetClientNpcMoving(ResID, bMoving)
    bMoving = bMoving or (bMoving == nil)
    self.QuestRegister.MovingClientNpc[ResID] = bMoving
end

---@param ResID int32
---@return boolean
function QuestMgr:CheckClientNpcMoving(ResID)
    return self.QuestRegister.MovingClientNpc[ResID]
end

function QuestMgr:GetAutoPlaySequenceId(MapID)
    if (self.QuestRegister == nil or self.QuestRegister.MapAutoPlaySeqInfo == nil ) then
        return 0
    end
    
    local SequenceInfo = self.QuestRegister.MapAutoPlaySeqInfo[MapID]
    if not (SequenceInfo and next(SequenceInfo)) then 
        return 0 
    end

    return SequenceInfo.SequenceID
end

---@param MapID int32
---@return boolean
function QuestMgr:PlayQuestMapSequence(MapID)
    local SequenceInfo = self.QuestRegister.MapAutoPlaySeqInfo[MapID]
    if not (SequenceInfo and next(SequenceInfo)) then return false end

    local function SequenceStoppedCallback(_)
        _G.NpcDialogMgr:CheckNeedEndInteraction()
        self:SendFinishTarget(SequenceInfo.QuestID, SequenceInfo.TargetID)
    end

    -- print("test PlayQuestMapSequence bSeqWaitLoading = false")
    self.bSeqWaitLoading = false
    --进seq之前先兜底处理一次镜头
    if SequenceInfo.Callback ~= nil then
        SequenceInfo.Callback()
    end
    QuestHelper.QuestPlaySequence(SequenceInfo.SequenceID, SequenceStoppedCallback)
    self.QuestRegister:UnRegisterMapAutoPlaySequence(MapID)
    return true
end

---@param QuestID int32
---@return ProtoCS.CS_QUEST_STATUS
function QuestMgr:GetQuestStatus(QuestID)
    if QuestID == nil then return QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED end

    local EndChapterID = self.EndQuestToChapterIDMap[QuestID]
    if EndChapterID then return QUEST_STATUS.CS_QUEST_STATUS_FINISHED end

    local Quest = self.QuestMap[QuestID]
    if not Quest then return QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED end

    return Quest.Status or QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED
end

---@param TargetID int32
---@return ProtoCS.CS_QUEST_NODE_STATUS
function QuestMgr:GetTargetStatus(TargetID)
    if TargetID == nil then return TARGET_STATUS.CS_QUEST_NODE_STATUS_NOT_STARTED end
    local QuestID = TargetID // 100 -- 目标ID在任务ID的基础上多两位

    local EndChapterID = self.EndQuestToChapterIDMap[QuestID]
    if EndChapterID then return TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED end

    local Quest = self.QuestMap[QuestID]
    if not Quest then return TARGET_STATUS.CS_QUEST_NODE_STATUS_NOT_STARTED end

    local Target = Quest.Targets[TargetID]
    if not Target then return TARGET_STATUS.CS_QUEST_NODE_STATUS_NOT_STARTED end

    return Target.Status or TARGET_STATUS.CS_QUEST_NODE_STATUS_NOT_STARTED
end

---@param ChapterID int32
---@return CHAPTER_STATUS
function QuestMgr:GetChapterStatus(ChapterID)
    if ChapterID == nil then return CHAPTER_STATUS.NOT_STARTED end

    local EndChapter = self.EndChapterMap[ChapterID]
    if EndChapter then return CHAPTER_STATUS.FINISHED end

    local Chapter = self.ChapterMap[ChapterID]
    if not Chapter then return CHAPTER_STATUS.NOT_STARTED end

    return Chapter.Status or CHAPTER_STATUS.NOT_STARTED
end

---@param QuestID int32
---@return CHAPTER_STATUS|nil
function QuestMgr:GetQuestChapterStatus(QuestID)
	local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
	if QuestCfgItem == nil then return nil end
	return self:GetChapterStatus(QuestCfgItem.ChapterID)
end

---@param QuestID int32
---@return string|nil
function QuestMgr:GetQuestName(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then
        return _G.QuestFaultTolerantMgr:GetChapterName(QuestID)
    end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return nil end
    return ChapterCfgItem.QuestName
end

---@param QuestID int32
---@return ProtoRes.QUEST_TYPE|nil
function QuestMgr:GetQuestType(QuestID)
	return QuestHelper.GetQuestTypeByQuestID(QuestID)
end

---@return ChapterID int32|nil
function QuestMgr:GetTrackingChapter()
	return QuestMainVM:GetTrackingChapter()
end

---@return QuestID int32|nil
function QuestMgr:GetTrackingQuest()
	local ChapterID = QuestMainVM:GetTrackingChapter()
    local Chapter = self.ChapterMap[ChapterID]
    if Chapter == nil then return nil end
    local CurrQuestID = Chapter.CurrQuestID
    return CurrQuestID
end

---@param ChapterID int32
---@return boolean
function QuestMgr:SetTrackChapter(ChapterID)
    if self.ChapterMap[ChapterID] == nil then return false end
	QuestMainVM:SetTrackChapter(ChapterID)
    return true
end

---@param QuestID int32
---@return boolean
function QuestMgr:SetTrackQuest(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return false end
    return self:SetTrackChapter(QuestCfgItem.ChapterID)
end

function QuestMgr:CancelTrackQuest()
    QuestMainVM:SetTrackChapter(nil)
end

function QuestMgr:CheckNeedRevertTarget()
    local TargetID = self.QuestRegister:GetTargetNeedRevert()
    if TargetID == nil or TargetID == 0 then
        QuestHelper.PrintQuestWarning("Revert target ID invalid")
        return
    end
    self:SendTargetRevert(TargetID)
end

function QuestMgr:CheckNeedRemoveQuest()
    if not _G.OpsActivityMgr.QueryActivityList then
        return
    end
    local GiveUpList = {}
    for ChapterID, Chapter in pairs(self.ChapterMap) do
        local Cfg = Chapter.Cfg
        if Cfg then
            --任务活动,活动结束要移除数据
            if Cfg.Activity > 0 then
                if not self.QuestRegister:IsActivityOpen(Cfg.Activity) then
                    table.insert(GiveUpList, ChapterID)
                end
            end
        end
    end
    for ChapterID, Chapter in pairs(self.EndChapterMap) do
        local Cfg = Chapter.Cfg
        if Cfg then
            if Cfg.Activity > 0 then
                if not self.QuestRegister:IsActivityOpen(Cfg.Activity) then
                    table.insert(GiveUpList, ChapterID)
                end
            end
        end
    end
    if #GiveUpList > 0 then
        self:SendGiveUpQuest(GiveUpList, true)
    end
end

---@param TargetID int32
---@param ActorType int32
---@param ResID int32
---@return boolean
function QuestMgr:IsTargetRegisteredOnActor(TargetID, ActorType, ResID)
    if TargetID == nil then return false end

    local QuestParamsList = {}
    if ActorType == EActorType.Npc then
        QuestParamsList = self:GetNPCQuestParamsList(ResID)
    elseif ActorType == EActorType.EObj then
        QuestParamsList = self:GetEObjQuestParamsList(ResID)
    elseif ActorType == EActorType.Monster then
        QuestParamsList = self:GetMonsterQuestParamsList(ResID)
    end    

    for _, QuestParams in ipairs(QuestParamsList) do
        if TargetID == QuestParams.TargetID then 
            return true, QuestParams end
    end
    return false
end

---获取特定类型和状态的任务列表，支持获取多种状态
---由于历史命名问题，用ChapterID代表任务，QuestID代表任务内节点
---@param QuestType QUEST_TYPE
---@param ChapterStatusList table<CHAPTER_STATUS>
---@return table<CHAPTER_STATUS, table<int32>>
function QuestMgr:GetChapterIDList(QuestType, ChapterStatusList)
    if (QuestType == nil) or (ChapterStatusList == nil) then return {} end

    local ChapterIDList = {}
    for _, ChapterStatus in ipairs(ChapterStatusList) do
        ChapterIDList[ChapterStatus] = {}
    end

    if ChapterIDList[CHAPTER_STATUS.NOT_STARTED] ~= nil then
        -- 只会获取可接取的任务
        for _, CfgPak in pairs(self.ActivatedCfgPakMap) do
            if QuestType == CfgPak[2].QuestType then
                table.insert(ChapterIDList[CHAPTER_STATUS.NOT_STARTED], CfgPak[2].id)
            end
        end
    end

    if (ChapterIDList[CHAPTER_STATUS.IN_PROGRESS] ~= nil)
    or (ChapterIDList[CHAPTER_STATUS.CAN_SUBMIT] ~= nil) then
        for ChapterID, Chapter in pairs(self.ChapterMap) do
            if (QuestType == Chapter.Cfg.QuestType)
            and (ChapterIDList[Chapter.Status] ~= nil) then
                table.insert(ChapterIDList[Chapter.Status], ChapterID)
            end
        end
    end

    if (ChapterIDList[CHAPTER_STATUS.FINISHED] ~= nil)
    or (ChapterIDList[CHAPTER_STATUS.FAILED] ~= nil) then
        for ChapterID, Chapter in pairs(self.EndChapterMap) do
            if (QuestType == Chapter.Cfg.QuestType)
            and (ChapterIDList[Chapter.Status] ~= nil) then
                table.insert(ChapterIDList[Chapter.Status], ChapterID)
            end
        end
    end

    return ChapterIDList
end

---是否存在满足条件的职业
---@param ChapterID number
---@return boolean
function QuestMgr:IsExistProfessionMeetCondition(QuestID)
    local RoleDetail = MajorUtil.GetMajorRoleDetail()
    if not RoleDetail then
        return false
    end
    local QuestCfgItem = QuestCfg:FindCfgByKey(QuestID)
    if not QuestCfgItem then
        return true
    end
    local ChapterCfgItem = QuestChapterCfg:FindCfgByKey(QuestCfgItem.ChapterID)
    if not ChapterCfgItem then
        return true
    end
    local NeedProfession = QuestCfgItem.Profession
    local MinLevel = ChapterCfgItem.MinLevel
    for ProfID, ProfData in pairs(RoleDetail.Prof.ProfList) do
        if ProfData.Level >= MinLevel then
            if NeedProfession == 0 or ProfID == NeedProfession then
                return true
            end
        end
    end
    return false
end

---不满足战斗或生产职业等级要求时打开推荐提升等级的界面
---@param ChapterID number
function QuestMgr:IsOpenPromoteLevelUp(QuestID)
    local RoleDetail = MajorUtil.GetMajorRoleDetail()
    if nil == RoleDetail or nil == RoleDetail.Prof or nil == RoleDetail.Prof.ProfList then
        print(" 【QuestMgr】IsOpenPromoteLevelUp 检测到职业列表为空 ")
        return
    end
    local QuestCfgItem = QuestCfg:FindCfgByKey(QuestID)
    if not QuestCfgItem then
        return
    end
    local ChapterCfgItem = QuestChapterCfg:FindCfgByKey(QuestCfgItem.ChapterID)
    if not ChapterCfgItem then
        return
    end
    if not RoleInitCfg then
        return
    end

    local NeedProfession = QuestCfgItem.Profession  --职业限制
    local MinLevel = ChapterCfgItem.MinLevel        --等级限制
    if NeedProfession == 0 then                     --不限制职业的情况
        local CurrentProfID = MajorUtil.GetMajorAttributeComponent().ProfID
        local CurrentProfData = RoleDetail.Prof.ProfList[CurrentProfID]
        if CurrentProfData.Level < MinLevel then
            local Specialization = RoleInitCfg:FindProfSpecialization(CurrentProfID)
            if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
                return CurrentProfID, ProtoRes.promote_type.PROMOTE_TYPE_COMBAT      --战斗职业不满足等级要求
            elseif Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
                return CurrentProfID, ProtoRes.promote_type.PROMOTE_TYPE_PRODUCTION  --生产职业不满足等级要求
            end
        end
        return
    end
    if NeedProfession and NeedProfession ~= 0 then --有限制职业的情况
        local ProfData = RoleDetail.Prof.ProfList[NeedProfession]
        if ProfData then
            if ProfData.Level >= MinLevel then
                --若限制的职业已解锁且满足等级要求则不打开推荐界面
                return
            end
            local Specialization = RoleInitCfg:FindProfSpecialization(NeedProfession)
            if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
                return NeedProfession, ProtoRes.promote_type.PROMOTE_TYPE_COMBAT
            elseif Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
                return NeedProfession, ProtoRes.promote_type.PROMOTE_TYPE_PRODUCTION
            end
        end
        return
    end
end

---任务是否开启
---@param ChapterID number
function QuestMgr:IsChapterActive(ChapterID)
    return self.ChapterMap[ChapterID] ~= nil or self.EndChapterMap[ChapterID] ~= nil
end

---获取任务分享信息
---@param ChapterID number @任务章节ID
---@return QuestShareInfoParam
function QuestMgr:GetShareInfo(ChapterID)
    ---@class QuestShareInfoParam
    ---@field StatusTip string
    ---@field BgPath string
    ---@field IconPath string
    ---@field LevelTip string
    ---@field Name string
    ---@field IsActive boolean
    local QuestShareInfoParam = {
        StatusTip = "",
        BgPath="Texture2D'/Game/UI/Texture/NewChat/UI_Chat_More_Img_TaskBanner.UI_Chat_More_Img_TaskBanner'",
        IconPath="", LevelTip="", Name="", IsActive=false,
    }
    local IsActive = self:IsChapterActive(ChapterID)
    QuestShareInfoParam.IsActive = IsActive
    local ChapterCfgItem = QuestChapterCfg:FindCfgByKey(ChapterID)
    if ChapterCfgItem then
        if IsActive then
            if ChapterCfgItem.LogImage ~= "" then
                QuestShareInfoParam.BgPath = ChapterCfgItem.LogImage
            end
            QuestShareInfoParam.Name = ChapterCfgItem.QuestName
            QuestShareInfoParam.StatusTip = LSTR(594004) --594004("求助任务")
        else
            QuestShareInfoParam.Name = "???"
            QuestShareInfoParam.StatusTip = LSTR(594005) --594005("尚未开启该任务，暂时无法查看")
        end
        QuestShareInfoParam.LevelTip = string.format(LSTR(596303), ChapterCfgItem.MinLevel) --596303("%d级")
        QuestShareInfoParam.IconPath = self:GetQuestIconAtLog(nil, ChapterCfgItem.QuestType)
    end
    return QuestShareInfoParam
end

---打开任务界面
---@param JumpChapterID number @跳转到Chapter的ID
function QuestMgr:OpenPanel(JumpChapterID)
    if not self:IsChapterActive(JumpChapterID) then
        MsgTipsUtil.ShowTips(LSTR(594006)) --594006("您暂未开启该任务")
        return
    end
    _G.UIViewMgr:ShowView(_G.UIViewID.QuestLogMainPanel, { QuestID = JumpChapterID })
end

--- 打开任务界面并跳转对应页签
function QuestMgr:OpenPanelByQuestType(QuestType)
    local View = _G.UIViewMgr:ShowView(_G.UIViewID.QuestLogMainPanel)
    View:UpdateQuestTypeSelection(QuestType)
end

---打开地图或任务界面（任务未接取则打开任务所在地图）
---@param QuestID number@任务id（6位数）
function QuestMgr:OpenMapOrLogPanel(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem then
        if self:GetChapterStatus(QuestCfgItem.ChapterID) == CHAPTER_STATUS.NOT_STARTED then
            local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
            if ChapterCfgItem then
                local StartQuestID = ChapterCfgItem.StartQuest
                if (self.ActivatedCfgPakMap[StartQuestID] ~= nil) then
                    local StartQuestCfgItem = QuestHelper.GetQuestCfgItem(StartQuestID)
                    if StartQuestCfgItem then
                        _G.WorldMapMgr:ShowWorldMapQuest(StartQuestCfgItem.AcceptMapID, StartQuestCfgItem.AcceptUIMapID, StartQuestID)
                    end
                else
                    MsgTipsUtil.ShowTips(LSTR(594006)) --594006("您暂未开启该任务")
                end
            end
        else
            _G.UIViewMgr:ShowView(_G.UIViewID.QuestLogMainPanel, { QuestID = QuestID })
        end
    end
end

---是否处于正在提交状态
---有些提交不是一瞬间的，比如使用情感动作，需要锁定状态
---@return boolean
function QuestMgr:IsSubmitingStatus()
    return self.bSubmiting
end

---设置正在提交状态
---@param Val boolean
function QuestMgr:SetSubmitingStatus(Val)
    self.bSubmiting = Val
end

---是否任务商品
---@param ItemResID number
---@return boolean
function QuestMgr:IsQuestGoods(ItemResID)
    for _, Target in ipairs(self.QuestRegister.QuestOwnItemList) do
        if Target:IsNeed(ItemResID) then
            return true
        end
    end
    return false
end

---覆盖一般交互的图标和文字
---@param InteractID number
---@param ResID number
function QuestMgr:GetQuestOverwriteInteract(InteractID, ResID)
	for _, Overwrite in ipairs(self.QuestRegister.OverwriteInteractList) do
		if QuestRegister.IsOverwriteInteractEqual(Overwrite, InteractID, ResID) then
			return Overwrite
		end
	end
    return nil
end

---根据任务目标进度显示的交互
---@param ActorType EActorType
---@param ResID number
---@return table InteractIDList
function QuestMgr:GetFollowTargetInteract(ActorType, ResID)
    local InteractIDList = {}
	for _, FollowTargetInteract in ipairs(self.QuestRegister.FollowTargetInteractList) do
		if QuestRegister.IsFollowTargetInteractEqual(
        FollowTargetInteract, FollowTargetInteract.ID, ActorType, ResID) then
			table.insert(InteractIDList, FollowTargetInteract.ID)
		end
	end
    return InteractIDList
end

---设置对白分支信息，支持分别单独设置
---@param Index number|nil
---@param ID number|nil
function QuestMgr:SetDialogBranchInfo(Index, ID)
	self.QuestRegister:SetDialogBranchInfo(Index, ID)
end

---@param DialogOrSeqID number
---@return boolean
function QuestMgr:IsBlackScreenOnStopDialogOrSeq(DialogOrSeqID)
    if _G.StoryMgr.Setting.GetAutoSkipQuestSequence() then
        return false
    end
    return self.QuestRegister:IsBlackScreenOnStopDialogOrSeq(DialogOrSeqID)
end

function QuestMgr:OnSkipQuestSequence()
    -- 假设调用到此接口时一定未设置“自动跳过任务剧情动画”，不再检查是否设置
    self.SequenceSkipCount = self.SequenceSkipCount + 1
    if self.SequenceSkipCount == 3 then
        MsgTipsUtil.ShowTips(LSTR(597003)) -- 597003("设置中可以开启自动跳过任务剧情动画功能")
    end
end

function QuestMgr:ClearCountSkipQuestSequence()
    self.SequenceSkipCount = 0
end

function QuestMgr:SetInQuestSequence(bValue)
    self.bInQuestSequence = bValue
end

---@return table table { DialogID, Callback }
function QuestMgr:GetHintTalk(NpcID, EObjID)
	return self.QuestRegister:GetHintTalk(NpcID, EObjID)
end

function QuestMgr:GetQuestSetEObjState(EObjID)
    local EObjState = self.QuestRegister.EObjState
    local State = EObjState[EObjID] or -1
    return State
end

function QuestMgr:EnableQuestCheckInfo(bEnable)
    self.bEnableQuestCheckInfo = bEnable
end

function QuestMgr:LogQuestCheckInfo(CondBit, Str)
    if self.QuestCheckInfo == nil then
        return
    end
    if CondBit ~= nil then
        table.insert(self.QuestCheckInfo, "CondBit "..CondBit)
    elseif Str ~= nil then
        table.insert(self.QuestCheckInfo, Str)
    end
end

function QuestMgr:IsTeleportAfterSequence(SequenceID)
    return self.QuestRegister.TeleportAfterSequence[SequenceID]
end

return QuestMgr
