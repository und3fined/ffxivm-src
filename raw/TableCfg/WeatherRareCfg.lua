-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WeatherRareCfg : CfgBase
local WeatherRareCfg = {
	TableName = "c_weather_rare_cfg",
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

setmetatable(WeatherRareCfg, { __index = CfgBase })

WeatherRareCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WeatherRareCfg
