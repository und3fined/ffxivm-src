--
-- Author: ZhengJanChuan
-- Date: 2025-09-01 09:42
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

---@class WardrobeSuitItem2VM : UIViewModel
local WardrobeSuitItem2VM = LuaClass(UIViewModel)
local IconBg = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'"

---Ctor
function WardrobeSuitItem2VM:Ctor()
    self.AppID = nil   --外观id
    self.EquipID = nil  --装备id
    self.CanEquip = nil   --是否能穿戴
    self.StainedEnable = nil    -- 是否能染色
    self.IsUnlock = nil   -- 是否解锁
    self.ItemVM = ItemVM.New()  
    self.IsStained = nil  -- 是否已染色
    self.HideColor = true
    -- self.IsSelected = nil
    self.RedDotName = nil
    self.IsEmpty = nil
    self.IsRed = nil
end

function WardrobeSuitItem2VM:OnInit()
end

function WardrobeSuitItem2VM:OnBegin()
end

function WardrobeSuitItem2VM:OnEnd()
end

function WardrobeSuitItem2VM:OnShutdown()
end

function WardrobeSuitItem2VM:UpdateVM(Value)
    if not  Value.IsEmpty  then
        self.AppID = Value.AppID
        self.CanEquip =  WardrobeMgr:CanEquipAppearance(Value.AppID)
        self.StainedEnable = WardrobeMgr:GetDyeEnable(Value.AppID)
        self.IsStained = WardrobeMgr:GetIsDye(Value.AppID)
        if WardrobeMgr:GetIsClothing(Value.AppID) then
            self.IsStained=  WardrobeMgr:GetCurrentIsDye( Value.AppID)
        else
            self.IsStained =  WardrobeMgr:GetIsDye(Value.AppID)
        end
        self.RedDotName = Value.RedDotName
        self.IsUnlock = WardrobeMgr:GetIsUnlock(Value.AppID)
        self.EquipID = Value.EquipID
        local SpeacialID = WardrobeUtil.GetIsSpecial(Value.AppID) and WardrobeDefine.SpecialShiftID or 0 
        local Item = ItemUtil.CreateItem(self.EquipID +  SpeacialID, 1)
        self.ItemVM.ItemQualityIcon = IconBg
        self.ItemVM:UpdateVM(Item, {PanelBagVisible = true, IsShowNum = false, IsShowLeftCornerFlag = false})
        self.IsRed = Value.IsRed
    else
        local Item = ItemUtil.CreateItem(nil, 1)
        self.IsStained = false
        self.IsUnlock = true
        self.StainedEnable = false
        self.CanEquip = true
        self.IsRed = false
        self.ItemVM:UpdateVM(Item, {PanelBagVisible = true, IsShowNum = false, IsShowLeftCornerFlag = false})
    end
end

function WardrobeSuitItem2VM:IsEqualVM(Value)
    return self.AppID ~= Value.AppID
end


--要返回当前类
return WardrobeSuitItem2VM