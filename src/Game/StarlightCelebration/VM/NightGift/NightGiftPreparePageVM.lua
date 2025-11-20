local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local UIBindableList = require("UI/UIBindableList")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local NightGiftItemVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftItemVM")
local NightGiftSlotVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftSlotVM")

local ItemCfg = require("TableCfg/ItemCfg")
local BagMainVM = require("Game/NewBag/VM/BagMainVM")
local OpsStarlightDefine = require("Game/StarlightCelebration/OpsStarlightDefine")
local BagDefine = require("Game/Bag/BagDefine")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")

local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE

local BagMgr = _G.BagMgr

local LSTR = _G.LSTR
---@class NightGiftPreparePageVM : UIViewModel
local NightGiftPreparePageVM = LuaClass(UIViewModel)

---Ctor
function NightGiftPreparePageVM:Ctor()
    self.ItemNameText = nil
    self.EmptyVisible = nil

    self.DescribeText = nil
	self.BlessingText = nil
	self.BtnFinishEnabled = nil

    self.IsToggleChecked = true
    self.BagGiftList = {}
	self.GiftList = {}

	self.EditQuantityVisible = nil
	self.CurGiftItem = nil
	self.BtnInfoVisible = nil


    self.PublicItemVMList = self:ResetBindableList(self.PublicItemVMList, NightGiftItemVM)
    self.CurrentItemVMList = UIBindableBagSlotList.New(BagSlotVM, {IsShowCanRecovery = true, IsShowNewFlag = false, IsMaskClose = true})
	self.NightGiftItemVMList = UIBindableList.New(NightGiftSlotVM)
end

function NightGiftPreparePageVM:UpdatePreparePageInfo()
    self:UpdateBagInfo()
	self:UpdateGiftItemList()
end

function NightGiftPreparePageVM:UpdateBagInfo()
    self.PublicItemVMList:UpdateByValues(self:GetTabMenuList())
    self.TabIndex = 1
    local TabVM = self.PublicItemVMList:Get(self.TabIndex)
    TabVM.bSelect = _G.UE.ESlateVisibility.Visible
    self:UpdateItemListInfo()
	self:UpdateBagGiftInfo()
end

function NightGiftPreparePageVM:GetIsChecked()
    return self.IsToggleChecked
end

function NightGiftPreparePageVM:SetIsChecked(IsChecked)
    self.IsToggleChecked = IsChecked
    self:UpdateBagInfo()
end

function NightGiftPreparePageVM:GetTabMenuList()
	local ItemTabs = {}
	if self.IsToggleChecked  then
		for _, Value in ipairs(BagDefine.ItemTabs) do
			if Value.Type ~= ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK then
				table.insert(ItemTabs, Value)
			end
		end
	else
		return BagDefine.EquipTabs
	end

	return ItemTabs
end

function NightGiftPreparePageVM:UpdateItemListInfo()
	
	local ItemList = {}
	ItemList = BagMgr:FilterItemByCondition(function (Item)
	
		if Item.IsBind == false then
			local ItemType = self.IsToggleChecked and BagMainVM:GetItemTabType(self.TabIndex) or BagMainVM:GetEquipTabType(self.TabIndex)
			local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
			if Cfg then
				if ItemType == BagDefine.ITEM_CLASSIFY_TYPE_ITEM_ALL then
					if not ItemUtil.CheckIsEquipment(Cfg.Classify) then
						if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY or Cfg.Classify ~= ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_NONE then
							return true
						end
					end
				elseif ItemType == BagDefine.ITEM_CLASSIFY_TYPE_EQUIP_ALL then
					if ItemUtil.CheckIsEquipment(Cfg.Classify) then
						return true
					end
				elseif ItemType == ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK then
					if Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
						return true
					end
				elseif ItemType == Cfg.Classify then
					return true
				end
			end
		end
		return false
	end)

	local Capacity = math.ceil(#ItemList/4) * 4 > 28  and math.ceil(#ItemList/4) * 4 or 28
	
	ItemList = BagMainVM:FillCapacityByEmptyItem(ItemList, Capacity - #ItemList)

	self.CurrentItemVMList:UpdateByValues(ItemList)

end

function NightGiftPreparePageVM:OnSelectChangedItem(Index, ItemData, ItemView)
    if self.TabIndex then
        local TabVM = self.PublicItemVMList:Get(self.TabIndex)
        TabVM.bSelect = _G.UE.ESlateVisibility.HitTestInvisible
    end

    local CurTabVM = self.PublicItemVMList:Get(Index)
    CurTabVM.bSelect = _G.UE.ESlateVisibility.Visible
    self.TabIndex = Index

    self:UpdateItemListInfo()
	self:UpdateBagGiftInfo()
end

function NightGiftPreparePageVM:UpdateGiftSelected()
	for i = 1, self.CurrentItemVMList:Length() do
		local ItemVM = self.CurrentItemVMList:Get(i)
		if ItemVM.IsValid then
			ItemVM:UpdateRecoverySelected(self.BagGiftList, true)
		end
	end
end

function NightGiftPreparePageVM:AddItemToGiftList(ItemGID, Item)

	if self.BagGiftList[ItemGID] == nil then
		if #self.GiftList >= OpsStarlightDefine.GiftMaxNum then
			_G.MsgTipsUtil.ShowTips(LSTR(1700067))
			return false
		end
		self.BagGiftList[ItemGID] = Item
		local GiftItem = ItemUtil.CreateItem(Item.ResID, 1)
		GiftItem.GID = ItemGID
		table.insert(self.GiftList, GiftItem)
		self.CurGiftItem = GiftItem
	else
		self.CurGiftItem = self:GetGiftItemByGID(ItemGID)
	end

	self:UpdateBagGiftInfo()
	self:UpdateGiftItemList()

	return true
end

function NightGiftPreparePageVM:UpdateBagGiftInfo()
	self:UpdateGiftSelected()
	if self.CurGiftItem then
		self.ItemNameText = ItemUtil.GetItemName(self.CurGiftItem.ResID)
		self.EditQuantityVisible = true
		self.BtnFinishEnabled = true
		self.BtnInfoVisible = true
	else
		self.ItemNameText = LSTR(1700024)
		self.EditQuantityVisible = false
		self.BtnFinishEnabled = false
		self.BtnInfoVisible = false
	end

end

function NightGiftPreparePageVM:RemoveItemFromGiftList(ItemGID)
	if self.BagGiftList[ItemGID] then
		self.BagGiftList[ItemGID] = nil

		for index, value in ipairs(self.GiftList) do
			if value.GID == ItemGID then
				table.remove(self.GiftList, index)
				break
			end
		end

	end

	self.CurGiftItem = self:GetNextGiftItem()
	self:UpdateBagGiftInfo()
	self:UpdateGiftItemList()
end

function NightGiftPreparePageVM:GetGiftItemByGID(GID)
	for _, Value in ipairs(self.GiftList) do
		if Value.GID == GID then
			return Value
		end
	end
	return nil
end  

function NightGiftPreparePageVM:GetNextGiftItem()
	if self.GiftList and #self.GiftList > 0 then
		return self.GiftList[#self.GiftList]
	end

	return nil
end

function NightGiftPreparePageVM:UpdateGiftItemList()
	local ItemList = {}
	for i = 1, OpsStarlightDefine.GiftMaxNum do
		if i <= #self.GiftList then
			table.insert(ItemList, self.GiftList[i])
		else
			table.insert(ItemList, {})
		end
	end

	self.NightGiftItemVMList:UpdateByValues(ItemList) 
	self.DescribeText = string.format(LSTR(1700027), string.format("%d/%d", #self.GiftList, OpsStarlightDefine.GiftMaxNum))
end

function NightGiftPreparePageVM:ClearData()
	self.BagGiftList = {}
	self.GiftList = {}
	self.CurGiftItem = nil
end


--要返回当前类
return NightGiftPreparePageVM