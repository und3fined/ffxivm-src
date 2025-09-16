local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")

local EquipmentMgr = _G.EquipmentMgr

local MagicsparInlaySlotItemVM = require("Game/Magicspar/VM/MagicsparInlaySlotItemVM")

---@class EquipmentDetailItemVM : UIViewModel
local EquipmentDetailItemVM = LuaClass(UIViewModel)

function EquipmentDetailItemVM:Ctor()
    self.Part = nil
    self.ResID = nil
    self.GID = nil
    self.bSelect = false
    self.bCanEquip = true
    self.EquipmentNameColor = "828282FF"
    self.ItemLevelColor = "828282FF"
    self.IsBind = false
    self.mapMagicsparInlaySlotItemVM = nil
    self.NoUsePath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Tag_IconSlot_No_Red_png.UI_Tag_IconSlot_No_Red_png'"
	self.bIsEquiped = false
	self.bIsTaslkItem = false
end

function EquipmentDetailItemVM:UpdateVM(Value, Param)
	self.Part = Param.Part
	self:SetEquipment(Value.ResID, Value.GID)
    if not self.bIsEquiped then
        self.bIsTaslkItem = Param.bIsTaslkItem
    else
        self.bIsTaslkItem = false
    end
end

function EquipmentDetailItemVM:SetEquipment(InResID, InGID)
    self.ResID = InResID
    self.GID = InGID
    local Reason
    self.bCanEquip, Reason = EquipmentMgr:CanEquiped(InResID)
    self.bIsEquiped = EquipmentMgr:IsEquiped(InGID)

    if Reason > 0 and (Reason == 1 or Reason == 2) then
        self.NoUsePath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Tag_IconSlot_No_Blue_png.UI_Tag_IconSlot_No_Blue_png'"
    end

    self.Item = EquipmentMgr:GetItemByGID(InGID)
    self.IsBind = self.Item and self.Item.IsBind or false

    ---魔晶石信息
    --print("魔晶石信息")   
    self.MagicsparInlayCfg = MagicsparInlayCfg:FindCfgByPart(self.Part)
end

function EquipmentDetailItemVM:SetSelect(InValue)
    self.bSelect = InValue
    self.EquipmentNameColor = self.bSelect and "FFF4D0FF" or "828282FF"
    self.ItemLevelColor = self.bSelect and "FFF4D0FF" or "828282FF"
end

return EquipmentDetailItemVM