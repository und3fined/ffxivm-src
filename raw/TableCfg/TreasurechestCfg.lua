-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TreasurechestCfg : CfgBase
local TreasurechestCfg = {
	TableName = "c_treasurechest_cfg",
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

setmetatable(TreasurechestCfg, { __index = CfgBase })

TreasurechestCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TreasurechestCfg
