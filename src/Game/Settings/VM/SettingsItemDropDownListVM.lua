
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SettingsItemDropDownListVM : UIViewModel
local SettingsItemDropDownListVM = LuaClass(UIViewModel)

---Ctor
function SettingsItemDropDownListVM:Ctor( )
    self.Desc = ""
    self.DisplayStyle = 0
    self.GetValueFunc = nil
    self.SetValueFunc = nil
    self.Value = {}
    self.SettingCfg = nil
    self.SwitchTips = nil
end

function SettingsItemDropDownListVM:UpdateVM( Value )
    self.Desc = Value.Desc or ""
    self.DisplayStyle = Value.DisplayStyle or 0
    self.GetValueFunc = Value.GetValueFunc
    self.SetValueFunc = Value.SetValueFunc
    self.Value = Value.Value or {}
    self.SettingCfg = Value
    self.SwitchTips = Value.SwitchTips
end

function SettingsItemDropDownListVM:IsEqualVM(Value)
    return  Value ~= nil and Value.ID == self.SettingCfg.ID
end

function SettingsItemDropDownListVM:AdapterOnGetWidgetIndex()
    return 3
end

return SettingsItemDropDownListVM