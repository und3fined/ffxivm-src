---
--- Author: ccppeng
--- DateTime: 2024-10-29 20:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
---@class CommSelectSettingsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommCheckBoxView
---@field ImgBG UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSelectSettingsItemView = LuaClass(UIView, true)

function CommSelectSettingsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--self.ImgBG = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSelectSettingsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSelectSettingsItemView:OnInit()

end

function CommSelectSettingsItemView:OnDestroy()

end

function CommSelectSettingsItemView:OnShow()

end

function CommSelectSettingsItemView:OnHide()

end

function CommSelectSettingsItemView:OnRegisterUIEvent()

end

function CommSelectSettingsItemView:OnRegisterGameEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox, self.OnCheckBoxClick)
end

function CommSelectSettingsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	local Binders
	if self.CheckBox ~= nil and self.CheckBox.ImgDisabledMask ~= nil then
		Binders = {
			{ "bSelect", UIBinderSetIsChecked.New(self, self.CheckBox, true) },
			{ "Title",  UIBinderSetText.New(self, self.Text) },
			{ "TitleColor", UIBinderSetColorAndOpacityHex.New(self, self.Text) },
			{ "bSelect", UIBinderValueChangedCallback.New(self, nil, self.OnItemSelectChange) },
			{ "bIsClickMaskVisible",  UIBinderSetIsVisible.New(self,self.CheckBox.ImgDisabledMask) },
		}
	else
		Binders = {
			{ "Title",  UIBinderSetText.New(self, self.Text) },
			{ "TitleColor", UIBinderSetColorAndOpacityHex.New(self, self.Text) },
			{ "bSelect", UIBinderValueChangedCallback.New(self, nil, self.OnItemSelectChange) },
		}
	end

    if self.CheckBox ~= nil then
		if self.CheckBox.TextContent ~= nil then
			UIUtil.SetIsVisible(self.CheckBox.TextContent)
		end
    end
	self:RegisterBinders(ViewModel, Binders)
end

function CommSelectSettingsItemView:OnCheckBoxClick(ToggleButton, ButtonState)
	if self.ViewModel ~= nil then
        --是否可以点击
		if not self.ViewModel:CanClick() then 
        --错误提示
			self.ViewModel:ProcessClickFailed()
		end
		if ButtonState == _G.UE.EToggleButtonState.Checked  then
			if self.ViewModel:IsAutoUse() then
				self.CheckBox:SetChecked(self.ViewModel:SetSelect(true,nil))
			else
				self.CheckBox:SetChecked(false)
			end
		else
			self.CheckBox:SetChecked(self.ViewModel:GetSelectedState())
		end
	end

end

function CommSelectSettingsItemView:OnItemSelectChange(NewValue, OldValue)
	if OldValue == nil then
		return
	end
	if NewValue == true then
		self.ViewModel:OnSelectedItem()
	end
end

return CommSelectSettingsItemView