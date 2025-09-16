---
--- Author: rock
--- DateTime: 2025-3-3 11:06
--- Description:PreviewEquipPartVM 装备图标槽
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local FLOG_WARNING = _G.FLOG_WARNING
local ITEM_TYPE = ProtoCommon.ITEM_TYPE_DETAIL

---@class PreviewEquipPartVM: UIViewModel
---@field SignIcon string @标记图标
---@field Icon string @部位图标
---@field SlotBg string @插槽背景
---@field IsSelect bool @是否选中
---@field bOwned bool @是否拥有
local PreviewEquipPartVM = LuaClass(UIViewModel)

function PreviewEquipPartVM:Ctor()
    self.Icon = ""
    self.bOwned = false-- 预览界面不显示拥有状态

	--- 通用物品里需要隐藏的节点
	self.NumVisible = false
	self.HideItemLevel = true
	self.IconChooseVisible = false
	self.ItemLevelVisible = false
	self.IsMask = false
    self.SelectBtnState = false

	self.ResID = nil
	self.Part = nil
	self.EquipmentID = nil
	self.IsSelect = false
end

function PreviewEquipPartVM:IsEqualVM(Value)
	return nil ~= Value
end

function PreviewEquipPartVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("StoreEquipPartVM:InitVM, Value is nil")
        return
    end
    -- local Quality = StoreDefine.ItemQuality[Value.ItemColor]
    -- Quality = Quality or StoreDefine.ItemQuality[1]
    -- self.SlotBg = Quality

	self.Icon = UIUtil.GetIconPath(Value.IconID)
	self.ResID = Value.ItemID
	self.ItemType = Value.ItemType
	if self.ItemType == ITEM_TYPE.COLLAGE_COIFFURE then
		local HairCfg = HairUnlockCfg:FindCfgByItemID(Value.ItemID)
		if HairCfg == nil then
			FLOG_ERROR("PreviewEquipPartVM HairCfg is nil, ItemID=%d", Value.ItemID)
			return
		end
		self.EquipmentID = HairCfg.HairID
		self.Part = ProtoCommon.equip_part.EQUIP_PART_BODY_HAIR
	else
		self.EquipmentID = Value.EquipmentID
		local TempEquipmentCfg = EquipmentCfg:FindCfgByEquipID(self.EquipmentID)
		if TempEquipmentCfg == nil then
			FLOG_ERROR("PreviewEquipPartVM TempEquipmentCfg is nil, ItemID=%d  EquipmentID=%d", Value.ItemID, Value.EquipmentID)
			return
		end
		self.Part = (TempEquipmentCfg.Part == ProtoCommon.equip_part.EQUIP_PART_FINGER) and ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER or TempEquipmentCfg.Part
	end
	self.SelectBtnState = false
	self.IsMask = self.bOwned
end

function PreviewEquipPartVM:UpdateOwnedState(Flag)
    self.bOwned = Flag
end

function PreviewEquipPartVM:OnSelectedChange(IsSelect)
    self.IsSelect = IsSelect
end

return PreviewEquipPartVM