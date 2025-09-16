--
-- Author: henghaoli
-- Date: 2024-04-16 14:07:00
-- Description: 对应C++里面的UDamageCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local TimerMgr = require("Timer/TimerMgr")
local EventMgr = require("Event/EventMgr")
local AudioPlayerTypeMgr = require("Audio/AudioPlayerTypeMgr")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local EventID = require("Define/EventID")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local BehitSplashCfg = require("TableCfg/BehitSplashCfg")
local BehitRadialBlurCfg = require("TableCfg/BehitRadialBlurCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsID = require("Define/MsgTipsID")

local CS_ATTACK_EFFECT = ProtoCS.CS_ATTACK_EFFECT
local RelationEnemyType = ProtoRes.camp_relation.camp_relation_enemy

local UE = _G.UE
local FVector = UE.FVector
local UAudioMgr = UE.UAudioMgr.Get()
local FLinearColor = UE.FLinearColor
local USkillUtil = UE.USkillUtil
local SkillSystemMgr = _G.SkillSystemMgr
local RemoveCellTimer <const> = UE.USkillMgr.RemoveCellTimer

local LSTR = _G.LSTR

local pb = require("pb")



---@class DamageCell : SkillCellBase
---@field Super SkillCellBase
---@field DamageIndex number
---@field CurAttackData table 当前的AttackData
---@field DelayShowEfxTimerID number
---@field EndPlaybackTimerID number
---@field DelaySoundTimerID number
local DamageCell = LuaClass(SkillCellBase, false)

function DamageCell:Init(CellData, SkillObject)
    self.DelaySoundTimerID = nil
    self.DelayShowEfxTimerID = nil

    local bShouldStartCell = false
    if ActorUtil.IsMajor(SkillObject.OwnerEntityID) then
        bShouldStartCell = true
    end
    SuperInit(self, CellData, SkillObject, bShouldStartCell)

    SkillObject.CurrentDamageIndex = SkillObject.CurrentDamageIndex + 1
    self.DamageIndex = SkillObject.CurrentDamageIndex
    SkillObject:AddDamageCell(SkillObject.CurrentDamageIndex, self)
end

function DamageCell:StartCell()
    local SelectTargetMgr = _G.SelectTargetMgr

    local SkillObject = self.SkillObject
    if not SkillObject then
        return
    end

    local CellData = self.CellData
    local Me = ActorUtil.GetActorByEntityID(SkillObject.OwnerEntityID)
    if not Me then
        return
    end

    local SelectPos = Me:FGetActorLocation()
    local bHaveTargetBlocked = false
    local TargetEntityIDList

    if SkillObject.bJoyStick then
        SelectPos = SkillObject.Position
        TargetEntityIDList, bHaveTargetBlocked = SelectTargetMgr:SelectTargets(
            SkillObject.CurrentSkillID, SkillObject.CurrentSubSkillID, self.DamageIndex, Me, true, CellData.NeedChangeTarget,
            SkillObject.Position, SkillObject.Angle, nil, CellData.NeedReSelectTarget)
        if TargetEntityIDList then
            TargetEntityIDList = TargetEntityIDList:ToTable()
        end
    else
        TargetEntityIDList, bHaveTargetBlocked = SelectTargetMgr:SelectTargets(
            SkillObject.CurrentSkillID, SkillObject.CurrentSubSkillID, self.DamageIndex, Me, true, CellData.NeedChangeTarget,
            nil, nil, nil, CellData.NeedReSelectTarget)
        if TargetEntityIDList then
            TargetEntityIDList = TargetEntityIDList:ToTable()
        end

        if TargetEntityIDList and #TargetEntityIDList > 0 then
            local Monster = ActorUtil.GetActorByEntityID(TargetEntityIDList[1])
            SelectPos = Monster:FGetActorLocation()
        else
            if _G.GMMgr:IsShowDebugTips() then
                if bHaveTargetBlocked then
                    MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillCannotSeeTarget)-- 看不见目标
                else
                    MsgTipsUtil.ShowTips(LSTR(140068))  -- 技能伤害节点目标为空
                end
            end
        end
    end

    if self.DamageIndex == 1 then
        if TargetEntityIDList and #TargetEntityIDList > 0 then
            SkillObject.TargetID = TargetEntityIDList[1]
        end
    end

    if CellData.bUseFristDamageTarget then
        TargetEntityIDList = {}
        if SkillObject.TargetID > 0 then
            table.insert(TargetEntityIDList, SkillObject.TargetID)
        end
    end

    local ConvertedLocation = SkillActionUtil.ConvertClientVector(SelectPos)
    local DirPos = SelectPos - Me:FGetActorLocation()

    -- ComboType
    if SkillObject.CurrentCastSkillType == 1 then
        SkillActionUtil.SendAttack(
            SkillObject.OwnerEntityID, SkillObject.CurrentSkillID, TargetEntityIDList, 0, ConvertedLocation, DirPos,
            SkillObject.CurrentTableID, SkillObject.CurrentTableIndex)
    else
        SkillActionUtil.SendAttack(
            SkillObject.OwnerEntityID, SkillObject.CurrentSkillID, TargetEntityIDList, 0, ConvertedLocation, DirPos,
            0, 0, SkillObject.CurrentTableID, SkillObject.CurrentTableIndex)
    end

    RemoveCellTimer(self.DelayTimerID)
end

function DamageCell:OnAttackPresent(AttackData)
    local bIsLeftCountMatch = (AttackData.LeftCount == self.TotalDamageCount - self.DamageIndex)
    if not bIsLeftCountMatch then
        return
    end
    self.CurAttackData = AttackData
    local CellData = self.CellData
    local SkillObject = self.SkillObject
    local OwnerEntityID = SkillObject.OwnerEntityID
    local DamageIndex = self.DamageIndex

    local Cfg = SkillSubCfg:FindCfgByKey(SkillObject.CurrentSubSkillID)
    

    if bIsLeftCountMatch then
        if ActorUtil.IsMonster(OwnerEntityID) then
            if Cfg then
                local CombatComp = ActorUtil.GetActorCombatComponent(OwnerEntityID)
                CombatComp:SendMonsterTurnToTarget(Cfg.HitList[DamageIndex].PermitTurn, 0)
            end
        end

        local bIsMajorBeAttack = false
        for _, EffectInfo in ipairs(AttackData.EffectList) do
            if EffectInfo.EffectType == CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_DAMAGE then
                local EventParams = EventMgr:GetEventParams()

                local TargetEntityID = EffectInfo.Target
                EventParams.ULongParam1 = EffectInfo.Target
                EventParams.ULongParam2 = EffectInfo.Giver

                local SuperArmorConsume = CellData.SuperArmorConsume
                EventParams.IntParam1 = SuperArmorConsume

                -- 发送霸体指消耗值信息
                if SuperArmorConsume > 0 then
                    EventMgr:SendCppEvent(EventID.BehitSuperArmorConsume, EventParams)
                    EventMgr:SendEvent(EventID.BehitSuperArmorConsume, EventParams)
                end

                -- 主角受击
                local Target = ActorUtil.GetActorByEntityID(TargetEntityID)
                if Target and ActorUtil.IsMajor(TargetEntityID) then
                    bIsMajorBeAttack = true
                    EventMgr:SendCppEvent(EventID.MajorHit, EventParams)
                    EventMgr:SendEvent(EventID.MajorHit, EventParams)
                end
            end
        end

        if bIsMajorBeAttack then
            local CurSelectActor = _G.SelectTargetMgr:GetCurrSelectedTarget()
            local CurSelectEntityID = 0
            if CurSelectActor then
                CurSelectEntityID = CurSelectActor:GetAttributeComponent().EntityID
            end

            if CurSelectEntityID ~= AttackData.ObjID then
                local RelationType = SelectTargetBase:GetCampRelationByEntityID(OwnerEntityID)
                if RelationType == RelationEnemyType then
                    local EventParams = EventMgr:GetEventParams()
                    EventParams.ULongParam1 = AttackData.ObjID
                    EventMgr:SendCppEvent(EventID.MajorNeedSelectAttacker, EventParams)
                    EventMgr:SendEvent(EventID.MajorNeedSelectAttacker, EventParams)
                end
            end
        end
    end

    if not CellData.m_IsHandleAttackInfo and bIsLeftCountMatch then
        self:DoAttackEffect(AttackData, SkillObject)
    end
end

-- function DamageCell:StartPlaybackRate()
--     local SkillObject = self.SkillObject
--     local CellData = self.CellData
--     local AnimComp = ActorUtil.GetActorAnimationComponent(SkillObject.OwnerEntityID)
--     local PlaybackRate = CellData.m_PlaybackRate
--     AnimComp:SetPlayRate(PlaybackRate)

--     local EffectList = SkillObject.CurrentEffectIDList
--     local UFXMgr = UE.UFXMgr.Get()
--     for _, EffectID in pairs(EffectList) do
--         UFXMgr:SetPlaybackRate(EffectID, PlaybackRate)
--     end

--     self.EndPlaybackTimerID = TimerMgr:AddTimer(self, self.EndPlaybackRate, CellData.m_PlaybackRateTime, 0, 1, nil, "DamageCell:EndPlaybackRate")
-- end

-- function DamageCell:EndPlaybackRate()
--     local SkillObject = self.SkillObject
--     if not SkillObject then
--         return
--     end

--     local AnimComp = ActorUtil.GetActorAnimationComponent(SkillObject.OwnerEntityID)
--     local PlaybackRate = 1 / SkillObject.PlayRate

--     local EffectList = SkillObject.CurrentEffectIDList
--     local UFXMgr = UE.UFXMgr.Get()
--     for _, EffectID in pairs(EffectList) do
--         UFXMgr:SetPlaybackRate(EffectID, PlaybackRate)
--     end

--     AnimComp:SetPlayRate(PlaybackRate)
-- end

local function ShowBehitSoundInternal(Params)
    if not Params then
        return
    end

    local SoundPath, EffectList, bPlaySoundOnce, bIsBulletVfx = table.unpack(Params)
    local LastEntityID = 0
    for _, EffectInfo in ipairs(EffectList) do
        local CurrentEntityID = EffectInfo.Target
        if CurrentEntityID ~= LastEntityID then
            local Target = ActorUtil.GetActorByEntityID(EffectInfo.Target)
            local Skip = SkillActionUtil.NeedSkipHitEffAndSound(EffectInfo.EffectType, bIsBulletVfx)
            if not Skip and Target then
                UAudioMgr:AsyncLoadAndPostEvent(
                    SoundPath, Target, AudioPlayerTypeMgr:GetOnHitSoundDelegatePair(EffectInfo.Giver))
            end
        end
        LastEntityID = CurrentEntityID

        if bPlaySoundOnce then
            break
        end
    end
end

local function GetBehitSoundParams(CellData, AttackData)
    if not CellData or not AttackData then
        return
    end

    local bPlaySoundOnce = CellData.bPlaySoundOnce or SkillSystemMgr.bIsActive
    return { CellData.m_Event, AttackData.EffectList, bPlaySoundOnce, CellData.bIsBulletVfx }
end

function DamageCell:ShowBehitSound(AttackData)
    ShowBehitSoundInternal(GetBehitSoundParams(self.CellData, AttackData))
end
--修改该接口时应一并修改SkillVfxCell_DODamageAttackEffect
function DamageCell:DoAttackEffect(AttackData, SkillObject)
    local BinaryData = pb.encode("csproto.CombatAttackS", AttackData or {})
    local CellData = self.CellData
    USkillUtil.DoSvrAttackEffect(BinaryData, CellData.m_DelayFlyTime)

    local Cfg = SkillSubCfg:FindCfgByKey(SkillObject.CurrentSubSkillID)
    for _, EffectInfo in ipairs(AttackData.EffectList) do
        if EffectInfo.EffectType == CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_DAMAGE then
            local EventParams = EventMgr:GetEventParams()

            EventParams.ULongParam1 = EffectInfo.Target
            EventParams.ULongParam2 = EffectInfo.Giver

            --怪物受击
            local TargetEntityID = EffectInfo.Target
            local Target = ActorUtil.GetActorByEntityID(TargetEntityID)
            local Skip = SkillActionUtil.NeedSkipHitEffAndSound(EffectInfo.EffectType,CellData.bIsBulletVfx)
            if  not Skip and Target and ActorUtil.IsMonster(TargetEntityID) then
                if Cfg then
                    EventParams.IntParam2 = Cfg.SkillPower
                end
                EventParams.FloatParam1 = CellData.m_DamagePower

                EventMgr:SendCppEvent(EventID.MonsterHitPlay, EventParams)
                EventMgr:SendEvent(EventID.MonsterHitPlay, EventParams)
            end
        end
    end

    if CellData.SplashIndex > 0 then
        local bIsCanShow = self:CanShow(CellData, SkillObject,true)
        if bIsCanShow then
            local SplashCfg = BehitSplashCfg:FindCfgByKey(CellData.SplashIndex)
            if SplashCfg then
                for _, EffectInfo in ipairs(AttackData.EffectList) do
                    local AvatarComp = ActorUtil.GetActorAvatarComponent(EffectInfo.Target)
                    local Skip = SkillActionUtil.NeedSkipHitEffAndSound(EffectInfo.EffectType,CellData.bIsBulletVfx)
                    if not Skip and AvatarComp then
                        local Color = FLinearColor(SplashCfg.ColorR, SplashCfg.ColorG, SplashCfg.ColorB, SplashCfg.ColorA)
                        AvatarComp:SplashTakeDamage(
                            SplashCfg.Type, SplashCfg.LastTime, SplashCfg.Strength, SplashCfg.Range, Color, 0)
                    end
                end
            end
        end
    end

    if CellData.RadialBlurIndex > 0 then
        local bIsCanShow = self:CanShow(CellData, SkillObject)

        if bIsCanShow then
            local BlurCfg = BehitRadialBlurCfg:FindCfgByKey(CellData.RadialBlurIndex)
            if BlurCfg then
                local UCameraPostEffectMgr = UE.UCameraPostEffectMgr.Get()
                local SocketName = BlurCfg.SocketName
                local RelativeLocation = FVector(BlurCfg.PointOffsetX, BlurCfg.PointOffsetY, BlurCfg.PointOffsetZ)
                for _, EffectInfo in ipairs(AttackData.EffectList) do
                    local Target = ActorUtil.GetActorByEntityID(EffectInfo.Target)
                    local Skip = SkillActionUtil.NeedSkipHitEffAndSound(EffectInfo.EffectType,CellData.bIsBulletVfx)
                    if not Skip and Target then
                        UCameraPostEffectMgr:StartRadialBlur(
                            SocketName, BlurCfg.BlurDst, BlurCfg.BlurRadius, BlurCfg.BlurStrength,
                            BlurCfg.Time, Target, RelativeLocation, math.floor(BlurCfg.RadialBlurWeight), BlurCfg.RadialBlurType, 
                            BlurCfg.BlurDstPower, BlurCfg.BlurRadiusPower
                        )
                    end
                end
            end
        end
    end

    if #CellData.m_Event > 0 and CellData.m_Event ~= "None" then
        if CellData.m_SoundDelayTime > 0 then
            self.DelaySoundTimerID =
                TimerMgr:AddTimer(
                    nil,
                    ShowBehitSoundInternal,
                    CellData.m_SoundDelayTime,
                    0, 1,
                    GetBehitSoundParams(CellData, AttackData),
                    "DamageCell:ShowBehitSound")
        else
            self:ShowBehitSound(AttackData)
        end
    end
end

function DamageCell:BreakSkill()
    SuperBreakSkill(self)
    -- TimerMgr:CancelTimer(self.DelaySoundTimerID)
    TimerMgr:CancelTimer(self.DelayShowEfxTimerID)
end

function DamageCell:ResetAction()
    -- local TimerID = self.EndPlaybackTimerID or 0
    -- if TimerMgr.Timers[TimerID] then
    --     TimerMgr:CancelTimer(TimerID)
    --     self:EndPlaybackRate()
    -- end

    -- TimerMgr:CancelTimer(self.DelaySoundTimerID)
    TimerMgr:CancelTimer(self.DelayShowEfxTimerID)
    SuperResetAction(self)
end

return DamageCell
