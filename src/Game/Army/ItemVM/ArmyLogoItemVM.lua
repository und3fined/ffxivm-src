local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class ArmyLogoItemVM : UIViewModel
local ArmyLogoItemVM = LuaClass(UIViewModel)
---Ctor
function ArmyLogoItemVM:Ctor()
    self.ID = nil
    self.Icon = nil
end

function ArmyLogoItemVM:UpdateVM(Value)
    self.ID = Value.ID
	self.Icon = Value.Icon
end

function ArmyLogoItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end


--要返回当前类
return ArmyLogoItemVM