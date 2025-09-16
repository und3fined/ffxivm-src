--
-- Author: star
-- Date: 2023-12-05 21:37
-- Description: 公会仓库
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ArmyDepotPageItemVM = require("Game/Army/ItemVM/ArmyDepotPageItemVM")
local ArmyDepotPageToggleItemVM = require("Game/Army/ItemVM/ArmyDepotPageToggleItemVM")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyMgr = require("Game/Army/ArmyMgr")
local GroupStoreCfg = require("TableCfg/GroupStoreCfg")
local ProtoRes = require("Protocol/ProtoRes")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")

local Default_Num = 0
---@class ArmyDepotPageVM : UIViewModel
---@field BindableListPage  UIBindableList
local ArmyDepotPageVM = LuaClass(UIViewModel)

---Ctor
function ArmyDepotPageVM:Ctor()
	self.BindableListPage = UIBindableList.New(ArmyDepotPageItemVM)
	self.BindableToggleListPage = UIBindableList.New(ArmyDepotPageToggleItemVM)
	self.CurrentPage = 1
	self.PageName = ""
	self.PageIcon = ""

	self.CapacityText = ""
	self.DepotListVisible = false
	self.Enlarge = 0
	self.DepotList = {}
	self.IsOpenEnlarge = nil
	self.IsCloseEnlarge = nil
	self.NumState = nil
	self.NumPercent = nil
	self.TotalMoneyNumStr = nil
	self.TotalMoneyNum = 0
	self.IsGoldAnimPlay = nil
	self.IsGoldDepotPerm = nil
end

function ArmyDepotPageVM.DepotListSort(A, B)
	return A.Index < B.Index
end

function ArmyDepotPageVM:OnInit()
	self.NumState = ArmyDefine.DepotNumState.Empty
	self.NumPercent = 0
end

function ArmyDepotPageVM:DepotListInit()
	local MaxNum = ArmyMgr:GetArmyStoreMaxCount()
	Default_Num = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GroupStoreDefaultGridNum)
	self.DepotList = {}
	local Groupcfg = GroupStoreCfg:FindAllCfg()
	for _, GroupcfgData in ipairs(Groupcfg) do
		if GroupcfgData.ID <= MaxNum then
			local StroeName = ArmyMgr:GetStoreName(GroupcfgData.ID)
			local DepoSimple = {DepotName = StroeName or "", ItemNum = 0, Index = GroupcfgData.ID, Type = 1, Capacity = Default_Num}
			table.insert(self.DepotList, DepoSimple)
		end
	end
	local CurDepotList
	table.sort(self.DepotList, self.DepotListSort)
	self.BindableToggleListPage:UpdateByValues(self.DepotList)
	---默认显示第一个仓库
	if self.DepotList and self.DepotList[self.CurrentPage] then
		CurDepotList = {self.DepotList[self.CurrentPage]}
		self.BindableListPage:UpdateByValues(CurDepotList)
	end
end

function ArmyDepotPageVM:OnBegin()

end

function ArmyDepotPageVM:OnEnd()

end

function ArmyDepotPageVM:OnShutdown()

end

function ArmyDepotPageVM:UpdateDepotPageVMForDepotSimple(InDepotSimple)
	if nil == self.DepotList or nil == InDepotSimple then
		return
	end
	local UpDateIndex
	for i, DepotSimple in ipairs(self.DepotList) do
		if DepotSimple.Index == InDepotSimple.Index then
			UpDateIndex = i
		end
	end
	if UpDateIndex then
		self.DepotList[UpDateIndex] = InDepotSimple
	end
	--local CurDepotList = {self.DepotList[UpDateIndex]}
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end
	ViewModel:UpdateVM(self.DepotList[self.CurrentPage])
	self.BindableToggleListPage:UpdateByValues(self.DepotList)
	--self.BindableListPage:UpdateByValues(CurDepotList)
	self:UpdatePageInfo()
	self:UpdateCapacityText()
	self.IsOpenEnlarge = true
	self.IsCloseEnlarge = false
	-- 判断扩容是否已达上限
	-- local CfgRow = DepotEnlargeCfg:FindCfgByKey(self.Enlarge)
	-- if CfgRow == nil then
	-- 	self.IsOpenEnlarge = false
	-- 	self.IsCloseEnlarge = true
	-- else
	-- 	self.IsOpenEnlarge = true
	-- 	self.IsCloseEnlarge = false
	-- end
end

function ArmyDepotPageVM.SortDepotListPagePredicate(Left, Right)
	if Left.Index ~= Right.Index then
		return Left.Index < Right.Index
	end

	return false
end

---FindDepotPageVM
---@param Index number
---@return DepotPageVM
function ArmyDepotPageVM:FindDepotPageVM(Index)
	local function Predicate(ViewModel)
		if ViewModel.PageIndex == Index then
			return true
		end
	end

	return self.BindableListPage:Find(Predicate)
end

function ArmyDepotPageVM:SetCurrentPage(Index)
	self.CurrentPage = Index

	self:UpdatePageList()
	self:UpdateCapacityText()
	self:UpdatePageInfo()
end

function ArmyDepotPageVM:GetCurDepotIndex()
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end
	return ViewModel.PageIndex
end

function ArmyDepotPageVM:DepotEnlarge(DepotMsg)
	local DepotList = self.DepotList
	table.insert(DepotList, DepotMsg)
	self:SetCurrentPage(#DepotList)
	self:UpdateDepotPageVM(DepotList)
end

function ArmyDepotPageVM:OnItemUpdate()
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end

	ViewModel:OnItemUpdate()

	self.IconColor = ViewModel.IconColor

	self:UpdateCapacityText()
end

function ArmyDepotPageVM:OnUpdateItemCD(GroupID, EndFreezeTime, FreezeCD)
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateItemListCD(GroupID, EndFreezeTime, FreezeCD)
end

function ArmyDepotPageVM:OnNameChanged(Index, Type, DepotName)
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end
	for _, value in pairs(self.DepotList) do
		if value.Index == Index then
			value.Type = Type
			value.DepotName = DepotName
		end
	end
	ViewModel:UpdateVM(self.DepotList[self.CurrentPage])
	self.BindableToggleListPage:UpdateByValues(self.DepotList)
	--self.BindableListPage:UpdateByValues(self.DepotList)
	self:UpdatePageInfo()
end

function ArmyDepotPageVM:UpdateCapacityText()
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end

	local Count = ViewModel:GetItemCount()
	local MaxCount
	local StoreId = self:GetCurDepotIndex()
	if StoreId then
		MaxCount = ArmyMgr:GetStoreCapacity(StoreId) or 0
	else
		MaxCount = ViewModel.Capacity
	end

	if Count == 0 then
		self.NumState = ArmyDefine.DepotNumState.Empty
	elseif Count < MaxCount then
		self.NumState = ArmyDefine.DepotNumState.NotFull
	elseif Count == MaxCount then
		self.NumState = ArmyDefine.DepotNumState.Full
	end
	self.NumPercent = Count / MaxCount
	self.CapacityText = string.format("%d/%d", Count, MaxCount)
end

function ArmyDepotPageVM:UpdatePageInfo()
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end

	self.PageName = ViewModel.PageName
	self.PageIcon = ViewModel.PageIcon
	self.IconColor = ViewModel.IconColor

end

function ArmyDepotPageVM:UpdatePageList()
	local Num = #self.DepotList
	if self.CurrentPage > Num then
		return
	end
	local ViewModel = self.BindableListPage:Get(1)
	if nil == ViewModel then
		return
	end
	ViewModel:UpdateVM(self.DepotList[self.CurrentPage])
end

function ArmyDepotPageVM:SetDepotListVisible(Visible)
	self.DepotListVisible = Visible
end

function ArmyDepotPageVM:GetDepotListVisible()
	return self.DepotListVisible
end

function ArmyDepotPageVM:SetDepotNumState(NumState)
	self.NumState = NumState
end

function ArmyDepotPageVM:GetDepotNumState()
	return self.NumState
end

function ArmyDepotPageVM:SetArmyMoneyStoreNum(TotalNum, IsGoldAnimPlay)
	if IsGoldAnimPlay then
		self.OldTotalNum = self.TotalMoneyNum
	else
		self:SetTotalMoneyNumStrByNum(TotalNum)
	end
	self:SetTotalMoneyNum(TotalNum)
	self.IsGoldAnimPlay = IsGoldAnimPlay
end

function ArmyDepotPageVM:SetTotalMoneyNumStrByAminVlaue(AminVlaue, AnimNum)
	local OldNum = AnimNum.OldNum
	local Num = AnimNum.Num
	if OldNum and Num and AminVlaue then
		local TotalNum = (Num - OldNum) * AminVlaue + OldNum
		self.TotalMoneyNumStr = ArmyMgr:FormatMoneyNumber(TotalNum)
	end
end

function ArmyDepotPageVM:SetTotalMoneyNumStrByNum(TotalNum)
	self.TotalMoneyNumStr = ArmyMgr:FormatMoneyNumber(TotalNum)
end

function ArmyDepotPageVM:SetTotalMoneyNum(TotalNum)
	self.TotalMoneyNum = TotalNum
end

function ArmyDepotPageVM:GetArmyMoneyStoreNum()
	return self.TotalMoneyNum
end

function ArmyDepotPageVM:GetOldTotalNum()
	return self.OldTotalNum
end

function ArmyDepotPageVM:SetIsGoldAnimPlay(IsGoldAnimPlay)
	self.IsGoldAnimPlay = IsGoldAnimPlay
end

function ArmyDepotPageVM:UpdateTotalMoneyNumStr()
	if self.TotalNum then
		self.TotalMoneyNumStr = ArmyMgr:FormatMoneyNumber(self.TotalNum)
	end
end

function ArmyDepotPageVM:SetIsGoldDepotPerm(IsGoldDepotPerm)
	self.IsGoldDepotPerm = IsGoldDepotPerm
end

function ArmyDepotPageVM:GetIsGoldDepotPerm()
	return self.IsGoldDepotPerm
end


return ArmyDepotPageVM