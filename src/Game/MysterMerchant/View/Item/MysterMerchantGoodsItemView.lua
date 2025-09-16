---
--- Author: Administrator
--- DateTime: 2023-10-19 14:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")

---@class MysterMerchantGoodsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoods UFButton
---@field CommonRedDot2 CommonRedDot2View
---@field FVerticalBox UFVerticalBox
---@field GoodsMoney ShopGoodsMoneyItemNewView
---@field IconTask UFImage
---@field ImgBar UFImage
---@field ImgColor UFImage
---@field ImgFlame UFImage
---@field ImgHQ UFImage
---@field ImgInlet UFImage
---@field ImgShopMask UFImage
---@field ImgTime UFImage
---@field ImgTipsBg UFImage
---@field ImgX UFImage
---@field ListPanel UFCanvasPanel
---@field MaskPanel UFCanvasPanel
---@field PanelArrow UFCanvasPanel
---@field PanelHQ UFCanvasPanel
---@field PanelHotSale UFCanvasPanel
---@field PanelTask UFCanvasPanel
---@field TagPanel UFCanvasPanel
---@field TextDiscount UFTextBlock
---@field TextHotSale UFTextBlock
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field Textcondition UFTextBlock
---@field TimePanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysterMerchantGoodsItemView = LuaClass(UIView, true)

function MysterMerchantGoodsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoods = nil
	--self.CommonRedDot2 = nil
	--self.FVerticalBox = nil
	--self.GoodsMoney = nil
	--self.IconTask = nil
	--self.ImgBar = nil
	--self.ImgColor = nil
	--self.ImgFlame = nil
	--self.ImgHQ = nil
	--self.ImgInlet = nil
	--self.ImgShopMask = nil
	--self.ImgTime = nil
	--self.ImgTipsBg = nil
	--self.ImgX = nil
	--self.ListPanel = nil
	--self.MaskPanel = nil
	--self.PanelArrow = nil
	--self.PanelHQ = nil
	--self.PanelHotSale = nil
	--self.PanelTask = nil
	--self.TagPanel = nil
	--self.TextDiscount = nil
	--self.TextHotSale = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.Textcondition = nil
	--self.TimePanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysterMerchantGoodsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	self:AddSubView(self.GoodsMoney)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysterMerchantGoodsItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ItemQuality", UIBinderSetBrushFromAssetPath.New(self, self.ImgColor) },
		{ "Icon", UIBinderSetBrushFromIconID.New(self, self.ImgInlet) },
		{ "QuotaVisible", UIBinderSetIsVisible.New(self, self.FHorizontalQuota) },
		--{ "FVerticalBoxVisible", UIBinderSetIsVisible.New(self, self.FVerticalBox) },
		{ "HQVisible", UIBinderSetIsVisible.New(self, self.PanelHQ) },
		{ "QuotaTtitle", UIBinderSetText.New(self, self.TextQuota) },
		{ "QuotaNum", UIBinderSetText.New(self, self.TextNum) },
		{ "TagVisible", UIBinderSetIsVisible.New(self, self.TagPanel) },
		{ "TimeVisible", UIBinderSetIsVisible.New(self, self.TimePanel) },
		{ "DiscountText", UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },
		{ "MaskVisible", UIBinderSetIsVisible.New(self, self.MaskPanel) },
		{ "TipsText", UIBinderSetText.New(self, self.TextTips) },
		{ "HQImage", UIBinderSetBrushFromAssetPath.New(self, self.ImgColor) },
		{ "TaskVisible", UIBinderSetIsVisible.New(self, self.IconTask) },
		{ "GoldCoinPrice", UIBinderSetText.New(self, self.TextMoney1) },
		{ "CostPricePanelVisible", UIBinderSetIsVisible.New(self, self.GoodsMoney.CostPricePanel) },
		{ "CostPriceNum", UIBinderSetText.New(self, self.GoodsMoney.TextCostPrice) },


		{ "SpeciaIcon", UIBinderSetIsVisible.New(self, self.ImgFlame) },
		{ "HQColor", UIBinderSetBrushFromAssetPath.New(self, self.ImgHQ) },
		--{ "TaskVisible", UIBinderSetIsVisible.New(self, self.IconTask) },
		{ "ArrowIconVisible", UIBinderSetIsVisible.New(self, self.PanelArrow) },
		{ "TextconditionText", UIBinderSetText.New(self, self.Textcondition) },
		{ "PanelTaskVisible", UIBinderSetIsVisible.New(self, self.PanelTask) },
	}
end

function MysterMerchantGoodsItemView:OnDestroy()

end

function MysterMerchantGoodsItemView:OnShow()
	
end
	
function MysterMerchantGoodsItemView:OnHide()

end

function MysterMerchantGoodsItemView:OnRegisterUIEvent()
end

function MysterMerchantGoodsItemView:OnRegisterGameEvent()

end

function MysterMerchantGoodsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	if ViewModel then
		self.ViewModel = ViewModel
		self:RegisterBinders(ViewModel, self.Binders)
		self.GoodsMoney:SetParams({Data = ViewModel.ShopGoodsMoneyItemNewVM})
	end
end

-- function MysterMerchantGoodsItemView:UpdateMoneyInfo(List)
-- 	self.GoodsMoney:UpdateMoneyInfo(List)
-- end

-- function MysterMerchantGoodsItemView:SetGoodsState(List)
-- 	local ViewModel = ShopGoodsListItemVM.New()
-- 	ViewModel:UpdateGoodsState(List, true)
-- end

function MysterMerchantGoodsItemView:SetBuyViewItemState(Value)
	UIUtil.SetIsVisible(self.GoodsMoney, Value)
	--UIUtil.SetIsVisible(self.SizeBoxName, Value)
	UIUtil.SetIsVisible(self.ImgShopMask, Value)
	UIUtil.SetIsVisible(self.ImgTipsBg, Value)
	UIUtil.SetIsVisible(self.TextTips, Value)
	UIUtil.SetIsVisible(self.ImgBar, Value)
	--UIUtil.SetIsVisible(self.FHorizontalQuota, Value)
	UIUtil.SetIsVisible(self.TextName, Value)
	UIUtil.SetIsVisible(self.Textcondition, Value)
	UIUtil.CanvasSlotSetPosition(self.ImgInlet, _G.UE4.FVector2D(0, 0))
end


return MysterMerchantGoodsItemView