---
--- Author: xingcaicao
--- DateTime: 2023-10-16 20:43
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PersonInfoBtnVM : UIViewModel
local PersonInfoBtnVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoBtnVM:Ctor( )
    self.ID = nil
    self.Name = nil
    self.Priority = 0
    self.IsAdd = nil
    self.BtnIcon = ''
end

function PersonInfoBtnVM:IsEqualVM( Value )
    return Value ~= nil and self.ID ~= nil and self.ID == Value.ID
end

function PersonInfoBtnVM:UpdateVM( Value )
	self.ID         = Value.ID
    self.Name       = Value.Name
    self.Priority   = Value.Priority or 0
    self.IsAdd      = Value.IsAdd
    -- print('personinfo icon = ' .. tostring(Value.Icon))
    self.BtnIcon    = Value.Icon
end

return PersonInfoBtnVM