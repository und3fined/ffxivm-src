local LuaClass = require("Core/LuaClass")
local CommMenuChildVM = require("Game/Common/Menu/CommMenuChildVM")

---@class House2TabItemVM : UIViewModel
local House2TabItemVM = LuaClass(CommMenuChildVM)


function House2TabItemVM:Ctor()
	self.Key = nil
	self.Name = ""
	self.ModuleID = nil
	self.IsUnLock = false
	self.ParentVM = nil
	self.AlwaysSelect = false
    self.ExtraData = nil
end

function House2TabItemVM:UpdateVM(Value, Parent)
    self.Super.UpdateVM(self, Value, Parent)
    self.ExtraData = Value.ExtraData
end

return House2TabItemVM