local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EquipmentMoreFilterItemVM : UIViewModel
local EquipmentMoreFilterItemVM = LuaClass(UIViewModel)

function EquipmentMoreFilterItemVM:Ctor()
    self.Text = nil
    self.bSelect = false
end

return EquipmentMoreFilterItemVM