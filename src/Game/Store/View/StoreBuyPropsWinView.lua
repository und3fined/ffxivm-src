
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
local ProtoRes = require("Protocol/ProtoRes")

---@class StoreBuyPropsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BG Comm2FrameMView
---@field BtnAdd UFButton
---@field BtnBuyConfirm CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnGift UFButton
---@field BtnItem UFButton
---@field BtnSub UFButton
---@field HorizontalPrice UFHorizontalBox
---@field ImgGoods UFImage
---@field ImgHQ UFImage
---@field ImgMoney UFImage
---@field ImgQuality UFImage
---@field PanelBuySetting UFCanvasPanel
---@field PanelDiscount UFCanvasPanel
---@field PanelHQ UFCanvasPanel
---@field PanelOriginal UFCanvasPanel
---@field TextAmount UFTextBlock
---@field TextCurrentPrice UFTextBlock
---@field TextDiscount UFTextBlock
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
	--self.BtnAdd = nil
	--self.BtnBuyConfirm = nil
	--self.BtnCancel = nil
	--self.BtnGift = nil
	--self.BtnItem = nil
	--self.BtnSub = nil
	--self.HorizontalPrice = nil
	--self.ImgGoods = nil
	--self.ImgHQ = nil
	--self.ImgMoney = nil
	--self.ImgQuality = nil
	--self.PanelBuySetting = nil
	--self.PanelDiscount = nil
	--self.PanelHQ = nil
	--self.PanelOriginal = nil
	--self.TextAmount = nil
	--self.TextCurrentPrice = nil
	--self.TextDiscount = nil
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
	self:AddSubView(self.BtnCancel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreBuyPropsWinView:OnInit()
	self.Binders = {
		{ "MultiBuyBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "MultiBuyIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgGoods) },
		{ "MultiBuyName", UIBinderSetText.New(self, self.TextItemName) },
		{ "MultiBuySubName", UIBinderSetText.New(self, self.TextItemType) },
		{ "MultiBuyPriceText", UIBinderSetText.New(self, self.TextCurrentPrice) },
		{ "MultiBuyPriceType", UIBinderSetBrushFromAssetPath.New(self, self.ImgMoney) },
		{ "MultiBuyPurchaseNumber", UIBinderSetText.New(self, self.AmountSlider.TextQuantity) },
		{ "MultiBuyQuantity", UIBinderSetText.New(self, self.TextSurplus) },
		{ "MultiBuyDesc", UIBinderSetText.New(self, self.TextItemDescription) },
		{ "MultiDisPanelVisible", UIBinderSetIsVisible.New(self, self.PanelDiscount) },
		{ "MultiDisText", UIBinderSetText.New(self, self.TextDiscount) },

		{ "bMultiBuyPanelHQVisible", UIBinderSetIsVisible.New(self, self.PanelHQ) },
		-- { "bMultiBuySliderEnabled", UIBinderSetIsEnabled.New(self, self.AmountSlider) },
		{ "bMultiBuySliderEnabled", UIBinderSetIsVisible.New(self, self.AmountSlider) },
		
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
	self.BtnCancel:SetBtnName(LSTR(950030))			--- 取消
	self.BtnBuyConfirm:SetBtnName(LSTR(950053))		--- 确认购买

	self.AmountSlider:SetSliderValueMaxTips(LSTR(950040))
	self.AmountSlider:SetSliderValueMinTips(LSTR(950040))
	self.BtnBuyConfirm:UpdateImage(StoreMainVM.MultiBuyConfirmBtnImgType)
	UIUtil.SetIsVisible(self.TextAmount, StoreMainVM.bMultiBuySliderEnabled)
	UIUtil.SetIsVisible(self.TextSurplus, StoreMainVM.bMultiBuySliderEnabled)
	local ItemData = _G.StoreMgr:GetProductDataByID(StoreMainVM.CurrentselectedID)
	if nil ~= ItemData then
		if not StoreMainVM.bMultiBuySliderEnabled then
			local IsCan, CanNotReason = _G.StoreMgr:IsCanBuy(ItemData.Cfg.ID)
			self.TextSoldout:SetText(CanNotReason)
			self.TextSoldout:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("#DC5868FF"))
			UIUtil.SetIsVisible(self.TextSoldout, not IsCan)
		else
			if ItemData.GoodsCounterFirst == 0 then
				UIUtil.SetIsVisible(self.TextSoldout, false)
			else
				local RemainGoodsQuantity = StoreMgr:GetRemainQuantity(ItemData.Cfg.ID)
				if RemainGoodsQuantity >= 0 then
					self.TextSoldout:SetText(string.format(LSTR(950035), RemainGoodsQuantity))
					self.TextSoldout:SetColorAndOpacity(_G.UE.FLinearColor.FromHex("#828282FF"))
					UIUtil.SetIsVisible(self.TextSoldout, true)
				else
					UIUtil.SetIsVisible(self.TextSoldout, false)
				end
			end
		end
	end
	local CanBuyForOther = false
	if nil ~= StoreMainVM.CurrentselectedID then
		CanBuyForOther = _G.StoreMgr:CanGift(StoreMainVM.CurrentselectedID)
	end
	UIUtil.SetIsVisible(self.BtnGift, CanBuyForOther, true)
	UIUtil.SetIsVisible(self.BtnCancel, true, true)
	self.AmountSlider:SetSliderValueMaxMin(StoreMainVM.MultiBuyLimitNum, 1)
	self.AmountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v,self.MaxNum)
	end)

	self.AmountSlider:SetBtnIsShow(StoreMainVM.MultiBuyLimitNum > 1)
	if _G.CommonDefine.bPreLoadCommRewardPannel then
		_G.StoreMgr:PreLoadCommRewardPannel()
	end

	--临时处理，分支和主干蓝图代码不同导致显示问题
	UIUtil.SetIsVisible(self.TextAmount, false)
end

function StoreBuyPropsWinView:OnNumChanged(NewValue)
	UIUtil.SetIsVisible(self.BtnAdd, NewValue == StoreMainVM.MultiBuyLimitNum, true)
	UIUtil.SetIsVisible(self.BtnSub, NewValue == 1, true)
end

function StoreBuyPropsWinView:OnHide()
	_G.StoreMgr.CommRewardPannel = nil
end

function StoreBuyPropsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.Hide)
	UIUtil.AddOnClickedEvent(self, self.BtnGift, self.OnClickButtonGift)
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnClickBtnItem)
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickBtnAddAndBtnSub)
	UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnClickBtnAddAndBtnSub)
	
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
		if StoreMainVM:bAvailableBuyByMultiBuy() then
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
		ItemTipsUtil.ShowTipsByResID(ItemID, self.BtnItem, {X = 0, Y = 0})
	end
end

--- 点击错误提示Btn
function StoreBuyPropsWinView:OnClickBtnAddAndBtnSub()
	local Tips = LSTR(950040)
	MsgTipsUtil.ShowTips(Tips)
end

function StoreBuyPropsWinView:OnScoreUpdate(Params)
	if nil == Params or nil == self.PriceVM or Params ~= self.PriceVM.ScoreID then -- 当前默认使用水晶点
		return
	end
	self.PriceVM:UpdatePriceColor()
end

return StoreBuyPropsWinView