--author : haialexzhou
--brief : 技能选怪目标过滤

local ProtoRes = require ("Protocol/ProtoRes")
local SelectTargetBase = require ("Game/Skill/SelectTarget/SelectTargetBase")
local SelectTargetAreaFilter = require ("Game/Skill/SelectTarget/SelectTargetAreaFilter")
local RPNGenerator = require ("Game/Skill/SelectTarget/RPNGenerator")
local ProtoCommon = require("Protocol/ProtoCommon")
local UPWorldMgr = _G.UE.UPWorldMgr:Get()
local ActorUtil = require("Utils/ActorUtil")
local EActorType = _G.UE.EActorType
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

-- 常量定义, 减少运行时频繁对table执行index操作增加额外耗时
local SKILL_CONDITION_DISTANCE <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_DISTANCE
local EXLocationType_ServerLoc <const> = _G.UE.EXLocationType.ServerLoc
local SKILL_CONDITION_ATTR = ProtoRes.skill_condition_type.SKILL_CONDITION_ATTR
local SKILL_CONDITION_BUFF <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_BUFF
local SKILL_OBJECT_TYPE_CASTER <const> = ProtoRes.skill_object_type.SKILL_OBJECT_TYPE_CASTER
local SKILL_CONDITION_HP_WAN_RATE <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_HP_WAN_RATE
local SKILL_CONDITION_MP_WAN_RATE <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_MP_WAN_RATE
local SKILL_CONDITION_SPEED <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_SPEED
local SKILL_CONDITION_MONSTER_RESID <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_MONSTER_RESID
local SKILL_CONDITION_CRAFTER_TOOL <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_CRAFTER_TOOL
local SKILL_CONDITION_BUFF_PILE <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_BUFF_PILE
-- 施法者和强锁目标关系(纯客户端条件)
local SKILL_CONDITION_CURRENT_STRONG_LOCK_TARGET_RELATION <const> = ProtoRes.skill_condition_type.SKILL_CONDITION_CURRENT_STRONG_LOCK_TARGET_RELATION

local HardLockType <const> = _G.UE.ETargetLockType.Hard
local UActorManager = nil

--parm是根据类型而定的，比如BuffID
local function GetValueBySkillSelectType(Executor, Target, SelectType, Param1, ObjectType)
    if (nil == Executor or nil == Target) then
        return 0
    end
    local AttributeComp = Target:GetAttributeComponent()
    if (nil == AttributeComp) then
        return 0
    end

    local Value = 0
    if (SelectType == SKILL_CONDITION_DISTANCE) then
        local CachedValue = SelectTargetBase.TargetDistMap[AttributeComp.EntityID]
        if CachedValue ~= nil then
            Value = CachedValue
        else
            -- 施法者和目标的距离
            -- local profile_tag = _G.UE.FProfileTag("FGetLocation")
            local ActionPos = Executor:FGetLocation(EXLocationType_ServerLoc)
            local TargetPos = Target:FGetLocation(EXLocationType_ServerLoc)
            -- profile_tag:End()
            -- profile_tag = _G.UE.FProfileTag("GetTargetRadius")
            local ExecutorRadius = SelectTargetBase:GetTargetRadius(Executor)
            local TargetRadius = SelectTargetBase:GetTargetRadius(Target)
            -- profile_tag:End()
            -- profile_tag = _G.UE.FProfileTag("GetDistance")
            Value = SelectTargetBase:GetDistance(ActionPos, TargetPos, ExecutorRadius, TargetRadius)
            Value = Value > 0 and Value or 0
            -- profile_tag:End()
            SelectTargetBase.TargetDistMap[AttributeComp.EntityID] = Value
        end
    elseif (SelectType == SKILL_CONDITION_ATTR) then
        -- todo 目标的属性值
        -- 属性条件，参数1是属性枚举，参数2是属性值
        if (Param1 ~= 0) then
            Value = AttributeComp:GetAttrValue(Param1)
        end
        
    elseif (SelectType == SKILL_CONDITION_BUFF) then
        --todo 目标身上是否有buff id
        --buff条件，参数1是buff id，参数2是0和1
        Value = 0
        local BuffComp = Target:GetBuffComponent()
        if ObjectType and ObjectType == SKILL_OBJECT_TYPE_CASTER then
            BuffComp = Executor:GetBuffComponent()
        end
        if (BuffComp ~= nil and Param1 ~= 0) then
            local IsExist = BuffComp:IsExistBuffForBuffID(Param1)
            Value = IsExist and 1 or 0
        end

    elseif (SelectType == SKILL_CONDITION_HP_WAN_RATE) then
        --血量万分比
        local CurrHP = AttributeComp:GetCurHp()
        local MaxHP = AttributeComp:GetMaxHp()
        Value = (MaxHP > 0 and (CurrHP / MaxHP) or 0) * 10000

    elseif (SelectType == SKILL_CONDITION_MP_WAN_RATE) then
        --蓝量万分比
        local CurrMP = AttributeComp:GetCurMp()
        local MaxMP = AttributeComp:GetMaxMp()
        Value = (MaxMP > 0 and (CurrMP / MaxMP) or 0) * 10000
    elseif (SelectType == SKILL_CONDITION_SPEED) then
        --移动速度
        local Actor = Target
        if ObjectType and ObjectType == SKILL_OBJECT_TYPE_CASTER then
            Actor = Executor
        end
        
        if Actor then
            local Velocity = Actor.CharacterMovement.Velocity
            Velocity.Z = 0
            Value = Velocity:Size()
        end
    elseif (SelectType == SKILL_CONDITION_MONSTER_RESID) then
		local ActorType = Target:GetActorType()
        if EActorType.Monster == ActorType then
            Value = Target:GetActorResID()
        end
    elseif (SelectType == SKILL_CONDITION_CRAFTER_TOOL) then
        --生产职业工具
        local AttrComp = Executor:GetAttributeComponent()
        if AttrComp then
            local EntityID = AttrComp.EntityID
            Value = _G.ActorMgr:GetTool(EntityID) or 0
        end
    elseif (SelectType == SKILL_CONDITION_BUFF_PILE) then
        local BuffComp = Target:GetBuffComponent()
        if ObjectType and ObjectType == SKILL_OBJECT_TYPE_CASTER then
            BuffComp = Executor:GetBuffComponent()
        end
        if (BuffComp ~= nil and Param1 ~= 0) then
            Value = BuffComp:GetBuffPile(Param1)
        end
    elseif (SelectType == SKILL_CONDITION_CURRENT_STRONG_LOCK_TARGET_RELATION) then
        if not UActorManager then
            UActorManager = _G.UE.UActorManager.Get()
        end
        local TargetLockType, SelectedTarget = SelectTargetBase.TargetLockType, SelectTargetBase.SelectedTarget
        if not TargetLockType then
            SelectedTarget, TargetLockType = SelectTargetBase:GetCurrSelectedTarget()  --当前选中的目标
        end
        SelectedTarget = TargetLockType == HardLockType and SelectedTarget or nil
        local bRelationValid = UActorManager:CheckRelation(Executor, SelectedTarget, Param1)
        Value = bRelationValid and 1 or 0
    end

    return Value
end

-- 判断目标是否符合条件（技能条件表）,第一轮筛选
local function TargetIsConformCondition(Executor, Target, ConditionID)
    if (nil == Executor or nil == Target) then
        return false
    end
    --通过ConditionID获取ResSkillCondition
	-- local profile_tag = _G.UE.FProfileTag("GetResSkillCondition")
    local ResSkillCondition = SelectTargetBase:GetResSkillCondition(ConditionID) 
	-- profile_tag:End()
    if (nil == ResSkillCondition) then
        return false
    end

    -- --对施法者check条件
    -- if ResSkillCondition.ObjectType == ProtoRes.skill_object_type.SKILL_OBJECT_TYPE_CASTER
    --     and Executor ~= Target then
    --     return false
    -- --对目标check条件
    -- elseif ResSkillCondition.ObjectType == ProtoRes.skill_object_type.SKILL_OBJECT_TYPE_TARGET 
    --     and Executor == Target then
    --     return false
    -- end

    -- 提取数值
    -- profile_tag = _G.UE.FProfileTag("GetValueBy")
    local Value = GetValueBySkillSelectType(Executor, Target, ResSkillCondition.Type, ResSkillCondition.Param1, ResSkillCondition.ObjectType)
	-- profile_tag:End()
    local ConfigValue = ResSkillCondition.Param2 + SelectTargetBase:GetFaultTolerantRangeInCondition(ResSkillCondition)
    --进行比较
    if (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_EQ) then
        return Value == ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_LT) then
        return Value < ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_LE) then
        return Value <= ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_GT) then
        return Value > ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_GE) then
        return Value >= ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_NE) then
        return Value ~= ConfigValue
    end

    return false
end

local GetTargetTypeValueFromRlt <const> = _G.UE.USkillUtil.GetTargetTypeValueFromRlt
local SetTargetTypeValueInRlt <const> = _G.UE.USkillUtil.SetTargetTypeValueInRlt

--判断目标是否符合类型
local function TargetIsConformTargetType(Executor, Target,  ResSkillTargetSelect)
    local Result = false
    if (nil == Executor or nil == Target or nil == ResSkillTargetSelect) then
        return false
    end

    local ActorType = Target:GetActorType()
    --这里改成二进制组合模式，然后按&操作会更好些，等后面组合模式复杂了再优化吧
    --目标类型：现在拆分为目标阵营
    local RelationType = ResSkillTargetSelect.SkillRelationType
    local TargetType = ResSkillTargetSelect.SkillFillterTargetType
    --自身 （仅仅是自身的情况，如果自身和其他的组合的话，下面判定
	if (RelationType == ProtoRes.skill_relation_type.SKILL_RELATION_SELF) then
        Result = (Executor == Target)
        return Result
    --主人
    elseif (TargetType == ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_MASTER) then
        if (Executor ~= Target and SelectTargetBase:IsOwnerMaster(Executor, Target)) then
            Result = true
        end
        return Result
    elseif TargetType == 9 then --任务Npc和EObj 纯客户端的，写死的9；  没在skill_filter_target_type协议上体现
        if ActorType == _G.UE.EActorType.EObj or ActorType == _G.UE.EActorType.NPC then
            return true
        end
    end

    --只有技能目标类型是9 任务Npc和EObj的时候才允许；其他的都是不允许的
    if ActorType == _G.UE.EActorType.EObj or ActorType == _G.UE.EActorType.NPC then
        return false
    end

    --全部
    if (RelationType == ProtoRes.skill_relation_type.SKILL_RELATION_ALL) then
        Result = true
    end

    --判定是不是有配置自身
	if not Result and RelationType & ProtoRes.skill_relation_type.SKILL_RELATION_SELF ~= 0 then        -- 1
        if Executor == Target then
            Result = true
        end
    end

    --敌对  编辑器默认这个，而且大多数是这种，所以早点判定这个
    if not Result and (RelationType & ProtoRes.skill_relation_type.SKILL_RELATION_ENEMY ~= 0) then  -- 8
        if (Executor ~= Target and SelectTargetBase:IsCanBeAttack(Executor, Target)) then
            Result = true
        end
    end

    --友好
    if not Result and (RelationType & ProtoRes.skill_relation_type.SKILL_RELATION_FRIEND ~= 0) then -- 2
        if SelectTargetBase:IsCanBeHeal(Executor, Target) or SelectTargetBase:IsCanBeAssist(Executor, Target) then
            Result = true
        end
    end

    --自身+友好
    -- if (RelationType == ProtoRes.skill_relation_type.SKILL_RELATION_SELF_AND_FRIEND) then
    --     if (Executor == Target or SelectTargetBase:IsCanBeHeal(Executor, Target) or SelectTargetBase:IsCanBeAssist(Executor, Target)) then
    --         Result = true
    --     end
    -- end

    --自身召唤物
    if  not Result and (RelationType & ProtoRes.skill_relation_type.SKILL_RELATION_SELF_CALL ~= 0) then -- 4
        if (Executor ~= Target and SelectTargetBase:IsOwnerCallerObj(Executor, Target)) then
            Result = true
        end
    end

    --队友
    if  not Result and (RelationType & ProtoRes.skill_relation_type.SKILL_RELATION_TEAM ~= 0) then -- 16
        if (Target ~= nil and Executor ~= Target) then
            if SelectTargetBase:IsTeamMember(Target) then
                Result = true
            end
        end
    end
    
    local TargetAttrComp = Target:GetAttributeComponent()
    --机制特训怪
    if  not Result and (RelationType & ProtoRes.skill_relation_type.SKILL_RELATION_MECHANISM_TRAIN ~= 0) then -- 32
        if (Target ~= nil and Executor ~= Target and TargetAttrComp) then
            if SelectTargetBase:GetMonsterTag(TargetAttrComp.ResID) == ProtoRes.monster_tag.MONSTER_TAG_MECHANISM_TRAIN then
                Result = true
            end
        end
    end
    
    --如果目标阵营的判定通过了，继续目标类型的判定
    if Result then
        if TargetAttrComp then
            local Rlt = SelectTargetBase.TargetTypeRltMap[TargetAttrComp.EntityID] or 0
            local RltValue = GetTargetTypeValueFromRlt(Rlt, TargetType)
            if RltValue ~= nil then
                Result = RltValue
            else
                local IsCallObj = false
                if TargetAttrComp and TargetAttrComp.Owner > 0 then
                    --召唤物也必然是monster
                    IsCallObj = true
                end
        
                --!!!!! 如果这里的处理不是完全静态的，可能动态改变，就不能用这个缓存了！！！！！

                --除非战斗召唤物  编辑器默认这个
                if TargetType == ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_EXCLUDE_NOT_COMBAT_CALL then
                    if IsCallObj and SelectTargetBase:GetMonsterTag(TargetAttrComp.ResID) == ProtoRes.monster_tag.MONSTER_TAG_NOT_COMBAT_CALL then
                        Result = false  --仅仅非战斗召唤物不是目标，其他的都是
                    end
                --非战斗召唤物
                elseif TargetType == ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_NOT_COMBAT_CALL then
                    if IsCallObj == false or
                        SelectTargetBase:GetMonsterTag(TargetAttrComp.ResID) ~= ProtoRes.monster_tag.MONSTER_TAG_NOT_COMBAT_CALL then
                        Result = false
                    end
                --战斗召唤物
                elseif TargetType == ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_COMBAT_CALL then
                    if IsCallObj == false or
                        SelectTargetBase:GetMonsterTag(TargetAttrComp.ResID) ~= ProtoRes.monster_tag.MONSTER_TAG_DEFAULT then
                        Result = false
                    end
                --召唤物
                elseif TargetType == ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_CALL then
                    if IsCallObj == false then
                        Result = false
                    end
                -- elseif
                --主人：前面单独拎出来了
                --全部：不用再判定了，直接是通过的
                -- elseif TargetType == ProtoRes.skill_filter_target_type.SKILL_FILTER_TARGET_ALL then
                end

                --!!!!! 如果这里的处理不是完全静态的，可能动态改变，就不能用这个缓存了！！！！！
                SelectTargetBase.TargetTypeRltMap[TargetAttrComp.EntityID] = SetTargetTypeValueInRlt(Rlt, TargetType, Result)
            end
        end
    end

    return Result
end

--执行第一次筛选(目标筛选表), 遍历视野内所有目标，根据自身、友好、敌对等关系逐个目标执行判断
--OriginActorList: 视野中所有目标列表
--OutTargetList: 需要返回的选中目标列表
local function ExecuteFirstSelect(SelectID, VisionActorList, OutTargetList, Executor)
    --todo 根据SelectID取得目标筛选表数据
    local ResSkillTargetSelect = SelectTargetBase:GetResSkillTargetSelect(SelectID)
    if (nil == ResSkillTargetSelect) then
        return
    end
    if (UPWorldMgr == nil) then
        UPWorldMgr = _G.UE.UPWorldMgr:Get()
    end

    local profile_tag = nil

    local bForbidChangeTarget = SelectTargetBase:IsForbidChangeTarget()
    
	local AreaExpressionStr = SelectTargetBase:GetSkillHitAreaStr()

    -- local ExecutorPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    -- ExecutorPos.Z = ExecutorPos.Z + 50

    local ActorCnt = VisionActorList:Length()
    for i = 1, ActorCnt, 1 do
        local Target = VisionActorList:Get(i)
        while (Target ~= nil) do
            --采集物过滤掉
            local ActorType = Target:GetActorType()
            if ActorType == _G.UE.EActorType.Gather
                or ActorType == _G.UE.EActorType.ClientShow
                or ActorType == _G.UE.EActorType.Summon then    --任何情况下召唤兽都不进入客户端目标选择
                break
            -- --过滤掉交互物
            -- elseif ActorType == _G.UE.EActorType.NPC then
            --     break   --npc目前不参与战斗，将来需要的时候再说
            --     -- local AttrComponent = Target:GetAttributeComponent()
            --     -- if (AttrComponent ~= nil) then
            --     --     --过滤掉交互物
            --     --     if SelectTargetBase:GetNpcType(AttrComponent.ResID) == ProtoRes.NPC_TYPE.INTERACTOBJ then
            --     --         break
            --     --     end
            --     -- end
            end

            local bIsContinue
            do
                local _ <close> = CommonUtil.MakeProfileTag("CanSelect")
                bIsContinue = SelectTargetBase:IsCanBeSelect(Target, true)
            end
            if (not bIsContinue) then
                break
            end
            --判断是否符合目标类型
            do
                local _ <close> = CommonUtil.MakeProfileTag("ConfirmType")
                bIsContinue = TargetIsConformTargetType(Executor, Target, ResSkillTargetSelect)
            end
            if (not bIsContinue) then
                break
            end

            if ActorType == _G.UE.EActorType.Monster then
                if _G.FateMgr:IsFateMonsterButNotJoin(Target:GetActorEntityID()) then
                    SelectTargetBase.HaveFateState = true
                    break
                end
            end

            --目标是否符合技能筛选条件
            --默认都满足
            do
                local _ <close> = CommonUtil.MakeProfileTag("ConditionExpr")
                if (ResSkillTargetSelect.ConditionExpr ~= "" and ResSkillTargetSelect.ConditionExpr ~= nil) then
                    bIsContinue = RPNGenerator:ExecuteRPNBoolExpression(ResSkillTargetSelect.ConditionExpr, Executor, Target, TargetIsConformCondition)
                end
            end
            if (not bIsContinue) then
                break
            end

            --如果是选目标的技能，目标是否在技能伤害范围内，这个改到ExecuteSecondSelect排序之后去处理了
            do
                local _ <close> = CommonUtil.MakeProfileTag("InArea" .. AreaExpressionStr)
                if bForbidChangeTarget then
                    bIsContinue = SelectTargetAreaFilter:TargetIsInArea(Executor, Target, AreaExpressionStr)
                    if (not bIsContinue) then
                        break
                    end
                end
            end

            --暂时屏蔽此功能，否额魔科学第2层那个球打不到
            -- local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)
            -- TargetPos.Z = TargetPos.Z + 50 --避免射线打到地面
            -- --角色和目标之间是否有阻挡
            -- bIsContinue = UPWorldMgr:IsCanArrivedInStraightLine(ExecutorPos, TargetPos)
            -- if (not bIsContinue) then
            --     print("target is can't arrived!!!")
            --     break
            -- end

            table.insert(OutTargetList, Target)

            break --这个break千万不能删掉！！
        end
        
    end
end

--比小
local function SortByCompareLess(TargetUnitA, TargetUnitB)
    if (TargetUnitA == nil or TargetUnitB == nil) then
        return false
    end
    return TargetUnitA.Value < TargetUnitB.Value
end

--比大
local function SortByCompareGreater(TargetUnitA, TargetUnitB)
    if (TargetUnitA == nil or TargetUnitB == nil) then
        return false
    end
    return TargetUnitA.Value > TargetUnitB.Value
end

-- 随机排序
local function SortByRandom(T)
    if (nil == T) then
        return T
    end
    -- 设置随机数种子
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
    local TableLen = #T
    while(TableLen > 0)
    do
        local Index = math.random(TableLen)
        T[TableLen], T[Index] = T[Index], T[TableLen]
        TableLen = TableLen - 1
    end
    return T
end

--执行第二次筛选，从第一步筛选出来的目标列表中按指定规则取出指定数量的目标
local function ExecuteSecondSelect(SelectID, OutTargetList, Executor)
    --根据SelectID取得目标筛选表数据
    local ResSkillTargetSelect = SelectTargetBase:GetResSkillTargetSelect(SelectID)
    if (nil == ResSkillTargetSelect) then
        return
    end

    local CurrSelectedTarget = SelectTargetBase.SelectedTarget --:GetCurrSelectedTarget()
    local bForbidChangeTarget = SelectTargetBase:IsForbidChangeTarget()

    --当前有选中目标，并且技能是选目标的技能
    --check选中的目标是否是技能的目标，如果不是，则后面切换；  治疗技能不会切目标，忽略这个逻辑
    if not bForbidChangeTarget and CurrSelectedTarget then
        local IsSkillTarget = false
        for i = 1, #OutTargetList do
           if CurrSelectedTarget == OutTargetList[i] then
                IsSkillTarget = true
                break
           end
        end

        if not IsSkillTarget then
            CurrSelectedTarget = nil
        end
    end

    -- local profile_tag = nil

    if (#OutTargetList > 0) then
        local BeSelectedPriorityTarget = nil
        local TargetUnitList = {}
        for i = 1, #OutTargetList do
           if (CurrSelectedTarget == OutTargetList[i]) then
                BeSelectedPriorityTarget = OutTargetList[i]
           else
                -- 提取数值
                local TargetUnit = SelectTargetBase:GetUnUsedTarget()
                TargetUnit.Actor = OutTargetList[i]             
                -- profile_tag = _G.UE.FProfileTag("GetValueBy22")   
                TargetUnit.Value = GetValueBySkillSelectType(Executor, OutTargetList[i], ResSkillTargetSelect.SelectType, ResSkillTargetSelect.Attr)
                -- profile_tag:End()
                table.insert(TargetUnitList, TargetUnit)
           end
        end
        _G.TableTools.ClearTable(OutTargetList)

        if (#TargetUnitList > 1) then
            --进行排序
            if (ResSkillTargetSelect.SelectFunc == ProtoRes.skill_select_func_type.SKILL_SELECT_FUNC_MAX) then
                table.sort(TargetUnitList, SortByCompareGreater)

            elseif (ResSkillTargetSelect.SelectFunc == ProtoRes.skill_select_func_type.SKILL_SELECT_FUNC_MIN) then
                table.sort(TargetUnitList, SortByCompareLess)

            elseif (ResSkillTargetSelect.SelectFunc == ProtoRes.skill_select_func_type.SKILL_SELECT_FUNC_RAND) then
                SortByRandom(TargetUnitList)
            end
        end
        
        if (#TargetUnitList > 0) then
            --之前选择的目标不是技能目标，或者之前没选中目标的情况
            if not bForbidChangeTarget and not CurrSelectedTarget then
                local ActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)

                local ScreenSize = UIUtil.GetViewportSize()
                local UActorUtil = _G.UE.UActorUtil
                local IsFixTargetHit = SelectTargetBase:GetIsFixTargetHit()

                for i = #TargetUnitList, 1, -1 do
                    local TargetActor = TargetUnitList[i].Actor

                    if not IsFixTargetHit or UActorUtil.IsActorInScreen(TargetActor, ScreenSize) then
                        if ActorUtil.CheckBlockByActionPos(ActionPos, TargetActor) then
                            CurrSelectedTarget = TargetUnitList[1].Actor
                            BeSelectedPriorityTarget = CurrSelectedTarget
                            break
                        end
                    else
                        table.remove(TargetUnitList, i)
                    end
                end
            end
        end

        if not bForbidChangeTarget then
            if CurrSelectedTarget then
                local AttrComp = CurrSelectedTarget:GetAttributeComponent()
                if AttrComp then
                    _G.SelectTargetMgr:SkillSelectTarget(AttrComp.EntityID)
                end
            end

            local bIsContinue
            for i = #TargetUnitList, 1, -1 do
                local TargetActor = TargetUnitList[i].Actor

                do
                    local _ <close> = CommonUtil.MakeProfileTag("InArea2")
                    bIsContinue = SelectTargetAreaFilter:TargetIsInArea(Executor, TargetActor)
                end
                if not bIsContinue then
                    table.remove(TargetUnitList, i)
                end
            end
        end

        local Num = 0
        local HaveTargetBlocked = false
        --优先选择
        if (BeSelectedPriorityTarget ~= nil) then
            local UseSelectedTarget = true
            --这么搞的话玩家理解成本有点高，策划结论：让玩家自己取消目标选择或者手动选不满血的人就行
            -- local SkillClass = SelectTargetBase:GetSkillClass()
            -- local Flag = ProtoRes.skill_class.SKILL_CLASS_HEAL
            -- --治疗技能
            -- if (SkillClass & Flag) ~= 0 then
            --     local AttributeComponent = BeSelectedPriorityTarget:GetAttributeComponent()
            --     if nil ~= AttributeComponent then
            --         local CurrHP = AttributeComponent:GetCurHp()
            --         local MaxHP = AttributeComponent:GetMaxHp()
            --         UseSelectedTarget = (CurrHP < MaxHP) --血量已满，避免无效和过量治疗
            --     end 
            -- end

            if (UseSelectedTarget) then
                --不能直接拿Executor和target连，因为有选点的技能
                --所以是ActionPos
                local ActionPos = nil
                if SelectTargetBase.IsSelectTargetHit then
                    ActionPos = Executor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
                else
                    ActionPos = SelectTargetBase:GetSkillActionPos()
                end

                if ActorUtil.CheckBlockByActionPos(ActionPos
                    , BeSelectedPriorityTarget) then
                    table.insert(OutTargetList, BeSelectedPriorityTarget)
                    Num = Num + 1
                else
                    HaveTargetBlocked = true
                end
            end
        end

        --取出指定数量的目标
        if not HaveTargetBlocked or not SelectTargetBase.IsSelectTargetHit then
            for i = 1, #TargetUnitList do
                if (Num >= ResSkillTargetSelect.SelectCount) then
                    break
                end
    
                local TargetActor = TargetUnitList[i].Actor
                --不能直接拿Executor和target连，因为有选点的技能
                --所以是ActionPos
                if Executor == TargetActor or
                    ActorUtil.CheckBlockByActionPos(SelectTargetBase:GetSkillActionPos(), TargetActor) then
                    table.insert(OutTargetList, TargetActor)
                    Num = Num + 1
                else
                    HaveTargetBlocked = true
                end
            end
        end

        SelectTargetBase.HaveTargetBlocked = HaveTargetBlocked

        SelectTargetBase:RecycleTargets(TargetUnitList)
    end
end

--执行选怪
local function ExecuteSelect(SelectID, VisionActorList, Executor)
    --选怪结果列表
    local OutTargetList = {}
    do
        local _ <close> = CommonUtil.MakeProfileTag("FirstSelect")
        ExecuteFirstSelect(SelectID, VisionActorList, OutTargetList, Executor)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("SecondSelect")
        ExecuteSecondSelect(SelectID, OutTargetList, Executor)
    end
    return OutTargetList
end


local SelectTargetFilter = {}
--过滤目标列表
function SelectTargetFilter:FilterTargets(Executor, VisionActorList)
    local SelectTargetList = {}

    if (nil == Executor or nil == VisionActorList) then
        return SelectTargetList
    end

    local ConditionStr = SelectTargetBase:GetSkillHitTargetConditionStr()
    if (ConditionStr ~= "" and ConditionStr ~= nil) then
        local ConditionArray = _G.StringTools.StringSplit(ConditionStr, "/")
        for index = 1, #ConditionArray do
            local CurConditionStr = ConditionArray[index]

            local SelectID = tonumber(CurConditionStr)
            --配的纯数字
            if (SelectID) then
                SelectTargetList = ExecuteSelect(SelectID, VisionActorList, Executor)
            else
                SelectTargetList = RPNGenerator:ExecuteRPNListExpression(CurConditionStr, Executor, VisionActorList, ExecuteSelect)
            end

            if SelectTargetList and #SelectTargetList > 0 then
                return SelectTargetList
            end
        end
    end

    if (SelectTargetList == nil) then
        SelectTargetList = {}
    end

    return SelectTargetList
end

local function ExecuteCheckTaskUseItemTargets(SelectID, VisionActorList, Executor)
    --todo 根据SelectID取得目标筛选表数据
    local ResSkillTargetSelect = SelectTargetBase:GetResSkillTargetSelect(SelectID)
    if (nil == ResSkillTargetSelect) then
        return {}
    end
    local OutTargetList = {}

    local profile_tag = nil
    local ActorCnt = #VisionActorList
    for i = 1, ActorCnt, 1 do
        local Target = ActorUtil.GetActorByEntityID(VisionActorList[i])
        while (Target ~= nil) do
            local bIsContinue =  true
            --目标是否符合技能筛选条件
            --默认都满足
            do
                local _ <close> = CommonUtil.MakeProfileTag("ConditionExpr")
                if (ResSkillTargetSelect.ConditionExpr ~= "" and ResSkillTargetSelect.ConditionExpr ~= nil) then
                    bIsContinue = RPNGenerator:ExecuteRPNBoolExpression(ResSkillTargetSelect.ConditionExpr, Executor, Target, TargetIsConformCondition)
                end
            end
            if (not bIsContinue) then
                break
            end

            table.insert(OutTargetList, Target)
            break --这个break千万不能删掉！！
        end
    end
    return OutTargetList
end

--判定技能条件，忽略范围等
function SelectTargetFilter:CheckTaskUseItemTargets(Executor, ActorList)
    local SelectTargetList = {}

    if (nil == Executor or nil == ActorList) then
        return SelectTargetList
    end

    local ConditionStr = SelectTargetBase:GetSkillHitTargetConditionStr()
    if (ConditionStr ~= "" and ConditionStr ~= nil) then
        local ConditionArray = _G.StringTools.StringSplit(ConditionStr, "/")
        for index = 1, #ConditionArray do
            local CurConditionStr = ConditionArray[index]

            local SelectID = tonumber(CurConditionStr)
            --配的纯数字
            if (SelectID) then
                SelectTargetList = ExecuteCheckTaskUseItemTargets(SelectID, ActorList, Executor)
            else
                SelectTargetList = RPNGenerator:ExecuteRPNListExpression(CurConditionStr, Executor, ActorList, ExecuteCheckTaskUseItemTargets)
            end

            if SelectTargetList and #SelectTargetList > 0 then
                return SelectTargetList
            end
        end
    end

    if (SelectTargetList == nil) then
        SelectTargetList = {}
    end

    return SelectTargetList
end

local function ExecuteCheckSkillTargets(SelectID, VisionActorList, Executor)
    local OutTargetList = {}

    --todo 根据SelectID取得目标筛选表数据
    local ResSkillTargetSelect = SelectTargetBase:GetResSkillTargetSelect(SelectID)
    if (nil == ResSkillTargetSelect) then
        return OutTargetList
    end

    local profile_tag = nil
    local ActorCnt = #VisionActorList
    for i = 1, ActorCnt, 1 do
        local Target = VisionActorList[i]
        while (Target ~= nil) do
            local bIsContinue =  true
            --判断是否符合目标类型
            do
                local _ <close> = CommonUtil.MakeProfileTag("ConfirmType")
                bIsContinue = TargetIsConformTargetType(Executor, Target, ResSkillTargetSelect)
            end
            if (not bIsContinue) then
                break
            end

            do
                local _ <close> = CommonUtil.MakeProfileTag("ConditionExpr")
                if (ResSkillTargetSelect.ConditionExpr ~= "" and ResSkillTargetSelect.ConditionExpr ~= nil) then
                    bIsContinue = RPNGenerator:ExecuteRPNBoolExpression(ResSkillTargetSelect.ConditionExpr, Executor, Target, TargetIsConformCondition)
                end
            end
            if (not bIsContinue) then
                break
            end

            table.insert(OutTargetList, Target)
            break --这个break千万不能删掉！！
        end
    end

    return OutTargetList
end

--判定是不是技能目标，忽略范围
function SelectTargetFilter:CheckSkillTargets(Executor, ActorList)
    local SelectTargetList = {}

    if (nil == Executor or nil == ActorList) then
        return SelectTargetList
    end

    local ConditionStr = SelectTargetBase:GetSkillHitTargetConditionStr()
    if (ConditionStr ~= "" and ConditionStr ~= nil) then
        local ConditionArray = _G.StringTools.StringSplit(ConditionStr, "/")
        for index = 1, #ConditionArray do
            local CurConditionStr = ConditionArray[index]

            local SelectID = tonumber(CurConditionStr)
            --配的纯数字
            if (SelectID) then
                SelectTargetList = ExecuteCheckSkillTargets(SelectID, ActorList, Executor)
            else
                SelectTargetList = RPNGenerator:ExecuteRPNListExpression(CurConditionStr, Executor, ActorList, ExecuteCheckSkillTargets)
            end

            if SelectTargetList and #SelectTargetList > 0 then
                return SelectTargetList
            end
        end
    end

    if (SelectTargetList == nil) then
        SelectTargetList = {}
    end

    return SelectTargetList
end

--目标是否符合技能目标类型，提供给外部调用(这里不支持技能子表中目标筛选字符串是表达式的情况，也不支持配置/的情况)
function SelectTargetFilter:CheckTargetIsConformTargetType(Executor, Target,  SubSkillID)
    local ConditionStr = SelectTargetBase:GetSkillHitTargetConditionStr(SubSkillID)
    local SelectID = tonumber(ConditionStr)
    if (not SelectID) then
        return false
    end
    local ResSkillTargetSelect = SelectTargetBase:GetResSkillTargetSelect(SelectID)
    return TargetIsConformTargetType(Executor, Target,  ResSkillTargetSelect)
end

local SkillConditionCfg = require("TableCfg/SkillConditionCfg")
-- 同栏位多技能替换条件判断
local function MultiSkillReplaceCondition(Executor, Target, ConditionID)
    if (nil == Executor) then
        return false
    end

    local ResSkillCondition = SkillConditionCfg:FindCfgByKey(ConditionID)
    if (nil == ResSkillCondition) then
        return false
    end
    -- 只判定自身条件且没有获取到Target的情况
    if(ResSkillCondition.ObjectType and ResSkillCondition.ObjectType == ProtoRes.skill_object_type.SKILL_OBJECT_TYPE_CASTER) then
        Target = Executor
    end
    if(nil == Target) then
        return false
    end
    local Value = GetValueBySkillSelectType(Executor, Target, ResSkillCondition.Type, ResSkillCondition.Param1, ResSkillCondition.ObjectType)
    local ConfigValue = ResSkillCondition.Param2
    --进行比较
    if (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_EQ) then
        return Value == ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_LT) then
        return Value < ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_LE) then
        return Value <= ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_GT) then
        return Value > ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_GE) then
        return Value >= ConfigValue
    elseif (ResSkillCondition.Sign == ProtoRes.condition_sign.CONDITION_SIGN_NE) then
        return Value ~= ConfigValue
    end

    return false
end
function SelectTargetFilter:MultiSkillReplaceCheck(ConditionExpr, Executor, Target)
    return RPNGenerator:ExecuteRPNBoolExpression(ConditionExpr, Executor, Target, MultiSkillReplaceCondition)
end

return SelectTargetFilter