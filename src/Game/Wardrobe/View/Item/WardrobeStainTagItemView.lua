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

---@class WardrobeStainTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgDye UFImage
---@field ImgStainColor UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainTagItemView = LuaClass(UIView, true)

function WardrobeStainTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgDye = nil
	--self.ImgStainColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainTagItemView:OnInit()
	self.Binders = {
		{ "StainColor", UIBinderSetBrushTintColorHex.New(self, self.ImgStainColor)},
		{ "StainColorVisible", UIBinderSetIsVisible.New(self, self.ImgDye)} ,
	}
end

function WardrobeStainTagItemView:OnDestroy()

end

function WardrobeStainTagItemView:OnShow()

end

function WardrobeStainTagItemView:OnHide()

end

function WardrobeStainTagItemView:OnRegisterUIEvent()

end

function WardrobeStainTagItemView:OnRegisterGameEvent()

end

function WardrobeStainTagItemView:OnRegisterBinder()
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

return WardrobeStainTagItemView