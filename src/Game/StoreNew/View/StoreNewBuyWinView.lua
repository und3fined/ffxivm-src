---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 15:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local StoreDefine = require("Game/Store/StoreDefine")
local ScoreCfg = require("TableCfg/ScoreCfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local ItemVM = require("Game/Item/ItemVM")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local StoreMgr = require("Game/Store/StoreMgr")
local UIBinderSetTextFormatForScore = require("Binder/UIBinderSetTextFormatForScore")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local StoreBuyWinVM = require("Game/Store/VM/StoreBuyWinVM")
local StoreCfg = require("TableCfg/StoreCfg")
local StoreGoodVM = require("Game/Store/VM/ItemVM/StoreGoodVM")
local StoreUtil = require("Game/Store/StoreUtil")
local EventID = require("Define/EventID")
local MysteryboxCfg = require("TableCfg/MysteryboxCfg")

local StoreMainVM = _G.StoreMainVM

---@class StoreNewBuyWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnCoupons UFButton
---@field BtnGift UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field Comm96Slot CommBackpack96SlotView
---@field Commodity StoreCommodityItemView
---@field IconCoupons UFImage
---@field PanelCoupons UFCanvasPanel
---@field PanelMoney UFHorizontalBox
---@field PanelOriginalPrice UFCanvasPanel
---@field PanelSlot UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextCoupons UFTextBlock
---@field TextDetails URichTextBox
---@field TextHint UFTextBlock
---@field TextName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextPrice UFTextBlock
---@field TextSlot UFTextBlock
---@field TextSlotList UFTextBlock
---@field TextType UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewBuyWinView = LuaClass(UIView, true)

function StoreNewBuyWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnCancel = nil
	--self.BtnCoupons = nil
	--self.BtnGift = nil
	--self.Comm2FrameM_UIBP = nil
	--self.Comm96Slot = nil
	--self.Commodity = nil
	--self.IconCoupons = nil
	--self.PanelCoupons = nil
	--self.PanelMoney = nil
	--self.PanelOriginalPrice = nil
	--self.PanelSlot = nil
	--self.TableViewSlot = nil
	--self.TextCoupons = nil
	--self.TextDetails = nil
	--self.TextHint = nil
	--self.TextName = nil
	--self.TextOriginalPrice = nil
	--self.TextPrice = nil
	--self.TextSlot = nil
	--self.TextSlotList = nil
	--self.TextType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewBuyWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.Commodity)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewBuyWinView:OnInit()
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnEquipPartSelectChanged, true, false)
	self.BuyWinVM = StoreBuyWinVM.New()
	self.CommodityVM = StoreGoodVM.New()
	self.BuyWinBinders =
	{
		{ "ItemVMList", UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
		{ "ProductName", UIBinderSetText.New(self, self.TextName) },
		{ "TextHint", UIBinderSetText.New(self, self.TextHint) },
		{ "BuyGoodDesc", UIBinderSetText.New(self, self.TextDetails) },
		{ "bPanelSlotVisible", UIBinderSetIsVisible.New(self, self.PanelSlot) },
	}
	-- self.MainBinders =
	-- {
	-- 	{ "ContainsItemList", 		UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
	-- 	{ "ProductName", 			UIBinderSetText.New(self, self.TextName) },
	-- 	{ "TextTipsText", 			UIBinderSetText.New(self, self.TextHint) },
	-- 	{ "BuyGoodDesc", 			UIBinderSetText.New(self, self.TextDetails) },
	-- 	{ "PanelSlotVislble", 		UIBinderSetIsVisible.New(self, self.PanelSlot) },
	-- }
	self.PriceBinders =
	{
		{ "BuyPrice", UIBinderSetTextFormatForScore.New(self, self.TextPrice) },
		{ "RawPrice", UIBinderSetTextFormatForScore.New(self, self.TextOriginalPrice) },
		{ "bShowRawPrice", UIBinderSetIsVisible.New(self, self.PanelOriginalPrice) },
		{ "bHasCoupon", UIBinderSetIsVisible.New(self, self.PanelCoupons) },
		{ "CouponedNum", UIBinderValueChangedCallback.New(self, nil, self.OnCouponedNumChanged) },
		{ "BuyPriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextPrice) },
	}
	self.MysteryBoxItemVM = ItemVM.New({IsCanBeSelected = true, IsShowNum = false, IsShowSelectStatus = false})
	self.BuyPriceVM = StoreMgr:GetBuyPriceVM()
end

function StoreNewBuyWinView:OnDestroy()
	
end

function StoreNewBuyWinView:OnShow()
	self.GoodsCfgData = StoreCfg:FindCfgByKey(StoreBuyWinVM.GoodsID) or StoreMainVM.SkipTempData
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(StoreDefine.BuyTipTittleText))
	local GoodsData = nil
	if StoreMainVM.CurrentSelectedTabType == ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX then
		local TempGoodsData = table.deepcopy(StoreMainVM.SkipTempData)
		self.Params = self.Params or {}
		self.Params.IsShowGiftBtn = false
		--- 盲盒的购买界面图片用单独的
		TempGoodsData.Icon = TempGoodsData.BuyIcon
		GoodsData = {Cfg = TempGoodsData}
		self.TextSlotList:SetText(LSTR(950084))		--- 随机获得
		self.TextSlot:SetText(LSTR(950085))	--- 必得
		UIUtil.SetIsVisible(self.BtnGift, false)
		if StoreMainVM.SkipTempData ~= nil and StoreMainVM.SkipTempData.PrizePoolID ~= nil then
			local TempRandCfg = CommercializationRandCfg:FindAllCfg(string.format("PrizePoolID=%d and ProbMode=%d", StoreMainVM.SkipTempData.PrizePoolID, ProtoRes.PROBABILITY_TYPE.PROBABILITY_TYPE_GUARANTEED))[1]
			self.MysteryBoxItemVM:UpdateVM({ResID = TempRandCfg.DropID})
		end
		self.Comm96Slot:SetParams({ Data = self.MysteryBoxItemVM})

		local Items = StoreMainVM.ContainsItemList:GetItems()
		for _, value in ipairs(Items) do
			local TempCfg = HairUnlockCfg:FindCfgByItemID(value.ResID)
			if TempCfg ~= nil then
				value.Icon = _G.StoreMgr:GetHairIconByHairID(TempCfg.HairID)
			end
		end
		-- self.TextPrice:SetText(StoreMainVM.BuyGoodPriceText)
		--self.TextOriginalPrice:SetText(StoreMainVM.OriginalPriceText)
		self.TextType:SetText(ProtoEnumAlias.GetAlias(ProtoRes.StoreMall, ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX))
		--UIUtil.SetIsVisible(self.PanelOriginalPrice, StoreMainVM.PanelOriginalVisible)
	else
		if nil ~= self.GoodsCfgData then
			StoreBuyWinVM:UpdateByGoodsID(self.GoodsCfgData.ID)
			GoodsData = StoreMgr:GetProductDataByID(self.GoodsCfgData.ID)
		end
		self.TextSlotList:SetText(LSTR(950058))		--- 包含以下物品
		StoreMgr:ChooseBestCoupon(self.GoodsCfgData)
		StoreMainVM:UpdateCouponsSelectedState(self.GoodsCfgData)
		if nil ~= self.GoodsCfgData then
			self.TextType:SetText(ProtoEnumAlias.GetAlias(ProtoRes.Store_Label_Type, self.GoodsCfgData.LabelMain))
		end
	end
	self.BtnBuy:SetBtnName(LSTR(StoreDefine.LSTRTextKey.ConfirmPurchaseText))
	self.BtnCancel:SetBtnName(LSTR(StoreDefine.LSTRTextKey.CancleText))

	if nil ~= GoodsData then
		self.CommodityVM:UpdateVM({GoodData = GoodsData})
	end
	self.Commodity:SetParams({ Data = self.CommodityVM, bBottomInfoInvisible = true })

	local bShowGiftBtn = true
	local Param = self.Params
	if Param ~= nil then
		local IsShowGiftBtn = Param.IsShowGiftBtn
		if IsShowGiftBtn ~= nil then
			bShowGiftBtn = bShowGiftBtn and IsShowGiftBtn
		end
	end
	local CurrentCfgData = self.GoodsCfgData
	if nil ~= CurrentCfgData then
		UIUtil.SetIsVisible(self.BtnGift, StoreMgr:CanGift(CurrentCfgData.ID), true)
	end
	UIUtil.SetIsVisible(self.BtnGift, bShowGiftBtn, true)
	if _G.CommonDefine.bPreLoadCommRewardPannel then
		_G.StoreMgr:PreLoadCommRewardPannel()
	end
end

function StoreNewBuyWinView:OnCouponedNumChanged(CouponedNum)
	local bCouponed = nil ~= CouponedNum and CouponedNum > 0
	if bCouponed then
		local ScoreName = LSTR(StoreDefine.LSTRTextKey.StampsText)	--- 水晶点
		local ScoreID = StoreMainVM.SkipTempData.Price[1].ID
		local TempScoreCfg = ScoreCfg:FindCfgByKey(ScoreID)
		if TempScoreCfg ~= nil then
			ScoreName = TempScoreCfg.NameText
		end
		self.TextCoupons:SetText(string.format("%s%d%s", "-", CouponedNum, ScoreName))
		UIUtil.SetColorAndOpacityHex(self.TextCoupons, "D1BA8EFF")
	else
		self.TextCoupons:SetText(LSTR(StoreDefine.LSTRTextKey.NotUseCoupon))
		UIUtil.SetColorAndOpacityHex(self.TextCoupons, "FFFFFFFF")
	end
	UIUtil.SetIsVisible(self.IconCoupons, bCouponed)
end

function StoreNewBuyWinView:OnHide()
	_G.StoreMgr.CommRewardPannel = nil
end

function StoreNewBuyWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickBtnBuy)
	UIUtil.AddOnClickedEvent(self, self.BtnCoupons, self.OnClickBtnCoupons)
	UIUtil.AddOnClickedEvent(self, self.BtnGift, self.OnClickBtnGift)
	UIUtil.AddOnClickedEvent(self, self.Comm96Slot.Btn, self.OnClickMysteryBoxItem)
end

function StoreNewBuyWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateScore, self.OnScoreUpdate)
end

function StoreNewBuyWinView:OnClickMysteryBoxItem()
	ItemTipsUtil.ShowTipsByResID(self.MysteryBoxItemVM.ResID, self.Comm96Slot, {X = 0, Y = 0})
end

function StoreNewBuyWinView:OnEquipPartSelectChanged(Index, ItemData, ItemView)
	ItemData.IsSelect = false
	-- if nil == StoreMainVM.ContainsItemList or nil == StoreMainVM.ContainsItemList.Items or nil == StoreMainVM.ContainsItemList.Items[Index] or
	-- 	nil == StoreMainVM.ContainsItemList.Items[Index].ResID then
	-- 	return
	-- end
	-- ItemTipsUtil.ShowTipsByResID(StoreMainVM.ContainsItemList.Items[Index].ResID, ItemView, {X = 0, Y = 0})
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0, Y = 0})
end

function StoreNewBuyWinView:OnClickBtnBuy()
	_G.StoreMgr:CheckPurchasePreconditions(self.GoodsCfgData)
	if nil ~= StoreMainVM.CurrentSelectedItem then
		StoreUtil.ReportPurchaseClickFlow(StoreMainVM.CurrentSelectedItem.GoodID,
			StoreDefine.PurchaseOperationType.ClickDetailBuyButton)
	end
end

function StoreNewBuyWinView:OnClickBtnCoupons()
	_G.UIViewMgr:ShowView(_G.UIViewID.StoreNewCouponsWin)
end

function StoreNewBuyWinView:OnClickBtnGift()
	if StoreMainVM.CurrentSelectedItem ~= nil then
		_G.UIViewMgr:ShowView(_G.UIViewID.StoreGiftChooseFriendWin, {GoodsID = StoreMainVM.CurrentSelectedItem.GoodID})
	end
end

function StoreNewBuyWinView:OnRegisterBinder()
	-- self:RegisterBinders(StoreMainVM, self.MainBinders)
	self:RegisterBinders(StoreBuyWinVM, self.BuyWinBinders)
	self:RegisterBinders(self.BuyPriceVM, self.PriceBinders)
end

function StoreNewBuyWinView:OnScoreUpdate(Params)
	if nil == Params or nil == self.BuyPriceVM or Params ~= self.BuyPriceVM.ScoreID then
		return
	end
	self.BuyPriceVM:UpdatePriceColor()
end

return StoreNewBuyWinView