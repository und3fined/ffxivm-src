local WeatherService = require("Game/Weather/WeatherService")
local MapWeatherCfg = require("TableCfg/MapWeatherCfg")
local WeatherMgr = _G.WeatherMgr
local TimeDefine = require("Define/TimeDefine")
local AozyTimeDefine = TimeDefine.AozyTimeDefine
local FLOG_ERROR = _G.FLOG_ERROR
local TimeUtil = require("Utils/TimeUtil")
local WeatherUtil = require("Game/Weather/WeatherUtil")

local M = {}

function M.GetTimeShow(Cnt)
    if Cnt < 1 then
        return {}
    end

    local CurrentTime = WeatherUtil.GetCurrWeatherPeriodStartBell()

    local Ret = {}
    for Idx = 1, Cnt do
        local Text = string.format("%02d", (CurrentTime - 16 + Idx * 8) % 24)
        Ret[Idx] = Text
    end

    return Ret
end

return M