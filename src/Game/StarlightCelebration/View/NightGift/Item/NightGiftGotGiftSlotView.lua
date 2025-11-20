---
--- Author: Administrator
--- DateTime: 2025-08-08 17:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class NightGiftGotGiftSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack126Slot CommBackpack126SlotView
---@field ImgTitle UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftGotGiftSlotView = LuaClass(UIView, true)

function NightGiftGotGiftSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack126Slot = nil
	--self.ImgTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftGotGiftSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftGotGiftSlotView:OnInit()
	self.Binders = {	
		{ "ImgTitleVisible", UIBinderSetIsVisible.New(self, self.ImgTitle)},
	
	}
end

function NightGiftGotGiftSlotView:OnDestroy()

end

function NightGiftGotGiftSlotView:OnShow()

end

function NightGiftGotGiftSlotView:OnHide()

end

function NightGiftGotGiftSlotView:OnRegisterUIEvent()
	self.CommBackpack126Slot:SetClickButtonCallback(self, self.OnGotGiftItemClicked)
end

function NightGiftGotGiftSlotView:OnRegisterGameEvent()

end

function NightGiftGotGiftSlotView:OnRegisterBinder()
	local Params = self.Params
	if not Params then return end
		
	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
	self.CommBackpack126Slot:SetParams({Data = ViewModel.ItemSlotVM})
end

function NightGiftGotGiftSlotView:OnGotGiftItemClicked()
	local Params = self.Params
	if not Params then return end
		
	local ViewModel = Params.Data

	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	ItemTipsUtil.ShowTipsByResID(ViewModel.ItemSlotVM.ResID , self)
end

return NightGiftGotGiftSlotView