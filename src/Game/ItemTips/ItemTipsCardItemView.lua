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
---@class ItemTipsCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field ImgStar1 UFImage
---@field ImgStar2 UFImage
---@field ImgStar3 UFImage
---@field ImgStar4 UFImage
---@field ImgStar5 UFImage
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextIntro UFTextBlock
---@field TextLearn UFTextBlock
---@field TextRarity UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsCardItemView = LuaClass(UIView, true)

function ItemTipsCardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.ImgStar1 = nil
	--self.ImgStar2 = nil
	--self.ImgStar3 = nil
	--self.ImgStar4 = nil
	--self.ImgStar5 = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextIntro = nil
	--self.TextLearn = nil
	--self.TextRarity = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsCardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsCardItemView:OnInit()
	self.Binders = {
		{ "IntroText", UIBinderSetText.New(self, self.TextIntro) },

		{ "StarImg1", UIBinderSetIsVisible.New(self, self.ImgStar1) },
		{ "StarImg2", UIBinderSetIsVisible.New(self, self.ImgStar2) },
		{ "StarImg3", UIBinderSetIsVisible.New(self, self.ImgStar3) },
		{ "StarImg4", UIBinderSetIsVisible.New(self, self.ImgStar4) },
		{ "StarImg5", UIBinderSetIsVisible.New(self, self.ImgStar5) },

		{ "IncludeText", UIBinderSetText.New(self, self.TextLearn) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
	}

end

function ItemTipsCardItemView:OnDestroy()

end

function ItemTipsCardItemView:OnShow()

end

function ItemTipsCardItemView:OnHide()

end

function ItemTipsCardItemView:OnRegisterUIEvent()

end

function ItemTipsCardItemView:OnRegisterGameEvent()

end

function ItemTipsCardItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	
	self:RegisterBinders(ViewModel, self.Binders)

	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
	self.TextRarity:SetText(LSTR(1020036))
end

return ItemTipsCardItemView