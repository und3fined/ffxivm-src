--
-- Author: henghaoli
-- Date: 2024-04-17 14:03:00
-- Description: 对应C++里面的USkillWeightCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init



---@class SkillWeightCell : SkillCellBase
---@field Super SkillCellBase
local SkillWeightCell = LuaClass(SkillCellBase, false)

function SkillWeightCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function SkillWeightCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    self.SkillObject:SetSkillWeight(self.CellData.SkillWeight)
end

return SkillWeightCell
