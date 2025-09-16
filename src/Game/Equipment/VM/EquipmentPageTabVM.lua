local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EquipmentPageTabVM : UIViewModel
local EquipmentPageTabVM = LuaClass(UIViewModel)

function EquipmentPageTabVM:Ctor()
    self.Text = nil
    self.bSelect = nil
end

return EquipmentPageTabVM