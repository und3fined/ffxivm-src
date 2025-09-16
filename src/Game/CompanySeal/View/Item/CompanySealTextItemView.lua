---
--- Author: Administrator
--- DateTime: 2024-06-14 19:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CompanySealTextItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconUp UFImage
---@field RedDot2 CommonRedDot2View
---@field TextNewPermissions2 URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealTextItemView = LuaClass(UIView, true)

function CompanySealTextItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconUp = nil
	--self.RedDot2 = nil
	--self.TextNewPermissions2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealTextItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealTextItemView:OnInit()
	self.Binders = {
		{ "Desc", UIBinderSetText.New(self, self.TextNewPermissions2) },
		-- { "RedDot2Visible", UIBinderSetIsVisible.New(self, self.RedDot2)},
		{ "RedDot2Visible", UIBinderValueChangedCallback.New(self, nil, self.OnRedDot2VisibleChanged)},
		{ "IconUpVisible", UIBinderSetIsVisible.New(self, self.IconUp)},
	}
end

function CompanySealTextItemView:OnDestroy()

end

function CompanySealTextItemView:OnShow()
	self.RedDot2:SetIsCustomizeRedDot(true)
end

function CompanySealTextItemView:OnRedDot2VisibleChanged(NewValue)
	if self.RedDot2 ~= nil and self.RedDot2.ItemVM ~= nil then
		self.RedDot2.ItemVM.IsVisible = NewValue
	end
end

function CompanySealTextItemView:OnHide()

end

function CompanySealTextItemView:OnRegisterUIEvent()

end

function CompanySealTextItemView:OnRegisterGameEvent()

end

function CompanySealTextItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return CompanySealTextItemView