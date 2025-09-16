local LuaClass = require("Core/LuaClass")
local ProtoCommon = require("Protocol/ProtoCommon")
local FishStatus = ProtoCommon.LIFESKILL_STATUS
local FishCfg = require("TableCfg/FishCfg")
local ActorUtil = require("Utils/ActorUtil")
local SkillUtil = require("Utils/SkillUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local EFishStateType = _G.UE.EFishStateType
local EFishHuckType = _G.UE.EFishHuckType
local FishDefine = require("Game/Fish/FishDefine")

local FishPlayerUnit = LuaClass()
FishPlayerUnit.FishPlayers = {}

FishPlayerUnit.EndTypeEnum = {
    End = 0,
    Wait = 1,
}

function FishPlayerUnit.Get(EntityID, bCreate)
    EntityID = EntityID or 0
    if EntityID == 0 then
        return nil
    end

    local Unit = FishPlayerUnit.FishPlayers[EntityID]
    if Unit then
        return Unit
    end

    bCreate = bCreate or true
    if bCreate == true then
        Unit = FishPlayerUnit.New(EntityID)
        FishPlayerUnit.FishPlayers[EntityID] = Unit
        return Unit
    end
    return nil
end

function FishPlayerUnit.Del(EntityID)
    local Unit = FishPlayerUnit.FishPlayers[EntityID]
    if Unit then
        Unit:ReleaseElement()
    end
    FishPlayerUnit.FishPlayers[EntityID] = nil
end

function FishPlayerUnit.DelAll()
    for _, value in pairs(FishPlayerUnit.FishPlayers) do
        value:ReleaseElement()
    end
    FishPlayerUnit.FishPlayers = {}
end

function FishPlayerUnit:Ctor(EntityID)
    self.CurFishState = self.FISHER_PREPARE
    self.CurFishID = 0
    self.CurRodType = nil
    self.FishDropTimer = 0
    self.FishLiftTimer = 0

    self.EntityID = EntityID
    self.bSitCorrect = false -- 部分情况下为了匹配动作，需要临时调整站坐状态，在此进行标记
end

function FishPlayerUnit:ReleaseElement()
    if self.FishDropTimer > 0 then
        TimerMgr:CancelTimer(self.FishDropTimer)
        self.FishDropTimer = 0
    end
    if self.FishLiftTimer > 0 then
        TimerMgr:CancelTimer(self.FishLiftTimer)
    end
    self.CurFishID = 0
    self.CurRodType = nil
end

function FishPlayerUnit:OnSkillFishDrop(Params)
    self:RemoveIdleAnim()
    if self.CurFishState ~= FishStatus.FISHER_PREPARE and self.CurFishState ~= FishStatus.FISHER_WAIT then
        print("[FishPlayerUnit] OnSkillFishDrop invalid")
    end

    self.CurFishState = FishStatus.FISHER_DROPCAST

    local SkillID = Params.LifeSkillID
    local BaitID = Params.FishDrop.BaitID
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.EntityID)
    if AnimComp then
        AnimComp:SetFishState(0, EFishHuckType.None, SkillID, BaitID, EFishStateType.Fishing)
    end
    local FishID = Params.FishDrop.FishResID
    if FishID <= 0 then
        --等待结束协议
        --这里等回包而不是P3模拟，不然fishing动画会被立即中断
        return
    end

    local Stamp = Params.FishDrop.HookedTimestampMS
    local WaitTime = SkillUtil.StampToTime(Stamp)
    if WaitTime <= 0 then
        --几种可能
        --P1超时
        --P1咬钩
        --P1咬钩，但脱钩了
        --P1咬钩且执行后续协议
        print("[FishPlayerUnit] Time out")
    end

    self:ReleaseElement()
    self.FishDropTimer = TimerMgr:AddTimer(self, self.OnFishBite, WaitTime, 1, 1)
    self.CurFishID = FishID
end

function FishPlayerUnit:OnFishBite()
    self:RemoveIdleAnim()
    self.CurRodType = FishCfg:FindValue(self.CurFishID, "RodType")
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.EntityID)
    if AnimComp then
        AnimComp:SetFishState(self.CurRodType, EFishHuckType.None, 0, 0, EFishStateType.Bite)
    end

    self.CurFishState = FishStatus.FISHER_LIFT_WINDOW
end

local function InvokeNextTime(Params)
    local AnimComp = ActorUtil.GetActorAnimationComponent(Params.EntityID)
    if AnimComp then
        AnimComp:SetFishState(Params.RodType, Params.Quality + 1, 0, 0, EFishStateType.Hook)
    end
end

function FishPlayerUnit:OnSkillFishLift(Params)
    self:RemoveIdleAnim()
    if self.CurFishState ~= FishStatus.FISHER_LIFT_WINDOW then
        print("OnSkillFishLift")
    end

    local FishID = Params.FishLift.Fish.ResID
    local FishCount = Params.FishLift.Fish.Count
    local Quality = Params.FishLift.Fish.Quality
    local bSuccess = FishID ~= nil and FishID > 0 and FishCount > 0

    if FishID ~= self.CurFishID then
        --中途接收到了提竿协议
        self.CurFishID = FishID
        self.CurRodType = FishCfg:FindValue(self.CurFishID, "RodType")
    end

    local AnimComp = ActorUtil.GetActorAnimationComponent(self.EntityID)
    local SkillID = Params.LifeSkillID
    if AnimComp then
        -- 当RodType == 3时，此时的提竿动作时是站起的，因此需要修正此时的客户端站坐状态
        if self.CurRodType == 3  then
            local PlayerAnimInstance = AnimComp:GetPlayerAnimInstance()
            local bSit = PlayerAnimInstance and PlayerAnimInstance.bSit or false
            if bSit then
                AnimComp:SetActorSit(Params.ObjID, false, false, false)
                self.bSitCorrect = true
            end
        end
        AnimComp:SetFishState(self.CurRodType, EFishHuckType.None, SkillID, 0, EFishStateType.Fight)
    end
    if not bSuccess then
        --P1提竿失败,等结束协议
        return
    end
    self.CurFishState = FishStatus.FISHER_LIFTING

    self.FishLiftTimer = TimerMgr:AddTimer(nil, InvokeNextTime, 0.05, 0.05, 1, {EntityID = self.EntityID, RodType = self.CurRodType, Quality = Quality})
end

function FishPlayerUnit:OnSkillFishLiftResult()
    self.CurFishState = FishStatus.FISHER_AFTER_LIFT
end

-- function FishPlayerUnit:OnSkillFishLiftResult()
--     if self.CurFishState ~= FishStatus.FISHER_LIFTING then
--         print("OnSkillFishLiftResult")
--     end

--     --这里需要
--     local FishID = self.CurFishID
--     local EndTime = 15  --提竿后等待期，HQ以小钓大无限时长，其他15s
--     self.CurUseSmallCatchBig = FishCfg:FindValue(FishID, "BaitID") ~= 0 and 1 or 0
--     if self.CurFishQuality == LifeSkillQuality.LIFE_SKILL_QUALITY_HQ and self.CurUseSmallCatchBig == 1 then
--         EndTime = 0
--     end
--     if EndTime > 0 then
--         self.FishLiftTimer = TimerMgr:AddTimer(self, self.OnFishEnd, EndTime, 1, 1)
--     end

--     self.CurFishState = FishStatus.FISHER_AFTER_LIFT
-- end

function FishPlayerUnit:OnSkillFishEnd(Params)
    self:RemoveIdleAnim()
    local EndType = Params.FishEnd.EndType
    local FishState = EFishStateType.None
    if FishPlayerUnit.EndTypeEnum.End == EndType then
        -- 退出钓鱼状态
        FishState = EFishStateType.None
        self.CurFishState = FishStatus.FISHER_PREPARE
    elseif FishPlayerUnit.EndTypeEnum.Wait == EndType then
        -- 钓鱼提竿失败
        FishState = EFishStateType.HookFail
        self.CurFishState = FishStatus.FISHER_AFTER_LIFT
    end
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.EntityID)
    if AnimComp then
        AnimComp:SetFishState(0, 0, 0, 0, FishState)
    end
    self:ReleaseElement()
end

function FishPlayerUnit:RemoveIdleAnim()
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.EntityID)
        if AnimComp and self.IdleAnim then
            AnimComp:StopMontage(self.IdleAnim)
            self.IdleAnim = nil
        end
end

function FishPlayerUnit:SetFishStateFirst(bSit)
    --TODO 默认动作写在这里
    local AnimComp = ActorUtil.GetActorAnimationComponent(self.EntityID)
    if AnimComp then
        local PlayAnim = bSit and FishDefine.SitAnim or FishDefine.StandAnim
        local DynamicMontange = AnimationUtil.CreateLoopDynamicMontage(nil, ObjectMgr:LoadObjectSync(PlayAnim), "WholeBody")
        AnimComp:PlayMontage(DynamicMontange, nil)
        self.CurFishState = FishStatus.FISHER_WAIT
        self.IdleAnim = DynamicMontange
    end
end

function FishPlayerUnit:AnimNotify_OnFishHookEnd(EntityID)
    if self.EntityID == EntityID and self.bSitCorrect then
        self.bSitCorrect = false
        local AnimComp = ActorUtil.GetActorAnimationComponent(self.EntityID)
        AnimComp:SetActorSit(EntityID, true, false, false)
    end
end

function FishPlayerUnit:IsInFishState()
    return self.CurFishState ~= nil and self.CurFishState ~= FishStatus.INVALID and self.CurFishState ~= FishStatus.FISHER_PREPARE
end

return FishPlayerUnit