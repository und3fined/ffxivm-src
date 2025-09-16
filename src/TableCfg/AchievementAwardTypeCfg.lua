-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AchievementAwardTypeCfg : CfgBase
local AchievementAwardTypeCfg = {
	TableName = "c_AchievementAwardType_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'AwardType',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(AchievementAwardTypeCfg, { __index = CfgBase })

AchievementAwardTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return AchievementAwardTypeCfg
