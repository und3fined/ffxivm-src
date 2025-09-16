-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AchievementCategoryCfg : CfgBase
local AchievementCategoryCfg = {
	TableName = "c_AchievementCategory_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Category',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(AchievementCategoryCfg, { __index = CfgBase })

AchievementCategoryCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return AchievementCategoryCfg
