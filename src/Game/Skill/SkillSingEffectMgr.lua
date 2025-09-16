



local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local SkillSingEffectMgr = LuaClass(MgrBase)
local StatusSingingCfg = require("TableCfg/StatusSingingCfg")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState

local ObjectPool = require("Game/ObjectPool/ObjectPool")
local SingSkillObject = require("Game/Skill/SkillAction/SingSkillObject")
local SkillActionConfig = require("Game/Skill/SkillAction/SkillActionConfig")

local MsgTipsID = require("Define/MsgTipsID")
local SingEffectGlobalID = 0
local SingleRoleMaxLimit = -1  --单一EntityID最大吟唱效果上限，-1表示无上限
local LSTR

local FLOG_WARNING = _G.FLOG_WARNING
local SingStateTag = "Sing"


function SkillSingEffectMgr:OnInit()
    self.SingEffectMap = {}

    --[[{
        [EntityID] = {[SingID1] = Status, [SingID2] = Status},
    }]]
    self.CurrentEntityIDEffects = {}
    self.PlayerSingMap = {}
    self.ToleranceTime = 500 --主角技能吟唱的容错时间ms
    self.SingCacheData = {}

    self.RecordToleranceTime = {}
end

function SkillSingEffectMgr:OnBegin()
	LSTR = _G.LSTR
    self:InitSingSkillObjectPool()
end

function SkillSingEffectMgr:OnEnd()
    self:ReleaseSingSkillObjectPool()
end

function SkillSingEffectMgr:OnShutdown()

end

function SkillSingEffectMgr:OnRegisterNetMsg()

end

function SkillSingEffectMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WorldPreLoad, self.OnLevelChange)
    self:RegisterGameEvent(EventID.LevelPreLoad, self.OnLevelChange)
    self:RegisterGameEvent(EventID.ActorDestroyed, self.OnActorDestroyed)

    self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.ActorVelocityUpdate)
    self:RegisterGameEvent(EventID.MajorJumpStart, self.OnMajorJumpStart)
    self:RegisterGameEvent(EventID.TrivialCombatStateUpdate, self.OnControlStateChange)

    self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
end

function SkillSingEffectMgr:OnRegisterTimer()

end

function SkillSingEffectMgr:OnLevelChange()
    self.SingEffectMap = {}
    for key, _ in pairs(self.SingEffectMap) do
        self.SingEffectMap[key] = nil
    end
    self.RecordToleranceTime = {}
end

function SkillSingEffectMgr:OnActorDestroyed(Params)
    local EntityID = Params.ULongParam1
    local SingEffectIDs = self.CurrentEntityIDEffects[EntityID]
    if SingEffectIDs then
        for SingEffectID, _ in pairs(SingEffectIDs) do
            self:BreakSingEffect(EntityID, SingEffectID)
        end
    end
    self.CurrentEntityIDEffects[EntityID] = nil
end

--UniqueID
function SkillSingEffectMgr:GetUniqueID()
    SingEffectGlobalID = SingEffectGlobalID + 1
    return SingEffectGlobalID
end

--SingID: 吟唱表ID
function SkillSingEffectMgr:PlaySingEffect(EntityID, SingID, TargetIDs, PlayRate)
    if SingID == nil then
        FLOG_WARNING("[SkillSingEffectMgr]InValid SingID is nil")
        return 0
    end
    SingID = tonumber(SingID)
    if EntityID <= 0 or SingID == 0 or not self.CurrentEntityIDEffects then
        return 0
    end
    local CurrentEntityIDEffect = self.CurrentEntityIDEffects[EntityID]
    if SingleRoleMaxLimit >= 0 and SingID > 0 then
        local SingleEntityIDCount = 0
        if CurrentEntityIDEffect ~= nil then
            for _, _ in pairs(CurrentEntityIDEffect) do
                SingleEntityIDCount = SingleEntityIDCount + 1
            end
        end
        if SingleEntityIDCount >= SingleRoleMaxLimit then
            FLOG_WARNING(string.format("[SkillSingEffectMgr]EntityID: %d, SkillSingEffect Exceeded Limit %d", EntityID, SingleRoleMaxLimit))
            return 0
        end
    end
    --小于0的singID强制播放
    SingID = math.abs(SingID)
    local Cfg = StatusSingingCfg:FindCfgByKey(SingID)
    if Cfg == nil then
        return 0
    end

    local SingPlayRate = PlayRate or 1
    local SingCellObject = self:AllocSingSkillObject()
    local EndTime = Cfg.EndTime * SingPlayRate
    local SingEffectID = self:GetUniqueID()
    SingCellObject:Init(SingID, EntityID, TargetIDs, SingEffectID, EndTime, SingPlayRate)

    if CurrentEntityIDEffect == nil then
        self.CurrentEntityIDEffects[EntityID] = {}
    end
    self.CurrentEntityIDEffects[EntityID][SingEffectID] = true
    self.SingEffectMap[SingEffectID] = SingCellObject

    return SingEffectID
end

function SkillSingEffectMgr:BreakSingEffectInternal(SingEffectID)
    if SingEffectID == nil or SingEffectID == 0 then
        return
    end
    local Object = self.SingEffectMap[SingEffectID]
    if Object ~= nil then
        Object:BreakSkill()
        self:FreeSingSkillObject(Object)
        self.SingEffectMap[SingEffectID] = nil
    end
end

--SingEffectID: SkillSingEffectMgr:PlaySingEffect返回值
function SkillSingEffectMgr:BreakSingEffect(EntityID, SingEffectID)
    if not EntityID or EntityID <= 0 or not SingEffectID or SingEffectID == 0 then
        return
    end

    if not self.CurrentEntityIDEffects or self.CurrentEntityIDEffects[EntityID] == nil then
        return
    end

    local SingEffectIDs = self.CurrentEntityIDEffects[EntityID]

    if SingEffectID == -1 then
        for key, _ in pairs(SingEffectIDs) do
            self:BreakSingEffectInternal(key)
        end
        self.CurrentEntityIDEffects[EntityID] = nil
    elseif SingEffectIDs[SingEffectID] ~= nil then
        self:BreakSingEffectInternal(SingEffectID)
        SingEffectIDs[SingEffectID] = nil
    end
end

function SkillSingEffectMgr:IsSinging(EntityID)
    return self.PlayerSingMap[EntityID] ~= nil
end

function SkillSingEffectMgr:BreakSingInternal(Params)
    local InLogicData = _G.SkillLogicMgr:GetSkillLogicData(Params.EntityID)
    if InLogicData and InLogicData.bMajor then
        self.RecordToleranceTime[Params.EntityID] = TimeUtil.GetLocalTimeMS()
        self:RegisterTimer(function()
            local MaskType = SkillBtnState.SkillBtnControl
            _G.SkillLogicMgr:SetSkillButtonEnable(Params.EntityID, MaskType, nil, function() return true end)
        end, self.ToleranceTime / 1000, 1, 1)
    end
    _G.EventMgr:SendEvent(EventID.SkillSingOver, Params)
    self:PlayerSingBreak(Params.EntityID, true)
end

function SkillSingEffectMgr:PlayerSingBegin(EntityID, SkillID, MajorSkillInfo, JoyStickParams)
    if not SkillID then
        return false
    end
    local _ <close> = CommonUtil.MakeProfileTag("SkillSingEffectMgr:PlayerSingBegin")
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if not Cfg then
        return false
    end

    --返回非吟唱技能
    if Cfg.IsSing == 0 then
        return false
    end

    local IsMajor = MajorUtil.IsMajor(EntityID)
    --移动中无法开始吟唱
    if IsMajor then
        local Velocity = MajorUtil.GetMajor().CharacterMovement.Velocity
        if Velocity.X ~= 0 or Velocity.Y ~= 0 or Velocity.Z ~= 0 then
            local MajorActor= ActorUtil.GetActorByEntityID(EntityID)
            if MajorActor and  MajorActor:IsPathWalking()  then
                _G.AutoPathMoveMgr:StopAutoPathMoving()
            else
                return true
            end
        end
    end

    --角色是否存活
    local ActorStateComponent = ActorUtil.GetActorStateComponent(EntityID)
    if not ActorStateComponent or ActorStateComponent:IsDeadState() then
        return true
    end

    --上一吟唱未结束，直接干掉
    if self.PlayerSingMap[EntityID] then
        self:PlayerSingBreak(EntityID, false)
    end

    local SingID = Cfg.SingID
    local SingTime = Cfg.SingTime + 50
    local PlayRate = 1
    --角色CD急速计算
    if Cfg.QuickAttrInvalid == 0 then
        local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
        if AttributeComponent then
            PlayRate = 1 - AttributeComponent:GetAttrValue(ProtoCommon.attr_type.attr_shorten_sing_time) / 10000
        end
        SingTime = SingTime * PlayRate
    end

    local IsSwitchFirst = 0
    local FirstTarget = 0
    local SubSkillID = 0
    if IsMajor then
        --主角额外判断
        SubSkillID = SkillUtil.MainSkill2SubSkill(SkillID)
        if not SubSkillID or SubSkillID == 0 then
            return true
        end
        local SubCfg = SkillSubCfg:FindCfgByKey(SubSkillID)
        if not SubCfg then
            return true
        end
        local ActorRef = ActorUtil.GetActorByEntityID(EntityID)
        local TargetList = nil --目标列表至多获取一次

        local AbsolutePosition = nil
        local AbsoluteAngle = nil
        if JoyStickParams ~= nil then
            AbsolutePosition = JoyStickParams.Position
            AbsoluteAngle = JoyStickParams.Angle
        end

        IsSwitchFirst = Cfg.IsSwitchFirst or 0
        if IsSwitchFirst == 1 then
            TargetList = TargetList or _G.SelectTargetMgr:SelectTargets(SkillID, SubSkillID, 1, ActorRef, false, true, AbsolutePosition, AbsoluteAngle)
            if TargetList:Length() > 0 then
                FirstTarget = TargetList:GetRef(1)
            end
        end

        --技能不能空放，但找不到目标
        if SubCfg.IsCastWithoutTarget == 0 and IsMajor then
            TargetList = TargetList or _G.SelectTargetMgr:SelectTargets(SkillID, SubSkillID, 1, ActorRef, false, true, AbsolutePosition, AbsoluteAngle)
            if TargetList:Length() == 0 then
                MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillNoTargetOrFar)-- 没有有效目标或目标距离过远
                return true
            end
        end

        local ForwardTarget = Cfg.IsFaceToTarget
        if ForwardTarget ~= 0 then
            --面朝目标
            TargetList = TargetList or _G.SelectTargetMgr:SelectTargets(SkillID, SubSkillID, 1, ActorRef, false, true, AbsolutePosition, AbsoluteAngle)
            if TargetList:Length() > 0 then
                --TODO[chaooren] 这个方法移到ActorUtil里比较好
                ActorUtil.InitSelectPosAndDirInfo(ActorRef, ActorUtil.GetActorByEntityID(TargetList:GetRef(1)))
            end
        end
        --吟唱期间锁定旋转
        local StateComponent = ActorUtil.GetActorStateComponent(EntityID)
		if StateComponent ~= nil then
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, false, SingStateTag)
		end

        --打断当前技能(如果有)
        local CombatComponent = ActorUtil.GetActorCombatComponent(EntityID)
        if CombatComponent ~= nil then
            CombatComponent:BreakSkill()
        end

        local TotalTime = SingTime + self.ToleranceTime

        local Params = _G.EventMgr:GetEventParams()
		Params.ULongParam1 = MajorSkillInfo.SkillType
		Params.ULongParam2 = MajorSkillInfo.Index
		Params.IntParam1 = MajorSkillInfo.SkillID
		Params.IntParam2 = MajorSkillInfo.CfgID
		Params.IntParam3 = MajorSkillInfo.QueueIndex
		Params.IntParam4 = MajorSkillInfo.QueueSkillID

        if IsMajor then
            local LogicData = _G.SkillLogicMgr:GetSkillLogicData(EntityID)
            local ReviseSkillSing = LogicData:GetReviseSkillSing(SkillID)
            if ReviseSkillSing then
                TotalTime = TotalTime * (ReviseSkillSing / 10000)
            end
            _G.EventMgr:SendEvent(EventID.MajorSing, {EntityID = EntityID, SkillID = SkillID, Time = TotalTime})
            _G.EventMgr:SendCppEvent(EventID.MajorSing, Params)
            local MaskType = SkillBtnState.SkillBtnControl
            _G.SkillLogicMgr:SetSkillButtonEnable(EntityID, MaskType, nil, function() return false end)--主角技能按钮禁用
            local bEnterCombat = SkillMainCfg:FindValue(SkillID, "IsTempHoldWeapon") == 1
            if bEnterCombat and StateComponent and not StateComponent:IsInCombatNetState() then
                StateComponent:TempHoldWeapon(_G.UE.ETempHoldMask.Skill)
            end
        end
    else
        _G.EventMgr:SendEvent(EventID.ThirdPlayerSkillSing, {EntityID = EntityID, SkillID = SkillID, Time = SingTime})
    end

    local SingEffectID = self:PlaySingEffect(EntityID, SingID, nil, PlayRate)

    local Info = {}
    Info.TimerID = 
        self:RegisterTimer(self.BreakSingInternal, SingTime / 1000, 1, 1
            , {EntityID = EntityID, SingEffectID = SingEffectID, SkillID = SkillID})
    Info.SingEffectID = SingEffectID
    Info.SkillID = SkillID
    Info.MajorSkillInfo = MajorSkillInfo
    Info.JoyStickParams = JoyStickParams
    if IsSwitchFirst == 1 then
        Info.SubSkillID = SubSkillID
        Info.IsSwitchFirst = IsSwitchFirst
        Info.FirstTarget = FirstTarget
    end
    self.PlayerSingMap[EntityID] = Info
    return true, SingEffectID
end

function SkillSingEffectMgr:PlayerSingBreak(EntityID, bSuccess)
    local PlayerSingData = self.PlayerSingMap[EntityID]
    if not PlayerSingData then
        return
    end
    local _ <close> = CommonUtil.MakeProfileTag("SkillSingEffectMgr:PlayerSingBreak")
    local SingEffectID = PlayerSingData.SingEffectID
    self:BreakSingEffect(EntityID, SingEffectID)
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(EntityID)
    if LogicData then
        local MajorSkillInfo = PlayerSingData.MajorSkillInfo
        local StateComponent = ActorUtil.GetActorStateComponent(EntityID)
		if StateComponent ~= nil then
			StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, true, SingStateTag)
		end

        if LogicData.bMajor then
            local bEnterCombat = SkillMainCfg:FindValue(PlayerSingData.SkillID or 0, "IsTempHoldWeapon") == 1
            if bEnterCombat and StateComponent and not StateComponent:IsInCombatNetState() then
                StateComponent:ClearTempHoldWeapon(_G.UE.ETempHoldMask.Skill, true)
            end
        end

        local bCastSkill = false
        if bSuccess and MajorSkillInfo then
            if not LogicData.bMajor then
                SkillUtil.PlayerCastSkillFinal(EntityID, MajorSkillInfo.SkillType, MajorSkillInfo.SkillID, MajorSkillInfo.SkillID, MajorSkillInfo.Index, nil, true)
                bCastSkill = true
            elseif LogicData:CanCastSkill(MajorSkillInfo.Index, false, SkillBtnState.SkillBtnControl) == true then
                if PlayerSingData.IsSwitchFirst == 1 then
                    local FirstTarget = PlayerSingData.FirstTarget
                    local EventParams = _G.EventMgr:GetEventParams()
		            EventParams.ULongParam1 = FirstTarget
		            _G.EventMgr:SendCppEvent(_G.EventID.SKillSelectTarget, EventParams)
                    local TargetList = _G.SelectTargetMgr:SelectTargets(PlayerSingData.SkillID, PlayerSingData.SubSkillID, 1, MajorUtil.GetMajor(), false, true)
                    if FirstTarget == 0 or (TargetList:Length() ~= 0 and TargetList:GetRef(1) == FirstTarget) then
                        bCastSkill = SkillUtil.CastSkillDirect(MajorSkillInfo, PlayerSingData.JoyStickParams, true)
                    end
                else
                    bCastSkill = SkillUtil.CastSkillDirect(MajorSkillInfo, PlayerSingData.JoyStickParams, true)
                end
            end
        end

        --技能释放失败时发送主角吟唱结束事件
        if not bCastSkill then
            local MaskType = SkillBtnState.SkillBtnControl
            _G.SkillLogicMgr:SetSkillButtonEnable(EntityID, MaskType, nil, function() return true end)
            local Params = _G.EventMgr:GetEventParams()
            Params.ULongParam1 = PlayerSingData.SkillID
            _G.EventMgr:SendCppEvent(EventID.MajorBreakSing, Params)
            _G.EventMgr:SendEvent(EventID.MajorBreakSing, {EntityID = EntityID})
        end
    elseif not bSuccess then
        _G.EventMgr:SendEvent(EventID.ThirdPlayerSkillSingBreak, {EntityID = EntityID})
    end

    --看起来是break过程中又调用到了break
    if PlayerSingData then
        self:UnRegisterTimer(PlayerSingData.TimerID)
        self.PlayerSingMap[EntityID] = nil
    end
end

function SkillSingEffectMgr:ActorVelocityUpdate(Params)
    local EntityID = Params.ULongParam1
    if EntityID == MajorUtil.GetMajorEntityID() then
        local Velocity=  MajorUtil.GetMajor().CharacterMovement.Velocity
        if Velocity.X ~= 0 or Velocity.Y ~= 0 or Velocity.Z ~= 0 then
            self:PlayerSingBreak(EntityID, false)
        end
    end
end

function SkillSingEffectMgr:OnMajorJumpStart()
    local EntityID = MajorUtil.GetMajorEntityID()
    if EntityID then
        self:PlayerSingBreak(EntityID, false)
    end
end

function SkillSingEffectMgr:OnControlStateChange(Params)
    if MajorUtil.GetMajorEntityID() ~= Params.ULongParam1 then
		return
	end
    local MajorStateComp = MajorUtil.GetMajorStateComponent()
    if MajorStateComp == nil or MajorStateComp:GetActorControlState(_G.UE.EActorControllStat.CanUseSkill) == false then
		self:PlayerSingBreak(MajorUtil.GetMajorEntityID(), false)
	end
end


function SkillSingEffectMgr:GetToleranceTime(EntityID)
    if self.PlayerSingMap[EntityID] then
        return -1
    end
    local Record = self.RecordToleranceTime[EntityID]
    if Record then
        local Diff = self.ToleranceTime - (TimeUtil.GetLocalTimeMS() - Record)
        if Diff > 0 then
            return Diff / 1000
        end
    end
    return 0
end

--吟唱时技能替换则中断吟唱
function SkillSingEffectMgr:OnSkillReplace(Params)
    if Params.RawSkillID == nil then
        return
    end
    local SingData = self.PlayerSingMap[Params.EntityID]
    if SingData and SingData.SkillID == Params.RawSkillID then
        self:PlayerSingBreak(Params.EntityID, false)
    end
end

function SkillSingEffectMgr:InitSingSkillObjectPool()
    local function Constructor()
        return SingSkillObject.New()
    end

    local Pool = ObjectPool.New(Constructor)
    Pool:PreLoadObject(SkillActionConfig.SingSkillObjectPoolSize)

    self.SingSkillObjectPool = Pool
end

function SkillSingEffectMgr:ReleaseSingSkillObjectPool()
    self.SingSkillObjectPool:ReleaseAll()
end

function SkillSingEffectMgr:AllocSingSkillObject()
    ---@param Object SingSkillObject
    local Object = self.SingSkillObjectPool:AllocObject()
    Object:ResetParams()
    return Object
end

function SkillSingEffectMgr:FreeSingSkillObject(Object)
    self.SingSkillObjectPool:FreeObject(Object)
end

function SkillSingEffectMgr:OnPWorldExit()
    local EntityID = MajorUtil.GetMajorEntityID()
    if EntityID then
        self:PlayerSingBreak(EntityID, false)
    end
end

return SkillSingEffectMgr