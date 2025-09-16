---
--- Author: jamiyang
--- DateTime: 2023-08-08 10:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class MountNewFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SingleBox CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountNewFilterItemView = LuaClass(UIView, true)

function MountNewFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SingleBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountNewFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountNewFilterItemView:OnInit()

end

function MountNewFilterItemView:OnDestroy()

end

function MountNewFilterItemView:OnShow()

end

function MountNewFilterItemView:OnHide()

end

function MountNewFilterItemView:OnRegisterUIEvent()

end

function MountNewFilterItemView:OnRegisterGameEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxClick)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox.ToggleButton, self.OnToggleStateChanged)
end

function MountNewFilterItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel
	local Binders = {
		{ "IsSelect", UIBinderSetIsChecked.New(self, self.SingleBox, true) },
		{ "IsSelect", UIBinderValueChangedCallback.New(self, nil, self.OnItemSelectChange) },
		{ "TitleText",  UIBinderSetText.New(self, self.SingleBox.TextContent) },
		--{ "TitleColor",  UIBinderSetColorAndOpacityHex.New(self, self.SingleBox.TextContent) },
	}
	self:RegisterBinders(ViewModel, Binders)

end

function MountNewFilterItemView:OnSingleBoxClick(ToggleButton, ButtonState)
	self.ViewModel.IsSelect = ButtonState == _G.UE.EToggleButtonState.Checked
end

function MountNewFilterItemView:OnToggleStateChanged(ToggleButton, ButtonState)
	--if self.ViewModel.IsTitle == false then
		--return
	--end
	self.ViewModel.IsSelect = ButtonState == _G.UE.EToggleButtonState.Checked
end

function MountNewFilterItemView:OnItemSelectChange(NewValue, OldValue)
	if NewValue == nil or OldValue == nil then
		return
	end
	self.ViewModel:SetSelect(NewValue, true)
end

return MountNewFilterItemView