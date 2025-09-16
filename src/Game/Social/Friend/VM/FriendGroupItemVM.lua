---
--- Author: xingcaicao
--- DateTime: 2023-08-25 14:43
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FriendGroupItemVM : UIViewModel
local FriendGroupItemVM = LuaClass(UIViewModel)

function FriendGroupItemVM:Ctor()
    self.ID = nil
    self.Name = "" 
    self.CreateTime = 0
end

function FriendGroupItemVM:IsEqualVM( Value )
    return Value ~= nil and Value.ID ~= self.ID
end

function FriendGroupItemVM:UpdateVM( Value )
    self.ID = Value.ID
    self.Name = Value.Name or ""
    self.CreateTime = Value.CreateTime  or 0
end

--- 更新分组名
---@param NewName string @新的分组名
function FriendGroupItemVM:UpdateName( NewName )
    self.Name = NewName or ""
end

return FriendGroupItemVM