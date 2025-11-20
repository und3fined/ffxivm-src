
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreMgr = require("Game/Store/StoreMgr")
local StoreUtil = require("Game/Store/StoreUtil")
local StorePropsItemVM = require("Game/Store/VM/ItemVM/StorePropsItemVM")

---@class StoreBuyPropsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BG Comm2FrameMView
---@field BtnBuyConfirm CommBtnLView
---@field BtnGift UFButton
---@field CommWinSlotQuality CommWinSlotQualityView
---@field HorizontalPrice UFHorizontalBox
---@field ImgMoney UFImage
---@field PanelBuySetting UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field ShopGoods ShopGoodsListItemView
---@field TextCurrentPrice UFTextBlock
---@field TextItemDescription UFTextBlock
---@field TextItemName UFTextBlock
---@field TextItemType UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextSoldout UFTextBlock
---@field TextSurplus UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreBuyPropsWinView = LuaClass(UIView, true)

function StoreBuyPropsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BG = nil
	--self.BtnBuyConfirm = nil
	--self.BtnGift = nil
	--self.CommWinSlotQuality = nil
	--self.HorizontalPrice = nil
	--self.ImgMoney = nil
	--self.PanelBuySetting = nil
	--self.PanelOriginal = nil
	--self.ShopGoods = nil
	--self.TextCurrentPrice = nil
	--self.TextItemDescription = nil
	--self.TextItemName = nil
	--self.TextItemType = nil
	--self.TextOriginalPrice = nil
	--self.TextSoldout = nil
	--self.TextSurplus = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreBuyPropsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnBuyConfirm)
	self:AddSubView(self.CommWinSlotQuality)
	self:AddSubView(self.ShopGoods)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreBuyPropsWinView:OnInit()
	self.Binders = {
		{ "MultiBuyQualityBg", UIBinderSetBrushFromAssetPath.New(self, self.CommWinSlotQuality.ImgBg2) },
		{ "MultiBuyBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) }, --1
		{ "MultiBuyName", UIBinderSetText.New(self, self.TextItemName) },
		{ "MultiBuySubName", UIBinderSetText.New(self, self.TextItemType) },
		{ "MultiBuyPriceText", UIBinderSetText.New(self, self.TextCurrentPrice) },
		{ "MultiBuyPriceType", UIBinderSetBrushFromAssetPath.New(self, self.ImgMoney) },
		{ "MultiBuyQuantity", UIBinderSetText.New(self, self.TextSurplus) },
		{ "MultiBuyDesc", UIBinderSetText.New(self, self.TextItemDescription) },

		-- { "bMultiBuySliderEnabled", UIBinderSetIsEnabled.New(self, self.AmountSlider) },
		{ "bMultiBuySliderEnabled", UIBinderSetIsVisible.New(self, self.AmountSlider) },
		{ "bHorizontalPriceVisible", UIBinderSetIsVisible.New(self, self.HorizontalPrice) },
		
		{ "bMultiBuyPanelOriginalVisible", UIBinderSetIsVisible.New(self, self.PanelOriginal) },
		{ "bMultiBuyOriginalPriceText", UIBinderSetText.New(self, self.TextOriginalPrice) },

		{ "MultiBuyConfirmTextColor", UIBinderSetColorAndOpacityHex.New(self, self.BtnBuyConfirm.TextContent) },
		-- { "bMultiBuySliderEnabled", UIBinderSetIsEnabled.New(self, self.BtnBuyConfirm) },
		{ "MultiBuyLimitNum", UIBinderSetText.New(self, self.AmountSlider.TextMax) },
		{ "MultiBuyPurchaseNumber", UIBinderValueChangedCallback.New(self, nil, self.OnNumChanged) },
		
		-- { "MultiBuyConfirmBtnImgType", UIBinderCommBtnUpdateImage.New(self, self.BtnBuyConfirm) },
	}
	self.PriceBinders =
	{
		{ "BuyPriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCurrentPrice) },
	}

	self.PriceVM = StoreMgr:GetBuyPriceVM()
end

function StoreBuyPropsWinView:OnDestroy()
    
end

function StoreBuyPropsWinView:OnShow()
	--重置购买数据
	StoreMainVM:SetMultiQuantity(1)
	self.BG:SetTitleText(LSTR(StoreDefine.BuyTipTittleText))
	self.BtnBuyConfirm:SetBtnName(LSTR(950053))		--- 确认购买

	self.AmountSlider:SetSliderValueMaxTips(LSTR(950040))
	self.AmountSlider:SetSliderValueMinTips(LSTR(950040))
	self.BtnBuyConfirm:UpdateImage(StoreMainVM.MultiBuyConfirmBtnImgType)
	UIUtil.SetIsVisible(self.TextSurplus, StoreMainVM.bMultiBuySliderEnabled)
	local ItemData = _G.StoreMgr:GetProductDataByID(StoreMainVM.CurrentselectedID)
	if not ItemData then
		FLOG_ERROR("StoreBuyPropsWinView ItemData is Nil") 
		self:Hide()
		return
	end
	local VM = StorePropsItemVM.New()
	local Data = {PropsData = ItemData, ItemIndex = 1, BtnVisible = true}
	Data.ImgBarVisible = false
	VM:UpdateVM(Data)
	self.ShopGoods:SetParams({Data = VM})
	self.ShopGoods:SetBuyViewItemStateByMarket(false)

	if nil ~= ItemData then
		if not StoreMainVM.bMultiBuySliderEnabled then
			local IsCan, CanNotReason = _G.StoreMgr:IsCanBuy(ItemData.Cfg.ID)
			self.TextSoldout:SetText(CanNotReason)
			self.TextSoldout:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("#DC5868FF"))
			UIUtil.SetIsVisible(self.TextSoldout, not IsCan)
			StoreMainVM.bHorizontalPriceVisible = IsCan
		else
			UIUtil.SetIsVisible(self.TextSoldout, false)
			if ItemData.GoodsCounterFirst == 0 then
				StoreMainVM.bHorizontalPriceVisible = true
			else
				local RemainGoodsQuantity = StoreMgr:GetRemainQuantity(ItemData.Cfg.ID)
				if RemainGoodsQuantity == 0 then
					StoreMainVM.bHorizontalPriceVisible = false
				else
					StoreMainVM.bHorizontalPriceVisible = true
				end
			end
		end
	end
	local CanBuyForOther = false
	if nil ~= StoreMainVM.CurrentselectedID then
		CanBuyForOther = _G.StoreMgr:CanGift(StoreMainVM.CurrentselectedID)
	end
	UIUtil.SetIsVisible(self.BtnGift, CanBuyForOther, true)
	self.AmountSlider:SetSliderValueMaxMin(StoreMainVM.MultiBuyLimitNum, 1)
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v,self.MaxNum)
	end)

	self.AmountSlider:SetBtnIsShow(StoreMainVM.MultiBuyLimitNum > 1)
	if _G.CommonDefine.bPreLoadCommRewardPannel then
		_G.StoreMgr:PreLoadCommRewardPannel()
	end
end

function StoreBuyPropsWinView:OnNumChanged(NewValue)
end

function StoreBuyPropsWinView:OnHide()
	_G.StoreMgr.CommRewardPannel = nil
end

function StoreBuyPropsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGift, self.OnClickButtonGift)
	UIUtil.AddOnClickedEvent(self, self.ShopGoods.BtnGoods, self.OnClickBtnItem)
	
	UIUtil.AddOnClickedEvent(self, self.BtnBuyConfirm.Button, self.OnClickButtonBuy)
end

function StoreBuyPropsWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateScore, self.OnScoreUpdate)
end

function StoreBuyPropsWinView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.Binders)
	self:RegisterBinders(self.PriceVM, self.PriceBinders)
end

---@type 确认购买
function StoreBuyPropsWinView:OnClickButtonBuy()
	local ItemData = _G.StoreMgr:GetProductDataByID(StoreMainVM.CurrentselectedID)
	if nil == ItemData then
		return
	end
	local IsCan, CanNotReason = _G.StoreMgr:IsCanBuy(ItemData.Cfg.ID)
	if not IsCan then
		MsgTipsUtil.ShowTips(StoreUtil.GetTipsByCannotBuyReason(CanNotReason))
	else
		if StoreMainVM:bAvailableBuyByMultiBuy(ItemData) then
			self:Hide()
			StoreMainVM:BuyProps(ItemData.Cfg.ID)
		end
	end
	if nil ~= StoreMainVM.CurrentSelectedItem then
		StoreUtil.ReportPurchaseClickFlow(StoreMainVM.CurrentSelectedItem.GoodsId,
			StoreDefine.PurchaseOperationType.ClickDetailBuyButton)
	end
end

--- 赠送
function StoreBuyPropsWinView:OnClickButtonGift()
	if StoreMainVM.CurrentSelectedItem ~= nil then
		_G.UIViewMgr:ShowView(_G.UIViewID.StoreGiftChooseFriendWin, {GoodsID = StoreMainVM.CurrentSelectedItem.GoodsId})
	end
end

---@type 滑动条改变购买数量
function StoreBuyPropsWinView:OnValueChangedSlider(Value)
	StoreMainVM:ChangeQuantityBySlider(Value)
end

---@type 点击物品
function StoreBuyPropsWinView:OnClickBtnItem()
	local ItemData = _G.StoreMgr:GetProductDataByID(StoreMainVM.CurrentselectedID)
	local ItemID
	if ItemData and ItemData.Cfg and ItemData.Cfg.Items and ItemData.Cfg.Items[1] then
		ItemID = ItemData.Cfg.Items[1].ID
	end
	if ItemID then
		ItemTipsUtil.ShowTipsByResID(ItemID, self.ShopGoods, {X = 0, Y = 0})
	end
end

function StoreBuyPropsWinView:OnScoreUpdate(Params)
	if nil == Params or nil == self.PriceVM or Params ~= self.PriceVM.ScoreID then -- 当前默认使用水晶点
		return
	end
	self.PriceVM:UpdatePriceColor()
end

return StoreBuyPropsWinView