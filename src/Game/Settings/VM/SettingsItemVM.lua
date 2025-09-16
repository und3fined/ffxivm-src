---
--- Author: xingcaicao
--- DateTime: 2023-03-22 16:09
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SettingsItemVM : UIViewModel
local SettingsItemVM = LuaClass(UIViewModel)

---Ctor
function SettingsItemVM:Ctor( )
    self.Desc = ""
    self.DisplayStyle = 0
    self.GetValueFunc = nil
    self.SetValueFunc = nil
    self.Value = {}
    self.SettingCfg = nil
    self.SwitchTips = nil
    self.NoTranslateStr = ""
end

function SettingsItemVM:UpdateVM( Value )
    self.Desc = Value.Desc or ""
    self.DisplayStyle = Value.DisplayStyle or 0
    self.GetValueFunc = Value.GetValueFunc
    self.SetValueFunc = Value.SetValueFunc
    self.Value = Value.Value or {}
    self.SettingCfg = Value
    self.SwitchTips = Value.SwitchTips
end

function SettingsItemVM:IsEqualVM(Value)
    return  Value ~= nil and Value.ID == self.SettingCfg.ID
end

function SettingsItemVM:AdapterOnGetWidgetIndex()
    return 1
end

return SettingsItemVM