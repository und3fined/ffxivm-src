--
-- Author: henghaoli
-- Date: 2024-04-24 11:23:00
-- Description: 对应C++里面的UCameraEffectCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EDamageEffectType = ProtoRes.EDamageEffectType



---@class CameraEffectCell : SkillCellBase
---@field Super SkillCellBase
local CameraEffectCell = LuaClass(SkillCellBase, false)

function CameraEffectCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, self:CanShow(CellData, SkillObject))
end

function CameraEffectCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local FXPath = CellData.m_EffectTemplate
    if CellData.m_EffectType == EDamageEffectType.EDamageEffectType_Actor then
        FXPath = CellData.m_EffectActor
    end
    _G.UE.UCameraMgr.Get():PlayCameraEffect(
        FXPath, SkillActionUtil.ProtoRotator2FRotator(CellData.m_RelativeRotation), CellData.m_ViewportScale)
end

return CameraEffectCell
