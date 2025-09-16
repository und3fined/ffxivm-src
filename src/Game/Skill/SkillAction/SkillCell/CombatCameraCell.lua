--
-- Author: henghaoli
-- Date: 2024-04-23 16:57:00
-- Description: 对应C++里面的UCombatCameraCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")

local UE = _G.UE
local FCombatCameraParam = UE.FCombatCameraParam


---@class CombatCameraCell : SkillCellBase
---@field Super SkillCellBase
local CombatCameraCell = LuaClass(SkillCellBase, false)

function CombatCameraCell:Init(CellData, SkillObject)
    local bCanPlay = false
    if CellData.CombatCameraParam.IsBroadcast or ActorUtil.IsMajor(SkillObject.OwnerEntityID) then
        bCanPlay = true
    end
    SuperInit(self, CellData, SkillObject, bCanPlay)
end

function CombatCameraCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local ProtoParam = CellData.CombatCameraParam
    local UEParam = FCombatCameraParam()
    UEParam.CameraPositionType = ProtoParam.CameraPositionType
    UEParam.Offset = SkillActionUtil.ProtoVector2FVector(ProtoParam.Offset)
    UEParam.IsLookAtSelf = ProtoParam.IsLookAtSelf
    UEParam.LookAtSocket = ProtoParam.LookAtSocket
    UEParam.LookAtLagDistance = ProtoParam.LookAtLagDistance
    UEParam.LookAtLagSpeed = ProtoParam.LookAtLagSpeed
    UEParam.Rotator = SkillActionUtil.ProtoRotator2FRotator(ProtoParam.Rotator)
    UEParam.FOV = ProtoParam.FOV
    UEParam.TransformType = ProtoParam.TransformType
    UEParam.MoveType = ProtoParam.MoveType
    UEParam.SplinePath = ProtoParam.SplinePath
    UEParam.Weight = ProtoParam.Weight
    UEParam.IsBroadcast = ProtoParam.IsBroadcast
    UEParam.ConditionDistanceMin = ProtoParam.ConditionDistanceMin
    UEParam.ConditionDistanceMax = ProtoParam.ConditionDistanceMax
    UEParam.bResume = ProtoParam.bResume
    UEParam.bRecord = ProtoParam.bRecord

    UE.UCameraMgr.Get():PlayCombatCameraAction(UEParam, CellData.m_EndTime - CellData.m_StartTime)
end

function CombatCameraCell:BreakSkill()
    SuperBreakSkill(self)
    UE.UCameraMgr.Get():BreakCombatCamera()
end

return CombatCameraCell
