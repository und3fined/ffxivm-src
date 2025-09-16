-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CompanysealCfg : CfgBase
local CompanysealCfg = {
	TableName = "c_companyseal_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ItemName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CompanysealCfg, { __index = CfgBase })

CompanysealCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CompanysealCfg
