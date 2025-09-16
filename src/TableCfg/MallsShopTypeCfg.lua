-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MallsShopTypeCfg : CfgBase
local MallsShopTypeCfg = {
	TableName = "c_MallsShopType_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ShopType',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MallsShopTypeCfg, { __index = CfgBase })

MallsShopTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MallsShopTypeCfg
