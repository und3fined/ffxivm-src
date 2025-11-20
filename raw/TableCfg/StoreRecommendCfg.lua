-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StoreRecommendCfg : CfgBase
local StoreRecommendCfg = {
	TableName = "c_store_recommend_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'BtnText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(StoreRecommendCfg, { __index = CfgBase })

StoreRecommendCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StoreRecommendCfg
