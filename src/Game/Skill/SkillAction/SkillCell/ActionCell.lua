--
-- Author: henghaoli
-- Date: 2024-04-15 10:43:00
-- Description: 对应C++里面的UActionCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local SkillLogicMgr = require("Game/Skill/SkillLogicMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillRaceReplaceAnimCfg = require("TableCfg/SkillRaceReplaceAnimCfg")

local role_gender = ProtoCommon.role_gender
local race_type = ProtoCommon.race_type

local UE = _G.UE
local EAvatarPartType = UE.EAvatarPartType
local EArtPathType = UE.EArtPathType
local EArtPathCollisionType = UE.EArtPathCollisionType
local FArtPathParams = UE.FArtPathParams
local FWeakObjectPtr = UE.FWeakObjectPtr
-- 注意require的时序
local UMoveSyncMgr = UE.UMoveSyncMgr.Get()
local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = UE.USkillMgr.RemoveCellTimer

-- StopArtPath默认淡出时间
local DefaultBlendOutTime = 0.3

---@class ActionCell : SkillCellBase
---@field Super SkillCellBase
---@field ActionName string
---@field EndAnimTimerID number
---@field WeakMontage UE.FWeakObjectPtr
local ActionCell = LuaClass(SkillCellBase, false)

function ActionCell:Init(CellData, SkillObject)
    local bNotStartCell = CellData.DamageIndex and CellData.DamageIndex > 0
    SuperInit(self, CellData, SkillObject, not bNotStartCell)

    self.ActionName = CellData.m_AnimationAsset
    self.EndAnimTimerID = 0
    self.WeakMontage = nil

    if CellData.RaceReplaceAnimID > 0 then
        self:ChangeAnimByRaceReplace()
    end

    if CellData.bGetMontagesByBone then
        local TargetAnim = ActorUtil.GetActorAnimationComponent(
            SkillObject.OwnerEntityID):SelectTimelineByAttachType(CellData.ReplaceKeyID)
        if TargetAnim and #TargetAnim > 0 then
            self.ActionName = TargetAnim
        end
    end
end

function ActionCell:StartCell(TargetEntityID)
    local CellData = self.CellData
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local OwnerEntityID = SkillObject.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)
    if not Me then
        return
    end

    local ActionName = self.ActionName

    if CellData.MoveCantPlayAnim and Me:GetMovementComponent().Velocity:Size2D() > 0 then
        return
    end

    local AreaType = EAvatarPartType.MASTER
    if CellData.m_AreaType ~= 0 then
        AreaType = EAvatarPartType.RIDE_MASTER
    end

    if TargetEntityID then
        local AttrComp = Me:GetAttributeComponent()
        if AttrComp then
            AttrComp.Target = TargetEntityID
        end
    end
    local Blend = CellData.m_DynamicMontageBlend
    local Montage = Me:GetAnimationComponent():PlayAnimation(
        ActionName, 1 / SkillObject.PlayRate,
        Blend.m_BlendIn, Blend.m_BlendOut, not CellData.bDontStopAllMontages, AreaType, CellData.bUseTableData)
    if Montage then
        self.WeakMontage = FWeakObjectPtr(Montage)
    end

    RemoveCellTimer(self.DelayTimerID)

    local CurveInfo = CellData.CurveEditorPanel
    if CurveInfo ~= "None" and not SkillObject.bIsSingSkillObject then
        local AttributeComp = Me:GetAttributeComponent()
        local ArtPathParams = FArtPathParams()
        ArtPathParams.EntityID = OwnerEntityID
        ArtPathParams.PathID = SkillActionUtil.GetPathID(SkillObject)
        ArtPathParams.Duration = CellData.m_EndTime - CellData.m_StartTime
        ArtPathParams.CurveVectorPath = CurveInfo
        ArtPathParams.CureScale = CellData.CurveCoefficient
        ArtPathParams.TimeScale = CellData.CurveTimeCoefficient * (1 / SkillObject.PlayRate)
        ArtPathParams.UnfreezeTime = CellData.CurveLastTime
        if AttributeComp then
            ArtPathParams.TargetEntityID = AttributeComp.Target
        end
        ArtPathParams.AnimMontagePath = ActionName
        ArtPathParams.bCollisionStopAnim = CellData.IsCollisionStopAnim
        ArtPathParams.SkillID = SkillObject.CurrentSkillID

        if SkillLogicMgr:IsSkillSystem(OwnerEntityID) then
            ArtPathParams.bNeedNotifyServer = false
            ArtPathParams.ArtPathType = EArtPathType.Direction
        else
            if SkillObject.bJoyStick then
                if SkillObject.bEnableJoyStickPoint then
                    ArtPathParams.ArtPathType = EArtPathType.EndPos
                    ArtPathParams.EndPos = SkillObject.Position
                else
                    ArtPathParams.ArtPathType = EArtPathType.JoyStickDirection
                    ArtPathParams.JoyDirection = _G.UE.FRotator(0, SkillObject.Angle, 0)
                end
            else
                if SkillObject.bIsDisplacementByMove then
                    ArtPathParams.ArtPathType = EArtPathType.VelocityDirection
                end

                if SkillObject.bIsJoystickByMove then
                    ArtPathParams.ArtPathType = EArtPathType.InputVelocityDirection
                end
            end
        end
        ArtPathParams.CollisionType = EArtPathCollisionType.NoCollision
        if CellData.IsCollisionStop then
            ArtPathParams.CollisionType = EArtPathCollisionType.CollisionAlwaysStop
        end

        if not SkillObject.bIgnoreArt then
            UMoveSyncMgr:PlayArtPath(OwnerEntityID, ArtPathParams)
        end
    end

    local Delay = (CellData.m_EndTime - CellData.m_StartTime) * SkillObject.PlayRate
    self.EndAnimTimerID = AddCellTimer(self, "EndAnim", Delay)
end

function ActionCell:EndAnim()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end
    local AnimComp = ActorUtil.GetActorAnimationComponent(SkillObject.OwnerEntityID)
    if not AnimComp then
        return
    end

    local WeakMontage = self.WeakMontage
    if WeakMontage then
        if not WeakMontage:IsValid() then
            return
        end
        AnimComp:StopMontage(WeakMontage:Get())
        WeakMontage:Set(nil)
    else
        AnimComp:StopAnimation(self.ActionName)
    end
end

function ActionCell:OnAttackPresent(AttackData)
    local CellData = self.CellData
    local DamageIndex = CellData.DamageIndex or 0
    if DamageIndex > 0 and AttackData.LeftCount == self.TotalDamageCount - DamageIndex then
        if #AttackData.EffectList > 0 then
            local TargetEntityID = AttackData.EffectList[1].Target
            if TargetEntityID and TargetEntityID > 0 then
                self:StartCell(TargetEntityID)
            end
        end
    end
end

function ActionCell:BreakSkill()
    SuperBreakSkill(self)
    self:EndAnim()
    RemoveCellTimer(self.EndAnimTimerID)

    local SkillObject = self.SkillObject
    if SkillObject.bStopSkillBreakArtPath then
        UMoveSyncMgr:StopArtPath(SkillObject.OwnerEntityID, SkillActionUtil.GetPathID(SkillObject), DefaultBlendOutTime)
    end
end

function ActionCell:StopCell()
    if self.CellData.MoveStopAnim then
        self:EndAnim()
        RemoveCellTimer(self.EndAnimTimerID)
        RemoveCellTimer(self.DelayTimerID)
    end
end

function ActionCell:ChangeAnimByRaceReplace()
    local RaceReplaceAnimID = self.CellData.RaceReplaceAnimID
    if RaceReplaceAnimID == 0 then
        return
    end
    local TargetAnimPath = self.ActionName
    local Cfg = SkillRaceReplaceAnimCfg:FindCfgByKey(RaceReplaceAnimID)
    if not Cfg then
        return
    end

    local AttrComp = ActorUtil.GetActorAttributeComponent(self.SkillObject.OwnerEntityID)
    local RaceID = AttrComp.RaceID
    if AttrComp.Gender == role_gender.GENDER_MALE then
        if RaceID == race_type.RACE_TYPE_Lalafell then
            TargetAnimPath = Cfg.LalafellM
        elseif RaceID == race_type.RACE_TYPE_Roegadyn then
            TargetAnimPath = Cfg.RoegadynM
        end
    else
        if RaceID == race_type.RACE_TYPE_Lalafell then
            TargetAnimPath = Cfg.LalafellW
        elseif RaceID == race_type.RACE_TYPE_Roegadyn then
            TargetAnimPath = Cfg.RoegadynW
        end
    end

    if TargetAnimPath and #TargetAnimPath > 0 then
        self.ActionName = TargetAnimPath
    end
end

function ActionCell:ResetAction()
    self:EndAnim()
    RemoveCellTimer(self.EndAnimTimerID)

    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    if SkillObject.bStopSkillBreakArtPath then
        UMoveSyncMgr:StopArtPath(SkillObject.OwnerEntityID, SkillActionUtil.GetPathID(SkillObject), DefaultBlendOutTime)
    end

    SuperResetAction(self)
end

return ActionCell
