---
--- Author: Leo
--- DateTime: 2023-09-21 19:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class JumboCactpotResumDianItemVM : UIViewModel

local JumboCactpotResumDianItemVM = LuaClass(UIViewModel)

function JumboCactpotResumDianItemVM:Ctor()
    self.bIsSelect = false
    self.bIsNotSelect = false
end

function JumboCactpotResumDianItemVM:IsEqualVM()
    return true
end

function JumboCactpotResumDianItemVM:UpdateVM(Value)
    local bIsSelect = Value
    self.bIsSelect = bIsSelect
    self.bIsNotSelect = not bIsSelect
end

return JumboCactpotResumDianItemVM