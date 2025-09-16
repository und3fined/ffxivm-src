---
--- Author: Administrator
--- DateTime: 2025-03-20 18:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")

---@class WardrobeStainStyleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStyle UFButton
---@field ImgBg UFImage
---@field ImgStainColor UFImage
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainStyleItemView = LuaClass(UIView, true)

function WardrobeStainStyleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStyle = nil
	--self.ImgBg = nil
	--self.ImgStainColor = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainStyleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainStyleItemView:OnInit()
	self.Binders = {
		{ "Color", UIBinderSetBrushTintColorHex.New(self, self.ImgStainColor) },
	}
end

function WardrobeStainStyleItemView:OnDestroy()

end

function WardrobeStainStyleItemView:OnShow()

end

function WardrobeStainStyleItemView:OnHide()

end

function WardrobeStainStyleItemView:OnRegisterUIEvent()
end

function WardrobeStainStyleItemView:OnRegisterGameEvent()

end

function WardrobeStainStyleItemView:OnRegisterBinder()
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

function WardrobeStainStyleItemView:OnSelectChanged(bSelected)
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

return WardrobeStainStyleItemView