local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")
local AnimVoiceCfg = require("TableCfg/AnimVoiceCfg")

---@class LoginCreateVoiceItemVM : UIViewModel
local LoginCreateVoiceItemVM = LuaClass(UIViewModel)


function LoginCreateVoiceItemVM:Ctor()
    self.bItemSelect = false
    self.CheckIcon = nil
    self.UnChecIcon = nil
end

function LoginCreateVoiceItemVM:SetItemType(Index)
    local AnimVoiceTable = AnimVoiceCfg:FindCfg("ID = " .. Index)
    self.CheckIcon = AnimVoiceTable.IconSelect
    self.UnChecIcon = AnimVoiceTable.Icon
end

function LoginCreateVoiceItemVM:SetItemSelected(IsSelected)
    self.bItemSelect = IsSelected
end
return LoginCreateVoiceItemVM