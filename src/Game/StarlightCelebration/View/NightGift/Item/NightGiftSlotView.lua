---
--- Author: Administrator
--- DateTime: 2025-08-05 14:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class NightGiftSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field NewBagSlotItem NewBagSlotRecoveryItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftSlotView = LuaClass(UIView, true)

function NightGiftSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.NewBagSlotItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.NewBagSlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftSlotView:OnInit()
	self.Binders = {	
		{ "SlotItemVisible", UIBinderSetIsVisible.New(self, self.NewBagSlotItem)},
	
	}
end

function NightGiftSlotView:OnDestroy()

end

function NightGiftSlotView:OnShow()

end

function NightGiftSlotView:OnHide()

end

function NightGiftSlotView:OnRegisterUIEvent()

end

function NightGiftSlotView:OnRegisterGameEvent()

end

function NightGiftSlotView:OnRegisterBinder()
	local Params = self.Params
	if not Params then return end
		
	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
	self.NewBagSlotItem.BagSlot:SetParams({Data = ViewModel.ItemSlotVM})

end

return NightGiftSlotView