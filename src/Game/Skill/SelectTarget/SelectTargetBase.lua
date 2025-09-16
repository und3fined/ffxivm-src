--author : haialexzhou
--brief : 选怪基础类，封装一些公用函数

local LuaClass = require ("Core/LuaClass")

local ProtoRes = require("Protocol/ProtoRes")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local EObjCfg = require("TableCfg/EobjCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local MonsterCfg = require("TableCfg/MonsterCfg")
--技能主表
local SkillMainCfg = require("TableCfg/SkillMainCfg")
--技能子表
local SkillSubCfg = require("TableCfg/SkillSubCfg")
--目标筛选表
local SkillTargetSelectCfg = require("TableCfg/SkillTargetSelectCfg")
--技能条件表
local SkillConditionCfg = require("TableCfg/SkillConditionCfg")
--技能范围表
local SkillAreaCfg = require("TableCfg/SkillAreaCfg")
local RPNGenerator = require ("Game/Skill/SelectTarget/RPNGenerator")
local CommonDefine = require("Define/CommonDefine")
local TeamHelper = require("Game/Team/TeamHelper")

local EActorType = _G.UE.EActorType

local HardLockType <const> = _G.UE.ETargetLockType.Hard

--选怪结果单位
local SelecteTargetUnit = LuaClass()

function SelecteTargetUnit:Init()
    self.Actor = nil
    self.Value = 0
end

--选怪基础类
local SelectTargetBase = {}

function SelectTargetBase:Construct()
    --目前只有怪物的， 怪物表中配置的怪物半径
    -- self.ActorRadiusMap = {}
    --记录怪物的Tag
    self.MonsterTagMap = {}
    --记录npc的type，用于召唤物的判定
    self.NpcTypeMap = {}
    
    --缓存
    self.ForbitSelectMap = {    --用于根据ResIDent的读表的静态检查
        [EActorType.Monster] = {},
        [EActorType.Npc] = {},  --上面2个对应于各自表格的SelectCircleType   select_circle_type.SELECT_FORBID
        [EActorType.EObj] = {}, --对应于表格的CanSelect == 0
    }
    
    -- ExecuteSecondSelect的GetValueBySkillSelectType计算无法免去，因为SelectID里面的FIrstFilter、SecondFilter的Value不是同一个
    -- 所以计算量大的Distance缓存，可以节省一定的计算，每次Reset的时候清理
    self.TargetDistMap = {}
    
    self.TargetTypeRltMap = {}
    
    --固定不变的，不用每次Init的时候又重新赋值
    --预先缓存5个
    self.PoolInitCnt = 15
    self.PoolMaxCacheCnt = 22

    --缓存相关表格数据
    self.SkillConditionData = self.SkillConditionData or {}
    self.SkillTargetSelectData = self.SkillTargetSelectData or {}
    self.SkillAreaData = self.SkillAreaData or {}
    self.SkillSubData = self.SkillSubData or {}
    self.SkillData = self.SkillData or {}
    --是不是治疗技能的缓存，按技能ID缓存
    self.HealSkillMap = {}
    --是不是选目标技能的缓存 [SubSkillID][HitIdx] = true/false
    self.SelectTargetHitMap = {}
    
    self.MaxZDiff = CommonDefine.SwitchTarget.MaxZDiff --选目标Z轴最大差值
    --技能释放位置，目标判定过程中范围判定的时候会赋值
    self.SkillActionPos = _G.UE.FVector()
    
    --缓存处理，防止自动战斗时不停创建SelectTarget对象
    if (self.UsedSelectTargetPool == nil or self.UnUsedSelectTargetPool == nil) then
        self.UsedSelectTargetPool = {}
        self.UnUsedSelectTargetPool = {}
        for i = 1, self.PoolInitCnt, 1 do
            local TargetUnit = SelecteTargetUnit.New()
            TargetUnit:Init()
            table.insert(self.UnUsedSelectTargetPool, TargetUnit)
        end
    -- else --Reset的时候会清理，所以不用这里再check了
    --     if (#self.UnUsedSelectTargetPool > self.PoolMaxCacheCnt) then
    --         _G.TableTools.RemoveTableElements(self.UnUsedSelectTargetPool, self.PoolMaxCacheCnt)
    --     end
    end
end

function SelectTargetBase:Init(SkillID, SubSkillID, HitIdx, bUseFaultTolerantRange, SelectedPos, DirAngle, bForbidChangeTarget)
    self.SkillID = SkillID
    self.SubSkillID = SubSkillID
    self.HitIdx = HitIdx --命中索引
    self.bUseFaultTolerantRange = bUseFaultTolerantRange --使用容错半径
    self.SelectedPos = SelectedPos --选中点
    self.SelectedTarget, self.TargetLockType = self:GetCurrSelectedTarget()  --当前选中的目标
    self.DirAngle = DirAngle --朝向角度

    --有没有目标被障碍阻挡，ExecuteSecondSelect时会赋值
    self.HaveTargetBlocked = false
    self.HaveFateState = false

    self.bForbidChangeTarget = _G.SelectTargetMgr.bSettingForbidChangeTarget or bForbidChangeTarget

    --是不是选目标的技能
    if self.SelectTargetHitMap[SubSkillID] and self.SelectTargetHitMap[SubSkillID][HitIdx] ~= nil then
        self.IsSelectTargetHit = self.SelectTargetHitMap[SubSkillID][HitIdx]
    else
        self.IsSelectTargetHit = false

        local AreaExpressionStr = self:GetSkillHitAreaStr()
        local AreaID = tonumber(AreaExpressionStr )
        if (AreaID ~= nil) then
            local ResSkillArea = self:GetResSkillArea(AreaID)
            if ResSkillArea.PointType == ProtoRes.skill_point_type.SKILL_POINT_SELECT_TARGET
                or not bForbidChangeTarget and ResSkillArea.PointType == ProtoRes.skill_point_type.SKILL_POINT_TARGET then
                self.IsSelectTargetHit = true
            end
        end

        self.SelectTargetHitMap[SubSkillID] = self.SelectTargetHitMap[SubSkillID] or {}
        self.SelectTargetHitMap[SubSkillID][HitIdx] = self.SelectTargetHitMap[SubSkillID][HitIdx] or {}
        self.SelectTargetHitMap[SubSkillID][HitIdx] = self.IsSelectTargetHit
    end
    --如果是目标选择的技能，先确定一个被选中的目标；（当前可能没选中目标，或者选中的可能不是技能目标）
    -- local CurrSelectedTarget = SelectTargetBase.SelectedTarget
    
    --是不是治疗技能
    self.IsHealSkill = self.HealSkillMap[SkillID]
    if self.IsHealSkill == nil then
        self.IsHealSkill = false
        local SkillClass = self:GetSkillClass()
        if (SkillClass & ProtoRes.skill_class.SKILL_CLASS_HEAL) ~= 0 then
            self.IsHealSkill = true
        end
        self.HealSkillMap[SkillID] = self.IsHealSkill
    end

    self.CasterRadius = 0
    self.SelectedDirAngle = -1
end

--===========   预先处理（原来会算多次）    =======================
function SelectTargetBase:PreProcess(Executor)
    if Executor then
        local AvatarComponent = Executor:GetAvatarComponent()
        if AvatarComponent then
            self.CasterRadius = AvatarComponent:GetRadius() * 100 * Executor:GetModelScale()
        end
    end

    self.ActionPosMap = {}
    self.RelativeOffsetMap = {}
end

function SelectTargetBase:IsForbidChangeTarget()
    local bForbid = true
    if not self.bForbidChangeTarget and self.IsSelectTargetHit and not self.IsHealSkill and self.TargetLockType ~= HardLockType then
        bForbid = false
    end

    return bForbid
end

--从缓存池中取
function SelectTargetBase:GetUnUsedTarget()
	local TargetUnit = nil
	if (#self.UnUsedSelectTargetPool > 0) then
		TargetUnit = self.UnUsedSelectTargetPool[1]
		table.remove(self.UnUsedSelectTargetPool, 1)
	else
		TargetUnit = SelecteTargetUnit.New()
    end

    if (TargetUnit) then
        TargetUnit:Init()
    end
    
	table.insert(self.UsedSelectTargetPool, TargetUnit)
	
    return TargetUnit
end

--回收
function SelectTargetBase:RecycleTarget(TargetUnit)
    if (nil == TargetUnit) then
        return
    end
	TargetUnit:Init()
	_G.TableTools.RemoveTableElement(self.UsedSelectTargetPool, TargetUnit)
	table.insert(self.UnUsedSelectTargetPool, TargetUnit)
	if (#self.UnUsedSelectTargetPool > self.PoolMaxCacheCnt) then
		_G.TableTools.RemoveTableElements(self.UnUsedSelectTargetPool, self.PoolMaxCacheCnt)
	end
end

function SelectTargetBase:RecycleTargets(TargetUnitList)
    for i = 1, #TargetUnitList do
        self:RecycleTarget(TargetUnitList[i])
    end
end

--切图的时候在清理，不切图的话，就缓存着技能的子表等数据
function SelectTargetBase:ExitMap()
    -- self.SkillConditionData = {}
    -- self.SkillTargetSelectData = {}
    -- self.SkillAreaData = {}
    -- self.SkillSubData = {}
    -- self.SkillData = {}
end

function SelectTargetBase:ClearAllCache()
    -- 主表相关
    self.SkillData = {}
    self.HealSkillMap = {}

    -- 子表相关
    self.SkillSubData = {}
    self.SkillAreaData = {}
    self.SkillTargetSelectData = {}
    self.SkillConditionData = {}
    self.SelectTargetHitMap = {}
end

function SelectTargetBase:Reset()
    self.SkillID = 0
    self.SubSkillID = 0
    self.HitIdx = 0
    self.SelectedPos = nil
    self.SelectedTarget = nil
    self.TargetLockType = nil
    self.DirAngle = 0

    --技能释放位置，目标判定过程中范围判定的时候会赋值
    self.SkillActionPos = _G.UE.FVector()
    self.IsSelectTargetHit = false
    --有没有目标被障碍阻挡
    self.HaveTargetBlocked = false
    self.HaveFateState = false
    
    -- self.SkillConditionData = {}
    -- self.SkillTargetSelectData = {}
    -- self.SkillAreaData = {}
    -- self.SkillSubData = {}   --子表数据缓存着
    -- self.SkillData = {}      --主表数据缓存

    self.UsedSelectTargetPool = {}
    if (#self.UnUsedSelectTargetPool > self.PoolMaxCacheCnt) then
		_G.TableTools.RemoveTableElements(self.UnUsedSelectTargetPool, self.PoolMaxCacheCnt)
	end

    self.TargetDistMap = {}
    RPNGenerator:ClearCache()
    self.CasterRadius = 0
    self.SelectedDirAngle = -1
end

function SelectTargetBase:GetIsFixTargetHit()
    if self.HitIdx == 1 and self.bUseFaultTolerantRange == false then
        return true
    end

    return false
end

--获取技能条件表数据
function SelectTargetBase:GetResSkillCondition(ConditionID)
    if (ConditionID == nil or self.SkillConditionData == nil) then
        return
    end

    local Data = self.SkillConditionData[ConditionID]
    if not Data then
        Data = SkillConditionCfg:FindCfgByKey(ConditionID)
        self.SkillConditionData[ConditionID] = Data
    end
    return Data
end

--获取目标筛选表数据
function SelectTargetBase:GetResSkillTargetSelect(SelectID)
    if (SelectID == nil or self.SkillTargetSelectData == nil) then
        return
    end
    local Data = self.SkillTargetSelectData[SelectID]
    if not Data then
        Data = SkillTargetSelectCfg:FindCfgByKey(SelectID)
        self.SkillTargetSelectData[SelectID] = Data
    end
    return Data
end

 --获取技能范围表数据
function SelectTargetBase:GetResSkillArea(AreaID)
    if (AreaID == nil or self.SkillAreaData == nil) then
        return
    end
    local Data = self.SkillAreaData[AreaID]
    if not Data then
        Data = SkillAreaCfg:FindCfgByKey(AreaID)
        self.SkillAreaData[AreaID] = Data
    end
    return Data
end

--获取技能子表数据
function SelectTargetBase:GetResSubSkill(SubSkillID)
    -- local bDB = nil
    if (SubSkillID == nil) then
        SubSkillID = self.SubSkillID
    end
    if (SubSkillID == nil or self.SkillSubData == nil or SubSkillID == 0) then
        return
    end

    local Cfg = self.SkillSubData[SubSkillID]
    if not Cfg then
        -- bDB = true
        Cfg = SkillSubCfg:FindCfgByKey(SubSkillID)
        self.SkillSubData[SubSkillID] = Cfg
    end

    return Cfg--, bDB
end

function SelectTargetBase:PreloadMainSkillInfo(SkillID, MainSkillInfo)
    if not MainSkillInfo then
        return
    end

    self.SkillData[SkillID] = MainSkillInfo

    local SkillClass = MainSkillInfo.Class
    if (SkillClass & ProtoRes.skill_class.SKILL_CLASS_HEAL) ~= 0 then
        self.HealSkillMap[SkillID] = true
    else
        self.HealSkillMap[SkillID] = false
    end
end

function SelectTargetBase:PreloadSkillInfo(SubSkillID, SubSkillInfo)
    if not SubSkillInfo then
        return
    end
    
    self.SkillSubData = self.SkillSubData or {}
    self.SkillAreaData = self.SkillAreaData or {}
    self.SkillTargetSelectData = self.SkillTargetSelectData or {}
    self.SkillConditionData = self.SkillConditionData or {}

    if (self.SkillSubData[SubSkillID] == nil) then
        self.SkillSubData[SubSkillID] = SubSkillInfo
    end

    self.SelectTargetHitMap[SubSkillID] = self.SelectTargetHitMap[SubSkillID] or {}

    for index = 1, #SubSkillInfo.HitList do
        local SkillHitUnit = SubSkillInfo.HitList[index]
        if (SkillHitUnit ~= nil) then
            local AreaID = tonumber(SkillHitUnit.AreaStr)
            if AreaID ~= nil then
                local AreaData = self.SkillAreaData[AreaID]
                if not AreaData then
                    AreaData = SkillAreaCfg:FindCfgByKey(AreaID)
                    self.SkillAreaData[AreaID] = AreaData
                end

                if AreaData and AreaData.PointType == ProtoRes.skill_point_type.SKILL_POINT_SELECT_TARGET then
                    self.SelectTargetHitMap[SubSkillID][index] = true
                else
                    self.SelectTargetHitMap[SubSkillID][index] = false
                end
            end
            
            local SelectID = tonumber(SkillHitUnit.TargetConditionStr)
            if SelectID ~= nil and self.SkillTargetSelectData[SelectID] == nil then
                local SelectCfg = SkillTargetSelectCfg:FindCfgByKey(SelectID)
                self.SkillTargetSelectData[SelectID] = SelectCfg
                if SelectCfg then
                    local ConditionID = tonumber(SelectCfg.ConditionExpr)
                    if ConditionID then
                        if (self.SkillConditionData[ConditionID] == nil) then
                            self.SkillConditionData[ConditionID] = SkillConditionCfg:FindCfgByKey(ConditionID)
                        end
                    end
                end
            end
        end
    end
end

--获取技能主表数据
function SelectTargetBase:GetResSkill()
    if (self.SkillID == nil or self.SkillData == nil) then
        return
    end

    local Cfg = self.SkillData[self.SkillID]
    if not Cfg then
        Cfg = SkillMainCfg:FindCfgByKey(self.SkillID)
        self.SkillData[self.SkillID] = Cfg
    end

    return Cfg
end

--获取命中范围表达式字符串
function SelectTargetBase:GetSkillHitAreaStr(SubSkillID, HitIdx)
    local ResSubSkill = self:GetResSubSkill(SubSkillID)
    if (HitIdx == nil) then
        HitIdx = self.HitIdx
    end
    if (ResSubSkill == nil or HitIdx == nil or HitIdx == 0) then
        return nil
    end

    local SkillHitUnit = ResSubSkill.HitList[HitIdx]
    if (SkillHitUnit ~= nil) then
        return SkillHitUnit.AreaStr
    end

    return nil
end

--获取范围表容错半径
function SelectTargetBase:GetFaultTolerantRangeInArea(ResSkillArea)
    if (self.bUseFaultTolerantRange and ResSkillArea ~= nil) then
        return ResSkillArea.FaultTolerantRange
    end

    return 0
end

--获取条件表容错半径
function SelectTargetBase:GetFaultTolerantRangeInCondition(ResSkillCondition)
    if (self.bUseFaultTolerantRange and ResSkillCondition ~= nil) then
        return ResSkillCondition.FaultTolerantRange
    end

    return 0
end

--选中点（手搓技能）
function SelectTargetBase:GetSelectedPos()
    return self.SelectedPos
end

--朝向角度（手搓技能）
function SelectTargetBase:GetDirAngle()
    return self.DirAngle
end

function SelectTargetBase:GetSkillActionPos()
    return self.SkillActionPos
end

--获取目标筛选表达式字符串
function SelectTargetBase:GetSkillHitTargetConditionStr(SubSkillID)
    local ResSubSkill = self:GetResSubSkill(SubSkillID)
    if (ResSubSkill == nil or self.HitIdx == nil or self.HitIdx == 0) then
        return nil
    end

    local SkillHitUnit = ResSubSkill.HitList[self.HitIdx]
    if (SkillHitUnit ~= nil) then
        return SkillHitUnit.TargetConditionStr
    end

    return nil
end


--获取技能类别
function SelectTargetBase:GetSkillClass()
    local ResSkill = SelectTargetBase:GetResSkill()
    if (ResSkill ~= nil) then
        return ResSkill.Class
    end

    return 0
end

--获取顶层owner
-- local function GetTopOwner(Target)
--     if (Target == nil) then
--         return nil
--     end

--     local TargetOwner = Target
--     while TargetOwner do
--         local AttributeComp = TargetOwner:GetAttributeComponent()
--         if AttributeComp and AttributeComp.Owner and AttributeComp.Owner > 0 then
--             local OwnerActor = ActorUtil.GetActorByEntityID(AttributeComp.Owner)
--             if OwnerActor then
--                 TargetOwner = OwnerActor
--             else
--                 FLOG_ERROR("GetTopOwner: Has Owner, but GetActor Failed" .. AttributeComp.Owner)
--                 break
--             end
--         else
--             break
--         end
--     end

--     return TargetOwner
-- end

--获取阵营
local function GetCamp(Target)
    if (Target == nil) then
        return ProtoRes.camp_type.camp_type_none, 0
    end

    local AttributeComp = Target:GetAttributeComponent()
    if AttributeComp then
        return AttributeComp.Camp, AttributeComp.CampData
    end
    
    return ProtoRes.camp_type.camp_type_none, 0
end

--获取动态阵营关系
function SelectTargetBase:GetDynamicCampRelation(Executor, Target, ExecutorCamp, TargetCamp)
     -- 在我方队伍
    if self:IsTeamMember(Target) then
        return ProtoRes.camp_relation.camp_relation_ally
    end

    --因为客户端的Executor基本是主角，所以不用判定怪物之间是不是同一个怪物组
    -- local TargetType = Target:GetActorType() --直接是敌人就好了
    -- if TargetType == _G.UE.EActorType.Monster or TargetType == _G.UE.EActorType.Npc then
    --     return ProtoRes.camp_relation.camp_relation_enemy
    -- end

    -- 有家族

    -- 都无，则是敌对关系
    return ProtoRes.camp_relation.camp_relation_enemy
end

-- 在我方队伍
function SelectTargetBase:IsTeamMember(Target)
    if (Target ~= nil) then
        local AttributeComp = Target:GetAttributeComponent()
        if AttributeComp ~= nil then
            local Mgr = TeamHelper.GetTeamMgr()
            if Mgr:IsTeamMemberByRoleID(AttributeComp.RoleID) then
                return true
            end
            
            if Mgr:IsTeamMemberByEntityID(AttributeComp.EntityID) then
                return true
            end
        end
    end

    return false
end

function SelectTargetBase:GetCampRelationByEntityID(EntityID)
	local Major = MajorUtil.GetMajor()
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        return ProtoRes.camp_relation.camp_relation_neutral
    end

	local Relation = self:GetCampRelationByMajor(Major, Actor)

    --debug
    -- local ActorName = Actor:GetAttributeComponent().ActorName
    -- FLOG_INFO("GetCampRelationByEntityID %s Relation:%d", ActorName, Relation)
    --debug

	return Relation
end

function SelectTargetBase:GetCampRelationByMajor(Executor, Target)
    local TargetAttrComp = Target:GetAttributeComponent()
    local EntityID = 0
    local Relation = nil
    if TargetAttrComp then
        EntityID = TargetAttrComp.EntityID
		Relation = _G.SelectTargetMgr.CampCache[EntityID]
        if Relation ~= nil then
            return Relation
        end
    end

    Relation = self:GetCampRelation(Executor, Target)
    _G.SelectTargetMgr.CampCache[EntityID] = Relation
    return Relation
end

--获取阵营关系
function SelectTargetBase:GetCampRelation(Executor, Target)
    -- 对自己施法，快速判定为友好的
    if (Executor == Target) then
        return ProtoRes.camp_relation.camp_relation_ally
    end
   
    if (nil == Executor or nil == Target ) then
        return ProtoRes.camp_relation.camp_relation_neutral
    end

    --优先溯源后的判定
    local TargetTopOwner = _G.ActorMgr:GetTopOwner(Target)
    local ExecutorTopOwner = _G.ActorMgr:GetTopOwner(Executor)
    if (TargetTopOwner == ExecutorTopOwner) then
        return ProtoRes.camp_relation.camp_relation_ally
    end

    --先进行阵营的溯源，找最顶层Owner的
    local CampA, CampDataA = GetCamp(ExecutorTopOwner)
    local CampB, CampDataB = GetCamp(TargetTopOwner);
    --debug
    -- FLOG_INFO("GetActorCampRelation CampA:%d, CampB:%d", CampA, CampB)
    --debug
    -- 如果双方是固定阵营，则判定阵营即可
    if (CampA >= ProtoRes.camp_type.camp_type_fix1 and CampB >= ProtoRes.camp_type.camp_type_fix1) then
        if (CampA == CampB) then
            return ProtoRes.camp_relation.camp_relation_ally
        else
            return ProtoRes.camp_relation.camp_relation_enemy
        end
    end

    -- 无固定阵营，则根据阵营关系表获取关系，如果是动态阵营关系，还需进一步判定是否可攻击
    local CampRelation = _G.ActorMgr:GetActorCampRelation(CampA, CampB)
    if CampRelation == ProtoRes.camp_relation.camp_relation_dynamic then
        CampRelation = self:GetDynamicCampRelation(Executor, Target, CampA, CampB)
    elseif CampRelation == ProtoRes.camp_relation.camp_relation_eachother then  --捉对厮杀阵营关系
        if CampDataA ~= 0 and CampDataA == CampDataB then   -- 同一组的玩家之间是敌对关系，否则为中立关系
            return ProtoRes.camp_relation.camp_relation_enemy
        end

        return ProtoRes.camp_relation.camp_relation_neutral
    end
    --debug
    -- FLOG_INFO("GetActorCampRelation %d", CampRelation)
    --debug

    return CampRelation
end

--目标是否可被选中
function SelectTargetBase:IsCanBeSelect(Target, IsSkillSelect)
    if (Target == nil) then
        return false
    end

    local TargetType = Target:GetActorType()
    if not IsSkillSelect and TargetType == _G.UE.EActorType.Gather then    --外面判定过了
        return true
    end
    
    local ActorResID = Target:GetActorResID()
    if self:IsForbidSelect(Target, TargetType, ActorResID) then
        return false
    end

    local StateComponent = Target:GetStateComponent()
    -- local AttrComponent = Target:GetAttributeComponent()
    if StateComponent == nil then-- or AttrComponent == nil then
        return false
    end

    --如果是技能选择并且不可技能选中   如果不是技能选择并且不可玩家选中
    if (IsSkillSelect and not StateComponent:GetActorControlState(_G.UE.EActorControllStat.CanPlayerSkillSelected)
        or not IsSkillSelect and not StateComponent:GetActorControlState(_G.UE.EActorControllStat.CanPlayerSelected)) then
        return false
    end

    -- 如果不是技能选择 EObj类型要根据配置表是否可选中
    if not IsSkillSelect and TargetType == _G.UE.EActorType.EObj then
        local bForbid = self:IsForbidSelectByStaticCheck(TargetType, ActorResID)
        if bForbid == true then
            return false
        end

        if bForbid == nil then
            local Cfg = EObjCfg:FindCfgByKey(ActorResID)
            if Cfg ~= nil then
                if Cfg.CanSelect == 0 then
                    self.ForbitSelectMap[TargetType][ActorResID] = true
                    return false;
                end

                self.ForbitSelectMap[TargetType][ActorResID] = false
            end
        end
    end

    local ResSubSkill = self:GetResSubSkill()
    if (TargetType == _G.UE.EActorType.Player) then
        if (IsSkillSelect and ResSubSkill ~= nil and ResSubSkill.SelectDeadTarget == 0 and StateComponent:IsDeadState()) then
            return false
        end
    else
        if (StateComponent:IsDeadState()) then
            return false
        end

        -- --怪物表的这个字段废弃掉了，使用出生buff带上逻辑状态（4个选中的状态设置）
        -- if (TargetType == _G.UE.EActorType.Monster) then
        --     return StateComponent:GetActorControlState(_G.UE.EActorControllStat.CanPlayerSelected)
        -- end
    end

    return true
end

--目标是否可被攻击
function SelectTargetBase:IsCanBeAttack(Executor, Target)
    local Result = false--todo
    if (Executor == nil or Target == nil) then
        return Result
    end

	-- local profile_tag = _G.UE.FProfileTag("IsCanBeAttack")
    local CampRelation = self:GetCampRelationByMajor(Executor, Target)
    if (CampRelation == ProtoRes.camp_relation.camp_relation_enemy) then
        Result = true
    end
	-- profile_tag:End()
    return Result
end

--目标是否可被治疗
function SelectTargetBase:IsCanBeHeal(Executor, Target)
    local Result = false--todo
	-- local profile_tag = _G.UE.FProfileTag("IsCanBeHeal")
    local CampRelation = self:GetCampRelationByMajor(Executor, Target)
    if (CampRelation == ProtoRes.camp_relation.camp_relation_ally) then
        Result = true
    end
	-- profile_tag:End()
    return Result
end

--目标是否可被辅助
function SelectTargetBase:IsCanBeAssist(Executor, Target)
    local Result = false--todo
	-- local profile_tag = _G.UE.FProfileTag("IsCanBeAssist")
    local CampRelation = self:GetCampRelationByMajor(Executor, Target)
    if (CampRelation == ProtoRes.camp_relation.camp_relation_ally) then
        Result = true
    end
	-- profile_tag:End()
    return Result
end

--目标是否是技能释放者的召唤物
function SelectTargetBase:IsOwnerCallerObj(Owner, Target)
    if (Owner == nil or Target == nil) then
        return false
    end
    local OwnerAttrComponent = Owner:GetAttributeComponent()
    local TargetAttrComponent = Target:GetAttributeComponent()
    if (OwnerAttrComponent == nil or TargetAttrComponent == nil) then
        return false
    end
    if (TargetAttrComponent.Owner == OwnerAttrComponent.EntityID) then
        return true
    end

    return false
end

--目标是否是所属者的主人
function SelectTargetBase:IsOwnerMaster(Owner, Target)
    if (Owner == nil or Target == nil) then
        return false
    end
    local OwnerAttrComponent = Owner:GetAttributeComponent()
    local TargetAttrComponent = Target:GetAttributeComponent()
    if (OwnerAttrComponent == nil or TargetAttrComponent == nil) then
        return false
    end
    if (OwnerAttrComponent.Owner == TargetAttrComponent.EntityID) then
        return true
    end

    return false
end

--计算反余弦角度值
function SelectTargetBase:DegAcos(CosValue)
    return (180.0) / 3.1415926535897932 * math.acos(CosValue)
end

--计算目标自身半径
function SelectTargetBase:GetTargetRadius(Target)
    local Radius = 0
    if (Target ~= nil) then
        local TargetType = Target:GetActorType()
        if (TargetType == _G.UE.EActorType.Monster) then
            Radius = Target:GetCapsuleRadius()
            -- local AttrComponent = Target:GetAttributeComponent()
			-- if (AttrComponent ~= nil) then
            --     Radius = self.ActorRadiusMap[AttrComponent.ResID]
            --     if not Radius then
            --         Radius = Target:GetCapsuleRadius()
            --             --MonsterCfg:FindValue(AttrComponent.ResID, "Radius")
            --         self.ActorRadiusMap[AttrComponent.ResID] = Radius
            --     end
            -- end
        end
    end
    return Radius
end

--获取monster的Tag，外部要保障Target是Monster
function SelectTargetBase:GetMonsterTag(ResID)
    local Tag = self.MonsterTagMap[ResID]
    if not Tag then
        Tag = MonsterCfg:FindValue(ResID, "MonsterTag")
        self.MonsterTagMap[ResID] = Tag
    end
    
    return Tag
end

--计算距离（不考虑z坐标）
function SelectTargetBase:GetDistance(ExecutorPos, TargetPos, ExecutorRadius, TargetRadius)
    --Z轴差距比较大的时候，返回一个比较大的值
    if (not self.MaxZDiff or not ExecutorPos or not TargetPos 
        or math.abs(ExecutorPos.Z - TargetPos.Z) > self.MaxZDiff) then
        return 1000000
    end
    local Distance = ExecutorPos:Dist2D(TargetPos) - ExecutorRadius - TargetRadius
    return Distance
end

--获取当前选中的目标
local USelectEffectMgr
function SelectTargetBase:GetCurrSelectedTarget()
    if not USelectEffectMgr then
        USelectEffectMgr = _G.UE.USelectEffectMgr:Get()
    end
    local SelectedTarget = USelectEffectMgr:GetCurrSelectedTarget()
    local TargetLockType = USelectEffectMgr:GetCurrSelectedTargetLockType()
    return SelectedTarget, TargetLockType
end

function SelectTargetBase:GetNpcType(ResID)
    if not ResID then
        return ProtoRes.NPC_TYPE.NPC
    end

    if not self.NpcTypeMap[ResID] then
        local NpcType = NpcCfg:FindValue(ResID, "Type")
        self.NpcTypeMap[ResID] = NpcType
        return NpcType
    end

    return self.NpcTypeMap[ResID]
end

function SelectTargetBase:IsForbidSelect(TargetActor, TargetType, TargetActorResID)
    if not TargetActorResID then
        TargetActorResID = TargetActor:GetActorResID()
    end

	if EActorType.Npc == TargetType or EActorType.Monster == TargetType then
        local bForbid = self:IsForbidSelectByStaticCheck(TargetType, TargetActorResID)
        if bForbid ~= nil then
            return bForbid
        end
    end

	if EActorType.Npc == TargetType then
		local SelectCircleType = NpcCfg:FindValue(TargetActorResID, "SelectCircleType")
		if SelectCircleType == ProtoRes.select_circle_type.SELECT_FORBID then
            self.ForbitSelectMap[TargetType][TargetActorResID] = true
			return true
		end

        self.ForbitSelectMap[TargetType][TargetActorResID] = false
	elseif EActorType.Monster == TargetType then
		local SelectCircleType = MonsterCfg:FindValue(TargetActorResID, "SelectCircleType")
		if SelectCircleType == ProtoRes.select_circle_type.SELECT_FORBID then
            self.ForbitSelectMap[TargetType][TargetActorResID] = true
			return true
		end

        self.ForbitSelectMap[TargetType][TargetActorResID] = false
	end

	return false
end

function SelectTargetBase:IsForbidSelectByStaticCheck(TargetType, TargetActorResID)
    local TypeMap = self.ForbitSelectMap[TargetType]
    if TypeMap then
        local bForbid = TypeMap[TargetActorResID]
        if bForbid ~= nil then
            return bForbid
        end
    end

    return nil
end

return SelectTargetBase