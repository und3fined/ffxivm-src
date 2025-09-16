---
--- Author: star
--- DateTime: 2023-12-01 16:42
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local BagMgr = require("Game/Bag/BagMgr")
local UIBindableList = require("UI/UIBindableList")
local ArmyDepotSlotVM = require("Game/Army/ItemVM/ArmyDepotSlotVM")
local BagDefine = require("Game/Bag/BagDefine")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ArmyDepotPageVM = require("Game/Army/VM/ArmyDepotPageVM")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ArmyMgr = require("Game/Army/ArmyMgr")
local MajorUtil = require("Utils/MajorUtil")
local GroupStoreCfg = require("TableCfg/GroupStoreCfg")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionClass = ProtoRes.GroupPermissionClass
local GroupPermissionCfg = require("TableCfg/GroupPermissionCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GroupPermissionType = ProtoRes.GroupPermissionType
local BagMainVM = require("Game/NewBag/VM/BagMainVM")

local BagMainType = {Item = 1, Equip = 2}
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE
local UIViewID = _G.UIViewID
local UIViewMgr



---@class ArmyDepotPanelVM : UIViewModel
local ArmyDepotPanelVM = LuaClass(UIViewModel)

---Ctor
function ArmyDepotPanelVM:Ctor()
	self.CurrentItemVMList = UIBindableList.New(ArmyDepotSlotVM)
    self.TabType = BagMainType.Item
    self.SlotItemVM = {}
	--self.CacheItemVM = {}
	self.NoneTipsVisible = nil
	--self.SubTitleText = nil
	self.TitleNameText = nil
	self.MaxGetItemsAllPrice = nil
	self.CounterGetItemsAllPrice = nil
	self.AvailableListDepotList = {}
	self.IsAllowedRename = nil
	self.ItemIndex = 0

	self.EmptyItemCache = {}

	--- 第一次不加載完所有item，优化性能
	self.CurNeedLoadItemNum = 0
	--- 每次添加加载item的数量
	self.AddLoadItemNum = 0
end

function ArmyDepotPanelVM:OnInit()
    self.ArmyDepotPageVM = ArmyDepotPageVM.New()
    self.ArmyDepotPageVM:Init() 
	self.NoneTipsVisible = false
	self.TitleNameText = ""
	--self.SubTitleText = ""
	self.ArmyDepotCountPriceCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GROUP_STORE_GIFT_WORTH_MAX)
	self.MaxGetItemsAllPrice = 0
	self.CounterGetItemsAllPrice = 0
	UIViewMgr = _G.UIViewMgr
	self.IsAllowedRename = false
	--self.EmptyItemCache =  ArmyDepotSlotVM.New()

	self.CurNeedLoadItemNum = 100
	self.AddLoadItemNum = 100
	self.EmptyItemCache.CurloadNum = self.CurNeedLoadItemNum
end

--- 赠礼限制不需要了
-- function ArmyDepotPanelVM:SetCountPrice()
-- 	if self.ArmyDepotCountPriceCfg and self.ArmyDepotCountPriceCfg.Value then
-- 		local ArmyDepotCountPriceID = self.ArmyDepotCountPriceCfg.Value[1]
-- 		self.CounterGetItemsAllPrice = CounterMgr:GetCounterCurrValue(ArmyDepotCountPriceID)
-- 		self.MaxGetItemsAllPrice = CounterMgr:GetCounterLimit(ArmyDepotCountPriceID)
-- 	end
-- end

-- function ArmyDepotPanelVM:GetCounterGetItemsAllPrice()
-- 	if self.CounterGetItemsAllPrice then
-- 		return self.CounterGetItemsAllPrice
-- 	else
-- 		return 0
-- 	end
-- end

-- function ArmyDepotPanelVM:GetMaxGetItemsAllPrice()
-- 	if self.MaxGetItemsAllPrice then
-- 		return self.MaxGetItemsAllPrice
-- 	else
-- 		return 0
-- 	end
-- end

function ArmyDepotPanelVM:SetTextTitle()
	-- LSTR string:背包
	self.TitleNameText = LSTR(910209)
	--self.SubTitleText = self:IsItemTab() and BagDefine.ItemTabs[self.TabIndex].Name or BagDefine.EquipTabs[self.TabIndex].Name
end

function ArmyDepotPanelVM:OnReset()

end

function ArmyDepotPanelVM:OnBegin()

end

function ArmyDepotPanelVM:OnEnd()

end

function ArmyDepotPanelVM:OnShutdown()

end

function ArmyDepotPanelVM:IsItemTab()
	return self.TabType == BagMainType.Item
end

function ArmyDepotPanelVM:IsEquipTab()
	return self.TabType == BagMainType.Equip
end

function ArmyDepotPanelVM:SetTabToItem()
	self.TabType = BagMainType.Item
	self:SetCurTabIndex(1)
end

function ArmyDepotPanelVM:SetTabToEquip()
	self.TabType = BagMainType.Equip
	self:SetCurTabIndex(1)
end

function ArmyDepotPanelVM:SetCurTabIndex(Index)
	self.TabIndex = Index
	self:UpdateTabInfo()
	self:SetCurItemIndex(1)

end

function ArmyDepotPanelVM:GetDepotPageVM()
    return self.ArmyDepotPageVM
end

--------------- 背包列表处理 start---------------
function ArmyDepotPanelVM:SetCurItemIndex(Index)
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.Item then
		CurItemVM:SetItemSelected(false)
	end

	local ClickedItemVM = self.CurrentItemVMList:Get(Index)
	if ClickedItemVM and ClickedItemVM.Item then
		ClickedItemVM:SetItemSelected(true)
	end

	self.ItemIndex = Index
end


function ArmyDepotPanelVM:UpdateTabInfo()

	local CurTabItem = self:GetCurTabItemList()
	local BagCapacity = BagMgr:GetBagLeftNum()
	--_G.UE.FProfileTag.StaticEnd()
	local ItemNum = #CurTabItem
	if ItemNum < self.CurNeedLoadItemNum then
		if ItemNum + BagCapacity < self.CurNeedLoadItemNum then
			CurTabItem = self:FillCapacityByEmptyItem(CurTabItem, BagCapacity)
		else
			local EmptyItemNum = self.CurNeedLoadItemNum - ItemNum
			CurTabItem = self:FillCapacityByEmptyItem(CurTabItem, EmptyItemNum)
		end
	elseif ItemNum > self.CurNeedLoadItemNum then
		CurTabItem[ self.CurNeedLoadItemNum + 1] = nil
	end
	--self.CurrentItemVMList.UpdateVMParams = {IsShowCanRecovery = self.IsShowCanRecovery, IsAllowDoubleClick = self.IsAllowDoubleClick}
	self.CurrentItemVMList.UpdateVMParams = {CurloadNum = self.CurNeedLoadItemNum}
	self.CurrentItemVMList:UpdateByValues(CurTabItem)
	
end

--- 显示到底了，添加Item
function ArmyDepotPanelVM:UpdateTabInfoByShowEnd()
	local Capacity = BagMgr.Capacity
	if Capacity == nil then
		local CurTabItem = self:GetCurTabItemList()
		local BagCapacity = BagMgr:GetBagLeftNum()
		Capacity = #CurTabItem + BagCapacity
	end

	---显示完全，不执行
	if Capacity and Capacity <= self.CurNeedLoadItemNum then
		return
	elseif Capacity == nil then
		_G.FLOG_ERROR("无法获取到背包数量数据")
		return
	end
	self.CurNeedLoadItemNum = self.CurNeedLoadItemNum + self.AddLoadItemNum
	self.EmptyItemCache.CurloadNum = self.CurNeedLoadItemNum
	self:UpdateTabInfo()
end

function ArmyDepotPanelVM:FillCapacityByEmptyItem(ItemList, FillCapacity)

	local ResultList = ItemList or {}
	local ItemLen = #ResultList
	for i = 1, FillCapacity do
		ResultList[ItemLen + i] = self.EmptyItemCache
	end
	return ResultList
end

-- function ArmyDepotPanelVM:UpdateTabInfo()
-- 	local CurTabItem, ConsumeBagCount = self:GetCurTabItemList()
-- 	self:SetCurItemIndex(1)
-- 	--self.CurrentItemVMList:UpdateByValues(CurTabItem, ArmyDepotPanelVM.SortBagItemVMPredicate)
-- 	--self:UpdateRecoverySelected()

-- 	--显示空格子
-- 	--self:AppendEmptyItem(BagMgr.Capacity - ConsumeBagCount)
-- end

function ArmyDepotPanelVM:GetCurTabItemList()
	local AllItemList = BagMgr.ItemList
	local Length = #AllItemList
	local ItemList = {}
	local ConsumeBagCount = 0
	local ItemType = self:IsItemTab() and ArmyDefine.ItemTabs[self.TabIndex].Type or ArmyDefine.EquipTabs[self.TabIndex].Type
	for i = 1, Length do
		local Item = AllItemList[i]
		local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
		if Cfg then
			if ItemType == ArmyDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL then
				if not ItemUtil.CheckIsEquipment(Cfg.Classify) then
					table.insert(ItemList, Item)
					if Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
						ConsumeBagCount = ConsumeBagCount + 1
					end
				end
			elseif ItemType == ArmyDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL then
				if ItemUtil.CheckIsEquipment(Cfg.Classify) then
					table.insert(ItemList, Item)
					if Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
						ConsumeBagCount = ConsumeBagCount +1
					end
				end
			elseif ItemType == ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK then
				if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
					table.insert(ItemList, Item)
				end
			elseif ItemType == Cfg.Classify then
				table.insert(ItemList, Item)
				if Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
					ConsumeBagCount = ConsumeBagCount +1
				end
			end
		end
	end
	---同步背包优化，不需要排序了
	--table.sort(ItemList, BagMgr.SortBagItemPredicate)
	return ItemList, ConsumeBagCount
end

--- 保持和背包一致
-- function ArmyDepotPanelVM.SortBagItemVMPredicate(Left, Right)
-- 	local  LeftNew = BagMgr.NewItemRecord[Left.GID] == true
-- 	local  RightNew = BagMgr.NewItemRecord[Right.GID] == true
-- 	if LeftNew ~= RightNew then
-- 		return LeftNew
-- 	end

-- 	if Left.ResID ~= Right.ResID then
-- 		--无论升序降序 ResID小的排前面
-- 		return Left.ResID < Right.ResID
-- 	end

-- 	if Left.Num ~= Right.Num then
-- 		--无论升序降序 数量多的排前面
-- 		return Left.Num > Right.Num
-- 	end

-- 	if Left.GID ~= Right.GID then
-- 		--无论升序降序 GID小的排前面
-- 		return Left.GID < Right.GID

-- 	end

-- 	return false
-- end

function ArmyDepotPanelVM:GetCurItem()
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM == nil then
		return nil
	end

	return CurItemVM.Item
end

-- 空格子的填充 空格子统一用一个vm
function ArmyDepotPanelVM:InitBagItemCache(EmptyGridNumber)
	-- local Length = #self.CacheItemVM
	-- if Length == EmptyGridNumber then
	-- 	return
	-- end
	-- for i = Length, EmptyGridNumber  do
	-- 	if self.CacheItemVM[i] == nil then
	-- 		self.CacheItemVM[i] = self.EmptyItemCache
	-- 	end
	-- end
end

function ArmyDepotPanelVM:SetBagAllItem(GridNumber)
	local Length = self.CurrentItemVMList:Length()
	if Length == GridNumber then
		return
	end

	local CacheLength = #self.CacheItemVM
	if GridNumber > CacheLength then
		for i = CacheLength, GridNumber do
			if self.CacheItemVM[i] == nil then
				self.CacheItemVM[i] = self.EmptyItemCache
			end
		end
	end

	if Length > GridNumber then
		for i = GridNumber, Length do
			self.SlotItemVM[i + 1] = nil
		end
	else
		for i = Length, GridNumber do
			self.SlotItemVM[i] = self.CacheItemVM[i]
		end
	end

	self.CurrentItemVMList:Update(self.SlotItemVM)
end

function ArmyDepotPanelVM:UpdateItemListCD(GroupID, EndFreezeTime, FreezeCD)
	for i = 1, self.CurrentItemVMList:Length() do
		local ItemVM = self.CurrentItemVMList:Get(i)
		if ItemVM.IsValid then
			ItemVM:UpdateItemCD(GroupID, EndFreezeTime, FreezeCD)
		end
	end
end
--------------- 背包列表处理 end---------------

function ArmyDepotPanelVM:UpdatePanelInfo()
    self:UpdateTabInfo()
    self.ArmyDepotPageVM:OnItemUpdate()
end

--- 权限变更检测
function ArmyDepotPanelVM:UpdateDepotPermissionsStatus()
	local AvailableList = {}
	local IsAllowedRename = ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.GPT_EDIT_STORE_NAME)
	local StoreNum = ArmyMgr:GetArmyStoreMaxCount()
	for ID = 1, StoreNum do
		--- 权限收敛，按等级解锁数量，ID代表第几个仓库
		local Groupcfg = GroupStoreCfg:FindCfgByKey(ID)
		if Groupcfg and Groupcfg.UsePermissionId then
			local IsAvailable = ArmyMgr:GetSelfIsHavePermisstion(Groupcfg.UsePermissionId)
			if IsAvailable then
				table.insert(AvailableList, Groupcfg.ID)
			end
		end
	end
	---重命名权限被取消
	if self.IsAllowedRename == true and IsAllowedRename == false then
		if UIViewMgr:IsViewVisible(UIViewID.ArmyDepotRename) then
			UIViewMgr:HideView(UIViewID.ArmyDepotRename)
			-- LSTR string:命名权限被取消
			MsgTipsUtil.ShowTips(LSTR(910089))
		end
	end
	--- 金币权限判断
	self.ArmyDepotPageVM:SetIsGoldDepotPerm(ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.GroupPermissionTypeMoneyBag))
	--self.ArmyDepotPageVM:SetIsGoldDepotPerm(true)
	self.IsAllowedRename = IsAllowedRename
	self.AvailableListDepotList = AvailableList
end

function ArmyDepotPanelVM:GetIsAllowedRename()
	return self.IsAllowedRename
end

function ArmyDepotPanelVM:GetAvailableListDepotList()
	return self.AvailableListDepotList
end

---@param Index 仓库下标
function ArmyDepotPanelVM:IsAvailableDepot(Index)
	local AvailableListDepotList = self:GetAvailableListDepotList()
	local IsAvailable = false
	for _, DepotIndex in ipairs(AvailableListDepotList) do
		if DepotIndex == Index then
			IsAvailable = true
			break
		end
	end
	return IsAvailable
end

---@param Index 仓库下标
function ArmyDepotPanelVM:IsAvailableCurDepot()
	local AvailableListDepotList = self:GetAvailableListDepotList()
	local CurIndex = self.ArmyDepotPageVM:GetCurDepotIndex()
	local IsAvailable = false
	for _, DepotIndex in ipairs(AvailableListDepotList) do
		if DepotIndex == CurIndex then
			IsAvailable = true
			break
		end
	end
	return IsAvailable
end

function ArmyDepotPanelVM:UpdateArmyMoneyStoreData(TotalNum, IsAnimPlay)
	self.ArmyDepotPageVM:SetArmyMoneyStoreNum(TotalNum, IsAnimPlay)
end



return ArmyDepotPanelVM
