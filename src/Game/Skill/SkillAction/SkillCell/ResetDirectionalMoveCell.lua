--
-- Author: henghaoli
-- Date: 2024-04-18 19:41:00
-- Description: 对应C++里面的UResetDirectionalMoveCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")

local UE = _G.UE
local EArtPathType = UE.EArtPathType
local EArtPathCollisionType = UE.EArtPathCollisionType
local FArtPathParams = UE.FArtPathParams

local UMoveSyncMgr = UE.UMoveSyncMgr.Get()

local CommonCurvePath = "CurveVector'/Game/BluePrint/Skill/MoveCurve/MoveToCommon.MoveToCommon'"



---@class ResetDirectionalMoveCell : SkillCellBase
---@field Super SkillCellBase
local ResetDirectionalMoveCell = LuaClass(SkillCellBase, false)

function ResetDirectionalMoveCell:Init(CellData, SkillObject)
    SuperInit(self, CellData, SkillObject, true)
end

function ResetDirectionalMoveCell:StartCell()
    local CellData = self.CellData
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end
    local DirectionalMovePos = SkillObject.DirectionalMovePos
    if not DirectionalMovePos then
        -- 弱网下可能前一个DirectionalMoveCell没有触发
        return
    end

    local OwnerEntityID = SkillObject.OwnerEntityID

    local ArtPathParams = FArtPathParams()
    if _G.SkillLogicMgr:IsSkillSystem(OwnerEntityID) then
        ArtPathParams.bNeedNotifyServer = false
    end
    ArtPathParams.EntityID = OwnerEntityID
    ArtPathParams.PathID = SkillActionUtil.GetPathID(SkillObject)
    ArtPathParams.Duration = CellData.m_EndTime - CellData.m_StartTime
    ArtPathParams.CurveVectorPath = CommonCurvePath
    ArtPathParams.CureScale = -CellData.m_MoveSpeed
    ArtPathParams.ArtPathType = EArtPathType.EndPos
    ArtPathParams.CollisionType = EArtPathCollisionType.NoCollision
    ArtPathParams.EndPos = DirectionalMovePos
    ArtPathParams.bNeedSetRotation = CellData.bNeedSetRotation
    ArtPathParams.SkillID = SkillObject.CurrentSkillID
    UMoveSyncMgr:PlayArtPath(OwnerEntityID, ArtPathParams)
end

function ResetDirectionalMoveCell:StopArtPath()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end
    if SkillObject.bStopSkillBreakArtPath then
        UMoveSyncMgr:StopArtPath(SkillObject.OwnerEntityID, SkillActionUtil.GetPathID(SkillObject))
    end
end

function ResetDirectionalMoveCell:BreakSkill()
    SuperBreakSkill(self)
    self:StopArtPath()
end

function ResetDirectionalMoveCell:ResetAction()
    self:StopArtPath()
    SuperResetAction(self)
end

return ResetDirectionalMoveCell
