-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DirectUpgradeCfg : CfgBase
local DirectUpgradeCfg = {
	TableName = "c_direct_upgrade_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DirectUpgradeCfg, { __index = CfgBase })

DirectUpgradeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return DirectUpgradeCfg
