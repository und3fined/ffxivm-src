-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FootPrintTypeCfg : CfgBase
local FootPrintTypeCfg = {
	TableName = "c_FootPrint_Type_cfg",
    LruKeyType = nil,
	KeyName = "ID",
	Localization = {
        Config = {
            {
                Name = 'ShowText',
            },
            {
                Name = 'CompText',
            },
            {
                Name = 'CountName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FootPrintTypeCfg, { __index = CfgBase })

FootPrintTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FootPrintTypeCfg
