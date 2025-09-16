-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BuddyAiCfg : CfgBase
local BuddyAiCfg = {
	TableName = "c_buddy_ai_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BuddyAiCfg, { __index = CfgBase })

BuddyAiCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BuddyAiCfg
