---
--- Author: Administrator
--- DateTime: 2023-12-05 10:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NewWeatherTimeLItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EmptyState NewWeatherEmptyStateItemView
---@field WeatherTimeItem_UIBP NewWeatherTimeItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherTimeLItemView = LuaClass(UIView, true)

function NewWeatherTimeLItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EmptyState = nil
	--self.WeatherTimeItem_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherTimeLItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EmptyState)
	self:AddSubView(self.WeatherTimeItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherTimeLItemView:OnInit()

end

function NewWeatherTimeLItemView:OnDestroy()

end

function NewWeatherTimeLItemView:OnShow()
	local Params = self.Params
    if nil == Params then
        return
    end

    self.Data = self.Params.Data
    if nil == self.Data then
        return
    end

	local Time = self.Data.Time

	self.WeatherTimeItem_UIBP:SetTime(Time)
end

function NewWeatherTimeLItemView:OnHide()

end

function NewWeatherTimeLItemView:OnRegisterUIEvent()

end

function NewWeatherTimeLItemView:OnRegisterGameEvent()

end

function NewWeatherTimeLItemView:OnRegisterBinder()

end

return NewWeatherTimeLItemView