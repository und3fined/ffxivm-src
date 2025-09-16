--
-- Author: henghaoli
-- Date: 2024-04-18 15:54:00
-- Description: 对应C++里面的UDirectionalMoveCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")

local UE = _G.UE
local EArtPathType = UE.EArtPathType
local EArtPathCollisionType = UE.EArtPathCollisionType
local FArtPathParams = UE.FArtPathParams

local UMoveSyncMgr = UE.UMoveSyncMgr.Get()

local DefaultBlendOutTime = 0.3



---@class DirectionalMoveCell : SkillCellBase
---@field Super SkillCellBase
---@field CurAttackData table
---@field ArtPathParams userdata
local DirectionalMoveCell = LuaClass(SkillCellBase, false)

function DirectionalMoveCell:Init(CellData, SkillObject)
    -- 通过Attack包触发
    SuperInit(self, CellData, SkillObject, false)
end

function DirectionalMoveCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end
    local CellData = self.CellData
    local CurAttackData = self.CurAttackData

    local OwnerEntityID = SkillObject.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)
    if not Me then
        return
    end

    local TargetVector
    local TargetEntityID = 0
    if CellData.IsServerPos then
        TargetVector = SkillActionUtil.ConvertServerVector(CurAttackData.SelectPos)
    else
        if #CurAttackData.EffectList == 0 then
            return
        end

        local CurAimActor = ActorUtil.GetActorByEntityID(CurAttackData.EffectList[1].Target)
        if not CurAimActor then
            return
        end
        TargetEntityID = CurAimActor:GetAttributeComponent().EntityID
        TargetVector = CurAimActor:FGetActorLocation()
    end

    SkillObject.DirectionalMovePos = Me:FGetActorLocation()

    local ArtPathParams = FArtPathParams()
    ArtPathParams.EntityID = OwnerEntityID
    ArtPathParams.PathID = SkillActionUtil.GetPathID(SkillObject)
    ArtPathParams.Duration = CellData.m_EndTime - CellData.m_StartTime
    ArtPathParams.CurveVectorPath = CellData.CurveEditorPanel
    ArtPathParams.CureScale = CellData.m_MoveSpeed
    ArtPathParams.ArtPathType = EArtPathType.EndPos
    ArtPathParams.TargetEntityID = Me:GetAttributeComponent().Target
    ArtPathParams.SkillID = SkillObject.CurrentSkillID

    if _G.SkillLogicMgr:IsSkillSystem(OwnerEntityID) then
        ArtPathParams.bNeedNotifyServer = false
    else
        if SkillObject.bJoyStick then
            ArtPathParams.ArtPathType = EArtPathType.EndPos
            ArtPathParams.EndPos = SkillObject.Position
        else
            if SkillObject.bIsDisplacementByMove then
                ArtPathParams.ArtPathType = EArtPathType.VelocityDirection
            end

            if SkillObject.bIsJoystickByMove then
                ArtPathParams.ArtPathType = EArtPathType.InputVelocityDirection
            end
        end
    end

    ArtPathParams.CollisionType = EArtPathCollisionType.CollisionTargetStop
    if CellData.IsCollisionStop then
        ArtPathParams.CollisionType = EArtPathCollisionType.CollisionAlwaysStop
    end

    if CellData.IsServerPos then
        ArtPathParams.ArtPathType = EArtPathType.EndPos
        ArtPathParams.CollisionType = EArtPathCollisionType.NoCollision
    elseif TargetEntityID ~= 0 then
        ArtPathParams.ConfigTargetID = TargetEntityID
    end

    ArtPathParams.EndPos = TargetVector
    ArtPathParams:LuaAddCallback(self, self.PlaySingCallBack)
    self.ArtPathParams = ArtPathParams

    UMoveSyncMgr:PlayArtPath(OwnerEntityID, ArtPathParams)
end

function DirectionalMoveCell:PlaySingCallBack()
    local SkillObject = self.SkillObject
    local CellData = self.CellData
    if not SkillObject or not CellData then
        return
    end

    _G.SkillSingEffectMgr:PlaySingEffect(SkillObject.OwnerEntityID, CellData.SingId)
end

function DirectionalMoveCell:OnAttackPresent(AttackData)
    self.CurAttackData = AttackData
    if AttackData.LeftCount == self.TotalDamageCount - self.CellData.m_DamageId then
        self:StartCell()
    end
end

function DirectionalMoveCell:StopArtPath()
    local ArtPathParams = self.ArtPathParams
    if ArtPathParams then
        ArtPathParams:LuaClearCallback()
    end
    self.ArtPathParams = nil

    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    if SkillObject.bStopSkillBreakArtPath then
        UMoveSyncMgr:StopArtPath(SkillObject.OwnerEntityID, SkillActionUtil.GetPathID(SkillObject), DefaultBlendOutTime)
    end
end

function DirectionalMoveCell:BreakSkill()
    SuperBreakSkill(self)
    self:StopArtPath()
end

function DirectionalMoveCell:ResetAction()
    self:StopArtPath()
    SuperResetAction(self)
end

return DirectionalMoveCell
