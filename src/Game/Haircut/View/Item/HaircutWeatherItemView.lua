---
--- Author: jamiyang
--- DateTime: 2024-01-23 10:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HaircutWeatherItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelectIcon UFImage
---@field ImgWeatherIcon UFImage
---@field ItemToggleButton UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutWeatherItemView = LuaClass(UIView, true)

function HaircutWeatherItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelectIcon = nil
	--self.ImgWeatherIcon = nil
	--self.ItemToggleButton = nil
	--self.AnimChecked = nil
	--self.AnimIn = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutWeatherItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutWeatherItemView:OnInit()

end

function HaircutWeatherItemView:OnDestroy()

end

function HaircutWeatherItemView:OnShow()
	if self.Params and self.Params.Data then
		self.Cfg = self.Params.Data
		UIUtil.ImageSetBrushFromAssetPath(self.ImgWeatherIcon, self.Cfg.IconPath)
	end
end

function HaircutWeatherItemView:OnHide()

end

function HaircutWeatherItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ItemToggleButton, self.OnItemToggleBtnClick)
end

function HaircutWeatherItemView:OnRegisterGameEvent()

end

function HaircutWeatherItemView:OnRegisterBinder()

end

function HaircutWeatherItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self.ItemToggleButton:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	else
		self.ItemToggleButton:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	end
end

function HaircutWeatherItemView:OnItemToggleBtnClick(ToggleButton, ButtonState)
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	
	Adapter:OnItemClicked(self, Params.Index)
end

return HaircutWeatherItemView