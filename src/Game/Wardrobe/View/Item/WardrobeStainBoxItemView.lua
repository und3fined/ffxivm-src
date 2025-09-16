---
--- Author: Administrator
--- DateTime: 2024-02-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class WardrobeStainBoxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgCheck UFImage
---@field ImgMetal UFImage
---@field ImgNormalcy UFImage
---@field ImgSelect UFImage
---@field ImgStainColor UFImage
---@field ImgUnlock UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainBoxItemView = LuaClass(UIView, true)

function WardrobeStainBoxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgCheck = nil
	--self.ImgMetal = nil
	--self.ImgNormalcy = nil
	--self.ImgSelect = nil
	--self.ImgStainColor = nil
	--self.ImgUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainBoxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainBoxItemView:OnInit()
	self.Binders = {
		{ "Color", UIBinderSetBrushTintColorHex.New(self, self.ImgStainColor) },
		{ "ColorVisible", UIBinderSetIsVisible.New(self, self.ImgStainColor) },
		{ "IsMetal", UIBinderSetIsVisible.New(self, self.ImgMetal)},
		{ "IsNormalcy", UIBinderSetIsVisible.New(self, self.ImgNormalcy)},
		{ "IsColorUnlock", UIBinderSetIsVisible.New(self, self.ImgUnlock)},
		{ "IsChecked", UIBinderSetIsVisible.New(self, self.ImgCheck)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
	}
end

function WardrobeStainBoxItemView:OnDestroy()

end

function WardrobeStainBoxItemView:OnShow()

end

function WardrobeStainBoxItemView:OnHide()

end

function WardrobeStainBoxItemView:OnRegisterUIEvent()

end

function WardrobeStainBoxItemView:OnRegisterGameEvent()

end

function WardrobeStainBoxItemView:OnRegisterBinder()
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

function WardrobeStainBoxItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	if ViewModel.ID == 0 then
		ViewModel.IsSelected = false
		return
	end

	ViewModel.IsSelected = bSelected
end

return WardrobeStainBoxItemView