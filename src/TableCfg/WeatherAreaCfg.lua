-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WeatherAreaCfg : CfgBase
local WeatherAreaCfg = {
	TableName = "c_weather_area_cfg",
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
    DefaultValues = {
        ID = 1,
    },
	LuaData = {
        {
        },
        {
            ID = 2,
        },
        {
            ID = 3,
        },
        {
            ID = 4,
        },
        {
            ID = 5,
        },
	},
}

setmetatable(WeatherAreaCfg, { __index = CfgBase })

WeatherAreaCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WeatherAreaCfg
