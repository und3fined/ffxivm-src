local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local BagDefine = require("Game/Bag/BagDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local BagMgr = require("Game/Bag/BagMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local LSTR = _G.LSTR

local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE

---@class BagPropsSideFrameVM : UIViewModel
local BagPropsSideFrameVM = LuaClass(UIViewModel)
---Ctor
function BagPropsSideFrameVM:Ctor()
    self.PropName = nil
    self.UseBtnEnabled = false
    self.UseBtnVisible = true
    self.EmptyItemCache = {}
    self.CurrentItemVMList = UIBindableBagSlotList.New(BagSlotVM)
end


function BagPropsSideFrameVM:SetCurItem(Index)
	self.CurGID = nil
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item then
		CurItemVM:SetItemSelected(false)
	end

	local ClickedItemVM = self.CurrentItemVMList:Get(Index)
	self:SetEmptyItem(ClickedItemVM == nil or ClickedItemVM.IsValid == false)
	if ClickedItemVM and ClickedItemVM.IsValid == true and ClickedItemVM.Item then
		ClickedItemVM:SetItemSelected(true)
		self.CurGID = ClickedItemVM.Item.GID
	end

	self.ItemIndex = Index
end

function BagPropsSideFrameVM:GetCurItem()
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item and CurItemVM.Item.GID == self.CurGID then
        CurItemVM.Item.FreezeGroup = CurItemVM.FreezeGroup
		return CurItemVM.Item
	end

	self.ItemIndex = self:UpdateItemIndexByGID(self.CurGID)
	CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item then
        CurItemVM.Item.FreezeGroup = CurItemVM.FreezeGroup
		return CurItemVM.Item
	end

	return nil
end

function BagPropsSideFrameVM:UpdateItemIndexByGID(GID)
	if GID == nil then
		return
	end

	for i = 1, self.CurrentItemVMList:Length() do
		local ItemVM = self.CurrentItemVMList:Get(i)
		if ItemVM and ItemVM.IsValid == true and ItemVM.Item and ItemVM.Item.GID == GID then
			return i
		end
	end
end

function BagPropsSideFrameVM:UpdateTabInfo()
	local EasyUseItemList = self:GetEasyUseItemList()
    local FillCapacityNum = 0
    local ItemNum =  #EasyUseItemList
    if ItemNum < 24 then
        FillCapacityNum = 24 - ItemNum
    elseif ItemNum%4 ~= 0 then
        FillCapacityNum = (4 - ItemNum%4 )%4
    end

	EasyUseItemList = self:FillCapacityByEmptyItem(EasyUseItemList, FillCapacityNum)

	self.CurrentItemVMList.UpdateVMParams = {IsShowCanRecovery = self.IsShowCanRecovery, IsAllowDoubleClick = self.IsAllowDoubleClick}
	self.CurrentItemVMList:UpdateByValues(EasyUseItemList)

end

function BagPropsSideFrameVM:FillCapacityByEmptyItem(ItemList, FillCapacity)

	local ResultList = ItemList or {}
	local ItemLen = #ResultList
	for i = 1, FillCapacity do
		ResultList[ItemLen + i] = self.EmptyItemCache
	end
	return ResultList
end

function BagPropsSideFrameVM:SetEmptyItem(IsEmpty)
    self.NoneTipsVisible = IsEmpty
    self.PanelDetailVisible = not IsEmpty
end

function BagPropsSideFrameVM.SortBagItemVMPredicate(Left, Right)
	if Left.IsNew ~= Right.IsNew then
		return Left.IsNew
	end


	if Left.ResID ~= Right.ResID then
		--无论升序降序 ResID小的排前面
		return Left.ResID < Right.ResID
	end

	if Left.Num ~= Right.Num then
		--无论升序降序 数量多的排前面
		return Left.Num > Right.Num
	end

	if Left.GID ~= Right.GID then
		--无论升序降序 GID小的排前面
		return Left.GID < Right.GID

	end

	return false
end

-- 获取快捷使用道具
function BagPropsSideFrameVM:GetEasyUseItemList()
	local AllItemList = BagMgr.ItemList
	local Length = #AllItemList
	local ItemList = {}

	for i = 1, Length do
		local Item = AllItemList[i]
		local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
        if Cfg then
			if Cfg.PropEasyUse == 1 then
				table.insert(ItemList, Item)
			end
        end
	end
	return ItemList
end

--要返回当前类
return BagPropsSideFrameVM