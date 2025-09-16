--
-- Author: henghaoli
-- Date: 2024-04-18 20:11:00
-- Description: 对应C++里面的USkillControlCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local ActorUtil = require("Utils/ActorUtil")

local EActorControllStat = _G.UE.EActorControllStat
local StateTag <const> = require("Game/Skill/SkillAction/SkillActionDefine").SkillActionStateTag



---@class SkillControlCell : SkillCellBase
---@field Super SkillCellBase
local SkillControlCell = LuaClass(SkillCellBase, false)

function SkillControlCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function SkillControlCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local OwnerEntityID = SkillObject.OwnerEntityID
    local StateComp = ActorUtil.GetActorStateComponent(OwnerEntityID)
    if not StateComp then
        return
    end

    if self.CellData.SkillControl then
        StateComp:SetActorControlState(EActorControllStat.CanMove, false, StateTag)
    else
        StateComp:SetActorControlState(EActorControllStat.CanMove, true, StateTag)
    end
end

return SkillControlCell
