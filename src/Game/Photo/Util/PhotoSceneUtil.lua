

local Util = {}
local TimeUtil = require("Utils/TimeUtil")

local TransTime = 0.1
local IsFixed = true
local INVALID_WEATHER = 0 --Weather.WeatherInfo.INVALID_WEATHER_ID

function Util.GetOneDaySec()
    -- local TS = TimeUtil.GetLocalTime()
    -- local DateTable = os.date("*t", TS)
    -- local Time = DateTable.hour * 3600 + DateTable.min * 60 + DateTable.sec
    -- _G.FLOG_INFO(string.format('[Photo][PhotoSceneVM][ResetWeatherAndTime2Now] h = %s, m = %s, time = %s',
    --     tostring(DateTable.hour),
    --     tostring(DateTable.min),
    --     tostring(Time)
    -- ))
    local AZTime = TimeUtil.GetAozySec()
    -- AZTime = 60 * 60 * 24 + 60 * 60 * 12
    -- print('testinfo aozy time = ' .. tostring(AZTime))
    local Time = AZTime % (60 * 60 * 24)
    -- print('testinfo Time = ' .. tostring(Time))
    return Time
end

-- Time = 0 -> 天气时间不变
function Util.SetWeatherAndTime(WeatherID, Time)
    _G.FLOG_INFO('[Photo][PhotoSceneUtil][SetWeatherAndTime] wid = %s, time = %s', WeatherID, Time)
    -- print(' zhg SetWeather Time = ' .. tostring(Time) .. " WeatherID = " .. tostring(WeatherID))
    _G.WeatherMgr:PlaySpecialClientWeatherEffect(WeatherID,TransTime,Time,IsFixed) 
end

function Util.ExitPhotoWeather()
    local Time = Util.GetOneDaySec()

    _G.FLOG_INFO('[Photo][PhotoSceneUtil][ExitPhotoWeather] wid = %s, time = %s', INVALID_WEATHER, Time)
    _G.WeatherMgr:PlaySpecialClientWeatherEffect(INVALID_WEATHER, TransTime, Time, false) 
end

function Util.PauseWeather(IsPause)
    _G.UE.UEnvMgr:Get():SetLockTime(IsPause)
end

local Path = "/Game/LightManager/FiterPresets/PostFilter"
local DarkEdgePath = "/Game/LightManager/FiterPresets/PostFilter_v0001"
-- local Path = "/Game/LightManager/LightPresets/Level/UI/EmailInterface/L_EmailInterface_LightLevel_v01"

function Util.AddFilterLevel()
    local UWorldMgr = _G.UE.UWorldMgr.Get()
    UWorldMgr:LoadDynamicLevel(Path, false)
end

function Util.RemFilterLevel()
    local UWorldMgr = _G.UE.UWorldMgr.Get()
    UWorldMgr:UnLoadLevel("PostFilter", true)
end

function Util.AddDarkEdgeLevel()
    local UWorldMgr = _G.UE.UWorldMgr.Get()
    UWorldMgr:LoadDynamicLevel(DarkEdgePath, false)
end

function Util.RemDarkEdgeLevel()
    local UWorldMgr = _G.UE.UWorldMgr.Get()
    UWorldMgr:UnLoadLevel("PostFilter_v0001", true)
end

function Util.GetDarkEdgeActors()
    local UWorldMgr = _G.UE.UWorldMgr.Get()
    local DarkEdgeLevel =_G.UE.UGameplayStatics.GetStreamingLevel(FWORLD(), "PostFilter_v0001")

    if DarkEdgeLevel and DarkEdgeLevel:IsLevelLoaded() then
        local Level = DarkEdgeLevel:GetLoadedLevel()
        if Level then
            return UWorldMgr:GetActorsInLevel(Level)
        end
    end

    return nil
end

return Util