---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
-- local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class StoreNewBlindBoxSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewBlindBoxSlotItemView = LuaClass(UIView, true)

function StoreNewBlindBoxSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm126Slot = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewBlindBoxSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewBlindBoxSlotItemView:OnInit()
	self.Binders = {
		{ "TextProbability", 			UIBinderSetText.New(self, self.Text) },
		-- { "bIsOwned", 			UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgMask) },
		-- { "bIsOwned", 			UIBinderSetIsVisible.New(self, self.Comm126Slot.IconReceived) },
	}
end

function StoreNewBlindBoxSlotItemView:OnDestroy()

end

function StoreNewBlindBoxSlotItemView:OnShow()

end

function StoreNewBlindBoxSlotItemView:OnHide()

end

function StoreNewBlindBoxSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Comm126Slot.Btn, self.OnClickButtonItem)

end

function StoreNewBlindBoxSlotItemView:OnClickButtonItem()
	ItemTipsUtil.ShowTipsByResID(self.ViewModel.ID, self)
end

function StoreNewBlindBoxSlotItemView:OnRegisterGameEvent()

end

function StoreNewBlindBoxSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreNewBlindBoxSlotItemView