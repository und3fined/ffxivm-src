---
--- Author: Administrator
--- DateTime: 2023-11-17 15:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
---@class ItemTipsBuddyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBuff UFImage
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field PanelEffect UFCanvasPanel
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextE UFTextBlock
---@field TextEffect UFTextBlock
---@field TextIntro UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsBuddyItemView = LuaClass(UIView, true)

function ItemTipsBuddyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBuff = nil
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.PanelEffect = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextE = nil
	--self.TextEffect = nil
	--self.TextIntro = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsBuddyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsBuddyItemView:OnInit()
	self.Binders = {
		{ "IntroText", UIBinderSetText.New(self, self.TextIntro) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "EffectText", UIBinderSetText.New(self, self.TextEffect) },
		{ "BuffImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBuff) },
		{ "BuffTitle", UIBinderSetText.New(self, self.TextE) },
		
		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
		
	}
end

function ItemTipsBuddyItemView:OnDestroy()

end

function ItemTipsBuddyItemView:OnShow()

end

function ItemTipsBuddyItemView:OnHide()

end

function ItemTipsBuddyItemView:OnRegisterUIEvent()

end

function ItemTipsBuddyItemView:OnRegisterGameEvent()

end

function ItemTipsBuddyItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
end

return ItemTipsBuddyItemView