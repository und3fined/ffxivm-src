---
--- Author: sammrli
--- DateTime: 2024-02-02 17:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require ("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require ("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require ("Binder/UIBinderSetColorAndOpacityHex")

---@class TravelLogVideoSequenceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgBgNoContent UFImage
---@field PanelFocus UFCanvasPanel
---@field TextQuantity UFTextBlock
---@field AnimChecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TravelLogVideoSequenceItemView = LuaClass(UIView, true)

function TravelLogVideoSequenceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgBgNoContent = nil
	--self.PanelFocus = nil
	--self.TextQuantity = nil
	--self.AnimChecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TravelLogVideoSequenceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TravelLogVideoSequenceItemView:OnInit()

end

function TravelLogVideoSequenceItemView:OnDestroy()

end

function TravelLogVideoSequenceItemView:OnShow()

end

function TravelLogVideoSequenceItemView:OnHide()

end

function TravelLogVideoSequenceItemView:OnRegisterUIEvent()

end

function TravelLogVideoSequenceItemView:OnRegisterGameEvent()

end

function TravelLogVideoSequenceItemView:OnRegisterBinder()
	if nil == self.Params then return end

	---@type TravelLogVideoSequenceItemVM
	self.ViewModel = self.Params.Data

	local Binders = {
		{ "Text", UIBinderSetText.New(self, self.TextQuantity) },
		{ "IsNoContent", UIBinderSetIsVisible.New(self, self.ImgBg, true, true)},
		{ "IsNoContent", UIBinderSetIsVisible.New(self, self.ImgBgNoContent, false, true)},
		{ "Selected", UIBinderSetIsVisible.New(self, self.PanelFocus)},
		{ "ColorHex", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity)},
		{ "Selected", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedChange)},
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function TravelLogVideoSequenceItemView:OnSelectedChange(Val)
	if Val then
		self:PlayAnimation(self.AnimChecked)
	end
end

return TravelLogVideoSequenceItemView