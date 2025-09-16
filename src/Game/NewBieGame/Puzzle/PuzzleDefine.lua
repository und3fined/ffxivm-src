
--[[
Author: lightpaw_Leo
Date: 2024-08-2 14:02:12
Description: 剪影拼装默认配置
--]]


local GameID = {
    Burritos = 1,
    PenguinJigsaw = 2,
}

local EndType = { SuccessEnd = 1, TimeOutEnd = 2 }

local function Lerp(A, B, Alpha)
    return (1- Alpha) * A + Alpha * B
end

local function Vector2DLerp(A, B, Alpha)
    local AX = (1- Alpha) * (A.X)
    local AY = (1- Alpha) * (A.Y)

    local BX = Alpha * (B.X)
    local BY = Alpha * (B.Y)

    return _G.UE.FVector2D(AX + BX, AY + BY)
end

-- 移动到目标位置的操作
local MoveToTargetOp = {
    ByDrag = 1,
    ByMouseClickAutoMove = 2,
    ByTimeOutAutoMove = 3,
}

local BurritoAudioPath = {
    Perpare = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_prepare.Play_Mini_Gilgamesh_prepare'",
    Begin = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_start.Play_Mini_Gilgamesh_start'",
    Correct = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_UI_Puzzle_correct.Play_UI_Puzzle_correct'",
    Error = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_UI_Puzzle_fail.Play_UI_Puzzle_fail'",
    Success = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Gilgamesh/Play_Mini_Gilgamesh_perfect1.Play_Mini_Gilgamesh_perfect1'",
    AutoFinish = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/QuestGames/Play_UI_Puzzle_auto.Play_UI_Puzzle_auto'",
}

local PuzzleDefine = {
    GameID = GameID,
    Lerp = Lerp,
    Vector2DLerp = Vector2DLerp,
    MoveToTargetOp = MoveToTargetOp,
    EndType = EndType,
    BurritoAudioPath = BurritoAudioPath,
}





return PuzzleDefine