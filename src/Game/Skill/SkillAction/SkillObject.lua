--
-- Author: henghaoli
-- Date: 2024-04-08 16:29:00
-- Description: 对应C++里面的SkillBase技能母体的概念
--

local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local TimeUtil = require("Utils/TimeUtil")
local EffectUtil = require("Utils/EffectUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillUtil = require("Utils/SkillUtil")
local SkillLogicMgr = require("Game/Skill/SkillLogicMgr")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SkillActionDefine = require("Game/Skill/SkillAction/SkillActionDefine")
local ProtoCommon = require("Protocol/ProtoCommon")

local SkillObjectMgr

local UE = _G.UE
local FVector = UE.FVector
-- local EActorType = UE.EActorType
local EActorState = UE.EActorState
-- local EActorControllStat = UE.EActorControllStat
local FLOG_ERROR = _G.FLOG_ERROR

local ESkillActionType = ProtoRes.ESkillActionType
local SkillBreakType = SkillActionDefine.SkillBreakType

local SingToleranceTime = 0.5
local DefaultEndTime = 5

local XPCall = CommonUtil.XPCall
local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = _G.UE.USkillMgr.RemoveCellTimer

local ResetSkillWeight <const> = -1

---@class SkillObject
local SkillObject = LuaClass()

function SkillObject:Ctor()
    self:ResetParams()
end

function SkillObject:SetSkillObjectMgr(InSkillObjectMgr)
    SkillObjectMgr = InSkillObjectMgr
end

function SkillObject:ResetParams()
    self.PlayRate = 0
    self.ID = 0                 -- 技能ID
    self.bIsSpellSkill = false  -- 是否吟唱技能
    self.SpellLoopTime = 0      -- 吟唱持续时间
    self.SpellEndTime = 0       -- 吟唱结束时间
    self.Actions = {}
    self.DamageCellMap = {}
    self.CurrentDamageIndex = 0
    self.OwnerEntityID = nil

    self.CurrentSkillID = 0
    self.CurrentSubSkillID = 0
    self.SkillWeight = ResetSkillWeight
    self.TargetIndex = 0
    self.CurrentTableID = 0
    self.CurrentTableIndex = 0
    self.CurrentCastSkillType = 0  -- ESkillCastType
    self.CurrentStartTime = 0

    self.bIsDisplacementByMove = false
    self.bIsJoystickByMove = false
    self.bStopSkillBreakArtPath = false
    self.bIgnoreArt = false

    self.CurrentEffectIDList = {}
    self.AllEffectIDList = {}

    self.bJoyStick = false
    self.bEnableJoyStickPoint = false

    self.Position = FVector()
    self.DirectionalMovePos = nil
    self.TargetID = 0
    self.Angle = 0

    self.bIsEndState = false
    self.bHasServerCheck = false  -- 是否通过服务器校验. 收到服务器校验后, 才能去执行后续Attack包的逻辑
    self.bIsCanBreak = false
    self.SingTime = 0

    self.DelayTimerID = 0
    self.ChangeCanBreakDelayTimerID = 0
    self.ChangeCantBreakDelayTimerID = 0
    self.SkillWeightDegradeTimerID = 0
end

function SkillObject:Init(SkillID, SubSkillID, bIgnoreArt, Owner, TableID, TableIndex, CastSkillType, SkillRate, bInJoyStick, InPosition, InAngle, bHasServerCheck)
    self:ResetParams()
    local ShortActionTime = 0
    if Owner and Owner.AttributeCom then
        self.OwnerEntityID = Owner.AttributeCom.EntityID
        ShortActionTime = Owner.AttributeCom:GetAttrValue(ProtoCommon.attr_type.attr_shorten_action_time) / 10000
    end
    self.CurrentSkillID = SkillID
    self.CurrentSubSkillID = SubSkillID
    self.CurrentTableIndex = TableIndex
    self.CurrentTableID = TableID
    self.CurrentCastSkillType = CastSkillType
    self.PlayRate = SkillRate

    self.bJoyStick = bInJoyStick
    self.bIgnoreArt = bIgnoreArt
    self.Position = FVector(InPosition.X, InPosition.Y, InPosition.Z)
    self.Angle = InAngle
    self.bHasServerCheck = bHasServerCheck
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if not Cfg then
        return false
    end
    self.bEnableJoyStickPoint = Cfg.IsEnableJoyStickPoint > 0
    if not self:CastSkill() then
        return false
    end
    local SingTime = SkillUtil.GetSimulateSingTime(SkillID, SubSkillID, Cfg) / 1000 * (1 - ShortActionTime)

    if SingTime > 0 then
        self.SingTime = SingTime
        self.bIsCanBreak = true
        local Delay = math.max(SingTime - SingToleranceTime, 0)
        self.ChangeCantBreakDelayTimerID = AddCellTimer(self, "SetCanBreakFalse", Delay)
    end
    return true
end

function SkillObject:SetCanBreakFalse()
    self.bIsCanBreak = false
end

function SkillObject:SetSkillWeight(SkillWeight)
    self.SkillWeight = SkillWeight

    local EntityID = self.OwnerEntityID
    if not ActorUtil.IsMajor(EntityID) then
        return
    end
    _G.EventMgr:SendEvent(_G.EventID.MajorChangeSkillWeight, {SkillID = self.CurrentSkillID, SubSkillID = self.CurrentSubSkillID, SkillWeight = SkillWeight})
end

function SkillObject:CastSkill()
    self.CurrentStartTime = TimeUtil.GetLocalTimeMS()
    local CurrentSubSkillID = self.CurrentSubSkillID or 0
    local Cfg = SkillSubCfg:FindCfgByKey(CurrentSubSkillID)
    if not Cfg then
        FLOG_ERROR("[SkillObject:CastSkill] c_skill_sub_cfg is nullptr: SubSkillID = %d", CurrentSubSkillID)
        return false
    end

    self.bIsDisplacementByMove = Cfg.IsDisplacementByMove > 0
    self.bIsJoystickByMove = Cfg.bIsJoystickByMove > 0
    self.bStopSkillBreakArtPath = Cfg.bStopSkillBreakArtPath > 0

    self.Actions = _G.SkillActionMgr:GetActionList(self.CurrentSubSkillID)
    local HitCount = Cfg.HitCount
    local Actions = self.Actions

    do
        local _ <close> = CommonUtil.MakeProfileTag("SkillObject:ActionInit")
        for _, Action in ipairs(Actions) do
            local CellData = Action.CellData
            Action.TotalDamageCount = HitCount
            -- 避免某个Cell Init过程中出现Error影响其他Cell
            -- XPCall(Action, Action.Init, CellData, self)
            Action:Init(CellData, self)
        end
    end

    -- local BlendValue = Cfg.BlendValue
    -- local OwnerEntityID = self.OwnerEntityID
    -- local AttrComp = ActorUtil.GetActorAttributeComponent(OwnerEntityID)
    -- if BlendValue > 0 and AttrComp and AttrComp.ObjType == EActorType.Monster then
    --     ActorUtil.GetActorAnimationComponent(OwnerEntityID).DynamicBlend = BlendValue
    -- end

    local PlayRate = self.PlayRate

    local EndTime = Cfg.EndTime
    if EndTime > 0 then
        EndTime = EndTime / 1000
    else
        EndTime = DefaultEndTime
    end
    self.DelayTimerID = AddCellTimer(self, "SkillEnd", EndTime * PlayRate)

    local MoveBreakTime = Cfg.MoveBreakTime
    if MoveBreakTime > 0 then
        self.ChangeCanBreakDelayTimerID = AddCellTimer(self, "ChangeSkillCanBeMoveBreak", MoveBreakTime / 1000 * PlayRate)
    end

    local DegradeTime = Cfg.DegradeTime
    if DegradeTime > 0 then
        self.SkillWeightDegradeTimerID = AddCellTimer(self, "SkillWeightDegrade", DegradeTime / 1000 * PlayRate)
    end
    local SkillWeight = SkillMainCfg:FindValue(self.CurrentSkillID, "SkillWeight")
    self:SetSkillWeight(SkillWeight)
    
    return true
end

function SkillObject:ResetSkill(BreakType)
    local Actions = self.Actions
    local SkillActionMgr = _G.SkillActionMgr
    local FreeCellObject = SkillActionMgr.FreeCellObject

    local SkillBreakType_SkillEnd = SkillBreakType.SkillEnd
    for Index, Action in pairs(Actions) do
        local Type = Action.CellData.Type
        -- XPCall(Action, Action.ResetAction)
        if BreakType == SkillBreakType_SkillEnd then
            Action:ResetAction()
        else
            Action:BreakSkill()
        end
        FreeCellObject(SkillActionMgr, Type, Action)
        Actions[Index] = nil
    end

    self.DamageCellMap = nil

    if SkillLogicMgr:IsSkillSystem(self.OwnerEntityID) then
        local AllEffectIDList = self.AllEffectIDList
        for _, ID in pairs(AllEffectIDList) do
            EffectUtil.StopVfx(ID, 0, 0)
        end
    end
end

function SkillObject:StopSkillCell(ActionType)
    local Actions = self.Actions
    for _, Action in pairs(Actions) do
        if Action.CellData.Type == ActionType then
            XPCall(Action, Action.StopCell)
        end
    end
end

function SkillObject:SkillEnd()
    local StateComp = ActorUtil.GetActorStateComponent(self.OwnerEntityID)
    if StateComp then
        StateComp:SwitchState(EActorState.Idle)
    end

    self:BreakSkill(SkillBreakType.SkillEnd)
end

function SkillObject:ChangeSkillCanBeMoveBreak()
    self.bIsCanBreak = true
    local OwnerEntityID = self.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)
    if not Me then
        return
    end

    if ActorUtil.IsMajor(OwnerEntityID) and (Me:MoveOnlyByVirtualJoystick() or Me:IsPathWalking()) then
        self:StopSkillCell(ESkillActionType.ESkillActionType_SkillPlayAnimationAction)
        local EntityID = self.OwnerEntityID
        SkillObjectMgr:SendQuitSkill(EntityID)
    end
end

function SkillObject:OnAttackPresent(AttackData)
    local Actions = self.Actions
    for _, Action in pairs(Actions) do
        XPCall(Action, Action.OnAttackPresent, AttackData)
    end
end

function SkillObject:OnActionPresent(ActionData)
    local Actions = self.Actions
    for _, Action in pairs(Actions) do
        XPCall(Action, Action.OnActionPresent, ActionData)
    end
end

function SkillObject:BreakSkill(BreakType)
    BreakType = BreakType or SkillBreakType.Break
    local CombatComp = ActorUtil.GetActorCombatComponent(self.OwnerEntityID)
    if CombatComp then
        local CurrentSkillID = self.CurrentSkillID
        local CurrentSubSkillID = self.CurrentSubSkillID
        CombatComp:SendSkillEndEvent(CurrentSubSkillID, CurrentSkillID)
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("ResetSkill")
        self:ResetSkill(BreakType)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("ResetSkillControl")
        self:ResetSkillControl()
    end
    self.bIsEndState = true

    RemoveCellTimer(self.DelayTimerID)
    RemoveCellTimer(self.ChangeCanBreakDelayTimerID)
    RemoveCellTimer(self.ChangeCantBreakDelayTimerID)
    RemoveCellTimer(self.SkillWeightDegradeTimerID)

    SkillObjectMgr:UnRegisterSkillObject(self.OwnerEntityID, self)
end

local CppResetSkillControl <const> = _G.UE.USkillUtil.ResetSkillControl

function SkillObject:ResetSkillControl()
    -- local OwnerEntityID = self.OwnerEntityID
    -- local StateComp = ActorUtil.GetActorStateComponent(OwnerEntityID)
    -- if StateComp then
    --     StateComp:SetActorControlState(EActorControllStat.CanMove, true, "")
    --     StateComp:SetActorControlState(EActorControllStat.CanTurn, true, "")
    -- end

    -- local AvatarComp = ActorUtil.GetActorAvatarComponent(OwnerEntityID)
    -- if AvatarComp then
    --     AvatarComp:SplashSkillReset()
    -- end

    -- local Actor = ActorUtil.GetActorByEntityID(OwnerEntityID)
    -- if Actor then
    --     Actor:StartFadeIn(-1, true)
    --     Actor:IsSyncRotatorInFaceTarget(false)
    -- end

    -- if ActorUtil.IsMonster(OwnerEntityID) then
    --     ActorUtil.GetActorAnimationComponent(OwnerEntityID).DynamicBlend = 0
    -- end

    -- self:SetSkillWeight(-1)

    if self.SkillWeight ~= ResetSkillWeight then
        self:SetSkillWeight(ResetSkillWeight)
    end

    -- 这部分逻辑涉及大量获取Comp的操作, 放到C++比较省时间
    CppResetSkillControl(self.OwnerEntityID, self.CurrentSkillID, self.CurrentSubSkillID, ResetSkillWeight)
end

function SkillObject:AddEffectID(EffectID)
    local CurrentEffectIDList = self.CurrentEffectIDList
    if table.find_item(CurrentEffectIDList, EffectID) == nil then
        table.insert(CurrentEffectIDList, EffectID)
    end
end

function SkillObject:RemoveEffectID(EffectID)
    table.remove_item(self.CurrentEffectIDList, EffectID)
end

function SkillObject:RecordEffectID(EffectID)
    local AllEffectIDList = self.AllEffectIDList
    if table.find_item(AllEffectIDList, EffectID) == nil then
        table.insert(AllEffectIDList, EffectID)
    end
end

function SkillObject:AddDamageCell(Index, DamageCell)
    if self.DamageCellMap then
        self.DamageCellMap[Index] = DamageCell
    end
end

function SkillObject:GetDamageCell(Index)
    if self.DamageCellMap then
        return self.DamageCellMap[Index]
    end
end

function SkillObject:SkillWeightDegrade()
    self:SetSkillWeight(ResetSkillWeight)
end

return SkillObject
