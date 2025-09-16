--
-- Author: ZhengJanChuan
-- Date: 2024-03-04 11:04
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE
local ItemCfg = require("TableCfg/ItemCfg")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")

---@class WardrobePresetsSlotItemVM : UIViewModel
local WardrobePresetsSlotItemVM = LuaClass(UIViewModel)

local  ItemColorType =
{
	-- ITEM_COLOR_WHITE = 1,	-- 白
	-- ITEM_COLOR_GREEN = 2,	-- 绿
	-- ITEM_COLOR_BLUE = 3,	-- 蓝
	-- ITEM_COLOR_PURPLE = 4,	-- 紫
	-- ITEM_COLOR_RED = 6,	-- 红,
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_02.UI_Quality_Slot_NQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_03.UI_Quality_Slot_NQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_04.UI_Quality_Slot_NQ_04'",
}

---Ctor
function WardrobePresetsSlotItemVM:Ctor()
	self.EquipmentIcon = nil
	self.EquipmentIconAlpha = nil
	self.CurSuitChecked = false
	self.StainTagVisible = false
	self.StainColor = ""
	self.StainColorVisible = false
	self.CanEquiped = true
	self.IsEmpty = false
	self.ItemQualityVisible = false
	self.ItemQualityIcon = ItemColorType[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE]
end

function WardrobePresetsSlotItemVM:OnInit()
end

function WardrobePresetsSlotItemVM:OnBegin()
end

function WardrobePresetsSlotItemVM:OnEnd()
end

function WardrobePresetsSlotItemVM:OnShutdown()
end

function WardrobePresetsSlotItemVM:UpdateVM(Value)
    self.EquipmentIcon = Value.EquipmentIcon
	self.EquipmentIconAlpha = Value.EquipmentIconAlpha
	self.StainTagVisible = Value.StainTagVisible
	self.StainColorVisible = Value.StainColorVisible
	self.StainColor = Value.StainColor
	self.CanEquiped = Value.CanEquiped

	self.ItemQualityVisible = false
	self.IsEmpty = true
	local Cfg = ItemCfg:FindCfgByKey(WardrobeUtil.GetWeaponEquipIDByAppearanceID((Value.Avatar)))
	if Cfg ~= nil then
		self.ItemQualityIcon = ItemColorType[Cfg.ItemColor]
		self.ItemQualityVisible = true
		self.IsEmpty = false
	end
end


--要返回当前类
return WardrobePresetsSlotItemVM