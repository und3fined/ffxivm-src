---
--- Author: lightpaw_Leo
--- Date: 2024-07-30 19:02:12
--- Description: 剪影拼装ViewModel

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PuzzleBurritosVM = LuaClass(UIViewModel)

---Ctor
function PuzzleBurritosVM:Ctor()
end

function PuzzleBurritosVM:OnInit()
    self:ResetData()
end

function PuzzleBurritosVM:OnBegin()
end

function PuzzleBurritosVM:UpdateVM(Value)
end

function PuzzleBurritosVM:OnShutdown()
end

function PuzzleBurritosVM:ResetData()
    self.PuzzleBurritosTime = "0"

    self.bMoveBread01Visible = true
    self.bMoveBread02Visible = true
    self.bMoveBread03Visible = true
    self.bMoveBread04Visible = true
    self.bMoveBread05Visible = true
    self.bMoveBread06Visible = true

    self.bYesBread01Visible = false
    self.bYesBread02Visible = false
    self.bYesBread03Visible = false
    self.bYesBread04Visible = false

    self.Progress = 0
end

function PuzzleBurritosVM:OnEnd()
    self:ResetData()
end

function PuzzleBurritosVM:SetTimeText(InTimeText)
    self.PuzzleBurritosTime = InTimeText
end

--- @type 设置正确位置img显隐
function PuzzleBurritosVM:SetYesBreadVisible(ID, bVisible)
    local NameIndex = string.format("bYesBread%02dVisible", ID)
    self[NameIndex] = bVisible
end

--- @type 设置可移动img显隐
function PuzzleBurritosVM:SetMoveBreadVisible(ID, bVisible)
    local NameIndex = string.format("bMoveBread%02dVisible", ID)
    self[NameIndex] = bVisible
end

function PuzzleBurritosVM:UpdateProgressValue(InValue)
    self.Progress = InValue
end

--- @type 设置拼图背景得显隐
function PuzzleBurritosVM:UpdateShadowVisible(Num)
    if Num > 5 then
        Num = 5
    end
    for i = 1, 5 do
        local NameIndex = string.format("bShadow%dVisible", i)
        if i <= Num then
            self[NameIndex] = true
        else
            self[NameIndex] = false
        end
    end
end

return PuzzleBurritosVM
