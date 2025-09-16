---
--- Author: jamiyang
--- DateTime: 2023-10-17 20:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class LoginCreateAppearanceVoiceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgVoiceCheck UFImage
---@field ImgVoiceUncheck UFImage
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateAppearanceVoiceItemView = LuaClass(UIView, true)

function LoginCreateAppearanceVoiceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgVoiceCheck = nil
	--self.ImgVoiceUncheck = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateAppearanceVoiceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateAppearanceVoiceItemView:OnInit()
	self.Binders = {
		{ "bItemSelect", UIBinderSetIsChecked.New(self, self.ToggleBtn)},
		{ "CheckIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgVoiceCheck, true) },
		{ "UnChecIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgVoiceUncheck, true) },
	}
end

function LoginCreateAppearanceVoiceItemView:OnDestroy()

end

function LoginCreateAppearanceVoiceItemView:OnShow()

end

function LoginCreateAppearanceVoiceItemView:OnHide()

end

function LoginCreateAppearanceVoiceItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickButtonItem)
end

function LoginCreateAppearanceVoiceItemView:OnRegisterGameEvent()

end

function LoginCreateAppearanceVoiceItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function LoginCreateAppearanceVoiceItemView:OnClickButtonItem()
	--self.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
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

function LoginCreateAppearanceVoiceItemView:OnSelectChanged(bSelect)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
end
return LoginCreateAppearanceVoiceItemView