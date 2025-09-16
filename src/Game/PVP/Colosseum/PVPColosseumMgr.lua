--
-- Author: peterxie
-- Date:
-- Description: 水晶冲突玩法管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsID = require("Define/MsgTipsID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewMgr = require("UI/UIViewMgr")
local BusinessUIMgr = require("UI/BusinessUIMgr")
local UIViewID = require("Define/UIViewID")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local EffectUtil = require("Utils/EffectUtil")
local AudioUtil = require("Utils/AudioUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

local PVPColosseumHeaderVM = require("Game/PVP/Colosseum/VM/PVPColosseumHeaderVM")
local PVPColosseumBattleLogVM = require("Game/PVP/Colosseum/VM/PVPColosseumBattleLogVM")
local PVPColosseumRecordVM = require("Game/PVP/Record/VM/PVPColosseumRecordVM")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ColosseumTeam = PVPColosseumDefine.ColosseumTeam
local ColosseumConstant = PVPColosseumDefine.ColosseumConstant
local ColosseumLogInfoID = PVPColosseumDefine.ColosseumLogInfoID
local ColosseumLogType = PVPColosseumDefine.ColosseumLogType
local ColosseumCrystalDestination = PVPColosseumDefine.ColosseumCrystalDestination
local ColosseumCrystalState = PVPColosseumDefine.ColosseumCrystalState
local ColosseumCrystalVFX = PVPColosseumDefine.ColosseumCrystalVFX
local ColosseumCrystalActionTimeline = PVPColosseumDefine.ColosseumCrystalActionTimeline
local ColosseumMapMarkerLayoutType = PVPColosseumDefine.ColosseumMapMarkerLayoutType
local ColosseumMapMarkerIcon = PVPColosseumDefine.ColosseumMapMarkerIcon

local ProtoCS = require ("Protocol/ProtoCS")
local ProtoRes = require ("Protocol/ProtoRes")
local CS_CMD = ProtoCS.CS_CMD
local CS_COLOSSEUM_COMBAT_CMD = ProtoCS.CS_COLOSSEUM_COMBAT_CMD
local CS_PVPCOLOSSEUM_CMD = ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD
local CD_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local ColosseumSequence = ProtoCS.ColosseumSequence
local CrystalStatus = ProtoCS.CrystalStatus
local EventType = ProtoCS.EventType
local PvPColosseumMode = ProtoCS.Game.PvPColosseum.PvPColosseumMode

local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR
local FVector = _G.UE.FVector

local EventMgr ---@type EventMgr
local PWorldMgr ---@type PWorldMgr
local PVPTeamMgr ---@type PVPTeamMgr
local RoleInfoMgr ---@type RoleInfoMgr


---@class PVPColosseumMgr : MgrBase
local PVPColosseumMgr = LuaClass(MgrBase)

function PVPColosseumMgr:OnInit()
	-- 是否初始化完成，包括关卡加载好，队伍数据拉取好，等等
	self.IsInitialized = false

	-- 是否是调试模式，输出战场内的水晶争夺相关数据
	self.isCrystalDebug_ = false

	-- 当前战场阶段
	self.CurrentSequence = ColosseumSequence.COLOSSEUM_PHASE_NONE
	-- 当前战场阶段结束时间戳
	self.SequenceEndTime = 0

	-- 比赛类型，PVP模式，练习赛/段位赛/自定赛
	self.matchType_ = PvPColosseumMode.Exercise
	-- 所属队伍索引
	self.teamIndex_ = 0

	-- 水晶冲突玩法战场数据，对战和观战通用 --

	-- 水晶角色
	self.crystalEntityID_ = 0
	self.crystal_ = nil ---@type ABaseCharacter
	self.crystalAnimComp_ = nil
	-- 水晶动作
	self.ATLId = nil
	-- 水晶圆环特效
	self.crystalCircleVfxId_ = 0
	self.crystalCircleEffectID_ = 0
	-- 水晶圆环特效冷却计时器
	self.crystalCircleVfxCooldownTimer_ = 0
	-- 水晶解除绑定时间戳
	self.crystalReleaseBindingTime_ = 0

	-- 后台下发的水晶原始数据
	self.crystalStatus_ = CrystalStatus.CRYSTAL_STATUS_BINDING
	-- 水晶目的地。后台下发的水晶原始数据，前台使用时转化下，水晶数据和表现这里参考端游的实现
	self.crystalDestination_ = ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_MAX
	-- 水晶状态
	self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_INACTIVE

	-- 中心节点当前到达率（‰）。正值代表队伍1攻击方，负值代表队伍2攻击方
	self.crystalReachProgress_ = 0
	-- 队伍最长到达率（‰）。水晶最长推进进度千分比
	self.crystalLongestReachProgress_ = {0, 0}
	-- 水晶范围内玩家人数。手游这块数据不显示，后台同步时省掉了
	self.crystalCountInRange_ = {0, 0}
	-- 攻击检查点当前突破率（‰）。端游是用百分比，手游改用千分比
	self.offenseCheckPointProgress_ = {0, 0}

	-- 地区事件日志类型
	self.areaEventLogType_ = 0
	-- 地区活动结束时间戳
	self.areaEventTime_ = 0


	-- 加时赛劣势方队伍索引
	self.OvertimeBehindTeamIndex = 0
	-- 加时赛劣势方胜利的推进目标点光圈特效
	self.TargetCircleEffectID = nil


	-- 是否第一次进入水晶圈内，给出提示
	self.bFirstEnteCrystalCircle = true
	-- 是否第一次进入检查点突破，给出提示
	self.bFirstEnterCheckPointBreaking = true
	-- 是否显示准备阶段结束倒计时
	self.bShowCountDownForWaitTime = false
	-- 是否显示主赛程结束倒计时
	self.bShowCountDownForRegularTime = false
	-- 是否播放水晶解除绑定表现
	self.bHasPlayReleaseBindingAnim = false
	-- 是否显示队伍1通过检查点，重连后避免重复显示，最好是改由后台来触发
	self.bShowPassCheckPointTeam1 = false
	self.bShowPassCheckPointTeam2 = false
end

---初始化战场相关数据
function PVPColosseumMgr:ResetData()
	self.crystalStatus_ = CrystalStatus.CRYSTAL_STATUS_BINDING
	self.crystalDestination_ = ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_MAX
	self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_INACTIVE

	self.crystalReachProgress_ = 0
	self.crystalLongestReachProgress_ = {0, 0}
	self.crystalCountInRange_ = {0, 0}
	self.offenseCheckPointProgress_ = {0, 0}

	self.areaEventLogType_ = 0
	self.areaEventTime_ = 0

	self.OvertimeBehindTeamIndex = 0
	self.TargetCircleEffectID = nil

	self.bFirstEnteCrystalCircle = true
	self.bFirstEnterCheckPointBreaking = true
	self.bShowCountDownForWaitTime = false
	self.bShowCountDownForRegularTime = false
	self.bHasPlayReleaseBindingAnim = false
	self.bShowPassCheckPointTeam1 = false
	self.bShowPassCheckPointTeam2 = false

	self.CurrentSequence = ColosseumSequence.COLOSSEUM_PHASE_NONE
	self.SequenceEndTime = 0
	self.matchType_ = PvPColosseumMode.Exercise
	self.teamIndex_ = 0

	self.crystalEntityID_ = 0
	self.crystal_ = nil
	self.crystalAnimComp_ = nil
	self.ATLId = nil
	self.crystalCircleVfxId_ = 0
	self.crystalCircleEffectID_ = 0
end

function PVPColosseumMgr:OnBegin()
	EventMgr = _G.EventMgr
	PWorldMgr = _G.PWorldMgr
	PVPTeamMgr = _G.PVPTeamMgr
	RoleInfoMgr = _G.RoleInfoMgr

	_G.UE.FTickHelper.GetInst():SetTickIntervalByFrame(self.TickTimerID, 10)
    _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
end

function PVPColosseumMgr:OnEnd()

end

function PVPColosseumMgr:OnShutdown()

end

function PVPColosseumMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLOSSEUM_COMBAT, CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_BUNDLE, self.OnNetMsgColosseumBundle)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLOSSEUM_COMBAT, CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_SEQUENCE, self.OnNetMsgColosseumSequence)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLOSSEUM_COMBAT, CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_TEAM, self.OnNetMsgColosseumTeam)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLOSSEUM_COMBAT, CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_CRYSTAL, self.OnNetMsgColosseumCrystal)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLOSSEUM_COMBAT, CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_EVENT_NOTIFY, self.OnNetMsgColosseumEventNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COLOSSEUM_COMBAT, CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_VISION_INFO, self.OnNetMsgColosseumVisionInfo)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, CS_PVPCOLOSSEUM_CMD.GAME_RESULT, self.OnNetMsgColosseumGameResult)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, CS_PVPCOLOSSEUM_CMD.GAME_RESULT_LIKE, self.OnNetMsgColosseumGameResultLike)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PvPColosseum, CS_PVPCOLOSSEUM_CMD.GET_LIKE_INFO, self.OnNetMsgColosseumGetLikeInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CD_PWORLD_CMD.CS_PWORLD_CMD_SCENE_MEMBER_LEAVE, self.OnNetMsgTeamMemberLeave)
end

function PVPColosseumMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
	self:RegisterGameEvent(EventID.PWorldReady, self.OnGameEventPWorldReady)

	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)

	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)

	self:RegisterGameEvent(EventID.SceneTeamQueryFinish, self.OnGameEventSceneTeamQueryFinish) -- 断线重连后隐藏已离开玩家点赞按钮
end

function PVPColosseumMgr:OnGameEventPWorldMapEnter(Params)
	if not self:IsPVPColosseumPWorld() then
		return
	end

	if Params.bReconnect then
		return
	end

	self:ResetBattle()
end

function PVPColosseumMgr:OnGameEventPWorldExit(LeavePWorldResID, LeaveMapResID)
	local PWorldTableCfg = PWorldMgr:GetLastPWorldTableCfg()
	if PWorldTableCfg and PWorldTableCfg.SubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_COLOSSEUM then
		self:ResetBattle()
		self:LeaveResultState()
	end
end

function PVPColosseumMgr:OnGameEventPWorldReady()
	if not self:IsPVPColosseumPWorld() then
		return
	end

	self:SendColosseumBundle()
end

function PVPColosseumMgr:OnGameEventRoleLoginRes(Params)
	if not self:IsPVPColosseumPWorld() then
		return
	end

	if Params.bReconnect then
		-- 重连后走副本流程，会触发PWorldReady
		--self:SendColosseumBundle()

		-- 断线重连后恢复pvp主界面，Login去掉了统一处理
		BusinessUIMgr:ShowMainPanel(UIViewID.PVPColosseumMain)
	end
end

function PVPColosseumMgr:OnGameEventVisionEnter(Params)
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1
	local ResID = Params.IntParam2
	if ActorUtil.IsMonster(EntityID) and ResID == ColosseumConstant.EXD_BNPC_BASE_MKS_CRYSTAL then
		self.crystalEntityID_ = EntityID
		self.crystal_ = ActorUtil.GetActorByEntityID(EntityID)
		self.crystalAnimComp_ = self.crystal_:GetAnimationComponent()
	end
end

function PVPColosseumMgr:OnGameEventVisionLeave(Params)
	if nil == Params then
		return
	end

	local ActorType = Params.IntParam1
	local ResID = Params.IntParam2
	if ActorType == _G.UE.EActorType.Monster and ResID == ColosseumConstant.EXD_BNPC_BASE_MKS_CRYSTAL then
		self.crystalEntityID_ = 0
		self.crystal_ = nil
		self.crystalAnimComp_ = nil
	end
end

function PVPColosseumMgr:OnGameEventSceneTeamQueryFinish(Params)
	if PWorldMgr:CurrIsInPVPColosseum() then
		PVPColosseumRecordVM:UpdateAllLikeBtn()
	end
end

---重置战场
function PVPColosseumMgr:ResetBattle()
	FLOG_INFO("[PVPColosseumMgr:ResetBattle]")

	self:ResetData()

	PVPColosseumRecordVM:Reset()
	PVPColosseumBattleLogVM:Reset()
	_G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)

	self.IsInitialized = false
end

function PVPColosseumMgr:InitBattle()
	-- 理论上队伍数据在进副本时已经准备好。后台队伍成员CampID camp_type_fix1是星级队 camp_type_fix2是灵级队，转换成客户端队伍索引
	local myCampID = PVPTeamMgr:GetMajorCampID()
	local myTeamIndex = (myCampID == ProtoRes.camp_type.camp_type_fix1) and ColosseumTeam.COLOSSEUM_TEAM_1 or ColosseumTeam.COLOSSEUM_TEAM_2
	self.teamIndex_ = myTeamIndex
	FLOG_INFO("[PVPColosseumMgr:InitBattle] myCampID=%s, myTeamIndex=%s", myCampID, myTeamIndex)

	self:UpdateFieldSG()
end

---开启战斗
---策划案里的流程需求，和pve副本流程不同，pvp副本是后台创建时就开始计时，不是等所有玩家ready后才开始计时
function PVPColosseumMgr:StartBattle()
	if self.IsInitialized then
		return
	end

	FLOG_INFO("[PVPColosseumMgr:StartBattle]")

	self:InitBattle()

	PVPColosseumHeaderVM:BattleStart()
	PVPColosseumBattleLogVM:BattleStart()
	_G.UE.FTickHelper.GetInst():SetTickEnable(self.TickTimerID)


	local function ShowMainUI()
		--[[
		if UIViewMgr:IsViewVisible(UIViewID.PVPColosseumIntroduction) then
			UIViewMgr:HideView(UIViewID.PVPColosseumIntroduction)
		end
		--]]

		BusinessUIMgr:ShowMainPanel(UIViewID.PVPColosseumMain)

		if self.CurrentSequence == ColosseumSequence.COLOSSEUM_PHASE_WAIT then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.TeamMemberNum4)
		end

		local function ShowStartTips()
			-- 当前已进入对战区域，人物属性和技能已替换为对战专用版
			MsgTipsUtil.ShowTipsByID(338001)

			-- 进入PVP地图新手引导提示
			local function ShowPVPMapTutorial(Params)
				local EventParams = _G.EventMgr:GetEventParams()
				EventParams.Type = TutorialDefine.TutorialConditionType.PVPMap
				EventParams.Param1 = PWorldMgr:GetCurrPWorldResID()
				_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
			end

			local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowPVPMapTutorial, Params = {}}
			_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
		end

		self:RegisterTimer(ShowStartTips, 3)
	end

	local function ShowIntroductionUI()
		--UIViewMgr:ShowView(UIViewID.PVPColosseumIntroduction)
	end

	local bShowIntroduction = false
	if self.CurrentSequence == ColosseumSequence.COLOSSEUM_PHASE_WAIT then
		local EndTime = self.SequenceEndTime
		local RemainTime = EndTime - TimeUtil.GetServerTimeMS()
		RemainTime = math.floor(RemainTime / 1000)
		if RemainTime > 15 then
			--ShowIntroductionUI()
			bShowIntroduction = true
		end
	end

    if not bShowIntroduction then
		ShowMainUI()
	else
		--self:RegisterTimer(ShowMainUI, 10)
		local function SequenceFinishedCallback()
			ShowMainUI()
		end
		local CurrMapID = PWorldMgr:GetCurrMapResID()
		local CurrMapLayouts = PVPColosseumDefine.ColosseumMapLayouts[CurrMapID]
		if nil == CurrMapLayouts then return end
		_G.StoryMgr:PlaySequenceByPath(CurrMapLayouts.SequencePath, SequenceFinishedCallback)
	end

	self.IsInitialized = true
end

---结束战斗
---正常比赛结束的表现
function PVPColosseumMgr:FinishBattle(OldSequence)
	FLOG_INFO("[PVPColosseumMgr:FinishBattle]")

	self:EnterResultState()

	-- 结算时屏蔽相关UI --
	self:HideCountDownTime()
	if UIViewMgr:IsViewVisible(UIViewID.InfoPVPReviveTimeTips) then
        UIViewMgr:HideView(UIViewID.InfoPVPReviveTimeTips)
    end
	PVPColosseumHeaderVM:SetHeaderPanelVisible(false)

	if OldSequence == ColosseumSequence.COLOSSEUM_PHASE_REGULAR
		and self:GetCrystalReachProgressUInt() == ColosseumConstant.COLOSSEUM3_CHECK_POINT_PROGRESS_PERMIL * 2 then
		-- 上阶段主赛程，水晶胜利表现，加时赛没有此表现
		self:PlayCrystalAnim(5)
	end

	PVPColosseumBattleLogVM:Reset()
	_G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
end


--region 协议处理

---请求战场全量数据，切地图后或者断线重连后调用
function PVPColosseumMgr:SendColosseumBundle()
	local ColosseumCombatBundleReq = {}

    local MsgBody = {}
    local SubMsgID = CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_BUNDLE
    MsgBody.Cmd = SubMsgID
    MsgBody.bundle_req = ColosseumCombatBundleReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_COLOSSEUM_COMBAT, SubMsgID, MsgBody)
end

---合包处理
function PVPColosseumMgr:OnNetMsgColosseumBundle(MsgBody)
    local ColosseumCombatBundleRsp = MsgBody.bundle_rsp
    if ColosseumCombatBundleRsp == nil then return end

	for _, ColosseumCombatRsp in ipairs(ColosseumCombatBundleRsp.colosseum_combat_rsp) do
		local SubCmd = ColosseumCombatRsp.Cmd
		if SubCmd == CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_SEQUENCE then
			self:OnNetMsgColosseumSequence(ColosseumCombatRsp)
		elseif SubCmd == CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_TEAM then
			self:OnNetMsgColosseumTeam(ColosseumCombatRsp)
		elseif SubCmd == CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_CRYSTAL then
			self:OnNetMsgColosseumCrystal(ColosseumCombatRsp)
		elseif SubCmd == CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_EVENT_NOTIFY then
			self:OnNetMsgColosseumEventNotify(ColosseumCombatRsp)
		elseif SubCmd == CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_VISION_INFO then
			self:OnNetMsgColosseumVisionInfo(ColosseumCombatRsp)
		end
	end
end

---更新游戏阶段
function PVPColosseumMgr:OnNetMsgColosseumSequence(MsgBody)
    local ColosseumCombatSequenceRsp = MsgBody.sequence_rsp
    if ColosseumCombatSequenceRsp == nil then return end

	local sequence = ColosseumCombatSequenceRsp.sequence
	local OldSequence = self.CurrentSequence
	self.CurrentSequence = sequence

	local IsSuddenDeath = false -- 是否是加时赛
	local EndTime = 0

	if sequence == ColosseumSequence.COLOSSEUM_PHASE_INIT then
		-- 初始化阶段

	elseif sequence == ColosseumSequence.COLOSSEUM_PHASE_WAIT then
		-- 准备阶段，出生点等待
		local ColosseumSequenceWaitRsp = ColosseumCombatSequenceRsp.wait
		EndTime = ColosseumSequenceWaitRsp.wait_end_time

	elseif sequence == ColosseumSequence.COLOSSEUM_PHASE_REGULAR then
		-- 主赛程阶段
		local ColosseumSequenceRegularRsp = ColosseumCombatSequenceRsp.regular
		EndTime = ColosseumSequenceRegularRsp.regular_end_time
		-- 水晶解绑时间
		self:SetCrystalReleaseBindingTime(ColosseumSequenceRegularRsp.crystal_release_time)
		-- 战斗开始提示 338005，改由关卡事件驱动

	elseif sequence == ColosseumSequence.COLOSSEUM_PHASE_OVERTIME then
		-- 加时赛阶段
		IsSuddenDeath = true
		local ColosseumSequenceOvertimeRsp = ColosseumCombatSequenceRsp.overtime
		EndTime = ColosseumSequenceOvertimeRsp.overtime_end_time
		-- 进入加时阶段提示 338006，改由关卡事件驱动
		self:SetOvertimeInfo(ColosseumSequenceOvertimeRsp)

	elseif sequence == ColosseumSequence.COLOSSEUM_PHASE_RESULT then
		-- 结算信息展示阶段
		local ColosseumSequenceResultRsp = ColosseumCombatSequenceRsp.result
		EndTime = ColosseumSequenceResultRsp.show_end_time
	end

	self.SequenceEndTime = EndTime
	-- 战场倒计时
    PVPColosseumHeaderVM:SetCountDownTime(EndTime, IsSuddenDeath)

	if not self.IsInitialized then
		self:StartBattle()
	end

	if sequence == ColosseumSequence.COLOSSEUM_PHASE_RESULT then
		self:FinishBattle(OldSequence)
		self:WaitGameResult()
	end
end

---更新局内队伍数据
function PVPColosseumMgr:OnNetMsgColosseumTeam(MsgBody)
    local ColosseumCombatTeamRsp = MsgBody.team_rsp
    if ColosseumCombatTeamRsp == nil then return end

	for _, PlayerInfo in ipairs(ColosseumCombatTeamRsp.player_info) do
		if PlayerInfo.role_id ~= 0 then
			PVPTeamMgr:UpdateRespawnTime(PlayerInfo.role_id, PlayerInfo.respawn_time)
		end
	end

	local ServerTime = TimeUtil.GetServerTimeMS()

	-- 判断我方队伍是否团灭
	local DeadMemberCount = 0
	local PlayerMemberVMList = PVPTeamMgr:GetPVPTeamVM():GetTeamMemberList()
	for i = 1, PlayerMemberVMList:Length() do
		local MemberVM = PlayerMemberVMList:Get(i) ---@type TeamMemberVM
		if MemberVM and MemberVM.RespawnTime > ServerTime then
			DeadMemberCount = DeadMemberCount + 1
		end
	end

	if DeadMemberCount > 0 and DeadMemberCount == PVPTeamMgr:GetTeamMemberCount() then
		MsgTipsUtil.ShowPVPColosseumTeamTips(LSTR(810024), true) -- "我方被团灭"
	end

	-- 判断敌方队伍是否团灭
	DeadMemberCount = 0
	local EnemyMemberVMList = PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberList()
	for i = 1, EnemyMemberVMList:Length() do
		local MemberVM = EnemyMemberVMList:Get(i) ---@type TeamMemberVM
		if MemberVM and MemberVM.RespawnTime > ServerTime then
			DeadMemberCount = DeadMemberCount + 1
		end
	end

	if DeadMemberCount > 0 and DeadMemberCount == PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberNum() then
		MsgTipsUtil.ShowPVPColosseumTeamTips(LSTR(810025), false) -- "敌方被团灭"
	end
end

---更新战场水晶数据
function PVPColosseumMgr:OnNetMsgColosseumCrystal(MsgBody)
    local ColosseumCombatCrystalRsp = MsgBody.crystal_rsp
    if ColosseumCombatCrystalRsp == nil then return end

	local Status = ColosseumCombatCrystalRsp.status
	-- 星级队，对应客户端的1队；灵极队，对应客户端的2队
	local CrystalInfo = ColosseumCombatCrystalRsp.crystal_info

	self:SetCrystalStatus(Status)

	if Status == CrystalStatus.CRYSTAL_STATUS_BINDING then
		-- 水晶绑定

	elseif Status == CrystalStatus.CRYSTAL_STATUS_RELEASE then
		-- 模拟触发事件通知：水晶解除绑定
		PVPColosseumBattleLogVM:HideCountDownInfo()
		PVPColosseumBattleLogVM:PushLogEvent(ColosseumLogType.MKS_LOG_TYPE_CRYSTAL_UNLOCKED)

	elseif Status == CrystalStatus.CRYSTAL_STATUS_DESTINATION_CENTER then
		-- 往水晶出生点移动
		self:SetCrystalReachProgress(ColosseumCombatCrystalRsp.crystal_ratio)
		self:SetCrystalDestination(ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_CENTER)

	elseif Status == CrystalStatus.CRYSTAL_STATUS_IDLE then
		-- 原地待机
		self:SetCrystalDestination(ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_CENTER)

	elseif Status == CrystalStatus.CRYSTAL_STATUS_DESTINATION_DEADLOCK then
		-- 争夺
		self:SetCrystalDestination(ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_DEADLOCKED)

	elseif Status == CrystalStatus.CRYSTAL_STATUS_DESTINATION_ASTRA then
		-- 往星极队移动，即水晶往左移动，下发的信息里是灵极队的护送进度
		self:SetCrystalReachProgress(ColosseumCombatCrystalRsp.crystal_ratio)
		if CrystalInfo then
			self:SetCrystalLongestReachProgress(ColosseumTeam.COLOSSEUM_TEAM_2, CrystalInfo.escort_progress)
		end
		self:SetCrystalDestination(ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_1)

	elseif Status == CrystalStatus.CRYSTAL_STATUS_DESTINATION_UMBRA then
		-- 往灵极队移动
		self:SetCrystalReachProgress(ColosseumCombatCrystalRsp.crystal_ratio)
		if CrystalInfo then
			self:SetCrystalLongestReachProgress(ColosseumTeam.COLOSSEUM_TEAM_1, CrystalInfo.escort_progress)
		end
		self:SetCrystalDestination(ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_2)

	elseif Status == CrystalStatus.CRYSTAL_STATUS_ASTRA_BREAKING then
		-- 星极队突破中，即水晶推进到灵极队半场，下发的信息是星极队的突破进度
		if CrystalInfo then
			self:SetOffenseCheckPointProgress(ColosseumTeam.COLOSSEUM_TEAM_1, CrystalInfo.breaking_progress)

			if CrystalInfo.breaking_progress == ColosseumConstant.COLOSSEUM3_OFFENSE_CHECK_POINT_BROKEN then
				-- 模拟触发事件通知：1队突破完成
				if (not self.bShowPassCheckPointTeam1) then
					self.bShowPassCheckPointTeam1 = true
					PVPColosseumBattleLogVM:PushLogEvent(ColosseumLogType.MKS_LOG_TYPE_PASS_CHECKPOINT_TEAM_1)
				end
				EventMgr:SendEvent(EventID.PVPColosseumCheckPointUpdate)
			end
		end

	elseif Status == CrystalStatus.CRYSTAL_STATUS_UMBRA_BREAKING then
		-- 灵极队突破中
		if CrystalInfo then
			self:SetOffenseCheckPointProgress(ColosseumTeam.COLOSSEUM_TEAM_2, CrystalInfo.breaking_progress)

			if CrystalInfo.breaking_progress == ColosseumConstant.COLOSSEUM3_OFFENSE_CHECK_POINT_BROKEN then
				-- 模拟触发事件通知：2队突破完成
				if (not self.bShowPassCheckPointTeam2) then
					self.bShowPassCheckPointTeam2 = true
					PVPColosseumBattleLogVM:PushLogEvent(ColosseumLogType.MKS_LOG_TYPE_PASS_CHECKPOINT_TEAM_2)
				end
				EventMgr:SendEvent(EventID.PVPColosseumCheckPointUpdate)
			end
		end
	end

end

---战场事件通知
function PVPColosseumMgr:OnNetMsgColosseumEventNotify(MsgBody)
    local ColosseumCombatEventNotifyRsp = MsgBody.event_notify_rsp
    if ColosseumCombatEventNotifyRsp == nil then return end

	local CurrEventType = ColosseumCombatEventNotifyRsp.type
	if CurrEventType == EventType.EVENT_TYPE_ERUPTION_WARNING then
		local ColosseumEventTime = ColosseumCombatEventNotifyRsp.event_time
		-- 火山喷发预警倒计时
		self:SetAreaEventTime(ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_ERUPTION_EXEC, ColosseumEventTime.timestamp)
		local function EventExecute()
			-- 模拟触发事件通知：火山喷发
			PVPColosseumBattleLogVM:HideCountDownInfo()
			PVPColosseumBattleLogVM:PushLogEvent(ColosseumLogType.MKS_LOG_TYPE_ERUPTION_EXEC)
		end
		local RemainTime = ColosseumEventTime.timestamp - TimeUtil.GetServerTimeMS()
		if self.AreaEventTimeID then
			self:UnRegisterTimer(self.AreaEventTimeID)
			self.AreaEventTimeID = nil
		end
		self.AreaEventTimeID = self:RegisterTimer(EventExecute, RemainTime / 1000)

	elseif CurrEventType == EventType.EVENT_TYPE_GUST_WARNING then
		local ColosseumEventTime = ColosseumCombatEventNotifyRsp.event_time
		-- 暴风预警倒计时
		self:SetAreaEventTime(ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_TORNADO_EXEC, ColosseumEventTime.timestamp)
		local function EventExecute()
			-- 模拟触发事件通知：暴风
			PVPColosseumBattleLogVM:HideCountDownInfo()
			PVPColosseumBattleLogVM:PushLogEvent(ColosseumLogType.MKS_LOG_TYPE_TORNADO_EXEC)
		end
		local RemainTime = ColosseumEventTime.timestamp - TimeUtil.GetServerTimeMS()
		if self.AreaEventTimeID then
			self:UnRegisterTimer(self.AreaEventTimeID)
			self.AreaEventTimeID = nil
		end
		self.AreaEventTimeID = self:RegisterTimer(EventExecute, RemainTime / 1000)

	elseif CurrEventType == EventType.EVENT_TYPE_KO then
		-- 战场击杀
		local ColosseumEventKO = ColosseumCombatEventNotifyRsp.ko
		PVPColosseumBattleLogVM:PushLogKnockOut(ColosseumEventKO.role_id, ColosseumEventKO.target_role_id, ColosseumEventKO.ko_num)

	elseif CurrEventType == EventType.EVENT_TYPE_CRYSTAL_LEAVE_WARNING then
		-- 劣势方离开水晶范围预警
		if self.teamIndex_ == self.OvertimeBehindTeamIndex then
			-- 我方是劣势方才显示出圈判输倒计时
			self:ShowCountDownForOverTime(ColosseumConstant.OverTimeCountDown)
		end

	elseif CurrEventType == EventType.EVENT_TYPE_NOT_ENOUGH_PLAYERS then
		-- 参赛人员不足
		MsgTipsUtil.ShowTipsByID(338040)
	end
end

---队伍视野信息同步(也可以认为是阵营视野)
function PVPColosseumMgr:OnNetMsgColosseumVisionInfo(MsgBody)
    local ColosseumCombatVisionInfoRsp = MsgBody.vision_info_rsp
    if ColosseumCombatVisionInfoRsp == nil then return end

	-- 先清除老的视野信息，再添加新的视野信息。如果某RoleID不在下发列表里，表示不在队伍视野里
	PVPTeamMgr:ClearMemberVisionInfo()

	for _, VisionInfo in ipairs(ColosseumCombatVisionInfoRsp.vision_info) do
		PVPTeamMgr:UpdateMemberVisionInfo(VisionInfo)
	end
end

---比赛结算，由局外协议下发
function PVPColosseumMgr:OnNetMsgColosseumGameResult(MsgBody)
	if not self:IsPVPColosseumPWorld() then
		return
	end

	local PvPColosseumGameResultRsp = MsgBody.GameResultRsp
	if PvPColosseumGameResultRsp == nil then return end

	self:SetGameResult(PvPColosseumGameResultRsp)
end

---点赞玩家请求
function PVPColosseumMgr:RequestLikeRole(SceneInstID, RoleID)
    local SubMsgID = CS_PVPCOLOSSEUM_CMD.GAME_RESULT_LIKE

	local PvPColosseumLikeReq = {
		SceneInstID = SceneInstID,
		TgtRoleID = RoleID,
	}

    local MsgBody = {
		Cmd = SubMsgID,
		LikeReq = PvPColosseumLikeReq
	}
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PvPColosseum, SubMsgID, MsgBody)
end

---点赞数据请求
function PVPColosseumMgr:RequestLikeData(SceneInstID)
	if not self:IsPVPColosseumPWorld() then return end
	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_RESULT then return end
	if SceneInstID == nil then return end

    local SubMsgID = CS_PVPCOLOSSEUM_CMD.GET_LIKE_INFO

	local PvPColosseumGetLikeInfoReq = {
		GameInstID = SceneInstID,
	}

    local MsgBody = {
		Cmd = SubMsgID,
		PvPColosseumGetLikeInfoReq = PvPColosseumGetLikeInfoReq
	}
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PvPColosseum, SubMsgID, MsgBody)
end

---点赞玩家
function PVPColosseumMgr:OnNetMsgColosseumGameResultLike(MsgBody)
	if not self:IsPVPColosseumPWorld() then return end
	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_RESULT then return end

	local PvPColosseumGameResulLikeRsp = MsgBody.LikeRsp
	if PvPColosseumGameResulLikeRsp == nil then return end

	local SrcRoleID = PvPColosseumGameResulLikeRsp.SrcRoleID
	local TargetRoleID = PvPColosseumGameResulLikeRsp.TgtRoleID
	local MajorID = MajorUtil.GetMajorRoleID()
	-- 点赞者和被点赞者都能收到回包，分开处理
	if SrcRoleID == MajorID then
		RoleInfoMgr:QueryRoleSimple(TargetRoleID, function(Params, RoleVM)
			if RoleVM then
				MsgTipsUtil.ShowTipsByID(338010, nil, RoleVM.Name)
			end
		end, nil, false)
		PVPColosseumRecordVM:LikeRole(TargetRoleID)
	elseif TargetRoleID == MajorID then
		local IsLikeByTeammate = PVPTeamMgr:IsTeamMemberByRoleID(SrcRoleID)
		if IsLikeByTeammate then
			MsgTipsUtil.ShowTipsByID(338011)
		else
			MsgTipsUtil.ShowTipsByID(338012)
		end
		PVPColosseumRecordVM:GetLike(PvPColosseumGameResulLikeRsp.CurLikeNum)
	end
end

function PVPColosseumMgr:OnNetMsgColosseumGetLikeInfo(MsgBody)
	if not self:IsPVPColosseumPWorld() then return end
	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_RESULT then return end

	local Info = MsgBody.PvPColosseumGetLikeInfoRsp
	if Info.LikeNum > 0 then
		PVPColosseumRecordVM:GetLike(Info.LikeNum)
	end

	if Info.TgtLike[1] and Info.TgtLike[1] > 0 then
		PVPColosseumRecordVM:LikeRole(Info.TgtLike)
	end
end

function PVPColosseumMgr:OnNetMsgTeamMemberLeave(MsgBody)
	if not self:IsPVPColosseumPWorld() then return end
	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_RESULT then return end

	local MemberLeaveData = MsgBody.LeaveScene
    if MemberLeaveData == nil then return end

	local MajorID = MajorUtil.GetMajorRoleID()
	local RoleID = MemberLeaveData.ResID
    if MajorID == RoleID then return end

	local IsMyTeam = PVPTeamMgr:IsTeamMemberByRoleID(RoleID)
	PVPColosseumRecordVM:HideLike(IsMyTeam, RoleID)
end

--endregion


--region 协议更新战场数据

---水晶解除绑定倒计时提示
---@param EndTime number 结束时间戳
function PVPColosseumMgr:SetCrystalReleaseBindingTime(EndTime)
	self.crystalReleaseBindingTime_ = EndTime

	PVPColosseumBattleLogVM:SetCountDownInfo(ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_CRYSTAL, EndTime)
end

---区域事件倒计时提示
---@param AreaEventLogType number 区域事件日志类型
---@param EndTime number 结束时间戳
function PVPColosseumMgr:SetAreaEventTime(AreaEventLogType, EndTime)
	self.areaEventLogType_ = AreaEventLogType
	self.areaEventTime_ = EndTime

	PVPColosseumBattleLogVM:SetCountDownInfo(AreaEventLogType, EndTime)
end

---设置加时赛信息
function PVPColosseumMgr:SetOvertimeInfo(ColosseumSequenceOvertimeRsp)
	-- 后台下发加时赛优势方，0：平局，此时双方都视为劣势方，1：星极队，2：灵极队
	local dominant_team = ColosseumSequenceOvertimeRsp.dominant_team

	-- 劣势方队伍索引，后台下发的是优势方，这里转换下
	local BehindTeamIndex = 0
	if dominant_team == 0 then
		BehindTeamIndex = self.teamIndex_
	elseif dominant_team == 1 then
		BehindTeamIndex = ColosseumTeam.COLOSSEUM_TEAM_2
	elseif dominant_team == 2 then
		BehindTeamIndex = ColosseumTeam.COLOSSEUM_TEAM_1
	end
	self.OvertimeBehindTeamIndex = BehindTeamIndex

	local function ShowOvertimeTips()
		FLOG_INFO("[PVPColosseumMgr:ShowOvertimeTips] teamIndex_=%s, BehindTeamIndex=%s", self.teamIndex_, BehindTeamIndex)
		if self.teamIndex_ == BehindTeamIndex then
			-- 劣势方获胜条件提示
			MsgTipsUtil.ShowTipsByID(338003)
		else
			-- 优势方获胜条件提示
			MsgTipsUtil.ShowTipsByID(338004)
		end
	end
	-- 延迟显示，和前面进入加时赛提示错开
	self:RegisterTimer(ShowOvertimeTips, 3)

	-- 劣势方获胜需要达到的推进进度，为优势方水晶最长推进进度
	local enemyTeamIndex = self.GetOtherTeamIndex(BehindTeamIndex)
	local BehindTargetProgress = self:GetCrystalLongestReachProgress(enemyTeamIndex)
	PVPColosseumHeaderVM:SetOvertimeBehindInfo(BehindTeamIndex, BehindTargetProgress)

	-- 后台下发劣势方胜利的推进目标点
	local TargetCSPosition = ColosseumSequenceOvertimeRsp.pos
	local TargetPos = FVector(TargetCSPosition.x, TargetCSPosition.y, TargetCSPosition.z)
	if self.TargetCircleEffectID then
		EffectUtil.StopVfx(self.TargetCircleEffectID)
		self.TargetCircleEffectID = nil
	end
	self.TargetCircleEffectID = self:ShowOvertimeEffect(TargetPos)

	if dominant_team == 0 then
		-- 平局，此时双方都视为劣势方，有两个推进目标点
		TargetCSPosition = ColosseumSequenceOvertimeRsp.pos_b
		TargetPos = FVector(TargetCSPosition.x, TargetCSPosition.y, TargetCSPosition.z)
		if self.TargetCircleEffectID_B then
			EffectUtil.StopVfx(self.TargetCircleEffectID_B)
			self.TargetCircleEffectID_B = nil
		end
		self.TargetCircleEffectID_B = self:ShowOvertimeEffect(TargetPos)
	end
end

function PVPColosseumMgr:SetCrystalStatus(Value)
	self.crystalStatus_ = Value
end

function PVPColosseumMgr:SetCrystalDestination(Value)
	self.crystalDestination_ = Value
end

function PVPColosseumMgr:SetCrystalReachProgress(Value)
	self.crystalReachProgress_ = Value
end

function PVPColosseumMgr:SetCrystalLongestReachProgress(teamIndex, Value)
	if teamIndex <= ColosseumTeam.COLOSSEUM_TEAM_MAX then
		self.crystalLongestReachProgress_[teamIndex] = Value
	end
end

function PVPColosseumMgr:SetCrystalCountInRange(teamIndex, Value)
	if teamIndex <= ColosseumTeam.COLOSSEUM_TEAM_MAX then
		self.crystalCountInRange_[teamIndex] = Value
	end
end

function PVPColosseumMgr:SetOffenseCheckPointProgress(teamIndex, Value)
	if teamIndex <= ColosseumTeam.COLOSSEUM_TEAM_MAX then
		self.offenseCheckPointProgress_[teamIndex] = Value
	end
end

--endregion


--region 战场tick更新，逻辑实现参考端游

function PVPColosseumMgr.OnTick(DeltaTime)
	do
		local _ <close> = CommonUtil.MakeProfileTag("PVPColosseumMgr.OnTick")
		_G.PVPColosseumMgr:Update(DeltaTime)
	end
end

function PVPColosseumMgr:Update(DeltaTime)
	if not self:IsPVPColosseumPWorld() then
        return
    end
	if not self.IsInitialized then
		return
	end

	self:OnTimerCountDown()

	if self.crystal_ == nil then
		return
	end
	self.crystalCircleVfxCooldownTimer_ = self.crystalCircleVfxCooldownTimer_ - DeltaTime
	if self.crystalCircleVfxCooldownTimer_ <= 0 then
		self.crystalCircleVfxCooldownTimer_ = 0
	end
	do
		local _ <close> = CommonUtil.MakeProfileTag("PVPColosseumMgr.OnTick_ColosseumParam")
		self:UpdateCrystal()
	end

	self:OutputCrystalDebugInfo()
	self:CheckMajorInCrystalCircle()
	self:CheckCountDownForOverTime()
end

---更新水晶
function PVPColosseumMgr:UpdateCrystal()
	local vfxId = 0
	local oldState = self.crystalState_

	if self.CurrentSequence < ColosseumSequence.COLOSSEUM_PHASE_REGULAR or self.crystalStatus_ == CrystalStatus.CRYSTAL_STATUS_BINDING then
		-- 拘束中
		self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_INACTIVE
		vfxId = ColosseumConstant.EXD_VFX_MKS_CRYSTAL_INACTIVE

	elseif self.crystalCircleVfxCooldownTimer_ == 0 then
		local teamIndex = self.teamIndex_
		local enemyTeamIndex = self.GetOtherTeamIndex(teamIndex)
		local crystalReachProgress = self:GetCrystalReachProgress()

		--[[
		-- 标准范围内人数差。正为队伍1领先，负为队伍2领先
		local crystalDiffInRange = self:GetCrystalCountInRange(ColosseumTeam.COLOSSEUM_TEAM_1) - self:GetCrystalCountInRange(ColosseumTeam.COLOSSEUM_TEAM_2)
		-- 我方队伍是否在标准范围内以人数差领先。手游这里改用后台下发的是否突破中来判断，不用人数差来判断
		local crystalDiffInRangeLead = false
		if (teamIndex == ColosseumTeam.COLOSSEUM_TEAM_1 and crystalDiffInRange > 0)
			or (teamIndex == ColosseumTeam.COLOSSEUM_TEAM_2 and crystalDiffInRange < 0) then
			crystalDiffInRangeLead = true
		end
		-- 敌方队伍是否在标准范围内以人数差领先
		local crystalDiffInRangeEnemyLead = false
		if (enemyTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_1 and crystalDiffInRange > 0)
			or (enemyTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_2 and crystalDiffInRange < 0) then
			crystalDiffInRangeEnemyLead = true
		end
		--]]

		-- 攻击检查点上队伍索引
		local teamIndexOnOffenseCheckPoint = 0
		--[[
		if (crystalReachProgress ~= 0 and self:GetCrystalReachProgressUInt() == ColosseumConstant.COLOSSEUM3_CHECK_POINT_PROGRESS_PERMIL) then
			if crystalReachProgress > 0 then
				teamIndexOnOffenseCheckPoint = ColosseumTeam.COLOSSEUM_TEAM_1
			elseif crystalReachProgress < 0 then
				teamIndexOnOffenseCheckPoint = ColosseumTeam.COLOSSEUM_TEAM_2
			end
		end
		--]]
		if self.crystalStatus_ == CrystalStatus.CRYSTAL_STATUS_ASTRA_BREAKING then
			teamIndexOnOffenseCheckPoint = ColosseumTeam.COLOSSEUM_TEAM_1
		elseif self.crystalStatus_ == CrystalStatus.CRYSTAL_STATUS_UMBRA_BREAKING then
			teamIndexOnOffenseCheckPoint = ColosseumTeam.COLOSSEUM_TEAM_2
		end

		if (teamIndexOnOffenseCheckPoint == teamIndex and self:GetOffenseCheckPointProgress(teamIndex) < ColosseumConstant.COLOSSEUM3_OFFENSE_CHECK_POINT_BROKEN) then
			-- 我方攻击点突破中
			vfxId = ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ALLY
			self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_CHECK_POINT_BREAKING

			if self.bFirstEnterCheckPointBreaking then
				self.bFirstEnterCheckPointBreaking = false
				-- 当水晶战术点内我方人数大于敌方时，突破进度才会增长
				MsgTipsUtil.ShowTipsByID(338002)
			end

		elseif (teamIndexOnOffenseCheckPoint == enemyTeamIndex and self:GetOffenseCheckPointProgress(enemyTeamIndex) < ColosseumConstant.COLOSSEUM3_OFFENSE_CHECK_POINT_BROKEN) then
			-- 敌方攻击点突破中
			vfxId = ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ENEMY
			self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_CHECK_POINT_BREAKING

		else
			local crystalDestination = self:GetCrystalDestination()
			if (crystalDestination == ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_CENTER) then
				-- 中心待机/中心移动中
				vfxId = ColosseumConstant.EXD_VFX_MKS_CRYSTAL_IDLE
				self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_NEUTRAL

			elseif (crystalDestination == ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_DEADLOCKED) then
				-- 膠着中
				vfxId = ColosseumConstant.EXD_VFX_MKS_CRYSTAL_IDLE
				self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_DEADLOCKED

			elseif (crystalDestination == ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_1 and teamIndex == ColosseumTeam.COLOSSEUM_TEAM_2)
				or (crystalDestination == ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_2 and teamIndex == ColosseumTeam.COLOSSEUM_TEAM_1) then
				-- 我方攻击移动中
				vfxId = ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ALLY
				if (self:GetCrystalReachProgressUInt() == self:GetCrystalLongestReachProgress(teamIndex)) then
					self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_LONGEST
				else
					self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY
				end
				if self.crystalState_ ~= oldState then
					MsgTipsUtil.ShowPVPColosseumTeamTips(LSTR(810021), true) -- "我方正在运送水晶"
				end

			elseif (crystalDestination == ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_1 and teamIndex == ColosseumTeam.COLOSSEUM_TEAM_1)
				or (crystalDestination == ColosseumCrystalDestination.COLOSSEUM3_CRYSTAL_DESTINATION_TEAM_2 and teamIndex == ColosseumTeam.COLOSSEUM_TEAM_2) then
				-- 敌方攻击移动中
				vfxId = ColosseumConstant.EXD_VFX_MKS_CRYSTAL_ENEMY
				if (self:GetCrystalReachProgressUInt() == self:GetCrystalLongestReachProgress(enemyTeamIndex)) then
					self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_LONGEST
				else
					self.crystalState_ = ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY
				end
				if self.crystalState_ ~= oldState then
					MsgTipsUtil.ShowPVPColosseumTeamTips(LSTR(810022), false) -- "敌方正在运送水晶"
				end
			end
		end

	else
		vfxId = self.crystalCircleVfxId_
	end

	self:UpdateCrystalEffect(vfxId)
	self:UpdateCrystalAnim()
	-- 更新战场态势UI
	PVPColosseumHeaderVM:UpdateVM()
	if self.crystalState_ ~= oldState then
		-- 更新小地图水晶
		EventMgr:SendEvent(EventID.PVPColosseumCrystalStateUpdate)
	end
end

---更新水晶圆环特效
function PVPColosseumMgr:UpdateCrystalEffect(vfxId)
	if vfxId > 0 then
		-- 更新特效
		if self.crystalCircleVfxId_ ~= vfxId then
			self.crystalCircleVfxCooldownTimer_ = ColosseumConstant.CRYSTAL_CIRCLE_VFX_COOLDOWN_TIME

			if self.crystalCircleEffectID_ then
				EffectUtil.StopVfx(self.crystalCircleEffectID_)
				self.crystalCircleEffectID_ = 0
			end

			if self.crystal_ == nil then
				return
			end
			local VfxParameter = _G.UE.FVfxParameter()
			VfxParameter.VfxRequireData.EffectPath = ColosseumCrystalVFX[vfxId]
			--VfxParameter.VfxRequireData.VfxTransform = self.crystal_:FGetActorTransform()
			VfxParameter.VfxRequireData.bAlwaysSpawn = true

			if vfxId == ColosseumConstant.EXD_VFX_MKS_CRYSTAL_INACTIVE then
				-- 水晶锁定特效，加一个向下偏移，贴合中间平台柱子
				local OffsetTransform = _G.UE.FTransform()
				OffsetTransform:SetLocation(_G.UE.FVector(0, 0, -80))
				VfxParameter.OffsetTransform = OffsetTransform
			end

			VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_AMonsterCharacter
			local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
            VfxParameter:SetCaster(self.crystal_, 0, AttachPointType_Body, 0)
			self.crystalCircleEffectID_ = EffectUtil.PlayVfx(VfxParameter)

			self.crystalCircleVfxId_ = vfxId

			-- 水晶圆环特效切换时，播放对应音效
			AudioUtil.LoadAndPlaySoundEvent(self.crystalEntityID_, PVPColosseumDefine.AudioPath[vfxId], true)
		end
	else
		-- 删除特效
		self.crystalCircleVfxId_ = 0
		if self.crystalCircleEffectID_ then
			EffectUtil.StopVfx(self.crystalCircleEffectID_)
			self.crystalCircleEffectID_ = 0
		end
	end
end

---更新水晶模型动作
function PVPColosseumMgr:UpdateCrystalAnim()
	local newATLId = self.ATLId
	local crystalState = self:GetCrystalState()
	if crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_INACTIVE then
		newATLId = 0
	elseif crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_NEUTRAL
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_DEADLOCKED then
		newATLId = 1
	elseif crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_LONGEST
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_CHECK_POINT_BREAKING then
		newATLId = 3
	elseif crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_LONGEST
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_CHECK_POINT_BREAKING then
		newATLId = 2
	end

	if (self.ATLId ~= newATLId) then
		self.ATLId = newATLId
		self:PlayCrystalAnim(newATLId)
	end
end

function PVPColosseumMgr:PlayCrystalAnim(ATLId)
	if self.crystal_ == nil then
		return
	end
	if self.crystalAnimComp_ == nil then
		self.crystalAnimComp_ = self.crystal_:GetAnimationComponent()
	end
	if self.crystalAnimComp_ then
		local ATLFileName = ColosseumCrystalActionTimeline[ATLId]
		local ActionTimelinePath = self.crystalAnimComp_:GetActionTimeline(ATLFileName)
		FLOG_INFO("[PVPColosseumMgr:PlayCrystalAnim] play crystal animation ATLId=%d, ActionTimelinePath=%s", ATLId, ActionTimelinePath)
		self.crystalAnimComp_:PlayAnimationCallBack(ActionTimelinePath, nil)
	end
end

---输出水晶调试信息
function PVPColosseumMgr:OutputCrystalDebugInfo()
	if not self.isCrystalDebug_ then
		return
	end

	local statusName = "unknown"
	for name, value in pairs(CrystalStatus) do
		if self.crystalStatus_ == value then
			statusName = name
			break
		end
	end
	FLOG_INFO("----STATUS: %s", statusName)

	if (self.CurrentSequence > ColosseumSequence.COLOSSEUM_PHASE_WAIT) then
		local stateName = "unknown"
		for name, value in pairs(ColosseumCrystalState) do
			if self.crystalState_ == value then
				stateName = name
				break
			end
		end
		FLOG_INFO("STATE: %s", stateName)
		FLOG_INFO("CURENT: %.1f%%", self.crystalReachProgress_ * 0.1)
		FLOG_INFO("TEAM1 SCORE: %.1f%%, CT: %.0f%%", self.crystalLongestReachProgress_[1] * 0.1, self.offenseCheckPointProgress_[1] * 0.1)
		FLOG_INFO("TEAM2 SCORE: %.1f%%, CT: %.0f%%", self.crystalLongestReachProgress_[2] * 0.1, self.offenseCheckPointProgress_[2] * 0.1)
		--FLOG_INFO("COUNT IN RANGE: %d vs %d", self.crystalCountInRange_[1], self.crystalCountInRange_[2])
	end
end

---检查主角是否在水晶圈内，给出提示
function PVPColosseumMgr:CheckMajorInCrystalCircle()
	if not self.bFirstEnteCrystalCircle then
		return
	end
	if self.crystalState_ == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_INACTIVE then
		return
	end

	if self.crystal_ == nil then
		return
	end
	local MajorActor = MajorUtil.GetMajor()
	if MajorActor == nil  then
		return
	end

	local MajorPos = MajorActor:FGetActorLocation(_G.UE.EXLocationType.ServerLoc)
	local CrystalPos = self.crystal_:FGetActorLocation(_G.UE.EXLocationType.ServerLoc)
	local Distance = FVector.Dist(MajorPos, CrystalPos) / 100
	if Distance < ColosseumConstant.CrystalCircleDistance then
		self.bFirstEnteCrystalCircle = false
		MsgTipsUtil.ShowPVPColosseumTeamTips(LSTR(810023), true) -- "圈内仅有我方玩家，水晶才会移动"
	end
end

---检查加时赛阶段，劣势方出圈判输倒计时的隐藏，倒计时显示仍由后台下发
function PVPColosseumMgr:CheckCountDownForOverTime()
	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_OVERTIME then
		return
	end

	-- 我方是劣势方才显示出圈判输倒计时
	if self.teamIndex_ ~= self.OvertimeBehindTeamIndex then
		return
	end

	-- 根据水晶状态判断劣势方是否在水晶圈内，争夺中和往优势方移动这两个状态是在圈里，其他状态认为在圈外
	local IsInCrystalCircle = false
	if self.crystalStatus_ == CrystalStatus.CRYSTAL_STATUS_DESTINATION_DEADLOCK then
		IsInCrystalCircle = true
	elseif self.crystalStatus_ == CrystalStatus.CRYSTAL_STATUS_DESTINATION_ASTRA
		and self.OvertimeBehindTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_2 then
		IsInCrystalCircle = true
	elseif self.crystalStatus_ == CrystalStatus.CRYSTAL_STATUS_DESTINATION_UMBRA
		and self.OvertimeBehindTeamIndex == ColosseumTeam.COLOSSEUM_TEAM_1 then
		IsInCrystalCircle = true
	end

	if IsInCrystalCircle then
		self:HideCountDownTime()
	end
end

--endregion


--region 战场定时更新，主要处理一些倒计时类型
-- 优化：可以考虑将从tick去掉，换成定时器，0.5秒更新一次

function PVPColosseumMgr:OnTimerCountDown()
	self:CountDownForCrystalReleaseBinding()
	self:CountDownForWaitTime()
	self:CountDownForRegularTime()
end

---水晶解除绑定倒计时
function PVPColosseumMgr:CountDownForCrystalReleaseBinding()
	if (self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_REGULAR) then
		return
	end

	if self.bHasPlayReleaseBindingAnim then
		return
	end

	local EndTime = self.crystalReleaseBindingTime_
    if (EndTime == nil or EndTime == 0) then
        return
    end
    local RemainTime = EndTime - TimeUtil.GetServerTimeMS()
	local RemainSec = RemainTime / 1000
	if RemainSec <= 5.5 then
		-- 水晶解除绑定动作表现提前播放，动作播放完正好后台下发解除绑定。动画资源时长5.2秒
		if (not self.bHasPlayReleaseBindingAnim) then
			self.bHasPlayReleaseBindingAnim = true
			self:PlayCrystalAnim(4)

			local function KillInActiveEffect()
				if self.crystalCircleEffectID_ then
					EffectUtil.KickTriggerByID(self.crystalCircleEffectID_, 2)
				end
			end
			-- 解除绑定动作播放，3.7+0.5秒后Kill锁定特效，解绑动作里的特效也是在3.7秒后Kill，保持同步
			self:RegisterTimer(KillInActiveEffect, 4.2)
		end
	end
end

---准备阶段结束倒计时
function PVPColosseumMgr:CountDownForWaitTime()
	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_WAIT then
		return
	end

    local EndTime = self.SequenceEndTime
    if (EndTime == nil or EndTime == 0) then
        return
    end
    local RemainTime = EndTime - TimeUtil.GetServerTimeMS()
    local RemainSec = RemainTime / 1000
	local CountDownTime = 5
    if RemainSec <= CountDownTime and RemainSec > 1 then
        if (not self.bShowCountDownForWaitTime) then
			self.bShowCountDownForWaitTime = true
            self:ShowCountDownForWaitTime(CountDownTime)
        end
    end
end

---主赛程结束倒计时
function PVPColosseumMgr:CountDownForRegularTime()
	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_REGULAR then
		return
	end

    local EndTime = self.SequenceEndTime
    if (EndTime == nil or EndTime == 0) then
        return
    end
    local RemainTime = EndTime - TimeUtil.GetServerTimeMS()
    local RemainSec = RemainTime / 1000
	local CountDownTime = 10
    if RemainSec <= CountDownTime and RemainSec > 1 then
		if (not self.bShowCountDownForRegularTime) then
			self.bShowCountDownForRegularTime = true
			self:ShowCountDownForRegularTime(CountDownTime)
		end
    end
end

--endregion


--region 对外接口

function PVPColosseumMgr:GetSequence()
	return self.CurrentSequence
end

---获取水晶角色对象
---@return ABaseCharacter
function PVPColosseumMgr:GetCrystalCharacter()
	return self.crystal_
end

function PVPColosseumMgr:GetCrystalDestination()
	return self.crystalDestination_
end

function PVPColosseumMgr:GetCrystalState()
	return self.crystalState_
end

function PVPColosseumMgr:GetCrystalReachProgress()
	return self.crystalReachProgress_
end

---获取中心节点当前到达率（‰）绝对值，不区分队伍
function PVPColosseumMgr:GetCrystalReachProgressUInt()
	return math.abs(self.crystalReachProgress_)
end

function PVPColosseumMgr:GetCrystalLongestReachProgress(teamIndex)
	if teamIndex <= ColosseumTeam.COLOSSEUM_TEAM_MAX then
		return self.crystalLongestReachProgress_[teamIndex]
	end
	return 0
end

function PVPColosseumMgr:GetCrystalCountInRange(teamIndex)
	if teamIndex <= ColosseumTeam.COLOSSEUM_TEAM_MAX then
		return self.crystalCountInRange_[teamIndex]
	end
	return 0
end

---获取攻击检查点当前突破率
function PVPColosseumMgr:GetOffenseCheckPointProgress(teamIndex)
	if teamIndex <= ColosseumTeam.COLOSSEUM_TEAM_MAX then
		return self.offenseCheckPointProgress_[teamIndex]
	end
	return 0
end

---判断指定队伍的防守检查点是否正在被突破中
---@return boolean
function PVPColosseumMgr:IsDefenseCheckPointBreaking(teamIndex)
	if (teamIndex == self.teamIndex_ and self.crystalState_ == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_CHECK_POINT_BREAKING)
		or (teamIndex ~= self.teamIndex_ and self.crystalState_ == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_CHECK_POINT_BREAKING) then
		local enemyTeamIndex = self.GetOtherTeamIndex(teamIndex)
		if self:GetOffenseCheckPointProgress(enemyTeamIndex) < ColosseumConstant.COLOSSEUM3_OFFENSE_CHECK_POINT_BROKEN then
			return true
		end
	end

    return false;
end

---判断指定队伍的防守检查点是否已被突破
---@return boolean
function PVPColosseumMgr:IsDefenseCheckPointBroken(teamIndex)
	local enemyTeamIndex = self.GetOtherTeamIndex(teamIndex)
	return self:GetOffenseCheckPointProgress(enemyTeamIndex) == ColosseumConstant.COLOSSEUM3_OFFENSE_CHECK_POINT_BROKEN
end


---获取我方队伍索引
---@return number
function PVPColosseumMgr:GetTeamIndex()
	return self.teamIndex_
end

---获取给定队伍的敌对方队伍索引
---@return number
function PVPColosseumMgr.GetOtherTeamIndex(teamIndex)
	local OtherTeamIndex = (teamIndex == ColosseumTeam.COLOSSEUM_TEAM_1) and ColosseumTeam.COLOSSEUM_TEAM_2 or ColosseumTeam.COLOSSEUM_TEAM_1
	return OtherTeamIndex
end

---判断给定队伍索引是否我方队伍
---@param teamIndex number 队伍索引
---@return boolean
function PVPColosseumMgr:IsMyTeamByTeamIndex(teamIndex)
	local bIsMyTeam = (teamIndex == self.teamIndex_)
	return bIsMyTeam
end

---判断给定CampID是否我方队伍
---@param CampID number 队员阵营ID
---@return boolean
function PVPColosseumMgr:IsMyTeamByCampID(CampID)
	local bIsMyTeam = (CampID == PVPTeamMgr:GetMajorCampID())
	return bIsMyTeam
end

---判断战场是否满员，双方队伍都满的情况
---@return boolean
function PVPColosseumMgr:IsMatchFull()
	if PVPTeamMgr:GetPVPTeamVM():GetMemberNum() == ColosseumConstant.MaxMemberNum
		and PVPTeamMgr:GetPVPTeamVM():GetEnemyMemberNum() == ColosseumConstant.MaxMemberNum then
		return true
	end

	return false
end

---获取比赛类型
function PVPColosseumMgr:GetMatchType()
	return self.matchType_
end


---判断当前是否为水晶冲突地图
function PVPColosseumMgr:IsPVPColosseumPWorld()
	return PWorldMgr:CurrIsInPVPColosseum()
end

---获取地图SG标记图标ID
---@param teamIndex number 队伍索引
---@param mapMarkerLayoutIndex number 地图标记SG类型
---@return number
function PVPColosseumMgr:GetSGMapMarkerIconID(teamIndex, mapMarkerLayoutIndex)
	local IconID = 0
	local bIsMyTeam = self:IsMyTeamByTeamIndex(teamIndex)

	if mapMarkerLayoutIndex == ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_BASE then
		IconID = bIsMyTeam and ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_BASE_ALLY or ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_BASE_ENEMY

	elseif mapMarkerLayoutIndex == ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_CHECK_POINT then
		-- 检查点的图标根据是否突破完成而改变
		if(self:IsDefenseCheckPointBroken(teamIndex)) then
			IconID = bIsMyTeam and ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_BROKEN_ALLY or ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_BROKEN_ENEMY
		else
			IconID = bIsMyTeam and ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_ALLY or ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CHECKPOINT_ENEMY
		end

	elseif mapMarkerLayoutIndex == ColosseumMapMarkerLayoutType.MAP_MARKER_LAYOUT_GOAL then
		IconID = bIsMyTeam and ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_GOAL_ALLY or ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_GOAL_ENEMY
	end

	return IconID
end

---获取地图水晶标记图标ID
---@return number
function PVPColosseumMgr:GetCrystalMapMarkerIconID()
	local IconID = 0

	local crystalState = self:GetCrystalState()
	if crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_INACTIVE then
		IconID = ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CRYSTAL_INACTIVE

	elseif crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_NEUTRAL then
		IconID = ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CRYSTAL_NEUTRAL

	elseif crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_DEADLOCKED then
		IconID = ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CRYSTAL_DEADLOCKED

	elseif crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_LONGEST
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ALLY_CHECK_POINT_BREAKING then
		IconID = ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CRYSTAL_ALLY

	elseif crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_LONGEST
		or crystalState == ColosseumCrystalState.COLOSSEUM3_CRYSTAL_STATE_ENEMY_CHECK_POINT_BREAKING then
		IconID = ColosseumMapMarkerIcon.EXD_ICON_MAP_MARKER_MKS_CRYSTAL_ENEMY
	end

	return IconID
end

--endregion


--region 其他接口

---客户端根据所属队伍更改场地SG颜色
function PVPColosseumMgr:UpdateFieldSG()
	local ColosseumMapLayouts = PVPColosseumDefine.ColosseumMapLayouts
	local CurrMapID = PWorldMgr:GetCurrMapResID()
	local CurrMapLayouts = ColosseumMapLayouts[CurrMapID]
	if nil == CurrMapLayouts then return end

	-- SG状态参考端游后台代码，端游用的状态id，手游接口用的状态index
	--local SgTimelineState = (self.teamIndex_ == ColosseumTeam.COLOSSEUM_TEAM_1) and 0x0001 or 0x0010
	local SgTimelineState = (self.teamIndex_ == ColosseumTeam.COLOSSEUM_TEAM_1) and 0 or 4
	--PWorldMgr:PlaySharedGroupTimeline(CurrMapLayouts.Field, SgTimelineState)
	_G.UE.UContentSgMgr:Get():PlayManagedSGWithSgIDAndIndex(1000, SgTimelineState)
	FLOG_INFO("[PVPColosseumMgr:UpdateFieldSG] field sg InstanceID=%d, ID=1000, state index=%d", CurrMapLayouts.Field, SgTimelineState)

	--[[
	local PWorldDynDataMgr = PWorldMgr.GetPWorldDynDataMgr()
	local DynData = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE, CurrMapLayouts.Field)
	if DynData then
		DynData:UpdateState(SgTimelineState)
	end
	--]]
end

---劣势方胜利的推进目标点光圈特效
---@param TargetPos FVector
function PVPColosseumMgr:ShowOvertimeEffect(TargetPos)
	if TargetPos == nil then
		return
	end

	local GroudPos, GroundValid = PWorldMgr:GetGroudPosByLineTrace(TargetPos, 1000)
	if GroundValid then
		TargetPos = GroudPos
	end
	local Translation = TargetPos
	local Rotation = _G.UE.FQuat()
	local Scale3D = FVector(1, 1, 1)

	local VfxParameter = _G.UE.FVfxParameter()
	local VfxRequireData = VfxParameter.VfxRequireData
	VfxRequireData.EffectPath = ColosseumCrystalVFX[ColosseumConstant.EXD_VFX_MKS_CRYSTAL_OVERTIME]
	VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)
	VfxRequireData.bAlwaysSpawn = true
	VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_Others
	local EffectID = EffectUtil.PlayVfx(VfxParameter)
	return EffectID
end

---显示准备阶段结束倒计时，即战斗开始倒计时
function PVPColosseumMgr:ShowCountDownForWaitTime(RemainSec)
	local Params = {}
	Params.BeginTime = RemainSec + 1
	Params.TimeInterval = 1
	Params.TimeDelay = 0
	Params.StartTitleText = ""
	Params.CountDownLoopSound = PVPColosseumDefine.AudioPath.CountDown
	UIViewMgr:ShowView(UIViewID.InfoCountdownTipsView, Params)
end

---显示主赛程结束倒计时
function PVPColosseumMgr:ShowCountDownForRegularTime(RemainSec)
	local Params = {}
	Params.BeginTime = RemainSec
	Params.CountDownLoopSound = PVPColosseumDefine.AudioPath.CountDown
	UIViewMgr:ShowView(UIViewID.InfoCountdownTipsForPVPView, Params)
end

---显示加时赛劣势方出圈判输倒计时
function PVPColosseumMgr:ShowCountDownForOverTime(RemainSec)
	self:HideCountDownTime()

	local Params = {}
	Params.BeginTime = RemainSec
	-- 倒计时到了会自动隐藏
	UIViewMgr:ShowView(UIViewID.InfoCountdownTipsForPVPView, Params)
end

---隐藏倒计时UI
function PVPColosseumMgr:HideCountDownTime()
	if UIViewMgr:IsViewVisible(UIViewID.InfoCountdownTipsView) then
        UIViewMgr:HideView(UIViewID.InfoCountdownTipsView)
    end
	if UIViewMgr:IsViewVisible(UIViewID.InfoCountdownTipsForPVPView) then
        UIViewMgr:HideView(UIViewID.InfoCountdownTipsForPVPView)
    end
end

---进入结算状态
---结算时，无法操作摇杆，无法释放技能等
function PVPColosseumMgr:EnterResultState()
	if self.ResultState == true then
		return
	end
	self.ResultState = true

	CommonUtil.DisableShowJoyStick(true)
    CommonUtil.HideJoyStick()
	UIUtil.SetInputMode_UIOnly()

	local StateComponent = MajorUtil.GetMajorStateComponent()
    if StateComponent ~= nil then
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, false, "PVPResult")
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanUseSkill, false, "PVPResult")
    end
end

---离开结算状态
function PVPColosseumMgr:LeaveResultState()
	if self.ResultState == false then
		return
	end
	self.ResultState = false

	CommonUtil.DisableShowJoyStick(false)
    CommonUtil.ShowJoyStick()
	UIUtil.SetInputMode_GameAndUI()

	local StateComponent = MajorUtil.GetMajorStateComponent()
    if StateComponent ~= nil then
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, true, "PVPResult")
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanUseSkill, true, "PVPResult")
    end
end

---比赛结果
function PVPColosseumMgr:SetGameResult(PvPColosseumGameResultRsp)
	local WinnerTeamIndex = 0
	-- 星极队1、灵极队2
	local PvPColosseumTeam1 = PvPColosseumGameResultRsp.Teams[1]
	local PvPColosseumTeam2 = PvPColosseumGameResultRsp.Teams[2]
	if PvPColosseumTeam1 == nil or PvPColosseumTeam2 == nil then
		FLOG_ERROR("[PVPColosseumMgr:SetGameResult] game result PvPColosseumTeam nil")
		return
	end

	if PvPColosseumTeam1.IsWin == true then
		WinnerTeamIndex = ColosseumTeam.COLOSSEUM_TEAM_1
	elseif PvPColosseumTeam2.IsWin == true then
		WinnerTeamIndex = ColosseumTeam.COLOSSEUM_TEAM_2
	end
	local IsWinner = WinnerTeamIndex == self:GetTeamIndex()

	PVPColosseumRecordVM:UpdateVM(IsWinner, self.SequenceEndTime, PvPColosseumGameResultRsp)
	PVPColosseumRecordVM.HasSetGameResult = true
	if self.WaitGameResultTimeID then
		self:UnRegisterTimer(self.WaitGameResultTimeID)
		self.WaitGameResultTimeID = nil
	end

	local function ShowGameResultTips()
		if IsWinner then
			-- 胜利提示
			MsgTipsUtil.ShowTipsByID(338007)
		else
			-- 失败提示
			MsgTipsUtil.ShowTipsByID(338008)
		end

		self:RegisterTimer(function()
            _G.LootMgr:SetDealyState(false)
        end, 1)
	end

	self:RegisterTimer(ShowGameResultTips, 1)

	-- 延迟显示，和前面胜负提示错开
	self:RegisterTimer(self.ShowGameResultUI, 4)
end

---显示比赛结果UI
function PVPColosseumMgr:ShowGameResultUI()
	if not self:IsPVPColosseumPWorld() then
		return
	end

	if self.CurrentSequence ~= ColosseumSequence.COLOSSEUM_PHASE_RESULT then
		return
	end

	UIViewMgr:ShowView(UIViewID.PVPColosseumRecord)
end

---等待比赛结果，在结算信息展示阶段
function PVPColosseumMgr:WaitGameResult()
	if PVPColosseumRecordVM.HasSetGameResult then
		-- 如果已有数据，则直接用显示已有数据显示，一般是结算信息展示阶段发生了断线重连
		self:ShowGameResultUI()
        -- 断线重连请求点赞数据刷新UI
		self:RequestLikeData(PVPColosseumRecordVM.SceneInstID)
	else
		-- 如果没有数据，则等待一段时间后，判断后台是否下发结果(正常流程)，没有则直接退出副本（断线重连，解决结果数据丢包问题）
		-- 理论上断线重连后应该重新请求后台下发结果，目前后台没实现
		local function WaitResultTimeOut()
			FLOG_INFO("[PVPColosseumMgr:WaitGameResult] result time out")
			if self:IsPVPColosseumPWorld() then
				PWorldMgr:SendLeavePWorld()
			end
		end

		if self.WaitGameResultTimeID then
			self:UnRegisterTimer(self.WaitGameResultTimeID)
			self.WaitGameResultTimeID = nil
		end
		self.WaitGameResultTimeID = self:RegisterTimer(WaitResultTimeOut, 5)
	end
end

--endregion


--region 测试用例

---测试战场阶段的倒计时和提示
function PVPColosseumMgr:TestCaseColosseumSequence()
	self.CurrentSequence = ColosseumSequence.COLOSSEUM_PHASE_REGULAR

	local ServerTime = TimeUtil.GetServerTimeMS()
	self.SequenceEndTime = ServerTime + 60*1000
	self:SetCrystalReleaseBindingTime(ServerTime + 20*1000)

	PVPColosseumHeaderVM:SetCountDownTime(self.SequenceEndTime, false)
end

---测试战场态势的图标显示
function PVPColosseumMgr:TestCaseColosseumCrystal()
	local Status = math.random(3, 9)
	--Status = CrystalStatus.CRYSTAL_STATUS_ASTRA_BREAKING
	self:SetCrystalDestination(Status)

	local Progress = math.random(-1000, 1000)
	--Progress = 500
	self:SetCrystalReachProgress(Progress)

	local ProgressValue1 = math.random(0, 1000)
	local ProgressValue2 = math.random(0, 1000)
	self:SetCrystalLongestReachProgress(1, ProgressValue1)
	self:SetCrystalLongestReachProgress(2, ProgressValue2)

	local CheckValue1 = math.random(0, 1000)
	local CheckValue2 = math.random(0, 1000)
	--CheckValue1 = 1000
	self:SetOffenseCheckPointProgress(1, CheckValue1)
	self:SetOffenseCheckPointProgress(2, CheckValue2)
end

---测试战场日志
function PVPColosseumMgr:TestCaseColosseumEvent()
	local ServerTime = TimeUtil.GetServerTimeMS()

	--PVPTeamMgr:UpdateRespawnTime(MajorUtil.GetMajorRoleID(), ServerTime + 10*1000)

	--self:SetAreaEventTime(ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_CRYSTAL, ServerTime + 20*1000)

	local Value = math.random(1, 100)
	if Value <= 30 then
		local LogEvent = math.random(2, 8)
		PVPColosseumBattleLogVM:PushLogEvent(LogEvent)
	elseif Value <= 70 then
		PVPColosseumBattleLogVM:PushLogKnockOut(MajorUtil.GetMajorRoleID(), MajorUtil.GetMajorRoleID(), math.random(1, 7))
	else
		if math.random(1, 10) > 5 then
			MsgTipsUtil.ShowPVPColosseumTeamTips(LSTR(810024), true)
		else
			MsgTipsUtil.ShowPVPColosseumTeamTips(LSTR(810025), false)
		end
	end
end

function PVPColosseumMgr:TestCaseCrystalEffect()
	local MajorActor = MajorUtil.GetMajor()
	if MajorActor == nil  then
		return
	end

	local TargetPos = MajorActor:FGetActorLocation()
	self:ShowOvertimeEffect(TargetPos)
end

--endregion


return PVPColosseumMgr