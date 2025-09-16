---
--- Author: frankjfwang
--- DateTime: 2022-05-20 17:43
--- Description:
---
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local Log = require("Game/MagicCard/Module/Log")
local CardRuleCfg = require("TableCfg/FantasyCardRuleCfg")

local table = table
local format = string.format

local GameRulesDebugString = ""

---@class GameRuleService
---@field GameRules RuleConfig[] @本局规则
local GameRuleService = {}

function GameRuleService:SetGameRules(SvrRules)
    if not SvrRules or #SvrRules == 0 then
        self.GameRules = {}
        GameRulesDebugString = "No Rule."
        return
    end

    self.GameRules = MagicCardVMUtils.GetRuleConfigListSorted(SvrRules)
    GameRulesDebugString = "Rules: "
    for _, r in ipairs(self.GameRules) do
        GameRulesDebugString = string.format("%s[%d, %s]", GameRulesDebugString, r.Rule, r.RuleText)
    end
    Log.I(GameRulesDebugString)
end

function GameRuleService:HasRule(...)
    if self.GameRules == nil then
        return false
    end
    
    local RuleIdSet = table.pack(...)
    for _, RuleId in ipairs(RuleIdSet) do
        for _, RuleCfg in ipairs(self.GameRules) do
            if RuleCfg.Rule == RuleId then
                return true
            end
        end
    end
    return false
end

function GameRuleService.GetRuleName(RuleId)
    if RuleId == 0 then
        return "普通规则"
    end

    local RuleCfg = CardRuleCfg:FindCfgByKey(RuleId)
    if RuleCfg then
        return RuleCfg.RuleText
    else
        return format("错误Rule: %s", RuleId)
    end
end

function GameRuleService.GameRulesDebugString()
    return GameRulesDebugString
end

return GameRuleService
