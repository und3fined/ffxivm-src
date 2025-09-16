---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class HaircutTextSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnText UFButton
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field TextContent UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutTextSlotItemView = LuaClass(UIView, true)

function HaircutTextSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnText = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.TextContent = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutTextSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutTextSlotItemView:OnInit()
	self.Binders = {
		{ "bItemSelect", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "SelectText", UIBinderSetText.New(self, self.TextContent)},
		{ "bShowText", UIBinderSetIsVisible.New(self, self.TextContent)},
	}
end

function HaircutTextSlotItemView:OnDestroy()

end

function HaircutTextSlotItemView:OnShow()

end

function HaircutTextSlotItemView:OnHide()

end

function HaircutTextSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnText, self.OnClickButtonItem)
end

function HaircutTextSlotItemView:OnRegisterGameEvent()

end

function HaircutTextSlotItemView:OnRegisterBinder()
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

function HaircutTextSlotItemView:OnClickButtonItem()
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

function HaircutTextSlotItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
	if IsSelected then
		self:PlayAnimation(self.AnimChecked)
	else
		self:PlayAnimation(self.AnimUnchecked)
	end
end

return HaircutTextSlotItemView