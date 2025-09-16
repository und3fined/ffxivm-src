-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WeatherRegionCfg : CfgBase
local WeatherRegionCfg = {
	TableName = "c_weather_region_cfg",
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

setmetatable(WeatherRegionCfg, { __index = CfgBase })

WeatherRegionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WeatherRegionCfg
