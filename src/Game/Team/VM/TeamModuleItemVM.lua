---
--- Author: xingcaicao
--- DateTime: 2023-06-19 14:57
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class TeamModuleItemVM : UIViewModel
local TeamModuleItemVM = LuaClass(UIViewModel)

function TeamModuleItemVM:Ctor( )
    self.Type = nil
    self.Name = ""
    self.IconPath = ""
    self.IsPlayPointAni = false
end

function TeamModuleItemVM:UpdateVM( Value )
    self.Type       = Value.Type 
    self.Name       = Value.Name or ""
    self.IconPath   = Value.IconPath or ""
    self.ModuleID   = Value.ModuleID
    self.IsPlayPointAni = false
end

function TeamModuleItemVM:SetIsPlayPointAni( IsPlay )
    self.IsPlayPointAni = IsPlay
end

return TeamModuleItemVM