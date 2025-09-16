---
--- Author: Administrator
--- DateTime: 2023-05-18 14:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MarketRemoveWinVM = require("Game/Market/VM/MarketRemoveWinVM")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")
local MarketMgr = require("Game/Market/MarketMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local EventID = _G.EventID
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
---@class MarketRemoveWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnRemove CommBtnLView
---@field EmptyTips CommBackpackEmptyView
---@field HorizontalPrice UFHorizontalBox
---@field MarketPurchaseWindowItem_UIBP MarketPurchaseWindowItemView
---@field PanelEmpty UFCanvasPanel
---@field TableViewMarket UTableView
---@field TextA UFTextBlock
---@field TextAftertaxIncome UFTextBlock
---@field TextAmount UFTextBlock
---@field TextAmount1 UFTextBlock
---@field TextItemDescription URichTextBox
---@field TextItemName UFTextBlock
---@field TextItemType UFTextBlock
---@field TextMarketPrice UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextUP UFTextBlock
---@field TextUnitPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketRemoveWinView = LuaClass(UIView, true)

function MarketRemoveWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnRemove = nil
	--self.EmptyTips = nil
	--self.HorizontalPrice = nil
	--self.MarketPurchaseWindowItem_UIBP = nil
	--self.PanelEmpty = nil
	--self.TableViewMarket = nil
	--self.TextA = nil
	--self.TextAftertaxIncome = nil
	--self.TextAmount = nil
	--self.TextAmount1 = nil
	--self.TextItemDescription = nil
	--self.TextItemName = nil
	--self.TextItemType = nil
	--self.TextMarketPrice = nil
	--self.TextQuantity = nil
	--self.TextUP = nil
	--self.TextUnitPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketRemoveWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnRemove)
	self:AddSubView(self.EmptyTips)
	self:AddSubView(self.MarketPurchaseWindowItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketRemoveWinView:OnInit()
	self.ReferencePriceTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMarket, nil, false)
	self.Binders = {
		{ "ItemTypeText", UIBinderSetText.New(self, self.TextItemType) },
		{ "ItemNameText", UIBinderSetText.New(self, self.TextItemName) },
		{ "ItemDescriptionText", UIBinderSetText.New(self, self.TextItemDescription) },
		{ "IncomeText", UIBinderSetTextFormatForMoney.New(self, self.TextAmount1) },                     -- 收益
		{ "AmountText", UIBinderSetTextFormatForMoney.New(self, self.TextAmount) },       --数量
		{ "UnitPriceText", UIBinderSetTextFormatForMoney.New(self, self.TextUnitPrice) },    --价格
		{ "ReferencePriceVMList", UIBinderUpdateBindableList.New(self, self.ReferencePriceTableViewAdapter) },

		{ "MarketPriceVisible", UIBinderSetIsVisible.New(self, self.PanelMarketPrice) },
		{ "EmptyTipsVisible", UIBinderSetIsVisible.New(self, self.PanelEmpty) },

	}
end

function MarketRemoveWinView:OnDestroy()

end

function MarketRemoveWinView:OnShow()
	if nil == self.Params then
		return
	end
	MarketRemoveWinVM:UpdateVM(self.Params)

	local Stall = self.Params.Stall
	if Stall == nil then
		return
	end
	local ResID = Stall.ResID
	MarketMgr:SendReferencePriceMessage(ResID)
	
end

function MarketRemoveWinView:OnHide()

end

function MarketRemoveWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRemove, self.OnClickedRemoveBtn)
end

function MarketRemoveWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MarketReferencePriceUpdata, self.OnReferencePriceUpdata)
end

function MarketRemoveWinView:OnRegisterBinder()
	if nil == self.Binders then return end
	self:RegisterBinders(MarketRemoveWinVM, self.Binders)
	self.MarketPurchaseWindowItem_UIBP:SetParams({Data = MarketRemoveWinVM.SellItemMV})

	self.Bg:SetTitleText(LSTR(1010088))

	self.EmptyTips:SetTipsContent(LSTR(1010069))
	self.TextQuantity:SetText(LSTR(1010071))
	self.TextMarketPrice:SetText(LSTR(1010072))
	self.TextUP:SetText(LSTR(1010075))
	self.TextA:SetText(LSTR(1010071))
	self.TextAftertaxIncome:SetText(LSTR(1010076))
	self.BtnRemove:SetText(LSTR(1010074))
	
end

function MarketRemoveWinView:OnReferencePriceUpdata(ReferencePrice)
	if self.Params == nil then
		return
	end
	local Stall = self.Params.Stall
	if Stall == nil then
		return
	end
	local ResID = Stall.ResID 
	if ResID == ReferencePrice.ResID then
		MarketRemoveWinVM:UpdateReferencePrice(ReferencePrice)
	end
end

function MarketRemoveWinView:OnClickedRemoveBtn()
	---请求下架
	local Stall = self.Params.Stall
	if Stall == nil then
		return
	end

	MarketMgr:SendCloseSaleItemMessage(Stall.SellID, Stall.ResID)
	self:Hide()
end

return MarketRemoveWinView