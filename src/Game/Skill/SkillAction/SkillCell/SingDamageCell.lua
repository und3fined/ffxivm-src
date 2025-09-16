--
-- Author: henghaoli
-- Date: 2024-06-06 15:16:00
-- Description: 专供吟唱使用的DamageCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local AudioPlayerTypeMgr = require("Audio/AudioPlayerTypeMgr")

local UAudioMgr = _G.UE.UAudioMgr.Get()
local TimerMgr = _G.TimerMgr



---@class DamageCell : SkillCellBase
---@field Super SkillCellBase
---@field DelayOnHitTimerID number
---@field DelaySoundTimerID number
local SingDamageCell = LuaClass(SkillCellBase, false)

function SingDamageCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function SingDamageCell:StartCell()
    local CellData = self.CellData
    local SkillObject = self.SkillObject
    if not CellData or not SkillObject then
        return
    end

    local TargetIDs = SkillObject.TargetIDList
    if TargetIDs == nil then
        return
    end

    if type(TargetIDs) == "number" then
        TargetIDs = { TargetIDs }
    end

    local DelayTime = CellData.m_DelayTime
    if DelayTime > 0 then
        self.DelayOnHitTimerID = TimerMgr:AddTimer(self, self.PlayOnHitEffect, DelayTime, 1, 1, TargetIDs, "SingDamageCell:PlayOnHitEffect")
    else
        self:PlayOnHitEffect(TargetIDs)
    end
end

function SingDamageCell:PlaySound(Params)
    local TargetIDs, EventPath, OwnerEntityID = table.unpack(Params)
    if not EventPath or EventPath == "None" then
        return
    end

    for _, TargetID in ipairs(TargetIDs) do
        local Target = ActorUtil.GetActorByEntityID(TargetID)
        if Target then
            UAudioMgr:AsyncLoadAndPostEvent(
                EventPath, Target, AudioPlayerTypeMgr:GetOnHitSoundDelegatePair(OwnerEntityID))
        end
    end
end

function SingDamageCell:PlayOnHitEffect(TargetIDs)
    local CellData = self.CellData
    local SkillObject = self.SkillObject
    if not CellData or not SkillObject then
        return
    end

    local SoundDelayTime = CellData.m_SoundDelayTime
    local SoundParams = table.pack(TargetIDs, CellData.m_Event, SkillObject.OwnerEntityID)
    if SoundDelayTime > 0 then
        self.DelaySoundTimerID = TimerMgr:AddTimer(self, self.PlaySound, SoundDelayTime, 1, 1, SoundParams, "SingDamageCell:PlaySound")
    else
        self:PlaySound(SoundParams)
    end
end

function SingDamageCell:ResetAction()
    if self.DelayOnHitTimerID then
        TimerMgr:CancelTimer(self.DelayOnHitTimerID)
        self.DelayOnHitTimerID = nil
    end

    if self.DelaySoundTimerID then
        TimerMgr:CancelTimer(self.DelaySoundTimerID)
        self.DelaySoundTimerID = nil
    end

    SuperResetAction(self)
end

return SingDamageCell
