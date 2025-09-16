--[[
Author: lightpaw_Leo
Date: 2024-07-30 19:02:12
Description: 剪影拼装Mgr
--]]

local LuaClass = require("Core/LuaClass")
local PuzzleGameBase = require("Game/NewBieGame/Puzzle/PuzzleGameBase")
local PuzzleBurritosVM = require("Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosVM")
local UIViewID = require("Define/UIViewID")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")
local AudioPath = PuzzleDefine.BurritoAudioPath

local UE = _G.UE
local PuzzleBurritosGameInst = LuaClass(PuzzleGameBase, true)
local MoveItemCount = 6 -- 有效的数量
local DestItemCount = 4

function PuzzleBurritosGameInst:Ctor()

end

function PuzzleBurritosGameInst:GetMainViewID()
    return UIViewID.PuzzleBurritosMainPanel
end

function PuzzleBurritosGameInst:OnGetDestCount()
    return DestItemCount
end

-- 子类覆写的，提供默认大小
function PuzzleBurritosGameInst:OnGetDefaultSize()
    return UE.FVector2D(404, 404)
end

--- @type 当完成一块拼图
function PuzzleBurritosGameInst:OnFinishOnePuzzleItem(PuzzleItemID, MoveOp)
    self.Super:OnFinishOnePuzzleItem(PuzzleItemID, MoveOp)
    if not self:IsTimeOut() then
        self.PuzzleMainPanel:PlayAnimation(self.PuzzleMainPanel[string.format("AnimPaperShadow%s", self.FinishNum)])
    end
    self:UpdateShadowVisible(self.FinishNum)
end

-- 移动物品的ID列表，子类覆写提供
function PuzzleBurritosGameInst:OnGetMoveItemIDTable()
    local ResultTable = {}
    for Index = 1, MoveItemCount do
        ResultTable[Index] = Index
    end
    return ResultTable
end

-- 摆放目标区域ID列表，子类覆写提供
function PuzzleBurritosGameInst:OnGetDestItemIDTable()
    local ResultTable = {}
    for Index = 1, DestItemCount do
        ResultTable[Index] = Index
    end
    return ResultTable
end

--- @type 设置拼图背景的显隐
function PuzzleBurritosGameInst:UpdateShadowVisible(Num)
    if self.RemainTime <= 0 then
        return
    end
    PuzzleBurritosVM:UpdateShadowVisible(Num)
end

--- @type 是否在剪影范围
function PuzzleBurritosGameInst:bIsPuzzleRange(Pos)
    return Pos.X >= 580 and Pos.X <= 1000 and Pos.Y >= 280 and Pos.Y <= 630
end


function PuzzleBurritosGameInst:GetCorrectAutioPath()
    return AudioPath.Correct
end


return PuzzleBurritosGameInst