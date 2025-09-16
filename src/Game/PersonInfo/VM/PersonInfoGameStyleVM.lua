---
--- Author: xingcaicao
--- DateTime: 2023-04-21 21:07
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PersonInfoGameStyleVM : UIViewModel
local PersonInfoGameStyleVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoGameStyleVM:Ctor( )
	self.ID         = nil 
    self.Desc       = "" 
    self.Icon       = nil 
    self.IsEmpty    = false
end

function PersonInfoGameStyleVM:IsEqualVM( Value )
    return Value ~= nil and self.ID ~= nil and self.ID == Value.ID
end

function PersonInfoGameStyleVM:UpdateVM( Value )
	self.ID         = Value.ID
    self.Desc       = Value.Desc or ""
    self.Icon       = Value.Icon
    self.IsEmpty    = nil == self.ID
end

return PersonInfoGameStyleVM
