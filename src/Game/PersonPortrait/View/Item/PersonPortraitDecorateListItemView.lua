---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")

local TabTypes = PersonPortraitDefine.TabTypes

---@class PersonPortraitDecorateListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot2 CommonRedDot2View
---@field DecorateImgPanel UFCanvasPanel
---@field ImgBg UFImage
---@field ImgDecoration UFImage
---@field ImgFrame UFImage
---@field ImgInUse UFImage
---@field ImgSecret UFImage
---@field ImgSelect UFImage
---@field LockPanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitDecorateListItemView = LuaClass(UIView, true)

function PersonPortraitDecorateListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot2 = nil
	--self.DecorateImgPanel = nil
	--self.ImgBg = nil
	--self.ImgDecoration = nil
	--self.ImgFrame = nil
	--self.ImgInUse = nil
	--self.ImgSecret = nil
	--self.ImgSelect = nil
	--self.LockPanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitDecorateListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitDecorateListItemView:OnInit()
	self.Binders = {
		{ "BgIcon", 			UIBinderSetBrushFromAssetPath.New(self, self.ImgBg, nil, false, true) },
		{ "DecorationIcon", 	UIBinderSetBrushFromAssetPath.New(self, self.ImgDecoration, nil, false, true) },
		{ "FrameIcon", 			UIBinderSetBrushFromAssetPath.New(self, self.ImgFrame, nil, false, true) },

		{ "ImgUnlockVisible", 	UIBinderSetIsVisible.New(self, self.LockPanel) },
		{ "ImgSecretVisible", 	UIBinderSetIsVisible.New(self, self.ImgSecret) },
		{ "ImgSecretVisible", 	UIBinderSetIsVisible.New(self, self.DecorateImgPanel, true) },
		{ "RedDotID", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRedDotID) },
	}

	self.BindersPersonPortraitVM = {
		{ "CurSelectResID", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSelectResID) },
		{ "CurTab", 				UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurTab) },
		{ "CurProfSetResIDsServer", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSetResIDsServer) }
	}
end

function PersonPortraitDecorateListItemView:OnDestroy()

end

function PersonPortraitDecorateListItemView:OnShow()

end

function PersonPortraitDecorateListItemView:OnHide()

end

function PersonPortraitDecorateListItemView:OnRegisterUIEvent()

end

function PersonPortraitDecorateListItemView:OnRegisterGameEvent()

end

function PersonPortraitDecorateListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
	self:RegisterBinders(PersonPortraitVM, self.BindersPersonPortraitVM)
end

function PersonPortraitDecorateListItemView:UpdateImgInUseVisible()
	local ViewModel = self.ViewModel
	if ViewModel then
		UIUtil.SetIsVisible(self.ImgInUse, table.contain(PersonPortraitVM.CurProfSetResIDsServer or {}, ViewModel.ID))
	end
end

function PersonPortraitDecorateListItemView:OnValueChangedRedDotID(ID)
	self.CommonRedDot2:SetRedDotIDByID(ID)
end

function PersonPortraitDecorateListItemView:OnValueChangedCurSelectResID(ID)
	local IsSelected = ID ~= nil and self.ViewModel ~= nil and (self.ViewModel.ID == ID) 
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

function PersonPortraitDecorateListItemView:OnValueChangedCurTab()
	local Tab = PersonPortraitVM.CurTab
    if nil == Tab or (1 << Tab) & TabTypes.Design == 0 or nil == self.ViewModel then
		return
	end

	self:UpdateImgInUseVisible()
end

function PersonPortraitDecorateListItemView:OnValueChangedCurSetResIDsServer()
	self:UpdateImgInUseVisible()
end

return PersonPortraitDecorateListItemView