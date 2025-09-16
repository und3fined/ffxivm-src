---
--- Author: Administrator
--- DateTime: 2024-06-25 15:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local MarketMainVM = require("Game/Market/VM/MarketMainVM")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class MarketGoodsListItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCollect UFButton
---@field BtnGoods UFButton
---@field FHorizontalQuota UFHorizontalBox
---@field IconCollectFocus UFImage
---@field IconCollectNormal UFImage
---@field ImgBar UFImage
---@field ImgColor UFImage
---@field ImgFlame UFImage
---@field ImgGoods1 UFImage
---@field ImgHQ UFImage
---@field ImgInlet UFImage
---@field ImgX UFImage
---@field Money1 UFCanvasPanel
---@field PanelArrow UFCanvasPanel
---@field PanelCollect UFCanvasPanel
---@field PanelHQ UFCanvasPanel
---@field TextLowest UFTextBlock
---@field TextMoney1 UFTextBlock
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field TextQuota UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimJumpShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketGoodsListItemNewView = LuaClass(UIView, true)

function MarketGoodsListItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCollect = nil
	--self.BtnGoods = nil
	--self.FHorizontalQuota = nil
	--self.IconCollectFocus = nil
	--self.IconCollectNormal = nil
	--self.ImgBar = nil
	--self.ImgColor = nil
	--self.ImgFlame = nil
	--self.ImgGoods1 = nil
	--self.ImgHQ = nil
	--self.ImgInlet = nil
	--self.ImgX = nil
	--self.Money1 = nil
	--self.PanelArrow = nil
	--self.PanelCollect = nil
	--self.PanelHQ = nil
	--self.TextLowest = nil
	--self.TextMoney1 = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.TextQuota = nil
	--self.AnimIn = nil
	--self.AnimJumpShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketGoodsListItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketGoodsListItemNewView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Icon", UIBinderSetBrushFromIconID.New(self, self.ImgInlet) },
		{ "QuotaVisible", UIBinderSetIsVisible.New(self, self.FHorizontalQuota) },
		
		{ "HQColor", UIBinderSetBrushFromAssetPath.New(self, self.ImgHQ) },
		{ "HQVisible", UIBinderSetIsVisible.New(self, self.PanelHQ) },
		{ "QuotaTtitle", UIBinderSetText.New(self, self.TextQuota) },
		{ "QuotaNum", UIBinderSetText.New(self, self.TextNum) },
		
		{ "HQImage", UIBinderSetBrushFromAssetPath.New(self, self.ImgColor) },
		{ "CollectSelectVisible", UIBinderSetIsVisible.New(self, self.IconCollectFocus) },
		
		
		{ "MoneyVisible", UIBinderSetIsVisible.New(self, self.Money1) },
		{ "MoneyNum1", UIBinderSetText.New(self, self.TextMoney1) },
		{ "PriceInfoText", UIBinderSetText.New(self, self.TextLowest) },

		{ "UpArrowVisible", UIBinderSetIsVisible.New(self, self.PanelArrow) },
		{ "ImgXVisible", UIBinderSetIsVisible.New(self, self.ImgX) },
		{ "ProfRestrictionsImgColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgX) },

	}
end

function MarketGoodsListItemNewView:OnDestroy()

end

function MarketGoodsListItemNewView:OnShow()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	if nil == ViewModel.CommodityItem then return end

	if MarketMainVM.JumpToBuyItemID == ViewModel.CommodityItem.ResID and self.AnimJumpShow then
		self:PlayAnimation(self.AnimJumpShow)
		MarketMainVM.JumpToBuyItemID = nil
	end

end

function MarketGoodsListItemNewView:OnHide()

end

function MarketGoodsListItemNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCollect, self.OnClickedCollect)
end

function MarketGoodsListItemNewView:OnRegisterGameEvent()

end

function MarketGoodsListItemNewView:OnRegisterBinder()

	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	if nil == self.Binders then return end
	
	self:RegisterBinders(ViewModel, self.Binders)

end

function MarketGoodsListItemNewView:OnClickedCollect()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:OnClickedCollect()
end

function MarketGoodsListItemNewView:PlayJumpShowAni(ItemID)
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	if nil == ViewModel.CommodityItem then return end

	if ItemID == ViewModel.CommodityItem.ResID and self.AnimJumpShow then
		self:PlayAnimation(self.AnimJumpShow)
	end
    
end

return MarketGoodsListItemNewView