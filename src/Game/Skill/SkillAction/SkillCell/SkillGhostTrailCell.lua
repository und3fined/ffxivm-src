--
-- Author: henghaoli
-- Date: 2024-04-25 16:45:00
-- Description: 对应C++里面的USkillGhostTrailCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")

local UE = _G.UE
local GetConsoleVariableBoolValue = UE.UKismetSystemLibrary.GetConsoleVariableBoolValue
local SkillLogicMgr = _G.SkillLogicMgr
local TArray = UE.TArray
local FName = UE.FName
local FMatEditParam = UE.FMatEditParam
local TArray_TagsToGhost = TArray(FName)
local TArray_MatParams = TArray(FMatEditParam)



---@class SkillGhostTrailCell : SkillCellBase
---@field Super SkillCellBase
---@field GhostTrailEffect userdata
local SkillGhostTrailCell = LuaClass(SkillCellBase, false)

function SkillGhostTrailCell:Init(CellData, SkillObject)
    self.GhostTrailEffect = nil
    SuperInit(self, CellData, SkillObject, true)
end

function SkillGhostTrailCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    if GetConsoleVariableBoolValue("r.ghosttrail") then
        local AvatarComp = ActorUtil.GetActorAvatarComponent(SkillObject.OwnerEntityID)
        if not AvatarComp then
            return
        end

        TArray_TagsToGhost:Clear()
        local TagsToGhost = CellData.TagsToGhost
        for _, Tag in ipairs(TagsToGhost) do
            TArray_TagsToGhost:Add(FName(Tag))
        end

        TArray_MatParams:Clear()
        local MatParams = CellData.MatParams
        for _, MatParam in ipairs(MatParams) do
            local UE_MatParam = FMatEditParam()
            UE_MatParam.ParamName = MatParam.ParamName
            UE_MatParam.Curve = MatParam.Curve
            UE_MatParam.ColorCurve = MatParam.ColorCurve
            TArray_MatParams:Add(UE_MatParam)
        end

        self.GhostTrailEffect = AvatarComp:StartGhostTrail(
            CellData.m_EndTime - CellData.m_StartTime,
            CellData.GhostSpawnDelay,
            CellData.GhostLifetime,
            CellData.GhostAmount,
            CellData.GhostAllMeshes,
            TArray_TagsToGhost,
            CellData.GhostMaterial,
            TArray_MatParams,
            CellData.ScaleOverTime,
            CellData.ScaleCurve,
            true
        )
    end
end

function SkillGhostTrailCell:BreakSkill()
    SuperBreakSkill(self)
    local OwnerEntityID = self.SkillObject.OwnerEntityID
    local AvatarComp = ActorUtil.GetActorAvatarComponent(OwnerEntityID)
    if AvatarComp and SkillLogicMgr:IsSkillSystem(OwnerEntityID) then
        AvatarComp:StopGhostTrailEffect(self.GhostTrailEffect)
    end
end

function SkillGhostTrailCell:ResetAction()
    self:BreakSkill()
    SuperResetAction(self)
end

return SkillGhostTrailCell
