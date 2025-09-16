

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SettingsItemHyperLinkVM : UIViewModel
local SettingsItemHyperLinkVM = LuaClass(UIViewModel)

---Ctor
function SettingsItemHyperLinkVM:Ctor( )
    self.Desc = ""
    self.DisplayStyle = 0
    self.GetValueFunc = nil
    self.SetValueFunc = nil
    self.Value = {}
    self.SettingCfg = nil
    self.SwitchTips = nil
end

function SettingsItemHyperLinkVM:UpdateVM( Value )
    self.Desc = Value.Desc or ""
    self.DisplayStyle = Value.DisplayStyle or 0
    self.GetValueFunc = Value.GetValueFunc
    self.SetValueFunc = Value.SetValueFunc
    self.Value = Value.Value or {}
    self.SettingCfg = Value
    self.SwitchTips = Value.SwitchTips
    self.NoTranslateStr = Value.NoTranslateStr or ""
end

function SettingsItemHyperLinkVM:IsEqualVM(Value)
    return  Value ~= nil and Value.ID == self.SettingCfg.ID
end

function SettingsItemHyperLinkVM:AdapterOnGetWidgetIndex()
    return 2
end

return SettingsItemHyperLinkVM