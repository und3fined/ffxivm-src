-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GoldSauserGateCfg : CfgBase
local GoldSauserGateCfg = {
	TableName = "c_gold_sauser_gate_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Zone',
            },
            {
                Name = 'GameName',
            },
            {
                Name = 'GameDesc',
            },
            {
                Name = 'GameInstruction',
            },
            {
                Name = 'SignUpTipContent',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GoldSauserGateCfg, { __index = CfgBase })

GoldSauserGateCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GoldSauserGateCfg
