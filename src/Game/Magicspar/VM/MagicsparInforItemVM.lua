local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemDBCfg = require("TableCfg/ItemCfg")
local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")

local ItemUtil = require("Utils/ItemUtil")

local EquipmentMgr = _G.EquipmentMgr

---@class MagicsparInforItemVM : UIViewModel
local MagicsparInforItemVM = LuaClass(UIViewModel)

function MagicsparInforItemVM:Ctor()
    self.ResID = nil
    self.GID = nil
    self.Name = nil
    self.Level = nil
    self.Part = nil
    self.ItemLevelColor = "828282FF"
    self.bShowSwitch = false
end

function MagicsparInforItemVM:InitItem(InResID, InGID, InPart)

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
    self.ItemLevelColor = ItemUtil.GetItemQualityColorByResID(InResID)
    self.bShowSwitch = _G.EquipmentMgr:IsEquiped(InGID)
end

return MagicsparInforItemVM