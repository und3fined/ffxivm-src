---
--- Author: xingcaicao
--- DateTime: 2023-05-05 10:39
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SimpleProfInfoVM : UIViewModel
local SimpleProfInfoVM = LuaClass(UIViewModel)

---Ctor
function SimpleProfInfoVM:Ctor( )
    self.ProfID = nil
    self.Level = 0
    self.LevelDesc = ""
    self.IsEmpty = false
end

function SimpleProfInfoVM:IsEqualVM( Value )
    return Value ~= nil and self.ProfID ~= nil and self.ProfID == Value.ProfID and self.Level == Value.Level and self.IsEmpty == Value.IsEmpty
end

function SimpleProfInfoVM:UpdateVM( Value )
	self.ProfID = Value.ProfID
	self.Level  = Value.Level or 0
    self.LevelDesc  = tostring(self.Level) or ""
    self.IsEmpty = nil == self.ProfID or self.ProfID <= 0
end

return SimpleProfInfoVM