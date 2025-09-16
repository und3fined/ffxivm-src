---
--- Author: enqingchen
--- DateTime: 2023-02-22 11:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MountFilterTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field ButtonType UFButton
---@field FliterTips UCanvasPanel
---@field PanelFilterBar UFCanvasPanel
---@field SingleBox CommSingleBoxView
---@field TextFilterType UFTextBlock
---@field TextType UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountFilterTipsView = LuaClass(UIView, true)

function MountFilterTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.ButtonType = nil
	--self.FliterTips = nil
	--self.PanelFilterBar = nil
	--self.SingleBox = nil
	--self.TextFilterType = nil
	--self.TextType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountFilterTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountFilterTipsView:OnInit()

end

function MountFilterTipsView:OnDestroy()

end

function MountFilterTipsView:OnShow()

end

function MountFilterTipsView:OnHide()

end

function MountFilterTipsView:OnRegisterUIEvent()

end

function MountFilterTipsView:OnRegisterGameEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnFold, self.OnBtnFoldClick)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxClick)
end

function MountFilterTipsView:OnRegisterBinder()
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
		{ "IsTitle", UIBinderSetIsVisible.New(self, self.PanelFilterBar) },
		{ "IsTitle", UIBinderSetIsVisible.New(self, self.FliterTips, true) },
		{ "IsSelect", UIBinderSetIsChecked.New(self, self.BtnFold, true) },
		{ "TitleText",  UIBinderSetText.New(self, self.TextFilterType) },
		{ "TitleText",  UIBinderSetText.New(self, self.TextType) },
		{ "IsSelect", UIBinderSetIsChecked.New(self, self.SingleBox, true) },
		{ "TitleColor", UIBinderSetColorAndOpacityHex.New(self, self.TextFilterType) },
		{ "IsSelect", UIBinderValueChangedCallback.New(self, nil, self.OnItemSelectChange) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

function MountFilterTipsView:OnItemSelectChange(NewValue, OldValue)
	if OldValue == nil then
		return
	end
	self.ViewModel:SetSelect(NewValue, true)
end

function MountFilterTipsView:OnBtnFoldClick(ToggleButton, ButtonState)
	if self.ViewModel.IsTitle == false then
		return
	end
	self.ViewModel.IsSelect = ButtonState == _G.UE.EToggleButtonState.Checked
end

function MountFilterTipsView:OnSingleBoxClick(ToggleButton, ButtonState)
	if self.ViewModel.IsTitle == true then
		return
	end
	self.ViewModel.IsSelect = ButtonState == _G.UE.EToggleButtonState.Checked
end

return MountFilterTipsView