---
--- Author: lydianwang
--- DateTime: 2021-09-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ItemTipsFrameVM = require("Game/ItemTips/VM/ItemTipsFrameVM")
local BagMainVM = require("Game/NewBag/VM/BagMainVM")
local QuestSubmitItemVM = require("Game/Quest/VM/DataItemVM/QuestSubmitItemVM")

local ItemSubmitInfo = {}

---@param RequiredNum number
---@param NQToHQ number 需求是NQ时，此NQ物品对应的HQ物品ResID
---@return ItemSubmitInfo
function ItemSubmitInfo.New(RequiredNum, NQToHQ)
	local Object = {
		RequiredNum = RequiredNum or 1,
		NQToHQ = NQToHQ or 0,

		SubmitNum = 0,
		SubmitGIDMap = {}, -- map< uint64 GID, int32 Num >
		bHQSubmitNQ = false, -- 需求是NQ时，提交了HQ物品
	}
	setmetatable(Object, { __index = ItemSubmitInfo })
	return Object
end

---@class ItemSubmitVM : UIViewModel
local ItemSubmitVM = LuaClass(UIViewModel)

function ItemSubmitVM:Ctor()
    self.RequiredItemVMList = UIBindableList.New(QuestSubmitItemVM)
    self.OwnedItemVMList = UIBindableList.New(QuestSubmitItemVM)
    self.ItemTipsVMData = ItemTipsFrameVM

	-- 以下由业务自己实现接口填充
	self.ItemToSubmit = {}

	self.IsMagicsparNeed = false -- 是否需要魔晶石
	--self.IsNewStypeUI = true
end

---@return ItemSubmitVM
function ItemSubmitVM.CreateForQuestTarget(Target)
	if Target == nil then return nil end

	local VM = ItemSubmitVM.New()

    for i, ItemResID in ipairs(Target.RequiredItemList) do
		VM.ItemToSubmit[ItemResID] = ItemSubmitInfo.New(
			Target.RequiredNumList[i],
			Target.RequiredItemHQList[i])
	end

	VM.SubmitItem = function(VMInst, CollectItem)
		if Target then
			Target:SendFinish(CollectItem)
		end
	end

	VM:ResetData()

	return VM
end

function ItemSubmitVM:ResetData()
    for ItemResID, _ in pairs(self.ItemToSubmit) do
        self:ResetSubmitItem(ItemResID)
    end
	self.SelectedItemInfo = {
		GID = -1,
		ResID = -1,
	}
	self.bHQTipsVisible = false
end

function ItemSubmitVM:ResetSubmitItem(ItemResID)
	local SubmitInfo = self.ItemToSubmit[ItemResID]
	if SubmitInfo == nil then return end
	SubmitInfo.SubmitNum = 0
	SubmitInfo.SubmitGIDMap = {}
	SubmitInfo.bHQSubmitNQ = false
end

---@param Values table
function ItemSubmitVM:InitRequiredItem(Values)
	self.RequiredItemVMList:UpdateByValues(Values, BagMainVM.SortBagItemVMPredicate)
end

---@param Values table
function ItemSubmitVM:UpdateOwnedItem(Values)
	-- 创建VM可能会影响性能，后续考虑查找原有VM
    self.OwnedItemVMList:UpdateByValues(Values, BagMainVM.SortBagItemVMPredicate)
end

---@return bool
function ItemSubmitVM:CheckCurrItemNotEqualToVM(ItemData)
	if ItemData == nil or ItemData.GID == nil or ItemData.ResID == nil then
		return false
	end

	if self.SelectedItemInfo.GID == ItemData.GID
	and self.SelectedItemInfo.ResID == ItemData.ResID then
		return false
	end

	self.SelectedItemInfo.GID = ItemData.GID
	self.SelectedItemInfo.ResID = ItemData.ResID
	return true
end

---@return boolean
function ItemSubmitVM:CheckReadyToSubmit()
	for _, Info in pairs(self.ItemToSubmit) do
		if Info.SubmitNum < Info.RequiredNum then return false end
	end
	return true
end

function ItemSubmitVM:ResetHQTipsVisibility()
	for _, SubmitInfo in pairs(self.ItemToSubmit) do
		if SubmitInfo.bHQSubmitNQ then
            self.bHQTipsVisible = true
			return
		end
	end
    self.bHQTipsVisible = false
end

---@return table, table
function ItemSubmitVM:GetSubmitItemInfo()
	local HQSubmitNQList = {}
	local CollectItem = {}
	for _, Info in pairs(self.ItemToSubmit) do
		if Info.bHQSubmitNQ then
			table.insert(HQSubmitNQList, Info.NQToHQ)
		end
		for GID, Num in pairs(Info.SubmitGIDMap) do
			CollectItem[GID] = Num
		end
	end
	if next(CollectItem) == nil then
		CollectItem = nil
	end
    return HQSubmitNQList, CollectItem
end

---由业务实现
---@param CollectItem table
function ItemSubmitVM:SubmitItem(CollectItem)
	_G.FLOG_WARNING("ItemSubmitVM:SubmitItem not implemented!")
end

return ItemSubmitVM