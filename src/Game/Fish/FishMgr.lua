local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local FishBaitCfg = require("TableCfg/FishBaitCfg")
local SettingsCfg = require("TableCfg/SettingsCfg")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local EffectUtil = require("Utils/EffectUtil")
local ActorUtil = require("Utils/ActorUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ObjectGCType = require("Define/ObjectGCType")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD
local MainPanelVM = require("Game/Main/MainPanelVM")
local MountVM = require("Game/Mount/VM/MountVM")

local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
local RPNGenerator = require("Game/Skill/SelectTarget/RPNGenerator")
local LifeSkillConditionCfg = require("TableCfg/LifeSkillConditionCfg")
local FishLocationCfg = require("TableCfg/FishLocationCfg")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")
local FishCfg = require("TableCfg/FishCfg")
local FishVM = require("Game/Fish/FishVM")
local BagMgr = require("Game/Bag/BagMgr")
local SaveKey = require("Define/SaveKey")
local UIViewMgr = require("UI/UIViewMgr")
local EventMgr = require("Event/EventMgr")
local NaviDecalMgr = require("Game/Navi/NaviDecalMgr")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ObjectMgr = require("Object/ObjectMgr")
local SkillLogicMgr = require("Game/Skill/SkillLogicMgr")
local BuoyMgr = require("Game/HUD/BuoyMgr")
local LifeSkillBuffMgr = require("Game/Skill/LifeSkillBuffMgr")
local UIViewID = require("Define/UIViewID")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

local LifeSkillQuality = ProtoCS.LifeSkillQuality
local ProfFisher = ProtoCommon.prof_type.PROF_TYPE_FISHER
local LifeSkillActionType = ProtoRes.LIFESKILL_ACTION_TYPE

local FishMainPanelViewID = UIViewID.FishMainPanel
local MainPanel = UIViewID.MainPanel
local EFishStateType = _G.UE.EFishStateType
local EFishHuckType = _G.UE.EFishHuckType
local SaveMgr = _G.UE.USaveMgr
local FVfxParameter = _G.UE.FVfxParameter
local UAudioMgr = _G.UE.UAudioMgr
local UILayer = require("UI/UILayer")

local FishStatus = table.deepcopy(ProtoCommon.LIFESKILL_STATUS)
FishStatus["FISHER_AFTER_FISHEND"] = 996
FishStatus["FISHER_LIFT_ANIMEND"] = 997
FishStatus["FISHER_DROPCAST"] = 998
FishStatus["FISHER_LIFTCAST"] = 999
FishStatus["FISHER_LIFTFAILDCAST"] = 1000

local FishNetStat = ProtoCommon.CommStatID.COMM_STAT_FISH

local FishPlayerUnit = require("Game/Fish/FishPlayerUnit")
local EndTypeEnum = FishPlayerUnit.EndTypeEnum
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local NoFishReason = ProtoCS.NoFishReason
local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE

local FishDefine = require("Game/Fish/FishDefine")
local ClientFishReason = FishDefine.ClientFishReason
local FishLiftFailReason = FishDefine.FishLiftFailReason
local FishErrorCode = FishDefine.FishErrorCode
local FishSKillID = FishDefine.FishSKillID
local FishBuffID = FishDefine.FishBuffID
local FishBuffCode = FishDefine.FishBuffCode
local ViewDisSettingID = FishDefine.ViewDisSettingID
local MinCameraDis = FishDefine.MinCameraDis
local FishActionID = FishDefine.FishActionID

--TODO[chaooren] 剩余未做的事
--1、切图后钓鱼流程应重置避免错误流程和表现
--2、钓鱼流程还要再看一下，各阶段的异常返回流程
--3、各部分提示
--4、钓鱼动作接入

---@class FishMgr : MgrBase
local FishMgr = LuaClass(MgrBase)

local FishBiteWindowTime = 3    --鱼咬钩时间
local HookEndTime = 15       --hook到动作结束最长时间
local EndActionTime = 1     --结束/收杆动作时间
local LiftFailEndTime = 2   -- 空提动作时间
local AfterLiftTime = 15     -- 提竿后窗口期时间

local InputRangeCheckValue = 0.25

local bMoveLock = false

local FishEffectDataAssetPath = FishDefine.FishEffectDataAssetPath

-- 查询1P是否在钓鱼状态中
function FishMgr:IsInFishState()
    return self.CurFishState ~= FishStatus.INVALID and self.CurFishState ~= FishStatus.FISHER_PREPARE
end

-- 根据EntityID查询玩家是否处于钓鱼状态
function FishMgr:IsEntityInFishing(EntityID)
    local InFishing = false
    if MajorUtil.IsMajor(EntityID) then
        InFishing = self:IsInFishState()
    else
        local Player = FishPlayerUnit.Get(EntityID)
        if nil ~= Player then
            InFishing = Player:IsInFishState()
        end
    end
    return InFishing
end

function FishMgr:StateKeepDelayRemoveBuff()
    return self.CurFishState ~= FishStatus.INVALID and self.CurFishState ~= FishStatus.FISHER_PREPARE and self.CurFishState ~= FishStatus.FISHER_AFTER_LIFT and self.CurFishState ~= FishStatus.FISHER_AFTER_FISHEND
end

function FishMgr:GetCurrentBaitID()
    return self.BaitID
end

function FishMgr:SetCurrentBaitID(BaitID)
    self.BaitID = BaitID or 0
    self:SaveLastFishBaitID()
end


function FishMgr:GetValidBaitID()
    local BaitID , BaitItem = FishVM:FindValidBaitID(self.BaitID)
    self:SetCurrentBaitID(BaitID)
    return BaitID , BaitItem
end

function FishMgr:SetFishBaitItemSelected(BaitID)
    local LastID = self:GetValidBaitID()
    if LastID ~= BaitID then
        FishVM:SetItemUseState(LastID,false)
    end
    self:SetCurrentBaitID(BaitID)
    FishVM:SetItemUseState(BaitID,true)
end

local function ChangeMoveAndTurn(bLock)
    local EActorControllStat = _G.UE.EActorControllStat
    local StateComp = MajorUtil.GetMajorStateComponent()
    if StateComp and bMoveLock ~= bLock then
        bMoveLock = bLock
        StateComp:SetActorControlState(EActorControllStat.CanMove, not bLock, "Fish")
        StateComp:SetActorControlState(EActorControllStat.CanTurn, not bLock, "Fish")
    end
    print("[Fish] LockMove " .. (bLock and "true" or "false"))
end

local function ChangeCalculateVelocityRange(bChange)
    local MajorController = MajorUtil.GetMajorController()
    if MajorController then
        MajorController:SetCalculateVelocityRange(bChange)
    end
    print("[Fish] CalculateVelocityRange " .. (bChange and "true" or "false"))
end

local function ChangeVelocityRangeCheck(Value)
    Value = Value or 2
    local MajorController = MajorUtil.GetMajorController()
    if MajorController then
        MajorController:SetVelocityRangeCheck(Value)
    end
    print("[Fish] RangeCheck " .. tostring(Value))
end

function FishMgr:StartMoveAndTurnChange(Delay, State)
    if self.ControlTimer > 0 then
        TimerMgr:CancelTimer(self.ControlTimer)
    end
    print("[Fish] MoveResetStart Delay: " .. tostring(Delay))
    if Delay > 0 then
        self.ControlTimer = TimerMgr:AddTimer(nil,ChangeMoveAndTurn, Delay, 1, 1, State)
    else
        ChangeMoveAndTurn(State)
    end
    
end

-- function FishMgr:StartChangeVelocityRangeCheck(Delay)
--     if self.ControlTimer > 0 then
--         TimerMgr:CancelTimer(self.ControlTimer)
--     end
--     print("[Fish] RangeCheck Start ")
--     self.ControlTimer = TimerMgr:AddTimer(nil,ChangeVelocityRangeCheck, Delay, 1, 1, InputRangeCheckValue)
--     -- 这里使用self:RegisterTimer似乎会导致逻辑出错，所以需要直接AddTimer
--     -- self.ControlTimer = self:RegisterTimer(ChangeVelocityRangeCheck, Delay, 1, 1, InputRangeCheckValue)
-- end

    --[[
        FISHER_PREPARE = 1,	-- 钓鱼准备期
        FISHER_WAIT = 2,	-- 钓鱼等待期
        FISHER_LIFT_WINDOW = 3,	-- 钓鱼提竿窗口期
        FISHER_AFTER_LIFT = 4,	-- 钓鱼提竿后窗口期
        FISHER_ESCAPE = 5,	-- 钓鱼鱼逃脱期
        FISHER_LIFTING = 6,  -- 钓鱼提竿动作期

        FISHER_AFTER_FISHEND = 996 -- 钓鱼后等待期
        FISHER_LIFT_ANIMEND = 997   --提竿动画完成，离开动画蓝图Hook
        FISHER_DROPCAST = 998  -- 抛竿动画中
        FISHER_LIFTCAST = 999  -- 提竿动画中
        FISHER_LIFTFAILDCAST = 1000 -- 空提动画中
    --]]

-- 增加钓鱼状态下对抛竿/提竿类技能的使用限制，防止出现因为弱网导致技能释放和技能替换出现的问题
-- 抛竿技能组使用的钓鱼状态限制
local FishDropEnableStatusMap = {
    [FishStatus.FISHER_PREPARE] = true,
    [FishStatus.FISHER_AFTER_LIFT] = true,
    [FishStatus.FISHER_ESCAPE] = true,
    [FishStatus.FISHER_LIFT_ANIMEND] = true,
    [FishStatus.FISHER_AFTER_FISHEND] = true
}

-- 提竿技能组使用的钓鱼状态限制
local FishLiftEnableStatusMap = {
    [FishStatus.FISHER_WAIT] = true,
    [FishStatus.FISHER_LIFT_WINDOW] = true
}

function FishMgr:CanUseFishSkill(SkillID)
    local Status = self.CurFishState
    local ActionType = SkillMainCfg:FindValue(SkillID, "ActionType") or 0
    local res = false
    if ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_FISH_DROP then
        res = FishDropEnableStatusMap[Status] or false
    elseif  ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_FISH_LIFT then
        res = FishLiftEnableStatusMap[Status] or false
    elseif  ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_FUNCTIONAL then
        res = FishDropEnableStatusMap[Status] or false
    elseif ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_CHOOSE_BAIT then
        res = true
    end
    return res
end

-- 判定玩家在钓鱼中（抛竿->钓鱼结束），主要限制玩家更换鱼饵
function FishMgr:CanSetFishBait()
    local res = FishLiftEnableStatusMap[self.CurFishState] or false
    return res
end

function FishMgr:OnCastLifeSkill(Params)
    -- FLOG_ERROR("FishMgr:OnCastLifeSkill")
    local SkillID = Params.IntParam1
    --打开钓饵背包技能特殊处理
    if SkillID == FishSKillID.ShowBaitBagSkillID then
        self:ShowFishBaitBagPanel()
        return false
    end

    local Major = MajorUtil.GetMajor()
    if not Major then
        return false
    end

    if not self.InFishArea then
        FLOG_WARNING("[Fish] CastSkill %d Falid because not in FishArea", SkillID)
        return false
    end

    if not self:CanUseFishSkill(SkillID) then
        MsgTipsUtil.ShowTipsByID(FishErrorCode[ClientFishReason.DisableSkill])
        return false
    end

    local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ActorLoc)
    local BaitID = self:GetValidBaitID()
    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    local ActionType = SkillMainCfg:FindValue(SkillID, "ActionType") or 0
    -- 抛竿技能
    if ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_FISH_DROP then
        -- 通用状态检测
        if CommonStateUtil.CheckBehavior(FishActionID, true) == false then
            return false
        end

        -- 抛竿射线检测
        local USkillMgr = _G.UE.USkillMgr
        local RawRotation = Major:GetActorForwardVector() 
        local bNewTrace = USkillMgr.FishSkillNewLineTrace(MajorPos,RawRotation)
        if self.bShowLineTrace then
            USkillMgr.FishSkillLineTraceDebug(MajorPos,RawRotation)
        end
        if bNewTrace == false then
            MsgTipsUtil.ShowTipsByID(FishErrorCode[ClientFishReason.LineTraceFail])
            FLOG_WARNING("[Fish]Fish PhysicalMaterial no match")
            return false
        end
    
        local MoveComp = MajorUtil.GetMajor():GetMovementComponent()
        if MoveComp then
           if MoveComp:IsFalling() then
                -- 在空中时无法抛竿
                return false
           end
        end
    
        if ActorUtil.IsClimbingState(MajorUtil.GetMajorEntityID()) then
            -- 在攀爬状态下无法抛竿
            return false
        end

        -- 以小钓大技能消耗上次钓到的鱼而不是鱼饵，因此需要特殊处理
        if SkillID == FishSKillID.Mooch_1 or SkillID == FishSKillID.Mooch_2 then
            if not self.CanMooch then
                MsgTipsUtil.ShowTipsByID(FishErrorCode[ClientFishReason.FishBaitExhaust])
                return false
            end
        elseif BaitID == 0 then
            MsgTipsUtil.ShowTipsByID(FishErrorCode[ClientFishReason.FishBaitExhaust])
            return false
        end
        -- 背包已满的情况下无法钓鱼
        local LeftBagNum = BagMgr:GetBagLeftNum()
        if LeftBagNum <= 0 then
            MsgTipsUtil.ShowTipsByID(FishErrorCode[ClientFishReason.BagFull])
            return false
        end
        if self.FishEndTimer ~= 0 then
            TimerMgr:CancelTimer(self.FishEndTimer)
            self.FishEndTimer = 0
        end
        AnimComp:SetFishState(0, EFishHuckType.None, SkillID, BaitID, EFishStateType.Fishing)
        self:StartMoveAndTurnChange(0, true)
        ChangeCalculateVelocityRange(true)
        self:SetFishStatus(FishStatus.FISHER_DROPCAST)
        self:OnEnterFishingState()
        self:RefreshFishSkill()
        -- 隐藏寻路引导线
        NaviDecalMgr:SetNavPathHiddenInGame(true)
        NaviDecalMgr:DisableTick(true)
        BuoyMgr:ShowAllBuoys(false)
    -- 提竿技能
    elseif ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_FISH_LIFT then
        if self.CurFishState ~= FishStatus.FISHER_LIFT_WINDOW then
            --不在提竿窗口期提竿，直接结束
            print("[Fish] Press Lift Skill but not Fish Bite windowtime")
            MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftTooEarly])
            self:OnFishFaild()
            return false
        else
            --这里直接干掉Bite Timer，确保C/S在钓鱼流程上一致
            self:ClearBiteTimer()
            AnimComp:SetFishState(self.CurRodType, EFishHuckType.None, SkillID, 0, EFishStateType.Fight)
            self:SetFishStatus(FishStatus.FISHER_LIFTCAST)
            self:RefreshFishSkill()
        end
    end

    local AreaID = self.GimmickAreaID

    Params.ULongParam2 = BaitID
    Params.FloatParam1 = MajorPos.X
    Params.FloatParam2 = MajorPos.Y
    Params.FloatParam3 = MajorPos.Z - Major:GetCapsuleHalfHeight()
    Params.ULongParam3 = AreaID
end

function FishMgr:OnInit()
    self.InFishArea = nil   --当前钓鱼区域
    self.FishDropTimer = 0  --抛竿->咬钩
    self.FishBiteTimer = 0  --咬钩->失败
    self.FishHookTimer = 0  --提竿->提竿动作完成
    self.FishLiftTimer = 0  --提竿->结束
    self.FishEndTimer = 0   --提竿后窗口期->钓鱼后等待期

    self.BaitID = 0 --当前鱼饵ID
    self.AreaID = nil --当前渔场ID
    self.GimmickAreaID = nil -- 当前渔场对应的Gimmick区域ID（服务器需要使用）

    self.CurFishID = 0
    self.CurFishState = FishStatus.FISHER_PREPARE  --当前钓鱼状态
    self.CurFishQuality = nil --当前鱼质量(NQ/HQ)
    self.CurRodType = nil --当前鱼杆种(用于条件判断，鱼咬钩表现)
    self.CurUseSmallCatchBig = 0
    self.CacheLocationCfg = nil
    self.FishEffectVfxID = 0 -- 捕鱼鱼竿端头特效ID

    self.ControlTimer = 0   --移动旋转控制
    self.FishReleaseList = {}   --放生列表

    self.IsFishAnim = false -- 当前是否在钓鱼动作中（正在播放动画）
    self.bSendMsg = false -- 当前渔场变化是否向服务器通知过的标识，目的为优化服务器请求数量
    self.bLost = false -- 是否错过提竿时间，现在钓鱼提竿需要考虑拟饵消耗，需要等待服务器回包，因此用一个参数标记
    self.bShowLineTrace = false -- 钓鱼时射线检测画线开关，默认关闭，可通过GM指令开启(client DebugFishLineTrace)
    self.CanMooch = true -- 当前是否能够使用以小钓大技能（上次钓上的鱼是否还在）
    self.bSitCorrect = false -- 部分情况下为了匹配动作，需要临时调整站坐状态，在此进行标记
    self.bFishGM = false -- 使用GM指令快速钓鱼，需要特殊处理逻辑
    self.bGameEventDynRegister = false -- 部分事件需要动态注册，在此标记，防止断线重连时重复注册
end

function FishMgr:OnBegin()

end

function FishMgr:OnEnd()
    LifeSkillConfig.UnRegisterCastSkillCallback(ProfFisher)
end

function FishMgr:OnShutdown()

end

function FishMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_FISH_DROP_CMD, self.OnSkillFishDrop)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_FISH_LIFT_CMD, self.OnSkillFishLift)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_FISH_LIFT_END, self.OnSkillFishLiftResult)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_FISH_END, self.OnSkillFishEnd)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_REPLACE, self.OnFishSkillListReplace)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMM_STAT, ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS, self.OnNetMsgGetStatStatus)
end

function FishMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
    -- self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    -- 捕鱼buff处理，需要所有玩家处理坐下逻辑
    self:RegisterGameEvent(EventID.AddLifeSkillBuff, self.OnCastLifeBuff)
	self:RegisterGameEvent(EventID.RemoveLifeSkillBuff, self.OnRemoveLifeBuff)
end

function FishMgr:OnRegisterTimer()

end

-- 部分事件仅在捕鱼职业中生效，因此需要在此动态注册
function FishMgr:DynRegisterGameEvent()
    self:RegisterGameEvent(EventID.InputRangeChange, self.OnInputRangeChange)
    self:RegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnBuffRemove) -- 移除buff的通知，只处理主角的buff
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:RegisterGameEvent(EventID.ActorReviveNotify,self.OnGameEventActorReviveNotify) -- 玩家复活时无关UI会被强制销毁，在此监听事件重新显示捕鱼UI
    self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate) -- 监听背包物品更新，目的是监听鱼饵的变化
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnExitWorld)
    self:RegisterGameEvent(EventID.SkillMainPanelShow, self.OnSkillMainPanelShow) -- 处理捕鱼UI和主界面层级关系
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected) -- 捕鱼断线重连处理

    self.bGameEventDynRegister = true
end

function FishMgr:DynUnRegisterGameEvent()
    self:UnRegisterGameEvent(EventID.InputRangeChange, self.OnInputRangeChange)
    self:UnRegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnBuffRemove)
    self:UnRegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:UnRegisterGameEvent(EventID.ActorReviveNotify,self.OnGameEventActorReviveNotify)
    self:UnRegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
    self:UnRegisterGameEvent(EventID.PWorldMapExit, self.OnExitWorld)
    self:UnRegisterGameEvent(EventID.SkillMainPanelShow, self.OnSkillMainPanelShow)
    self:UnRegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected)

    self.bGameEventDynRegister = false
end

function FishMgr:SetFishReleaseList(InList)
    self.FishReleaseList = InList or {}
end

function FishMgr:OnFishSkillListReplace(MsgBody)
    local SkillList = MsgBody.ReplayNotify.SkillList
    SkillLogicMgr:ServerSkillListReplace(SkillList)
end

function FishMgr:OnGameEventVisionEnter(Params)
    local EntityID = Params.ULongParam1
    local StateComp = ActorUtil.GetActorStateComponent(EntityID)
    if StateComp and StateComp:IsInNetState(FishNetStat) then
        --一进视野就在钓鱼
        local FishPlayer = FishPlayerUnit.Get(EntityID, true)
        local bSit = LifeSkillBuffMgr:HasBuff(EntityID, FishBuffID.SitBuffID)
        FishPlayer:SetFishStateFirst(bSit)
    end
end

function FishMgr:OnGameEventVisionLeave(Params)
    local EntityID = Params.ULongParam1
    FishPlayerUnit.Del(EntityID)
end

function FishMgr:PostFishActionEndMsg(EndType)
    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local MsgBody = {}
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_FISH_END
    MsgBody.Cmd = SubMsgID
    local FishEnd = {EndType = EndType}
    MsgBody.FishEnd = FishEnd
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function FishMgr:IsInFishReleaseList(FishID)
    local ResID = FishCfg:FindValue(FishID, "ItemID")
    return self.FishReleaseList[ResID] ~= nil
end

function FishMgr:OnFishLiftAnimFinish(bAsCollections)
    local bRelease = self:IsInFishReleaseList(self.CurFishID)
    self.CanMooch = not bRelease
    --此处向服务器推送提竿动画播放完成
    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local MsgBody = {}
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_FISH_LIFT_END
    MsgBody.Cmd = SubMsgID
    MsgBody.FishLiftEnd = {["ReleaseFish"] = bRelease , ["Collect"] = bAsCollections}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

local function GetSitStatus(EntityID)
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp then
		local PlayerAnimInstance = AnimComp:GetPlayerAnimInstance()
		return PlayerAnimInstance and PlayerAnimInstance.bSit or false
	end
	return false
end                                           

function FishMgr:OnInputRangeChange(Params)
    if self.CurFishState == FishStatus.FISHER_WAIT or self.CurFishState == FishStatus.FISHER_AFTER_LIFT or self.CurFishState == FishStatus.FISHER_AFTER_FISHEND then
        self:ExitFishState()
    end
end

function FishMgr:ExitFishState()
    print("[Fish]移动导致钓鱼流程结束")
    -- 移动时自动站起身
    local bSit = GetSitStatus(MajorUtil.GetMajorEntityID())
    if bSit then
        self:SendMajorSitChange()
    end
    self:OnFishEnd()
end

-- 当杀端时强制通知服务器退出钓鱼状态
function FishMgr:OnEndExitFishState()
    local bSit = GetSitStatus(MajorUtil.GetMajorEntityID())
    if bSit then
        self:SendMajorSitChange()
    end
    self:PostFishActionEndMsg(EndTypeEnum.End)
end

---------------------捕鱼坐相关逻辑-----------------
function FishMgr:SendMajorSitChange()
    if self.CurFishState == FishStatus.INVALID or self.CurFishState == FishStatus.FISHER_PREPARE then
        --此期间不允许切换站坐
        return
    end

    local bSit = not GetSitStatus(MajorUtil.GetMajorEntityID())

    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local MsgBody = {}
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_FISH_LIFT_SIT
    MsgBody.Cmd = SubMsgID
    local FishSit = {Sit = bSit}
    MsgBody.FishSit = FishSit
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function FishMgr:OnCastLifeBuff(BuffInfo)
    local BuffID = BuffInfo.BuffID
    local EntityID = BuffInfo.EntityID
    if BuffID == FishBuffID.SitBuffID then
        self:OnFishPlayerSitChange(EntityID, true)
    elseif BuffID == FishBuffID.IdenticalCastBuffID or BuffID == FishBuffID.SurfaceSlapBuffID then
        -- 这里获取到buff时的提示需要获取到鱼的名称，所以放到钓鱼模块里来做提示，后续最好统一放到buff模块中处理
        -- 只显示玩家本人的
        if not MajorUtil.IsMajor(EntityID) then
            return 
        end
        if self.CurFishID ~= 0 then 
            local FishCfg = FishCfg:FindCfgByKey(self.CurFishID)
            local FishName = FishCfg and FishCfg.Name or ""
            MsgTipsUtil.ShowTipsByID(FishBuffCode[BuffID],nil,FishName)
        end
    end
end

function FishMgr:OnRemoveLifeBuff(BuffInfo)
    local BuffID = BuffInfo.BuffID
    local EntityID = BuffInfo.EntityID
    if BuffID == FishBuffID.SitBuffID then
        self:OnFishPlayerSitChange(EntityID, false)
    end
end

function FishMgr:OnFishPlayerSitChange(EntityID, bSit)
    if MajorUtil.IsMajor(EntityID) and (bSit and (self.CurFishState == FishStatus.INVALID or self.CurFishState == FishStatus.FISHER_PREPARE)) then
        return
    end
    self:DoFishSit(EntityID, bSit)
end

function FishMgr:DoFishSit(EntityID, bSit)
    -- 这里现在改成直接调用接口切换站坐，而不是事件触发，原因是传送时假如玩家坐下则需s要站起，此时主角已被UnInit()，事件的监听被卸载，所以无法触发对应逻辑，所以改成了接口调用
    -- local EventParams = _G.EventMgr:GetEventParams()
    -- EventParams.ULongParam1 = EntityID
    -- EventParams.BoolParam1 = bSit
    -- EventParams.BoolParam2 = false
    -- _G.EventMgr:SendCppEvent(EventID.ActorSit, EventParams)
    local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
    if AnimComp then
        AnimComp:SetActorSit(EntityID, bSit, false, false)
    end
    local AvatarCom = ActorUtil.GetActorAvatarComponent(EntityID)
    if AvatarCom then
        AvatarCom:SetPartHidden(UE.EAvatarPartType.WEAPON_SYSTEM, false, false, false, _G.UE.EDitherReason.Common, false)
    end
end
---------------------捕鱼坐相关逻辑END-----------------

---------------------钓鱼逻辑初始化-----------------

function FishMgr:OnGameEventMajorCreate()
    local ProfID = MajorUtil.GetMajorProfID()
    FLOG_INFO("FishMgr:OnGameEventMajorCreate Init")
    if ProfID and ProfID == ProfFisher then
        --缓存渔场坐标信息
        local CurrMapResID = _G.PWorldMgr:GetCurrMapResID() or 0
        if CurrMapResID == 0 then
            FLOG_ERROR("[Fish] CurrMapResID is 0")
        end
        self.CacheLocationCfg = FishLocationCfg:FindAllCfg(string.format("MapID == %d", CurrMapResID))
        --加载捕鱼专用资产
        ObjectMgr:LoadObjectAsync(FishEffectDataAssetPath, nil, ObjectGCType.Hold)
        -- 打开捕鱼人界面
        local AreaID = self.AreaID
        local GimmickID = self.GimmickAreaID
        if GimmickID and AreaID then 
            self:OnEnterFishArea(AreaID,GimmickID)
        else
            self:OnExitFishArea(0,false)
        end
        LifeSkillConfig.RegisterCastSkillCallback(ProfFisher, self, self.OnCastLifeSkill)
        if self.bGameEventDynRegister == false then
            self:DynRegisterGameEvent()
        end
        self:ShowFishMainPanel()
    else
        if  self.bGameEventDynRegister == true then
            self:DynUnRegisterGameEvent()
        end
        LifeSkillConfig.UnRegisterCastSkillCallback(ProfFisher)
        UIViewMgr:HideView(FishMainPanelViewID, false)
        self.CacheLocationCfg = nil
        --卸载捕鱼专用资产
        ObjectMgr:UnLoadObject(FishEffectDataAssetPath, true)
    end
end

function FishMgr:OnEventMajorProfSwitch()
    FLOG_INFO("FishMgr:OnEventMajorProfSwitch Switch Prof")
    self:OnGameEventMajorCreate()
end

---------------------钓鱼逻辑初始化-----------------

---------------------渔场检测-----------------
--渔场检测逻辑现使用GimmickBox触发，因此Lua中不进行检测，只做事件触发

function FishMgr:OnEnterFishArea(AreaID,GimmickID)
    if self.AreaID ~= AreaID then
        -- AreaID改变则重置通知状态
        self.bSendMsg = false
    end
    self.AreaID = AreaID
    self.GimmickAreaID = GimmickID
    self.InFishArea = true
    local ProfID = MajorUtil.GetMajorProfID()
    if ProfID and ProfID == ProfFisher and self.bSendMsg == false then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        SkillLogicMgr:SetSkillButtonEnable(MajorEntityID, SkillBtnState.EnterFishingArea, nil, function(_, SkillID)
            local bFishSkill = self:IsFishSkill(SkillID)
            if bFishSkill == false then return nil end
            return true
        end)

        FLOG_INFO("[FishMgr]EnterFishArea AreaID = "..AreaID.."GimmickID = "..GimmickID)
    end
    -- 渔场解锁条件修改为进入渔场即解锁，不限定捕鱼人职业，因此这里不进行职业判定
    EventMgr:SendEvent(EventID.EnterFishArea, self.AreaID)
end

-- AreaID 离开的渔场ID，当为0代表为初始化逻辑，实际没有离开渔场，因此不向服务器发送消息
-- bforce 强制向服务器推送消息，由于玩家被销毁时会离开事件，但是不确定是因为传送还是因为主角下线，因此传送时强制推送区别其他情况
function FishMgr:OnExitFishArea(AreaID,bforce)
    -- AreaID改变则重置通知状态
    self.bSendMsg = false
    self.AreaID = nil
    self.GimmickAreaID = nil
    self.InFishArea = false
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local ProfID = MajorUtil.GetMajorProfID()
    if ProfID and ProfID == ProfFisher and self.bSendMsg == false then
        SkillLogicMgr:SetSkillButtonEnable(MajorEntityID, SkillBtnState.EnterFishingArea, nil, function(_, SkillID)
            local bFishSkill = self:IsFishSkill(SkillID)
            if bFishSkill == false then return nil end
            local ActionType = SkillMainCfg:FindValue(SkillID, "ActionType") or 0
            --常态使用类技能始终返回true
            if ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_CHOOSE_BAIT then 
                return true
            end
            return false
        end)

        if AreaID == 0 then
            -- AreaID == 0 表示初始化逻辑，实际没有离开渔场，因此不向服务器发送消息
            return
        end

        -- 由于断线重连和杀端的情况下会因为主角被销毁触发离开渔场区域的事件，因此需要判断主角是否已被销毁
        local MajorActor = MajorUtil.GetMajor()
        if nil == MajorActor then
            return
        end
        local MajorActive = MajorActor:IsActive()

        -- 杀端为了保持服务器钓鱼状态的同步，所以这里需要强制退出钓鱼状态
        if not MajorActive and self:IsInFishState() then
            self:OnEndExitFishState()
        end

        -- 由于传送和杀端/断线重连的情况都会导致主角被销毁，因此传送时bforce强制推送
        if bforce or MajorActive then
            FLOG_INFO("[FishMgr]ExitFishArea AreaID = "..AreaID)
            EventMgr:SendEvent(EventID.ExitFishArea, self.AreaID)

            --通知服务器切换渔场
            local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
            local MsgBody = {}
            local SubMsgID = CS_SUB_CMD.LIFE_SKILL_LEAVE_FISH_LOCATION_CMD
            MsgBody.Cmd = SubMsgID
            GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
            self.bSendMsg = true
        end
    end
end

---------------------渔场检测END-----------------

---------------------钓鱼主流程-----------------

--TODO 动画event
function FishMgr:AnimNotify_OnFishDropEnd(EntityID)
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
    if self.CurFishState == FishStatus.FISHER_DROPCAST then
        self:SetFishStatus(FishStatus.FISHER_WAIT)
        self:RefreshFishSkill()
        ChangeVelocityRangeCheck(InputRangeCheckValue)
    end
end

--服务器下发抛竿协议
function FishMgr:OnSkillFishDrop(Params)

    if Params ~= nil and not MajorUtil.IsMajor(Params.ObjID) then
        FishPlayerUnit.Get(Params.ObjID):OnSkillFishDrop(Params)
        if Params ~= nil then
            local EntityID = Params.ObjID
            if  EntityID ~= nil then
                EventMgr:SendEvent(EventID.FisherManFishing, EntityID)
            end
        end
        return
    end

    _G.UIViewMgr:ShowView(_G.UIViewID.GatherDrugSkillPanel)

    --res: 等待时间
    if self.CurFishState ~= FishStatus.FISHER_DROPCAST and self.CurFishState ~= FishStatus.FISHER_WAIT then
        FLOG_WARNING("[Fish]Case OnSkillFishDrop but CurState not FishDropCast or FishDrop")
        return
    end

    if self.FishLiftTimer ~= 0 then
        TimerMgr:CancelTimer(self.FishLiftTimer)
        self.FishLiftTimer = 0
    end

    local FishID = Params.FishDrop.FishResID
    local AreaID = Params.FishDrop.LocationID
    print("客户端与服务器渔场ID是否匹配: " .. tostring(AreaID == self.AreaID))

    local Stamp = Params.FishDrop.HookedTimestampMS
    local WaitTime = SkillUtil.StampToTime(Stamp)
    if FishID == 0 then
        --钓鱼失败时客户端模拟一个30s的时长`
        WaitTime = 30
    end
    if WaitTime <= 0 then
        --网络延迟导致等待时间不大于0，将直接进入钓鱼结束状态，避免卡流程
        --超过3s的延迟，毁灭吧赶紧的
        local Time = (TimeUtil.GetLocalTimeMS() - TimeUtil.GetServerTimeMS()) / 1000
        FLOG_ERROR("[Fish]网络延迟过高无法执行正常钓鱼流程，请验证本地时间与服务器时间是否一致，延迟：".. Time .."s")
        self:OnFishFaild()
        return
    end

    self:ClearData()
    self.CurFishID = FishID
    print("[Fish]抛竿成功")
    EventMgr:SendEvent(EventID.FishDrop, {BiteTime = WaitTime})
    if FishID <= 0 then
        --等3s播收杆动作
        self.FishDropTimer = self:RegisterTimer(self.PostFishActionEndMsg, 3, 1, 1, EndTypeEnum.Wait)
        return
    end

    self.FishDropTimer = self:RegisterTimer(self.OnFishBite, WaitTime, 1, 1)
end

--鱼咬钩
function FishMgr:OnFishBite()
    self.FishDropTimer = 0
    self.CurRodType = FishCfg:FindValue(self.CurFishID, "RodType")
    --根据鱼ID播放咬钩动画
    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    if AnimComp then
        AnimComp:SetFishState(self.CurRodType, EFishHuckType.None, 0, 0, EFishStateType.Bite)
    end
    local WindowTime = FishBiteWindowTime    --窗口期时间
    self:SetFishStatus(FishStatus.FISHER_LIFT_WINDOW)
    self:RefreshFishSkill()

    -- _G.EventMgr:SendEvent(EventID.FishBite)

    self.FishBiteTimer = self:RegisterTimer(self.OnFishLost, WindowTime, 1, 1)

    self:ShowBiteEffect(self.CurRodType)
    ChangeVelocityRangeCheck()
    print("[Fish] fish bite")
end

--服务器下发提竿协议
function FishMgr:OnSkillFishLift(Params)
    if not MajorUtil.IsMajor(Params.ObjID) then
        FishPlayerUnit.Get(Params.ObjID):OnSkillFishLift(Params)
        return
    end
    -- 使用GM指令快速钓鱼逻辑
    if self.bFishGM then
        self:OnGetFishFastGMNetMsg(Params)
        return
    end
    --res：是否成功
    if self.CurFishState ~= FishStatus.FISHER_LIFTCAST then
        FLOG_WARNING("[Fish]Case OnSkillFishLift but CurState not BeforeEnd")
        self:OnFishFaild()
        return
    end

    local FishID = Params.FishLift.Fish.ResID
    local FishCount = Params.FishLift.Fish.Count
    local Quality = Params.FishLift.Fish.Quality
    local FishSize = Params.FishLift.Fish.Size or 0
    local FishValue = Params.FishLift.Fish.CollectValue or 0
    local bSuccess = Params.FishLift.Result == ProtoCS.LiftResult.LiftResultSuccess

    print("[Fish] " .. _G.table_to_string(Params.FishLift))
    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    if not bSuccess then
        --提竿失败，根据情况播放提示，失败提示延迟弹出
        self:RegisterTimer(self.ShowFishLiftFailTips,LiftFailEndTime,1,1,Params)
        self:OnFishLiftFaild()
        return
    end
    -- 当RodType == 3时，此时的提竿动作时是站起的，因此需要修正此时的客户端站坐状态
    if self.CurRodType == 3  then
        local bSit = GetSitStatus(Params.ObjID)
        if bSit then
            self:DoFishSit(Params.ObjID,false)
            self.bSitCorrect = true
        end
    end
    AnimComp:SetFishState(self.CurRodType, Quality + 1, 0, 0, EFishStateType.Hook)
    self.FishCount = FishCount
    self.FishSize = FishSize
    self.FishValue = FishValue
    self.CurFishQuality = Quality
    self:SetFishStatus(FishStatus.FISHER_LIFTING)
    self:RefreshFishSkill()
    local EntityID = MajorUtil.GetMajorEntityID()
    self.FishHookTimer = self:RegisterTimer(self.AnimNotify_OnFishHookEnd, HookEndTime, 1, 1,EntityID)

    EventMgr:SendEvent(EventID.FishLiftStart)
end

function FishMgr:AnimNotify_OnFishFightStart(EntityID)
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
    self:ShowFightSoundEffect(self.CurRodType, self.CurFishQuality)
end

function FishMgr:AnimNotify_OnFishFightEnd(EntityID)
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
    self:ShowFightEffect(self.CurFishQuality or -1)
end

function FishMgr:AnimNotify_OnFishHookEnd(EntityID)
    if not MajorUtil.IsMajor(EntityID) then
        FishPlayerUnit.Get(EntityID):AnimNotify_OnFishHookEnd(EntityID)
        return
    end
    if self.CurFishState == FishStatus.FISHER_LIFTING then
        -- 提竿成功表现
        if self.FishHookTimer > 0 then
            TimerMgr:CancelTimer(self.FishHookTimer)
            self.FishHookTimer = 0
        end
        self:SetFishStatus(FishStatus.FISHER_LIFT_ANIMEND)
        local FishValue = self.FishValue
        local CollectionsID = FishCfg:FindValue(self.CurFishID, "CollectItemID")
        if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCollection) and CollectionsID ~= 0 then
            UIViewMgr:ShowView(UIViewID.FishRarefiedTipsPanel,{FishValue = FishValue, CollectItemID = CollectionsID})
        else
            self:OnFishLiftAnimFinish(false)
        end
        -- 站坐状态修正还原
        if self.bSitCorrect then
            self:DoFishSit(EntityID,true)
            self.bSitCorrect = false
        end
        -- 动画状态还原，防止出现异常情况
        self:OnAinmHookFinish()
    end
end

function FishMgr:OnSkillFishLiftResult(Params)
    if Params.ObjID ~= 0 and not MajorUtil.IsMajor(Params.ObjID) then
        FishPlayerUnit.Get(Params.ObjID):OnSkillFishLiftResult(Params)
        return
    end

    if self.CurFishState ~= FishStatus.FISHER_LIFT_ANIMEND then
        print("[Fish] FishLiftResult state not in FishLift")
        return
    end
    ChangeVelocityRangeCheck(InputRangeCheckValue)

    local FishID = self.CurFishID
    self.CurUseSmallCatchBig = FishCfg:FindValue(FishID, "BaitID") ~= 0 and 1 or 0
    self:SetFishStatus(FishStatus.FISHER_AFTER_LIFT)
    self.FishEndTimer = self:RegisterTimer(self.OnAfterFishEnd,AfterLiftTime,1,1)
    self:RefreshFishSkill()
    local FishCount = self.FishCount
    local FishSize = self.FishSize
    local FishValue = self.FishValue
    local FishTipParams = {FishID = FishID, FishCount = FishCount, FishSize = FishSize, FishValue = FishValue}
    EventMgr:SendEvent(EventID.FishLift, FishTipParams)
    self:ShowPopFishSoundEffect(self.CurFishQuality)
    AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_atma.Play_SE_UI_SE_UI_atma")
    if Params.ReleaseFish ~= nil then
        self.CanMooch = not Params.ReleaseFish
    end
    print("[Fish] Fish Lift Result, show fish tips")
end

function FishMgr:OnSkillFishEnd(Params)
    if nil == Params.ObjID then
        FLOG_ERROR("[Fish]OnSkillFishEnd():FishEnd Msg ObjID is nil")
        return
    end
    if not MajorUtil.IsMajor(Params.ObjID) then
        FishPlayerUnit.Get(Params.ObjID):OnSkillFishEnd(Params)
        return
    elseif Params.FishEnd.EndType == EndTypeEnum.Wait then 
        if Params.FishEnd.FailReason == NoFishReason.NoFishReason_Invalid and self.bLost then
            local ConsumeLure = Params.FishEnd.ConsumeLure
            if ConsumeLure then
                local BaitID = self:GetCurrentBaitID()
                local BaitName = FishBaitCfg:FindValue(BaitID, "Name")
                MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftTooLateConsumeBait],nil,BaitName)
            else
                MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftTooLate])
            end
            self.bLost = false
        elseif Params.FishEnd.FailReason ~= NoFishReason.NoFishReason_Invalid and self.CurFishState ~= FishStatus.FISHER_PREPARE then
            self:OnDropFaild(Params.FishEnd.FailReason)
        end
    end
end

function FishMgr:OnDropFaild(Reason)
    --为保证抛竿失败时，错误提示、失败动作、技能替换同时发生，将流程写在这里
    --服务器错误码
    MsgTipsUtil.ShowTipsByID(FishErrorCode[Reason])
    self:OnFishFaild(true)
end

function FishMgr:OnFishLiftFaild()
    self:OnFishFaild()
end

function FishMgr:OnFishFaild(NoPost)
    if self.CurFishState ~= FishStatus.FISHER_PREPARE then
        if NoPost ~= true then
            self:PostFishActionEndMsg(EndTypeEnum.Wait)
        end
        self:ClearTimer()
        self:ClearData()
        EventMgr:SendEvent(EventID.FishEnd,false)
    end
    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    if AnimComp then
        AnimComp:SetFishState(0, 0, 0, 0, EFishStateType.HookFail)
    end
    ChangeVelocityRangeCheck(InputRangeCheckValue)
    -- 空提的时候需要屏蔽移动响应
    self:SetFishStatus(FishStatus.FISHER_LIFTFAILDCAST)
    self:RefreshFishSkill()
end

-- 提竿失败动画播放结束后还原动画状态与移动响应
function FishMgr:AnimNotify_OnFishHookFailEnd(EntityID)
    if not MajorUtil.IsMajor(EntityID) or self.CurFishState ~= FishStatus.FISHER_LIFTFAILDCAST then
        return
    end
    self:SetFishStatus(FishStatus.FISHER_AFTER_LIFT)
    self.FishEndTimer = self:RegisterTimer(self.OnAfterFishEnd,AfterLiftTime,1,1)
    -- 动画状态还原，防止出现异常情况
    self:OnAinmHookFinish()
    self:RefreshFishSkill()
end

--未提竿
function FishMgr:OnFishLost()
    self.CurFishState = FishStatus.FISHER_ESCAPE
    self.bLost = true
    self:OnFishFaild()
end

function FishMgr:OnFishEnd()
    if self.CurFishState ~= FishStatus.FISHER_PREPARE then
        self:PostFishActionEndMsg(EndTypeEnum.End)
        self:ClearTimer()
        self:ClearData()
        EventMgr:SendEvent(EventID.FishEnd,true)
    end
    if self.FishEndTimer ~= 0 then
        TimerMgr:CancelTimer(self.FishEndTimer)
        self.FishEndTimer = 0
    end
    self:SetFishStatus(FishStatus.FISHER_PREPARE)
    self:OnExitFishingState()
    self:RefreshFishSkill()
    print("[Fish] 钓鱼流程结束")
    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    if AnimComp then
        AnimComp:SetFishState(0, 0, 0, 0, EFishStateType.None)
    end
    local AvatarCom = MajorUtil.GetMajorAvatarComponent()
    if AvatarCom then
        AvatarCom:TakeOffAvatarPart(UE.EAvatarPartType.WEAPON_SYSTEM, true)
    end
    self:StartMoveAndTurnChange(EndActionTime, false)
    ChangeCalculateVelocityRange(false)
    ChangeVelocityRangeCheck()
    -- 重新显示寻路引导线
    NaviDecalMgr:SetNavPathHiddenInGame(false)
    NaviDecalMgr:DisableTick(false)
    BuoyMgr:ShowAllBuoys(true)
end

-- 提竿结束，动画状态机设置防止因状态不对导致动画重复播放
function FishMgr:OnAinmHookFinish()
    local AnimComp = MajorUtil.GetMajorAnimationComponent()
    if AnimComp then
        AnimComp:SetFishState(0, 0, 0, 0, EFishStateType.HookResult)
    end
end

-- 钓鱼后等待期提竿窗口期结束后，部分技能不可用
function FishMgr:OnAfterFishEnd()
    self:SetFishStatus(FishStatus.FISHER_AFTER_FISHEND)
    self:RefreshFishSkill()

    self.FishEndTimer = 0
end

function FishMgr:ClearData()
    self.CurFishID = 0
    self.CurRodType = nil
    self.CurFishQuality = nil
    self.FishCount = 0
    self.FishSize = 0
    self.FishValue = 0
end

function FishMgr:ClearTimer()
    TimerMgr:CancelTimer(self.FishDropTimer)
    self.FishDropTimer = 0
    TimerMgr:CancelTimer(self.FishBiteTimer)
    self.FishBiteTimer = 0
    TimerMgr:CancelTimer(self.FishLiftTimer)
    self.FishLiftTimer = 0
    TimerMgr:CancelTimer(self.FishHookTimer)
    self.FishHookTimer = 0
    TimerMgr:CancelTimer(self.FishEndTimer)
    self.FishEndTimer = 0
end

function FishMgr:ClearBiteTimer()
    if self.FishBiteTimer ~= 0 then
        TimerMgr:CancelTimer(self.FishBiteTimer)
        self.FishBiteTimer = 0
    end
end

local function IsNotFishStatus(Status)
    return Status == FishStatus.FISHER_PREPARE or Status == FishStatus.INVALID
end

function FishMgr:SetFishStatus(Status)
    print("[Fish] FishStatus " .. tostring(Status))
    if self.CurFishState ~= Status then
        if IsNotFishStatus(Status) then
            EventMgr:SendEvent(EventID.ExitFishStatus, Status)
            EventMgr:SendEvent(EventID.SwitchPeacePanel, 5)
        elseif IsNotFishStatus(self.CurFishState) and Status == FishStatus.FISHER_DROPCAST then
            EventMgr:SendEvent(EventID.EnterFishStatus, Status)
            EventMgr:SendEvent(EventID.SwitchFightPanel)
        end
        self.CurFishState = Status
    end
end

---------------------钓鱼主流程END-----------------
---
---------------------捕鱼相关特效音效逻辑-----------------
function FishMgr:ShowEffectVfx(VfxPath, OffsetTransform)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local Me = ActorUtil.GetActorByEntityID(MajorEntityID)
    local VfxParameter = FVfxParameter()
    local VfxRequireData = VfxParameter.VfxRequireData
    VfxRequireData.EffectPath = VfxPath
    VfxRequireData.VfxTransform = Me:FGetActorTransform()
    --VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_Fisher
    VfxRequireData.bAlwaysSpawn = true
    if OffsetTransform then
        VfxParameter.OffsetTransform = OffsetTransform
    end
    VfxParameter.LODMethod = _G.UE.ParticleSystemLODMethod.PARTICLESYSTEMLODMETHOD_ActivateAutomatic
    VfxParameter.LODLevel = EffectUtil.GetMajorEffectLOD()
    VfxParameter:SetCaster(Me, 0, 0, 0)
    EffectUtil.PlayVfx(VfxParameter)
end

function FishMgr:ShowBiteEffect(RodType)
    local FishEffectDA = ObjectMgr:GetObject(FishEffectDataAssetPath)
    if FishEffectDA == nil then
        return
    end
    local ZOffset = -50
    local EffectPath = FishEffectDA:GetBiteEffect(RodType)

    self:ShowEffectVfx(EffectPath)

    local bExist, BiteSound1, BiteSound2 = FishEffectDA:GetBiteSound(RodType, "", "")
    -- 咬杆音效只和目前RodType有关，Sound1和Sound2目前是一样的
    if bExist then
        local AudioMgr = UAudioMgr:Get()
        local Me = MajorUtil.GetMajor()
        AudioMgr:LoadAndPostEvent(BiteSound1, Me, false)
    end
end

function FishMgr:ShowFightSoundEffect(RodType, Quality)
    local FishEffectDA = ObjectMgr:GetObject(FishEffectDataAssetPath)
    if FishEffectDA == nil then
        return
    end
    local bHQ = not (Quality == 0)
    local SoundEvent = FishEffectDA:GetFightSound(RodType, bHQ)
    local AudioMgr = UAudioMgr:Get()
    AudioMgr:LoadAndPostEvent(SoundEvent, MajorUtil.GetMajor(), false)
end

function FishMgr:ShowFightEffect(Quality)
    local FishEffectDA = ObjectMgr:GetObject(FishEffectDataAssetPath)
    if FishEffectDA == nil then
        return
    end

    if Quality ~= -1 then
        local EffectPath = FishEffectDA:GetQualityEffect(Quality)
        self:ShowEffectVfx(EffectPath)
    end
end

function FishMgr:ShowPopFishSoundEffect(Quality)
    local FishEffectDA = ObjectMgr:GetObject(FishEffectDataAssetPath)
    if FishEffectDA == nil then
        return
    end
    local bHQ = not (Quality == 0)
    local SoundEvent = FishEffectDA:GetPopFishSoundEffect(bHQ)
    local AudioMgr = UAudioMgr:Get()
    AudioMgr:LoadAndPostEvent(SoundEvent, MajorUtil.GetMajor(), false)
end

local AttachPointType_MainWeapon = _G.UE.EVFXAttachPointType.AttachPointType_MainWeapon
local FishEquipmentPosKey = _G.UE.EAvatarPartType.EQUIP_MAIN_FISH
local EVFXEID = _G.UE.EVFXEID.EID_W_EDGE_END

function FishMgr:ShowIsFishingEffect()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local ActorAvatarCmp = ActorUtil.GetActorAvatarComponent(MajorEntityID)
    if not ActorAvatarCmp then
        return 
    end

    local Me = ActorUtil.GetActorByEntityID(MajorEntityID)
    if not Me then
        return 
    end

    local FishEffectDA = ObjectMgr:GetObject(FishEffectDataAssetPath)
    if FishEffectDA == nil then
        return
    end
    local FishingEffectPath = FishEffectDA:GetIsFishingEffect()
    local VfxParameter = _G.UE.FVfxParameter()
    
    VfxParameter.VfxRequireData.EffectPath = FishingEffectPath
    local Tranform = Me:GetTransform()
    VfxParameter.VfxRequireData.VfxTransform = Tranform
    VfxParameter:SetCaster(Me, 0, AttachPointType_MainWeapon, 0)
    local EffectID = EffectUtil.PlayVfx(VfxParameter)
    return EffectID
end

function FishMgr:StopFishingEffect()
    EffectUtil.StopVfx(self.FishEffectVfxID)
    self.FishEffectVfxID = 0
end
---------------------捕鱼相关特效音效逻辑END-----------------

---------------------钓鱼状态改变/技能替换-----------------

function FishMgr:RefreshFishSkill()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    SkillLogicMgr:SetSkillButtonEnable(MajorEntityID, SkillBtnState.FishState, self, self.FishSkillValid)
end

function FishMgr:ChangeCurrentFishQuality(Quality)
    if self.CurFishQuality ~= Quality then
        self.CurFishQuality = Quality
    end
end

local function SignCompute(CompareA, CompareB, Sign)
    if CompareA == nil or CompareB == nil or Sign == nil then
        return false
    end
    local SignEnum = ProtoRes.condition_sign
    if Sign == SignEnum.CONDITION_SIGN_NULL then
        return true
    elseif Sign == SignEnum.CONDITION_SIGN_EQ then
        return CompareA == CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_LT then
        return CompareA < CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_LE then
        return CompareA <= CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_GT then
        return CompareA > CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_GE then
        return CompareA >= CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_NE then
        return CompareA ~= CompareB
    end

    return false
end

-- 查找渔场的鱼类列表内是否存在可以被该鱼饵通过以小钓大钓上的鱼
local function CanMoochInArea(AreaID,BaitID)
    local MoochList = FishBaitCfg:FindValue(BaitID,"MoochFishID")
    local FishList = FishLocationCfg:FindValue(AreaID,"FishID")
    for _, value in pairs(MoochList) do
        if table.find_item(FishList,value) then
            return true
        end
    end
    return false
end

local function FishSkillCondition(Executor, _, ConditionID)
    local Cfg = LifeSkillConditionCfg:FindCfgByKey(ConditionID)
    if Cfg == nil or Executor == nil then
        return false
    end
    local Condition = ProtoRes.lifeskill_condition_type

    local Type = Cfg.Type
    local Param1 = Cfg.Param1
    local Param2 = Cfg.Param2
    local Sign = Cfg.Sign

    if Type == Condition.LIFESKILL_CONDITION_INVALID then

    elseif Type == Condition.LIFESKILL_CONDITION_FISHING_STATUS then
        local CurState = Executor.CurFishState
        return SignCompute(CurState, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_ATTR then
        local AttrValue = MajorUtil.GetMajorAttributeComponent():GetAttrValue(Param1)
        return SignCompute(AttrValue, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_HARVEST_QUALITY then
        local Quality = Executor.CurFishQuality
        return SignCompute(Quality, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_EFFECT_EXIST then
        local bContainBuff = LifeSkillBuffMgr:IsMajorContainBuff(Param1)
        local ContainBuffInt = bContainBuff and 1 or 0
        return Param2 == ContainBuffInt
    elseif Type == Condition.LIFESKILL_CONDITION_FISH_CONFIG then
        local FishID = Executor.CurFishID
        local Property = nil
        if Param1 == 0 then --鱼杆
            Property = FishCfg:FindValue(FishID, "RodType")
            return SignCompute(Property, Param2, Sign)
        elseif Param1 == 1 then --鱼饵ID(判断该鱼是否可以以小钓大)
            Property = FishCfg:FindValue(FishID, "BaitID")
            local AreaID = Executor.AreaID
            return SignCompute(Property, Param2, Sign) and CanMoochInArea(AreaID,Property)
        end
    end

    return true
end

function FishMgr:FishSkillValid(_, SkillID)
    local bFishSkill = self:IsFishSkill(SkillID)
    if bFishSkill == false then
        return nil
    end

    -- 策划表配置条件判定
    local ConditionStr = SkillMainCfg:FindValue(SkillID, "LifeSkillCondition")
    local Result = RPNGenerator:ExecuteRPNBoolExpression(ConditionStr, self, nil, FishSkillCondition)

    -- (客户端)钓鱼状态条件判定
    local StateRes = self:CanUseFishSkill(SkillID)
    return (Result and StateRes)
end

-- 进入钓鱼状态(开始抛竿)
function FishMgr:OnEnterFishingState()
    -- 捕鱼坐按钮显隐
    self:ShowFishBtnSit(true)

    -- 相机最小视距设置
    local Major = MajorUtil.GetMajor()
    if nil ~= Major then
        local Camera = Major:GetCameraControllComponent()
        Camera:SetMinCameraDistance(MinCameraDis)
    end

    -- 解除自动移动
    _G.UE.UActorManager.Get():SetVirtualJoystickIsSprintLocked(false)

    -- 通用状态进入钓鱼状态
    CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_FISH, true)

    local EntityID = MajorUtil.GetMajorEntityID()
    EventMgr:SendEvent(EventID.FisherManFishing, EntityID)

    -- 屏蔽部分按钮
    MainPanelVM:SetEmotionVisible(false)
    MainPanelVM:SetPhotoVisible(false)
    MountVM:SetMountCallBtnVisible(false)
    
    -- 鱼竿端头播放特效
    if self.FishEffectVfxID == 0 then
        self.FishEffectVfxID = self:ShowIsFishingEffect()
    end
end

-- 退出钓鱼状态(移动触发)
function FishMgr:OnExitFishingState()
    self:ShowFishBtnSit(false)

    local Major = MajorUtil.GetMajor()
    if nil ~= Major then
        local Camera = Major:GetCameraControllComponent()
        local Values = SettingsCfg:FindValue(ViewDisSettingID,"Value")
        local MinViewDis = tonumber(Values[3])
        Camera:SetMinCameraDistance(MinViewDis)
    end

    CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_FISH, false)

    MainPanelVM:SetEmotionVisible(true)
    MainPanelVM:SetPhotoVisible(true)
    MountVM:SetMountCallBtnVisible(true)

    if self.FishEffectVfxID ~= 0 then
        self:StopFishingEffect()
    end
end

---------------------钓鱼状态改变/技能替换END-----------------

---------------------钓鱼相关接口-----------------

function FishMgr:IsFishSkill(SkillID)
    if SkillID ~= nil and SkillID > 0 then
        local SkillFirstClass = SkillMainCfg:FindValue(SkillID, "SkillFirstClass")
        local SkillSecondClass = SkillMainCfg:FindValue(SkillID, "Prof")
        if SkillFirstClass == ProtoRes.skill_first_class.LIFE_SKILL and SkillSecondClass == ProtoCommon.prof_type.PROF_TYPE_FISHER then
            return true
        end
    end
    return false
end

function FishMgr:IsInFishArea()
    return self.InFishArea or self.AreaID ~= nil
end

-- 目前只有捕鱼技能初始化使用
function FishMgr:FishSkillEnableStateInit(SkillID)
    local ActionType = SkillMainCfg:FindValue(SkillID, "ActionType") or 0
    -- 选饵技能不在渔场内也可以使用
    if ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_CHOOSE_BAIT then 
        return true
    end
    return self:IsInFishArea()
end

function FishMgr:GetFishData()
    --鱼ID、竿种、质量(NQ/HQ)、数量、尺寸
    return {ID = self.CurFishID, RodType = self.CurRodType, Quality = self.CurFishQuality, Count = self.FishCount, Size = self.FishSize}
end

function FishMgr:GetFishQuality()
    return self.CurFishQuality
end
---------------------钓鱼相关接口END-----------------

---------------------GM钓鱼相关接口-----------------

-- 获取当前区域ID(钓鱼GM使用)
function FishMgr:GetFishAreaID()
    return self.GimmickAreaID
end

-- GM快速钓鱼客户端逻辑处理
function FishMgr:SetFishFastState()
    self.bFishGM = true
end

function FishMgr:OnGetFishFastGMNetMsg(Params)
    self.FishID = Params.FishLift.Fish.ResID
    self.FishCount = Params.FishLift.Fish.Count
    self.CurFishQuality = Params.FishLift.Fish.Quality
    self.FishSize = Params.FishLift.Fish.Size or 0
    self.FishValue = Params.FishLift.Fish.CollectValue or 0
    local FishTipParams = {FishID = self.FishID, FishCount = self.FishCount, FishSize = self.FishSize, FishValue = self.FishValue}
    EventMgr:SendEvent(EventID.FishLift, FishTipParams)
    self:ShowPopFishSoundEffect(self.CurFishQuality)
    AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_atma.Play_SE_UI_SE_UI_atma")
    self.bFishGM = false
end

---------------------GM钓鱼相关接口END-----------------

-- 打开鱼饵界面
function FishMgr:ShowFishBaitBagPanel()
    FishVM:UpdateBaitItemVM()
	local BaitID, BaitItem = self:GetValidBaitID()
    local BaitNum = 0
    if BaitItem then
        BaitNum = BaitItem.Num
    end
	-- local HaveId = false
	-- if BaitID ~= 0 then
	-- 	HaveId = true
	-- end
	UIViewMgr:ShowView(UIViewID.FishBiteBagPanel,{BaitID = BaitID, Num = BaitNum})
end

--打开捕鱼界面MainUI
function FishMgr:ShowFishMainPanel()
    local AreaID = self.AreaID
    --为了确保交互，渔场UI必须在MainUI之上
    if UIViewMgr:IsViewVisible(FishMainPanelViewID) == false then
        UIViewMgr:ShowView(FishMainPanelViewID,{AreaID = AreaID})
    else
        -- MainUI存在重新show的情况会导致MainUI显示在捕鱼UI之上，因此在这里调整层级确保捕鱼UI在MainUI之上
        UIViewMgr:ChangeLayer(FishMainPanelViewID,UILayer.Low)
    end
end

--捕鱼专属技能捕鱼坐按钮显隐
function FishMgr:ShowFishBtnSit(bShow)
    if UIViewMgr:IsViewVisible(FishMainPanelViewID) == true then
        UIViewMgr:FindView(FishMainPanelViewID):ChangeBtnSitShowState(bShow)
    end
end

function FishMgr:OnExitWorld()
    -- 由于钓鱼时存在传送的可能性，因此在此先强制退出钓鱼状态，解决钓鱼状态下切场景无法正常退出钓鱼的情况
    -- 捕鱼坐的动作由buff的添加和移除触发，离开地图时LifeSkillBuffMgr会清理所有的buff，导致无法处理服务器移除buff的回包，因此由客户端自行处理动作切换
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local bSit = GetSitStatus(MajorEntityID)
    if bSit then
        self:SendMajorSitChange()
        self:DoFishSit(MajorEntityID,false)
    end
    self:OnFishEnd()
end

-- 由于捕鱼UI和MainUI属于同一层级，但同时捕鱼UI有需要显示在MainUI上层，因此当MainUI重新创建时，需要调整捕鱼UI层级使其在MainUI之上
function FishMgr:OnSkillMainPanelShow(Params)
    local ProfID = MajorUtil.GetMajorProfID()
    if ProfID and ProfID == ProfFisher then
        self:ShowFishMainPanel()
    end
end

-- 保存上次使用的鱼饵ID到本地
function FishMgr:SaveLastFishBaitID()
    local BaitID = self.BaitID
    if BaitID ~= 0 then
        local SaveKeyParam = SaveKey.SavedFishBaitID
        SaveMgr.SetInt(SaveKeyParam,BaitID,true)
    end
end


-- 处理钓鱼职业升级的情况
-- 目前升级对钓鱼的流程本身没有影响，因此暂不处理
function FishMgr:OnMajorLevelUpdate(Params)

end

-- 断线重连处理
function FishMgr:OnNetworkReconnected(Params)
    if nil == Params then
        return
    end

    local bRelay = Params and Params.bRelay
    if bRelay then
        -- 闪断情况
        FLOG_INFO("FishMgr:OnNetworkReconnected not Reconnect")
        -- 闪断情况下进行捕鱼状态恢复
        self:FishStateRecovery()
    else
        -- 非闪断情况
        FLOG_INFO("FishMgr:OnNetworkReconnected Reconnect")
        -- 触发断线重连后退出钓鱼状态
        self:ExitFishState()
    end
    -- 触发断线重连后退出钓鱼状态
    self:ShowFishMainPanel()
end

-- 主角移除buff通知，现在前后台BUFF移除是分开计算的，因此客户端单独计算
function FishMgr:OnBuffRemove(BuffInfo)
    local BuffID = BuffInfo.BuffID
    local Cfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if nil ~= Cfg then
        local NoticeID = Cfg.RemoveNotice
        if nil ~= NoticeID then
            MsgTipsUtil.ShowTipsByID(NoticeID)

        end
    end
end

-- 主角复活时，捕鱼职业的情况下，重新显示捕鱼UI
function FishMgr:OnGameEventActorReviveNotify(Params)
    if nil == Params then
		return
	end

    local EntityID = Params.ULongParam1
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end

    self:ShowFishMainPanel()
end

-- 主角死亡时强制退出钓鱼状态
function FishMgr:OnGameEventMajorDead()
    self:ExitFishState()
end

--钓鱼失败提示延迟弹出
function FishMgr:ShowFishLiftFailTips(Params)
    if Params.FishLift.Result == ProtoCS.LiftResult.LiftResultFail1 then
        if Params.FishLift.ConsumeLure then
            local BaitID = self:GetCurrentBaitID()
            local BaitName = FishBaitCfg:FindValue(BaitID, "Name")
            MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftTooLateConsumeBait],nil,BaitName)
        else
            MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftTooLate])
        end
    elseif Params.FishLift.Result == ProtoCS.LiftResult.LiftResultFail2 then
        if Params.FishLift.ConsumeLure then
            local BaitID = self:GetCurrentBaitID()
            local BaitName = FishBaitCfg:FindValue(BaitID, "Name")
            MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftLineBrokenConsumeBait],nil,BaitName)
        else
            MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftLineBroken])
        end
    elseif Params.FishLift.Result == ProtoCS.LiftResult.LiftResultFailGathering then
        MsgTipsUtil.ShowTipsByID(FishErrorCode[FishLiftFailReason.LiftNoGathering])
    end
end

-- 抛竿时射线检测画线显示/关闭
function FishMgr:ShowDebugLineTarce()
    self.bShowLineTrace =  not self.bShowLineTrace
end

-- 监听鱼饵物品的更新,主要目的是处理鱼饵耗尽
function FishMgr:OnBagUpdate(Params)
    for _, v in ipairs(Params) do
        if v.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_DELETE then
            local Item = v.PstItem
            if self.BaitID ~= 0 then
                local Cfg = FishBaitCfg:FindCfgByKey(self.BaitID)
                local BaitResID = Cfg.ItemID
                local FishResID = FishCfg:FindValue(self.CurFishID, "ItemID")
                if BaitResID == Item.ResID then
                    MsgTipsUtil.ShowTipsByID(FishErrorCode[ClientFishReason.FishBaitExhaust])
                elseif FishResID == Item.ResID then
                    -- 用于以小钓大的鱼已经被消耗，无法使用
                    self.CanMooch = false
                end
            end
        end
    end
end

-- 从鱼饵背包界面跳转至商店后需求返回，目前关闭商店界面会隐藏其他UI，因此在这里监听关闭商店的事件
function FishMgr:OnRegisterReturnToBaitbag()
    self:RegisterGameEvent(EventID.ShopPlayOutAni,self.ReturnToFishBaitBag)
end

-- 退出商店自动打开鱼饵背包
function FishMgr:ReturnToFishBaitBag()
    local ProfID = MajorUtil.GetMajorProfID()
    if ProfID and ProfID == ProfFisher then
        self:ShowFishBaitBagPanel()
    end
    self:UnRegisterGameEvent(EventID.ShopPlayOutAni,self.ReturnToFishBaitBag)
end

    --[[
        FISHER_PREPARE = 1,	-- 钓鱼准备期
        FISHER_WAIT = 2,	-- 钓鱼等待期
        FISHER_LIFT_WINDOW = 3,	-- 钓鱼提竿窗口期
        FISHER_AFTER_LIFT = 4,	-- 钓鱼提竿后窗口期
        FISHER_ESCAPE = 5,	-- 钓鱼鱼逃脱期
        FISHER_LIFTING = 6,  -- 钓鱼提竿动作期

        FISHER_AFTER_FISHEND = 996 -- 钓鱼后等待期
        FISHER_LIFT_ANIMEND = 997   --提竿动画完成，离开动画蓝图Hook
        FISHER_DROPCAST = 998  -- 抛竿动画中
        FISHER_LIFTCAST = 999  -- 提竿动画中
        FISHER_LIFTFAILDCAST = 1000 -- 空提动画中
    --]]

-- 断线重连后捕鱼状态恢复 
function FishMgr:FishStateRecovery()
    local FishState = self.CurFishState
    FLOG_INFO("[FishMgr]:FishStateRecovery CurFishState = "..FishState)
    local AnimComp = MajorUtil.GetMajorAnimationComponent()

    if FishState == FishStatus.FISHER_PREPARE then

    elseif FishState == FishStatus.FISHER_WAIT then

    elseif FishState == FishStatus.FISHER_LIFT_WINDOW then

    elseif FishState == FishStatus.FISHER_AFTER_LIFT then
        if AnimComp then
            AnimComp:SetFishState(0, 0, 0, 0, EFishStateType.HookResult)
        end
    end
end

-- 登录时同步服务器钓鱼状态
function FishMgr:OnNetMsgGetStatStatus(MsgBody)
    if nil == MsgBody or nil == MsgBody.Status then
        return
    end
    local StatusRsp = MsgBody.Status
    local IsFishing = StatusRsp.StatBits & (1 << ProtoCommon.CommStatID.COMM_STAT_FISH) > 0

    -- 登录时服务器处于钓鱼状态则手动清理
    if IsFishing then
        FLOG_INFO("FishMgr:OnNetMsgGetStatStatus Update FishStatus IsFishing")
        self:PostFishActionEndMsg(EndTypeEnum.End)
    end

    self:UnRegisterGameNetMsg(CS_CMD.CS_CMD_COMM_STAT, ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS, self.OnNetMsgGetStatStatus)
end

-- function FishMgr:DisConnect()
--     _G.NetworkStateMgr:TestDisconnect()
--     self:RegisterTimer(self.Reconnect,15,1,1)
-- end

-- function FishMgr:Reconnect()
--     _G.NetworkStateMgr:TestReconnect()
-- end

return FishMgr