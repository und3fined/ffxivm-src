--
-- Author: ZhengJanChuan
-- Date: 2024-02-22 17:22
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemVM = require("Game/Item/ItemVM")
local WardrobeAppearanceItemVM = require("Game/Wardrobe/VM/WardrobeAppearanceItemVM")
local ItemUtil = require("Utils/ItemUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")

---@class WardrobeSuitItemVM : UIViewModel
local WardrobeSuitItemVM = LuaClass(UIViewModel)
local IconBg = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'"

---Ctor
function WardrobeSuitItemVM:Ctor()
    self.CanEquip = nil
    self.StainedEnable = nil
    self.IsUnlock = nil
    self.AppID = nil
    self.EquipID = nil
    self.ItemVM = ItemVM.New()

    self.HideColor = nil
    self.IsStained = nil
end

function WardrobeSuitItemVM:OnInit()
end

function WardrobeSuitItemVM:OnBegin()
end

function WardrobeSuitItemVM:OnEnd()
end

function WardrobeSuitItemVM:OnShutdown()
end

function WardrobeSuitItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeSuitItemVM:UpdateVM(Value)
    self.AppID = Value.AppID
    self.CanEquip =  WardrobeMgr:CanEquipAppearance(Value.AppID)
    self.StainedEnable = WardrobeMgr:GetDyeEnable(Value.AppID)
    self.IsStained = WardrobeMgr:GetIsDye(Value.AppID)
    self.IsUnlock = WardrobeMgr:GetIsUnlock(Value.AppID)
    self.EquipID = Value.EquipID
    local SpeacialID = WardrobeUtil.GetIsSpecial(Value.AppID) and WardrobeDefine.SpecialShiftID or 0 
    local Item = ItemUtil.CreateItem(self.EquipID +  SpeacialID, 1)
    Item.IconChooseVisible = false
    self.HideColor = true
    self.ItemVM:UpdateVM(Item, {PanelBagVisible = true, IsShowNum = false, IsShowLeftCornerFlag = false})
    self.ItemVM.ItemQualityIcon = IconBg
end

function WardrobeSuitItemVM:IsEqualVM(Value)
    return self.AppID ~= Value.AppID
end


--要返回当前类
return WardrobeSuitItemVM