local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class MenuBtnVM : UIViewModel
local MenuBtnVM = LuaClass(UIViewModel)
---Ctor
function MenuBtnVM:Ctor()
    self.Value = nil
    self.Name = nil
end

function MenuBtnVM:UpdateVM(Value)
	self.Name = Value.Name
    self.Value = Value
end

function MenuBtnVM:IsEqualVM(Value)
    return nil ~= Value and Value.Name == self.Name
end


--要返回当前类
return MenuBtnVM