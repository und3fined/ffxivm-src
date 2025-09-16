local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class DepotLogoItemVM : UIViewModel
local DepotLogoItemVM = LuaClass(UIViewModel)
---Ctor
function DepotLogoItemVM:Ctor()
    self.ID = nil
    self.Icon = nil
end

function DepotLogoItemVM:UpdateVM(Value)
    self.ID = Value.ID
	self.Icon = Value.Icon
end

function DepotLogoItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end


--要返回当前类
return DepotLogoItemVM