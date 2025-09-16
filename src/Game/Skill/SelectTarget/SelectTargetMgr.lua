--author : haialexzhou
--brief : 选怪管理类，暴露一些接口给外部类调用
-- 选怪流程：
-- 1. 从技能子表获取目标筛选字符串
-- 2. 解析目标筛选字符串
-- a. 如果字符串是纯数字，说明只配了一个ID，遍历视野中所有Target，然后对每个Target执行后面1)， 2)，3)，得到满足条件的List
-- b. 如果字符串不是纯数字（101&102这种，角色选怪基本上不会出现这种情况），通过执行表达式进行字符串拆分，拆分成单个ID，执行a。

-- 每个Target执行以下操作：
-- 1). 判断目标类型
-- 2). 解析命中范围字符串，通过执行布尔表达式得到目标是否在范围中，范围参数,字符串，如长,宽 或 内半径，外半径，角度
-- 3). 通过目标筛选表的条件表达式，对技能条件表执行布尔表达式进行筛选

-- 根据上面得到的List，执行4，（后面如果需要增加一些额外的排序规则，也可以在这里加入），得到最终结果
-- 4). 根据目标筛选表的筛选类型和方法，进行最后一轮筛选和排序

local LuaClass = require("Core/LuaClass")
local ProtoRes = require ("Protocol/ProtoRes")
local MgrBase = require("Common/MgrBase")
local SelectTargetBase = require ("Game/Skill/SelectTarget/SelectTargetBase")
local SelectTargetFilter = require ("Game/Skill/SelectTarget/SelectTargetFilter")
local SelectTargetAreaFilter = require ("Game/Skill/SelectTarget/SelectTargetAreaFilter")
local ActorUtil = require("Utils/ActorUtil")
--技能主表
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ActorManager = _G.UE.UActorManager
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local LSTR = _G.LSTR

local TargetLockType_Hard <const> = _G.UE.ETargetLockType.Hard
local TargetLockType_Weak <const> = _G.UE.ETargetLockType.Weak
local camp_relation_enemy <const> = ProtoRes.camp_relation.camp_relation_enemy

-- --技能表相关----Start--------------------------------------------
-- --技能表关系：技能主表里包含多个子技能，子技能中包含多个目标类型和范围，目标类型中会包含多个技能条件，根据技能条件筛选出列表后，再根据目标筛选表中的筛选类型进行二次筛选（属性值只有类型是属性的情况下才有效）

-- --技能条件表
-- local ResSkillConditionTable = LuaClass()

-- function ResSkillConditionTable:Ctor()
--     self.ID = 0 --条件ID
--     self.Type = ProtoRes.skill_condition_type.SKILL_CONDITION_DISTANCE --条件类型
--     self.Param1 = 0 --条件参数1
--     self.Param2 = 0 --条件参数2
--     self.Sign = ProtoRes.condition_sign.CONDITION_SIGN_EQ --条件比较符号
-- end

-- --技能目标筛选表
-- local ResSkillTargetSelectTable = LuaClass()

-- function ResSkillTargetSelectTable:Ctor()
--     self.ID = 0 --ID
--     self.TargetType = ProtoRes.skill_target_type.SKILL_TARGET_SELF --目标类型：现在拆分为目标阵营+目标类型了
--     self.ConditionExpr = "" --条件表达式字符串，跟目标筛选一样
--     self.SelectType = ProtoRes.skill_condition_type.SKILL_CONDITION_DISTANCE --筛选类型
--     self.SelectFunc = ProtoRes.skill_select_func_type.SKILL_SELECT_FUNC_MAX --筛选方法
--     self.SelectCount = 0 --筛选数量
--     self.Attr = ProtoRes.attr_type.attr_null --属性值
-- end

-- --技能范围表
-- local ResSkillAreaTable = LuaClass()

-- function ResSkillAreaTable:Ctor()
--     self.ID = 0 --ID
--     self.PointType = ProtoRes.skill_point_type.SKILL_POINT_NULL --作用点类型
--     self.HOffset = 0 --作用点水平偏移
--     self.VOffset = 0 --作用点垂直偏移
--     self.DirOffset = 0 --作用点朝向偏移
--     self.AreaType = ProtoRes.skill_area_type.SKILL_AREA_SINGLE --范围类型,如矩形，圆扇形
--     self.AreaParam = "" --范围参数,字符串，如长,宽 或 内半径，外半径，角度
-- end

-- --子技能表
-- local ResSubSkillTable = LuaClass()

-- function ResSubSkillTable:Ctor()
--     self.ID = 0 --ID
-- end

-- --技能表
-- local ResSkillTable = LuaClass()

-- function ResSkillTable:Ctor()
--     self.ID = 0
--     self.Type = ProtoRes.skill_type.SKILL_TYPE_NULL --技能类型
--     self.Class = ProtoRes.skill_class.SKILL_CLASS_NULL --技能类别
-- end

------------------------------------------------------------------end----------------------


---@class SelectTargetMgr : MgrBase
local SelectTargetMgr = LuaClass(MgrBase)
local SelectedTargetList = _G.UE.TArray(_G.UE.uint64)
local TmpVisionActorList = _G.UE.TArray(_G.UE.ABaseCharacter)

function SelectTargetMgr:OnInit()
	self.LastShowTipsTime = nil
	self.DynamicSkillTargets = {}

	--设置项 是否禁止切换目标
	self.bSettingForbidChangeTarget = false

	--相对于主角的阵营关系缓存
	self.CampCache = {}

	--固定你不变的初始化，不用每次选目标都执行的
	SelectTargetBase:Construct()
	SelectTargetAreaFilter:Construct()

	self.ShowTipsTime = 0
end

function SelectTargetMgr:OnBegin()
end

function SelectTargetMgr:OnEnd()
end

function SelectTargetMgr:OnShutdown()
end

function SelectTargetMgr:OnRegisterNetMsg()
end

function SelectTargetMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.Camp_Change_ClearCache, self.OnCampChange)
    self:RegisterGameEvent(EventID.TeamInfoUpdate, self.OnTeamInfoUpdate)
end

function SelectTargetMgr:OnCampChange(Params)
    local EntityID = Params.ULongParam1
    local bMajor = Params.BoolParam1
	if bMajor then
		self.CampCache = {}
		self:CancelSelectTargetActor()
	else
		local SelectedTarget = self:GetCurrSelectedTarget()
		if SelectedTarget then
			local AttrComp = SelectedTarget:GetAttributeComponent()
			if AttrComp and AttrComp.EntityID == EntityID then 
				_G.UE.USelectEffectMgr:Get():UnSelectActor(AttrComp.EntityID)
			end
		end

		self.CampCache[EntityID] = nil
	end
end

function SelectTargetMgr:OnTeamInfoUpdate()
    if not _G.PWorldMgr:CurrIsInDungeon() then
		self.CampCache = {}
		--todo 清理C++测的缓存
	end
end

---释放技能时选目标
---@param SkillID int 技能ID
---@param SubSkillID int 技能子ID
---@param HitIdx int HitList索引
---@param Executor ABaseCharacter 技能释放者
---@param bUseFaultTolerantRange boolean 是否使用容错半径   也兼做锁敌的选目标的判定(false并且HitIdx是1:锁敌  true：非锁敌)
---@param bForbidChangeTarget boolean 是否禁止切换目标
---@param SelectedPos JoyStickParams.Position 选中点（双摇杆手搓技能）
---@param DirAngle JoyStickParams.Angle 朝向角度（双摇杆手搓技能）
---@param bFilterOnly boolean 只筛选出目标，不执行选择
---NeedReSelectTarget 在此Damage执行前，主目标的目标阵营与当前Damage的阵营选择不一致时是否需要重新选目标
function SelectTargetMgr:SelectTargets(SkillID, SubSkillID, HitIdx, Executor,
	bUseFaultTolerantRange, bForbidChangeTarget, SelectedPos, DirAngle, bFilterOnly, bNeedReSelectTarget)

	SelectedTargetList:Clear()
	if not Executor then
		return SelectedTargetList, false, false
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("SelectBaseInit")
		SelectTargetBase:Init(SkillID, SubSkillID, HitIdx, bUseFaultTolerantRange, SelectedPos, DirAngle, bForbidChangeTarget)
	end
	--初始化为主角的位置
	SelectTargetBase.SkillActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)

	local DynamicTargets = self.DynamicSkillTargets[SkillID]
	local bNeedDynamicallySelect = (DynamicTargets and next(DynamicTargets))

	do
		local _ <close> = CommonUtil.MakeProfileTag("SelfGetSkillActors")
		SelectTargetBase:PreProcess(Executor)
	end
	-- C++做第一次初步筛选，得到VisionActorList
	local VisionActorList = self:GetSkillActors(Executor)
		--_G.UE.UActorManager:Get():GetAllActors()
		--self:GetSkillActors(Executor)

	if DynamicTargets then
		for i=1, #DynamicTargets do
			local DynamicTarget = DynamicTargets[i]
			local DynamicActor = ActorUtil.GetActorByResID(DynamicTarget.ResID)
			if DynamicActor then
				VisionActorList:Add(DynamicActor)
			end
		end
	end

	local TargetList, HaveTargetBlocked, HaveFateState
	if bNeedReSelectTarget then
		local USelectEffectMgr = _G.UE.USelectEffectMgr:Get()
		local CurSelectTarget = USelectEffectMgr:GetCurrSelectedTarget()
		if CurSelectTarget then
			local ActorList = {CurSelectTarget}
			TargetList = SelectTargetFilter:CheckSkillTargets(Executor, ActorList)
			if #TargetList == 0 then
				local AttrComp = CurSelectTarget:GetAttributeComponent()
				if AttrComp then 
					USelectEffectMgr:UnSelectActor(AttrComp.EntityID)
					SelectTargetBase.ActionPosMap = {}	--清缓存
					-- FLOG_INFO("pcw UnSelectActor %d", AttrComp.EntityID)
				end

				local ActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
				local VisionActorListTable = VisionActorList:ToTable()
				table.sort(VisionActorListTable, 
					function(Actor1, Actor2) 
						local Dist1 = USelectEffectMgr:GetDistByPos(Executor, Actor1, SelectTargetBase.MaxZDiff, ActionPos)
						local Dist2 = USelectEffectMgr:GetDistByPos(Executor, Actor2, SelectTargetBase.MaxZDiff, ActionPos)
						return Dist1 < Dist2
					end)

				for index = 1, #VisionActorListTable do
					local CurActor = VisionActorListTable[index]
					ActorList = {CurActor}
					TargetList = SelectTargetFilter:CheckSkillTargets(Executor, ActorList)
					if #TargetList > 0 then
						local EntityID = ActorUtil.GetActorEntityID(CurActor)
						
						local EventParams = _G.EventMgr:GetEventParams()
						EventParams.ULongParam1 = EntityID
						EventParams.IntParam2 = TargetLockType_Weak
						_G.EventMgr:SendCppEvent(_G.EventID.SKillSelectTarget, EventParams)

						SelectTargetBase.SelectedTarget = CurActor	--范围检测的时候会用到
						-- FLOG_INFO("pcw UnSelectActor %d", EntityID)
						break
					end
				end
			end
		end
	end

    local ActorCnt = VisionActorList:Length()
	do
		local _ <close> = CommonUtil.MakeProfileTag("FilterTargets-" .. ActorCnt)
		-- 下面做精细复杂的筛选
		TargetList = SelectTargetFilter:FilterTargets(Executor, VisionActorList)
		if bNeedDynamicallySelect then
			local _ <close> = CommonUtil.MakeProfileTag("DynamicallySelect")
			self:DynamicallySelect(Executor, SkillID, VisionActorList, TargetList)
		end
		HaveTargetBlocked = SelectTargetBase.HaveTargetBlocked
		HaveFateState = SelectTargetBase.HaveFateState
		SelectTargetBase:Reset()	--Reset时会对HaveTargetBlocked清空
	end

	if (_G.GMMgr:IsShowDebugTips()) then
		print("SelectTargetMgr TargetList cnt=" .. #TargetList .. "; bUseFaultTolerantRange=" .. tostring(bUseFaultTolerantRange) .. "; bForbidChangeTarget=" .. tostring(bForbidChangeTarget))
		_G.MsgTipsUtil.ShowTips("选中" .. #TargetList .. "个目标")
	end

	local SelecteTargetObjID = 0
	local ExecutorAttributeComponent = Executor:GetAttributeComponent()
	local DynSelectIndex = 0
	-- FLOG_WARNING("yahaha %s %d %d %s", "======", SkillID, SubSkillID, "======")
	for i = 1, #TargetList do
		local AttributeComponent = TargetList[i]:GetAttributeComponent()
		if (AttributeComponent ~= nil) then
			-- FLOG_WARNING("yahaha %s %s %s", AttributeComponent.ActorName, AttributeComponent.ResID, AttributeComponent.EntityID)
			SelectedTargetList:AddUnique(AttributeComponent.EntityID)
			--目标类型为自身的技能不需要切换选中效果
			if ((SelecteTargetObjID == 0)
			and (not bForbidChangeTarget or bNeedDynamicallySelect)
			and (AttributeComponent.EntityID ~= ExecutorAttributeComponent.EntityID)) then
				SelecteTargetObjID = AttributeComponent.EntityID
				DynSelectIndex = i
			end
			--print("SelectTargetMgr Target EntityID=" .. tostring(AttributeComponent.EntityID) .. " target pos=" .. tostring(TargetList[i]:FGetLocation(_G.UE.EXLocationType.ServerLoc)))
		end
	end
	if bNeedDynamicallySelect and DynSelectIndex > 1 then
		SelectedTargetList:Swap(1, DynSelectIndex)
	end

	if (SelecteTargetObjID ~= 0) and not SelectedPos and (bFilterOnly ~= true) then
		self:SkillSelectTarget(SelecteTargetObjID)
	end

	if (_G.GMMgr:IsShowDebugTips()) then
		local Target = nil
		if (SelecteTargetObjID ~= 0) then
			Target = ActorManager:Get():GetActorByEntityID(SelecteTargetObjID)
		end

		if (Target == nil) then
			Target = SelectTargetBase:GetCurrSelectedTarget()
		end

		if (Target ~= nil) then
			if (self.LastShowTipsTime == nil or (self.LastShowTipsTime ~= nil and _G.TimeUtil.GetServerTime() - self.LastShowTipsTime > 1)) then
				local ExecutorPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
				local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
				local ExecutorRadius = SelectTargetBase:GetTargetRadius(Executor)
				local TargetRadius = SelectTargetBase:GetTargetRadius(Target)
				local Distance = SelectTargetBase:GetDistance(ExecutorPos, TargetPos, ExecutorRadius, TargetRadius)
				local DistanceTips = "距离目标：" .. string.format("%.1f", Distance/100) .. "米"
				_G.MsgTipsUtil.ShowTips(DistanceTips)
				self.LastShowTipsTime = _G.TimeUtil.GetServerTime()
			end
		end
	end

	--HaveTargetBlocked：是否有Target因为技能阻挡被剔除掉； 主要用于目标数量为0时提示 “看不见目标”
    return SelectedTargetList, HaveTargetBlocked, HaveFateState
end

--C++释放技能的时候调用
function SelectTargetMgr:CppCastSkillSelectTargets(SkillID, SubSkillID, HitIdx, Executor, bUseFaultTolerantRange, bForbidChangeTarget, SelectedPos, DirAngle)
	local SelectedTargetList, HaveTargetBlocked, HaveFateState =
		 self:SelectTargets(SkillID, SubSkillID, HitIdx, Executor, bUseFaultTolerantRange, bForbidChangeTarget, SelectedPos, DirAngle)
	
	local CanCastSkill = true

	local SubSkillCfg = SelectTargetBase:GetResSubSkill(SubSkillID)
	--是否可以空放
	local IsCanCastSkill = false
	if SubSkillCfg then
		IsCanCastSkill = SubSkillCfg.IsCastWithoutTarget
		local TargetCnt = SelectedTargetList:Length()
		if IsCanCastSkill == 0 and TargetCnt == 0 then
			CanCastSkill = false

			if HaveFateState then
				_G.FateMgr:TryShowAttackMentionTips()
				
				return SelectedTargetList, CanCastSkill
			end

			if HaveTargetBlocked then
				MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillCannotSeeTarget)--106025重复，废弃吧
				return SelectedTargetList, CanCastSkill
			end

			local CurTime = _G.TimeUtil.GetLocalTimeMS()
			if CurTime - self.ShowTipsTime > 2000 then
				self.ShowTipsTime = CurTime
				MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillNoTargetOrFar)-- 没有有效目标或目标距离过远	106026
				return SelectedTargetList, CanCastSkill
			end
		end
		
		local USelectEffectMgr = _G.UE.USelectEffectMgr:Get()
		local TargetLockType = USelectEffectMgr:GetCurrSelectedTargetLockType()
		if TargetLockType == _G.UE.ETargetLockType.Hard and IsCanCastSkill == 0 then
			if TargetCnt > 0 then
				local SelectedTargetEntityID = SelectedTargetList:Get(1)
				local SelectedTarget = ActorUtil.GetActorByEntityID(SelectedTargetEntityID)
				if SelectedTarget and SelectedTarget:GetActorType() ~= _G.UE.EActorType.Major then
					local CurLockTarget = USelectEffectMgr:GetCurrSelectedTarget()
					local CampRelation = SelectTargetBase:GetCampRelation(CurLockTarget, SelectedTarget)
					if CurLockTarget ~= SelectedTarget and CampRelation ~= ProtoRes.camp_relation.camp_relation_enemy then
						CanCastSkill = false
						_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillNoTargetOrFar)-- 没有有效目标或目标距离过远
						return SelectedTargetList, CanCastSkill
					end
				end
			end
		end
	else
		CanCastSkill = false
		_G.FLOG_ERROR("SelectTargets SubSkillID is nil:%d", SubSkillID)
	end

	return SelectedTargetList, CanCastSkill
end

local GetActorByEntityID = _G.UE.UActorUtil.GetActorByEntityID

function SelectTargetMgr:SkillSelectTarget(SelecteTargetObjID)
	if SelecteTargetObjID and SelecteTargetObjID > 0 then

		local CurrLockTarget, CurrTargetLockType = SelectTargetBase:GetCurrSelectedTarget()  --当前选中的目标
		if CurrTargetLockType == TargetLockType_Hard then
			local InSelectedTarget = GetActorByEntityID(SelecteTargetObjID)
			if SelectTargetBase:GetCampRelation(CurrLockTarget, InSelectedTarget) ~= camp_relation_enemy then
				return
			end
		end

		local function DelaySendEvent()
			local _ <close> = CommonUtil.MakeProfileTag("EventSKillSelectTarget")
			local EventParams = _G.EventMgr:GetEventParams()
			EventParams.ULongParam1 = SelecteTargetObjID
			EventParams.IntParam2 = TargetLockType_Weak
			_G.EventMgr:SendCppEvent(_G.EventID.SKillSelectTarget, EventParams)
		end
	
		_G.TimerMgr:AddTimer(nil, DelaySendEvent, 0, 1, 1)
	end
end

--是否需要追敌
function SelectTargetMgr:IsNeedMoveToTarget(SkillID, SubSkillID, HitIdx, Executor)
    local ResSubSkill = SelectTargetBase:GetResSubSkill(SubSkillID)
	if (ResSubSkill == nil) then
		return false
	end

	--追敌半径
	local LockRadius = ResSubSkill.LockRadius
	local AreaExpressionStr = SelectTargetBase:GetSkillHitAreaStr(SubSkillID, HitIdx)
	local AreaID = tonumber(AreaExpressionStr) --不支持范围ID表达式
	if (AreaID == nil) then
		return false
	end
	local ResSkillArea = SelectTargetBase:GetResSkillArea(AreaID)
	if (ResSkillArea == nil) then
		return false
	end

	--作用点是自己不追敌
	if (ResSkillArea.PointType == ProtoRes.skill_point_type.SKILL_POINT_SELF) then
		return false
	end
	--单体范围的技能才追敌
	if (ResSkillArea.AreaType == ProtoRes.skill_area_type.SKILL_AREA_SINGLE) then
		local AttackDistance = tonumber(ResSkillArea.AreaParamStr)
		if (AttackDistance == nil or AttackDistance == 0) then
			return false
		end
		local MoveToTarget = nil
		--todo 当前选中的怪如果在攻击范围内，则不需要重新选怪
		local CurrSelectedTarget = nil
		if (CurrSelectedTarget ~= nil and SelectTargetFilter:CheckTargetIsConformTargetType(Executor, CurrSelectedTarget, SubSkillID) ) then
			--local Distance = math.abs(_G.UE.FVector:Distance(Executor:GetPosition(), CurrSelectedActor:GetPosition()))
			local Distance = 0 --todo
			--在技能攻击范围和锁敌范围之间
			if (Distance > AttackDistance and Distance < LockRadius) then
				--todo 需要增加判断路径可通的判断
				MoveToTarget = CurrSelectedTarget
			elseif (Distance < AttackDistance) then
				--不能直线到达
				--if (not CanArriveInLine) then
				--	MoveToTarget = CurrSelectedTarget
				--end
			end
		end

		if (CurrSelectedTarget == nil) then
			local TargetList = self:SelectTargets(SkillID, SubSkillID, HitIdx, Executor)
			for _, Target in ipairs(TargetList) do
				local Distance = 0 --todo
				if (Distance < AttackDistance) then
					--不能直线到达
					--if (not CanArriveInLine) then
					--	MoveToTarget = Target
					--end
					break
				end

				if (Distance > AttackDistance and Distance < LockRadius) then
					--todo 需要增加判断路径可通的判断
					MoveToTarget = Target
				end
			end
		end

		if (MoveToTarget ~= nil) then
			--移动到Target，Target身上显示选中特效等

			return true
		end
	end

	return false
end

--目标是否能被选中   c++过来的，不是技能的目标判定
function SelectTargetMgr:IsCanBeSelect(Target, IsSkillSelect)
	return SelectTargetBase:IsCanBeSelect(Target, IsSkillSelect)
end

--当前选中的目标
function SelectTargetMgr:GetCurrSelectedTarget()
	return SelectTargetBase:GetCurrSelectedTarget()
end

---给技能添加可选中的目标
function SelectTargetMgr:AddSkillTargetByResID(SkillID, ActorType, ResID)
	self.DynamicSkillTargets[SkillID] = self.DynamicSkillTargets[SkillID] or {}
	local Targets = self.DynamicSkillTargets[SkillID]
	local TargetInfo = {
		ActorType = ActorType,
		ResID = ResID,
	}
	table.insert(Targets, TargetInfo)
end

---给技能移除可选中的目标
function SelectTargetMgr:RemoveSkillTargetByResID(SkillID, ActorType, ResID)
	local Targets = self.DynamicSkillTargets[SkillID]
	if Targets == nil then return end

	for i = #Targets, 1, -1 do
		local TargetInfo = Targets[i]
		if (TargetInfo.ActorType == ActorType) and (TargetInfo.ResID == ResID) then
			table.remove(Targets, i)
		end
	end

	if next(Targets) == nil then
		self.DynamicSkillTargets[SkillID] = nil
	end
end

---任务使用物品，判定目标是否满足技能条件
---@param ActorList 传入的目标EntityID
---@param SkillID int 技能ID
---@param Executor ABaseCharacter 技能释放者
function SelectTargetMgr:CheckTaskUseItemTargets(ActorList, SkillID, Executor)
	local _ <close> = CommonUtil.MakeProfileTag("TaskSelectBaseInit")

    local IDList = SkillMainCfg:GetSkillIdList(SkillID)
    if IDList == nil or IDList[1] == nil then
        return {}
    end
	
	local SubSkillID = IDList[1].ID
    SelectTargetBase:Init(SkillID, SubSkillID, 1, false, nil, nil, true)
	--初始化为主角的位置
	SelectTargetBase.SkillActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)

	local TargetList = SelectTargetFilter:CheckTaskUseItemTargets(Executor, ActorList)
	SelectTargetBase:Reset()	--Reset时会对HaveTargetBlocked清空

    return TargetList
end

--------------------------------------- private begin ---------------------------------------
-- 做第一次初步筛选
-- 1、技能目标是主人、自身的则可以直接确定；跳过下面的过程
-- 2、如果配置了范围，则根据技能的施法位置ActionPos，按52米半径的圆形范围，调用GetSkillActors获得技能目标actor
-- 3、如果没配置范围，就取施法者周围20米半径圆形范围 ，调用GetSkillActors获得技能目标actor

-- 4、ActorManager的GetSkillActors除了做圆形范围的过滤，还会做些其他简单固定的过滤（比如技能target类型、z坐标差的判定等）
-- 4.1、距离相关：a、圆形范围之外的忽略           b、z差值大于SelectTargetBase.MaxZDiff的忽略
-- 4.2、能否选择：a、如果不是玩家，死亡状态的忽略  b、如果是怪物并且bIsForbidSelect禁止选择的忽略  c、技能不可选中的忽略
-- 4.3、技能目标：如果传给c++的参数是0，c++则忽略这些判定
		-- a、召唤物：如果Owner不是技能释放者的忽略
		-- b、敌对：首先排除掉自己； 固定的静态阵营并且阵营和施法者相同的同阵营actor忽略；   是玩家并且是队友的忽略；    施法者的召唤物忽略；   施法者的主人忽略；
		-- c、友好、自身和友好：固定的静态阵营并且阵营和施法者不同的actor忽略；    不是相同静态阵营的monster忽略
		--注：b/c这里对于npc的处理还没加（npc后期也可以参与战斗，等后续需求确定了再加上，这样又可以降低些数量）
-- 注：如果c++代码有问题，并且需要热更，可以切换到lua代码回来
		--a、如果是4.2 想屏蔽，调用GetSkillActors时，IgnoreRule传入true即可
		--b、如果是4.3 技能目标有热更需要，调用GetSkillActors时，可以将技能目标直接改为0，这样c++就不做这些过滤了
		--c、如果完全不要c++过滤，则可以从GetSkillActors切换到GetAllActors，返回最初那样，得到视野内所有的actor

function SelectTargetMgr:GetSkillActors(Executor, bIgnoreRule)
	-- local VisionActorList = _G.UE.TArray(_G.UE.ABaseCharacter)

	-- 技能目标类型
	local RelationType = 0
	local TargetType = 0

	local ConditionStr
	do
		local _ <close> = CommonUtil.MakeProfileTag("ConditionStr")
		-- 1、技能目标是主人、自身的则可以直接确定；跳过下面的过程
		-- 这里也只能处理没有使用&|，以及/的，因为这里不能决定最终的；  大部分是只配置一个的
		--local ConditionStr, bDB = SelectTargetBase:GetSkillHitTargetConditionStr()
		ConditionStr = SelectTargetBase:GetSkillHitTargetConditionStr()
	end
    if (ConditionStr ~= "" and ConditionStr ~= nil) then
        local SelectID = tonumber(ConditionStr)
        --只处理 配的纯数字的情况，如果使用了逆波兰式的，则跳过；    目前只配置了1个id
        if (SelectID) then
			local ResSkillTargetSelect
			do
				local _ <close> = CommonUtil.MakeProfileTag("TargetSelect")
				ResSkillTargetSelect = SelectTargetBase:GetResSkillTargetSelect(SelectID)
			end
			if (nil == ResSkillTargetSelect) then
				TmpVisionActorList:Clear()
				return TmpVisionActorList
			end

			--只有技能目标是 主人、自身 这2种的才可以快速判定（只有确定的1个目标），其余都不行（召唤物都不行，因为施法者可以召唤多个召唤物）
			TargetType = ResSkillTargetSelect.SkillTargetType
			RelationType = ResSkillTargetSelect.SkillRelationType
			--自身：忽略目标类型
			if (RelationType == ProtoRes.skill_relation_type.SKILL_RELATION_SELF) then
				TmpVisionActorList:Clear()
				TmpVisionActorList:Add(Executor)
				return TmpVisionActorList
			--主人：忽略目标阵营
			elseif (TargetType == ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_MASTER) then
				local OwnerAttrComponent = Executor:GetAttributeComponent()
				if OwnerAttrComponent then
					local OwnerActor = ActorUtil.GetActorByEntityID(OwnerAttrComponent.Owner)
					if OwnerActor then
						TmpVisionActorList:Clear()
						TmpVisionActorList:Add(OwnerActor)
					end
				end

				return TmpVisionActorList
			end
		end
	end

	local Radius, ActionPos, AreaExpressionStr
	do
		local _ <close> = CommonUtil.MakeProfileTag("HitAreaStr")
		Radius = 5200
		ActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
		AreaExpressionStr = SelectTargetBase:GetSkillHitAreaStr()
	end

	-- 2、如果配置了范围，则根据技能的施法位置ActionPos，按52米半径的圆形范围，调用GetSkillActors获得技能目标actor
	if AreaExpressionStr ~= nil then
		local AreaID = tonumber(AreaExpressionStr) --不支持范围ID表达式    基本上没用逆波兰式，只配置了1个id
		if (AreaID) then
			local ResSkillArea
			do
				local _ <close> = CommonUtil.MakeProfileTag("GetResSkillArea")
				ResSkillArea = SelectTargetBase:GetResSkillArea(AreaID)
			end
			if ResSkillArea then
				-- 获取施法位置
				local _ <close> = CommonUtil.MakeProfileTag("GetActionPos")
				ActionPos = SelectTargetAreaFilter:GetSkillActionPos(ResSkillArea, Executor)
			end
		else
			-- 如果使用了逆波兰式，就取施法者周围110米半径圆形范围的;   目前没有这种配置
			Radius = 11000
		end
	else
		-- 3、如果没配置范围，就取施法者周围20米半径圆形范围 ，调用GetSkillActors获得技能目标actor
		Radius = 2000
	end

	local _ <close> = CommonUtil.MakeProfileTag("GetSkillActors")
	-- 4、ActorManager的GetSkillActors除了做圆形范围的过滤，还会做些其他简单固定的过滤（比如技能target类型、z坐标差的判定等）
	local VisionActorList = ActorManager:Get():GetSkillActors(
		Executor, RelationType, TargetType, ActionPos, Radius, SelectTargetBase.MaxZDiff, bIgnoreRule or false)

	return VisionActorList
end

function SelectTargetMgr:DynamicallySelect(Executor, SkillID, VisionActorList, TargetList)
	local DynamicTargets = self.DynamicSkillTargets[SkillID]
	if not (DynamicTargets and next(DynamicTargets)) then return end

	local CurrSelectedTarget = SelectTargetBase:GetCurrSelectedTarget()
	if CurrSelectedTarget ~= nil then
		for _, Target in ipairs(TargetList) do
			if Target == CurrSelectedTarget then
				_G.TableTools.ClearTable(TargetList)
				table.insert(TargetList, CurrSelectedTarget)
				return
			end
		end
	end

	-- 目标是否已筛选出来
	for _, Target in ipairs(TargetList) do
		local AttrComp = Target:GetAttributeComponent()
		if AttrComp then
			for _, TargetInfo in ipairs(DynamicTargets) do
				if (TargetInfo.ActorType == AttrComp.ActorType) and (TargetInfo.ResID == AttrComp.ResID) then
					return
				end
			end
		end
	end

	local function CalcDist(Target)
		local ActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
		local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
		local ExecutorRadius = SelectTargetBase:GetTargetRadius(Executor)
		local TargetRadius = SelectTargetBase:GetTargetRadius(Target)
		local Dist = SelectTargetBase:GetDistance(ActionPos, TargetPos, ExecutorRadius, TargetRadius)
		return (Dist > 0) and Dist or 0
	end

	local ActorCnt = VisionActorList:Length()
	local DynamicTargetList = {}

	-- 目标是否在技能伤害范围内
	for i = 1, ActorCnt do
		local Target = VisionActorList:Get(i)
		local ActorType = Target:GetActorType()
		local ResID = Target:GetActorResID()
		for _, TargetInfo in ipairs(DynamicTargets) do
			if (TargetInfo.ActorType == ActorType) and (TargetInfo.ResID == ResID) then
				local Dist = CalcDist(Target)
				if Dist < 1000 -- 强制距离判断，避免技能选择逻辑选出远处目标
				and SelectTargetAreaFilter:TargetIsInArea(Executor, Target) then
					table.insert(DynamicTargetList, { Target = Target, Dist = Dist })
				end
				break
			end
		end
	end
	if next(DynamicTargetList) == nil then return end

	table.sort(DynamicTargetList, function(v1, v2) return v1.Dist < v2.Dist end)

	-- 下面这种方式会优先选择EObj，在EObj和怪物放一起的时候可能总是打不到怪
	-- 但怪物的排序不止距离一项因素，也不好强行按距离给怪物排序，以后碰到问题再回顾这段排序逻辑
	local MinTargetDist = 1999999999
	for _, Target in ipairs(TargetList) do
		local TargetDist = CalcDist(Target)
		if (TargetDist < MinTargetDist) then
			MinTargetDist = TargetDist
		end
	end
	for _, TargetInfo in ipairs(DynamicTargetList) do
		if TargetInfo.Dist > MinTargetDist then
			table.insert(TargetList, TargetInfo.Target)
		else
			table.insert(TargetList, 1, TargetInfo.Target)
		end
	end
end

--取消场景中已选中的对象
function SelectTargetMgr:CancelSelectTargetActor()
	local SelectedTarget = self:GetCurrSelectedTarget()
	if SelectedTarget then
		local AttrComp = SelectedTarget:GetAttributeComponent()
		if AttrComp then 
			_G.UE.USelectEffectMgr:Get():UnSelectActor(AttrComp.EntityID)
		end
	end
end

--------------------------------------- private end ---------------------------------------

return SelectTargetMgr