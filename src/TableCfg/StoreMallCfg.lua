-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StoreMallCfg : CfgBase
local StoreMallCfg = {
	TableName = "c_store_mall_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MainCategory',
            },
            {
                Name = 'SubCategory',
            },
            {
                Name = 'SubCategory',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(StoreMallCfg, { __index = CfgBase })

StoreMallCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StoreMallCfg
