---
--- Author: anypkvcai
--- DateTime: 2022-09-19 19:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local SampleVM = require("Game/Sample/SampleVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
--local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
--local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
--local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetGenderName = require("Binder/UIBinderSetGenderName")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
--local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class SampleBinderPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextColor UFTextBlock
---@field TextGenderName UFTextBlock
---@field TextIsVisible UFTextBlock
---@field TextLocalString UFTextBlock
---@field TextProfName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SampleBinderPageView = LuaClass(UIView, true)

function SampleBinderPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextColor = nil
	--self.TextGenderName = nil
	--self.TextIsVisible = nil
	--self.TextLocalString = nil
	--self.TextProfName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SampleBinderPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SampleBinderPageView:OnInit()
	self.Binders = {
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextColor) },
		{ "GenderID", UIBinderSetGenderName.New(self, self.TextGenderName) },
		{ "IsVisible", UIBinderSetIsVisible.New(self, self.TextIsVisible) },
		{ "LocalString", UIBinderSetText.New(self, self.TextLocalString) },
		{ "ProfID", UIBinderSetProfName.New(self, self.TextProfName) },
	}
end

function SampleBinderPageView:OnDestroy()

end

function SampleBinderPageView:OnShow()

end

function SampleBinderPageView:OnHide()

end

function SampleBinderPageView:OnRegisterUIEvent()

end

function SampleBinderPageView:OnRegisterGameEvent()

end

function SampleBinderPageView:OnRegisterBinder()
	local ViewModel = SampleVM

	self:RegisterBinders(ViewModel, self.Binders)
end

return SampleBinderPageView