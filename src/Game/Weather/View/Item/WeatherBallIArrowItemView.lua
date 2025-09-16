---
--- Author: Administrator
--- DateTime: 2023-12-05 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NewWeatherBallIArrowItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field WeatherArrow NewWeatherArrowItemView
---@field WeatherBallISlot NewWeatherBallISlotItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherBallIArrowItemView = LuaClass(UIView, true)

function NewWeatherBallIArrowItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.WeatherArrow = nil
	--self.WeatherBallISlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherBallIArrowItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	-- self:AddSubView(self.WeatherArrow)
	self:AddSubView(self.WeatherBallISlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherBallIArrowItemView:OnInit()

end

function NewWeatherBallIArrowItemView:OnDestroy()

end

function NewWeatherBallIArrowItemView:OnShow()

end

function NewWeatherBallIArrowItemView:OnHide()

end

function NewWeatherBallIArrowItemView:OnRegisterUIEvent()

end

function NewWeatherBallIArrowItemView:OnRegisterGameEvent()

end

function NewWeatherBallIArrowItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end

    self.VM = self.Params.Data
    if nil == self.VM then
        return
    end

	self.WeatherBallISlot:UpdWeather(self.VM)
	UIUtil.SetIsVisible(self.ArrowPanel1, self.VM.IsShowArr)
end

return NewWeatherBallIArrowItemView