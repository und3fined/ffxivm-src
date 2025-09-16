---
--- Author: Administrator
--- DateTime: 2023-05-05 16:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MarketSellVM = require("Game/Market/VM/MarketSellVM")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local DepotVM = require("Game/Depot/DepotVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MarketMgr = require("Game/Market/MarketMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local BagMgr = require("Game/Bag/BagMgr")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MarketMainVM = require("Game/Market/VM/MarketMainVM")
local MarketStallItemVM = require("Game/Market/VM/MarketStallItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local AudioUtil = require("Utils/AudioUtil")
local BagDefine = require("Game/Bag/BagDefine")

local ContainerType = ProtoCommon.ContainerType
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
local DepotMgr = _G.DepotMgr
local EventID = _G.EventID
local MsgTipsUtil = _G.MsgTipsUtil
local EToggleButtonState = _G.UE.EToggleButtonState

---@class MarketSellPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnReceive CommBtnLView
---@field RichTextStalls URichTextBox
---@field TableViewItems UTableView
---@field TableViewStalls UTableView
---@field TextHint UFTextBlock
---@field TextIncome UFTextBlock
---@field TextTotalRevenue UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---@field AnimSum UWidgetAnimation
---@field AnimUpdateItem UWidgetAnimation
---@field CurveAnimSum CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketSellPageView = LuaClass(UIView, true)

function MarketSellPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnReceive = nil
	--self.RichTextStalls = nil
	--self.TableViewItems = nil
	--self.TableViewStalls = nil
	--self.TextHint = nil
	--self.TextIncome = nil
	--self.TextTotalRevenue = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--self.AnimSum = nil
	--self.AnimUpdateItem = nil
	--self.CurveAnimSum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketSellPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnReceive)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketSellPageView:OnInit()
	self.ViewModel = MarketSellVM.New()
	self.ItemTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItems)
	self.ItemTableViewAdapter:SetOnClickedCallback(self.OnItemSelectChanged)
	self.StallTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewStalls, self.OnStallSelectChanged, true)

	self.Binders = {
		{ "CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.ItemTableViewAdapter) },
		{ "StallsNum", UIBinderSetText.New(self, self.RichTextStalls) },

		{ "CurrentStallVMList", UIBinderUpdateBindableList.New(self, self.StallTableViewAdapter) },

		{ "BtnReceiveEnabled", UIBinderSetIsEnabled.New(self, self.BtnReceive, false, true) },
		{ "MoneyValue", UIBinderSetItemNumFormat.New(self, self.TextIncome) },
		{ "BtnAddVisible", UIBinderSetIsVisible.New(self, self.BtnAdd, false, true) },

	}
end

function MarketSellPageView:OnDestroy()

end

function MarketSellPageView:OnShow()
	MarketMainVM.SubTitleTextVisible = true
	MarketMainVM.ImgBgLineVisible = false
	self.ViewModel:SetItemTab()
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), self.ViewModel.TabIndex)
	self.VerIconTabs:ScrollIndexIntoView(self.ViewModel.TabIndex)
	self.ViewModel:UpdateItemListInfo()

	self.ViewModel:UpdateStallListInfo()
	MarketMgr:SendStallStatusMessage()
end

function MarketSellPageView:GetTabMenuList()
	local ItemTabs = {}
	if self.ViewModel:IsItemTab()  then
		for _, Value in ipairs(BagDefine.ItemTabs) do
			if Value.Type ~= ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK then
				table.insert(ItemTabs, Value)
			end
		end
	elseif self.ViewModel:IsEquipTab() then
		return BagDefine.EquipTabs
	end

	return ItemTabs
end

function MarketSellPageView:SeekJumoToSellItem(GID)
	if GID == nil then
		return
	end

	local SellItem = BagMgr:FindItem(self.GID)
	if SellItem ~= nil then
		local Params = {ItemData = SellItem,  ContainerIndex = ContainerType.CONTAINER_TYPE_BAG}
		UIViewMgr:ShowView(UIViewID.MarketOnSaleWin, Params)
	end

end


function MarketSellPageView:OnHide()
end

function MarketSellPageView:ResetData()
	self.ListData = nil
end

function MarketSellPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReceive.Button, self.OnClickedBtnReceive)
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickedBtnAdd)

	--UIUtil.AddOnClickedEvent(self, self.ButtonTrim, self.OnClickedTrimButton)
	--UIUtil.AddOnClickedEvent(self, self.BtnSwitchGoods, self.OnClickedTrimButton)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnSelectionChangedVerIconTabs)

	self.VerIconTabs:SetClickButtonSwitchCallback(self, self.OnClickedTrimButton)
end

function MarketSellPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MarketStallInfoUpdata, self.OnStallInfoUpdata)
	self:RegisterGameEvent(EventID.MarketReceiveMoney, self.OnMarketReceiveMoney)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnBagRefresh)

	self:RegisterGameEvent(EventID.MonthCardUpdate, self.OnMonthCardUpdate)

	self:RegisterGameEvent(EventID.MonthCardUIClose, self.OnMonthCardUIClose)
end

function MarketSellPageView:OnMonthCardUpdate()
	self.ViewModel:UpdateStallListInfo()
end

function MarketSellPageView:OnStallInfoUpdata()
	self.ViewModel:UpdateStallListInfo(MarketMgr.PlayAnimMonthCardUnlock)

	if MarketMgr.PlayAnimMonthCardUnlock == true then
		MarketMgr.PlayAnimMonthCardUnlock = nil
		self.StallTableViewAdapter:ScrollIndexIntoView(MarketMgr.FreeStallNum + 1)
		--self.StallTableViewAdapter:ScrollToBottom()
	end
end

function MarketSellPageView:OnMarketReceiveMoney()
	self.ViewModel:UpdateStallListInfo()
end

function MarketSellPageView:OnBagRefresh()
	self.ViewModel:UpdateItemListInfo()
end

function MarketSellPageView:SequenceEvent_AnimSum()
	
end

function MarketSellPageView:OnMonthCardUIClose()
	if MarketMgr.PlayAnimMonthCardUnlock == true then
		MarketMgr:SendStallStatusMessage()
	end
end

function MarketSellPageView:OnRegisterBinder()
	if nil == self.Binders then return end
	self:RegisterBinders(self.ViewModel, self.Binders)

	self.TextTotalRevenue:SetText(LSTR(1010089))
	self.TextHint:SetText(LSTR(1010091))
	self.BtnReceive:SetText(LSTR(1010090))
end

function MarketSellPageView:OnItemSelectChanged(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.IsValid == false then
		return
	end
	local ItemIndex = ContainerType.CONTAINER_TYPE_BAG
	local Params = {Item = ItemData.Item,  ContainerIndex = ItemIndex}

	UIViewMgr:ShowView(UIViewID.MarketOnSaleWin, Params)
end

function MarketSellPageView:OnStallSelectChanged(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end
	if ItemData.Status == MarketStallItemVM.StallStatus.Idle then
		MsgTipsUtil.ShowTips(LSTR(1010026))
		return
	end

	if ItemData.Status == MarketStallItemVM.StallStatus.Lock then
		self:OnClickedBtnAdd()
		return
	end
	
	if ItemData.Status == MarketStallItemVM.StallStatus.Occupancy then
		local Income = MarketMgr:GetStallIncomeNoTax(ItemData.StallItem)
		if Income > 0 then
			local CurGoldCount = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    		local MaxGoldCount = _G.ScoreMgr:GetScoreMaxValue(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    		if CurGoldCount + MarketMgr:GetStallIncome(ItemData.StallItem) > MaxGoldCount then
				MsgTipsUtil.ShowTips(LSTR(1010027))
       	 		return
    		end

			MarketMgr:SendGetBackMoneyMessage({{SellID = ItemData.StallItem.SellID, GetNum = Income}})
			return
		end

		if  ItemData.ExpiredSold == true then
			local Params = {Stall = ItemData.StallItem}
			UIViewMgr:ShowView(UIViewID.MarketOnSaleWin, Params)
			return
		end

		UIViewMgr:ShowView(UIViewID.MarketRemoveWin, {Stall = ItemData.StallItem})
		
	end

end


function MarketSellPageView:OnClickedBtnReceive()
	if self.ViewModel.BtnReceiveEnabled == false then
		MsgTipsUtil.ShowTips(LSTR(1010028))
		return
	end

	local TotalNum = 0
	local SellInfos = {}
	local StallItemList = MarketMgr.StallItemList or {}
	for _, V in ipairs(StallItemList) do
		local Income = MarketMgr:GetStallIncomeNoTax(V)
		if Income > 0 then
			table.insert(SellInfos, {SellID = V.SellID, GetNum = Income})
			TotalNum = TotalNum + MarketMgr:GetStallIncome(V)
		end
	end

	local CurGoldCount = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    local MaxGoldCount = _G.ScoreMgr:GetScoreMaxValue(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
    if CurGoldCount + TotalNum > MaxGoldCount then
		MsgTipsUtil.ShowTips(LSTR(1010027))
        return
    end
	local path = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/SYS/Play_SE_UI_gillfix.Play_SE_UI_gillfix'"
	AudioUtil.LoadAndPlay2DSound(path)
	self:PlayAnimSum()
	
	MarketMgr:SendGetBackMoneyMessage(SellInfos)
end

function MarketSellPageView:OnClickedBtnAdd()
	UIViewMgr:ShowView(UIViewID.MarketIncreaseWin)
end

function MarketSellPageView:PlayAnimSum()
	self:PlayAnimation(self.AnimSum)
end

function MarketSellPageView:OnClickedTrimButton()
	if self.ViewModel:IsItemTab()  then
		self.ViewModel:SetEquipTab()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Checked)
		
	elseif self.ViewModel:IsEquipTab() then
		self.ViewModel:SetItemTab()
		self.VerIconTabs:SetBtnSwitchCheckedState(EToggleButtonState.Unchecked)
	end
	self.VerIconTabs:UpdateItems(self:GetTabMenuList(), self.ViewModel.TabIndex)
	self.VerIconTabs:ScrollIndexIntoView(self.ViewModel.TabIndex)
end

function MarketSellPageView:OnSelectionChangedVerIconTabs(MenuIndex)
	self.ViewModel:SetTabIndex(MenuIndex)
	
	self.ItemTableViewAdapter:ScrollToTop()
end

return MarketSellPageView