---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")

local TabTypes = PersonPortraitDefine.TabTypes

---@class PersonPortraitEmotionListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EmoInfoPanel UFCanvasPanel
---@field ImgEmoAction UFImage
---@field ImgInUse UFImage
---@field ImgSecret UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitEmotionListItemView = LuaClass(UIView, true)

function PersonPortraitEmotionListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EmoInfoPanel = nil
	--self.ImgEmoAction = nil
	--self.ImgInUse = nil
	--self.ImgSecret = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitEmotionListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitEmotionListItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "EmotionIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEmoAction, nil, true) },

		{ "ImgSecretVisible", 	UIBinderSetIsVisible.New(self, self.ImgSecret) },
		{ "ImgSecretVisible", 	UIBinderSetIsVisible.New(self, self.EmoInfoPanel, true) },
		{ "ImgUnlockVisible", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsUnlock) },
	}

	self.BindersPersonPortraitVM = {
		{ "CurSelectResID", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSelectResID) },
		{ "CurTab", 				UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurTab) },
		{ "CurProfSetResIDsServer", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSetResIDsServer) }
	}
end

function PersonPortraitEmotionListItemView:OnDestroy()

end

function PersonPortraitEmotionListItemView:OnShow()

end

function PersonPortraitEmotionListItemView:OnHide()

end

function PersonPortraitEmotionListItemView:OnRegisterUIEvent()

end

function PersonPortraitEmotionListItemView:OnRegisterGameEvent()

end

function PersonPortraitEmotionListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel 
	self:RegisterBinders(ViewModel, self.Binders)
	self:RegisterBinders(PersonPortraitVM, self.BindersPersonPortraitVM)
end

function PersonPortraitEmotionListItemView:SetIcon(Img, Icon)
	if string.isnilorempty(Icon) then
		UIUtil.SetIsVisible(Img, false)

	else
		UIUtil.SetIsVisible(Img, true)
		UIUtil.ImageSetBrushFromAssetPath(Img, Icon)
	end
end

function PersonPortraitEmotionListItemView:UpdateImgInUseVisible()
	local ViewModel = self.ViewModel
	if ViewModel then
		UIUtil.SetIsVisible(self.ImgInUse, table.contain(PersonPortraitVM.CurProfSetResIDsServer or {}, ViewModel.ID))
	end
end

function PersonPortraitEmotionListItemView:OnValueChangedIsUnlock(NewValue)
	local Color = NewValue and "#696969FF" or "#FFFFFFFF"
	UIUtil.SetColorAndOpacityHex(self.ImgEmoAction, Color)
	UIUtil.SetColorAndOpacityHex(self.TextName, Color)
end

function PersonPortraitEmotionListItemView:OnValueChangedCurSelectResID(ID)
	local IsSelected = ID ~= nil and self.ViewModel ~= nil and (self.ViewModel.ID == ID) 
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
end

function PersonPortraitEmotionListItemView:OnValueChangedCurTab()
	local Tab = PersonPortraitVM.CurTab
    if nil == Tab or (1 << Tab) & TabTypes.Character == 0 or nil == self.ViewModel then
		return
	end

	self:UpdateImgInUseVisible()
end

function PersonPortraitEmotionListItemView:OnValueChangedCurSetResIDsServer()
	self:UpdateImgInUseVisible()
end

return PersonPortraitEmotionListItemView