-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BuddyEquipCfg : CfgBase
local BuddyEquipCfg = {
	TableName = "c_buddy_equip_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BuddyEquipCfg, { __index = CfgBase })

BuddyEquipCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BuddyEquipCfg
