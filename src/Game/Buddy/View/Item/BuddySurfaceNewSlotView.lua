---
--- Author: Administrator
--- DateTime: 2025-06-09 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class BuddySurfaceNewSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCheck UFImage
---@field ImgEquipment UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceNewSlotView = LuaClass(UIView, true)

function BuddySurfaceNewSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCheck = nil
	--self.ImgEquipment = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceNewSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceNewSlotView:OnInit()
	self.Binders = {
		{ "ImgCheckVisible", UIBinderSetIsVisible.New(self, self.ImgCheck) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEquipment) },
		{ "EquipmentText", UIBinderSetText.New(self, self.TextName) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },

	}
end

function BuddySurfaceNewSlotView:OnDestroy()

end

function BuddySurfaceNewSlotView:OnShow()

end

function BuddySurfaceNewSlotView:OnHide()

end

function BuddySurfaceNewSlotView:OnRegisterUIEvent()
	
end

function BuddySurfaceNewSlotView:OnRegisterGameEvent()

end

function BuddySurfaceNewSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return BuddySurfaceNewSlotView