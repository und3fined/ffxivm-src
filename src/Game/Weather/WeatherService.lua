--[[
    v_hggzhang 23-03-16
    # 天气预报算法
    - 保持结构和服务一致，方便对比查看
]]

local MapWeatherCfg = require("TableCfg/MapWeatherCfg")
local WeatherRateCfg = require("TableCfg/WeatherRateCfg")
local Weather = require("Game/Weather/Weather")


local TimeDefine = require("Define/TimeDefine")
local AozyTimeDefine = TimeDefine.AozyTimeDefine

local TimeUtil = require("Utils/TimeUtil")
local FLOG_ERROR = _G.FLOG_ERROR

local M = {}

-- ChangeEqRealSecsWeather 地球时间1400秒=艾欧泽亚8小时，天气变更一次，175*8=1400
local ChangeEqRealSecsWeather = 1400
-- ChangeFreqWeather 天气预报变化小时数
local ChangeFreqWeather = 8
-- ForecastCount 天气预报个数
local ForecastCount = 30

local Mask = 0x00000000FFFFFFFF

--[[
    MapWeaher = {
        MapID,
        Seed,
        Weathers = Arr[]
    }
]]

function M.Update(MapWeaher)
    local t = TimeUtil.GetServerTime() - ChangeEqRealSecsWeather
    local Seed = M.GetSeed(t)
    if MapWeaher.Seed == Seed then return end

    local Cfg = MapWeatherCfg:FindCfgByKey(MapWeaher.MapID)
    if not Cfg then
        FLOG_ERROR(string.format("Error: WeatherService update mapID = %d is not exist", MapWeaher.MapID))
        return
    end

    local Scheme = Cfg.Scheme
    for Idx = 1, ForecastCount do
        MapWeaher.Weathers[Idx] = M.GetWeather(Scheme, M.GetWeatherRate(t))
        t = t + ChangeEqRealSecsWeather
    end

    -- print("zhg UpdateWeatherServer = " .. table_to_string_block(MapWeaher))

    MapWeaher.Seed = Seed
end

function M.GetWeatherRate(t)
    local Seed = M.GetSeed(t)
    local Step1 = (Seed << 11) ~ Seed
    
    Step1 = Step1 & Mask
    local Step2 = (Step1 >> 8) ~ Step1
    local WeatherRate = Step2 % 100

    return WeatherRate
end

function M.GetSeed(t)
    local Hour = math.floor(t / AozyTimeDefine.BellEqRealSecs)
    local Day = math.floor(t / AozyTimeDefine.SunEqRealSecs)
    local Chunk = (Hour + ChangeFreqWeather - (Hour % ChangeFreqWeather)) % AozyTimeDefine.BellsEverySun

    return Day * 100 + Chunk
end

function M.GetWeather(WeatherPlanID, Rate)
    local Cfg = WeatherRateCfg:FindCfgByKey(WeatherPlanID)
    -- print("zhg GetWeather Scheme = " .. Scheme)
    if not Cfg then return Weather.WeatherInfo.EXD_WEATHER_SUNY end

    local RightBound = 0
    local WIdx = 1

    for Idx, _ in ipairs(Cfg.Weather) do
        RightBound = RightBound + Cfg.Rate[Idx]
        WIdx = Idx
        if Rate < RightBound then
            break
        end
    end

    return Cfg.Weather[WIdx]
end

return M