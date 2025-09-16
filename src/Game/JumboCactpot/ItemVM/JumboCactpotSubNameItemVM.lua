---
--- Author: Leo
--- DateTime: 2023-08-29 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class JumboCactpotSubNameItemVM : UIViewModel

local JumboCactpotSubNameItemVM = LuaClass(UIViewModel)

function JumboCactpotSubNameItemVM:Ctor()
    self.Nickname = ""
    self.RoleId = 0
end

function JumboCactpotSubNameItemVM:IsEqualVM()
    return true
end

function JumboCactpotSubNameItemVM:UpdateVM(Value)
    self.Nickname = Value.Nickname
    self.RoleId = Value.RoleId

end

return JumboCactpotSubNameItemVM