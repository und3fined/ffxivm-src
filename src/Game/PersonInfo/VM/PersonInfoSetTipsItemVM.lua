---
--- Author: xingcaicao
--- DateTime: 2023-10-16 20:43
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PersonInfoSetTipsItemVM : UIViewModel
local PersonInfoSetTipsItemVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoSetTipsItemVM:Ctor( )
    self.Name = nil
    self.Priority = 0
    self.Callback = nil
    self.ReddotID = nil
end

function PersonInfoSetTipsItemVM:IsEqualVM( Value )
    return Value ~= nil and self.Name ~= nil and self.Name == Value.Name
end

function PersonInfoSetTipsItemVM:UpdateVM( Value )
    self.ReddotID   = Value.ReddotID
    self.Name       = Value.Name
    self.Priority   = Value.Priority or 0
    self.Callback   = Value.Callback
end

return PersonInfoSetTipsItemVM