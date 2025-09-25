---
--- Author: haialexzhou
--- DateTime: 2021-10-27
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SequencePlayerBase = require("Game/Story/SequencePlayerBase")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ObjectGCType = require("Define/ObjectGCType")
local StorySetting = require("Game/Story/StorySetting")
local ScenarioTextCfg = require("TableCfg/ScenarioTextCfg")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local NpcCfg = require("TableCfg/NpcCfg")
local DynamicCutsceneCfg = require("TableCfg/DynamicCutsceneCfg")
local MajorUtil = require("Utils/MajorUtil")
local EffectUtil = require("Utils/EffectUtil")
local StoryDefine = require("Game/Story/StoryDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorManager = _G.UE.UActorManager
local DialogueSequenceSavePath = "/Game/EditorRes/Dialogue/Sequence"
local SequencePlayerReport = require("Game/Story/SequencePlayerReport")
local ActorUIUtil = require("Utils/ActorUIUtil")
local FLOG_INFO = _G.FLOG_INFO
local LoadWorldReasonNormal = _G.UE.ELoadWorldReason.Normal
local EActorType = _G.UE.EActorType

--当前播放的sequence配置信息
local SequenceCfgClass = LuaClass()

function SequenceCfgClass:Ctor(SequencePath)
	self.SequenceID = nil
	self.SequencePath = SequencePath or ""
	self.SequenceObject = nil
	self.SceneCharacterShowType = ProtoRes.dialogue_scene_character_show_type.HIDE_ALL_EXCEPT_NPC
	self.IsAutoPlay = true
	self.BlendTime = 0
	self.bUseSyncLoad = false
	self.bHasAnyDialog = true
	self.bSkipLoadSubLevel = false
	self.bIsNcut = false

	self.bIsPlayMultiple = false
	self.CurrentSequence = nil
	self.ToTalSequence = nil
	self.StartFrameNumber = 0

	self.OnPossessTarget = nil
end

--缓存当前播放的sequence信息
local SequenceCacheInfo = LuaClass()

function SequenceCacheInfo:Ctor()
	self.SequenceCfg = nil
	self.SequenceStopedCallback = nil
	self.SequencePauseCallback = nil
	self.SequenceFinishedCallback = nil
	self.PlaybackSettings = nil
end

--连续播放的sequence信息
local SequenceContinuousInfo = LuaClass()

function SequenceContinuousInfo:Ctor()
	self.PreSequenceID = nil
	self.NextSequenceID = nil
	self.IsSequencePlaying = false
end

function SequenceContinuousInfo:OnSequencePlay(SequenceID)
	if self.PreSequenceID == nil or self.NextSequenceID == nil then
		return
	end
	if self.PreSequenceID == SequenceID then
		self.IsSequencePlaying = true
	else
		self.PreSequenceID = nil
		self.NextSequenceID = nil
		self.IsSequencePlaying = false
	end
end

--sequence上报处理
local DialogueSequenceReporter = LuaClass()

function DialogueSequenceReporter:Ctor()
	self:Init(0, 1, 0)
	self.SequencePlayerReport = SequencePlayerReport.New()
end

function DialogueSequenceReporter:Init(SequenceID, VideoType, StopFlag)
	self.SequenceID = SequenceID
	self.StopFlag = StopFlag
	self.bReportFinished = false
	self.VideoType = VideoType --VideoType(0-视频， 1-sequence)
	self.bIsCGMoviePlaying = false
end

function DialogueSequenceReporter:SetSequencePath(Path)
	self.SequencePlayerReport:RecordRoute(Path)
end

function DialogueSequenceReporter:SetStopFlag(StopFlag)
	self.StopFlag = StopFlag
	self.SequencePlayerReport:RecordBreak()
end

function DialogueSequenceReporter:ReportSequenceBegin()
	if self.SequenceID and self.SequenceID > 0 then
		_G.PWorldMgr:SendMovieBegin(self.SequenceID, self.VideoType)
	end
	self.SequencePlayerReport:RecordPlay()
end

function DialogueSequenceReporter:ReportSequenceFinished()
	if (self.bReportFinished) then
		return
	end

	if self.SequenceID and self.SequenceID > 0 then
		_G.PWorldMgr:SendMovieEnd(self.SequenceID, self.VideoType, self.StopFlag)
	end

	self.bReportFinished = true
	self.SequencePlayerReport:RecordStop()
end

---@class StoryMgr : MgrBase
local StoryMgr = LuaClass(MgrBase)

function StoryMgr:OnInit()
	self.Setting = StorySetting
	self.Setting.Init()
	self.SequencePlayer = nil
	self.bIsPlaying = false
	self.Reporter = nil
	self.CacheFuncOnPossessTarget = nil
	self.bPlayingEnterBackground = false
	self.OuterStopCallbackWhenException = nil
	self.SkipGroupSeqIDs = {}
	self.bStayOriginalMap = true

	--杂项值，各种后面新增中间变量
	self.MiscellaneousValue = {
		bWaitRestoreLayerSetFinish = false, --等开场动画的Layerset Restore结束
	}
end

function StoryMgr:OnBegin()
end

function StoryMgr:OnEnd()
	self:DestroySequencePlayer(true)
end

function StoryMgr:OnShutdown()
end

function StoryMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ClientSetupPost, self.Setting.OnGameEventClientSetupPost)
	self:RegisterGameEvent(_G.EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
	self:RegisterGameEvent(_G.EventID.LoadWorldInCutScene, self.OnGameEventLoadWorldInCutScene)
	self:RegisterGameEvent(_G.EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
	self:RegisterGameEvent(_G.EventID.PWorldLayersLoaded, self.OnGameEventPWorldLayersLoaded)
	self:RegisterGameEvent(_G.EventID.MajorCreate, self.OnOuterGameEventMajorCreate)
	self:RegisterGameEvent(_G.EventID.NetworkReconnected, self.OnGameEventNetworkReconnected)
end

function StoryMgr:DoRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.VisionEnter, self.OnGameEventVisionEnter)
	--视野控制逻辑执行完成
	self:RegisterGameEvent(_G.EventID.VisionShowMesh, self.OnGameEventVisionShowMesh)
    self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(_G.EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:RegisterGameEvent(_G.EventID.MajorEntityIDUpdate, self.OnGameEventMajorEntityIDUpdate)
	self:RegisterGameEvent(_G.EventID.BeginDialogueSpeak, self.OnGameEventBeginDialogueSpeak)
	self:RegisterGameEvent(_G.EventID.DialogueTouchWaiting, self.OnGameEventDialogueTouchWaiting)
	self:RegisterGameEvent(_G.EventID.EndDialogueSpeak, self.OnGameEventEndDialogueSpeak)
	self:RegisterGameEvent(_G.EventID.SeqSkipState, self.OnGameEventSeqSkipState)
	self:RegisterGameEvent(_G.EventID.PWorldExit, self.OnGameEventPWorldExit)
	--模型胶囊体调整完成，包括正确的Scale和Z轴调整坐标
	self:RegisterGameEvent(_G.EventID.CharacterCapsuleFit, self.OnCharacterCapsuleFit)
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAvatarAssembleAllFinish)
	self:RegisterGameEvent(_G.EventID.Avatar_InvalidAssemble, self.OnAvatarAssembleAllFinish)
	self:RegisterGameEvent(_G.EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
    self:RegisterGameEvent(_G.EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
	self:RegisterGameEvent(_G.EventID.PWorldTransBegin, self.OnGameEventPWorldTransBegin)
end

function StoryMgr:DoUnRegisterGameEvent()
	self:UnRegisterGameEvent(_G.EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:UnRegisterGameEvent(_G.EventID.VisionShowMesh, self.OnGameEventVisionShowMesh)
    self:UnRegisterGameEvent(_G.EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:UnRegisterGameEvent(_G.EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:UnRegisterGameEvent(_G.EventID.MajorEntityIDUpdate, self.OnGameEventMajorEntityIDUpdate)
	self:UnRegisterGameEvent(_G.EventID.BeginDialogueSpeak, self.OnGameEventBeginDialogueSpeak)
	self:UnRegisterGameEvent(_G.EventID.DialogueTouchWaiting, self.OnGameEventDialogueTouchWaiting)
	self:UnRegisterGameEvent(_G.EventID.EndDialogueSpeak, self.OnGameEventEndDialogueSpeak)
	self:UnRegisterGameEvent(_G.EventID.SeqSkipState, self.OnGameEventSeqSkipState)
	self:UnRegisterGameEvent(_G.EventID.PWorldExit, self.OnGameEventPWorldExit)
	self:UnRegisterGameEvent(_G.EventID.CharacterCapsuleFit, self.OnCharacterCapsuleFit)
	self:UnRegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAvatarAssembleAllFinish)
	self:UnRegisterGameEvent(_G.EventID.Avatar_InvalidAssemble, self.OnAvatarAssembleAllFinish)
	self:UnRegisterGameEvent(_G.EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
    self:UnRegisterGameEvent(_G.EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
	self:UnRegisterGameEvent(_G.EventID.PWorldTransBegin, self.OnGameEventPWorldTransBegin)
end

function StoryMgr:OnTimer()
	if (self.SequencePlayer ~= nil) then
		SequencePlayerVM:UpdateOnTimer()
	end
end


function StoryMgr:OnGameEventVisionShowMesh(Params)
	--print("0 OnGameEventVisionShowMesh EntityID=" .. tostring(Params.ULongParam1))
	if self.SequencePlayer == nil or self.EnterVisionActors == nil then
		return
	end
	local EntityID = Params.ULongParam1

	local VisionActor = ActorUtil.GetActorByEntityID(EntityID)
	--进入视野的对象如果被sequence用到，不隐藏
	if (VisionActor == nil or VisionActor:GetIsSequenceing()) then
		return
	end

	if (self.EnterVisionActors[EntityID]) then
		ActorManager:Get():HideActor(EntityID, true)
	end
end

function StoryMgr:OnCharacterCapsuleFit(Params)
	if (self.SequencePlayer ~= nil) then
		local EntityID = Params.ULongParam1
		local AdjustZ = Params.FloatParam1
		local ModelScale = Params.FloatParam2

		self:UpdateVisionActorScaleAndZPos(EntityID, AdjustZ, ModelScale)
	end
end

function StoryMgr:OnAvatarAssembleAllFinish(Params)
	if (self.SequencePlayer ~= nil) and (self.SequencePlayer:IsWaitAvatarsToAssemble()) then
		local EntityID = Params.ULongParam1
		local ActorType = Params.IntParam1
		self.SequencePlayer:OnAvatarAssembleAllFinish(EntityID, ActorType)
	end
end

function StoryMgr:OnGameEventVisionEnter(Params)
	--print("0 OnGameEventVisionEnter EntityID=" .. tostring(Params.ULongParam1))
	if nil == Params or self.SequencePlayer == nil then
		return
	end

	local EntityID = Params.ULongParam1
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	--print("1 OnGameEventVisionEnter EntityID=" .. tostring(EntityID))
	local bIsQuestNpc = false
	if Params.IntParam1 == _G.UE.EActorType.Npc then
		local Cfg = NpcCfg:FindCfgByKey(Params.IntParam2)
		bIsQuestNpc = (Cfg ~= nil) and (Cfg.IsQuestObj == 1)
	end
	
	if (Actor ~= nil and ((not Actor:IsClientActor()) or bIsQuestNpc)) then
		local TargetType = Actor:GetActorType()
		local SceneCharacterShowType = self.SequencePlayer:GetSceneCharacterShowType()

		local ResID = Actor:GetActorResID()
		if TargetType == _G.UE.EActorType.Npc and self.SequencePlayer.ResIDForbiddenInSequence[ResID] ~= nil
		and (SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.HIDE_ALL_EXCEPT_NPC
		or SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.SHOW_ALL) then
			self.SequencePlayer.ActorsForbiddenInSequence[EntityID] = true
			Actor:SetForbiddenInSequence(true)
			self:HideEnterVisionActor(EntityID)
			return
		end

		--print("2 OnGameEventVisionEnter EntityID=" .. tostring(EntityID) .. "; TargetType=" .. tostring(TargetType) .. "; SceneCharacterShowType=" .. tostring(SceneCharacterShowType))
		if (TargetType == _G.UE.EActorType.Npc
		and SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.HIDE_ALL_EXCEPT_NPC) then
			--播放剧情之前，发生了断线重连，重连成功后发送视野包会清除视野对象。 如果在收到视野回包之前开始播放剧情，剧情会新创建一个npc对象。收到视野回包后也会创建了一个一样的npc。
			--这里把满足上述情况的npc进行隐藏
			if (not self:CurrentPlayingIsNCut() and not Actor:GetIsSequenceing() and self.SequencePlayer:IsExistedInPossessableActors(Params.IntParam2)) then
				self.SequencePlayer.ActorsForbiddenInSequence[EntityID] = true
				Actor:SetForbiddenInSequence(true)
				self:HideEnterVisionActor(EntityID)
			end

			return
		elseif (TargetType == _G.UE.EActorType.Monster
		and SceneCharacterShowType == ProtoRes.dialogue_scene_character_show_type.HIDE_ALL_EXCEPT_MONSTER) then
			return
		elseif (TargetType == _G.UE.EActorType.EObj
		and SceneCharacterShowType ~= ProtoRes.dialogue_scene_character_show_type.HIDE_ALL) then
			local EObjType = Actor.EObjType
			if (EObjType == ProtoRes.ClientEObjType.ClientEObjTypeTask) then
				-- https://tapd.woa.com/tapd_fe/20420083/story/detail/1020420083120925096
				return
			end
		end

		--更新队友绑定信息(剧情辅助器机器人队友类型是Monster)
		if (TargetType == _G.UE.EActorType.Player or TargetType == _G.UE.EActorType.Monster) then
			if (ActorUIUtil.IsTeamMember(EntityID) and self.SequencePlayer ~= nil) then
				local bUpdated = self.SequencePlayer:UpdateCachedTeamMemberPossessable(EntityID)
				if (bUpdated) then
					return
				end
			end
		end

		if (SceneCharacterShowType ~= ProtoRes.dialogue_scene_character_show_type.SHOW_ALL) then
			self:HideEnterVisionActor(EntityID)
		end
	end
end

function StoryMgr:OnGameEventLoginRes(Param)
    local bReconnect = Param and Param.bReconnect

    if bReconnect and self:SequenceIsPlaying() then
		if (self.SequencePlayer ~= nil) then
			self.SequencePlayer:HideOtherCharacters(true)
		end
		if not UIViewMgr:IsViewVisible(UIViewID.DialogueMainPanel) then
			UIViewMgr:ShowView(UIViewID.DialogueMainPanel, { ViewType = StoryDefine.UIType.SequenceDialog })
		end
		if not UIViewMgr:IsViewVisible(UIViewID.CGMovieMainPanel) and self.bIsCGMoviePlaying then
			UIViewMgr:ShowView(UIViewID.CGMovieMainPanel, { MovieName = self.CGMovieNameCache,  StartTime = self.CGMoviePlayTime})
		end
    end
end

---正在播放的时候刷新了Major, 会导致缓存的PossessableInfo出错
function StoryMgr:UpdateMajorPossessableInfo(LastMajorEntityID, MajorEntityID)
	local Major = ActorUtil.GetActorByEntityID(MajorEntityID)
	if Major == nil then
		return
	end
	_G.FLOG_INFO("StoryMgr:UpdateMajorPossessableInfo:LastMajorEntityID=%d, MajorEntityID=%d", LastMajorEntityID, MajorEntityID)
	self.SequencePlayer:UpdatePossessableActorInfo(Major, LastMajorEntityID, MajorEntityID)
end

function StoryMgr:OnGameEventMajorEntityIDUpdate(Params)
	if nil == Params or self.SequencePlayer == nil then
		return
	end
	local LastMajorEntityID = self.MajorEntityID
	local EntityID = Params.ULongParam1
	self.MajorEntityID = EntityID
	if LastMajorEntityID ~= nil and EntityID ~= LastMajorEntityID then
		self:UpdateMajorPossessableInfo(LastMajorEntityID, EntityID)
	end
end

function StoryMgr:OnGameEventMajorCreate(Params)
	if nil == Params or self.SequencePlayer == nil then
		return
	end

	local bReuseMajor = Params.BoolParam1
	local LastMajorEntityID = self.MajorEntityID
	local EntityID = Params.ULongParam1
	self.MajorEntityID = EntityID
	if LastMajorEntityID ~= nil and EntityID ~= LastMajorEntityID then
		self:UpdateMajorPossessableInfo(LastMajorEntityID, EntityID)
	end

	if bReuseMajor then
		-- 主角复用时不隐藏
		return
	end
	local Major = ActorUtil.GetActorByEntityID(EntityID)
	if Major ~= nil then
		--隐藏新创建的主角
		self:HideEnterVisionActor(EntityID)
	end
end

-- VideoEnd上报：
-- 网络闪断 - 网络消息配置重新上报
-- 原地重登 - NetworkReconnected做标记，MajorCreate清理标记并上报
-- 界面登录 - ComBatStateUpdate更早，则MajorCreate上报；MajorCreate更早则定时上报

function StoryMgr:ClearCombatStatVideo()
	if self:SequenceIsPlaying() then
		return true
	end
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	--ps：这里用ComBatState，CS_COMM_STAT_CMD_STATUS需要主动获取（客户端目前没这个逻辑）
	if ActorUtil.IsInComBatState(MajorEntityID, ProtoCommon.CombatStatID.COMBAT_STAT_VIDEO) then
		_G.PWorldMgr:SendMovieEnd(0, 0, 0)
		return true
	end
	return false
end

function StoryMgr:OnOuterGameEventMajorCreate(Params)
	if nil == Params then
		return
	end

	local bReuseMajor = Params.BoolParam1
	if bReuseMajor and not self.ResendMovieEndAfterMajorCreate then
		return -- 只在刚登录时处理以下逻辑，切副本和断线(非NeedLogin)等情况不处理
	end

	self.ResendMovieEndAfterMajorCreate = false

	-- 如果上次在播片中退游戏，重新登录需通知后台修改状态
	if not self:SequenceIsPlaying() then
		if not self:ClearCombatStatVideo() then
			_G.TimerMgr:AddTimer(self, self.ClearCombatStatVideo, 2)
		end
	end
end

function StoryMgr:OnGameEventNetworkReconnected(Params)
	-- 正在播放Sequence的情况下触发断线重连不需要额外处理
	if self:SequenceIsPlaying() then
		return
	end
	self.ResendMovieEndAfterMajorCreate = false
	-- 正常情况下只有收到服务器下发的任务目标节点状态更新才会清掉缓存数据，如果收到断线重连时还没有清除缓存数据证明在两段连播Sequence中间的等待过程中出现了弱网情况
	-- 弱网情况下没办法保证连播Sequence的衔接过程能正常进行，为了避免出现掉地情况，需要先返回初始场景
	local bIsSequenceWaitingToChangeMap = self:IsSequenceWaitingToChangeMap()
	if bIsSequenceWaitingToChangeMap then
		FLOG_INFO("[StoryMgr:OnGameEventNetworkReconnected]bRelay=%s", tostring(Params.bRelay))
		self:ClearWaitingSequenceCache()
		-- ChangeMapCacheInfo没有开放给lua侧，这里重新调用一次cpp的UStoryMgr::Finish来切回原场景
		local StoryMgrInstance = _G.UE.UStoryMgr:Get()
		if (StoryMgrInstance ~= nil) then
			StoryMgrInstance:Finish()
		end
	else
		--needlogin，此时会clear bResend网络包，增加个检测
		if (not Params.bRelay) then
			local MajorEntityID = MajorUtil.GetMajorEntityID()
			--ps：这里用ComBatState，CS_COMM_STAT_CMD_STATUS需要主动获取（客户端目前没这个逻辑）
			if ActorUtil.IsInComBatState(MajorEntityID, ProtoCommon.CombatStatID.COMBAT_STAT_VIDEO) then
				self.ResendMovieEndAfterMajorCreate = true --等收到EnterPWorld包后再发
			end
		end
	end
end


function StoryMgr:OnGameEventWorldPreLoad(Params)
	self:DestroySequencePlayer()
end

function StoryMgr:OnGameEventLoadWorldInCutScene(Params)
	local bClearSequenceCacheInfo = Params
	self.bStayOriginalMap = not bClearSequenceCacheInfo
	self:DestroySequencePlayer(bClearSequenceCacheInfo)
end

-- 根据端游特殊规则裁剪(-SpeakerName-)
-- (-SpeakerName-)都在开头，所以只找第一个就行
-- 例："(-？？？？-)沙蚤!有一大群沙蚤!!"
local function OverrideNameFromContent(Content)
	if Content == nil then return nil, nil end
	if not Content:startsWith("(-") then return nil, Content end

	local Divide, _ = Content:find("-)", 1, true)
	if Divide == nil then return nil, Content end

	local OverrideName = Content:sub(3, Divide - 1)
	local NewContent = Content:sub(Divide + 3) -- 假设特殊规则都带换行符

	if (OverrideName == "") or (NewContent == "") then
		return nil, Content
	else
		return OverrideName, NewContent
	end
end

--每句对白开始都会调用
function StoryMgr:OnGameEventBeginDialogueSpeak(Params)
	if (self.SequencePlayer ~= nil) then
		local DialogueSentenceInfo = {};

		local RawContent = nil
		local Cfg = ScenarioTextCfg:FindCfgByTextKey(Params.StringParam2)
		if (Cfg ~= nil) then
			RawContent = Cfg.Content
		end

		local OverrideName
		OverrideName, DialogueSentenceInfo.Content = OverrideNameFromContent(RawContent)
		if OverrideName ~= nil then
			DialogueSentenceInfo.SpeakerName = OverrideName
		else
			local EntityID = Params.ULongParam1
			DialogueSentenceInfo.SpeakerName = (EntityID ~= 0)
				and ActorUtil.GetActorName(EntityID) or ""
		end

		DialogueSentenceInfo.bHideDialog = Params.IntParam1 > 0
		DialogueSentenceInfo.bTouchWaitCfg = Params.IntParam2 > 0 -- section配置的值，不反映实际TouchWait功能
		DialogueSentenceInfo.DialogStyle = Params.IntParam3
		DialogueSentenceInfo.bTouchIgnore = Params.BoolParam1
		--先加个开关控制
		DialogueSentenceInfo.bScrollContent = false

		DialogueSentenceInfo.bSelfSync = Params.BoolParam2

		DialogueSentenceInfo.VoiceName = nil
		if Params.StringParam3 ~= "" then
			DialogueSentenceInfo.VoiceName = Params.StringParam3
		end
		self.CurrDialogueTextKey = Params.StringParam2
		self.CurrDialogueEndTime = Params.FloatParam1
		self.bTouchNoJump = Params.BoolParam3
		self.bTouchWaitInSectionBegin = Params.BoolParam4
		--print("StoryMgr:OnGameEventBeginDialogueSpeak!!!!!!!!! self.CurrDialogueEndTime=" .. tostring(self.CurrDialogueEndTime) .. "; bTouchWaitInSectionBegin=" .. tostring(self.bTouchWaitInSectionBegin) .. "; RawContent" .. tostring(RawContent))

		self.SequencePlayer:ShowDialogueSentence(DialogueSentenceInfo)
	end
end

--对白执行按键等待
function StoryMgr:OnGameEventDialogueTouchWaiting(Params)
    if (self.SequencePlayer == nil) then return end

	if self.bTouchNoJump and SequencePlayerVM.bTouchedScreen then return end
	self.bTouchNoJump = false

	local bTouchWait = Params.BoolParam1
	if bTouchWait and (SequencePlayerVM.bIsNcut or not SequencePlayerVM.bIsAutoPlay) then
		self:PauseSequence(true)
	end
end

--每句对白结束都会调用
function StoryMgr:OnGameEventEndDialogueSpeak(Params)
	--可能出现某句对白section在新的对白section播放后才结束，避免覆盖新播放的对白语句
	if (Params.StringParam1 ~= "" and self.CurrDialogueTextKey ~= "" and self.CurrDialogueTextKey ~= Params.StringParam1) then
		return
	end

    if (self.SequencePlayer ~= nil) then
		self.CurrDialogueTextKey = nil
		self.CurrDialogueEndTime = nil
		self.bTouchNoJump = false
		self.bTouchWaitInSectionBegin = nil
		--local bTouchWait = Params.BoolParam1
		local bKeepWidget = Params.BoolParam2

		SequencePlayerVM:OnEndDialogueSentence(bKeepWidget)
	end
end

--sequence的skip状态变更
function StoryMgr:OnGameEventSeqSkipState(Params)
    if (self.SequencePlayer ~= nil) then
		local bEnableSkip = Params.BoolParam1
		local SkipEndTime = Params.FloatParam1

		if bEnableSkip then
			self.SkipEndTime = SkipEndTime
		else
			self.SkipEndTime = nil
		end
	end
end

--处理sequence播放过程中收到离开副本逻辑，这时直接终止sequence播放
function StoryMgr:OnGameEventPWorldExit(Params)
	self:StopSequenceInException()

	local StoryMgrInstance = _G.UE.UStoryMgr:Get()
	if (StoryMgrInstance ~= nil) then
		StoryMgrInstance:DestroySequenceActor()
	end

	self.SequenceCacheInfoObj = nil
end

--处理sequence播放过程外收到切地图逻辑
function StoryMgr:OnGameEventPWorldMapExit(_)
    if _G.PWorldMgr.LoadWorldReason == LoadWorldReasonNormal then
		self.bStayOriginalMap = true
		-- 正常切地图时清理黑屏，sequence切地图不管
        local FadeViewID = UIViewID.CommonFadePanel
        if UIViewMgr:IsViewVisible(FadeViewID) then
            UIViewMgr:HideView(FadeViewID)
        end
    end
end

--目前只有过场动画里有配置切换layerset
function StoryMgr:OnGameEventPWorldLayersLoaded(Params)
	local CurrTime = _G.TimeUtil.GetServerTime()
    _G.FLOG_INFO("[LoadWorld cost time record] OnGameEventPWorldLayersLoaded: CurrTime=%d Params=%d", CurrTime, Params.IntParam1)

	--change layerset
	if Params.IntParam1 == 1 and self.SequencePlayer ~= nil and self:SequenceIsPlaying() then
		self.SequencePlayer:ContinueSequence()
		_G.LoadingMgr:HideLoadingView()

	--restore
	elseif Params.IntParam1 == 2 then
		local function DelayExecute()
			_G.FLOG_INFO("[StoryMgr:OnGameEventPWorldLayersLoaded]DelayExecute,%d", self.RestoreTransformCnt)
			--又在播放新的sequence了
			if (self:SequenceIsPlaying()) then
				_G.FLOG_INFO("[StoryMgr:OnGameEventPWorldLayersLoaded]SequenceIsPlaying")
				self:CancelRestoreTransformTimer()
				return
			end
			self.RestoreTransformCnt = self.RestoreTransformCnt - 1
			local bIsLoadingView = (_G.LoadingMgr:IsLoadingView()) and (not _G.WorldMsgMgr.IsShowLoadingView)
			-- 如果有loading界面, 并且不是最后一次Callback, 设置坐标前做一次贴地检测
			local bNeedCheck = bIsLoadingView and self.RestoreTransformCnt > 0
			if bNeedCheck then
				bNeedCheck = not self:RestoreVisionActorsTransformWithCheck()
			else
				self:RestoreVisionActorsTransform()
			end
			if bNeedCheck then
				_G.FLOG_INFO("[StoryMgr:OnGameEventPWorldLayersLoaded]Check restore actors transform failed. RestoreTransformCnt=%d", self.RestoreTransformCnt)
				return
			end
			self:CancelRestoreTransformTimer()
			-- 0.1秒延迟中触发了切地图的loading界面, 这里就不再额外处理关闭界面
			if _G.WorldMsgMgr.IsShowLoadingView then
				_G.FLOG_INFO("[StoryMgr:OnGameEventPWorldLayersLoaded]IsShowLoadingView")
				return
			end
			_G.FLOG_INFO("[StoryMgr:OnGameEventPWorldLayersLoaded]HideLoadingView")
			_G.LoadingMgr:HideLoadingView()
		end
		--level加载完成后，立即贴地会偶现失败，延迟一会执行
		self:CancelRestoreTransformTimer()
		local RestoreInterval = 0.5
		self.RestoreTransformCnt = 3
		self.RestoreTransformTimerID = _G.TimerMgr:AddTimer(self, DelayExecute, 0.1, RestoreInterval, self.RestoreTransformCnt)

		if (self.MiscellaneousValue and self.MiscellaneousValue.bWaitRestoreLayerSetFinish) then
			self.MiscellaneousValue.bWaitRestoreLayerSetFinish = false
			_G.PWorldMgr:OnAutoPlaySequenceFinish()
		end
	end
end

function StoryMgr:CancelRestoreTransformTimer()
	print("[StoryMgr:CancelRestoreTransformTimer]", self.RestoreTransformTimerID)
	if self.RestoreTransformTimerID then
		_G.TimerMgr:CancelTimer(self.RestoreTransformTimerID)
		self.RestoreTransformTimerID = nil
	end
	self.RestoreTransformCnt = 0
end

function StoryMgr:OnGameEventAppEnterBackground()
	if self:SequenceIsPlayingStatus() then
		self.bPlayingEnterBackground = true
		_G.FLOG_INFO("OnGameEventAppEnterBackground PauseSequence")
		self:PauseSequence()
		if (self.SequencePlayer ~= nil) then
			self.SequencePlayer:AdjustCharactersPostion()
		end
	end
end

function StoryMgr:OnGameEventAppEnterForeground()
	if self.bPlayingEnterBackground then
		self.bPlayingEnterBackground = false
		_G.FLOG_INFO("OnGameEventAppEnterForeground ContinueSequence")
		self:ContinueSequence()
	end
end

--同地图传送时更新Major缓存信息
function StoryMgr:OnGameEventPWorldTransBegin()
	if (self.CachedVisionActorTransforms ~= nil) then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local MajorTransform = self.CachedVisionActorTransforms[MajorEntityID]
        if (MajorTransform ~= nil) then
			local NewLocation = _G.PWorldMgr:GetMajorBirthPos()
			local NewRotator = _G.PWorldMgr:GetMajorBirthRot()
			MajorTransform:SetLocation(NewLocation)
			MajorTransform:SetRotation(NewRotator:ToQuat())
			print("OnGameEventPWorldTransBegin CacheVisionActorTransform: " .. " " .. NewLocation.X .. " " .. NewLocation.Y .. " " .. NewLocation.Z)
            self.CachedVisionActorTransforms[MajorEntityID] = MajorTransform
        end
    end
end

--sequence播放期间，隐藏进入视野的Actor
function StoryMgr:HideEnterVisionActor(EntityID)
	if self.SequencePlayer == nil then
		return
	end

	local VisionActor = ActorUtil.GetActorByEntityID(EntityID)
	--进入视野的对象如果被sequence用到，不隐藏
	if (VisionActor == nil or VisionActor:GetIsSequenceing()) then
		return
	end

	ActorManager:Get():HideActor(EntityID, true)

	if (self.EnterVisionActors == nil) then
		self.EnterVisionActors = {}
	end
	if (not self.EnterVisionActors[EntityID]) then
		self.EnterVisionActors[EntityID] = true
	end
end

function StoryMgr:ShouldPlaySequence()
	if (self.SequencePlayer ~= nil) then
		print("Sequence is playing!")
		return false
	end

	if (_G.PWorldMgr:IsLoadingWorld()) then
		print("loading world!")
		return false
	end

	if (_G.PWorldMgr:PWorldInstIDIsInvalid()) then
		print("pworld is invalid!")
		return false
	end

	return true
end

---获取对白Sequence路径
---@param SequenceID int32 @对应对白表ID
---@return string @对白路Sequence径
function StoryMgr:GetDialogueSequencePath(SequenceID)
	local SequenceName = string.format("LCut_%d", SequenceID)
	local SequencePath = string.format("LevelSequence'%s/%s.%s'", DialogueSequenceSavePath, SequenceName, SequenceName)
	return SequencePath
end

---播放对白sequence
---@param SequenceID int32 对应对白表ID
---@param SequenceStopCallback function sequence播放停止回调
---@param SequencePauseCallback function sequence播放暂停回调
---@param SequenceFinishedCallback function sequence播放结束回调
---@param ReportFinishCallback function sequence某些任务需要通过事件提前上报Sequence结束，执行额外一些逻辑，此时Sequence并未真正结束
---@param PlaybackSettings luatable 播放参数配置，字段名可选：bRestoreState，bDisableMovementInput，bDisableLookAtInput，bPauseAtEnd
function StoryMgr:PlayDialogueSequence(SequenceID,
	SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings, ReportFinishCallback)

	if (not self:ShouldPlaySequence()) then
		return
	end

	if self:IsSequenceInSkipGroup(SequenceID, true) then
		self:DoSequenceSkipGroup(SequenceID, SequenceStopCallback)
		return
	end

	self.SequencePlayer = SequencePlayerBase.New()
	if (self.Reporter == nil) then
		self.Reporter = DialogueSequenceReporter.New()
	end

	if (self.Reporter) then
		self.Reporter:Init(SequenceID, 1, 0)
	end

	self.EventReportFinishCallback = ReportFinishCallback

	local SequencePath =  self:GetDialogueSequencePath(SequenceID)
	local SequenceCfg = SequenceCfgClass.New(SequencePath)
	SequenceCfg.SequenceID = SequenceID

	if self.CacheFuncOnPossessTarget ~= nil then
		SequenceCfg.OnPossessTarget = self.CacheFuncOnPossessTarget
	end

	self.Reporter:SetSequencePath(SequencePath)

	local bIsStoped = false
	local bIsSendBegin = false
	local function OnSequenceStoped()
		bIsStoped = true
		if (bIsSendBegin) then
			self:ReportSequenceFinished()
		end

		if (SequenceStopCallback) then
			SequenceStopCallback()
		end
	end

	_G.InteractiveMgr:StopMajorMoveForFixedTime(2)

	local FadeParamOnStop = {
		FadeOutTime = 1,
		FadeOutWhiteColor = false,
		IsBlackScreenAfterPlay = false,
	}

	self:DoPlaySequenceAfterFade(SequenceCfg, FadeParamOnStop,
		OnSequenceStoped, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)

	if (not bIsStoped) then
		if (self.Reporter) then
			self.Reporter:ReportSequenceBegin()
		end
		bIsSendBegin = true
	end
end

---获取关卡过场Sequence路径
---@param SequenceID int32 @关卡过场SequenceID
---@return string @关卡过场Sequence路径
function StoryMgr:GetCutSceneSequencePath(SequenceID)
	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
	if (PWorldDynDataMgr == nil) then
		return nil
	end

	local CutSceneSequence = PWorldDynDataMgr:GetCutSceneSequence(SequenceID)
	if (CutSceneSequence == nil) then
		CutSceneSequence = self:GetDynamicCutsceneCfgByID(SequenceID) --场景里没有配置，就从表格里读取
	end
	--找不到关卡过场Sequence
	if (CutSceneSequence == nil) then
		return nil
	end
	--设置跳过已阅览过的过场动画, 不会播放的Sequence也不返回路径
	if self.Setting.IsSkip(CutSceneSequence.ID) then
		return nil
	end
	return CutSceneSequence.SequencePath
end

---播放通过关卡配置的过场动画
---@param SequenceID int32 对应关卡过场Sequence
---@param SequenceStopCallback function sequence播放停止回调
---@param SequencePauseCallback function sequence播放暂停回调
---@param SequenceFinishedCallback function sequence播放结束回调
---@param ReportFinishCallback function sequence 某些任务需要通过事件提前上报Sequence结束，执行额外一些逻辑，此时Sequence并未真正结束
---@param PlaybackSettings luatable 播放参数配置，字段名可选：bRestoreState，bDisableMovementInput，bDisableLookAtInput，bPauseAtEnd
function StoryMgr:PlayCutSceneSequenceByID(SequenceID,
	SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings, ReportFinishCallback)

	if (not self:ShouldPlaySequence()) then
		return
	end

	if self:IsSequenceInSkipGroup(SequenceID, true) then
		self:DoSequenceSkipGroup(SequenceID, SequenceStopCallback)
		return
	end

	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
	if (PWorldDynDataMgr == nil) then return end

	local CutSceneSequence = PWorldDynDataMgr:GetCutSceneSequence(SequenceID)
	if (CutSceneSequence == nil) then
		CutSceneSequence = self:GetDynamicCutsceneCfgByID(SequenceID) --场景里没有配置，就从表格里读取

		if (CutSceneSequence == nil) then
			print("CutSceneSequence is nil! SequenceID=" .. tostring(SequenceID))
			return
		end
		CutSceneSequence.IsAutoPlay = false
	end

	self:PlayCutSceneSequence(CutSceneSequence,
		SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings, ReportFinishCallback)
end

---播放通过关卡配置的过场动画
function StoryMgr:PlayCutSceneSequence(CutSceneSequence,
	SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings, ReportFinishCallback)

	if (not self:ShouldPlaySequence()) then
		return
	end

	if (CutSceneSequence == nil) then
		print("CutSceneSequence is nil!")
		return
	end

	if (self.Reporter == nil) then
		self.Reporter = DialogueSequenceReporter.New()
	end

	if (self.Reporter) then
		self.Reporter:Init(CutSceneSequence.ID, 1, 0)
		self.Reporter:SetSequencePath(CutSceneSequence.SequencePath)
	end

	local bForbidSkip = false
	--需要判断队伍里是否有初见(新人，未通关过该副本)
	if (CutSceneSequence.bIsCanSkip and CutSceneSequence.CheckNewbieForSkip and _G.PWorldMgr:HasNewbieInTeam()) then
        bForbidSkip = true
    end

	--设置跳过已阅览过的过场动画,则终止（在sequencePlayer等初始化前终止）
	if not bForbidSkip and self.Setting.IsSkip(CutSceneSequence.ID) then
		self:ReportSequenceFinished()
		return
	end

	self.SequencePlayer = SequencePlayerBase.New()
	if PlaybackSettings then
		self.SequencePlayer:SetIsPlayNext(PlaybackSettings.bIsPlayNext)
	end

	self.EventReportFinishCallback = ReportFinishCallback

	local SequenceCfg = SequenceCfgClass.New(CutSceneSequence.SequencePath)
	SequenceCfg.SequenceID = CutSceneSequence.ID
	SequenceCfg.IsAutoPlay = CutSceneSequence.IsAutoPlay
	SequenceCfg.bIsCanSkip = CutSceneSequence.bIsCanSkip
	SequenceCfg.CheckNewbieForSkip = CutSceneSequence.CheckNewbieForSkip
	SequenceCfg.SceneCharacterShowType = CutSceneSequence.SceneCharacterShowType

	local bIsStoped = false
	local bIsSendBegin = false

	local function OnSequenceStoped()
		bIsStoped = true
		if (bIsSendBegin) then
			self:ReportSequenceFinished()
			if not SequenceCfg.bIsNcut --lcut没有EnableSkipStart轨道，避免出问题，先暂时不做判断。之后和策划沟通EnableSkipStart轨道导出规则
			or ( (self.SequencePlayer ~= nil) and self.SequencePlayer:HasEnableSkipStart() ) then
				self.Setting.SendBrowsedSetup(CutSceneSequence.ID)
			end
		end

		if (SequenceStopCallback) then
			SequenceStopCallback()
		end

		if (CutSceneSequence.IsResetFadeWhenStop) then
			_G.PWorldMgr:ResetFadeWhenSequenceStop()
		end

		--关卡开场动画播放结束
		if (CutSceneSequence.IsAutoPlay) then
			--如果过场动画切换了layerset，等恢复后再执行，避免出现loading过程中角色被怪物打死
			local bIsRestoreLayersetFinish = _G.PWorldMgr:IsRestoreLayersetFinish()
			if (bIsRestoreLayersetFinish) then
				_G.PWorldMgr:OnAutoPlaySequenceFinish()
			else
				if (self.MiscellaneousValue ~= nil) then
					self.MiscellaneousValue.bWaitRestoreLayerSetFinish = true
				end
			end
		end
	end

	_G.InteractiveMgr:StopMajorMoveForFixedTime(2)

	local FadeParamOnStop = {
		FadeOutTime = CutSceneSequence.FadeOutTime,
		FadeOutWhiteColor = CutSceneSequence.FadeOutWhiteColor,
		IsBlackScreenAfterPlay = CutSceneSequence.IsBlackScreenAfterPlay,
	}
	if FadeParamOnStop.FadeOutWhiteColor == 0 then
		FadeParamOnStop.FadeOutWhiteColor = false -- db数据转换
	end

	self:DoPlaySequenceAfterFade(SequenceCfg, FadeParamOnStop,
		OnSequenceStoped, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)
	-- self:DoPlaySequence(SequenceCfg,
	-- 	OnSequenceStoped, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)

	if (not bIsStoped) then
		if (self.Reporter) then
			self.Reporter:ReportSequenceBegin()
		end
		bIsSendBegin = true
	end
end

---sequence内部切换场景后调用重新播放sequence，(上报逻辑暂未加入)
function StoryMgr:ReplaySequenceAfterChangeMap(SequencePath, StartFrameNumber)

	if (not self:ShouldPlaySequence()) then
		return
	end

	self.SequencePlayer = SequencePlayerBase.New()

	local SequenceCfg = SequenceCfgClass.New(SequencePath)
	SequenceCfg.SceneCharacterShowType = ProtoRes.dialogue_scene_character_show_type.HIDE_ALL
	SequenceCfg.IsAutoPlay = true
	SequenceCfg.bUseSyncLoad = true
	SequenceCfg.StartFrameNumber = StartFrameNumber

	if (self.SequenceCacheInfoObj ~= nil) then
		SequenceCfg.SequenceID = self.SequenceCacheInfoObj.SequenceCfg.SequenceID
		SequenceCfg.IsAutoPlay = self.SequenceCacheInfoObj.SequenceCfg.IsAutoPlay
		SequenceCfg.SceneCharacterShowType = self.SequenceCacheInfoObj.SequenceCfg.SceneCharacterShowType
		SequenceCfg.bIsPlayMultiple = self.SequenceCacheInfoObj.SequenceCfg.bIsPlayMultiple
		SequenceCfg.CurrentSequence = self.SequenceCacheInfoObj.SequenceCfg.CurrentSequence
		SequenceCfg.ToTalSequence = self.SequenceCacheInfoObj.SequenceCfg.ToTalSequence
		local SequenceStopedCallback = self.SequenceCacheInfoObj.SequenceStopedCallback
		local SequencePauseCallback = self.SequenceCacheInfoObj.SequencePauseCallback
		local SequenceFinishedCallback = self.SequenceCacheInfoObj.SequenceFinishedCallback
		local PlaybackSettings = self.SequenceCacheInfoObj.PlaybackSettings
		if PlaybackSettings then
			self.SequencePlayer:SetIsPlayNext(PlaybackSettings.bIsPlayNext)
		end

		if (_G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM)) then
			--把GM的参数给重新用上
			if (self.SequenceCacheInfoObj.SequenceCfg.CacheGMStartFrameNumber ~= nil and self.SequenceCacheInfoObj.SequenceCfg.CacheGMStartFrameNumber > StartFrameNumber) then
				SequenceCfg.StartFrameNumber = self.SequenceCacheInfoObj.SequenceCfg.CacheGMStartFrameNumber
			end
		end

		self.SequenceCacheInfoObj = nil
		self:DoPlaySequence(SequenceCfg,
		SequenceStopedCallback,
		SequencePauseCallback,
		SequenceFinishedCallback,
		PlaybackSettings)
	else
		self:DoPlaySequence(SequenceCfg)
	end
	-- sequence里切关卡会导致主角linklayer失效
	local Major = MajorUtil.GetMajor()
	if Major then
		Major:UpdateLookAtLayer()
	end
end

function StoryMgr:PlaySequenceByPath(SequencePath, SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings, OtherParams)
	if (not self:ShouldPlaySequence()) then
		return
	end

	self.SequencePlayer = SequencePlayerBase.New()

	local SequenceCfg = SequenceCfgClass.New(SequencePath)
	SequenceCfg.SceneCharacterShowType = ProtoRes.dialogue_scene_character_show_type.HIDE_ALL
	SequenceCfg.bSkipLoadSubLevel = true

	if (OtherParams ~= nil) then
		if (OtherParams.bLoadSubLevel) then
			SequenceCfg.bSkipLoadSubLevel = false
		end

		if (OtherParams.SceneCharacterShowType) then
			SequenceCfg.SceneCharacterShowType = OtherParams.SceneCharacterShowType
		end

		if (OtherParams.NoSequenceDialog) then
			self.SequencePlayer.UIViewID = nil
		end

		if (OtherParams.StartFrameNumber) then
			SequenceCfg.StartFrameNumber = OtherParams.StartFrameNumber
			SequenceCfg.CacheGMStartFrameNumber = OtherParams.StartFrameNumber
		end
	end

	self:DoPlaySequence(SequenceCfg, SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)
end

function StoryMgr:PlayStaffRollSequence(SequencePath, SequenceStopCallback)
	if (not self:ShouldPlaySequence()) then
		return
	end

	self.SequencePlayer = SequencePlayerBase.New()
	self.SequencePlayer.UIViewID = _G.UIViewID.StaffRollMainPanel

	local SequenceCfg = SequenceCfgClass.New(SequencePath)
	SequenceCfg.bSkipLoadSubLevel = true

	self:DoPlaySequence(SequenceCfg, SequenceStopCallback)
end

function StoryMgr:PlayShowMovieSequence(SequencePath, SequenceStopCallback)
	if (not self:ShouldPlaySequence()) then
		return
	end

	self.SequencePlayer = SequencePlayerBase.New()
	self.SequencePlayer.UIViewID = nil

	local SequenceCfg = SequenceCfgClass.New(SequencePath)
	SequenceCfg.bSkipLoadSubLevel = true

	local PlaybackSettings = {
		bDisableMovementInput = true,
		bDisableLookAtInput = true,
		bPauseAtEnd = true,
	}
	self:DoPlaySequence(SequenceCfg, SequenceStopCallback, nil, nil, PlaybackSettings)
end

---播放多个过场动画
---@param SequencePathList 过场Sequence完整路径列表
---@param SequenceStopCallback 全部动画播完回调
---@param CurrentIndex 当前播放第几个cutscene
---@param SequenceStartPlayCallback 开始播放回调
function StoryMgr:PlayCutSceneSequenceByPathList(SequencePathList, SequenceStopCallback, CurrentIndex, SequenceStartPlayCallback)
	local ToTal = #SequencePathList
	if not CurrentIndex then
		CurrentIndex = 1
	end

	local FinishCallback = function()
		CurrentIndex = CurrentIndex + 1
		local InterruptMultiPlay = true
		if self.SequencePlayer then
			InterruptMultiPlay = self.SequencePlayer.bIsInterruptMultiPlay
		end

		self:ResetStatusAndCacheData()

		if CurrentIndex <= ToTal and not InterruptMultiPlay then
			local PlayNext = function()
				self:PlayCutSceneSequenceByPathList(SequencePathList, SequenceStopCallback, CurrentIndex, SequenceStartPlayCallback)
			end
			_G.LoadingMgr:ShowLoadingView(true, true)
			_G.TimerMgr:AddTimer(nil, PlayNext, 0.02) --StoryMgr上一个动画的数据未清理,延迟一帧播放
		else
			if SequenceStopCallback then
				SequenceStopCallback()
			end
		end
	end
	if SequenceStartPlayCallback then
		SequenceStartPlayCallback(CurrentIndex)
	end
	self:PlayMultipleCutSceneSequence(SequencePathList[CurrentIndex], FinishCallback, CurrentIndex, ToTal)
end

function StoryMgr:PlayMultipleCutSceneSequence(SequencePath, SequenceFinishedCallback, CurrentSequence, ToTalSequence)
	if (not self:ShouldPlaySequence()) then
		return
	end

	local SequenceID = tonumber(SequencePath)
	local CutSceneSequence = self:GetDynamicCutsceneCfgByID(SequenceID)
	if not CutSceneSequence then
		if SequenceFinishedCallback then
			SequenceFinishedCallback()
		end
		FLOG_ERROR("[StoryMgr] Sequence cant find, ID="..tostring(SequenceID))
		return
	end

	self.SequencePlayer = SequencePlayerBase.New()

	local CanPlayNext = CurrentSequence < ToTalSequence

	local SequenceCfg = SequenceCfgClass.New(CutSceneSequence.SequencePath)
	SequenceCfg.SequenceID = CutSceneSequence.ID
	SequenceCfg.IsAutoPlay = CutSceneSequence.IsAutoPlay
	SequenceCfg.bIsCanSkip = true
	SequenceCfg.SceneCharacterShowType = CutSceneSequence.SceneCharacterShowType
	SequenceCfg.bIsPlayMultiple = true -- 播放多个
	SequenceCfg.CurrentSequence = CurrentSequence
	SequenceCfg.ToTalSequence = ToTalSequence
	self.SequencePlayer:SetIsPlayNext(CanPlayNext)

	self:DoPlaySequence(SequenceCfg, SequenceFinishedCallback, nil, nil , {bIsPlayNext = CanPlayNext})
end

function StoryMgr:PlayChocoboSequence(SequenceID, SequenceStopCallback, StainID1, StainID2)
	-- ProcessMonsterPossessableActor里，possess actor后把染色id拿出来赋值给actor
	-- 要保证染色id队列顺序和sequence资源里possessable顺序相同，对于lcut则是传参顺序和脚本调用顺序相同
	local ChocoboStainList = {}
	if StainID1 ~= nil then
		table.insert(ChocoboStainList, StainID1)
		if StainID2 ~= nil then
			table.insert(ChocoboStainList, StainID2)
		end
	end

	self.CacheFuncOnPossessTarget = function(Target, ResID, _, ActorType)
        if not (Target ~= nil and ResID == 30001673
		and ChocoboStainList ~= nil and ActorType == _G.UE.EActorType.Npc) then
			return
        end
		local AvatarComp = Target:GetAvatarComponent()
		local AttrComp = Target:GetAttributeComponent()
		if AvatarComp == nil or AttrComp == nil then
			return
		end

		local StainID = ChocoboStainList[1] or 0
		AttrComp.SubType = _G.UE.EActorSubType.Buddy
		_G.UE.UVisionMgr.Get():RemoveFromVision(Target)
		AvatarComp:HandleAvatarEquip(1, ProtoCommon.equip_part.EQUIP_PART_LEG, -1, false, StainID, true)
		AvatarComp:HandleAvatarEquip(2, ProtoCommon.equip_part.EQUIP_PART_HEAD, -1, false, 0, true)
		AvatarComp:HandleAvatarEquip(3, ProtoCommon.equip_part.EQUIP_PART_BODY, -1, false, 0, true)
		AvatarComp:StartLoad(true)
		table.remove(ChocoboStainList, 1)
	end

	self:PlayDialogueSequence(SequenceID, SequenceStopCallback)

	self.CacheFuncOnPossessTarget = nil
end

function StoryMgr:DoPlaySequenceAfterFade(SequenceCfg, FadeParamOnStop,
	SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)

	local FadeViewID = UIViewID.CommonFadePanel
	local bFadeViewVisible = UIViewMgr:IsViewVisible(FadeViewID)
	local bLoadingViewVisible = _G.LoadingMgr:IsLoadingView()

	if not (bFadeViewVisible or bLoadingViewVisible) then
		local Params = {}
		Params.FadeColorType = 3
		Params.Duration = 1
		Params.bAutoHide = false
		UIViewMgr:ShowView(FadeViewID, Params)
	end

	local StopCallbackWithFade = function()
		SequenceStopCallback()

		if UIViewMgr:IsViewVisible(FadeViewID) then
			UIViewMgr:HideView(FadeViewID) -- 兜底保证界面隐藏
			return
		end

		if FadeParamOnStop.FadeOutTime == nil or FadeParamOnStop.FadeOutTime <= 0 then -- 兼容关卡过场设置
			return
		end

		local Params = {}
		Params.Duration = FadeParamOnStop.FadeOutTime

		local bShortBlackScreenWhenSkip = false
		local bQuestNeedBlackScreen = _G.QuestMgr:IsBlackScreenOnStopDialogOrSeq(SequenceCfg.SequenceID)
		if self.SequencePlayer and self.SequencePlayer.bClickButtonSkip then
			local bWaitingTeleport = _G.QuestMgr:IsTeleportAfterSequence(SequenceCfg.SequenceID)
			bShortBlackScreenWhenSkip = self.bStayOriginalMap and bQuestNeedBlackScreen and (not bWaitingTeleport)
		end

		local bLongBlackScreen = (not bShortBlackScreenWhenSkip)
			and (FadeParamOnStop.IsBlackScreenAfterPlay or bQuestNeedBlackScreen)

		if bLongBlackScreen then
			Params.FadeColorType = nil
			Params.bAutoHide = false -- 切地图会自动清理UI
		else
			Params.FadeColorType = not FadeParamOnStop.FadeOutWhiteColor and 1 or 0
		end

		UIViewMgr:ShowView(FadeViewID, Params)
	end

	if bLoadingViewVisible then
		self:DoPlaySequence(SequenceCfg,
			StopCallbackWithFade, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)
	else
		_G.TimerMgr:AddTimer(nil, function()
			self:DoPlaySequence(SequenceCfg,
				StopCallbackWithFade, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)
		end, 1, nil, nil, nil, "DoPlaySequenceAfterFade")
	end
end

function StoryMgr:DoPlaySequence(SequenceCfg,
	SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)
	--_G.TRACE_CPUPROFILER_EVENT_SCOPE("DoPlaySequence")
	if (self.SequencePlayer ~= nil) and (SequenceCfg ~= nil) then
		local SequenceID = SequenceCfg.SequenceID
		self.SequenceID = SequenceID
		_G.NpcDialogMgr:PreEndInteraction()
		self:UpdatePlayingStatus(true, SequenceID)
		--这个函数始终都会执行
		local function OnSequenceStoped(bPlaySuccess)
			self.SequenceID = nil
			self:UpdatePlayingStatus(false, SequenceID)
			-- 需要提前记录一下，StopCallback的时候有可能把数据清掉了
			local bIsSequenceWaitingToChangeMap = self:IsSequenceWaitingToChangeMap()
			if (SequenceStopCallback ~= nil) then
			    SequenceStopCallback()
		    end

			if (self.EnterVisionActors) then
				for EntityID, _ in pairs(self.EnterVisionActors) do
					ActorManager:Get():HideActor(EntityID, false)
				end

				self.EnterVisionActors = nil
			end

			-- local ActorMgr = require("Game/Actor/ActorMgr")
			-- ActorMgr:ForceShowNearbyNpcs(600)
			_G.UE.UVisionMgr.Get():CheckActorVisibility()

			if (self.UpdateVMTimerID ~= nil) then
				self:UnRegisterTimer(self.UpdateVMTimerID)
				self.UpdateVMTimerID = nil
			end

			self:DoUnRegisterGameEvent()
			_G.StorySubLevelLoader:DestroySublevelLoader()

			--没有播放成功 或者 手动停止了sequence
			if (not bPlaySuccess or (self.SequencePlayer ~= nil and self.SequencePlayer.ManualStopSequence)) then
				self:DestroySequencePlayer(true)
			end

			--没有播放成功，调用一次关闭loading
			if (not bPlaySuccess and _G.LoadingMgr:IsLoadingView()) then
				_G.LoadingMgr:HideLoadingView()
			elseif bPlaySuccess and bIsSequenceWaitingToChangeMap then
				self:ShowLoadingAfterSequence()
			end

			--FLOG_INFO("[LoadWorld cost time record] PlaySequence: OnSequenceStoped bPlaySuccess=%s", tostring(bPlaySuccess))
		end

		local function OnSequenceFinished()
			self:UpdatePlayingStatus(false, SequenceID)
			--bPauseAtEnd 为true的时候  会执行到Finish而不会执行到Stop，否则两个函数都会执行到
			if (PlaybackSettings and PlaybackSettings.bPauseAtEnd == true) then
				OnSequenceStoped(true)
				return
			end

			if (SequenceFinishedCallback ~= nil) then
				SequenceFinishedCallback()
			end
			self:DestroySequencePlayer(true)
			--FLOG_INFO("[LoadWorld cost time record] PlaySequence: OnSequenceFinished")
		end

		local SequencePath = SequenceCfg.SequencePath
		if (SequencePath == nil or SequencePath == "") then
			OnSequenceStoped()
			return
		end

		SequenceCfg.bIsNcut = (nil == string.find(SequencePath, "LCut_")) -- lcut名称固定格式
		if not SequenceCfg.bIsNcut then
			local List = StoryDefine.LcutWithNcutList
			for _, IDStr in ipairs(List) do
				if string.find(SequencePath, IDStr) then
					SequenceCfg.bIsNcut = true

					--Luct作为Ncut播放，本地NPC需要隐藏						
					SequenceCfg.SceneCharacterShowType = ProtoRes.dialogue_scene_character_show_type.HIDE_ALL
					break
				end
			end
		end		

		local CurrTime = _G.TimeUtil.GetServerTime()
		FLOG_INFO("[LoadWorld cost time record] PlaySequence: %s, CurrTime: %d", SequencePath, CurrTime)

		local SequenceActor = self.SequencePlayer:CreateSequenceActor()
		if (SequenceActor == nil) then
			OnSequenceStoped()
			return
		end

		self.OuterStopCallbackWhenException = OnSequenceStoped

		local function ExecPlaySequence(SequenceObject)
			SequenceCfg.SequenceObject = SequenceObject
			self.UpdateVMTimerID = self:RegisterTimer(self.OnTimer, 0, 0.05, 0) -- 对话框滚动出字时间50ms

			if (self.MiscellaneousValue ~= nil) then
				self.MiscellaneousValue.bWaitRestoreLayerSetFinish = false
			end
			
			if (not self.SequencePlayer) then
				OnSequenceStoped()
				return
			end
			self.MajorEntityID = MajorUtil.GetMajorEntityID()
			self:DoRegisterGameEvent()

			-- 取消选中，避免sequence内出现选中贴花
			-- 后续如有需要也可换成c++隐藏贴花
			_G.InteractiveMgr:CancelTargetInteractive()
			-- 播放Sequence的时候先强制下坐骑
			if _G.MountMgr:IsInRide() then
				_G.MountMgr:ForceSendMountCancelCall()
			end

			local CutsceneCfg = self:GetDynamicCutsceneCfgByPath(SequencePath)
			local bSkipLoadLayerSet = false
			local bSkipLoadStreamingLevel = false
			local bSkipWaitAvatarLoadFinish = false
			if (CutsceneCfg ~= nil) then
				bSkipLoadLayerSet = CutsceneCfg.ForbidLoadLayerSet ~= nil and CutsceneCfg.ForbidLoadLayerSet > 0 or false
				bSkipLoadStreamingLevel = CutsceneCfg.ForbidLoadLevelStreaming ~= nil and CutsceneCfg.ForbidLoadLevelStreaming > 0 or false
				bSkipWaitAvatarLoadFinish =CutsceneCfg.ForbidWaitAvatarLoadFinish ~= nil and CutsceneCfg.ForbidWaitAvatarLoadFinish > 0 or false
			end

			local bIsNeedChangeMap = false
			local StoryMgrInstance = _G.UE.UStoryMgr:Get()
			if (StoryMgrInstance ~= nil) then
				local ChangeMapInfo = StoryMgrInstance:GetChangeMapInfo(SequenceObject)
				--做个优化：如果在Sequence开始的时候（第0帧）就需要切地图，直接模拟BgSetup轨道切地图，不走后续sequence初始化流程
				if (ChangeMapInfo.bExecuteImmediately and ChangeMapInfo.MapPath ~= "") then
					self.SequenceCacheInfoObj = SequenceCacheInfo.New()
					self.SequenceCacheInfoObj.SequenceCfg = SequenceCfg
					self.SequenceCacheInfoObj.SequenceStopedCallback = SequenceStopCallback
					self.SequenceCacheInfoObj.SequencePauseCallback = SequencePauseCallback
					self.SequenceCacheInfoObj.SequenceFinishedCallback = SequenceFinishedCallback
					self.SequenceCacheInfoObj.PlaybackSettings = PlaybackSettings
					StoryMgrInstance:SetCurrentSkipInfo(bSkipLoadLayerSet, bSkipLoadStreamingLevel)
					local bSuccess = StoryMgrInstance:ChangeMapSimulationBgSetup(SequencePath, ChangeMapInfo.MapPath, ChangeMapInfo.Layerset)
					if (bSuccess) then
						self:DoUnRegisterGameEvent() --切换地图会重复注册，这里先反注册
						_G.LoadingMgr:ShowLoadingView(true, true)
					else
						FLOG_INFO("[LoadWorld cost time record]Simulation BgSetupTrack ChangeMapfailed!!!")
						OnSequenceStoped() --出异常了，直接结束算了
					end

					return
				end

				bIsNeedChangeMap = ChangeMapInfo.bChangeMap
			end

			local function OnAllSublevelLoaded()
				if (self.SequencePlayer and self.SequenceCacheInfoObj) then
					local SequenceCfgTemp = self.SequenceCacheInfoObj.SequenceCfg
					local SequenceStopedCallbackTemp = self.SequenceCacheInfoObj.SequenceStopedCallback
					local SequencePauseCallbackTemp = self.SequenceCacheInfoObj.SequencePauseCallback
					local SequenceFinishedCallbackTemp = self.SequenceCacheInfoObj.SequenceFinishedCallback
					local PlaybackSettingsTemp = self.SequenceCacheInfoObj.PlaybackSettings
					if self.SequenceContinuousInfoCache ~= nil then
						self.SequenceContinuousInfoCache:OnSequencePlay(SequenceID)
					end
					self.SequencePlayer:PlaySequence(SequenceCfgTemp, SequenceStopedCallbackTemp, SequencePauseCallbackTemp,
					SequenceFinishedCallbackTemp, PlaybackSettingsTemp)

					if not bIsNeedChangeMap then
						self.SequenceCacheInfoObj = nil
					end
				end
			end

			SequenceCfg.bSkipLoadLayerSet = bSkipLoadLayerSet
			SequenceCfg.bSkipLoadStreamingLevel = bSkipLoadStreamingLevel
			SequenceCfg.bSkipWaitAvatarLoadFinish = bSkipWaitAvatarLoadFinish

			local bLCutSkipLoadSubLevel = not SequenceCfg.bIsNcut
			if self.bGMLoadSubLevel then
				bLCutSkipLoadSubLevel = false
				self.bGMLoadSubLevel = nil
			end

			local bNeedLoadSubLevel = false
			--这里只加载LevelStreamingVolume配置的子level，Layerset不加载(影响副本中autoplay的Sequence表现)，放到各自的轨道里执行
			if (not SequenceCfg.IsAutoPlay and not bIsNeedChangeMap and not SequenceCfg.bSkipLoadSubLevel and not bLCutSkipLoadSubLevel) then
				
				local bLoadAllSubLevels = true --默认加载所有子level，叙事策划不想用关卡编辑器来配置, 统一通过表格控制某些Sequence不加载所有子level
				if (CutsceneCfg ~= nil) then
					bLoadAllSubLevels = CutsceneCfg.LoadAllSubLevels ~= nil and CutsceneCfg.LoadAllSubLevels > 0 or false
				end

				bNeedLoadSubLevel = _G.StorySubLevelLoader:LoadSublevels(SequenceObject, bLoadAllSubLevels, bSkipLoadStreamingLevel, OnAllSublevelLoaded)
			end

			self.SequenceCacheInfoObj = nil
			if (not bNeedLoadSubLevel) then
				--sequence内部需要切换地图，缓存配置数据
				if (bIsNeedChangeMap) then
					self.SequenceCacheInfoObj = SequenceCacheInfo.New()
					self.SequenceCacheInfoObj.SequenceCfg = SequenceCfg
					self.SequenceCacheInfoObj.SequenceStopedCallback = SequenceStopCallback
					self.SequenceCacheInfoObj.SequencePauseCallback = SequencePauseCallback
					self.SequenceCacheInfoObj.SequenceFinishedCallback = SequenceFinishedCallback
					self.SequenceCacheInfoObj.PlaybackSettings = PlaybackSettings
				end
				if self.SequenceContinuousInfoCache ~= nil then
					self.SequenceContinuousInfoCache:OnSequencePlay(SequenceID)
				end
				self.SequencePlayer:PlaySequence(SequenceCfg,
					OnSequenceStoped, SequencePauseCallback, OnSequenceFinished, PlaybackSettings)
			else
				self.SequenceCacheInfoObj = SequenceCacheInfo.New()
				self.SequenceCacheInfoObj.SequenceCfg = SequenceCfg
				self.SequenceCacheInfoObj.SequenceStopedCallback = OnSequenceStoped
				self.SequenceCacheInfoObj.SequencePauseCallback = SequencePauseCallback
				self.SequenceCacheInfoObj.SequenceFinishedCallback = OnSequenceFinished
				self.SequenceCacheInfoObj.PlaybackSettings = PlaybackSettings

				_G.LoadingMgr:ShowLoadingView(true, true)
			end
		end

		--levelsequence全部走动态加载的方式
		if (SequenceCfg.bUseSyncLoad) then
			local SequenceObject = _G.ObjectMgr:LoadObjectSync(SequencePath, ObjectGCType.LRU)
			ExecPlaySequence(SequenceObject)
		else
			local function OnLoadSequenceComplete()
				self.bIsLoadingSequence = false
				local SequenceObject = _G.ObjectMgr:GetObject(SequencePath)
				ExecPlaySequence(SequenceObject)
			end

			local function OnLoadSequenceFailed()
				self.bIsLoadingSequence = false
				OnSequenceStoped()
			end

			self.bIsLoadingSequence = true
			_G.ObjectMgr:LoadObjectAsync(SequencePath, OnLoadSequenceComplete, ObjectGCType.LRU, OnLoadSequenceFailed)
		end
	end
end

--通过sequence中配置的Event Trigger调用
function StoryMgr:ReportSequenceFinished()
	if (self.Reporter) then
		self.Reporter:ReportSequenceFinished()
	end
end

function StoryMgr.ReportSequenceFinishedForBP()
	local SeqMgr = StoryMgr

	SeqMgr:ReportSequenceFinished()

	if SeqMgr.EventReportFinishCallback then
		SeqMgr.EventReportFinishCallback()
		SeqMgr.EventReportFinishCallback = nil
	end
end

 --跟pause区别，play后时间会进行跳转，不会从暂停的时间点开始播(LastTickGameTimeSeconds值不会重置)
 function StoryMgr:ScrubSequence()
	if (self.SequencePlayer ~= nil) then
        self.SequencePlayer:ScrubSequence()
    end
end

function StoryMgr:PauseSequence(bDelay)
	if (self.SequencePlayer ~= nil) then
		if (bDelay) then
			--如果UMovieSceneSequencePlayer中的bIsEvaluating为true，会导致pause会延迟处理，LastTickGameTimeSeconds的值在Update中会被重新赋值
			--重新play后会Jump到最新时间位置，而不是之前pause的位置，所以这里不在bIsEvaluating为true时直接调用Pause，而是等当前帧tick结束后再执行
			self.SequencePlayer:AddLatentAction(_G.UE.EStoryLatentAction.Pause)
		else
			self.SequencePlayer:PauseSequence()
		end
    end
end

function StoryMgr:ContinueSequence()
	if (self.SequencePlayer ~= nil) then
		--先执行play，再执行PlayToSeconds，确保UCustomLevelSequencePlayer的PlayerStatus跟UMovieSceneSequencePlayer::IsPlaying()一致（TearDown->SafeResetPlayerStatus函数会重置PlayerStatus）,否则AdjustCharactersPostion不会执行导致某帧坠地。
		self.SequencePlayer:ContinueSequence()

		--在对白开头暂停Sequence，点击继续的时候关闭UI，不跳帧
		if (self.bTouchWaitInSectionBegin) then
			SequencePlayerVM:OnEndDialogueSentence()
		else
			--点击继续的时候，跳到最末帧，一般用于lcut的情况，一句句连续显示文本
			if (self.CurrDialogueEndTime ~= nil and self.CurrDialogueEndTime > 0) then
				FLOG_INFO("Dialogue PlayToSeconds %.1f", self.CurrDialogueEndTime) -- 辅助排查异常跳转问题 https://tapd.woa.com/tapd_fe/20420083/bug/detail/1020420083141053715
				self.SequencePlayer:PlayToSeconds(self.CurrDialogueEndTime)
				-- 这一步之后，c++ SequenceActor没有tick，导致这一帧贴地表现异常（PIE单帧步进可见）。需要主动贴地
				if (self.SequencePlayer ~= nil) then -- PlayToSeconds到sequence末尾可能把sequence停了，导致SequencePlayer==nil
					self.SequencePlayer:AdjustCharactersPostion()
				end
			end
		end
    end
end

--手动跳过sequence
function StoryMgr:StopSequence(bClickButtonSkip)
    if (self.SequencePlayer ~= nil) then
		if (self.Reporter) then
			self.Reporter:SetStopFlag(1)
		end

        self.SequencePlayer:StopSequence(bClickButtonSkip)
	else
		--出现了异常，把劇情UI关闭
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.DialogueMainPanel) then
            UIViewMgr:HideView(UIViewID.DialogueMainPanel)
        end
    end
end


function StoryMgr:ResetStatusAndCacheData()
	local StoryMgrInstance = _G.UE.UStoryMgr:Get()
	if StoryMgrInstance then
		StoryMgrInstance:UpdatePlayingStatus(false)
		StoryMgrInstance:ResetCacheData()
	end
end

--异常停止
function StoryMgr:StopSequenceInException()
    if (self.SequencePlayer ~= nil) then
		FLOG_INFO("[LoadWorld cost time record] PlaySequence: StopSequenceInException!!!")
		self.SequencePlayer:StopSequenceInException()
    end
	local Callback = self.OuterStopCallbackWhenException
	if self:SequenceIsPlaying() and Callback ~= nil then
		Callback(false)
	end

	self:ResetStatusAndCacheData()
end

function StoryMgr:DestroySequencePlayer(bClearSequenceCacheInfo)
	if (self.SequencePlayer ~= nil) then
		self.SequencePlayer:Destroy()
		self.SequencePlayer = nil
    end
	self.OuterStopCallbackWhenException = nil

	if (bClearSequenceCacheInfo) then
		self.SequenceCacheInfoObj = nil
	end
end

function StoryMgr:UpdateDialogueTopWidget(SkipType, FadeColorType, bCanSkip)
	if (self.SequencePlayer ~= nil) then
        self.SequencePlayer:UpdateDialogueTopWidget(SkipType, FadeColorType, bCanSkip)
    end
end

--当前正在播放sequence
function StoryMgr:SequenceIsPlaying()
	return self.bIsPlaying
end

function StoryMgr:GetCurrentSequenceID()
	return self.SequenceID
end

function StoryMgr:PlayCGMovie(MovieName)
	if UIViewMgr:IsViewVisible(UIViewID.CGMovieMainPanel) then
		return
	end
	self.bIsCGMoviePlaying = true
	self.CGMovieNameCache = MovieName
	UIViewMgr:ShowView(UIViewID.CGMovieMainPanel, { MovieName = MovieName })
end

function StoryMgr:StopCGMovie()
	self.bIsCGMoviePlaying = false
	self.CGMovieNameCache = nil
	self.CGMoviePlayTime = 0
	if UIViewMgr:IsViewVisible(UIViewID.CGMovieMainPanel) then
		UIViewMgr:HideView(UIViewID.CGMovieMainPanel)
	end
end

function StoryMgr:IsCGMoviePlaying()
	return self.bIsCGMoviePlaying
end

function StoryMgr:CacheCGMoviePlayTime(MediaPlayTime)
	self.CGMoviePlayTime = MediaPlayTime
end

function StoryMgr:UpdatePlayingStatus(IsPlaying, InSequenceID)
	self.bIsPlaying = IsPlaying

	 local StoryMgrInstance = _G.UE.UStoryMgr:Get()
	 if (StoryMgrInstance) then
		StoryMgrInstance:UpdatePlayingStatus(IsPlaying)
	 end

	 if (IsPlaying) then
		_G.EventMgr:SendCppEvent(_G.EventID.BeginPlaySequence)
		_G.EventMgr:SendEvent(_G.EventID.BeginPlaySequence, { SequenceID = InSequenceID })
	 else
		_G.EventMgr:SendCppEvent(_G.EventID.EndPlaySequence)
		_G.EventMgr:SendEvent(_G.EventID.EndPlaySequence, { SequenceID = InSequenceID })
	 end

	 EffectUtil.UpdateInDialogOrSeq()
end

--sequence正在播放中，用来区分是否pause或者scrub
function StoryMgr:SequenceIsPlayingStatus()
	return self.SequencePlayer ~= nil and self.SequencePlayer:IsPlayingStatus()
end

--按键等待状态下会暂停Sequence
function StoryMgr:SequenceIsPausedStatus()
	return self.SequencePlayer ~= nil and self.SequencePlayer:IsPausedStatus()
end

--sequence资源正在加载中
--角色资源加载，子level加载
function StoryMgr:SequenceIsLoading()
	if (self.SequencePlayer == nil and self.SequenceCacheInfoObj ~= nil) then
		--Sequence内部切换地图的时候会重新创建SequencePlayer，参考PWorldMgr:ChangeMapForCutScene
		return true

	elseif (self.SequencePlayer ~= nil and (self.SequencePlayer:IsWaitAvatarsToAssemble() or self.SequenceCacheInfoObj ~= nil)) then
		return true
	elseif self.bIsLoadingSequence == true then
		-- 在加载sequence本身的资源
		return true
	end

	return false
end

function StoryMgr.UpdateActorTransformInSeq(EntityID, NewLocation, NewQuat)
	local self = StoryMgr
	if (self.SequencePlayer ~= nil) then
		local Actor = ActorUtil.GetActorByEntityID(EntityID)
		if Actor then
			-- 传过来的是服务器同步的数据，需要加上胶囊体高度
			local Character = Actor:Cast(_G.UE.ABaseCharacter)
			if Character then
				NewLocation.Z = NewLocation.Z + Character:GetCapsuleHalfHeight()
			end
		end
		local NewTransform = _G.UE.FTransform(NewQuat, NewLocation)
		self:UpdateVisionActorTransform(EntityID, NewTransform)
	end
end

function StoryMgr.SequenceIsPlayingTest()
	return StoryMgr.SequencePlayer ~= nil
end

function StoryMgr:GetSceneCharacterShowType()
	if (self.SequencePlayer ~= nil) then
		return self.SequencePlayer:GetSceneCharacterShowType()
	end
	return 0
end

--LCut和NCut在某些时候需要逻辑区分
function StoryMgr:CurrentPlayingIsNCut()
	if (self.SequencePlayer ~= nil) then
		return self.SequencePlayer:CurrentPlayingIsNCut()
	end
	return false
end

---@param CppMenuInfo _G.UE.FMenuSetupInfo
function StoryMgr:OpenMenuInSeq(CppMenuInfo)
	if (self.SequencePlayer == nil) then return end
	local MenuInfo = {
		Message = "",
		Choices = {},
		DialogueBranchID = 0,
	}

	local MessageCfg = ScenarioTextCfg:FindCfgByTextKey(CppMenuInfo.MessageKey)
	if (MessageCfg ~= nil) then
		MenuInfo.Message = MessageCfg.Content
	end

	local ChoiceKeys = CppMenuInfo.ChoiceKeys
	for i = 1, ChoiceKeys:Length() do
		local ChoiceKey = ChoiceKeys:Get(i)
		local ChoiceCfg = ScenarioTextCfg:FindCfgByTextKey(ChoiceKey)
		local ChoiceContent = ""
		if (ChoiceCfg ~= nil) then
			ChoiceContent = ChoiceCfg.Content
		end
		table.insert(MenuInfo.Choices, ChoiceContent)
	end

	MenuInfo.DialogueBranchID = CppMenuInfo.DialogueBranchID

	SequencePlayerVM:OpenMenu(MenuInfo)
end

---@return number
function StoryMgr.GetMenuChoiceIndex()
	return SequencePlayerVM:GetMenuChoiceIndex()
end

---@param Index number
function StoryMgr.ChooseMenuChoice(Index)
	SequencePlayerVM:ChooseMenuChoice(Index)
end

function StoryMgr:HasCachedVisionActorTransform(Target)
	if (Target == nil) then
		return true
	end

	if (self.CachedVisionActorTransforms ~= nil) then
		local AttributeComp = Target:GetAttributeComponent()
		if (AttributeComp ~= nil and self.CachedVisionActorTransforms[AttributeComp.EntityID] ~= nil) then
			return true
		end
	end

	return false
end

--缓存视野里Actor的Transform信息，sequence结束后恢复
function StoryMgr:CacheVisionActorTransform(Target)
	if (Target == nil) then
		return
	end

	if (self.CachedVisionActorTransforms == nil) then
		self.CachedVisionActorTransforms = {}
	end

	local AttributeComp = Target:GetAttributeComponent()
	if (AttributeComp ~= nil) then
		local TargetTransform = Target:FGetActorTransform()
		--local Pos = TargetTransform:GetLocation()
		--print("CacheVisionActorTransform: " .. tostring(AttributeComp.EntityID) .. " " .. Pos.X .. " " .. Pos.Y .. " " .. Pos.Z)
		self.CachedVisionActorTransforms[AttributeComp.EntityID] = TargetTransform
	end
end

--重置actor坐标播放sequence之前的初始状态
function StoryMgr:RestoreVisionActorsTransform()
	if (self.CachedVisionActorTransforms ~= nil) then
        for EntityID, Transform in pairs(self.CachedVisionActorTransforms) do
            local Actor = ActorUtil.GetActorByEntityID(EntityID)
            if (Actor ~= nil) then
				--不贴地，原样还原，防止在狭小的空间播放ncut改变角色Z坐标
                Actor:FSetActorTransform(Transform, false, false) -- 这里不会贴地
            end
        end
        self.CachedVisionActorTransforms = nil
    end
end

function StoryMgr:RestoreVisionActorsTransformWithCheck()
	if self.CachedVisionActorTransforms == nil then
		return true
	end
	local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
	local RemainCacheCnt = 0
	_G.FLOG_INFO("[StoryMgr:RestoreVisionActorsTransformWithCheck]CachedVisionActorTransforms Num %d", table.length(self.CachedVisionActorTransforms))
	for EntityID, Transform in pairs(self.CachedVisionActorTransforms) do
		local Actor = ActorUtil.GetActorByEntityID(EntityID)
		if (Actor ~= nil) then
			-- 只检测一下主角的
			local bCanSetTransform = (Actor:GetActorType() ~= EActorType.Major) or
				UMoveSyncMgr:CheckActorFindFloor(Actor, Transform, true)
			if bCanSetTransform then
				Actor:FSetActorTransform(Transform, false, false) -- 这里不会贴地
			else
				RemainCacheCnt = RemainCacheCnt + 1
			end
		end
	end
	if RemainCacheCnt > 0 then
		_G.FLOG_INFO("[StoryMgr:RestoreVisionActorsTransformWithCheck]RemainCacheCnt=%d", RemainCacheCnt)
		return false
	else
		self.CachedVisionActorTransforms = nil
		return true
	end
end

--sequence播放过场中，移动同步更新transform信息
function StoryMgr:UpdateVisionActorTransform(EntityID, NewTransform)
    if (self.CachedVisionActorTransforms ~= nil) then
        if (self.CachedVisionActorTransforms[EntityID] ~= nil) then
            self.CachedVisionActorTransforms[EntityID] = NewTransform
        end
    end
end

--sequence播放过场中，模型胶囊体调整完成后更新Scale和Z轴信息
function StoryMgr:UpdateVisionActorScaleAndZPos(EntityID, AdjustZ, Scale)
    if (self.CachedVisionActorTransforms == nil) then
        return
    end
    local Transform = self.CachedVisionActorTransforms[EntityID]
    if (Transform == nil) then
        return
    end

    if (Scale > 0.0 or AdjustZ > 0) then
        Transform:SetScale3D(_G.UE.FVector(Scale, Scale, Scale))
        local OriginLocation = Transform:GetLocation()
        OriginLocation.Z = OriginLocation.Z + AdjustZ
        Transform:SetLocation(OriginLocation)
        self.CachedVisionActorTransforms[EntityID] = Transform
    end
end

-- ---------------------------------------------------- --------------------------------------------------
-- 片尾动画
-- ---------------------------------------------------- --------------------------------------------------

function StoryMgr:BeginStaffRollPlay()
	if (self.SequencePlayer ~= nil) then
		self.SequencePlayer:ShowStaffRoll()
	end
end

function StoryMgr:EndStaffRollPlay()
    if (self.SequencePlayer ~= nil) then
		self.SequencePlayer:HideStaffRoll()
	end
end

function StoryMgr.ShowStaffRollImage(Image)
	SequencePlayerVM:ShowStaffRollImage(Image)
end

function StoryMgr.HideStaffRollImage(Image)
	SequencePlayerVM:HideStaffRollImage(Image)
end

function StoryMgr.ShowStaffScroll(StaffTable, ScrollTime)
	SequencePlayerVM:ShowStaffScroll(StaffTable, ScrollTime)
end
-- ---------------------------------------------------- --------------------------------------------------

---播放独立的Sequence，不走StoryMgr流程
function StoryMgr:PlayIndependentSequenceByPath(SequencePath)
	local StoryMgrInstance = _G.UE.UStoryMgr:Get()
	if (StoryMgrInstance ~= nil) then

		local function OnLoadSequenceComplete()
			local SequenceObject = _G.ObjectMgr:GetObject(SequencePath)
			self.SequenceActor = StoryMgrInstance:CreateSequenceActor()
			if (SequenceObject and self.SequenceActor
				and _G.CommonUtil.IsObjectValid(self.SequenceActor)) then
				self.SequenceActor:SetSequence(SequenceObject)
				self.SequenceActor:Play()
			end
		end

		_G.ObjectMgr:LoadObjectAsync(SequencePath, OnLoadSequenceComplete, ObjectGCType.NoCache)

	end
end

function StoryMgr:GetDynamicCutsceneCfgByPath(SequencePath)
	local CutsceneCfg = nil
	if (SequencePath ~= nil and SequencePath ~= "") then
		if SequencePath:sub(1,1) == '/' then
			SequencePath = string.format("LevelSequence'%s'", SequencePath)
		end

		CutsceneCfg = DynamicCutsceneCfg:FindCfg(string.format("SequencePath = \"%s\"", SequencePath))
	end
	return CutsceneCfg
end

function StoryMgr:GetDynamicCutsceneCfgByID(SequenceID)
	local CutsceneCfg = nil
	if (SequenceID ~= nil and SequenceID > 0) then
		CutsceneCfg = DynamicCutsceneCfg:FindCfgByKey(SequenceID)
	end
	return CutsceneCfg
end

--根据文本长度计算口型动画时长
function StoryMgr:GetCurrentDialogueContentDuration()
    if (self.SequencePlayer ~= nil) then
		return self.SequencePlayer:GetCurrentDialogueContentDuration()
	end
	return 0.0
end

--自动播放的时候，需要用这个值计算对白界面停留的时间
function StoryMgr:UpdateDialogueAudioDuration(CurrentAudioDuration)
    if (self.SequencePlayer ~= nil) then
		self.SequencePlayer:UpdateDialogueAudioDuration(CurrentAudioDuration)
	end
end

function StoryMgr:RegisterWaitingSequenceWithChangeMap(PreSequenceID, SequenceID)
	-- 需要提供连续播放的SequenceID, 用来进行校验
	if PreSequenceID == nil or SequenceID == nil then
		return
	end
	if self.SequenceContinuousInfoCache == nil then
		self.SequenceContinuousInfoCache = SequenceContinuousInfo.New()
	end
	local PreSequenceIDCache = self.SequenceContinuousInfoCache.PreSequenceID
	local NextSequenceIDCache = self.SequenceContinuousInfoCache.NextSequenceID
	if PreSequenceIDCache == PreSequenceID and NextSequenceIDCache == SequenceID then
		-- 忽略重复记录
		return
	end
	if self.bIsPlaying then
		local CurrentSequenceID = self:GetCurrentSequenceID()
		if CurrentSequenceID ~= PreSequenceID then
			-- 当前正在播放的SequenceID和记录的PreSequenceID不一致
			return
		end
	end
	_G.FLOG_INFO("[StoryMgr:Register]PreSequenceID=%d, NextSequenceID=%d", PreSequenceID, SequenceID)
	self.SequenceContinuousInfoCache.PreSequenceID = PreSequenceID
	self.SequenceContinuousInfoCache.NextSequenceID = SequenceID
	self.SequenceContinuousInfoCache.IsSequencePlaying = self.bIsPlaying
end

function StoryMgr:UnRegisterWaitingSequenceWithChangeMap(SequenceID)
	if self.SequenceContinuousInfoCache == nil then
		return
	end
	local PreSequenceIDCache = self.SequenceContinuousInfoCache.PreSequenceID
	local NextSequenceIDCache = self.SequenceContinuousInfoCache.NextSequenceID
	if PreSequenceIDCache == nil or NextSequenceIDCache == nil then
		return
	end
	_G.FLOG_INFO("[StoryMgr:UnRegister]PreSequenceIDCache=%d, NextSequenceIDCache=%d, SequenceID=%d",
	PreSequenceIDCache, NextSequenceIDCache, SequenceID)
	self:ClearWaitingSequenceCache()
end

function StoryMgr:ClearWaitingSequenceCache()
	if self.SequenceContinuousInfoCache == nil then
		return
	end
	_G.FLOG_INFO("[StoryMgr:ClearWaitingSequenceCache]")
	self.SequenceContinuousInfoCache.PreSequenceID = nil
	self.SequenceContinuousInfoCache.NextSequenceID = nil
	self.SequenceContinuousInfoCache.IsSequencePlaying = false
end

function StoryMgr:IsSequenceInSkipGroup(SequenceID, bResetSkipGroup)
    for _, SkipID in ipairs(self.SkipGroupSeqIDs) do
        if SequenceID == SkipID then
            return true
        end
    end
	if bResetSkipGroup then
		self.SkipGroupSeqIDs = {}
	end
    return false
end

function StoryMgr:ResetSkipGroup()
	self.SkipGroupSeqIDs = {}
end

function StoryMgr:DoSequenceSkipGroup(SequenceID, SequenceStopCallback)
	FLOG_INFO("Skip group sequence %d before playing", SequenceID or 0)
	if SequenceStopCallback then
		SequenceStopCallback()
	end

	_G.EventMgr:SendEvent(_G.EventID.JumpAndEndSequence, { SequenceID = SequenceID })
end

function StoryMgr:IsSequenceWaitingToChangeMap()
	if self.SequenceContinuousInfoCache == nil then
		return false
	end
	local CacheInfo = self.SequenceContinuousInfoCache
	-- 先判断有没有注册的连播Sequence
	if not CacheInfo.IsSequencePlaying or CacheInfo.NextSequenceID == nil or CacheInfo.PreSequenceID == nil then
		return false
	end
	-- 需要做一些额外的判断
	local bIsInSkipGroup = self:IsSequenceInSkipGroup(CacheInfo.PreSequenceID)
	_G.FLOG_INFO("[StoryMgr:IsSequenceWaitingToChangeMap]PreSequenceIDCache=%d, NextSequenceIDCache=%d, bIsInSkipGroup=%s", CacheInfo.PreSequenceID, CacheInfo.NextSequenceID, tostring(bIsInSkipGroup))
	return not bIsInSkipGroup
end

function StoryMgr:ShowLoadingAfterSequence()
	if _G.LoadingMgr:IsLoadingView() then
		return
	end
	FLOG_INFO("[StoryMgr:ShowLoadingAfterSequence]")
	-- 这里直接调用WorldMsgMgr的loading接口可以复用一下loading界面超时的逻辑
	_G.WorldMsgMgr:ShowLoadingView(_G.WorldMsgMgr.CurWorldName, nil, true)
end

return StoryMgr