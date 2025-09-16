

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SettingsItemSliderVM : UIViewModel
local SettingsItemSliderVM = LuaClass(UIViewModel)

---Ctor
function SettingsItemSliderVM:Ctor( )
    self.Desc = ""
    self.DisplayStyle = 0
    self.GetValueFunc = nil
    self.SetValueFunc = nil
    self.Value = {}
    self.SettingCfg = nil
    self.SwitchTips = nil
end

function SettingsItemSliderVM:UpdateVM( Value )
    self.Desc = Value.Desc or ""
    self.DisplayStyle = Value.DisplayStyle or 0
    self.GetValueFunc = Value.GetValueFunc
    self.SetValueFunc = Value.SetValueFunc
    self.Value = Value.Value or {}
    self.SettingCfg = Value
    self.SwitchTips = Value.SwitchTips
end

function SettingsItemSliderVM:IsEqualVM(Value)
    return  Value ~= nil and Value.ID == self.SettingCfg.ID
end

function SettingsItemSliderVM:AdapterOnGetWidgetIndex()
    return 1
end

return SettingsItemSliderVM