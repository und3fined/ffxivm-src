---
--- Author: Administrator
--- DateTime: 2025-03-20 16:02
--- Description: 染色区域列表Tab
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetOutlineColor = require("Binder/UIBinderSetOutlineColor")

local NormalColor = "#878075"
local SelectedColor = "#FFF4D0"

local OutlineNormalColor = "#2121217F"
local OutlineSelectedColor = "#8066447F"

---@class WardrobeStainTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---@field WardrobeStainTag WardrobeStainTagItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainTabItemView = LuaClass(UIView, true)

function WardrobeStainTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.TextName = nil
	--self.WardrobeStainTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WardrobeStainTag)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainTabItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName)},
		{ "Color", UIBinderSetBrushTintColorHex.New(self, self.WardrobeStainTag.ImgStainColor) },
		{ "IsStain", UIBinderSetIsVisible.New(self, self.WardrobeStainTag.ImgStainColor) },
		{ "IsMetal", UIBinderSetIsVisible.New(self, self.WardrobeStainTag.ImgMetal)},
		{ "IsNormalcy", UIBinderSetIsVisible.New(self, self.WardrobeStainTag.ImgNormalcy)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "TabSelectedColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName)},
		{ "TabOutlineSelectedColor", UIBinderSetOutlineColor.New(self, self.TextName)},
	}
end

function WardrobeStainTabItemView:OnDestroy()

end

function WardrobeStainTabItemView:OnShow()
	self.TextName.Font.OutlineSettings.OutlineSize = 2
end

function WardrobeStainTabItemView:OnHide()

end

function WardrobeStainTabItemView:OnRegisterUIEvent()

end

function WardrobeStainTabItemView:OnRegisterGameEvent()

end

function WardrobeStainTabItemView:OnRegisterBinder()
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

function WardrobeStainTabItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
	ViewModel.TabSelectedColor = bSelected and SelectedColor or NormalColor
	ViewModel.TabOutlineSelectedColor = bSelected and OutlineSelectedColor or OutlineNormalColor
end

return WardrobeStainTabItemView