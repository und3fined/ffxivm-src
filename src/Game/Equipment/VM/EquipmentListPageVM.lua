local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EquipmentMgr = _G.EquipmentMgr
local EquipmentDetailItemVM = require("Game/Equipment/VM/EquipmentDetailItemVM")
local EquipmentFilterItemVM = require("Game/Equipment/VM/EquipmentFilterItemVM")
local LSTR = _G.LSTR
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemDBCfg = require("TableCfg/ItemCfg")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local ProtoCS = require("Protocol/ProtoCS")
local UIBindableList = require("UI/UIBindableList")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

FilterType = 
{
    All = 1,
    Useable = 2,
    UnUseable = 3,
}

local FilterName = 
{
    [FilterType.All] = LSTR(1050022),
    [FilterType.Useable] = LSTR(1050045),
    [FilterType.UnUseable] = LSTR(1050013),
}

---@class EquipmentListPageVM : UIViewModel
local EquipmentListPageVM = LuaClass(UIViewModel)

function EquipmentListPageVM:Ctor()
    self.Part = nil
    self.IconPath = nil
    self.PartName = nil
    self.PartCount = 0
	-- self.CachedItemVMList = {}
    -- self.ItemVMList = {}
	self.ItemBindableList = UIBindableList.New(EquipmentDetailItemVM)
    self.ProfID = nil
    self.bEmpty = true
    self.SelectIndex = nil
    self.lstEquipmentFilterItemVM = nil
	self.FilterTypeList = nil
    self.FilterType = FilterType.All
    self.FilterName = FilterName[self.FilterType]
end

function EquipmentListPageVM:UpdateList()
    self:GenListByFilterType(self.FilterType)
end

function EquipmentListPageVM:SetFilter(InFilterType, bForceUpdateList)
	local OldFilterType = self.FilterType
    self.FilterType = InFilterType
    if (self.FilterType) then
        self.FilterName = FilterName[self.FilterType]
    end
	if OldFilterType ~= self.FilterType or bForceUpdateList then
		self:GenListByFilterType(self.FilterType)
	end
end

---@param InPart ProtoCommon.equip_part
function EquipmentListPageVM:SetPart(InPart, ProfID)
    self.Part = InPart
    self.ProfID = ProfID

	self.IconPath = EquipmentMgr:GetPartIcon(InPart)
    self.PartName = EquipmentMgr:GetPartName(InPart)

	self:GenFilterTypes()

    self:SetFilter(FilterType.All, true)
end

function EquipmentListPageVM:Filter(InFilterType, Item)
    local bCanEquip, Reason = EquipmentMgr:CanEquiped(Item.ResID)
    if bCanEquip == false and Reason ~= 3 then
        --职业、种族、性别不符合
        return false
    end
    if InFilterType == FilterType.All then
        return true
    end
    if InFilterType == FilterType.Useable and bCanEquip == true then
        return true
    end
    if InFilterType == FilterType.UnUseable and bCanEquip == false then
        return true
    end
    return false
end

function EquipmentListPageVM:GenListByFilterType(InFilterType)
    local BagItemList = EquipmentMgr:GetEquipmentsByPart(self.Part, self.ProfID)
    local EquipedItem = EquipmentMgr:GetEquipedItemByPart(self.Part)
    local EquipedGID = EquipedItem and EquipedItem.GID or 0
	local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_EQUIPMENT_MAGIC_INLAY_ID)
	local Finish = _G.NewTutorialMgr:IsSubGroupComplete(Cfg.Value[2])
	local TutorialState = _G.NewTutorialMgr:GetTutorialState()
	local SpecialItem = nil
	local AllItemList = {}
	for _, Item in ipairs(BagItemList) do
		if EquipedGID ~= Item.GID and self:Filter(InFilterType, Item) then
			if Item.ResID == Cfg.Value[1] then
				if Finish then
					--开启新手引导
					table.insert(AllItemList, Item)
				else
					if TutorialState then
						SpecialItem = Item
					else
						table.insert(AllItemList, Item)
					end
				end
			else
				table.insert(AllItemList, Item)
			end
		end
	end
	
    local function Sort(Left, Right)
        local LeftCfg = ItemDBCfg:FindCfgByKey(Left.ResID)
        local RightCfg = ItemDBCfg:FindCfgByKey(Right.ResID)

        --物品等级
        if LeftCfg.ItemLevel ~= RightCfg.ItemLevel then
            return LeftCfg.ItemLevel > RightCfg.ItemLevel
        end

        ---装备等级
        if LeftCfg.Grade ~= RightCfg.Grade then
            return LeftCfg.Grade > RightCfg.Grade
        end
        
        if Left.ResID ~= Right.ResID then
            return Left.ResID < Right.ResID
        end
    
        local LeftEndureDeg = Left.Attr.Equip.EndureDeg
        local RightEndureDeg = Right.Attr.Equip.EndureDeg
        if LeftEndureDeg ~= RightEndureDeg then
            return LeftEndureDeg > RightEndureDeg
        end

        return Left.ResID < Right.ResID
    end
	table.sort(AllItemList, Sort)

	if nil ~= EquipedItem and self:Filter(InFilterType, EquipedItem) then
		-- 已装备的放在第一位
		table.insert(AllItemList, 1, EquipedItem)
	end

	--新手引导未完成，魔晶石装备放在第一位
	if SpecialItem then
		table.insert(AllItemList, 1, SpecialItem)
	end

	self.ItemBindableList:Clear()
	local function GenDetailItemVMList()
		for Index, Item in ipairs(AllItemList) do
			local Cfg = ItemDBCfg:FindCfgByKey(Item.ResID)
			if nil ~= Cfg then
				local bIsTaslkItem = _G.EquipmentMgr:CheckIsQuestTrackItem(self.Part, Item.ResID, Cfg.ItemLevel)
				self.ItemBindableList.UpdateVMParams = {Part = self.Part, bIsTaslkItem = bIsTaslkItem}
				self.ItemBindableList:AddByValue(Item)
				if nil ~= self.GIDToSelect then
					if self.GIDToSelect == Item.GID then
						self.SelectIndex = 0 -- 保证选中成功触发
						self.SelectIndex = Index
					end
				elseif Index == 1 then
					self.SelectIndex = 0 -- 保证选中成功触发
					self.SelectIndex = EquipedItem and 1
				end
			end
			coroutine.yield()
		end
		self.GIDToSelect = nil
		self.bIsGeneratingList = false
	end

	local GenDetailItemVMListCO = coroutine.create(GenDetailItemVMList)

	self.ItemIndex = 1
	if nil ~= self.GenListTimerID then
		_G.TimerMgr:CancelTimer(self.GenListTimerID)
	end
	self.bIsGeneratingList = true
	self.GenListTimerID = _G.TimerMgr:AddTimer(self, function() coroutine.resume(GenDetailItemVMListCO) end,
		0, 0, #AllItemList + 1)

	-- self:InitItemBindableList(#AllItemList)

    -- for Index, Item in ipairs(AllItemList) do
	-- 	local Cfg = ItemDBCfg:FindCfgByKey(Item.ResID)
	-- 	local bIsTaslkItem = _G.EquipmentMgr:CheckIsQuestTrackItem(self.Part, Item.ResID, Cfg.ItemLevel)
	-- 	local DetailItemVM = self.ItemBindableList:Get(Index)
	-- 	DetailItemVM:UpdateVM(Item, {Part = self.Part, bIsTaslkItem = bIsTaslkItem})
    -- end

    self.PartCount = AllItemList and #AllItemList or 0
    self.bEmpty = self.PartCount <= 0
end

function EquipmentListPageVM:GenFilterTypes()
	local FilterTypes = {FilterType.All, FilterType.Useable, FilterType.UnUseable}

    local FilterTypeList = {}
    for Index, FilterType in ipairs(FilterTypes) do
        FilterTypeList[Index] = {}
		FilterTypeList[Index].Name = FilterName[FilterType]
    end

    self.FilterTypeList = FilterTypeList
end

function EquipmentListPageVM:InitItemBindableList(InCapacity)
	local CurrentCapacity = self.ItemBindableList:Length()
	if CurrentCapacity == InCapacity then
		return
	end

	local CachedCapacity = #self.CachedItemVMList
	if InCapacity > CachedCapacity then
		for Index = CachedCapacity + 1, InCapacity do
			if nil == self.CachedItemVMList[Index] then
				self.CachedItemVMList[Index] = EquipmentDetailItemVM.New()
			end
		end
	end

	if CurrentCapacity > InCapacity then
		for Index = InCapacity + 1, CurrentCapacity do
			self.ItemVMList[Index] = nil
		end
	else
		for Index = CurrentCapacity + 1, InCapacity do
			self.ItemVMList[Index] = self.CachedItemVMList[Index]
		end
	end

	self.ItemBindableList:Update(self.ItemVMList)
end

function EquipmentListPageVM:SelectByGID(GID)
	if self.bIsGeneratingList then
		self.GIDToSelect = GID
	elseif self.ItemBindableList:Length() > 0 then
		local _, Index = self.ItemBindableList:Find(function(Item) return Item.GID == GID end)
		if nil ~= Index then
			self.SelectIndex = Index
		end
	end
end

return EquipmentListPageVM