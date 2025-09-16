--[[
Date: 2021-12-01
LastEditors: moody
LastEditTime: 2021-12-01 
--]]

local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local EmotionCfg = require("TableCfg/EmotionCfg")
local ObjectGCType = require("Define/ObjectGCType")
local EventID = require("Define/EventID")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local AnimationUtil = require("Utils/AnimationUtil")
local AnimMgr = require("Game/Anim/AnimMgr")
local CommonDefine = require("Define/CommonDefine")
local ProtoCS = require ("Protocol/ProtoCS")
local EmotionTargetType = ProtoCS.EmotionTargetType
local EObjectGC = _G.UE.EObjectGC
local AvatarPartType = _G.UE.EAvatarPartType
local TimerMgr = nil
local EmotionTaskBase = LuaClass()

function EmotionTaskBase:Ctor()
	self.FromID = nil
	self.EmotionID = nil
	self.ToID = nil
	self.bForceLoop = nil
	self.IDType = nil			--该类型来自服务器
	self.MotionType = nil
	self.IsBattleEmotion = nil
	self.LookAtRule = nil
	self.bOpenHeightAdjust = false
	self.IsTurnToTarget = nil
	self.CancelByServer = nil
	self.MontageToPlay = nil
	self.bIsLastFace = false	--已在播放表情
	self.AnimParam = nil
	self.AnimResHandle = nil
	self.CancelReason = nil		--取消动作的原因（EmotionDefines.CancelReason）
	self.bIsLastHoldWeapon = false
	TimerMgr = _G.TimerMgr
end

function EmotionTaskBase:PlayEmotion()
	local _ <close> = CommonUtil.MakeProfileTag("EmotionTaskBase:PlayEmotion")
	if self:IsFaceAnim() then  --是表情动作
		self.AnimParam = EmotionAnimUtils.GetFaceEmotionAnimResParam(self)
	else
		self.AnimParam = EmotionAnimUtils.GetEmotionAnimResParam(self)
	end

	local _ <close> = CommonUtil.MakeProfileTag("EmotionTaskBase:PlayEmotion:LoadObjectsAsync")
	local PathArray = _G.UE.TArray("")
	if not string.isnilorempty(self.AnimParam.StateAnimPath) then
		PathArray:Add(self.AnimParam.StateAnimPath)
	end
	if not string.isnilorempty(self.AnimParam.BeginAnimPath) then
		PathArray:Add(self.AnimParam.BeginAnimPath)
	end
	local Callback = function() self:OnAnimLoad() end
	self.AnimResHandle = _G.ObjectMgr:LoadObjectsAsync(PathArray, Callback, EObjectGC.NoCache, Callback)
end

function EmotionTaskBase:OnAnimLoad()
	self:SetLookAtTarget()
	self:PlayEmotionAnim(self.bForceLoop and "Loop" or "")
end

local ULuaDelegateMgr = _G.UE.ULuaDelegateMgr

function EmotionTaskBase:PlayEmotionAnim(Section)
	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	local AnimComp = FromActor and FromActor:GetAnimationComponent() or nil
	if not AnimComp then
		self:CancleEmotion()
		return
	end
	
	local Emotion = EmotionCfg:FindCfgByKey(self.EmotionID)
	if nil == Emotion then
		print('[Emotion] Play Emotion ID' .. self.EmotionID .. " Is Invalid")
		self:CancleEmotion()
		return
	end
	
	-- if self:IsValidVelocity(FromActor, self.EmotionID, Emotion.MotionType) then
	-- 	print(" [EmotionMgr] [EmotionTaskBase] Is Valid Velocity > 0 ")
	-- 	self:CancleEmotion()
	-- 	return
	-- end

	local AnimParam = self.AnimParam
	local StateAnim = _G.ObjectMgr:LoadObjectSync(AnimParam.StateAnimPath, ObjectGCType.LRU)

	self:SetEmotionStates()
	AnimComp:SetCameraLookAtState(0)  --关闭镜头lookat

	if StateAnim then
		local Proxy = ULuaDelegateMgr.Get():NewLevelLifeDelegateProxy()
		local Ref = UnLua.Ref(Proxy)
		local OnEmotionAnimEnded = function(_, AnimMontage, bInterrupted)
			self.MontageToPlay = nil
			local EventParams = _G.EventMgr:GetEventParams()
			EventParams.ULongParam1 = self.FromID
			EventParams.ULongParam2 = self.ToID
			EventParams.IntParam1 = self.EmotionID
			EventParams.IntParam2 = self.CancelReason
            EventParams.BoolParam1 = bInterrupted
			_G.EventMgr:SendEvent(EventID.CancelEmotion, EventParams)
			_G.EventMgr:SendCppEvent(EventID.CancelEmotion, EventParams)
			Ref = nil
		end

		local StopAllMontages = true
		if self:IsFaceAnim() then
			if self.bIsLastFace then
				StopAllMontages = true
			else
				StopAllMontages = false				--播放表情不打断常规动作
			end
		else
			if self.bIsLastFace then
				AnimComp.bIsPlayFaceAnim = false
				StopAllMontages = false				--播放常规动作不打断表情 
			else
				StopAllMontages = true
			end
		end

		if self:IsLoopAnim() then
			local Animations = {
				[1] = {AnimPath = AnimParam.BeginAnimPath, bStopAllMontages = StopAllMontages},
				[2] = {AnimPath = AnimParam.StateAnimPath, bStopAllMontages = StopAllMontages},
			}
			self.AnimationQueueID = AnimMgr:PlayAnimationMulti(self.FromID, Animations, true)
		else
			if self:GetCurState() == EmotionDefines.StateDefine.ADJUST and 
			(self.adjust == _G.UE.EPlayerAnimAdjustType.DOWN_L or self.adjust == _G.UE.EPlayerAnimAdjustType.DOWN_M)then
				self.PlayMonTime = TimerMgr:AddTimer(self, function()
					if CommonUtil.IsObjectValid(AnimComp) then
						self.MontageToPlay = AnimComp:PlayMontage(StateAnim, {Proxy, OnEmotionAnimEnded}, nil, 1, 0.25, 0.25, nil, StopAllMontages, 0, true)
					end
				end , 1, 0, 1)
				return
			end
			print('[EmotionTaskBase]PlayEmotionAnim', self.EmotionID)
			self.MontageToPlay = AnimComp:PlayMontage(StateAnim, {Proxy, OnEmotionAnimEnded}, nil, 1, 0.25, 0.25, nil, StopAllMontages, 0, true)
		end
	else
		self:CancleEmotion()
	end
end

function EmotionTaskBase:CancleEmotion()
	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	if not FromActor or not FromActor:GetAnimationComponent() then return end
	local AnimComp = FromActor:GetAnimationComponent()
	local Emotion = EmotionCfg:FindCfgByKey(self.EmotionID)
	if nil == Emotion then
		print('[Emotion] Cancle Emotion ID' .. self.EmotionID .. " Is Invalid")
		return
	end
	
	if self.MontageToPlay then
		if self:IsFaceAnim() then
			AnimComp:StopFaceAnimMontage(self.MontageToPlay)
		else
			AnimComp:StopMontage(self.MontageToPlay)
		end
	else
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.ULongParam1 = self.FromID
		EventParams.ULongParam2 = self.ToID
		EventParams.IntParam1 = self.EmotionID
		EventParams.IntParam2 = self.CancelReason
        EventParams.BoolParam1 = true
		_G.EventMgr:SendEvent(EventID.CancelEmotion, EventParams)
		_G.EventMgr:SendCppEvent(EventID.CancelEmotion, EventParams)
	end
	if self.AnimationQueueID then
		AnimMgr:StopAnimationMulti(self.FromID, self.AnimationQueueID)
	end
	
	-- AnimComp:StopAnimation()  --停止所有动作

	if self.AnimResHandle then
		_G.ObjectMgr:CancelLoad(self.AnimResHandle)
		self.AnimResHandle = nil
	end

	AnimComp:SetCameraLookAtState(1)  --重新启动镜头lookat
end

---特殊动作状态（包括战斗动作、高度调整、追踪规则）
function EmotionTaskBase:SetEmotionStates()
	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	if FromActor == nil or FromActor:GetAnimationComponent() == nil then
		return
	end

	--【战斗动作】
	-- 战斗动作是指由情感动作表配置“IsBattleEmotion”的情感动作（目前只有胜利呼唤）
	-- 还原端游表现是这种动作需要在播放时手拿武器。
	if self.IsBattleEmotion == 1 then
		local StateCom = ActorUtil.GetActorStateComponent(self.FromID)
		StateCom:TempHoldWeapon(_G.UE.ETempHoldMask.Emote)
	else
		if not self:IsFaceAnim() then  --播放普通动作要收刀（表情不收）
			FromActor:GetAvatarComponent():TempSetAvatarBack(1)
			self:LockAttachmentTransform(FromActor, true)	-- 锁定武器Transform
		end
	end

	--【高度调整】
	local AnimComp = FromActor:GetAnimationComponent()
	local AnimInst = AnimComp and AnimComp:GetAnimInstance() or nil
	if AnimInst == nil then return end
	if self:GetCurState() == EmotionDefines.StateDefine.ADJUST then
		if CommonDefine.bMajorAnimInstanceUseCode == false then
			AnimInst:SetOpenHeightAdjust(self.bOpenHeightAdjust)	--走动画蓝图
		else
			self:ActiveHeightAdjust()
		end
		if MajorUtil.IsMajor(self.FromID) then
			local AType = _G.UE.EPlayerAnimAdjustType
			local bDOWN = self.adjust == AType.DOWN_M or self.adjust == AType.DOWN_L
			if bDOWN then
				_G.EmotionMgr:SetCameraLookAt(0, true, true)
			end
		end
	end

	--【追踪规则】0=ALL, 1=Eye, 2=HeadAndEye, 3=none
	AnimInst:SetLookAtType(self.LookAtRule)
end

function EmotionTaskBase:LockAttachmentTransform(Actor, IsLock)
	local AvatarCom = Actor and Actor:GetAvatarComponent() or nil
	if AvatarCom then
		if IsLock then
			AvatarCom:LockTransformByPosKey(AvatarPartType.WEAPON_MASTER_HAND)
			AvatarCom:LockTransformByPosKey(AvatarPartType.WEAPON_SLAVE_HAND)
		else
			AvatarCom:UnlockTransformByPosKey(AvatarPartType.WEAPON_MASTER_HAND)
			AvatarCom:UnlockTransformByPosKey(AvatarPartType.WEAPON_SLAVE_HAND)
		end
	end
end

---重置战斗动作、高度调整、追踪规则状态
function EmotionTaskBase:ResetEmotionStates()
	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	if FromActor == nil or FromActor:GetAnimationComponent() == nil then
		return
	end

	self:LockAttachmentTransform(FromActor, false)
	FromActor:SetWeaponAttachmentSocketByState()

	local AnimComp = FromActor:GetAnimationComponent()
	local AnimInst = AnimComp and AnimComp:GetAnimInstance() or nil
	if AnimInst then
		AnimInst:SetLookAtType(0)
	end

	if nil == EmotionDefines then
		EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
	end
	local CurState = self:GetCurState()
	if nil ~= CurState and CurState == EmotionDefines.StateDefine.ADJUST then
		--高度调整动作
		local StopAjustAnim = function(AnimInst, StopTime)
			if self:GetCurState() ~= EmotionDefines.StateDefine.ADJUST then return end
			if not AnimInst then return end
			AnimInst:SetOpenHeightAdjust(false)
			AnimInst:StopSlotAnimation(StopTime, "Additive_Ajust")
			AnimInst:StopSlotAnimation(StopTime, "Additive_Add")
			TimerMgr:CancelTimer(self.PlayMonTime)
			self.PlayMonTime = nil
			if MajorUtil.IsMajor(self.FromID) then
				local AType = _G.UE.EPlayerAnimAdjustType
				if self.adjust == AType.DOWN_M or self.adjust == AType.DOWN_L then
					self.IsEndCamera = true
					_G.EmotionMgr:SetCameraLookAt(0, false)
				end
			end
		end

		local IsMove = function(FromActor)
			if CommonUtil.IsObjectValid(FromActor) and 
				CommonUtil.IsObjectValid(FromActor.CharacterMovement) 
				and FromActor.CharacterMovement.Velocity then
				return FromActor.CharacterMovement.Velocity:Size() > 1
			end
		end

		if IsMove(FromActor) then
			--移动将迅速打断高度调整的下跪动作，减小过渡时间
			StopAjustAnim(AnimInst, 0.05)
		else
			StopAjustAnim(AnimInst, 0.5)
		end
	end
end

function EmotionTaskBase:TaskEnter(Params)
	self:OnTaskEnter(Params)
end

---是持续循环动作、改变姿势Id=90（情感动作表：2）
function EmotionTaskBase:IsLoopAnim()
	return EmotionAnimUtils.IsLoopAnim(self.MotionType)
end

---是表情动作（情感动作表：动作分类列，MotionType = 0）
function EmotionTaskBase:IsFaceAnim()
	return EmotionAnimUtils.IsFaceAnim(self.MotionType)
end

function EmotionTaskBase:TaskEnd(Params)
	local _ <close> = CommonUtil.MakeProfileTag("EmotionTaskBase:TaskEnd")
	self:ResetEmotionStates()
	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	if FromActor then
		-- 重新启动镜头lookat
	    local AnimComp = FromActor:GetAnimationComponent()
		if AnimComp then
			AnimComp:SetCameraLookAtState(1)
		end
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("EmotionTaskBase:TaskEnd:SendStopEmotionReq")
		--local bInterrupted = Params.BoolParam1
		-- 若主角因为某些客户端行为（例如被其他蒙太奇顶替）中断掉持续类情感动作 则需要同步服务器
		-- 状态类情感动作规则较为复杂 不会被蒙太奇等顶替掉 通常中断时后台也会处理 故无需同步后台
		if not self.CancelByServer and self.FromID == MajorUtil.GetMajorEntityID() and self:IsLoopAnim() then
			-- print("[Emotion] EmotionTaskBase:TaskEnd send stop emtion req by EmotionID:" .. self.EmotionID .. " task end")
			local ProtoCS = require ("Protocol/ProtoCS")
			_G.EmotionMgr:SendStopEmotionReq(ProtoCS.EmotionType.EmotionTypeLast)
		end
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("EmotionTaskBase:TaskEnd:SyncMajorRotation")
		local MajorID = MajorUtil.GetMajorEntityID()
		if self.FromID == MajorID then
			-- 同步朝向
			_G.UE.UMoveSyncMgr:Get():SyncMajorRotation()
		end
	end

	self:HoldWeaponStateEnd()

	self:OnTaskEnd(Params)
end

function EmotionTaskBase:OnTaskEnter(Params)
end

function EmotionTaskBase:OnTaskEnd(Params)
end

function EmotionTaskBase:CanPlayEmotion()
	if ActorUtil.GetActorByEntityID(self.FromID) == nil then
		return
	end
	if self.IsBattleEmotion == 1 then   --来源：情感动作表的列“是否战斗动作，IsBattleEmotion”
		local ProfID = ActorUtil.GetActorAttributeComponent(self.FromID).ProfID
		local Specialization = RoleInitCfg:FindProfSpecialization(ProfID)
		-- 生产职业不能使用战斗情感动作
		if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
			return false
		end
	end
	return self.EmotionID ~= 0
end

function EmotionTaskBase:GetCurState()
	if nil == ActorUtil then
		ActorUtil = require("Utils/ActorUtil")
	end
	if nil == EmotionDefines then
		EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
	end
	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	if FromActor then
		local bIsSitState, SitEmotionID = _G.EmotionMgr:IsSitState(self.FromID)
		local bIsRiding = false
		if FromActor:GetRideComponent() ~= nil then
			bIsRiding = FromActor:GetRideComponent():IsInRide()
		end
		local bIsSwimming = FromActor:IsSwimming()
		if SitEmotionID == _G.EmotionMgr.SitGroundID then	--座り中は補正しない
			return EmotionDefines.StateDefine.SIT_GROUND
		elseif SitEmotionID == _G.EmotionMgr.SitChairID then
			return EmotionDefines.StateDefine.SIT_CHAIR		--潜水は補正しない(暂无)
		elseif bIsRiding or bIsSwimming then				--マウント中は補正しない
			return EmotionDefines.StateDefine.UPPER_BODY	--泳ぎは補正しない
		elseif self:IsOpenHeightAdjust() then				--高さ調整
			return EmotionDefines.StateDefine.ADJUST
		end
	end
	return EmotionDefines.StateDefine.NORMAL
end

function EmotionTaskBase:IsOpenHeightAdjust()
	if self.bOpenHeightAdjust then
		if self.ToID == 0 then
			return false
		elseif self.FromID == self.ToID then
			if self.IDType ~= EmotionTargetType.EmotionTargetTypeListCompanion then
				return false
			end
		end
		return true
	else
		return false
	end
end

--- 启动LookAt
function EmotionTaskBase:SetLookAtTarget()
	local FromActor = ActorUtil.GetActorByEntityID(self.FromID)
	local TargetActor = ActorUtil.GetActorByEntityID(self.ToID)
	local EmotionMgr = _G.EmotionMgr
	--没有选中目标则不转身
	if not TargetActor or not EmotionMgr then
		return
	end

	--在坐下状态不转身
	local bIsSit, _ = EmotionMgr:IsSitState(self.FromID)
	if bIsSit then
		return
	end

	--若目标是宠物 IDType = 4  该类型由服务器在下发播放情感动作时确定
	--(因宠物没有EntityID，而且宠物位置不同步,若转向同步,则会导致转向后其他玩家看到的方向不对)
	if self.IDType == EmotionTargetType.EmotionTargetTypeListCompanion then
		if TargetActor:GetCompanionComponent() ~= nil then
			TargetActor = TargetActor:GetCompanionComponent():GetCompanion()
		end
	end

	--目标为自己且不是自己宠物则不转身 (先判断上面是宠物)
	if TargetActor == FromActor then
		return
	end

	EmotionMgr:RInterpToLookAtActor(FromActor, TargetActor)
end

function EmotionTaskBase:ActiveHeightAdjust()
	--高さ調整
    self.adjust = 0
	if self:GetCurState() == EmotionDefines.StateDefine.ADJUST then
		self.adjust = _G.EmotionMgr:GetEmoteAjustTimeline(self.FromID, self.ToID, self.IDType, self.EmotionID)
		if (self.adjust and self.adjust ~= 0) then
		
			-- uActionTimelineID_Main = pkEmoteData->TimelineID_Adjust
			-- if self.EmotionID == _G.EmotionMgr.EXD_EMOTE_STROKE and self.adjust == _G.UE.EPlayerAnimAdjustType.DOWN_L or self.adjust == _G.UE.EPlayerAnimAdjustType.DOWN_M then
			-- 	uActionTimelineID_Main = EXD_ACTION_TIMELINE_AJUST_EMOTE_STROKE_TOP_UPPER	--なでるの特殊対応
			-- end

			local MajorAnimInst = AnimationUtil.GetPlayerAnimInst(self.FromID)
			if nil == MajorAnimInst then return end
			local AdjustBody = self.adjust
			if self.adjust == _G.UE.EPlayerAnimAdjustType.ADD_TIPTOE then
				AdjustBody = _G.UE.EPlayerAnimAdjustType.TIPTOE
			end
			local AnimSequence = MajorAnimInst:GetAdjustAnim(AdjustBody)
			if AnimSequence == nil then
				_G.FLOG_INFO(' [EmotionTaskBase] GetAdjustAnimSequence = false ')
				return
			end
			MajorAnimInst:SetOpenHeightAdjust(self.bOpenHeightAdjust)  	--在状态机开启高度调整
			if (self.adjust == _G.UE.EPlayerAnimAdjustType.DOWN_L or self.adjust == _G.UE.EPlayerAnimAdjustType.DOWN_M) and
				MajorAnimInst:Montage_IsPlaying(nil) then	--おなじアジャストが流れている場合

				local AnimMontage = MajorAnimInst:PlaySlotAnimationAsDynamicMontage(AnimSequence, "Additive_Ajust", 0.1, 0.1, 1, 1, -1, 1)	--1秒カットしてしゃがみ状態から再生
				self.AjustMonTime = AnimMontage:GetPlayLength() - 1
			else
				local AnimMontage = MajorAnimInst:PlaySlotAnimationAsDynamicMontage(AnimSequence, "Additive_Ajust")	--body
				self.AjustMonTime = AnimMontage:GetPlayLength()
			end
			if self.adjust == _G.UE.EPlayerAnimAdjustType.ADD_TIPTOE then
				--踮脚（TIPTOE） 的同时需要抬手（ADD_TIPTOE）
				local AddAnimSeq = MajorAnimInst:GetAdjustAnim(self.adjust)
				if AddAnimSeq then
					MajorAnimInst:PlaySlotAnimationAsDynamicMontage(AddAnimSeq, "Additive_Add")	--add
				end
			end
		end
	end
end

function EmotionTaskBase:IsValidVelocity(FromActor, EmotionID, MotionType)
	if FromActor and FromActor.CharacterMovement then
		local Velocity = FromActor.CharacterMovement.Velocity
		if Velocity:Size() > _G.EmotionMgr.INF then
			if nil ~= MotionType and MotionType ~= 0 then			--移动中可以使用表情0
				if EmotionID ~= _G.EmotionMgr.EXD_EMOTE_WAKE then	--起床动作
					return true
				end
			end
		end
	end
	return false
end

--- 战斗动作在播放时会进入战斗掏出武器（如：胜利欢呼 ID = 110）
--- 战斗动作（目前只有胜利呼唤动作）在结束播放时要退出战斗状态
function EmotionTaskBase:HoldWeaponStateEnd()
	if self.IsBattleEmotion ~= 1 then
		return
	end
	local StateComponent = ActorUtil.GetActorStateComponent(self.FromID)
	if StateComponent then
		StateComponent:ClearTempHoldWeapon(_G.UE.ETempHoldMask.Emote, true)
	end
end

function EmotionTaskBase:RotationInterp(EntityID)
	if nil == _G.EmotionMgr.RotationInterpSpeed then
		local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
		if ClientGlobalCfg then
			local ProtoRes = require("Protocol/ProtoRes")
			if ProtoRes then
				local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_ROTATION_INTERP_SPEED)
				if Cfg then
					_G.EmotionMgr.RotationInterpSpeed = Cfg.Value[1]
				end
			end
		end
    end

    MajorUtil.LookAtActorByInterp(EntityID, _G.EmotionMgr.RotationInterpSpeed)
end

return EmotionTaskBase
