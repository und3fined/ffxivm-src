--
-- Author: ZhengJanChuan
-- Date: 2024-02-23 15:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")

---@class WardrobeEquipmentSlotItemVM : UIViewModel
local WardrobeEquipmentSlotItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeEquipmentSlotItemVM:Ctor()
    self.ID = 0
    self.UnlockVisible = false
    self.CanUnlockVisible = false
    self.StainTagVisible = false
    self.FavoriteVisible = false
    self.CheckVisible = false
    self.CanEquip = true
    self.ItemName = ""
    self.EquipmentIcon = nil
    self.IsSelected = false

    self.StainColor = ""
    self.StainColorVisible = false
end

function WardrobeEquipmentSlotItemVM:OnInit()
end

function WardrobeEquipmentSlotItemVM:OnBegin()
end

function WardrobeEquipmentSlotItemVM:OnEnd()
end

function WardrobeEquipmentSlotItemVM:OnShutdown()
end

function WardrobeEquipmentSlotItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeEquipmentSlotItemVM:UpdateVM(Value)
    self.UnlockVisible = not Value.UnlockVisible
    self.CanUnlockVisible = Value.CanUnlockVisible
    self.StainTagVisible = Value.StainTagVisible
    self.FavoriteVisible = Value.FavoriteVisible
    self.CheckVisible = Value.CheckVisible
    self.CanEquip = Value.CanEquip
    self.ItemName = Value.ItemName
    self.EquipmentIcon = Value.EquipmentIcon

    self.StainColor = Value.StainColor
    self.StainColorVisible = Value.StainColorVisible
    self.ID = Value.ID

end

function WardrobeEquipmentSlotItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function WardrobeEquipmentSlotItemVM:UpdateFavoriteState(IsFavorite)
    self.FavoriteVisible = IsFavorite
end

function WardrobeEquipmentSlotItemVM:UpdateUnlockState(IsUnlock)
    self.UnlockVisible = not IsUnlock
end

function WardrobeEquipmentSlotItemVM:UpdateCanUnlockState(IsCanUnlock)
    self.CanUnlockVisible = IsCanUnlock
end

function WardrobeEquipmentSlotItemVM:UpdateIsClothing(IsClothing)
    self.CheckVisible = IsClothing
end


function WardrobeEquipmentSlotItemVM:UpdateColorState(Value)
    self.StainColor = Value.StainColor
    self.StainColorVisible = Value.StainColorVisible
    self.StainTagVisible = Value.StainTagVisible
end

function WardrobeEquipmentSlotItemVM:UpdateUnlockDataState()
    self.UnlockVisible = not WardrobeMgr:GetIsUnlock(self.ID)
    self.CanEquip = WardrobeMgr:CanEquipAppearance(self.ID)
end


--要返回当前类
return WardrobeEquipmentSlotItemVM