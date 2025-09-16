--
-- Author: henghaoli
-- Date: 2024-04-17 15:36:00
-- Description: 对应C++里面的USkillVfxCell
--

local LuaClass = require("Core/LuaClass")
local SkillCellBase = require("Game/Skill/SkillAction/SkillCell/SkillCellBase")
local SuperInit <const> = SkillCellBase.Init
local SuperBreakSkill <const> = SkillCellBase.BreakSkill
local SuperResetAction <const> = SkillCellBase.ResetAction
local ActorUtil = require("Utils/ActorUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local EffectUtil = require("Utils/EffectUtil")
local CommonUtil = require("Utils/CommonUtil")

local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local EventMgr = require("Event/EventMgr")
local AudioPlayerTypeMgr = require("Audio/AudioPlayerTypeMgr")
local EventID = require("Define/EventID")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local ProtoCS = require("Protocol/ProtoCS")
local BehitSplashCfg = require("TableCfg/BehitSplashCfg")
local BehitRadialBlurCfg = require("TableCfg/BehitRadialBlurCfg")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local MajorUtil = require("Utils/MajorUtil")

local CS_ATTACK_EFFECT = ProtoCS.CS_ATTACK_EFFECT

local UE = _G.UE
local FVector = UE.FVector
local FTransform = UE.FTransform
local FQuat = UE.FQuat
local FVfxParameter = UE.FVfxParameter
local ParticleSystemLODMethod = UE.ParticleSystemLODMethod
local FLOG_WARNING = _G.FLOG_WARNING

local FGameFXManager = _G.UE.UFGameFXManager.Get()
local SkillLogicMgr = _G.SkillLogicMgr

local AddCellTimer <const> = _G.UE.USkillMgr.AddCellTimer
local RemoveCellTimer <const> = _G.UE.USkillMgr.RemoveCellTimer

local UAudioMgr = UE.UAudioMgr.Get()
local FLinearColor = UE.FLinearColor
local USkillUtil = UE.USkillUtil
local SkillSystemMgr = _G.SkillSystemMgr
local ULuaDelegateMgr = _G.UE.ULuaDelegateMgr.Get()
local UnLuaRef = UnLua.Ref

local pb = require("pb")

---@class SkillVfxCell : SkillCellBase
---@field Super SkillCellBase
---@field EffectID number
---@field CurAttackData table
---@field BreakEffectTimerID number
---@field bIsSkillSystem bool
local SkillVfxCell = LuaClass(SkillCellBase, false)

function SkillVfxCell:Init(CellData, SkillObject)
    self.EffectID = 0
    self.BreakEffectTimerID = nil
    local bShouldStartCell = CellData.DamageIndex == 0
    self.bIsSkillSystem = SkillLogicMgr:IsSkillSystem(SkillObject.OwnerEntityID)
    SuperInit(self, CellData, SkillObject, bShouldStartCell)
end

--特效回调时技能或许已结束
--不支持延迟音效
--see DamageCell:DoAttackEffect
---@param SimpleSkillObject table   only{CurrentSubSkillID, OwnerEntityID}
local function DODamageAttackEffect(CellData, AttackData, SimpleSkillObject)
    local BinaryData = pb.encode("csproto.CombatAttackS", AttackData or {})
    USkillUtil.DoSvrAttackEffect(BinaryData, CellData.m_DelayFlyTime)

    local Cfg = SkillSubCfg:FindCfgByKey(SimpleSkillObject.CurrentSubSkillID)
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
        local bIsCanShow = SkillActionUtil.CanShow(CellData.IsMajorShowSplash, SimpleSkillObject.OwnerEntityID)
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
        local bIsCanShow = SkillActionUtil.CanShow(CellData.IsMajorShow, SimpleSkillObject.OwnerEntityID)
        
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
        
        local bPlaySoundOnce = CellData.bPlaySoundOnce or SkillSystemMgr.bIsActive
        local EffectList = AttackData.EffectList
        local LastEntityID = 0
        for _, EffectInfo in ipairs(EffectList) do
            local CurrentEntityID = EffectInfo.Target
            if CurrentEntityID ~= LastEntityID then
                local Target = ActorUtil.GetActorByEntityID(EffectInfo.Target)
                local Skip = SkillActionUtil.NeedSkipHitEffAndSound(EffectInfo.EffectType,CellData.bIsBulletVfx)
                if not Skip and Target then
                    UAudioMgr:AsyncLoadAndPostEvent(
                        CellData.m_Event, Target, AudioPlayerTypeMgr:GetOnHitSoundDelegatePair(EffectInfo.Giver))
                end
            end
            LastEntityID = CurrentEntityID
    
            if bPlaySoundOnce then
                break
            end
        end

    end
end

local EActorType_Monster  <const> = UE.EActorType.Monster
function SkillVfxCell:StartCell()
    local CellData = self.CellData
    local SkillObject = self.SkillObject

    if not CellData or not SkillObject then
        return
    end
    local CurrentSubSkillID = SkillObject.CurrentSubSkillID

    local OwnerEntityID = SkillObject.OwnerEntityID
    local Me = ActorUtil.GetActorByEntityID(OwnerEntityID)
    if not Me then
        FLOG_WARNING("[SkillVfxCell] Owner is nullptr.")
        return
    end

    if  CellData.bIsOnlyPlayInP1  and not SkillActionUtil.IsSimulateMajor(OwnerEntityID) then
        return
    end

    local LODLevel, bHighPriority = SkillActionUtil.GetLODLevel(OwnerEntityID)

    local ActorType = ActorUtil.GetActorType(OwnerEntityID)
    if ActorType == _G.UE.EActorType.Player and SettingsUtils.SettingsTabPicture:GetOtherPlayerEffectSwitch() == 0 then
        LODLevel = 2
        if _G.GMMgr.PlayerEffWhiteListSwitch ~= true or not EffectUtil.InVfxEffectBlockeList(CurrentSubSkillID) then
            return
        end
    end


    local VfxParameter = FVfxParameter()
    local VfxRequireData = VfxParameter.VfxRequireData
    VfxRequireData.EffectPath = CellData.m_VfxClass

    if SkillObject.bJoyStick or CellData.bUseSelectPoint then
        VfxRequireData.VfxTransform = FTransform(_G.UE.FRotator(0, SkillObject.Angle, 0):ToQuat(), SkillObject.Position)
    else
        VfxRequireData.VfxTransform = Me:FGetActorTransform()
    end

    VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_SkillVfxCell
    
    local bInInMonsterWhitelist = false
    local ResID = ActorUtil.GetActorResID(OwnerEntityID)
    bInInMonsterWhitelist = _G.ClientVisionMgr:GetIsInMonsterWhitelist(ResID) 

    if  _G.GMMgr.VisionEffWhiteListSwitch == false then
        bInInMonsterWhitelist = false
    end

    VfxRequireData.bAlwaysSpawn = bHighPriority or bInInMonsterWhitelist
    if ActorType == EActorType_Monster then
        local TopOwner = _G.ActorMgr:GetTopOwner(Me)
        if TopOwner == MajorUtil.GetMajor() then
            VfxRequireData.bAlwaysSpawn = true
        end
    end

    if not VfxRequireData.bAlwaysSpawn then
        local IsMajorRide = Me:GetActorType() == _G.UE.EActorType.Major and Me:GetRideComponent() ~= nil and Me:GetRideComponent():IsInRide() --主角坐骑技能特效强显
        VfxRequireData.bAlwaysSpawn =VfxRequireData.bAlwaysSpawn or IsMajorRide
    end
    
    VfxRequireData.FixedPositionType = CellData.FixedPositionType or 0
    VfxParameter.OffsetTransform = SkillActionUtil.ProtoTransform2FTransform(CellData.OffsetTransform)
	VfxParameter.LODMethod = ParticleSystemLODMethod.PARTICLESYSTEMLODMETHOD_ActivateAutomatic
	VfxParameter.LODLevel = LODLevel
    VfxParameter.PlaybackRate = 1 / SkillObject.PlayRate
    VfxParameter:SetCaster(Me, CellData.CasterOverwriteEID, CellData.CasterSlot, 0)

    local Skip = false
    local DamageCellData
    local AttackData = self.CurAttackData
 
    local OwnerEntityID = SkillObject.OwnerEntityID
    local TagrgetNum = 0
    if CellData.DamageIndex > 0 then
        local bServerPos = false
        local bShowMainTarget = false

        local DamageCell = SkillObject:GetDamageCell(CellData.DamageIndex)
        if DamageCell then
            DamageCellData = DamageCell.CellData
        end
        
        if DamageCellData then
            bServerPos = DamageCellData.IsServerPos
            bShowMainTarget = DamageCellData.bShowMainTarget
        end

        if bServerPos then
            local TargetVector = SkillActionUtil.ConvertServerVector(AttackData.SelectPos)
            VfxRequireData.VfxTransform = FTransform(FQuat(), TargetVector)
        end
        for Index, EffectInfo in ipairs(AttackData.EffectList) do
            if bShowMainTarget and Index > 1 then
                break
            end
            local Target = ActorUtil.GetActorByEntityID(EffectInfo.Target)
            Skip = SkillActionUtil.NeedSkipHitEffAndSound(EffectInfo.EffectType,CellData.bIsBulletVfx)
            if  not Skip and Target then
                TagrgetNum = TagrgetNum + 1
                VfxParameter:AddTarget(Target, CellData.TargetOverwriteEID, CellData.TargetSlot, 0)
            end
        end
        Skip = TagrgetNum <= 0
    end

	local Proxy = ULuaDelegateMgr:NewLevelLifeDelegateProxy()
	local Ref = UnLuaRef(Proxy)

    VfxParameter.VfxCommonEvent = {
        Proxy,
        function(_, bMajorOnly, Key)
            if (bMajorOnly and not ActorUtil.IsMajor(OwnerEntityID)) then
                return
            end
            if Key == 1 then
                DODamageAttackEffect(DamageCellData, AttackData, {CurrentSubSkillID = CurrentSubSkillID, OwnerEntityID = OwnerEntityID})
            end
            --[[
                VfxParameter的生命周期应当与回调函数相同
                否则, 极小概率出现VfxParameter被回收, 原Delegate地址的内存被其他Delegate复用, 但此时回调函数仍然存活,  产生崩溃
                这里显式地捕获它作为回调函数的上值, 保证VfxParameter的生命周期和回调函数的生命周期同步
            ]]
            VfxParameter = VfxParameter
        end
    }
    -- VfxCommonEvent不一定会执行到, 绑定End事件确保DelegateProxy的销毁
    VfxParameter.OnVfxEnd = {
        Proxy,
        function()
            Ref = nil
        end
    }

    if not Skip then
        local EffectID = EffectUtil.PlayVfx(VfxParameter)
        self.EffectID = EffectID
        SkillObject:RecordEffectID(EffectID)
        SkillObject:AddEffectID(EffectID)
    end
    local EndTime = (CellData.m_EndTime - CellData.m_StartTime) * SkillObject.PlayRate
    self.BreakEffectTimerID = AddCellTimer(self, "BreakEffect", EndTime)
end

function SkillVfxCell:OnAttackPresent(AttackData)
    local CellData = self.CellData
    if CellData.DamageIndex > 0 and AttackData.LeftCount == self.TotalDamageCount - CellData.DamageIndex then
        self.CurAttackData = AttackData
        self:StartCell()
    end
end

local NoBreak = 0
local BreakBlock = 1
local BreakAll = 2

function SkillVfxCell:BreakEffect()
    self:ResetTimer()

    local CellData = self.CellData
    if not CellData then
        self.EffectID = 0
        return
    end

    local BreakType = CellData.BreakType

    local EffectID = self.EffectID
    if BreakType == BreakBlock then
        FGameFXManager:StopVfx(EffectID, 0, 2)
    elseif BreakType == BreakAll then
        FGameFXManager:StopVfx(EffectID, 0, 0)
    end
    self.SkillObject:RemoveEffectID(EffectID)
    self.EffectID = 0
end

function SkillVfxCell:ResetAction()
    self:BreakSkill()
    SuperResetAction(self)
end

function SkillVfxCell:BreakSkill()
    SuperBreakSkill(self)

    self:ResetTimer()

    local SkillObject = self.SkillObject
    if not SkillObject then
        self.EffectID = 0
        return
    end

    if self.bIsSkillSystem then
        FGameFXManager:StopVfx(self.EffectID, 0, 0)
    else
        self:BreakEffect()
    end
    self.EffectID = 0
end

function SkillVfxCell:ResetTimer()
    local BreakEffectTimerID = self.BreakEffectTimerID
    if BreakEffectTimerID then
        RemoveCellTimer(BreakEffectTimerID)
        self.BreakEffectTimerID = nil
    end
end

return SkillVfxCell
