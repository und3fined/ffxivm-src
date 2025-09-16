---
--- Author: Administrator
--- DateTime: 2023-10-19 16:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ShopDropDownListItemNewVM =  require("Game/Shop/ItemVM/ShopDropDownListItemNewVM")
local ShopMgr = require("Game/Shop/ShopMgr")
local CommScreenerVM = require("Game/Common/Screener/CommScreenerVM")
local MallMainTypeCfg = require("TableCfg/MallsMainTypeCfg")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local MajorUtil = require("Utils/MajorUtil")

---@class ShopDropDownListItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownList1 CommDropDownListView
---@field DropDownList2 CommDropDownListView
---@field DropDownListPanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopDropDownListItemNewView = LuaClass(UIView, true)

function ShopDropDownListItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownList1 = nil
	--self.DropDownList2 = nil
	--self.DropDownListPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopDropDownListItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownList1)
	self:AddSubView(self.DropDownList2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopDropDownListItemNewView:OnInit()
	self.ViewModel = ShopDropDownListItemNewVM.New()
	self.ScreenerData1 = nil
	self.ScreenerData2 = nil
	self.Index1 = nil
	self.Index2 = nil
	self.FirstType = nil
	self.FilterNum = nil
	self.IsChanged = false
end

function ShopDropDownListItemNewView:OnDestroy()

end

function ShopDropDownListItemNewView:OnShow()
	self.IsInShopView = false
end

function ShopDropDownListItemNewView:OnHide()
	if self.FilterNum == nil then
		return
	end
	if self.FilterNum > 0 then
		ShopMgr:SetFilterSelectIndex(ShopMgr.CurOpenMallId, self.Index1, 1, self.FirstType)
		ShopMgr:SetFilterSelectIndex(ShopMgr.CurOpenMallId, self.Index2, 2, self.FirstType)
	end
	self.IsChanged = false
end

function ShopDropDownListItemNewView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList1, self.OnSelectionChangedDropDownList1)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList2, self.OnSelectionChangedDropDownList2)
end

function ShopDropDownListItemNewView:OnRegisterGameEvent()

end

function ShopDropDownListItemNewView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "DropDownListInfo", UIBinderSetIsVisible.New(self, self.DropDownList2) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

function ShopDropDownListItemNewView:OnSelectionChangedDropDownList1(Index, ItemData, ItemView)
	if self.ScreenerData1 == nil then	
		return
	end

	if not self.IsChanged then
		return
	end

	if not ShopMgr.CanChange then
		return
	end

	self.Index1 = Index
	local List = {}
	List.Info = self.ScreenerData1[Index]
	List.Index = 1
	List.ScrId = self.ScrId1
	ShopMgr.FilterSelectName1 = ItemData.Name
	ShopMgr:SetFilterSelectIndex(ShopMgr.CurOpenMallId, self.Index1, 1, self.FirstType)
	EventMgr:SendEvent(EventID.FilterGoods, List)
	--第一个筛选器刷新时要一起刷新第二个从属筛选器
	--if self.FilterNum > 1 then
		--self:UpdateSecondFilter(self.ScreenerData2)
	--end
end

function ShopDropDownListItemNewView:OnSelectionChangedDropDownList2(Index, ItemData, ItemView)
	if self.ScreenerData2 == nil then	
		return
	end

	if not self.IsChanged then
		return
	end

	if not ShopMgr.CanChange then
		return
	end

	self.Index2 = Index
	local List = {}
	List.Info = self.ScreenerData2[Index]
	List.Index = 2
	List.ScrId = self.ScrId2
	ShopMgr.FilterSelectName2 = ItemData.Name
	ShopMgr:SetFilterSelectIndex(ShopMgr.CurOpenMallId, self.Index2, 2, self.FirstType)
	EventMgr:SendEvent(EventID.FilterGoods, List)
end

function ShopDropDownListItemNewView:UpdateListInfo(ShopInfo, GoodList, FilterInfo)
	if GoodList == nil then
		FLOG_ERROR("UpdateListInfo GoodList = nil")
		return
	end

	self.ShopInfo = ShopInfo
	self.FirstType = GoodList.FirstType
	local DropNum = FilterInfo.FilterNum
	self.FilterNum = DropNum or 0
	if DropNum == 0 then
		UIUtil.SetIsVisible(self.DropDownList1, false, true)
		UIUtil.SetIsVisible(self.DropDownList2, false, true)
		return
	end

	if DropNum == 1 then
		UIUtil.SetIsVisible(self.DropDownList1, true, true)
		UIUtil.SetIsVisible(self.DropDownList2, false, true, true)
		
		self.ScrId1 = FilterInfo.ScreenerID1 or 1
		local ScreenerListInfo1, DefaultIndex = ShopMgr:GetScreenerListInfo(self.ScrId1)
		ShopInfo.ScrIndex = self.ScrId1
		local ScreenerData1 = ShopMgr:GetCond(ShopInfo, self.ScrId1, ScreenerListInfo1, GoodList)
		if ScreenerData1 == nil then
			return
		end
		--- 从筛选表里找到的下标，可能二次筛选过后会变,所以再找一遍
		if not ShopMgr.JumpToGoodsState then
			DefaultIndex = 1
			for index, value in ipairs(ScreenerData1) do
				if value.Data.IsCurProf then
					DefaultIndex = index
				end
			end
		end
		self.GoodsList = GoodList
		self.DropDownList1:UpdateItems(ScreenerData1)
		local FilterIndex1
		if self.IsInShopView then
			FilterIndex1 = self:IsHasSameIndex(ScreenerData1, ShopMgr.FilterSelectName1)
		else
			FilterIndex1 = ShopMgr:GetFilterListIndex(ShopMgr.CurOpenMallId, GoodList.FirstType, 1) or DefaultIndex
		end
		local Data1 = {}
		if ScreenerData1 and ScreenerData1[FilterIndex1] then
			Data1.Name = ScreenerData1[FilterIndex1].Name
		else
			FLOG_ERROR("ScreenerData1[FilterIndex1] = nil")
			Data1.Name = ""
		end
		
		self.IsChanged = true
		ShopMgr.CanChange = true
		self.ScreenerData1 = ScreenerData1
		self.DropDownList1:SetSelectedIndex(FilterIndex1, Data1)
	else
		UIUtil.SetIsVisible(self.DropDownList1, true, true)
		UIUtil.SetIsVisible(self.DropDownList2, true, true)

		self.ScrId1 = FilterInfo.ScreenerID1 or 1
		self.ScrId2 = FilterInfo.ScreenerID2 or 1
		local ScreenerListInfo1, DefaultIndex = ShopMgr:GetScreenerListInfo(self.ScrId1)
		local ScreenerListInfo2 = ShopMgr:GetScreenerListInfo(self.ScrId2)
		self.ScreenerListInfo2 = ScreenerListInfo2
		ShopInfo.ScrIndex = self.ScrId1
		local ScreenerData1 = ShopMgr:GetCond(ShopInfo, self.ScrId1, ScreenerListInfo1, GoodList)
		if ScreenerData1 == nil then
			return
		end
		--- 从筛选表里找到的下标，可能二次筛选过后会变，所以再找一遍
		if not ShopMgr.JumpToGoodsState then
			DefaultIndex = 1
			for index, value in ipairs(ScreenerData1) do
				if value.Data.IsCurProf then
					DefaultIndex = index
				end
			end
		end
		ShopInfo.ScrIndex = self.ScrId2
		local ScreenerData2 = ShopMgr:GetCond(ShopInfo, self.ScrId2, ScreenerListInfo2, ShopMgr.FilterAfterGoodsList)
		self.ScreenerData2 = ScreenerData2
		self.GoodsList = GoodList
		self.DropDownList1:UpdateItems(ScreenerData1)
		self.DropDownList2:UpdateItems(ScreenerData2)
		local FilterIndex1
		local FilterIndex2
		if self.IsInShopView then
			FilterIndex1 = self:IsHasSameIndex(ScreenerData1, ShopMgr.FilterSelectName1)
			if FilterIndex1 == 1 then
				local Index1 = ShopMgr:GetFilterListIndex(ShopMgr.CurOpenMallId, GoodList.FirstType, 1) or DefaultIndex
				FilterIndex1 = Index1
			end
			self.Index1 = FilterIndex1
			local Data1 = {}
			local Name = ""
			if ScreenerData1 and ScreenerData1[FilterIndex1] then
				Name = ScreenerData1[FilterIndex1].Name
			else
				_G.FLOG_WARNING("ScreenerData1 Error1")
			end
			Data1.Name = Name
			self.IsChanged = true
			ShopMgr.CanChange = true
			self.ScreenerData1 = ScreenerData1
			self.DropDownList1:SetSelectedIndex(FilterIndex1,Data1)
			local CurData2 = self.ScreenerData2 or ScreenerData2
			FilterIndex2 = self:IsHasSameIndex(CurData2, ShopMgr.FilterSelectName2)
			if FilterIndex2 == 1 then
				local Index2 = ShopMgr:GetFilterListIndex(ShopMgr.CurOpenMallId, GoodList.FirstType, 2) or 1
				FilterIndex2 = Index2
			end
			self.FilterIndex2 = FilterIndex2
			self.Index2 = FilterIndex2
			-- if FilterIndex2 == 1 then
			-- 	local Index2 = ShopMgr:GetFilterListIndex(ShopMgr.CurOpenMallId, GoodList.FirstType, 2) or 1
			-- 	FilterIndex2 = Index2
			-- end
			local Data2 = {}
			Data2.Name = CurData2[FilterIndex2].Name
			self.DropDownList2:SetSelectedIndex(FilterIndex2,Data2)
		else
			local CurData2 = self.ScreenerData2 or ScreenerData2
			FilterIndex1 = ShopMgr:GetFilterListIndex(ShopMgr.CurOpenMallId, GoodList.FirstType, 1) or DefaultIndex
			FilterIndex2 = ShopMgr:GetFilterListIndex(ShopMgr.CurOpenMallId, GoodList.FirstType, 2) or 1
			self.Index1 = FilterIndex1
			self.Index2 = FilterIndex2
			self.FilterIndex2 = FilterIndex2
			local Data1 = {}
			local Data2 = {}
			local Name1 = ""
			local Name2 = ""
			if ScreenerData1 and ScreenerData1[FilterIndex1] then
				Name1 = ScreenerData1[FilterIndex1].Name
			else
				_G.FLOG_WARNING("ScreenerData1 Error2")
			end
			Data1.Name = Name1

			if CurData2 and CurData2[FilterIndex2] then
				Name2 = CurData2[FilterIndex2].Name
			else
				_G.FLOG_WARNING("CurData2 Error")
			end
			Data2.Name = Name2
			self.IsChanged = true
			ShopMgr.CanChange = true
			self.ScreenerData1 = ScreenerData1
			self.DropDownList1:SetSelectedIndex(FilterIndex1, Data1)
			self.DropDownList2:SetSelectedIndex(FilterIndex2)
		end

	end
end

function ShopDropDownListItemNewView:UpdateSecondFilter(GoodsList)
	local ScreenerData2 = ShopMgr:GetCond(self.ShopInfo, self.ScrId1, self.ScreenerListInfo2, GoodsList, self.Index1)
	self.DropDownList2:UpdateItems(ScreenerData2)
	local Data = {}
	Data.Name = ScreenerData2[1].Name
	self.ScreenerData2 = ScreenerData2
	self.DropDownList2:SetSelectedIndex(1, Data)
end

function ShopDropDownListItemNewView:SetState(value)
	self.IsChanged = value
end

function ShopDropDownListItemNewView:SetIsInShopState(State)
	self.IsInShopView = State
end

function ShopDropDownListItemNewView:SetAllFilterVisible(Value)
	if self.FilterNum == 0 then
		UIUtil.SetIsVisible(self.DropDownList1, false, true)
		UIUtil.SetIsVisible(self.DropDownList2, false, true)
		return
	elseif self.FilterNum == 1 then
		UIUtil.SetIsVisible(self.DropDownList1, Value, true)
		UIUtil.SetIsVisible(self.DropDownList2, false, true)
		return
	else
		UIUtil.SetIsVisible(self.DropDownList1, Value, true)
		UIUtil.SetIsVisible(self.DropDownList2, Value, true)
		return
	end
end

function ShopDropDownListItemNewView:IsHasSameIndex(List, Name)
	local Value = 1
	if Name == "" or Name == nil then
		return Value
	end
	
	for Index, value in pairs(List) do
		if value.Name == Name then
			Value = Index
			return Value
		end
	end

	return Value
end

return ShopDropDownListItemNewView