--
-- Author: henghaoli
-- Date: 2024-04-24 17:29:00
-- Description: 对应C++里面的USkillChangeActorCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init

local EventMgr = _G.EventMgr
local EventID = _G.EventID



---@class SkillChangeActorCell : SkillCellBase
---@field Super SkillCellBase
local SkillChangeActorCell = LuaClass(SkillCellBase, false)

function SkillChangeActorCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function SkillChangeActorCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local Params = EventMgr:GetEventParams()
    Params.IntParam1 = CellData.ActorType
    Params.IntParam2 = CellData.ActorValue
    Params.ULongParam1 = SkillObject.OwnerEntityID

    EventMgr:SendCppEvent(EventID.ChangeActorShow, Params)
    EventMgr:SendEvent(EventID.ChangeActorShow, Params)
end

return SkillChangeActorCell
