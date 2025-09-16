local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EquipmentDiscountTagVM : UIViewModel
local EquipmentDiscountTagVM = LuaClass(UIViewModel)

function EquipmentDiscountTagVM:Ctor()
    self.DiscountOffValue = 0
end

return EquipmentDiscountTagVM