--
-- Author: henghaoli
-- Date: 2024-04-18 20:20:00
-- Description: 对应C++里面的USkillControlTurnCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local ActorUtil = require("Utils/ActorUtil")

local EActorControllStat = _G.UE.EActorControllStat
local StateTag <const> = require("Game/Skill/SkillAction/SkillActionDefine").SkillActionStateTag



---@class SkillControlTurnCell : SkillCellBase
---@field Super SkillCellBase
local SkillControlTurnCell = LuaClass(SkillCellBase, false)

function SkillControlTurnCell:Init(CellData, SkillObject)
    local Delay = CellData.m_StartTime * SkillObject.PlayRate
    if Delay <= 0.03 then
        SuperInit(self, CellData, SkillObject, false)
        self:StartCell()
    else
        SuperInit(self, CellData, SkillObject, true)
    end
end

function SkillControlTurnCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local OwnerEntityID = SkillObject.OwnerEntityID
    local StateComp = ActorUtil.GetActorStateComponent(OwnerEntityID)
    if not StateComp then
        return
    end

    if self.CellData.SkillControlTurn then
        StateComp:SetActorControlState(EActorControllStat.CanTurn, false, StateTag)
    else
        StateComp:SetActorControlState(EActorControllStat.CanTurn, true, StateTag)
    end
end

return SkillControlTurnCell
