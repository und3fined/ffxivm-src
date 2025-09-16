-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StoreCouponCfg : CfgBase
local StoreCouponCfg = {
	TableName = "c_store_coupon_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(StoreCouponCfg, { __index = CfgBase })

StoreCouponCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StoreCouponCfg
