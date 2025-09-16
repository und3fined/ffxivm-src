---
--- Author: Administrator
--- DateTime: 2023-10-19 11:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShopMainPanelNewView = LuaClass(UIView, true)
local ShopMgr = require("Game/Shop/ShopMgr")
local UIViewMgr = require("UI/UIViewMgr")
local ShopMainPanelNewVM = require("Game/Shop/ShopMainPanelNewVM")
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

local UIViewID = _G.UIViewID

---@class ShopMainPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnSearcher UFButton
---@field DropDownList ShopDropDownListItemNewView
---@field ImgBg UFImage
---@field MoneySlot1 CommMoneySlotView
---@field MoneySlot2 CommMoneySlotView
---@field MoneySlot3 CommMoneySlotView
---@field Spacer USpacer
---@field TabList ShopTabListItemNewView
---@field TableViewIist UTableView
---@field TextTitleName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY

function ShopMainPanelNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnSearcher = nil
	--self.DropDownList = nil
	--self.ImgBg = nil
	--self.MoneySlot1 = nil
	--self.MoneySlot2 = nil
	--self.MoneySlot3 = nil
	--self.Spacer = nil
	--self.TabList = nil
	--self.TableViewIist = nil
	--self.TextTitleName = nil
	--self.AnimIn = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopMainPanelNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.MoneySlot1)
	self:AddSubView(self.MoneySlot2)
	self:AddSubView(self.MoneySlot3)
	self:AddSubView(self.TabList)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY~
end

function ShopMainPanelNewView:OnInit()
	self.ViewModel = ShopMainPanelNewVM.New()
	self.PriceViewList = {self.MoneySlot1, self.MoneySlot2, self.MoneySlot3}
	self.TabInfoList = {}
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewIist, self.OnSelectChanged, true)
	self.Binders = {
		{ "CurGoodsList", UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
	}

end

function ShopMainPanelNewView:OnDestroy()

end

function ShopMainPanelNewView:OnShow()
	self.ShopId = self.Params.ShopId
	self.CurIndex = 0
	local EnableSearch = MallCfg:FindCfgByKey(self.ShopId).EnableSearch
	if EnableSearch ~= 1 then
		UIUtil.SetIsVisible(self.BtnSearcher, false, true)
	else
		UIUtil.SetIsVisible(self.BtnSearcher, true, true)
	end
	local Open = self.Params.Open
	self.TabInfoList = ShopMgr:GetTabListByShopID(self.ShopId)
	self.TabList:UpdateItems(self.TabInfoList)
	self:SetBackBtnState(Open)
	self:InitViewInfo(self.ShopId)
end

function ShopMainPanelNewView:InitViewInfo(ShopId)
	local ShopMainTypeOpenList = ShopMgr.ShopMainTypeOpenList
	local Index = 1
	if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
		Index = self:GetJumpType()
	else
		Index = ShopMainTypeOpenList[ShopId] or 1
	end
	local ShopName = MallCfg:FindCfgByKey(ShopId).Name
	if Index == nil then
		Index = 1
	end

	self.TextTitleName:SetText(ShopName)
	self.TabList:SetSelectedIndex(Index)
	self:UpdatePrice(self.TabInfoList)
end

function ShopMainPanelNewView:UpdateFilter(FirstType ,GoodList)
	local Data = {}
	Data.ShopID = self.ShopId
	Data.FirstType = FirstType
	self.DropDownList:UpdateListInfo(Data, GoodList, self.FilterInfo)
end

function ShopMainPanelNewView:UpdatePrice(List)
	local MianTypeIndex = 1
	if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
		MianTypeIndex = self:GetJumpType()
	else
		MianTypeIndex = ShopMgr.FirstTypeIndex or 1
	end
	if next(List) == nil or List[MianTypeIndex] == nil then
		FLOG_ERROR("UpdatePrice Tab List Nil")
		return
	end
	--FLOG_ERROR("Test tab price = %s",List[MianTypeIndex])
	for i = 1,3 do
		if List[MianTypeIndex].Price ~= nil then
			if List[MianTypeIndex].Price[i] then
				local PriceType = List[MianTypeIndex].PriceType
				local IsScore = false
				local ScoreType = ProtoEnumAlias.GetAlias(ProtoRes.GoodsPriceType, ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE)
				if PriceType[i] == ScoreType then
					IsScore = true
				end
	
				UIUtil.SetIsVisible(self.PriceViewList[i], true)
				self.PriceViewList[i]:UpdateView(List[MianTypeIndex].Price[i], false, UIViewID.MarketExchangeWin, IsScore)
			else
				UIUtil.SetIsVisible(self.PriceViewList[i], false)
			end
		end
	end
end

function ShopMainPanelNewView:SetBackBtnState(Open)
	UIUtil.SetIsVisible(self.BtnBack, Open == 1)
	UIUtil.SetIsVisible(self.BtnClose, Open ~= 1)
end

function ShopMainPanelNewView:OnHide()
	local Data = {}
	Data.ShopId = self.Params.ShopId
	Data.MainTypeIndex = ShopMgr.FirstTypeIndex
	ShopMgr.LastMallId = 0
	ShopMgr:SetShopMainTypeOpenList(Data)
	if ShopMgr.JumpToGoodsState then
		ShopMgr.JumpToGoodsState = false
	end
end

function ShopMainPanelNewView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.TabList, self.UpdateShopTypeList)
	self.BtnBack:AddBackClick(self, function(e) e:OnCloseView() end)
end

function ShopMainPanelNewView:OnRegisterGameEvent() 
	self:RegisterGameEvent(EventID.UpdateMallGoodsListMsg, self.UpdateListByBuy)
	self:RegisterGameEvent(EventID.ScrollToSelectedGoods, self.ScrollToSelectedGoods)
	self:RegisterGameEvent(EventID.FilterGoods, self.FilterGoodsList)
	self:RegisterGameEvent(EventID.UpdateScore, self.OnUpdateItemValue)
	self:RegisterGameEvent(EventID.UpdateQuestTargetOwnItem, self.OnUpdateQuestTargetOwnItem)
end

function ShopMainPanelNewView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ShopMainPanelNewView:OnUpdateItemValue()
	local MianTypeIndex = ShopMgr.FirstTypeIndex
	local List = self.TabInfoList
	if List == nil or next(List) == nil then
		FLOG_ERROR("OnUpdateItemValue Tab List Nil")
		return
	end

	--FLOG_ERROR("Test tab price = %s",List[MianTypeIndex])
	for i = 1,3 do
		if List[MianTypeIndex].Price ~= nil then
			if List[MianTypeIndex].Price[i] then
				local PriceType = List[MianTypeIndex].PriceType
				local ScoreType = ProtoEnumAlias.GetAlias(ProtoRes.GoodsPriceType, ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE)
				if PriceType[i] ~= ScoreType then
					self.PriceViewList[i]:UpdateView(List[MianTypeIndex].Price[i], false, UIViewID.MarketExchangeWin, false)
				end		
			end
		end
	end
end

function ShopMainPanelNewView:UpdateShopTypeList(Index)
	local _ <close> = CommonUtil.MakeProfileTag("UpdateShopTypeList")
	if self.CurIndex == Index then
		return
	end

	--跳转状态不改变
	-- if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
	-- 	return
	-- end
	self.CurIndex = Index
	ShopMgr.FirstTypeIndex = Index
	local ShopMainTypeIndex

	if ShopMgr.JumpToGoodsState or ShopMgr.JumpToShop then
		ShopMainTypeIndex = self:GetJumpType()
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
	self:CheckJumpState(self.CurGoodsList)
	self:UpdateFilter(self.CurFirstType, self.CurGoodsList)
end

function ShopMainPanelNewView:FilterGoodsList(List)
	--FLOG_ERROR("TestFilterGoodsList = %s",table_to_string(List))
	local GoodsList
	local FliterList
	if List.Index == 1 then
		FliterList = ShopMgr.CurFirstTypeFilterList[self.ShopId][self.CurFirstType][List.ScrId]

		if #FliterList[List.Info.Index].GoodsList ~= 0 then
			GoodsList = FliterList[List.Info.Index].GoodsList
		else
			GoodsList = ShopMgr.CurFirstTypeGoodsList
		end

		ShopMgr.FilterAfterGoodsList = GoodsList

		if self.FilterInfo.FilterNum > 1 then
			self.DropDownList:UpdateSecondFilter(GoodsList)
		end
	else
		FliterList = ShopMgr.CurFirstTypeFilterList[self.ShopId][self.CurFirstType][List.ScrId]
		local SencondList

		if ShopMgr.AfterFistFilterList[List.Info.Index] ~= nil then
			SencondList = ShopMgr.AfterFistFilterList[List.Info.Index].GoodsList
		else
			SencondList = FliterList[List.Info.Index].GoodsList
		end

		if #FliterList[List.Info.Index].GoodsList ~= 0 then
			GoodsList = ShopMgr:GetSecondFilterList(ShopMgr.FilterAfterGoodsList, SencondList)
		else
			GoodsList = ShopMgr.FilterAfterGoodsList
		end	
	end

    self.ViewModel:UpdateGoodsListInfo(GoodsList)
	self:PlayAnimation(self.AnimUpdateList)
end

function ShopMainPanelNewView:UpdateGoodsList(IsPlayAni)
	local _ <close> = CommonUtil.MakeProfileTag("ShopUpdateGoodsList")
	local ShopMainTypeOpenList = ShopMgr.ShopMainTypeOpenList
	local Index = ShopMainTypeOpenList[self.ShopId]

	if Index == nil then
		Index = 1
	end
	local CurOpenGoodList = ShopMgr.CurOpenShopGoodSList

	--ShopMgr.FirstTypeIndex = FirstType
	local GoodList = self.CurGoodsList--ShopMgr:GetGoodsByType(self.ShopId, FirstType)
	if GoodList == nil then
		return
	end
	
	local DropNum = self.FilterInfo.FilterNum
	if DropNum < 1 then
		UIUtil.SetIsVisible(self.Spacer, false)
	else
		UIUtil.SetIsVisible(self.Spacer, true)
	end


	ShopMgr.FilterAfterGoodsList = GoodList
	self.ViewModel:UpdateGoodsListInfo(GoodList)

	if IsPlayAni then
		self:PlayAnimation(self.AnimUpdateList)
	end

	if ShopMgr.JumpToShop then
		ShopMgr.JumpToShop = false
	end
	--self.TurnPageBar:UpdatePage(GoodList)
end

function ShopMainPanelNewView:UpdateListByBuy()
	self.ViewModel:UpdateGoodsListInfo(ShopMgr.CurFirstTypeGoodsList)
end

function ShopMainPanelNewView:OnSelectChanged(Index, ItemData, ItemView)
	--FLOG_ERROR("GOODS INDEX = %d",Index)
	ShopMgr.CurQueryShopID = self.ShopId
	UIViewMgr:ShowView(UIViewID.ShopBuyPropsWinNewView, ItemData)
end

function ShopMainPanelNewView:ScrollToSelectedGoods(Index)
	self.GoodsTableViewAdapter:ScrollToIndex(Index)
end

function ShopMainPanelNewView:OnCloseView()
	ShopMgr.CurQueryShopID = nil
	self:Hide()
end

function ShopMainPanelNewView:CheckJumpState(GoodsList)
	local JumpState = ShopMgr.JumpToGoodsState
	if not JumpState then
		return
	end

	for i = 1,#GoodsList do
		if GoodsList[i].GoodsId == ShopMgr.JumpToGoodsItemResID then
			self.GoodsTableViewAdapter:ScrollToIndex(i)
			local ItemData = self.ViewModel:GetJumpGoodsInfo(GoodsList[i].GoodsId)
			ShopMgr.CurQueryShopID = self.ShopId
			UIViewMgr:ShowView(UIViewID.ShopBuyPropsWinNewView, ItemData)
			--ShopMgr.JumpToGoodsState = false 
			break
		end
	end
	ShopMgr.JumpToGoodsState = false 
end

function ShopMainPanelNewView:GetJumpType()
	local Index = 1
	for i = 1, #self.TabInfoList do 
		if self.TabInfoList[i].FirstType == ShopMgr.ShopMainTypeIndex then
			Index = i
			return Index
		end
	end

	return Index
end

function ShopMainPanelNewView:OnUpdateQuestTargetOwnItem()
	if self.ViewModel  and self.ViewModel.CurGoodsList then
		local CurGoodsList = self.ViewModel.CurGoodsList
		local Num = CurGoodsList:Length()
		for i=1, Num do
			local GoodItem = CurGoodsList:Get(i)
			if GoodItem and GoodItem.ItemID then
				GoodItem:SetTaskState(GoodItem.ItemID)
			end
		end
	end
end

return ShopMainPanelNewView