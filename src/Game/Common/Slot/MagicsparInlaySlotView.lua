---
--- Author: enqingchen
--- DateTime: 2021-12-29 17:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetItemMicroIcon = require("Binder/UIBinderSetItemMicroIcon")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local MagicsparInlaySlotItemVM = require("Game/Magicspar/VM/MagicsparInlaySlotItemVM")
---@class MagicsparInlaySlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Eff UImage
---@field FBtn_InlaySlot UFButton
---@field Img_Empty UFImage
---@field Img_Icon UFImage
---@field Img_Select UFImage
---@field AnimTip UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInlaySlotView = LuaClass(UIView, true)

function MagicsparInlaySlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Eff = nil
	--self.FBtn_InlaySlot = nil
	--self.Img_Empty = nil
	--self.Img_Icon = nil
	--self.Img_Select = nil
	--self.AnimTip = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInlaySlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInlaySlotView:OnInit()
	self.ViewModel = MagicsparInlaySlotItemVM.New()
	self.Binders = {
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Img_Select) },
		{ "ResID", UIBinderSetItemMicroIcon.New(self, self.Img_Icon) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Img_Icon) },
		{ "bInlay", UIBinderSetIsVisible.New(self, self.Img_Empty, true, true) },
		{ "DefaultIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Img_Empty) },
	}
end

function MagicsparInlaySlotView:OnDestroy()

end

function MagicsparInlaySlotView:OnShow()

end

function MagicsparInlaySlotView:OnHide()

end

function MagicsparInlaySlotView:OnRegisterUIEvent()

end

function MagicsparInlaySlotView:OnRegisterGameEvent()

end

function MagicsparInlaySlotView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return MagicsparInlaySlotView