-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BuddyGlobalCfg : CfgBase
local BuddyGlobalCfg = {
	TableName = "c_buddy_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BuddyGlobalCfg, { __index = CfgBase })

BuddyGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BuddyGlobalCfg
