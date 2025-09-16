--author : haialexzhou
--brief : 通过按钮手动切换目标

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SelectTargetBase = require ("Game/Skill/SelectTarget/SelectTargetBase")
local ProtoRes = require("Protocol/ProtoRes")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorManager = _G.UE.UActorManager
local CommonDefine = require("Define/CommonDefine")
local UIUtil = require("Utils/UIUtil")

local SummonCfg = require("TableCfg/SummonCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local EActorType = _G.UE.EActorType
local TargetLockType_Hard <const> = _G.UE.ETargetLockType.Hard
local TargetLockType_Weak <const> = _G.UE.ETargetLockType.Weak

--切目标优先级类型
SwitchTargetPriorityType =
{
	SwitchTargetPriority_FarToNear = 0, --由远到近
	SwitchTargetPriority_NearToFar = 1, --由近到远
	SwitchTargetPriority_HP = 2,		--生命由低到高
	SwitchTargetPriority_Enmity = 3,	--仇恨：1仇(4)，我的队友1仇(3)，有仇恨（但1仇恨不是我和我队友 ）(2)，没仇恨(0)
}

--切目标切换类型
SwitchTargetSwitchType =
{
	SwitchTargetSwitchType_All = 0, --目标视野内所有
	SwitchTargetSwitchType_Sector = 1 --目标视野内指定角度扇形区域
}

--切怪目标单元
local SwitchTargetUnit = LuaClass()

function SwitchTargetUnit:Ctor()
	self.TargetID = 0
	self.HP = 0
	self.Distance = 0
	self.bHasSelected = 0
end

--当前可被切换的目标单元列表
local CurrCanSwitchTargetUnitList = {}
--最近选择的优先级类型
local RecentlyPriorityType = SwitchTargetPriorityType.SwitchTargetPriority_NearToFar
--最近选择的切换类型
local RecentlySwitchType = SwitchTargetSwitchType.SwitchTargetSwitchType_Sector
--最近选择的目标ID
local RecentlySelectedTargetID = 0
--最近执行切换目标所在的地图ID
local RecentlyMapResID = 0

--切怪半径, 比MAX_SELECTED_DISTANCE值小一些，否则选中圈无法显示
local SwitchRadius = CommonDefine.SwitchTarget.SwitchRadius
local SwitchRadiusSquared = SwitchRadius * SwitchRadius
local MaxZDiff = CommonDefine.SwitchTarget.MaxZDiff
--扇形角度
local SectorAngle = CommonDefine.SwitchTarget.SwitchRagle

local function GetEnmityValue(MajorEntityID, Target, TargetID)
	local EnmityValue = 0	--仇恨：1仇(4)，我的队友1仇(3)，有仇恨（但1仇恨不是我和我队友 ）(2)，没仇恨(0)
	local FirstEnmityEntityID = _G.TargetMgr:GetFirstTargetOfMonster(TargetID)
	if FirstEnmityEntityID > 0 then
		if FirstEnmityEntityID == MajorEntityID then
			EnmityValue = 4
		elseif SelectTargetBase:IsTeamMember(Target) then
			EnmityValue = 3
		else
			EnmityValue = 2
		end
	end

	return EnmityValue
end

local function GenerateTargetUnitList(Executor, VisionActorList)
	if (VisionActorList == nil or Executor == nil) then
		return
	end
	local ExecutorPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local ActorCnt = VisionActorList:Length()

	local Major = MajorUtil.GetMajor()
	local CameraRotation = Major:GetCameraBoomRelativeRotation()

	local ScreenSize = UIUtil.GetViewportSize()
	local ScreenLocation = _G.UE.FVector2D()
	-- print(" ==== pcw ScreenSize ==== ".. ScreenSize.X ..","..ScreenSize.Y)
	local MajorEntityID = Major and Major:GetActorEntityID() or 0

    for i = 1, ActorCnt, 1 do
		local Target = VisionActorList:Get(i)
		local IsContinue = true
		if (Target == Executor) then
			IsContinue = false
		end

		--采集物过滤掉
		local ActorType = Target:GetActorType()
		if ActorType == _G.UE.EActorType.Gather
			or ActorType == _G.UE.EActorType.EObj
			or ActorType == _G.UE.EActorType.Summon
			or ActorType == _G.UE.EActorType.ClientShow then
			IsContinue = false
		--过滤掉交互物
		end

		if (IsContinue) then
			IsContinue = SelectTargetBase:IsCanBeSelect(Target, false)
		end

		if IsContinue then
			--是否是敌对的camp_relation_enemy
			IsContinue = SelectTargetBase:IsCanBeAttack(Executor, Target)
		end

		if (IsContinue) then
			local IsInSector = true
			local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)

			-- if (RecentlySwitchType == SwitchTargetSwitchType.SwitchTargetSwitchType_Sector and (SectorAngle % 360 ~= 0) ) then
			-- 	local Rotator = Executor:K2_GetActorRotation()
			-- 	local ExecutorForward = Rotator:GetForwardVector() --释放技能时玩家的朝向
			-- 	local WithTargetDir = TargetPos - ExecutorPos
			-- 	local CosValue2D = ExecutorForward:CosineAngle2D(WithTargetDir)
			-- 	local AngleForTarget = SelectTargetBase:DegAcos(CosValue2D)

			-- 	--判断Executor跟Target之间的夹角是否小于扇形角度的二分之一
			-- 	if (AngleForTarget > (SectorAngle * 0.5)) then
			-- 		IsInSector  = false
			-- 	end
			-- end

			local Distance = ExecutorPos:DistSquared2D(TargetPos)
			local AttrComponent = Target:GetAttributeComponent()
			if (AttrComponent ~= nil) then
				--过滤掉交互物
				if ActorType == _G.UE.EActorType.NPC and SelectTargetBase:GetNpcType(AttrComponent.ResID) == ProtoRes.NPC_TYPE.INTERACTOBJ then
					IsContinue = false
				end
			end

			if IsContinue and AttrComponent then
				local TargetID = AttrComponent.EntityID

				UIUtil.ProjectWorldLocationToScreen(TargetPos, ScreenLocation)   --获取人物头顶世界位置转为屏幕位置
				-- print(" ==== pcw ScreenLocation ==== ID:" , TargetID , ", ", ScreenLocation.X ..","..ScreenLocation.Y)
				if ScreenLocation.X < 0 or ScreenLocation.Y < 0
					or ScreenLocation.Y > ScreenSize.Y or ScreenLocation.X > ScreenSize.X then
					IsInSector = false
				end

				if (IsInSector and Distance < SwitchRadiusSquared) then
					local HP = AttrComponent:GetCurHp()
					local TargetUnit = nil
					for _, TargetUnitTemp in ipairs(CurrCanSwitchTargetUnitList) do
						if (TargetUnitTemp.TargetID == TargetID) then
							TargetUnit = TargetUnitTemp
							break
						end
					end

					if (TargetUnit == nil) then
						TargetUnit = SwitchTargetUnit.New()
						TargetUnit.TargetID = TargetID
						TargetUnit.HP = HP
						TargetUnit.Distance = Distance
						TargetUnit.bHasSelected = false
						TargetUnit.EnmityValue = GetEnmityValue(MajorEntityID, Target, TargetID)

						table.insert(CurrCanSwitchTargetUnitList, TargetUnit)
					else
						TargetUnit.HP = HP
						TargetUnit.Distance = Distance
						TargetUnit.EnmityValue = GetEnmityValue(MajorEntityID, Target, TargetID)
					end

					-- 在这里判定，增加没必要开销
					-- if ActorUtil.CheckBlock(Executor, Target) then
					-- 	TargetUnit.SkillBlock = true
					-- else
					-- 	TargetUnit.SkillBlock = false
					-- end
				else
					for i, TargetUnitTemp in ipairs(CurrCanSwitchTargetUnitList) do
						if (TargetUnitTemp.TargetID == TargetID) then
							table.remove(CurrCanSwitchTargetUnitList, i)
							break
						end
					end

				end
			end
		end

	end

	table.sort(CurrCanSwitchTargetUnitList, function(TargetA, TargetB)
		if (RecentlyPriorityType == SwitchTargetPriorityType.SwitchTargetPriority_FarToNear) then
			return TargetA.Distance > TargetB.Distance
		elseif (RecentlyPriorityType == SwitchTargetPriorityType.SwitchTargetPriority_NearToFar) then
			return TargetA.Distance < TargetB.Distance
		elseif (RecentlyPriorityType == SwitchTargetPriorityType.SwitchTargetPriority_Enmity) then
			return TargetA.EnmityValue > TargetB.EnmityValue
		else
			return TargetA.HP < TargetB.HP
		end
	end)
end

local function ResetTargetUnitsState()
	for _, TargetUnit in ipairs(CurrCanSwitchTargetUnitList) do
		TargetUnit.bHasSelected = false
	end
end

local function ResetTargetSkillBlockState()
	for _, TargetUnit in ipairs(CurrCanSwitchTargetUnitList) do
		TargetUnit.SkillBlock = false
	end
end

local function ResetSelectedTargetUnitState(TargetID)
	for _, TargetUnit in ipairs(CurrCanSwitchTargetUnitList) do
		if (TargetUnit.TargetID == TargetID) then
			TargetUnit.bHasSelected = false
		end
	end
end

local USelectEffectMgr
local function GetCanSwitchTargetUnit()
	local Major = MajorUtil.GetMajor()
	if not USelectEffectMgr then
		USelectEffectMgr = _G.UE.USelectEffectMgr.Get()
	end
	local CurrSelectedTarget = USelectEffectMgr:GetCurrSelectedTarget()
	local CurrSelectedTargetID = nil
	if CurrSelectedTarget then
		CurrSelectedTargetID = CurrSelectedTarget.AttributeCom.EntityID
	end
	for _, TargetUnit in ipairs(CurrCanSwitchTargetUnitList) do
		local TargetID = TargetUnit.TargetID
		if TargetID == CurrSelectedTargetID then
			TargetUnit.bHasSelected = true
		elseif (not TargetUnit.bHasSelected and not TargetUnit.SkillBlock) then
			--这里不确定什么类型的技能，按主角位置和目标进行检测
			if ActorUtil.IsDeadState(TargetID) then
				goto continue
			end
			local TargetActor = ActorUtil.GetActorByEntityID(TargetID)
			if not TargetActor then
				goto continue
			end

			if ActorUtil.CheckBlock(Major, TargetActor) then
				return TargetUnit
			else
				local CampRelation = SelectTargetBase:GetCampRelationByMajor(Major, TargetActor)
				if CampRelation == ProtoRes.camp_relation.camp_relation_enemy then
					TargetUnit.SkillBlock = true
				else
					return TargetUnit
				end
			end
		end
		::continue::
	end

	return nil
end

--处理选择的结果
local function ProcessSwitchResult(TargetID, bUseWeakLock)
	if (TargetID ~= 0) then
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.ULongParam1 = TargetID
		EventParams.IntParam2 = bUseWeakLock and TargetLockType_Weak or TargetLockType_Hard
		_G.EventMgr:SendCppEvent(_G.EventID.SKillSelectTarget, EventParams)
		_G.EventMgr:SendEvent(_G.EventID.SelectMonsterIndex, TargetID)
	end

	RecentlySelectedTargetID = TargetID
end

local function ExecuteSwitch(AllowRecursion)
	local TargetUnit = GetCanSwitchTargetUnit()
	if (TargetUnit ~= nil) then
		TargetUnit.bHasSelected = true
		ProcessSwitchResult(TargetUnit.TargetID)
	else
		--没有未被选择的目标，重置状态
		ResetTargetUnitsState()

		if (AllowRecursion) then
			ExecuteSwitch(false) --防止出异常导致栈溢出
		end
	end
end


local SwitchTarget = LuaClass(MgrBase)

function SwitchTarget:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ManualSelectTarget, self.OnInputSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)
end

function SwitchTarget:OnGameEventUnSelectTarget(Params)
	RecentlySelectedTargetID = 0
	ResetTargetUnitsState()
end

function SwitchTarget:OnInputSelectTarget(Params)
	if (Params ~= nil and Params.ULongParam1 ~= nil and Params.ULongParam1 > 0) then
		if (RecentlySelectedTargetID ~= Params.ULongParam1) then
			ResetSelectedTargetUnitState(RecentlySelectedTargetID)
		end
	end
end

function SwitchTarget:SetSwitchType(Index)
	if Index == 2 then
		RecentlyPriorityType = SwitchTargetPriorityType.SwitchTargetPriority_HP
	elseif Index == 3 then
		RecentlyPriorityType = SwitchTargetPriorityType.SwitchTargetPriority_Enmity
	else
		RecentlyPriorityType = SwitchTargetPriorityType.SwitchTargetPriority_NearToFar
	end
end

--手动切目标
function SwitchTarget:SwitchTargets(Executor)
	if not Executor then
		return
	end
	
	-- local PriorityType = SwitchTargetPriorityType.SwitchTargetPriority_NearToFar
	local SwitchType = SwitchTargetSwitchType.SwitchTargetSwitchType_Sector

	if (SwitchType ~= RecentlySwitchType
	    or (_G.PWorldMgr.BaseInfo ~= nil and RecentlyMapResID ~= _G.PWorldMgr.BaseInfo.CurrMapResID) )then
		RecentlySelectedTargetID = 0
		_G.TableTools.ClearTable(CurrCanSwitchTargetUnitList)
		-- RecentlyPriorityType = PriorityType
		RecentlySwitchType = SwitchType
		RecentlyMapResID = _G.PWorldMgr.BaseInfo.CurrMapResID
	end

	-- local VisionActorList = ActorManager:Get():GetAllActors()

	local ExecutorPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local VisionActorList = ActorManager:Get():GetSkillActors(Executor
		, ProtoRes.skill_relation_type.SKILL_RELATION_ENEMY
		, ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_ALL
		, ExecutorPos, SwitchRadius, MaxZDiff, false)

	GenerateTargetUnitList(Executor, VisionActorList)

	--清理技能阻挡的记录（这个是动态变化的），所以每次切换的时候优先清空下
	ResetTargetSkillBlockState()

	ExecuteSwitch(true)
end

---@param bUseWeakLock bool 默认false使用强锁, 传true则使用弱锁
function SwitchTarget:SwitchToTarget(EntityID, bUseWeakLock)
	ProcessSwitchResult(EntityID, bUseWeakLock)
end

---@param bUseWeakLock bool 默认false使用强锁, 传true则使用弱锁
function SwitchTarget:ManualSwitchToTarget(EntityID, IsCameraResume, bUseWeakLock)
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = EntityID
	EventParams.BoolParam2 = IsCameraResume
	EventParams.IntParam2 = bUseWeakLock and TargetLockType_Weak or TargetLockType_Hard
    _G.EventMgr:SendCppEvent(_G.EventID.ManualSelectTarget, EventParams)
	_G.EventMgr:SendEvent(_G.EventID.ManualSelectTarget, EventParams)
end

--是否可以点选的判定，从c++挪到lua，并新加功能
--自己give的召唤兽，并且可选才会可选；  别人的都不可选中
--然后就是只能选敌对目标的

function SwitchTarget:CheckCanClickSelect(FromActor, TargetActor)
	if FromActor and TargetActor then
		if _G.PhotoMgr.IsOnPhoto then
			return self:CheckCanClickSelectPhoto(FromActor, TargetActor)
		else
			return self:CheckCanClickSelectGame(FromActor, TargetActor)
		end
	end

	return false
end

function SwitchTarget:CheckCanClickSelectPhoto(FromActor, TargetActor)
	local MajorEntityID = MajorUtil.GetMajorEntityID()

	if ActorUtil.GetActorEntityID(TargetActor) == MajorEntityID then
		return true
	end

	return false
end

function SwitchTarget:CheckCanClickSelectGame(FromActor, TargetActor)
	if (MajorUtil.IsGatherProf() and _G.GatherMgr.IsGathering) or (MajorUtil.IsCrafterProf() and _G.CrafterMgr:GetIsMaking()) then
		return false
	end

	--演奏状态不能选中任何目标对象
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local StateComp = ActorUtil.GetActorStateComponent(MajorEntityID)
	if StateComp then
		if StateComp:IsInNetState(ProtoCommon.CommStatID.CommStatPerform) then
			return false
		end
	end

	local TargetType = TargetActor:GetActorType()

	if EActorType.Npc == TargetType then
		-- 点击NPC时输出NPC相关信息，方便策划配表
		--local AttributeComp = TargetActor:GetAttributeComponent()
		local NpcID = TargetActor:GetActorResID()
		local Cfg = NpcCfg:FindCfgByKey(NpcID)
		--_G.FLOG_INFO("[SwitchTarget:CheckCanClickSelect] click NpcID=%s, ListID=%d, Name=%s, Title=%s, Pos(%s)", NpcID, AttributeComp.ListID, Cfg.Name, Cfg.Title, TargetActor:FGetActorLocation())
		if nil == Cfg or string.isnilorempty(Cfg.Name) then
			return false
		end
	end

	if EActorType.Gather == TargetType then
		return false
	end

	if EActorType.ClientShow == TargetType then
		return false
	end

	if EActorType.Summon == TargetType then
		--自己give的召唤兽，并且可选才会可选；  别人的都不可选中
		local SummonActor = TargetActor:Cast(_G.UE.ASummonCharacter)
		if SummonActor then
			if SummonActor:GetOwnerEntityID() == MajorUtil.GetMajorEntityID() then
				local Cfg = SummonCfg:FindCfgByKey(SummonActor:GetActorResID())
				if Cfg and Cfg.IsCanSelect == 1 then
					return true
				end
			end
		end

		return false
	else
		if SelectTargetBase:IsForbidSelect(TargetActor, TargetType) then
			return false
		end

		local Relation = SelectTargetBase:GetCampRelationByMajor(FromActor, TargetActor)
		if ProtoRes.camp_relation.camp_relation_enemy == Relation then
			if not ActorUtil.CheckBlock(FromActor, TargetActor) then --阻挡了
				return false
			end
		end
	end

	return true
end

return SwitchTarget