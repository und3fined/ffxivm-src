---
--- Author: HugoWong
--- DateTime: 2023-11-17 17:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CompanionListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ImgCalled UFImage
---@field ImgEmpty UFImage
---@field ImgFavourite UFImage
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field PanelCompanion UFCanvasPanel
---@field RedDotNew CommonRedDot2View
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanionListItemView = LuaClass(UIView, true)

function CompanionListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ImgCalled = nil
	--self.ImgEmpty = nil
	--self.ImgFavourite = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.PanelCompanion = nil
	--self.RedDotNew = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanionListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDotNew)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionListItemView:OnInit()
	self.Binders =  {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon, false, false, true) },
		{ "IsCalled", UIBinderSetIsVisible.New(self, self.ImgCalled) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsFavourite", UIBinderSetIsVisible.New(self, self.ImgFavourite) },
		{ "IsEmpty", UIBinderSetIsVisible.New(self, self.ImgEmpty) },
		{ "IsEmpty", UIBinderSetIsVisible.New(self, self.PanelCompanion, true, true) },
	}
end

function CompanionListItemView:OnDestroy()

end

function CompanionListItemView:OnShow()

end

function CompanionListItemView:OnHide()

end

function CompanionListItemView:OnRegisterUIEvent()

end

function CompanionListItemView:OnRegisterGameEvent()

end

function CompanionListItemView:OnRegisterBinder()
	local Parmas = self.Params
	if Parmas == nil then return end

	local ViewModel = self.Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)

	self:RegisterReddot()
end

function CompanionListItemView:RegisterReddot()
	if not self.ViewModel.IsShowReddot then return end

	self.RedDotNew:SetIsCustomizeRedDot(true)
	self.RedDotNew.ItemVM = self.ViewModel.ReddotVM
end

function CompanionListItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectChanged then
		ViewModel:OnSelectChanged(IsSelected)
	end
end

return CompanionListItemView