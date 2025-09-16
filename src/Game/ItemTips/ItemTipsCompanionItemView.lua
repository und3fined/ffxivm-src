---
--- Author: Administrator
--- DateTime: 2024-01-17 11:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
---@class ItemTipsCompanionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field PanelMaker UFCanvasPanel
---@field RichText_Desc URichTextBox
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextLearn UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsCompanionItemView = LuaClass(UIView, true)

function ItemTipsCompanionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.PanelMaker = nil
	--self.RichText_Desc = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextLearn = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsCompanionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsCompanionItemView:OnInit()
	self.Binders = {
		{ "IntroText", UIBinderSetText.New(self, self.RichText_Desc) },
		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },
		{ "OwnText", UIBinderSetText.New(self, self.TextLearn) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
	}
end

function ItemTipsCompanionItemView:OnDestroy()

end

function ItemTipsCompanionItemView:OnShow()

end

function ItemTipsCompanionItemView:OnHide()

end

function ItemTipsCompanionItemView:OnRegisterUIEvent()

end

function ItemTipsCompanionItemView:OnRegisterGameEvent()

end

function ItemTipsCompanionItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
end

return ItemTipsCompanionItemView