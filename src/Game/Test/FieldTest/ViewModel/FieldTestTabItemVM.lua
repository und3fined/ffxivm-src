---
--- Author: sammrli
--- DateTime: 2023-05-22 15:46
--- Description:野外测试工具页签 ViewModel
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FieldTestTabItemVM : UIViewModel
local FieldTestTabItemVM = LuaClass(UIViewModel)

function FieldTestTabItemVM:Ctor()
    self.Key = 0
    self.NormalName = "测试"
    self.SelectedName = "测试"
    self.IsNormalVisible = true
    self.IsSelectedVisible = false
    self.CallBack = nil
    self.PanelView = nil
end

function FieldTestTabItemVM:UpdateVM(Value)
    self.Key = Value.Key
    self.NormalName = Value.Name
    self.SelectedName = Value.Name
    self.CallBack = Value.CallBack
    self.PanelView = Value.PanelView
end

return FieldTestTabItemVM