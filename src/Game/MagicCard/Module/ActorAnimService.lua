
--
-- Author: frankjfwang
-- Date: 2022-07-21 16:57:14
-- Description:
--
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local Log = require("Game/MagicCard/Module/Log")
local NpcAnimCfg = require("TableCfg/FantasyCardNpcAnimCfg")
local NpcCfg = require("TableCfg/FantasyCardNpcCfg")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local EmotionCfg = require("TableCfg/EmotionCfg")
local AnimationUtil = require("Utils/AnimationUtil")
local FantasyCardMotionClassifyCfg = require("TableCfg/FantasyCardMotionClassifyCfg")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local NpcAnimEnum = ProtoRes.fantasy_card_npc_anim_enum
local MajorAnimEnum = ProtoRes.fantasy_card_major_anim_enum
local MajorAnimComponent ---@type UAnimationComponent
-- local NpcAnimComponent ---@type UAnimationComponent -- 不要缓存，要用的时候去获取一下，有可能角色被释放了，导致组件使用报错
local MajorPlayCardAnimTime = 1

---@class ActorAnimService
local ActorAnimService = {}

function ActorAnimService:Reset()
    MajorAnimComponent = MajorUtil.GetMajorAnimationComponent()
    Log.Check(MajorAnimComponent, "ActorAnimService no major anim component")

    self:SetAnimEmoIDList()

    -- 预读一些配置
    self.LeadingAnimCond = self.GetNpcAnimCond(NpcAnimEnum.Emo_Leading_Once)
    self.BehindAnimCond = self.GetNpcAnimCond(NpcAnimEnum.Emo_Behind_Once)
    self.MajorPlayCardAnimTime = MajorPlayCardAnimTime
end

function ActorAnimService:GetNpcNpcAnimComponent()
    local TempAnimComponent = nil
    local EntityID = _G.MagicCardMgr:GetOpponentEntityID()
    if(EntityID ~= nil and EntityID > 0) then
        local NpcActor = ActorUtil.GetActorByEntityID(EntityID)
        if (NpcActor ~= nil) then
            TempAnimComponent = NpcActor:GetAnimationComponent()
        end
    end

    return TempAnimComponent
end

---@type 设置对手的情感动作
function ActorAnimService:SetAnimEmoIDList()
    local SaluteEmoID = 0
    local DrawEmoID = 0
    local VictoryEmoID = 0
    local FailEmoID = 0
    local EmoList = _G.MagicCardMgr:GetOpponentSettedEmo()
    if _G.MagicCardMgr:IsPVPMode() then
        if EmoList ~= nil and #EmoList > 0 then
            SaluteEmoID = EmoList[1] or 0
            VictoryEmoID = EmoList[2] or 0
            DrawEmoID = EmoList[3] or 0
            FailEmoID = EmoList[4] or 0
        end
        -- 玩家没有设置行礼动作就设置一个默认的
        if SaluteEmoID <= 0 then
            local SaluteCfg = FantasyCardMotionClassifyCfg:FindAllCfg("IsSalute = 1")
            if SaluteCfg and #SaluteCfg > 0 then
                SaluteEmoID = SaluteCfg[1].EmotionID
            end
        end
    else
        -- PVE对手，随机动作
        local SaluteCfg = FantasyCardMotionClassifyCfg:FindAllCfg("IsSalute = 1")
        local VictoryCfg = FantasyCardMotionClassifyCfg:FindAllCfg("IsWin = 1")
        local DrawCfg = FantasyCardMotionClassifyCfg:FindAllCfg("IsDraw = 1")
        local FailCfg = FantasyCardMotionClassifyCfg:FindAllCfg("IsLose = 1")
        if SaluteCfg and #SaluteCfg > 0 then
            local SaluteIndex = math.random(#SaluteCfg)
            SaluteEmoID = SaluteCfg[SaluteIndex].EmotionID
        end
    
        if DrawCfg and #DrawCfg > 0 then
            local DrawIndex = math.random(#DrawCfg)
            DrawEmoID = DrawCfg[DrawIndex].EmotionID
        end
    
        if VictoryCfg and #VictoryCfg > 0 then
            local VictoryIndex = math.random(#VictoryCfg)
            VictoryEmoID = VictoryCfg[VictoryIndex].EmotionID
        end
        if FailCfg and #FailCfg > 0 then
            local FailIndex = math.random(#FailCfg)
            FailEmoID = FailCfg[FailIndex].EmotionID
        end
    end

    self.PVPAnimEmoIDList = {
        [LocalDef.SettedEmoTypeDefine.Salute] = SaluteEmoID > 0 and SaluteEmoID,
        [LocalDef.SettedEmoTypeDefine.Draw] = DrawEmoID > 0 and DrawEmoID,
        [LocalDef.SettedEmoTypeDefine.Victory] = VictoryEmoID > 0 and VictoryEmoID,
        [LocalDef.SettedEmoTypeDefine.Fail] = FailEmoID > 0 and FailEmoID,
    }
end

---@type 获取PVP对手的情感动作
function ActorAnimService:GetPVPAnimAsset(AnimEnum)
    local AnimAsset = nil
    if self.PVPAnimEmoIDList then
        local EmoID = self.PVPAnimEmoIDList[AnimEnum]
        if EmoID and EmoID > 0 then
            local EmotionCfg = EmotionCfg:FindCfgByKey(EmoID)
            if EmotionCfg == nil then
                return
            end
            local EntityID = _G.MagicCardMgr:GetOpponentEntityID()
            if(EntityID == nil or EntityID <= 0) then
                return
            end

            local PlayerActor = ActorUtil.GetActorByEntityID( EntityID)
            if PlayerActor == nil then
                return
            end
            AnimAsset = EmotionAnimUtils.GetActorEmotionAnimPath(EmotionCfg.AnimPath, PlayerActor, EmotionDefines.AnimType.EMOT)
         end
    end

    return AnimAsset
end

function ActorAnimService.GetNpcAnimCond(AnimEnum)
    local TableData = NpcAnimCfg:FindCfgByKey(AnimEnum)
    if (TableData == nil) then
        return 0
    end
    return NpcAnimCfg:FindCfgByKey(AnimEnum).CondValue
end

function ActorAnimService:__PlayMajorAnim(AnimAsset, bStopAllMontages)
    local RealAnimAsset = type(AnimAsset) == "string" and AnimAsset or ""
    if Log.Check(RealAnimAsset ~= "" and MajorAnimComponent, "PlayMajorAnim Param error") then
        Log.I("PlayMajorAnim: bStopAllMontages? [%s] [%s]", bStopAllMontages, AnimAsset)
        local Montage = MajorAnimComponent:PlayAnimation(RealAnimAsset, 1.0, 0.25, 0.25, bStopAllMontages)
        return self:GetMontageLength(Montage)
    end
end

function ActorAnimService:PlayMajorAnimByTimeline(TimelineID, bStopAllMontages)
    if Log.Check(MajorAnimComponent, "MajorAnimComponent is nil") then
        local Montage = MajorAnimComponent:PlayActionTimeline(TimelineID, 1.0, 0.25, 0.25, bStopAllMontages)
        return self:GetMontageLength(Montage, 0.7) --实际时间更短，因为混合0.25会减少时长
    end
end

--- 播放设置好的情感动作 EmoIndex 是 LocalDef.SettedEmoTypeDefine
function ActorAnimService:PlaySettedEmoAnim(EmoIndex, bStopAllMontages)
    local EmoID = _G.MagicCardMgr.EmoIDTable[EmoIndex]
    if (EmoID > 0) then
        -- 播放设置好的情感动作
        local EmotionCfg = EmotionCfg:FindCfgByKey(EmoID)

        if EmotionCfg then
            local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(
                                 EmotionCfg.AnimPath, MajorUtil.GetMajor(), EmotionDefines.AnimType.EMOT
                             )
            return self:__PlayMajorAnim(AnimPath, bStopAllMontages)
        end
    end
    -- 策划需求，如果没有设置动作的话，就不要播放动作了
    return 0
end

function ActorAnimService:PlayMajorAnimByEnum(AnimAssetEnum, bStopAllMontages)
    local TimelineID = MagicCardVMUtils.GetFantasyCardTimelineID(AnimAssetEnum)
    if TimelineID == nil or TimelineID <= 0 then
        return 0
    end
    local stopAllMontages = true
    if bStopAllMontages ~= nil then
        stopAllMontages = bStopAllMontages
    end
    
    return self:PlayMajorAnimByTimeline(TimelineID, stopAllMontages)
end

function ActorAnimService:StopMajorAnim()
    if Log.Check(MajorAnimComponent) and _G.UE.UCommonUtil.IsObjectValid(MajorAnimComponent) then
        MajorAnimComponent:StopAnimation()
    end
end

function ActorAnimService:StopNpcAnim()
    local NpcAnimComponent = self:GetNpcNpcAnimComponent()
    if NpcAnimComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(NpcAnimComponent) then
        NpcAnimComponent:StopAnimation()
    end
end

function ActorAnimService:PlayNpcAnimByEnum(AnimAssetEnum)
    local NpcAnimComponent = self:GetNpcNpcAnimComponent()
    if (NpcAnimComponent == nil) then
        return false, 0
    end

    if _G.MagicCardMgr:IsPVPMode() then
        return self:PlayPVPPlayerAnimByAnimEnum(AnimAssetEnum, false)
    else
        return self:PlayNpcAnimByActionTimelineID(AnimAssetEnum, true)
    end
end

function ActorAnimService:PlayPVPPlayerAnimByAnimEnum(AnimAssetEnum, bStopAllMontages)
    local NewAnimEnum = self:ConvertNPCAnimEnum2TimelineIndex(AnimAssetEnum)
    local TimelineID = MagicCardVMUtils.GetFantasyCardTimelineID(NewAnimEnum)
    local Montage = nil
    local Percent = 1
    local NpcAnimComponent = self:GetNpcNpcAnimComponent()
    if TimelineID and TimelineID > 0 then  --打牌相关动作
        Montage = NpcAnimComponent:PlayActionTimeline(TimelineID, 1.0, 0.25, 0.25, bStopAllMontages)
        Percent = 0.7
    else  --情感相关动作
        NewAnimEnum = self:ConvertNPCAnimEnum2EmoIndex(AnimAssetEnum)
        local AnimPath = self:GetPVPAnimAsset(NewAnimEnum)
        local RealAnimAsset = type(AnimPath) == "string" and AnimPath or ""
        if RealAnimAsset ~= "" and NpcAnimComponent then
            Montage = NpcAnimComponent:PlayAnimation(RealAnimAsset, 1.0, 0.25, 0.25, bStopAllMontages)
        else
            Log.W(string.format("PlayPVPPlayerAnim [%s] not exit", Log.EnumValueToKey(NpcAnimEnum, AnimAssetEnum)))
        end
    end

    if Montage then
        return true, self:GetMontageLength(Montage, Percent)
    end
    return false, 0
end

---@type 将通用的NPC动作枚举类型转换成打牌动作Timeline Index
function ActorAnimService:ConvertNPCAnimEnum2TimelineIndex(AnimEnum)
    local NewAnimEnum = nil
    if AnimEnum == NpcAnimEnum.PlayCard_Normal then
        NewAnimEnum = MajorAnimEnum.Major_PlayCard_Normal
    elseif AnimEnum == NpcAnimEnum.Anim_InGame_Normal then
        NewAnimEnum = MajorAnimEnum.Major_Anim_InGame_Normal
    elseif AnimEnum == NpcAnimEnum.PlayCard_TakeOut then
        NewAnimEnum = MajorAnimEnum.Major_PlayCard_TakeOut
    end
    return NewAnimEnum
end

---@type 将通用的NPC动作枚举类型转换成情感动作 Index
function ActorAnimService:ConvertNPCAnimEnum2EmoIndex(AnimEnum)
    local NewAnimEnum = nil
    if AnimEnum == NpcAnimEnum.Emo_Salute then
        NewAnimEnum = LocalDef.SettedEmoTypeDefine.Salute
    elseif AnimEnum == NpcAnimEnum.Emo_Draw then
        NewAnimEnum = LocalDef.SettedEmoTypeDefine.Draw
    elseif AnimEnum == NpcAnimEnum.Emo_PlayerSuccess then
        NewAnimEnum = LocalDef.SettedEmoTypeDefine.Victory
    elseif AnimEnum == NpcAnimEnum.Emo_PlayerFailure then
        NewAnimEnum = LocalDef.SettedEmoTypeDefine.Fail
    end
    return NewAnimEnum
end

function ActorAnimService:PlayNpcAnimByActionTimelineID(AnimAssetEnum, bStopAllMontages)
    local NPCID = _G.MagicCardMgr:GetPVENPCID()
    if (NPCID == nil or NPCID <=0) then
        return false, 0
    end

    local stopAllMontages = true
    if bStopAllMontages ~= nil then
        stopAllMontages = bStopAllMontages
    end
    
    local _npcAIData = NpcCfg:FindCfgByKey(NPCID)
    if (_npcAIData == nil) then
        _G.FLOG_ERROR("错误，无法获取数据，幻卡NPCID是："..tostring(NPCID))
        return false, 0
    end

    local TargetID = _npcAIData.Anim[AnimAssetEnum]

    if (AnimAssetEnum == NpcAnimEnum.PlayCard_Normal) then
        -- 如果是普通出牌动作，那么要去做一下随机
        math.randomseed(os.time())  -- 设置随机数种子
        TargetID = 0
        local count = #_npcAIData.NormalPutCardAnimArray
        for i = 1, count - 1 do
            local chanceMax = _npcAIData.NormalPutCardAnimArray[i].ChancePercentage
            local randomInt = math.random(1, 100)
            if (randomInt <= chanceMax) then
                TargetID = _npcAIData.NormalPutCardAnimArray[i].TimelineID
                break
            end
        end

        if (TargetID <= 0) then
            TargetID = _npcAIData.NormalPutCardAnimArray[count].TimelineID
        end
    end

    if (TargetID == nil or TargetID <=0) then
        _G.FLOG_ERROR("错误，无法获取动作 TimelineID，幻卡NPCID是："..tostring(NPCID))
        return false, 0
    end

    local AnimComp = self:GetNpcNpcAnimComponent()
    if (AnimComp == nil) then
        _G.FLOG_WARNING("没有获取到对方的 AnimComp ，请检查")
        return false, 0
    end

    local Montage = nil
    if AnimAssetEnum == NpcAnimEnum.Anim_InGame_Normal or AnimAssetEnum == NpcAnimEnum.Anim_InGame_Impatient
        or AnimAssetEnum == NpcAnimEnum.Anim_EndGame_Idle then
        -- 待机动作只能通过这种方式才能保持
        AnimComp:SetIdleActionTimeline(TargetID)
    else
        Montage = AnimComp:PlayActionTimeline(TargetID, 1.0, 0.25, 0.25, stopAllMontages)
    end

    local MontageLength = 0
    if Montage then
        MontageLength = self:GetMontageLength(Montage, 0.7)
    end

    return true, MontageLength
end

function ActorAnimService:PlayNpcEmoAnim(AnimAssetEnum)
    return self:PlayNpcAnimByEnum(AnimAssetEnum)
end

function ActorAnimService:OnGameEnd()
    -- 播放结束待机动作
    self:PlayNpcAnimByEnum(NpcAnimEnum.Anim_EndGame_Idle)
end

-- 游戏结束并且关闭结算界面
function ActorAnimService:OnGameExit()
    local AnimComp = self:GetNpcNpcAnimComponent()
    if (AnimComp == nil) then
        return
    end
    AnimComp:SetIdleActionTimeline(0) -- 播放默认待机动作
end

---@return boolean, float @如果满足条件成功播放返回true，并且返回动作时长
function ActorAnimService:PlayNpcScoreAnim(IsLeadingOrBehind, NpcScore)
    local AnimToPlay
    if IsLeadingOrBehind then
        if NpcScore >= self.LeadingAnimCond then
            AnimToPlay = NpcAnimEnum.Emo_Leading_Once
        end
    else
        -- 落后
        if NpcScore <= self.BehindAnimCond then
            AnimToPlay = NpcAnimEnum.Emo_Behind_Once
        end
    end
    if AnimToPlay then
        Log.I(
            "PlayNpcScoreAnim 播放领先/落后表情 NpcScore[%d], Anim: [%s]", NpcScore,
            Log.EnumValueToKey(NpcAnimEnum, AnimToPlay)
        )
        return self:PlayNpcEmoAnim(AnimToPlay)
    else
        return false, 0
    end
end

function ActorAnimService:PlayNpcComboAnim(ComboCount, IsPlayerMove)
    local ComboHappyCond = NpcAnimCfg:FindCfgByKey(NpcAnimEnum.PlayCard_Combo_Happy).CondValue
    if ComboCount < ComboHappyCond then
        return false
    end

    local HappyOrSupperHappy = ComboCount == ComboHappyCond
    local AnimAssetEnum
    if not IsPlayerMove then
        AnimAssetEnum = HappyOrSupperHappy and NpcAnimEnum.Emo_Combo_Happy or NpcAnimEnum.Emo_Combo_SupperHappy
    else
        AnimAssetEnum = HappyOrSupperHappy and NpcAnimEnum.Emo_Combo_Sad or NpcAnimEnum.Emo_Combo_SupperSad
    end

    Log.I("Npc播放[%s]动作，ComboCount：[%d]", Log.EnumValueToKey(NpcAnimEnum, AnimAssetEnum), ComboCount)
    return self:PlayNpcEmoAnim(AnimAssetEnum)
end

---@return 播放动作的时长
function ActorAnimService:PlayNpcPlayCardAnim(ComboCount, FlipCount)
    local IsPlayCardCombo, IsPlayCardFlip = false, false
    local PlayAnimEnum = NpcAnimEnum.PlayCard_Normal
    local Duration = 0
    local ComboHappyCond = self.GetNpcAnimCond(NpcAnimEnum.PlayCard_Combo_Happy)
    if ComboCount >= ComboHappyCond then
        PlayAnimEnum = ComboCount == ComboHappyCond and NpcAnimEnum.PlayCard_Combo_Happy or
                           NpcAnimEnum.PlayCard_Combo_SupperHappy
        IsPlayCardCombo, Duration = self:PlayNpcEmoAnim(PlayAnimEnum)
    end

    local FlipHappyCond = self.GetNpcAnimCond(NpcAnimEnum.PlayCard_Flip_Happy)
    if not IsPlayCardCombo and FlipCount > FlipHappyCond then
        PlayAnimEnum = NpcAnimEnum.PlayCard_Flip_Happy
        IsPlayCardFlip, Duration = self:PlayNpcEmoAnim(PlayAnimEnum)
    end
    local IsPlayed = false
    if not IsPlayCardCombo and not IsPlayCardFlip then
        PlayAnimEnum = NpcAnimEnum.PlayCard_Normal
        IsPlayed, Duration = self:PlayNpcEmoAnim(PlayAnimEnum)
    end

    Log.I(
        "Npc出牌动作：[%s] with ComboCount[%d], FlipCount[%d], 播放Combo?[%s] 播放Flip？[%s]",
        Log.EnumValueToKey(NpcAnimEnum, PlayAnimEnum), ComboCount, FlipCount, IsPlayCardCombo, IsPlayCardFlip
    )

    return Duration
end

function ActorAnimService:PlayNpcIdleAnim()
    ActorAnimService:PlayNpcAnimByEnum(NpcAnimEnum.Anim_InGame_Normal)
end

---@return 动作时长，npc和major动作时长一致
function ActorAnimService:PlayMajorAndNpcSaluteAnim()
    local MajorAnimLength = self:PlaySettedEmoAnim(LocalDef.SettedEmoTypeDefine.Salute, true)
    local _, NpcAnimLength = self:PlayNpcEmoAnim(NpcAnimEnum.Emo_Salute)
    return MajorAnimLength, NpcAnimLength
end

function ActorAnimService:GetMontageLength(Montage, Percent)
    if Montage == nil then
        return 0
    end
    local ActualPercent = Percent ~= nil and Percent or 1
    local Length = AnimationUtil.GetAnimMontageLength(Montage)
    return Length * ActualPercent
end


return ActorAnimService
