---
--- Author: Leo
--- DateTime: 2023-08-29 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class JumboCactpotBoughtNumVM : UIViewModel

local JumboCactpotBoughtNumVM = LuaClass(UIViewModel)

function JumboCactpotBoughtNumVM:Ctor()
    self.BoughtNum = ""
end

function JumboCactpotBoughtNumVM:IsEqualVM()
    return true
end

function JumboCactpotBoughtNumVM:UpdateVM(Value)
    self.BoughtNum = Value
end

return JumboCactpotBoughtNumVM