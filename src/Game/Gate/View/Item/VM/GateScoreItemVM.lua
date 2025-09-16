---
--- Author: sammrli
--- DateTime: 2023-09-18 20:30
--- Description: 分数Item View Modle
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class GateScoreItemVM : UIViewModel
---@field SetNumber function
local GateScoreItemVM = LuaClass(UIViewModel)

function GateScoreItemVM:Ctor()
    self.Number = 0
    self.IconNumber = nil
    self.NumberAddCallback = nil
    self.NumberSubtractCallback = nil
end

function GateScoreItemVM:UpdateVM(Value)
    self.Number = Value.Number
    self.IconNumber = Value.IconNumber
end

function GateScoreItemVM:SetNumber(Number, IsAdd)
    if self.Number ~= Number then
        self.IconNumber = string.format("PaperSprite'/Game/UI/Atlas/Gate/Frames/UI_Gate_Img_ScoreNumber%d_png.UI_Gate_Img_ScoreNumber%d_png'", Number, Number)
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

function GateScoreItemVM:SetNumberAddCallback(Func)
    self.NumberAddCallback = Func
end

function GateScoreItemVM:SetNumberSubtractCallback(Func)
    self.NumberSubtractCallback = Func
end

return GateScoreItemVM
