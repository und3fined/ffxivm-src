---
--- Author: Administrator
--- DateTime: 2023-05-05 10:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


local MarketBuyVM = require("Game/Market/VM/MarketBuyVM")
local TradeMarketTypeInfoCfg = require("TableCfg/TradeMarketTypeInfoCfg")
local TradeMarketMainTypeCfg = require("TableCfg/TradeMarketMainTypeCfg")
local TradeMarketGoodsCfg = require("TableCfg/TradeMarketGoodsCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MarketMgr = require("Game/Market/MarketMgr")
local MarketDefine = require("Game/Market/MarketDefine")
local ProtoRes = require("Protocol/ProtoRes")
local MarketMainVM = require("Game/Market/VM/MarketMainVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local TipsUtil = require("Utils/TipsUtil")
local GlobalCfg = require("TableCfg/GlobalCfg")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local CommScreenerVM = require("Game/Common/Screener/CommScreenerVM")
local EventID = _G.EventID
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
local ShopMgr = _G.ShopMgr
local ClientVisionMgr =_G.ClientVisionMgr
---@class MarketBuyPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLast UFButton
---@field BtnLastDisable UFButton
---@field BtnNext UFButton
---@field BtnNextDisable UFButton
---@field BtnPage UFButton
---@field CommDropDownList1 CommDropDownListView
---@field CommDropDownList2 CommDropDownListView
---@field CommSearchBtn CommSearchBtnView
---@field MarketEmptyPanel MarketEmptyPanelView
---@field NewScreener UFHorizontalBox
---@field PanelPageSwitch UFCanvasPanel
---@field PanelSearchHistory UFCanvasPanel
---@field SearchBar CommSearchBarView
---@field TableViewCommodity UTableView
---@field TableViewHistory UTableView
---@field TableView_60 UTableView
---@field TextEmpty UFTextBlock
---@field TextFollow UFTextBlock
---@field TextHistory UFTextBlock
---@field TextPage UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimChangeSubTab UWidgetAnimation
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimPageSwitch UWidgetAnimation
---@field AnimSearch UWidgetAnimation
---@field AnimSearchCancel UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketBuyPageView = LuaClass(UIView, true)

function MarketBuyPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLast = nil
	--self.BtnLastDisable = nil
	--self.BtnNext = nil
	--self.BtnNextDisable = nil
	--self.BtnPage = nil
	--self.CommDropDownList1 = nil
	--self.CommDropDownList2 = nil
	--self.CommSearchBtn = nil
	--self.MarketEmptyPanel = nil
	--self.NewScreener = nil
	--self.PanelPageSwitch = nil
	--self.PanelSearchHistory = nil
	--self.SearchBar = nil
	--self.TableViewCommodity = nil
	--self.TableViewHistory = nil
	--self.TableView_60 = nil
	--self.TextEmpty = nil
	--self.TextFollow = nil
	--self.TextHistory = nil
	--self.TextPage = nil
	--self.VerIconTabs = nil
	--self.AnimChangeSubTab = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--self.AnimPageSwitch = nil
	--self.AnimSearch = nil
	--self.AnimSearchCancel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketBuyPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommDropDownList1)
	self:AddSubView(self.CommDropDownList2)
	self:AddSubView(self.CommSearchBtn)
	self:AddSubView(self.MarketEmptyPanel)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketBuyPageView:OnInit()
	self.ViewModel = MarketBuyVM.New()
	self.SubTypeTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_60, self.OnSubTabSelectChanged, true)
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCommodity, self.OnCommoditySelectChanged, true)

	self.PageIndex = 1
	self.PageMax = 1

	self.Binders = {
		{ "SubTabVMList", UIBinderUpdateBindableList.New(self, self.SubTypeTableViewAdapter) },
		{ "GoodsItemListVMList", UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
		
		{ "MarketEmptyVisible", UIBinderSetIsVisible.New(self, self.MarketEmptyPanel) },
		--{ "ConcernEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelConcernEmpty) },
		{ "FavorText", UIBinderSetText.New(self, self.TextFollow) },

		{ "PageText", UIBinderSetText.New(self, self.TextPage) },
		{ "PageLastVisible", UIBinderSetIsVisible.New(self, self.BtnLast, false, true) },
		{ "PageLastDisableVisible", UIBinderSetIsVisible.New(self, self.BtnLastDisable, false, true) },
		{ "PageNextVisible", UIBinderSetIsVisible.New(self, self.BtnNext, false, true) },
		{ "PageNextDisableVisible", UIBinderSetIsVisible.New(self, self.BtnNextDisable, false, true) },
		{ "PageSwitchVisible", UIBinderSetIsVisible.New(self, self.PanelPageSwitch) },

		{ "SearchHistoryVisible", UIBinderSetIsVisible.New(self, self.PanelSearchHistory) },
		--{ "SearchEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelSearchEmpty) },
		{ "NewScreenerVisible", UIBinderSetIsVisible.New(self, self.NewScreener) },
		{ "CommDropDownVisible", UIBinderSetIsVisible.New(self, self.CommDropDownList2) },
		{ "SearchBarVisible", UIBinderSetIsVisible.New(self, self.SearchBar) },
	
	}
end

function MarketBuyPageView:OnDestroy()

end

function MarketBuyPageView:OnShow()
	MarketMainVM.SubTitleTextVisible = true
	if self.Tabs == nil then
		self.Tabs = {}
		local AllCfg = TradeMarketMainTypeCfg:FindAllCfg()
		table.sort(AllCfg, function(A, B) return A.Order < B.Order end)
		for _, V in pairs(AllCfg) do
			if V.MainType > 0 then
				table.insert(self.Tabs, {Key = V.Order, MainType = V.MainType, IconPath = V.IconPath, SelectIcon = V.SelectIcon, MainTypeName = V.MainTypeName })
			end
		end
	end
	self.VerIconTabs:UpdateItems(self.Tabs)
	self.VerIconTabs.AdapterTabs:SetAlwaysNotifySelectChanged(true)
	if self.MainType ~= nil then
		local Cfg = TradeMarketMainTypeCfg:FindCfgByKey(self.MainType)
		if Cfg ~= nil then
			self.VerIconTabs:SetSelectedIndex(Cfg.Order)
			MarketMainVM.SubTitleText = self.Tabs[Cfg.Order].MainTypeName
		end
	end

	self.SearchBar:SetText('')
	self.SearchBar:SetHintText(LSTR(1010041))
	self.CommDropDownList1:SetForceTrigger(true)
	self.CommDropDownList2:SetForceTrigger(true)
end

function MarketBuyPageView:ResetTabIndex()
	self.OpenDefaultTab = true
	self.VerIconTabs:SetSelectedIndex(1)
end

function MarketBuyPageView:ResetData()
	self.MainType = nil
end

function MarketBuyPageView:SeekJumoToBuyItem(ItemID)
	if ItemID == nil then
		return
	end
	local Cfg = TradeMarketGoodsCfg:FindCfgByKey(ItemID)
	if Cfg == nil then
		return
	end

	self:SetSeletedByMainTypeAndSubType(Cfg.MainType, Cfg.SubType, ItemID)
end

function MarketBuyPageView:SetSeletedByMainTypeAndSubType(MainType, SubType, ItemID)
	local MainTypeCfg = TradeMarketMainTypeCfg:FindCfgByKey(MainType)
	if MainTypeCfg == nil then
		return
	end
	local CfgSearchCond = string.format("MainType == %d and SubType == %d", MainType, SubType)
	local AllCfg = TradeMarketTypeInfoCfg:FindAllCfg(CfgSearchCond)
	if AllCfg ~= nil and #AllCfg > 0 then
		--定位选中的筛选器Index
		self:SetScreenerIndex(AllCfg[1].Screener, ItemID)
		self.ViewModel.JumpSubTypeIndex = AllCfg[1].ShowID
		self.VerIconTabs:SetSelectedIndex(MainTypeCfg.Order)
	end

end

function MarketBuyPageView:SearchCond(Date1, Date2, Index1, Index2)
    local SearchCond = {}
    if Date1 ~= nil and Index1 ~= nil then
        local DropDownSearchCond = CommScreenerVM:GetScreenerSearchCond(Date1[Index1])
        if DropDownSearchCond ~= nil then
            table.insert(SearchCond, DropDownSearchCond)	
        end
    end
    
    if Date2 ~= nil and Index2 ~= nil then
        local DropDownSearchCond = CommScreenerVM:GetScreenerSearchCond(Date2[Index2])
        if DropDownSearchCond ~= nil then
            table.insert(SearchCond, DropDownSearchCond)	
        end
    end

    return SearchCond
end

function MarketBuyPageView:SetScreenerIndex(Screener, ItemID)
	if Screener == nil or #Screener < 1 then
		return
	end
	if ItemID == nil then
		return
	end
	local Date1 = self.ViewModel:GetScreenListByScreenerID(Screener[1] or 0) or {}
	local Date2 = self.ViewModel:GetScreenListByScreenerID(Screener[2] or 0) or {}
	local i = 1 
	repeat
		local j = 1
		repeat
			local SearchCond = self:SearchCond(Date1, Date2, i, j)
			if #SearchCond > 0 then
        		table.concat(SearchCond, " AND ", 1, #SearchCond)
        		local ScreenerList = ItemCfg:FindAllCfg(table.concat(SearchCond, " AND ", 1, #SearchCond))
	
				for k = 1, #ScreenerList do
					local ScreenerData = ScreenerList[k]
					if ScreenerData.ItemID == ItemID then
						self.ViewModel.JumpDropDown1Index = i
						self.ViewModel.JumpDropDown2Index = j
						self.ViewModel.JumpItemID = ItemID
						return
					end
				end
			end
			j = j +1
		until j >#Date2
		i = i + 1
	until i >#Date1

end


function MarketBuyPageView:OnHide()
	UIViewMgr:HideView(UIViewID.CommMiniKeypadWin)
end

function MarketBuyPageView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnTabItemSelectChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnLast, self.OnClickedLastBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnNext, self.OnClickedNextBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnLastdisable, self.OnClickedLastBtnDisable)
	UIUtil.AddOnClickedEvent(self, self.BtnNextDisable, self.OnClickedNextBtnDisable)

	UIUtil.AddOnClickedEvent(self, self.BtnPage, self.OnBtnPageValueClick)

	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDownList1, self.OnFilter1SelectedChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDownList2, self.OnFilter2SelectedChanged)

	UIUtil.AddOnClickedEvent(self, self.CommSearchBtn.BtnSearch, self.OnClickedCommSearchBtn)
	self.SearchBar:SetCallback(self, self.OnChangeCallback, self.OnSearchInputFinish, self.OnCancelSearchClicked)
	self.SearchBar.BtnCancelAlwaysVisible = true
end


function MarketBuyPageView:SetSkinAniCallback(TargetView, TargetCallback)
    self.CallbackView = TargetView
    self.ClickCallback = TargetCallback
end

function MarketBuyPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MarketTypeQueryGoods, self.OnRefreshCurPage)
	self:RegisterGameEvent(EventID.MarketRefreshBuyPage, self.OnRefreshBuyPage)

	self:RegisterGameEvent(EventID.MarketRefreshConcernInfo, self.OnRefreshConcernInfo)

	self:RegisterGameEvent(EventID.MarketRefreshStallBriefList, self.OnMarketRefreshStallBriefList)
end

function MarketBuyPageView:OnRegisterBinder()
	if nil == self.Binders then return end
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.TextHistory:SetText(LSTR(1010048))
	self.TextEmpty:SetText(LSTR(1010049))

	--self.PanelSearchEmpty:SetTipsContent(LSTR(1010050))
	--self.PanelConcernEmpty:SetTipsContent(LSTR(1010051))
end

function MarketBuyPageView:OnTabItemSelectChanged(Index)
	if self.Searching == true then
		self:QuitSearch()
		self.MainType = nil
	end
	if self.MainType == self.Tabs[Index].MainType then
		return
	end
	self:PlayAnimation(self.AnimChangeTab)

	self.MainType = self.Tabs[Index].MainType
	MarketMainVM.SubTitleText = self.Tabs[Index].MainTypeName
	self:SetSubTabList(self.MainType)
end

function MarketBuyPageView:SetSubTabList(MainType)
	local CfgSearchCond = string.format("MainType == %d ", MainType)
	local AllCfg = TradeMarketTypeInfoCfg:FindAllCfg(CfgSearchCond)
	table.sort(AllCfg, function(A, B) return A.ShowID < B.ShowID end)

	if MainType == ProtoRes.TradeMainType.TRADE_CONCERN_TYPE then
		local ConcernSubTab = {}
		for _, V in pairs(AllCfg) do
			local ConcernList = MarketMgr:GetConcernGoodsByType(V.SubType)
			if #ConcernList > 0 then
				table.insert(ConcernSubTab, V)
			end
		end

		self.ViewModel:UpdateSubTab(ConcernSubTab)
		self.ViewModel.MarketEmptyVisible = #ConcernSubTab == 0
		--首次开启时 没有关注列表则 默认显示装备列
		if #ConcernSubTab > 0 then
			self.SubTypeTableViewAdapter:SetSelectedIndex(1)
		else
			if self.OpenDefaultTab == true then
				self.OpenDefaultTab = false
				self.VerIconTabs:SetSelectedIndex(2)
			else
				self.ViewModel:SetSubPanelInfo(MainType)
				self.ViewModel.PageSwitchVisible = false
				MarketMgr.GoodsList = {}
				self.ViewModel:UpdateGoodsList({})
				self.MarketEmptyPanel:SetConcernEmpty()
			end
		end
	else
		self.MarketEmptyPanel:SetSearchEmpty(_G.LSTR(1010106))
		self.ViewModel:UpdateSubTab(AllCfg)

		local SubTypeIndex = 1
		if self.ViewModel.JumpSubTypeIndex then
			SubTypeIndex = self.ViewModel.JumpSubTypeIndex
			self.ViewModel.JumpSubTypeIndex = nil
		end
		self.SubTypeTableViewAdapter:SetSelectedIndex(SubTypeIndex)
	end

	if(self.ClickCallback ~= nil and self.CallbackView ~= nil) then
        self.ClickCallback(self.CallbackView, self.ViewModel.MarketEmptyVisible == true)
    end
end

function MarketBuyPageView:OnSubTabSelectChanged(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	if self.Searching == true then
		self.SubType = ItemData.SubTabData.SubType
		self:OnCancelSearchClicked()
		return
	end
	self:PlayAnimation(self.AnimChangeSubTab)
	self.ViewModel:SetSubTabIndex(ItemData.SubTabData.ShowID)
	self:SetSubPanelBySubType(ItemData.SubTabData)
end

function MarketBuyPageView:SetSubPanelBySubType(SubTabData)
	self.SubType = SubTabData.SubType
	self.PageIndex = 1
	self.ViewModel:SetSubPanelInfo(self.MainType, SubTabData)
	self:SetCommDropDownList1Item()
	self:SetCommDropDownList2Item()
	self:OnScreenerAction()
end


function MarketBuyPageView:SetCommDropDownList2Item()
	if self.ViewModel.SubTabData == nil or self.ViewModel.SubTabData.Screener == nil or #self.ViewModel.SubTabData.Screener < 2 then
		return
	end

	local DefaultIdex = 1
	local CurFind = false 
	local ScreenerList = self.ViewModel.DropDown2Date
	if self.ViewModel.SubTabData.ScreenerValue then
		DefaultIdex, CurFind = self:GetDropDownDefaultIndex(self.ViewModel.SubTabData.ScreenerValue[2], ScreenerList)
	end

	self.ViewModel.DropDown2Index = DefaultIdex

	if self.ViewModel.JumpDropDown2Index then
		self.ViewModel.DropDown2Index  = self.ViewModel.JumpDropDown2Index
		self.ViewModel.JumpDropDown2Index = nil
	end

	local ListData = {}
	local ListLen = #ScreenerList
	for i = 1, ListLen do
		if DefaultIdex == i and CurFind == true then
			table.insert(ListData, {Name = ScreenerList[i].ScreenerName .. LSTR(1010097)})
		else
			table.insert(ListData, {Name = ScreenerList[i].ScreenerName})
		end

	end

	self.CommDropDownList2:UpdateItems(ListData, self.ViewModel.DropDown2Index)
end

function MarketBuyPageView:SetCommDropDownList1Item()
	if self.ViewModel.SubTabData == nil or self.ViewModel.SubTabData.Screener == nil or #self.ViewModel.SubTabData.Screener < 1 then
		return
	end

	local DefaultIdex = 1
	local CurFind = false 
	local ScreenerList = self.ViewModel.DropDown1Date
	if self.ViewModel.SubTabData.ScreenerValue then
		DefaultIdex, CurFind = self:GetDropDownDefaultIndex(self.ViewModel.SubTabData.ScreenerValue[1], ScreenerList)
	end
	
	self.ViewModel.DropDown1Index = DefaultIdex

	if self.ViewModel.JumpDropDown1Index then
		self.ViewModel.DropDown1Index  = self.ViewModel.JumpDropDown1Index
		self.ViewModel.JumpDropDown1Index = nil
	end

	local ListData = {}
	local ListLen = #ScreenerList
	for i = 1, ListLen do
		if DefaultIdex == i and CurFind == true then
			table.insert(ListData, {Name = ScreenerList[i].ScreenerName .. LSTR(1010097)})
		else
			table.insert(ListData, {Name = ScreenerList[i].ScreenerName})
		end

	end

	self.CommDropDownList1:UpdateItems(ListData, self.ViewModel.DropDown1Index)
end

function MarketBuyPageView:GetDropDownDefaultIndex(ScreenerTypeValue, ScreenerList)
    if ScreenerTypeValue == nil then
        return 1, false
    end
    
	local ListLen = #ScreenerList
    if ScreenerTypeValue == ProtoRes.ScreeerTypeValue.DEFAULT_JOB_TYPE then
		local MajorProfID = MajorUtil.GetMajorProfID()
		local Cfg = RoleInitCfg:FindCfgByKey(MajorProfID)
		for i = 1, ListLen do
			if string.find(ScreenerList[i].ScreenerName, Cfg.ProfName) then
				return i, true
			end
		end
    end
	return 1, false

end

function MarketBuyPageView:CacheAllGoodsItemList()
	local AllItemList = {}
	if self.MainType == ProtoRes.TradeMainType.TRADE_CONCERN_TYPE then
		AllItemList =  MarketMgr:GetConcernGoodsByType(self.SubType) 
	else
		if self.MainType == nil or self.SubType == nil then
			return AllItemList
		end
		local CfgSearchCond = string.format("MainType == %d AND SubType == %d AND Disabled == 0", self.MainType, self.SubType)
		local SearchItemList = TradeMarketGoodsCfg:FindAllCfg(CfgSearchCond)
		for i = 1, #SearchItemList do
			local SearchItemData = SearchItemList[i]
			if #AllItemList >= MarketDefine.TypeQueryCountMax then
				break
			end
			if SearchItemData ~= nil and ClientVisionMgr:CheckVersionByGlobalVersion(SearchItemData.OnVersion) then
				table.insert(AllItemList, SearchItemData.ResID)
			end
		end
	end

	self.PageMax = math.ceil(#AllItemList / MarketDefine.TypeQueryCountPerPage)
	if self.PageMax == 0 then
		self.PageMax = 1
	end

	return AllItemList
end

function MarketBuyPageView:CheckVersion(OnVersion)
	local CurVersion =  MarketMgr.CurVersion or GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION).Value
    local OnVersion = string.split(OnVersion, ".")
	return ShopMgr:CompareOnVersion(CurVersion, OnVersion)
end


function MarketBuyPageView:OnCommoditySelectChanged(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	self.ClickedView = ItemView
	MarketMgr:SendStallListMessage(ItemData.ResID, 0, MarketMgr.StallListOnePageNum*3 - 1, false)
	--[[if ItemData.CommodityItem.AllSellNum == 0 then
		_G.MsgTipsUtil.ShowTips(LSTR(1010042))
		ItemTipsUtil.ShowTipsByResID(ItemData.CommodityItem.ResID, ItemView)
		return
	end

	UIViewMgr:ShowView(UIViewID.MarketBuyWin, ItemData)]]--
end

function MarketBuyPageView:OnMarketRefreshStallBriefList(StallBriefInfo)
	if _G.UIViewMgr:IsViewVisible(UIViewID.MarketBuyWin) then
		return
	end
	if self.ClickedView == nil or self.ClickedView.Params == nil then
		return
	end
	if StallBriefInfo.Stalls and #StallBriefInfo.Stalls > 0 then
		UIViewMgr:ShowView(UIViewID.MarketBuyWin, self.ClickedView.Params.Data)
	else
		_G.MsgTipsUtil.ShowTips(LSTR(1010042))
		if self.ClickedView.Params.Data then
			ItemTipsUtil.ShowTipsByResID(self.ClickedView.Params.Data.ResID, self.ClickedView)
		end
		
	end

	self.ClickedView = nil

	if #self.AllItemList > 0 then
		MarketMgr:SendTypeQueryMessage(self.AllItemList)
	end
end

function MarketBuyPageView:OnClickedLastBtn()
	if self.PageIndex == 1 then
		return
	end
	--self:PlayAnimation(self.AnimPageSwitch)
	self.PageIndex = self.PageIndex - 1
	self.ViewModel:UpdatePageInfo(self.PageIndex, self.PageMax, self.PageIndex > 1, self.PageIndex < self.PageMax)
	MarketMgr:SendTypeQueryMessage(self.AllItemList)
end

function MarketBuyPageView:OnClickedLastBtnDisable()
	_G.MsgTipsUtil.ShowTips(LSTR(1010043))

end

function MarketBuyPageView:OnClickedNextBtnDisable()
	_G.MsgTipsUtil.ShowTips(LSTR(1010044))
end

function MarketBuyPageView:OnClickedNextBtn()
	if self.PageIndex == self.PageMax then
		return
	end
	--self:PlayAnimation(self.AnimPageSwitch)
	self.PageIndex = self.PageIndex + 1
	self.ViewModel:UpdatePageInfo(self.PageIndex, self.PageMax, self.PageIndex > 1, self.PageIndex < self.PageMax)
	MarketMgr:SendTypeQueryMessage(self.AllItemList)
end

function MarketBuyPageView:OnFilter1SelectedChanged(Index)
	if Index == self.ViewModel.DropDown1Index then
		return
	end
	self.ViewModel.DropDown1Index = Index
	self.CommDropDownList2:ResetDropDown()
	self.PageIndex = 1
	self:OnScreenerAction()
end

function MarketBuyPageView:OnFilter2SelectedChanged(Index)
	if Index == self.ViewModel.DropDown2Index then
		return
	end
	self.ViewModel.DropDown2Index = Index
	self.PageIndex = 1
	self:OnScreenerAction()
end

function MarketBuyPageView:OnScreenerAction()
	local SearchCond = self.ViewModel:SearchCondAndScreenerList()
	self.AllItemList = {}
	if #SearchCond > 0 then
        --table.concat(SearchCond, " AND ", 1, #SearchCond)
        local ScreenerList = ItemCfg:FindAllCfg(table.concat(SearchCond, " AND ", 1, #SearchCond))
		for i = 1, #ScreenerList do
			local ScreenerData = ScreenerList[i]
			if #self.AllItemList >= MarketDefine.TypeQueryCountMax then
				break
			end
			local Cfg = TradeMarketGoodsCfg:FindCfgByKey(ScreenerData.ItemID)
			if Cfg ~= nil and Cfg.MainType == self.MainType and Cfg.SubType == self.SubType and Cfg.Disabled == 0 and ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.OnVersion) then
				table.insert(self.AllItemList, Cfg.ResID)
			end
		end
		self.PageMax = math.ceil(#self.AllItemList / MarketDefine.TypeQueryCountPerPage)
		if self.PageMax == 0 then
			self.PageMax = 1
		end
	else
		self.AllItemList = self:CacheAllGoodsItemList()
	end

	self.ViewModel:UpdatePageInfo(self.PageIndex, self.PageMax, self.PageIndex > 1, self.PageIndex < self.PageMax)
	self.ViewModel.MarketEmptyVisible = #self.AllItemList == 0
	if #self.AllItemList > 0 then
		self.ViewModel.PageSwitchVisible = true
		MarketMgr:SendTypeQueryMessage(self.AllItemList)
	else
		self.ViewModel.PageSwitchVisible = false
		MarketMgr.GoodsList = {}
		self.ViewModel:UpdateGoodsList({})
	end
end

function MarketBuyPageView:OnBtnPageValueClick()
	local ConfirmCallback = function (ConfirmValue)
		--self:PlayAnimation(self.AnimPageSwitch)
		self.PageIndex = ConfirmValue
		self.ViewModel:UpdatePageInfo(self.PageIndex, self.PageMax, self.PageIndex > 1, self.PageIndex < self.PageMax)
		MarketMgr:SendTypeQueryMessage(self.AllItemList)
	end
	local ShowCallback = function (Value)
		self.PageIndex = Value
		self.ViewModel.PageText = string.format("%d/%d", Value, self.PageMax)
	end

	local Params = { CutValue = self.PageIndex, ConfirmCallback = ConfirmCallback , 
					ShowCallback = ShowCallback, LowerLimit = 1, UpperLimit = self.PageMax, }
	local View = UIViewMgr:ShowView(UIViewID.CommMiniKeypadWin, Params)
	local PageMax = self.PageMax
	local InputUpperLimit = 9
	while PageMax > 0 do
        PageMax = math.floor(PageMax / 10)
        InputUpperLimit = InputUpperLimit*10 + 9
    end
	View.InputUpperLimit = InputUpperLimit
	local KetpadSize = UIUtil.CanvasSlotGetSize(View.FCanvasPanel_3)
	local BtnSize = UIUtil.GetWidgetSize(self.PanelPageSwitch)
	local InOffset = _G.UE.FVector2D(-BtnSize.X - KetpadSize.X - 20, -KetpadSize.Y + 100)
	TipsUtil.AdjustTipsPosition(View.FCanvasPanel_3, self.PanelPageSwitch, InOffset, _G.UE.FVector2D(0, 0))

end

function MarketBuyPageView:OnRefreshBuyPage()
	if #self.AllItemList > 0 then
		MarketMgr:SendTypeQueryMessage(self.AllItemList)
	end
end

function MarketBuyPageView:OnRefreshCurPage()
	local GoodsList = {}
	if self.ViewModel.JumpItemID then
		for i = 1, #MarketMgr.GoodsList do
			if self.ViewModel.JumpItemID == MarketMgr.GoodsList[i].ResID then
				self.PageIndex = math.ceil(i / MarketDefine.TypeQueryCountPerPage)
				self.ViewModel:UpdatePageInfo(self.PageIndex, self.PageMax, self.PageIndex > 1, self.PageIndex < self.PageMax)
				self.ViewModel.JumpItemID = nil
				break
			end
		end
	end

	for i = 1, MarketDefine.TypeQueryCountPerPage do
		local ItemIdex =  (self.PageIndex - 1)*MarketDefine.TypeQueryCountPerPage + i
		if ItemIdex <= #MarketMgr.GoodsList then
			table.insert(GoodsList, MarketMgr.GoodsList[ItemIdex])
		else
			break
		end
	end

	self.ViewModel:UpdateGoodsList(GoodsList)
end

function MarketBuyPageView:OnRefreshConcernInfo()
	if self.MainType ~= ProtoRes.TradeMainType.TRADE_CONCERN_TYPE then
		self:OnRefreshBuyPage()
		return
	end
	self.MarketEmptyPanel:SetConcernEmpty()
	local CfgSearchCond = string.format("MainType == %d ", ProtoRes.TradeMainType.TRADE_CONCERN_TYPE)
	local AllCfg = TradeMarketTypeInfoCfg:FindAllCfg(CfgSearchCond)
	table.sort(AllCfg, function(A, B) return A.ShowID < B.ShowID end)

	local SelectedIndex = 1
	local Index = 0
	local ConcernSubTab = {}
	local PageIndex = 1
	for _, V in pairs(AllCfg) do
		local ConcernList = MarketMgr:GetConcernGoodsByType(V.SubType)
		local Num = #ConcernList
		if Num > 0 then
			table.insert(ConcernSubTab, V)
			Index = Index + 1
			if V.SubType == self.SubType then
				SelectedIndex = Index
				if Num > (self.PageIndex - 1)*MarketDefine.TypeQueryCountPerPage then
					PageIndex = self.PageIndex 
				end
			end
		end
	end

	self.ViewModel:UpdateSubTab(ConcernSubTab)
	self.ViewModel.MarketEmptyVisible = #ConcernSubTab == 0
	if #ConcernSubTab > 0 then
		self.SubTypeTableViewAdapter:SetSelectedIndex(SelectedIndex)
	else
		self.ViewModel:SetSubPanelInfo(ProtoRes.TradeMainType.TRADE_CONCERN_TYPE)
		self.ViewModel.PageSwitchVisible = false
		MarketMgr.GoodsList = {}
		self.ViewModel:UpdateGoodsList({})
	end

	if PageIndex > 1 then
		self.PageIndex = PageIndex
		self.ViewModel:UpdatePageInfo(self.PageIndex, self.PageMax, self.PageIndex > 1, self.PageIndex < self.PageMax)
		self:OnRefreshBuyPage()
	end
	
end

function MarketBuyPageView:OnClickedCommSearchBtn()
	self.ViewModel:EnterSearch()
	self.SearchBar:SetFocus()
	self.SearchBar:SetText('')
	self.SearchBar:SetHintText(LSTR(1010041))
	self.Searching = true
end

function MarketBuyPageView:OnChangeCallback(Text)
	self.Searching = true
end

function MarketBuyPageView:OnSearchInputFinish(SearchText)
	if string.isnilorempty(SearchText) then
		return
	end
	self:PlayAnimation(self.AnimSearch)
	MarketMainVM.SubTitleTextVisible = false
	self.VerIconTabs:SetSelectedIndex(nil)
	self.ViewModel:SetSubTabIndex(nil)
	self.Searching = true


	--local CfgSearchCond = "Disabled == 0 AND ItemName LIKE "..SearchText.."%"
	--self.AllItemList = TradeMarketGoodsCfg:FindAllCfg(CfgSearchCond) or {}
	local ScreenerList = TradeMarketGoodsCfg:FindAllCfg("Disabled == 0")
	self.AllItemList = {}
	for i = 1, #ScreenerList do
		if #self.AllItemList >= MarketDefine.TypeQueryCountMax then
			break
		end
		local Cfg = ScreenerList[i]
		if Cfg ~= nil then
			local ItemName = Cfg.ItemName or ""
			local Pattern = "^"..SearchText
			local bValid = ItemName == SearchText or string.match(ItemName, Pattern) ~= nil
			if bValid == true and ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.OnVersion) then
				table.insert(self.AllItemList, Cfg.ResID)
			end
		end
	end

	local Len = #self.AllItemList
	self.PageMax = math.ceil(Len / MarketDefine.TypeQueryCountPerPage)
	if self.PageMax == 0 then
		self.PageMax = 1
	end

	self.PageIndex = 1
	self.ViewModel:UpdatePageInfo(self.PageIndex, self.PageMax, self.PageIndex > 1, self.PageIndex < self.PageMax)

	if Len > 0 then
		MarketMgr:SendTypeQueryMessage(self.AllItemList)
	else
		MarketMgr.GoodsList = {}
		self.ViewModel:UpdateGoodsList({})
	end

	self.MarketEmptyPanel:SetSearchEmpty(_G.LSTR(1010050))
	self.ViewModel.MarketEmptyVisible = Len == 0
	self.ViewModel.PageSwitchVisible = Len > 0
	
    self.ViewModel.FavorText = ""
	
	if(self.ClickCallback ~= nil and self.CallbackView ~= nil) then
        self.ClickCallback(self.CallbackView, self.ViewModel.MarketEmptyVisible == true)
    end
end

function MarketBuyPageView:OnCancelSearchClicked()
	--self:PlayAnimation(self.AnimSearchCancel)
	MarketMainVM.SubTitleTextVisible = true
	self.Searching = false
	self.SearchBar:SetText('')
	self.SearchBar:SetHintText(LSTR(1010041))
	if self.MainType == ProtoRes.TradeMainType.TRADE_CONCERN_TYPE and MarketMgr:GetConcernGoodsNum() <= 0 then
		self.MainType = nil
		self.VerIconTabs:SetSelectedIndex(1)
		self.ViewModel.PageSwitchVisible = false
	else
		self.ViewModel.PageSwitchVisible = true
		local MainType = self.MainType
		local SubType = self.SubType
		self.MainType = nil 
		self.SubType = nil
		self:SetSeletedByMainTypeAndSubType(MainType, SubType)

	end
end

function MarketBuyPageView:QuitSearch()
	--self:PlayAnimation(self.AnimSearchCancel)
	MarketMainVM.SubTitleTextVisible = true
	self.ViewModel.PageSwitchVisible = true
	self.SearchBar:SetText('')
	self.SearchBar:SetHintText(LSTR(1010041))
	self.Searching = false
end

return MarketBuyPageView