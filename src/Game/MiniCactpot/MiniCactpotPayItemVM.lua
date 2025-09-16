local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MiniCactpotPayItemVM : UIViewModel
local MiniCactpotPayItemVM = LuaClass(UIViewModel)

---Ctor
function MiniCactpotPayItemVM:Ctor()
    self.Sum = 0
    self.AwardNum = 0

    self.IsChecked = false
    self.IsSelected = false
end

return MiniCactpotPayItemVM
