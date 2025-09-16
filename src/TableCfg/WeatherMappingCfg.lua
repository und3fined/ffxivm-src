-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WeatherMappingCfg : CfgBase
local WeatherMappingCfg = {
	TableName = "c_weather_mapping_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(WeatherMappingCfg, { __index = CfgBase })

WeatherMappingCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WeatherMappingCfg
