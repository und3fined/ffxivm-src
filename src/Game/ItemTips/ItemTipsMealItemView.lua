---
--- Author: Administrator
--- DateTime: 2023-08-04 12:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
---@class ItemTipsMealItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextD UFTextBlock
---@field TextDuration UFTextBlock
---@field TextEffect UFTextBlock
---@field TextEffextDesc UFTextBlock
---@field TextIntro UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsMealItemView = LuaClass(UIView, true)

function ItemTipsMealItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextD = nil
	--self.TextDuration = nil
	--self.TextEffect = nil
	--self.TextEffextDesc = nil
	--self.TextIntro = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsMealItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsMealItemView:OnInit()
	self.Binders = {
		{ "EffectText", UIBinderSetText.New(self, self.TextEffextDesc) },
		{ "IntroText", UIBinderSetText.New(self, self.TextIntro) },

		{ "DurationText", UIBinderSetText.New(self, self.TextDuration) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
	}
end

function ItemTipsMealItemView:OnDestroy()

end

function ItemTipsMealItemView:OnShow()

end

function ItemTipsMealItemView:OnHide()

end

function ItemTipsMealItemView:OnRegisterUIEvent()

end

function ItemTipsMealItemView:OnRegisterGameEvent()

end

function ItemTipsMealItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)

	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
	self.TextEffect:SetText(LSTR(1020049))
	self.TextD:SetText(LSTR(1020050))
end

return ItemTipsMealItemView