---
--- Author: chriswang
--- DateTime: 2023-11-01 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateWeatherItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelectIcon UFImage
---@field ImgWeatherIcon UFImage
---@field ItemToggleButton UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateWeatherItemView = LuaClass(UIView, true)

function LoginCreateWeatherItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelectIcon = nil
	--self.ImgWeatherIcon = nil
	--self.ItemToggleButton = nil
	--self.AnimChecked = nil
	--self.AnimIn = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateWeatherItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateWeatherItemView:OnInit()

end

function LoginCreateWeatherItemView:OnDestroy()

end

function LoginCreateWeatherItemView:OnShow()
	if self.Params and self.Params.Data then
		self.Cfg = self.Params.Data
		UIUtil.ImageSetBrushFromAssetPath(self.ImgWeatherIcon, self.Cfg.IconPath)
	end
end

function LoginCreateWeatherItemView:OnHide()

end

function LoginCreateWeatherItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ItemToggleButton, self.OnItemToggleBtnClick)
end

function LoginCreateWeatherItemView:OnRegisterGameEvent()

end

function LoginCreateWeatherItemView:OnRegisterBinder()

end

function LoginCreateWeatherItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self.ItemToggleButton:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	else
		self.ItemToggleButton:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	end
end

function LoginCreateWeatherItemView:OnItemToggleBtnClick(ToggleButton, ButtonState)
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

return LoginCreateWeatherItemView