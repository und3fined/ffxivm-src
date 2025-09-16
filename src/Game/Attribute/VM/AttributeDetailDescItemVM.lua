local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class AttributeDetailDescItemVM : UIViewModel
local AttributeDetailDescItemVM = LuaClass(UIViewModel)

function AttributeDetailDescItemVM:Ctor()
    self.Index = nil
    self.ItemType = nil
    self.bOpen = true
    self.LeftText = nil
    self.LeftSubText = nil
    self.RightText = nil
    self.RightSubText = nil
    self.RightSubTextColor = "00FD2BFF" --红色f80003
    self.DescText = nil
	self.bIsLastItem = false
	self.bInLevelSync = false
end

return AttributeDetailDescItemVM