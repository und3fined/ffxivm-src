--
-- Author: henghaoli
-- Date: 2024-04-25 10:44:00
-- Description: 对应C++里面的UDamageWarningCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local TimeUtil = require("Utils/TimeUtil")
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local ProtoRes = require("Protocol/ProtoRes")
local EDamageRangType = ProtoRes.EDamageRangType
local RelationEnemyType = ProtoRes.camp_relation.camp_relation_enemy

local EventMgr = _G.EventMgr
local EventID = _G.EventID

local UE = _G.UE
local FVector = UE.FVector
local FRotator = UE.FRotator
local FSkillDecalInfo = UE.FSkillDecalInfo
local USkillDecalMgr = UE.USkillDecalMgr.Get()



---@class DamageWarningCell : SkillCellBase
---@field Super SkillCellBase
---@field StartUpTime number
---@field CurAttackData table
---@field WarningID number
local DamageWarningCell = LuaClass(SkillCellBase, false)

function DamageWarningCell:Init(CellData, SkillObject)
    local bCanStart = CellData.DamageIndexID == 0
    self.StartUpTime = TimeUtil.GetServerTimeMS()
    self.WarningID = 0
    SuperInit(self, CellData, SkillObject, bCanStart)
end

function DamageWarningCell:StartCell()
    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local OwnerEntityID = SkillObject.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)
    if not Me then
        return
    end
    local RangeInfo = FSkillDecalInfo()

    RangeInfo.LuaWarningPath = CellData.m_WarningActor
    RangeInfo.Location = Me:FGetActorLocation() - FVector(0, 0, Me:GetCapsuleHalfHeight())
    RangeInfo.Rotation = Me:FGetActorRotation() + FRotator(0, CellData.m_DamageDegOffset, 0)
    RangeInfo.EndTime = CellData.m_EndTime - CellData.m_StartTime
    RangeInfo.ZHighDiff = CellData.ZHighDiff
    RangeInfo.bScaleWithFloor = CellData.ZHighDiff <= 0
    RangeInfo.TexPath = CellData.m_Texture
    RangeInfo.Angle = 10
    RangeInfo.Range = 30
    -- 施法者半径 = 骨骼半径 * 缩放 
    -- 缩放 = 胶囊体缩放 * 缩放系数
    local Radius = 0
    local AvartarComp = Me:GetAvatarComponent()
    local CapsuleScale = Me:GetCapsuleScale()
    local ScaleFactor = Me:GetScaleFactor()
    if AvartarComp then
        Radius = AvartarComp:GetRadius() * 100 * CapsuleScale * ScaleFactor
    end

    local CasterRadius = CellData.CasterRadius and Radius or 0

    local DurationMic = self.StartUpTime + math.floor(CellData.m_EndTime * 1000) - TimeUtil.GetServerTimeMS()
    if DurationMic <= 0 then
        DurationMic = 1
    end
    local RealDuration = RangeInfo.EndTime
    local Duration = DurationMic / 1000
    if Duration > RealDuration then
        Duration = RealDuration
    end

    local DamageType = CellData.m_DamageType
    local DamageParams = CellData.m_DamageParams
    local CellDataLocation = SkillActionUtil.ProtoVector2FVector(CellData.m_DamagePointOffset)
    if DamageType == EDamageRangType.EDamageRangType_Sector then
        RangeInfo.Location = RangeInfo.Location + RangeInfo.Rotation:RotateVector(CellDataLocation)
        if DamageParams.Y >= 1 then
            RangeInfo.InsideRange = (DamageParams.Y + CasterRadius) / 100
        end
        RangeInfo.Range = (DamageParams.X + CasterRadius) / 100
        RangeInfo.Angle = DamageParams.Z
    elseif DamageType == EDamageRangType.EDamageRangType_Rectangle then
        RangeInfo.Angle = DamageParams.X / 100
        RangeInfo.Range = (DamageParams.Y + CasterRadius) / 100
        RangeInfo.Location = RangeInfo.Location + RangeInfo.Rotation:RotateVector(CellDataLocation - FVector(DamageParams.Y / 2, 0, 0))
    end

    RangeInfo.AnimTime = Duration
    RangeInfo.AnimCycle = CellData.AnimCycle or 1

    if CellData.DamageIndexID > 0 then
        RangeInfo.Location = SkillActionUtil.ConvertServerVector(self.CurAttackData.SelectPos)
    end

    if not SkillObject.bIsSingSkillObject then
        local Params = EventMgr:GetEventParams()
        Params.IntParam1 = SkillObject.CurrentSkillID
        Params.FloatParam1 = RangeInfo.EndTime
        Params.BoolParam1 = CellData.m_IsGuidedReading
        Params.BoolParam2 = CellData.m_IsAllowBreak
        Params.ULongParam1 = OwnerEntityID

        EventMgr:SendCppEvent(EventID.StartDamageWarningCell, Params)
        EventMgr:SendEvent(EventID.StartDamageWarningCell, Params)
    end

    local Relation = SelectTargetBase:GetCampRelationByEntityID(OwnerEntityID)
    if Relation ~= RelationEnemyType then
        RangeInfo.Col = SkillActionUtil.ProtoColor2FLinearColor(CellData.m_FriendColor)
        RangeInfo.ColorType = 1; 
    else
        RangeInfo.Col = SkillActionUtil.ProtoColor2FLinearColor(CellData.m_Color)
        RangeInfo.ColorType = 0; 
    end

    if CellData.bFollowMoveAndDirection then
        RangeInfo.bFollowMoveAndDirection = CellData.bFollowMoveAndDirection
        RangeInfo.AttachedComponent = Me:K2_GetRootComponent()
    end

    self.WarningID = USkillDecalMgr:PlaySkillDecal(RangeInfo, nil)
end

function DamageWarningCell:OnAttackPresent(AttackData)
    self.CurAttackData = AttackData
    local CellData = self.CellData
    if CellData.DamageIndexID > 0 and AttackData.LeftCount == self.TotalDamageCount - CellData.DamageIndexID then
        self:StartCell()
    end
end

function DamageWarningCell:EndDamageWarning()

    local Params = EventMgr:GetEventParams()
    Params.ULongParam1 = self.SkillObject.OwnerEntityID
    EventMgr:SendCppEvent(EventID.EndDamageWarning, Params)
    EventMgr:SendEvent(EventID.EndDamageWarning, Params)

    USkillDecalMgr:BreakSkillDecal(self.WarningID)
end

function DamageWarningCell:BreakSkill()
    SuperBreakSkill(self)
    self:EndDamageWarning()
end

function DamageWarningCell:ResetAction()
    self:EndDamageWarning()
    SuperResetAction(self)
end

return DamageWarningCell
