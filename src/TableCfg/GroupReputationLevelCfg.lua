-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GroupReputationLevelCfg : CfgBase
local GroupReputationLevelCfg = {
	TableName = "c_GroupReputationLevel_cfg",
    LruKeyType = nil,
	KeyName = "Level",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Text',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GroupReputationLevelCfg, { __index = CfgBase })

GroupReputationLevelCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return GroupReputationLevelCfg
