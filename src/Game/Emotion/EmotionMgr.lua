--- Date: 2021-2025
--- LastEditors: moody
--- LastEditTime: 2021-11-12 11:14:07
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local SaveKey = require("Define/SaveKey")
local TimeUtil = require("Utils/TimeUtil")
local BuffUtil = require("Utils/BuffUtil")
local UIViewID = require("Define/UIViewID")
local RideCfg = require("TableCfg/RideCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsID = require("Define/MsgTipsID")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EmotionCfg = require("TableCfg/EmotionCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local AnimationUtil = require("Utils/AnimationUtil")
local CompanionCfg = require("TableCfg/CompanionCfg")
local ChangeRoleCfg = require("TableCfg/ChangeRoleCfg")
local EmotionEidCfg = require("TableCfg/EmotionEidCfg")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local CommSideBarUtil = require("Utils/CommSideBarUtil")
local EmoActPanelVM = require("Game/EmoAct/EmoActPanelVM")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local EmotionContentCfg = require("TableCfg/EmotionContentCfg")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local EmotionTaskFactory = require("Game/Emotion/EmotionTaskFactory")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local CommonSelectSidebarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local SUB_MSG_ID = ProtoCS.Role.GrandCompany.GrandCompanyCmd
local EmotionTargetType = ProtoCS.EmotionTargetType
local ClientSetupKey = ProtoCS.ClientSetupKey
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD
local EMOTION_SUB_ID = ProtoCS.EmotionSubMsg
local EMOTION_TYPE = ProtoCS.EmotionType
local CS_CMD = ProtoCS.CS_CMD
local UKismetMathLibrary = nil
local PWorldMgr = nil
local UIViewMgr = nil
local EventMgr = nil
local TimerMgr = nil
local USaveMgr = nil
local PhotoMgr = nil
local MountMgr = nil
local LSTR = nil

local EmotionMgr = LuaClass(MgrBase)
function EmotionMgr:Ctor()	
end

function EmotionMgr:OnInit()
	self.Tasks = {}
	self.INF = 0.000000001				---起步速度
	self.MaxRecentEmoNum = 4			---记录最近使用的最大数量
	self.MaxFavoriteEmoNum = 20			---记录收藏的最大数量
	self.HoldWeaponEmotionID = 116 		---持有武器动作 ID = 116
	self.SitChairID = 50 				---坐椅子 ID = 50
	self.EndChairTime = 0.3 			---坐椅起身延迟
	self.SitGroundID = 52 				---坐地上 ID = 52
	self.HoldWeaponSitID = {50, 52} 	---坐下的ID = 50、52
	self.EXD_EMOTE_HUG = 112			---拥抱
	self.EXD_EMOTE_EMBRACE = 113		---深情拥抱
	self.EXD_EMOTE_FISTBUMP = 115		---对拳
	self.EXD_EMOTE_STROKE = 105 		---抚摸
	self.EXD_EMOTE_BAjAFIRE = 62 		---巴哈烈焰
	self.EXD_EMOTE_SLEEP = 88 			---睡觉
	self.EXD_EMOTE_WAKE = 89 			---起床
	self.EXD_EMOTE_NOD = 13 			---打盹
	self.MajorCanUseType = EmotionDefines.CanUseTypes.STAND
	self.MaxLastTime = 86400  			---最大最近使用的时间（秒），超过时间会清空最近使用
	self.Timespan = 500					---快速点击间隔（毫秒）
	self.ReqPastTime = 0				---记录当前时间的毫秒
	--self.AjustInterval = 1000			---高度调整间隔
	self.IntervalMs = 0					---记录间隔的时间
	self.GrandCompany = {				---三个军团的ID，key为军团枚举
		[1] = 55,
		[2] = 56,
		[3] = 57,
	}
	self.RotationInterpSpeed = nil
	self.IsInterpRota = nil
end

function EmotionMgr:OnBegin()
	USaveMgr = _G.UE.USaveMgr
	PWorldMgr = _G.PWorldMgr
	LSTR = _G.LSTR	--多语言ukey值对应文本配置在21EmotionText.xlsx
	TimerMgr = _G.TimerMgr
	UIViewMgr = _G.UIViewMgr
	EventMgr = _G.EventMgr
	PhotoMgr = _G.PhotoMgr
	MountMgr = _G.MountMgr
	UKismetMathLibrary = _G.UE.UKismetMathLibrary

	self.MajorActiveEmotionIDs = {}		---由服务器激活的ID为true
	EmoActPanelVM.SavedFavoriteID = {}	---主角的收藏列表
	self.IsNameOffset = false  			---是否调整名字位置（调整位置功能仅在坐下动作时使用）
	self.TimeHandle = nil 		 		---调整名字的定时器句柄
	self.IsFindChair = true				---坐下时找椅子
	self.AutoDropWeapon = "1"
	self.AutoResetPose = true
	self.ResetToIdleTime = 30
	self.HideWeaponTime = 5
	self.bIsNeedShowTips = true
	self.bIsActiveChangeRole = nil
	self.bBecomeHuman = nil				---变人
	self.CannotText = {}				---用来打日志的
	self:RegisterCheckItemUsedFun()
end

function EmotionMgr:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function EmotionMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EMOTION, EMOTION_SUB_ID.EmotionSubMsgEnter, self.OnEmotionEnter)	 --主角回包的情感动作的即时广播
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EMOTION, EMOTION_SUB_ID.EmotionSubMsgNotify, self.OnEmotionNotify) --其他玩家回包的情感动作的即时广播
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EMOTION, EMOTION_SUB_ID.EmotionSubMsgQueryStat, self.OnEmotionQueryStat)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EMOTION, EMOTION_SUB_ID.EmotionSubMsgLeave, self.OnEmotionLeave)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EMOTION, EMOTION_SUB_ID.EmotionSubMsgActive, self.OnEmotionActive) --解锁
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EMOTION, EMOTION_SUB_ID.EmotionSubMsgQuery, self.OnEmotionQuery)   --查询已解锁、已收藏
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_EMOTION, EMOTION_SUB_ID.EmotionSubMsgLike, self.OnEmotionLike)     --收藏true 取消收藏false

	-- self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_START_MAKE, self.OnNetMsgStartMake)
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_QUIT_MAKE, self.OnNetMsgQuitMake)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdJoinCompany, self.OnNetMsgJoinCompany)	--加入军团
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdTransferCompany, self.OnNetMsgTransferCompany)	--更换军团

end

function EmotionMgr:OnRegisterGameEvent()
	-- 角色移动、使用技能、死亡、触发交互时 都会取消使用身体情感动作
	self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.OnGameEventActorVelocityUpdate)
	self:RegisterGameEvent(EventID.InputFirstMove, self.OnGameEventInputFirstMove)
	self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventOtherCharacterDead)
	self:RegisterGameEvent(EventID.PreClickFunctionItems, self.OnGameEventPreClickFunctionItems)
	self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
	self:RegisterGameEvent(EventID.MajorHit, self.OnGameEventMajorHit)
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnGameEventSetupPost)	--姿势切换

	self:RegisterGameEvent(EventID.PlayEmotion, self.OnPlayEmotion)
	self:RegisterGameEvent(EventID.CancelEmotion, self.OnGameEventCancelEmotion)
	self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)		--网络状态更新-后台数据
	self:RegisterGameEvent(EventID.ReqPlayEmotion, self.OnGameEventReqPlayEmotion)
	
	self:RegisterGameEvent(EventID.PostEmotionEnter, self.OnGameEventPostEmotionEnter)
	self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
	self:RegisterGameEvent(EventID.SkillStart, self.OnGameEventSkillStart)
	self:RegisterGameEvent(EventID.SkillEnd, self.OnGameEventSkillEnd)

	self:RegisterGameEvent(EventID.SelectTarget, self.OnGameEventSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)

	self:RegisterGameEvent(EventID.MountCall, self.OnGameEventMountCall)			-- 上坐骑
	self:RegisterGameEvent(EventID.MountBack, self.OnGameEventMountBack)			-- 下坐骑
	self:RegisterGameEvent(EventID.EnterFishStatus, self.OnGameEventEnterFishStatus)-- 钓鱼中
	self:RegisterGameEvent(EventID.ExitFishStatus, self.OnGameEventExitFishStatus)	-- 钓鱼结束
--	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)		-- 主角创建
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)		-- 角色登录成功、断线重连时查询

	self:RegisterGameEvent(EventID.Avatar_Update_Master, self.OnAvatarUpdateMaster)	-- 主mesh更新
	self:RegisterGameEvent(EventID.ActorReviveNotify,self.OnGameEventReviveNotify)	-- 角色复活

	-- self:RegisterGameEvent(EventID.NetworkReconnected, self.OnRelayConnected)	-- 网络闪断
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)  -- 进入地图
	self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit) 	-- 退出副本地图
	self:RegisterGameEvent(EventID.StartSwimming, self.OnGameEventStartSwimming)  	-- 开始游泳
	self:RegisterGameEvent(EventID.EndSwimming, self.OnGameEventEndSwimming)  		-- 结束游泳

	self:RegisterGameEvent(EventID.QuestTargetEmotionStart, self.OnGameEventQuestTargetEmotionStart)-- 任务开始时
	self:RegisterGameEvent(EventID.QuestTargetEmotionEnd, self.OnGameEventQuestTargetEmotionEnd)	-- 任务终结时
    self:RegisterGameEvent(EventID.PlayerEnterIdleState, self.OnPlayerEnterIdleState)				-- 进出待机状态
    self:RegisterGameEvent(EventID.Attr_Change_ChangeRoleId, self.OnGameEventChangeRole)			-- 变身
    self:RegisterGameEvent(EventID.PVPDuelAccept, self.OnGameEventPVPDuelAccept)					-- 决斗
    self:RegisterGameEvent(EventID.MajorEntityIDUpdate, self.OnGameEventMajorEntityIDUpdate)		-- 主角EntityID更新
end

function EmotionMgr:OnEnd()
	self.Tasks = {}
	self.MajorCanUseType = EmotionDefines.StateDefine.NORMAL
	self.MajorActiveEmotionIDs = {}
	EmoActPanelVM.SavedFavoriteID = {}
	self.OnceEmotions = nil
	self.LoopEmotions = nil
	self.FaceEmotions = nil
	self.AllMatchedEmotions = nil
	self.TargetQuestEmotionID = nil
	self.CannotText = {}
	self:ClearPoseTimerHandle()
	self.IdleSetupValue = nil
end

function EmotionMgr:EmotionTaskEnter(Params)
	local FromID = Params.ULongParam1
	local EmotionID = Params.IntParam1
	if self.Tasks[FromID] then
		for k,Task in pairs(self.Tasks[FromID])do
			if Task.EmotionID == EmotionID then
				Task:TaskEnter(Params)
				break
			end
		end
	end
end

--- 改变姿势
function EmotionMgr:ReqChangeIdleAnim()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	EmotionAnimUtils.ChangePoseByAddOne(MajorEntityID)
	self:UpdateIdleAnimParams()
end

--- 主角请求播放情感动作
function EmotionMgr:OnGameEventReqPlayEmotion(Params)
	local EmotionID = Params.IntParam1
	self:SendEmotionReq(EmotionID)
end

---若需要请求终⽌情感动作，请发起此事件，
---在 EmotionTaskBase:TaskEnd 函数(任务终结时)内其会判断是否需要通知后台。
function EmotionMgr:OnGameEventCancelEmotion(Params)
	local FromID = Params.ULongParam1
	local ToID = Params.ULongParam2
	local bInterrupted = Params.BoolParam1
	local EmotionID = Params.IntParam1
	local CancelReason = Params.IntParam2
	if self.Tasks[FromID] then
		for k,Task in pairs(self.Tasks[FromID])do
			if Task.EmotionID == EmotionID then
				table.remove(self.Tasks[FromID], k)
				if #self.Tasks[FromID] == 0 then
					self.Tasks[FromID] = nil
				end
				Task:TaskEnd(Params)
				break
			end
		end

		local EventParams = EventMgr:GetEventParams()
		EventParams.ULongParam1 = FromID
		EventParams.ULongParam2 = ToID
		EventParams.IntParam1 = EmotionID
		EventParams.IntParam2 = CancelReason
		EventParams.BoolParam1 = bInterrupted
		EventMgr:SendEvent(EventID.PostEmotionEnd, EventParams)
		EventMgr:SendCppEvent(EventID.PostEmotionEnd, EventParams)
	end
end

function EmotionMgr:OnGameEventPreClickFunctionItems(FunctionItem)
	local EntityID = MajorUtil.GetMajorEntityID()
	if self.Tasks[EntityID] then
		self:SendStopEmotionReq(FunctionItem.WeaponBackWhenClick and EMOTION_TYPE.EmotionTypeAll or EMOTION_TYPE.EmotionTypeLast)
	end
end

--- 手动停止主角的坐下动作
function EmotionMgr:StopSitChairByMajor()
	local EntityID = MajorUtil.GetMajorEntityID()
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if not PlayerAnimInst then
		return
	end
	if PlayerAnimInst.bUseChair then
		-- PlayerAnimInst:EndChair(EntityID)
		PlayerAnimInst.bUseChair = false
		self:MajorCanUseSkill(true, EntityID, self.SitChairID)

		local EventParams = EventMgr:GetEventParams()
		EventParams.ULongParam1 = EntityID
		EventParams.BoolParam1 = false
		EventParams.BoolParam3 = false	--停止动作
		EventMgr:SendCppEvent(EventID.ActorSit, EventParams)
	end
	if PlayerAnimInst.bUseBed then
		PlayerAnimInst.bUseBed = false
		self:MajorCanUseSkill(true, EntityID, self.SitChairID)
	end
end

---@param CancelByServer 为false时同步后台
function EmotionMgr:StopAllEmotions(EntityID, CancelByServer, CancelReason)
	self:StopAllEmotionsOf(EntityID, {0, 1, 2, 3}, CancelByServer, CancelReason)
end

function EmotionMgr:StopAllEmotionsNotState(EntityID, CancelByServer, CancelReason)
	self:StopAllEmotionsOf(EntityID, {0, 1, 2}, CancelByServer, CancelReason)
end

function EmotionMgr:StopSitEmotion(EntityID, CancelByServer, CancelReason)
	self:StopEmotionsByPred(EntityID, self.IsSitEmotionID, CancelByServer, true, CancelReason)
end

function EmotionMgr:StopAllEmotionsNotHoldWeapon(EntityID, CancelByServer, CancelReason)
	self:StopEmotionsByPred(EntityID, self.IsHoldWeaponID, CancelByServer, false, CancelReason)
end

--- 坐下后监测玩家摇杆输入的第一帧（非0值），则立即停止坐下
function EmotionMgr:OnGameEventInputFirstMove(InParams)
	local EntityID = InParams.ULongParam1
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if not PlayerAnimInst then return end
	if PlayerAnimInst.bUseChair then	--坐下时起身

		-- PlayerAnimInst:DisableMove()
		-- print("EmotionMgr:DisableMove", EntityID)
		self:StopSitChairByMajor()
		self:StopAllEmotions(EntityID, false, EmotionDefines.CancelReason.NONE)
		
		-- PlayerAnimInst.bUseChair = false

		-- self:RegisterTimer(function()
		-- 	if PlayerAnimInst then
		-- 		PlayerAnimInst:EnableMove()
		-- 		print("EmotionMgr:EnableMove", self.EndChairTime, EntityID)
		-- 	end
		-- end, self.EndChairTime, 0, 1)

		return
	end
	if self:IsEmotionPlaying(EntityID, self.EXD_EMOTE_WAKE) then
		PlayerAnimInst.bUseBed = false
		return
	end
	if PlayerAnimInst.bUseBed then		--躺下时起床
		self:SendEmotionReq(self.EXD_EMOTE_WAKE)
		PlayerAnimInst.bUseBed = false
		return
	end
	self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.MOVE)
end

function EmotionMgr:OnGameEventActorVelocityUpdate(InParams)
	local EntityID = InParams.ULongParam1
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if not Actor then return end
	local IsMajor = MajorUtil.IsMajor(EntityID)
	local Velocity = Actor.CharacterMovement.Velocity
	if Velocity:Size() < self.INF then
		if not IsMajor then
			local PlayerAnimInst = AnimationUtil.GetAnimInst(EntityID)
			if PlayerAnimInst and PlayerAnimInst.bUseChair then
				self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.MOVE)
			end
		end
		return
	end

	if self:IsEmotionPlaying(EntityID, self.EXD_EMOTE_SLEEP) then
		return
	end
	if self:IsEmotionPlaying(EntityID, self.EXD_EMOTE_WAKE) then
		return
	end

	-- 移动时后台会自动停止非持刀情感动作
	self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.MOVE)

	-- 是主角
	if IsMajor then
		self:ClearLookAtTimer(Actor)
	end

	-- 正在触发技能中不播放拔刀
	local StateCom = ActorUtil.GetActorStateComponent(EntityID)
	if StateCom and StateCom:IsUsingSkill() then
		local AnimCom = ActorUtil.GetActorAnimationComponent(EntityID)
		if not AnimCom then return end
		AnimCom.IsInEmote = false
	end
end

--玩家死亡
function EmotionMgr:OnGameEventOtherCharacterDead(InParams)
	local EntityID = InParams.ULongParam1
	if ActorUtil.IsPlayer(EntityID) or ActorUtil.IsMajor(EntityID) then
		self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.DEAD)
	end
end

--主角死亡
function EmotionMgr:OnGameEventMajorDead()
	local EntityID = MajorUtil.GetMajorEntityID()
	-- Major死亡时后台会自动停止非状态情感动作
	self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.DEAD)

	UIViewMgr:HideView(UIViewID.CommEasytoUseView)
end

--- 复活
function EmotionMgr:OnGameEventReviveNotify(Params)
	local EntityID = Params.ULongParam1
	-- local StateCom = ActorUtil.GetActorStateComponent(EntityID)
	-- local IsInDungeon = StateCom:IsInDungeon()
	-- if IsInDungeon then	--在副本中
	-- 	if (PWorldMgr:GetCurrPWorldSubType() == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_8R) then
	-- 		return		-- 在8人副本中复活不退出拔刀动作（这个需求不做了）
	-- 	end
	-- end
	local IsCombatState = ActorUtil.IsCombatState(EntityID)
	if not IsCombatState then
		--复活时不在战斗中，收刀
		self:StopAllEmotions(EntityID, false, EmotionDefines.CancelReason.SERVER_NOTIFY)
		local FromActor = ActorUtil.GetActorByEntityID(EntityID)
		FromActor:GetAvatarComponent():TempSetAvatarBack(1)
	end
end

-- -- 闪断
-- function EmotionMgr:OnRelayConnected(Params)
-- 	local RoleID = Params.RoleID
-- 	local bRelay = Params.bRelay
-- 	if bRelay then
-- 		--为闪断
-- 	end
-- end

--- 在切换新地图前, 离开旧地图时
function EmotionMgr:OnGameEventPWorldMapExit(Params)
	--self:SendStopEmotionAll()
	local EntityID = MajorUtil.GetMajorEntityID()
	local AnimCom = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimCom then
		AnimCom.IsInEmote = true
	end
end

--- 进入副本地图
function EmotionMgr:OnGameEventPWorldMapEnter(Params)
	local EntityID = MajorUtil.GetMajorEntityID()
	local AnimCom = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimCom then
		AnimCom.IsInEmote = false
	end
	if PWorldMgr == nil then
		PWorldMgr = require("Game/PWorld/PWorldMgr")
	end

	if PWorldMgr:RspFlagIsReconnect(nil) then
		self:SendEmotionStatQueryReq()		-- 断线重连查询
	elseif PWorldMgr.EnterMapServerFlag == 0 or PWorldMgr.EnterMapServerFlag == 2 then
		self:StopSitChairByMajor()

		--bug=143816832 站姿切换后，换地图或者进本，姿态又回到初始值
		local AnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)
		if AnimInst == nil or PlayerAnimParam == nil or not self.IdleSetupValue then
			return
		end
		EmotionAnimUtils.ApplyIdleCSValue(EntityID, self.IdleSetupValue, false)
	end
end

--- 角色组装
function EmotionMgr:OnAvatarUpdateMaster(Params)
	local EntityID = Params.ULongParam1
	if EntityID <= 0 then return end

	if self.Tasks[EntityID] then
		for _,Task in pairs(self.Tasks[EntityID])do
			if Task:IsLoopAnim() then
				Task:PlayEmotion() -- 进入视野的角色组装后执行播放任务
			end

			if Task.EmotionID == self.SitChairID then
				-- 在进入副本地图的时候会判断是断线重连并请求查询状态，随后直接播放动作；
				-- 若按服务器消息播放坐下时，角色未组装，则移动组件检测碰撞地面会使其坐空；
				-- 这里添加一个长延迟后，重新执行坐下时的位移逻辑
				self:RegisterTimer(function()
					self:SitChairStat(EntityID)
					print("EmotionMgr:OnAvatarUpdateMaster SitChairStat", EntityID)
				end, 1)
			end
		end
	end
	
	if not ActorUtil.IsPlayerOrMajor(EntityID) then
		return
	end
	
	if MajorUtil.IsMajor(EntityID) then
		self:GetHeight()
		-- self:SetAutoFoldWeapon()
		self:SetOpenAutoPose()
		return
	else
	 	--其他玩家在有进行切换姿势的操作后，立即切换进入视野的动作表现
		-- local PlayerAnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)
		-- if PlayerAnimInst and PlayerAnimParam then
		-- 	PlayerAnimParam.bIgnoreRestTime = true
		-- 	PlayerAnimParam.IdleToRestTime = 0
		-- 	PlayerAnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
		-- end
	end
end

--- 加入军团时 更新EmotionID
function EmotionMgr:OnNetMsgJoinCompany(MsgBody)
	if MsgBody.JoinCompany.ID then
        local GrandCompanyID = MsgBody.JoinCompany.ID

		for k, ID in pairs(self.GrandCompany) do
			if k == GrandCompanyID then
				local ActiveList = {ID}
				self:OnActiveListID(ActiveList)
			else
				local DeactiveList = {ID}
				self:OnDeactiveListID(DeactiveList)
			end
		end
		--若已打开主界面，需刷新一下图标
		if UIViewMgr:IsViewVisible(UIViewID.CommEasytoUseView) then
			self:ShowEmotionMainPanel()
		end

	--	local EmotionID = self.GrandCompany[GrandCompanyID]
	--	local Name = ProtoEnumAlias.GetAlias(ProtoRes.grand_company_type, GrandCompanyID)
    --   print(" 加入军团时 更新EmotionID", Name, EmotionID)
    end
end

--- 更换军团时 更新EmotionID
function EmotionMgr:OnNetMsgTransferCompany(MsgBody)
	if MsgBody.TransferCompany then
		local GrandCompanyID = MsgBody.TransferCompany.ID

        for k, ID in pairs(self.GrandCompany) do
			if k == GrandCompanyID then
				local ActiveList = {ID}
				self:OnActiveListID(ActiveList)
			else
				local DeactiveList = {ID}
				self:OnDeactiveListID(DeactiveList)
			end
		end
		--若已打开主界面，需刷新一下图标
		if UIViewMgr:IsViewVisible(UIViewID.CommEasytoUseView) then
			self:ShowEmotionMainPanel()
		end
		
		-- local EmotionID = self.GrandCompany[GrandCompanyID]
		-- local Name = ProtoEnumAlias.GetAlias(ProtoRes.grand_company_type, GrandCompanyID)
        -- print(" 更换军团时 更新EmotionID", Name, EmotionID)
    end
end

--- 受伤受到攻击停止播放动作
function EmotionMgr:OnGameEventMajorHit(Params)
	local EntityID = Params.ULongParam1
	--自动停止非持刀情感动作
	self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.HIT)
end

---情感动作会根据玩家的状态来进⾏终⽌，例如玩家移动、玩家死亡、玩家进⼊交互，都会去执⾏终⽌。
---其中由于玩家进⼊交互是客户端控制的，故⽽会同步给服务器。
---另外，部分循环情感动作可能经由蒙太奇进⾏打断，此时亦会通知服务器。
function EmotionMgr:SendStopEmotionReq(EmotionTypeToStop)
	local MsgID = CS_CMD.CS_CMD_EMOTION
	local SubMsgID = EMOTION_SUB_ID.EmotionSubMsgLeave

	local MsgBody = {}
	MsgBody.SubMsgID = SubMsgID
	MsgBody.Leave = {EmotionType = EmotionTypeToStop}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

	-- 主动上报清除收拔刀状态时，清除临时持刀状态
	if EmotionTypeToStop ~= EMOTION_TYPE.EmotionTypeLast then
		self:ClearTempHoldWeapon(MajorUtil.GetMajorEntityID())
	end
end

function EmotionMgr:SendStopEmotionAll()
	self:SendStopEmotionReq(EMOTION_TYPE.EmotionTypeAll)
end

function EmotionMgr:ClearTempHoldWeapon(EntityID)
	local StateComp = ActorUtil.GetActorStateComponent(EntityID)
	if StateComp then
		StateComp:ClearTempHoldWeapon(_G.UE.ETempHoldMask.ALL, false)		-- 清除本地临时持刀状态
	end
end

--- 某玩家是否正在播放EmotionID
function EmotionMgr:IsEmotionPlaying(EntityID, EmotionID)
	if self.Tasks[EntityID] then
		for k,Task in pairs(self.Tasks[EntityID])do
			if Task.EmotionID == EmotionID then
				return true
			end
		end
	end
	return false
end

--- 发送该指令后，客户端会向服务器去请求调⽤该id对应的情感动作
function EmotionMgr:SendEmotionReq(EmotionID)
	local FromID = MajorUtil.GetMajorEntityID()
	local Major = MajorUtil.GetMajor()
	-- 攀爬时屏蔽情感动作播放
	if Major and Major:IsClimbingState() then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUse)
		return
	end

	if false == self:IsNetMsgBody(EmotionID, true) then
		print(" [EmotionMgr] SendEmotionReq: can not use Emotion ! ")
		local Params = {EntityID = FromID, EmotionID = EmotionID}
		EventMgr:SendEvent(EventID.BreakPlayEmotion, Params)	--处于某些情况在播放动作之前阻断（还没有开始播放）
		return
	end

	---若正在播放手持武器动作ID=116，则会停止播放
	if self.IsHoldWeaponID(EmotionID) and Major and Major:IsHoldWeapon() then
		self:SendStopEmotionReq(EMOTION_TYPE.EmotionTypeAll)
		return
	end

	---若正在播放坐下动作ID=50、52，再次点击对应时会停止播放
	if self.IsSitEmotionID(EmotionID) and self:IsSitState(FromID) then
		self:SendStopEmotionReq(EMOTION_TYPE.EmotionTypeAll)
		return
	end

    ---若附近没有椅子（坐椅子上ID = 50），则坐地上（ID = 52）
	if EmotionID == self.SitChairID and self.IsFindChair == true then
		local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(FromID)
		if PlayerAnimInst then
			local IsChair = PlayerAnimInst:FindChair(FromID)
			if IsChair == false then
				EmotionID = self.SitGroundID
			end
		end
	end

	-- 打盹(ID = 13)
	if EmotionID == self.EXD_EMOTE_NOD then
		if self:FindBed(FromID) == true then
			if self:IsEmotionPlaying(FromID, self.EXD_EMOTE_SLEEP) then
				EmotionID = self.EXD_EMOTE_WAKE 	-- 如果正在睡觉 则播放起床
			elseif not self:IsEmotionPlaying(FromID, self.SitChairID) then
				EmotionID = self.EXD_EMOTE_SLEEP	-- 在床上打盹会睡觉
			end
		end
	end
	
	--端游逻辑：时间间隔500毫秒内不会播放情感动作
	self.IntervalMs = TimeUtil.GetLocalTimeMS() - self.ReqPastTime
	if self.IntervalMs < self.Timespan then
		if EmotionID ~= self.EXD_EMOTE_WAKE then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionFastClick)
			return
		end
	end
	self.ReqPastTime = TimeUtil.GetLocalTimeMS()

	local MsgID = CS_CMD.CS_CMD_EMOTION
	local SubMsgID = EMOTION_SUB_ID.EmotionSubMsgEnter
	local TargetActor = _G.SelectTargetMgr:GetCurrSelectedTarget()	--主角自己选中的目标
	local TargetID = nil
	local IsClientActor = false
	if TargetActor and TargetActor:GetAttributeComponent() then
		IsClientActor = TargetActor:IsClientActor()
		TargetID = IsClientActor and TargetActor:GetAttributeComponent().ListID or TargetActor:GetAttributeComponent().EntityID
	end
	local TargetType = IsClientActor and EmotionTargetType.EmotionTargetTypeListID or EmotionTargetType.EmotionTargetTypeEntity

	if nil ~= self.NewTargetEntityID and self.NewTargetEntityID ~= 0 then
		TargetID = self.NewTargetEntityID
	end

	local MsgBody = {}
	MsgBody.SubMsgID = SubMsgID
	MsgBody.Enter = { EmotionID = EmotionID, Target = {ID = TargetID, IDType = TargetType}}

	---------------------------------------------宠物线----------------------------------------------
	if TargetActor ~= nil then
		local CompanionCharacter = nil
		CompanionCharacter = TargetActor:Cast(_G.UE.ACompanionCharacter)  --若选中的是宠物
		if CompanionCharacter ~= nil then
			
			MsgBody = self:CompanionStartEmote(FromID, EmotionID)
		end
	end
	---------------------------------------------宠物线----------------------------------------------

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 主角回包的情感动作的即时广播
function EmotionMgr:OnEmotionEnter(MsgBody)
	if nil == MsgBody.Enter then
		print(" [EmotionMgr] OnEmotionEnter: not Is MsgBody.Enter ")
		return
	end
	local EntityID = MajorUtil.GetMajorEntityID()
	local EmotionID = MsgBody.Enter.EmotionID ~= 0 and MsgBody.Enter.EmotionID or MsgBody.Enter.StatEmotion
	if false == self:IsNetMsgBody(nil, false, MsgBody.Enter, EntityID) then
		print(" [EmotionMgr] OnEmotionEnter: not Is NetMsgBody ")
		local Params = {EntityID = EntityID, EmotionID = EmotionID}
		EventMgr:SendEvent(EventID.BreakPlayEmotion, Params)
		return
	end

	-- print('[Emotion] OnEmotionEnter EmotionID = ', EmotionID)
	self:PlayEmotionServer(EntityID, MsgBody.Enter, false)
end

--- 其他玩家回包的情感动作的即时广播
function EmotionMgr:OnEmotionNotify(MsgBody)
	if not MsgBody or not MsgBody.Notify then
		return
	end
	local EntityID = MsgBody.Notify.EntityID
	local EmotionID = MsgBody.Notify.EmotionID
	local Target = MsgBody.Notify.Target

	self:MountCustomEmoteNotify(EntityID, EmotionID, Target)	  ---坐骑皮肤

	self:PlayEmotionServer(EntityID, MsgBody.Notify, false)

	self:CompanionStartEmoteNotify(EntityID, EmotionID, Target)  ---宠物交互

	if EmotionID == 0 and 0 == MsgBody.Notify.StatEmotion then
		---若正在播放坐下动作ID=52，再次点击对应时会停止播放
		if self:IsEmotionPlaying(EntityID, 52) then
			self:StopAllEmotions(EntityID, false, EmotionDefines.CancelReason.SERVER_NOTIFY)
			return
		end
	end
end

-- 断线重连用于查询状态 直接进入循环状态即可
function EmotionMgr:OnEmotionQueryStat(MsgBody)
	local EntityID = MajorUtil.GetMajorEntityID()
	local Major = MajorUtil.GetMajor()
	self:StopAllEmotions(EntityID, true, EmotionDefines.CancelReason.SERVER_NOTIFY)
	if Major and not Major:IsInSequencer() then
		self:PlayEmotionServer(EntityID, MsgBody.Query, true)
	end
end

---结束播放的回包
function EmotionMgr:OnEmotionLeave(MsgBody)
	local EmotionType = MsgBody.Leave.EmotionType
	local EntityID = MajorUtil.GetMajorEntityID()
	if EmotionType then
		if EmotionType == EMOTION_TYPE.EmotionTypeAll then
			self:StopAllEmotions(EntityID, true, EmotionDefines.CancelReason.SERVER_NOTIFY)
		elseif EmotionType == EMOTION_TYPE.EmotionTypeLast then
			-- 只保留持刀状态
			self:StopAllEmotionsNotHoldWeapon(EntityID, true, EmotionDefines.CancelReason.SERVER_NOTIFY)
		elseif EmotionType == EMOTION_TYPE.EmotionTypeStat then
			self:StopAllEmotionsOf(EntityID, {0, 1, 3}, true, EmotionDefines.CancelReason.SERVER_NOTIFY)
		end
	else
		-- 默认停止所有情感动作
		self:StopAllEmotions(EntityID, true, EmotionDefines.CancelReason.SERVER_NOTIFY)
	end
end

--- 角色进游戏会接收一次
function EmotionMgr:OnEmotionQuery(MsgBody)
	local ActiveSet = MsgBody.Active.ActiveEmotion
	local LikeList = MsgBody.Active.LikeEmotion
	for _, v in pairs(ActiveSet) do
		self:ActiveEmotion(v)
	end
	for _, ID in pairs(LikeList) do
		EmoActPanelVM.SavedFavoriteID[ID] = true
	end
end

--- 解锁回包
function EmotionMgr:OnEmotionActive(MsgBody)
	local ActiveSet = MsgBody.Active.ActiveEmotion
	self:OnActiveListID(ActiveSet)

	if #ActiveSet > 0 then
		--若已打开主界面，需刷新一下图标
		if UIViewMgr:IsViewVisible(UIViewID.CommEasytoUseView) then
			self:ShowEmotionMainPanel()
		end
	end
end

--- 解锁新动作
function EmotionMgr:OnActiveListID(ActiveList)
	for _, ID in pairs(ActiveList) do
		self:ActiveEmotion(ID)
		
		local EmotionCfg = EmotionCfg:FindCfgByKey(ID)
		if EmotionCfg and EmotionCfg.EmotionName then
			local EmotionName = string.format("<span color=\"%s\">%s</>", "#d1ba8e", EmotionCfg.EmotionName)
			MsgTipsUtil.ShowTips(string.format(LSTR(210025), EmotionName))	--"学会了新的情感动作%s"
		end

		self:AddRedDot(ID)	--红点相关
	end
end

--- 删除动作
function EmotionMgr:OnDeactiveListID(ActiveList)
	for _, ID in pairs(ActiveList) do
		self:DeactiveEmotion(ID)
		self:DelRedDot(ID)	--红点相关
	end
end

--- 向服务器发送收藏消息
function EmotionMgr:SendFavoriteReq(EmotionID)
	local IsSaved = self:IsSavedFavoriteID(EmotionID)
	local Num = self:GetFavoriteNum()

	if Num >= self.MaxFavoriteEmoNum and false == IsSaved then
		--"当前已达收藏上限%d/%d，无法收藏"
		MsgTipsUtil.ShowTips(string.format(LSTR(210035), self.MaxFavoriteEmoNum, self.MaxFavoriteEmoNum))
		return
	end
	local MsgID = CS_CMD.CS_CMD_EMOTION
	local SubMsgID = EMOTION_SUB_ID.EmotionSubMsgLike
	local MsgBody = {}
	local IsLike = not EmoActPanelVM.bIsFavorite	-- 反向一下 取消收藏
	MsgBody.SubMsgID = SubMsgID
	MsgBody.Like = { Emotion = EmotionID, Like = IsLike }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 收藏的回包消息
function EmotionMgr:OnEmotionLike(MsgBody)
	local EmotionID = MsgBody.Like.Emotion
	local IsLike = MsgBody.Like.Like
	self:SetFavoriteIDList(EmotionID, IsLike)
	EmoActPanelVM.bIsFavorite = IsLike  --这里仅刷新一下收藏状态
	EventMgr:SendEvent(EventID.EmotionUpdateFavorite)
	
	local Num = self:GetFavoriteNum()
	local EmotionName = ""
	local EmotionCfg = EmotionCfg:FindCfgByKey(EmotionID)
	if EmotionCfg and EmotionCfg.EmotionName then
		EmotionName = string.format("<span color=\"%s\">%s</>", "#FF8C00", EmotionCfg.EmotionName)
	end
	if IsLike then
		local T = LSTR(210033)
		MsgTipsUtil.ShowTips(string.format(T, EmotionName, Num, self.MaxFavoriteEmoNum))	--"取消收藏%s，当前收藏%d/%d"
	else
		MsgTipsUtil.ShowTips(string.format(LSTR(210034), EmotionName, Num, self.MaxFavoriteEmoNum))	--"已收藏%s，当前收藏%d/%d"
	end
end

--- 骑乘状态使用情感动作，角色会在坐在坐骑上播放
function EmotionMgr:UpdateEmoteState(FromID)
	local Tasks = self.Tasks[FromID] or {}
	local IsInEmote = false
	for _, Task in pairs(Tasks) do
		if Task.MotionType ~= 3 then
			IsInEmote = true
			break
		end
	end
	if PhotoMgr.IsOnPhoto then
		IsInEmote = true
	end

	if self:IsSitStateFace(FromID) then
		IsInEmote = false	--播放表情不停止当前的坐下姿势
	end
	if self:IsNormalIdleFace(FromID) == true then
		IsInEmote = false	--播放表情不停止当前的站立姿势
	end

	local AnimComp = ActorUtil.GetActorAnimationComponent(FromID)
	if AnimComp then
		AnimComp.IsInEmote = IsInEmote
	end
end

--- 开始播放事件
function EmotionMgr:OnGameEventPostEmotionEnter(Params)
	local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnGameEventPostEmotionEnter")
	local FromID = Params.ULongParam1
	local ToID = Params.ULongParam2
	local MajorID = MajorUtil.GetMajorEntityID()
	local EmotionID = Params.IntParam1
	local IDType = Params.IDType
	local bSendChat = Params.bSendChat

	do
		local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnGameEventPostEmotionEnter_UpdateEmoteState")
		self:UpdateEmoteState(FromID)
	end
	if MajorUtil.IsMajor(FromID) then
		CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_EMOTION, true)
	end

	if (FromID == MajorID) or (ToID == MajorID) then	--为主角
		--若躺在床上时播放其他动作，需要结束床
		if not self:IsBedEmotion(EmotionID) then
			local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(FromID)
			if PlayerAnimInst and PlayerAnimInst.bUseBed then	
				if self.IsSitEmotionID(EmotionID) then
					PlayerAnimInst.bUseBed = false
				else
					self:EndBed(FromID, EmotionID)
					self:UpdateName(FromID)
				end
			end
		end

		if self.IsSitEmotionID(EmotionID) then
			self:UpdateMajorCanUseType()
			local Major = MajorUtil.GetMajor()
			if Major then
				Major:EnableFloatHeight(false)
			end
		elseif EmotionID == self.EXD_EMOTE_WAKE then	--起床
			local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(MajorID)
			if PlayerAnimInst then
				PlayerAnimInst:DisableMove()
			end
		end
		local MiniGameMgr = _G.GoldSaucerMiniGameMgr
		local IsMiniGame = MiniGameMgr and MiniGameMgr:IsInGoldSaucerMiniGame() or false
		local bShowHUD = Params.BoolParam3 and not IsMiniGame
		local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnGameEventPostEmotionEnter_ShowTipsChat")
		self:ShowTipsChat(bShowHUD, EmotionID, FromID, ToID, IDType, bSendChat)
	else
		local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnGameEventPostEmotionEnter_ShowTargetChat")
		self:ShowTargetChat(EmotionID, FromID, ToID, IDType)
	end

	if EmotionID == self.EXD_EMOTE_SLEEP then		--开始睡觉动作
		self:UseBed(FromID, EmotionID)
	elseif EmotionID == self.EXD_EMOTE_WAKE then	--开始起床动作
		self:EndBed(FromID, EmotionID)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnGameEventPostEmotionEnter_UseEyeAndMouth")
		self:UseEyeAndMouth(EmotionID, FromID) --眨眼
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnGameEventPostEmotionEnter_OnBaHaFire")
		self:OnBaHaFire(EmotionID, FromID)
	end

	do
		--调整名字位置
		if Params.BoolParam3 == true then 	--（外部调用动作不调整名字）
			if not self.IsHoldWeaponID(EmotionID) then	--不是拔刀时
				local Actor = ActorUtil.GetActorByEntityID(FromID)
				local RideComp = Actor and Actor:GetRideComponent() or nil
				local bIsRide = RideComp and RideComp:IsInRide() or nil
				if bIsRide ~= true then	--不是坐骑上
					if not self:IsFacePlaying(FromID) then	--不是表情
						self:UpdateName(FromID, -30)
					end
				end
			end
		end
	end
end

--- 停止播放事件
function EmotionMgr:OnGameEventPostEmotionEnd(Params)
	local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnGameEventPostEmotionEnd")
	local EmotionID = Params.IntParam1
	local FromID = Params.ULongParam1
	local MajorID = MajorUtil.GetMajorEntityID()
	if FromID == MajorID then	--为主角
		if nil == self.Tasks[FromID] then
			CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_EMOTION, false)
		end
		if self.IsSitEmotionID(EmotionID) then
			self:UpdateMajorCanUseType()
			local Major = MajorUtil.GetMajor()
			Major:EnableFloatHeight(true)
		elseif EmotionID == self.EXD_EMOTE_WAKE then
			local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(MajorID)
			if PlayerAnimInst then
				PlayerAnimInst:EnableMove()
			end
		end
	end

	if EmotionID == self.EXD_EMOTE_SLEEP then	--结束睡觉
		self:EndBed(FromID, EmotionID)
	elseif EmotionID == self.EXD_EMOTE_WAKE then
		self:UpdateName(FromID)		--起床后
	end

	self:UpdateEmoteState(FromID)
	self:OnBaHaFireEnd(EmotionID, FromID)	--巴哈烈焰
	do
		--恢复名字位置
		if not self.IsHoldWeaponID(EmotionID) then	--不是拔刀
			local IsSit,_ = self:IsSitState(FromID)
			if not IsSit then	--不是坐下
				local Actor = ActorUtil.GetActorByEntityID(FromID)
				local RideComp = Actor and Actor:GetRideComponent() or nil
				local bIsRide = RideComp and RideComp:IsInRide() or nil
				if bIsRide ~= true then	--不是坐骑上
					if not self:IsFacePlaying(FromID) then	--不是表情
						self:UpdateName(FromID)
					end
				end
			end
		end
	end

	-- 非持刀状态特效结束保底
	local Actor = ActorUtil.GetActorByEntityID(FromID)
	if nil ~= Actor and nil ~= Actor:GetAvatarComponent() and not Actor:IsHoldWeapon() then
		Actor:GetAvatarComponent():BreakEffect(_G.UE.EAvatarPartType.WEAPON_MASTER_HAND)
		Actor:GetAvatarComponent():BreakEffect(_G.UE.EAvatarPartType.WEAPON_SLAVE_HAND)
	end
end

function EmotionMgr:OnGameEventStartSwimming(Params)
	if Params.ULongParam1 == MajorUtil.GetMajorEntityID() then
		self:UpdateMajorCanUseType()
		self:SendStopEmotionAll()
	end

	self:StopAllEmotions(Params.ULongParam1, false, EmotionDefines.CancelReason.SWIM)
	local AvatarCom = ActorUtil.GetActorAvatarComponent(Params.ULongParam1)
	if AvatarCom then
		-- 立刻收刀
		AvatarCom:SetMasterHandWeaponState(1, false, _G.UE.EAttachmentTransformType.ALL, false)
		AvatarCom:SetSlaveHandWeaponState(1, false, _G.UE.EAttachmentTransformType.ALL, false)
	end
end

function EmotionMgr:OnGameEventEndSwimming(Params)
	if Params.ULongParam1 == MajorUtil.GetMajorEntityID() then
		self:UpdateMajorCanUseType()
	end
end

function EmotionMgr:OnGameEventPWorldExit(Params)
	-- 情感动作重置
	for ID, List in pairs(self.Tasks) do
		local TasksRemove = {}
		for k,v in ipairs(List) do
			table.insert(TasksRemove, v)
		end
		self:RemoveByList(ID, TasksRemove, true)
	end

	self.Tasks = {}
end

function EmotionMgr:OnGameEventSkillStart(Params)
	if nil == Params then return end
    local EntityID = Params.ULongParam1
	if not ActorUtil.IsPlayerOrMajor(EntityID) then
		return
	end
	
	-- 技能开始时 中断所有非持刀类情感动作(若在坐下状态制作道具 亦要终止)
	self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.SKILL)
	-- 根据SkillID 来判断是否需要临时持刀 持刀相关逻辑主要位于StateComp内
	local StateComp = ActorUtil.GetActorStateComponent(EntityID)
	local SkillID = Params.IntParam2
	if _G.UE.UStateComponent.ShouldTempHoldWeapon(SkillID) and StateComp then
		StateComp:TempHoldWeapon(_G.UE.ETempHoldMask.Skill)
	end

	if MajorUtil.IsMajor(Params.ULongParam1) then
		self:ReqRefreshUI()
	end
end

function EmotionMgr:OnGameEventSkillEnd(Params)
	if nil == Params then return end
    local EntityID = Params.ULongParam1
	if not ActorUtil.IsPlayerOrMajor(EntityID) then
		return
	end

	-- 根据SkillID 来判断是否需要临时持刀 持刀相关逻辑主要位于StateComp内
	local StateComp = ActorUtil.GetActorStateComponent(EntityID)
	local SkillID = Params.IntParam2
	if _G.UE.UStateComponent.ShouldTempHoldWeapon(SkillID) and StateComp and StateComp:IsHoldWeaponState() then
		StateComp:ClearTempHoldWeapon(_G.UE.ETempHoldMask.Skill, true)
	end

	if MajorUtil.IsMajor(Params.ULongParam1) then
		self:ReqRefreshUI()
	end
end

---切换姿势: 回包同步
function EmotionMgr:OnGameEventSetupPost(Params)
	local SetupKey = Params.IntParam1
	local RoleID = Params.ULongParam1
	local SetupValue = Params.StringParam1
	local IsSetSync = Params.BoolParam1
	local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)

	if SetupKey == ClientSetupKey.CSKAutoFoldWeapon then
		local WeaponValue = string.split(SetupValue, ',')
		if not WeaponValue then
			return
		end
		local StateComp = ActorUtil.GetActorStateComponent(EntityID)
		if StateComp then
			StateComp.bIsAutoDropWeapon = WeaponValue[1] == "1"			   --参数来源：游戏设置->角色->自动收回武器
			StateComp.HideWeaponTime = tonumber( WeaponValue[2] ) or 5	--参数来源：游戏设置->角色->自动收回武器时间（秒）
			
			local IsHoldWeapon = StateComp:IsHoldWeaponState()
			local IsCombatState = ActorUtil.IsCombatState(EntityID)
			if StateComp.bIsAutoDropWeapon and not IsCombatState and IsHoldWeapon then
				StateComp:TempHoldWeapon(_G.UE.ETempHoldMask.AutoDropWeapon)
				StateComp:ClearTempHoldWeapon(_G.UE.ETempHoldMask.AutoDropWeapon, true)
			end
			-- if not IsCombatState or not IsHoldWeapon then	--解决关闭自动收回武器后收刀，再次开启设置则无法收刀。
			-- 	StateComp:SetHoldWeaponState(IsHoldWeapon, StateComp.bIsAutoDropWeapon, StateComp.HideWeaponTime)
			-- end
		end

		local AnimCom = ActorUtil.GetActorAnimationComponent(EntityID)
		if Actor and AnimCom and Actor:IsHoldWeapon() then
			local bIsPlayRest = AnimCom.IsInEmote
			AnimCom.IsInEmote = not bIsPlayRest
		end

	elseif SetupKey == ClientSetupKey.CSKIdleAnims then
		if self.Tasks[EntityID] then
			-- 先处理已在播放其他情感动作
			local IsHoldWeaponID = false
			local TasksRemove = {}
			for _, v in ipairs(self.Tasks[EntityID]) do
				if EmotionAnimUtils.IsOnceAnim(v.MotionType) then		--从普通动作切换姿势时，立即中断普通动作
					table.insert(TasksRemove, v)
				
				elseif EmotionAnimUtils.IsFaceAnim(v.MotionType) then	--从表情切换姿势时，不停止表情
					local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
					if AnimComp == nil then return end
					AnimComp.IsInEmote = false
				
				elseif self.IsHoldWeaponID(v.EmotionID) then	--从战斗姿势切换为战斗闲置姿势，不停止拔刀
					IsHoldWeaponID = true
				end
			end
			if not IsHoldWeaponID then
				self:RemoveByList(EntityID, TasksRemove, true)
				EmotionAnimUtils.ApplyIdleCSValue(EntityID, SetupValue, IsSetSync)
				return
			end
		end

		EmotionAnimUtils.ApplyIdleCSValue(EntityID, SetupValue, IsSetSync)

		--bug=143816832 站姿切换后，换地图或者进本，姿态又回到初始值
		if MajorUtil.IsMajor(EntityID) then
			local AnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)
			if AnimInst == nil or PlayerAnimParam == nil then
				return
			end
			self.IdleSetupValue = SetupValue
		end
	end
end

------------↓ 气泡提示与聊天消息 start ↓------------

--- 显示头顶气泡Tips
---@param bIsTips 	启用显示
---@param EmotionID 播放动作
---@param FromID 	播放角色
---@param TargetID 	选中角色
---@param IDType	目标类型
---@param bSendChat	发送消息
function EmotionMgr:ShowTipsChat(bIsTips, EmotionID, FromID, TargetID, IDType, bSendChat)
	local TipsDesc, ChatMes
	if TargetID == nil or TargetID == 0 then  	--没有选中目标
		TipsDesc, ChatMes = self:NoTargetTips(FromID, EmotionID)

	else
		local CompanionName = EmotionMgr:GetCompanionName(TargetID, IDType)
		if CompanionName ~= nil then			--要先判断选中宠物
			TipsDesc, ChatMes = self:TargetTips(FromID, EmotionID, TargetID, CompanionName)
		elseif TargetID ~= FromID then 			--选中其他玩家
			local TargetName = ActorUtil.GetActorName(TargetID)
			TipsDesc, ChatMes = self:TargetTips(FromID, EmotionID, TargetID, TargetName)
		elseif TargetID == FromID then 			--选中自身（宠物共用自身ID）
			TipsDesc, ChatMes = self:NoTargetTips(FromID, EmotionID)
		end
	end
	if not string.isnilorempty(ChatMes) and bSendChat then
		self:SendChatMessage(ChatMes)  --附近频道发送聊天消息
	end

	if bIsTips == false then return end   		--某些情况不需要显示气泡
	if string.isnilorempty(TipsDesc) then return end
	local ViewParams = {
		EntityID = FromID, 
		EmotionID = EmotionID, 
		TipsDesc = TipsDesc }
	if nil ~= self.TipsTimeID then
		self:UnRegisterTimer(self.TipsTimeID)
		self.TipsTimeID = nil
	end
	self.TipsTimeID = self:RegisterTimer(function()
		if _G.UIViewMgr:IsViewVisible(UIViewID.EmotionUsingTips) then
			_G.UIViewMgr:HideView(UIViewID.EmotionUsingTips)  --若存在则先销毁旧tips，再创建新tips
		end
		_G.UIViewMgr:ShowView(UIViewID.EmotionUsingTips, ViewParams)
	end, 0.15, 0, 1, ViewParams)

end

--- 其他玩家选中其他玩家播放动作，会显示聊天信息
function EmotionMgr:ShowTargetChat(EmotionID, FromID, ToID, IDType)
	if 0 == ToID and nil == IDType then return end
	if FromID ~= ToID then
		local Major = MajorUtil.GetMajor()
		local From1 = ActorUtil.GetActorByEntityID(FromID)
		if From1 and Major then
			local Location1 = From1:FGetLocation(_G.UE.EXLocationType.ServerLoc)
			local MajorLocation = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
			local Dist = UKismetMathLibrary.Vector_Distance(Location1, MajorLocation)
			if nil == self.ChatScope then
				local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_EMOTION_CHAT_SCOPE)
				if nil ~= Cfg then
					self.ChatScope = Cfg.Value[1]
				end
			end
			if self.ChatScope and self.ChatScope >= Dist then	--限定可显示范围内的信息
				self:TargetChat(EmotionID, FromID, ToID, IDType)
			end
		end
	end
end

--- 向附近频道组装一条聊天消息
function EmotionMgr:TargetChat(EmotionID, FromID, ToID, IDType)
	if nil == ToID and nil == IDType then return end
	local FromName = ActorUtil.GetActorName(FromID)
	local TargetName = ActorUtil.GetActorName(ToID)
	if string.isnilorempty(TargetName) then return end
	local CompanionName = self:GetCompanionName(ToID, IDType)
	if not string.isnilorempty(CompanionName) then
		TargetName = CompanionName	--若选中的是宠物
	end

	local EmotionDescPrefix, EmotionDesc = self:GetEmotionDesc(ToID, EmotionID)
	EmotionDesc = self:MatchStringPatern(EmotionDesc)

	EmotionDesc = string.format("<span color=\"#%s\">%s</>", "AAFCE9", EmotionDesc)
	EmotionDescPrefix = string.format("<span color=\"#%s\">%s</>", "AAFCE9", EmotionDescPrefix)
	FromName = string.format("<span color=\"#%s\">%s</>", "83cb68", FromName)
	TargetName = string.format("<span color=\"#%s\">%s</>", "83cb68", TargetName)

	self:SendChatMessage(FromName .. EmotionDescPrefix .. TargetName .. EmotionDesc)
end

---获取情感动作表文本信息ID对应的文本信息内容（有、无目标）
function EmotionMgr:GetEmotionDesc(TargetID, EmotionID)
	local Emotion = EmotionCfg:FindCfgByKey(EmotionID)
	local EmotionDesc = ""
	local EmotionDescPrefix = ""

	if nil ~= Emotion then
		local EmotionContent = EmotionContentCfg:FindCfg("ID = " .. Emotion.EmotionContentID)
		if EmotionContent then
			if TargetID ~= nil and TargetID ~= 0 then
				-- 展示有目标文本信息
				local TargetContentText = EmotionContent.TargetContentText
				local SpContent = string.split(TargetContentText, "%%s")
				EmotionDescPrefix = SpContent[1] or ""
				EmotionDesc = SpContent[2] or ""
			else
				-- 展示无目标文本信息
				EmotionDesc = EmotionContent.ContentText
			end
		end
	end
	return EmotionDescPrefix, EmotionDesc
end

--- 删除句号
function EmotionMgr:MatchStringPatern(StringParam)
	local Pattern = "[%s.。]+$"
	if string.match(StringParam, Pattern) then
		StringParam = string.gsub(StringParam, Pattern, "")
	end
	return StringParam
end

--- 无选中目标
function EmotionMgr:NoTargetTips(EntityID, EmotionID)
	local EmotionContent = EmotionContentCfg:FindCfg("ID = " .. EmotionID)
	local EmotionDesc = (nil ~= EmotionContent) and EmotionContent.ContentText or ""
	if string.isnilorempty(EmotionDesc) then
		return
	end
	EmotionDesc = self:MatchStringPatern(EmotionDesc)
	if string.isnilorempty(EmotionDesc) then
		return
	end
	local MyName = ActorUtil.GetActorName(EntityID)
	local TipsDesc = string.format("<span color=\"#%s\">%s</>", "FFFFFF", EmotionDesc)  --头顶气泡字体的颜色
	local ChatDesc = string.format("<span color=\"%s\">%s</>", "#c6c6c6", EmotionDesc)--附近聊天字体颜色
	MyName = string.format("<span color=\"#%s\">%s</>", "7ecef4", MyName)		     	  --修改自己名字的颜色
	
	local ChatMes = MyName .. ChatDesc
	return TipsDesc, ChatMes
end

--- 有选中目标
function EmotionMgr:TargetTips(EntityID, EmotionID, TargetID, TargetName)
	local EmotionDescPrefix, EmotionDesc = self:GetEmotionDesc(TargetID, EmotionID)
	EmotionDesc = self:MatchStringPatern(EmotionDesc)
	if EmotionDesc == nil and EmotionDescPrefix == nil or EmotionDesc == "" and EmotionDescPrefix == "" then
		return
	end

	local MyName = ActorUtil.GetActorName(EntityID)
	if string.isnilorempty(MyName) or string.isnilorempty(TargetName) then
		return
	end
	local TipsDesc = string.format("<span color=\"#%s\">%s</>", "FFFFFF", EmotionDesc)--头顶气泡颜色
	local TipsDescPrefix = string.format("<span color=\"#%s\">%s</>", "FFFFFF", EmotionDescPrefix)
	local ChatDesc = string.format("<span color=\"%s\">%s</>", "#c6c6c6", EmotionDesc)--附近聊天颜色
	local ChatDescPrefix = string.format("<span color=\"%s\">%s</>", "#c6c6c6", EmotionDescPrefix)
	MyName = string.format("<span color=\"#%s\">%s</>", "7ecef4", MyName)
	TargetName = string.format("<span color=\"#%s\">%s</>", "83cb68", TargetName)

	TipsDesc = TipsDescPrefix .. TargetName .. TipsDesc
	local ChatMes = MyName .. ChatDescPrefix .. TargetName .. ChatDesc
	return TipsDesc, ChatMes
end

---发送聊天消息到附近频道
function EmotionMgr:SendChatMessage(Content)
	if Content == nil then
		return
	end

	_G.ChatMgr:AddEmotionTipsMsgInNearbyChannel(Content)
end

------------↑ 气泡提示与聊天消息 end ↑------------

--- 最近使用的时间
function EmotionMgr:IsRecentTime()
	local RecentTime = USaveMgr.GetInt(SaveKey.InteractionTimeEmotions, 0, false)
	local NewTime = TimeUtil.GetLocalTime()
	local bShowTime = NewTime - RecentTime < self.MaxLastTime
	local Recent = EmotionMgr:GetAllSavedEmotions(SaveKey.RecentUseEmotions)
	return bShowTime and #Recent > 0
end

function EmotionMgr:SetRecentTime()
	USaveMgr.SetInt(SaveKey.InteractionTimeEmotions, TimeUtil.GetLocalTime(), false)
end

--- 记录最近使用的情感动作
function EmotionMgr:SaveRecentEmotion(EmotionID)
	if EmotionID == nil then
		return
	end
	local EmotionName = tostring(EmotionID)
	local RecentEmotionsStr = USaveMgr.GetString(SaveKey.RecentUseEmotions, "", true)
	if #RecentEmotionsStr == 0 then
		RecentEmotionsStr = EmotionName
	else
		local EmotionIDSet = string.split(RecentEmotionsStr, ",")  --按逗号 ，分割元素
		local _, id = table.find_item(EmotionIDSet, EmotionName)
		if nil == id then
			table.insert(EmotionIDSet, 1, EmotionName)
			if #EmotionIDSet > self.MaxRecentEmoNum then    	   --设置最大保存的数量
				table.remove(EmotionIDSet, #EmotionIDSet)
			end
		else
			table.remove(EmotionIDSet, id)
			table.insert(EmotionIDSet, 1, EmotionName)
		end

		RecentEmotionsStr = table.concat(EmotionIDSet, ',')  --将所有参数按逗号串联起来
	end
	--print("[Emotion] Save Recent Emotion Str " .. RecentEmotionsStr)
	USaveMgr.SetString(SaveKey.RecentUseEmotions, RecentEmotionsStr, true)
end

---获取所有保存Key中的情感动作
function EmotionMgr:GetAllSavedEmotions(SaveEmotionsKey)

	---获取所有UI显示顺序大于等于0的情感动作
	if self.AllMatchedEmotions == nil then
		self.AllMatchedEmotions = EmotionCfg:FindAllCfg("UIPriority >= 0")
	end
	local AllEmotion = self.AllMatchedEmotions

	local CurEmotionList = {}
	if nil == SaveEmotionsKey then
		--收藏
		for id, v in pairs(EmoActPanelVM.SavedFavoriteID) do
			if v == true then
				for _, Emotion in pairs(AllEmotion) do
					if id == Emotion.ID then
						if self:IsActivatedID(id) then
							table.insert(CurEmotionList, Emotion)
						end
					end
				end
			end
		end
	else
		--最近使用
		local RecentEmotionsStr = USaveMgr.GetString(SaveEmotionsKey, "", true)
		local EmotionIDSet = string.split(RecentEmotionsStr, ",")  --按逗号 ，分割元素
		for i, ID in pairs(EmotionIDSet) do
			local numberID = tonumber(ID)
			for _, Emotion in pairs(AllEmotion) do
				if numberID == Emotion.ID then
					if self:IsActivatedID(numberID) then
						table.insert(CurEmotionList, Emotion)
					end
				end
			end
		end
	end
	return CurEmotionList
end

-- ---获取最近使用的收藏ID
-- function EmotionMgr:GetSavedRecentEmotionID(EmotionID)

-- 	if EmotionID == nil then
-- 		return
-- 	end

-- 	local EmotionName = tostring(EmotionID)

-- 	local RecentEmotionsStr = USaveMgr.GetString(SaveKey.RecentUseEmotions, "", true)
-- 	local EmotionIDSet = string.split(RecentEmotionsStr, ",")

-- 	local _, id = table.find_item(EmotionIDSet, EmotionName)

-- 	return id
-- end

--- 保存收藏的情感动作
function EmotionMgr:SaveFavoriteEmotion(EmotionID)
	if EmotionID == nil then
		return false
	end
	local EmotionName = tostring(EmotionID)
	local FavoriteEmotions = USaveMgr.GetString(SaveKey.FavoriteEmotions, "", true)
	if #FavoriteEmotions == 0 then
		FavoriteEmotions = EmotionName
	else
		local EmotionIDSet = string.split(FavoriteEmotions, ",")   --按逗号，分割元素, 将一个字符串分割成数组
		if #EmotionIDSet >= self.MaxFavoriteEmoNum then    	 	   --是否超出最大保存的数量
			--table.remove(EmotionIDSet, #EmotionIDSet) --移除最后一个
			return false
		end
		local _, id = table.find_item(EmotionIDSet, EmotionName)
		if id == nil then
			table.insert(EmotionIDSet, 1, EmotionName)  	--在表头插入ID，若已存在则不执行
		end
		FavoriteEmotions = table.concat(EmotionIDSet, ',')       --将所有参数按逗号 ，链接成一个字符串
	end
	USaveMgr.SetString(SaveKey.FavoriteEmotions, FavoriteEmotions, true)
	return true
end

---查询ID是否已收藏
function EmotionMgr:IsSavedFavoriteID(EmotionID)
	return EmoActPanelVM.SavedFavoriteID[EmotionID] == true
end

---获取已收藏的数量
function EmotionMgr:GetFavoriteNum()
	local Num = 0
	for ID, v in pairs(EmoActPanelVM.SavedFavoriteID) do
		if ID and v == true then
			Num = Num + 1
		end
	end
	return Num
end

---设置已收藏 ID = true
function EmotionMgr:SetFavoriteIDList(EmotionID, bIsFavorite)
	EmoActPanelVM.SavedFavoriteID[EmotionID] = bIsFavorite
end

---删除收藏ID
function EmotionMgr:RemoveFavoriteEmotionID(EmotionID)
	if EmotionID == nil then
		return
	end

	local EmotionName = tostring(EmotionID)

	local RecentEmotionsStr = USaveMgr.GetString(SaveKey.FavoriteEmotions, "", true)
	local EmotionIDSet = string.split(RecentEmotionsStr, ",")

	local _, id = table.find_item(EmotionIDSet, EmotionName)

	if id == nil then
		return
	end

	table.remove(EmotionIDSet, id)
	EmotionIDSet = table.concat(EmotionIDSet, ',')       --将所有参数按逗号 ，链接
	USaveMgr.SetString(SaveKey.FavoriteEmotions, EmotionIDSet, true)

end

---列表数量不满状态需要补充空格占位
---@param TargetTable 插入空格的列表
---@param MaxTableNumber 列表的最大长度
function EmotionMgr:FillBlank(TargetTable, MaxTableNumber)
	if #TargetTable < MaxTableNumber then
		for i = 1, MaxTableNumber - #TargetTable do
			table.insert(TargetTable, {})
		end
	end
	return TargetTable
end

--- 最近使用与收藏
function EmotionMgr:RecentFavoriteTab()
	local Favorite = EmotionMgr:GetAllSavedEmotions()
	local MaxNullSlot = self.MaxFavoriteEmoNum
	Favorite = self:FillBlank(Favorite, MaxNullSlot)	--不足则补空格

	if not EmotionMgr:IsRecentTime() then
		--仅收藏
		USaveMgr.SetString(SaveKey.RecentUseEmotions, '', true)	--超过最近使用的时间,会清空最近使用记录

		local FavoriteList = {{TextSort = EmotionDefines.RecentFavorite.Favorite, EmotionList = Favorite}}
		return FavoriteList
	else
		--最近使用、收藏
		local Recent = self:GetAllSavedEmotions(SaveKey.RecentUseEmotions)
		Recent = self:FillBlank(Recent, self.MaxRecentEmoNum)

		local ListRecentAndFavorite = 
		{
			{TextSort = EmotionDefines.RecentFavorite.Recent, EmotionList = Recent},
			{TextSort = EmotionDefines.RecentFavorite.Favorite, EmotionList = Favorite},
		}
		return ListRecentAndFavorite
	end
end

--- 玩家所有动作都在这个列表（不包含收藏、最近使用）
---@param MotionType 情感动作类型
function EmotionMgr:EmotionTab(MotionType, CheckFunc)
	local MajorActiveEmotionIDs = self.MajorActiveEmotionIDs
	local AllEmotion = {}

	if MotionType ~= nil then
		if MotionType == EmotionDefines.EmotionTypeId.OnceEmotionTab then      -- 一般1
			if not self.OnceEmotions then
				self.OnceEmotions = EmotionCfg:FindAllCfg("MotionType == 1 AND UIPriority >= 0")
			end
			AllEmotion = self.OnceEmotions
		elseif MotionType == EmotionDefines.EmotionTypeId.LoopEmotionTab then  -- 持续2
			if not self.LoopEmotions then
				self.LoopEmotions = EmotionCfg:FindAllCfg("(MotionType == 2 OR MotionType == 3) AND UIPriority >= 0")
			end
			AllEmotion = self.LoopEmotions
		elseif MotionType == EmotionDefines.EmotionTypeId.FaceEmotionTab then  -- 表情3
			if not self.FaceEmotions then
				self.FaceEmotions = EmotionCfg:FindAllCfg("MotionType == 0 AND UIPriority > 0")
			end
			AllEmotion = self.FaceEmotions
		end
	else
		if not self.AllMatchedEmotions then
			self.AllMatchedEmotions = EmotionCfg:FindAllCfg("UIPriority >= 0")
		end
		AllEmotion = self.AllMatchedEmotions
	end

	--- 这里存放所有对应类型的动作(不包含收藏类)
	local CurEmotionList = {}

	--- 只展示激活的情感动作，将当前类型的动作添加到动作表
	for k,v in ipairs(AllEmotion) do
		if MajorActiveEmotionIDs[v.ID] then
			if not CheckFunc or CheckFunc(v) then
				table.insert(CurEmotionList, v)
			end
		end
	end

	-- 将动作排序
	table.sort(CurEmotionList,function(l,r)
		local PriorityL = l.UIPriority or 0
		local PriorityR = r.UIPriority or 0
		if PriorityL == PriorityR then
		end
		return PriorityL < PriorityR
	end)

	do
		-- 任务交互时把目标动作直接插入列表正中间  (任务相关)
		-- 若不需要中间插入则只需把这代码块注销即可
		if nil ~= self.TargetQuestEmotionID then
			CurEmotionList = self:CenterByIDInList(CurEmotionList, self.TargetQuestEmotionID)
		end
	end

	return CurEmotionList
end

--- 获取所有表情
function EmotionMgr:FaceEmotionList()

	return self:EmotionTab(EmotionDefines.EmotionTypeId.FaceEmotionTab)
end

--- 持续类情感动作在服务器会保存其播放状态，有玩家进⼊视野时会发包告知
function EmotionMgr:OnNetStateUpdate(Params)
	local Stat = Params.IntParam1
	if Stat == ProtoCommon.CommStatID.COMM_STAT_EMOTION then
		local CurEmotion = Params.BoolParam1
		local EntityID = Params.ULongParam1

		if self:IsEmotionPlaying(EntityID, self.EXD_EMOTE_WAKE) then
			--正在起床不要立即停止
			return
		end
	
		if not CurEmotion then
			self:StopAllEmotionsNotState(EntityID, true, EmotionDefines.CancelReason.SERVER_NOTIFY)
		end
	end
end

function EmotionMgr:IsOnPlayState(EmotionID, StatEmotion, EntityID)
	if StatEmotion == 0 then
		return false
	end
	if self:IsEmotionPlaying(EntityID, StatEmotion) then
		return false
	end
	if EmotionID ~= 0 and self.IsHoldWeaponID(StatEmotion)then
		return false
	end
	return true
end

--- 服务器回包后，播放情感动作
function EmotionMgr:PlayEmotionServer(EntityID, MsgBody, bForceLoop)
	local TargetID = MsgBody.Target and MsgBody.Target.ID or 0
	local IDType = MsgBody.Target and MsgBody.Target.IDType or 0
	local EmotionID = MsgBody.EmotionID or MsgBody.Emotion
	local StatEmotion = MsgBody.StatEmotion

	if EmotionID == 0 and StatEmotion == 0 then
		self:StopAllEmotions(EntityID, true)
		return
	end

	-- 如果TargetID是ListID 则将其转换为EnitityID统一后续流程
	local TargetEntityID = self:GetEntityIDByType(TargetID, IDType)
	if TargetEntityID == nil then
		return
	else
		TargetID = TargetEntityID
	end

	-- 先播普通情感动作
	if EmotionID ~= 0 then
		local Params = {}
		Params.ULongParam1 = EntityID
		Params.ULongParam2 = TargetID
		Params.IntParam1 = EmotionID
		Params.BoolParam1 = bForceLoop
		Params.BoolParam3 = self.bIsNeedShowTips
		Params.IDType = IDType
		Params.bSendChat = true
		self:OnPlayEmotion(Params)
	end

	-- 再播状态性情感动作（抽拔刀）
	if self:IsOnPlayState(EmotionID, StatEmotion, EntityID) then
		local Params = {}
		Params.ULongParam1 = EntityID
		Params.ULongParam2 = TargetID
		Params.IntParam1 = StatEmotion
		Params.BoolParam1 = bForceLoop
		Params.BoolParam3 = self.bIsNeedShowTips
		Params.bSendChat = true
		self:OnPlayEmotion(Params)
	end

	self:PlayHelmetGimmick(EmotionID, EntityID)
end

--- 发送开始播放事件
function EmotionMgr:EmtionEnter(Params)
	local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:EmtionEnter")
	local FromID = Params.ULongParam1
	local TargetID = Params.ULongParam2
	local EmotionID = Params.IntParam1
	local NeedShowHUD = Params.BoolParam3
	local EventParams = EventMgr:GetEventParams()
	EventParams.ULongParam1 = FromID		--自己的EntityID
	EventParams.ULongParam2 = TargetID		--选中目标的EntityID（若没有为0）
	EventParams.IntParam1 = EmotionID		--情感动作ID
	EventParams.BoolParam3 = NeedShowHUD	--是否显示头顶气泡
	EventParams.IDType = Params.IDType		--选中目标的类型（若选中宠物为4）
	EventParams.bSendChat = Params.bSendChat--是否发送消息到附近聊天频道
	self:EmotionTaskEnter(EventParams)

	EventMgr:SendEvent(EventID.PostEmotionEnter, EventParams)
	EventMgr:SendCppEvent(EventID.PostEmotionEnter, EventParams)
end

---不经由服务器进⾏情感动作的播放
function EmotionMgr:OnPlayEmotion(Params)
	local _ <close> = CommonUtil.MakeProfileTag("EmotionMgr:OnPlayEmotion")
	local EmotionTask = EmotionTaskFactory:CreateTask(Params)
	local FromID = Params.ULongParam1
	if EmotionTask:CanPlayEmotion() then
		self:RemoveIncompatibleEmotion(EmotionTask)
		if not self.Tasks[FromID] then
			self.Tasks[FromID] = {}
		end
		table.insert(self.Tasks[FromID], EmotionTask)
		-- print('[Emotion] Tasks Num:', #self.Tasks[FromID])
		self:EmtionEnter(Params)
		EmotionTask:PlayEmotion()
		return EmotionTask
	end
end

function EmotionMgr:RemoveIncompatibleEmotion(Task)
	local EmotionID = Task.EmotionID
	local EntityID = Task.FromID
	local MotionType = Task.MotionType
	if self.Tasks[EntityID] then
		local TasksRemove = {}
		for _, v in ipairs(self.Tasks[EntityID]) do
			if not self:CheckIncompatible(MotionType, v.MotionType) then
				if self:IsBattleAndWeapon(EmotionID, v.IsBattleEmotion) then
					table.insert(TasksRemove, v)
				end
			end
		end
		-- 服务器亦会检测
		self:RemoveByList(EntityID, TasksRemove, true)
	end
end

function EmotionMgr:CheckIncompatible(MotionType1, MotionType2)
	-- 测试兼容性
	-- 表情和其他动作能兼容
	if MotionType1 == 0 and MotionType2 == 0 then
		return false
	end
	if MotionType1 == MotionType2 then
		return false
	end
	-- 若已经具有特殊情感动作（收拔刀）则其可以和表情或一次性情感动作兼容
	if MotionType2 == 3 and MotionType1 ~= 2 then
		return true
	end

	return MotionType1 == 0 or MotionType2 == 0
end

-- 拔刀兼容战斗动作
function EmotionMgr:IsBattleAndWeapon(OnEmotionID, LastIsBattleEmotion)
	if (LastIsBattleEmotion == 1) and self.IsHoldWeaponID(OnEmotionID) then
		return false
	end

	return true
end

---@field CancelByServer boolean
---CancelByServer为true时意味着前台无需同步后台
function EmotionMgr:StopAllEmotionsOf(EntityID, MotionTypes, CancelByServer, CancelReason)
	if self.Tasks[EntityID] then
		-- 由于CancelEmotion会导致Tasks的元素被remove掉 故先拷贝
		local TasksClone = {}
		for k,v in ipairs(self.Tasks[EntityID]) do
			if table.find_item(MotionTypes, v.MotionType) ~= nil then
				v.CancelReason = CancelReason
				table.insert(TasksClone, v)
			end
		end
		self:RemoveByList(EntityID, TasksClone, CancelByServer)
	end
end

---@field CancelByServer boolean
---CancelByServer为true时意味着前台无需同步后台
---PredValue true 使用PredFunc的返回值与之对比 移除相同的
---CancelReason 用于保存终止参数 
function EmotionMgr:StopEmotionsByPred(EntityID, PredFunc, CancelByServer, PredValue, CancelReason)
	if PredValue == nil then
		PredValue = true
	end
	if self.Tasks[EntityID] then
		-- 由于CancelEmotion会导致Tasks的元素被remove掉 故先拷贝
		local TasksClone = {}
		for _, v in ipairs(self.Tasks[EntityID]) do
			if PredFunc(v.EmotionID) == PredValue then
				v.CancelReason = CancelReason
				table.insert(TasksClone, v)
			end
		end
		self:RemoveByList(EntityID, TasksClone, CancelByServer)
	end
end

function EmotionMgr:RemoveByList(EntityID, List, CancelByServer)
	for k,v in ipairs(List) do
		v.CancelByServer = CancelByServer
		v:CancleEmotion()
	end

	if self.Tasks[EntityID] and #self.Tasks[EntityID] == 0 then
		self.Tasks[EntityID] = nil
	end
end

--- 坐下、切换姿势、表情、一般动作，当四者同时在播放时，不出现站起且不能切回默认姿势
function EmotionMgr:IsSitStateFace(EntityID)
	if not self.Tasks[EntityID] then
		return false
	end
	local IsSit = self:IsSitState(EntityID)
	if not IsSit then
		return false
	end
	local IsFace = self:IsFacePlaying(EntityID)
	local bIsPlay = false
	for _,Task in pairs(self.Tasks[EntityID])do
		if EmotionAnimUtils.IsOnceAnim(Task.MotionType) then
			if IsFace then
				bIsPlay = false
				break
			end
			bIsPlay = true
			break
		end
	end

	return IsFace and bIsPlay
end

--- 站立、切换姿势、表情，当三者同时在播放时，不能切回默认姿势
function EmotionMgr:IsNormalIdleFace(EntityID)
	if not self.Tasks[EntityID] then
		return false
	end
	local IsSit = self:IsSitState(EntityID)
	if IsSit then
		return false
	end
	local IsFace = self:IsFacePlaying(EntityID)
	if not IsFace then
		return false
	end
	local AnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)
	if AnimInst == nil or PlayerAnimParam == nil then
		return false
	end
	if PlayerAnimParam.NormalIdleType ~= 0 then
		return true
	end
end

--- 正在播放表情
function EmotionMgr:IsFacePlaying(EntityID)
	if self.Tasks[EntityID] then
		for _,Task in pairs(self.Tasks[EntityID])do
			if Task:IsFaceAnim() then
				return true
			end
		end
	end
	return false
end

--- 若已在播放表情类，检测是否也在播放其他肢体动作
function EmotionMgr:IsBodyToFacePlaying(EntityID)
	local IsPlay = false
	if self.Tasks[EntityID] then
		for _,Task in pairs(self.Tasks[EntityID])do
			if EmotionAnimUtils.IsFaceAnim(Task.MotionType) then
				IsPlay = true
			elseif EmotionAnimUtils.IsOnceAnim(Task.MotionType) then
				IsPlay = false
				return IsPlay
			end
			if IsPlay then
				if EmotionAnimUtils.IsLoopAnim(Task.MotionType) then
					IsPlay = false
					return IsPlay
				end
			end
		end
	end
	return IsPlay
end

--- 若正在播放（坐）情感动作ID = 50、52，则为true
function EmotionMgr:IsSitState(EntityID)
	if self.HoldWeaponSitID then
		for  _,v in ipairs(self.HoldWeaponSitID) do
			if self:IsEmotionPlaying(EntityID, v) then
				return true, v
			end
		end
		return false;
	end
end

--- 判断ID是坐下（动作ID = 50、52）
function EmotionMgr.IsSitEmotionID(EmotionID)
	for  _,v in pairs(_G.EmotionMgr.HoldWeaponSitID) do
		if EmotionID == v then
			return true;
		end
	end
	return false;
end

--- 持有武器ID == 116
function EmotionMgr.IsHoldWeaponID(EmotionID)
	return EmotionID == _G.EmotionMgr.HoldWeaponEmotionID
end

--- 判断 ID = 90（改变姿势）
function EmotionMgr:IsChangePoseEmotion(EmotionID)
	return EmotionID == 90
end

--- 头部装备 ID = {60, 61}
function EmotionMgr:IsEquipEmotion(EmotionID)
	if EmotionID == 61 then
		return true
	end
	if EmotionID == 60 then
		return true
	end
	return false
end

--- 睡觉起床 ID = {88, 89}
function EmotionMgr:IsBedEmotion(EmotionID)
	if EmotionID == 88 then
		return true
	end
	if EmotionID == 89 then
		return true
	end
	return false
end

--- 若正在床上睡觉，则为true
function EmotionMgr:IsBedState(EntityID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if PlayerAnimInst and PlayerAnimInst.bUseBed then
		return true
	end
	return false;
end

--- 状态性ID
function EmotionMgr:IsNormalEmotion(ID)
	local SpecIDs = {116, 50, 52, 90}
	return table.find_item(SpecIDs, ID) ~= nil
end

-- 将listid 或者entityid统一转成entityid
function EmotionMgr:GetEntityIDByType(TargetID, IDType)
	if IDType == EmotionTargetType.EmotionTargetTypeListID then
		local TargetActor = ActorUtil.GetActorByListID(TargetID)
		if TargetActor and TargetActor:GetAttributeComponent() then
			local EntityID = TargetActor:GetAttributeComponent().EntityID
			return EntityID
		else
			return nil
		end
	else
		return TargetID
	end
end

--- 刷新情感动作小图标UI的可用性
function EmotionMgr:ReqRefreshUI()
	EventMgr:SendEvent(EventID.EmotionRefreshItemUI)
end

--- 更新当前角色状态，如站立、坐下时、在坐骑时、等等
function EmotionMgr:UpdateMajorCanUseType()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local Major = MajorUtil.GetMajor()
	local PrevType = self.MajorCanUseType

	if Major and Major:GetRideComponent():IsInRide() then  --是坐骑状态
		self.MajorCanUseType = EmotionDefines.CanUseTypes.RIDE
	elseif self.FishStatus == true then
		self.MajorCanUseType = EmotionDefines.CanUseTypes.FISHING
	elseif Major and Major:IsSwimming() then
		self.MajorCanUseType = EmotionDefines.CanUseTypes.SWIMMING
	else
		local bIsSitState, SitEmotionID = self:IsSitState(MajorEntityID)
		if SitEmotionID == 52 then
			self.MajorCanUseType = EmotionDefines.CanUseTypes.SIT_GROUND
		elseif SitEmotionID == 50 then
			self.MajorCanUseType = EmotionDefines.CanUseTypes.SIT_CHAIR
		else
			self.MajorCanUseType = EmotionDefines.CanUseTypes.STAND
		end
	end

	if self.MajorCanUseType ~= PrevType then
		self:ReqRefreshUI()
	end
end

function EmotionMgr:OnGameEventMountCall(Params)
	if Params.EntityID == MajorUtil.GetMajorEntityID() then
		self:UpdateMajorCanUseType()
	end
end

function EmotionMgr:OnGameEventMountBack(Params)
	if Params.EntityID == MajorUtil.GetMajorEntityID() then
		self:UpdateMajorCanUseType()
	end
end

function EmotionMgr:OnGameEventEnterFishStatus(Params)
	self.FishStatus = true
	self:UpdateMajorCanUseType()
end

function EmotionMgr:OnGameEventExitFishStatus(Params)
	self.FishStatus = false
	self:UpdateMajorCanUseType()
end

function EmotionMgr:OnGameEventRoleLoginRes(Params)
	-- 查询Major的情感动作权限
	local MsgID = CS_CMD.CS_CMD_EMOTION
	local SubMsgID = EMOTION_SUB_ID.EmotionSubMsgQuery
	local MsgBody = {}
	MsgBody.SubMsgID = SubMsgID
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

	--- 断线重连（在重连后玩家的EntityID会变）
	if Params and Params.bReconnect then
		self:StopSitChairByMajor()
		self:SendEmotionStatQueryReq()
	-- else
		-- CommSideBarUtil.ClearCurEasyUseLastType()
	end
end

function EmotionMgr:SendEmotionStatQueryReq()
	local MsgID = CS_CMD.CS_CMD_EMOTION
	local SubMsgID = EMOTION_SUB_ID.EmotionSubMsgQueryStat
	local MsgBody = {}
	MsgBody.SubMsgID = SubMsgID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---激活
function EmotionMgr:ActiveEmotion(EmotionID)
	self.MajorActiveEmotionIDs[EmotionID] = true
end

---不激活
function EmotionMgr:DeactiveEmotion(EmotionID)
	self.MajorActiveEmotionIDs[EmotionID] = nil
end

---查询ID是否已解锁
function EmotionMgr:IsActivatedID(EmotionID)
	return EmotionID and self.MajorActiveEmotionIDs[EmotionID] or false
end

---人物肖像（ 接口 ）
function EmotionMgr:IsActivated(EmotionID)
	if EmotionID % 15 == 0 then
		return false
	end

	return EmotionID and self.MajorActiveEmotionIDs[EmotionID] or false
end

--- 向自己或其他玩家的宠物发送情感动作，该宠物会与主角交互
function EmotionMgr:CompanionStartEmote(EntityID, EmotionID)
	local TargetActor = _G.SelectTargetMgr:GetCurrSelectedTarget()  				--选中的Actor
	if TargetActor then
		local TargetCompanion = TargetActor:Cast(_G.UE.ACompanionCharacter)			--选中的宠物
		if TargetCompanion and TargetCompanion:GetAttributeComponent() then
			local TargetID = TargetCompanion:GetAttributeComponent().Owner			--宠物主人的ID
			local SubMsgID = EMOTION_SUB_ID.EmotionSubMsgEnter
			local TargetType = EmotionTargetType.EmotionTargetTypeListCompanion
			local MsgBody = {}
			MsgBody.SubMsgID = SubMsgID
			MsgBody.Enter = { EmotionID = EmotionID, Target = {ID = TargetID, IDType = TargetType}}
			local Caster = ActorUtil.GetActorByEntityID(EntityID)    				--玩家
			TargetCompanion:RequestEmotion(EmotionID, Caster)
			return MsgBody
		end
	end
end

--- 宠物交互, 交互距离要小于5米
---@param EntityID  发起玩家
---@param EmotionID 交互动作
---@param Target    交互对象
function EmotionMgr:CompanionStartEmoteNotify(EntityID, EmotionID, Target)
	if Target == nil then return end
	local TargetID = Target.ID
	local IDType = Target.IDType

	if TargetID == nil or TargetID == 0 or (IDType ~= EmotionTargetType.EmotionTargetTypeListCompanion) then 
		return
	end

	local EntityActor = ActorUtil.GetActorByEntityID(TargetID)
	if (EntityActor == nil) or (EntityActor:GetCompanionComponent() == nil) then return end
	local TargetCompanion = EntityActor:GetCompanionComponent():GetCompanion()

	if TargetCompanion then
		local Caster = ActorUtil.GetActorByEntityID(EntityID)
		if Caster == nil then return end
		TargetCompanion:RequestEmotion(EmotionID, Caster)
	end
end

---根据选中网络玩家的宠物，来获取宠物名字
---@param TargetID 	宠物的主人
---@param IDType 	类型是宠物
function EmotionMgr:GetCompanionName(TargetID, IDType)
	if TargetID == nil or TargetID == 0 or IDType == nil then 
		return nil 
	end

	if IDType == EmotionTargetType.EmotionTargetTypeListCompanion then
		local TargetCharactor = ActorUtil.GetActorByEntityID(TargetID)
		if (TargetCharactor == nil) or (TargetCharactor:GetCompanionComponent() == nil) then return end
		local TargetCompanion = TargetCharactor:GetCompanionComponent():GetCompanion()
		if TargetCompanion then
			local AttributeComponent = TargetCompanion:GetAttributeComponent()
			if AttributeComponent then
				local CompanionData = CompanionCfg:FindCfgByKey(AttributeComponent.ResID)
				if CompanionData == nil then return end
				return CompanionData.Name
			end
		end
	end
	return nil
end

function EmotionMgr:GetHeight()
	local Major = MajorUtil.GetMajor()
	if Major == nil then
		return 76
	end
	local HeadLocation = Major:GetSocketLocationByName("H_head_M")
	local RootLocation = Major:GetSocketLocationByName("H_root_M")
	self.Height = HeadLocation.Z - RootLocation.Z
	return self.Height
	--  _G.UE.UKismetSystemLibrary.DrawDebugCoordinateSystem(_G.FWORLD(), HeadLocation, _G.UE.FRotator(0), 50, 50, 1);
	--  _G.UE.UKismetSystemLibrary.DrawDebugCoordinateSystem(_G.FWORLD(), RootLocation, _G.UE.FRotator(0), 100, 100, 1);
end

function EmotionMgr:GetEid(Eid, AttachType)
	local Major = MajorUtil.GetMajor()
	if Major == nil then return end
	local EidCfg = require("TableCfg/EidCfg")
	local SearchConditions = string.format("EntityID == \"%s\" AND Eid == \"%s\"", AttachType, Eid)
	local EidData = EidCfg:FindCfg(SearchConditions)  --TODO 注意：这里在查表时，定义为字符串的字段列要加\"字段\"
	if EidData == nil then
		return _G.UE.FVector(0, 0, 0)
	end
	local EidLoaction = _G.UE.FVector(EidData.OffsetX, EidData.OffsetY, EidData.OffsetZ)
	return EidLoaction
	-- local EidTransform = _G.UE.FTransform()
	-- Major:GetEidTransform(Eid, EidTransform)
	-- return EidTransform
end

--- 调整坐下时相机的偏移
---@param EmotionID		ID填50_52_88_13
---@param bIsStat 		进入状态
---@param bHeightAdjust 下蹲相机跟随
function EmotionMgr:SetCameraLookAt(EmotionID, bIsStat, bHeightAdjust)
	local Major = MajorUtil.GetMajor()
	if Major == nil then return end
	local MajorCameraCom = Major:GetCameraControllComponent()
	if MajorCameraCom == nil then return end
	local CameraResetType = _G.UE.ECameraResetLocation.RecordLocation
	local CameraMoveParam = _G.LuaCameraMgr:GetDefaultCameraParam()
	local OffsetLocation = _G.UE.FVector(0, 0, 0)

	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
	local AttachType = AvatarComp and AvatarComp:GetAttachType() or "nil"
	local TypeName = string.format("Name = \"%s\"", AttachType)
	local EidCfg = EmotionEidCfg:FindAllCfg(TypeName)
	EidCfg = EidCfg and EidCfg[1] or nil

	if bIsStat then
		if EidCfg then
			if EmotionID == self.SitChairID then
				OffsetLocation.Z = EidCfg.Sit			--坐椅子上
			elseif EmotionID == self.SitGroundID then
				OffsetLocation.Z = EidCfg.SitGround		--坐地上
			elseif EmotionID == self.EXD_EMOTE_SLEEP or EmotionID == self.EXD_EMOTE_NOD then	--睡床上
				OffsetLocation.Z = EidCfg.Bed
			elseif EmotionID == 0 and bHeightAdjust then--下蹲相机跟随
				OffsetLocation.Z = -EidCfg.Down_M
			end
		end
	end

	CameraMoveParam.ResetType = _G.UE.ECameraResetType.Interp
	CameraMoveParam.LagValue = 0.01
	CameraMoveParam.SocketExternOffset = OffsetLocation
	MajorCameraCom:ResetSpringArmByParam(CameraResetType, CameraMoveParam)

	self:UnRegisterGameEvent(EventID.PhotoEnd, self.SetCameraLookAt)
	if not bIsStat then
		if _G.PhotoMgr.IsOnPhoto then
			print("[EmotionMgr]退出拍照时会重新恢复镜头位置,此处重新调整镜头Z高度")
			self:RegisterGameEvent(EventID.PhotoEnd, self.SetCameraLookAt)
		end
	end
end

--- 相机运镜效果（该方案未启用）
---@param PrevType 		  前一个状态
---@param MajorCanUseType 现在的状态
function EmotionMgr:SetCameraLocation(PrevType, MajorCanUseType)
	local Major = MajorUtil.GetMajor()
	local MajorCameraCom = Major:GetCameraControllComponent()
	if MajorCameraCom == nil then return end
	local LocationType = _G.UE.ECameraResetLocation.RecordLocation
	local RotatorYaw = math.random(140, 220)
	local CameraMoveParam = _G.UE.FCameraResetParam()
	CameraMoveParam.Distance = 300;   		 --设置弹簧臂长度
	CameraMoveParam.Rotator = _G.UE.FRotator(0, RotatorYaw, 0)
    CameraMoveParam.ResetType = _G.UE.ECameraResetType.Interp
	CameraMoveParam.LagValue = 3  			 --旋转速度
    CameraMoveParam.bRelativeRotator = true  --相对旋转
    CameraMoveParam.TargetOffset = _G.UE.FVector(0, 0, 0)  		--目标偏移
    CameraMoveParam.NextTransform = _G.UE.FTransform()
	CameraMoveParam.SocketExternOffset = _G.UE.FVector(0, 0, 0)	--弹簧臂末端偏移
    CameraMoveParam.FOV = 0;
	--因为不同角色身高差异，这里是获取主角头部的骨骼插槽位置
	local HeadLocation = Major:Cast(_G.UE.ABaseCharacter):GetSocketLocationByName("head_M")
	local OffsetFactor = UKismetMathLibrary.MapRangeClamped(HeadLocation.Z, 100, 250, -5, -60)   --高度修正因素
	local Type = EmotionDefines.CanUseTypes
	if MajorCanUseType == Type.SIT_CHAIR and PrevType == Type.STAND then  	 	 --椅子上
		CameraMoveParam.LagValue = 3
		CameraMoveParam.SocketExternOffset = _G.UE.FVector(0, 0, OffsetFactor)
		MajorCameraCom:ResetSpringArmByParam(LocationType, CameraMoveParam)
	elseif MajorCanUseType == Type.SIT_GROUND and PrevType == Type.STAND then  	 --坐地上
		CameraMoveParam.LagValue = 5
		CameraMoveParam.SocketExternOffset = _G.UE.FVector(0, 0, -100)
		MajorCameraCom:ResetSpringArmByParam(LocationType, CameraMoveParam)
	elseif PrevType == Type.SIT_CHAIR or PrevType == Type.SIT_GROUND then
		MajorCameraCom:ResetSpringArmToDefault(true, 10)
	end
end

--- 巴哈烈焰
function EmotionMgr:OnBaHaFire(EmotionID, EntityID)
	if EmotionID == self.EXD_EMOTE_BAjAFIRE then

		--播放音效
		-- local FromActor = ActorUtil.GetActorByEntityID(EntityID)
		-- if FromActor then
		-- 	local Location = FromActor:K2_GetActorLocation()
		-- 	Location.Z = Location.Z + 150
		-- 	local Rotation = _G.UE.FRotator(0)
		-- 	local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/etc/SE_VFX_Etc_Emot_Megaflare/Play_SE_VFX_Etc_Emot_Megaflare.Play_SE_VFX_Etc_Emot_Megaflare'"
		-- 	AudioUtil.LoadAndPlaySoundAtLocation(SoundPath, Location, Rotation, _G.UE.EObjectGC.NoCache)
		-- end

		--实时调整名字位置
	--	self:OnNameTask(EntityID)
		--self:UpdateName(EntityID, -50)

		--调整相机
		if MajorUtil.IsMajor(EntityID) then
			local Major = MajorUtil.GetMajor()
			local MajorCameraCom = Major:GetCameraControllComponent()
			if MajorCameraCom == nil then return end
			local Distance = 800;  	--设置弹簧臂长度
			MajorCameraCom:SetTargetArmLength(Distance)
		end
	end
end

--- 巴哈烈焰End
function EmotionMgr:OnBaHaFireEnd(EmotionID, EntityID)
	if EmotionID == self.EXD_EMOTE_BAjAFIRE then
		--self:UpdateName(EntityID)
		if MajorUtil.IsMajor(EntityID) then
			self.IsNameOffset = false
		end
		-- if self.TimeHandle ~= nil then  --清除定时器
		-- 	self:UnRegisterTimer(self.TimeHandle)
		-- 	self.TimeHandle = nil
		-- end
		-- local ActorInfoObject = _G.HUDMgr:GetActorInfoObject(EntityID)
		-- if ActorInfoObject then
		-- 	ActorInfoObject:SetOffset(0, 0)
		-- end
	end
end

--- 开始调整玩家名字(方案未启用)
function EmotionMgr:OnNameTask(EntityID)
	if self.TimeHandle ~= nil then  --清除定时器
		self:UnRegisterTimer(self.TimeHandle)
		self.TimeHandle = nil
	end

	local Params = {}
	Params.EntityID = EntityID
	self.TimeHandle = self:RegisterTimer(self.UpdateNameLocation, 0.0, 0.02, -1, Params)
end

--- 实时调整名字位置
function EmotionMgr:UpdateNameLocation(Params)
	local EntityID = (Params.EntityID ~= nil) and Params.EntityID or MajorUtil.GetMajorEntityID()
	local ActorInfoObject = _G.HUDMgr:GetActorInfoObject(EntityID)
	if ActorInfoObject then
		local FromActor = ActorUtil.GetActorByEntityID(EntityID)
		if FromActor == nil then return end
		self.IsNameOffset = true
		local HeadLocation = FromActor:GetSocketLocationByName("head_M")
		local MajorDistance, _ = self:GetDistance(HeadLocation)
		local OffsetFactor = 50
		OffsetFactor = UKismetMathLibrary.MapRangeClamped(MajorDistance, 100, 1600, 100, 50)
		self.NameScreenLocation = _G.UE.FVector2D()
		UIUtil.ProjectWorldLocationToScreen(HeadLocation, self.NameScreenLocation)
		self.NameScreenLocation.Y = self.NameScreenLocation.Y - OffsetFactor
		--上面给气泡用
		--下面给名字用
		local NameOffset = _G.UE.FVector2D()
		UIUtil.ProjectWorldLocationToScreen(HeadLocation, NameOffset)
		local Scale = UIUtil.GetViewportScale()
		NameOffset.Y = NameOffset.Y - UKismetMathLibrary.MapRangeClamped(MajorDistance, 100, 1600, 900*Scale, 0)

		ActorInfoObject:SetOffset(0, NameOffset.Y)
	end
end

--- 播放动作时使名字跟随头顶一起动
function EmotionMgr:UpdateName(EntityID, OffsetY)
	local HUDMgr = _G.HUDMgr
	if OffsetY then
		HUDMgr:SetEidMountPoint(EntityID, "EID_HEAD_TOP")
		HUDMgr:SetOffsetY(EntityID, OffsetY)
		return
	end
	HUDMgr:ResetEidMountPoint(EntityID)
	HUDMgr:SetOffsetY(EntityID, 0)
end

--- 计算屏幕中心到世界某点的距离、视角
function EmotionMgr:GetDistance(Location)
	local WorldPosition = _G.UE.FVector()
	local WorldDirection = _G.UE.FVector()
	local RotationAt = _G.UE.FVector(0)
	local DistanceLocation = 500

	local ViewportSize = UIUtil.GetViewportSize()
	local Scale = UIUtil.GetViewportScale()
	local ViewportX = ViewportSize.X / Scale
	local ViewportY = ViewportSize.Y / Scale	-- 计算屏幕中心点
	local ScreenLocation = _G.UE.FVector2D(ViewportX * 0.5, ViewportY * 0.5);

	UIUtil.DeprojectScreenToWorld(ScreenLocation, WorldPosition, WorldDirection)

	DistanceLocation = UKismetMathLibrary.Vector_Distance(WorldPosition, Location)
	RotationAt = UKismetMathLibrary.FindLookAtRotation(WorldPosition, Location)

	return DistanceLocation, math.abs(RotationAt.Pitch)
end

--- 眨眼和口型开关
function EmotionMgr:UseEyeAndMouth(EmotionID, EntityID)
	local EmotionData = EmotionCfg:FindCfgByKey(EmotionID)
	if not EmotionData then return end
	local IsUseEye = EmotionData.IsUseEye == 1		--注意 1 ：禁眨眼     0 ：可眨眼
	local IsUseMouth = EmotionData.IsUseMouth == 1

	--- 从动画组件禁用眨眼
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp ~= nil then
		if EmotionData.IsUseEye ~= nil then
			AnimComp:SetIsUseEye(IsUseEye)
		end
		if EmotionData.IsUseMouth ~= nil then
			AnimComp:SetIsUseMouth(IsUseMouth)
		end
	end

end

------------↓ 椅子(床)相关  ↓------------
function EmotionMgr:SitChairStat(EntityID)
	local Major = ActorUtil.GetActorByEntityID(EntityID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if PlayerAnimInst then
	--	PlayerAnimInst:DisableMove()
		PlayerAnimInst:UseChair(EntityID)
		EventMgr:SendEvent(EventID.UseWorldViewObj, { IsSitState = true })
		print("EmotionMgr:SitChairStat", EntityID)
	end
end

--- 从椅子上下来
function EmotionMgr:EndUseChair(EntityID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if PlayerAnimInst then
		PlayerAnimInst:EndChair(EntityID)
	--	PlayerAnimInst:EnableMove()
		EventMgr:SendEvent(EventID.UseWorldViewObj, { IsSitState = false })
		print("EmotionMgr:EndUseChair", EntityID)
	end
end

--- 找床
function EmotionMgr:FindBed(EntityID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if PlayerAnimInst then
		local bIsBed = PlayerAnimInst:FindBed(EntityID)
		return bIsBed
	end
end

--- 睡床上
function EmotionMgr:UseBed(EntityID, EmotionID)
	local Major = ActorUtil.GetActorByEntityID(EntityID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if PlayerAnimInst then
		Major:DoClientModeEnter()
		PlayerAnimInst:UseBed(EntityID)
		self:RegisterTimer(function()
			Major:DoClientModeExit()
			print("[EmotionMgr]UseBed:DoClientModeExit")
		end, 0.5, 0, 1)
	end
	if MajorUtil.IsMajor(EntityID) then
		self:SetCameraLookAt(EmotionID, true)
		self:MajorCanUseSkill(false, EntityID, EmotionID)
	end
	self:UpdateName(EntityID, -40)
end

--- 起床
function EmotionMgr:EndBed(EntityID, EmotionID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if not PlayerAnimInst then return end
	PlayerAnimInst.bUseBed = false
	if MajorUtil.IsMajor(EntityID) then
		self:SetCameraLookAt(EmotionID, false)
		self:MajorCanUseSkill(true, EntityID, EmotionID)
	end
end

--- 坐下/睡觉时 禁止释放技能 禁转向
function EmotionMgr:MajorCanUseSkill(bIsUse, EntityID, EmotionID)
	if not MajorUtil.IsMajor(EntityID) then
		return	-- 仅能对自己生效
	end

	--禁转向（这里的禁转向的初衷是为了避免在即将起床时，摇杆导致人物发生转向）
	local StateComponent = ActorUtil.GetActorStateComponent(EntityID)
	if StateComponent ~= nil then
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, bIsUse, "Emotion")
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanUseSkill, bIsUse, "Emotion")
		if EmotionID ~= self.SitChairID and EmotionID ~= self.SitGroundID then
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, bIsUse, "Emotion")
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanAllowMove, bIsUse, "Emotion")
		end
	end

	--禁技能
	_G.SkillLogicMgr:SetSkillButtonEnable(EntityID, SkillBtnState.CanUseSkill, self, function() return bIsUse end)
end

------------↑ 椅子(床)相关 End  ↑------------

function EmotionMgr:OnGameEventSelectTarget(Params)
	local EntityID = Params.ULongParam1
	local IsResumeCamera = Params.BoolParam2

	if _G.InteractiveMgr:IsSpecialSelectInteractiveTarget(EntityID) then
		return
	end

	if not IsResumeCamera then -- 不是相机恢复的点击
		self:ShowMainPanelViewByQuest(Params)  --任务相关
	end
end

function EmotionMgr:OnGameEventUnSelectTarget(Params)
	self:HideMainPanelView(Params)  --任务相关
end

------------↓ 任务相关 ↓------------

--- 添加任务显示图标角标的标识UI
function EmotionMgr:AddQuestID(EmotionID)
	local _, id = table.find_item( EmoActPanelVM.EmotionShowQuestID, EmotionID )
	if id == nil then
		table.insert( EmoActPanelVM.EmotionShowQuestID, 1, EmotionID)
	end
end

--- 获取所在列表
function EmotionMgr:GetEmoActType(EmotionID)
	if nil == EmotionID or EmotionID == {} then
		return
	end

	--列表类型：一般1、持续2、表情3
	local EmotionData = EmotionCfg:FindCfgByKey(EmotionID)
	if EmotionData.MotionType ~= nil then
		local Type = EmotionData.MotionType
		if Type == 1 then
			return 1
		elseif Type == 2 or Type == 3 then
			return 2
		elseif Type == 0 then
			return 3
		end
	end
end

--- 将当前任务动作在列表置中
function EmotionMgr:CenterByIDInList(EmotionTable, QuestEmoID)
	if EmotionTable ~= nil and QuestEmoID ~= nil and #EmotionTable > 13 then
		for i = 12, #EmotionTable do
			local EmoActData = EmotionTable[i]
			if EmoActData.ID ~= nil then
				if EmoActData.ID == QuestEmoID then
					table.remove(EmotionTable, i)
					table.insert( EmotionTable, 1, EmoActData )
				end
			end
		end
	end
	return EmotionTable
end

--- 设置当前任务的动作ID
function EmotionMgr:SetScrollIndexIntoView(QuestEmoID)
	-- for key, value in pairs(EmoActPanelVM.CurEmotionList.Items) do
	-- 	if (value.ID == QuestEmoID) then
			self.TargetQuestEmotionID = QuestEmoID
	-- 		return
	-- 	end
	-- end
end

--- 选中任务NPC或EOBJ时，自动打开ID所在的菜单列表
--- 只有变量Params.ULongParam1会使用到，如果选中的不是NPC，则调用本接口，传入该变量即可
function EmotionMgr:ShowMainPanelViewByQuest(Params)
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1
	local ResID = ActorUtil.GetActorResID(EntityID)
	self.TargetQuestEmotionID = nil

	local IsMajor = MajorUtil.IsMajor(EntityID)	--屏蔽主角选中的是自己

	for _, value in pairs(EmoActPanelVM.QuestList) do
		if (ResID == value.NpcResID or ResID == value.EObjResID) and (value.EmotionID ~= 0) and (not IsMajor) then
			local Major = MajorUtil.GetMajor()
			local Actor = ActorUtil.GetActorByEntityID(EntityID)
			if Major == nil or Actor == nil then return end
			local Distance = (Major:FGetActorLocation() - Actor:FGetActorLocation()):Size()
			local GlobalCfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_COMMON_INTERACTIVE_RANGE)
			local CfgDistance = 600
			if GlobalCfg and GlobalCfg.Value and GlobalCfg.Value[1] > 33 then
				CfgDistance = GlobalCfg.Value[1]
			end
			if Distance > CfgDistance then
				print("EmotionMgr:ShowMainPanelViewByQuest",LSTR(591005))	--"距离太远。"
				return
			end

			self:SetScrollIndexIntoView(value.EmotionID)	--先设置任务动作ID，再走下面逻辑

			--这里模拟一次一级交互的点击
			local EntranceItem = _G.InteractiveMgr:GetEntranceItemByEntityID(EntityID)
			if EntranceItem then
				_G.InteractiveMgr:OnEntranceClick(EntranceItem)
			else
				_G.FLOG_ERROR("EmotionMgr Get EntranceItem is nil, ResID ====="..tostring(ResID))
			end

			local TabType = self:GetEmoActType(value.EmotionID)  --自动打开ID所在的菜单页签列表
			self:ShowEmotionMainPanel({TabType = TabType, QuestEmoID = value.EmotionID })
			self:AddQuestID(value.EmotionID)	 	--存放任务角标

			--新手引导的任务
			if value.QuestID == 160182 then
				local function ShowInteactiveFunc()
					local EventParams = EventMgr:GetEventParams()
					local TutorialDefine = require("Game/Tutorial/TutorialDefine")
					EventParams.Type = TutorialDefine.TutorialConditionType.Interactive
					EventParams.Param1 = TutorialDefine.InteractiveType.NPC or TutorialDefine.InteractiveType.EObj
					EventParams.Param2 = value.NpcResID == ResID and value.NpcResID or value.EObjResID
					_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
				end
				local TutorialConfig = { Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowInteactiveFunc, Params = {} }
				_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
				break
			end
		end
	end
end

--- 选中结束时
function EmotionMgr:HideMainPanelView(Params)
	self.TargetQuestEmotionID = nil
end

--- 任务开始时，会一次性发送所有情感动作任务过来，这里保存到QuestList中
function EmotionMgr:OnGameEventQuestTargetEmotionStart(Params)
	local _, Quest = self:find_item( EmoActPanelVM.QuestList, Params )
	if Quest == nil then
		table.insert( EmoActPanelVM.QuestList, 1, Params )
	end

	-- print(" ===== [情感动作任务] EmotionMgr:", "当前接受的任务是:", table.tostring(Params))
	-- print(" ===== [情感动作任务] EmotionMgr:", "共接受的任务有:", table.tostring(EmoActPanelVM.QuestList))
	-- print(" ===== [情感动作任务] EmotionMgr:", "现有情感动作任务总计:", #EmoActPanelVM.QuestList)
end

--- 任务终结时，清除任务ID
function EmotionMgr:OnGameEventQuestTargetEmotionEnd(Params)
	local i, item1 = self:find_item( EmoActPanelVM.QuestList, Params )
	local len = #EmoActPanelVM.QuestList
	if i ~= nil and i >= 1 and i <= len then
		table.remove(EmoActPanelVM.QuestList, i)  --移除任务
	end

	local E, Key = table.find_item( EmoActPanelVM.EmotionShowQuestID, Params.EmotionID )
	if Key ~= nil then
		for _, value in pairs(EmoActPanelVM.QuestList) do
			if value ~= nil and value.EmotionID ~= nil then
				if value.EmotionID == Params.EmotionID then
					--若还存在相同任务，则不移除
					return
				end
			end
		end
		if i ~= nil and i >= 1 and i <= #EmoActPanelVM.EmotionShowQuestID then
			table.remove( EmoActPanelVM.EmotionShowQuestID, i)  --移除显示图标UI角标
		end
	end

	-- print(" ===== [情感动作任务] EmotionMgr:", "当前结束的任务是:", table.tostring(Params))
	-- print(" ===== [情感动作任务] EmotionMgr:", "还剩余的任务有:", table.tostring(EmoActPanelVM.QuestList))
	-- print(" ===== [情感动作任务] EmotionMgr:", "剩余任务总计:", #EmoActPanelVM.QuestList)
end

-- 定义一个辅助函数，用于比较两个 table 是否相等
function EmotionMgr:deep_compare(t1, t2)
    -- 如果两者类型不同，则不相等
    if type(t1) ~= type(t2) then
        return false
    end

    -- 如果都是表，则递归比较每个键值对
    if type(t1) == "table" then
        for k1, v1 in pairs(t1) do
            local v2 = t2[k1]
            if v2 == nil or not EmotionMgr:deep_compare(v1, v2) then
                return false
            end
        end
        -- 检查 t2 是否有 t1 以外的额外键
        for k2 in pairs(t2) do
            if t1[k2] == nil then
                return false
            end
        end
        return true
    elseif t1 ~= t2 then
        -- 如果都不是表且值不相等，则不相等
        return false
    end

    -- 如果不是表且值相等，则相等
    return true
end

--- 在表1中查找表2
function EmotionMgr:find_item(Table1, Table2)
    for i, item1 in ipairs(Table1) do
        if self:deep_compare(item1, Table2) then
            return i, item1
        end
    end
    return nil, nil
end

------------↑ Quest End 情感动作任务 结束 ↑------------

function EmotionMgr:GetOwnedHead()
	local Item = _G.EquipmentMgr:GetEquipedItemByPart(3)
	local HeadResID = nil ~= Item and Item.ResID or nil
	return _G.EquipmentMgr:IsEquipHasGimmick(HeadResID)
end

--- 平滑转向目标，插值旋转
function EmotionMgr:RInterpToLookAtActor(FromActor, ToActor)
	if FromActor ~= nil and nil ~= ToActor and UKismetMathLibrary ~= nil then
		local TargetLocation = _G.UE.FVector(ToActor:FGetActorLocation().X, ToActor:FGetActorLocation().Y, 0)
		local FromLocation = _G.UE.FVector(FromActor:FGetActorLocation().X, FromActor:FGetActorLocation().Y, 0)
		local Dis = UKismetMathLibrary.Vector_Distance(TargetLocation, FromLocation)
		if Dis <= 20 then
			--距離が近すぎて回転できない
			return
		end
		local TargetRotation = _G.UE.FRotator(0)
		TargetRotation = UKismetMathLibrary.FindLookAtRotation(FromActor:FGetActorLocation(), ToActor:FGetActorLocation())
		TargetRotation.Pitch = 0
		if self.IsInterpRota then
			self.LookAtrTimerNum = 0
			self:ClearLookAtTimer(FromActor)
			FromActor:DoClientModeEnter()
			self.LookAtrTimer = self:RegisterTimer(self.UpdateRotation, 0.0, 0.02, -1, {FromActor=FromActor,TargetRotation=TargetRotation})
		else
			FromActor:FSetRotationForServer(TargetRotation)
		end
	end
end

function EmotionMgr:UpdateRotation(Params)
	if Params and Params.FromActor ~= nil and Params.TargetRotation and UKismetMathLibrary ~= nil then
		local InterpRotation = UKismetMathLibrary.RInterpTo(Params.FromActor:FGetActorRotation(), Params.TargetRotation, 0.02, 10)
		if InterpRotation ~= nil then
			Params.FromActor:FSetRotationForServer(InterpRotation)
		end

		self.LookAtrTimerNum = self.LookAtrTimerNum + 1
		if self.LookAtrTimerNum > 20 then
			self:ClearLookAtTimer(Params.FromActor)
		end
	else
		self:ClearLookAtTimer(Params.FromActor)
	end
end

function EmotionMgr:ClearLookAtTimer(FromActor)
	if self.LookAtrTimer ~= nil then
		self:UnRegisterTimer(self.LookAtrTimer)
		self.LookAtrTimer = nil
		self.LookAtrTimerNum = 0
		if FromActor then
			FromActor:DoClientModeExit()
		end
	end
end

--- 下蹲阈值（走配置表）
function EmotionMgr:GetDown_M()
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
	local AttachType = AvatarComp and AvatarComp:GetAttachType() or "nil"
	local TypeName = string.format("Name = \"%s\"", AttachType)
	local EidCfg = EmotionEidCfg:FindAllCfg(TypeName)
	EidCfg = EidCfg and EidCfg[1] or nil
	return EidCfg and EidCfg.Down_M or 50
end

--- エモート時の高さ合わせアクションタイムラインID取得
function EmotionMgr:GetEmoteAjustTimeline(EntityID, TargetID, IDType, EmotionID)
	local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if PlayerAnimInst == nil then return end
	local Major = ActorUtil.GetActorByEntityID(EntityID)
	local TargetActor = ActorUtil.GetActorByEntityID(TargetID)
	if IDType == EmotionTargetType.EmotionTargetTypeListCompanion then  --若目标是宠物 IDType = 4
		if (TargetActor ~= nil) and (TargetActor:GetCompanionComponent() ~= nil) then
			TargetActor = TargetActor:GetCompanionComponent():GetCompanion()
		end
	end
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	local LookAtTarget = AnimComp and AnimComp:GetLookAtTarget() or nil
	LookAtTarget = LookAtTarget.Target and LookAtTarget.Target or TargetActor
	if LookAtTarget == nil then return end --释放目标为Actor的才释放高度调整
	local Target = LookAtTarget:Cast(_G.UE.ABaseCharacter)
	if Target and Major then
		local TargetPos = _G.UE.FVector(Target:K2_GetActorLocation().X, Target:K2_GetActorLocation().Y, 0)
		local MajorLocation = _G.UE.FVector(Major:K2_GetActorLocation().X, Major:K2_GetActorLocation().Y, 0)
		local Dis = UKismetMathLibrary.Vector_Distance(TargetPos, MajorLocation)
		if Dis <= 200 then  --距離制限
			local TargetEIDTransform = _G.UE.FTransform()
			Target:GetEidTransform("EID_LOOK_AT", TargetEIDTransform)	--身長取得
			local MajorEIDTransform = _G.UE.FTransform()
			Major:GetEidTransform("EID_LOOK_AT", MajorEIDTransform)
			local HeightDistance = MajorEIDTransform:GetLocation().Z - TargetEIDTransform:GetLocation().Z
			if HeightDistance == 0 then return 0 end
			if nil == self.Height then
				self.Height = self:GetHeight()
			end
		--[[
			local height = self.Height
			if height == 0 then return 0 end
			local ct_y = MajorEIDTransform:GetLocation().Z + height
			local tg_y = TargetEIDTransform:GetLocation().Z
			local rate = ( tg_y - ct_y ) / height;
			local EXD_ACTION_TIMELINE_AJUST_EMOTE = _G.UE.EPlayerAnimAdjustType
			if EmotionID == self.EXD_EMOTE_HUG or EmotionID == self.EXD_EMOTE_EMBRACE then	-- ハグ
				if rate < -0.40 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_L end
				if rate < -0.30 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_M end
				if rate < -0.20 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_H end
				if rate > 0.1 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.ADD_TIPTOE end
			end
			if EmotionID == self.EXD_EMOTE_FISTBUMP then   -- 拳を合わせる
				if rate < -0.75 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_L end
				if rate < -0.5 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_M end
				if rate < -0.25 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_H end
			else
				if rate < -0.75 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_L end
				if rate < -0.5 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_M end
				if rate < -0.25 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.DOWN_H end
				if rate > 0.1 then return EXD_ACTION_TIMELINE_AJUST_EMOTE.ADD_TIPTOE end
			end

					上面是端游逻辑 参考：TimelineComponent::GetEmoteAjustTimeline() ;
					下面是自己写的逻辑 ;

			--]]

			if not PlayerAnimInst:Montage_IsPlaying(nil) then
				self.HeightDistance = HeightDistance
			end
			HeightDistance = PlayerAnimInst:Montage_IsPlaying(nil) and self.HeightDistance or HeightDistance
			local Down_M = self:GetDown_M()
			local AnimType = _G.UE.EPlayerAnimAdjustType.TIPTOE			--身高110%以上(仰头)
			if HeightDistance < -100 then
				AnimType = _G.UE.EPlayerAnimAdjustType.ADD_TIPTOE		--身高110%以上(手臂抬起)
			elseif HeightDistance >= -100 and HeightDistance < -50 then
				AnimType = _G.UE.EPlayerAnimAdjustType.ADD_TIPTOE		--身高110%以上(手臂抬起)
			elseif HeightDistance >= -50 and HeightDistance < 0 then
				AnimType = _G.UE.EPlayerAnimAdjustType.SAME_HEIGHT		--身高110%以下(平视)
			elseif HeightDistance == 0 then
				return 0
			elseif HeightDistance > 0 and HeightDistance < Down_M then
				AnimType = _G.UE.EPlayerAnimAdjustType.DOWN_H			--身高75%以下(倾覆身体)
			elseif HeightDistance >= Down_M and HeightDistance < 100 then
				AnimType = _G.UE.EPlayerAnimAdjustType.DOWN_M			--身高50%以下(下蹲)
			elseif HeightDistance >= 100 then
				AnimType = _G.UE.EPlayerAnimAdjustType.DOWN_L			--身高25%以下(倾覆身体并下蹲)
			end
			return AnimType
		end
	end
end

function EmotionMgr:IsValidVelocity(EntityID, EmotionID)
	local Actor = EntityID and ActorUtil.GetActorByEntityID(EntityID) or MajorUtil.GetMajor()
	if Actor and Actor.CharacterMovement then
		local Velocity = Actor.CharacterMovement.Velocity
		if Velocity:Size() > self.INF then
			if nil ~= EmotionID and EmotionID ~= 0 then
				local EmotionData = EmotionCfg:FindCfgByKey(EmotionID)
				if (EmotionData or {}).MotionType ~= 0 then		--移动中可以使用表情0
					if EmotionID ~= self.EXD_EMOTE_WAKE then	--起床动作
						return true
					end
				end
			end
		end
	end
	return false
end

--- 协议安全
---@param SendID 		向服务器发送的情感动作ID
---@param IsSendReq   	判断是否为主角客户端向服务器发送请求
---@param MsgBody		服务器回包
---@param EntityID		主角实例ID
---@return boolean
function EmotionMgr:IsNetMsgBody(SendID, IsSendReq, MsgBody, EntityID)
	if not self:CheckMajorState() then
		print("检测到主角在某个通用行为状态下，不能播放情感动作")
		return false
	end
	if self:IsValidVelocity(EntityID, SendID) then
		local ActorManager = _G.UE.UActorManager:Get()
		if ActorManager and ActorManager:GetVirtualJoystickIsSprintLocked() then
			ActorManager:SetVirtualJoystickIsSprintLocked(false)    --关闭自动锁定移动
		else
			MsgTipsUtil.ShowTips(LSTR(210026))  --"移动中无法操作"
			return false
		end
	end

	local StateCom = MajorUtil.GetMajorStateComponent()
	if StateCom and StateCom:IsUsingSkill() then
		--MsgTipsUtil.ShowTips(LSTR(210027))    --"技能中无法操作!"
		return false
	end

	if _G.SingBarMgr:GetMajorIsSinging() then
		MsgTipsUtil.ShowTips(LSTR(210028))  --"读条中无法操作!"
		return false
	end

	if _G.MountMgr:IsRequestingMount() then
		MsgTipsUtil.ShowTips(LSTR(210028))  --"召唤坐骑中无法操作!"
		return false
	end

	if PWorldMgr and PWorldMgr:GetCrystalPortalMgr():GetIsTransferring() then
		MsgTipsUtil.ShowTips(LSTR(210029))  --"传送中无法操作!"
		return false
	end

	if BuffUtil.IsMajorBuffExist(7621) or BuffUtil.IsMajorBuffExist(48042) then	--狂欢
		local bIsUseSkill = ActorUtil.IsCanUseSkill(MajorUtil.GetMajorEntityID())
		if not bIsUseSkill then
			print("处于狂欢buff中,无法播放情感动作 ")
			return false
		end
	end

	local IsVertigo = ActorUtil.IsInComBatState(MajorUtil.GetMajorEntityID(), ProtoCommon.CombatStatID.COMBAT_STAT_VERTIGO)
	if IsVertigo then
		MsgTipsUtil.ShowTips(LSTR(" 检测到当前不能使用技能,可能处于眩晕等buff中,无法播放情感动作 "))
		print(" 检测到当前不能使用技能,可能处于眩晕等buff中,无法播放情感动作 ")
		return false
	end

	if IsSendReq == true then	--在主角发包前
		if not self:IsActivatedID(SendID) then
			if SendID == nil then
				print(" 尝试调用无效的情感动作ID ")
				return false
			end
			local EmotionData = EmotionCfg:FindCfgByKey(SendID)
			if nil == EmotionData then
				print(string.format( "检测到ID为 %d 的情感动作不存在 !", SendID) )
				return false
			end
			print(string.format("情感动作“ %s ”未解锁 !", EmotionData.EmotionName))
			return false
		end
	end

	if not IsSendReq then 		--在主角回包后
		if nil == MsgBody or nil == EntityID then
			return false
		end

		local EmotionID = (MsgBody.EmotionID ~= 0) and MsgBody.EmotionID or MsgBody.StatEmotion
		local EmotionData = EmotionCfg:FindCfgByKey(EmotionID)
		if nil == EmotionData then
			return false
		end

		if not self:IsActivatedID(EmotionID) then	--此判断只为主角服务
			-- local Text = string.format(LSTR(210030), EmotionData.EmotionName)	--"检测到情感动作“ %s ” 未激活 !"
			-- MsgTipsUtil.ShowTips(Text)
			return false
		end

		-- 验证附近是否有椅子（坐椅子上ID = 50）
		if EmotionID == self.SitChairID and self.IsFindChair == true then
			local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
			if PlayerAnimInst then
				local IsChair = PlayerAnimInst:FindChair(EntityID)
				if IsChair == false then
					return false
				end
			end
		end
		-- 验证附近是否有床（睡觉ID = 88）
		if self:IsBedEmotion(EmotionID) then
			local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
			if PlayerAnimInst then
				local IsBed = PlayerAnimInst:FindBed(EntityID)
				if IsBed == false then
					return false
				end
			end
		end
	end

	return true
end

--- 登录游戏后，继续显示未读红点
function EmotionMgr:InitRedDot()
	local StringID = USaveMgr.GetString(SaveKey.RedDotEmotions, "", true)
	local IDList = string.split(StringID, ",")
    for _, v in ipairs(IDList) do
        self:AddRedDot(tonumber(v))
    end
end

--- 显示红点，以动作ID作为最终子节点
function EmotionMgr:AddRedDot(ID)
	if not self:IsActivatedID(ID) then	--接入红点前拦截未激活的ID
		return
	end

	--接入红点
	local EmotionCfg = EmotionCfg:FindCfgByKey(ID)
	if EmotionCfg == nil or nil == EmotionCfg.MotionType then return end
	local TabName = EmotionDefines.MotionTypeKeyRedDots[EmotionCfg.MotionType]
	if string.isnilorempty(TabName) then return end
	local RedDotName = string.format( "%s/%s", TabName, EmotionCfg.ID)
	RedDotMgr:AddRedDotByName(RedDotName, nil, true)

	--保存未读红点，用于下次登录游戏时显示未读红点
	local StringID = USaveMgr.GetString(SaveKey.RedDotEmotions, "", true)
	local IDList = string.split(StringID, ",")  	--按逗号拆分
	local _, id = table.find_item(IDList, tostring(ID))
	if id == nil then
		table.insert(IDList, 1, tostring(ID))
		IDList = table.concat(IDList, ',')  	--按逗号链接
		USaveMgr.SetString(SaveKey.RedDotEmotions, IDList, true)
	end
end

--- 删除红点，以动作ID作为最终子节点
function EmotionMgr:DelRedDot(ID)
	local StringID = USaveMgr.GetString(SaveKey.RedDotEmotions, "", true)
	local IDList = string.split(StringID, ",")
	local _, id = table.find_item(IDList, tostring(ID))
	if id ~= nil then
		--删除已读红点
		table.remove(IDList, id)
		IDList = table.concat(IDList, ',')
		USaveMgr.SetString(SaveKey.RedDotEmotions, IDList, true)

		--隐藏红点
		local EmotionCfg = EmotionCfg:FindCfgByKey(ID)
		if EmotionCfg == nil or nil == EmotionCfg.MotionType then return end
		local TabName = EmotionDefines.MotionTypeKeyRedDots[EmotionCfg.MotionType]
		if string.isnilorempty(TabName) then return end
		local RedDotName = string.format( "%s/%s", TabName, EmotionCfg.ID)
		RedDotMgr:DelRedDotByName(RedDotName)
	end
end

--- 从其他动作切换到改变姿势Idle时 (UI业务)
function EmotionMgr:FaceToChangePose(EmotionID)
	if EmoActPanelVM.SelectList == {} then return end
	local Keys = {}
	for k, v in pairs(EmoActPanelVM.SelectList) do
		table.insert(Keys, k)
	end
	table.sort(Keys)	--按时间顺序
	local MaxKey = Keys[#Keys]
	for k, v in pairs(EmoActPanelVM.SelectList) do
		if k < MaxKey then
			if v and v.ID ~= EmotionID then
				if CommonUtil.IsObjectValid(v.ItemView) then
					v.ItemView:SetSelectVisibity(false)
				end
			end
			EmoActPanelVM.SelectList[k] = nil	--清除旧时间
		end
	end
end

--- 点击不能使用的动作时 弹当前状态不能使用的提示
function EmotionMgr:ShowCannotUseTips(ID)
	local EmoCfg = EmotionCfg:FindCfgByKey(ID)
	if EmoCfg and EmoCfg.IsBattleEmotion == 1 then
		-- 生产职业不能使用战斗情感动作
		local EntityID = MajorUtil.GetMajorEntityID()
		local ProfID = ActorUtil.GetActorAttributeComponent(EntityID).ProfID
		local Specialization = RoleInitCfg:FindProfSpecialization(ProfID)
		if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCombatUse)
			return
		end
	end

	if self:IsEquipEmotion(ID) then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUseT)
		return
	end

	if self.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_GROUND then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUseG)
		return
	end

	if self.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_CHAIR then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUseC)
		return
	end

	local Major = MajorUtil.GetMajor()
	if Major == nil then return end
	if Major:GetRideComponent() ~= nil then
		if Major:GetRideComponent():IsInRide() then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUseR)
			return
		end
	end

	if Major:IsSwimming() then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUseS)
		return
	end

	print("【情感动作】当前状态无法使用", 
	"动作ID:",ID, 
	"列表数量：", #EmoActPanelVM.CanUseList, 
	"此动作是否有效：",EmoActPanelVM.CanUseList[ID], 
	"CanUse配置",EmoCfg.CanUse[self.MajorCanUseType], 
	"主角状态",self.MajorCanUseType,
	self.CannotText[ID])

	MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUse)
end

--- 准备跳起时 若主角正在坐下状态 则先退出坐下状态 随后直接跳起
function EmotionMgr:ExitSitToJump(EntityID)
	if EntityID == nil then
		EntityID = MajorUtil.GetMajorEntityID()
	end
	local bIsSit, EmotionID = self:IsSitState(EntityID)
	if bIsSit then	--是坐椅子上
		local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
			local AnimInst = AnimComp and AnimComp:GetPlayerAnimInstance() or nil
			if AnimInst == nil then return end
		if EmotionID == self.SitChairID then
			-- AnimInst.bSitToJump = true	--(暂关闭插值调整功能)
		end
		self:StopAllEmotionsNotHoldWeapon(EntityID, false, EmotionDefines.CancelReason.MOVE)
		local PlayerAnimParam = AnimInst:GetPlayerAnimParam()
		PlayerAnimParam.bIgnoreExitSit = true
		AnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
		-- self:SetMeshLocation(EntityID)	--(暂关闭插值调整功能)
	end
end

--- 若直接从坐跳跃到空中，需要在恰当时机恢复Mesh的位置，这里采用插值调整
function EmotionMgr:SetMeshLocation(EntityID)
	if self.SitToJumpTimer ~= nil then  --清除定时器
		self:UnRegisterTimer(self.SitToJumpTimer)
		self.SitToJumpTimer = nil
	end
	self.SitToJumpTimerNum = 0
	local NewMeshLoc = _G.UE.FVector(0, 0, -78)
	self.SitToJumpTimer = self:RegisterTimer(self.UpdateMeshLocation, 0.5, 0.02, -1, {EntityID = EntityID, NewLoc = NewMeshLoc})
end

function EmotionMgr:UpdateMeshLocation(Params)
	self.SitToJumpTimerNum = self.SitToJumpTimerNum + 1
	if self.SitToJumpTimerNum > 15 then
		if self.SitToJumpTimer ~= nil then  --清除定时器
			self:UnRegisterTimer(self.SitToJumpTimer)
			self.SitToJumpTimer = nil
		end
		return
	end
	local Actor = ActorUtil.GetActorByEntityID(Params.EntityID)
	local Mesh = Actor and Actor.Mesh or nil
	local OldMeshLoc = Mesh and Mesh:GetRelativeLocation() or nil
	if nil ~= OldMeshLoc then
		local InterpLoc = UKismetMathLibrary.VInterpTo(OldMeshLoc, Params.NewLoc, 0.02, 7)
		Mesh:K2_SetRelativeLocation(InterpLoc, false, nil, false)
	end
end

--- 接入快捷使用弹窗，判断此演技教材是否已解锁过对应动作ID
function EmotionMgr:RegisterCheckItemUsedFun()
	local function CheckItemUsed(ItemResID)
		local ECfg = EmotionCfg:FindCfg(string.format("Item = %d", ItemResID))
		if ECfg == nil then 
			return false 
		end
		return self:IsActivatedID(ECfg.ID)
	end
	_G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ACTINGBOOK, CheckItemUsed)
end

--------  自动切换姿势(Idle、Weapon) ↓ --------
--- 自动切换拔刀Pose姿势（由设置中的相关选项值更新时触发）
function EmotionMgr:SetAutoFoldWeapon()
    if self.WTimeHandle ~= nil then
        self:UnRegisterTimer(self.WTimeHandle)
        self.WTimeHandle = nil
    end
    self.WTimeHandle = self:RegisterTimer(function()
        self:AutoFoldWeapon()
    end, 0.2)
end

--- 自动切换站立Pose姿势（由设置中的相关选项值更新时触发）
function EmotionMgr:SetOpenAutoPose()
    if self.PTimeHandle ~= nil then
        self:UnRegisterTimer(self.PTimeHandle)
        self.PTimeHandle = nil
    end
    self.PTimeHandle = self:RegisterTimer(function()
		self:SetAutoPoseChange()
    end, 0.2)
end

--同步新设置的自动收回武器开关、时间
function EmotionMgr:AutoFoldWeapon()
	local Params = {}
	Params.IntParam1 = ClientSetupKey.CSKAutoFoldWeapon
	Params.StringParam1 = self.AutoDropWeapon .. string.format(",%.1f",self.HideWeaponTime)
	EventMgr:SendEvent(EventID.ClientSetupSet, Params)   
end

function EmotionMgr:UpdateIdleAnimParams()
	local Params = {}
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	Params.StringParam1 = EmotionAnimUtils.GetIdleCSValue(MajorEntityID)
	Params.IntParam1 = ClientSetupKey.CSKIdleAnims
	EventMgr:SendEvent(EventID.ClientSetupSet, Params)
end

function EmotionMgr:SetAutoPoseChange()
	self:ClearPoseTimerHandle()
    if self.AutoResetPose then
        self.PoseTimerHandle = self:RegisterTimer(self.AutoPoseOn, 0, 2, 0)
        self.PoseStartTime = TimeUtil.GetLocalTimeMS()
    end
end

function EmotionMgr:ClearPoseTimerHandle()
    if self.PoseTimerHandle then
        self:UnRegisterTimer(self.PoseTimerHandle)
        self.PoseTimerHandle = nil
    end
end

function EmotionMgr:AutoPoseOn()
    local CurTime =  TimeUtil.GetLocalTimeMS()
    local DeltaTime = CurTime - self.PoseStartTime

    if DeltaTime >= self.ResetToIdleTime * 1000 then
        self:DoChangeIdleAnim()
    end
end

function EmotionMgr:DoChangeIdleAnim()
	local Major = MajorUtil.GetMajor()
	if not Major then return end
	if not self:CheckMajorState() then
		return
	end
	if not self:IsValidState() then
		return
	end
    if Major:IsHoldWeapon() then
		self:ClearPoseTimerHandle()
        return  --战斗放松姿势只切一次
	end
    self.PoseStartTime = TimeUtil.GetLocalTimeMS()
    local AnimCom = MajorUtil.GetMajorAnimationComponent()
    if AnimCom and AnimCom.IsInEmote == false then
		--若在播放情感动作，则不自动切换姿势
        self:ReqChangeIdleAnim()
    end
end

function EmotionMgr:CheckIsInEmote(EntityID)
	local AnimCom = ActorUtil.GetActorAnimationComponent(EntityID)
    if AnimCom then
		return AnimCom.IsInEmote
	end
	return false
end

--进出待机状态的事件通知
function EmotionMgr:OnPlayerEnterIdleState(Params)
    if Params then
        local bEnter = Params.BoolParam1
        local EntityID = Params.ULongParam1

        if not MajorUtil.IsMajor(EntityID) then
            return
        end
        if not bEnter then
            return
        end
        self:ClearPoseTimerHandle()
        if self.AutoResetPose then
            self.PoseTimerHandle = self:RegisterTimer(self.AutoPoseOn, 0, 2, 0)
            self.PoseStartTime = TimeUtil.GetLocalTimeMS()
        end
    end
end

function EmotionMgr:IsValidState()
	if MajorUtil.GetMajorCurHp() <= 0 then
		return
    end
	if MajorUtil.IsMajorCombat() then
        return
    end
	local Major = MajorUtil.GetMajor()
	if not Major then
		return
	end
	if Major:GetIsSequenceing() then
        return	--过场动画
    end
	if Major:GetRideComponent():IsInRide() then
		return
	end
	if Major:IsInFly() then
		return
	end
	local Velocity = Major.CharacterMovement.Velocity
	if Velocity:Size() > 0.01 then
		return
	end
	if PWorldMgr:GetCrystalPortalMgr():GetIsTransferring() then
		return	--传送中
	end
	if _G.FishMgr:IsInFishState() then
        return
    end
	if _G.SingBarMgr:GetMajorIsSinging() then
		return	--读条中
	end
	if _G.NpcDialogMgr:IsDialogPlaying() then
		return	--对话中
	end
	if _G.GatherMgr:IsGatherState() then
		return	--采集中
	end
	if _G.CrafterMgr:GetIsMaking() then
		return	--制作中
	end
	if _G.GoldSaucerMiniGameMgr:CheckIsInMiniGame() then
		return
	end
	return true
end
--------  自动切换姿势(Idle、Weapon) ↑ --------

-- 只在主角变身时，判断情感动作可用性
function EmotionMgr:OnGameEventChangeRole(Params)
	if not Params then return end
	local EntityID = Params.ULongParam1
	local ChangeRoleID = Params.IntParam1
	if not MajorUtil.IsMajor(EntityID) then
		return
	end
	self.bIsActiveChangeRole = 0 ~= ChangeRoleID and true or nil	--是否开启了变身
	self.bBecomeHuman = nil
	if self.bIsActiveChangeRole then
		local Data = ChangeRoleCfg:FindCfgByKey(ChangeRoleID)
		if nil ~= Data then
			if 1 == Data.Emote then
				self.bBecomeHuman = true	--开启变身后 是否变成人型
			end
		end
	end
	self:SendStopEmotionAll()
	self:StopAllEmotions(Params.ULongParam1, false, EmotionDefines.CancelReason.ChangeRole)
	self:ReqRefreshUI()
end

-- 在进入决斗时，停止情感动作
function EmotionMgr:OnGameEventPVPDuelAccept(Params)
	if not Params then return end
	local RoleID = Params.InviterID
	local TgtRoleID = Params.TargetID
	local MajorEntityID = ActorUtil.GetActorEntityIDByResID(RoleID)
	if not MajorEntityID then
		MajorEntityID = MajorUtil.GetMajorEntityID()
	end
	if self.Tasks[MajorEntityID] then
		self:SendStopEmotionAll()
	end
	local TgtEntityID = ActorUtil.GetActorEntityIDByResID(TgtRoleID)
	self:StopAllEmotions(TgtEntityID, true, EmotionDefines.CancelReason.SKILL)
end

function EmotionMgr:OnGameEventMajorEntityIDUpdate(Params)
	local NowID = Params.ULongParam1
	local OldID = Params.ULongParam2
	local MajorTasks = self.Tasks[OldID]
	if MajorTasks then
		-- 重新更新主角EntityID，这种情况应该出现在断线过久后重连
		for _, Task in pairs(MajorTasks) do
			Task.FromID = NowID
		end
		self.Tasks[OldID] = nil
		self.Tasks[NowID] = MajorTasks
	end
end

-- 开关头盔 头部装备动作 适配ID = { 60, 61 }
function EmotionMgr:PlayHelmetGimmick(EmotionID, EntityID)
	if MajorUtil.IsMajor(EntityID) then
		if self:IsEquipEmotion(EmotionID) then
			if SettingsTabRole:GetHelmetGimmickOn() == 1 then
				SettingsTabRole:SetHelmetGimmickOn(2, true)
			else
				SettingsTabRole:SetHelmetGimmickOn(1, true)
			end
		end
	end
end

-- 从坐在椅子上突变为上坐骑
function EmotionMgr:StopAllEmotionsByMount(EntityID)
	local IsSit, ID = self:IsSitState(EntityID)
	if IsSit then
		print("[Emotion]Stop All Emotions from Mount", IsSit, ID)
	end

	self:StopAllEmotions(EntityID, false, EmotionDefines.CancelReason.MOVE)
end

function EmotionMgr:SetFaceAnimIgnoreRest(EntityID, IsEmoFaceAnimPlaying)
	local PlayerAnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(EntityID)
	if PlayerAnimInst == nil or PlayerAnimParam == nil then
		return
	end
	if nil ~= IsEmoFaceAnimPlaying then
		PlayerAnimInst.IsEmoFaceAnimPlaying = IsEmoFaceAnimPlaying
	else
		local IsFace = self:IsFacePlaying(EntityID)
		PlayerAnimInst.IsEmoFaceAnimPlaying = IsFace == true	--强制为bool值
	end
end

function EmotionMgr:MountCustomEmoteNotify(EntityID, EmotionID, Target)
	if EmotionID ~= 0 and Target and Target.IDType then
		if Target.IDType == EmotionTargetType.EmotionTargetTypeMountFacade then
			-- 坐骑外观
			local EntityActor = ActorUtil.GetActorByEntityID(EntityID)
			if Target.ID and EntityActor then
				local MountResID = 1001
				local CustomMadeID = 1
				if Target.ID == 0 then
					CustomMadeID = 1
				else
					CustomMadeID = Target.ID
				end
				MountMgr:SetCustomMadeID(EntityActor, MountResID, CustomMadeID)
			end
		end
	end
end

-----------------------------------------------------------------------------
------------------------  下面放的是对外接口  ---------------------------------

--- 打开情感动作界面
---@param Params 		  	默认传nil
---@param Params.TabType  	可切换页签:收藏0、一般1、持续2、表情3
---@param Params.EntityID 	可选中释放目标
---@param Params.EmoActID 	可跳转到情感动作ID
---@param Params.QuestEmoID	跳转到任务动作
function EmotionMgr:ShowEmotionMainPanel(Params)
	-- CommSideBarUtil.ClearCurEasyUseLastType()
	self:ShowEasyMainPanel(Params)
end

function EmotionMgr:ShowEasyMainPanel(Params)
	if UIViewMgr:IsViewVisible(UIViewID.CommEasytoUseView) then
		UIViewMgr:HideView(UIViewID.CommEasytoUseView)
		return
	end
	CommSideBarUtil.ShowSideBarByType(CommonSelectSidebarDefine.PanelType.EasyToUse, CommonSelectSidebarDefine.EasyToUseTabType.Emoji, Params)
end

---@param ID 		    Q情感动作表ID
---@param NeedShowHUD   是否显示头顶泡泡
---@param bSendChat     是否向附近频道发送消息
function EmotionMgr:PlayEmotionID(ID, NeedShowHUD, EntityID, bSendChat)
	local Path = EmotionAnimUtils.GetEmotionAtlPath(ID)
	if string.isnilorempty(Path) then return end
	local Params = {
		BoolParam3 = NeedShowHUD == true,
		ULongParam2 = 0,
		IntParam1 = ID,
		IDType = 0,
		ULongParam1 = EntityID or MajorUtil.GetMajorEntityID(),
		BoolParam1 = false,
		bSendChat = bSendChat == true,
	}
	self:OnPlayEmotion(Params)
end

--- 传入ID, EntityID  直接播放情感动作
---@param ID 		    情感动作ID
---@param EntityID 		EntityID也支持NPC播放
---@param NeedShowHUD   是否显示头顶泡泡
---@param bSendChat 	是否向附近频道发送消息
function EmotionMgr:PlayEmotionIDFromEntityID(ID, EntityID, NeedShowHUD, bSendChat)
	if EntityID == nil or EntityID == 0 then
		EntityID = MajorUtil.GetMajorEntityID()
	end
	self:PlayHelmetGimmick(ID, EntityID)
	local NpcActor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == NpcActor then return end
	local AnimComp = NpcActor:GetAnimationComponent()
	if nil == AnimComp then return end
	local Path = EmotionAnimUtils.GetEmotionAtlPath(ID)
	if string.isnilorempty(Path) then return end

	local Params = {
		BoolParam3 = NeedShowHUD == true,
		ULongParam2 = 0,
		IntParam1 = ID,
		IDType = 0,
		ULongParam1 = EntityID,
		BoolParam1 = false,
		bSendChat = bSendChat == true,
	}
	local EmotionTask = self:OnPlayEmotion(Params)
	return EmotionTask
end

---播放情感动作表中配置的动作（拍照）
function EmotionMgr:PhotoPlayEmotion(ID, EntityID)
	local EmotionTask = self:PlayEmotionIDFromEntityID(ID, EntityID, false, false)
	if EmotionTask and EmotionTask.MontageToPlay then
		return EmotionTask.MontageToPlay
	end
end

---@param ID 		    情感动作表ID
---@param AnimPathType 	字符串类型,可填nil（AnimPath、BeginAnimPath、、）
---@param AnimComp 		动画组件
function EmotionMgr:AnimCompPlayEmotion(ID, AnimPathType, AnimComp)
	local Path = EmotionAnimUtils.GetEmotionAtlPath(ID, AnimPathType)
	if string.isnilorempty(Path) then return end
	if nil == AnimComp then
		AnimComp = MajorUtil.GetMajorAnimationComponent()
	end
	AnimComp:PlayAnimation(Path)
end

--[[ 传入路径, 直接播放所有动作
例如：
Lua _G.EmotionMgr:PlayEmotionPath("AnimSequence'/Game/Assets/Character/Human/Animation/c0101/a0001/mt_m90007/A_c0101a0001_emot-cbem_zsmdhb.A_c0101a0001_emot-cbem_zsmdhb'")
Lua _G.EmotionMgr:PlayEmotionPath("AnimSequence'/Game/Assets/Character/Monster/m90007/Animation/a0001/mount/A_m90007a0001_emot-cbem_zsmdhb.A_m90007a0001_emot-cbem_zsmdhb'")
]]
function EmotionMgr:PlayEmotionPath(Path)
	if nil == MajorUtil then return end
	local AnimComp = MajorUtil.GetMajor():GetAnimationComponent()
	if nil == AnimComp then return end
	if string.isnilorempty(Path) then return end
	AnimComp:PlayAnimation(Path)
end

function EmotionMgr:SetNewTargetEntityID(EntityID)
	self.NewTargetEntityID = EntityID
end

function EmotionMgr:GetCurState(EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if not Actor then return end
	local _, SitEmotionID = self:IsSitState(EntityID)
	local bIsRiding =  Actor:GetRideComponent() and Actor:GetRideComponent():IsInRide() or false
	local bIsSwimming = Actor:IsSwimming()
	if SitEmotionID == self.SitGroundID then			--座り中は補正しない
		return EmotionDefines.StateDefine.SIT_GROUND
	elseif SitEmotionID == self.SitChairID then
		return EmotionDefines.StateDefine.SIT_CHAIR		--潜水は補正しない(暂无)
	elseif bIsRiding or bIsSwimming then				--マウント中は補正しない
		return EmotionDefines.StateDefine.UPPER_BODY	--泳ぎは補正しない
	end
	return EmotionDefines.StateDefine.NORMAL
end

--- 检测当前状态情感动作可用性（对外接口）
---@param EmotionID 	情感动作ID
---@param EntityID 		玩家EntityID
---@param IgnoreActi	允许未解锁ID
function EmotionMgr:IsEnableID(EmotionID, EntityID, IgnoreActi)
	EntityID = EntityID or MajorUtil.GetMajorEntityID()
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if not Actor then return end
	local StateCom = ActorUtil.GetActorStateComponent(EntityID)
	if StateCom == nil then return end
	local RideCom = Actor:GetRideComponent()
	if RideCom == nil then return end
	local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if AttributeComp == nil then return end
	local EmotionCfg = EmotionCfg:FindCfgByKey(EmotionID)
	if not EmotionCfg then
		self.CannotText[EmotionID] = EmotionDefines.ELog[9]
		return false
	end
	if true ~= IgnoreActi then
		if not self:IsActivatedID(EmotionID) then
			self.CannotText[EmotionID] = EmotionDefines.ELog[10]
			return false
		end
	end

	local RideID = RideCom:GetRideResID()
	local bIsRiding = RideCom:IsInRide()			--坐骑中
	local bIsSwimming = Actor:IsSwimming()			--游泳中
	local bIsFish = _G.FishMgr:IsInFishState()		--钓鱼中
	local bSkill = StateCom:IsUsingSkill()			--技能中
	local bIsStorage = _G.SkillStorageMgr:IsStorage(EntityID)	--蓄力中
	local bIsDead = StateCom:IsDeadState()			--死亡中
	local bIsChange = self.bIsActiveChangeRole and not self.bBecomeHuman or false	--变人
	local bSpecialState = bSkill or bIsStorage or bIsDead or bIsChange	--特殊状态，所有动作都不可用
	local bIsEnable = true

	if bSpecialState then
		bIsEnable = false
		self.CannotText[EmotionID] = string.format("%s %s %s %s %s",EmotionDefines.ELog[0],
		tostring(bSkill),tostring(bIsStorage),tostring(bIsDead),tostring(bIsChange))
	elseif not self:CanUseRideStart(bIsRiding, EmotionCfg, RideID) then   --坐骑状态
		self.CannotText[EmotionID] = MsgTipsID.EmitionCannotUseR
		bIsEnable = false
	elseif not self:CanUseSwimming(bIsSwimming, EmotionCfg) then	 --游泳状态
		self.CannotText[EmotionID] = MsgTipsID.EmitionCannotUseS
		bIsEnable = false
	elseif not self:CanUseFish(bIsFish, EmotionCfg) then		 --钓鱼状态
		self.CannotText[EmotionID] = EmotionDefines.ELog[3]
		bIsEnable = false
	elseif EmotionCfg.IsBattleEmotion == 1 or self.IsHoldWeaponID(EmotionID) then  --生产职业不能使用战斗情感动作或收拔刀动作
		local ProfID = AttributeComp.ProfID
		local Specialization = RoleInitCfg:FindProfSpecialization(ProfID)
		local CanUse = nil
		if EmotionMgr.IsHoldWeaponID(EmotionID) then
			CanUse = true
		elseif EmotionCfg.CanUse then
			CanUse = EmotionCfg.CanUse[self.MajorCanUseType] == 1
		end
		bIsEnable = Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT and CanUse
		if bIsEnable == false then
			self.CannotText[EmotionID] = MsgTipsID.EmitionCombatUse
		end
	elseif EmotionCfg.MotionType == 3 then  	--持续动作
		bIsEnable = true
	elseif self:IsChangePoseEmotion(EmotionID) then  	--是否ID=90(改变姿势)
		bIsEnable = true
	elseif self:IsEmotionPlaying(EntityID, self.SitChairID) then
		if EmotionCfg.CanUse and EmotionCfg.CanUse[3] == 0 then     --坐在椅子上
			self.CannotText[EmotionID] = MsgTipsID.EmitionCannotUseC
			bIsEnable = false
		end
	elseif self:IsEmotionPlaying(EntityID, self.SitGroundID) then
		if EmotionCfg.CanUse and EmotionCfg.CanUse[2] == 0 then     --坐在地面上
			self.CannotText[EmotionID] = MsgTipsID.EmitionCannotUseG
			bIsEnable = false
		end
	-- elseif EmotionCfg.CanUse and EmotionCfg.CanUse[self.MajorCanUseType] == 0 then
	-- 	self.CannotText[EmotionID] = EmotionDefines.ELog[8]		--注意self.MajorCanUseType是给主角用的
	-- 	bIsEnable = false
	elseif self:IsEquipEmotion(EmotionID) and self:GetOwnedHead() then   --头部装备始终可用
		bIsEnable = true
	elseif string.isnilorempty(EmotionCfg.AnimPath) and string.isnilorempty(EmotionCfg.BeginAnimPath)
		and string.isnilorempty(EmotionCfg.OnGroundAnimPath) and string.isnilorempty(EmotionCfg.OnChairAnimPath)
		and string.isnilorempty(EmotionCfg.UpperBodyAnimPath) and string.isnilorempty(EmotionCfg.AdjustAnimPath) then
		self.CannotText[EmotionID] = EmotionDefines.ELog[7]
		bIsEnable = false	--最后再检查情感动作表是否填写有动作路径
	end
	return bIsEnable
end

--- 在坐骑状态时，判断能否使用情感动作（对外接口）
function EmotionMgr:CanUseRideStart(bIsRiding, EmotionData, RideID)
	if EmotionData and bIsRiding == true then
		--判断此情感动作是否在坐骑时可用（对应Q情感动作表的CanUse[3]列）
		if EmotionData.CanUse[4] == 0 then
			return false
		end

		local RideData = RideCfg:FindCfgByKey(RideID)
		if RideData then
			--根据Z坐骑表的IsEmote列，判断该坐骑上是否可以使用情感动作
			if RideData.IsEmote == false or RideData.IsEmote == 0 then
				return false
			end
		end
	end
	return true
end

--- 在游泳状态时，判断能否使用情感动作（对外接口）
function EmotionMgr:CanUseSwimming(bIsSwimming, EmotionData)
	if EmotionData and bIsSwimming == true then
		if EmotionData.MotionType == 3 or 
			self:IsChangePoseEmotion(EmotionData.ID) or 
			EmotionData.CanUse[6] == 0 then
			return false
		end
	end
	return true
end

--- 在钓鱼状态时，判断能否使用情感动作（对外接口）
function EmotionMgr:CanUseFish(bIsFish, EmotionData)
	if EmotionData and bIsFish == true then
		if EmotionData.CanUse[5] == 0 then
			return false
		end
	end
	return true
end

--- 检测主角在某个通用行为状态下，能否播放情感动作
function EmotionMgr:CheckMajorState()
	return CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_ENTER_EMOTION, false)
end

--- 查询物品ID是否已解锁（对外接口）
function EmotionMgr:IsActivatedByItemID(ItemID)
	local Data = EmotionCfg:FindAllCfg(string.format("Item == %d", ItemID))
	if nil == Data then
		return false
	end
	return Data[1] and Data[1].ID and self:IsActivatedID(Data[1].ID)
end

--- 检测当前状态情感动作可用性（巡回乐团接口）
function EmotionMgr:IsEnableAtIgnoreActivatedID(EmotionID, IgnoreActi)
	local EntityID = MajorUtil.GetMajorEntityID()
	return self:IsEnableID(EmotionID, EntityID, IgnoreActi)
end

return EmotionMgr