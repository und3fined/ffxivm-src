---
--- Author: Leo
--- DateTime: 2023-08-29 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class JumboCactpotLottoryNameItemVM : UIViewModel

local JumboCactpotLottoryNameItemVM = LuaClass(UIViewModel)

function JumboCactpotLottoryNameItemVM:Ctor()
    self.Nickname = ""
end

function JumboCactpotLottoryNameItemVM:IsEqualVM()
    return true
end

function JumboCactpotLottoryNameItemVM:UpdateVM(Value)
    self.Nickname = Value.Nickname
end

return JumboCactpotLottoryNameItemVM