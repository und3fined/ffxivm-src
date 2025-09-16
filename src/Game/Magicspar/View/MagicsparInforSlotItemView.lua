---
--- Author: jamiyang
--- DateTime: 2023-07-26 14:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetItemMicroIcon = require("Binder/UIBinderSetItemMicroIcon")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local MagicsparInlaySlotItemVM = require("Game/Magicspar/VM/MagicsparInlaySlotItemVM")

---@class MagicsparInforSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Eff UImage
---@field FBtn_InlaySlot UFButton
---@field Img_Empty UFImage
---@field Img_Icon UFImage
---@field Img_Select UFImage
---@field AnimTip UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInforSlotItemView = LuaClass(UIView, true)

function MagicsparInforSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Eff = nil
	--self.FBtn_InlaySlot = nil
	--self.Img_Empty = nil
	--self.Img_Icon = nil
	--self.Img_Select = nil
	--self.AnimTip = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInforSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInforSlotItemView:OnInit()
	self.ViewModel = MagicsparInlaySlotItemVM.New()
end

function MagicsparInforSlotItemView:OnDestroy()

end

function MagicsparInforSlotItemView:OnShow()

end

function MagicsparInforSlotItemView:OnHide()

end

function MagicsparInforSlotItemView:OnRegisterUIEvent()

end

function MagicsparInforSlotItemView:OnRegisterGameEvent()

end

function MagicsparInforSlotItemView:OnRegisterBinder()
	local Binders = {
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Img_Select) },
		{ "ResID", UIBinderSetItemMicroIcon.New(self, self.Img_Icon) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Img_Icon) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Img_Empty, true, true) },
		{ "DefaultIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Img_Empty) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return MagicsparInforSlotItemView