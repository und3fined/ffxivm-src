-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CompanionGlobalCfg : CfgBase
local CompanionGlobalCfg = {
	TableName = "c_companion_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CompanionGlobalCfg, { __index = CfgBase })

CompanionGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CompanionGlobalCfg
