-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CatalystCfg : CfgBase
local CatalystCfg = {
	TableName = "c_catalyst_cfg",
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

setmetatable(CatalystCfg, { __index = CfgBase })

CatalystCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CatalystCfg
