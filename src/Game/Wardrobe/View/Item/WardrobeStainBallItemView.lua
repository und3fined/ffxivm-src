---
--- Author: Administrator
--- DateTime: 2024-02-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class WardrobeStainBallItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgBg2 UFImage
---@field ImgMetalColor UFImage
---@field ImgSelect UFImage
---@field ImgStainColor UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainBallItemView = LuaClass(UIView, true)

function WardrobeStainBallItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgBg2 = nil
	--self.ImgMetalColor = nil
	--self.ImgSelect = nil
	--self.ImgStainColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainBallItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainBallItemView:OnInit()
	self.Binders = {
		{ "ColorImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgStainColor) },
		{ "StainVisible", UIBinderSetIsVisible.New(self, self.ImgStainColor) },
		{ "IsMetal", UIBinderSetIsVisible.New(self, self.ImgMetalColor)},
		{ "StainVisible", UIBinderSetIsVisible.New(self, self.ImgBg2)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
	}
end

function WardrobeStainBallItemView:OnDestroy()

end

function WardrobeStainBallItemView:OnShow()

end

function WardrobeStainBallItemView:OnHide()

end

function WardrobeStainBallItemView:OnRegisterUIEvent()

end

function WardrobeStainBallItemView:OnRegisterGameEvent()

end

function WardrobeStainBallItemView:OnRegisterBinder()
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

function WardrobeStainBallItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end



return WardrobeStainBallItemView