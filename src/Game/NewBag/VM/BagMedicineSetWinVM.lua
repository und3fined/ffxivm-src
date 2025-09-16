local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local NewBagProfessionItemVM = require("Game/NewBag/VM/NewBagProfessionItemVM")
local UIBindableList = require("UI/UIBindableList")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local MajorUtil = require("Utils/MajorUtil")
local BagMainVM = require("Game/NewBag/VM/BagMainVM")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")

local BagMgr = _G.BagMgr
local ActorMgr = _G.ActorMgr
local ProfMgr = _G.ProfMgr
---@class BagMedicineSetWinVM : UIViewModel
local BagMedicineSetWinVM = LuaClass(UIViewModel)

---Ctor
function BagMedicineSetWinVM:Ctor()
	self.MedicineBindableList = UIBindableBagSlotList.New(BagSlotVM)
	--self.MedicineBindableList = UIBindableList.New(BagSlotVM)
	self.ProfBindableList = UIBindableList.New(NewBagProfessionItemVM)
	self.ItemIndex = 1
	self.NoneTipsVisible = nil
	self.DrugTipsVisible = nil

	self.SetBtnVisible = nil
	self.ReplaceBtnVisible = nil
	self.CancelBtnVisible = nil
end

local ProfActiveSort = function(A, B)
    if A.bActive ~= B.bActive then
        return A.bActive
    end
	local ProfClassList =
    {
        ProtoCommon.class_type.CLASS_TYPE_TANK,
        ProtoCommon.class_type.CLASS_TYPE_HEALTH,
        ProtoCommon.class_type.CLASS_TYPE_NEAR,
        ProtoCommon.class_type.CLASS_TYPE_FAR,
        ProtoCommon.class_type.CLASS_TYPE_MAGIC,
        ProtoCommon.class_type.CLASS_TYPE_CARPENTER,
        ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER,
    }

	local AProfClass = RoleInitCfg:FindProfClass(A.ProfID)
	local BProfClass = RoleInitCfg:FindProfClass(B.ProfID)
	local ASort = 0
	local BSort = 0
	for Index, ProfClass in ipairs(ProfClassList) do
		if ProfClass == AProfClass then
			ASort = Index
		end

		if ProfClass == BProfClass then
			BSort = Index
		end

    end

	return ASort < BSort
end

function BagMedicineSetWinVM:SetProList()
	local ProfList = {}
	local RoleDetail = ActorMgr:GetMajorRoleDetail() or {}
    local ProfDetailList = RoleDetail.Prof and RoleDetail.Prof.ProfList or {}
	local MajorProfID = MajorUtil.GetMajorProfID()
	local ProfSpecialization = RoleInitCfg:FindProfSpecialization(MajorProfID)
    local ProfSortData = ProfMgr.GenProfTypeSortData(ProfDetailList, ProfSpecialization)
    for i, SectionData in ipairs(ProfSortData) do
        if SectionData.lst and next(SectionData.lst) then
            for _, ItemData in ipairs(SectionData.lst) do
				local ProfLevel = RoleInitCfg:FindProfLevel(ItemData.Prof)
				local ProfCfg = RoleInitCfg:FindProfForPAdvance(ItemData.Prof)
				local ProfType = RoleInitCfg:FindProfSpecialization(ItemData.Prof)
				if ProfType == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
					table.insert(ProfList, ItemData)
				else
					if ProfLevel > 0 and not ItemData.bActive and ProfCfg then
						--未解锁的有基职的特职不显示
					elseif ItemData.AdvancedProf ~= 0 and EquipmentVM.lstProfDetail[ItemData.AdvancedProf] ~= nil then
						--解锁特职的基职不显示
					else
						table.insert(ProfList, ItemData)
					end
				end
			end
        end
    end
	
	self.ProfBindableList:UpdateByValues(ProfList, ProfActiveSort)
end

function BagMedicineSetWinVM:SetSelectedProf(ProfID)
	for i = 1, self.ProfBindableList:Length() do
		local BindableProfVM = self.ProfBindableList:Get(i)
		BindableProfVM:SetSelect(BindableProfVM.ProfID == ProfID)
	end
end

function BagMedicineSetWinVM:GetMajorIndex()
	local MajorProfID = MajorUtil.GetMajorProfID()
	local MajorIndex = 0
	for i = 1, self.ProfBindableList:Length() do
		local BindableProfVM = self.ProfBindableList:Get(i)
		if BindableProfVM.ProfID == MajorProfID then
			MajorIndex = i
			break
		end
	end
	return MajorIndex
end

function BagMedicineSetWinVM:UpdateMedicineBindableList(ProfID)

	local ItemList = BagMgr:FilterItemByCondition(function (Item)
			local ItemResID = Item.ResID
			local Cfg = ItemCfg:FindCfgByKey(ItemResID)
			if Cfg and Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.CONSUMABLES_MEDICINE and Cfg.UseFunc > 0 then
				---职业类型限制
				local ClassLimit = Cfg.ClassLimit
				if ClassLimit ~= nil then
					local ProfClass = RoleInitCfg:FindProfClass(ProfID) 
			
					local bIsProfClassMatch = true
					if ClassLimit == ProtoCommon.class_type.CLASS_TYPE_COMBAT then
						bIsProfClassMatch = RoleInitCfg:FindProfSpecialization(ProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
					elseif ClassLimit == ProtoCommon.class_type.CLASS_TYPE_PRODUCTION then
						bIsProfClassMatch = RoleInitCfg:FindProfSpecialization(ProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
					elseif ClassLimit ~= ProtoCommon.class_type.CLASS_TYPE_NULL and ClassLimit ~= ProfClass then
						bIsProfClassMatch = false
					end
			
					if not bIsProfClassMatch then
						return false
					end
				end
				
				---职业限制
				local ProfLimit = Cfg.ProfLimit
				if type(ProfLimit) == "table" then
					local bHasLimit = false	---是否有职业限制
					local bProfHas = false	---ProfID是否在限制中
					for _, v in pairs(ProfLimit) do
						if v ~= ProtoCommon.prof_type.PROF_TYPE_NULL then
							bHasLimit = true
							if v == ProfID then
								bProfHas = true
								break
							end
						end
					end
					if bHasLimit == true and bProfHas == false then
						return false
					end
				end
				
				return true
			end
			return false
		end
	)

	ItemList = BagMainVM:FillCapacityByEmptyItem(ItemList, BagMgr:GetBagLeftNum())
	self.MedicineBindableList.UpdateVMParams = {ProfID = ProfID}
	self.MedicineBindableList:UpdateByValues(ItemList)
end



function BagMedicineSetWinVM:SetCurItemIndex(Index)
	local CurItemVM = self.MedicineBindableList:Get(self.ItemIndex)
	if CurItemVM and CurItemVM.Item then
		CurItemVM:SetItemSelected(false)
	end

	local ClickedItemVM = self.MedicineBindableList:Get(Index)
	self:SetEmptyItem(ClickedItemVM == nil or ClickedItemVM.IsValid == false)
	if ClickedItemVM and ClickedItemVM.IsValid == true then
		ClickedItemVM:SetItemSelected(true)
	end

	self.ItemIndex = Index
end

function BagMedicineSetWinVM:SetEmptyItem(IsEmpty)
	self.NoneTipsVisible = IsEmpty
	self.DrugTipsVisible = not IsEmpty
end

function BagMedicineSetWinVM:GetCurItem()
	local CurItemVM = self.MedicineBindableList:Get(self.ItemIndex)
	if CurItemVM == nil then
		return nil
	end

	return CurItemVM.Item
end

function BagMedicineSetWinVM:SetMedicine()
	self.SetBtnVisible = true
	self.ReplaceBtnVisible = false
	self.CancelBtnVisible = false
end

function BagMedicineSetWinVM:ReplaceMedicine()
	self.SetBtnVisible = false
	self.ReplaceBtnVisible = true
	self.CancelBtnVisible = false
end

function BagMedicineSetWinVM:CancelMedicine()
	self.SetBtnVisible = false
	self.ReplaceBtnVisible = false
	self.CancelBtnVisible = true
end

--要返回当前类
return BagMedicineSetWinVM