---
--- Author: HugoWong
--- DateTime: 2023-11-06 15:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CompanionVM = require ("Game/Companion/VM/CompanionVM")

local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")

local EToggleButtonState = _G.UE.EToggleButtonState

---@class CompanionCallingSettingItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommCheckBoxView
---@field ImgBG UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanionCallingSettingItemView = LuaClass(UIView, true)

function CompanionCallingSettingItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--self.ImgBG = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanionCallingSettingItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionCallingSettingItemView:OnInit()
	
end

function CompanionCallingSettingItemView:OnDestroy()

end

function CompanionCallingSettingItemView:OnShow()
	UIUtil.SetIsVisible(self.CheckBox.TextContent, false)
end

function CompanionCallingSettingItemView:OnHide()

end

function CompanionCallingSettingItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox, self.OnCheckBoxClicked)
end

function CompanionCallingSettingItemView:OnRegisterGameEvent()

end

function CompanionCallingSettingItemView:OnRegisterBinder()
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
		{
			ViewModel = self.ViewModel,
			Binders = {
				{ "Title", UIBinderSetText.New(self, self.Text) },
				{ "IsSelect", UIBinderSetIsChecked.New(self, self.CheckBox, true) },
				{ "Clickable", UIBinderValueChangedCallback.New(self, nil, self.OnClickableChange) },
			}
		},
		{
			ViewModel = CompanionVM,
			Binders = {
				{ "OnlineAutoCalling", UIBinderValueChangedCallback.New(self, nil, self.OnOnlineAutoCallingChange) },
			}
		},
	}

	self:RegisterMultiBinders(Binders)
end

function CompanionCallingSettingItemView:OnClickableChange(NewValue, OldValue)
	if NewValue == nil then return end

	self.CheckBox:SetClickable(NewValue)
end

function CompanionCallingSettingItemView:OnCheckBoxClicked(ToggleButton, ButtonState)
	local ViewModel = self.Params.Data
	if ViewModel == nil then return end

	local IsCheck = ButtonState == EToggleButtonState.Checked
	if ViewModel:GetSelect() == IsCheck then return end

	local Params = self.Params
	if nil == Params then return end

	local Adapter = Params.Adapter
	if nil == Adapter then return end

	Adapter:OnItemClicked(self, Params.Index)
end

function CompanionCallingSettingItemView:OnOnlineAutoCallingChange(NewValue, OldValue)
	if NewValue then
		self.Text:SetColorAndOpacity(self.CheckBox.CheckedColor)
	else
		self.Text:SetColorAndOpacity(self.CheckBox.UnCheckedColor)
	end
end

return CompanionCallingSettingItemView