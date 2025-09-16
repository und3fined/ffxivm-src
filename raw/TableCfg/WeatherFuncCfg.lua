-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WeatherFuncCfg : CfgBase
local WeatherFuncCfg = {
	TableName = "c_weather_func_cfg",
    LruKeyType = nil,
	KeyName = "WeatherPlanID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(WeatherFuncCfg, { __index = CfgBase })

WeatherFuncCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return WeatherFuncCfg
