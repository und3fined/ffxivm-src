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
---@field ImgSelect UFCanvasPanel
---@field SizeBox_0 USizeBox
---@field TextName UFTextBlock
---@field WardrobeStainTag WardrobeStainTagItemView
---@field WardrobeStainTagNew WardrobeStainStyleItem2View
---@field WardrobeStainTagNew2 WardrobeStainStyleItem2View
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainTabItemView = LuaClass(UIView, true)

function WardrobeStainTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.SizeBox_0 = nil
	--self.TextName = nil
	--self.WardrobeStainTag = nil
	--self.WardrobeStainTagNew = nil
	--self.WardrobeStainTagNew2 = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WardrobeStainTag)
	self:AddSubView(self.WardrobeStainTagNew)
	self:AddSubView(self.WardrobeStainTagNew2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainTabItemView:OnInit()
	UIUtil.SetIsVisible(self.WardrobeStainTag, false)
	UIUtil.SetIsVisible(self.WardrobeStainTagNew, true)
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


	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName)}, --
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "TabSelectedColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName)},
		{ "TabOutlineSelectedColor", UIBinderSetOutlineColor.New(self, self.TextName)},
		-- 新增逻辑
		{ "IsPreStained", UIBinderSetIsVisible.New(self, self.SizeBox_0) }, -- 是否有预览色
		{ "IsPreStained", UIBinderSetIsVisible.New(self, self.WardrobeStainTagNew2) }, --是否有预览色

		{ "IsPreColorEmpty", UIBinderSetIsVisible.New(self, self.WardrobeStainTagNew2.ImgStainColor, true) },
		{ "PreColorHex", UIBinderSetBrushTintColorHex.New(self, self.WardrobeStainTagNew2.ImgStainColor) },
		{ "PreColorIsMetal", UIBinderSetIsVisible.New(self, self.WardrobeStainTagNew2.ImgMetal) },

		{ "ColorIsMetal", UIBinderSetIsVisible.New(self, self.WardrobeStainTagNew.ImgMetal) },
		{ "IsColorEmpty", UIBinderSetIsVisible.New(self, self.WardrobeStainTagNew.ImgStainColor, true) },
		{ "ColorHex", UIBinderSetBrushTintColorHex.New(self, self.WardrobeStainTagNew.ImgStainColor) },
	}

	self:RegisterBinders(ViewModel, Binders)
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

function WardrobeStainTabItemView:PlaySelectedAnim()
	self:PlayAnimation(self.AnimSelect)
end

return WardrobeStainTabItemView