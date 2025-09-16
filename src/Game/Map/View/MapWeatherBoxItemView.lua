---
--- Author: anypkvcai
--- DateTime: 2023-02-23 10:31
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local MapVM = require("Game/Map/VM/MapVM")
--local MapSetting = require("Game/Map/MapSetting")
--local EventID = require("Define/EventID")
local WeatherCfg = require("TableCfg/WeatherCfg")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderDecoratorFilter = require("Binder/UIBinderDecoratorFilter")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

--local WEATHER_CLICK_TIPS_TIME = 3
--local WEATHER_CHANGE_TIPS_TIME = 10

---@class MapWeatherBoxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnWeather UFButton
---@field ImgWeather UFImage
---@field ImgWeatherBg UFImage
---@field ImgWeather_1 UFImage
---@field MapWeatherTipsItem MapWeatherTipsItemView
---@field PanelWeather UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapWeatherBoxItemView = LuaClass(UIView, true)

function MapWeatherBoxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnWeather = nil
	--self.ImgWeather = nil
	--self.ImgWeatherBg = nil
	--self.ImgWeather_1 = nil
	--self.MapWeatherTipsItem = nil
	--self.PanelWeather = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapWeatherBoxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MapWeatherTipsItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapWeatherBoxItemView:OnInit()
	self.Binders = {
		{ "WeatherID", UIBinderDecoratorFilter.New(UIBinderSetBrushFromAssetPath.New(self, self.ImgWeather), WeatherCfg.GetWeatherIcon, WeatherCfg) },
		--{ "WeatherID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedWeatherID) },
		{ "WeatherShowType", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedWeatherShowType) },
	}

	self.TipsVisible = false
end

function MapWeatherBoxItemView:OnDestroy()

end

function MapWeatherBoxItemView:OnShow()
	local ShowType = MapVM:GetWeatherShowType()
	self:UpdateWeatherBox(ShowType)
end

function MapWeatherBoxItemView:OnHide()
	self:HideWeatherTips()
end

function MapWeatherBoxItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnWeather, self.OnClickedBtnWeather)
end

function MapWeatherBoxItemView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
end

function MapWeatherBoxItemView:OnRegisterBinder()
	self:RegisterBinders(MapVM, self.Binders)
end

function MapWeatherBoxItemView:OnClickedBtnWeather()
	local IsVisible = not self.TipsVisible

	if IsVisible then
		self:ShowWeatherTips()
	else
		self:HideWeatherTips()
	end
	--UIUtil.SetIsVisible(self.AsyncPanelWeatherTips, IsVisible)
	--
	--if nil ~= self.HideTipsTimerID then
	--	self:UnRegisterTimer(self.HideTipsTimerID)
	--end
	--
	--if IsVisible then
	--	self.HideTipsTimerID = self:RegisterTimer(self.OnTimerHideTips, 3)
	--end
end

--function MapWeatherBoxItemView:OnValueChangedWeatherID(Value)
--	self:ShoWeatherTips(WEATHER_CHANGE_TIPS_TIME)
--end

function MapWeatherBoxItemView:OnValueChangedWeatherShowType(Value)
	self:UpdateWeatherBox(Value)
end

--function MapWeatherBoxItemView:OnGameEventPWorldEnter(Params)
--	self:ShoWeatherTips(WEATHER_CHANGE_TIPS_TIME)
--end

function MapWeatherBoxItemView:UpdateWeatherBox(ShowType)
	UIUtil.SetIsVisible(self.PanelWeather, ShowType == 0)

	--if MapSetting.WeatherShowType.Always == ShowType then
	--	if nil ~= self.HideTipsTimerID then
	--		self:UnRegisterTimer(self.HideTipsTimerID)
	--	end
	--	UIUtil.SetIsVisible(self.AsyncPanelWeatherTips, true)
	--elseif MapSetting.WeatherShowType.Never == ShowType then
	--	UIUtil.SetIsVisible(self.AsyncPanelWeatherTips, false)
	--else
	--	self:ShoWeatherTips(WEATHER_CHANGE_TIPS_TIME)
	--end
end

function MapWeatherBoxItemView:ShowWeatherTips()
	--if MapSetting.GetSettingValue(MapSetting.SettingType.ShowWeather) ~= MapSetting.WeatherShowType.Default then
	--	return
	--end

	self.TipsVisible = true

	if nil ~= self.HideTipsTimerID then
		self:UnRegisterTimer(self.HideTipsTimerID)
	end

	self.HideTipsTimerID = self:RegisterTimer(self.OnTimerHideTips, 3)

	UIUtil.SetIsVisible(self.MapWeatherTipsItem, true)
end

--function MapWeatherBoxItemView:OnValueChangedWeatherID(Value)
--	if nil ~= self.HideWeatherTimerID then
--		self:UnRegisterTimer(self.HideWeatherTimerID)
--	end
--
--	self.HideWeatherTimerID = self:RegisterTimer(self.OnTimerHideWeather, 10)
--
--	UIUtil.SetIsVisible(self.PanelWeather, true)
--end

--function MapWeatherBoxItemView:OnTimerHideWeather()
--	UIUtil.SetIsVisible(self.PanelWeather, false)
--end

function MapWeatherBoxItemView:HideWeatherTips()
	self.TipsVisible = false
	UIUtil.SetIsVisible(self.MapWeatherTipsItem, false)
end

function MapWeatherBoxItemView:OnTimerHideTips()
	self:HideWeatherTips()
end

return MapWeatherBoxItemView