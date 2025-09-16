-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SkillCdGroupCfg : CfgBase
local SkillCdGroupCfg = {
	TableName = "c_skill_cd_group_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ID = 1,
        Time = 20000,
    },
	LuaData = {
        {
            Time = 1500,
        },
        {
            ID = 2,
            Time = 2000,
        },
        {
            ID = 3,
            Time = 3000,
        },
        {
            ID = 4,
        },
        {
            ID = 5,
        },
        {
            ID = 6,
            Time = 15000,
        },
        {
            ID = 7,
            Time = 250,
        },
        {
            ID = 8,
            Time = 60000,
        },
        {
            ID = 9,
            Time = 250,
        },
        {
            ID = 10,
            Time = 8000,
        },
        {
            ID = 11,
        },
        {
            ID = 12,
            Time = 30000,
        },
        {
            ID = 13,
            Time = 5000,
        },
        {
            ID = 14,
            Time = 18000,
        },
        {
            ID = 15,
            Time = 15000,
        },
        {
            ID = 16,
            Time = 12000,
        },
        {
            ID = 17,
            Time = 15000,
        },
        {
            ID = 18,
            Time = 7000,
        },
        {
            ID = 19,
        },
        {
            ID = 20,
            Time = 15000,
        },
	},
}

setmetatable(SkillCdGroupCfg, { __index = CfgBase })

SkillCdGroupCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


return SkillCdGroupCfg
