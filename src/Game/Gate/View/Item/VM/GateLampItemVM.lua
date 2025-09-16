---
--- Author: sammrli
--- DateTime: 2023-09-18 20:30
--- Description: 分数Item View Modle
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class GateLampItemVM : UIViewModel
---@field SetNumber function
local GateLampItemVM = LuaClass(UIViewModel)

function GateLampItemVM:Ctor()
    self.Number = 0
    self.IconNumber = nil
    self.NumberAddCallback = nil
    self.NumberSubtractCallback = nil
end

function GateLampItemVM:UpdateVM(Value)
    self.Number = Value.Number
    self.IconNumber = Value.IconNumber
end

function GateLampItemVM:SetNumber(Number, IsAdd)
    if self.Number ~= Number then
        self.IconNumber = string.format("PaperSprite'/Game/UI/Atlas/Gate/Frames/UI_Gate_PanelLamp_Img_Number%d_png.UI_Gate_PanelLamp_Img_Number%d_png'", Number, Number)
        if IsAdd then
            if self.NumberAddCallback then
                self.NumberAddCallback()
            end
        else
            if self.NumberSubtractCallback then
                self.NumberSubtractCallback()
            end
        end

        self.Number = Number
    end
end

function GateLampItemVM:SetNumberAddCallback(Func)
    self.NumberAddCallback = Func
end

function GateLampItemVM:SetNumberSubtractCallback(Func)
    self.NumberSubtractCallback = Func
end

return GateLampItemVM
