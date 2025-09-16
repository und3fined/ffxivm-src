--
-- Author: henghaoli
-- Date: 2024-04-23 17:23:00
-- Description: 对应C++里面的UFadeActorCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local ActorUtil = require("Utils/ActorUtil")



---@class FadeActorCell : SkillCellBase
---@field Super SkillCellBase
local FadeActorCell = LuaClass(SkillCellBase, false)

function FadeActorCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true, true)
end

function FadeActorCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    if not Me then
        return
    end

    local FadeTime = CellData.m_EndTime - CellData.m_StartTime
    -- fade out
    if CellData.TargetType == 1 then
        Me:StartFadeOut(FadeTime, 0)
    -- fade in
    else
        Me:StartFadeIn(FadeTime, true)
    end
end

return FadeActorCell
