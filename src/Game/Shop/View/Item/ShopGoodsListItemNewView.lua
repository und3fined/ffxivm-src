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

---@class ShopGoodsListItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoods UFButton
---@field CommonRedDot2 CommonRedDot2View
---@field FHorizontalQuota UFHorizontalBox
---@field FVerticalBox UFVerticalBox
---@field GoodsMoney ShopGoodsMoneyItemNewView
---@field IconTask UFImage
---@field ImgBar UFImage
---@field ImgColor UFImage
---@field ImgInlet UFImage
---@field ImgTime UFImage
---@field MaskPanel UFCanvasPanel
---@field PanelHQ UFCanvasPanel
---@field PanelTask UFCanvasPanel
---@field SizeBoxName USizeBox
---@field TagPanel UFCanvasPanel
---@field TextDiscount UFTextBlock
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field TextQuota UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field TimePanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopGoodsListItemNewView = LuaClass(UIView, true)

function ShopGoodsListItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoods = nil
	--self.CommonRedDot2 = nil
	--self.FHorizontalQuota = nil
	--self.FVerticalBox = nil
	--self.GoodsMoney = nil
	--self.IconTask = nil
	--self.ImgBar = nil
	--self.ImgColor = nil
	--self.ImgInlet = nil
	--self.ImgTime = nil
	--self.MaskPanel = nil
	--self.PanelHQ = nil
	--self.PanelTask = nil
	--self.SizeBoxName = nil
	--self.TagPanel = nil
	--self.TextDiscount = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.TextQuota = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TimePanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopGoodsListItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	self:AddSubView(self.GoodsMoney)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopGoodsListItemNewView:OnInit()
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
		
	}
end

function ShopGoodsListItemNewView:OnDestroy()

end

function ShopGoodsListItemNewView:OnShow()
	
end
	
function ShopGoodsListItemNewView:OnHide()

end

function ShopGoodsListItemNewView:OnRegisterUIEvent()
end

function ShopGoodsListItemNewView:OnRegisterGameEvent()

end

function ShopGoodsListItemNewView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
	self.GoodsMoney:SetParams({Data = ViewModel.ShopGoodsMoneyItemNewVM})
end

function ShopGoodsListItemNewView:UpdateMoneyInfo(List)
	self.GoodsMoney:UpdateMoneyInfo(List)
end


return ShopGoodsListItemNewView