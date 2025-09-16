---
--- Author: sammrli
--- DateTime: 2023-06-14 15:46
--- Description:玩法验证工具问题item ViewModel
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FieldTestProblemItemVM : UIViewModel
local FieldTestProblemItemVM = LuaClass(UIViewModel)

function FieldTestProblemItemVM:Ctor()
    self.ID = 0
    self.Name = ""
    self.Action = 0
    self.BgColor = "FFFFFF66"
end

function FieldTestProblemItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.Name = Value.Name
    self.Action = Value.Action
end

return FieldTestProblemItemVM