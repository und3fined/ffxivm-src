--
-- Author: Carl
-- Date: 2025-3-25 16:57:14
-- Description:玩法说明索引ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class DepartDescIndexItemVM : UIViewModel
local DepartDescIndexItemVM = LuaClass(UIViewModel)

function DepartDescIndexItemVM:Ctor()
    self.Index = 1
end

function DepartDescIndexItemVM:IsEqualVM(Value)
    return Value ~= nil and Value == self.Index
end

function DepartDescIndexItemVM:UpdateVM(Value)
    self.Index = Value
end

return DepartDescIndexItemVM