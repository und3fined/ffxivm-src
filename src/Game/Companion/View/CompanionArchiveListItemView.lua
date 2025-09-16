---
--- Author: Administrator
--- DateTime: 2024-08-06 10:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CompanionArchiveListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBGNotOwned UFImage
---@field ImgBGOwn UFImage
---@field ImgHide UImage
---@field ImgIconNotOwned UFImage
---@field ImgIconOwn UFImage
---@field ImgSelect UFImage
---@field PanelCompanion UFCanvasPanel
---@field RedDotNew CommonRedDot2View
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanionArchiveListItemView = LuaClass(UIView, true)

function CompanionArchiveListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBGNotOwned = nil
	--self.ImgBGOwn = nil
	--self.ImgHide = nil
	--self.ImgIconNotOwned = nil
	--self.ImgIconOwn = nil
	--self.ImgSelect = nil
	--self.PanelCompanion = nil
	--self.RedDotNew = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanionArchiveListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDotNew)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionArchiveListItemView:OnInit()
	self.Binders =  {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconOwn, false, false, true) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconNotOwned, false, false, true) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsNotOwn", UIBinderValueChangedCallback.New(self, nil, self.CheckImgVisible) },
		{ "IsStoryProtect", UIBinderValueChangedCallback.New(self, nil, self.CheckImgVisible) },
	}
end

function CompanionArchiveListItemView:OnDestroy()

end

function CompanionArchiveListItemView:OnShow()

end

function CompanionArchiveListItemView:OnHide()

end

function CompanionArchiveListItemView:OnRegisterUIEvent()

end

function CompanionArchiveListItemView:OnRegisterGameEvent()

end

function CompanionArchiveListItemView:CheckImgVisible()
	UIUtil.SetIsVisible(self.ImgBGOwn, false)
	UIUtil.SetIsVisible(self.ImgIconOwn, false)
	UIUtil.SetIsVisible(self.ImgBGNotOwned, false)
	UIUtil.SetIsVisible(self.ImgIconNotOwned, false)
	UIUtil.SetIsVisible(self.ImgHide, false)

	if not self.ViewModel.IsNotOwn then
		-- 已拥有
		UIUtil.SetIsVisible(self.ImgBGOwn, true)
		UIUtil.SetIsVisible(self.ImgIconOwn, true)
	elseif not self.ViewModel.IsStoryProtect then
		-- 未拥有且不是剧情保护
		UIUtil.SetIsVisible(self.ImgBGNotOwned, true)
		UIUtil.SetIsVisible(self.ImgIconNotOwned, true)
	else
		-- 未拥有且剧情保护
		UIUtil.SetIsVisible(self.ImgHide, true)
	end
end

function CompanionArchiveListItemView:OnRegisterBinder()
	local Parmas = self.Params
	if Parmas == nil then return end

	local ViewModel = self.Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)

	self:RegisterReddot()
end

function CompanionArchiveListItemView:RegisterReddot()
	if not self.ViewModel.IsShowReddot then return end

	self.RedDotNew:SetIsCustomizeRedDot(true)
	self.RedDotNew.ItemVM = self.ViewModel.ReddotVM
end

function CompanionArchiveListItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectChanged then
		ViewModel:OnSelectChanged(IsSelected)
	end
end

return CompanionArchiveListItemView