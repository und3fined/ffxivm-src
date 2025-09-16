-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GrandCompanyCfg : CfgBase
local GrandCompanyCfg = {
	TableName = "c_grand_company_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GrandCompanyCfg, { __index = CfgBase })

GrandCompanyCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GrandCompanyCfg
