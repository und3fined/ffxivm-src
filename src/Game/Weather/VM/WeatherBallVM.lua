local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local WeatherBallVM = LuaClass(UIViewModel) 
local WeatherUtil = require("Game/Weather/WeatherUtil")

local WeatherCfg = require("TableCfg/WeatherCfg")

function WeatherBallVM:Ctor()
    self.MapID = nil
    self.TimeOff = 0

    self.WeatherID = 0
    self.Icon = ""
    self.Name = ""

    self.Alpha = 1.0
    self.IsShowBorder = false
    self.IsShowName = false
    self.IsGlow = false

    self.NameColor = "AFAFAFFF"

    self.IsSelected = false
    self.IsUnExpBall = false
    self.bBtnSlotVisible = true
end

function WeatherBallVM:IsEqualVM(Value)
    return nil ~= Value and Value.MapID == self.MapID and Value.TimeOff == self.TimeOff
end

local LastBallIdx = 28

function WeatherBallVM:UpdateVM(WeatherInfo)
    self.MapID = WeatherInfo.MapID
    self.TimeOff = WeatherInfo.TimeOff
    -- print('testinfo Timeoff = ' .. tostring(self.TimeOff))
    self.WeatherID = WeatherUtil.GetMapWeather(self.MapID, self.TimeOff)

    local Cfg = WeatherCfg:FindCfgByKey(self.WeatherID)
    if not Cfg then
        _G.FLOG_ERROR("[Weather][WeatherBallVM][UpdateVM] Cfg = nil")
        return
    end
    self.Icon = Cfg.Icon
    self.Name = Cfg.Name
    -- the arrow follow ball 
    self.IsShowArr = self.TimeOff ~= LastBallIdx
end

function WeatherBallVM:SetIsSelected(IsSelected)
    self.IsSelected = IsSelected
end

function WeatherBallVM:SetAlpha(V)
    self.Alpha = V
end

function WeatherBallVM:SetShowBorder(V)
    self.IsShowBorder = V
end

function WeatherBallVM:SetShowName(V)
    self.IsShowName = V
end

function WeatherBallVM:SetNameColor(V)
    self.NameColor = V
end

function WeatherBallVM:SetIsGlow(V)
    self.IsGlow = V
end

function WeatherBallVM:SetIsUnExpBall(V)
    self.IsUnExpBall = V
end

return WeatherBallVM