-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ScreenerClassificationCfg : CfgBase
local ScreenerClassificationCfg = {
	TableName = "c_screener_classification_cfg",
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

setmetatable(ScreenerClassificationCfg, { __index = CfgBase })

ScreenerClassificationCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ScreenerClassificationCfg
