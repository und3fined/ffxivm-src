-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FateAchievementMultiEventCfg : CfgBase
local FateAchievementMultiEventCfg = {
	TableName = "c_fate_achievement_multi_event_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'DescriptionText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FateAchievementMultiEventCfg, { __index = CfgBase })

FateAchievementMultiEventCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FateAchievementMultiEventCfg
