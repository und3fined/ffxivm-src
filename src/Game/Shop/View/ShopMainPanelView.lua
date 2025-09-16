---
--- Author: Administrator
--- DateTime: 2023-10-19 11:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShopMainPanelView = LuaClass(UIView, true)
local ShopMgr = require("Game/Shop/ShopMgr")
local UIViewMgr = require("UI/UIViewMgr")
local ShopMainPanelVM = require("Game/Shop/ShopMainPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local CommScreenerVM = require("Game/Common/Screener/CommScreenerVM")
local MallMainTypeCfg = require("TableCfg/MallsMainTypeCfg")
local MallCfg = require("TableCfg/MallCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local EventMgr = require("Event/EventMgr")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ShopDefine = require("Game/Shop/ShopDefine")
local CounterCfg = require("TableCfg/CounterCfg")
local LegendaryWeaponMallID = 4001


local UIViewID = _G.UIViewID

local GoodsPriceType = {
	[ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE] = "积分",
	[ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_ITEM] = "物品",
}

local DropDown_Enable_TableView_Pos = _G.UE4.FVector2D(-541, -403)
local DropDown_Disable_TableView_Pos = _G.UE4.FVector2D(-541, -324)

---@class ShopMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BGPanel UFCanvasPanel
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommSearchBar CommSearchBarView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field DropDownList ShopDropDownListItemNewView
---@field ImgTitle UFImage
---@field MarketEmptyPanel MarketEmptyPanelView
---@field MoneySlot1 CommMoneySlotView
---@field MoneySlot2 CommMoneySlotView
---@field MoneySlot3 CommMoneySlotView
---@field PanelTitle UFCanvasPanel
---@field TabList ShopTabListItemView
---@field TableViewList UTableView
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---@field Text3 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimItemIn UWidgetAnimation
---@field AnimItemOut UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY

function ShopMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BGPanel = nil
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.CommBackpackEmpty = nil
	--self.CommSearchBar = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonTitle = nil
	--self.DropDownList = nil
	--self.ImgTitle = nil
	--self.MarketEmptyPanel = nil
	--self.MoneySlot1 = nil
	--self.MoneySlot2 = nil
	--self.MoneySlot3 = nil
	--self.PanelTitle = nil
	--self.TabList = nil
	--self.TableViewList = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.Text3 = nil
	--self.AnimIn = nil
	--self.AnimItemIn = nil
	--self.AnimItemOut = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommSearchBar)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.MarketEmptyPanel)
	self:AddSubView(self.MoneySlot1)
	self:AddSubView(self.MoneySlot2)
	self:AddSubView(self.MoneySlot3)
	self:AddSubView(self.TabList)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY~
end

function ShopMainPanelView:OnInit()
	self.ViewModel = ShopMainPanelVM.New()
	self.PriceViewList = {self.MoneySlot1, self.MoneySlot2, self.MoneySlot3}
	self.TabInfoList = {}
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChanged, true)
	self.CommSearchBar:SetCallback(self, nil, self.OnSearchCommit, self.OnCancelSearchClicked)
	self.ViewModel.EmptyView = self.MarketEmptyPanel

	self.Binders = {
		{ "CurGoodsList", UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
		{ "EmptyVisible", UIBinderSetIsVisible.New(self, self.MarketEmptyPanel) },
		{ "GoodsListVisible", UIBinderSetIsVisible.New(self, self.GoodsTableViewAdapter, nil, true) },
	}

	self.LastChosedList = {}
	self.CurTabItemData = nil
end

function ShopMainPanelView:OnDestroy()

end

function ShopMainPanelView:OnShow()
	self.CommSearchBar:SetHintText(LSTR(1200097))	--- 搜索商品
	if self.MarketEmptyPanel ~= nil and self.MarketEmptyPanel.PanelSearchEmpty ~= nil then
		self.MarketEmptyPanel.PanelSearchEmpty.IsBrightText = true
	end
	self.MarketEmptyPanel:SetSearchEmpty()
	self.ShopId = self.Params.ShopId
	self.CurIndex = 0
	local EnableSearch = ShopMgr.AllShopInfo[self.ShopId].EnableSearch
	if EnableSearch ~= 1 then
		UIUtil.SetIsVisible(self.CommSearchBar, false, true)
	else
		UIUtil.SetIsVisible(self.CommSearchBar, true, true)
	end
	local Open = self.Params.Open
	self.TabInfoList = ShopMgr:GetTabListByShopID(self.ShopId)
	ShopMgr.CurOpenTabInfo = self.TabInfoList
	self.TabList:UpdateItems(self.TabInfoList)
	self:SetBackBtnState(Open)
	self:InitViewInfo(self.ShopId)
	UIUtil.SetIsVisible(self.MarketEmptyPanel, false)
	self:PlayAnimation(self.AnimItemIn)
	if ShopMgr.IsJumpAgain then
		self:CheckJumpAgainState(self.ShopId)
	end
	--self.TabList:SetSelectedIndex(3)
	UIUtil.SetIsVisible(self.PanelTitle, false)
end

function ShopMainPanelView:InitViewInfo(ShopId)
	local ShopMainTypeOpenList = ShopMgr.ShopMainTypeOpenList
	local Index = 1
	if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
		Index = ShopMgr:GetJumpType()
	else
		Index = ShopMainTypeOpenList[ShopId] or 1
	end
	local ShopName = ShopMgr.AllShopInfo[ShopId].Name--MallCfg:FindCfgByKey(ShopId).Name
	if Index == nil then
		Index = 1
	end

	self.CommonTitle:SetSubTitleIsVisible(false)
	self.CommonTitle:SetCommInforBtnIsVisible(false)
	self.CommonTitle.TextTitleName:SetText(ShopName)
	--self.TabList:SetSelectedIndex(Index)
	self:UpdatePrice(self.TabInfoList)
end

function ShopMainPanelView:UpdateFilter(FirstType ,GoodList)
	local Data = {}
	Data.ShopID = self.ShopId
	Data.FirstType = FirstType
	self.DropDownList:UpdateListInfo(Data, GoodList, self.FilterInfo)
end

function ShopMainPanelView:UpdatePrice(List)
	local MianTypeIndex = 1
	if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
		MianTypeIndex = ShopMgr:GetJumpType()
	else
		MianTypeIndex = ShopMgr.FirstTypeIndex or 1
	end
	local PriceList = {}

	if next(List) == nil then	
		FLOG_ERROR("UpdatePrice Tab List Nil ")
		return
	end

	if List[MianTypeIndex] then
		PriceList = List[MianTypeIndex]
	else
		FLOG_WARNING("UpdatePrice Tab List Nil MianTypeIndex = %d", MianTypeIndex)
		PriceList = List[1]
	end


	--FLOG_ERROR("Test tab price = %s",List[MianTypeIndex])
	for i = 1,3 do
		if PriceList and PriceList.Price[i] then
			local PriceType = PriceList.PriceType
			local IsScore = false
			local ScoreType = GoodsPriceType[ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE]
			if PriceType[i] == ScoreType then
				IsScore = true
			end
			UIUtil.SetIsVisible(self.PriceViewList[i], true)
				self.PriceViewList[i]:UpdateView(PriceList.Price[i], false, UIViewID.MarketExchangeWin, IsScore)
		else
			UIUtil.SetIsVisible(self.PriceViewList[i], false)
		end
	end
end

function ShopMainPanelView:SetBackBtnState(Open)
	UIUtil.SetIsVisible(self.BtnBack, Open == 1)
	UIUtil.SetIsVisible(self.BtnClose, Open ~= 1)
end

function ShopMainPanelView:OnHide()
	local Data = {}
	Data.ShopId = self.Params.ShopId
	Data.MainTypeIndex = ShopMgr.FirstTypeIndex
	ShopMgr.LastMallId = 0
	ShopMgr.CurFirstTypeFilterList = {}
	ShopMgr.CanChange = false
	ShopMgr.LashChosedIndexList[self.ShopId] = self.CurIndex
	ShopMgr:SetShopMainTypeOpenList(Data)
	self.DropDownList:SetIsInShopState(false)
	-- if ShopMgr.JumpToGoodsState then
	-- 	ShopMgr.JumpToGoodsState = false
	-- end
	ShopMgr.CurOpenShopType = nil
	ShopMgr.CurQueryShopID = nil
    --- 重复跳转的流程是 收到协议-关闭旧主界面-打开新主界面，如果关闭的时候清空ID,再打开会找不到数据
	if not ShopMgr.IsJumpAgain then
		ShopMgr.CurOpenMallId = nil
	end
	ShopMgr.CurOpenMallCounterID = 0
	self:StopAnimation(self.AnimItemIn)
	if #self.LastChosedList > 0 then
		ShopMgr:RemoveFirstTypeAllRed(self.LastChosedList)
	end
	ShopMgr.CurOpenTabInfo = {}
	self.bPendingGC = false
	ShopMgr.JumpToGoodsState = false
	ShopMgr:ClearFilterData()
	EventMgr:SendEvent(EventID.ShopPlayOutAni)
end

function ShopMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.TabList, self.UpdateShopTypeList)
	self.BtnBack:AddBackClick(self, function(e) e:OnCloseView() end)
	UIUtil.AddOnFocusLostEvent(self, self.CommSearchBar.TextInput, self.OnTextFocusLost)
end

function ShopMainPanelView:OnRegisterGameEvent() 
	self:RegisterGameEvent(EventID.UpdateMallGoodsListMsg, self.UpdateListByBuy)
	self:RegisterGameEvent(EventID.ScrollToSelectedGoods, self.ScrollToSelectedGoods)
	self:RegisterGameEvent(EventID.FilterGoods, self.FilterGoodsList)
	self:RegisterGameEvent(EventID.UpdateScore, self.OnUpdateItemValue)
	self:RegisterGameEvent(EventID.UpdateQuestTargetOwnItem, self.OnUpdateQuestTargetOwnItem)
	self:RegisterGameEvent(EventID.EquipUpdate, self.OnUpdateEquipUpIcon)
end

function ShopMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ShopMainPanelView:OnUpdateItemValue()
	local MianTypeIndex = ShopMgr.FirstTypeIndex
	local List = self.TabInfoList
	if List == nil or next(List) == nil then
		FLOG_ERROR("OnUpdateItemValue Tab List Nil")
		return
	end

	--FLOG_ERROR("Test tab price = %s",List[MianTypeIndex])
	if List[MianTypeIndex] == nil then
		FLOG_ERROR("price List Error")
		return
	end
	
	for i = 1,3 do
		if List[MianTypeIndex].Price ~= nil then
			if List[MianTypeIndex].Price[i] then
				local PriceType = List[MianTypeIndex].PriceType
				local ScoreType = GoodsPriceType[ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE]
				if PriceType[i] ~= ScoreType then
					self.PriceViewList[i]:UpdateView(List[MianTypeIndex].Price[i], false, UIViewID.MarketExchangeWin, false)
				end		
			end
		end
	end
end

function ShopMainPanelView:OnSearchCommit(Text)
	if Text == "" or Text == nil then
		return
	end
	self.IsSearch = true
	self.ViewModel:MatchGoodsInfo(Text)

	if self.TabList then
		self.TabList:CancelSelected()
	end
	
	self.DropDownList:SetAllFilterVisible(false)
	if self.FilterInfo then
		if self.FilterInfo.FilterNum >= 1 then
			UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Enable_TableView_Pos)
		else
			UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Disable_TableView_Pos)
		end
	else
		UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Enable_TableView_Pos)
	end

	self.GoodsTableViewAdapter:ScrollToTop()
end

function ShopMainPanelView:OnCancelSearchClicked(Index)
	self.IsSearch = false
	self.ViewModel:SetSearchState(true)
	self.ViewModel:RecoverGoodsList()
	self.TabList:SetSelectedIndex(Index or self.CurIndex)
	self.DropDownList:SetAllFilterVisible(true)
	if self.FilterInfo then
		if self.FilterInfo.FilterNum >= 1 then
			UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Disable_TableView_Pos)
		else
			UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Enable_TableView_Pos)
		end
	else
		UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Enable_TableView_Pos)
	end
end

function ShopMainPanelView:OnTextFocusLost()
	if self.IsSearch then
		UIUtil.SetIsVisible(self.CommSearchBar.BtnCancelNode, true, true)
	end
end

function ShopMainPanelView:UpdateShopTypeList(Index, ItemData)
	local _ <close> = CommonUtil.MakeProfileTag("UpdateShopTypeList")
	if self.IsSearch then
		self:OnCancelSearchClicked(Index)
		self.CommSearchBar:OnClickButtonCancel()
	end

	if self.CurIndex == Index then
		return
	end

	if self.CurIndex ~= 0 then  
		ShopMgr:RemoveTabRedDot(ItemData.FirstType)
	end

	if #self.LastChosedList > 0 then
		ShopMgr:RemoveFirstTypeAllRed(self.LastChosedList)
	end

	--跳转状态不改变
	-- if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
	-- 	return
	-- end
	self.CurTabItemData = ItemData
	self.CurIndex = Index
	ShopMgr.FirstTypeIndex = Index
	local ShopMainTypeIndex

	if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
		ShopMainTypeIndex = ShopMgr:GetJumpType()
	else
		ShopMainTypeIndex = ShopMgr.FirstTypeIndex or 1
	end

	if self.TabInfoList[ShopMainTypeIndex] == nil then
		FLOG_ERROR("self.TabInfoList[ShopMainTypeIndex] == nil Check")
		self.CurFirstType = self.TabInfoList[1].FirstType
	else
		self.CurFirstType = self.TabInfoList[ShopMainTypeIndex].FirstType
	end

	self.CurGoodsList = ShopMgr:GetGoodsByType(self.ShopId, self.CurFirstType)
	self.CurGoodsList.FirstType = self.CurFirstType
	self.DropDownList:SetState(false)
    self:UpdatePrice(self.TabInfoList)
	self.FilterInfo = self.TabInfoList[Index].FilterInfo
	self:UpdateGoodsList(true)
	self:UpdateFilter(self.CurFirstType, self.CurGoodsList)
	self.DropDownList:SetIsInShopState(true)
	self:CheckJumpState(self.CurGoodsList)
	self.LastChosedList = self.CurGoodsList
	-- 传奇武器商店限购取消 采用原商品限购
	--self:OnUpdateMallCounterLimitInfo(ItemData)
	-- 切页签GC，延迟1秒以避免频繁调用
	local function DoGC()
		_G.ObjectMgr:CollectGarbage(false)
		self.bPendingGC = false
	end
	if not self.bPendingGC then
		self:RegisterTimer(function() DoGC() end, 1)
		self.bPendingGC = true
	end
end

function ShopMainPanelView:FilterGoodsList(List)
	--FLOG_ERROR("TestFilterGoodsList = %s",table_to_string(List))
	local GoodsList
	local FliterList
	local FliterIndex = List.Info and List.Info.Index or 0
	if List.Index == 1 then
		FliterList = ShopMgr.CurFirstTypeFilterList[self.ShopId][self.CurFirstType][List.ScrId]
		if FliterIndex >= 1 and #FliterList[FliterIndex].GoodsList > 0 then
			GoodsList = FliterList[FliterIndex].GoodsList
		else
			GoodsList = ShopMgr.CurFirstTypeGoodsList
		end

		if ShopMgr.FilterAfterGoodsList then
			ShopMgr.FilterAfterGoodsList = GoodsList
		else
			ShopMgr.FilterAfterGoodsList = {}
			ShopMgr.FilterAfterGoodsList = GoodsList
		end

		if self.FilterInfo.FilterNum > 1 then
			self.DropDownList:UpdateSecondFilter(GoodsList)
		end
	else
		FliterList = ShopMgr.CurFirstTypeFilterList[self.ShopId][self.CurFirstType][List.ScrId]
		local SencondList

		if FliterIndex >= 1 and ShopMgr.AfterFistFilterList[FliterIndex] then
			SencondList = ShopMgr.AfterFistFilterList[FliterIndex].GoodsList
		else
			FLOG_WARNING("ShopMgr.AfterFistFilterList[FliterIndex] = nil")
			SencondList = FliterList[1].GoodsList
		end

		if FliterIndex and #FliterList[FliterIndex].GoodsList > 0 then
			GoodsList = ShopMgr:GetSecondFilterList(ShopMgr.FilterAfterGoodsList, SencondList)
		else
			GoodsList = ShopMgr.FilterAfterGoodsList
		end	
	end
	ShopMgr.CurFirstTypeGoodsList = GoodsList
    self.ViewModel:UpdateGoodsListInfo(GoodsList, false)
	self:PlayAnimation(self.AnimUpdateList)
	self.GoodsTableViewAdapter:ScrollToTop()
end

function ShopMainPanelView:UpdateGoodsList(IsPlayAni)
	local _ <close> = CommonUtil.MakeProfileTag("ShopUpdateGoodsList")
	local ShopMainTypeOpenList = ShopMgr.ShopMainTypeOpenList
	local Index = ShopMainTypeOpenList[self.ShopId]

	if Index == nil then
		Index = 1
	end
	--local CurOpenGoodList = ShopMgr.CurOpenShopGoodSList

	--ShopMgr.FirstTypeIndex = FirstType
	local GoodList = self.CurGoodsList--ShopMgr:GetGoodsByType(self.ShopId, FirstType)
	if GoodList == nil then
		return
	end
	
	local DropNum = self.FilterInfo.FilterNum
	self:OnUpdateTableListPos(DropNum >= 1)

	ShopMgr.FilterAfterGoodsList = GoodList
	self.ViewModel:UpdateGoodsListInfo(GoodList, false)

	if IsPlayAni then
		self:PlayAnimation(self.AnimUpdateList)
	end

	if ShopMgr.JumpToShop then
		ShopMgr.JumpToShop = false
	end
	--self.TurnPageBar:UpdatePage(GoodList)
end

function ShopMainPanelView:UpdateListByBuy()
	self.ViewModel:UpdateGoodsListInfo(ShopMgr.CurFirstTypeGoodsList, false)
	-- 传奇武器商店限购取消 采用原商品限购
	-- if self.CurTabItemData then
	-- 	self:OnUpdateMallCounterLimitInfo(self.CurTabItemData)
	-- end
end

function ShopMainPanelView:OnSelectChanged(Index, ItemData, ItemView)
	--FLOG_ERROR("GOODS INDEX = %d",Index)
	--传奇武器商店限购取消 采用原商品限购
	-- if ShopMgr.CurOpenMallCounterID and ShopMgr.CurOpenMallCounterID ~= 0 then
	-- 	if ShopMgr:CheckCurMallCounter() then
	-- 		_G.MsgTipsUtil.ShowTipsByID(157049)
	-- 		return
	-- 	end
	-- end
	if table.contain(ShopMgr.RedDotList, ItemData.GoodsId) then
		ShopMgr:RemoveRedDot(ItemData.GoodsId)
	end

	--点击最后一个红点商品时 清空Type红点
	local FirstTypeAllRed = ShopMgr.FirstTypeAllRed and ShopMgr.FirstTypeAllRed[self.CurFirstType]
	if FirstTypeAllRed then
		local NewList = {}
		if table.contain(FirstTypeAllRed, ItemData.GoodsId) then
			NewList = ShopMgr:RemoveFistTypeRedDot(self.CurFirstType, ItemData.GoodsId) or {}
		end

		if #NewList == 0 then
			ShopMgr:RemoveTabRedDot(self.CurFirstType)
		end
	end

	ShopMgr.CurQueryShopID = self.ShopId
	UIViewMgr:ShowView(UIViewID.ShopBuyPropsWinView, ItemData)
end

function ShopMainPanelView:ScrollToSelectedGoods(Index)
	self.GoodsTableViewAdapter:ScrollToIndex(Index)
end

function ShopMainPanelView:OnCloseView()
	self:Hide()
end

function ShopMainPanelView:CheckJumpState(GoodsList)
	local JumpState = ShopMgr.JumpToGoodsState
	if not JumpState then
		self.GoodsTableViewAdapter:ScrollToTop()
		return
	end 

	for i = 1, #GoodsList do
		if GoodsList[i].GoodsId == ShopMgr.JumpToGoodsItemResID then
			self.GoodsTableViewAdapter:ScrollToIndex(i)
			local ItemData = self.ViewModel:GetJumpGoodsInfo(GoodsList[i].GoodsId)
			ShopMgr.CurQueryShopID = self.ShopId
			UIViewMgr:ShowView(UIViewID.ShopBuyPropsWinView, ItemData)
			--ShopMgr.JumpToGoodsState = false 
			ShopMgr.IsJumpAgain = false
			break
		end
	end
	ShopMgr.JumpToGoodsState = false
	ShopMgr.JumpToBuyNum = 0
end

function ShopMainPanelView:CheckJumpAgainState(ShopID)
	if not ShopMgr.IsJumpAgain then
		return
	end

	local JumpIndex = ShopMgr:GetJumpType() or 1
	self.TabList:SetSelectedIndex(JumpIndex)
	local GoodsList = ShopMgr:GetGoodsByType(ShopID, ShopMgr.ShopMainTypeIndex)


	for i = 1, #GoodsList do
		if GoodsList[i].GoodsId == ShopMgr.JumpToGoodsItemResID then
			self.GoodsTableViewAdapter:ScrollToIndex(i)
			local ItemData = self.ViewModel:GetJumpGoodsInfo(GoodsList[i].GoodsId)
			ShopMgr.CurQueryShopID = self.ShopId
			UIViewMgr:ShowView(UIViewID.ShopBuyPropsWinView, ItemData)
			--ShopMgr.JumpToGoodsState = false 
			ShopMgr.IsJumpAgain = false
			break
		end
	end

	ShopMgr.JumpToGoodsState = false
	ShopMgr.JumpToBuyNum = 0
end

function ShopMainPanelView:OnUpdateQuestTargetOwnItem()
	if self.ViewModel and self.ViewModel.CurGoodsList then
		local CurGoodsList = self.ViewModel.CurGoodsList
		local Num = CurGoodsList:Length()
		for i=1, Num do
			local GoodItem = CurGoodsList:Get(i)
			if GoodItem and GoodItem.ItemID then
				GoodItem:UpdateTaskState(GoodItem.ItemID)
			end
		end
	end
end

function ShopMainPanelView:OnUpdateEquipUpIcon()
	if self.ViewModel and self.ViewModel.CurGoodsList then
		local CurGoodsList = self.ViewModel.CurGoodsList
		local Num = CurGoodsList:Length()
		for i=1, Num do
			local GoodItem = CurGoodsList:Get(i)
			if GoodItem and GoodItem.ItemID then
				GoodItem:SetEquipUpIcon(GoodItem.ItemID)
			end
		end
	end
end

function ShopMainPanelView:OnUpdateMallCounterLimitInfo(ItemData)
	if self.MallCounterTimerID ~= nil then
		self:UnRegisterTimer(self.MallCounterTimerID)
	end
	local MallCounterID = ItemData.CounterID
	ShopMgr.CurOpenMallCounterID = MallCounterID
	local TempCounterCfg = CounterCfg:FindCfgByKey(MallCounterID)
	UIUtil.SetIsVisible(self.PanelTitle, MallCounterID ~= 0)
	
	if TempCounterCfg == nil then
		return
	end
	if LegendaryWeaponMallID ~= ShopMgr.CurOpenMallId then
		return
	end
	self:OnUpdateTableListPos(MallCounterID ~= 0)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgTitle, ItemData.CounterImgPath)
	self.Text1:SetText(ItemData.TabName)
	local Test = _G.CounterMgr:GetCounterRestore(MallCounterID)
	local Test2 = _G.CounterMgr:GetCounterCurrValue(MallCounterID)
	self.Text2:SetText(string.format(LSTR(1200098), _G.CounterMgr:GetCounterRestore(MallCounterID) - _G.CounterMgr:GetCounterCurrValue(MallCounterID), _G.CounterMgr:GetCounterRestore(MallCounterID)))	--- 每周限购
	local Now = _G.TimeUtil.GetServerLogicTime()
	if ShopMgr:GetNextMonday_ZeroMS() - Now <= 60 then
		self.MallCounterTimerID = self:RegisterTimer(function() self.Text3:SetText(_G.LocalizationUtil.GetCountdownTimeForSimpleTime(ShopMgr:GetNextMonday_ZeroMS(), "s")) end, 0, 1, ShopMgr:GetNextMonday_ZeroMS() - Now)
	end
	self.Text3:SetText(_G.LocalizationUtil.GetCountdownTimeForLongTime(ShopMgr:GetNextMonday_ZeroMS() - Now))	--- 刷新：x天y小时
end

function ShopMainPanelView:OnUpdateTableListPos(IsDownPos)
	if IsDownPos then
		UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Disable_TableView_Pos)
	else
		UIUtil.CanvasSlotSetPosition(self.TableViewList, DropDown_Enable_TableView_Pos)
	end
end

return ShopMainPanelView