---
--- Author: Administrator
--- DateTime: 2023-10-27 15:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ShopGoodsMoneyItemNewVM = require("Game/Shop/ItemVM/ShopGoodsMoneyItemNewVM")
local ShopMgr = require("Game/Shop/ShopMgr")
local GoodsCfg = require("TableCfg/GoodsCfg")
local MallCfg = require("TableCfg/MallCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")
local EventID = require("Define/EventID")
local UIBinderSetIconItemAndScore = require("Binder/UIBinderSetIconItemAndScore")

---@class ShopGoodsMoneyItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CostPricePanel UFCanvasPanel
---@field ImgGoods1 UFImage
---@field ImgGoods2 UFImage
---@field ImgGoods3 UFImage
---@field ImgLine UFImage
---@field Money1 UFCanvasPanel
---@field Money2 UFCanvasPanel
---@field Money3 UFCanvasPanel
---@field TextCostPrice UFTextBlock
---@field TextMoney1 UFTextBlock
---@field TextMoney2 UFTextBlock
---@field TextMoney3 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopGoodsMoneyItemNewView = LuaClass(UIView, true)

function ShopGoodsMoneyItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CostPricePanel = nil
	--self.ImgGoods1 = nil
	--self.ImgGoods2 = nil
	--self.ImgGoods3 = nil
	--self.ImgLine = nil
	--self.Money1 = nil
	--self.Money2 = nil
	--self.Money3 = nil
	--self.TextCostPrice = nil
	--self.TextMoney1 = nil
	--self.TextMoney2 = nil
	--self.TextMoney3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopGoodsMoneyItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopGoodsMoneyItemNewView:OnInit()
	self.ViewModel = ShopGoodsMoneyItemNewVM.New()
	self.Binders = {
		{ "Img1", UIBinderSetIconItemAndScore.New(self, self.ImgGoods1) },
		{ "Img2", UIBinderSetIconItemAndScore.New(self, self.ImgGoods2) },
		{ "Img3", UIBinderSetIconItemAndScore.New(self, self.ImgGoods3) },
		{ "MoneyVisible1", UIBinderSetIsVisible.New(self, self.Money1) },
		{ "MoneyVisible2", UIBinderSetIsVisible.New(self, self.Money2) },
		{ "MoneyVisible3", UIBinderSetIsVisible.New(self, self.Money3) },
		{ "MoneyNum1", UIBinderSetText.New(self, self.TextMoney1) },
		{ "MoneyNum2", UIBinderSetText.New(self, self.TextMoney2) },
		{ "MoneyNum3", UIBinderSetText.New(self, self.TextMoney3) },
		{ "CostPricePanelVisible", UIBinderSetIsVisible.New(self, self.CostPricePanel) },
		{ "CostPriceNum", UIBinderSetText.New(self, self.TextCostPrice) },

	}
end

function ShopGoodsMoneyItemNewView:OnDestroy()

end

function ShopGoodsMoneyItemNewView:OnShow()

end

function ShopGoodsMoneyItemNewView:OnHide()

end

function ShopGoodsMoneyItemNewView:OnRegisterUIEvent()

end

function ShopGoodsMoneyItemNewView:OnRegisterGameEvent()
	
end

function ShopGoodsMoneyItemNewView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	
	self:RegisterBinders(ViewModel, self.Binders)
end

return ShopGoodsMoneyItemNewView