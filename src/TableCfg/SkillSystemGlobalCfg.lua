-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SkillSystemGlobalCfg : CfgBase
local SkillSystemGlobalCfg = {
	TableName = "c_skill_system_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        ID = 1,
        _Value = '["2.0.0"]',
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            _Value = '["1","2","3","4","5","8","9","11"]',
        },
        {
            ID = 3,
            _Value = '["1","2","3","4","5","8","9","13"]',
        },
        {
            ID = 4,
            _Value = '["2.1.0"]',
        },
	},
}

setmetatable(SkillSystemGlobalCfg, { __index = CfgBase })

SkillSystemGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SkillSystemGlobalCfg
