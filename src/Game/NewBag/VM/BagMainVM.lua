local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local BagDefine = require("Game/Bag/BagDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local BagMgr = require("Game/Bag/BagMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")

local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE
local LSTR = _G.LSTR

local BagMainType = {Item = 1, Equip = 2}

---@class BagMainVM : UIViewModel
local BagMainVM = LuaClass(UIViewModel)
---Ctor
function BagMainVM:Ctor()
	self.TabIndex = 1

	self.IsEquipPage = nil
	self.IsBagPage = nil
    self.EmptyItemCache = {}
	self.CurrentItemVMList = UIBindableBagSlotList.New(BagSlotVM)
	--self.CurrentItemVMList = UIBindableList.New(BagSlotVM)
	self.ItemIndex = nil
	self.CurGID = nil

	self.NoneTipsVisible = nil
	self.PanelDetailVisible = nil

	self.TitleNameText = nil
	self.SubTitleText = nil
	self.IsBag = nil
	self.OpenDepotBtnVisible = nil
	self.DepotPageVisible = nil


	--背包容量
	self.BagNotFullVisible = nil
	self.ImgBagNotFullPercent = nil
	self.BagFullVisible = nil
	self.CapacityText = nil
	self.CapacityTextColor = nil

	--批量回收
	self.IsRecovery = nil
	self.RecoveryPanelVisible = nil
	self.BtnRecoveryOffVisible = nil
	self.BtnRecoveryVisible = nil
	self.RecoveryListPanelVisible = nil
	self.BtnRecoveryOKEnabled = nil

	self.RecoveryList = {}

	self.RecoveryItemVMList = UIBindableList.New(BagSlotVM, {IsShowNewFlag = false, IsShowCanRecovery = true})
	self.RecoveryNumText = nil
	self.RecoveryGoldText = nil
	self.RecoveryScoreIcon = nil

	self.IsShowCanRecovery = nil
	self.IsAllowDoubleClick = nil

	self.ClassifyCache = {}
end

function BagMainVM:SetIsBag(IsBag)
	self.IsBag = IsBag
	self.IsAllowDoubleClick = IsBag == false
	if self.IsBag then
		self.TitleNameText = LSTR(990052)
		self.SubTitleText = self:IsItemTab() and self:GetItemTabName(self.TabIndex) or self:GetEquipTabName(self.TabIndex)
		self.OpenDepotBtnVisible = true
		self.DepotPageVisible = false
		self.BtnRecoveryOffVisible = false
		self.BtnRecoveryVisible = true

		local ClickedItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
		self:SetEmptyItem(ClickedItemVM == nil or ClickedItemVM.IsValid == false)
	else
		self.SubTitleText = LSTR(990053)
		self.OpenDepotBtnVisible = false
		self.DepotPageVisible = true
		self.NoneTipsVisible = false
		self.PanelDetailVisible = false
		self.BtnRecoveryOffVisible = true
		self.BtnRecoveryVisible = false
	end

end

function BagMainVM:GetItemTabName(TabIndex)
	if TabIndex == nil then
		return ""
	end

	if BagDefine.ItemTabs == nil then
		return ""
	end

	if TabIndex < 0 or TabIndex > #BagDefine.ItemTabs then
		return ""
	end

	return BagDefine.ItemTabs[TabIndex].Name
end

function BagMainVM:GetEquipTabName(TabIndex)
	if TabIndex == nil then
		return ""
	end
	
	if BagDefine.EquipTabs == nil then
		return ""
	end
	
	if TabIndex < 0 or TabIndex > #BagDefine.EquipTabs then
		return ""
	end

	return BagDefine.EquipTabs[TabIndex].Name
end

function BagMainVM:GetItemTabType(TabIndex)
	if TabIndex == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL
	end

	if BagDefine.ItemTabs == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL
	end

	if TabIndex < 0 or TabIndex > #BagDefine.ItemTabs then
		return BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL
	end

	return BagDefine.ItemTabs[TabIndex].Type
end

function BagMainVM:GetEquipTabType(TabIndex)
	if TabIndex == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL
	end
	if BagDefine.EquipTabs == nil then
		return BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL
	end
	
	if TabIndex < 0 or TabIndex > #BagDefine.EquipTabs then
		return BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL
	end

	return BagDefine.EquipTabs[TabIndex].Type
end

function BagMainVM:IsItemTab()
	return self.IsBagPage
end

function BagMainVM:IsEquipTab()
	return self.IsEquipPage 
end

function BagMainVM:InitShowTabIndex()
	self.IsEquipPage = false
	self.IsBagPage = true
end

function BagMainVM:SetTabToItem()
	self.IsEquipPage = false
	self.IsBagPage = true
	self:SetCurTabIndex(1)
end

function BagMainVM:SetTabToEquip()
	self.IsEquipPage = true
	self.IsBagPage = false
	self:SetCurTabIndex(1)
end

function BagMainVM:SetCurTabIndex(Index)
	self.TabIndex = Index
	local RecoveryIndex  = self:UpdateTabInfo()
	self:SetCurItem(RecoveryIndex or 1)


	if self.IsBag then
		self.SubTitleText = self:IsItemTab() and self:GetItemTabName(self.TabIndex) or self:GetEquipTabName(self.TabIndex)
	end
end

function BagMainVM:SetCurItem(Index)
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

function BagMainVM:GetCurItem()
	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item and CurItemVM.Item.GID == self.CurGID then
		CurItemVM.Item.FreezeGroup = CurItemVM.FreezeGroup
		return CurItemVM.Item
	end

	self.ItemIndex = self:UpdateItemIndexByGID(self.CurGID)

	local CurItemVM = self.CurrentItemVMList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.IsValid == true and CurItemVM.Item then
		CurItemVM.Item.FreezeGroup = CurItemVM.FreezeGroup
		return CurItemVM.Item
	end

	return nil
end

function BagMainVM:UpdateItemIndexByGID(GID)
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

function BagMainVM:UpdateTabInfo()
	--_G.UE.FProfileTag.StaticBegin("BagMainVM:GetItemList")
	local CurTabItem = self:GetCurTabItemList()
	local BagCapacity = BagMgr:GetBagLeftNum()
	--_G.UE.FProfileTag.StaticEnd()

	CurTabItem = self:FillCapacityByEmptyItem(CurTabItem, BagCapacity)

	self.CurrentItemVMList.UpdateVMParams = {IsShowCanRecovery = self.IsShowCanRecovery, IsAllowDoubleClick = self.IsAllowDoubleClick}
	self.CurrentItemVMList:UpdateByValues(CurTabItem)

	--_G.UE.FProfileTag.StaticBegin("BagMainVM:updateDate")
	if self.IsRecovery == true then
		local RecoveryIndex = nil
		for i = 1, self.CurrentItemVMList:Length() do
			local ItemVM = self.CurrentItemVMList:Get(i)
			if ItemVM.IsValid then
				local IsSelected = ItemVM:UpdateRecoverySelected(self.RecoveryList, self.IsRecovery)
				if IsSelected and RecoveryIndex == nil then
					RecoveryIndex = i
				end
			end
		end
		return RecoveryIndex
	end
	--_G.UE.FProfileTag.StaticEnd()
end

function BagMainVM:FillCapacityByEmptyItem(ItemList, FillCapacity)

	local ResultList = ItemList or {}
	local ItemLen = #ResultList
	for i = 1, FillCapacity do
		ResultList[ItemLen + i] = self.EmptyItemCache
	end
	return ResultList
end

function BagMainVM:GetRecoveryHighValueItems()
	local HighValueItems = {}
	for _, value in pairs(self.RecoveryList) do
		if BagMgr:IsHighValueItem(value) == true then
			table.insert(HighValueItems, value)
		end
	end

	return HighValueItems
end

function BagMainVM:GetRecoveryItems()
	local RecoveryItems = {}
	for _, value in pairs(self.RecoveryList) do
		table.insert(RecoveryItems, value)
	end

	return RecoveryItems
end

function BagMainVM:AddItemToRecoveryList(ItemGID, Item)
	self.RecoveryList[ItemGID] = Item
	self:UpdateRecoverySelected()

	self:UpdateRecoveryItemList()
end


function BagMainVM:RemoveItemFromRecoveryList(ItemGID)
	self.RecoveryList[ItemGID] = nil
	self:UpdateRecoverySelected()

	self:UpdateRecoveryItemList()
end

function BagMainVM:GetRecoveryListGIDs()
	local GIDList = {}
	for _, value in pairs(self.RecoveryList) do
		table.insert(GIDList, value.GID)
	end

	return GIDList
end

function BagMainVM:UpdateRecoveryItemList()
	local RecoveryArray = {}
	local RecoveryNum = 0
	local RecoveryGold = 0
	for _, value in pairs(self.RecoveryList) do
		RecoveryNum = RecoveryNum + 1

		local Cfg = ItemCfg:FindCfgByKey(value.ResID)
		if nil ~= Cfg then
			RecoveryGold = RecoveryGold + Cfg.RecoverNum * value.Num
		end

		table.insert(RecoveryArray, value)
	end

	self.RecoveryNumText = string.format("%d / %d", RecoveryNum, BagMgr.RecoveryMaxNum)
	self.RecoveryGoldText = RecoveryGold

	local ScoreData =  ScoreCfg:FindCfgByKey(BagMgr.RecoveryScoreID)
    if ScoreData then
        self.RecoveryScoreIcon = ScoreData.IconName
    end

	self.RecoveryItemVMList:UpdateByValues(RecoveryArray, BagMainVM.SortBagItemVMPredicate)

	BagMainVM.BtnRecoveryOKEnabled = RecoveryNum > 0
end

function BagMainVM:IsRecoveryNumExceedLimit()
	local RecoveryNum = 0
	for _, _ in pairs(self.RecoveryList) do
		RecoveryNum = RecoveryNum + 1
	end
	return RecoveryNum >= BagMgr.RecoveryMaxNum
end

function BagMainVM:UpdateRecoverySelected()
	for i = 1, self.CurrentItemVMList:Length() do
		local ItemVM = self.CurrentItemVMList:Get(i)
		if ItemVM.IsValid then
			ItemVM:UpdateRecoverySelected(self.RecoveryList, self.IsRecovery)
		end
	end
end

function BagMainVM:UpdateBagCapacity()
	--处理容量显示
	local Capacity = BagMgr.Capacity
	local BagCount = BagMgr:CalcBagUseCapacity()
	local LeftNum = BagMgr:GetBagLeftNum()
	self.CapacityText = string.format("%d/%d", BagCount, Capacity)
	if Capacity > 0 then
		self.ImgBagNotFullPercent = BagCount / Capacity
	end

	self.BagNotFullVisible = LeftNum > 10
	self.BagFullVisible = LeftNum <= 10
	self.CapacityTextColor = LeftNum > 10 and "d5d5d5" or "dc5868"
end


function BagMainVM:SetEmptyItem(IsEmpty)
	if self.IsBag then
		self.NoneTipsVisible = IsEmpty
		self.PanelDetailVisible = not IsEmpty
	end
end

function BagMainVM.SortBagItemVMPredicate(Left, Right)
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


function BagMainVM:GetCurTabItemList()
	local AllItemList = BagMgr.ItemList
	local Length = #AllItemList
	local ItemList = {}

	local ItemType = self:IsItemTab() and self:GetItemTabType(self.TabIndex) or self:GetEquipTabType(self.TabIndex)
	for i = 1, Length do
		local Item = AllItemList[i]
		local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
		if Cfg then
			if ItemType == BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL then
				if not ItemUtil.CheckIsEquipment(Cfg.Classify) then
					if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY or Cfg.Classify ~= ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_NONE then
						table.insert(ItemList, Item)
					end
				end
			elseif ItemType == BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL then
				if ItemUtil.CheckIsEquipment(Cfg.Classify) then
					table.insert(ItemList, Item)
				end
			elseif ItemType == ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK then
				if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
					table.insert(ItemList, Item)
				end
			elseif ItemType == Cfg.Classify then
				table.insert(ItemList, Item)
			end
		end
	end
	return ItemList
end

function BagMainVM:SetRecoveryPanelVisible(Visible)
	self.RecoveryPanelVisible = Visible
	self.IsRecovery = Visible
	self.RecoveryList = {}

	self:UpdateRecoveryItemList()
end

--要返回当前类
return BagMainVM