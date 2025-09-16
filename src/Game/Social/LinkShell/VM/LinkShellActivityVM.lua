---
--- Author: xingcaicao
--- DateTime: 2023-08-09 16:42
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@field ID number @ID
---@field Name string @名称
---@field Icon string @图标
---@class LinkShellActivityVM : UIViewModel
local LinkShellActivityVM = LuaClass(UIViewModel)

function LinkShellActivityVM:Ctor()
    self.ID = nil
    self.Name  = nil
    self.Icon = nil
end

function LinkShellActivityVM:IsEqualVM( Value )
    return Value ~= nil and Value.ID ~= self.ID
end

function LinkShellActivityVM:UpdateVM( Value )
    self.ID     = Value.ID
    self.Name   = Value.Desc
    self.Icon   = Value.Icon
end

return LinkShellActivityVM