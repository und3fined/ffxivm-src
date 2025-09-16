---
--- Author: anypkvcai
--- DateTime: 2023-02-24 16:04
--- Description: 地图天气时间tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapVM = require("Game/Map/VM/MapVM")
local WeatherCfg = require("TableCfg/WeatherCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderDecoratorFilter = require("Binder/UIBinderDecoratorFilter")


---@class MapWeatherTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextWeather UFTextBlock
---@field WeatherTimeBar WeatherTimeBarItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapWeatherTipsItemView = LuaClass(UIView, true)

function MapWeatherTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextWeather = nil
	--self.WeatherTimeBar = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapWeatherTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WeatherTimeBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapWeatherTipsItemView:OnInit()
	self.Binders = {
		{ "WeatherID", UIBinderDecoratorFilter.New(UIBinderSetText.New(self, self.TextWeather), WeatherCfg.GetWeatherName, WeatherCfg) },
	}

end

function MapWeatherTipsItemView:OnDestroy()

end

function MapWeatherTipsItemView:OnShow()
	UIUtil.SetIsVisible(self.WeatherTimeBar, true)
end

function MapWeatherTipsItemView:OnHide()

end

function MapWeatherTipsItemView:OnRegisterUIEvent()

end

function MapWeatherTipsItemView:OnRegisterGameEvent()

end

function MapWeatherTipsItemView:OnRegisterBinder()
	self:RegisterBinders(MapVM, self.Binders)
end

return MapWeatherTipsItemView