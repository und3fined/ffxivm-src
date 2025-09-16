-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BuddyCfg : CfgBase
local BuddyCfg = {
	TableName = "c_buddy_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BuddyCfg, { __index = CfgBase })

BuddyCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BuddyCfg
