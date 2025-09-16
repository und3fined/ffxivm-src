-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AccessoryExistCfg : CfgBase
local AccessoryExistCfg = {
	TableName = "c_accessory_exist_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(AccessoryExistCfg, { __index = CfgBase })

AccessoryExistCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return AccessoryExistCfg
