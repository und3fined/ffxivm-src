---
--- Author: Administrator
--- DateTime: 2024-02-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")

---@class WardrobePresetsSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgEquipment UFImage
---@field ImgNo UFImage
---@field StainTag WardrobeStainTagItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobePresetsSlotItemView = LuaClass(UIView, true)

function WardrobePresetsSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgEquipment = nil
	--self.ImgNo = nil
	--self.StainTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobePresetsSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.StainTag)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobePresetsSlotItemView:OnInit()
	self.Binders = {
		{ "EquipmentIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEquipment) },
		{ "EquipmentIconAlpha", UIBinderSetOpacity.New(self, self.ImgEquipment) },
		{ "StainTagVisible", UIBinderSetIsVisible.New(self, self.StainTag) },
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconslotBkg) },
		{ "ItemQualityVisible", UIBinderSetIsVisible.New(self, self.ImgIconslotBkg) },
		{ "IsEmpty", UIBinderSetIsVisible.New(self, self.FImgEmptyBg) },
		{ "CanEquiped", UIBinderSetIsVisible.New(self, self.ImgNo, true) },
		{ "CanEquiped", UIBinderSetIsVisible.New(self, self.FImg_Mask, true) },
		{ "StainColorVisible", UIBinderSetIsVisible.New(self, self.StainTag.ImgDye)},
	}
end

function WardrobePresetsSlotItemView:OnDestroy()

end

function WardrobePresetsSlotItemView:OnShow()
	UIUtil.SetIsVisible(self.StainTag.ImgStainColor, false)
end

function WardrobePresetsSlotItemView:OnHide()

end

function WardrobePresetsSlotItemView:OnRegisterUIEvent()

end

function WardrobePresetsSlotItemView:OnRegisterGameEvent()

end

function WardrobePresetsSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return WardrobePresetsSlotItemView