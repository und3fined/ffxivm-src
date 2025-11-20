---
--- Author: Administrator
--- DateTime: 2025-08-05 11:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeConsumeItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack58Slot CommBackpack58SlotView
---@field HorizontalConsume UFHorizontalBox
---@field TextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeConsumeItem2View = LuaClass(UIView, true)

function WardrobeConsumeItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack58Slot = nil
	--self.HorizontalConsume = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeConsumeItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack58Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeConsumeItem2View:OnInit()
	self.Binders = {
		{ "Num", UIBinderSetText.New(self, self.TextNum)},
	}

end

function WardrobeConsumeItem2View:OnDestroy()

end

function WardrobeConsumeItem2View:OnShow()

end

function WardrobeConsumeItem2View:OnHide()

end

function WardrobeConsumeItem2View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBackpack58Slot.Btn, self.OnClickButtonItem)
end

function WardrobeConsumeItem2View:OnRegisterGameEvent()
end

function WardrobeConsumeItem2View:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.CommBackpack58Slot:SetParams({Data = ViewModel.BagSlotVM})
end

function WardrobeConsumeItem2View:OnClickButtonItem()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	if ViewModel.BagSlotVM ~= nil and ViewModel.BagSlotVM.ResID ~= nil and ViewModel.BagSlotVM.ResID ~= 0 then
		local Item = ItemUtil.CreateItem(ViewModel.BagSlotVM.ResID)
		if Item ~= nil then
			Item.NeedBuyNum = ViewModel.ItemNum
			ItemTipsUtil.ShowTipsByItem(Item, self.CommBackpack58Slot)
		end
	end
end

return WardrobeConsumeItem2View