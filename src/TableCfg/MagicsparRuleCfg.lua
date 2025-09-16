-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MagicsparRuleCfg : CfgBase
local MagicsparRuleCfg = {
	TableName = "c_magicspar_rule_cfg",
    LruKeyType = nil,
	KeyName = "MateID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MagicsparRuleCfg, { __index = CfgBase })

MagicsparRuleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function MagicsparRuleCfg:FindRuleCfg(InEquipProperty, InItemMainType)
	local SearchConditions = string.format("EquipProperty = %d and ItemMainType = %d", 
	InEquipProperty, InItemMainType)
	return self:FindCfg(SearchConditions)
end

return MagicsparRuleCfg
