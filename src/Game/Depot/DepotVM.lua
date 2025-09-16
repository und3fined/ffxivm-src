--
-- Author: anypkvcai
-- Date: 2022-03-14 21:37
-- Description: 仓库
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local DepotPageVM = require("Game/Depot/DepotPageVM")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")

local DepotEnlargeCfg = require("TableCfg/DepotEnlargeCfg")
local EToggleButtonState = _G.UE.EToggleButtonState

local MAX_ITEM_COUNT = 30

---@class DepotVM : UIViewModel
---@field BindableListPage  UIBindableList
local DepotVM = LuaClass(UIViewModel)

---Ctor
function DepotVM:Ctor()
	self.DepotListItem = UIBindableList.New(BagSlotVM, {IsShowNewFlag = false, IsAllowDoubleClick = true})
	self.PageListPage = UIBindableList.New(DepotPageVM)
	
	self.CurrentPage = 1
	self.PageName = ""
	self.PageIcon = ""

	self.CapacityText = ""
	self.DepotListVisible = false
	self.Enlarge = 0
	self.DepotList = {}  -- 存储仓库信息 仓库名 icon 类型 num
	self.DepotItemList = {} -- 存储仓库物品
	self.IsOpenEnlarge = nil
	self.IsCloseEnlarge = nil
	self.ToggleBtnNameState = EToggleButtonState.Unchecked

	self:InitItemVM()
end

function DepotVM:InitItemVM()
	for _ = 1, MAX_ITEM_COUNT do
		local ViewModel = BagSlotVM.New()
		self.DepotListItem:Add(ViewModel)
	end
end

function DepotVM:OnInit()
end

function DepotVM:OnBegin()

end

function DepotVM:OnEnd()
	self:ClearnData()
end

function DepotVM:OnShutdown()

end

---@param DepotList table<DepotSimple>
function DepotVM:UpdateDepotPageVM(DepotList)
	table.sort(DepotList, DepotVM.SortDepotListPagePredicate)
	self.DepotList = DepotList
	self.PageListPage:UpdateByValues(DepotList)
	
	-- 判断扩容是否已达上限
	local CfgRow = DepotEnlargeCfg:FindCfgByKey(self.Enlarge)
	if CfgRow == nil then
		self.IsOpenEnlarge = false
		self.IsCloseEnlarge = true
	else
		self.IsOpenEnlarge = true
		self.IsCloseEnlarge = false
	end
end

function DepotVM:SetDepotItems(DepotIndex, Items)
	self.DepotItemList[DepotIndex] = Items
	self:RefreshDepotPageByItem(DepotIndex)
end

function DepotVM:RefreshDepotPageByItem(DepotIndex)
	local Value = self:GetDepotPage(DepotIndex)
	if Value ~= nil then
		Value.ItemNum = self:GetPageItemNum(DepotIndex)
	end
end

function DepotVM:SetDepotItem(DepotIndex, DepotPos, DepotItem)
	local DepotItems = self.DepotItemList[DepotIndex] or {}
	DepotItems[DepotPos] = DepotItem
	self.DepotItemList[DepotIndex] = DepotItems
	self:RefreshDepotPageByItem(DepotIndex)
end

function DepotVM:RemoveDepotItem(DepotIndex, DepotPos)
	local DepotItems = self.DepotItemList[DepotIndex] or {}
	DepotItems[DepotPos] = nil
	self.DepotItemList[DepotIndex] = DepotItems
	self:RefreshDepotPageByItem(DepotIndex)
end


function DepotVM.SortDepotListPagePredicate(Left, Right)
	if Left.Index ~= Right.Index then
		return Left.Index < Right.Index
	end

	return false
end

---FindDepotPageVM
---@param Index number
---@return DepotPageVM
function DepotVM:FindDepotPageVM(Index)
	local function Predicate(ViewModel)
		if ViewModel.PageIndex == Index then
			return true
		end
	end

	return self.PageListPage:Find(Predicate)
end

function DepotVM:SetCurrentPage(Index)
	self.CurrentPage = Index
	local ViewModel = self.PageListPage:Get(Index)
	if ViewModel ~= nil then
		for i = 1, self.PageListPage:Length() do
			self.PageListPage:Get(i):SetSelelctIndex(ViewModel.PageIndex)
		end
	end
end

function DepotVM:GetCurDepotIndex()
	local ViewModel = self.PageListPage:Get(self.CurrentPage)
	if nil == ViewModel then
		return
	end
	return ViewModel.PageIndex
end

function DepotVM:DepotEnlarge(DepotMsg)
	local DepotList = self.DepotList
	table.insert(DepotList, DepotMsg)
	self:UpdateDepotPageVM(DepotList)
	self:SetCurrentPage(#DepotList)
	self:OnItemUpdate()
end

function DepotVM:ClearnData()
	self.DepotList = {}
	self.DepotItemList = {}
	self.CurrentPage = 1
end

function DepotVM:OnItemUpdate()
	local ViewModel = self.PageListPage:Get(self.CurrentPage)
	if nil == ViewModel then
		return
	end
	ViewModel:UpdateVM(self:GetDepotPage(self.CurrentPage))
	self:UpdateItems(self.DepotItemList[self.CurrentPage] or {})

	self:UpdatePageInfo()
	self:UpdateCapacityText()
end

function DepotVM:OnUpdateItemCD(GroupID, EndFreezeTime, FreezeCD)
	for i = 1, self.DepotListItem:Length() do
		local ItemVM = self.DepotListItem:Get(i)
		if ItemVM.IsValid then
			ItemVM:UpdateItemCD(GroupID, EndFreezeTime, FreezeCD)
		end
	end
end

function DepotVM:OnNameChanged(Index, Type, DepotName)
	local Value = self:GetDepotPage(Index)
	if Value ~= nil then
		Value.Type = Type
		Value.DepotName = DepotName
	end

	self:UpdatePageInfo()
end

function DepotVM:UpdateCapacityText()
	local ViewModel = self.PageListPage:Get(self.CurrentPage)
	if nil == ViewModel then
		return
	end

	local Count = ViewModel:GetItemCount() or 0
	local MaxCount = MAX_ITEM_COUNT

	self.CapacityText = string.format("%d/%d", Count, MaxCount)
end

function DepotVM:UpdatePageInfo()
	local ViewModel = self.PageListPage:Get(self.CurrentPage)
	if nil == ViewModel then
		return
	end

	self.PageName = ViewModel.PageName
	self.PageIcon = ViewModel.PageIcon
	self.IconColor = ViewModel.IconColor
end

---UpdateItems
---@param Value table<number,common.Item>
function DepotVM:UpdateItems(Value)
	for i = 1, MAX_ITEM_COUNT do
		local ViewModel = self.DepotListItem:Get(i)
		if nil ~= ViewModel then
			ViewModel:UpdateVM(Value[i] or {}, {IsShowNewFlag = false, IsAllowDoubleClick = true})
		end
	end
end

function DepotVM:SetDepotListVisible(Visible)
	self.DepotListVisible = Visible
	if Visible == true then
		self.ToggleBtnNameState = EToggleButtonState.checked
	else
		self.ToggleBtnNameState = EToggleButtonState.Unchecked
	end
end

function DepotVM:GetDepotListVisible()
	return self.DepotListVisible
end

function DepotVM:GetCurDepotNum()
	return #self.DepotList
end

function DepotVM:GetDepotPage(Index)
	for _, Value in pairs(self.DepotList) do
		if Value.Index == Index then
			return Value
		end
	end

	return {}
end

function DepotVM:GetPageItemNum(Page)
	local Num = 0
	local Value = self.DepotItemList[Page] or {}
	for _, DepotItem in pairs(Value) do
		if DepotItem ~= nil and DepotItem.ResID ~= nil then
			Num = Num + 1
		end
	end

	return Num
end

function DepotVM:GetDepotItemNum(ResID)
	if nil == ResID or ResID <= 0 then
		return 0
	end

	local Num = 0
	for _, Value in pairs(self.DepotItemList) do
		for _, DepotItem in pairs(Value) do
			if DepotItem.ResID == ResID then
				Num = Num + DepotItem.Num
			end
		end
	end

	return Num
end

function DepotVM:GetAllDepotItems()
	local ItemList = {}

	for _, Value in pairs(self.DepotItemList) do
		for _, DepotItem in pairs(Value) do
			table.insert(ItemList, DepotItem)
		end
	end

	return ItemList
end

function DepotVM:GetMaxItemCount()
	return MAX_ITEM_COUNT
end

return DepotVM