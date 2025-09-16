-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RideSkillCfg : CfgBase
local RideSkillCfg = {
	TableName = "c_ride_skill_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SkillName',
            },
            {
                Name = 'SkillTag',
            },
            {
                Name = 'SingTimeDescribe',
            },
            {
                Name = 'SkillDescribe',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RideSkillCfg, { __index = CfgBase })

RideSkillCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return RideSkillCfg
