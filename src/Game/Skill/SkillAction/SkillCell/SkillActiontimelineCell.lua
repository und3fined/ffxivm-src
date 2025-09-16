--
-- Author: henghaoli
-- Date: 2024-04-23 19:14:00
-- Description: 对应C++里面的USkillActiontimelineCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EAreaType = ProtoRes.EAreaType

local UE = _G.UE
local EAvatarPartType = UE.EAvatarPartType



---@class SkillActiontimelineCell : SkillCellBase
---@field Super SkillCellBase
local SkillActiontimelineCell = LuaClass(SkillCellBase, false)

function SkillActiontimelineCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function SkillActiontimelineCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local AreaType = EAvatarPartType.MASTER
    if CellData.m_AreaType ~= EAreaType.EAreaType_Actor then
        AreaType = EAvatarPartType.RIDE_MASTER
    end

    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    if Me then
        Me:GetAnimationComponent():PlayActionTimelineMulti(CellData.ID, AreaType)
    end
end

return SkillActiontimelineCell
