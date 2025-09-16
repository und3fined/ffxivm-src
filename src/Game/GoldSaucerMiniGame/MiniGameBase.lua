--
-- Author: Alex
-- Date: 2023-10-08 19:15
-- Description:金蝶小游戏
--

local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local MiniGameVM = require("Game/GoldSaucerMiniGame/MiniGameVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local EobjLinktoSgAssetCfg = require("TableCfg/EobjLinktoSgAssetCfg")
-- local _G. = require("Game/GoldSaucerMiniGame/_G.")
local AnimationUtil = require("Utils/AnimationUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ObjectGCType = require("Define/ObjectGCType")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local EffectUtil = require("Utils/EffectUtil")

--local MainPanelVM = require("Game/Main/MainPanelVM")
local TimeUtil = require("Utils/TimeUtil")
local AudioUtil = require("Utils/AudioUtil")
local MiniGameCuffAudioDefine = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuffAudioDefine")
local AudioPath = MiniGameCuffAudioDefine.AudioPath

local MiniGameDifficulty = GoldSaucerMiniGameDefine.MiniGameDifficulty
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local AnimTimeLineSourcePath = GoldSaucerMiniGameDefine.AnimTimeLineSourcePath
--local AnimTimeLineSourceKey = GoldSaucerMiniGameDefine.AnimTimeLineSourceKey
local MapDynType = ProtoCommon.MapDynType
local EffectType = MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
--local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local LuaCameraMgr = require("Game/Camera/LuaCameraMgr")
local LightDefine = require("Game/Light/LightDefine")
local LightLevelID = LightDefine.LightLevelID
local LightLevelPath = LightDefine.LightLevelPath
local LightMgr = require("Game/Light/LightMgr")
local HUDMgr = require("Game/HUD/HUDMgr")
local EffectUtil = require("Utils/EffectUtil")

local CameraMoveDelayTime = 0.1 -- 摄像机延迟时间for 主角位置移动到目标点

---@class MiniGameBase
local MiniGameBase = LuaClass()

---Ctor
function MiniGameBase:Ctor()
	self.MiniGameType = nil
	self.DefineCfg = nil
	self.ProgressCfg = nil
	self.LastGameState = nil -- 前一次游戏状态
	self.GameState = nil -- 当前游戏状态
	self.ParamsMap = nil
	self.ChapterID = nil

	self.Name = ""

	self.EobjID = 0 -- 因为断线重连重新创建的客户端Actor的EntityID会和断线前不同，故记录EobjID（配表资源id）
    self.MapEditorID = 0 --金蝶游戏场内摆设的id
    self.ID = 0 -- 预留 作为家具摆放可能有多个 ，Actor是EntityID
	self.DynAssetID = nil -- 动态物件实例id(关卡编辑器静态生成的动态物件实例)
	self.LocalUpdateID = nil -- 动态物件接口配置id
	self.MaxRound = 0 -- 游戏挑战最大轮次

	self.UIViewMainID = nil -- 小游戏绑定UI界面ID
	--self.OKWinViewID = UIViewID.OutOnALimbOkWin -- 小游戏同意进入界面ID
	self.DoubleWinViewID = nil -- 翻倍挑战UI界面ID
	self.SettlementViewID = nil -- 结算界面ID

	--- 应对结算界面直接进入游戏需重置的变量
	self.Difficulty = MiniGameDifficulty.Sabotender
	self.TimeHandleGame = nil -- 游戏计时Handle(使用方法调用会确保一个实例只存在一个此计时循环)
	--self.DelayOpenUI = nil -- 人物动画后打开UI计时器
	self.RemainSeconds = 0 -- 剩余游戏秒数
	self.RemainChances = 0 -- 单轮游戏剩余出手次数
	self.PreServerTime = 0 -- 上一次更新服务器时间
	self.CurRound = 0 -- 当前轮数
	self.AchieveRewardProgress = 0 -- 获取奖励进度
	self.ProgressCounter = 0 -- 进度玩法计数器
	self.LatestProgressLv = nil -- 最近一次的手感等级
	self.LatestActPos = nil -- 最近一次的act后位置
	self.RoundEndState = nil -- 单轮结算状态
	self.FailReasonPos = nil -- 失败原因标准位置
	self.CurLoopFunc = nil -- 当前游戏循环方法
	self.bInViewShowProcess = false -- 是否处于UI表现过程中
	self.bActLockForTime = false -- 出手后锁定时间结束结算	

	self.bIsInit = true -- 判断是否第一次进入游戏（正式流程走交互按钮进入）false 为从结算界面直接进入
	self.bForceEnd = false --是否强制结束游戏

	self.QuitMajorPos = nil -- 离开游戏位置
	self.QuitCameraResetParams = nil -- 离开游戏摄像机视角设定

	self.IdleStateKey = nil -- 待机状态的动画资源Key
	self.WeaponModel = "" -- 人物武器模型资源

	self.TopTipsContentParams = nil

	-- 奖励暴击
	self.bCritical = false
	self.CriticalMutiply = 1

	self.ClientRltShowDelayTimerHandle = nil -- 孤树&矿脉延迟显示计时器(方法内调用前有自检查，会清除原有计时器再创建计时器)
	self.ClientRltShowDelayTime = 0.4 -- 延迟表现时间

	-- 结算界面新纪录&完美挑战
	self.bPerfectChallenge = false -- 是否完美挑战（翻倍挑战至最大次数）
	self.GameRunTime = 0 -- 游戏运行时间

	self.bPerfectChallengeNewRecord = false -- 是否完美挑战新纪录
	self.bCompleteChallengeNewRecord = false -- 是否完成挑战新纪录

	self.PerfectTimeRecord = 0 -- 完美挑战最小用时记录
	self.ChallengeCountRecord = 0 -- 挑战最大轮次记录

	self.TimerHandles = {} -- 所有计时器ID存储表

	self.ResultRewardSev = 0 -- 服务器结算奖励

	--LightLevel里面的灯光位置都不对, 先屏蔽掉
	self.NeedLightLevel = false
end

--- Base逻辑
function MiniGameBase:LockTheTimeSettle()
	self.bActLockForTime = true
end

--- 设定失败原因标准位置
function MiniGameBase:SetFailReasonPos(TargetPos)
	self.FailReasonPos = TargetPos
end

--- 设定是否需要强制结束游戏
function MiniGameBase:SetIsForceEnd(bForceEnd)
	self.bForceEnd = bForceEnd
end

--- 获取是否需要强制结束游戏
function MiniGameBase:GetIsForceEnd()
	return self.bForceEnd
end

--- 获取失败原因标准位置
function MiniGameBase:GetFailReasonPos()
	return self.FailReasonPos or 0
end

--- 获取当前轮数序号（从0开始）
function MiniGameBase:GetRoundIndex()
	return self.CurRound or 0
end

--- 获取进度玩法计数器数量
function MiniGameBase:GetProgressCounter()
	return self.ProgressCounter or 0
end

--- 设定历史完美挑战最小时间
function MiniGameBase:SetPerfectTimeRecord(Time)
	FLOG_INFO("MiniGameBase:SetPerfectTimeRecord %s", tostring(Time))
	self.PerfectTimeRecord = Time
end

--- 设定历史挑战成功最大轮次记录
function MiniGameBase:SetChallengeCountRecord(Count)
	FLOG_INFO("MiniGameBase:SetChallengeCountRecord %s", tostring(Count))
	self.ChallengeCountRecord = Count
end

--- 获取是否完美挑战新纪录
function MiniGameBase:GetPerfectChallengeNewRecord()
	return self.bPerfectChallengeNewRecord
end

--- 获取是否达成挑战新纪录
function MiniGameBase:GetCompleteChallengeNewRecord()
	return self.bCompleteChallengeNewRecord
end

--- 获取是否完美挑战状态
function MiniGameBase:GetIsPerfectChallenge()
	return self.bPerfectChallenge
end

--- 获取完美挑战完成时间
function MiniGameBase:GetPerfectChallengeTime()
	FLOG_INFO("MiniGameBase:GetPerfectChallengeTime %s, %s", tostring(self.bPerfectChallenge), tostring(self.GameRunTime))
	return self.bPerfectChallenge and self.GameRunTime or 0
end

--- 设定游戏阶段状态
function MiniGameBase:SetGameState(GameState)
	local OldState = self.GameState
	if OldState ~= GameState then
		self.GameState = GameState
		self.LastGameState = OldState
		local GameType = self.MiniGameType
		MiniGameVM:UpdateDetailMiniGameVM(GameType)
		FLOG_INFO("MiniGameBase:SetGameState curstate is %s", GameState)
	end
end

--- 获取游戏结算状态
function MiniGameBase:GetRoundEndState()
	return self.RoundEndState
end

--- 获取游戏阶段状态
function MiniGameBase:GetGameState()
	return self.GameState --or MiniGameStageType.Enter
end

--- 设定游戏难度
---@param Difficulty number @GoldSaucerMiniGameDefine.MiniGameDifficulty
function MiniGameBase:SelectDifficulty(Difficulty)
	self.Difficulty = Difficulty

	self:GameStart()
end

--- 重置游戏数据
function MiniGameBase:ResetGameInfo()
	self.Difficulty = MiniGameDifficulty.Sabotender
	self:StopGameTimeLoop() -- 游戏计时Handle,统一接口消除游戏循环Handle，防止有计时器漏消除
	self.RemainSeconds = 0 -- 剩余游戏秒数
	self.RemainChances = 0 -- 单轮游戏剩余出手次数
	self.CurRound = 0 -- 当前轮数
	self.AchieveRewardProgress = 0 -- 获取奖励进度
	self.LatestProgressLv = nil -- 最近一次的手感等级
	self.LatestActPos = nil -- 最近一次的act后位置
	self.RoundEndState = nil -- 单轮结算状态
	self.FailReasonPos = nil -- 失败原因标准位置
	self.TopTipsContentParams = nil
	self.ParamsMap = nil -- 各阶段参数集合
	self:UpdateDynAssetState() -- 重置装置状态
	self.bPerfectChallenge = false -- 是否完美挑战（翻倍挑战至最大次数）
	self.GameRunTime = 0 -- 挑战时间
	self.bPerfectChallengeNewRecord = false -- 是否完美挑战新纪录
	self.bCompleteChallengeNewRecord = false -- 是否完成挑战新纪录
	self.PerfectTimeRecord = 0 -- 完美挑战最小用时记录
	self.ChallengeCountRecord = 0 -- 挑战最大轮次记录
	self.ProgressCounter = 0 
end

--- 设置游戏结算是否暴击
function MiniGameBase:SetRltCritical(bCritical)
	self.bCritical = bCritical
end

--- 获取游戏结算是否暴击
function MiniGameBase:GetRltCritical()
	return self.bCritical
end

--- 设置游戏结算奖励货币数量
function MiniGameBase:SetResultRewardSev(RewardCount)
	self.ResultRewardSev = RewardCount
end

--- 获取游戏结算奖励货币数量
function MiniGameBase:GetResultRewardSev()
	return self.ResultRewardSev
end

--- 获取游戏是否处于再战状态
function MiniGameBase:GetIsReChallenge()
	return not self.bIsInit
end

--- 获取特定阶段存储的数据
---@param GameState MiniGameStageType@当前游戏阶段
function MiniGameBase:GetParamsByGameState(GameState)
	local ParamsMap = self.ParamsMap
	if not ParamsMap then
		return
	end

	return ParamsMap[GameState]
end

--- 同步进入游戏传入参数
function MiniGameBase:OnSyncParamsByGameState(GameState, Params)
	local ParamsMap = self.ParamsMap or {}
	ParamsMap[GameState] = Params
	self.ParamsMap = ParamsMap
end

--- 重连小游戏(奖励结算判断条件)
function MiniGameBase:NeedGameRewardAfterReconnect()
	local GameEndState = self:GetRoundEndState()
	if not GameEndState then
		return
	end

	return GameEndState == MiniGameRoundEndState.Success
end

--- 重连小游戏(场景处理)
function MiniGameBase:SetTheSceneViewAfterReconnect()
	self:SetStartMode(true)
	self:ResetDynAssetState()
	--_G.EmotionMgr:StopAllEmotions(MajorUtil.GetMajorEntityID(), false)
	self:SetTheMajorAvatarAndAnim()
end

--- 重连小游戏(场景处理)
function MiniGameBase:RecoverLoopLogicAfterReconnect()
	local GameType = self.MiniGameType
	local ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)
	if not ViewModel then
		return
	end

	ViewModel.ReconnectSuccess = true
end

--- 重连小游戏(UI处理)
function MiniGameBase:ReopenTheViewAfterReconnect()
	local GameType = self.MiniGameType
	local ViewID = self.UIViewMainID
	if ViewID == nil then
		return
	end
	local ViewConfig = UIViewMgr:FindConfig(ViewID)
	if not ViewConfig then
		return
	end

	local bAsyncOpen = ViewConfig.bAsyncLoad

    local ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)
	ViewModel:UpdateVM()
	local Params = {Data = ViewModel}
	local function RecoverGameState()
		local GameStateBindableProperty = ViewModel:FindBindableProperty("GameState")
		if not GameStateBindableProperty then
			return
		end
		local OldState = self.LastGameState
		local NewState = self.GameState
		if not OldState or not NewState then
			return
		end
		GameStateBindableProperty:OnValueChanged(NewState, OldState)
	end
	if bAsyncOpen then
		UIViewMgr:ShowView(ViewID, Params, RecoverGameState)
	else
		UIViewMgr:ShowView(ViewID, Params)
		RecoverGameState()
	end	
end

------------- 孤树&矿脉单独使用逻辑 -----------------
--- 单次出手结算
function MiniGameBase:ActionSettlement(Params)
	local CurProgressLv = Params.ProgressLevel
	self.LatestActPos = Params.ActAngle
	local ChangedProgress = Params.ProgressVal / 10000 or 0
	if ChangedProgress > 1 then
		ChangedProgress = 1
	end
	self.AchieveRewardProgress = ChangedProgress

	self.LatestProgressLv = CurProgressLv

	local CurRemainChances = self.RemainChances
	self.RemainChances = CurRemainChances - 1

	self.ProgressCounter = self.ProgressCounter + 1
	self.bInViewShowProcess = true
	self:DelayShowRltAfterMajorAct() -- 使用计时器控制显示时机代替动作结束显示以更好匹配显示效果
end

--- 更新客户端手感结果表现（分离数据与表现的变化时机，使表现匹配人物动作）
function MiniGameBase:UpdateClientRltShow()
	local GameType = self.MiniGameType
	if not GameType then
		return
	end
	MiniGameVM:UpdateDetailMiniGameVM(GameType)
	self:UpdateDynAssetState()
	self.bActLockForTime = false
end

function MiniGameBase:DelayShowRltAfterMajorAct()
	self:UpdateClientRltShow()
	local DelayTimer = self.ClientRltShowDelayTimerHandle
	if DelayTimer then
		_G.TimerMgr:CancelTimer(DelayTimer)
	end

	self.ClientRltShowDelayTimerHandle = _G.TimerMgr:AddTimer(self, function()
		self:PlayMajorCutAnimation()
	end, self.ClientRltShowDelayTime)
	self:AddTimerHandle(self.ClientRltShowDelayTimerHandle)
end
------------- 孤树&矿脉单独使用逻辑 -----------------

--- 取消重新进入游戏(服务器结算奖励)
function MiniGameBase:CancelRestartFunc()
	local GameType = self.MiniGameType
	EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = GameType, bRestart = false})
end

--- 获取当前游戏种类
function MiniGameBase:GetGameType()
	return self.MiniGameType
end

--- 获取当前游戏难度
function MiniGameBase:GetDifficulty()
	return self.Difficulty
end

--- 获取游戏名称
function MiniGameBase:GetName()
	return self.Name
end

--- 获取游戏剩余时间（整型）
function MiniGameBase:GetRemainSecondsInteger()
	return math.ceil(self.RemainSeconds)
end

--- 获取游戏剩余时间
function MiniGameBase:GetRemainSeconds()
	return self.RemainSeconds
end

--- 获取游戏出手次数
function MiniGameBase:GetRemainChances()
	return self.RemainChances
end

--- 获取游戏当前进度
function MiniGameBase:GetAchieveRewardProgress()
	return self.AchieveRewardProgress
end

--- 获取最新一次的游戏手感
function MiniGameBase:GetLatestProgressLv()
	return self.LatestProgressLv
end

--- 获取最新一次的Act位置
function MiniGameBase:GetLatestActPos()
	return self.LatestActPos
end

--- 获取TopTips显示内容
function MiniGameBase:GetTopTipsContent()
	return self.TopTipsContentParams
end

--- 游戏View界面表现结束
function MiniGameBase:ViewProcessEnd()
	self.bInViewShowProcess = false
end

------ 小游戏入局场景逻辑 ------

--- 设置ActorHUD显隐
---@param bHide boolean@是否隐藏
function MiniGameBase:SetActorHUDHideInGame(bHide)
	if bHide then
		HUDMgr:HideAllActors()
	else	
		HUDMgr:ShowAllActors()
	end
end

--- 小游戏场景其他系统相关状态预处理
function MiniGameBase:PreHandleOtherSysForStartMode(bReconnect)
	-- -- 进入对局时清除玩家对其他目标的选中态
	local EventParams = _G.EventMgr:GetEventParams()
	EventParams.ULongParam1 = 0
	_G.EventMgr:SendCppEvent(_G.EventID.ManualUnSelectTarget, EventParams)

	-- 进入对局清除战斗状态
	local StateComp = MajorUtil.GetMajorStateComponent()
	if StateComp then
		StateComp:SetNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT, false, true)
        _G.EmotionMgr:SendStopEmotionAll()
		StateComp:SetHoldWeaponState(false)
		StateComp:ClearTempHoldWeapon(_G.UE.ETempHoldMask.ALL, true)
	end

	if not bReconnect then
		self:SetMajorCanMove(false)
	end

	if bReconnect then
		_G.InteractiveMgr:SetCanShowInteractive(false)
   		_G.InteractiveMgr:HideMainPanel()
	end
	
	-- _G.UE.UInputMgr.Get():UnRegisterPlayerInputAxisForLua("MoveForward")

	-- 清除任务引导路径显示
	self.ChapterID = QuestMainVM.CurrTrackChapterID
	QuestMainVM.QuestTrackVM:TrackQuest(nil)

	-- 加载小游戏灯光关卡
	if self.NeedLightLevel then
		LightMgr:LoadLightLevelByPath(LightLevelPath[LightLevelID.LIGHT_LEVEL_ID_JD_MINIGAME])
	end

	-- 隐藏ActorHUD
	self:SetActorHUDHideInGame(true)

	-- 隐藏所有浮标
	_G.BuoyMgr:ShowAllBuoys(false)
end

--- 缓存人物在场景里时的Transform信息
function MiniGameBase:StoreMajorTransformInScene()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end
	local MajorPreEnterPos = Major:FGetActorLocation()
	if MajorPreEnterPos then
		self.QuitMajorPos = MajorPreEnterPos
	end
end

--- 设定游戏进行时主角的Transform
function MiniGameBase:SetTheMajorTransInGame()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	local ClientDef = self.DefineCfg
	if ClientDef == nil then
		return
	end

	local InstanceID = self:GetSgDynaInstanceID()
	if not InstanceID then
		return
	end

	self.DynAssetID = InstanceID

	local SgTransform = _G.UE.FTransform()
	PWorldMgr:GetInstanceAssetTransform(InstanceID, SgTransform)
	local SgRotator = SgTransform:Rotator()
	local SgLocation = SgTransform:GetLocation()
	local Rotator = SgRotator:GetForwardVector()
	FLOG_INFO("ChocoMoogleMajorPosError:SgInfo  InstanceID:%s  SgRotator:%s SgLocation:%s Rotator:%s", InstanceID, SgRotator, SgLocation, Rotator)
	local OffsetPos = SgLocation + Rotator * ClientDef.MajorStandPosOffset
	local MajorHalfHeight = Major:GetCapsuleHalfHeight()
	local ZOffset = ClientDef.ZOffset
	local TargetPos = _G.UE.FVector(OffsetPos.X, OffsetPos.Y, SgLocation.Z + ZOffset + MajorHalfHeight)
	Major:K2_SetActorLocation(TargetPos, false, nil, false)
	FLOG_INFO("ChocoMoogleMajorPosError:Role Init Pos %s %s %s", TargetPos.X, TargetPos.Y, TargetPos.Z)
	MajorUtil.LookAtPos(SgLocation)
end

--- 设定游戏进行时主角的动画
function MiniGameBase:SetTheMajorAvatarAndAnim()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	Major:HideMasterHand(true)
	Major:HideSlaveHand(true)

	local Path = self:GetIdlePathByRaceID()
	self:PlayAnyAsMontageLoopByPath(Path, GoldSaucerMiniGameDefine.DefaultSlot, 9999, true)
end

--- 设置游戏开始主角位置
function MiniGameBase:SetStartMode(bReconnect)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	EffectUtil.SetIsInMiniGame(true)
	Major:DoClientModeEnter()
	self:PreHandleOtherSysForStartMode(bReconnect)
	self:StoreMajorTransformInScene()
	self:SetTheMajorTransInGame()
	self:CameraMoveToRunningMode()
	EventMgr:SendEvent(EventID.MiniGameMajorEnterStartMode)
end

------ 小游戏入局场景逻辑 end ------

------ 小游戏退场场景逻辑 ------
--- 还原游戏退出主角位置
function MiniGameBase:SetQuitMode()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end
	self:SetMajorCanMove(true)

	EffectUtil.SetIsInMiniGame(false)
	self:UpdateOtherSysForQuitMode()
	self:RecoverTheMajorTransInGame()
	self:RecoverTheMajorAvatarAndAnim()
	self:CameraMoveToOriginMode()

	Major:DoClientModeExit()
	self:TryShowMiniGamesTutorial()
end

function MiniGameBase:SetMajorCanMove(bCanMove)
    local StateComponent = MajorUtil.GetMajorStateComponent()
   	if StateComponent ~= nil then
        --有tag，先判断状态是否一样
        local State = StateComponent:GetActorControlState(_G.UE.EActorControllStat.CanMove)
        if State == bCanMove then
            return
        end
		
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, bCanMove, "GoldMiniGame")
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanAllowMove, bCanMove, "GoldMiniGame")
	end--]] 
end

--- 更新退出小游戏后场景其他系统显示
function MiniGameBase:UpdateOtherSysForQuitMode()
	-- 还原任务引导路径显示
	local ChapterIDBeforeEnter = self.ChapterID
	if ChapterIDBeforeEnter then
		QuestMainVM.QuestTrackVM:TrackQuest(ChapterIDBeforeEnter)
		self.ChapterID = nil
	end

	-- 卸载小游戏灯光关卡
	if self.NeedLightLevel then
		LightMgr:UnLoadLightLevelByPath(LightLevelPath[LightLevelID.LIGHT_LEVEL_ID_JD_MINIGAME])
	end

	-- 隐藏ActorHUD
	self:SetActorHUDHideInGame(false)

	-- 显示所有浮标
	_G.BuoyMgr:ShowAllBuoys(true)

	_G.InteractiveMgr:SetCanShowInteractive(true)
   	_G.InteractiveMgr:ShowMainPanel()
end

-- 还原游戏退出后主角的Transform
function MiniGameBase:RecoverTheMajorTransInGame()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	local QuitMajorPos = self.QuitMajorPos
	if QuitMajorPos then
		Major:K2_SetActorLocation(QuitMajorPos, false, nil, false)
	end

	local InstanceID = self:GetSgDynaInstanceID()
	if not InstanceID then
		return
	end
	--self:SetDynAssetID(nil)

	local SgTransform = _G.UE.FTransform()
	PWorldMgr:GetInstanceAssetTransform(InstanceID, SgTransform)
	local SgLocation = SgTransform:GetLocation()
	if SgLocation then
		MajorUtil.LookAtPos(SgLocation)
	end
end

--- 还原游戏退出后主角的动画
function MiniGameBase:RecoverTheMajorAvatarAndAnim()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	-- 恢复显示主武器
	Major:HideMasterHand(false)
	Major:HideSlaveHand(false)

	self:StopMajorSlotAnimation(GoldSaucerMiniGameDefine.DefaultSlot) -- 停止Idle
	self:StopMajorActionAnim()										  -- 停止action动作
end
------ 小游戏退场场景逻辑 end ------

--- 相机移动至游戏视角
function MiniGameBase:CameraMoveToRunningMode()
	local ClientDef = self.DefineCfg
	if ClientDef == nil then
		return
	end
	local TimerHandle = _G.TimerMgr:AddTimer(self, function()
		FLOG_INFO("MiniGameMoogleFirstAngleError:Camera Move %s", tostring(TimeUtil.GetLocalTimeMS()))
		local MajorActor = MajorUtil.GetMajor()
		local MajorPos = MajorActor:FGetActorLocation()
		FLOG_INFO("MiniGameMoogleFirstAngleError:Role Position %s", tostring(MajorPos))
		LuaCameraMgr:TrySwitchCameraByID(ClientDef.CameraParamID)
	end, CameraMoveDelayTime)
	self:AddTimerHandle(TimerHandle)
end

--- 相机还原至原本视角
function MiniGameBase:CameraMoveToOriginMode()
	LuaCameraMgr:ResumeCamera()
end

--- 停止action动作 例如：劈砍，出拳，等
function MiniGameBase:StopMajorActionAnim()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end
	local AnimComp = Major:GetAnimationComponent()
	if AnimComp == nil then
		return
	end

	local MajorUtil = require("Utils/MajorUtil")
    local RaceID = MajorUtil.GetMajorRaceID()
    local DefineCfg = self.DefineCfg
    local ActionPath = DefineCfg.ActionPath
	local Path = ActionPath[RaceID]
	AnimationUtil.StopAnimation(AnimComp, Path)
end

--- 播放主角动画
---@param ActionState GoldSaucerMiniGameDefine.AnimTimeLineSourceKey @Define文件中的AnimTimeLineSourceKey
function MiniGameBase:PlayActionTimeLineByMajor(ActionState, CallBack)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

    local AnimPath = AnimTimeLineSourcePath[ActionState]
    if AnimPath == nil then
	FLOG_ERROR("MiniGameBase:PlayActionTimeLineByMajor The Anim Path is Invalid") --StopAnimation
		if CallBack and type(CallBack) == "function" then
			CallBack()
		end
        return
    end

    _G.AnimMgr:PlayActionTimeLineByActor(Major, AnimPath, CallBack)
end

function MiniGameBase:PlayActionTimeLineByPath(Path, CallBack)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

    local AnimPath = Path
    if AnimPath == nil then
	FLOG_ERROR("MiniGameBase:PlayActionTimeLineByMajor The Anim Path is Invalid") --StopAnimation
		if CallBack and type(CallBack) == "function" then
			CallBack()
		end
        return
    end

    _G.AnimMgr:PlayActionTimeLineByActor(Major, AnimPath, CallBack)
end

--- @type 可设置循环次数
---@param ActionState GoldSaucerMiniGameDefine.AnimTimeLineSourceKey @Define文件中的AnimTimeLineSourceKey
function MiniGameBase:PlayAnyAsMontageLoop(ActionState, Slot, LoopCount, bStopAllMontages)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	local AnimPath = AnimTimeLineSourcePath[ActionState]
    if AnimPath == nil then
		return
	end
	
	_G.AnimMgr:PlayAnyAsMontageLoop(Major, Slot, AnimPath, LoopCount, bStopAllMontages)
end

-- @type 可设置循环次数
---@param ActionState GoldSaucerMiniGameDefine.AnimTimeLineSourceKey @Define文件中的AnimTimeLineSourceKey
function MiniGameBase:PlayAnyAsMontageLoopByPath(Path, Slot, LoopCount, bStopAllMontage, PlayRate)
	if PlayRate == nil then
		PlayRate = 1
	end
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	local AnimPath = Path
    if AnimPath == nil then
		return
	end
	local AnimComp = Major:GetAnimationComponent()
	if AnimComp == nil then
		return
	end
	local Anim = _G.ObjectMgr:LoadObjectSync(Path, ObjectGCType.LRU)
	if Anim == nil then
		return
	end
	local AnimSeq = Anim:Cast(_G.UE.UAnimSequenceBase)
	FLOG_INFO("MiniGameBase:PlayAnyAsMontageLoopByPath Major Anim Idle Played")
	AnimComp:PlaySequenceToMontage(AnimSeq, Slot, nil, "", PlayRate, 0.25, 0.25, nil, LoopCount, bStopAllMontage)
		-- _G.AnimMgr:PlayAnyAsMontageLoop(Major, Slot, AnimPath, LoopCount, bStopAllMontages)
end

--- @type 设置蒙太奇当前播放的速率
function MiniGameBase:SetPlayRate(PlayRate)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end

	local AnimComp = Major:GetAnimationComponent()
	if AnimComp == nil then
		return
	end
	AnimComp:SetPlayRate(PlayRate)
end

--- @type 停止播放某个动画一般为Idle
function MiniGameBase:StopMajorSlotAnimation(Slot)
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return
	end
	local AnimComp = Major:GetAnimationComponent()
	if AnimComp == nil then
		return
	end

	FLOG_INFO("MiniGameBase:StopMajorSlotAnimation Major Anim Stopped")
	AnimationUtil.StopSlotAnimation(AnimComp, nil, Slot, 0.25, 0)
end

--- @type 获取IdleKey
function MiniGameBase:GetIdleKey()
	return self.IdleStateKey
end

function MiniGameBase:SetDynAssetID(DynAssetID)
	self.DynAssetID = DynAssetID
end

function MiniGameBase:GetInstanceID()
	return self.DynAssetID
end

--- @type 获得动态物件实例ID
function MiniGameBase:GetSgDynaInstanceID()
	local EObjEntityID = self.ID
	local EObjID = ActorUtil.GetActorResID(EObjEntityID)
	if not EObjID or EObjID == 0 then
		-- 重连后重新创建Actor，EntityID发生变化,更新EntityID
		EObjID = self.EobjID
		self.ID = ActorUtil.GetActorEntityIDByResID(EObjID)
	else
		self.EobjID = EObjID
	end
	
	local Cfg = EobjLinktoSgAssetCfg:FindCfgByKey(EObjID)
	if Cfg ~= nil then
		return Cfg.SgbID
	else
		FLOG_ERROR("EobjLinktoSgAssetCfg Cfg = nil EObjID = %s", EObjID)
	end
end

--- @type 
function MiniGameBase:GetViewModel()
	return MiniGameVM:GetDetailMiniGameVM(self.MiniGameType)
end

--- 开启游戏时间循环
---@param UpdateFunc function @循环中调用的方法
function MiniGameBase:StartGameTimeLoop(UpdateFunc)
	if self.TimeHandleGame then
		FLOG_ERROR("MiniGameBase:StartGameTimeLoop Time Loop is existed")
		return
	end

	self.TimeHandleGame = _G.TimerMgr:AddTimer(self, UpdateFunc, 0, GoldSaucerMiniGameDefine.MiniGameTickInterval, 0)
	self.CurLoopFunc = UpdateFunc
	self.PreServerTime = TimeUtil.GetServerTimeMS()
end

--- 中断/暂停游戏时间循环
---@param bPause boolean@是否暂停
function MiniGameBase:StopGameTimeLoop(bPause)
	local TimerHandle = self.TimeHandleGame
	if TimerHandle == nil then
		return
	end
	_G.TimerMgr:CancelTimer(TimerHandle)
	self.TimeHandleGame = nil
	if not bPause then
		self.CurLoopFunc = nil
	end
end

--- 恢复游戏时间循环
function MiniGameBase:RecoverGameTimeLoop()
	local TimerHandle = self.TimeHandleGame
	if TimerHandle then
		FLOG_ERROR("MiniGameBase:RecoverGameTimeLoop Time Loop is existed")
		return
	end

	local FuncToLoop = self.CurLoopFunc
	if FuncToLoop == nil then
		FLOG_ERROR("MiniGameBase:RecoverGameTimeLoop CurLoopFunc is not existed")
		return
	end
	self.TimeHandleGame = _G.TimerMgr:AddTimer(self, FuncToLoop, 0, GoldSaucerMiniGameDefine.MiniGameTickInterval, 0)
end

--- 关闭所有UI
---@param bStoreMainPanel boolean @是否保留主界面For 再战
function MiniGameBase:CloseAllUIView(bStoreMainPanel)
	local UIViewMainID = self.UIViewMainID
	if UIViewMainID and UIViewMgr:IsViewVisible(UIViewMainID) and not bStoreMainPanel then
		UIViewMgr:HideView(UIViewMainID, true) -- 界面无AnimOut动画
	end

	local DoubleWinViewID = self.DoubleWinViewID
	if DoubleWinViewID and UIViewMgr:IsViewVisible(DoubleWinViewID) then
		UIViewMgr:HideView(DoubleWinViewID)
	end

	local SettlementViewID = self.SettlementViewID
	if SettlementViewID and UIViewMgr:IsViewVisible(SettlementViewID) then
		UIViewMgr:HideView(SettlementViewID, true) -- 界面无AnimOut动画
	end
end

--- 更新动态物件状态
function MiniGameBase:UpdateDynAssetState()
	local DynAssetID = self.DynAssetID
	local LocalUpdateID = self.LocalUpdateID
	if not DynAssetID and not LocalUpdateID then
		return
	end

	self:ResetDynAssetState()

	local ClientDef = self.DefineCfg
	if not ClientDef then
		return
	end

	local DynStateIndex = ClientDef.DynAssetIndexDefault or 0 
	local CurProgressLv = self.LatestProgressLv
	if not CurProgressLv then
		if DynAssetID then
			PWorldMgr:PlaySharedGroupTimeline(DynAssetID, DynStateIndex)
		elseif LocalUpdateID then
			PWorldMgr:LocalUpdateDynData(EffectType, LocalUpdateID, DynStateIndex) 
		end
	else
		local ProgressLevelCfg = ClientDef.ProgressLevel
		if not ProgressLevelCfg then
			return
		end
		local LevelCfg = ProgressLevelCfg[CurProgressLv]
		if not LevelCfg then
			return
		end
		DynStateIndex = LevelCfg.DynAssetIndex or 0
		if DynAssetID then
			PWorldMgr:PlaySharedGroupTimeline(DynAssetID, DynStateIndex)
		elseif LocalUpdateID then
			PWorldMgr:LocalUpdateDynData(EffectType, LocalUpdateID, DynStateIndex) 
		end
	end
end

--- 重置动态物件状态
function MiniGameBase:ResetDynAssetState()
	local DynAssetID = self.DynAssetID
	if not DynAssetID then
		return
	end
	PWorldMgr:PlaySharedGroupTimeline(DynAssetID, 0)
end

--- 游戏流程
--- 游戏进入
function MiniGameBase:GameEnter()
	local IsInstanceInit = self.bIsInit
	if IsInstanceInit then
		self:SetStartMode()
		--- 利用动画时间加载表格数据
		self:LoadTableCfg()
		self.bIsInit = false
	end
	self:MakeExtraTableCfg()
	self:ResetDynAssetState()
	self:SetTheMajorAvatarAndAnim()
	self:BindViewModelToUIViewAndShow(IsInstanceInit)
end

--- 游戏选择难度阶段的游戏循环
function MiniGameBase:GameDifficultyLoop()
	local CurTime = self.RemainSeconds
	local GameType = self.MiniGameType
	-- 循环中逻辑处理位置
	local TickEndTime = CurTime - GoldSaucerMiniGameDefine.MiniGameTickInterval
	if TickEndTime < 0 then
		TickEndTime = 0
		self:StopGameTimeLoop()
		EventMgr:SendEvent(EventID.DetailMiniGameAutoSelectDifficulty, GameType)
	end
	self.RemainSeconds = TickEndTime
	MiniGameVM:UpdateDetailMiniGameTime(GameType)
end

--- 游戏设定难度
function MiniGameBase:GameSetDifficulty()
	self.TopTipsContentParams = self:OnGetTopTipsContent(MiniGameStageType.DifficultySelect)
	local DifficultySelectParam = self:OnCreateDifficultyParams()
	if DifficultySelectParam then
		self.RemainSeconds = DifficultySelectParam.TimeLimit
		self:StartGameTimeLoop(self.GameDifficultyLoop)
	end
	self:SetGameState(MiniGameStageType.DifficultySelect)
end

--- 游戏开始
function MiniGameBase:GameStart()
	self:InitMiniGame()
	self.TopTipsContentParams = self:OnGetTopTipsContent(MiniGameStageType.Start)
	self:SetGameState(MiniGameStageType.Start)
end

--- 游戏进行中
function MiniGameBase:GameRun()
	local Now = TimeUtil.GetServerTimeMS()
	local CurTime = self.RemainSeconds
	local RunTime = self.GameRunTime

	local Interval = (Now - self.PreServerTime) / 1000
	self.PreServerTime = Now

	-- 循环中逻辑处理位置
	local TickEndTime = CurTime - Interval
	local ActualAddTimeInterval = Interval
	if TickEndTime < 0 then
		ActualAddTimeInterval = ActualAddTimeInterval + TickEndTime
		TickEndTime = 0
	end
	self.GameRunTime = RunTime + ActualAddTimeInterval
	self.RemainSeconds = TickEndTime
	MiniGameVM:UpdateDetailMiniGameTime(self.MiniGameType)
	self:SetGameState(MiniGameStageType.Update)
	self:OnGameRun(TickEndTime)
	if self:OnIsGameRunEnd() and not self.bInViewShowProcess then
		self.PreServerTime = 0
		self:GameEnd()
	end
end

--- 更新完美挑战&新纪录信息
function MiniGameBase:UpdatePerfectChallengeAndNewRecordInfo()
    local HistoryPerfectChallengeCount = self.ChallengeCountRecord
    local RoundIndex = self.CurRound + 1
	if RoundIndex > HistoryPerfectChallengeCount then
		self.bCompleteChallengeNewRecord = true
	end
    
	local bPerfectChallenge = self.bPerfectChallenge
    local HistoryPerfectChallengeTime = self.PerfectTimeRecord or 0
	local CurRunTime = self.GameRunTime

	if bPerfectChallenge then
		if HistoryPerfectChallengeTime == 0 then
			self.bPerfectChallengeNewRecord = true
		elseif CurRunTime * 1000 < HistoryPerfectChallengeTime then
			self.bPerfectChallengeNewRecord = true
		end
	end
end

--- 游戏结束
function MiniGameBase:GameEnd()
	self:StopGameTimeLoop()
	self:SetGameState(MiniGameStageType.End)

	local function ChangeGameState()
		if self:OnIsHaveRestartStage() then
			local EndState = self.RoundEndState
			if EndState then
				if EndState == MiniGameRoundEndState.Success then --走翻倍协议结算奖励，最后还需要走一次退出协议
					if self.CurRound + 1 >= self.MaxRound then
						self.bPerfectChallenge = true
						self:CancelRestartFunc()
					else
						local RestartContentParams = self:OnCreateRestartContentParams()
						UIViewMgr:ShowView(self.DoubleWinViewID, RestartContentParams)
						local Major = MajorUtil.GetMajor()
						if Major then
							local Location = Major:FGetActorLocation()
							if Location then
								FLOG_INFO("MoogleTouchError:Role DoubleView Open Pos %s %s %s", Location.X, Location.Y, Location.Z)
							end
						end
					end
				else --客户端直接走退出协议结算，显示失败原因，最后直接走客户端退出游戏流程
					self:GameReward()
				end
			end
		else
			self:GameReward() -- 没有翻倍挑战的游戏，看UIView上监听GameState变化的事件具体处理（可能会掠过失败展示界面）
		end
	end

	local DelayForViewEndShow = _G.TimerMgr:AddTimer(self, ChangeGameState, 0.2)
	self:AddTimerHandle(DelayForViewEndShow)
end

--- 游戏重启（翻倍挑战）
function MiniGameBase:GameRestart()
	self.CurRound = self.CurRound + 1
	self.AchieveRewardProgress = 0
	self.ProgressCounter = 0
	self.LatestProgressLv = nil
	self.RoundEndState = nil -- 单轮重新挑战清除上次状态
	self:UpdateDynAssetState() -- 重置动态物件状态
	self.LatestActPos = nil
	self:OnGameRestart()
	self:SetGameState(MiniGameStageType.Restart)
end

--- 游戏奖励结算
function MiniGameBase:GameReward()
	self:UpdatePerfectChallengeAndNewRecordInfo()
	self:OnGameReward()

	self:SetGameState(MiniGameStageType.Reward)
end

--- 游戏失败原因展示
function MiniGameBase:GameFailInfoShow()
	self:SetGameState(MiniGameStageType.FailInfoShow)
end

--- 游戏退出
function MiniGameBase:GameQuit(bRewar)
	if not bRewar then
		self.bIsInit = true
		self:SetQuitMode()
	else
		self:Reset()
	end
	self:StopGameTimeLoop()
	self:ResetDynAssetState()
	self:UnRegisterAllTimer()
	self:SetGameState(MiniGameStageType.Quit)
	self:CloseAllUIView(bRewar)
end
--- 游戏流程 end

--- 派生逻辑
--- 静态加载的表格数据仅实例创建时加载一次
function MiniGameBase:LoadTableCfg()
end

--- 动态整理的表格数据每次游戏开始均执行
function MiniGameBase:MakeExtraTableCfg()
end

--- 差异化打开小游戏主界面逻辑
--- 绑定VM到View并显示
---@param bInit boolean@是否初始化打开界面
function MiniGameBase:BindViewModelToUIViewAndShow(bInit)
	local ViewID = self.UIViewMainID
	if ViewID == nil then
		return
	end

	local ViewConfig = UIViewMgr:FindConfig(ViewID)
	if not ViewConfig then
		return
	end

	local GameType = self.MiniGameType
    local ViewModel

	local function GameEnterAysnc()
		self:SetGameState(MiniGameStageType.Enter)
		
		if UIViewMgr:IsViewVisible(UIViewID.MooglePawOkWin) then
			UIViewMgr:HideView(UIViewID.MooglePawOkWin)
		end
		
		if self:OnIsGameHaveDifficultySelect() then
			self:GameSetDifficulty()
		else
			self:GameStart()
		end
	end

	local bAsyncOpen = ViewConfig.bAsyncLoad
	local bIsViewVisible = UIViewMgr:IsViewVisible(ViewID)

	if not bInit and bIsViewVisible then
		--- 未重新打开界面
		GameEnterAysnc()
		return
	end
	if bInit then --- 初始化创建小游戏界面
		ViewModel = MiniGameVM:CreateDetailMiniGameVM(GameType, self)
	else --- 界面被关闭
		ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)
	end
	local Params = {Data = ViewModel}
	if bAsyncOpen then
		UIViewMgr:ShowView(ViewID, Params, GameEnterAysnc)
	else
		UIViewMgr:ShowView(ViewID, Params)
		GameEnterAysnc()
	end
end

--- 初始化游戏
function MiniGameBase:InitMiniGame()
end

--- 设定选择游戏难度MsgText内容
function MiniGameBase:OnCreateDifficultyParams()
end

--- 获取镜头移动参数
function MiniGameBase:OnCreateCameraSettingParam()
end

--- 是否有难度选择阶段
function MiniGameBase:OnIsGameHaveDifficultySelect()
end

--- 是否结束游戏
function MiniGameBase:OnIsGameRunEnd()
end

--- 是否带有翻倍阶段
function MiniGameBase:OnIsHaveRestartStage()
end

--- 翻倍挑战显示参数
function MiniGameBase:OnCreateRestartContentParams()
end

--- 获取游戏翻倍挑战重置时间和次数
function MiniGameBase:GetRestartTimeAndChances()
end

--- 获取当前轮能够获得的奖励
function MiniGameBase:GetTheRewardGotInTheRoundInternal(Round)
end

--- 获取当前轮能够获得的奖励
function MiniGameBase:GetTheRewardGotInTheRound()
end

--- 获取顶部tips内容
function MiniGameBase:OnGetTopTipsContent(GameState)
end

--- 翻倍重新开始数据整理
function MiniGameBase:OnGameRestart()
end

--- 奖励结算数据整理
function MiniGameBase:OnGameReward()

end
--- 设置历史最大的分数
function MiniGameBase:SetMaxScore(MaxScore)
end

--- 子类需要在计时器中更新的内容写在这里
function MiniGameBase:OnGameRun(CurTime)
end

--- 是否循环Idle动画
function MiniGameBase:bNeedLoop()
end

--- 重置当前实例游戏数据
function MiniGameBase:Reset()
end

--- 播放主角砍伐/挖掘动画
function MiniGameBase:PlayMajorCutAnimation()
end

function MiniGameBase:GetIdlePathByRaceID()
	local ClientDef = self.DefineCfg
	if not ClientDef then
		return
	end

	local IdlePathList = ClientDef.IdlePath
	if not IdlePathList then
		return
	end

	local MajorRaceID = MajorUtil.GetMajorRaceID()
	if not MajorRaceID then
		return
	end
	return IdlePathList[MajorRaceID]
end

--- 依赖TimerMgr自身的Cancel逻辑，不做重复检查
function MiniGameBase:UnRegisterAllTimer()
	local TimerHandles = self.TimerHandles
	if not TimerHandles then
		return
	end
	for TimerID, _ in pairs(TimerHandles) do
		_G.TimerMgr:CancelTimer(TimerID)
	end
end

--- 记录小游戏运行过程中相关的计时器，在游戏结束时用于清除保证不会出现表现错误
--- 无对应的删除元素接口，因为lua内同一句尚未赋值前的local变量无法传入回调闭包方法内
function MiniGameBase:AddTimerHandle(TimerID)
	local MiniGameTimerList = self.TimerHandles or {}
	MiniGameTimerList[TimerID] = true
	self.TimerHandles = MiniGameTimerList
end

---- 音频相关begin----
function MiniGameBase:PlaySoundWithPostEvent(EventName, RTPCName, Intensity)
	local UAudioMgr = _G.UE.UAudioMgr.Get()
    local ActorProxy = UAudioMgr:GetAudioProxy()
	local Path
	if EventName == MiniGameCuffAudioDefine.AudioName.PlayFistSwish then
		Path = AudioPath.PlayFistSwish
	else	
		Path = AudioPath.StopFistSwish
	end
	-- UAudioMgr:PostEventByName(EventName, ActorProxy, true)
	AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), Path, true)
	if RTPCName ~= nil then
    	UAudioMgr.SetRTPCValue(RTPCName, Intensity, 0, MajorUtil.GetMajor())
    end
end

function MiniGameBase:SetRTPCValue(RTPCName, Intensity, InLerpTime)
	local LerpTime = InLerpTime or 0
	local UAudioMgr = _G.UE.UAudioMgr.Get()
    local ActorProxy = MajorUtil.GetMajor()--UAudioMgr:GetAudioProxy()
    UAudioMgr.SetRTPCValue(RTPCName, Intensity, LerpTime, ActorProxy)
end

--- @type 出现新手指南
function MiniGameBase:TryShowMiniGamesTutorial()
    local function ShowGoldSauserMiniGamesTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.UnlockGameplay--新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.GoldSauserMiniGames
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowGoldSauserMiniGamesTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end


return MiniGameBase