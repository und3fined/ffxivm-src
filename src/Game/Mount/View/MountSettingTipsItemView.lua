---
--- Author: enqingchen
--- DateTime: 2023-02-23 14:24
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

---@class MountSettingTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommCheckBoxView
---@field ImgCutLine_1 UFImage
---@field TextSetting UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSettingTipsItemView = LuaClass(UIView, true)

function MountSettingTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--self.ImgCutLine_1 = nil
	--self.TextSetting = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSettingTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSettingTipsItemView:OnInit()

end

function MountSettingTipsItemView:OnDestroy()

end

function MountSettingTipsItemView:OnShow()

end

function MountSettingTipsItemView:OnHide()

end

function MountSettingTipsItemView:OnRegisterUIEvent()

end

function MountSettingTipsItemView:OnRegisterGameEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox, self.OnCheckBoxClick)
end

function MountSettingTipsItemView:OnRegisterBinder()
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

function MountSettingTipsItemView:OnCheckBoxClick(ToggleButton, ButtonState)
	self.ViewModel:SetSelect(ButtonState == _G.UE.EToggleButtonState.Checked)
end

function MountSettingTipsItemView:OnItemSelectChange(NewValue, OldValue)
	if OldValue == nil then
		return
	end
	if NewValue == true then
		MountVM:SetCallSetting(self.ViewModel.Index)
	end
end

return MountSettingTipsItemView