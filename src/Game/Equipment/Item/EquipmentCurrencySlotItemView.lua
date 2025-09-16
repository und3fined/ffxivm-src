---
--- Author: ds_tianjiateng
--- DateTime: 2024-06-27 15:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class EquipmentCurrencySlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field FBtn_Item UFButton
---@field FImg_Icon UFImage
---@field FImg_Mask UFImage
---@field FImg_Quality UFImage
---@field FImg_Select UFImage
---@field IconLock UFImage
---@field PanelInfo UFCanvasPanel
---@field RichTextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentCurrencySlotItemView = LuaClass(UIView, true)

function EquipmentCurrencySlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--self.FBtn_Item = nil
	--self.FImg_Icon = nil
	--self.FImg_Mask = nil
	--self.FImg_Quality = nil
	--self.FImg_Select = nil
	--self.IconLock = nil
	--self.PanelInfo = nil
	--self.RichTextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencySlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencySlotItemView:OnInit()

end

function EquipmentCurrencySlotItemView:OnDestroy()

end

function EquipmentCurrencySlotItemView:OnShow()

end

function EquipmentCurrencySlotItemView:OnHide()

end

function EquipmentCurrencySlotItemView:OnRegisterUIEvent()

end

function EquipmentCurrencySlotItemView:OnRegisterGameEvent()

end

function EquipmentCurrencySlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
	   return
	end

	local Data = Params.Data
	if nil == Data then
	   return
	end

	local Binders = {  
		{ "IsLock", 		UIBinderSetIsVisible.New(self, self.IconLock) },
		{ "ItemIcon", 		UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.Icon) },
		{ "QualityIcon", 	UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.ImgQuanlity) },
		
	}
	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, Binders)
end

return EquipmentCurrencySlotItemView