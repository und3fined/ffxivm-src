local BuffDefine = require("Game/Buff/BuffDefine")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")

local ProtoRes = require("Protocol/ProtoRes")
local BuffCfg = require("TableCfg/BuffCfg")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")
local BonusStateBuffCfg = require("TableCfg/BonusStateBuffCfg")

-- 副本Buff数值修正表，后续可能会有多个。Key = 职能 * 1000000 + 角色等级 * 1000 + 副本等级
local SkillEffectFixAttrCfg = require("TableCfg/SkillEffectFixAttrCfg")

local M = {}

---@param Params FCombatBuff
---@return BuffVMParams
function M.CombatBuff2BuffVMParams(EntityID, BuffID, Params)
    local Cfg = BuffCfg:FindCfgByKey(BuffID)
    if nil == Cfg then return end
    return {
        BuffSkillType = BuffDefine.BuffSkillType.Combat,
        BuffID = Params.BuffID,
        EntityID = EntityID,
        GiverID = Cfg.IsIndependent > 0 and Params.Giver or 0,  -- 独立buff才考虑GiverID
        ExpdTime = Params.ExpdTime,
        Pile = Params.Pile or 0,
        Cfg = Cfg,
        IsEffective = true,  -- 主角的Buff有单独的事件控制
        IsBuffTimeDisplay = (Cfg.IsBuffTimeDisplay == 1),
        BuffRemoveType = ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION,
        RemainingCount = 1,
        IsEternal = (Params.ExpdTime == 0),
        AddTime = Params.AddTime,
    }
end

---@param Params LifeSkillBuffInfo @see LifeSkillBuffMgr:AddBuff(...)
---@return BuffVMParams
function M.LifeSkillBuff2BuffVMParams(EntityID, BuffID, Params)
    local Cfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if nil == Cfg then return end
    return {
        BuffSkillType = BuffDefine.BuffSkillType.Life,
        BuffID = Params.BuffID,
        EntityID = EntityID,
        GiverID = Params.GiverID,
        ExpdTime = Params.ExpdTime,
        Pile = Params.Pile or 0,
        Cfg = Cfg,
        IsEffective = true,
        IsBuffTimeDisplay = Params.IsBuffTimeDisplay,
        BuffRemoveType = Params.BuffRemoveType,
        RemainingCount = Params.RemainingCount,
        IsEternal = false,
        AddTime = Params.AddedTime,
    }
end

---@param Params BonusState
---@return BuffVMParams
function M.BonusState2BuffVMParams(EntityID, BuffID, Params)
    local Cfg = BonusStateBuffCfg:FindCfgByKey(BuffID)
    if nil == Cfg then return end
    return {
        BuffSkillType = BuffDefine.BuffSkillType.BonusState,
        BuffID = Params.ID,
        EntityID = EntityID,
        GiverID = 0,
        ExpdTime = Params.EndTime * 1000,
        Pile = 0,
        Cfg = Cfg,
        IsEffective = Params.Enable,
        IsBuffTimeDisplay = true,
        BuffRemoveType = ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION,
        RemainingCount = 1,
        IsEternal = (Params.EndTime == 0),
        AddTime = 0,
    }
end

---@param Params BuffVMParams
function M.CheckBuffDisplay(Params)
    if table.is_nil_empty(Params) then return false end

    local Cfg = Params.Cfg
    if Cfg.DisplayType == BuffDefine.BuffDisplayActiveType.Normal then return false end  -- DisplayType 填Normal不显示
    if Cfg.IconDisplayWeight < 0 then return false end  -- IconDisplayWeight < 0 不显示

    -- 加成状态支持配置仅自己可见
    if Params.BuffSkillType == BuffDefine.BuffSkillType.BonusState and
        Cfg.PrivateVisible == 1 and
        not MajorUtil.IsMajor(Params.EntityID) then
        return false
    end

    return true
end

function M.GetEntityBuffVMParamsList(EntityID, WithBonusState)
    local Values = {}
    local CombatBuffInfos = _G.SkillBuffMgr:GetActorBuffInfos(EntityID)
    for _, BuffInfo in ipairs(CombatBuffInfos or {}) do
        local Value = M.CombatBuff2BuffVMParams(EntityID, BuffInfo.BuffID, BuffInfo)
        if nil ~= Value and M.CheckBuffDisplay(Value) then
            table.insert(Values, Value)
        end
    end

    local LifeBuffInfos = _G.LifeSkillBuffMgr:GetBuffList(EntityID)
    for _, BuffInfo in ipairs(LifeBuffInfos or {}) do
        local Value = M.LifeSkillBuff2BuffVMParams(EntityID, BuffInfo.BuffID, BuffInfo)
        if nil ~= Value and M.CheckBuffDisplay(Value) then
            table.insert(Values, Value)
        end
    end

    if WithBonusState then
        local BonusStates = _G.BonusStateMgr:GetBonusStatesByEntityID(EntityID)
        for _, State in ipairs(BonusStates or {}) do
            local Value = M.BonusState2BuffVMParams(EntityID, State.ID, State)
            if nil ~= Value and M.CheckBuffDisplay(Value) then
                table.insert(Values, Value)
            end
        end
    end

    return Values
end

---SortBuffDisplay
---@param Lhs ActorBufferVM
---@param Rhs ActorBufferVM
---@return boolean 返回true代表将Lhs放在前面
function M.SortBuffDisplay(Lhs, Rhs)
    -- 1. 类型：战斗buff > 生产职业buff > 加成状态
    if Lhs.BuffSkillType ~= Rhs.BuffSkillType then
        return Lhs.BuffSkillType < Rhs.BuffSkillType  ---@see BuffDefine.BuffSkillType
    end

    -- 2. 自己施加的buff > 别人施加的buff
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if (Lhs.GiverID == MajorEntityID and Rhs.GiverID ~= MajorEntityID) or 
        (Lhs.GiverID ~= MajorEntityID and Rhs.GiverID == MajorEntityID) then
        return Lhs.GiverID == MajorEntityID
    end

    -- 3. 增减益：减益>增益
    if Lhs.BuffActiveType ~= Rhs.BuffActiveType then
        return Lhs.BuffActiveType > Rhs.BuffActiveType  ---@see BuffDefine.BuffDisplayActiveType
    end

    -- 4. 权重：权重越大越靠前
    if Lhs.Weight ~= Rhs.Weight then
        return Lhs.Weight > Rhs.Weight
    end

    -- 5. 计时or计次：计时buff在前
    if Lhs.BuffRemoveType ~= Rhs.BuffRemoveType then
        return Lhs.BuffRemoveType > Rhs.BuffRemoveType  ---@see ProtoRes.REMOVE_TYPE
    end

    -- 6. Buff添加时间：越晚的越靠前
    if Lhs.AddTime ~= Rhs.AddTime then
        return Lhs.AddTime > Rhs.AddTime
    end

    -- 7. 保底按照ID排序，ID越小越靠前
    return Lhs.BuffID < Rhs.BuffID
end

function M.GetLeftTimeSecondByExpdTime(ExpdTime)
    local ServerTime = TimeUtil.GetServerTimeMS()
    local LeftTime = (ExpdTime - ServerTime) / 1000
    LeftTime = math.floor(LeftTime + 0.5)
    LeftTime = LeftTime >= 0 and LeftTime or 0
    return LeftTime
end

function M.GetLeftTimeMSByExpdTime(ExpdTime)
    local ServerTime = TimeUtil.GetServerTimeMS()
    local LeftTime = (ExpdTime - ServerTime)
    LeftTime = LeftTime > 0 and LeftTime or 0
    return LeftTime
end

local LSTR = _G.LSTR
local BuffSmartLeftTimeUnit = {
    {Format = LSTR(500008), Sec = 24 * 60 * 60},  -- %d天
    {Format = LSTR(500009), Sec = 60 * 60},  -- %d小时
    {Format = LSTR(500010), Sec = 60},  -- %d分
    {Format = LSTR(500011), Sec = 1},  -- %d秒
}

function M.GetBuffSmartLeftTime(Time)
    if type(Time) ~= "number" then
        FLOG_ERROR("BuffUIUtil.GetBuffSmartLeftTime(): Time is not number.")
        return ""
    end

    local Lens = #BuffSmartLeftTimeUnit
    for Index = 1, Lens do
        local Unit = BuffSmartLeftTimeUnit[Index]
        local Value = math.floor(Time / Unit.Sec)
        if Value > 0 then
            return string.format(Unit.Format, Value)
        end
    end
    return string.format(BuffSmartLeftTimeUnit[Lens].Format, 0)
end

------------------ Begin Dynamic Buff Desc ------------------
-- 有一些Buff会在运行时动态变更属性（即根据副本等级、角色等级、角色职能变更buff属性），需要特殊处理

---解析从Buff表中读取的Tag字段
---@param Tag string 以","分割的多个数字组成的字符串
---@return table Tag中的所有token组成的列表
function M.GetAllTokenFromBuffTag(Tag)
    local Result = {}
    for Num in string.gmatch(Tag, "%d+") do
        table.insert(Result, tonumber(Num))
    end
    return Result
end

---判断Buff是否需要支持动态属性数据描述
---@param Tag string Buff表中读取的Tag字段
---@return boolean
function M.HasDynamicBuffDesc(Tag)
    if nil ~= Tag then
        local Tokens = M.GetAllTokenFromBuffTag(Tag)
        for _, Token in ipairs(Tokens) do
            if Token == BuffDefine.DynamicBuffDescTag then return true end
        end
    end
    return false
end

---简化版富文本Parser，仅识别<attr offset=-1></>
local DynamicDescAttributeFormat = "<attr offset=(-?%d+)></>"

---技能属性修正表中条目需要按照一定的优先级进行查询，从高到低分别是：
---  1. 既配了角色等级，又配了副本等级
---  2. 只配了副本等级
---  3. 只配了角色等级
local function QuerySkillEffectFixAttrCfg(ClassType, RoleLevel, SceneLevel)
    -- ID = 职能 * 1000000 + 角色等级 * 1000 + 副本等级
    local Cfg = SkillEffectFixAttrCfg:FindCfgByKey(ClassType * 1000000 + RoleLevel * 1000 + SceneLevel)
    if nil == Cfg then
        Cfg = SkillEffectFixAttrCfg:FindCfgByKey(ClassType * 1000000 + SceneLevel)
    end
    if nil == Cfg then
        Cfg = SkillEffectFixAttrCfg:FindCfgByKey(ClassType * 1000000 + RoleLevel * 1000)
    end
    return Cfg and Cfg.Value or 0
end

---转换（翻译）从表中读取的Desc
---@param Desc string 从表中读取的Desc字符串
---@param ClassType number 角色职能
---@param RoleLevel number 角色等级。注意这里的角色等级是角色真实等级，而不是副本下调后的
---@param SceneLevel number 副本等级
function M.TranslateDynamicBuffDesc(Desc, ClassType, RoleLevel, SceneLevel)
    if type(Desc) ~= "string" then
        return ""
    end

    local ResultTokens = {}

    local Index = 1
    while Index <= #Desc do
        local Begin, End, Offset = string.find(Desc, DynamicDescAttributeFormat, Index)

        if nil == Begin then
            break
        end

        if Begin > Index then
            table.insert(ResultTokens, string.sub(Desc, Index, Begin - 1))
        end
        local FixAttrValue = QuerySkillEffectFixAttrCfg(ClassType, RoleLevel, SceneLevel) * 10 ^ (tonumber(Offset) or 0)
        local FixAttrString = FixAttrValue == math.floor(FixAttrValue) and string.format("%d", FixAttrValue) or tostring(FixAttrValue)
        table.insert(ResultTokens, FixAttrString)
        Index = End + 1
    end

    if Index <= #Desc then
        table.insert(ResultTokens, string.sub(Desc, Index))
    end

    return table.concat(ResultTokens)
end

------------------ End Dynamic Buff Desc ------------------

return M
