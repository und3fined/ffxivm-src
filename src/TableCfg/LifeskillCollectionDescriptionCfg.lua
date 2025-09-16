-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LifeskillCollectionDescriptionCfg : CfgBase
local LifeskillCollectionDescriptionCfg = {
	TableName = "c_lifeskill_collection_description_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(LifeskillCollectionDescriptionCfg, { __index = CfgBase })

LifeskillCollectionDescriptionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LifeskillCollectionDescriptionCfg
