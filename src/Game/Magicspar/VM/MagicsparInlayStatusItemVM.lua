local LuaClass = require("Core/LuaClass")
local MagicsparInlaySlotItemVM = require("Game/Magicspar/VM/MagicsparInlaySlotItemVM")
local ItemCfg = require("TableCfg/ItemCfg")

---@class MagicsparInlayStatusItemVM : UIViewModel
local MagicsparInlayStatusItemVM = LuaClass(MagicsparInlaySlotItemVM)

function MagicsparInlayStatusItemVM:Ctor()
    self.Name = nil
    self.Detail = nil
end

function MagicsparInlayStatusItemVM:InitItem(InResID, Index, bNomal)
    self:InitMagicsparSlot(InResID, Index, bNomal)
    local c_item_cfg = ItemCfg:FindCfgByKey(InResID)
    if c_item_cfg == nil then
        return
    end
    self.Name = ItemCfg:GetItemName(InResID)
    self.Detail = ItemCfg:GetItemEffectDesc(InResID)
end

return MagicsparInlayStatusItemVM