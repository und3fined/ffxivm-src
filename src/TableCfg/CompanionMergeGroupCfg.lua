-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CompanionMergeGroupCfg : CfgBase
local CompanionMergeGroupCfg = {
	TableName = "c_CompanionMergeGroup_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
            {
                Name = 'Expository',
            },
            {
                Name = 'Cry',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CompanionMergeGroupCfg, { __index = CfgBase })

CompanionMergeGroupCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CompanionMergeGroupCfg
