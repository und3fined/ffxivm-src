local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoSceneVM = LuaClass(UIViewModel)
local TimeUtil = require("Utils/TimeUtil")
local WeatherUtil = require("Game/Weather/WeatherUtil")
local WeatherMappingCfg = require("TableCfg/WeatherMappingCfg")

local PhotoSceneUtil = require("Game/Photo/Util/PhotoSceneUtil")
local PhotoWeatherVM = require("Game/Photo/ItemVM/PhotoWeatherItemVM")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

local UIBindableList = require("UI/UIBindableList")
local MapWeatherCfg = require("TableCfg/MapWeatherCfg")
local WeatherRateCfg = require("TableCfg/WeatherRateCfg")
-- local ItemVM = require("Game/Item/ItemVM")

local LSTR = _G.LSTR

local PWorldQuestMgr
local PWorldMgr
local PWorldTeamMgr

local ClockInfo = {
    T0 = {
        Angle = 0,
    },

    T6 = {
        Angle = 90,
    },

    T12 = {
        Angle = 180,
    },

    T18 = {
        Angle = 270,
    },
}

-- 0 6 12 18 icon light
local ClockRangeAng = 15

function PhotoSceneVM:Ctor()
    self.TimeArwAng = 0
    self.Time = 0
    self.TimeOffset = 0
    for K, _G in pairs(ClockInfo) do
        self[K] = false
    end

    self.WeatherID = 0
    self.WeatherSeltIdx = 0

    self.IsShowAdjustTips = false

    self.WeatherList = UIBindableList.New(PhotoWeatherVM)
    self.WeatherName = ""

    self.WeatherTipsOpa = 1
end

function PhotoSceneVM:OnInit()
end

function PhotoSceneVM:OnBegin()
    -- PWorldQuestMgr = _G.PWorldQuestMgr
    -- PWorldMgr = _G.PWorldMgr
    -- PWorldTeamMgr = _G.PWorldTeamMgr
end

function PhotoSceneVM:OnEnd()
end

function PhotoSceneVM:OnShutdown()
end

function PhotoSceneVM:UpdateVM()
    local CurMapID = _G.PWorldMgr:GetCurrMapResID()
    CurMapID = WeatherMappingCfg:FindValue(CurMapID, "Mapping") or CurMapID
    
    local MWCfg = MapWeatherCfg:FindCfgByKey(CurMapID)
    if not MWCfg then
        _G.FLOG_ERROR('Andre.PhotoSceneVM:UpdateVM MWCfg = nil')
        return
    end

    local Scheme = MWCfg.Scheme
    local SCfg = WeatherRateCfg:FindCfgByKey(Scheme)
    if not SCfg then
        _G.FLOG_ERROR('Andre.PhotoSceneVM:UpdateVM SCfg = nil')
        return
    end

    local Weathers = SCfg.Weather

    -- merge
    local Set = {}
    for _, WID in pairs(Weathers) do
        if WID ~= 0 then
            Set[WID] = true
        end
    end

    local WIDs = {}
    for WID, _ in pairs(Set) do
        table.insert(WIDs, WID)
    end

    self.WeatherList:UpdateByValues(WIDs)
    self.WIDs = WIDs
    -- print('Andre.PhotoSceneVM:UpdateVM  ' .. table.tostring_block(WIDs))

    self:ResetWeatherAndTime2Now()
    self.IsShowAdjustTips = true
    self.WeatherTipsOpa = 1
end

function PhotoSceneVM:OnTimer()
end

local Day2Sec = 60 * 60 * 24

function PhotoSceneVM:SetTimeArwAngAndPauseWeather(Ang)
    self:SetTimeArwAng(Ang)
    _G.PhotoVM:SetIsPauseWeather(true)
end

function PhotoSceneVM:SetTimeArwAng(Ang, bIgOff)
    self.TimeArwAng = Ang
    -- UMG上12点方向是上午12，6点方向是午夜0点，反转了180度
    local OffAng = (Ang + 180) % 360
    -- print('[PhotoSceneVM] OffAng = ' .. tostring(OffAng))

    local Time = math.floor((OffAng / 360) * Day2Sec)
    if Time == 0 then
        Time = 1
    end
    if not bIgOff then
        local Now = PhotoSceneUtil.GetOneDaySec()
        self.TimeOffset = Time - Now
    end
    self:SetTime(Time)
    self:CheckClockTips(Ang)

    -- self:SetIsShowAdjustTips(false)
end

function PhotoSceneVM:CheckClockTips(Ang)
    Ang = Ang + 360
    for K, Info in pairs(ClockInfo) do
        local Min = Info.Angle - ClockRangeAng + 360
        local Max = Info.Angle + ClockRangeAng + 360
        local IsHit = (Min < Ang) and (Max > Ang)
        self[K] = IsHit
    end
end

function PhotoSceneVM:SetAngByTimeWithTimeOffset(Time)
    return self:SetAngByTime(Time + self.TimeOffset)
end

function PhotoSceneVM:SetAngByTime(Time)
    local Ang = Time * 360 / Day2Sec
    if Ang == self.LastSyncAng then
        return false
    end

    self.LastSyncAng = Ang
    
    self:SetTimeArwAng((Ang + 180) % 360, true)
    return true
end

function PhotoSceneVM:SetTime(Time)
    self.Time = Time
    -- print('Andre Time = ' .. tostring(Time))
    PhotoSceneUtil.SetWeatherAndTime(self.WeatherID, self.Time)
end

function PhotoSceneVM:SetWeatherSeltIdx(WeatherSeltIdx)
    self.WeatherSeltIdx = WeatherSeltIdx
    self.WeatherID = self.WIDs[WeatherSeltIdx]
    PhotoSceneUtil.SetWeatherAndTime(self.WeatherID, self.Time)
end

function PhotoSceneVM:ResetWeatherAndTime2Now()
    local Time = PhotoSceneUtil.GetOneDaySec()
    self.TimeOffset = 0
    self:SetAngByTime(Time)
    local CurrentMapResID = _G.PWorldMgr:GetCurrMapResID()

    local Weather = WeatherUtil.GetMapWeather(CurrentMapResID, 0)

    _G.FLOG_INFO(string.format('[Photo][PhotoSceneVM][ResetWeatherAndTime2Now] wid = %s',
        tostring(Weather)
    ))

    for Idx, W in pairs(self.WIDs or {}) do
        if W == Weather then
            self:SetWeatherSeltIdx(Idx)
            break
        end
    end
end

function PhotoSceneVM:SetIsShowAdjustTips(V)
    self.IsShowAdjustTips = V
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoSceneVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetScene(InTemplate, self.WeatherID, self.Time)
end

function PhotoSceneVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetScene(InTemplate)
    if Info then
        local WID = Info.WeatherID
        
        for _, ID in pairs(self.WIDs or {}) do
            if WID == ID then
                self.WeatherID = WID
                self.Time = Info.Time
                PhotoSceneUtil.SetWeatherAndTime(self.WeatherID, Info.Time)
                break
            end
        end

    end
end

return PhotoSceneVM