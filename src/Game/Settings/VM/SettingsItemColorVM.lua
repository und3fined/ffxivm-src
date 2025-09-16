

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SettingsItemColorVM : UIViewModel
local SettingsItemColorVM = LuaClass(UIViewModel)

---Ctor
function SettingsItemColorVM:Ctor( )
    self.Desc = ""
    self.DisplayStyle = 0
    self.GetValueFunc = nil
    self.SetValueFunc = nil
    self.Value = {}
    self.SettingCfg = nil
    self.SwitchTips = nil
end

function SettingsItemColorVM:UpdateVM( Value )
    self.Desc = Value.Desc or ""
    self.DisplayStyle = Value.DisplayStyle or 0
    self.GetValueFunc = Value.GetValueFunc
    self.SetValueFunc = Value.SetValueFunc
    self.Value = Value.Value or {}
    self.SettingCfg = Value
    self.SwitchTips = Value.SwitchTips
end

function SettingsItemColorVM:IsEqualVM(Value)
    return  Value ~= nil and Value.ID == self.SettingCfg.ID
end

function SettingsItemColorVM:AdapterOnGetWidgetIndex()
    return 4
end

return SettingsItemColorVM