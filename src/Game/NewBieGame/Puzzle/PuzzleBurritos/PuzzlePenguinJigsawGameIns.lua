--[[
Author: lightpaw_Leo
Date: 2024-07-30 19:02:12
Description: 剪影拼装Mgr
--]]
local LuaClass = require("Core/LuaClass")
local PuzzleGameBase = require("Game/NewBieGame/Puzzle/PuzzleGameBase")
local PuzzleBurritosVM = require("Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosVM")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")
local UIViewID = require("Define/UIViewID")
local UE = _G.UE
local PuzzlePenguinJigsawGameIns = LuaClass(PuzzleGameBase, true)

local AudioPath = PuzzleDefine.BurritoAudioPath
local MoveItemCount = 6 -- 可以移动的数量为6个
local PreFinishCount = 3 -- 提前完成的数量
local DestItemCount = 9 -- 所有拼图的碎片数量

function PuzzlePenguinJigsawGameIns:Ctor()
end

function PuzzlePenguinJigsawGameIns:GetMainViewID()
    return UIViewID.PuzzlePenguinJigsawMainView
end

function PuzzlePenguinJigsawGameIns:OnGetDefaultSize()
    return UE.FVector2D(200, 200)
end

-- 移动物品的ID列表，子类覆写提供
function PuzzlePenguinJigsawGameIns:OnGetMoveItemIDTable()
    local ResultTable = {}
    for Index = 1, MoveItemCount do
        ResultTable[Index] = Index
    end
    return ResultTable
end

-- 摆放目标区域ID列表，子类覆写提供
function PuzzlePenguinJigsawGameIns:OnGetDestItemIDTable()
    local ResultTable = {}
    for Index = 1, DestItemCount do
        ResultTable[Index] = Index
    end
    return ResultTable
end

--- @type 当完成一块拼图
function PuzzlePenguinJigsawGameIns:OnFinishOnePuzzleItem(PuzzleItemID, MoveOp)
    if not self:IsTimeOut() then
        self:AddFinishNum()
    end
    if (self.PuzzleMainPanel ~= nil and self.PuzzleMainPanel:IsValid()) then
        self.PuzzleMainPanel:EndHelpTip()
    end
    PuzzleBurritosVM:SetYesBreadVisible(PuzzleItemID, true)
    local CalcFinishCount = self.FinishNum - PreFinishCount
    if (CalcFinishCount < 0) then
        CalcFinishCount = 0
    end
    PuzzleBurritosVM:UpdateProgressValue(CalcFinishCount / MoveItemCount)
    self:ResetNoRightOpTime()
    self:CheckIsSuccess()

    if (self.ValidDestItemIDTable ~= nil) then
        for Key, Value in pairs(self.ValidDestItemIDTable) do
            if (Value == PuzzleItemID) then
                self.ValidDestItemIDTable[Key] = nil
                break
            end
        end
    end
end

function PuzzlePenguinJigsawGameIns:OnTimeRunOut()
    local NeedText = LocalizationUtil.GetTimerForHighPrecision(0)
    PuzzleBurritosVM:SetTimeText(NeedText)
    if (self.PuzzleMainPanel ~= nil and self.PuzzleMainPanel:IsValid()) then
        self.PuzzleMainPanel:OnTimeOut()
    end
end

function PuzzlePenguinJigsawGameIns:OnGetDestCount()
    return DestItemCount
end

--- @type 设置零散区拼图大小位置以及角度
function PuzzlePenguinJigsawGameIns:SetPuzzleItemPosAngleAndSize(PuzzleItem, Cfg)
end

--- @type 是否在剪影范围
function PuzzlePenguinJigsawGameIns:bIsPuzzleRange(Pos)
    return Pos.X >= 600 and Pos.X <= 1330 and Pos.Y >= 240 and Pos.Y <= 980
end

function PuzzlePenguinJigsawGameIns:GetCorrectAutioPath()
    return AudioPath.Correct
end


return PuzzlePenguinJigsawGameIns
