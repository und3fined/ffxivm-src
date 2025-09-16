-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CombatStatCfg : CfgBase
local CombatStatCfg = {
	TableName = "c_combat_stat_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CombatStatCfg, { __index = CfgBase })

CombatStatCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return CombatStatCfg
