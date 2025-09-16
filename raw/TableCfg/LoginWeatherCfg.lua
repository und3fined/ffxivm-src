-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LoginWeatherCfg : CfgBase
local LoginWeatherCfg = {
	TableName = "c_login_weather_cfg",
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

setmetatable(LoginWeatherCfg, { __index = CfgBase })

LoginWeatherCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LoginWeatherCfg
