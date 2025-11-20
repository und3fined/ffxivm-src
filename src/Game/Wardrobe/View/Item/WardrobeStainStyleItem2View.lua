---
--- Author: Administrator
--- DateTime: 2025-08-05 11:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")


---@class WardrobeStainStyleItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgMetal UFImage
---@field ImgStainColor UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeStainStyleItem2View = LuaClass(UIView, true)

function WardrobeStainStyleItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgMetal = nil
	--self.ImgStainColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeStainStyleItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeStainStyleItem2View:OnInit()
end

function WardrobeStainStyleItem2View:OnDestroy()

end

function WardrobeStainStyleItem2View:OnShow()

end

function WardrobeStainStyleItem2View:OnHide()

end

function WardrobeStainStyleItem2View:OnRegisterUIEvent()

end

function WardrobeStainStyleItem2View:OnRegisterGameEvent()

end

function WardrobeStainStyleItem2View:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	local Binders = {
		{ "Color", UIBinderSetBrushTintColorHex.New(self, self.ImgStainColor) },
		{ "IsMetal", UIBinderSetIsVisible.New(self, self.ImgMetal) },
	}

	self:RegisterBinders(ViewModel, Binders)
end


return WardrobeStainStyleItem2View