---
--- Author: Administrator
--- DateTime: 2024-06-06 19:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CompanySealSlot96pxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot CommBackpackSlotView
---@field PanelReceived UFCanvasPanel
---@field TextQuantity URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealSlot96pxItemView = LuaClass(UIView, true)

function CompanySealSlot96pxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.PanelReceived = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealSlot96pxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealSlot96pxItemView:OnInit()
	self.Binders = {
		{ "ItemIcon", UIBinderSetImageBrush.New(self, self.BackpackSlot.FImg_Icon)},
		{ "ImgEmptyVisible", UIBinderSetIsVisible.New(self, self.ImgEmpty)},
		{ "BtnClosureVisible", UIBinderSetIsVisible.New(self, self.BtnClosure)},
		{ "ItemQualityIcon", UIBinderSetImageBrush.New(self, self.BackpackSlot.FImg_Quality)},
		{ "RequireNumVisible", UIBinderSetIsVisible.New(self, self.TextQuantity)},
		{ "RequireNum", UIBinderSetText.New(self, self.TextQuantity)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.BackpackSlot.FImg_Select)},
		{ "BackpackSlotVisible", UIBinderSetIsVisible.New(self, self.BackpackSlot)},
		{ "PanelReceivedVisible", UIBinderSetIsVisible.New(self, self.PanelReceived)},
	}
end

function CompanySealSlot96pxItemView:OnDestroy()

end

function CompanySealSlot96pxItemView:OnShow()

end

function CompanySealSlot96pxItemView:OnHide()

end

function CompanySealSlot96pxItemView:OnRegisterUIEvent()
	self.BackpackSlot:SetClickButtonCallback(self, self.OnTaskItemClicked)
end

function CompanySealSlot96pxItemView:OnRegisterGameEvent()

end

function CompanySealSlot96pxItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function CompanySealSlot96pxItemView:OnTaskItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local ItemID = ViewModel.ResID or ViewModel.CurItemID
	if ItemID then
		ItemTipsUtil.ShowTipsByResID(ItemID, self.BackpackSlot, _G.UE4.FVector2D(0, 0))
	end
end

return CompanySealSlot96pxItemView