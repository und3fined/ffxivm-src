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
---@class ItemTipsCollectionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field PanelMaker UFCanvasPanel
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextCV UFTextBlock
---@field TextCollection UFTextBlock
---@field TextCollectionValue UFTextBlock
---@field TextIntro UFTextBlock
---@field TextMakerName UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsCollectionItemView = LuaClass(UIView, true)

function ItemTipsCollectionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.PanelMaker = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextCV = nil
	--self.TextCollection = nil
	--self.TextCollectionValue = nil
	--self.TextIntro = nil
	--self.TextMakerName = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsCollectionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsCollectionItemView:OnInit()
	self.Binders = {
		{ "CollectionValueText", UIBinderSetText.New(self, self.TextCollectionValue) },
		{ "IntroText", UIBinderSetText.New(self, self.TextIntro) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "MakerNameText", UIBinderSetText.New(self, self.TextMakerName) },
		{ "MakerNameVisible", UIBinderSetIsVisible.New(self, self.PanelMaker) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
	}
end

function ItemTipsCollectionItemView:OnDestroy()

end

function ItemTipsCollectionItemView:OnShow()

end

function ItemTipsCollectionItemView:OnHide()

end

function ItemTipsCollectionItemView:OnRegisterUIEvent()

end

function ItemTipsCollectionItemView:OnRegisterGameEvent()

end

function ItemTipsCollectionItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end


	self:RegisterBinders(ViewModel, self.Binders)
	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
	self.TextCollection:SetText(LSTR(1020037))
	self.TextCV:SetText(LSTR(1020038))
end

return ItemTipsCollectionItemView