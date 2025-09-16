-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BuddySkillCfg : CfgBase
local BuddySkillCfg = {
	TableName = "c_buddy_skill_cfg",
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
            {
                Name = 'Duration',
            },
            {
                Name = 'AdditionalEffects',
            },
            {
                Name = 'SkillType',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BuddySkillCfg, { __index = CfgBase })

BuddySkillCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BuddySkillCfg
