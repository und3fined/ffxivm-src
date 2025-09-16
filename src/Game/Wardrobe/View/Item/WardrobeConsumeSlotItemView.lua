---
--- Author: Administrator
--- DateTime: 2024-02-22 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class WardrobeConsumeSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field RichNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeConsumeSlotItemView = LuaClass(UIView, true)

function WardrobeConsumeSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.RichNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeConsumeSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeConsumeSlotItemView:OnInit()
	self.Binders = {
		{ "Num", UIBinderSetText.New(self, self.RichNum)},
	}
end

function WardrobeConsumeSlotItemView:OnDestroy()

end

function WardrobeConsumeSlotItemView:OnShow()

end

function WardrobeConsumeSlotItemView:OnHide()

end

function WardrobeConsumeSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnClickButtonItem)
end

function WardrobeConsumeSlotItemView:OnRegisterGameEvent()
	
end

function WardrobeConsumeSlotItemView:OnRegisterBinder()
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

function WardrobeConsumeSlotItemView:OnClickButtonItem()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ItemTipsUtil.ShowTipsByResID(ViewModel.BagSlotVM.ResID, self.BagSlot)
end

return WardrobeConsumeSlotItemView