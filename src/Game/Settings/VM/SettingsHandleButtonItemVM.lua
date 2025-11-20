
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SettingsHandleButtonItemVM : UIViewModel
local SettingsHandleButtonItemVM = LuaClass(UIViewModel)

function SettingsHandleButtonItemVM:Ctor()
    self.GetValueFunc = nil
    self.DefaultIndexFunc = nil
    self["HandleB"] = ""
    self["HandleY"] = ""
    self["HandleA"] = ""
    self["HandleX"] = ""
    self["HandleRight"] = ""
    self["HandleUp"] = ""
    self["HandleDown"] = ""
    self["HandleLeft"] = ""
    self["HandleRTB"] = ""
    self["HandleRTY"] = ""
    self["HandleRTA"] = ""
    self["HandleRTX"] = ""
    self["HandleRTRight"] = ""
    self["HandleRTUp"] = ""
    self["HandleRTDown"] = ""
    self["HandleRTLeft"] = ""
    self["HandleLTB"] = ""
    self["HandleLTY"] = ""
    self["HandleLTA"] = ""
    self["HandleLTX"] = ""
    self["HandleLTRight"] = ""
    self["HandleLTUp"] = ""
    self["HandleLTDown"] = ""
    self["HandleLTLeft"] = ""
    self["HandleLB"] = ""
    self["HandleRB"] = ""
    self["HandleR"] = ""
    self["HandleRS"] = ""
    self["HandleL"] = ""
    self["HandleSpecialLeft"] = ""
    self["HandleSpecialRight"] = ""
end

function SettingsHandleButtonItemVM:UpdateGetValueFunc(Param)
    if Param then
        self.GetValueFunc = Param
    end
end

function SettingsHandleButtonItemVM:SetCusActionText(SaveKey, CurActionText)
    if CurActionText then
        self[SaveKey] = CurActionText
    end
end

return SettingsHandleButtonItemVM
