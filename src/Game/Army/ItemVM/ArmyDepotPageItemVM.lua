---
--- Author: anypkvcai
--- DateTime: 2021-08-23 19:00
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ArmyDepotSlotVM = require("Game/Army/ItemVM/ArmyDepotSlotVM")
local GroupStoreIconCfg = require("TableCfg/GroupStoreIconCfg")
local GroupStoreCfg = require("TableCfg/GroupStoreCfg")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyDefine  = require("Game/Army/ArmyDefine")
local Default_Num = 0

---@class ArmyDepotPageItemVM : UIViewModel
local ArmyDepotPageItemVM = LuaClass(UIViewModel)

---Ctor
function ArmyDepotPageItemVM:Ctor()
	self.BindableListItem = UIBindableList.New(ArmyDepotSlotVM, {IsShowNewFlag = false})
	self.PageIndex = 0
	self.ItemNum = 0
	self.PageType = 0
	self.PageName = ""
	self.PageIcon = ""
	self.IconColor = "ffffffff"
	self.Capacity = 0

	self:InitItemVM()
end

function ArmyDepotPageItemVM:InitItemVM()
	Default_Num = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GroupStoreDefaultGridNum)
	for _ = 1, Default_Num do
		local ViewModel = ArmyDepotSlotVM.New()
		self.BindableListItem:Add(ViewModel)
	end
end

function ArmyDepotPageItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Index == self.PageIndex
end

---UpdateVM
---@param Value DepotSimple
function ArmyDepotPageItemVM:UpdateVM(Value)
	self.PageIndex = Value.Index
	self.ItemNum = Value.ItemNum
	self.Capacity = Value.Capacity
	local Length = self.BindableListItem:Length()
	if Length < self.Capacity then
		for _ = Length + 1, self.Capacity do
			local ViewModel = ArmyDepotSlotVM.New()
			self.BindableListItem:Add(ViewModel)
		end
	end
	self:UpdateInfo(Value.Type, Value.DepotName)
	self:UpdateIconColor()
	if Value.Items then
		self:UpdateItems(Value.Items)
	end
end

function ArmyDepotPageItemVM:UpdateItemListCD(GroupID, EndFreezeTime, FreezeCD)
	for i = 1, self.BindableListItem:Length() do
		local ItemVM = self.BindableListItem:Get(i)
		if ItemVM.IsValid then
			ItemVM:UpdateItemCD(GroupID, EndFreezeTime, FreezeCD)
		end
	end
end

function ArmyDepotPageItemVM:UpdateInfo(Type, Name)
	self.PageType = Type
	if Name == "" then
		local StoreCfg = GroupStoreCfg:FindCfgByKey(self.PageIndex)
		if StoreCfg then
            -- LSTR string:默认仓库名
            self.PageName = StoreCfg.GroupDefaultName or LSTR(910277)
        end
	else
		self.PageName = Name
	end
	local IconCfg = GroupStoreIconCfg:FindCfgByKey(Type)
	if IconCfg then
		self.PageIcon = IconCfg.Icon
	end
end

---UpdateItems
---@param Value table<number,common.Item>
function ArmyDepotPageItemVM:UpdateItems(Value)
	for i = 1, self.Capacity do
		local ViewModel = self.BindableListItem:Get(i)
		if nil ~= ViewModel then
			ViewModel:UpdateVM(Value[i])
			ViewModel:SetNoFullItemNumberStacks(self.PageIndex)
		end
	end
end

function ArmyDepotPageItemVM:UpdateItem(Pos, Item)
	local ViewModel = self.BindableListItem:Get(Pos)
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateVM(Item)
	ViewModel:SetNoFullItemNumberStacks(self.PageIndex)
end

function ArmyDepotPageItemVM:AddItem(Pos, Item)
	local ViewModel = self.BindableListItem:Get(Pos)
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateVM(Item)
	ViewModel:SetNoFullItemNumberStacks(self.PageIndex)
end

function ArmyDepotPageItemVM:RemoveItem(Pos, Item)
	local ViewModel = self.BindableListItem:Get(Pos)
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateVM(nil)
	ViewModel:SetNoFullItemNumberStacks(self.PageIndex)
end

function ArmyDepotPageItemVM:UpdateItemNum()
	local Num = 0
	local BindableListItem = self.BindableListItem
	local Length = BindableListItem:Length()
	for i = 1, Length do
		local ViewModel = BindableListItem:Get(i)
		if ViewModel.IsValid then
			Num = Num + 1
		end
	end

	self.ItemNum = Num
end

function ArmyDepotPageItemVM:GetItemCount()
	return self.ItemNum
end

function ArmyDepotPageItemVM:GetMaxItemCount()
	return self.Capacity
end

function ArmyDepotPageItemVM:OnItemUpdate()
	self:UpdateItemNum()
	self:UpdateIconColor()
end

function ArmyDepotPageItemVM:UpdateIconColor()
	self.IconColor = self:GetIconColor()
end

function ArmyDepotPageItemVM:GetIconColor()
	--绿色：66efa0
	--黄色：cdb271
	--红色：d05758

	local ItemNum = self.ItemNum
	if ItemNum <= 10 then
		return "66efa0ff"
	elseif ItemNum <= 20 then
		return "cdb271ff"
	else
		return "d05758"
	end
end

return ArmyDepotPageItemVM