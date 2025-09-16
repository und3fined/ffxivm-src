-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AchievementTypeCfg : CfgBase
local AchievementTypeCfg = {
	TableName = "c_AchievementType_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TypeName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(AchievementTypeCfg, { __index = CfgBase })

AchievementTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return AchievementTypeCfg
