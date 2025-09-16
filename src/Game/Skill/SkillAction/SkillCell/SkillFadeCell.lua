--
-- Author: henghaoli
-- Date: 2024-04-23 17:15:00
-- Description: 对应C++里面的USkillFadeCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init



---@class SkillFadeCell : SkillCellBase
---@field Super SkillCellBase
local SkillFadeCell = LuaClass(SkillCellBase, false)

function SkillFadeCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, self:CanShow(CellData, SkillObject))
end

function SkillFadeCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    _G.UE.UCameraPostEffectMgr.Get():SetColorFadeWithExit(
        CellData.TargetType, CellData.Duration, CellData.AnimType,
        CellData.ExitTargetType, CellData.ExitDuration, CellData.ExitAnimType,
        CellData.m_EndTime - CellData.m_StartTime)
end

return SkillFadeCell
