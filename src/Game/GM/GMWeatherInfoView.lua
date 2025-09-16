---
--- Author: skysong
--- DateTime: 2023-08-09 09:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WeatherCfgTable = require("TableCfg/WeatherCfg")
local CEnvMgr = _G.UE.UEnvMgr

---@class GMWeatherInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMWeatherInfoView = LuaClass(UIView, true)

function GMWeatherInfoView:Ctor()
    self.WeatherInfoTimerID = 0
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMWeatherInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMWeatherInfoView:OnInit()

end

function GMWeatherInfoView:OnDestroy()
    self:ClearTimer()
end

function GMWeatherInfoView:GetWeatherInfo(Params)
    local Percent = CEnvMgr:Get():GetAysoTimePrecent()
    local TimeValue = 24 * Percent
    local hour,mins = math.modf(TimeValue)
    local secs = math.floor(mins * 3600)
    local secs1,sces2 = math.modf(secs/60)
    self.WeatherTime:SetText("当前时间: "..tostring(hour).."小时"..tostring(secs1).."分")

    local WeatherID = CEnvMgr:Get():GetCurrentWeather()
    for Key, Value in pairs(self.IDNameMappingTable) do
        if Key == WeatherID then
            self.WeatherName:SetText("当前天气: "..tostring(Value))
        end
    end

    local WeatherTodFileName = CEnvMgr:Get():GetCurrentWeatherTodFileName()
    self.WeatherFileName:SetText("天气文件名: "..tostring(WeatherTodFileName))
end

function GMWeatherInfoView:InitWeatherCfgInfo()
    local Cfgs = WeatherCfgTable:FindAllCfg()

    if Cfgs then
        for _,V in pairs(Cfgs) do
            if V.ID > 0 then
                self.WeatherCfgInfo:Add(V.ID,V.Name)
            end
        end
    end
end

function GMWeatherInfoView:OnShow()
    self.WeatherCfgInfo = _G.UE.TMap(_G.UE.int32, _G.UE.FString)
    self:InitWeatherCfgInfo()
    self.IDNameMappingTable = CEnvMgr:Get():GetCurrentTodsystemActorWeathers(self.WeatherCfgInfo)

    if self.WeatherInfoTimerID == 0 then
        self.WeatherInfoTimerID = _G.TimerMgr:AddTimer(self, self.GetWeatherInfo, 0, 0, 0)
    end
end

function GMWeatherInfoView:ClearTimer()

    if self.WeatherInfoTimerID ~= nil and self.WeatherInfoTimerID > 0 then
        _G.TimerMgr:CancelTimer(self.WeatherInfoTimerID)
    end

    self.WeatherInfoTimerID = 0
end

function GMWeatherInfoView:OnHide()
    self:ClearTimer()
end

function GMWeatherInfoView:OnRegisterUIEvent()

end

function GMWeatherInfoView:OnRegisterGameEvent()

end

function GMWeatherInfoView:OnRegisterBinder()

end

return GMWeatherInfoView