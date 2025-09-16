--[[
Date: 2022-11-02 16:31:25
LastEditors: moody
LastEditTime: 2022-11-02 16:31:25
--]]

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local CommStatAnimCfg = require("TableCfg/CommStatAnimCfg")
-- local RecipeCfg = require("TableCfg/RecipeCfg")
local ObjectGCType = require("Define/ObjectGCType")
local AnimDefines = require("Game/Anim/AnimDefines")
-- local RecipetoolAnimCfg = require("TableCfg/RecipetoolAnimatiomCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")

local FLOG_ERROR = _G.FLOG_ERROR

local AnimMgr = LuaClass(MgrBase)

function AnimMgr:OnInit()
	self.AnimationQueueCounter = 100000000
	self.CachedCrafterStateMap = {}
	self.CachedGatherStateMap = {}

	self:InitLODMap()
end

function AnimMgr:InitLODMap()
	local AnimLODControllerInterface = _G.UE.AnimLODControllerInterface
	AnimLODControllerInterface.AddClassLODThreshold("default", 1)
	AnimLODControllerInterface.AddClassLODThreshold("postprocess", 0)
	AnimLODControllerInterface.ClearLODUpdateMasterPosKey()
	AnimLODControllerInterface.AddLODUpdateMasterPosKey(_G.UE.EAvatarPartType.NAKED_BODY_HAIR)
	AnimLODControllerInterface.AddLODUpdateMasterPosKey(_G.UE.EAvatarPartType.EARRING)
end

function AnimMgr:InitAnimBudget()
	local EnableAnimBudget = AnimDefines.EnableAnimBudget or false
	if false == EnableAnimBudget then
		return
	end

	_G.UE.UFGameAnimBlueprintLibrary.RegisterDefaultCalculateSignificance()
	CommonUtil.ConsoleCommand("a.Budget.Enabled 1")
	local UFMSkeletalMeshComponentBudgeted = _G.UE.UFMSkeletalMeshComponentBudgeted
	local EAvatarPartType = _G.UE.EAvatarPartType
	if UFMSkeletalMeshComponentBudgeted then
		UFMSkeletalMeshComponentBudgeted.ClearDisableAnimationBudgetPosKeys()
		--UFMSkeletalMeshComponentBudgeted.AddDisableAnimationBudgetPosKey(EAvatarPartType.NAKED_BODY_HAIR)
		--UFMSkeletalMeshComponentBudgeted.AddDisableAnimationBudgetPosKey(EAvatarPartType.NAKED_BODY_HEAD)
	end
end

function AnimMgr:OnBegin()
	self:InitAnimBudget()
end

-- function AnimMgr:OnEnd()
-- end

-- function AnimMgr:OnShutdown()

-- end

-- function AnimMgr:OnRegisterNetMsg()

-- end

function AnimMgr:OnRegisterGameEvent()
	-- 职业切换
	self:RegisterGameEvent(_G.EventID.OtherCharacterSwitch, self.OnOtherCharacterSwitch)
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.OnMajorProfSwitch)
	self:RegisterGameEvent(_G.EventID.InteractiveStateChange, self.OnInteractiveStatChanged)
	--self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAvatarUpdate)
	self:RegisterGameEvent(_G.EventID.WorldPreLoad, self.OnWorldPreLoad)
	--self:RegisterGameEvent(_G.EventID.WorldPostLoad, self.OnWorldPostLoad)
end

function AnimMgr:OnOtherCharacterSwitch(Params)
	self:UpdateProfAnims(Params.ULongParam1)
end

function AnimMgr:OnMajorProfSwitch(Params)
	self:UpdateProfAnims(MajorUtil.GetMajorEntityID())
end

-- 更新职业动画
function AnimMgr:UpdateProfAnims(EntityID)
	local AnimInst = AnimationUtil.GetPlayerAnimInst(EntityID)
	if AnimInst then
		AnimInst:OnCharacterProfChanged()
	end
end

--状态改变
function AnimMgr:OnInteractiveStatChanged(Params)
	local EntityID = Params.ULongParam1
	local CurStatBits = Params.ULongParam2
	local PrevStatBits = Params.ULongParam3
	local CurSpellID = Params.IntParam1
	local PrevSpellID = Params.IntParam2

	local CachedCrafterStateMap = self.CachedCrafterStateMap
	local CachedGatherStateMap = self.CachedGatherStateMap
	if CurStatBits == ProtoCommon.INTERACT_TYPE.INTERACT_TYPE_CRAFT then
		_G.CrafterMgr:EnterRecipeState(EntityID, CurSpellID)
		CachedCrafterStateMap[EntityID] = CurSpellID
		return
	elseif CurStatBits == ProtoCommon.INTERACT_TYPE.INTERACT_TYPE_GATHER then
		_G.GatherMgr:EnterGatherState(EntityID, CurSpellID)
		CachedGatherStateMap[EntityID] = CurSpellID
		return
	end

	if PrevStatBits == ProtoCommon.INTERACT_TYPE.INTERACT_TYPE_CRAFT then
		_G.CrafterMgr:ExitRecipeState(EntityID, PrevSpellID)
		CachedCrafterStateMap[EntityID] = nil
		return
	elseif PrevStatBits == ProtoCommon.INTERACT_TYPE.INTERACT_TYPE_GATHER then
		_G.GatherMgr:ExitGatherState(EntityID, PrevSpellID)
		CachedGatherStateMap[EntityID] = nil
		return
	end
end

function AnimMgr:GetCachedSpellID(EntityID, bCrafter)
	local StateMap = bCrafter and self.CachedCrafterStateMap or self.CachedGatherStateMap
	return StateMap and StateMap[EntityID] or nil
end

-- function AnimMgr:OnAvatarUpdate(Params)
-- 	local EntityID = Params.ULongParam1
-- 	local CachedCrafterState = self.CachedCrafterStateMap[EntityID]
-- 	local CachedGatherState = self.CachedGatherStateMap[EntityID]

-- 	if CachedCrafterState then
-- 		_G.CrafterMgr:EnterRecipeState(EntityID, CachedCrafterState)
-- 		self.CachedCrafterStateMap[EntityID] = nil
-- 	elseif MajorUtil.IsMajor(EntityID) and MajorUtil.IsCrafterProf() then
-- 		local Major = MajorUtil.GetMajor()
-- 		if Major then
-- 			Major:ClearCrafterWeaponState(false)
-- 		end
-- 	end

-- 	if CachedGatherState then
-- 		_G.GatherMgr:EnterGatherState(EntityID, CachedGatherState)
-- 		self.CachedGatherStateMap[EntityID] = nil
-- 	end
-- end

function AnimMgr:OnWorldPreLoad()
	self.CachedCrafterStateMap = {}
	self.CachedGatherStateMap = {}
	-- local AnimCom = MajorUtil.GetMajorAnimationComponent()
	-- if AnimCom then
	-- 	AnimCom:SaveLinkedLayers()
	-- end
end

function AnimMgr:OnWorldPostLoad()
	-- 保底处理
	-- local AnimCom = MajorUtil.GetMajorAnimationComponent()
	-- if AnimCom then
	-- 	AnimCom:RelinkLayers()
	-- end
	-- local AvatarCom = MajorUtil.GetMajorAvatarComponent()
	-- if AvatarCom then
	-- 	local Assembler = AvatarCom and AvatarCom:GetAssembler() or nil
	-- 	if Assembler then
	-- 		Assembler:ReInit()
	-- 	end
	-- end
end

function AnimMgr:PlayEnterAnim(EntityID, AnimID, CallBack, NoLoop)
	local Section = ""
	local RecipeAnimData = CommStatAnimCfg:FindCfg("ID = " .. AnimID)

	if RecipeAnimData == nil then
		FLOG_ERROR("[AnimMgr:PlayEnterAnim Loop] AnimID is invalid " .. AnimID)
		return
	end
	local EnterAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData.EnterAnim) 
	local EnterAnim = _G.ObjectMgr:LoadObjectSync(EnterAnimStr, ObjectGCType.LRU)
	local LoopAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData.LoopAnim)
	local LoopAnim = _G.ObjectMgr:LoadObjectSync(LoopAnimStr, ObjectGCType.LRU)

	if not EnterAnim or not LoopAnim then
		FLOG_ERROR("[AnimMgr:PlayEnterAnim] Can not Find Anim[%s] or Anim[%s]", EnterAnimStr, LoopAnimStr)
		return 
	end

	if NoLoop then
		AnimationUtil.PlayAnyAsMontage(EntityID, EnterAnim, "WholeBody", CallBack, nil, Section)
	else
		local DynamicMontage = AnimationUtil.CreateLoopDynamicMontage(EnterAnim, LoopAnim, "WholeBody")
		AnimationUtil.PlayAnyAsMontage(EntityID, DynamicMontage, "WholeBody", CallBack, nil, Section)
	end
	AnimationUtil.PlayAutoShake(EntityID, 1)
end

function AnimMgr:PlayExitAnim(EntityID, AnimID,Callback)
	local RecipeAnimData = CommStatAnimCfg:FindCfg("ID = " .. AnimID)
	if RecipeAnimData == nil then
		FLOG_ERROR("[AnimMgr:PlayExitAnim] AnimID is invalid " .. AnimID)
		return
	end

	local ExitAnimStr = AnimationUtil.ConvertToTruePath(RecipeAnimData.ExitAnim)
	local ExitAnim = _G.ObjectMgr:LoadObjectSync(ExitAnimStr, ObjectGCType.LRU)

	if not ExitAnim then
		FLOG_ERROR("[AnimMgr:PlayExitAnim] Can not Find Anim[%s]", ExitAnimStr)
		return 
	end

	AnimationUtil.PlayAnyAsMontage(EntityID, ExitAnim, "WholeBody", Callback, nil, "")
end

function AnimMgr:GetActionTimeLinePath(AnimPath)
	if not AnimPath then
		return
	end

	local SplitStrs = string.split(AnimPath, "/")
	local Name = SplitStrs[#SplitStrs]
	local MontagePath = string.format("AnimMontage'/Game/Assets/Character/Action/%s.%s'", AnimPath, Name)

	return MontagePath
end

function AnimMgr:GetActionTimeLinePathByLabel(ActionTimeLineLabel)
	if not ActionTimeLineLabel then return end

	local SearchCondition = string.format("Label = \"%s\"", ActionTimeLineLabel)
	local Cfg = ActiontimelinePathCfg:FindCfg(SearchCondition)
	if Cfg ~= nil then
		return self:GetActionTimeLinePath(Cfg.Filename)
	end
	return nil
end

function AnimMgr:GetActionTimeLineStance(ActionTimelineID)
	local Stance = 0
	local ActionCfg = ActiontimelinePathCfg:FindCfgByKey(ActionTimelineID)
	if ActionCfg and ActionCfg.Stance then
		Stance = ActionCfg.Stance
	end
	return Stance
end

function AnimMgr:PlayActionTimeLine(EntityID, AnimPath, CallBack)
	if not AnimPath then
		return
	end

	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
    
	local SplitStrs = string.split(AnimPath, "/")
	local Name = SplitStrs[#SplitStrs]
	FLOG_INFO("AnimMgr PlayActionTimeLine: %s - %s", AnimPath, Name)
	local MontagePath = string.format("AnimMontage'/Game/Assets/Character/Action/%s.%s'", AnimPath, Name)
	FLOG_INFO("AnimMgr MontagePath :%s", MontagePath)
	
	
	local Anim = _G.ObjectMgr:LoadObjectSync(MontagePath, ObjectGCType.LRU)
	if AnimComp == nil or Anim == nil then
		return
	end
	
	return AnimComp:PlayAnimationCallBack(MontagePath, CommonUtil.GetDelegatePair(CallBack, true))
end
function AnimMgr:PlayActionTimeLineWithCustomBlendTime(EntityID, AnimPath, CallBack)
	if not AnimPath then
		return
	end

	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
    
	local SplitStrs = string.split(AnimPath, "/")
	local Name = SplitStrs[#SplitStrs]
	FLOG_INFO("AnimMgr PlayActionTimeLine: %s - %s", AnimPath, Name)
	local MontagePath = string.format("AnimMontage'/Game/Assets/Character/Action/%s.%s'", AnimPath, Name)
	FLOG_INFO("AnimMgr MontagePath :%s", MontagePath)
	
	
	local Anim = _G.ObjectMgr:LoadObjectSync(MontagePath, ObjectGCType.LRU)
	if AnimComp == nil or Anim == nil then
		return
	end
	
	return AnimComp:PlayAnimation(MontagePath, 1.0, 0.25, 0.25, true)
end
--- @type 可设置循环次数
function AnimMgr:PlayAnyAsMontageLoop(Actor, Slot, AnimPath, LoopCount, bStopAllMontages)
	if not AnimPath then
		return
	end

	FLOG_INFO("AnimMgr AnimPath :%s", AnimPath)	
	local AnimComp = Actor:GetAnimationComponent()
	local Anim = _G.ObjectMgr:LoadObjectSync(AnimPath, ObjectGCType.LRU)
	if AnimComp == nil or Anim == nil then
		return
	end
	AnimComp:PlayAnimSequence(AnimPath, Slot, LoopCount, bStopAllMontages)
end


--AnimPath: "AnimSequence'/Game/Assets/Character/Action/emote/joy.joy'
function AnimMgr:PlayActionTimeLineByActor(Actor, AnimPath, CallBack)
	if AnimPath == nil then
		return
	end

	if Actor == nil then
		return
	end

	FLOG_INFO("AnimMgr AnimPath :%s", AnimPath)	
	local AnimComp = Actor:GetAnimationComponent()
	local Anim = _G.ObjectMgr:LoadObjectSync(AnimPath, ObjectGCType.LRU)
	if AnimComp == nil or Anim == nil then
		return
	end
	
	AnimComp:PlayAnimationCallBack(AnimPath, CallBack)
end

function AnimMgr:PlayActionTimeLineByActorNextTick(Actor, AnimPath, CallBack)
	if AnimPath == nil then
		return
	end

	if Actor == nil then
		return
	end

	FLOG_INFO("AnimMgr PlayActionTimeLineByActorNextTick AnimPath :%s", AnimPath)	
	local AnimComp = Actor:GetAnimationComponent()
	local Anim = _G.ObjectMgr:LoadObjectSync(AnimPath, ObjectGCType.LRU)
	if AnimComp == nil or Anim == nil then
		return
	end
	
	AnimComp:PlayAnimationCallBackNextTick(AnimPath, CallBack)
end

-- 按照参数列表顺序播放ActionTimeline，调用示例：
-- local ActionTimelines = {
-- 	[1] = {TimelineName = "cbnm_fueaction_1"},
-- 	[2] = {TimelineName = "cbnm_fueaction_2lp", PlayRate = 1, BlendInTime = 0.25, BlendOutTime = 0.25},
-- 	[3] = {TimelineName = "cbnm_fueaction_3"},
-- }
-- AnimMgr:PlayAnimationMulti(EntityID, ActionTimelines)

-- 按照参数列表顺序播放动画，调用示例：
-- local Animations = {
-- 	[1] = {AnimPath = "/Game/Assets/Character/Action/normal/u_fueaction_start.u_fueaction_start"},
-- 	[2] = {AnimPath = "/Game/Assets/Character/Action/normal/u_fueaction_loop.u_fueaction_loop", PlayRate = 1, BlendInTime = 0.25, BlendOutTime = 0.25},
-- }
-- AnimMgr:PlayAnimationMulti(EntityID, Animations)

-- 参数说明：
-- PlayRate: 播放速率
-- BlendInTime: 混入时间
-- BlendOutTime: 混出时间
-- bStopAllMontages: 是否停止所有蒙太奇
-- TargetAvatarPartType: 指定角色身上的部位来播放动画，默认为角色(99999) (坐骑为3001)
-- bLoop: 该动画是否循环

function AnimMgr:PlayAnimationMulti(EntityID, Animations,bUseBlendTimeDataInAsset)
	if Animations == nil or type(Animations) ~= "table" then return end
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp == nil then return end
	self.AnimationQueueCounter = self.AnimationQueueCounter + 1
	for i = 1, #Animations do
		local Param = Animations[i]
		local PlayRate = Param.PlayRate or 1
		local BlendInTime = Param.BlendInTime or 0.25
		local BlendOutTime = Param.BlendOutTime or 0.25

		local bStopAllMontages = true
		if Param.bStopAllMontages == false then
			bStopAllMontages = false
		end

		local TargetAvatarPartType = Param.TargetAvatarPartType or 99999
		local bLoop = false
		if Param.bLoop ~= nil then
			bLoop = Param.bLoop 
		end
		local Callback = Param.Callback
		if Callback ~= nil then
			AnimComp:QueueAnimationCallback(Param.AnimPath or AnimComp:GetDefaultTimeline(Param.TimelineName), Callback, PlayRate, BlendInTime, BlendOutTime, bStopAllMontages, TargetAvatarPartType, bLoop, self.AnimationQueueCounter, bUseBlendTimeDataInAsset)
		else
			AnimComp:QueueAnimation(Param.AnimPath or AnimComp:GetDefaultTimeline(Param.TimelineName), PlayRate, BlendInTime, BlendOutTime, bStopAllMontages, TargetAvatarPartType, bLoop, self.AnimationQueueCounter, bUseBlendTimeDataInAsset)
		end
	end
	AnimComp:PlayQueuedAnimations(self.AnimationQueueCounter)
	return self.AnimationQueueCounter
end

function AnimMgr:IsAnimationQueuePlaying(EntityID, InAnimationQueueID)
	local AnimationQueueID = InAnimationQueueID or 0
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp then
		return AnimComp:IsAnimationQueuePlaying(AnimationQueueID)
	end
end

function AnimMgr:GetCurrentQueueAnimation(EntityID, InAnimationQueueID)
	local AnimationQueueID = InAnimationQueueID or 0
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp then
		return AnimComp:GetCurrentQueueAnimation(AnimationQueueID)
	end
end

function AnimMgr:StopAnimationMulti(EntityID, InAnimationQueueID)
	local AnimationQueueID = InAnimationQueueID or 0
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp == nil then return end
	AnimComp:StopActionTimelineMulti(AnimationQueueID)
end

-- 循环播放一个资产没有设置为循环的ActionTimeline
function AnimMgr:PlayLoopActionTimeline(EntityID, AnimPath, PlayRate, BlendInTime, BlendOutTime, bStopAllMontages)
	local Animations = {
		[1] = {AnimPath = AnimPath, bLoop = true, PlayRate = PlayRate, BlendInTime = BlendInTime, BlendOutTime = BlendOutTime, bStopAllMontages = bStopAllMontages},
	}
	return AnimMgr:PlayAnimationMulti(EntityID, Animations)
end

function AnimMgr:UpdatePlayerAnimParam(Character, PropertyName, Value)
	if nil == Character then
		return
	end
	local AnimComp = Character:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	local AnimInst = AnimComp:GetAnimInstance()
	if nil == AnimInst or nil == AnimInst:Cast(_G.UE.UPlayerAnimInstance) then
		return
	end
	local AnimParam = AnimInst:GetPlayerAnimParam()
	AnimParam[PropertyName] = Value
	AnimInst:UpdatePlayerAnimParam(AnimParam)
end

return AnimMgr