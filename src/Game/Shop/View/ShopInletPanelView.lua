---
--- Author: Administrator
--- DateTime: 2024-08-19 19:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShopMgr = require("Game/Shop/ShopMgr")
local EquipmentCurrencyVM = require("Game/Equipment/VM/EquipmentCurrencyVM")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreSummaryTypeCfg = require("TableCfg/ScoreSummaryTypeCfg")
local ShopInletPanelVM = require("Game/Shop/ShopInletPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local EventID = require("Define/EventID")

local LSTR = _G.LSTR

---@class ShopInletPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BGPanel UFCanvasPanel
---@field BtnClose CommonCloseBtnView
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommBottomTab CommBottomTabView
---@field CommSearchBar CommSearchBarView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field Panel2 UFCanvasPanel
---@field Panel3 UFCanvasPanel
---@field Panel4 UFCanvasPanel
---@field Panel6 UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field TableView2 UTableView
---@field TableView3 UTableView
---@field TableView4 UTableView
---@field TableView6 UTableView
---@field TableViewSearchList UTableView
---@field AnimIn UWidgetAnimation
---@field AnimItemIn UWidgetAnimation
---@field AnimItemOut UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopInletPanelView = LuaClass(UIView, true)

function ShopInletPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BGPanel = nil
	--self.BtnClose = nil
	--self.CommBackpackEmpty = nil
	--self.CommBottomTab = nil
	--self.CommSearchBar = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonTitle = nil
	--self.Panel2 = nil
	--self.Panel3 = nil
	--self.Panel4 = nil
	--self.Panel6 = nil
	--self.PanelContent = nil
	--self.TableView2 = nil
	--self.TableView3 = nil
	--self.TableView4 = nil
	--self.TableView6 = nil
	--self.TableViewSearchList = nil
	--self.AnimIn = nil
	--self.AnimItemIn = nil
	--self.AnimItemOut = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopInletPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommBottomTab)
	self:AddSubView(self.CommSearchBar)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopInletPanelView:OnInit()
	self.ViewModel = ShopInletPanelVM.New()
	self.ShopTableTwoAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView2, self.OnFourSelectChanged, true, false, true)
	self.ShopTableThreeAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView3, self.OnFourSelectChanged, true, false, true)
	self.ShopTableFourAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView4, self.OnFourSelectChanged, true, false, true)
	self.ShopTableSixAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView6, self.OnFourSelectChanged, true, false, true)
	self.SearchAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSearchList, self.OnSearchListChanged, true)
	self.CommSearchBar:SetCallback(self, nil, self.OnSearchCommit, self.OnCancelSearchClicked)

	self.Binders = {
		{ "CurShopList", UIBinderUpdateBindableList.New(self, self.ShopTableFourAdapter) },
		{ "CurShopList", UIBinderUpdateBindableList.New(self, self.ShopTableSixAdapter) },
		{ "CurShopList", UIBinderUpdateBindableList.New(self, self.ShopTableTwoAdapter) },
		{ "CurShopList", UIBinderUpdateBindableList.New(self, self.ShopTableThreeAdapter) },
		{ "CurSearchList", UIBinderUpdateBindableList.New(self, self.SearchAdapter) },
		{ "TableView2Visible", UIBinderSetIsVisible.New(self, self.TableView2) },
		{ "TableView3Visible", UIBinderSetIsVisible.New(self, self.TableView3) },
		{ "TableView4Visible", UIBinderSetIsVisible.New(self, self.TableView4) },
		{ "TableView6Visible", UIBinderSetIsVisible.New(self, self.TableView6) },
		{ "TableSearchVisible", UIBinderSetIsVisible.New(self, self.TableViewSearchList) },
		{ "EmptyVisible", UIBinderSetIsVisible.New(self, self.CommBackpackEmpty) },
		{ "PanelContentVisible", UIBinderSetIsVisible.New(self, self.PanelContent) },
		
	}
	self.IsSearch = false
end

function ShopInletPanelView:OnDestroy()

end

function ShopInletPanelView:OnShow()
	--ShopMgr:GoodsRedClassify()
	self.CommBackpackEmpty:SetTipsContent(LSTR(1200090))
	self.CommSearchBar:SetHintText(LSTR(1200097))	--- 搜索商品
	local TabSelectIndex = 1
	if self.Params then
		TabSelectIndex = self.Params.Index or 1
	end
	self:GetSummaryType()
	self.FirstTabList = self:GetFirstTabInfo()
	self.CommBottomTab:UpdateItems(self.FirstTabList)
	self.CommBottomTab:SetSelectedIndex(TabSelectIndex)
	self.CommonTitle.TextTitleName:SetText(LSTR(1200022))
	self.CommonTitle:SetSubTitleIsVisible(false)
	self.CommonTitle:SetCommInforBtnIsVisible(false)
	self:InintShopTypeList(TabSelectIndex)
end

function ShopInletPanelView:OnHide()
	if ShopMgr.IsReq then
		ShopMgr.IsReq = false
	end
	if self.IsSearch then
		self:OnCancelSearchClicked()
	end
end

function ShopInletPanelView:OnRegisterUIEvent()
	self.BtnClose:SetCallback(self, self.Close)
	UIUtil.AddOnFocusLostEvent(self, self.CommSearchBar.TextInput, self.OnTextFocusLost)
end

function ShopInletPanelView:OnRegisterGameEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommBottomTab, self.UpdateShopTypeList)
	self:RegisterGameEvent(EventID.UpdateSerchGoods, self.OnUpdateSearchList)
	self:RegisterGameEvent(EventID.ShopPlayOutAni, self.BackCurView)
end

function ShopInletPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ShopInletPanelView:InintShopTypeList(Index)
	ShopMgr.ShopMainIndex = Index
	local ShopList = ShopMgr:GetShopCfgByTab(self.FirstTabList[ShopMgr.ShopMainIndex].ShowTypeIndex)
	self.ViewModel:UpdateShopListInfo(ShopList)
	--self:PlayAnimation(self.AnimUpdateList)
end

function ShopInletPanelView:UpdateShopTypeList(Index)
	if Index ==  ShopMgr.ShopMainIndex then
		return
	end
	-- self.ShopTableFourAdapter
	-- self.ShopTableSixAdapter
	ShopMgr.ShopMainIndex = Index
	ShopMgr.InletMainIndex = Index
	local ShopList = ShopMgr:GetShopCfgByTab(self.FirstTabList[ShopMgr.ShopMainIndex].ShowTypeIndex)
	self.ViewModel:UpdateShopListInfo(ShopList)
	--self:PlayAnimation(self.AnimUpdateList)
end

function ShopInletPanelView:OnFourSelectChanged(Index, ItemData, ItemView)
	--open = 1 从商会打开商店 = 2 从Npc打开商店
	--ItemData.Open = 1
	ShopMgr:OpenShop(ItemData.ShopID, nil, false, 1)
	self.CommSearchBar:OnClickButtonCancel()
end

function ShopInletPanelView:OnSearchListChanged(Index, ItemData, ItemView)
	ShopMgr:JumpToShopGoods(ItemData.MallID, ItemData.ItemID, 1)
end

function ShopInletPanelView:OnUpdateSearchList(List)
	self.SearchAdapter:ReleaseAllItem()
	self.ViewModel:SetSearchList(List)
end

function ShopInletPanelView:OnSearchCommit(Text)
	if Text == "" or Text == nil then
		return
	end
	self.IsSearch = true
	ShopMgr.ShopMainSearchList = {}
	local result = self.ViewModel:MatchGoodsInfo(Text)
	local ServerQueryIDsList = {}
	local NormalQueryList = {}
	local ServerQueryInfoList = {}
	for Index, Goods in pairs(result) do
		local IsSpeciaGoods = ShopMgr:IsQueryByServer(Goods.GoodsInfo, true)
		if IsSpeciaGoods and #ServerQueryIDsList < 100 then
			local GoodsID = result[Index].GoodsInfo.ID
			table.insert(ServerQueryIDsList, GoodsID)
			ServerQueryInfoList[GoodsID] = result[Index].GoodsInfo.MallID
		else
			table.insert(NormalQueryList, result[Index])
		end
	end

	if #NormalQueryList <= 0 and #ServerQueryIDsList <= 0 then
		self.ViewModel:SetSearchList({})
	else
		ShopMgr:SetSearchList(NormalQueryList, ServerQueryIDsList, ServerQueryInfoList)
	end

	local function DealyShow()
		self.SearchAdapter:ScrollToTop()
	end
	self.DealyID = self:RegisterTimer(DealyShow, 0.1, 0, 1)

	-- ShopMgr:SetNromalSearch(NormalQueryList)
	-- if #ServerQueryIDsList > 0 then
	-- 	ShopMgr:SetServerSearch(ServerQueryIDsList, ServerQueryInfoList)
	-- end
end

function ShopInletPanelView:OnCancelSearchClicked()
	self.IsSearch = false
	self.ViewModel:ExitSearch()
	ShopMgr.ShopMainSearchList = {}
end

function ShopInletPanelView:OnTextFocusLost()
	if self.IsSearch then
		UIUtil.SetIsVisible(self.CommSearchBar.BtnCancelNode, true, true)
	end
end

function ShopInletPanelView:BackCurView()
	self:PlayAnimation(self.AnimItemOut)
end

function ShopInletPanelView:GetSummaryType()
	self.ListData = {}
	for _, value in pairs(ProtoRes.ScoreSummaryType) do
		if value > 0 then
			local SearchConditions = string.format("%s%s", "ScoreSumType=", tostring(value))
			local Cfg = ScoreSummaryTypeCfg:FindCfg(SearchConditions)
			local Data
			if Cfg ~= nil then
				Data = {Name = Cfg.ScoreSummaryTabShow, ScoreSumType = Cfg.ScoreSumType}
			else
				local TabName = ProtoEnumAlias.GetAlias(ProtoRes.ScoreSummaryType, value)
				Data = {Name = TabName, ScoreSumType = value}
			end
			
			table.insert(self.ListData, Data)
		end
	end
	table.sort(self.ListData, self.Comp)
end

function ShopInletPanelView:GetFirstTabInfo()
	local List = ShopMgr:GetFirstTypeTab()
	local NewList = {}
	for i = 1, #self.ListData do
		for j = 1, #List do
			if self.ListData[i].Name == List[j].Name then
				List[j].ScoreSumType = self.ListData[i].ScoreSumType
			end
		end
	end

	for i = 1, #List do
		local UnlockShop = ShopMgr:GetShopCfgByTab(List[i].ShowTypeIndex)
		if #UnlockShop > 0 then
			table.insert(NewList, List[i])
		end
	end

	table.sort(NewList, self.Comp)
	return NewList
end

function ShopInletPanelView.Comp(V1, V2)
	local ShowTypeIndex1 = V1.ShowTypeIndex or 1
	local ShowTypeIndex2 = V2.ShowTypeIndex or 1
    if ShowTypeIndex1 < ShowTypeIndex2 then
        return true
    else
        return false
    end
end

return ShopInletPanelView