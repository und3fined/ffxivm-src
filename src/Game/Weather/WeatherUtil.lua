local WeatherService = require("Game/Weather/WeatherService")
local MapWeatherCfg = require("TableCfg/MapWeatherCfg")
local WeatherMgr = _G.WeatherMgr
local TimeDefine = require("Define/TimeDefine")
local AozyTimeDefine = TimeDefine.AozyTimeDefine
local FLOG_ERROR = _G.FLOG_ERROR
local TimeUtil = require("Utils/TimeUtil")

local M = {}

--- 根据地图id和轮换天气偏移获取天气ID
--- param MapID 地图ID
--- param Offset 天气轮换偏移，如当前天气 = 0， 上一个天气 = -1
function M.GetMapWeather(MapID, Offset)
    if (not MapID) or (not Offset) then
        _G.FLOG_WARNING("WeatherUtil GetMapWeather MapID or Offset is nil")
        return
    end

    local Weather = _G.WeatherMgr:GetForcastWeatherID(MapID,Offset)
    return Weather
end

---获取当前天气的开始Aozy Bell
---@return number Aozy时间，单位: 小时
function M.GetCurrWeatherPeriodStartBell()
    local AozyBell = (_G.TimeUtil.GetServerTime() + 2) * AozyTimeDefine.RealSec2AozyMin / 60  -- +2 意为加上两秒容错
    return AozyBell // 8 * 8  -- 向8取整
end

return M