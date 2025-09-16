
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class StoreGoodsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field HorizontalPrice UFHorizontalBox
---@field ImgDeadline UFImage
---@field ImgGoods UFImage
---@field ImgMoney UFImage
---@field ImgSelect UFImage
---@field PanelDeadline UFCanvasPanel
---@field PanelDiscount UFCanvasPanel
---@field PanelHotSale UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field SizeBoxCurrent USizeBox
---@field TextCurrentPrice UFTextBlock
---@field TextDeadline UFTextBlock
---@field TextDiscount UFTextBlock
---@field TextHotSale UFTextBlock
---@field TextItemName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextState UFTextBlock
---@field VerticalBoxInfo UFVerticalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGoodsItemView = LuaClass(UIView, true)

function StoreGoodsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.HorizontalPrice = nil
	--self.ImgDeadline = nil
	--self.ImgGoods = nil
	--self.ImgMoney = nil
	--self.ImgSelect = nil
	--self.PanelDeadline = nil
	--self.PanelDiscount = nil
	--self.PanelHotSale = nil
	--self.PanelOriginal = nil
	--self.SizeBoxCurrent = nil
	--self.TextCurrentPrice = nil
	--self.TextDeadline = nil
	--self.TextDiscount = nil
	--self.TextHotSale = nil
	--self.TextItemName = nil
	--self.TextOriginalPrice = nil
	--self.TextState = nil
	--self.VerticalBoxInfo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGoodsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreGoodsItemView:OnInit()
	self.Binders = {
		{ "GoodIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgGoods) },
		{ "StateTextVisible", UIBinderSetIsVisible.New(self, self.TextState) },
		{ "HorizontalPriceVisible", UIBinderSetIsVisible.New(self, self.HorizontalPrice) },
		{ "OriginalPanelVisible", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
		{ "HotSaleVisible", UIBinderSetIsVisible.New(self, self.PanelHotSale) },
		{ "OriginalPriceVisible", UIBinderSetIsVisible.New(self, self.TextOriginalPrice) },
		-- { "PanelDiscountVisible", UIBinderSetIsVisible.New(self, self.VerticalBoxInfo) },
		{ "LimitationVisible", UIBinderSetIsVisible.New(self, self.HorizontalLimitation) },
		{ "DiscountPanelVisible", UIBinderSetIsVisible.New(self, self.PanelDiscount) },
		{ "DeadlinePanelVisible", UIBinderSetIsVisible.New(self, self.PanelDeadline) },
		{ "IsShowTimeSaleIcon", UIBinderSetIsVisible.New(self, self.ImgDeadline) },
		{ "GoodStateText", UIBinderSetText.New(self, self.TextState) },
		{ "SaleRuleText", UIBinderSetText.New(self, self.TextHotSale) },
		{ "LimitationText", UIBinderSetText.New(self, self.TextLimitation) },
		{ "AmountText", UIBinderSetText.New(self, self.TextAmount) },
		{ "OriginalPriceText", UIBinderSetText.New(self, self.TextOriginalPrice) },
		{ "CrystalText", UIBinderSetText.New(self, self.TextCurrentPrice) },
		{ "DiscountText", UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeSaleText", UIBinderSetText.New(self, self.TextDeadline) },
		{ "ItemNameText", UIBinderSetText.New(self, self.TextItemName) },
		{ "SoldOutStateColor", UIBinderSetColorAndOpacityHex.New(self, self.TextState) },

	}
end

function StoreGoodsItemView:OnDestroy()

end

function StoreGoodsItemView:OnShow()
end

function StoreGoodsItemView:OnHide()

end

function StoreGoodsItemView:OnRegisterUIEvent()

end

function StoreGoodsItemView:OnRegisterGameEvent()

end

function StoreGoodsItemView:OnSelectChanged(NewValue)
	UIUtil.SetIsVisible(self.ImgSelect, false)
end

function StoreGoodsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreGoodsItemView