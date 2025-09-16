---
--- Author: xingcaicao
--- DateTime: 2024-08-15 16:57
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FriendScreenStyleItemVM : UIViewModel
local FriendScreenStyleItemVM = LuaClass(UIViewModel)

function FriendScreenStyleItemVM:Ctor()
    self.ID = "" 
    self.Icon = ""
    self.Desc = "" 
end

function FriendScreenStyleItemVM:UpdateVM(Value)
    self.ID = Value.ID 
    self.Icon = Value.Icon 
    self.Desc = Value.Desc or ""
end

return FriendScreenStyleItemVM 