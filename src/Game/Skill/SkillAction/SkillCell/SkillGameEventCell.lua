--
-- Author: henghaoli
-- Date: 2024-04-25 16:16:00
-- Description: 对应C++里面的USkillGameEventCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EGameEventID = ProtoRes.EGameEventID

local EventMgr = _G.EventMgr
local EventID = _G.EventID
local FLOG_ERROR = _G.FLOG_ERROR



---@class SkillGameEventCell : SkillCellBase
---@field Super SkillCellBase
local SkillGameEventCell = LuaClass(SkillCellBase, false)

function SkillGameEventCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function SkillGameEventCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local OwnerEntityID = SkillObject.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)

    if not Me then
        FLOG_ERROR("[SkillGameEventCell] Cannot get owned actor.")
        return
    end

    local Params = EventMgr:GetEventParams()
    Params.ULongParam1 = OwnerEntityID
    Params.IntParam1 = SkillObject.CurrentSkillID

    local GameEventID = CellData.m_EventID
    if GameEventID == EGameEventID.EGameEventID_CrafterSkillEffectEvent then
        Params.FloatParam1 = CellData.AddBuffAnimDelay
        Params.FloatParam2 = CellData.FlyTextDelay
        EventMgr:SendEvent(EventID.CrafterSkillEffect, Params)
    elseif GameEventID == EGameEventID.EGameEventID_GatherSkillEffectEvent then
        EventMgr:SendEvent(EventID.GatherSkillEffect, Params)
    elseif GameEventID == EGameEventID.EGameEventID_PlayUMGAnimEvent then
        Params.StringParam1 = CellData.m_AnimPath
        Params.BoolParam1 = CellData.bIsAnimPlayOnlyWhenSkillSuccessfullyCast
        EventMgr:SendEvent(EventID.PlayUMGAnim, Params)
    elseif GameEventID == EGameEventID.EGameEventID_SummonSingEvent then
        Params.IntParam2 = CellData.SummonID
        Params.IntParam3 = CellData.SingID
        EventMgr:SendEvent(EventID.SummonPlaySing, Params)
    elseif GameEventID == EGameEventID.EGameEventID_GetLifeSkillReward then
        EventMgr:SendEvent(EventID.SkillGameEventGetReward, Params)
    end
end

return SkillGameEventCell
