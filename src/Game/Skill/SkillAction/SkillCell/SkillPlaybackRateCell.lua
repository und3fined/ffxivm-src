--
-- Author: henghaoli
-- Date: 2024-04-25 18:43:00
-- Description: 对应C++里面的USkillPlaybackRateCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")

local UFGameFXManager = _G.UE.UFGameFXManager.Get()
local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = _G.UE.USkillMgr.RemoveCellTimer



---@class SkillPlaybackRateCell : SkillCellBase
---@field Super SkillCellBase
---@field EndCellTimerID number
local SkillPlaybackRateCell = LuaClass(SkillCellBase, false)

function SkillPlaybackRateCell:Init(CellData, SkillObject)
    self.EndCellTimerID = 0
    SuperInit(self, CellData, SkillObject, true)
end

function SkillPlaybackRateCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    local PlaybackRate = CellData.m_PlaybackRate
    Me:GetAnimationComponent():SetPlayRate(PlaybackRate)
    local EffectList = SkillObject.CurrentEffectIDList
    for _, EffectID in pairs(EffectList) do
        UFGameFXManager:SetPlaybackRate(EffectID, PlaybackRate)
    end
    self.EndCellTimerID = AddCellTimer(self, "EndCell", (CellData.m_EndTime - CellData.m_StartTime) * SkillObject.PlayRate)
end

function SkillPlaybackRateCell:EndCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local EffectList = SkillObject.CurrentEffectIDList
    for _, EffectID in pairs(EffectList) do
        UFGameFXManager:SetPlaybackRate(EffectID, 1 / SkillObject.PlayRate)
    end

    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    Me:GetAnimationComponent():SetPlayRate(1 / SkillObject.PlayRate)
end

function SkillPlaybackRateCell:BreakSkill()
    SuperBreakSkill(self)
    RemoveCellTimer(self.EndCellTimerID)
end

function SkillPlaybackRateCell:ResetAction()
    RemoveCellTimer(self.EndCellTimerID)
    SuperResetAction(self)
end

return SkillPlaybackRateCell
