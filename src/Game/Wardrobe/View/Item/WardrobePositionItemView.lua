---
--- Author: Administrator
--- DateTime: 2024-02-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class WardrobePositionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconPosition UFImage
---@field IconPositionSelect UFImage
---@field IconState UFImage
---@field ImgSelect UFImage
---@field StainTag WardrobeStainTagItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobePositionItemView = LuaClass(UIView, true)

function WardrobePositionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconPosition = nil
	--self.IconPositionSelect = nil
	--self.IconState = nil
	--self.ImgSelect = nil
	--self.StainTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobePositionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.StainTag)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobePositionItemView:OnInit()
	self.Binders = {
		{ "StainTagVisible", UIBinderSetIsVisible.New(self, self.StainTag) },
		{ "StateIconVisible", UIBinderSetIsVisible.New(self, self.IconPosition, true) },
		{ "StateIconVisible", UIBinderSetIsVisible.New(self, self.IconState) },
		{ "StainColorVisible", UIBinderSetIsVisible.New(self, self.StainTag.ImgDye)} ,
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "StateIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconState) },
		{ "PositionIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconPosition) },
		{ "PositionSelectVisible", UIBinderSetIsVisible.New(self, self.IconPositionSelect) },
		{ "PositionSelectIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconPositionSelect) },
		-- { "StainColor", UIBinderSetBrushTintColorHex.New(self, self.StainTag.ImgStainColor)},
	}

end

function WardrobePositionItemView:OnDestroy()

end

function WardrobePositionItemView:OnShow()
	UIUtil.SetIsVisible(self.StainTag.ImgStainColor, false)
end

function WardrobePositionItemView:OnHide()

end

function WardrobePositionItemView:OnRegisterUIEvent()

end

function WardrobePositionItemView:OnRegisterGameEvent()

end

function WardrobePositionItemView:OnRegisterBinder()
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

function WardrobePositionItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
	if ViewModel.bShowSelectedState then
		ViewModel.StateIconVisible = false
		ViewModel.PositionSelectVisible = bSelected
	else
		if ViewModel.StateIcon ~= "" then
			ViewModel.PositionSelectVisible = false
		else
			ViewModel.PositionSelectVisible = bSelected
		end
	end
end

return WardrobePositionItemView