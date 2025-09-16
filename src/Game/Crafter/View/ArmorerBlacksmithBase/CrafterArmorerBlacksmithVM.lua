local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")



---@class CrafterArmorerBlacksmithVM : UIViewModel
local CrafterArmorerBlacksmithVM = LuaClass(UIViewModel)

function CrafterArmorerBlacksmithVM:Ctor()
    self.bIsTapPanel4Visible = false
    self.bIsTapPanel6Visible = true
end

return CrafterArmorerBlacksmithVM