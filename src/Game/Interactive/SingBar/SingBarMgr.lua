
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local EffectUtil = require("Utils/EffectUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SingstateCfg = require("TableCfg/SingstateCfg")
local CommonUtil = require("Utils/CommonUtil")
local SkillUtil = require("Utils/SkillUtil")
local GameEventRegister = require("Register/GameEventRegister")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local AnimationUtil = require("Utils/AnimationUtil")

local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CsInteractionCMD
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local UE = _G.UE

local SingBarMgr = LuaClass(MgrBase)

--Major读条追加的时间
SingBarMgr.SingLifeAddTime = 150
--第3方玩家读条追加的时间，相当于超时处理，也相当于等待服务器通知
SingBarMgr.OtherPlayerSingLifeAddTime = 2000

--没有配置的话，会使用这个默认的
--对于有第2个读条的（比如水晶传送的），必须配置动作，也算合理；而且目前第3方玩家无法区分是否第2个，除非服务器改逻辑补协议；
SingBarMgr.DefaultAnimMontage = "AnimMontage'/Game/Assets/Character/Human/Animation/c0101/a0001/normal/A_c0101a0001_normal-cbnm_aettch_Montage.A_c0101a0001_normal-cbnm_aettch_Montage'"

--读条结束的类型
SingBarMgr.OverType = {
    BREAK = 1,
    NORMAL_END = 2
}

SingBarMgr.CanSelectSingStateList = {
    [33] = true, -- 召唤坐骑
}

SingBarMgr.TransferSingIDList = { --传送相关吟唱特殊处理
    [2] = true,
    [40] = true,
    [500015] = true,
}

SingBarMgr.ActiveCrystalSingIDList = { --激活水晶共鸣临界处理
    [3] = true,
    [4] = true,
}

-- 双pass半透材质渲染顺序适配
local AvatarType_Hair <const> = _G.UE.EAvatarPartType.NAKED_BODY_HAIR
local HairRenderPriority <const> = -1

--只有Major才有进度条SingBarOver，第三方玩家靠消息同步结束以及超时结束

function SingBarMgr:OnInit()
    self.MajorLastSingTime = 0
    
    --记录当前正在sing的所有玩家，遍历使用;  同时也记录下回调函数
    --如果是Major，则会记录是不是第1个读条、第2个读条的id
    self.PlayerSingMap = {}

    --记录主角最近的HP值，用于判断受到伤害时中断读条
    self.LastHp = 0

    self:Reset()
end

function SingBarMgr:OnBegin()
    self:Reset()
end

function SingBarMgr:OnEnd()
    self:Reset()
end

function SingBarMgr:OnShutdown()
end

function SingBarMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_INTERAVIVE, CS_SUB_CMD.CsInteractionCMDSpellChg, self.OnMajorSingBarChange)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_INTERAVIVE, CS_SUB_CMD.CsInteractionCMDBreak, self.OnInteractionBreakRsp)
    --第3方玩家
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_SPELL_CHG, self.OnOtherPlayerSingBarChange)
end

function SingBarMgr:Reset()
    for EntityID, _ in pairs(self.PlayerSingMap) do
        self:BreakCurSingDisplay(EntityID)
    end

    --记录当前正在sing的所有玩家，遍历使用;  同时也记录下回调函数
    --如果是Major，则会记录是不是第1个读条、第2个读条的id
    self.PlayerSingMap = {}

    --都是[EntityID, ID/Path]的形式
    self.TimerIDTable = {}
    self.EffectIDTable = {}
    --self.AnimPathTable = {}
    self.MontageTable = {}
    self.SoundIDTable = {}
    self.TimerLockTable = {}
    self.SingEffectMap = {}
    self.VfxIDTable = {}
    self.ATLIDTable = {}
    self.EndingATLIDTable = {}

    self.SingCallBack = nil

    --传送有概率在吟唱结束前收到跳转场景消息,这里重置参数
    self.MajorIsSinging = false
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_SPELL, false)

    self:UnRegisterGameEvents()

    --[singID, 是否是ActionTimeLine的]
    self.ActionTimeLineMap = {}

    --与交互的监听区分开
    if not self.EndingEventRegister then
        self.EndingEventRegister = GameEventRegister.New()
    end
    self.EndingEventRegister:UnRegisterAll()
end

function SingBarMgr:OnRegisterGameEvent()
    -- self:RegisterGameEvent(EventID.PlayerSingBarBegin, self.OnOtherPlayerSingBarBegin)
    -- self:RegisterGameEvent(EventID.PlayerSingBarBreak, self.OnOtherPlayerSingBarBreak)

	self:RegisterGameEvent(EventID.WorldPreLoad, self.OnLevelChange)
    self:RegisterGameEvent(EventID.LevelPreLoad, self.OnLevelChange)
    self:RegisterGameEvent(EventID.ActorDestroyed, self.OnActorDestroyed)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnPWorldMapExit)
end

function SingBarMgr:RegisterGameEvents()
    self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.ActorVelocityUpdate)
    self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    -- self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
    
    --self:RegisterGameEvent(EventID.Attr_Change_HP, self.OnMajorHpChange)
    self:RegisterGameEvent(EventID.MajorDead, self.OnBreakSingOver)
    self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnOtherCharacterDead)
    self:RegisterGameEvent(EventID.SelectTarget, self.OnSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnSelectTarget)
    self:RegisterGameEvent(EventID.MajorJumpStart, self.OnMajorJumpStart)
    self:RegisterGameEvent(EventID.MajorHit, self.OnGameEventMajorHit)
    self:RegisterGameEvent(EventID.LeaveInteractionRange, self.OnGameEventLeaveInteractionRange)
end

function SingBarMgr:UnRegisterGameEvents()
    self:UnRegisterGameEvent(EventID.ActorVelocityUpdate, self.ActorVelocityUpdate)
    self:UnRegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    -- self:UnRegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)

    --self:UnRegisterGameEvent(EventID.Attr_Change_HP, self.OnMajorHpChange)
    self:UnRegisterGameEvent(EventID.MajorDead, self.OnBreakSingOver)
    self:UnRegisterGameEvent(EventID.OtherCharacterDead, self.OnOtherCharacterDead)
    self:UnRegisterGameEvent(EventID.SelectTarget, self.OnSelectTarget)
	self:UnRegisterGameEvent(EventID.UnSelectTarget, self.OnSelectTarget)
    self:UnRegisterGameEvent(EventID.MajorJumpStart, self.OnMajorJumpStart)
    self:UnRegisterGameEvent(EventID.MajorHit, self.OnGameEventMajorHit)
    self:UnRegisterGameEvent(EventID.LeaveInteractionRange, self.OnGameEventLeaveInteractionRange)
end

--不同步视野内玩家的读条，可以使用读条表，也可以直接构造table（使用MajorSingByParamTable）
--同步与否在于业务系统的协议，读条是业务系统触发的；
--然后服务器那面计时，读条结束会自动触发交互，不用客户端再触发具体的内容了

--SingCallback(一般用不到)：参数  ture：被打断了  false：正常结束
--是否需要读条，读条是否同步，上层不用关心    读条表会配置IsClientOnly
function SingBarMgr:MajorSingByInteractiveID(InteractiveDescID, InteractiveEntityID, InteractiveListID, SingCallback)
    if not InteractiveDescID then
        FLOG_ERROR("BeginSing InteractiveDescID is nil")
        return false
    end

    local Interactivedesc = InteractivedescCfg:FindCfgByKey(InteractiveDescID)
    if not Interactivedesc then
        FLOG_ERROR("BeginSing InteractiveDescID is not config: %d", InteractiveDescID)
        return false
    end

    local SingStateIDNum = #Interactivedesc.SingStateID
    if SingStateIDNum == 0 or Interactivedesc.SingStateID[1] == 0 then
        if SingCallback then
            if nil ~= InteractiveEntityID and nil ~= InteractiveListID then
                CommonUtil.XPCall(nil, SingCallback, false, InteractiveEntityID, InteractiveListID)
            else
                CommonUtil.XPCall(nil, SingCallback, false)
            end
            FLOG_INFO("SingBarMgr Major CallBack no singbar")
        end

        return false
    end
    
    local SingstateDesc = SingstateCfg:FindCfgByKey(Interactivedesc.SingStateID[1])
    if not SingstateDesc then
        FLOG_ERROR("BeginSing SingstateDescID is not config: %d", Interactivedesc.SingStateID[1])
        return false
    end

    if SingstateDesc.IsClientOnly == 1 then
        _G.InteractiveMgr:PrintInfo("SingBarMgr MajorSingByInteractiveID (IsClientOnly=1) InteractiveID: %d", InteractiveDescID)

        local rlt = self:MajorSingBySingStateID(Interactivedesc.SingStateID[1], SingCallback, nil, InteractiveEntityID, InteractiveListID)
    
        if rlt then
            --是不是有第2个读条
            local MajorSingInfo = self.PlayerSingMap[MajorUtil.GetMajorEntityID()]
            if MajorSingInfo and SingStateIDNum == 2 then
                MajorSingInfo.SecondSingStateID = Interactivedesc.SingStateID[2]
            end
        else
            if SingCallback then
                 if nil ~= InteractiveEntityID and nil ~= InteractiveListID then
                    CommonUtil.XPCall(nil, SingCallback, true, InteractiveEntityID, InteractiveListID)
                else
                    CommonUtil.XPCall(nil, SingCallback, true)
                end
                FLOG_INFO("SingBarMgr cannot sing , then CallBack break sing")
            end
        end

        return rlt
    else
        FLOG_ERROR("SingBarMgr 现在不支持脱离交互流程的，并且同步第三方的读条")
        _G.MsgBoxUtil.MessageBox(LSTR(90025), LSTR(10002))
    end

    return true
end

function SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(SingStateID, SingCallback, ParamsTable, InteractiveEntityID, InteractiveListID)
    _G.InteractiveMgr:SetCurrentSingInteractionId(0)
    self:MajorSingBySingStateID(SingStateID, SingCallback, ParamsTable, InteractiveEntityID, InteractiveListID)
end

--也可以不配置交互表，只配置读条表，直接使用读条id进行读条
--SingCallback(一般用不到)：参数  ture：被打断了  false：正常结束
--读条是否同步，上层不用关心    读条表会配置IsClientOnly
function SingBarMgr:MajorSingBySingStateID(SingStateID, SingCallback, ParamsTable, InteractiveEntityID, InteractiveListID)
    local SingstateDesc = SingstateCfg:FindCfgByKey(SingStateID)
    if not SingstateDesc then
        FLOG_ERROR("SingBarMgr:MajorSingBySingStateID, SingStateID is not config: %d", SingStateID)
        return
    end

    local EntityID = MajorUtil.GetMajorEntityID()
    if not self:CanSing(EntityID, SingstateDesc.ID) then
        return false
    end

    _G.InteractiveMgr:PrintInfo("SingBarMgr:MajorSingBySingStateID, SingStateID:%d", SingStateID)
    self:OnMajorSingOver(EntityID, true, true)

    --[sammrli] 设置技能参数
    if ParamsTable == nil then
        ParamsTable = {}
    end
    ParamsTable.SkillID = SingstateDesc.SkillID
    ParamsTable.IconPath = SingstateDesc.IconPath

    --IsClientOnly：如果不是需要服务同步的，需要传入这个（用于客户端内部处理读条打断逻辑）
    self:OnMajorSingBegin(EntityID, SingstateDesc.UIStyle, SingstateDesc.Time
        , SingCallback, SingstateDesc.IsClientOnly, SingstateDesc.SingName, ParamsTable, SingstateDesc, InteractiveEntityID, InteractiveListID)

    if SingstateDesc.BreakedTime and SingstateDesc.BreakedTime ~= 100 and SingstateDesc.IsMovable == 0 then
        local LifeTime = SingstateDesc.BreakedTime * SingstateDesc.Time * 0.01
        local LockTime = SingstateDesc.Time - LifeTime
        self:StartLockMajorTimer(EntityID, LifeTime, LockTime > 0 and LockTime or 0)
    end

    local MajorSingInfo = self.PlayerSingMap[EntityID]
    if MajorSingInfo then
        MajorSingInfo.SingStateID = SingStateID
    end

    self:DoSingDisplay(EntityID, true, SingstateDesc)

    return true
end

--不使用交互表的简单读条，外部自己传入table参数，
--Time, Anim, SingEff, SingEffect, EffectSocket, EffectDeviation, SingSound, UIStyle, SingName
--没有参数就没有对应的表现
--IconPath:读条的图标
--外部可以利用这个接口做 sequence读条的概念，只传入SingTime
--SingCallback(一般用不到)：参数  ture：被打断了  false：正常结束
--IsClientOnly：如果不是需要服务同步的，需要传入这个（用于客户端内部处理读条打断逻辑）
--直接调用这个，认为是只有一个读条的（不是2个读条过程的；2个读条的情况是交互表配置的）
function SingBarMgr:MajorSingByParamTable(SingParam, SingCallback, IsClientOnly)
    if not SingParam or not SingParam.Time or SingParam.Time <= 0 then
        return false
    end

    _G.InteractiveMgr:PrintInfo("SingBarMgr MajorSingByParamTable")
    if SingParam and SingParam.Time and SingParam.Time > 0 then
        local EntityID = MajorUtil.GetMajorEntityID()
        if not self:CanSing(EntityID) then
            return false
        end
        self:OnMajorSingOver(EntityID, true, true)
        
        self:OnMajorSingBegin(EntityID, SingParam.UIStyle, SingParam.Time, SingCallback, IsClientOnly, SingParam.SingName)

        self:PlayEffect(EntityID, SingParam.SingEffect, SingParam.EffectSocketName, SingParam.EffectDeviation)
        self:PlayAnim(EntityID, SingParam.SingAnim)
        self:PlaySound(EntityID, SingParam.SingSound)

        return true
    end

    return false
end

----------------------------------------  内部接口 begin ------------------------
---
---
function SingBarMgr:OnPWorldMapExit()
    FLOG_WARNING("SingBarMgr:OnPWorldMapExit")
    self:OnMajorSingOver(MajorUtil.GetMajorEntityID(), true, true)
end
    
function SingBarMgr:OnMajorSingStartByChgRsp(InteractiveID, ServerSpellID)
    local Interactivedesc = InteractivedescCfg:FindCfgByKey(InteractiveID)
    if not Interactivedesc then
        return
    end
    
    local SingStateIDNum = #Interactivedesc.SingStateID
    if SingStateIDNum == 0 or Interactivedesc.SingStateID[1] == 0 then
        FLOG_ERROR("SingBarMgr:OnMajorSingStartByChgRsp SingStateID1 is 0")
        return
    end

    --读条前记录一下主角当前的CurHP
    self:GetMajorHp()

    _G.InteractiveMgr:SetCurrentSingInteractionId(InteractiveID)
    _G.InteractiveMgr:PrintInfo("SingBarMgr:OnMajorSingStartByChgRsp, SpellChgRsp first, ServerSpellID: %d, time:%d", ServerSpellID, TimeUtil.GetLocalTimeMS())
    local rlt = self:MajorSingBySingStateID(ServerSpellID, nil)
    if rlt then
        --是不是有第2个读条
        local MajorSingInfo = self.PlayerSingMap[MajorUtil.GetMajorEntityID()]
        if MajorSingInfo and SingStateIDNum == 2 then
            MajorSingInfo.SecondSingStateID = Interactivedesc.SingStateID[2]
        end
    end
end

--第3方玩家
--服务器会传过来读条id
function SingBarMgr:OnOtherPlayerSingBarBegin(EntityID, SingStateID)
    -- local EntityID = Params.ULongParam1
    -- local SingStateID = Params.IntParam1

    self:BreakCurSingDisplay(EntityID)

    if not SingStateID then
        FLOG_ERROR("OtherPlayerSing SingStateID is nil")
        return 
    end

    local SingstateDesc = nil
    if  SingStateID > 0 then
        SingstateDesc = SingstateCfg:FindCfgByKey(SingStateID)
    end

    if not SingstateDesc then
        FLOG_ERROR("OtherPlayerSing SingstateDescID is not config: %d", SingStateID)
        return
    end

    self:StartTimer(EntityID, SingstateDesc.Time + self.OtherPlayerSingLifeAddTime)

    self:DoSingDisplay(EntityID, false, SingstateDesc)

	_G.EventMgr:SendEvent(_G.EventID.OthersSingBarBegin, EntityID, SingStateID)
    self.PlayerSingMap[EntityID] = {SingStateID = SingStateID}
end

--CS_VISION_CMD_SPELL_CHG，打断读条或者结束，这个服务器目前没识别
--所以第3方玩家只能都是打断，而没有收手动作了
function SingBarMgr:OnOtherPlayerSingBarBreak(EntityID, SpellID)
    -- local EntityID = Params.ULongParam1
    local SingStateID = 0
    if self.PlayerSingMap and self.PlayerSingMap[EntityID] then
        SingStateID = self.PlayerSingMap[EntityID].SingStateID
    end
    if self:GetIsTransferSing(SingStateID) then                
        _G.EventMgr:SendEvent(_G.EventID.OthersSingBarOver, EntityID, true, SingStateID)
    end
    self:BreakCurSingDisplay(EntityID, nil, self.OverType.BREAK)
    _G.EventMgr:SendEvent(_G.EventID.OthersSingBarBreak, EntityID)

    if  SpellID and SpellID > 0 then
        local SingstateDesc = SingstateCfg:FindCfgByKey(SpellID)
        if SingstateDesc and not SingstateDesc.NotSyncEffectAndSound then
            self:PlaySound(EntityID, SingstateDesc.SingBreakSound)
        end
    end
end

function SingBarMgr:OnOtherPlayerSingBarChange(MsgBody)
    local SpellChg = MsgBody.SpellChg
    local EntityID = SpellChg.EntityID
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local SpellID = SpellChg.Interactive.SpellID
    if SpellID and SpellID > 0 then
        if SpellChg.Interactive.Type == ProtoCommon.INTERACT_TYPE.INTERACT_TYPE_GENERAL then
            _G.InteractiveMgr:PrintInfo("SingBarMgr:OnOtherPlayerSingBarChange, SpellID: %d, Time:%d", SpellID, TimeUtil.GetLocalTimeMS())
            if EntityID == 0 then
                FLOG_ERROR("SingBarMgr:OnOtherPlayerSingBarChange Error, EntityID: %d", EntityID)
                return
            end

            if EntityID ~= MajorEntityID then
                self:OnOtherPlayerSingBarBegin(EntityID, SpellID)
            else
                FLOG_INFO("SingBarMgr:OnOtherPlayerSingBarChange, major ignore.")
            end
        end
    else
        _G.InteractiveMgr:PrintInfo("SingBarMgr:OnOtherPlayerSingBarChange, Time:%d", TimeUtil.GetLocalTimeMS())
		-- //只是第3方玩家的
		-- //读条状态可能有多种，但读条结束或者打断都会这条协议下来，并且spellid为0
        -- 不处理主角自己的读条状态改变
        if EntityID ~= MajorEntityID then
            self:OnOtherPlayerSingBarBreak(EntityID, SpellID)
        end
    end
end

--对于2个读条的
--先Start发包，然后可以读条是Start回包，不可用则是break；然后是next或者break，然后是success
--客户端从业务模块触发读条后，会直接触发读条表现，第一个读条结束后，会自动触发第2个；
    --如果客户端还是第一个读条，但是收到了next的包，也会切入第2个读条
    --如果客户端收到了SUCCESS，则结束表现
--对于1个读条的
--先Start发包，然后可以读条是Start回包，不可用则是break；然后是break或者success
--客户端从业务模块触发读条后，会直接触发读条表现，
    --如果客户端收到了SUCCESS，则结束表现
function SingBarMgr:OnMajorSingBarChange(MsgBody)
    local SpellChgRsp = MsgBody.SpellChg
    if nil == SpellChgRsp then
        return
    end
    local EntityID = MajorUtil.GetMajorEntityID()

    --RoleID字段去掉了
    -- if not MajorUtil.IsMajorByRoleID(SpellChgRsp.RoleID) then
    --     return
    -- end

    _G.InteractiveMgr:PrintInfo("SingBarMgr:OnMajorSingBarChange, type:%d, time:%d", SpellChgRsp.Result, TimeUtil.GetLocalTimeMS())
    --_G.InteractiveMgr:EnableMajorMove(true)
    if SpellChgRsp.Result == ProtoCS.SpellResult.SpellResultBreak then
        self:OnMajorSingOver(EntityID, true, true)
        self.SingCallBack = nil
    elseif SpellChgRsp.Result == ProtoCS.SpellResult.SpellResultNext then
        self:BreakSingBarView(false)
        self:MajorSingBySecondSingStateID(SpellChgRsp.SpellID)
    elseif SpellChgRsp.Result == ProtoCS.SpellResult.SpellResultFirst then
        self:OnMajorSingStartByChgRsp(SpellChgRsp.InteractionID, SpellChgRsp.SpellID)
    elseif SpellChgRsp.Result == ProtoCS.SpellResult.SpellResultSuccell then
        -- self:OnMajorSingOver(EntityID, false, true)
        -- if self.TmpTimerID then
        --     TimerMgr:CancelTimer(self.TmpTimerID)
        -- end

        -- self.TmpTimerID = TimerMgr:AddTimer(self, function ()
        --     local Major = _G.UE.UActorManager:Get():GetMajor()
        --     if Major then
        --         Major:ResetFade()
        --     end
        -- end, 1)
    end
end

-- 读条结束、服务器会下发结果通知（打断、正常结束、播放读条后动作特效音效）

--主要做表现 PlayerSingMap中的数据，在第一个读条的时候设置过了，这里只会改IsFirst
function SingBarMgr:MajorSingBySecondSingStateID(SingStateID)
    local EntityID = MajorUtil.GetMajorEntityID() 

    local MajorSingInfo = self.PlayerSingMap[EntityID]
    if not MajorSingInfo or MajorSingInfo.IsFirst == false then
        --客户端自己已经进行第2个读条了，服务器协议才下发下来，所以不做任何事情，继续第2个读条
        return
    end

    local SingstateDesc = SingstateCfg:FindCfgByKey(SingStateID)
    if not SingstateDesc then
        FLOG_ERROR("SingBarMgr secondSingstateDescID is not config: %d", SingStateID)
        self:OnMajorSingOver(EntityID, true, true)
        return false
    end

    self:BreakCurSingDisplay(EntityID, true)

    self:StartTimer(EntityID, SingstateDesc.Time)

    if SingstateDesc.BreakedTime and SingstateDesc.BreakedTime ~= 100 then
        local LifeTime = SingstateDesc.BreakedTime * SingstateDesc.Time * 0.01
        local LockTime = SingstateDesc.Time - LifeTime
        self:StartLockMajorTimer(EntityID, LifeTime, LockTime)
    end

    --开始第2个读条
    MajorSingInfo.IsFirst = false
    MajorSingInfo.SingStateID = SingStateID
    _G.InteractiveMgr:PrintInfo("SingBarMgr SecondSing SingStateID: %d, Time:%d", SingStateID, TimeUtil.GetLocalTimeMS())


    _G.InteractiveMgr:SendInteractiveSpellChgReq(SingStateID)

    _G.EventMgr:SendEvent(_G.EventID.MajorSingBarBegin, EntityID, SingStateID)

    self:DoSingDisplay(EntityID, true, SingstateDesc)
    self:PlaySound(EntityID, SingstateDesc.SingSound)

    return true
end

function SingBarMgr:IsActionTimeLineSing(SingStateID, SingstateDesc)
    local Rlt = self.ActionTimeLineMap[SingStateID]
    if Rlt ~= nil then
        return Rlt
    end

    if not SingstateDesc then
        SingstateDesc = SingstateCfg:FindCfgByKey(SingStateID)
    end

    if not string.isnilorempty(SingstateDesc.AnimStart) then
        self.ActionTimeLineMap[SingStateID] = true
        return true
    else
        self.ActionTimeLineMap[SingStateID] = false
    end

    return false
end

function SingBarMgr:DoSingDisplay(EntityID, IsMajor, SingstateDesc)
    local IsPlay = false
    if IsMajor or not IsMajor and SingstateDesc.NotSyncEffectAndSound == 0 then
        IsPlay = true
    end

    --[sammrli] 播放G6配置的技能动作和特效
    if SingstateDesc.SkillID ~= nil and SingstateDesc.SkillID > 0 then
        if not self:GetIsTransferSing(SingstateDesc.ID) or not ActorUtil.IsInRide(EntityID) then
            local SubSkillID = SkillUtil.MainSkill2SubSkill(SingstateDesc.SkillID)
            self.SingEffectMap[EntityID] = _G.SkillSingEffectMgr:PlaySingEffect(EntityID, SubSkillID)
        end
    elseif self:IsActionTimeLineSing(SingstateDesc.ID, SingstateDesc) then
        if IsPlay and (not self:GetIsTransferSing(SingstateDesc.ID) or not ActorUtil.IsInRide(EntityID)) then
            local Actor = ActorUtil.GetActorByEntityID(EntityID)
            if Actor ~= nil and Actor:GetAnimationComponent() ~= nil then
                local StartPath = _G.AnimMgr:GetActionTimeLinePath(SingstateDesc.AnimStart)
                local LoopPath = _G.AnimMgr:GetActionTimeLinePath(SingstateDesc.AnimLoop)
                _G.InteractiveMgr:PrintInfo("SingBarMgr AnimStart  %s", StartPath)
                _G.InteractiveMgr:PrintInfo("SingBarMgr AnimLoop  %s", LoopPath)
                -- Actor:GetAnimationComponent():PlayAnimationAsync(StartPath, nil, 1, 0.25, 0)
                -- Actor:GetAnimationComponent():QueueAnimation(LoopPath, 1, 0, 0)
                local ActionTimelines = {
                    [1] = {AnimPath = StartPath},
                    [2] = {AnimPath = LoopPath},
                }
                self.ATLIDTable[EntityID] = _G.AnimMgr:PlayAnimationMulti(EntityID, ActionTimelines)
            end
        end

        --vfx
        self:PlayVfx(EntityID, SingstateDesc.SingEffect)
    else
        if IsPlay then
            self:PlayEffect(EntityID, SingstateDesc.SingEffect, SingstateDesc.EffectSocketName, SingstateDesc.EffectDeviation)
            self:PlayEffect(EntityID, SingstateDesc.SingEffect2, SingstateDesc.EffectSocketName2, SingstateDesc.EffectDeviation2)
        end

        self:PlayAnim(EntityID, SingstateDesc.SingAnim)
    end

    if IsPlay then
        self:PlaySound(EntityID, SingstateDesc.SingSound)
    end
end

function SingBarMgr:OnLevelChange()
    self:Reset()
end

function SingBarMgr:BreakSingBarView(IsBreak)
    if IsBreak then
        _G.EventMgr:SendEvent(EventID.MajorSingBarBreak)
    else
        _G.UIViewMgr:HideView(UIViewID.SingBarAttuning)
        _G.UIViewMgr:HideView(UIViewID.SingBarQuestUseItem)
    end
end

function SingBarMgr:OnActorDestroyed(Params)
    local EntityID = Params.ULongParam1
    -- FLOG_INFO("SingBarMgr OnActorDestroyed break : %d", EntityID)
    self:BreakCurSingDisplay(EntityID)
end

--不需要服务器同步给第3方玩家的读条
--移动要打断
function SingBarMgr:ActorVelocityUpdate(Params)
    local EntityID = Params.ULongParam1
    local bVelocityIsZero = Params.BoolParam1
    if EntityID == MajorUtil.GetMajorEntityID() and not bVelocityIsZero then
        local Sing = self.PlayerSingMap[EntityID]
        if Sing then
            if not self:IsMoveableSingStateID(Sing.SingStateID) then
                _G.InteractiveMgr:PrintInfo("SingBarMgr VelocityUpdate break major singbar")
                _G.InteractiveMgr:SendInteractiveBreakReq() --主动通知服务器打断,客户端移动上报有延迟,可能会导致服务器打断交互延迟
                self:OnMajorSingOver(EntityID, true, true)
            end
        end
    end
end

---打断结束动作，结束动作是本地表现，不用与服务器交互
function SingBarMgr:OnEndingRecieveActorVelocityUpdate(Params)
    local EntityID = Params.ULongParam1
    --break ending animation
    local ATLID = self.EndingATLIDTable[EntityID]
    if ATLID then
        _G.AnimMgr:StopAnimationMulti(EntityID, ATLID)
        self.EndingATLIDTable[EntityID] = nil
    end
    if #self.EndingATLIDTable == 0 then
        self.EndingEventRegister:UnRegisterAll()
    end
end

function SingBarMgr:OnSelectTarget()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if self.PlayerSingMap[MajorEntityID] == nil then return end
    local SingStateID = self.PlayerSingMap[MajorEntityID].SingStateID
    if SingStateID == nil then return end
    if self.CanSelectSingStateList[SingStateID] == nil then
        _G.InteractiveMgr:SendInteractiveBreakReq()
        local function SendInteractiveBreakReqTimeOut()
            self:OnInteractionBreakRsp()
        end
        self.SendInteractionBreakReqTimer = TimerMgr:AddTimer(nil, SendInteractiveBreakReqTimeOut, 0.5, 1, 1)
    end
end

function SingBarMgr:OnInteractionBreakRsp(MsgBody)
    --FLOG_INFO("SingBarMgr:OnInteractionBreakRsp, MsgBody:%s", tostring(MsgBody))
    if nil ~= self.SendInteractionBreakReqTimer then
        TimerMgr:CancelTimer(self.SendInteractionBreakReqTimer)
    end
    self:OnBreakSingOver()
    --_G.InteractiveMgr:ExitInteractive()
    --_G.InteractiveMgr:OnExitDialogue()
end

function SingBarMgr:GetMajorHp()
    local major = MajorUtil.GetMajor()
    if nil == major then
        FLOG_INFO("SingBarMgr:GetMajorHP major is nil")
        return
    end
    self.LastHp = MajorUtil.GetMajorCurHp()
end

function SingBarMgr:OnMajorHpChange(Params)
    if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if EntityID ~= MajorEntityID then
        return
    end

	local CurHP = Params.ULongParam3
	--local MaxHP = Params.ULongParam4
    if CurHP < self.LastHp then
        self:OnBreakSingOver()
    end
end

function SingBarMgr:OnGameEventMajorHit()
    _G.InteractiveMgr:PrintInfo("SingBarMgr:OnGameEventMajorHit")
    self:OnBreakSingOver()
end

function SingBarMgr:OnGameEventLeaveInteractionRange(Params)
    if Params and Params.IntParam1 == _G.LuaEntranceType.CRYSTAL then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        local Sing = self.PlayerSingMap[MajorEntityID]
        if Sing and self:GetIsActiveCrystalSing(Sing.SingStateID) then
            self:OnBreakSingOver()
        end
    end
end

function SingBarMgr:OnMajorJumpStart()
    _G.InteractiveMgr:SendInteractiveBreakReq()
    --self:OnBreakSingOver()
end

--打断
function SingBarMgr:OnBreakSingOver()
	local EntityID = MajorUtil.GetMajorEntityID()
    self:OnMajorSingOver(EntityID, true, true)
end

function SingBarMgr:OnOtherCharacterDead(Params)
	local EntityID = Params.ULongParam1
    self:BreakCurSingDisplay(EntityID)
end

--主角释放技能
function SingBarMgr:OnMajorUseSkill(Params)
    local EntityID = Params.ULongParam3
    if EntityID == nil or EntityID == 0 then
        EntityID = MajorUtil.GetMajorEntityID()
    end

    if self.PlayerSingMap[EntityID] then
        _G.InteractiveMgr:PrintInfo("SingBarMgr Major use skill, break major singbar")
        self:OnMajorSingOver(EntityID, true, true)
    end
end

--战斗状态不打断的读条，肯定不会是不需要服务器同步给第3方玩家的读条
--所以这里可以认为  不需要服务器同步的读条，进入战斗状态，就需要打断
function SingBarMgr:OnNetStateUpdate(Params)
	local EntityID = Params.ULongParam1
	if not MajorUtil.IsMajor(EntityID) or not self.PlayerSingMap[EntityID] then
		return
	end
    
    local IsNoSync = self.PlayerSingMap[EntityID].IsNoSync
    if IsNoSync then
        local StateType = Params.IntParam1
        if StateType ~= ProtoCommon.CommStatID.COMM_STAT_COMBAT then
            return
        end
        
        local State = Params.BoolParam1
        if State then
            _G.InteractiveMgr:PrintInfo("SingBarMgr COMM_STAT_COMBAT enter, break major singbar， noSync")
            self:OnMajorSingOver(EntityID, true, true)
        end
    end
end

function SingBarMgr:CanSing(EntityID, SingStateID)
    local IsMajor = MajorUtil.IsMajor(EntityID)
    local CurTime = TimeUtil.GetLocalTimeMS()

    --移动中无法开始吟唱
    if IsMajor then
        if CurTime - self.MajorLastSingTime < 800 then
            MsgTipsUtil.ShowTips(LSTR(90026))
            return false
        end

        --pcwtodo：需要补状态检查，如果当前是读条的通用装，也不能再次进行
        local Major = MajorUtil.GetMajor()
        if Major and Major.CharacterMovement then
            local Velocity = Major.CharacterMovement.Velocity
            if (Velocity.X ~= 0 or Velocity.Y ~= 0 or Velocity.Z ~= 0) and not self:IsMoveableSingStateID(SingStateID) then
                --自动寻路中，忽略
                local IsAutoPathMovingState = _G.AutoPathMoveMgr:IsAutoPathMovingState()
                if (not IsAutoPathMovingState) then
                    MsgTipsUtil.ShowTips(LSTR(90027))
                    _G.InteractiveMgr:SendInteractiveBreakReq()
                    --_G.InteractiveMgr:EnableMajorMove(false)
                    return false 
                end
            end
        else
            --角色已销毁（转场、断线）
            return false
        end
    end

    --角色是否存活
    local ActorStateComponent = ActorUtil.GetActorStateComponent(EntityID)
    if not ActorStateComponent or ActorStateComponent:IsDeadState() then
        MsgTipsUtil.ShowTips(LSTR(90028))
        return false
    end

    if IsMajor then
        self.MajorLastSingTime = CurTime
    end

    return true
end

function SingBarMgr:OnMajorSingBegin(EntityID, UIStyle, SingLife, SingCallback, IsClientOnly, SingName, ParamsTable, SingstateDesc, InteractiveEntityID, InteractiveListID)
    --FLOG_INFO("SingBarMgr:OnMajorSingBegin")
    local IsMovable = false
    if SingstateDesc then
        IsMovable = SingstateDesc.IsMovable == 1
    end
    --吟唱期间锁定旋转
    local StateComponent = MajorUtil.GetMajorStateComponent()
    if StateComponent ~= nil then
        -- obt分支临时修改,先置一次true清空状态计数器
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, true, "InteractiveSing")
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanUseSkill, true, "InteractiveSing")
        if not IsMovable then
            StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, false, "InteractiveSing")
        end
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanUseSkill, false, "InteractiveSing")
    end

    local ShowSingTimeCountDown = true
    if SingstateDesc then
        ShowSingTimeCountDown = not self:IsActionTimeLineSing(SingstateDesc.ID, SingstateDesc)
    end

    local AvatarComp = ActorUtil.GetActorAvatarComponent(EntityID)
    if AvatarComp then
        AvatarComp:SetPartTranslucencySortPriority(AvatarType_Hair, HairRenderPriority)
    end

    if SingstateDesc and SingstateDesc.HideOtherUIType ~= nil then
        _G.InteractiveMgr:PrintInfo("SingBarMgr:OnMajorSingBegin, SingstateID:%d, UIStyle:%d, HideUIType:%s", SingstateDesc.ID, UIStyle, SingstateDesc.HideOtherUIType)
        _G.InteractiveMgr:SetHideOtherUITypeBySing(SingstateDesc.HideOtherUIType)
        ParamsTable.HideOtherUIType = SingstateDesc.HideOtherUIType
    end
    if UIStyle == ProtoRes.SingStateUIStyle.UISTYLE_NORMAL then
        local SingBarView = _G.UIViewMgr:ShowView(UIViewID.SingBarAttuning, ParamsTable)
        if SingBarView then
            SingBarView:BeginSingBar(SingLife, SingName, ShowSingTimeCountDown)
        end
    elseif UIStyle == ProtoRes.SingStateUIStyle.UISTYLE_QUEST_USEITEM then
        local SingBarView = _G.UIViewMgr:ShowView(UIViewID.SingBarQuestUseItem, ParamsTable)
        if SingBarView then
            SingBarView:BeginSingBar(SingLife, SingName, ShowSingTimeCountDown)
        end
    else
        self:StartTimer(EntityID, SingLife)
    end

    self.MajorIsSinging = true
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_SPELL, true)

    self:RegisterGameEvents()

    local SingStateID =  SingstateDesc and SingstateDesc.ID or 0
	_G.EventMgr:SendEvent(_G.EventID.MajorSingBarBegin, EntityID, SingStateID)
    if nil ~= InteractiveEntityID and nil ~= InteractiveListID then
        self.PlayerSingMap[EntityID] = {Callback = SingCallback, IsNoSync = IsClientOnly, IsFirst = true, InteractiveEntityID = InteractiveEntityID, InteractiveListID = InteractiveListID}
    else
        self.PlayerSingMap[EntityID] = {Callback = SingCallback, IsNoSync = IsClientOnly, IsFirst = true}
    end
end

function SingBarMgr:GetMajorIsSinging()
    return self.MajorIsSinging
end

---是否传送吟唱
function SingBarMgr:GetIsTransferSing(SingID)
    if not SingID then
        return false
    end
    return self.TransferSingIDList[SingID]
end

---是否激活水晶共鸣
function SingBarMgr:GetIsActiveCrystalSing(SingID)
    if not SingID then
        return false
    end
    return self.ActiveCrystalSingIDList[SingID]
end

--打断或者正常结束
function SingBarMgr:OnMajorSingOver(EntityID, IsBreak, IsForce)
    self.MajorIsSinging = false
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_SPELL, false)

    if nil == self.PlayerSingMap then
        return
    end

    local MajorSingInfo = self.PlayerSingMap[EntityID]
    if not MajorSingInfo then
        return
    end

    local AvatarComp = ActorUtil.GetActorAvatarComponent(EntityID)
    if AvatarComp then
        AvatarComp:SetPartTranslucencySortPriority(AvatarType_Hair, 0)
    end

    self:BreakSingBarView(IsBreak)

    --读条结束、Major的计时器结束  才可能触发第2个读条
    if not IsForce and MajorSingInfo.IsFirst == true and MajorSingInfo.SecondSingStateID and MajorSingInfo.SecondSingStateID > 0 then
        _G.InteractiveMgr:PrintInfo("SingBarMgr:OnMajorSingOver, MajorSingBySecondSingStateID: %d", MajorSingInfo.SecondSingStateID)
        self:MajorSingBySecondSingStateID(MajorSingInfo.SecondSingStateID)
        return
    end

    local StateComponent = MajorUtil.GetMajorStateComponent()
    if StateComponent ~= nil then
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanTurn, true, "InteractiveSing")
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanUseSkill, true, "InteractiveSing")
    end

    self:UnRegisterGameEvents()

    _G.InteractiveMgr:PrintInfo("SingBarMgr:OnMajorSingOver, IsBreak:%s, time:%s", tostring(IsBreak), tostring(TimeUtil.GetLocalTimeMS()))
    _G.EventMgr:SendEvent(_G.EventID.MajorSingBarOver, EntityID, IsBreak, MajorSingInfo.SingStateID)

    local Callback = self.PlayerSingMap[EntityID].Callback
    if Callback then
        local InteractiveEntityID = self.PlayerSingMap[EntityID].InteractiveEntityID
        local InteractiveListID = self.PlayerSingMap[EntityID].InteractiveListID
        if nil ~= InteractiveEntityID and nil ~= InteractiveListID then
            CommonUtil.XPCall(nil, Callback, IsBreak, InteractiveEntityID, InteractiveListID)
        else
            CommonUtil.XPCall(nil, Callback, IsBreak)
        end
        _G.InteractiveMgr:PrintInfo("SingBarMgr:OnMajorSingOver, CallBack IsBreak:%s", tostring(IsBreak))
    end

    local overtype = self.OverType.BREAK
    if not IsBreak then
        overtype = self.OverType.NORMAL_END
    end

    self:BreakCurSingDisplay(EntityID, nil, overtype)

    if not IsBreak then
        --读条效果正常结束
        _G.InteractiveMgr:SendInteractiveEndReq()
    else
        --读条被打断了
        _G.InteractiveMgr:SetCurrentSingInteractionId(0)
    end
end

-------------------------------------------------  表现相关接口
function SingBarMgr:PlayEffect(EntityID, EffectPath, EffectSocket, EffectDeviation, EffectRotation)
    if not EffectPath or EffectPath == "" then
        return 
    end
    
    local MajorID = MajorUtil.GetMajorEntityID()

    local LODLevel = 0
    if MajorID ~= EntityID then
        LODLevel = 1
    end

    local VfxParameter = _G.UE.FVfxParameter()
    --local FXParam = _G.UE.FActorFXParam()
    local Major = MajorUtil.GetMajor()

	local Me = ActorUtil.GetActorByEntityID(EntityID)
    if Me then
        -- if self.EffectIDTable[EntityID] and self.EffectIDTable[EntityID] ~= 0 then
        --     EffectUtil.BreakEffect(self.EffectIDTable[EntityID])
        -- end
        VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(EffectPath)
        VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_SingBarMgr
        VfxParameter.LODMethod = 2
        VfxParameter.LODLevel = LODLevel
        VfxParameter.SetCaster(None, 0 , 0, 0)

        --[[if type(EffectDeviation) == "string" then
            local PosTable = string.split(EffectDeviation, ",")
            FXParam.RelativeLocation = _G.UE.FVector(tonumber(PosTable[1]), tonumber(PosTable[2]), tonumber(PosTable[3]))
        else
            FXParam.RelativeLocation = EffectDeviation
        end

        if EffectRotation then
            FXParam.RelativeRotation = EffectRotation
        end]]

        -- FXParam.SocketName  Relative*等 使用默认值
        local MyTransform = _G.UE.FTransform()
        MyTransform:SetLocation(Me:FGetActorLocation())
        VfxParameter.VfxRequireData.VfxTransform = MyTransform
        local EffectRltID = EffectUtil.PlayVfx(VfxParameter)
        --local EffectRltID = EffectUtil.PlayEffect(FXParam)
        local EffectTable = self.EffectIDTable[EntityID] or {}
        table.insert(EffectTable, EffectRltID)

        self.EffectIDTable[EntityID] = EffectTable
    end
end

function SingBarMgr:RemoveEffect(EntityID)
    local EffectTable = self.EffectIDTable[EntityID] or {}
    for index = 1, #EffectTable do
        local EffectID = EffectTable[index]
        if EffectID and EffectID > 0 then
            EffectUtil.StopVfx(EffectID)
            --EffectUtil.BreakEffect(EffectID)
        end
    end
end

function SingBarMgr:PlayVfx(EntityID, EffectPath)
    if string.isnilorempty(EffectPath) then
        return
    end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        local VfxParameter = UE.FVfxParameter()
        VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(EffectPath)
        --VfxParameter.VfxRequireData.EffectPath = EffectPath
        VfxParameter.PlaySourceType= UE.EVFXPlaySourceType.PlaySourceType_AetherCurrents
        local AttachPointType_Body = UE.EVFXAttachPointType.AttachPointType_Body
        VfxParameter:SetCaster(Actor, 0, AttachPointType_Body, 0)

        local VfxID = EffectUtil.PlayVfx(VfxParameter)

        local VfxIDList = self.VfxIDTable[EntityID] or {}
        table.insert(VfxIDList, VfxID)
        self.VfxIDTable[EntityID] = VfxIDList
    end
end

function SingBarMgr:RemoveVfx(EntityID)
    local VfxIDList = self.VfxIDTable[EntityID]
    if VfxIDList then
        for i=1, #VfxIDList do
            EffectUtil.StopVfx(VfxIDList[i])
        end
    end
    self.VfxIDTable[EntityID] = nil
end

function SingBarMgr:PlayAnim(EntityID, AnimPath, PlayRate, BlendIn, BlendOut)
    if not AnimPath or string.len(AnimPath) == 0 then
        --AnimPath = SingBarMgr.DefaultAnimMontage
        --[sammrli] 不设默认动作了
        return
    end

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        local AnimationComponent = Actor:GetAnimationComponent()
        if AnimationComponent ~= nil and AnimPath then
            --self.AnimPathTable[EntityID] = AnimPath
            _G.InteractiveMgr:PrintInfo("SingBarMgr PlayAnim  %s,  time:%d", AnimPath, TimeUtil.GetLocalTimeMS())
            local Montage = AnimationComponent:PlayAnimation(AnimPath, PlayRate or 1.0, BlendIn or 0, BlendOut or 0)
            self.MontageTable[EntityID] = Montage
        end
    end
end

--读条停止，播放End动作
function SingBarMgr:StopAnimation(EntityID, IsForceStopAnim, SingstateDesc, SingOverType)
    if not SingstateDesc then
        return
    end
    if self:GetIsTransferSing(SingstateDesc.ID) and ActorUtil.IsInRide(EntityID) then
        return
    end

    --local CurAnimPath = self.AnimPathTable[EntityID]
    local Montage = self.MontageTable[EntityID]
    if Montage then
        self.MontageTable[EntityID] = nil
    end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Montage and Actor then
		local AnimationComponent = Actor:GetAnimationComponent()
		if AnimationComponent ~= nil then
            local AnimInstance = AnimationComponent:GetAnimInstance()
            if AnimInstance then
                AnimationUtil.MontageStop(AnimInstance, Montage)
            end
		end
	end

    if self:IsActionTimeLineSing(SingstateDesc.ID, SingstateDesc) then
        local ATLID = self.ATLIDTable[EntityID]
        if ATLID then
            _G.AnimMgr:StopAnimationMulti(EntityID, ATLID)
            self.ATLIDTable[EntityID] = nil
        end
        if EntityID == MajorUtil.GetMajorEntityID() then
            if SingOverType ~= self.OverType.BREAK then
                if Actor then
                    local AnimComp = Actor:GetAnimationComponent()
                    if AnimComp then
                        local EndPath = _G.AnimMgr:GetActionTimeLinePath(SingstateDesc.AnimEnd)
                        local ActionTimelines = {
                            [1] = {AnimPath = EndPath,Callback = CommonUtil.GetDelegatePair(function()
                                _G.EventMgr:SendEvent(_G.EventID.SingBarAllOver,EntityID)
                                end,true)},
                        }
                        local ATLID = _G.AnimMgr:PlayAnimationMulti(EntityID, ActionTimelines)
                        self.EndingATLIDTable[EntityID] = ATLID
                        self.EndingEventRegister:UnRegisterAll()
                        self.EndingEventRegister:Register(EventID.ActorVelocityUpdate, self, self.OnEndingRecieveActorVelocityUpdate)
                    end
                end
            end
        else
            -- 如果P3配置了读条结束播放结束动作
            if SingstateDesc.AlwaysPlayEndAnim == 1 then
                if Actor then
                    local AnimComp = Actor:GetAnimationComponent()
                    if AnimComp then
                        local EndPath = _G.AnimMgr:GetActionTimeLinePath(SingstateDesc.AnimEnd)
                        local ActionTimelines = {
                            [1] = {AnimPath = EndPath,Callback = CommonUtil.GetDelegatePair(function()
                                _G.EventMgr:SendEvent(_G.EventID.SingBarAllOver,EntityID)
                                end,true)},
                        }
                        local ATLID = _G.AnimMgr:PlayAnimationMulti(EntityID, ActionTimelines)
                        self.EndingATLIDTable[EntityID] = ATLID
                    end
                end
            end
        end
    end
end

--主角和第三方玩家都播放
function SingBarMgr:PlaySound(EntityID, SoundPath)
    if not SoundPath then
        return
    end

    local Me = ActorUtil.GetActorByEntityID(EntityID)
    if not Me then
        return
    end

    local AudioMgr = _G.UE.UAudioMgr:Get()
    local SoundID = AudioMgr:LoadAndPostEvent(SoundPath, Me, false)

    if not EntityID then
        return
    end
    self.SoundIDTable[EntityID] = SoundID
end

function SingBarMgr:PlayActorSound(Actor, SoundPath)
    if not SoundPath then
        return
    end

    _G.UE.UAudioMgr:Get():LoadAndPostEvent(SoundPath, Actor, false)
end

function SingBarMgr:StopSound(EntityID)
    if not EntityID then
        return
    end
    local SoundID = self.SoundIDTable[EntityID]
    if SoundID then
        local AudioMgr = _G.UE.UAudioMgr:Get()
        AudioMgr:StopPlayingID(SoundID, 0, 0)
    end
end

--停掉所有效果
--第2个读条的时候才用到NotClearPlayerSingMap，传入true
--SingOverType   打断或者正常结束
function SingBarMgr:BreakCurSingDisplay(EntityID, NotClearPlayerSingMap, SingOverType)
    --self.PlayerSingMap 可能为空,SingbarMgr的生命周期是Level,有可能会被其他模块调用
    if not self.PlayerSingMap then
        _G.InteractiveMgr:PrintWarning("SingBarMgr Un Init !")
        return
    end

    if not self.PlayerSingMap[EntityID] then
        return
    end

    self:RemoveEffect(EntityID)
    self:StopSound(EntityID)
    self:RemoveVfx(EntityID)
    --if self.CurrentSingEffectID then
    --    _G.SkillSingEffectMgr:BreakSingEffect(EntityID, self.CurrentSingEffectID)
    --    self.CurrentSingEffectID = nil
    --end
    if self.SingEffectMap[EntityID] then
        _G.SkillSingEffectMgr:BreakSingEffect(EntityID, self.SingEffectMap[EntityID])
        self.SingEffectMap[EntityID] = nil
    end

    local SingstateDesc = nil
    local SingStateID = self.PlayerSingMap[EntityID].SingStateID
    if SingStateID and SingStateID > 0 then
        SingstateDesc = SingstateCfg:FindCfgByKey(SingStateID)
    end

    self:StopAnimation(EntityID, NotClearPlayerSingMap, SingstateDesc, SingOverType)
    
	_G.InteractiveMgr:PrintInfo("SingBarMgr BreakCurSingDisplay NotClearPlayerSingMap:" .. tostring(NotClearPlayerSingMap))

    local TimerID = self.TimerIDTable[EntityID]
    if TimerID then
        TimerMgr:CancelTimer(TimerID)
        self.TimerIDTable[EntityID] = nil
    end

    if self.SingBarTimer then
        self.SingBarTimer:Clear()
        self.SingBarTimer = nil
    end

    if SingstateDesc then
        local IsMajor = MajorUtil.IsMajor(EntityID)
        if IsMajor then --主角自己
            if SingOverType and SingOverType == self.OverType.NORMAL_END then --正常结束
                self:PlayEffect(EntityID, SingstateDesc.EndEffect, SingstateDesc.EndEffectSocketName, SingstateDesc.EndEffectDeviation)
                self:PlaySound(EntityID, SingstateDesc.SingStopSound)
            else --打断
                self:PlaySound(EntityID, SingstateDesc.SingBreakSound)
            end
        else --第3方玩家（打断音效已经外部处理了）
            if SingOverType and SingOverType == self.OverType.NORMAL_END then --正常结束
                if SingstateDesc and not SingstateDesc.NotSyncEffectAndSound then
                    self:PlayEffect(EntityID, SingstateDesc.EndEffect, SingstateDesc.EndEffectSocketName, SingstateDesc.EndEffectDeviation)
                    self:PlaySound(EntityID, SingstateDesc.SingStopSound)
                end
            end
        end
    end

    if not NotClearPlayerSingMap then
        self.PlayerSingMap[EntityID] = nil
    end
end

-------------------------------------------------  表现相关接口
---

function SingBarMgr:StartTimer(EntityID, SingLife)
    local LastTimerID = self.TimerIDTable[EntityID]
    if LastTimerID and LastTimerID > 0 then
        TimerMgr:CancelTimer(LastTimerID)
    end

    local SingTime = SingLife + self.SingLifeAddTime
    
    local function SingOver(Params)
        _G.InteractiveMgr:PrintInfo("SingBarMgr:StartTimer, SingOver: " .. TimeUtil.GetLocalTimeMS())
        if MajorUtil.IsMajor(Params.EntityID) then
            self:OnMajorSingOver(Params.EntityID, false)
        else
            self:BreakCurSingDisplay(Params.EntityID, nil, self.OverType.NORMAL_END)
        end
    end

	_G.InteractiveMgr:PrintInfo("SingBarMgr:StartTimer, time: " .. TimeUtil.GetLocalTimeMS())

    local TimerID = TimerMgr:AddTimer(nil, SingOver, SingTime / 1000, 1, 1, {EntityID = EntityID})
    self.TimerIDTable[EntityID] = TimerID

    return  SingTime
end

---锁定主角计时
---@param LifeTime number @剩余多少毫秒开始锁定主角
---@param LockTime number @锁定主角多少毫秒
function SingBarMgr:StartLockMajorTimer(EntityID, LifeTime, LockTime)
    _G.InteractiveMgr:PrintInfo("SingBar StartLockMajor "..tostring(LifeTime).." "..tostring(LockTime).. " "..TimeUtil.GetLocalTimeMS())
    local LastTimerID = self.TimerLockTable[EntityID]
    if LastTimerID and LastTimerID > 0 then
        TimerMgr:CancelTimer(LastTimerID)
    end

    if MajorUtil.IsMajor(EntityID) then
        local CallBack = function()
            local Major = MajorUtil.GetMajor()
            if Major then
                Major:LockInput((LockTime or 2000) / 1000 + 0.2) --加0.2秒临界值保护,避免连续锁定的情况中间有几帧能操作
            end
        end
        local TimerID = TimerMgr:AddTimer(nil, CallBack, LifeTime / 1000, 1, 1)
        self.TimerLockTable[EntityID] = TimerID
    end
end

function SingBarMgr:IsMoveableSingStateID(SingStateID)
    local SingstateDesc = SingstateCfg:FindCfgByKey(SingStateID)
    if SingstateDesc then
        return SingstateDesc.IsMovable == 1
    end
    return false
end

----------------------------------------  内部接口 end ------------------------

return SingBarMgr