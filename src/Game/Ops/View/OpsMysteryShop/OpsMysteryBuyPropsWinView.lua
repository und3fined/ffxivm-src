---
--- Author: yutingzhan
--- DateTime: 2025-06-24 16:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MysteryShopGoodsListItemVM = require("Game/Ops/VM/OpsMysteryShop/MysteryShopGoodsListItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
---@class OpsMysteryBuyPropsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BG Comm2FrameMView
---@field BtnBuyConfirm CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnGift2 UFButton
---@field BtnGoods UFButton
---@field BtnMoney1 UFButton
---@field BtnMoney2 UFButton
---@field BtnMoney3 UFButton
---@field BtnNumber1 UFButton
---@field BtnNumber2 UFButton
---@field BtnPreview UFButton
---@field BtnTips1 UFButton
---@field BtnTips1_1 UFButton
---@field BtnTips2 UFButton
---@field BtnTips2_1 UFButton
---@field CommMoney CommMoneyBarView
---@field FHorizontalSurplus UFHorizontalBox
---@field HorizontalCurrent1 UFHorizontalBox
---@field HorizontalCurrent2 UFHorizontalBox
---@field HorizontalCurrent3 UFHorizontalBox
---@field HorizontalPrice UFHorizontalBox
---@field ImgMoney1 UFImage
---@field ImgMoney2 UFImage
---@field ImgMoney3 UFImage
---@field ImgPreview UFImage
---@field NumberPanel1 UFCanvasPanel
---@field NumberPanel2 UFCanvasPanel
---@field PanelBuySetting UFCanvasPanel
---@field PanelItem UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field ShopGoods ShopGoodsListItemView
---@field TextAmount UFTextBlock
---@field TextCurrentPrice1 UFTextBlock
---@field TextCurrentPrice2 UFTextBlock
---@field TextCurrentPrice3 UFTextBlock
---@field TextItemDescription URichTextBox
---@field TextItemName UFTextBlock
---@field TextItemType URichTextBox
---@field TextNumWin UFTextBlock
---@field TextNumber1 UFTextBlock
---@field TextNumber2 UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextSoldout UFTextBlock
---@field TextSurplus URichTextBox
---@field TextSurplus_2 UFTextBlock
---@field TextWear UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMysteryBuyPropsWinView = LuaClass(UIView, true)

function OpsMysteryBuyPropsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BG = nil
	--self.BtnBuyConfirm = nil
	--self.BtnCancel = nil
	--self.BtnGift2 = nil
	--self.BtnGoods = nil
	--self.BtnMoney1 = nil
	--self.BtnMoney2 = nil
	--self.BtnMoney3 = nil
	--self.BtnNumber1 = nil
	--self.BtnNumber2 = nil
	--self.BtnPreview = nil
	--self.BtnTips1 = nil
	--self.BtnTips1_1 = nil
	--self.BtnTips2 = nil
	--self.BtnTips2_1 = nil
	--self.CommMoney = nil
	--self.FHorizontalSurplus = nil
	--self.HorizontalCurrent1 = nil
	--self.HorizontalCurrent2 = nil
	--self.HorizontalCurrent3 = nil
	--self.HorizontalPrice = nil
	--self.ImgMoney1 = nil
	--self.ImgMoney2 = nil
	--self.ImgMoney3 = nil
	--self.ImgPreview = nil
	--self.NumberPanel1 = nil
	--self.NumberPanel2 = nil
	--self.PanelBuySetting = nil
	--self.PanelItem = nil
	--self.PanelOriginal = nil
	--self.ShopGoods = nil
	--self.TextAmount = nil
	--self.TextCurrentPrice1 = nil
	--self.TextCurrentPrice2 = nil
	--self.TextCurrentPrice3 = nil
	--self.TextItemDescription = nil
	--self.TextItemName = nil
	--self.TextItemType = nil
	--self.TextNumWin = nil
	--self.TextNumber1 = nil
	--self.TextNumber2 = nil
	--self.TextOriginalPrice = nil
	--self.TextSoldout = nil
	--self.TextSurplus = nil
	--self.TextSurplus_2 = nil
	--self.TextWear = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMysteryBuyPropsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.CommMoney)
	self:AddSubView(self.ShopGoods)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMysteryBuyPropsWinView:OnInit()
	UIUtil.SetIsVisible(self.CommMoney.Money1, true)
	UIUtil.SetIsVisible(self.CommMoney.Money2,  false )
	UIUtil.SetIsVisible(self.CommMoney.Money3,  false)
	UIUtil.SetIsVisible(self.CommMoney.Money4, false)
	self.ViewModel = MysteryShopGoodsListItemVM.New()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextItemName) },
		{ "ItemType", UIBinderSetText.New(self, self.TextItemType) },
		{ "ItemDescription", UIBinderSetText.New(self, self.TextItemDescription) },

		{ "BuyPropsItemQuality", UIBinderSetBrushFromAssetPath.New(self, self.ShopGoods.ImgColor) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ShopGoods.ImgInlet) },
		{ "TagVisible", UIBinderSetIsVisible.New(self, self.ShopGoods.TagPanel) },
		{ "DiscountText", UIBinderSetText.New(self, self.ShopGoods.TextDiscount) },
		{ "TimeVisible", UIBinderSetIsVisible.New(self, self.ShopGoods.TimePanel) },
		{ "TimeText", UIBinderSetText.New(self, self.ShopGoods.TextTime) },
		{ "IsCanPreView", 		UIBinderSetIsVisible.New(self, self.BtnPreview) },
		{ "MoneyImg", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgMoney1) },
		{ "IsGenderCan", 		UIBinderSetIsVisible.New(self, self.TextWear, true) },
		{ "FormatCostPrice1", UIBinderSetText.New(self, self.TextCurrentPrice1) },
		{ "FormatCostPrice2", UIBinderSetText.New(self, self.TextOriginalPrice) },
		{ "CostPrice2Visiable", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
	}
end

function OpsMysteryBuyPropsWinView:OnDestroy()

end

function OpsMysteryBuyPropsWinView:OnShow()
	if self.Params == nil then
		return
	end
	self.ViewModel = self.Params
	self:RegisterBinders(self.Params, self.Binders)
	self:SetWinState()

	self.BG.FText_Title:SetText(LSTR(950047))
	self.BtnCancel:SetText(LSTR(10003))
	self.BtnBuyConfirm:SetText(LSTR(1200071))
	self.TextWear:SetText(LSTR(100134))
	self.AmountSlider:SetSliderValueMaxTips(LSTR(1200033))
	self.AmountSlider:SetSliderValueMinTips(LSTR(1200034))
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedAmountCountSlider(v)
	end)
	self.AmountSlider:SetSliderValueMaxMin(self.ViewModel.OnceLimitation,1)
	if self.ViewModel.OnceLimitation == 1 then
		self.TextAmount:SetText(1)
		self.AmountSlider:SetBtnIsShow(false)
		self:OnValueChangedAmountCountSlider(1)
	else
		self.AmountSlider:SetSliderValue(1)
		self.AmountSlider:SetBtnIsShow(true)
	end

	if self.ViewModel.IsCanBuy then
			UIUtil.SetIsVisible(self.PanelBuySetting, true)
			UIUtil.SetIsVisible(self.HorizontalPrice, true)
			UIUtil.SetIsVisible(self.TextSoldout, false)
			UIUtil.SetIsVisible(self.HorizontalCurrent1, true)
			UIUtil.SetIsVisible(self.HorizontalCurrent2, false)
			UIUtil.SetIsVisible(self.HorizontalCurrent3, false)

			self.BtnBuyConfirm:SetIsRecommendState(true)
	else
		UIUtil.SetIsVisible(self.PanelBuySetting, false)
		UIUtil.SetIsVisible(self.HorizontalPrice, false)
		UIUtil.SetIsVisible(self.TextSoldout, true)
		self.TextSoldout:SetText(_G.LSTR(950021))
		self.BtnBuyConfirm:SetIsDisabledState(true, true)
	end

	if self.ViewModel.PriceItemID == SCORE_TYPE.SCORE_TYPE_STAMPS then
		self.CommMoney.Money1:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, _G.UIViewID.RechargingMainPanel, true)
	else
		self.CommMoney.Money1:UpdateView(self.ViewModel.PriceItemID, false, nil, true)
	end

	if self.ViewModel.IsCanPreView then
		UIUtil.SetIsVisible(self.BtnPreview, true, true)
	end

	_G.EventMgr:SendEvent(EventID.UpdateMysteryShopCommMoney, {CommMoneyVisible = false})
end

function OpsMysteryBuyPropsWinView:OnHide()
	_G.EventMgr:SendEvent(EventID.UpdateMysteryShopCommMoney, {CommMoneyVisible = true})
end

function OpsMysteryBuyPropsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoods, self.OnClickedBtnSlot)
	UIUtil.AddOnClickedEvent(self, self.BtnPreview, self.OnClickedBtnPreview)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm, self.OnClickedConfirmBtn)
end

function OpsMysteryBuyPropsWinView:OnRegisterGameEvent()

end

function OpsMysteryBuyPropsWinView:OnRegisterBinder()
	
end

function OpsMysteryBuyPropsWinView:OnClickedBtnSlot()
	ItemTipsUtil.ShowTipsByResID(self.Params.ItemID, self.PanelItem)
end

function OpsMysteryBuyPropsWinView:OnClickedBtnPreview()
	if self.ViewModel.IsSuit then
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.SuitID)
	else
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.ItemID)
	end
end

function OpsMysteryBuyPropsWinView:OnClickedBtnCancel()
	self:Hide()
end

function OpsMysteryBuyPropsWinView:OnClickedConfirmBtn()
	if self.ViewModel.IsCanBuy then
		if self.IsMoneyEnough then
			_G.ShopMgr:SendMsgMallInfoBuy(self.ViewModel.GoodsID, 1)
		else
			if self.ViewModel.PriceItemID == ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS then
				MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(100030), _G.LSTR(100031), function ()
					_G.RechargingMgr:ShowMainPanel()
				end)
			else
				MsgTipsUtil.ShowTips(_G.LSTR(100135))
			end
		end
	else
		MsgTipsUtil.ShowTips(_G.LSTR(1200025)) -- 已售罄
	end
end

function OpsMysteryBuyPropsWinView:OnValueChangedAmountCountSlider(Value)
	self.TextAmount:SetText(Value)
	local SinglePrice = self.ViewModel.CostPrice1
	local ScoreValue = _G.ScoreMgr:GetScoreValueByID(self.ViewModel.PriceItemID)
    local Price = Value * SinglePrice
	self.TextCurrentPrice1:SetText(_G.ScoreMgr.FormatScore(Price))
    if ScoreValue < Price then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextCurrentPrice1, "dc5868")
        self.IsMoneyEnough = false
    else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextCurrentPrice1, "d1ba8e")
        self.IsMoneyEnough = true
    end
end

function OpsMysteryBuyPropsWinView:SetWinState()
	UIUtil.SetIsVisible(self.ShopGoods.GoodsMoney, false)
	UIUtil.SetIsVisible(self.ShopGoods.MaskPanel, false)
	UIUtil.SetIsVisible(self.ShopGoods.TextName, false)
	UIUtil.SetIsVisible(self.ShopGoods.PanelArrow, false)
	UIUtil.SetIsVisible(self.ShopGoods.PanelTask, false)
	UIUtil.SetIsVisible(self.ShopGoods.CommonRedDot2, false)
	UIUtil.SetIsVisible(self.ShopGoods.CommonRedDot2, false)
	UIUtil.SetIsVisible(self.ShopGoods.ImgX, false)
	UIUtil.SetIsVisible(self.ShopGoods.IconTask, false)
	UIUtil.SetIsVisible(self.TextSurplus, false)
	UIUtil.SetIsVisible(self.BtnNumber1, false)
	UIUtil.SetIsVisible(self.BtnNumber2, false)
	UIUtil.SetIsVisible(self.AmountSlider.TextQuantity, false)
	UIUtil.SetIsVisible(self.TextNumber1, false)
	UIUtil.SetIsVisible(self.TextNumber2, false)
	UIUtil.SetIsVisible(self.ShopGoods.ImgBar, false)
	UIUtil.SetIsVisible(self.TextNumWin, false)
	UIUtil.SetIsVisible(self.ShopGoods.CommonRedDot2, false)
	UIUtil.SetIsVisible(self.ShopGoods.TextNum, false)
	UIUtil.SetIsVisible(self.ShopGoods.Textcondition, false)
end

return OpsMysteryBuyPropsWinView