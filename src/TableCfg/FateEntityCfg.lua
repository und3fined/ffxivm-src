-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateEntityCfg : CfgBase
local FateEntityCfg = {
	TableName = "c_fate_entity_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateEntityCfg, { __index = CfgBase })

FateEntityCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateEntityCfg
