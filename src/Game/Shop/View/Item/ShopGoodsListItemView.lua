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
local ShopGoodsListItemVM = require("Game/Shop/ItemVM/ShopGoodsListItemVM")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")


---@class ShopGoodsListItemView : UIView
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
---@field PanelTask UFCanvasPanel
---@field TagPanel UFCanvasPanel
---@field TextDiscount UFTextBlock
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field Textcondition UFTextBlock
---@field TimePanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopGoodsListItemView = LuaClass(UIView, true)

function ShopGoodsListItemView:Ctor()
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
	--self.PanelTask = nil
	--self.TagPanel = nil
	--self.TextDiscount = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.Textcondition = nil
	--self.TimePanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopGoodsListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	self:AddSubView(self.GoodsMoney)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopGoodsListItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ItemQuality", UIBinderSetBrushFromAssetPath.New(self, self.ImgColor) },
		{ "Icon", UIBinderSetBrushFromIconID.New(self, self.ImgInlet) },
		{ "QuotaVisible", UIBinderSetIsVisible.New(self, self.FHorizontalQuota) },
		--{ "FVerticalBoxVisible", UIBinderSetIsVisible.New(self, self.FVerticalBox) },
		{ "HQVisible", UIBinderSetIsVisible.New(self, self.PanelHQ) },
		{ "SpeciaIcon", UIBinderSetIsVisible.New(self, self.ImgFlame) },
		{ "QuotaNum", UIBinderSetText.New(self, self.TextNum) },
		{ "QuotaVisible", UIBinderSetIsVisible.New(self, self.TextNum, nil, true) },
		{ "TagVisible", UIBinderSetIsVisible.New(self, self.TagPanel) },
		{ "TimeVisible", UIBinderSetIsVisible.New(self, self.TimePanel) },
		{ "DiscountText", UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },
		{ "MaskVisible", UIBinderSetIsVisible.New(self, self.MaskPanel) },
		{ "TipsText", UIBinderSetText.New(self, self.TextTips) },
		{ "HQImage", UIBinderSetBrushFromAssetPath.New(self, self.ImgColor) },
		{ "HQColor", UIBinderSetBrushFromAssetPath.New(self, self.ImgHQ) },
		--{ "TaskVisible", UIBinderSetIsVisible.New(self, self.IconTask) },
		{ "ArrowIconVisible", UIBinderSetIsVisible.New(self, self.PanelArrow) },
		{ "TextconditionText", UIBinderSetText.New(self, self.Textcondition) },
		{ "PanelTaskVisible", UIBinderSetIsVisible.New(self, self.PanelTask) },
		{ "ImgXVisible", 		UIBinderSetIsVisible.New(self, self.ImgX) },
		{ "ImgXColor", 			UIBinderSetColorAndOpacityHex.New(self, self.ImgX) },

		-- { "GoodsMoneyVisible", UIBinderSetIsVisible.New(self, self.GoodsMoney) },
		-- { "GoodsMoneyVisible", UIBinderSetIsVisible.New(self, self.SizeBoxName) },
	
	}
end

function ShopGoodsListItemView:OnDestroy()

end

function ShopGoodsListItemView:OnShow()
	UIUtil.SetIsVisible(self.BtnGoods, true, false)
	self.GoodsID = self.ViewModel.GoodsId
	self.RedDotName = _G.ShopMgr.RedDotName .. "/".. self.GoodsID
	if self.ViewModel.IsCanBuy then
		self.CommonRedDot2:SetRedDotNameByString(self.RedDotName)
		_G.ShopMgr:SetCurFistTypeRedDot(self.ViewModel.FirstType, self.GoodsID)
	else
		self.CommonRedDot2:SetRedDotNameByString("")
		_G.ShopMgr:RemoveRecordRedDot(self.GoodsID, self.ViewModel.FirstType)
	end
end
	
function ShopGoodsListItemView:OnHide()

end

function ShopGoodsListItemView:OnRegisterUIEvent()

end

function ShopGoodsListItemView:OnRegisterGameEvent()

end

function ShopGoodsListItemView:OnRegisterBinder()
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

function ShopGoodsListItemView:UpdateMoneyInfo(List)
	self.GoodsMoney:UpdateMoneyInfo(List)
end

function ShopGoodsListItemView:SetGoodsState(List)
	local ViewModel = ShopGoodsListItemVM.New()
	ViewModel:UpdateGoodsState(List, true)
end

function ShopGoodsListItemView:SetBuyViewItemState(Value)
	UIUtil.SetIsVisible(self.GoodsMoney, Value)
	--UIUtil.SetIsVisible(self.TextNum, Value)
	if self.ViewModel ~= nil then
		self.ViewModel.ImgXVisible = Value
		self.ViewModel.ArrowIconVisible = Value
	end
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

-- 限购信息显隐
function ShopGoodsListItemView:SetBuyViewItemStateEx(Value)
	UIUtil.SetIsVisible(self.TextNum, Value)
	self:SetBuyViewItemState(Value)
end

return ShopGoodsListItemView