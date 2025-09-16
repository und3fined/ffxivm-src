---
--- Author: Administrator
--- DateTime: 2023-05-08 21:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MarketOnSaleWinVM = require("Game/Market/VM/MarketOnSaleWinVM")

local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TradeMarketGoodsCfg = require("TableCfg/TradeMarketGoodsCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MarketMgr = require("Game/Market/MarketMgr")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local TradeMarketSystemParamCfg = require("TableCfg/TradeMarketSystemParamCfg")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
local EventID = _G.EventID
local MsgTipsUtil = _G.MsgTipsUtil
local MonthCardMgr =_G.MonthCardMgr


---@class MarketOnSaleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnAddPrice UFButton
---@field BtnAddQuantity UFButton
---@field BtnMaxPrice UFButton
---@field BtnMaxQuantity UFButton
---@field BtnOnRemoved CommBtnLView
---@field BtnOnSale CommBtnLView
---@field BtnOnSale2 CommBtnLView
---@field BtnSubtractPrice UFButton
---@field BtnSubtractQuantity UFButton
---@field CommInforBtn_UIBP_81 CommInforBtnView
---@field EditPrice CommEditQuantityItemView
---@field EditQuantity CommEditQuantityItemView
---@field EmptyTips CommBackpackEmptyView
---@field HorizontalPrice UFHorizontalBox
---@field IconPriceMost UFImage
---@field IconQuantityMost UFImage
---@field ImgPriceAdd UFImage
---@field ImgPriceAddDisable UFImage
---@field ImgPriceMaxNormal UFImage
---@field ImgQuantityAdd UFImage
---@field ImgQuantityAddDisable UFImage
---@field ImgQuantityMaxNormal UFImage
---@field ImgSubtract UFImage
---@field ImgSubtractDisable UFImage
---@field ImgSubtractDisable_1 UFImage
---@field ImgSubtract_1 UFImage
---@field InforBtn CommInforBtnView
---@field MarketPurchaseWindowItem_UIBP MarketPurchaseWindowItemView
---@field PanelEmpty UFCanvasPanel
---@field PanelMarketPrice UFCanvasPanel
---@field PanelRecommendPrice UFCanvasPanel
---@field PanelReferPrice UFCanvasPanel
---@field PanelTwoBtn UFCanvasPanel
---@field TableViewMarket UTableView
---@field TextAftertaxIncome UFTextBlock
---@field TextAmount UFTextBlock
---@field TextAmount1 UFTextBlock
---@field TextItemDescription URichTextBox
---@field TextItemName UFTextBlock
---@field TextItemType URichTextBox
---@field TextMarketPrice UFTextBlock
---@field TextPrice UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextQuantity1 UFTextBlock
---@field TextRecommendPrice UFTextBlock
---@field TextSettingPrice UFTextBlock
---@field TextSettingQuantity UFTextBlock
---@field TextTariff UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketOnSaleWinView = LuaClass(UIView, true)

function MarketOnSaleWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnAddPrice = nil
	--self.BtnAddQuantity = nil
	--self.BtnMaxPrice = nil
	--self.BtnMaxQuantity = nil
	--self.BtnOnRemoved = nil
	--self.BtnOnSale = nil
	--self.BtnOnSale2 = nil
	--self.BtnSubtractPrice = nil
	--self.BtnSubtractQuantity = nil
	--self.CommInforBtn_UIBP_81 = nil
	--self.EditPrice = nil
	--self.EditQuantity = nil
	--self.EmptyTips = nil
	--self.HorizontalPrice = nil
	--self.IconPriceMost = nil
	--self.IconQuantityMost = nil
	--self.ImgPriceAdd = nil
	--self.ImgPriceAddDisable = nil
	--self.ImgPriceMaxNormal = nil
	--self.ImgQuantityAdd = nil
	--self.ImgQuantityAddDisable = nil
	--self.ImgQuantityMaxNormal = nil
	--self.ImgSubtract = nil
	--self.ImgSubtractDisable = nil
	--self.ImgSubtractDisable_1 = nil
	--self.ImgSubtract_1 = nil
	--self.InforBtn = nil
	--self.MarketPurchaseWindowItem_UIBP = nil
	--self.PanelEmpty = nil
	--self.PanelMarketPrice = nil
	--self.PanelRecommendPrice = nil
	--self.PanelReferPrice = nil
	--self.PanelTwoBtn = nil
	--self.TableViewMarket = nil
	--self.TextAftertaxIncome = nil
	--self.TextAmount = nil
	--self.TextAmount1 = nil
	--self.TextItemDescription = nil
	--self.TextItemName = nil
	--self.TextItemType = nil
	--self.TextMarketPrice = nil
	--self.TextPrice = nil
	--self.TextQuantity = nil
	--self.TextQuantity1 = nil
	--self.TextRecommendPrice = nil
	--self.TextSettingPrice = nil
	--self.TextSettingQuantity = nil
	--self.TextTariff = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketOnSaleWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnOnRemoved)
	self:AddSubView(self.BtnOnSale)
	self:AddSubView(self.BtnOnSale2)
	self:AddSubView(self.CommInforBtn_UIBP_81)
	self:AddSubView(self.EditPrice)
	self:AddSubView(self.EditQuantity)
	self:AddSubView(self.EmptyTips)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.MarketPurchaseWindowItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketOnSaleWinView:OnInit()
	self.ReferencePriceTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMarket, nil, false)

	self.EditPrice:ShowRangeMode(false)
	self.EditQuantity:ShowRangeMode(false)

	self.Binders = {
		{ "ItemTypeText", UIBinderSetText.New(self, self.TextItemType) },
		{ "ItemNameText", UIBinderSetText.New(self, self.TextItemName) },
		{ "ItemDescriptionText", UIBinderSetText.New(self, self.TextItemDescription) },
		{ "TariffText", UIBinderSetText.New(self, self.TextTariff) },                     -- 税
		{ "AmountText", UIBinderSetTextFormatForMoney.New(self, self.TextAmount1) },      --收益
		{ "RecommendText", UIBinderSetTextFormatForMoney.New(self, self.TextAmount) },    --推荐价格
		{ "ReferencePriceVMList", UIBinderUpdateBindableList.New(self, self.ReferencePriceTableViewAdapter) },

		{ "MarketPriceVisible", UIBinderSetIsVisible.New(self, self.PanelMarketPrice) },
		{ "EmptyTipsVisible", UIBinderSetIsVisible.New(self, self.PanelEmpty) },

		{ "SellVisible", UIBinderSetIsVisible.New(self, self.BtnOnSale) },
		{ "ReSellVisible", UIBinderSetIsVisible.New(self, self.PanelTwoBtn) },
		{ "TextQuantityColor", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity1) },

	}
end

function MarketOnSaleWinView:OnDestroy()

end

function MarketOnSaleWinView:OnShow()
	if nil == self.Params then
		return
	end

	--设置数量控件的监听事件
	self.EditPrice:SetModifyValueCallback(function (ConfirmValue)
		local Quantity = MarketOnSaleWinVM.Quantity or 0
		if ConfirmValue * Quantity > MarketMgr.PriceSellMax then
			self.EditPrice:SetCurValue(MarketOnSaleWinVM.Price or 0)
			MsgTipsUtil.ShowTips(_G.LSTR(1010029))
			return
		end
		MarketOnSaleWinVM:SetPrice(ConfirmValue)
	end)

	self.EditQuantity:SetModifyValueCallback(function (ConfirmValue)
		local Price = MarketOnSaleWinVM.Price or 0
		if ConfirmValue * Price > MarketMgr.PriceSellMax then
			self.EditQuantity:SetCurValue(MarketOnSaleWinVM.Quantity or 0)
			MsgTipsUtil.ShowTips(_G.LSTR(1010029))
			return
		end
		MarketOnSaleWinVM:SetQuantity(ConfirmValue)
	end)

	self.EditPrice:SetUnitSubCall(function (CurValue)
		local Result  = CurValue - math.ceil(CurValue*MarketMgr.PriceGearPersent/100)
		return Result < self.EditPrice.LowerLimit and self.EditPrice.LowerLimit or Result
	end)
		
	self.EditPrice:SetUnitAddCall(function (CurValue)
		local Result  = CurValue + math.ceil(CurValue*MarketMgr.PriceGearPersent/100) 
		return Result > self.EditPrice.UpperLimit and self.EditPrice.UpperLimit or Result
	end)


	MarketOnSaleWinVM:UpdateVM(self.Params)

	self:SetUIInfoWithSell()
	self:SetUIInfoWithReSell()
end


function MarketOnSaleWinView:SetUIInfoWithReSell()
	local Stall = self.Params.Stall
	if Stall == nil then
		return
	end
	local ResID = Stall.ResID
	MarketMgr:SendReferencePriceMessage(ResID)

	local Num = Stall.TotalNum - Stall.SoldNum
	self.EditQuantity:SetAllBtnIsEnabled(false)

	self.EditQuantity:SetInputLowerLimit(Num)
	self.EditQuantity:SetInputUpperLimit(Num)

	local GoodCfg = TradeMarketGoodsCfg:FindCfgByKey(ResID)
    if GoodCfg ~= nil then
		self.EditPrice:SetInputLowerLimit(GoodCfg.PriceMin or 0)
		self.EditPrice:SetInputUpperLimit(GoodCfg.PriceMax or 0)
    end

	self.EditPrice:SetCurValue(Stall.SinglePrice)
	self.EditQuantity:SetCurValue(Num)
end

function MarketOnSaleWinView:SetUIInfoWithSell()
	local Item = self.Params.Item
	if Item == nil then
		return
	end
	local ResID = Item.ResID
	MarketMgr:SendReferencePriceMessage(ResID)
	local Num = Item.Num
	if MarketMgr.OnceSellNumMax < Num then
		Num = MarketMgr.OnceSellNumMax
	end
	self.EditQuantity:SetAllBtnIsEnabled(true)
	self.EditQuantity:SetInputLowerLimit(1)
	self.EditQuantity:SetInputUpperLimit(Num)
	
	local GoodCfg = TradeMarketGoodsCfg:FindCfgByKey(ResID)
	local BaseSugPrice = 0
	if GoodCfg ~= nil then
		self.EditPrice:SetInputLowerLimit(GoodCfg.PriceMin or 0)
		self.EditPrice:SetInputUpperLimit(GoodCfg.PriceMax or 0)
		BaseSugPrice = GoodCfg.BaseSugPrice
	end
	
	--处理默认值显示
	local Info = MarketMgr.SaleGoodCache[ResID]
	if Info ~= nil then
		local Quantity = Info.Num > Num and Num or Info.Num
		local Price = Info.Price
		self.EditQuantity:SetCurValue(Quantity)
		self.EditPrice:SetCurValue(Price)
	else
		self.EditPrice:SetCurValue(BaseSugPrice)
		self.EditQuantity:SetCurValue(1)
	end	

end


function MarketOnSaleWinView:OnHide()

end

function MarketOnSaleWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOnSale.Button, self.OnClickedSaleBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnOnSale2.Button, self.OnClickedReSaleBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnOnRemoved.Button, self.OnClickedRemovedBtn)
	self.InforBtn:SetCallback(self, self.OnInforBtnClickHelp)
end

function MarketOnSaleWinView:OnInforBtnClickHelp()
	local tipsContent = nil
	if MonthCardMgr:GetMonthCardStatus() == true then
		local TaxMonthCardCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_TAX_DESC_WITHOUT_MONTHCARD)
		if nil ~= TaxMonthCardCfg then
			local HelpCfgs = HelpCfg:FindAllHelpIDCfg(TaxMonthCardCfg.Value[1])
			local HelpContent = HelpInfoUtil.ParseContent(HelpCfgs)
			local Ret = {}
			for k, v in ipairs(HelpContent) do
				local Title = v.SecTitle
				local Content = {}
				for index, value in ipairs(v.SecContent) do
					local SecContent = value.SecContent
					if index == 2 then
						local LocalTimeStamp = TimeUtil.GetServerLogicTime()
						local VaildTimeStamp = MonthCardMgr:GetMonthCardValidTime()
						local RemainTimeStamp = VaildTimeStamp - LocalTimeStamp
						local SecondsTime = RemainTimeStamp + 1
						local MonthCardMainPanelVM = require("Game/MonthCard/VM/MonthCardMainPanelVM")
						local RemainTxt = _G.LocalizationUtil.GetCountdownTimeForSimpleTime(SecondsTime, MonthCardMainPanelVM:GetTimeFormat(SecondsTime))
						SecContent = string.format(value.SecContent, string.format("%d", MarketMgr.MonthCardTradeTax*100).."%", RemainTxt)
					end
					table.insert(Content, SecContent)
				end
				table.insert(Ret, {Title= Title, Content = Content})
			end

			tipsContent = Ret
		end

	else
		local TaxNormalCfg = TradeMarketSystemParamCfg:FindCfgByKey(ProtoRes.trade_market_param_cfg_id.TRADE_MAERKET_PARAM_TAX_DESC_WITH_MONTHCARD)
		if nil ~= TaxNormalCfg then
			local HelpCfgs = HelpCfg:FindAllHelpIDCfg(TaxNormalCfg.Value[1])
			tipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
		end
	end

	if tipsContent == nil then
		return
	end
	local BtnSize = UIUtil.GetWidgetSize(self.InforBtn)
	
	TipsUtil.ShowInfoTitleTips(tipsContent, self.InforBtn, _G.UE.FVector2D(-BtnSize.X, 10), _G.UE.FVector2D(1, 0))
end

function MarketOnSaleWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MarketReferencePriceUpdata, self.OnReferencePriceUpdata)
end

function MarketOnSaleWinView:OnRegisterBinder()
	
	if nil == self.Binders then return end
	self:RegisterBinders(MarketOnSaleWinVM, self.Binders)
	self.MarketPurchaseWindowItem_UIBP:SetParams({Data = MarketOnSaleWinVM.SellItemMV})
	
	self.Bg:SetTitleText(LSTR(1010068))
	self.EmptyTips:SetTipsContent(LSTR(1010069))
	self.TextRecommendPrice:SetText(LSTR(1010070))
	self.TextQuantity:SetText(LSTR(1010071))
	self.TextMarketPrice:SetText(LSTR(1010072))
	self.BtnOnSale:SetText(LSTR(1010073))
	self.BtnOnRemoved:SetText(LSTR(1010074))
	self.BtnOnSale2:SetText(LSTR(1010073))
	self.TextQuantity1:SetText(LSTR(1010071))
	self.TextPrice:SetText(LSTR(1010075))
	self.TextAftertaxIncome:SetText(LSTR(1010076))
end


function MarketOnSaleWinView:OnClickedSaleBtn()
	--处理摊位不足
	local FreeStallNum = MarketMgr.FreeStallNum or 0
	local MonthCardStallNum = MarketMgr.MonthCardStallNum or 0
	
	local IsOpenMonthCard = _G.MonthCardMgr:GetMonthCardStatus() == true
	local AllStallNum = IsOpenMonthCard and FreeStallNum + MonthCardStallNum or FreeStallNum
	local StallItemList = MarketMgr.StallItemList or {}
	if #StallItemList >= AllStallNum then
		MsgTipsUtil.ShowTips(LSTR(1010030))
		return
	end

	if self.Params == nil then
		return
	end
	local ItemData = self.Params.Item
	if ItemData == nil then
		return
	end

	if ItemData.Attr ~= nil and ItemData.Attr.Equip ~= nil and ItemData.Attr.Equip.GemInfo ~= nil then
		local CarryList = ItemData.Attr.Equip.GemInfo.CarryList or {}
		if #CarryList >0 then
			local RedColor = "#D1BA8E"
			local _finalStr = string.format(
                                  LSTR(1010031), RedColor)
			_G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, _G.LSTR(1010032), _finalStr, nil, LSTR(10002))
			self:Hide()
			return
		end
	end
	
	--发送上架请求
	MarketMgr:SendSaleItemMessage(ItemData.GID, ItemData.ResID, MarketOnSaleWinVM.Price, MarketOnSaleWinVM.Quantity, self.Params.ContainerIndex)
	self:Hide()
end

function MarketOnSaleWinView:OnClickedReSaleBtn()
	local Stall = self.Params.Stall
	if Stall == nil then
		return
	end

	MarketMgr:SendReSaleItemMessage(Stall.ResID, Stall.SellID, Stall.TotalNum - Stall.SoldNum, MarketOnSaleWinVM.Price)
	self:Hide()
end

function MarketOnSaleWinView:OnClickedRemovedBtn()
	local Stall = self.Params.Stall
	if Stall == nil then
		return
	end
	MarketMgr:SendCloseSaleItemMessage(Stall.SellID, Stall.ResID)
	self:Hide()
end

function MarketOnSaleWinView:OnReferencePriceUpdata(ReferencePrice)
	if self.Params == nil then
		return
	end
	local ResID = nil
	local ItemData = self.Params.Item
	if ItemData ~= nil then
		ResID = ItemData.ResID 
	end

	local Stall = self.Params.Stall
	if Stall ~= nil then
		ResID = Stall.ResID
	end

	if ResID == nil then
		return
	end

	if ResID == ReferencePrice.ResID then
		MarketOnSaleWinVM:UpdateReferencePrice(ReferencePrice)
	end

	local Info = MarketMgr.SaleGoodCache[ResID]
	if Info == nil then
		local RecommendPrice = MarketOnSaleWinVM:GetRecommendPrice(ReferencePrice.PriceList or {})
		if RecommendPrice > 0 then
			self.EditPrice:SetCurValue(RecommendPrice)
		end
	end
end

return MarketOnSaleWinView