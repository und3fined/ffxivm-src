local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class MounGetWayItemVM : UIViewModel
local MounGetWayItemVM = LuaClass(UIViewModel)

function MounGetWayItemVM:Ctor()
    self.GetText = nil
    self.GetWayIcon = nil
end


return MounGetWayItemVM