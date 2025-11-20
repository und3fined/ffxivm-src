---
--- Author: yutingzhan
--- DateTime: 2025-06-20 15:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MsgTipsUtil = require("Utils/MsgTipsUtil")


---@class MysteryShopGoodsListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnGoods UFButton
---@field FVerticalBox UFVerticalBox
---@field GoodsMoney ShopGoodsMoneyItemNewView
---@field ImgColor UFImage
---@field ImgInlet UFImage
---@field ImgShopMask UFImage
---@field ImgTag UFImage
---@field ImgTime UFImage
---@field ImgTipsBg UFImage
---@field ImgX UFImage
---@field MaskPanel UFCanvasPanel
---@field PanelArrow UFCanvasPanel
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
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysteryShopGoodsListItemView = LuaClass(UIView, true)

function MysteryShopGoodsListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnGoods = nil
	--self.FVerticalBox = nil
	--self.GoodsMoney = nil
	--self.ImgColor = nil
	--self.ImgInlet = nil
	--self.ImgShopMask = nil
	--self.ImgTag = nil
	--self.ImgTime = nil
	--self.ImgTipsBg = nil
	--self.ImgX = nil
	--self.MaskPanel = nil
	--self.PanelArrow = nil
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
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysteryShopGoodsListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GoodsMoney)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysteryShopGoodsListItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ItemQuality", UIBinderSetBrushFromAssetPath.New(self, self.ImgColor) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgInlet) },
		{ "TagVisible", UIBinderSetIsVisible.New(self, self.TagPanel) },
		{ "DiscountText", UIBinderSetText.New(self, self.TextDiscount) },
		{ "TimeVisible", UIBinderSetIsVisible.New(self, self.TimePanel) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },
		{ "MaskVisible", UIBinderSetIsVisible.New(self, self.MaskPanel) },
		{ "ImgXVisible", 		UIBinderSetIsVisible.New(self, self.ImgX) },
		{ "IsCanPreView", 		UIBinderSetIsVisible.New(self, self.BtnCheck) },
		{ "MoneyImg", 		UIBinderSetBrushFromAssetPath.New(self, self.GoodsMoney.ImgGoods1) },
		{ "FormatCostPrice1", UIBinderSetText.New(self, self.GoodsMoney.TextMoney1) },
		{ "FormatCostPrice2", UIBinderSetText.New(self, self.GoodsMoney.TextCostPrice) },
		{ "CostPrice2Visiable", UIBinderSetIsVisible.New(self, self.GoodsMoney.TextCostPrice) },
		{ "ImgTagVisiable", UIBinderSetIsVisible.New(self, self.ImgTag) },
		{ "ImgTag", UIBinderSetBrushFromAssetPath.New(self, self.ImgTag) },
	}
end

function MysteryShopGoodsListItemView:OnDestroy()

end

function MysteryShopGoodsListItemView:OnShow()
	UIUtil.SetIsVisible(self.PanelTask, false)
	UIUtil.SetIsVisible(self.TextNum, false)
	UIUtil.SetIsVisible(self.PanelArrow, false)
	UIUtil.SetIsVisible(self.Textcondition, false)
	UIUtil.SetColorAndOpacityHex(self.ImgX, "dc5868")
	UIUtil.SetIsVisible(self.GoodsMoney.Money2, false)
	UIUtil.SetIsVisible(self.GoodsMoney.Money3, false)
	UIUtil.SetColorAndOpacityHex(self.GoodsMoney.TextMoney1, "313131")
	self.TextTips:SetText(_G.LSTR(950021))
	if self.ViewModel.IsCanPreView then
		UIUtil.SetIsVisible(self.BtnCheck, true, true)
	end
end
	
function MysteryShopGoodsListItemView:OnHide()

end

function MysteryShopGoodsListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnBtnCheckClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnGoods, self.OnBtnGoodsClick)
end

function MysteryShopGoodsListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PlayRefreshAnim, self.PlayRefreshAnim)
end

function MysteryShopGoodsListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	if ViewModel then
		self.ViewModel = ViewModel
		self:RegisterBinders(ViewModel, self.Binders)
	end
end

function MysteryShopGoodsListItemView:OnBtnCheckClick()
	if self.ViewModel.IsSuit then
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.SuitID)
	else
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.ItemID)
	end
end

function MysteryShopGoodsListItemView:OnBtnGoodsClick()
	local ItemData = self.ViewModel
	if ItemData.IsSuit then
		if ItemData.IsCanBuy then
			_G.UIViewMgr:ShowView(_G.UIViewID.OpsMysteryBuySuitWinView, ItemData)
		else
			MsgTipsUtil.ShowTips(_G.LSTR(1200025)) -- 已售罄
		end
	else
		ItemData.IsOpsMysteryShop = true
		_G.UIViewMgr:ShowView(_G.UIViewID.OpsMysteryBuyPropsWinView, ItemData)
	end
end

function MysteryShopGoodsListItemView:PlayRefreshAnim()
	self:PlayAnimation(self.AnimRefresh)
end

return MysteryShopGoodsListItemView