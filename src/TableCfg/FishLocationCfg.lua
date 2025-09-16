-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FishLocationCfg : CfgBase
local FishLocationCfg = {
	TableName = "c_fish_location_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FishLocationCfg, { __index = CfgBase })

FishLocationCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FishLocationCfg
