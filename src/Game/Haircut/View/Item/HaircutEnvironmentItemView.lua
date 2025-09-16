---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HaircutEnvironmentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect1 UFImage
---@field ImgWeather1 UFImage
---@field ItemToggleBtn UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutEnvironmentItemView = LuaClass(UIView, true)

function HaircutEnvironmentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect1 = nil
	--self.ImgWeather1 = nil
	--self.ItemToggleBtn = nil
	--self.AnimChecked = nil
	--self.AnimIn = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutEnvironmentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutEnvironmentItemView:OnInit()

end

function HaircutEnvironmentItemView:OnDestroy()
end

function HaircutEnvironmentItemView:OnShow()
	if self.Params and self.Params.Data then
		self.Cfg = self.Params.Data
		UIUtil.ImageSetBrushFromAssetPath(self.ImgWeather1, self.Cfg.IconPath)
	end
end

function HaircutEnvironmentItemView:OnHide()

end

function HaircutEnvironmentItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ItemToggleBtn, self.OnItemToggleBtnClick)
end

function HaircutEnvironmentItemView:OnRegisterGameEvent()

end

function HaircutEnvironmentItemView:OnRegisterBinder()

end

function HaircutEnvironmentItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self.ItemToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	else
		self.ItemToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	end
end

function HaircutEnvironmentItemView:OnItemToggleBtnClick(ToggleButton, ButtonState)
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

return HaircutEnvironmentItemView