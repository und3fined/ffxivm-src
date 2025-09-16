---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ProtoRes = require("Protocol/ProtoRes")

---@class StoreNewCommodityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconTime UFImage
---@field ImgItem UFImage
---@field ImgLine1 UFImage
---@field ImgMask1 UFImage
---@field ImgMask2 UFImage
---@field ImgPoster UFImage
---@field ImgSelect UFImage
---@field PanelDiscountTag UFCanvasPanel
---@field PanelHotSale UFCanvasPanel
---@field PanelMoney UFHorizontalBox
---@field PanelOriginalPrice UFCanvasPanel
---@field PanelTime UFHorizontalBox
---@field TextAlreadyOwned UFTextBlock
---@field TextDiscount UFTextBlock
---@field TextHotSale UFTextBlock
---@field TextName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextPrice UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewCommodityItemView = LuaClass(UIView, true)

function StoreNewCommodityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconTime = nil
	--self.ImgItem = nil
	--self.ImgLine1 = nil
	--self.ImgMask1 = nil
	--self.ImgMask2 = nil
	--self.ImgPoster = nil
	--self.ImgSelect = nil
	--self.PanelDiscountTag = nil
	--self.PanelHotSale = nil
	--self.PanelMoney = nil
	--self.PanelOriginalPrice = nil
	--self.PanelTime = nil
	--self.TextAlreadyOwned = nil
	--self.TextDiscount = nil
	--self.TextHotSale = nil
	--self.TextName = nil
	--self.TextOriginalPrice = nil
	--self.TextPrice = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewCommodityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewCommodityItemView:OnInit()
	self.Binders = {
		{ "GoodIcon", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgPoster, true) },
		{ "GoodIcon", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgItem, true) },
		{ "ItemNameText", 			UIBinderSetText.New(self, self.TextName) },
		{ "SaleRuleText", 			UIBinderSetText.New(self, self.TextHotSale) },
		{ "OriginalPriceText", 		UIBinderSetText.New(self, self.TextOriginalPrice) },
		{ "GoodStateText", 			UIBinderSetText.New(self, self.TextAlreadyOwned) },
		{ "CrystalText", 			UIBinderSetText.New(self, self.TextPrice) },
		{ "DiscountText", 			UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeSaleText", 			UIBinderSetText.New(self, self.TextTime) },
		{ "StateTextVisible", 		UIBinderSetIsVisible.New(self, self.PanelMoney, true) },
		{ "StateTextVisible", 		UIBinderSetIsVisible.New(self, self.TextAlreadyOwned) },
		{ "OriginalPriceVisible", 	UIBinderSetIsVisible.New(self, self.TextOriginalPrice) },
		{ "HotSaleVisible", 		UIBinderSetIsVisible.New(self, self.PanelHotSale) },
		{ "OriginalPanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelOriginalPrice) },
		{ "DiscountPanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelDiscountTag) },
		{ "DeadlinePanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelTime) },
		{ "IsShowTimeSaleIcon", 	UIBinderSetIsVisible.New(self, self.IconTime) },
		{ "bGoodIconVisible", 		UIBinderSetIsVisible.New(self, self.ImgItem) },
		{ "bGoodIconVisible", 		UIBinderSetIsVisible.New(self, self.ImgPoster, true) },
		{ "bSelected", 				UIBinderSetIsVisible.New(self, self.ImgSelect) },
		
		-- { "PanelDiscountVisible", UIBinderSetIsVisible.New(self, self.VerticalBoxInfo) },
		-- { "LimitationVisible", 		UIBinderSetIsVisible.New(self, self.HorizontalLimitation) },
		-- { "IsShowTimeSaleIcon", 	UIBinderSetIsVisible.New(self, self.ImgDeadline) },
		-- { "LimitationText", 		UIBinderSetText.New(self, self.TextLimitation) },
		-- { "AmountText", 			UIBinderSetText.New(self, self.TextAmount) },
		-- { "SoldOutStateColor", 		UIBinderSetColorAndOpacityHex.New(self, self.TextState) },

	}
end

function StoreNewCommodityItemView:OnDestroy()

end

function StoreNewCommodityItemView:OnShow()
	-- UIUtil.SetIsVisible(self.ImgItem, self.ViewModel.bGoodIconVisible)
	-- UIUtil.SetIsVisible(self.ImgPoster, not self.ViewModel.bGoodIconVisible)

	if _G.StoreMainVM.CurrentSelectedTabType == ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX then
		self.TextName:SetText("")
		UIUtil.SetIsVisible(self.ImgLine1, false)
		UIUtil.SetIsVisible(self.ImgMask1, false)
		UIUtil.SetIsVisible(self.ImgMask2, false)
		UIUtil.SetIsVisible(self.PanelMoney, false)
	end

	if nil ~= self.Params and self.Params.bBottomInfoInvisible then
		UIUtil.SetIsVisible(self.TextName, false)
		UIUtil.SetIsVisible(self.ImgLine1, false)
		UIUtil.SetIsVisible(self.ImgMask1, false)
		UIUtil.SetIsVisible(self.ImgMask2, false)
		UIUtil.SetIsVisible(self.PanelMoney, false)
	end
end

function StoreNewCommodityItemView:OnHide()

end

function StoreNewCommodityItemView:OnSelectChanged(NewValue)
	UIUtil.SetIsVisible(self.ImgSelect, NewValue)
end

function StoreNewCommodityItemView:OnRegisterUIEvent()

end

function StoreNewCommodityItemView:OnRegisterGameEvent()

end

function StoreNewCommodityItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreNewCommodityItemView