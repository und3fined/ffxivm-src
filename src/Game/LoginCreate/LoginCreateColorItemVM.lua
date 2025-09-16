local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local FLinearColor = _G.UE.FLinearColor
---@class LoginCreateColorItemVM : UIViewModel
local LoginCreateColorItemVM = LuaClass(UIViewModel)


function LoginCreateColorItemVM:Ctor()
    self.bItemSelect = false
    self.SelectText = false
    self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 1) -- 色板单元格颜色
    self.DataValue = nil
   
end

function LoginCreateColorItemVM:UpdateData(ColorData)
    local ColorValue = ColorData.Color
    if ColorValue == nil then
        FLOG_ERROR("ColorValue error, please check CColorList")
        return
    end
    self.ItemColorAndOpacity = FLinearColor(ColorValue.R/255, ColorValue.G/255, ColorValue.B/255, ColorValue.A/255)
    self.DataValue = ColorData.DataValue
    self.SelectText = string.format("%d", self.DataValue)
end

function LoginCreateColorItemVM:OnSelectedChange(IsSelected)
    self.bItemSelect = IsSelected
end
return LoginCreateColorItemVM