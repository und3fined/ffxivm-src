-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FoodsCfg : CfgBase
local FoodsCfg = {
	TableName = "c_foods_cfg",
    LruKeyType = nil,
	KeyName = "ItemID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FoodsCfg, { __index = CfgBase })

FoodsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FoodsCfg
