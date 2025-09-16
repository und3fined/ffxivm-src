---
--- Author: Leo
--- DateTime: 2023-08-29 15:30:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class JumboCactpotTipsItemVM : UIViewModel

local JumboCactpotTipsItemVM = LuaClass(UIViewModel)

function JumboCactpotTipsItemVM:Ctor()
    self.TipContent = ""

end

function JumboCactpotTipsItemVM:IsEqualVM()
    return true
end

function JumboCactpotTipsItemVM:UpdateVM(Value)
    self.TipContent = Value
end

return JumboCactpotTipsItemVM