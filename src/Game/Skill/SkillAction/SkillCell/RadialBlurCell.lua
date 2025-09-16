--
-- Author: henghaoli
-- Date: 2024-04-23 18:54:00
-- Description: 对应C++里面的URadialBlurCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")



---@class RadialBlurCell : SkillCellBase
---@field Super SkillCellBase
local RadialBlurCell = LuaClass(SkillCellBase, false)

function RadialBlurCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, self:CanShow(CellData, SkillObject))
end

function RadialBlurCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local Duration = (CellData.m_EndTime - CellData.m_StartTime) * SkillObject.PlayRate
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)

    _G.UE.UCameraPostEffectMgr.Get():StartRadialBlur(
        CellData.SocketName, CellData.BlurDst, CellData.BlurRadius,
        CellData.BlurStrength, Duration, Me,
        SkillActionUtil.ProtoVector2FVector(CellData.PointOffset), math.floor(CellData.RadialBlurWeight),
        CellData.m_EffectType, CellData.BlurDstPower, CellData.BlurRadiusPower)
end

return RadialBlurCell
