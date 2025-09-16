---
--- Author: Administrator
--- DateTime: 2024-02-22 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeConsumeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field HorizontalConsume UFHorizontalBox
---@field TextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeConsumeItemView = LuaClass(UIView, true)

function WardrobeConsumeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.HorizontalConsume = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeConsumeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeConsumeItemView:OnInit()
	self.Binders = {
		{ "Num", UIBinderSetText.New(self, self.TextNum)},
	}
end

function WardrobeConsumeItemView:OnDestroy()

end

function WardrobeConsumeItemView:OnShow()

end

function WardrobeConsumeItemView:OnHide()

end

function WardrobeConsumeItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnClickButtonItem)
end

function WardrobeConsumeItemView:OnRegisterGameEvent()

end

function WardrobeConsumeItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.BagSlot:SetParams({Data = ViewModel.BagSlotVM})
end

function WardrobeConsumeItemView:OnClickButtonItem()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local Item = ItemUtil.CreateItem(ViewModel.BagSlotVM.ResID)
	Item.NeedBuyNum = ViewModel.ItemNum
	ItemTipsUtil.ShowTipsByItem(Item, self.BagSlot)
end

return WardrobeConsumeItemView