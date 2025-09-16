local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EquipmentFilterItemVM : UIViewModel
local EquipmentFilterItemVM = LuaClass(UIViewModel)

function EquipmentFilterItemVM:Ctor()
    self.Text = ""
end

return EquipmentFilterItemVM