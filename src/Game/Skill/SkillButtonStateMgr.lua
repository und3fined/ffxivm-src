local MajorUtil = require("Utils/MajorUtil")


local SkillButtonStateMgr = {
    --按钮状态优先级由上到下依次降低
    --按钮禁用提示仅依据优先级最高的状态，如优先级最高状态未配置提示则无提示
    --添加新状态可能要更新当前所有状态的索引
    SkillBtnState = {
        SkillLearn = 1,        --技能是否学习
        CrafterSkillState = 2,  --制作技能是否可用
        EnterFishingArea = 3,   --进出渔场
        FishState = 4,          --钓鱼状态
        Swimming_Fly = 5,          --游泳、飞行、潜水禁用
        SkillCDMask = 6,        --[TODO]这个没用，回头干掉
        ReChargeMask = 7,       --[TODO]这个没用，回头干掉
        CanUseMoveSkill = 8,    --是否可用位移技能
        BuffCondition = 9,      --BUFF条件
        SkillMP = 10,            --蓝量不足
        UseStatus = 11,         --战斗状态(仅战斗、仅脱战)
        SkillGP = 12,            --采集力不足
        GatherDurationMax = 13, --采集职业耐久满  高产技能不能释放
        SkillWeight = 14,       --技能权重
        GatherStateCannotDiscover = 15, --不能寻矿
        GatherHighProduceCnt = 16, --采集职业高产技能2次已经用完了
        GatherAddItemNum = 17,      --采集职业 莫非王土技能；  生效后不能再次释放该技能
        PVPLB = 18,              --PVP的极限技
        PVPQTE = 19,             --PVP的QTE技(目前只有黑魔)

        ValidStateMaxIndex = 19,
        SkillState_Max = 30,
        --技能无关：无回调参数
        SkillBtnControl = 31,   --吟唱禁用按钮
        IsFishingAnim = 32,     -- 正在钓鱼进行中，无法使用技能
        GatherSkillCasting = 33,  -- 策划希望使用采集技能时屏蔽其他所有技能
        SimpleGathering = 34,   --正在简易采集ing，不能使用技能
        CanUseSkill = 35,        --不可使用技能状态
        Dead = 36,               -- 放技能的玩家死亡
    }
}

local State = SkillButtonStateMgr.SkillBtnState
local MsgTipsID = require("Define/MsgTipsID")
local SkillMainCfg = require("TableCfg/SkillMainCfg")

local LSTR = _G.LSTR

local SkillButtonStateTips = {
    [State.SkillMP] = LSTR(140069),  -- 魔力不足
    [State.EnterFishingArea] = LSTR(140070),  -- 还未进入钓场
    [State.Swimming_Fly] = LSTR(80017), -- 当前状态无法使用
    [State.SkillGP] = LSTR(140071),  -- 采集力不足
    [State.GatherDurationMax] = MsgTipsID.GatherDurationMax,
    [State.GatherHighProduceCnt] = MsgTipsID.GatherHighProduceCnt,
    [State.GatherAddItemNum] = MsgTipsID.GatherAddItemNum,
    [State.SimpleGathering] = MsgTipsID.SimpleGathering,
    [State.GatherStateCannotDiscover] = MsgTipsID.GatherStateCannotDiscover,
    [State.CanUseSkill] = MsgTipsID.GatherCurStateInvalid,  --当前状态无法使用
}

--Buff条件参数为SkillID
SkillButtonStateTips[State.BuffCondition] = function(_, SkillID)
    -- if type(Params) == "table" then
    --     local str=""
    --     local BuffName =""
    --     local num=#Params
    --     if Params.ExcludeBuffList ~= nil and type(Params.ExcludeBuffList) == "table" and #Params.ExcludeBuffList > 0 then
    --         for index, value in ipairs(Params.ExcludeBuffList) do
    --             BuffName = BuffCfg:FindValue(value.BuffID, "BuffName") or "NULL"
    --                 str=str..BuffName
    --                 if index < #Params.ExcludeBuffList then
    --                     str=str..'、'
    --                 end
    --             end
    --             return nil, string.format(LSTR(140083), LSTR(str))
    --     end

    --     if Params.AtLeastoneRelayBuffList ~= nil and type(Params.AtLeastoneRelayBuffList) == "table" and #Params.AtLeastoneRelayBuffList > 0 then
    --         for index, value in ipairs(Params.AtLeastoneRelayBuffList) do
    --             BuffName = BuffCfg:FindValue(value.BuffID, "BuffName") or "NULL"
    --                 str=str..BuffName
    --                 if index < #Params.AtLeastoneRelayBuffList then
    --                     str=str..'、'
    --                 end
    --             end
    --             return nil, string.format(LSTR(140073), LSTR(str))
    --     end

    --     if Params.MustAllRelayBuffList ~= nil and type(Params.MustAllRelayBuffList) == "table" and #Params.MustAllRelayBuffList > 0 then
    --         for index, value in ipairs(Params.MustAllRelayBuffList) do
    --             BuffName = BuffCfg:FindValue(value.BuffID, "BuffName") or "NULL"
    --                 str=str..BuffName
    --                 if index < #Params.MustAllRelayBuffList then
    --                     str=str..'、'
    --                 end
    --             end
    --             return nil, string.format(LSTR(140073), LSTR(str))
    --     end
    --     return nil, string.format(LSTR(140072), LSTR(str))
    -- else
    --     local BuffName = BuffCfg:FindValue(Params, "BuffName") or "NULL"
    --     return nil, string.format(LSTR(140073), BuffName)
    -- end
    local BuffLimitTipsID = SkillMainCfg:FindValue(SkillID, "BuffLimitTipsID")
    if (BuffLimitTipsID ~= nil and BuffLimitTipsID ~= 0) then
        _G.MainProSkillMgr:UseSkillNotSummon(BuffLimitTipsID)
        return BuffLimitTipsID, nil
    end
end

SkillButtonStateTips[State.SkillLearn] = function(Params)
    --仅特职可用
    if Params then
        if Params < 0 then
            return MsgTipsID.SkillLearnAdvanceTips, nil
        else
            --return MsgTipsID.SkillLearnLevelTips, nil
            --TODO[chaooren]2501 系统提示表有冲突，合入主干后改用上面一行代码
            return nil, string.format(LSTR("%d级解锁"), Params)
        end
    end
end

SkillButtonStateTips[State.UseStatus] = function()
    local bMajorCombat = MajorUtil.IsMajorCombat()
    if bMajorCombat then
        return MsgTipsID.SkillDisableNormal
    else
        return MsgTipsID.SkillDisableCombat
    end
end


SkillButtonStateMgr.ButtonStateTips = SkillButtonStateTips


--除了这部分flag，其他始终affect
local bSkillButtonStateConditionAffectedFlag = 
{
    [State.EnterFishingArea] = true,
    [State.FishState] = true,
    [State.BuffCondition] = true,
    [State.SkillMP] = true,
    [State.SkillGP] = true,
    [State.GatherDurationMax] = true,
    [State.GatherHighProduceCnt] = true,
    [State.GatherAddItemNum] = true,
    [State.GatherStateCannotDiscover] = true,
}
SkillButtonStateMgr.bSkillButtonStateConditionAffectedFlag = bSkillButtonStateConditionAffectedFlag

return SkillButtonStateMgr