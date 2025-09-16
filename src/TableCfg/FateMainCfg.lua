-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateMainCfg : CfgBase
local FateMainCfg = {
	TableName = "c_fate_main_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'ProgressTitle',
            },
            {
                Name = 'FateSpecialText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateMainCfg, { __index = CfgBase })

FateMainCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateMainCfg
