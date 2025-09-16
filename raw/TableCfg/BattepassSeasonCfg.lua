-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BattepassSeasonCfg : CfgBase
local BattepassSeasonCfg = {
	TableName = "c_battepass_season_cfg",
    LruKeyType = nil,
	KeyName = "SeasonID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'UltimatePermissionShow',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BattepassSeasonCfg, { __index = CfgBase })

BattepassSeasonCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return BattepassSeasonCfg
