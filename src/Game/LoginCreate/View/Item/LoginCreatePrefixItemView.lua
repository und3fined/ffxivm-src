---
--- Author: jamiyang
--- DateTime: 2023-10-12 19:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class LoginCreatePrefixItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextName UFTextBlock
---@field TextNameChecked UFTextBlock
---@field ToggleBtn UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreatePrefixItemView = LuaClass(UIView, true)

function LoginCreatePrefixItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextName = nil
	--self.TextNameChecked = nil
	--self.ToggleBtn = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreatePrefixItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreatePrefixItemView:OnInit()
	self.Binders = {
		{ "bItemSelect", UIBinderSetIsChecked.New(self, self.ToggleBtn)},
		{ "TextTitle", UIBinderSetText.New(self, self.TextName)},
		{ "TextTitle", UIBinderSetText.New(self, self.TextNameChecked)},
	}
end

function LoginCreatePrefixItemView:OnDestroy()

end

function LoginCreatePrefixItemView:OnShow()

end

function LoginCreatePrefixItemView:OnHide()

end

function LoginCreatePrefixItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickButtonItem)

end

function LoginCreatePrefixItemView:OnRegisterGameEvent()

end

function LoginCreatePrefixItemView:OnRegisterBinder()
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

function LoginCreatePrefixItemView:OnClickButtonItem()
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

function LoginCreatePrefixItemView:OnSelectChanged(bSelect)
	-- if bSelect == true then
	-- 	self.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	-- else
	-- 	self.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	-- end
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(bSelect)
	end
	self:StopAllAnimations()
	if bSelect then
		self:PlayAnimation(self.AnimChecked)
	else
		self:PlayAnimation(self.AnimUnchecked)
	end
end
return LoginCreatePrefixItemView