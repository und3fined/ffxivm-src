---
---@author Lucas
---DateTime: 2023-05-8 12:11:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local ProtoRes = require("Protocol/ProtoRes")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local MajorUtil = require("Utils/MajorUtil")
local HairCfg = require("TableCfg/HairCfg")
local StoreMgr = require("Game/Store/StoreMgr")

local FLOG_WARNING = _G.FLOG_WARNING
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE
local ITEM_TYPE = ProtoCommon.ITEM_TYPE_DETAIL

---@class StoreEquipPartVM: UIViewModel
---@field SignIcon string @标记图标
---@field Icon string @部位图标
---@field SlotBg string @插槽背景
---@field IsSelect bool @是否选中
---@field bOwned bool @是否拥有
local StoreEquipPartVM = LuaClass(UIViewModel)

function StoreEquipPartVM:Ctor()
    self.Icon = ""
    self.bOwned = false

	--- 通用物品里需要隐藏的节点
	self.NumVisible = false
	self.HideItemLevel = true
	self.IconChooseVisible = false
	self.ItemLevelVisible = false
    -- self.SignIcon = ""
    -- self.SlotBg = ""
	self.IsMask = false
    self.SelectBtnState = false

	self.ResID = nil
	-- self.Part = nil
	self.EquipmentID = nil
	self.IsSelect = false

	self.BtnViewVisible = true
end

function StoreEquipPartVM:IsEqualVM(Value)
	return nil ~= Value
end

function StoreEquipPartVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("StoreEquipPartVM:InitVM, Value is nil")
        return
    end

	self.bOwned = StoreMgr.CheckItemOwned(Value.ItemID)

	self.ResID = Value.ItemID
	self.Name = Value.Name
	self.ItemType = Value.ItemType
	if self.ItemType == ITEM_TYPE.COLLAGE_COIFFURE then
		-- -- 如果在背包仓库邮件没找到，或许是已经解锁了
		-- if not self.bOwned then
		-- 	self.bOwned = _G.HaircutMgr.CheckHairUnlock(self.ResID)
		-- end
		local HairUnlockCfg = HairUnlockCfg:FindCfgByItemID(Value.ItemID)
		if HairUnlockCfg == nil then
			FLOG_ERROR("StoreEquipPartVM  ItemType is hair, But HairUnlockCfg is nil")
			return
		end
		self.EquipmentID = HairUnlockCfg.HairID
		self.Part = ProtoCommon.equip_part.EQUIP_PART_BODY_HAIR

		self.Icon = _G.StoreMgr:GetHairIconByHairID(HairUnlockCfg.HairID)
	else
		self.Icon = UIUtil.GetIconPath(Value.IconID)
		self.EquipmentID = Value.EquipmentID
		local TempEquipmentCfg = EquipmentCfg:FindCfgByEquipID(self.EquipmentID)
		if TempEquipmentCfg == nil then
			return
		end
		self.Part = TempEquipmentCfg.Part == ProtoCommon.equip_part.EQUIP_PART_FINGER and
			ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER or TempEquipmentCfg.Part
	end
	self.bOwned = self.bOwned and _G.StoreMainVM.CurrentStoreMode ~= StoreDefine.StoreMode.Gift
	self.IsMask = self.bOwned
	self.SelectBtnState = false
    self.IsSelect = false
	-- local SignIndex = StoreDefine.EquipPartEnum[TempEquipmentCfg.Part]
	-- self.SignIcon = StoreDefine.EquipPartSign[SignIndex]

	--- 外部指定是否显示小眼睛
	if Value.BtnViewVisible == nil then
		self.BtnViewVisible = true
	else
		self.BtnViewVisible = Value.BtnViewVisible
	end

end

function StoreEquipPartVM:UpdateOwnedState(Flag)
    self.bOwned = Flag
end

function StoreEquipPartVM:OnSelectedChange(IsSelect)
    self.IsSelect = IsSelect
end

return StoreEquipPartVM