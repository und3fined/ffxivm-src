---
--- Author: Administrator
--- DateTime: 2024-02-20 20:19
--- Description:外观列表Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationThingItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCheck UFImage
---@field ImgFocus UFImage
---@field ImgHave UFImage
---@field ImgTarget UFImage
---@field ImgThing UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationThingItemView = LuaClass(UIView, true)

function FashionEvaluationThingItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCheck = nil
	--self.ImgFocus = nil
	--self.ImgHave = nil
	--self.ImgTarget = nil
	--self.ImgThing = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationThingItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationThingItemView:OnInit()
	self.Binders = {
		{"AppearanceName", UIBinderSetText.New(self, self.TextName)},
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgThing)},
		{"IsVailid", UIBinderSetIsVisible.New(self, self.ImgThing)},
		{"IsEquiped", UIBinderSetIsVisible.New(self, self.ImgCheck)},
		{"IsEquiped", UIBinderSetIsVisible.New(self, self.ImgFocus)},
		{"IsOwn", UIBinderSetIsVisible.New(self, self.ImgHave)},
		{"IsTracked", UIBinderSetIsVisible.New(self, self.ImgTarget)},
	}
end

function FashionEvaluationThingItemView:OnDestroy()

end

function FashionEvaluationThingItemView:OnShow()

end

function FashionEvaluationThingItemView:OnHide()

end

function FashionEvaluationThingItemView:OnRegisterUIEvent()

end

function FashionEvaluationThingItemView:OnRegisterGameEvent()
end

function FashionEvaluationThingItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function FashionEvaluationThingItemView:OnSelectChanged(IsSelected)
	--UIUtil.SetIsVisible(self.ImgEquipeSelect, IsSelected)
end

return FashionEvaluationThingItemView