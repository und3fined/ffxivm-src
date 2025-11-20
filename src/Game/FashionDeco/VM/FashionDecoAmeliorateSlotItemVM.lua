--
-- Author: rock
-- Date: 2025-10-27 15:38
-- Description: 配饰改良成功界面，弹出展示面板的物品Item
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")

---@class FashionDecoAmeliorateSlotItemVM : UIViewModel
local FashionDecoAmeliorateSlotItemVM = LuaClass(UIViewModel)

---Ctor
function FashionDecoAmeliorateSlotItemVM:Ctor()
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
    self.TraitVisible = false
    self.TraitIcon = nil
    self.IsReward = nil
    self.RewardItemPlayAnimIn = nil
end

function FashionDecoAmeliorateSlotItemVM:OnInit()
end

function FashionDecoAmeliorateSlotItemVM:OnBegin()
end

function FashionDecoAmeliorateSlotItemVM:OnEnd()
end

function FashionDecoAmeliorateSlotItemVM:OnShutdown()
end

function FashionDecoAmeliorateSlotItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function FashionDecoAmeliorateSlotItemVM:UpdateVM(Value)
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
    self.TraitVisible = WardrobeUtil.IsTraitApp(self.ID)
    self.TraitIcon = WardrobeDefine.TraitTypeIcon[WardrobeUtil.GetTraitTypeApp(self.ID)]
    self.IsReward = Value.IsReward
end

function FashionDecoAmeliorateSlotItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function FashionDecoAmeliorateSlotItemVM:UpdateFavoriteState(IsFavorite)
    self.FavoriteVisible = IsFavorite
end

function FashionDecoAmeliorateSlotItemVM:UpdateUnlockState(IsUnlock)
    self.UnlockVisible = not IsUnlock
end

function FashionDecoAmeliorateSlotItemVM:UpdateCanUnlockState(IsCanUnlock)
    self.CanUnlockVisible = IsCanUnlock
end

function FashionDecoAmeliorateSlotItemVM:UpdateIsClothing(IsClothing)
    self.CheckVisible = IsClothing
end


function FashionDecoAmeliorateSlotItemVM:UpdateColorState(Value)
    self.StainColor = Value.StainColor
    self.StainColorVisible = Value.StainColorVisible
    self.StainTagVisible = Value.StainTagVisible
end

function FashionDecoAmeliorateSlotItemVM:UpdateUnlockDataState()
    self.UnlockVisible = not WardrobeMgr:GetIsUnlock(self.ID)
    self.CanEquip = WardrobeMgr:CanEquipAppearance(self.ID)
end


function FashionDecoAmeliorateSlotItemVM:UpdateRewardItemPlayAnimIn(RewardItemPlayAnimIn)
    self.RewardItemPlayAnimIn = RewardItemPlayAnimIn
end


--要返回当前类
return FashionDecoAmeliorateSlotItemVM