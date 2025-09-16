-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class WeatherForecastCfg : CfgBase
local WeatherForecastCfg = {
	TableName = "c_weather_forecast_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MapName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(WeatherForecastCfg, { __index = CfgBase })

WeatherForecastCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

-- function WeatherCfg:FindCfgByKeyAdv(WeatherID)
--     WeatherID = WeatherMappingCfg:FindValue(WeatherID, "Mapping") or WeatherID
    
-- 	local Cfg = self:FindCfgByKey(WeatherID)
-- 	if nil == Cfg then
-- 		return
-- 	end

-- 	return Cfg.Icon
-- end

function WeatherForecastCfg:FindAllAdv()
    local Ret = {}

    local All = self:FindAllCfg()

    for _, Item in pairs(All or {}) do
        if Item.IsShow == 1 then
            table.insert(Ret, Item)
        end
    end

    return Ret
end

return WeatherForecastCfg
