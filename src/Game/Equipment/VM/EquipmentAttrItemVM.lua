local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EquipmentAttrItemVM : UIViewModel
local EquipmentAttrItemVM = LuaClass(UIViewModel)

function EquipmentAttrItemVM:Ctor()
    self.LeftText = ""
    self.RightText = ""
    self.RightIcon = nil
    self.bHasIcon = false
    self.LeftTextColor = "999999FF"
    self.RightTextColor = "999999FF"
    --绿色"00FD2BFF" --红色f80003
end

return EquipmentAttrItemVM