---
--- Author: Administrator
--- DateTime: 2024-06-04 20:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")


---@class CompanySealSlot126pxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClosure UFButton
---@field Comm126Slot CommBackpack126SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealSlot126pxItemView = LuaClass(UIView, true)

function CompanySealSlot126pxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClosure = nil
	--self.Comm126Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealSlot126pxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealSlot126pxItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetImageBrush.New(self, self.Comm126Slot.Icon)},
		{ "ImgEmptyVisible", UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgEmpty)},
		{ "IsMask", UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgMask)},
		{ "BtnClosureVisible", UIBinderSetIsVisible.New(self, self.BtnClosure, false, true)},
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.Comm126Slot.ImgQuanlity)},
		{ "IconChooseVisible", UIBinderSetIsVisible.New(self, self.Comm126Slot.IconChoose)},
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.Comm126Slot.RichTextQuantity)},
		{ "Num", UIBinderSetText.New(self, self.Comm126Slot.RichTextQuantity)},
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgSelect)},
		{ "BackpackSlotVisible", UIBinderSetIsVisible.New(self, self.Comm126Slot.PanelInfo)},
		{ "HideItemLevel", UIBinderSetIsVisible.New(self, self.Comm126Slot.RichTextLevel)},
	}
	UIUtil.SetIsVisible(self.Comm126Slot.Btn, false)
end

function CompanySealSlot126pxItemView:OnDestroy()

end

function CompanySealSlot126pxItemView:OnShow()
	UIUtil.SetIsVisible(self.Comm126Slot.RichTextLevel, false)
end

function CompanySealSlot126pxItemView:OnHide()

end

function CompanySealSlot126pxItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnClosure, self.OnBtnBtnClosureClick)
	self.Comm126Slot:SetClickButtonCallback(self, self.OnTaskItemClicked)
end

function CompanySealSlot126pxItemView:OnRegisterGameEvent()

end

function CompanySealSlot126pxItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function CompanySealSlot126pxItemView:OnTaskItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	ItemTipsUtil.ShowTipsByResID(ViewModel.CurItemID, self.Comm126Slot, _G.UE4.FVector2D(0, 0))
end

function CompanySealSlot126pxItemView:OnBtnBtnClosureClick()
	if self.ViewModel.Index ~= 0 then
		EventMgr:SendEvent(EventID.CompanySealCancelRareChosed, self.ViewModel.Index)
	end
end

return CompanySealSlot126pxItemView