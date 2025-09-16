---
--- Author: Administrator
--- DateTime: 2023-05-22 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MarketBuyWinVM = require("Game/Market/VM/MarketBuyWinVM")
local TradeMarketSystemParamCfg = require("TableCfg/TradeMarketSystemParamCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local MarketMgr = require("Game/Market/MarketMgr")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MajorUtil = require("Utils/MajorUtil")

local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local ScoreMgr = _G.ScoreMgr
local EventID = _G.EventID

---@class MarketBuyWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExchange CommBtnLView
---@field BtnSwitch UFButton
---@field CommMoneyBar CommMoneyBarView
---@field CountSlider CommAmountSliderView
---@field ImgPriceIcon UFImage
---@field MarketPurchaseWindowItem_UIBP MarketPurchaseWindowItemView
---@field NewBg Comm2FrameLView
---@field RichTextAmount URichTextBox
---@field TableViewList UTableView
---@field TextItemDescription URichTextBox
---@field TextItemName UFTextBlock
---@field TextItemType URichTextBox
---@field TextPrice UFTextBlock
---@field TextSalePrice UFTextBlock
---@field TextSeller UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketBuyWinView = LuaClass(UIView, true)

function MarketBuyWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExchange = nil
	--self.BtnSwitch = nil
	--self.CommMoneyBar = nil
	--self.CountSlider = nil
	--self.ImgPriceIcon = nil
	--self.MarketPurchaseWindowItem_UIBP = nil
	--self.NewBg = nil
	--self.RichTextAmount = nil
	--self.TableViewList = nil
	--self.TextItemDescription = nil
	--self.TextItemName = nil
	--self.TextItemType = nil
	--self.TextPrice = nil
	--self.TextSalePrice = nil
	--self.TextSeller = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketBuyWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnExchange)
	self:AddSubView(self.CommMoneyBar)
	self:AddSubView(self.CountSlider)
	self:AddSubView(self.MarketPurchaseWindowItem_UIBP)
	self:AddSubView(self.NewBg)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketBuyWinView:OnInit()
	self.SaleStallTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSaleStallSelectChanged, true)
	self.BuyMaxNum = 99
	local OnceBuyMaxCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_ONCE_BUY_MAX)
	if OnceBuyMaxCfg ~= nil then
		self.BuyMaxNum = OnceBuyMaxCfg.Value[1]
	end

	self.Binders = {
		{ "ItemTypeText", UIBinderSetText.New(self, self.TextItemType) },
		{ "ItemNameText", UIBinderSetText.New(self, self.TextItemName) },
		{ "ItemDescriptionText", UIBinderSetText.New(self, self.TextItemDescription) },
	
		{ "ShopAmount", UIBinderSetTextFormat.New(self, self.RichTextAmount, "%d") },
		{ "SalePriceText", UIBinderSetTextFormatForMoney.New(self, self.TextSalePrice) },
		{ "SalePriceColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSalePrice) },
		{ "SaleStallVMList", UIBinderUpdateBindableList.New(self, self.SaleStallTableViewAdapter) },
	}

	UIUtil.SetIsVisible(self.CommMoneyBar.Money1, false)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money2,  true)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money3,  false)
end

function MarketBuyWinView:OnDestroy()

end

function MarketBuyWinView:OnShow()
	if nil == self.Params then
		return
	end
	self.CommMoneyBar.Money2:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE, false, nil, true)
	self:ResetStallBriefData(false)
	MarketMgr:SendStallListMessage(self.Params.ResID, 0, MarketMgr.StallListOnePageNum*3 - 1, self.IsReverse)

	MarketBuyWinVM:SetBuyItemInfo(self.Params.ResID)

	self.CountSlider:SetValueChangedCallback(function (v)
		self:OnValueChangedAmountCountSlider(v)
	end)
	self.CountSlider:SetSliderValueMaxMin(1, 1)
	self.CountSlider:SetSliderValue(1)

	self.CountSlider:SetBtnIsShow(false)
	
	self.CountSlider:SetSliderValueMaxTips("已达到最大数量，不能再增加")
	self.CountSlider:SetSliderValueMinTips("已达到最小数量，不能再减少")
end

function MarketBuyWinView:SetBuyInfoByStall(StallBrief)
	local MaxNum = StallBrief.Num > self.BuyMaxNum and self.BuyMaxNum or StallBrief.Num
	local Cfg = ItemCfg:FindCfgByKey(StallBrief.ResID)
	if nil == Cfg then
		return
	end

	if Cfg.MaxPile == 1 then
		MaxNum = Cfg.MaxPile
	end

	self.CountSlider:SetBtnIsShow(MaxNum > 1)

	self.CountSlider:SetSliderValueMaxMin(MaxNum, 1)
	self.CountSlider:SetSliderValue(1)
end

function MarketBuyWinView:OnHide()
	MarketBuyWinVM.StallBrief = nil
end

function MarketBuyWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExchange, self.OnClickedBuyBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickedSwitchBtn)
	UIUtil.AddOnScrolledEvent(self, self.SaleStallTableViewAdapter, self.OnTableViewScrolled)
end

function MarketBuyWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MarketRefreshStallBriefList, self.OnMarketRefreshStallBriefList)
	self:RegisterGameEvent(EventID.MarketRefreshConcernInfo, self.OnRefreshConcernInfo)
end

function MarketBuyWinView:ResetStallBriefData(IsReverse)
	self.IsReverse = IsReverse
	self.LastNum = 1
	MarketBuyWinVM.StallBriefBegin = nil
	MarketBuyWinVM.StallBriefEnd = nil
end

function MarketBuyWinView:OnRegisterBinder()
	if nil == self.Binders then return end
	self:RegisterBinders(MarketBuyWinVM, self.Binders)
	self.MarketPurchaseWindowItem_UIBP:SetParams({Data = MarketBuyWinVM.SellItemMV})

	self.NewBg:SetTitleText(LSTR(1010052))
	self.TextPrice:SetText(LSTR(1010053))
	self.TextSeller:SetText(LSTR(1010054))
	self.BtnExchange:SetText(LSTR(1010055))
	
end

function MarketBuyWinView:OnValueChangedAmountCountSlider(Value)
	MarketBuyWinVM:SetAmount(Value)
end

function MarketBuyWinView:OnSaleStallSelectChanged(Index, ItemData, ItemView)

	MarketBuyWinVM:SetSelectedStallBrief(ItemData.Value)
	self:SetBuyInfoByStall(ItemData.Value)
end

function MarketBuyWinView:OnRefreshConcernInfo()
	MarketBuyWinVM.SellItemMV:SetCollectStatus()
end

function MarketBuyWinView:OnMarketRefreshStallBriefList(StallBriefInfo)
	MarketBuyWinVM:UpdateStallBriefList(StallBriefInfo)
	if MarketBuyWinVM.StallBrief == nil then
		self.SaleStallTableViewAdapter:SetSelectedIndex(1)
	else
		MarketBuyWinVM:SetSelectedStallBrief(MarketBuyWinVM.StallBrief)
	end

end

function MarketBuyWinView:OnTableViewScrolled(TableView, ItemOffset)
	local Num = math.floor(self.SaleStallTableViewAdapter:GetScrollOffset()) + 1
	if self.LastNum ~= Num then
		if self.LastNum > Num then
			--往上滑动
			local StallBegin = MarketBuyWinVM.StallBriefBegin - MarketMgr.StallListOnePageNum
			if StallBegin < 0 then
				StallBegin = 0
			end
			if StallBegin >= 0 and self.StallBegin ~= StallBegin and Num == MarketMgr.StallListOnePageNum - 1 then
				MarketMgr:SendStallListMessage(self.Params.ResID, StallBegin , MarketBuyWinVM.StallBriefBegin - 1, self.IsReverse)
				self.StallBegin = StallBegin
				self.SaleStallTableViewAdapter:ScrollToIndex(Num + (MarketBuyWinVM.StallBriefBegin - StallBegin) + 1)
				self.LastNum = Num + (MarketBuyWinVM.StallBriefBegin - StallBegin) + 1
			else
				self.LastNum = Num
			end

		else
			--往下滑动
			if MarketBuyWinVM.StallBriefEnd == nil then
				return
			end

			local StallBegin = MarketBuyWinVM.StallBriefEnd + 1
			if MarketBuyWinVM.StallBriefEnd < MarketMgr.StallBriefNum - 1 and self.StallBegin ~= StallBegin and Num == MarketMgr.StallListOnePageNum*2 then
				local End = MarketBuyWinVM.StallBriefEnd + MarketMgr.StallListOnePageNum
				if MarketMgr.StallBriefNum ~= nil and End > MarketMgr.StallBriefNum then
					End = MarketMgr.StallBriefNum - 1
				end
				MarketMgr:SendStallListMessage(self.Params.ResID, StallBegin, End, self.IsReverse)
				self.StallBegin = StallBegin
				self.SaleStallTableViewAdapter:ScrollToIndex(Num - (End - StallBegin) - 1)
				self.LastNum = Num - (End - StallBegin) - 1
			else
				self.LastNum = Num
			end
		end
	end
end

function MarketBuyWinView:OnClickedSwitchBtn()
	self.IsReverse = not self.IsReverse
	local End = MarketMgr.StallListOnePageNum*3 - 1
	if MarketMgr.StallBriefNum ~= nil and End > MarketMgr.StallBriefNum then
		End = MarketMgr.StallBriefNum
	end
	self:ResetStallBriefData(self.IsReverse)
	MarketMgr:SendStallListMessage(self.Params.ResID, 0, End, self.IsReverse)
	MarketBuyWinVM.StallBrief = nil
end

function MarketBuyWinView:OnClickedBuyBtn()
	local StallBrief = MarketBuyWinVM.StallBrief
	if StallBrief == nil then
		return
	end
	local ResID = StallBrief.ResID
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if MajorRoleID == StallBrief.SellerID then
		_G.MsgTipsUtil.ShowTips(LSTR(1010037))
		return
	end

	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg.IsUnique == 1 then
		if _G.BagMgr:GetItemNum(ResID)  > 0 or _G.DepotVM:GetDepotItemNum(ResID) > 0 or _G.RollMgr:CheckEquipList(ResID) then
			_G.MsgTipsUtil.ShowTips(LSTR(1010038))
			return
		end

	end

	local CurCode = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
	if MarketBuyWinVM.SalePriceText > CurCode then
		_G.MsgTipsUtil.ShowTips(LSTR(1010039))
		return
    end

	if _G.BagMgr:GetBagLeftNum() == 0 then
		_G.MsgTipsUtil.ShowTips(LSTR(1010040))
		return
	end	

	MarketMgr:SendBuyGoodsMessage(MarketBuyWinVM.StallBrief.SellID, self.Params.ResID, MarketBuyWinVM.ShopAmount, MarketBuyWinVM.StallBrief.SinglePrice)
	self:Hide()
end

return MarketBuyWinView