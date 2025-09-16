local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local BuffUtil = require("Utils/BuffUtil")
local BuffCfg = require("TableCfg/BuffCfg")
local ActorUtil = require("Utils/ActorUtil")
local RichTextUtil = require("Utils/RichTextUtil")

local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")
local BuffDefine = require("Game/Buff/BuffDefine")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillActionUtil = require("Game/Skill/SkillAction/SkillActionUtil")
local EffectUtil = require("Utils/EffectUtil")
local ProtoCS = require("Protocol/ProtoCS")
local BuffTransferEffectCfg = require("TableCfg/BuffTransferEffectCfg")
local ChatDefine = require("Game/Chat/ChatDefine")

local LSTR = _G.LSTR

local SkillBuffMgr = LuaClass(MgrBase)

function SkillBuffMgr:OnInit()
    self.BuffList = {}
end

function SkillBuffMgr:OnBegin()
end

function SkillBuffMgr:OnEnd()
end

function SkillBuffMgr:OnShutdown()
end

function SkillBuffMgr:OnRegisterNetMsg()
end

function SkillBuffMgr:OnRegisterGameEvent()
    local EventID = _G.EventID
    self:RegisterGameEvent(EventID.UpdateBuff, self.OnCastBuff)
    self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
    self:RegisterGameEvent(EventID.UpdateBuffEffectiveState, self.OnUpdateBuffEffectiveState)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
    self:RegisterGameEvent(EventID.AttackEffectChange, self.OnGameEventAttackEffectChange)

    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)  -- 玩家登录或者断线重连
end

--拉取主角的buffs
function SkillBuffMgr:OnMajorCreate(Params)
    if nil == Params then
        return
    end

    _G.CombatMgr:SendSyncBuffReq(Params.ULongParam1)
end

function SkillBuffMgr:RemoveAllBuff(IsSendEvent)
    IsSendEvent = IsSendEvent or false
	local Major = MajorUtil.GetMajor()
	if Major then
		local BuffComp = Major:GetBuffComponent()
		if BuffComp then
			BuffComp:RemoveAllBuff(IsSendEvent)
		end
	end

    self:CloseTickTimer()

	self.BuffList = {}
    MajorBuffVM:UpdateBuffs()
end

function SkillBuffMgr:OnRegisterTimer()
end

function SkillBuffMgr:CloseTickTimer()
    if self.TickTimer then
        TimerMgr:CancelTimer(self.TickTimer)
        FLOG_INFO("SkillBuffMgr Close TickTimer")
        self.TickTimer = nil
    end
end

local SYSCHATMSGBATTLETYPE_BUFFUPDATE<const> = ChatDefine.SysChatMsgBattleType.BuffUpdate
function SkillBuffMgr:OnCastBuff(Params)
    local EntityID = Params.ULongParam1
    if MajorUtil.GetMajorEntityID() ~= EntityID then
        return
    end

    _G.EventMgr:SendEvent(_G.EventID.MajorUpdateBuff, Params)

    local BuffID = Params.IntParam1
    local IsHasBuff = Params.BoolParam1
    local GiverID = Params.ULongParam2
    local BuffTime = BuffUIUtil.GetLeftTimeSecondByExpdTime(Params.ULongParam3)

    local BuffInfo, BuffIndex = BuffUtil.FindBuff(BuffID, GiverID, self.BuffList)

    if nil ~= BuffInfo then
        --玩家身上有该buff，直接更新buff时间
        BuffInfo.ExpdTime = Params.ULongParam3 --+ 100 + (BuffInfo.LeftTime - math.floor(BuffInfo.LeftTime))

        -- _G.UE.FProfileTag.UnsafeStaticBegin("MajorInfoRefreshBuffTime")
        _G.EventMgr:SendEvent(_G.EventID.MajorInfoRefreshBuffTime, BuffIndex, true, BuffTime)
        -- _G.UE.FProfileTag.UnsafeStaticEnd()
        if not IsHasBuff then
            _G.FLOG_WARNING("SkillBuffMgr.OnCastBuff(): Buff (%d) already exists.", BuffID)
            IsHasBuff = true
        end
    elseif IsHasBuff and nil == BuffInfo then
        _G.FLOG_WARNING("SkillBuffMgr.OnCastBuff(): Buff (%d) does not exists.", BuffID)
        IsHasBuff = false
    end

    --玩家身上无该buff，创建buffWidget并Init
    if not IsHasBuff then
        local Cfg = BuffCfg:FindCfgByKey(BuffID)
        if not Cfg then
            _G.FLOG_ERROR("SkillBuffMgr.OnCastBuff(): Invalid BuffID (%d).", BuffID)
            return
        end

        BuffInfo = {}
        BuffInfo.BuffID = BuffID
        BuffInfo.IsBuffTimeDisplay = Cfg.IsBuffTimeDisplay
        BuffInfo.ExpdTime = Params.ULongParam3  -- + 100
        BuffInfo.LeftTime = BuffTime  -- + 0.1
        BuffInfo.GiverID = Cfg.IsIndependent > 0 and GiverID or 0
        BuffInfo.Pile = Params.IntParam2
        BuffInfo.BuffName = Cfg.BuffName
        BuffInfo.DisplayType = Cfg.DisplayType
        BuffInfo.BuffGiverID = GiverID or 0
        table.insert(self.BuffList, BuffInfo)
        -- _G.UE.FProfileTag.UnsafeStaticBegin("MajorInfoAddBuff")
        _G.EventMgr:SendEvent(_G.EventID.MajorInfoAddBuff, BuffInfo, true, self.BuffList)
        -- _G.UE.FProfileTag.UnsafeStaticEnd()

        -- _G.UE.FProfileTag.UnsafeStaticBegin("MajorInfoRefreshBuff")
        _G.EventMgr:SendEvent(_G.EventID.MajorInfoRefreshBuff, self.BuffList, true)
        -- _G.UE.FProfileTag.UnsafeStaticEnd()
    end

    ---BuffUI
    ---@type FCombatBuff
    local CombatBuffInfo = {
        BuffID = Params.IntParam1,
        Giver = Params.ULongParam2,
        ExpdTime = Params.ULongParam3,
        Pile = Params.IntParam2,
        AddTime = Params.ULongParam4,
    }
    --_G.UE.FProfileTag.UnsafeStaticBegin("AddOrUpdateBuff")
    MajorBuffVM:AddOrUpdateBuff(BuffID, BuffDefine.BuffSkillType.Combat, CombatBuffInfo)
    --_G.UE.FProfileTag.UnsafeStaticEnd()

     --战斗日志
    if nil ~= BuffInfo and BuffInfo.DisplayType ~= BuffDefine.BuffDisplayActiveType.Normal
        and BuffInfo.BuffID ~= BuffDefine.SysChatMsgIgnoreBuffID then
       -- _G.UE.FProfileTag.UnsafeStaticBegin("AddBuffUpdateMsg")
        BuffInfo.ChatType = SYSCHATMSGBATTLETYPE_BUFFUPDATE
        _G.SkillLogicMgr:PushSysChatMsgBattle(BuffInfo)
       -- _G.UE.FProfileTag.UnsafeStaticEnd()
    end

    -- _G.UE.FProfileTag.UnsafeStaticBegin("OnBuffInfoChange")
    self:OnBuffInfoChange(BuffID, true)
    -- _G.UE.FProfileTag.UnsafeStaticEnd()

end

function SkillBuffMgr:TimerUpdate(Params, DeltaTime)
    local bNoDurationBuff = true
    local CombatBuffCount = #self.BuffList

    for index = 1, CombatBuffCount do
        local BuffInfo = self.BuffList[index]

        if BuffInfo.IsBuffTimeDisplay == 1 then
            bNoDurationBuff = false
            BuffInfo.LeftTime = BuffUIUtil.GetLeftTimeSecondByExpdTime(BuffInfo.ExpdTime)
            -- BuffWidget:SetNewTime(BuffInfo.LeftTime)
            _G.EventMgr:SendEvent(_G.EventID.MajorInfoRefreshBuffTime, index, true, BuffInfo.LeftTime)
        end
    end

    if CombatBuffCount == 0 or bNoDurationBuff then
        self:CloseTickTimer()
    end
end

function SkillBuffMgr:OnUpdateBuffEffectiveState(Params)
    local GiverID = Params.ULongParam2
    if MajorUtil.GetMajorEntityID() == GiverID then
        local BuffID = Params.IntParam1
        local BuffStatus = Params.BoolParam1

        local _, BuffIndex = BuffUtil.FindBuff(BuffID, GiverID, self.BuffList)

        if BuffIndex and BuffIndex >= 1 then
            MajorBuffVM:UpdateBuffEffective(BuffDefine.BuffSkillType.Combat, BuffID, GiverID, BuffStatus)
            _G.EventMgr:SendEvent(_G.EventID.MajorInfoBuffEffectiveState, BuffIndex, BuffID, BuffStatus)
        end
    end
end

function SkillBuffMgr:OnRemoveBuff(Params)
    local EntityID = Params.ULongParam1
    if MajorUtil.GetMajorEntityID() == EntityID then

        _G.EventMgr:SendEvent(_G.EventID.MajorRemoveBuff, Params)

        local BuffID = Params.IntParam1
        local GiverID = Params.ULongParam2
        local BuffIns, Index = BuffUtil.FindBuff(BuffID, GiverID, self.BuffList)
        if BuffIns ~= nil and Index ~= nil then
            table.remove(self.BuffList, Index)
        end

        -- _G.UE.FProfileTag.StaticBegin("SkillBuffMgr1")
        MajorBuffVM:RemoveBuff(BuffID, GiverID, BuffDefine.BuffSkillType.Combat)
        -- _G.UE.FProfileTag.StaticEnd()
        -- _G.UE.FProfileTag.StaticBegin("SkillBuffMgr2")
        _G.EventMgr:SendEvent(_G.EventID.MajorInfoRefreshBuff, self.BuffList, true)
        -- _G.UE.FProfileTag.StaticEnd()

        -- _G.UE.FProfileTag.StaticBegin("SkillBuffMgr3")
        self:OnBuffInfoChange(Params.IntParam1, false)
    end
end

function SkillBuffMgr:IsBuffExist(BuffID)
    local BuffComp = MajorUtil.GetMajorBuffComponent()
    if BuffComp then
        return BuffComp:IsExistBuffForBuffID(BuffID or 0)
    end
end

--技能使用Buff限制
function SkillBuffMgr:SkillUseCanUseByBuffLimit(SkillID)
    local CanUse = true
    local BuffIDs = {
        ExcludeBuffList = {},
        MustAllRelayBuffList = {},
        AtLeastoneRelayBuffList = {}
    }
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if Cfg == nil then
        return false, BuffIDs
    end

    local BuffLimitCfg = Cfg.BuffLimit
    
    if BuffLimitCfg == nil then
        return false, BuffIDs
    end

    local BuffComp = MajorUtil.GetMajorBuffComponent()
    if BuffComp == nil  then
        return true,BuffIDs
    end
    
    if #BuffLimitCfg.ExcludeBuffList > 0 then
        for index, value in pairs(BuffLimitCfg.ExcludeBuffList) do
            local BuffID = value
            local BuffPile = BuffComp:GetBuffPile(BuffID)
            if BuffPile > 0 then
                table.insert(BuffIDs.ExcludeBuffList, {BuffID = BuffID})
            end
        end

        if #BuffIDs.ExcludeBuffList > 0 then
            CanUse = false
            return CanUse,BuffIDs
        end
    end

    if #BuffLimitCfg.AtLeastoneRelayBuffList > 0 then
        local hasNum = 0
        for index, value in pairs(BuffLimitCfg.AtLeastoneRelayBuffList) do
            local BuffID = value.BuffID
            local buffPile = value.BuffPile
            local BuffPile = BuffComp:GetBuffPile(BuffID)
            if BuffPile >= buffPile then
                hasNum = hasNum + 1
            else
                table.insert(BuffIDs.AtLeastoneRelayBuffList, {BuffID = BuffID, BuffPile=buffPile})        
            end
        end

        if hasNum <= 0 then
            CanUse = false
            return CanUse,BuffIDs
        end
    end

    if #BuffLimitCfg.MustAllRelayBuffList > 0 then
        for index, value in pairs(BuffLimitCfg.MustAllRelayBuffList) do
            local BuffID = value.BuffID
            local buffPile = value.BuffPile
            local BuffPile = BuffComp:GetBuffPile(BuffID)
            local tempResult=false
            if BuffPile < buffPile then
                table.insert(BuffIDs.MustAllRelayBuffList,{BuffID=BuffID, BuffPile=buffPile})
            end
        end

        if #BuffIDs.MustAllRelayBuffList > 0 then
            CanUse = false
            return CanUse,BuffIDs
        end
    end

    return CanUse,BuffIDs
end

function SkillBuffMgr:CanBuffAffectSkill(SkillID)
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if nil == Cfg then
        return false
    end
    local BuffLimitCfg = Cfg.BuffLimit
    if #BuffLimitCfg.AtLeastoneRelayBuffList == 0 and #BuffLimitCfg.MustAllRelayBuffList == 0 and #BuffLimitCfg.ExcludeBuffList == 0 then
        return false
    end
    return true
end

function SkillBuffMgr:OnBuffInfoChange(BuffID, bCast)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local BuffComponent = MajorUtil.GetMajorBuffComponent()
    if BuffComponent == nil then
        return
    end
    _G.SkillLogicMgr:SetSkillButtonEnable(
        MajorEntityID,
        SkillBtnState.BuffCondition,
        nil,
        function(_, SkillID)
            return BuffComponent:CanUseSkill(SkillID)
        end,
        BuffID
    )
end

function SkillBuffMgr:OnGameEventRoleLoginRes(Params)
    if Params.bReconnect then
        -- self:RemoveAllBuff(true)
        -- loiafeng: OnMajorCreate拉过了，这里就不拉了
        -- _G.CombatMgr:SendSyncBuffReq(MajorUtil.GetMajorEntityID()) --拉取主角的buffs
    end
end

function SkillBuffMgr:GetBuffList(Pred)
    if nil == Pred then
        return table.shallowcopy(self.BuffList)
    end

    local Ret = {}
    for Index, Val in pairs(self.BuffList) do
        if Pred(Index, Val) == true then
            table.insert(Ret, table.shallowcopy(Val))
        end
    end

    return Ret
end

function SkillBuffMgr:GetBuffHighestPileByID(ID)
    local Ret = 0
    for _, Val in pairs(self.BuffList) do
        if Val.BuffID == ID then
            local Pile = Val.Pile or 0
            Ret = Pile > Ret and Pile or Ret
        end
    end

    return Ret
end

--Get Major BuffInfo by BuffID
function SkillBuffMgr:GetBuffInfo(InBuffID)
	local BuffComponent = MajorUtil.GetMajorBuffComponent()
	if nil == BuffComponent then return end

    local BuffInfo = BuffComponent:FindBuffInfo(InBuffID)
    if BuffInfo then
        return BuffInfo.CombatBuffInfo
    end
end



---GetActorBuffInfos
function SkillBuffMgr:GetActorBuffInfos(EntityID)
    return _G.UE.UBuffComponent.FindAllBuffInfos(EntityID)
end

--战斗消息提示
local BUFF_DISPLAY_TYPE_POSITIVE<const> = ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_POSITIVE
function SkillBuffMgr:AddBuffUpdateMsg(Params)
    -- local _ <close> = CommonUtil.MakeProfileTag("AddBuffUpdateMsg")
	if nil == Params.BuffName or nil == Params.DisplayType then
		return
	end
	local BuffGiver = ActorUtil.GetActorName(Params.BuffGiverID)
	if nil == BuffGiver or "" == BuffGiver then
		return
	end
    local IconPath = "Texture2D'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_Fight1_png.UI_Chat_Icon_Fight1_png'"
    local BuffName = RichTextUtil.GetText(string.format("%s",LSTR(Params.BuffName)),"d1ba8e")
    local BuffGiverRichText = RichTextUtil.GetText(string.format(LSTR(140086), BuffGiver),"d1ba8e")
    local ContentLSTR =""
	if Params.DisplayType == BUFF_DISPLAY_TYPE_POSITIVE then
        IconPath = "Texture2D'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_Fight2_png.UI_Chat_Icon_Fight2_png'"
        local DisplayTypeIcon = RichTextUtil.GetTexture(IconPath,40, 40, -10)
        local ContentLSTR2 = string.format("%s%s", DisplayTypeIcon, BuffName)
        --你获得了
        ContentLSTR = string.format(LSTR(140087), ContentLSTR2)
    else
        local DisplayTypeIcon = RichTextUtil.GetTexture(IconPath,40, 40, -10)
        local ContentLSTR2 = string.format("%s%s", DisplayTypeIcon, BuffName)
        --你被附加了
        ContentLSTR = string.format(LSTR(140088), ContentLSTR2)
    end
    local Content = string.format("%s%s",ContentLSTR, BuffGiverRichText)
    
	_G.ChatMgr:AddSysChatMsgBattle(Content)
end

local CS_ATTACK_EFFECT_BUFF_TRANSFER <const> = ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_BUFF_TRANSFER
local EID_None <const> = _G.UE.EVFXEID.NONE
local AttachPointType_Max <const> = _G.UE.EVFXAttachPointType.AttachPointType_Max
local VfxParameter = _G.UE.FVfxParameter()
VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_UBuffComponent

function SkillBuffMgr:OnGameEventAttackEffectChange(Params)
    if nil == Params then
        return
    end

    if Params.EffectType == CS_ATTACK_EFFECT_BUFF_TRANSFER then
        local GiverID = Params.AttackObjID
        local Giver  = ActorUtil.GetActorByEntityID(GiverID)
        local TargetID = Params.BehitObjID
        local Target = ActorUtil.GetActorByEntityID(TargetID)
        local BuffID   = Params.BuffID

        if not Giver or not Target or not BuffID then
            return
        end

        local Cfg = BuffTransferEffectCfg:FindCfgByKey(BuffID)
        if not Cfg then
            return
        end

        local VfxRequireData = VfxParameter.VfxRequireData
        VfxRequireData.EffectPath = CommonUtil.ParseBPPath(Cfg.EffectPath)
        VfxRequireData.VfxTransform = Giver:FGetActorTransform()

        local LODLevel, bHighPriority = SkillActionUtil.GetLODLevel(GiverID)
        VfxParameter.LODLevel = LODLevel
        VfxRequireData.bAlwaysSpawn = bHighPriority
        VfxParameter:SetCaster(Giver, EID_None, AttachPointType_Max, 0)
        VfxParameter.Targets:Clear()
        VfxParameter:AddTarget(Target, EID_None, AttachPointType_Max, 0)

        EffectUtil.PlayVfx(VfxParameter)
    end
end

---
---
-----DEBUG
function SkillBuffMgr:AddSysChatMsgBattleDebug(BuffID)
    local BuffInfo = {}
    BuffInfo.BuffID = BuffID
    local Cfg = BuffCfg:FindCfgByKey(BuffInfo.BuffID)
    if nil ~= Cfg then
        BuffInfo.ChatType = SYSCHATMSGBATTLETYPE_BUFFUPDATE
        BuffInfo.DisplayType = Cfg.DisplayType
        BuffInfo.BuffGiverID = MajorUtil.GetMajorEntityID() or 0
        BuffInfo.BuffName = Cfg.BuffName
    end  
    return BuffInfo
end
return SkillBuffMgr
