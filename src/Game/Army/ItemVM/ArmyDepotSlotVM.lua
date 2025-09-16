local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local EquipmentCfg = require("TableCfg/EquipmentCfg")

local FantasyCardCfg = require("TableCfg/FantasyCardCfg")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")

local WearableState = EquipmentDefine.WearableState

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

---@class ArmyDepotSlotVM : UIViewModel
local ArmyDepotSlotVM = LuaClass(UIViewModel)

--蓝色6fbee9 红色dc5868
ArmyDepotSlotVM.WearableColorMap =
{
	[WearableState.Unwearable] = "dc5868",
	[WearableState.OtherProfWearable] = "6fbee9",
}

--[[ArmyDepotSlotVM.FantasyCardStar =
{
	[1] = "Texture2D'/Game/Assets/Icon/Quality/Tag/UI_Slot_MC_Tag_Star1.UI_Slot_MC_Tag_Star1'",
	[2] = "Texture2D'/Game/Assets/Icon/Quality/Tag/UI_Slot_MC_Tag_Star2.UI_Slot_MC_Tag_Star2'",
	[3] = "Texture2D'/Game/Assets/Icon/Quality/Tag/UI_Slot_MC_Tag_Star3.UI_Slot_MC_Tag_Star3'",
	[4] = "Texture2D'/Game/Assets/Icon/Quality/Tag/UI_Slot_MC_Tag_Star4.UI_Slot_MC_Tag_Star4'",
	[5] = "Texture2D'/Game/Assets/Icon/Quality/Tag/UI_Slot_MC_Tag_Star5.UI_Slot_MC_Tag_Star5'",
}]]--

ArmyDepotSlotVM.LeftCornerFlag =
{
	["Yes"] = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Check_png.UI_Comm_Img_Check_png'",
	["Forbid"] = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Cancel_png.UI_Comm_Img_Cancel_png'",
}

---Ctor
function ArmyDepotSlotVM:Ctor()
	self.IsShowNum = true
	self.IsShowNewFlag = true

	self.Item = nil
	self.IsValid = false

	self.GID = nil
	self.ResID = nil
	self.Num = nil
	self.NumVisible = nil

	self.Name = nil
	self.Icon = nil

	self.ItemType = nil
	self.ItemColor = nil
	self.ItemLevel = nil

	self.IsBind = false
	self.IsUnique = false

	self.IsHQ = false
	self.IsNew = false

	self.ItemQualityIcon = nil

	self.ItemCD = nil -- CD倒数text
	self.IsCD = nil --CDtext显隐
	self.IsMask = nil --遮罩显隐
	--套装
	self.IsInScheme = nil

	self.PanelBagVisible = nil
	self.IsSelect = nil

	-- 左下角图标 （标识穿戴，采集，制作）
	self.LeftCornerFlagImgIcon = nil
	self.LeftCornerFlagImgVisible = nil
	self.LeftCornerFlagImgColor = nil

	--物品回收
	self.IsShowCanRecovery = false
	self.PanelMultiChoiceVisible = nil

	--设置显示
	self.IsQualityVisible = true
	self.IconChooseVisible = false
	self.ItemLevelVisible = false

end

function ArmyDepotSlotVM:IsEqualVM(Value)
	return nil ~= Value and Value.GID == self.GID
end

function ArmyDepotSlotVM:UpdateVM(Value, Param)
	local IsValid = nil ~= Value and Value.ResID ~= nil
	self.IsValid = IsValid
	self.PanelBagVisible = IsValid
	self.Item = Value
	if not IsValid then
		---空格子传递当前加载数量
		if Value and Value.CurloadNum then
			self.CurloadNum = Value.CurloadNum
		end
		return
	end

	self:UpdateByParam(Param)

	local ValueResID = Value.ResID
	self.GID = Value.GID
	self.ResID = ValueResID
	self.Num = Value.Num

	local Cfg = ItemCfg:FindCfgByKey(ValueResID)
	if nil == Cfg then
		FLOG_WARNING("ItemVM:UpdateVM can't find item cfg, ResID =%d", ValueResID)
		return
	end

	self.Name = ItemCfg:GetItemName(ValueResID)
	self.Icon = UIUtil.GetIconPath(Cfg.IconID)

	self.IsBind = Value.IsBind
	self.IsUnique = Cfg.IsUnique > 0
	self.ItemType = Cfg.ItemType
	self.Classify = Cfg.Classify

	self.MaxPile = Cfg.MaxPile
	self.NumVisible = self.IsShowNum and (self.MaxPile > 1 or self.Num >1)
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(ValueResID)
	--新标签
	self:UpdateIsNew(Value.CreateTime)

	--套装
	self.IsInScheme = self:UpdateEquipIsInScheme(Value)

	--设置左下角图标
	self:UpdateLeftCornerFlag(ValueResID)


	---限时物品判断
	self.ExpireTime = Value.ExpireTime
	local IsTimeLimitItem =  _G.BagMgr:IsTimeLimitItem(self)
	---物品是否可存入
	local IsNoCanDeposit = Cfg.IsCanStore == false or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY or IsTimeLimitItem or self.IsBind
	--物品是否可回收标志/或者是否在CD中
	self.IsMask = (self.IsShowCanRecovery and Cfg.IsRecoverable == 0) or _G.BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil or IsNoCanDeposit
	self.IsCD = _G.BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil

	--选中标识
	self.IsSelect = false
	--回收选中标识
	self.PanelMultiChoiceVisible = false
end

function ArmyDepotSlotVM:UpdateRecoverySelected(RecoveryList)
	if self.IsShowCanRecovery and RecoveryList[self.GID] ~= nil then
		self.PanelMultiChoiceVisible = true
	else
		self.PanelMultiChoiceVisible = false
	end
end

function ArmyDepotSlotVM:UpdateByParam(Param)
	if Param == nil then
		return
	end

	if Param.IsShowNum ~= nil then
		self.IsShowNum = Param.IsShowNum
	end

	if Param.ProfID ~= nil then
		self.ProfID = Param.ProfID
	end

	if Param.IsShowCanRecovery ~= nil then
		self.IsShowCanRecovery = Param.IsShowCanRecovery
	end

	if Param.IsShowNewFlag ~= nil then
		self.IsShowNewFlag = Param.IsShowNewFlag
	end

	if Param.CurloadNum ~= nil then
		self.CurloadNum = Param.CurloadNum
	end

end

function ArmyDepotSlotVM:ClickedItemVM()
	if self.IsNew == true then
		_G.BagMgr.NewItemRecord[self.GID] = nil
		self.IsNew = false
	end
end

function ArmyDepotSlotVM:UpdateIsNew()
	if _G.BagMgr.NewItemRecord[self.GID] == true and self.IsShowNewFlag == true then
		self.IsNew = true
	else
		self.IsNew = false
	end
end

function ArmyDepotSlotVM:UpdateEquipIsInScheme(Value)
	return ItemUtil.ItemIsInScheme(Value)
end

---CheckIsEquipment
---@return boolean 是否装备
function ArmyDepotSlotVM:CheckIsEquipment()
	if self.Classify == nil then
		FLOG_ERROR("ItemVM:CheckIsEquipment ItemVM.Classify == nil ResID = %d", self.ResID)
		return -1
	end
	return ItemUtil.CheckIsEquipment(self.Classify)
end

function ArmyDepotSlotVM:SetItemSelected(IsSelected)
	self.IsSelect = IsSelected
end

function ArmyDepotSlotVM:SetItemRecoverySelected(IsSelected)
	self.PanelMultiChoiceVisible = IsSelected
end

function ArmyDepotSlotVM:UpdateLeftCornerFlag(ValueResID)
	self.LeftCornerFlagImgVisible = false
	--穿戴
	--self:SetLeftCornerFlagByWearable() Icon视觉验收不显示红叉 蓝叉
	--药品设置
	self:SetLeftCornerFlagByMedicineSet(ValueResID)
end
--穿戴标识
function ArmyDepotSlotVM:SetLeftCornerFlagByWearable()
	if self:CheckIsEquipment() then
		local CanWearable, OtherProfWearable= ItemUtil.UpdateProfRestrictions(self.ResID)
		if CanWearable == false then
			self.LeftCornerFlagImgVisible = true
			self.LeftCornerFlagImgIcon = ArmyDepotSlotVM.LeftCornerFlag["Forbid"]
			self.LeftCornerFlagImgColor = OtherProfWearable and ArmyDepotSlotVM.WearableColorMap[WearableState.OtherProfWearable] or ArmyDepotSlotVM.WearableColorMap[WearableState.Unwearable]
		end
	end
end

--药品设置标识
function ArmyDepotSlotVM:SetLeftCornerFlagByMedicineSet(ItemResID)
	if self:IsMedicineSet(ItemResID) then
		self.LeftCornerFlagImgVisible = true
		self.LeftCornerFlagImgIcon = ArmyDepotSlotVM.LeftCornerFlag["Yes"]
		self.LeftCornerFlagImgColor = "FFFFFF"
	end
end

function ArmyDepotSlotVM:IsMedicineSet(ItemResID)
	if self.ProfID == nil then
		return false
	end
	local MedicineID = _G.BagMgr.ProfMedicineTable[self.ProfID]
	if MedicineID == nil then
		return false
	end

	return MedicineID == ItemResID
end

--药品cd
function ArmyDepotSlotVM:UpdateItemCD(GroupID, EndFreezeTime, FreezeCD)
	local Cfg = ItemCfg:FindCfgByKey(self.ResID)
	if nil == Cfg then
		return
	end
 
	local IsCD = _G.BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil
	self.IsMask = IsCD
	self.IsCD = IsCD

	if IsCD then
		local CurTime = TimeUtil.GetServerTime()
		if EndFreezeTime - CurTime > 0 then
			self.ItemCD = tostring(EndFreezeTime - CurTime)
		end
	end

end

function ArmyDepotSlotVM:SetNoFullItemNumberStacks(DepotIndex)
	if self.MaxPile and self.Num and self.MaxPile > self.Num then
		local NoFullNum = self.MaxPile - self.Num
		_G.ArmyMgr:SetGroupStoreItemNumberStacks(self.ResID, NoFullNum, DepotIndex)
	end
end

return ArmyDepotSlotVM
