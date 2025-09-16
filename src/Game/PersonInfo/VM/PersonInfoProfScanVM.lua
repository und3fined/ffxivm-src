---
--- Author: xingcaicao
--- DateTime: 2023-04-13 19:40
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class PersonInfoProfScanVM : UIViewModel
local PersonInfoProfScanVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoProfScanVM:Ctor( )
    self.ProfID = nil
    self.Level = '-'
    self.IsMaxLevel = false
end

function PersonInfoProfScanVM:IsEqualVM( Value )
    return Value ~= nil and self.ProfID ~= nil and self.ProfID == Value.ProfID
end

function PersonInfoProfScanVM:UpdateVM( Value )
	self.ProfID     = Value.ProfID
	self.Level      = Value.Level or 0
    self.IsMaxLevel = Value.Level >= 90
end

return PersonInfoProfScanVM