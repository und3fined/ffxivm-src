---
--- Author: Administrator
--- DateTime: 2024-07-03 14:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class MarketSalesRecordItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClass UFButton
---@field HorizontalPrice UFHorizontalBox
---@field ImgPriceIcon UFImage
---@field ItemSlot CommBackpackSlotView
---@field PanelFriendsTag UFCanvasPanel
---@field TextAmount UFTextBlock
---@field TextName UFTextBlock
---@field TextPrice UFTextBlock
---@field TextPurchaserName UFTextBlock
---@field TextTaxRate UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketSalesRecordItemView = LuaClass(UIView, true)

function MarketSalesRecordItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClass = nil
	--self.HorizontalPrice = nil
	--self.ImgPriceIcon = nil
	--self.ItemSlot = nil
	--self.PanelFriendsTag = nil
	--self.TextAmount = nil
	--self.TextName = nil
	--self.TextPrice = nil
	--self.TextPurchaserName = nil
	--self.TextTaxRate = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketSalesRecordItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketSalesRecordItemView:OnInit()
	self.Binders = {
		{ "NameText", UIBinderSetText.New(self, self.TextName) },
		{ "PriceText", UIBinderSetTextFormatForMoney.New(self, self.TextPrice) },

		{ "PurchaserName", UIBinderSetText.New(self, self.TextPurchaserName) },
		{ "ItemNum", UIBinderSetTextFormat.New(self, self.TextAmount, "%d") },
		{ "RecordTime", UIBinderSetText.New(self, self.TextTime) },
		{ "TaxRateText", UIBinderSetText.New(self, self.TextTaxRate) },
	}
end

function MarketSalesRecordItemView:OnDestroy()

end

function MarketSalesRecordItemView:OnShow()

end

function MarketSalesRecordItemView:OnHide()

end

function MarketSalesRecordItemView:OnRegisterUIEvent()

end

function MarketSalesRecordItemView:OnRegisterGameEvent()

end

function MarketSalesRecordItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
	self.ItemSlot:SetParams({Data = ViewModel.CommItemSlotVM})
end

return MarketSalesRecordItemView