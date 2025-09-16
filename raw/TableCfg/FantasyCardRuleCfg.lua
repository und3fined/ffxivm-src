-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FantasyCardRuleCfg : CfgBase
local FantasyCardRuleCfg = {
	TableName = "c_fantasy_card_rule_cfg",
    LruKeyType = nil,
	KeyName = "Rule",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'RuleText',
            },
            {
                Name = 'RuleDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FantasyCardRuleCfg, { __index = CfgBase })

FantasyCardRuleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FantasyCardRuleCfg
