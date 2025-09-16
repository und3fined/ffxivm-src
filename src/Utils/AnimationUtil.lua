--[[
Date: 2022-12-09 16:19:27
LastEditors: moody
LastEditTime: 2022-12-09 16:19:28
--]]

local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local CommStatAnimCfg = require("TableCfg/CommStatAnimCfg")
local ObjectGCType = require("Define/ObjectGCType")

local AnimationUtil = {}

function AnimationUtil.CreateLoopDynamicMontage(StartAnim, LoopAnim, SlotNodeName)
	print("AnimationUtil.CreateLoopDynamicMontage")
	return _G.UE.FAnimUtils.CreateLoopDynamicMontage(StartAnim, LoopAnim, SlotNodeName, nil, 0.25, 0.25, 1.0, -1.0, 0.0)
end

function AnimationUtil.GetAnimInst(EntityID)
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp == nil then
		return nil
	end
	local AnimInst = AnimComp:GetAnimInstance()
	return AnimInst
end

function AnimationUtil.IsSlotPlayingMontage(AnimInst, SlotName)
	return _G.UE.UFGameAnimBlueprintLibrary.IsSlotPlayingMontage(AnimInst, SlotName)
end

function AnimationUtil.GetHeadAnimInst(EntityID)
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp == nil then
		return nil
	end
	local AnimInst = AnimComp:GetHeadAnimInstance()
	return AnimInst
end

function AnimationUtil.GetPlayerAnimInst(EntityID)
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp == nil then
		return nil
	end
	local AnimInst = AnimComp:GetPlayerAnimInstance()
	return AnimInst
end

-- AnimInst 未空时会默认使用主mesh的
function AnimationUtil.PlayAnyAsMontage(EntityID, AnimRes, Slot, Callback, AnimInst, Section, PlayRate, bStopAllMontages, BlendInTime, BlendOutTime)
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp == nil or AnimRes == nil then
		return
	end

	return AnimationUtil.PlayMontage(AnimComp, AnimRes, Slot, Callback, AnimInst, Section, PlayRate, bStopAllMontages, BlendInTime, BlendOutTime)
end

function AnimationUtil.PlayMontage(AnimComp, AnimRes, Slot, Callback, AnimInst, Section, PlayRate, bStopAllMontages, BlendInTime, BlendOutTime,StartTime)
	if nil == AnimComp or nil == AnimRes then
		return
	end

	Section = Section or ""
	PlayRate = PlayRate or 1.0
	BlendInTime = BlendInTime or 0.25
	BlendOutTime = BlendOutTime or 0.25
	if bStopAllMontages == nil then
		bStopAllMontages = true
	end

	Callback = CommonUtil.GetDelegatePair(Callback, true)

	local Montage = AnimRes:Cast(_G.UE.UAnimMontage)
	if Montage then
		return AnimComp:PlayMontage(Montage, Callback, Section, PlayRate, BlendInTime, BlendOutTime, AnimInst, bStopAllMontages,StartTime)
	end

	local AnimSeq = AnimRes:Cast(_G.UE.UAnimSequenceBase)
	if AnimSeq then
		return AnimComp:PlaySequenceToMontage(AnimSeq, Slot, Callback, Section, PlayRate, BlendInTime, BlendOutTime, AnimInst, 1, bStopAllMontages)
	end
end


------------ 使用通用状态动作表的动画进入和退出 begin --------------------
--进入动画到循环动画
function AnimationUtil.PlayCommonStatEnterAnim(EntityID, AnimID)
	local RecipeAnimData = CommStatAnimCfg:FindCfg("ID = " .. AnimID)
	AnimationUtil.PlayCommonStatEnterAnim()
	local EnterAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData.ExitAnim)
	local EnterAnim = _G.ObjectMgr:LoadObjectSync(EnterAnimStr, ObjectGCType.LRU)
	local LoopAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData.ExitAnim)
	local LoopAnim = _G.ObjectMgr:LoadObjectSync(LoopAnimStr, ObjectGCType.LRU)

	print("PlayCommonStatAnim:")

	if not EnterAnim or not LoopAnim then
		FLOG_ERROR("[AnimationUtil.PlayCommonStatEnterAnim] Can not Find Anim[%s] or Anim[%s]", EnterAnimStr, LoopAnimStr)
		return 
	end

	local DynamicMontage = AnimationUtil.CreateLoopDynamicMontage(EnterAnim, LoopAnim, "WholeBody")
	AnimationUtil.PlayAnyAsMontage(EntityID, DynamicMontage, "WholeBody", nil, nil, "")
end

--退出循环动画
function AnimationUtil.PlayCommonStatExitAnim(EntityID, AnimID)
	local RecipeAnimData = CommStatAnimCfg:FindCfg("ID = " .. AnimID)

	print("PlayCommonStatExitAnim:")
	local ExitAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData.ExitAnim)
	local ExitAnim = _G.ObjectMgr:LoadObjectSync(ExitAnimStr, ObjectGCType.LRU)

	if not ExitAnim then
		FLOG_ERROR("[AnimationUtil.PlayCommonStatExitAnim] Can not Find Anim[%s]", ExitAnimStr)
		return 
	end

	AnimationUtil.PlayAnyAsMontage(EntityID, ExitAnim, "WholeBody", nil, nil, "")
end

--检查一下配置的动画格式，兼容之前配置的Sequence
function AnimationUtil.ConvertToTruePath(Path)
	local MajorUtil = require("Utils/MajorUtil")
	local RoleInitCfg = require("TableCfg/RoleInitCfg")
	local DefalutDir = "lv_%s_%s"
	local DefaultPath = "AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/%s/timeline/base/b0001/%s.%s'"
	local IsGathering = _G.GatherMgr.IsGathering
	local isMaking = _G.CrafterMgr:GetIsMaking()
	local ProfID = MajorUtil.GetMajorProfID()
	if ProfID == nil then
		FLOG_ERROR("[AnimationUtil.ConvertToTruePath] MajorProfID == nil !")
		return ""
	end
	local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
	local FuncStr = Cfg.ProfAbbr
	if IsGathering then
		DefalutDir = string.format(DefalutDir, "p", FuncStr)
	elseif isMaking then
		DefalutDir = string.format(DefalutDir, "c", FuncStr)
	end
	
	local IsOldPath = string.match(Path,"/")
	if not IsOldPath then
		Path = string.format(DefaultPath, DefalutDir, Path, Path)
	end
	return Path
end

------------ 使用通用状态动作表的动画进入和退出 end --------------------

function AnimationUtil.PlayAutoShake(EntityID, ShakeType)
	local CurEntity = ActorUtil.GetActorByEntityID(EntityID)
	if CurEntity == nil then
		return nil
	end

	CurEntity:PlayAutoShake(ShakeType);
end

-- AnimComp为nil时使用EntityID对应的AnimComp
-- PosKey默认为0
-- BlendOutTime默认为0.25
function AnimationUtil.StopSlotAnimation(AnimComp, EntityID, SlotName, BlendOutTime, PosKey)
	AnimComp = AnimComp or ActorUtil.GetActorAnimationComponent(EntityID)
	BlendOutTime = BlendOutTime or 0.25
	if AnimComp then
		AnimComp:StopSlotAnimation(SlotName, BlendOutTime, PosKey)
	end
end

function AnimationUtil.StopAnimation(AnimComp, AnimPath, TargetAvatarPartType)
	if TargetAvatarPartType == nil then
		TargetAvatarPartType = 99999
	end
	if AnimComp then
		AnimComp:StopAnimation(AnimPath, TargetAvatarPartType)
	end
end

---@param BlendInTime number 默认0.25
function AnimationUtil.MontageStop(AnimInst, Montage, BlendOutTime)
	BlendOutTime = BlendOutTime or 0.25
	_G.UE.FAnimUtils.MontageStop(AnimInst, Montage, BlendOutTime)
end

function AnimationUtil.SetMontagePosition(AnimInst, Montage, Position)
	_G.UE.FAnimUtils.SetMontagePosition(AnimInst, Montage, Position)
end

function AnimationUtil.GetMontagePosition(AnimInst, Montage)
	return _G.UE.FAnimUtils.GetMontagePosition(AnimInst, Montage)
end
function AnimationUtil.GetMontagePlayRate(AnimInst, Montage)
	return _G.UE.FAnimUtils.GetMontagePlayRate(AnimInst, Montage)
end
function AnimationUtil.SetMontagePlayRate(AnimInst, Montage, NewPlayRate)
	return _G.UE.FAnimUtils.SetMontagePlayRate(AnimInst, Montage, NewPlayRate)
end
function AnimationUtil.MontageResume(AnimInst, Montage)
	_G.UE.FAnimUtils.MontageResume(AnimInst, Montage)
end
function AnimationUtil.MontageResumeAndStopNextTick(AnimInst, Montage)
	_G.UE.FAnimUtils.MontageResumeAndStopNextTick(AnimInst, Montage)
end
function AnimationUtil.MontagePause(AnimInst, Montage)
	_G.UE.FAnimUtils.MontagePause(AnimInst, Montage)
end

function AnimationUtil.MontageIsPlaying(AnimInst, Montage)
	return _G.UE.FAnimUtils.MontageIsPlaying(AnimInst, Montage)
end

function AnimationUtil.MontageGetBlendTime(AnimInst, Montage)
	return _G.UE.FAnimUtils.MontageGetBlendTime(AnimInst, Montage)
end

function AnimationUtil.GetAnimMontageLength(Montage)
	if Montage == nil then
		return
	end
	return Montage:GetPlayLength()
end

return AnimationUtil