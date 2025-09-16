---
--- Author: jamiyang
--- DateTime: 2023-10-25 10:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
--local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class LoginCreateTextSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnText UFButton
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field TextContent UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateTextSlotItemView = LuaClass(UIView, true)

function LoginCreateTextSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnText = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.TextContent = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateTextSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateTextSlotItemView:OnInit()
	self.Binders = {
		{ "bItemSelect", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "SelectText", UIBinderSetText.New(self, self.TextContent)},
		{ "bShowText", UIBinderSetIsVisible.New(self, self.TextContent)},
		--{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextContent) },
	}
end

function LoginCreateTextSlotItemView:OnDestroy()

end

function LoginCreateTextSlotItemView:OnShow()

end

function LoginCreateTextSlotItemView:OnHide()

end

function LoginCreateTextSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnText, self.OnClickButtonItem)

end

function LoginCreateTextSlotItemView:OnRegisterGameEvent()

end

function LoginCreateTextSlotItemView:OnRegisterBinder()
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

function LoginCreateTextSlotItemView:OnClickButtonItem()
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

function LoginCreateTextSlotItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
	
	if IsSelected then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, "FFFFFFFF")
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, "688FB6FF")
	end
end

return LoginCreateTextSlotItemView