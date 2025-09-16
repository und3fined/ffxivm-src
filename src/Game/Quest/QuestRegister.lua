--
-- Author: lydianwang
-- Date: 2022-01-12
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local TimerRegister = require("Register/TimerRegister")
local CounterMgr = require("Game/Counter/CounterMgr")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")

local QuestCfg = require("TableCfg/QuestCfg")
local NpcQuestCfg = require("TableCfg/NpcQuestCfg")

local GameEventRegister = require("Register/GameEventRegister")

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE

local QuestMgr = nil
local PWorldMgr = nil
local MapEditDataMgr = nil
local ClientVisionMgr = nil

local EActorType = _G.UE.EActorType
local ActorDescMap = {
	[EActorType.Npc] = "NPC",
	[EActorType.Monster] = "Monster",
	[EActorType.EObj] = "EObj",
}
local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS

-- TODO: 需要优化任务条件判断机制，支持LockMask
-- TODO: 更新param的标志是Icon == nil，这个要改
local ActorQuestParamsClass = {}
function ActorQuestParamsClass.New(ActorType, ResID, QuestID, QuestType,
	DialogOrSequenceID, QuestName, bShowQuestFunction, TargetID, InteractID, bDirectInteract)
	local Object = {
		ActorType = ActorType,
		ResID = ResID,
        QuestID = QuestID,
        QuestType = QuestType, -- 按任务类型排序
        DialogOrSequenceID = DialogOrSequenceID,
        QuestName = QuestName,
		bShowQuestFunction = bShowQuestFunction,
		bDirectInteract = bDirectInteract,
		-- 目标参数，可能为nil
        TargetID = TargetID,
        InteractID = InteractID,
		-- 动态数据
        bTracking = false, -- 请求列表时TryUpdateParamsListIcon动态更新
        ChapterStatus = 1, -- 请求列表时TryUpdateParamsListIcon动态更新
		LockMask = 0, -- 请求列表时TryUpdateParamsListIcon动态更新
		Icon = nil, -- 请求列表时TryUpdateParamsListIcon动态更新图标
    }
	return Object
end

---@class QuestRegister
local QuestRegister = LuaClass()

function QuestRegister:Ctor()
	QuestMgr = _G.QuestMgr
	PWorldMgr = _G.PWorldMgr
	MapEditDataMgr = _G.MapEditDataMgr
	ClientVisionMgr = _G.ClientVisionMgr

	self:InitData()

	self.TimerRegister = TimerRegister.New() -- QuestMgr没用到定时器，需要新建一个
	self.NewSubTimerID = 0

	-- 任务计数器
	self.QuestOnCounter = {} -- map< int CounterID, list< int QuestID > >
	self.QuestCounterValue = {} -- map< int CounterID, int CounterValue >

	-- 任务自身影响的其他互斥或相同任务
	self.AffectedExclusiveQuest = {} -- map< int QuestID, list< int QuestID > >
	self.AffectedSameQuest = {} -- map< int QuestID, list< int QuestID > >

	-- NPC任务已更新标记，用于优化查询性能
	self.NpcQuestUpdated = {} -- map< int NpcResID, bool >

	-- NPC任务列表，用于增量更新可接任务
	self.StartQuestIDListOnNpc = {} -- map< int NpcResID, list{ int QuestList } >

	-- 无任务NPC缓存，用于优化查询性能
	self.NoQuestNpc = {} -- map< int NpcResID, bool >

	-- 待排序任务列表
	self.QuestListToSort = {} -- map< int NpcResID, table QuestList >

	self.QuestItems = {} -- set< int ItemID >
end

---重置任务时需要刷新的数据
function QuestRegister:InitData()
	-- 玩家任务总数量
	self.QuestNum = 0

	-- NPC任务参数列表，用于NPC显示自身任务
    self.QuestParamsListOnNpc = {} -- map< int NpcResID, table QuestList >

	-- 怪物任务参数列表，用于提醒玩家去打怪
    self.QuestParamsListOnMonster = {} -- map< int MonsterResID, table QuestList >

	-- EObj任务参数列表，用于EObj显示自身任务
    self.QuestParamsListOnEObj = {} -- map< int EObjID, table QuestList >

    -- 对于职业固定任务，记录接取任务时的职业
    self.FixedProfOnAccept = {} -- map< int ChapterID, int ProfID >

	-- 任务每秒定时器与子定时器
	self.PerSecondTimer = nil
	self.SubTimerList = {}

	-- 记录任务有哪些前置任务已完成
	self.FinishedPrevQuest = {} -- map< int QuestID, set< int PrevQuestID, bool > >

	-- 需要进地图自动播放的Sequence
	self.MapAutoPlaySeqInfo = {} -- map< int MapID, list{ int SequenceID, int QuestID, int TargetID } >

	-- 需要回退的目标，只会在特定场景用到
	self.TargetNeedRevert = nil

	-- 和商城系统联动的数据
	self.QuestOwnItemList = {}

	self.OverwriteInteractList = {} -- list< table >

	self.FollowTargetInteractList = {} -- list< table >

	self.UseItemTargets = {} -- map< int TargetID, int ItemID >

	self.BlackScreenOnStopDialogOrSeq = {} -- list< int SequenceID >

	self.NpcHintTalks = {} -- map< int NpcID, list { int DialogID, function Callback } >
	self.EObjHintTalks = {} -- map< int EObjID, list { int DialogID, function Callback } >

	self.ActivityMap = {} --map<int ActivityID, int Status>
	self.ActivityQuestMap = {} --map<int QuestID, int ActivityID>
	self.TimeLimitMap = {} --map<int QuestID, int TimeStamp>

	self.TeleportAfterSequence = {} --map< int SequenceID, bool >

	self:PWorldInitData()
	self:DeActivateQuests()
	self:PreQuestUpdate()

	------ 后台也会记录的数据 ------

    -- 是否需要显示NPC
	self.ClientNpc = {} -- set< int NpcID, bool >

	-- 记录任务修改的地图默认BGM
	self.QuestMapBGM = {} -- map< int MapID, string MusicName >

	-- 任务相关触发器
	self.TriggerAreaList = {} -- map< int MapID, set< int AreaID, bool > >

    -- 是否需要显示EObj
	self.QuestEObj = {} -- set< int EObjResID, bool >

	-- 是否需要显示Obstacle
	self.QuestObstacle = {} -- map< int MapID, set< int ObstacleID, bool > >

	-- 是否需要显示Area
	self.QuestAreaScene = {} -- map < int MapID, set< int AreaID, bool > >

    -- EObj状态
	self.EObjState = {} -- set< int EObjResID, int State >

	-- 清理事件监听
	local Register = self.GameEventRegister
	if Register then
		Register:UnRegisterAll()
	end
end

---切地图后要清空的数据
function QuestRegister:PWorldInitData()
	-- 记录NPC移动，目前用于控制头顶图标显示
	self.MovingClientNpc = {}

	-- 屏幕特效(粒子)路径对应的FXID，用来打断特效
	-- self.ScreenEffectFXID = {} -- map< string FXPath, int FXID >
end

---更新任务前要清空的数据
function QuestRegister:PreQuestUpdate()
	-- 对话/对白中选择的选项，从1开始
	self.DialogChoiceIndex = 0
	-- 对话/对白中分支在《对白分支表》的唯一ID
	self.BranchUniqueID = 0
end

---任务相关条件变更时要更新的数据
---@param bKeepNpcQuest boolean 不清空NPC任务列表
---@param QuestIDCheckList table 只检查此任务列表数据
function QuestRegister:DeActivateQuests(bKeepNpcQuest, QuestIDCheckList)
	if not bKeepNpcQuest then
		self.NpcQuestUpdated = {}
	end

	local DeActivateQuestIDs = {}

	if QuestIDCheckList ~= nil then
		for _, QuestID in ipairs(QuestIDCheckList) do
			local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
			if QuestCfgItem and not QuestHelper.CheckCanActivate(QuestID, QuestCfgItem) then
				DeActivateQuestIDs[QuestID] = QuestCfgItem
			end
		end

	else
		for QuestID, CfgPak in pairs(QuestMgr.ActivatedCfgPakMap) do
			if not QuestHelper.CheckCanActivate(QuestID, CfgPak[1], CfgPak[2]) then
				DeActivateQuestIDs[QuestID] = CfgPak[1]
			end
		end
	end

	for QuestID, QuestCfgItem in pairs(DeActivateQuestIDs) do
		QuestHelper.RemoveNpcActivatedQuest(QuestCfgItem)
		QuestMgr.ActivatedCfgPakMap[QuestID] = nil
	end
end

function QuestRegister:ResetData()
    local CurrMapEditCfg = MapEditDataMgr:GetMapEditCfg()
	if CurrMapEditCfg then
		for _, NpcData in ipairs(CurrMapEditCfg.NpcList) do
			if self.ClientNpc[NpcData.NpcID] then
				ClientVisionMgr:ClientActorLeaveVision(NpcData.ListId, EActorType.Npc)
			end
		end

		if self.QuestMapBGM[CurrMapEditCfg.MapID] then
			local MapTableCfg = PWorldMgr:GetMapTableCfg(CurrMapEditCfg.MapID)
			if MapTableCfg then
				PWorldMgr:SwitchMapDefaultBGMusic(MapTableCfg.BGMusic)
			end
		end

		for _, EObjData in ipairs(CurrMapEditCfg.EObjList) do
			if EObjData.Type == ProtoRes.ClientEObjType.ClientEObjTypeTask
			and self.QuestEObj[EObjData.ResID] then
				ClientVisionMgr:ClientActorLeaveVision(EObjData.ID, EActorType.EObj)
			end
		end
	end

	-- for _, FXID in pairs(self.ScreenEffectFXID) do
    --     EffectUtil.BreakEffect(FXID)
	-- end

	self:InitData()

	if self.TimerRegister then
		self.TimerRegister:UnRegisterAll()
	end
end

function QuestRegister:OnPWorldEnter()
	self:PWorldInitData()
end

---@param QuestGenreID int32
function QuestRegister:OnAddQuest(QuestGenreID)
	if (10000 < QuestGenreID) and (QuestGenreID < 20000) then return end -- 主线不计数
	self.QuestNum = self.QuestNum + 1 -- 不作检查，方便发现bug
end

---@param QuestGenreID int32
function QuestRegister:OnRemoveQuest(QuestGenreID)
	if (10000 < QuestGenreID) and (QuestGenreID < 20000) then return end -- 主线不计数
	self.QuestNum = self.QuestNum - 1 -- 不作检查，方便发现bug
end

-- ==================================================
-- 各类数据注册接口
-- ==================================================

-- --------------------------------------------------
-- 注册任务到Actor身上
-- --------------------------------------------------

---@return boolean
function QuestRegister:RegisterQuestOnActor(ActorType, QuestParamsListOnActor,
	ResID, QuestID, QuestType, DialogOrSequenceID, QuestName, bShowQuestFunction, Target)

	local ActorDesc = ActorDescMap[ActorType] or "None"
	QuestParamsListOnActor, ResID, QuestID =
		(QuestParamsListOnActor or {}), (ResID or 0), (QuestID or 0)

    if (QuestID == 0) or (ResID == 0) then
        QuestHelper.PrintQuestWarning("Registering quest #%d on %s %d failed", QuestID, ActorDesc, ResID)
        return false
    end

	local TargetID = nil
	if Target then
		TargetID = Target.TargetID
	end

    QuestParamsListOnActor[ResID] = QuestParamsListOnActor[ResID] or {}
    local QuestList = QuestParamsListOnActor[ResID]
    for i = 1, #QuestList do
        if QuestID == QuestList[i].QuestID and TargetID == QuestList[i].TargetID then
            return false
        end
    end

	if QuestMgr.bQuestDataInit then
		-- local TargetInfo = ""
		if TargetID ~= nil then
			-- TargetInfo = string.format(" target #%d", TargetID)
			QuestHelper.PrintQuestInfo("Registering quest target #%d on %s %d", TargetID, ActorDesc, ResID)
		end
		-- QuestHelper.PrintQuestInfo("Registering quest #%d%s on %s %d", QuestID, TargetInfo, ActorDesc, ResID)
	end

	QuestType = QuestType or QuestCfg:FindChapterValue(QuestID, "QuestType")

	local InteractID = nil
	if Target and Target.Cfg and Target.Cfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT then
		InteractID = Target.InteractID -- 提供信息给交互系统，做特殊处理
	end

	local bDirectInteract = false
	if Target then
		local Params = QuestDefine.TargetClassParams[Target.Cfg.m_iTargetType]
		if Params and (nil ~= Params.bDirectInteract) then
			bDirectInteract = Params.bDirectInteract
		end
	end

	local QuestParams = ActorQuestParamsClass.New(ActorType, ResID, QuestID, QuestType,
		DialogOrSequenceID, QuestName, bShowQuestFunction, TargetID,
		InteractID, bDirectInteract)
    table.insert(QuestList, QuestParams)

    self:RegisterQuestListToSort(ActorType, QuestParamsListOnActor, ResID)

	return true
end

---@return boolean
function QuestRegister:UnRegisterQuestOnActor(ActorType, QuestParamsListOnActor,
	ResID, QuestID, TargetID)

	local ActorDesc = ActorDescMap[ActorType] or "None"
	QuestParamsListOnActor, ResID, QuestID =
		(QuestParamsListOnActor or {}), (ResID or 0), (QuestID or 0)

    if (QuestID == 0) or (ResID == 0) then
        QuestHelper.PrintQuestWarning("UnRegistering quest #%d on %s %d failed", QuestID, ActorDesc, ResID)
        return false
    end

    local QuestList = QuestParamsListOnActor[ResID]
    if QuestList == nil then return false end

	local bRet = false
    for i = #QuestList, 1, -1 do
        if QuestID == QuestList[i].QuestID and TargetID == QuestList[i].TargetID then
            table.remove(QuestList, i)

			if QuestMgr.bQuestDataInit and (TargetID or 0) ~= 0 then
				QuestHelper.PrintQuestInfo("UnRegistering quest target #%d on %s %d", TargetID, ActorDesc, ResID)
			end
			bRet = true
            break
        end
    end

    if next(QuestList) == nil then
        QuestParamsListOnActor[ResID] = nil
    end

	self.MakeLuaColonValid = nil
	return bRet
end

---@return boolean
function QuestRegister:RegisterQuestOnNpc(NpcResID, QuestID, QuestType, DialogOrSequenceID, QuestName, Target)
	local bShowQuestFunction = (DialogOrSequenceID or 0) ~= 0
	if Target then
		local Params = QuestDefine.TargetClassParams[Target.Cfg.m_iTargetType]
		if Params and (nil ~= Params.bShowQuestFunction) then
			bShowQuestFunction = Params.bShowQuestFunction
		end
	end

    local bRet = self:RegisterQuestOnActor(EActorType.Npc, self.QuestParamsListOnNpc,
		NpcResID, QuestID, QuestType,
		DialogOrSequenceID, QuestName,
		bShowQuestFunction, Target)

	self:MarkNpcQuestUpdated(NpcResID)
	return bRet
end

---@return boolean
function QuestRegister:UnRegisterQuestOnNpc(NpcResID, QuestID, TargetID)
	local bRet = self:UnRegisterQuestOnActor(EActorType.Npc, self.QuestParamsListOnNpc,
		NpcResID, QuestID, TargetID)

	self:MarkNpcQuestUpdated(NpcResID)
	return bRet
end

---@return boolean
function QuestRegister:RegisterQuestOnMonster(MonResID, QuestID, QuestType, Target)
	return self:RegisterQuestOnActor(EActorType.Monster, self.QuestParamsListOnMonster,
		MonResID, QuestID, QuestType,
		nil, nil,
		false, Target)
end

---@return boolean
function QuestRegister:UnRegisterQuestOnMonster(MonResID, QuestID, TargetID)
	return self:UnRegisterQuestOnActor(EActorType.Monster, self.QuestParamsListOnMonster,
		MonResID, QuestID, TargetID)
end

---@return boolean
function QuestRegister:RegisterQuestOnEObj(EObjID, QuestID, QuestType, QuestName, Target)
	local bShowQuestFunction = false
	if Target then
		local Params = QuestDefine.TargetClassParams[Target.Cfg.m_iTargetType]
		if Params and (nil ~= Params.bShowQuestFunction) then
			bShowQuestFunction = Params.bShowQuestFunction
		end
	end

	return self:RegisterQuestOnActor(EActorType.EObj, self.QuestParamsListOnEObj,
		EObjID, QuestID, QuestType,
		nil, QuestName,
		bShowQuestFunction, Target)
end

---@return boolean
function QuestRegister:UnRegisterQuestOnEObj(EObjID, QuestID, TargetID)
	return self:UnRegisterQuestOnActor(EActorType.EObj, self.QuestParamsListOnEObj,
		EObjID, QuestID, TargetID)
end

function QuestRegister:RegisterQuestListToSort(ActorType, QuestParamsListOnActor, ResID)
	if QuestParamsListOnActor[ResID] == nil then return end

	if self.QuestListToSort[ActorType] == nil then
		self.QuestListToSort[ActorType] = {}
	end

	self.QuestListToSort[ActorType][ResID] = QuestParamsListOnActor[ResID]
end

function QuestRegister:RegisterNpcQuestListToSort(ResID)
	self:RegisterQuestListToSort(EActorType.Npc, self.QuestParamsListOnNpc, ResID)
end

function QuestRegister:RegisterEObjQuestListToSort(ResID)
	self:RegisterQuestListToSort(EActorType.EObj, self.QuestParamsListOnEObj, ResID)
end

function QuestRegister:SortAllQuestList()
	for _, QuestLists in pairs(self.QuestListToSort) do
		for _, QuestList in pairs(QuestLists) do
			table.sort(QuestList, self.NpcQuestComp)
		end
	end
	self.QuestListToSort = {}
end

function QuestRegister:SortQuestList(ParamsList)
	if ParamsList ~= nil then
		table.sort(ParamsList, self.NpcQuestComp)
	end
end

---清空图标数据，后续动态更新
function QuestRegister:ClearAllQuestListIcon()
	local function ClearIcon(ParamsListOnActor)
		for _, ParamsList in pairs(ParamsListOnActor) do
			for _, QuestParams in ipairs(ParamsList) do
				QuestParams.Icon = nil
			end
		end
	end
	ClearIcon(self.QuestParamsListOnNpc)
	ClearIcon(self.QuestParamsListOnMonster)
	ClearIcon(self.QuestParamsListOnEObj)
end

function QuestRegister:OperateInteractorQuestList(OpFunc)
    for _, IUnit in ipairs(_G.InteractiveMgr.InteractorParamsList) do
		local ResID = IUnit.ResID
		local ActorType = IUnit.TargetType
		local ParamsListOnActor = nil

		if ActorType == EActorType.Npc then
			ParamsListOnActor = self.QuestParamsListOnNpc
		elseif ActorType == EActorType.EObj then
			ParamsListOnActor = self.QuestParamsListOnEObj
		elseif ActorType == EActorType.Monster then
			ParamsListOnActor = self.QuestParamsListOnMonster
		end

		if (ParamsListOnActor ~= nil) then
			local ParamsList = ParamsListOnActor[ResID]
			if (ParamsList ~= nil) then
				OpFunc(ParamsList)
			end
		end
    end
end

function QuestRegister:OperateCurrMapQuestList(OpFunc)
	local MapID = PWorldMgr:GetCurrMapResID()
	local QuestList = _G.QuestTrackMgr:GetMapQuestList(MapID)
	for _, QuestParam  in ipairs(QuestList) do
		local ResID = QuestParam.NaviObjID
		local NaviType = QuestParam.NaviType
		local ParamsListOnActor = nil
		if NaviType == QuestDefine.NaviType.NpcResID then
			ParamsListOnActor = self.QuestParamsListOnNpc
		elseif NaviType == QuestDefine.NaviType.EObjResID then
			ParamsListOnActor = self.QuestParamsListOnEObj
		end
		if ParamsListOnActor then
			local ParamsList = ParamsListOnActor[ResID]
			if ParamsList then
				OpFunc(ParamsList)
			end
		end
	end
end

-- --------------------------------------------------
-- 后台会记录的数据的注册接口
-- --------------------------------------------------

function QuestRegister:RegisterClientNpc(NpcID)
	-- QuestHelper.PrintQuestInfo("Registering client NPC %d", NpcID or 0)
    if (NpcID or 0) == 0 then return end
    self.ClientNpc[NpcID] = true
end

function QuestRegister:UnRegisterClientNpc(NpcID)
	-- QuestHelper.PrintQuestInfo("UnRegistering client NPC %d", NpcID or 0)
	if self.ClientNpc[NpcID] == nil then
		FLOG_WARNING("[QuestRegister] UnRegister Npc Is nil, ID="..tostring(NpcID))
		return
	end

	self.ClientNpc[NpcID] = nil
	local NpcData = MapEditDataMgr:GetNpc(NpcID)
	if NpcData ~= nil then
		ClientVisionMgr:ClientActorLeaveVision(NpcData.ListId, EActorType.Npc)
	end
end

function QuestRegister:RegisterMapBGM(MapID, BGM)
	-- QuestHelper.PrintQuestInfo("Registering BGM %s on Map %d", BGM or "?", MapID or 0)
	self.QuestMapBGM[MapID] = BGM

    local CurrMapEditCfg = MapEditDataMgr:GetMapEditCfg()
	if CurrMapEditCfg and (MapID == CurrMapEditCfg.MapID) then
		PWorldMgr:SwitchMapDefaultBGMusic(BGM)
	end
end

function QuestRegister:UnRegisterMapBGM(MapID)
	-- QuestHelper.PrintQuestInfo("UnRegistering BGM on Map %d", MapID or 0)
	if self.QuestMapBGM[MapID] == nil then return end

	self.QuestMapBGM[MapID] = nil
    local CurrMapEditCfg = MapEditDataMgr:GetMapEditCfg()
	if CurrMapEditCfg and (MapID == CurrMapEditCfg.MapID) then
		local MapTableCfg = PWorldMgr:GetMapTableCfg(MapID)
		if MapTableCfg then
			PWorldMgr:SwitchMapDefaultBGMusic(MapTableCfg.BGMusic)
		end
	end
end

function QuestRegister:RegisterQuestTrigger(MapID, AreaID)
	-- QuestHelper.PrintQuestInfo("Registering area %d on map %d", AreaID or 0, MapID or 0)

	if self.TriggerAreaList[MapID] == nil then
		self.TriggerAreaList[MapID] = {}
	end
	self.TriggerAreaList[MapID][AreaID] = true
end

function QuestRegister:UnRegisterQuestTrigger(MapID, AreaID)
	-- QuestHelper.PrintQuestInfo("UnRegistering area %d on map %d", AreaID or 0, MapID or 0)

	if self.TriggerAreaList[MapID] == nil then return end
	self.TriggerAreaList[MapID][AreaID] = nil
	if next(self.TriggerAreaList[MapID]) == nil then
		self.TriggerAreaList[MapID] = nil
	end
end

function QuestRegister:RegisterEObj(EObjID)
	-- QuestHelper.PrintQuestInfo("Registering EObj %d", EObjID or 0)
    if (EObjID or 0) == 0 then return end
	self.QuestEObj[EObjID] = true
end

function QuestRegister:UnRegisterEObj(EObjID)
	-- QuestHelper.PrintQuestInfo("UnRegistering EObj %d", EObjID or 0)
	if self.QuestEObj[EObjID] == nil then return end

	self.QuestEObj[EObjID] = nil

	local EObjData = MapEditDataMgr:GetEObjByResID(EObjID)
	if EObjData ~= nil then
		ClientVisionMgr:ClientActorLeaveVision(EObjData.ID, EActorType.EObj)
	end
end

function QuestRegister:RegisterObstacle(MapID, ObstacleID)
	if not self.QuestObstacle[MapID] then
		self.QuestObstacle[MapID] = {}
	end
	self.QuestObstacle[MapID][ObstacleID] = true

	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    local DynObstacle = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_OBSTACLE, ObstacleID)
    if DynObstacle then
        DynObstacle:UpdateState(1)
    end
end

function QuestRegister:UnRegisterObstacle(MapID, ObstacleID)
	if self.QuestObstacle[MapID] then
		self.QuestObstacle[MapID][ObstacleID] = nil
	end

	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    local DynObstacle = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_OBSTACLE, ObstacleID)
    if DynObstacle then
        DynObstacle:UpdateState(0)
    end
end

function QuestRegister:RegisterAreaScene(MapID, AreaID)
	if not self.QuestAreaScene[MapID] then
		self.QuestAreaScene[MapID] = {}
	end
	self.QuestAreaScene[MapID][AreaID] = true

	local Register = self.GameEventRegister
	if not Register then
		Register = GameEventRegister.New()
		self.GameEventRegister = Register
	end
	Register:Register(EventID.AreaTriggerBeginOverlap, self, self.OnGameEventAreaTriggerBeginOverlap)

	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    local DynArea = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA, AreaID)
    if DynArea then
        DynArea:UpdateState(1)
    end
end

function QuestRegister:UnRegisterAreaScene(MapID, AreaID)
	if self.QuestAreaScene[MapID] then
		self.QuestAreaScene[MapID][AreaID] = nil
	end

	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    local DynArea = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA, AreaID)
    if DynArea then
        DynArea:UpdateState(0)
    end

	local NeedListen = false
	for _, Map in pairs(self.QuestAreaScene) do
		for _, Area in pairs(Map) do
			if Area then
				NeedListen = true
			end
		end
	end
	if not NeedListen then
		local Register = self.GameEventRegister
		if Register then
			Register:UnRegister(EventID.AreaTriggerBeginOverlap, self, self.OnGameEventAreaTriggerBeginOverlap)
		end
	end
end

function QuestRegister:RegisterEObjState(EObjID, State)
	self.EObjState[EObjID] = State
end

function QuestRegister:UnRegisterEObjState(EObjID)
	self.EObjState[EObjID] = nil
end

-- --------------------------------------------------
-- 其他注册接口
-- --------------------------------------------------

function QuestRegister:RegisterFixedProf(ChapterID, ProfID)
	local RegProf = ProfID
	if not RegProf then
		local RoleSimple = MajorUtil.GetMajorRoleSimple()
		if RoleSimple then RegProf = RoleSimple.Prof end
	end
	self.FixedProfOnAccept[ChapterID] = RegProf
end

function QuestRegister:UnRegisterFixedProf(ChapterID)
    self.FixedProfOnAccept[ChapterID] = nil
end

function QuestRegister:RegisterPerSecondSubTimer(
	Listener, CurrTime, TimeLimit,
	CallbackOnTimer, CallbackOnStop)
	-- CallbackOnTimerParams, CallbackOnStopParams) 此两参数看未来需求再用

	if Listener == nil or CallbackOnTimer == nil or CallbackOnStop == nil then
		QuestHelper.PrintQuestWarning("RegisterPerSecondTimer() Invalid param")
		return
	end

	if self.PerSecondTimer == nil then
		self.PerSecondTimer = self.TimerRegister:Register(self, self.OnPerSecondTimer, 0, 1, 0)
	end

	-- register sub timer
	local SubTimerID = self:GenSubTimerID()
	self.SubTimerList[SubTimerID] = {
		Listener = Listener,
		CurrTime = CurrTime,
		TimeLimit = TimeLimit,
		CallbackOnTimer = CallbackOnTimer,
		CallbackOnStop = CallbackOnStop,
	}
	return SubTimerID
end

function QuestRegister:OnPerSecondTimer()
	local UnRegisterList = {}

	-- do sub timer
	for SubTimerID, Params in pairs(self.SubTimerList) do

		if Params.CurrTime < Params.TimeLimit then
			CommonUtil.XPCall(Params.Listener, Params.CallbackOnTimer, Params.CurrTime)
			Params.CurrTime = Params.CurrTime + 1
		else
			table.insert(UnRegisterList, SubTimerID)
		end
	end

	-- unregister sub timer
	for _, SubTimerID in ipairs(UnRegisterList) do
		self:UnRegisterPerSecondSubTimer(SubTimerID)
	end
end

function QuestRegister:UnRegisterPerSecondSubTimer(SubTimerID)
	if self.PerSecondTimer == nil then
		return
	end

	local Params = self.SubTimerList[SubTimerID]
	if Params ~= nil then
		local bFinished = Params.CurrTime >= Params.TimeLimit
		CommonUtil.XPCall(Params.Listener, Params.CallbackOnStop, bFinished)
		self.SubTimerList[SubTimerID] = nil
	end

	if next(self.SubTimerList) == nil then
		self.TimerRegister:UnRegister(self.PerSecondTimer)
		self.PerSecondTimer = nil
	end
end

function QuestRegister:RegisterQuestOnCounter(CounterID, QuestToReg)
	self.InsertUniqueToListMap(self.QuestOnCounter, CounterID, QuestToReg)
end

function QuestRegister:UnRegisterQuestOnCounter(CounterID, QuestToUnReg)
	for i, QuestID in ipairs(self.QuestOnCounter[CounterID]) do
		if QuestToUnReg == QuestID then
			table.remove(QuestID, i)
			return
		end
	end
end

function QuestRegister:UpdateQuestCounterValue(CounterID, CounterValue)
	self.QuestCounterValue[CounterID] = CounterValue
end

function QuestRegister:CheckQuestCounterToLimit(CounterID)
	return CounterMgr:CheckCounterToLimit(CounterID, self.QuestCounterValue[CounterID])
end

function QuestRegister:RegisterAffectedExclusiveQuest(QuestID, AffectedQuest)
	self.InsertUniqueToListMap(self.AffectedExclusiveQuest, QuestID, AffectedQuest)
end

function QuestRegister:RegisterAffectedSameQuest(QuestID, AffectedQuest)
	self.InsertUniqueToListMap(self.AffectedSameQuest, QuestID, AffectedQuest)
end

function QuestRegister:RegisterFinishedPrevQuest(QuestID, PrevQuestID)
    if QuestID == nil or PrevQuestID == nil then return end
	self.FinishedPrevQuest[QuestID] = self.FinishedPrevQuest[QuestID] or {}
	self.FinishedPrevQuest[QuestID][PrevQuestID] = true
end

function QuestRegister:UnRegisterFinishedPrevQuest(QuestID)
    if QuestID == nil then return end
	self.FinishedPrevQuest[QuestID] = nil
end

---@return luatable
function QuestRegister:GetFinishedPrevQuest(QuestID)
	return self.FinishedPrevQuest[QuestID] or {}
end

function QuestRegister:RegisterMapAutoPlaySequence(MapID, SequenceID, QuestID, TargetID, Callback)
	if MapID and SequenceID and QuestID and TargetID then
		self.MapAutoPlaySeqInfo[MapID] = {
			SequenceID = SequenceID, QuestID = QuestID, TargetID = TargetID, Callback = Callback,
		}
	end
end

function QuestRegister:UnRegisterMapAutoPlaySequence(MapID)
	self.MapAutoPlaySeqInfo[MapID] = nil
end

-- function QuestRegister:RegisterScreenEffect(FXPath, FXID)
-- 	self.ScreenEffectFXID[FXPath] = FXID
-- end

-- function QuestRegister:UnRegisterScreenEffect(FXPath)
-- 	local FXID = self.ScreenEffectFXID[FXPath]
-- 	if FXID ~= nil then
-- 		self.ScreenEffectFXID[FXPath] = nil
-- 	end
-- 	return FXID
-- end

---@return boolean
function QuestRegister:CheckNpcQuestUpdated(NpcResID)
	if (self.NpcQuestUpdated[NpcResID] == nil) then
		self.NpcQuestUpdated[NpcResID] = false
	end
	return (self.NpcQuestUpdated[NpcResID] == true)
end

---只在CheckNpcQuestUpdated执行后才生效
function QuestRegister:MarkNpcQuestUpdated(NpcResID)
	if (self.NpcQuestUpdated[NpcResID] ~= nil) then
		self.NpcQuestUpdated[NpcResID] = true
	end
end

function QuestRegister:GetStartQuestIDListOnNpc(NpcID)
	if (NpcID == nil) or (NpcID == 0) then return {} end
	if self.NoQuestNpc[NpcID] then return {} end

    if self.StartQuestIDListOnNpc[NpcID] ~= nil then
		return self.StartQuestIDListOnNpc[NpcID]
    end

    -- local profile_tag = _G.UE.FProfileTag(string.format("FindNpcQuestCfg_%d", NpcID))
	local NpcQuestCfgItem = NpcQuestCfg:FindCfgByKey(NpcID)
    -- profile_tag:End()

	if NpcQuestCfgItem ~= nil then
		self.StartQuestIDListOnNpc[NpcID] = NpcQuestCfgItem.StartQuest
		return self.StartQuestIDListOnNpc[NpcID]
	else
		-- 记录信息，避免再次查询失败
		self.NoQuestNpc[NpcID] = true
		return {}
	end
end

function QuestRegister:RegisterTargetNeedRevert(TargetID)
	self.TargetNeedRevert = TargetID
end

function QuestRegister:UnRegisterTargetNeedRevert()
	self.TargetNeedRevert = nil
end

function QuestRegister:GetTargetNeedRevert()
	return self.TargetNeedRevert or 0
end

function QuestRegister:RegisterOverwriteInteract(InteractID, Target)
	if Target ~= nil then
		local NpcID = Target:GetNpcID()
		local ResID = (NpcID ~= 0) and NpcID or Target:GetEObjID()

		local Overwrite = {
			InteractID = InteractID,
			ResID = ResID,
			DisplayName = Target.DisplayName,
			IconPath = Target.IconPath,
		}
		table.insert(self.OverwriteInteractList, Overwrite)
	end
end

function QuestRegister:UnRegisterOverwriteInteract(InteractID, Target)
	for index, Overwrite in ipairs(self.OverwriteInteractList) do
		local NpcID = Target:GetNpcID()
		local ResID = (NpcID ~= 0) and NpcID or Target:GetEObjID()
		if QuestRegister.IsOverwriteInteractEqual(Overwrite, InteractID, ResID) then
			table.remove(self.OverwriteInteractList, index)
			break
		end
	end
end

function QuestRegister.IsOverwriteInteractEqual(Overwrite, InteractID, ResID)
	return (Overwrite ~= nil) and (Overwrite.InteractID == InteractID) and (Overwrite.ResID == ResID)
end

function QuestRegister:RegisterFollowTargetInteract(InteractID, Target)
	if Target ~= nil then
		local NpcID = Target:GetNpcID()
		local ResID = (NpcID ~= 0) and NpcID or Target:GetEObjID()
		local ActorType = (NpcID ~= 0) and EActorType.Npc or EActorType.EObj

		local FollowTargetInteract = {
			ID = InteractID,
			ResID = ResID,
			ActorType = ActorType,
		}
		table.insert(self.FollowTargetInteractList, FollowTargetInteract)
	end
end

function QuestRegister:UnRegisterFollowTargetInteract(InteractID, Target)
	for index, FollowTargetInteract in ipairs(self.FollowTargetInteractList) do
		local NpcID = Target:GetNpcID()
		local ResID = (NpcID ~= 0) and NpcID or Target:GetEObjID()
		local ActorType = (NpcID ~= 0) and EActorType.Npc or EActorType.EObj

		if QuestRegister.IsFollowTargetInteractEqual(FollowTargetInteract, InteractID, ActorType, ResID) then
			table.remove(self.FollowTargetInteractList, index)
			break
		end
	end
end

function QuestRegister.IsFollowTargetInteractEqual(Interact, InteractID, ActorType, ResID)
	return (Interact ~= nil) and (Interact.ID == InteractID)
		and (Interact.ActorType == ActorType) and (Interact.ResID == ResID)
end

---设置对白分支信息，支持分别单独设置
---@param Index number|nil
---@param ID number|nil
function QuestRegister:SetDialogBranchInfo(Index, ID)
	self.DialogChoiceIndex = Index or self.DialogChoiceIndex
	self.BranchUniqueID = ID or self.BranchUniqueID
end

function QuestRegister:RegisterOwnItemData(TargetOwnItem)
	for _, Target in ipairs(self.QuestOwnItemList) do
		if Target == TargetOwnItem then
			return
		end
	end
	table.insert(self.QuestOwnItemList, TargetOwnItem)
end

function QuestRegister:UnRegisterOwnItemData(TargetOwnItem)
	for index, Target in ipairs(self.QuestOwnItemList) do
		if Target == TargetOwnItem then
			table.remove(self.QuestOwnItemList, index)
			return
		end
	end
end

---@param Args any
function QuestRegister:RegisterSeqWaitLoading(...)
	self.SeqWaitLoadingArgs = {...}
end

function QuestRegister:UnRegisterSeqWaitLoading()
	self.SeqWaitLoadingArgs = nil
end

function QuestRegister:GetSeqWaitLoadingArgs()
	return self.SeqWaitLoadingArgs
end

function QuestRegister:RegisterUseItemTarget(TargetID, ItemID)
	self.UseItemTargets[TargetID] = ItemID
	if self.QuestItems[ItemID] then
        _G.InteractiveMgr:AddEntranceUseItem(ItemID, TargetID)
	end
end

function QuestRegister:UnRegisterUseItemTarget(TargetID)
	local ItemID = self.UseItemTargets[TargetID]
	self.UseItemTargets[TargetID] = nil
	if self.QuestItems[ItemID] then
		_G.InteractiveMgr:RemoveEntranceUseItem(ItemID, TargetID)
	end
end

function QuestRegister:RegisterUseItemEntrance(ItemID, bUsableOnlyInTarget)
	self.QuestItems[ItemID] = true

	local bAdded = false
	for TargetID, TargetItemID in pairs(self.UseItemTargets) do
		if TargetItemID == ItemID then
			_G.InteractiveMgr:AddEntranceUseItem(ItemID, TargetID)
			bAdded = true
		end
	end

	if not bAdded and not bUsableOnlyInTarget then
		_G.InteractiveMgr:AddEntranceUseItem(ItemID)
	end
end

function QuestRegister:UnRegisterUseItemEntrance(ItemID, bUsableOnlyInTarget)
	self.QuestItems[ItemID] = nil
	if not bUsableOnlyInTarget then
		_G.InteractiveMgr:RemoveEntranceUseItem(ItemID)
		return
	end

	for TargetID, TargetItemID in pairs(self.UseItemTargets) do
		if TargetItemID == ItemID then
			_G.InteractiveMgr:RemoveEntranceUseItem(ItemID, TargetID)
		end
	end
end

function QuestRegister:IsBlackScreenOnStopDialogOrSeq(DialogOrSeqID)
    for i = 1, #self.BlackScreenOnStopDialogOrSeq do
        if DialogOrSeqID == self.BlackScreenOnStopDialogOrSeq[i] then
            return true
        end
    end
    return false
end

function QuestRegister:RegisterBlackScreenOnStopDialogOrSeq(DialogOrSeqID)
    if not self:IsBlackScreenOnStopDialogOrSeq(DialogOrSeqID) then
        table.insert(self.BlackScreenOnStopDialogOrSeq, DialogOrSeqID)
    end
end

function QuestRegister:UnRegisterBlackScreenOnStopDialogOrSeq(DialogOrSeqID)
    for i = 1, #self.BlackScreenOnStopDialogOrSeq do
        if DialogOrSeqID == self.BlackScreenOnStopDialogOrSeq[i] then
            table.remove(self.BlackScreenOnStopDialogOrSeq, i)
        end
    end
end

function QuestRegister:RegisterActivity(ActID, OpenStatus)
	self.ActivityMap[ActID] = OpenStatus
end

function QuestRegister:IsActivityOpen(ActID)
	if not self.ActivityMap then
		return false
	end
	return self.ActivityMap[ActID]
end

function QuestRegister:RegisterTeleportAfterSequence(SeqID)
	self.TeleportAfterSequence[SeqID] = true
end

function QuestRegister:UnRegisterTeleportAfterSequence(SeqID)
	self.TeleportAfterSequence[SeqID] = nil
end

function QuestRegister:RegisterActivityQuest(QuestID, ActID)
	if not CommonUtil.IsShipping() then
		FLOG_INFO("[QuestRegister] RegisterActivityQuest "..tostring(QuestID).." "..tostring(ActID).."\n"..debug.traceback())
	end
	self.ActivityQuestMap[QuestID] = ActID
end

function QuestRegister:UnRegisterActivityQuest(QuestID)
	if not CommonUtil.IsShipping() then
		if self.ActivityQuestMap[QuestID] then
			FLOG_INFO("[QuestRegister] UnRegisterActivityQuest "..tostring(QuestID))
		end
	end
	self.ActivityQuestMap[QuestID] = nil
end

function QuestRegister:RegisterTimeLimit(QuestID, TimeLimit)
	if not CommonUtil.IsShipping() then
		FLOG_INFO("[QuestRegister] RegisterTimeLimit %s %s", tostring(QuestID), tostring(TimeLimit))
	end
	self.TimeLimitMap[QuestID] = TimeLimit
	self:TryBeginLimitTimer()
end

function QuestRegister:UnRegisterTimeLimit(QuestID)
	if not CommonUtil.IsShipping() then
		if self.TimeLimitMap[QuestID] then
			FLOG_INFO("[QuestRegister] UnRegisterTimeLimit %s", tostring(QuestID))
		end
	end
	self.TimeLimitMap[QuestID] = nil
	self:TryBeginLimitTimer()
end

function QuestRegister:TryBeginLimitTimer()
	if self.TimeLimitTimer then
		self.TimerRegister:UnRegister(self.TimeLimitTimer)
		self.TimeLimitTimer = nil
	end
	local TargetQuestID = nil
	local NearestTime = nil
	for QuestID, TimeLimit in pairs(self.TimeLimitMap) do
		if not NearestTime then
			TargetQuestID = QuestID
			NearestTime = TimeLimit
		else
			if TimeLimit < NearestTime then
				TargetQuestID = QuestID
				NearestTime = TimeLimit
			end
		end
	end
	if TargetQuestID then
		if not CommonUtil.IsShipping() then
			FLOG_INFO("[QuestRegister] TryBeginLimitTimer %s", tostring(TargetQuestID))
		end
		self.TimeLimitTimer = self.TimerRegister:Register(self, self.OnTimeLimitTick, 0, 1, 0, TargetQuestID)
	end
end

function QuestRegister:OnTimeLimitTick(TargetQuestID)
	if self.TimeLimitMap == nil then
		return
	end
	local TimeLimit = self.TimeLimitMap[TargetQuestID]
	if TimeLimit == nil then
		return
	end
	local ServerTime = TimeUtil.GetServerLogicTime()
	local NearestTime = TimeLimit + 1 --加多一秒，担心临界值问题
	if ServerTime >= NearestTime then
		if self.TimeLimitTimer then
			self.TimerRegister:UnRegister(self.TimeLimitTimer)
			self.TimeLimitTimer = nil
		end
		--只抛事件通知，不在这里处理业务
		_G.EventMgr:SendEvent(EventID.QuestLimitTimeOver)
		if not CommonUtil.IsShipping() then
			FLOG_INFO("[QuestRegister] OnTimeLimitTick And Over")
		end
	end
end


-- ==================================================
-- 辅助功能
-- ==================================================

local ChapterStatusOrderMap = {
	[CHAPTER_STATUS.CAN_SUBMIT] = 1,
	[CHAPTER_STATUS.IN_PROGRESS] = 2,
	[CHAPTER_STATUS.NOT_STARTED] = 3,
}

---为了给其它系统使用，参数不限制类型，但至少要包含QuestID
function QuestRegister.NpcQuestComp(v1, v2)
    local ID1, ID2 = v1.QuestID, v2.QuestID
	if ID1 == nil or ID2 == nil then
		_G.FLOG_ERROR("NpcQuestComp meets invalid params, params should be TABLE and at least include \"QuestID\"")
		-- print(debug.traceback())
		return false
	end

	-- 追踪优先
	local TrackingQuestID = QuestMgr:GetTrackingQuest()
	if ID1 == TrackingQuestID then return true
	elseif ID2 == TrackingQuestID then return false
	end

	-- 容错任务优先
	local bIsFaultTolerant1 = _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(ID1)
	local bIsFaultTolerant2 = _G.QuestFaultTolerantMgr:IsFaultTolerantQuest(ID2)
	if bIsFaultTolerant1 ~= bIsFaultTolerant2 then
		return bIsFaultTolerant1
	end

	-- 可进行 < 不可进行
	local bCanProceed1 = QuestHelper.CheckCanProceed(ID1)
	local bCanProceed2 = QuestHelper.CheckCanProceed(ID2)
    if bCanProceed1 ~= bCanProceed2 then
        return bCanProceed1
    end

	local ChapterStatus1 = v1.ChapterStatus or QuestMgr:GetQuestChapterStatus(ID1) or -1
	local ChapterStatus2 = v2.ChapterStatus or QuestMgr:GetQuestChapterStatus(ID2) or -1
	-- 可提交 < 进行中 < 可接取
    if (ChapterStatus1 ~= ChapterStatus2) then
		local StatusOrder1 = ChapterStatusOrderMap[ChapterStatus1]
		local StatusOrder2 = ChapterStatusOrderMap[ChapterStatus2]
		if StatusOrder1 and StatusOrder2 then
			return StatusOrder1 < StatusOrder2
		end
    end

	local QuestType1 = v1.QuestType or QuestHelper.GetQuestTypeByQuestID(ID1) or -1
	local QuestType2 = v2.QuestType or QuestHelper.GetQuestTypeByQuestID(ID2) or -1
	-- 按ProtoRes.QUEST_TYPE排序
    if QuestType1 ~= QuestType2 then
        return QuestType1 < QuestType2
    end

	-- 高等级 < 低等级
    local Level1 = QuestCfg:FindChapterValue(ID1, "MinLevel") or -1
	local Level2 = QuestCfg:FindChapterValue(ID2, "MinLevel") or -1
    if Level1 ~= Level2 then
        return Level1 > Level2
    end

	-- 保底，无意义
    return ID1 < ID2
end

function QuestRegister.MonsterQuestComp(v1, v2)
	local ID1 = v1 and v1.QuestID or 0
	local ID2 = v2 and v2.QuestID or 0
	local bCanProceed1 = QuestHelper.CheckCanProceed(ID1)
	local bCanProceed2 = QuestHelper.CheckCanProceed(ID2)
    if bCanProceed1 ~= bCanProceed2 then
        return bCanProceed1
    end
end

function QuestRegister:GenSubTimerID()
	while self.SubTimerList[self.NewSubTimerID] ~= nil do
		self.NewSubTimerID = self.NewSubTimerID + 1 -- 任务专用，数量少，不考虑溢出情况
	end
	return self.NewSubTimerID
end

---往列表ListMap[ListID]唯一地插入InsertItem
function QuestRegister.InsertUniqueToListMap(ListMap, ListID, InsertItem)
	if ListMap[ListID] == nil then
		ListMap[ListID] = {}
	end
	for _, Item in ipairs(ListMap[ListID]) do
		if Item == InsertItem then
			return
		end
	end
	table.insert(ListMap[ListID], InsertItem)
end

function QuestRegister:SetHintTalk(NpcID, EObjID, DialogID, Callback)
	local HintTalks = nil
	local ResID = 0
	if (NpcID or 0) ~= 0 then
		HintTalks = self.NpcHintTalks
		ResID = NpcID
	elseif (EObjID or 0) ~= 0 then
		HintTalks = self.EObjHintTalks
		ResID = EObjID
	end
	if HintTalks == nil or ResID == 0 then
		QuestHelper.PrintQuestError("SetHintTalk falied", NpcID, EObjID, DialogID, Callback ~= nil)
		return
	end

	local Value = {}
	if DialogID == nil and Callback == nil then
		Value = nil
	else
		Value.DialogID = DialogID
		Value.Callback = Callback
	end
	HintTalks[ResID] = Value
end

---@return table table { DialogID, Callback }
function QuestRegister:GetHintTalk(NpcID, EObjID)
	if (NpcID or 0) ~= 0 then
		return self.NpcHintTalks[NpcID]
	elseif (EObjID or 0) ~= 0 then
		return self.EObjHintTalks[EObjID]
	end
	return nil
end

-- ==================================================
-- 事件监听
-- ==================================================

function QuestRegister:OnGameEventAreaTriggerBeginOverlap(Params)
	local CurrMapID = _G.PWorldMgr:GetCurrMapResID()
	local Map = self.QuestAreaScene[CurrMapID]
	if Map then
		local AreaID = Params.AreaID
		local Area = Map[AreaID]
		if Area then
			_G.QuestMgr:SendAreaSceneEnter(CurrMapID, AreaID)
		end
	end
end

return QuestRegister