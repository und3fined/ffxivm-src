---
--- Author: Administrator
--- DateTime: 2023-08-04 12:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
---@class ItemTipsBaitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field PanelLimitation UFCanvasPanel
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextIntro UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLimit UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsBaitItemView = LuaClass(UIView, true)

function ItemTipsBaitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.PanelLimitation = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextIntro = nil
	--self.TextLevel = nil
	--self.TextLimit = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsBaitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsBaitItemView:OnInit()
	self.Binders = {
		{ "ProfDetailColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLimit) },
		{ "ProfDetailColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLevel) },
		{ "ProfText", UIBinderSetText.New(self, self.TextLimit) },
		{ "GradeText", UIBinderSetText.New(self, self.TextLevel) },

		{ "IntroText", UIBinderSetText.New(self, self.TextIntro) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },
	}
end

function ItemTipsBaitItemView:OnDestroy()

end

function ItemTipsBaitItemView:OnShow()

end

function ItemTipsBaitItemView:OnHide()

end

function ItemTipsBaitItemView:OnRegisterUIEvent()

end

function ItemTipsBaitItemView:OnRegisterGameEvent()

end

function ItemTipsBaitItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)

	self.TextBP:SetText(LSTR(1020034))
	self.TextSP:SetText(LSTR(1020035))
end

return ItemTipsBaitItemView