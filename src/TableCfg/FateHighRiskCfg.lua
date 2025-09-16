-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateHighRiskCfg : CfgBase
local FateHighRiskCfg = {
	TableName = "c_fate_high_risk_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
            {
                Name = 'ShortTitle',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateHighRiskCfg, { __index = CfgBase })

FateHighRiskCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateHighRiskCfg
