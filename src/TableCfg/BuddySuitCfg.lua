-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BuddySuitCfg : CfgBase
local BuddySuitCfg = {
	TableName = "c_buddy_suit_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Description',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BuddySuitCfg, { __index = CfgBase })

BuddySuitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BuddySuitCfg
