local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MountSettingTipsItemVM : UIViewModel
local MountSettingTipsItemVM = LuaClass(UIViewModel)

function MountSettingTipsItemVM:Ctor()
    self.bSelect = false
    self.Title = nil
    self.TitleColor = nil
    self.Index = nil
end

function MountSettingTipsItemVM:SetSelect(InSelect)
    self.bSelect = InSelect
    self.TitleColor = self.bSelect and "C9C08FFF" or "AFAFAFFF"
end

return MountSettingTipsItemVM