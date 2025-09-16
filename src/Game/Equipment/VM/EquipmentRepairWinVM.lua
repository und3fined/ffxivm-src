local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
-- local ProtoCommon = require("Protocol/ProtoCommon")

local ScoreMgr = require("Game/Score/ScoreMgr")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentMgr = _G.EquipmentMgr
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local EquipmentSlotItemVM = require("Game/Equipment/VM/EquipmentSlotItemVM")
local EquipmentRepairItemVM = require("Game/Equipment/VM/EquipmentRepairItemVM")
local EquipmentUtil = require("Game/Equipment/EquipmentUtil")

---@class EquipmentRepairWinVM : UIViewModel
local EquipmentRepairWinVM = LuaClass(UIViewModel)

local PriceState =
{
	Adequate = 1,
	Inadequate = 2,
}

local PriceColorMap = 
{
	[PriceState.Adequate] = "FFFFFFFF",
	[PriceState.Inadequate] = "F80003FF",
}

function EquipmentRepairWinVM:Ctor()
	self.RepairItemVMList = nil
	self.Balance = 0
	self.TotalPrice = 0
	self.TotalPriceColor = PriceColorMap[PriceState.Adequate]
	self.FormattedTotalPrice = ""
    self.bCanRepair = false
	self.SelectedGID = 0
	self.ScoreType = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
end

function EquipmentRepairWinVM.SortComparison(Left, Right)
    local LeftEndureDeg = Left.EndureDeg
    local RightEndureDeg = Right.EndureDeg

    -- 按耐久度从低到高
    if LeftEndureDeg ~= RightEndureDeg then
        return LeftEndureDeg < RightEndureDeg
    end

	-- 按装备位显示顺序
	return EquipmentUtil.SortComparison(Left.Part, Right.Part)
end

--把RepairItemVMList数据更新到最新
function EquipmentRepairWinVM:RepairSuccUpdate(ListGID)
    local TempMap = {}
    for Key,Value in pairs(ListGID) do
        TempMap[Value] = 1
    end

    local TotalPrice = self.TotalPrice
    for _, EquipmentSlotItemVM in pairs(self.RepairItemVMList) do
        if TempMap[EquipmentSlotItemVM.GID] ~= nil then
            local EquipmentCfgData = EquipmentCfg:FindCfgByEquipID(EquipmentSlotItemVM.ResID)
            local ItemCfgData = ItemCfg:FindCfgByKey(EquipmentSlotItemVM.ResID)
            TotalPrice = TotalPrice - EquipmentUtil.GenRepairPrice(EquipmentSlotItemVM.ProgressValue * 100,
				EquipmentCfgData.RepairWeight, ItemCfgData.ItemLevel)

            EquipmentSlotItemVM.ProgressValue = 1.0
        end
	end
    self.TotalPrice = TotalPrice
end

function EquipmentRepairWinVM:UpdateData()
    local ItemList = EquipmentVM.ItemList
    if nil == ItemList then
		local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
		EquipmentMgr:OnEquipInfo(RoleDetail.Equip)
		ItemList = EquipmentVM.ItemList
		if nil == ItemList then
			return
		end
	end

    local RepairItemVMList = {}
    local TotalPrice = 0
    for Key, Item in pairs(ItemList) do
        local RepairItemVM = self:GenRepairItemVM(Item, Key)
		if nil ~= RepairItemVM then
			RepairItemVMList[#RepairItemVMList + 1] = RepairItemVM
			TotalPrice = TotalPrice + RepairItemVM.Price
		end
	end
    self:UpdateTotalPrice(TotalPrice)
    -- 排序
    table.sort(RepairItemVMList, EquipmentRepairWinVM.SortComparison)
    self.RepairItemVMList = RepairItemVMList
end

function EquipmentRepairWinVM:GenRepairItemVM(Item, Part)
	if nil == Item then
		return nil
	end
	local ItemCfgData = ItemCfg:FindCfgByKey(Item.ResID)
    local EquipCfgData = EquipmentCfg:FindCfgByEquipID(Item.ResID)
	if nil == ItemCfgData or nil == EquipCfgData then
		return nil
	end

	local RepairItemVM = EquipmentRepairItemVM.New()
	local SlotItemVM = EquipmentSlotItemVM.New()
    SlotItemVM:SetPart(Part, Item.ResID, Item.GID)
    SlotItemVM.bBtnVisibel = false
	SlotItemVM.bShowProgress = false
	RepairItemVM.Part = Part
	RepairItemVM.GID = Item.GID
	RepairItemVM.bSelected = self.SelectedGID == Item.GID
    RepairItemVM.SlotItemVM = SlotItemVM
	RepairItemVM.EquipName = ItemCfg:GetItemName(Item.ResID)
	RepairItemVM:SetEndureDeg(math.floor(SlotItemVM.ProgressValue * 100))
	RepairItemVM:SetDiscount(self:GetDiscount(EquipCfgData))
	local RawPrice = EquipmentUtil.GenRepairPrice(RepairItemVM.EndureDeg, EquipCfgData.RepairWeight, ItemCfgData.ItemLevel)
	RepairItemVM:SetPrice(math.ceil(RawPrice * (1.0 - RepairItemVM.Discount / 100.0)))
    return RepairItemVM
end

function EquipmentRepairWinVM:UpdateTotalPrice(Price)
	self.TotalPrice = Price
	self.FormattedTotalPrice = ScoreMgr.FormatScore(Price)
	local bBalanceAdequate = Price <= ScoreMgr:GetScoreValueByID(self.ScoreType)
	self.bCanRepair = Price > 0 and bBalanceAdequate
	self.TotalPriceColor = bBalanceAdequate and PriceColorMap[PriceState.Adequate] or PriceColorMap[PriceState.Inadequate]
end

function EquipmentRepairWinVM:GetDiscount(EquipCfgData)
	local RepairProf = EquipCfgData.RepairProf
    local ProfData = EquipmentMgr:GetEnabledProf(RepairProf)
    local RepairProfCurLevel = ProfData and ProfData.Level or 0
    local RepairProfLevel = EquipCfgData.RepairProfLevel
    local RepairProfRatio = EquipCfgData.RepairProfRatio
    local bRepairProfLevelEnough = ProfData ~= nil and RepairProfCurLevel >= RepairProfLevel

	local Discount = bRepairProfLevelEnough and (10000 - RepairProfRatio) / 100 or 0
	return Discount
end

function EquipmentRepairWinVM:FindIndexByGID(GID)
    if self.RepairItemVMList == nil then return 1 end
    for i = 1, #self.RepairItemVMList do
        local ViewModel = self.RepairItemVMList[i]
        if ViewModel.GID == GID then
            return i
        end
    end
    return 1
end

function EquipmentRepairWinVM:FindRepairItemVMByGID(GID)
    if self.RepairItemVMList == nil then return nil end
    for i = 1, #self.RepairItemVMList do
        local ViewModel = self.RepairItemVMList[i]
        if ViewModel.GID == GID then
            return ViewModel
        end
    end
    return nil
end

function EquipmentRepairWinVM:GetAllNeedRepairGIDs()
    if self.RepairItemVMList == nil then return nil end
    local GIDs = {}
    for i = 1, #self.RepairItemVMList do
        local RepairItemVM = self.RepairItemVMList[i]
		if RepairItemVM.EndureDeg < 100 then
        	GIDs[#GIDs + 1] = RepairItemVM.GID
		end
    end
    return GIDs
end

function EquipmentRepairWinVM:UpdateRepair(InResID, InGID, EndureDeg)
    self.ResID = InResID
    self.GID = InGID

    local EquipmentCfgData = EquipmentCfg:FindCfgByEquipID(InResID)
    local ItemCfgData = ItemCfg:FindCfgByKey(InResID)
    self.EndureDeg = EndureDeg
    self.bNeedRepair = EndureDeg >= 100
    self.EndureDegProgress = EndureDeg/100.0
    self.OtherEndureDegProgress = 1.0 - self.EndureDegProgress
    
    self.RepairProf = EquipmentCfgData.RepairProf
    local ProfDetail = EquipmentMgr:GetEnabledProf(self.RepairProf)
    self.RepairProfCurLevel = ProfDetail and ProfDetail.Level or 0

    local RepairProfName = RoleInitCfg:FindRoleInitProfName(self.RepairProf)
    local RepairProfLevel = EquipmentCfgData.RepairProfLevel
    self.RepairProfRatio = EquipmentCfgData.RepairProfRatio
    --绿色"00FD2BFF" --红色f80003
    self.bRepairProfLevelEnough = ProfDetail ~= nil and self.RepairProfCurLevel >= RepairProfLevel
    self.RepairProfLevelColor = self.bRepairProfLevelEnough and "00FD2BFF" or "B33939FF"

    self.RepairProfOpacity = self.bRepairProfLevelEnough and 1.0 or 0.5
    self.RepairProfTips = string.format(_G.LSTR(1050003), RepairProfName, RepairProfLevel)
    self.RepairProfSubTips = string.format(_G.LSTR(1050021), (10000-self.RepairProfRatio)/100)
    self.RepairProfLevelText = string.format("%d/%d", self.RepairProfCurLevel, RepairProfLevel)
    
    self.OriginalPrice = EquipmentUtil.GenRepairPrice(EndureDeg, EquipmentCfgData.RepairWeight, ItemCfgData.ItemLevel)
    self.CurlPrice = self.bRepairProfLevelEnough and _G.math.ceil(self.OriginalPrice*self.RepairProfRatio/10000) or self.OriginalPrice
end

return EquipmentRepairWinVM