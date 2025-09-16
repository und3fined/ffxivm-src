local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

local FantasyCardCfg = require("TableCfg/FantasyCardCfg")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local WearableState = EquipmentDefine.WearableState

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local BagMgr

---@class BagSlotVM : UIViewModel
local BagSlotVM = LuaClass(UIViewModel)

BagSlotVM.LeftCornerFlag =
{
	["Yes"] = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Check_png.UI_Comm_Img_Check_png'",
	["OtherProfWearable"] = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Icon_CancelBlue_png.UI_Bag_Icon_CancelBlue_png'",
	["Unwearable"] = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Icon_CancelRed_png.UI_Bag_Icon_CancelRed_png'",
}

---Ctor
function BagSlotVM:Ctor()
	self.IsShowNum = true
	rawset(self, "IsShowNewFlag", true)
	rawset(self, "IsShowLeftCornerFlag", true)

	rawset(self, "Item", nil)
	rawset(self, "IsValid", false)

	rawset(self, "GID", nil)
	rawset(self, "ResID", nil)
	self.Num = nil
	self.NumVisible = nil

	rawset(self, "Name", nil)
	self.Icon = nil

	rawset(self, "ItemType", nil)
	rawset(self, "ItemColor", nil)
	rawset(self, "ItemLevel", nil)

	rawset(self, "IsBind", false)
	rawset(self, "IsUnique", false)

	rawset(self, "IsHQ", false)
	self.IsNew = false

	self.ItemQualityIcon = nil

	self.ItemCD = 0 -- CD倒数text
	self.ItemCDShow = nil -- CD倒数显示
	self.IsCD = nil --CDtext显隐
	self.CDRadialProcess = nil
	self.IsMask = nil --遮罩显隐
	--套装
	self.IsInScheme = nil

	-- 幻化 染色
	self.GlamoursImgVisible = false
	rawset(self, "GlamoursStatusImg", nil)
	rawset(self, "GlamoursImgColor", nil)

	self.PanelBagVisible = nil
	self.IsSelect = nil

	-- 左下角图标 （标识穿戴，采集，制作）
	self.LeftCornerFlagImgIcon = nil
	self.LeftCornerFlagImgVisible = false

	--物品回收

	rawset(self, "IsShowCanRecovery", false)
	self.PanelMultiChoiceVisible = false

	self.IsAllowDoubleClick = false
	BagMgr = _G.BagMgr

	self.IsLimitedTime = nil
	self.IsExpired = nil

	rawset(self, "OtherProfWearableVisible", false)
	rawset(self, "UnwearableVisible", false)
end

function BagSlotVM:IsEqualVM(Value)
	return nil ~= Value and Value.GID == self.GID
end

function BagSlotVM:UpdateVM(Value, Param)
	local IsValid = nil ~= Value and Value.ResID ~= nil
	rawset(self, "IsValid", IsValid)
	self.PanelBagVisible = IsValid
	if not IsValid then
		rawset(self, "ResID", nil)
		self.Num = nil
		return
	end

	self:UpdateByParam(Param)
	
	local ValueResID = Value.ResID
	rawset(self, "Item", Value)
	rawset(self, "GID", Value.GID)
	self.IsMask = false
	rawset(self, "ResID", ValueResID)
	self.Num = Value.Num
	local Cfg = ItemCfg:FindCfgByKey(ValueResID)
	if nil == Cfg then
		FLOG_WARNING("ItemVM:UpdateVM can't find item cfg, ResID =%d", ValueResID)
		return
	end

	rawset(self, "Name", ItemCfg:GetItemName(ValueResID))
	self.Icon = UIUtil.GetIconPath(Cfg.IconID)

	rawset(self, "IsBind", Value.IsBind)
	rawset(self, "IsUnique", Cfg.IsUnique > 0)
	rawset(self, "ItemType", Cfg.ItemType)
	rawset(self, "Classify", Cfg.Classify)
	rawset(self, "IsRecoverable", Cfg.IsRecoverable)
	rawset(self, "FreezeGroup", Cfg.FreezeGroup)

	self.NumVisible = self.IsShowNum and (Cfg.MaxPile > 1 or self.Num >1)
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(ValueResID)

	if Cfg.IsCanStore == false or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
		self.IsMask = true
	end
	
	--新标签
	self:UpdateIsNew()

	--限时标签
	self:UpdateLimitedTime()

	--套装
	self.IsInScheme = self:UpdateEquipIsInScheme(Value)
	
	--设置左下角图标
	self:UpdateLeftCornerFlag(ValueResID)

	--物品是否可回收标志/或者是否在CD中
	if self.IsShowCanRecovery then
		if self.IsRecoverable == 1 and not self.IsInScheme then
			self.IsMask = false
		else
			self.IsMask = true
		end
	end
	
	self.IsCD = BagMgr.FreezeCDTable[self.FreezeGroup] ~= nil

	--选中标识
	self.IsSelect = false
	--回收选中标识
	self.PanelMultiChoiceVisible = false
end

function BagSlotVM:UpdateLimitedTime()
	if BagMgr:TimeLimitItemExpired(self.Item) then
		self.IsLimitedTime = false
		self.IsExpired = true
		self.IsMask = true
	else
		self.IsLimitedTime = BagMgr:IsTimeLimitItem(self.Item)
		self.IsExpired = false
	end
end

function BagSlotVM:UpdateRecoverySelected(RecoveryList, bRecoverying)
	if self.IsShowCanRecovery and RecoveryList[self.GID] ~= nil and bRecoverying then
		self.PanelMultiChoiceVisible = true
	else
		self.PanelMultiChoiceVisible = false
	end

	return self.PanelMultiChoiceVisible
end

function BagSlotVM:UpdateByParam(Param)
	self.IsShowNum = true
	rawset(self, "ProfID", nil)
	rawset(self, "IsShowCanRecovery", false)
	rawset(self, "IsShowNewFlag", true)
	self.IsAllowDoubleClick = false
	if Param == nil then
		return
	end

	if Param.IsShowNum ~= nil then
		self.IsShowNum = Param.IsShowNum
	end

	if Param.ProfID ~= nil then
		rawset(self, "ProfID", Param.ProfID)
	end

	if Param.IsShowCanRecovery ~= nil then
		rawset(self, "IsShowCanRecovery", Param.IsShowCanRecovery)
	end

	if Param.IsAllowDoubleClick ~= nil then
		self.IsAllowDoubleClick = Param.IsAllowDoubleClick
	end


	if Param.IsShowNewFlag ~= nil then
		rawset(self, "IsShowNewFlag", Param.IsShowNewFlag)
	end

	if Param.IsShowLeftCornerFlag ~= nil then
		rawset(self, "IsShowLeftCornerFlag", Param.IsShowLeftCornerFlag)
	end

end

function BagSlotVM:ClickedItemVM()
	if self.IsNew == true then
		BagMgr.NewItemRecord[self.GID] = nil
		self.IsNew = false

		--table.sort(BagMgr.ItemList, BagMgr.SortBagItemPredicate)
		--_G.EventMgr:PostEvent(_G.EventID.BagUpdateNew)
	end
end

function BagSlotVM:UpdateIsNew()
	if BagMgr.NewItemRecord[self.GID] == true and self.IsShowNewFlag == true then
		self.IsNew = true
	else
		self.IsNew = false
	end
end

function BagSlotVM:UpdateEquipIsInScheme(Value)
	return ItemUtil.ItemIsInScheme(Value)
end

---CheckIsEquipment
---@return boolean 是否装备
function BagSlotVM:CheckIsEquipment()
	if self.Classify == nil then
		FLOG_ERROR("ItemVM:CheckIsEquipment ItemVM.Classify == nil ResID = %d", self.ResID)
		return -1
	end
	return ItemUtil.CheckIsEquipment(self.Classify)
end

function BagSlotVM:SetItemSelected(IsSelected)
	if self.IsShowCanRecovery == true then
		return
	end
	self.IsSelect = IsSelected
end

function BagSlotVM:SetIsAllowDoubleClick(IsAllowDoubleClick)
	self.IsAllowDoubleClick = IsAllowDoubleClick
end

function BagSlotVM:SetItemRecoverySelected(IsSelected)
	self.PanelMultiChoiceVisible = IsSelected
end

function BagSlotVM:UpdateLeftCornerFlag(ValueResID)
	self.LeftCornerFlagImgVisible = false

	if self.IsShowLeftCornerFlag == true then
		--穿戴
		self:SetLeftCornerFlagByWearable()
		--药品设置
		self:SetLeftCornerFlagByMedicineSet(ValueResID)
		--改良
		self:SetLeftImproveFlag(ValueResID)
	end
end
--穿戴标识
function BagSlotVM:SetLeftCornerFlagByWearable()
	if self:CheckIsEquipment() then
		local CanWearable, OtherProfWearable= ItemUtil.UpdateProfRestrictions(self.ResID)
		if CanWearable == false then
			self.LeftCornerFlagImgVisible = true
			self.LeftCornerFlagImgIcon = OtherProfWearable and BagSlotVM.LeftCornerFlag["OtherProfWearable"] or BagSlotVM.LeftCornerFlag["Unwearable"]
			self.IsMask = true
		end
	end
end

--药品设置标识
function BagSlotVM:SetLeftCornerFlagByMedicineSet(ItemResID)
	if self:IsMedicineSet(ItemResID) then
		self.LeftCornerFlagImgVisible = true
		self.LeftCornerFlagImgIcon = BagSlotVM.LeftCornerFlag["Yes"]
	end
end

function BagSlotVM:SetLeftImproveFlag(ItemResID)
	self.CanImprove = _G.EquipmentMgr:CheckCanImprove(ItemResID)
end

function BagSlotVM:IsMedicineSet(ItemResID)
	if self.ProfID == nil then
		return false
	end
	local MedicineID = BagMgr.ProfMedicineTable[self.ProfID]
	if BagMgr:IsMedicineItem(MedicineID) == false then
		return false
	end

	return MedicineID == ItemResID
end

--药品cd
function BagSlotVM:UpdateItemCD(GroupID, EndFreezeTime, FreezeCD)
	--[[local Cfg = ItemCfg:FindCfgByKey(self.ResID)
	if nil == Cfg then
		return
	end
 
	if GroupID ~= Cfg.FreezeGroup then -- 非同一冷却组的道具不进行更新
		return
	end

	local IsCD = BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil
	self.IsCD = IsCD

	if IsCD then
		local CurTime = TimeUtil.GetServerTime()
		if EndFreezeTime - CurTime > 0 then
			self.ItemCD = math.floor(EndFreezeTime - CurTime)
			self.ItemCDShow = self.ItemCD <= 3600 --- 超过3600s不显示
			if Cfg.FreezeTime > 0  and FreezeCD > 0 then
				self.CDRadialProcess = 1 - self.ItemCD / FreezeCD
			else
				self.CDRadialProcess = 1
			end
		end
	end]]--

end

--- 特殊界面强制显示特殊数字
function BagSlotVM:SetTheNumText(NumText)
	if not NumText or type(NumText) ~= "string" then
		return
	end
	self.NumVisible = true
	self.Num = NumText
end


return BagSlotVM
