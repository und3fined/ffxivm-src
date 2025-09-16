---
--- Author: chunfengluo
--- DateTime: 2023-08-03 10:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MountVM = require("Game/Mount/VM/MountVM")

local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MountSettingSummonItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommCheckBoxView
---@field ImgBG UFImage
---@field TextSetting UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSettingSummonItemView = LuaClass(UIView, true)

function MountSettingSummonItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--self.ImgBG = nil
	--self.TextSetting = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSettingSummonItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSettingSummonItemView:OnInit()

end

function MountSettingSummonItemView:OnDestroy()

end

function MountSettingSummonItemView:OnShow()
	UIUtil.SetIsVisible(self.CheckBox.TextContent, false)
end

function MountSettingSummonItemView:OnHide()

end

function MountSettingSummonItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox, self.OnCheckBoxClick)
end

function MountSettingSummonItemView:OnRegisterGameEvent()

end

function MountSettingSummonItemView:OnRegisterBinder()
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
		{ "bSelect", UIBinderSetIsChecked.New(self, self.CheckBox, true) },
		{ "Title",  UIBinderSetText.New(self, self.TextSetting) },
		{ "TitleColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSetting) },
		{ "bSelect", UIBinderValueChangedCallback.New(self, nil, self.OnItemSelectChange) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

function MountSettingSummonItemView:OnCheckBoxClick(ToggleButton, ButtonState)
	self.ViewModel:SetSelect(ButtonState == _G.UE.EToggleButtonState.Checked)
end

function MountSettingSummonItemView:OnItemSelectChange(NewValue, OldValue)
	if OldValue == nil then
		self.CheckBox:SetClickable(true)
		return
	end
	if NewValue == true then
		MountVM:SetCallSetting(self.ViewModel.Index)
	end
	self.CheckBox:SetClickable(not NewValue)
end

return MountSettingSummonItemView