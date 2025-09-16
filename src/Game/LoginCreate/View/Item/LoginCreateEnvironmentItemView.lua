---
--- Author: chriswang
--- DateTime: 2023-11-01 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateEnvironmentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect1 UFImage
---@field ImgWeather1 UFImage
---@field ToggleButtonMap UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateEnvironmentItemView = LuaClass(UIView, true)

function LoginCreateEnvironmentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect1 = nil
	--self.ImgWeather1 = nil
	--self.ToggleButtonMap = nil
	--self.AnimChecked = nil
	--self.AnimIn = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateEnvironmentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateEnvironmentItemView:OnInit()

end

function LoginCreateEnvironmentItemView:OnDestroy()

end

function LoginCreateEnvironmentItemView:OnShow()
	if self.Params and self.Params.Data then
		self.Cfg = self.Params.Data
		UIUtil.ImageSetBrushFromAssetPath(self.ImgWeather1, self.Cfg.IconPath)
	end
end

function LoginCreateEnvironmentItemView:OnHide()

end

function LoginCreateEnvironmentItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ItemToggleBtn, self.OnItemToggleBtnClick)
end

function LoginCreateEnvironmentItemView:OnRegisterGameEvent()

end

function LoginCreateEnvironmentItemView:OnRegisterBinder()

end

function LoginCreateEnvironmentItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self.ItemToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	else
		self.ItemToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	end
end

function LoginCreateEnvironmentItemView:OnItemToggleBtnClick(ToggleButton, ButtonState)
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

return LoginCreateEnvironmentItemView