---
--- Author: sammrli
--- DateTime: 2023-09-20 20:30
--- Description: 金蝶结算界面Item View Modle
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@see GateResultListItemView

---@class GateResultListItemVM : UIViewModel
---@field IconPath stirng
---@field Name string
---@field Num string
---@field Score string
local GateResultListItemVM = LuaClass(UIViewModel)

function GateResultListItemVM:Ctor()
    self.IconPath = nil
    self.Name = nil
    self.Num = nil
    self.Score = nil
end

function GateResultListItemVM:UpdateVM(Value)
    self.IconPath = Value.IconPath
end

return GateResultListItemVM
