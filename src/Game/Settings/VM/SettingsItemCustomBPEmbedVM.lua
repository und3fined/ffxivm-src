

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SettingsItemCustomBPEmbedVM : UIViewModel
local SettingsItemCustomBPEmbedVM = LuaClass(UIViewModel)

---Ctor
function SettingsItemCustomBPEmbedVM:Ctor( )
    self.Desc = ""
    self.DisplayStyle = 0
    self.GetValueFunc = nil
    self.SetValueFunc = nil
    self.Value = {}
    self.SettingCfg = nil
    self.NoTranslateStr = nil
end

function SettingsItemCustomBPEmbedVM:UpdateVM( Value )
    self.Desc = Value.Desc or ""
    self.DisplayStyle = Value.DisplayStyle or 0
    self.GetValueFunc = Value.GetValueFunc
    self.SetValueFunc = Value.SetValueFunc
    self.Value = Value.Value or {}
    self.SettingCfg = Value
    self.NoTranslateStr = Value.NoTranslateStr or ""
end

function SettingsItemCustomBPEmbedVM:IsEqualVM(Value)
    return  Value ~= nil and Value.ID == self.SettingCfg.ID
end

function SettingsItemCustomBPEmbedVM:AdapterOnGetWidgetIndex()
    return 5
end

return SettingsItemCustomBPEmbedVM