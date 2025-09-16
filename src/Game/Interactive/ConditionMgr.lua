
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local BuffMgr = require("Game/Skill/SkillBuffMgr")
local LifeBuffMgr = require("Game/Skill/LifeSkillBuffMgr")
local CounterMgr = require("Game/Counter/CounterMgr")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local ArmyDefine = require("Game/Army/ArmyDefine")

local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCondType = ProtoRes.CondType
local CondFuncRelate = ProtoRes.CondFuncRelate
local MapAreaMgr = require("Game/PWorld/MapAreaMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local CondCfg = require("TableCfg/CondCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local ProfClassCfg = require("TableCfg/ProfClassCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TransCfg = require("TableCfg/TransCfg")
-- Proto
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =    ProtoCS.CS_QUEST_STATUS
local TARGET_STATUS =   ProtoCS.CS_QUEST_NODE_STATUS
-- local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")

local FLOG_ERROR = _G.FLOG_ERROR

local ConditionMgr = LuaClass()

CondFailReason = CondFailReason or
{
    AreaLimit = 1,	-- 区域限制
    ProfLimit = 2,	-- 职业限制
    LevelLimit = 3,	-- 等级限制
    ItemLimit = 4,	-- 物品数量
    NpcLimit = 5,	-- NPC限制
    TeamLimit = 6,	-- 队伍限制
    BuffLimit = 7,	-- 技能BUFF
    LifeSkill = 8,	-- 生活BUFF
    RideLimit = 9,	-- 骑乘状态
    EquipLimit = 10,	-- 穿戴装备
    EquipLevelLimit = 11,	-- 装备品级
    SceneFinishLimit = 12,	-- 完成副本
    EobjLimit = 13,	        -- EOBJ限制
    QuestLimit = 14,	    -- 任务状态限制
    MonsterLimit = 15,	    -- 怪物限制
	SceneLimit = 16,        -- 副本限定
	GenderLimit = 17,       -- 性别限制
	RaceLimit = 18,         -- 种族限制
    ScoreLimit = 19,        -- 积分数量
    QuestTargetLimit = 20,  --任务目标状态

    EntityCreateTimeLimit = 23, --实体创建时间限制
    CounterDetection = 24,      --计数器检测
    GrandCompanyLimit = 25,    --军团限制
    GrandCompanyMilitaryRankLimit = 26,  --军衔等级限制
    GroupLimit = 33, --部队限制
    GroupGrandCompanyLimit = 34, --部队国防联军限制
    TouringBandLimit = 42, --乐团应援次数限制
    TouringBandConditionLimit = 43, --乐团关键条件限制
    ModuleUnLockLimit = 45, --模块解锁限制
    GuessCardPlayerLimit = 50,  -- 强欲陷阱玩家限制
    PointlessTeleportationLimit = 52, -- 原地传送限制
    --特殊的额外的类型，比如NPC限制的时候，npc的resid符合条件，但是距离太远了
    TooFar = 1001,	    -- 距离太远了
}

function ConditionMgr:CheckConditionByID(ConditionID, ConditionParams, IsShowErrorTips)
    local Cond = CondCfg:FindCfgByKey(ConditionID)
    if Cond then
        return self:CheckCondition(Cond, ConditionParams, IsShowErrorTips)
    end

    return true
end

-- IsShowErrorTips 是否显示tips
-- ConditionParams 目前只有LimitValue1，NPC限制的时候用的到
-- 返回值是2个参数
    -- 第一个 true：成功  false：失败
    -- 第二个 CondFailReasonList，记录失败的reason，是一个map： [CondFailReason, true/false/nil]
function ConditionMgr:CheckCondition(ConditionCfg, ConditionParams, IsShowErrorTips)
    return self:DoCheckCondition(ConditionCfg, ConditionParams, IsShowErrorTips)
end

function ConditionMgr:DoCheckCondition(ConditionCfg, ConditionParams, IsShowErrorTips)
	if ConditionCfg then
		local CondRelate = ConditionCfg.CondFuncRelate --或/并

		local CondFailReasonList = {}
        local bHaveShowTips = false

        self.CondFailedTipsID = 0
        local TipsID = 0

		if CondRelate == CondFuncRelate.OR then	-- 或条件
            --任一个ok，都会返回true
            for _, Cond in pairs(ConditionCfg.Cond) do
                if Cond.Type ~= ItemCondType.CondTypeNone then
                    CondFailReasonList[Cond.Type] = true
    
                    local Rlt = self:CheckSubCond(Cond, ConditionParams, CondFailReasonList)
    
                    if Rlt then
                        return true
                    else
                        self.CondFailedTipsID = Cond.FailedTipsID or 0
                    end
                end
            end

            if self.CondFailedTipsID > 0 then
                TipsID = self.CondFailedTipsID
            elseif ConditionCfg and ConditionCfg.FailedTipsID > 0 then
                TipsID = ConditionCfg.FailedTipsID
            end
            
            if TipsID > 0 and IsShowErrorTips then
                bHaveShowTips = true
                _G.MsgTipsUtil.ShowTipsByID(TipsID)
            end

            --之前没有return，所以判定失败
            return false, CondFailReasonList, bHaveShowTips
		else -- 并条件
            local Rlt = false
            --任一个不行，都会返回false，判定失败
            for _, Cond in pairs(ConditionCfg.Cond) do
                if Cond.Type ~= ItemCondType.CondTypeNone then
                    CondFailReasonList[Cond.Type] = true
    
                    Rlt = self:CheckSubCond(Cond, ConditionParams, CondFailReasonList)
                    if not Rlt then
                        self.CondFailedTipsID = Cond.FailedTipsID or 0
                        if self.CondFailedTipsID > 0 then
                            TipsID = self.CondFailedTipsID
                        elseif ConditionCfg and ConditionCfg.FailedTipsID and ConditionCfg.FailedTipsID > 0 then
                            TipsID = ConditionCfg.FailedTipsID
                        end

                        if TipsID > 0 and IsShowErrorTips then
                            bHaveShowTips = true
                            _G.MsgTipsUtil.ShowTipsByID(TipsID)
                        end

                        return false, CondFailReasonList, bHaveShowTips
                    end
                end
            end

            --之前没有return，所以判定成功
            return true
		end
	end

	return false
end

function ConditionMgr:CheckSubCond(Cond, ConditionParams, CondFailReasonList)
    local Rlt = false

    if Cond.Type == ItemCondType.AreaLimit  then        -- 区域限制
        Rlt = self:CheckArea(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.ProfLimit then	    -- 职业限制
        Rlt = self:CheckProf(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.LevelLimit then    -- 等级限制
        Rlt = self:CheckLevel(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.ItemLimit then     -- 物品数量
        Rlt = self:CheckItem(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.NpcLimit then      -- NPC限制
        --LimitValue1 是Npc的ResID
        Rlt = self:CheckNpc(Cond, CondFailReasonList, ConditionParams)
    elseif Cond.Type == ItemCondType.TeamLimit then     -- 队伍限制
        Rlt = self:CheckTeam(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.BuffLimit then     -- 技能BUFF
        Rlt = self:CheckBuff(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.LifeSkill then     -- 生活BUFF
        Rlt = self:CheckLifeBuff(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.RideLimit then     -- 骑乘状态
        Rlt = self:CheckRideState(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.EquipLimit then    -- 穿戴装备
        Rlt = self:CheckEquip(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.EquipLevelLimit then       -- 装备品级
        Rlt = self:CheckEquipLevel(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.SceneFinishLimit then      -- 完成副本
        Rlt = self:CheckFinishScene(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.EobjLimit then             -- EObj限制
        Rlt = self:CheckEObj(Cond, CondFailReasonList, ConditionParams)
    elseif Cond.Type == ItemCondType.QuestLimit then            -- 任务状态
        Rlt = self:CheckQuest(Cond, CondFailReasonList, ConditionParams)
    elseif Cond.Type == ItemCondType.TargetMonsterLimit then            -- 怪物id限制
        Rlt = self:CheckMonster(Cond, CondFailReasonList, ConditionParams)
	elseif Cond.Type == ItemCondType.RaceLimit then
		Rlt = self:CheckRace(Cond, CondFailReasonList)
	elseif Cond.Type == ItemCondType.GenderLimit then
		Rlt = self:CheckGender(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.ScoreLimit then
        Rlt = self:CheckScore(Cond, CondFailReasonList)
	elseif Cond.Type == ItemCondType.QuestTargetLimit then
		Rlt = self:CheckQuestTarget(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.MagicCardTourneyLimit then
        Rlt = self:CheckMagicCardTourney(Cond, CondFailReasonList, ConditionParams)
    elseif Cond.Type == ItemCondType.GoldSauserOpportunitySignState then
        Rlt = self:CheckGoldSauserSignupState(Cond)
    elseif Cond.Type == ItemCondType.EntityCreateTimeLimit then
        Rlt = self:CheckEntityCreateTimeLimit(Cond, CondFailReasonList, ConditionParams)
    elseif Cond.Type == ItemCondType.CounterDetection then
        Rlt = self:CheckCounterDetection(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.JumboCactpotLimit then
        Rlt = self:CheckJumboCactpot(Cond)
    elseif Cond.Type == ItemCondType.MysterMerchantQuestLimit then
        Rlt = self:CheckMysterMerchant(Cond)               
    elseif Cond.Type == ItemCondType.GrandCompanyLimit then
        Rlt = self:CheckGrandCompany(Cond, CondFailReasonList)   
    elseif Cond.Type == ItemCondType.GrandCompanyMilitaryRankLimit then
        Rlt = self:CheckGrandCompanyMilitaryRank(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.GroupLimit then
        Rlt = self:CheckArmy(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.GroupGrandCompanyLimit then
        Rlt = self:CheckArmyGrandCompany(Cond, CondFailReasonList)                     
    elseif Cond.Type == ItemCondType.SceneLimit then
        Rlt = self:CheckSingScene(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.TouringBandLimit then
        Rlt = self:CheckTouringBandLimit(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.TouringBandConditionLimit then
        Rlt = self:CheckTouringBandConditionLimit(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.ModuleUnLockLimit then
        Rlt = self:CheckModuleOpenLimit(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.CrystalActiveLimit then
        Rlt = self:CheckCrystalActiveLimit(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.GuessCardPlayerLimit then
        Rlt = self:CheckGuessCardPlayerLimit(Cond, CondFailReasonList)
    elseif Cond.Type == ItemCondType.PointlessTeleportationLimit then
        Rlt = self:CheckPointlessTeleportationLimit(Cond, CondFailReasonList)
    else -- 默认是放开检测的，所以新增类型得如上处理（注意CondFailReasonList）
        CondFailReasonList[Cond.Type] = false
        Rlt = true
    end

    return Rlt
end

function ConditionMgr:Test()
    -- local P = {
    --     Condition = {
    --         [1] = {
    --             CondType = ProtoRes.interaction_func_cond_type.INTERACTION_FUNC_COND_TYPE_HASITEM,
    --             CondValue = {
    --                 [1] = 1,
    --                 [2] = 60000018,
    --                 [3] = 10,
    --                 [4] = 60000019,
    --                 [5] = 10,
    --             }
    --         }
    --     }
    -- }

    -- self:CheckEnableCommon(P, nil)
end

function ConditionMgr:CheckArea(Cond, CondFailReasonList)
    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local CurrMapAreaID = MapAreaMgr.CurrAreaID

    if Cond.Value[1] == CurrPWorldResID then
        if Cond.Value[2] == nil or Cond.Value[2] == CurrMapAreaID then
            CondFailReasonList[CondFailReason.AreaLimit] = false
            return true
        end
    end

    return false
end

function ConditionMgr:CheckProf(Cond, CondFailReasonList)
	local ProfID = MajorUtil.GetMajorProfID()
    if ProfID and ProfID > 0 then
        local CheckType = Cond.Value[1]
        if CheckType == 0 then      --职业的限定
            for index = 2, 3 do
                local Prof = Cond.Value[index]
                if Prof and Prof > 0 and ProfID == Prof then
                    CondFailReasonList[CondFailReason.ProfLimit] = false
                    return true
                end
            end
        elseif CheckType == 1 then  --职业类的限定
            for index = 2, 3 do
                local ProfClass = Cond.Value[index]
                if ProfClass and ProfClass > 0 then
                    local ProfList = ProfClassCfg:FindValue(ProfClass, "Prof")
                    if ProfList then
                        for _, SubProf in ipairs(ProfList) do
                            if ProfID == SubProf then
                                CondFailReasonList[CondFailReason.ProfLimit] = false
                                return true
                            end
                        end
                    end
                end
            end
        elseif CheckType == 2 then  --职能的限定
            for index = 2, 3 do
                local ProfFunction = Cond.Value[index]
                if ProfFunction and ProfFunction > 0 then
                    local Function = RoleInitCfg:FindValue(ProfID, "Function")
                    if Function and Function == ProfFunction then
                        CondFailReasonList[CondFailReason.ProfLimit] = false
                        return true
                    end
                end
            end
        end
    end

    return false
end

function ConditionMgr:CheckLevel(Cond, CondFailReasonList)
    if Cond.Value[1] then
        local MajorLevel = MajorUtil.GetMajorLevel()
        if not MajorLevel or Cond.Value[1] > MajorLevel then
            return  false
        end
    end

    CondFailReasonList[CondFailReason.LevelLimit] = false
    return  true
end

function ConditionMgr:CheckNpc(Cond, CondFailReasonList, ConditionParams)
    local NpcResID = 0
    local EntityID = 0
    if ConditionParams then
        NpcResID = ConditionParams.LimitValue1
        EntityID = ConditionParams.EntityID or 0
    end

    if NpcResID == 0 then
        return false
    end

    if Cond.Value[1] then
        if Cond.Value[1] ~= NpcResID then
            return false
        end
    end

    local NpcActor
    if EntityID ~= 0 then
        NpcActor = ActorUtil.GetActorByEntityID(EntityID)
    else
        NpcActor = ActorUtil.GetActorByResID(NpcResID)
    end

    if NpcActor == nil then
        FLOG_ERROR("ConditionMgr:CheckNpc NPC %d not found", NpcResID)
        return false
    end

    local LimitDistance = 1000
    if Cond.Value[2] and Cond.Value[2] > 0 then
        LimitDistance = Cond.Value[2]
    end

	local Major = MajorUtil.GetMajor()
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local NpcPos = NpcActor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    local Dist = _G.UE.FVector.Dist(MajorPos, NpcPos)
    if Dist > LimitDistance then    --超出距离限制，也不符合条件
        CondFailReasonList[CondFailReason.TooFar] = true
        return false
    end

    CondFailReasonList[CondFailReason.NpcLimit] = false
    return  true
end

function ConditionMgr:CheckItem(Cond, CondFailReasonList)
    local ItemID = Cond.Value[1]
    local CompareType = Cond.Value[2]
    local CompareNum = Cond.Value[3]

    local Ret = false
    if ItemID and ItemID > 0 then
        local ItemNum =  _G.BagMgr:GetItemNum(ItemID) or 0
        if CompareType == 0 then        --小于等于
            Ret = ItemNum <= CompareNum
        elseif CompareType == 1 then    --大于等于
            Ret = ItemNum >= CompareNum
        end
    end

    if Ret then
        CondFailReasonList[CondFailReason.ItemLimit] = false
    end

    return  Ret
end

function ConditionMgr:CheckTeam(Cond, CondFailReasonList)
    local CompareType = Cond.Value[1]
    local CompareTeamMemNum = Cond.Value[2]
    if CompareType and CompareTeamMemNum then
        if CompareType == 0 and CompareTeamMemNum == 0
            and not _G.TeamMgr:IsInTeam() then
            CondFailReasonList[CondFailReason.ItemLimit] = false
            return true
        end

        local Ret = false
        if CompareType == 0 then        --小于等于
            Ret = _G.TeamMgr:GetMemberNum() <= CompareTeamMemNum
        elseif CompareType == 1 then    --大于等于
            Ret = _G.TeamMgr:GetMemberNum() >= CompareTeamMemNum
        end

        if Ret then
            CondFailReasonList[CondFailReason.TeamLimit] = false
            return true
        end
    end

    return  false
end

function ConditionMgr:CheckBuff(Cond, CondFailReasonList)
    local CompareType = Cond.Value[1]
    local BuffID1 = Cond.Value[2]
    local BuffID2 = Cond.Value[3]

    local Buff1Pile = 0
    if BuffID1 and BuffID1 > 0 then
        Buff1Pile = BuffMgr:GetBuffHighestPileByID(BuffID1)
    end

    local Buff2Pile = 0
    if BuffID2 and BuffID2 > 0 then
        Buff2Pile = BuffMgr:GetBuffHighestPileByID(BuffID2)
    end

    local Ret = false
    if CompareType == 0 then        --无buff中的任一个
        if BuffID1 and BuffID1 > 0 and BuffID2 and BuffID2 > 0
            and Buff1Pile == 0 and Buff2Pile == 0 then
            Ret = true
        end
    elseif CompareType == 1 then    --有所有buff
        Ret = true
        if BuffID1 and BuffID1 > 0 and Buff1Pile <= 0 then
            Ret = false
        end

        if BuffID2 and BuffID2 > 0 and Buff2Pile <= 0 then
            Ret = false
        end
    elseif CompareType == 2 then    --有其中之一
        if BuffID1 and BuffID1 > 0 and Buff1Pile > 0 then
            Ret = true
        end

        if BuffID2 and BuffID2 > 0 and Buff2Pile > 0 then
            Ret = true
        end
    end

    if Ret then
        CondFailReasonList[CondFailReason.BuffLimit] = false
        return true
    end

    return false
end

-- 生活buff暂时没有层数
function ConditionMgr:CheckLifeBuff(Cond, CondFailReasonList)
    local CompareType = Cond.Value[1]
    local BuffID1 = Cond.Value[2]
    local BuffID2 = Cond.Value[3]

    local HaveBuff1 = false
    if BuffID1 and BuffID1 > 0 then
        HaveBuff1 = LifeBuffMgr:IsMajorContainBuff(BuffID1)
    end

    local HaveBuff2 = false
    if BuffID2 and BuffID2 > 0 then
        HaveBuff2 = LifeBuffMgr:IsMajorContainBuff(BuffID2)
    end

    local Ret = false
    if CompareType == 0 then        --无buff中的任一个
        if BuffID1 and BuffID1 > 0 and BuffID2 and BuffID2 > 0
            and not HaveBuff1 and not HaveBuff2 then
            Ret = true
        end
    elseif CompareType == 1 then    --有所有buff
        Ret = true
        if BuffID1 and BuffID1 > 0 and not HaveBuff1 then
            Ret = false
        end

        if BuffID2 and BuffID2 > 0 and not HaveBuff2 then
            Ret = false
        end
    elseif CompareType == 2 then    --有其中之一
        if BuffID1 and BuffID1 > 0 and HaveBuff1 then
            Ret = true
        end

        if BuffID2 and BuffID2 > 0 and HaveBuff2 then
            Ret = true
        end
    end

    if Ret then
        CondFailReasonList[CondFailReason.LifeSkill] = false
        return true
    end

    return false
end

--当前还没有此功能
function ConditionMgr:CheckRideState(Cond, CondFailReasonList)
    CondFailReasonList[CondFailReason.RideLimit] = false
    return  true
end

function ConditionMgr:CheckEquip(Cond, CondFailReasonList)
    local EquipPart = Cond.Value[1]
    local EquipID = Cond.Value[2]

    local EquipItem = nil
    local Ret = false
    --如果14的话，9或者10任一个都可以
    if EquipPart == ProtoCommon.equip_part.EQUIP_PART_FINGER then
        EquipItem = _G.EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER)
        --先检查9
        if EquipItem and EquipItem.ResID and EquipItem.ResID == EquipID then
            Ret = true
        --然后检测10
        else
            EquipItem = _G.EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER)
            if EquipItem and EquipItem.ResID and EquipItem.ResID == EquipID then
                Ret = true
            end
        end
    else
        EquipItem = _G.EquipmentMgr:GetEquipedItemByPart(EquipPart)
        if EquipItem and EquipItem.ResID and EquipItem.ResID == EquipID then
            Ret = true
        end
    end

    if Ret then
        CondFailReasonList[CondFailReason.EquipLimit] = false
        return true
    end

    return  true
end

function ConditionMgr:CheckEquipLevel(Cond, CondFailReasonList)
    local EquipPart = Cond.Value[1]
    local EquipLevel = Cond.Value[2]

    local EquipItem = _G.EquipmentMgr:GetEquipedItemByPart(EquipPart)
    if EquipItem and EquipItem.ResID then
        local EquipedItemCfg = ItemCfg:FindCfgByKey(EquipItem.ResID)
        if EquipedItemCfg and EquipedItemCfg.ItemLevel >= EquipLevel then
            CondFailReasonList[CondFailReason.EquipLevelLimit] = false
            return true
        end
    end

    return  false
end

function ConditionMgr:CheckFinishScene(Cond, CondFailReasonList)
    CondFailReasonList[CondFailReason.SceneFinishLimit] = false
    return  true
end

function ConditionMgr:CheckEObj(Cond, CondFailReasonList, ConditionParams)
    local EObjID = 0
    local EntityID = 0
    if ConditionParams then
        EObjID = ConditionParams.LimitValue1
        EntityID = ConditionParams.EntityID or 0
    end

    if EObjID == 0 then
        return false
    end

    if Cond.Value[1] then
        if Cond.Value[1] ~= EObjID then
            return false
        end
    end

    local EObjActor
    if EntityID ~= 0 then
        EObjActor = ActorUtil.GetActorByEntityID(EntityID)
    else
        EObjActor = ActorUtil.GetActorByResID(EObjID)
    end

    if EObjActor == nil then
        _G.FLOG_ERROR("ConditionMgr:CheckEObj %d not found", EObjID)
        return false
    end

    local LimitDistance = 1000
    if Cond.Value[2] and Cond.Value[2] > 0 then
        LimitDistance = Cond.Value[2]
    end

	local Major = MajorUtil.GetMajor()
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local EObjPos = EObjActor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    local Dist = _G.UE.FVector.Dist(MajorPos, EObjPos)
    if Dist > LimitDistance then    --超出距离限制，也不符合条件
        CondFailReasonList[CondFailReason.TooFar] = true
        return false
    end

    CondFailReasonList[CondFailReason.EobjLimit] = false
    return  true
end

function ConditionMgr:CheckQuest(Cond, CondFailReasonList, ConditionParams)
    local QuestID = 0
    if Cond.Value[1] then
        QuestID = Cond.Value[1]
    end

    local LimitStatus = Cond.Value[2] or 0
    local QuestStatus = _G.QuestMgr:GetQuestStatus(QuestID)

    --进行中
    if LimitStatus == 0 and QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
        CondFailReasonList[CondFailReason.QuestLimit] = false
        return  true
    --已完成
    elseif LimitStatus == 1 and QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
        CondFailReasonList[CondFailReason.QuestLimit] = false
        return  true
    --未接取，这个要早于未完成的判定，要不一直走不到了
    elseif LimitStatus == 3 and QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
        CondFailReasonList[CondFailReason.QuestLimit] = false
        return  true
    --未完成
    elseif LimitStatus == 2 and QuestStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
        CondFailReasonList[CondFailReason.QuestLimit] = false
        return  true
    end

    return false
end

function ConditionMgr:CheckQuestTarget(Cond, CondFailReasonList, ConditionParams)
    local QuestTargetID = 0
    if Cond.Value[1] then
        QuestTargetID = Cond.Value[1]
    end

    local LimitStatus = Cond.Value[2] or 0
    local QuestTargetStatus = _G.QuestMgr:GetTargetStatus(QuestTargetID)

    --进行中
    if LimitStatus == 0 and QuestTargetStatus == TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS then
        CondFailReasonList[CondFailReason.QuestTargetLimit] = false
        return  true
    --已完成
    elseif LimitStatus == 1 and QuestTargetStatus == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED then
        CondFailReasonList[CondFailReason.QuestTargetLimit] = false
        return  true
    --未开始，这个要早于未完成的判定，要不一直走不到了
    elseif LimitStatus == 3 and QuestTargetStatus == TARGET_STATUS.CS_QUEST_NODE_STATUS_NOT_STARTED then
        CondFailReasonList[CondFailReason.QuestTargetLimit] = false
        return  true
    --未完成
    elseif LimitStatus == 2 and QuestTargetStatus ~= TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED then
        CondFailReasonList[CondFailReason.QuestTargetLimit] = false
        return  true
    end

    return false
end

function ConditionMgr:CheckMonster(Cond, CondFailReasonList, ConditionParams)
    local MonsterID = 0
    if Cond.Value[1] then
        MonsterID = Cond.Value[1]
    end

    local MonsterResID = 0
    local EntityID = 0
    if ConditionParams then
        MonsterResID = ConditionParams.LimitValue1
        EntityID = ConditionParams.EntityID or 0
    end

    if MonsterResID == 0 then
        return false
    end

    if MonsterResID ~= MonsterID then
        return false
    end

    local MonsterActor
    if EntityID ~= 0 then
        MonsterActor = ActorUtil.GetActorByEntityID(EntityID)
    else
        MonsterActor = ActorUtil.GetActorByResID(MonsterResID)
    end

    if MonsterActor == nil then
        FLOG_ERROR("ConditionMgr:CheckMonster Monster %d not found", MonsterResID)
        return false
    end

    local LimitDistance = 1000
    if Cond.Value[2] and Cond.Value[2] > 0 then
        LimitDistance = Cond.Value[2]
    end

	local Major = MajorUtil.GetMajor()
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local NpcPos = MonsterActor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    local Dist = _G.UE.FVector.Dist(MajorPos, NpcPos)
    if Dist > LimitDistance then    --超出距离限制，也不符合条件
        CondFailReasonList[CondFailReason.TooFar] = true
        return false
    end

    CondFailReasonList[CondFailReason.MonsterLimit] = false
    return  true
end

function ConditionMgr:CheckRace(Cond, CondFailReasonList)
	local Race = Cond.Value[1]
	local bSuccess = MajorUtil.GetMajorRaceID() == Race
	CondFailReasonList[CondFailReason.RaceLimit] = not bSuccess
	return bSuccess
end

function ConditionMgr:CheckGender(Cond, CondFailReasonList)
	local Gender = Cond.Value[1]
	local bSuccess = MajorUtil.GetMajorGender() == Gender
	CondFailReasonList[CondFailReason.GenderLimit] = not bSuccess
	return bSuccess
end

function ConditionMgr:CheckScore(Cond, CondFailReasonList)
	local ScoreID = Cond.Value[1]
    local CompSymbol = Cond.Value[2]
    local Limit =  Cond.Value[3]
    local bSuccess = false
    if CompSymbol == ProtoRes.ValueLimit.Smaller then
        bSuccess = _G.ScoreMgr:GetScoreValueByID(ScoreID) <= Limit
	    CondFailReasonList[CondFailReason.ScoreLimit] = not bSuccess
    elseif CompSymbol == ProtoRes.ValueLimit.Greater then
        bSuccess = _G.ScoreMgr:GetScoreValueByID(ScoreID) >= Limit
        CondFailReasonList[CondFailReason.ScoreLimit] = not bSuccess
    end
	return bSuccess
end

function ConditionMgr:CheckSingScene(Cond, CondFailReasonList)
    CondFailReasonList[CondFailReason.SceneLimit] = false

    local SceneType = Cond.Value[1]
    if SceneType > 0 then
        if _G.PWorldMgr:CurrIsInSingleDungeon() then    --私人
            if SceneType & (1 << 3) ~= 0 then
                return true
            end
        elseif _G.PWorldMgr:CurrIsInDungeon() then      --副本
            if SceneType & (1 << 2) ~= 0 then
                return true
            end
        elseif _G.PWorldMgr:CurrIsInField() then        --野外
            if SceneType & (1 << 1) ~= 0 then
                return true
            end
        elseif _G.PWorldMgr:CurrIsInMainCity() then     --主城
            if SceneType & 1 ~= 0 then
                return true
            end
        end
    else
        return true
    end

    CondFailReasonList[CondFailReason.SceneLimit] = true
    return false
	-- local Gender = Cond.Value[1]
	-- local bSuccess = MajorUtil.GetMajorGender() == Gender
	-- CondFailReasonList[CondFailReason.GenderLimit] = not bSuccess
	-- return bSuccess
end

function ConditionMgr:CheckMagicCardTourney(Cond, CondFailReasonList)
    local LimitValue = Cond.Value[1]
    if LimitValue == 0 then -- 是否显示报名选项
        return _G.MagicCardTourneyMgr:IsShowInteractionSignUp()
    elseif LimitValue == 1 then -- 是否显示进入对局室选项
        return _G.MagicCardTourneyMgr:IsShowInteractionEnterTourney()
    elseif LimitValue == 2 then -- 是否显示领奖选项
        return _G.MagicCardTourneyMgr:IsShowInteractionGetReward()
    elseif LimitValue == 3 then -- 是否显示退出对局室选项
        return _G.MagicCardTourneyMgr:GetIsInTourneyRomm()
    elseif LimitValue == 4 then -- 是否可进行大赛对局
        return _G.MagicCardTourneyMgr:CanStartTourneyGame()
    end
	
	return false
end

function ConditionMgr:CheckMysterMerchant(Cond)
    local LimitValue = Cond.Value[1]
    if LimitValue == 1 then -- 是否显示提交货物选项
        return _G.MysterMerchantMgr:IsShowGoodsSubmit()
    elseif LimitValue == 2 then -- 是否显示神秘商店选项
        return _G.MysterMerchantMgr:IsShowMysterMerchant()
    elseif LimitValue == 3 then -- 是否显示冒险投资选项
        return _G.MysterMerchantMgr:IsShowInvestOption()
    end
	
	return false
end

function ConditionMgr:CheckGoldSauserSignupState(Cond)
    local GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
    if (Cond.Value ~= nil and Cond.Value[1] ~= nil and Cond.Value[1] > 0) then
        return GoldSauserMgr:GetHasSignUp() == true
    else
        return GoldSauserMgr:GetHasSignUp() == false
    end
end

function ConditionMgr:CheckEntityCreateTimeLimit(Cond, CondFailReasonList, ConditionParams)
    local CreateTime = 0
    if ConditionParams then
        CreateTime = ConditionParams.EntityCreateCreateTime
    end

    local DelayTime = Cond.Value[1]

    local CurTime = TimeUtil.GetServerTime()
	local bSuccess = false
    if CurTime - CreateTime >= DelayTime then
        bSuccess = true
    end

	CondFailReasonList[CondFailReason.EntityCreateTimeLimit] = not bSuccess
	return bSuccess
end

function ConditionMgr:CheckCounterDetection(Cond, CondFailReasonList)
    local CounterID = 0
    if Cond.Value[1] then
        CounterID = Cond.Value[1]
    end

    local CounterValue = 0
    if Cond.Value[3] then
        CounterValue = Cond.Value[3]
    end

	local bSuccess = false
    local CounterCurrValue = CounterMgr:GetCounterCurrValue(CounterID)
    if CounterCurrValue >= CounterValue then
        bSuccess = true
    end

	CondFailReasonList[CondFailReason.CounterDetection] = not bSuccess
	return bSuccess
end

function ConditionMgr:CheckJumboCactpot(Cond)
    local LimitValue = Cond.Value[1]
    local JumbCondVal = JumboCactpotDefine.JumbCondVal
    if LimitValue == JumbCondVal.CanLottery then -- 是否可以领奖
        return _G.JumboCactpotMgr:IsLottory()
    elseif LimitValue == JumbCondVal.IsExpired then -- 奖券已过期对话
        return _G.JumboCactpotMgr:IsExpired()
    elseif LimitValue == JumbCondVal.IsDuringCeremoney then -- 开奖仪式不能领奖对话
        return _G.JumboCactpotMgr:IsWaitLottory()
    elseif LimitValue == JumbCondVal.NoBuy then -- 一次没买
        return _G.JumboCactpotMgr:GetPurNumLocal() == 0
    elseif LimitValue == JumbCondVal.BuySome then -- 买了一些，但还有次数
        return _G.JumboCactpotMgr:IsExistJumbCount()
    elseif LimitValue == JumbCondVal.NoPurchases then -- 没有次数
        return not _G.JumboCactpotMgr:IsExistJumbCount()
    elseif LimitValue == JumbCondVal.ShowBuyJumbOption then -- 可以购买仙彩
        return _G.JumboCactpotMgr:CanShowBuyJumbOption()
    elseif LimitValue == JumbCondVal.ShowExplainJumbOption then -- 可以听取仙彩说明
        return _G.JumboCactpotMgr:CanShowExplainJumbOption()
    end
	
end

function ConditionMgr:CheckGrandCompany(Cond, CondFailReasonList)
    local LimitValue = Cond.Value[1]
    local CurGrandCompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
    local bSuccess = LimitValue == CurGrandCompanyInfo.GrandCompanyID
	CondFailReasonList[CondFailReason.GrandCompanyLimit] = not bSuccess
	return bSuccess
end

function ConditionMgr:CheckGrandCompanyMilitaryRank(Cond, CondFailReasonList)
    local LimitValue = Cond.Value[1]

    local bSuccess = false
    local CurGrandCompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
    if CurGrandCompanyInfo.GrandCompanyID > 0 then
        local CompanyMilitaryRank = CurGrandCompanyInfo.MilitaryLevelList[CurGrandCompanyInfo.GrandCompanyID] or 0
        bSuccess = CompanyMilitaryRank >= LimitValue 
    end
    
	CondFailReasonList[CondFailReason.GrandCompanyMilitaryRankLimit] = not bSuccess
	return bSuccess
end       

function ConditionMgr:CheckArmy(Cond, CondFailReasonList)
    local LimitValue = Cond.Value[1]

    local bSuccess = false
    local IsInvert = false
    if LimitValue == ArmyDefine.ArmyConditionEnum.IsJoin then
        if Cond.Value[2] and Cond.Value[2] == 1 then
            IsInvert = true
        end
        bSuccess = _G.ArmyMgr:IsInArmy()
    elseif LimitValue == ArmyDefine.ArmyConditionEnum.IsLeader then
        if Cond.Value[2] and Cond.Value[2] == 1 then
            IsInvert = true
        end
        bSuccess = _G.ArmyMgr:IsLeader()
    elseif  LimitValue == ArmyDefine.ArmyConditionEnum.IsHavePermisstion then
        local QueryPermisstionType = Cond.Value[2]
        if Cond.Value[3] and Cond.Value[3] == 1 then
            IsInvert = true
        end
        if QueryPermisstionType then
            bSuccess = _G.ArmyMgr:GetSelfIsHavePermisstion(QueryPermisstionType)
        end
    elseif  LimitValue == ArmyDefine.ArmyConditionEnum.IsUnlock then
        if Cond.Value[2] and Cond.Value[2] == 1 then
            IsInvert = true
        end
        local ModuleID = ProtoCommon.ModuleID
        bSuccess =  _G.ModuleOpenMgr:ModuleState(ModuleID.ModuleIDArmy)
    elseif  LimitValue == ArmyDefine.ArmyConditionEnum.IsUnlockSE then
        if Cond.Value[2] and Cond.Value[2] == 1 then
            IsInvert = true
        end
        bSuccess = _G.ArmyMgr:GetArmyPerermissionData(ArmyDefine.ArmyUpLevelPerermissionType.ArmySELevel) ~= nil
    elseif  LimitValue == ArmyDefine.ArmyConditionEnum.IsUnlockShop then
        if Cond.Value[2] and Cond.Value[2] == 1 then
            IsInvert = true
        end
        bSuccess = _G.ArmyMgr:GetArmyPerermissionData(ArmyDefine.ArmyUpLevelPerermissionType.ArmyShopLevel) ~= nil
    end
    if IsInvert then
        bSuccess = not bSuccess
    end
	CondFailReasonList[CondFailReason.GroupLimit] = not bSuccess
	return bSuccess
end  

function ConditionMgr:CheckArmyGrandCompany(Cond, CondFailReasonList)
    local LimitValues = Cond.Value

    local bSuccess = false
    local CurGrandCompanyID = _G.ArmyMgr:GetArmyUnionType()
    if nil ~= CurGrandCompanyID and CurGrandCompanyID > 0 then
        for _, LimitValue in ipairs(LimitValues) do
            if LimitValue == CurGrandCompanyID then
                bSuccess = true
                break
            end
        end
    end
    CondFailReasonList[CondFailReason.GrandCompanyMilitaryRankLimit] = not bSuccess
    return bSuccess
end  

function ConditionMgr:CheckTouringBandLimit(Cond, CondFailReasonList)
    local TouringBandDefine = require("Game/TouringBand/TouringBandDefine")
    local LimitValues = (Cond.Value or {})[1] or 0
    
    local BandID = _G.TouringBandMgr:GetCurBandID()
    local CheeringNum = _G.TouringBandMgr:GetBandCheeringNum(BandID)
    local bSuccess = (CheeringNum == LimitValues) or (CheeringNum >= TouringBandDefine.TALK_CHEERING_NUM and LimitValues == TouringBandDefine.TALK_CHEERING_NUM)
    CondFailReasonList[CondFailReason.TouringBandLimit] = not bSuccess
    return bSuccess
end

function ConditionMgr:CheckTouringBandConditionLimit(Cond, CondFailReasonList)
    local BandID = _G.TouringBandMgr:GetCurBandID()
    local MapData = _G.TouringBandMgr:GetBandMapDataByID(BandID)
    local State = ProtoCS.Game.TouringBand.BandInteractStatus.UnFinish
    if MapData ~= nil then
        State = MapData.Status
    end
    local bSuccess = State ~= ProtoCS.Game.TouringBand.BandInteractStatus.Wait
    CondFailReasonList[CondFailReason.TouringBandConditionLimit] = not bSuccess
    return bSuccess
end

function ConditionMgr:CheckModuleOpenLimit(Cond, CondFailReasonList)
    local LimitValues = (Cond.Value or {})[1] or 0
    local bSuccess = _G.ModuleOpenMgr:CheckOpenState(LimitValues)
    CondFailReasonList[CondFailReason.ModuleUnLockLimit] = not bSuccess
    return bSuccess
end

function ConditionMgr:CheckCrystalActiveLimit(Cond, CondFailReasonList)
    local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")
    local ActivatedList = CrystalPortalMgr:GetActivatedList()
    if ActivatedList and Cond and Cond.Value[1] and ActivatedList[Cond.Value[1]] then
        return false
    else
        return true
    end
end

function ConditionMgr:CheckGuessCardPlayerLimit(Cond, CondFailReasonList)
    local MajorID = MajorUtil.GetMajorRoleID()
    local OwnerID = _G.PWorldMgr and _G.PWorldMgr:GetOwnerID() or 0
    local bSuccess = MajorID == OwnerID
    CondFailReasonList[CondFailReason.GuessCardPlayerLimit] = not bSuccess
    return bSuccess
end

--- 道具使用传送原地限制
---Cond { Value1:ItemResID, Value2:LimitDis }
function ConditionMgr:CheckPointlessTeleportationLimit(Cond, CondFailReasonList)
    local LimitValues = Cond.Value or {}
    local ItemResID = LimitValues[1]
    local LimitDis = LimitValues[2]
    if not ItemResID or not LimitDis then
        CondFailReasonList[CondFailReason.PointlessTeleportationLimit] = false
        return true -- 默认没有限制
    end

	local ICfg = ItemCfg:FindCfgByKey(ItemResID)
	if not ICfg then
        FLOG_ERROR("ConditionMgr:CheckPointlessTeleportationLimit Can not find the item in itemconfig")
        CondFailReasonList[CondFailReason.PointlessTeleportationLimit] = true
		return false
    end
    local FuncCfg = FuncCfg:FindCfgByKey(ICfg.UseFunc) --物品使用没有函数调用
    if not FuncCfg then
        FLOG_ERROR("ConditionMgr:CheckPointlessTeleportationLimit Can not find the item in itemconfig")
        CondFailReasonList[CondFailReason.PointlessTeleportationLimit] = true
        return false
    end
    local Func = FuncCfg.Func
    if not Func then
        CondFailReasonList[CondFailReason.PointlessTeleportationLimit] = true
        return false
    end
    local FuncParam = Func[1].Value
    local bCommAethery = #FuncParam > 0
    local TranID
    if not bCommAethery then
        local ProfID = MajorUtil.GetMajorProfID()
        local RCfg = RoleInitCfg:FindCfgByKey(ProfID)
        if RCfg then
            TranID = RCfg.HomePlace
        end
    end

    if not TranID then
        TranID = FuncParam[1]
    end
    
    local TCfg = TransCfg:FindCfgByKey(TranID)
    if not TCfg then
        FLOG_ERROR("TransCfs Is InVaild   TranID = %s", TranID)
        CondFailReasonList[CondFailReason.PointlessTeleportationLimit] = true
        return false
    end
    local function Parse_Position(s)
        -- 初始化结果table
        local result = {}
        
        -- 去除不必要的字符并准备解析
        s = string.gsub(s, "[{}\"]", "") -- 移除大括号和双引号简化解析
        for pair in string.gmatch(s, '([^,]+)') do
            local key, value = string.match(pair, '(%u+):([-%d]+)')
            if key and value then
                result[key] = tonumber(value) -- 将值从字符串转换为数字
            end
        end
        
        return result
    end

    local TransMapId = TCfg.MapID
    local CurMapID = _G.PWorldMgr:GetCurrMapResID()
    if TransMapId == CurMapID then
        local Pos = TCfg._Position
        local PosTab = Parse_Position(Pos)--assert(load("return " .. Pos))()
        local TargetLocation = _G.UE.FVector(PosTab.X, PosTab.Y, PosTab.Z)
        local Major = MajorUtil.GetMajor()
        local MajorLoc = Major:FGetActorLocation()
        if _G.UE.FVector.Dist(MajorLoc, TargetLocation) <= LimitDis then -- 临时后面改配置
            CondFailReasonList[CondFailReason.PointlessTeleportationLimit] = true
            return false
        end
    end
    CondFailReasonList[CondFailReason.PointlessTeleportationLimit] = false
    return true
end


return ConditionMgr