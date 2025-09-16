---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShopVM = require("Game/Shop/ShopVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ShopDefine = require("Game/Shop/ShopDefine")
local ShopMgr = require("Game/Shop/ShopMgr")
local EventID = require("Define/EventID")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local UIBinderCanvasSlotSetSize = require("Binder/UIBinderCanvasSlotSetSize")

---@class ShopSearchResultPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BorderLimitBg UBorder
---@field BorderSoldOut UBorder
---@field BtnBack CommBackBtnView
---@field BtnBuy Comm1BtnMView
---@field BtnInput CommSearchBarView
---@field CurrencyPage ShopCurrencyPageView
---@field ItemTipsContent ItemTipsContentView
---@field PanelItemTips UFCanvasPanel
---@field SearchPageCallBtn UFButton
---@field TableViewItems UTableView
---@field TextLimitContent UTextBlock
---@field TextSoldOut UTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopSearchResultPanelView = LuaClass(UIView, true)

function ShopSearchResultPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BorderLimitBg = nil
	--self.BorderSoldOut = nil
	--self.BtnBack = nil
	--self.BtnBuy = nil
	--self.BtnInput = nil
	--self.CurrencyPage = nil
	--self.ItemTipsContent = nil
	--self.PanelItemTips = nil
	--self.SearchPageCallBtn = nil
	--self.TableViewItems = nil
	--self.TextLimitContent = nil
	--self.TextSoldOut = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopSearchResultPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnInput)
	self:AddSubView(self.CurrencyPage)
	self:AddSubView(self.ItemTipsContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopSearchResultPanelView:OnInit()

    --self.BtnInput.StoreRecord = true

	self.TableViewItemsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItems, nil, true)

	self.Binders = {
		{"ShopName", UIBinderSetText.New(self, self.TextTitle)},
		{"CurShopItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewItemsAdapter)},
		{"IsCurrencyPageShow", UIBinderSetIsVisible.New(self, self.CurrencyPage)},
        {"IsRightItemTipsPanelShow", UIBinderSetIsVisible.New(self, self.PanelItemTips)},
		{"bBuy", UIBinderSetIsVisible.New(self, self.BtnBuy)},
        {"bBuy", UIBinderSetIsVisible.New(self, self.BorderLimitBg, true)},
        {"BuyBtnName", UIBinderSetText.New(self, self.BtnBuy.TextButton)},
		{"SearchInputLastRecord", UIBinderSetText.New(self, self.BtnInput)},
		{"CanNotContent", UIBinderSetText.New(self, self.TextLimitContent)},
        {"SearchBtnSize", UIBinderCanvasSlotSetSize.New(self, self.SearchPageCallBtn, true)}
	}
end

function ShopSearchResultPanelView:OnDestroy()

end

function ShopSearchResultPanelView:OnShow()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
	if ViewModel.bBuy then
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextLimitContent, ShopDefine.ShopTextColor.Red)
    else
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextLimitContent, ShopDefine.ShopTextColor.White)
    end
end

function ShopSearchResultPanelView:OnHide()
end

function ShopSearchResultPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.SearchPageCallBtn, self.OnSearchPageCallBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnBtnBuyClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnBtnBackClicked)
end

function ShopSearchResultPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateMallGoodsListMsg, self.UpdateMallGoodsListView)
end

function ShopSearchResultPanelView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

	self.CurrencyPage:SetParams({Data = ViewModel.CurrencyPageVM})
	self.ItemTipsContent:SetParams({ViewModel = ViewModel.RightItemTipsPanelVM, GetAccessOffset = ItemTipsUtil.GetAccessOffset[ItemDefine.ItemSource.Shop]})

	self:RegisterBinders(ViewModel, self.Binders)
end

--- 刷新商店计时器
function ShopSearchResultPanelView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function ShopSearchResultPanelView:OnTimer()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    ViewModel:UpdateShopItemListTimeLimitShow()
end

function ShopSearchResultPanelView:OnSearchPageCallBtnClicked()
    ShopVM:ShowShopSearchPagePanel()
end

function ShopSearchResultPanelView:OnBtnBuyClicked()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    ViewModel:ShowExchangeWinPanel()
end

function ShopSearchResultPanelView:OnBtnBackClicked()
	self:Hide()
end

function ShopSearchResultPanelView:UpdateMallGoodsListView()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
	local CurResultGoodsInfo = ShopMgr:FindAllItemsInSpecificShopByKeyWord(ViewModel.SearchInputLastRecord)
	ShopVM:UpdateShopSearchResultData(CurResultGoodsInfo)
	if ViewModel.bBuy then
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextLimitContent, ShopDefine.ShopTextColor.Red)
    else
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextLimitContent, ShopDefine.ShopTextColor.White)
    end
end

return ShopSearchResultPanelView