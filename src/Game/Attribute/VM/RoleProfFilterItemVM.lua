local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class RoleProfFilterItemVM : UIViewModel
local RoleProfFilterItemVM = LuaClass(UIViewModel)

function RoleProfFilterItemVM:Ctor()
    self.Text = nil
end

return RoleProfFilterItemVM