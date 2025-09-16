---
--- Author: Administrator
--- DateTime: 2024-09-13 16:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class NewBagProfessionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconProfession UFImage
---@field ImgDrugDisabled UFImage
---@field ImgDrugNoSet UFImage
---@field ImgDrugSet UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagProfessionItemView = LuaClass(UIView, true)

function NewBagProfessionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconProfession = nil
	--self.ImgDrugDisabled = nil
	--self.ImgDrugNoSet = nil
	--self.ImgDrugSet = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagProfessionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagProfessionItemView:OnInit()
	self.Binders = {
		{ "IconColor", UIBinderSetBrushTintColorHex.New(self, self.IconProfession) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "ProfID", UIBinderSetProfIcon.New(self, self.IconProfession) },
		{ "Opacity", UIBinderSetRenderOpacity.New(self, self.IconProfession) },
		{ "DrugIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgDrugSet) },
		{ "SetVisible", UIBinderSetIsVisible.New(self, self.ImgDrugSet) },
		{ "NotSetVisible", UIBinderSetIsVisible.New(self, self.ImgDrugNoSet) },
		{ "NotDrugVisible", UIBinderSetIsVisible.New(self, self.ImgDrugDisabled) },
	}
end

function NewBagProfessionItemView:OnDestroy()

end

function NewBagProfessionItemView:OnShow()

end

function NewBagProfessionItemView:OnHide()

end

function NewBagProfessionItemView:OnRegisterUIEvent()

end

function NewBagProfessionItemView:OnRegisterGameEvent()

end

function NewBagProfessionItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

return NewBagProfessionItemView