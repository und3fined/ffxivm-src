local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local FLinearColor = _G.UE.FLinearColor
---@class LoginCreateTextSlotItemVM : UIViewModel
local LoginCreateTextSlotItemVM = LuaClass(UIViewModel)


function LoginCreateTextSlotItemVM:Ctor()
    self.bItemSelect = false
    self.SelectText = false
    self.DataValue = nil
    self.Index = nil
    self.bShowText = true
end

function LoginCreateTextSlotItemVM:UpdateData(TextData)
    self.DataValue = TextData.DataValue
    if TextData.bSize == true then
        self.SelectText = TextData.Index == 1 and _G.LSTR(980041) or _G.LSTR(980042)
        self.DataValue = TextData.Index == 1 and 0 or 1
    else
        self.SelectText = string.format(_G.LSTR(980037), TextData.Index)
    end
end

function LoginCreateTextSlotItemVM:OnSelectedChange(IsSelected)
    self.bItemSelect = IsSelected
end
return LoginCreateTextSlotItemVM