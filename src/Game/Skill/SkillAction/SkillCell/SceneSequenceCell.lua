--
-- Author: henghaoli
-- Date: 2024-04-24 11:46:00
-- Description: 对应C++里面的USceneSequenceCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperResetAction <const> = SkillCellBase.ResetAction

local UE = _G.UE
local TArray = UE.TArray
local AActor = UE.AActor
local UGameplayStatics = UE.UGameplayStatics
local ALevelSequenceActor = UE.ALevelSequenceActor



---@class SceneSequenceCell : SkillCellBase
---@field Super SkillCellBase
---@field LevelSequenceActor userdata
local SceneSequenceCell = LuaClass(SkillCellBase, false)

function SceneSequenceCell:Init(CellData, SkillObject)
    self.LevelSequenceActor = nil
    SuperInit(self, CellData, SkillObject, true)
end

function SceneSequenceCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local SequencePath = self.CellData.m_SequencePath
    if SequencePath == "None" then
        return
    end

    local Actors = TArray(AActor)
    UGameplayStatics.GetAllActorsOfClass(_G.FWORLD(), ALevelSequenceActor.StaticClass(), Actors)
    for Index = 1, Actors:Length() do
        local LevelSequenceActor = Actors:Get(Index):Cast(ALevelSequenceActor)
        local LevelSequenceTarget = LevelSequenceActor:GetSequence()
        if LevelSequenceTarget then
            local SequenceName = LevelSequenceTarget:GetName()
            if string.find(SequencePath, SequenceName) then
                self.LevelSequenceActor = LevelSequenceActor
                break
            end
        end
    end
end

function SceneSequenceCell:PlayLevelSequence()
    local LevelSequenceActor = self.LevelSequenceActor
    if not LevelSequenceActor then
        return
    end
    LevelSequenceActor.PlaybackSettings.bDisableMovementInput = true
    LevelSequenceActor.PlaybackSettings.bDisableLookAtInput = true
    local SequencePlayer = LevelSequenceActor.SequencePlayer
    if SequencePlayer then
        SequencePlayer:Play()
    end
end

function SceneSequenceCell:ResetAction()
    self.LevelSequenceActor = nil
    SuperResetAction(self)
end

return SceneSequenceCell
