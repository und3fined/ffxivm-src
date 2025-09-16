---
--- Author: Administrator
--- DateTime: 2023-08-04 12:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
---@class ItemTipsMedicineItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextD UFTextBlock
---@field TextDuration UFTextBlock
---@field TextE UFTextBlock
---@field TextEffect UFTextBlock
---@field TextIntro UFTextBlock
---@field TextRT UFTextBlock
---@field TextRecastTime UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsMedicineItemView = LuaClass(UIView, true)

function ItemTipsMedicineItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextD = nil
	--self.TextDuration = nil
	--self.TextE = nil
	--self.TextEffect = nil
	--self.TextIntro = nil
	--self.TextRT = nil
	--self.TextRecastTime = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsMedicineItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsMedicineItemView:OnInit()
	self.Binders = {
		{ "RecastTimeText", UIBinderSetText.New(self, self.TextRecastTime) },

		{ "EffectText", UIBinderSetText.New(self, self.TextEffect) },
		{ "IntroText", UIBinderSetText.New(self, self.TextIntro) },

		{ "DurationText", UIBinderSetText.New(self, self.TextDuration) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
	}
end

function ItemTipsMedicineItemView:OnDestroy()

end

function ItemTipsMedicineItemView:OnShow()

end

function ItemTipsMedicineItemView:OnHide()

end

function ItemTipsMedicineItemView:OnRegisterUIEvent()

end

function ItemTipsMedicineItemView:OnRegisterGameEvent()

end

function ItemTipsMedicineItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	

	self:RegisterBinders(ViewModel, self.Binders)

	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
	self.TextE:SetText(LSTR(1020049))
	self.TextD:SetText(LSTR(1020050))
	self.TextRT:SetText(LSTR(1020051))
end

return ItemTipsMedicineItemView