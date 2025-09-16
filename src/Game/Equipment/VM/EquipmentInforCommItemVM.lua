local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemDBCfg = require("TableCfg/ItemCfg")
local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")

local EquipmentMgr = _G.EquipmentMgr

---@class EquipmentInforCommItemVM : UIViewModel
local EquipmentInforCommItemVM = LuaClass(UIViewModel)

function EquipmentInforCommItemVM:Ctor()
    self.ResID = nil
    self.GID = nil
    self.Name = nil
    self.Level = nil
    self.Part = nil
    self.bShowInlaySlot = true
end

function EquipmentInforCommItemVM:InitItem(InResID, InGID, InPart)

    local ItemCfg = ItemDBCfg:FindCfgByKey(InResID)
    
    self.Name = ItemDBCfg:GetItemName(InResID)
    self.Level = ItemCfg.ItemLevel

    self.Item = EquipmentMgr:GetItemByGID(InGID)
    if InPart then
        self.Part = InPart
    elseif (self.Item) then
        self.Part = self.Item.Attr.Equip.Part
    else
        local EquipmentCfg = EquipmentCfg:FindCfgByEquipID(InResID)
        self.Part = EquipmentCfg.Part
    end

    self.MagicsparInlayCfg = MagicsparInlayCfg:FindCfgByPart(self.Part)

    self.ResID = InResID
    self.GID = InGID

    --魔晶石选项
    self.bShowInlaySlot = _G.EquipmentMgr:CheckCanMosic(InResID)
end

return EquipmentInforCommItemVM