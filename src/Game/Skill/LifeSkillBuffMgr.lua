local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local EffectUtil = require("Utils/EffectUtil")
local ProtoCS = require("Protocol/ProtoCS")
local BuffUtil = require("Utils/BuffUtil")
local AudioUtil = require("Utils/AudioUtil")
local ActorUtil = require("Utils/ActorUtil")

local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")
local BuffDefine = require("Game/Buff/BuffDefine")

local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD

--[[
    Util
]]
local function MajorEID()
    return MajorUtil.GetMajorEntityID()
end

local function IsMajor(EID)
    return MajorEID() == EID
end

local function MakeBuffInfo()
    return {
        Map = {},
        List = {},
    }
end

local function AddBuffInner(Context, EID, BuffInfo, BuffID)
    BuffID = BuffID or BuffInfo.BuffID
    if not Context.Map[EID] then
        Context.Map[EID] = MakeBuffInfo()
    end

    Context.Map[EID].Map[BuffID] = BuffInfo
    table.insert(Context.Map[EID].List, BuffInfo)
end

local function GetBuffRemoveType(BuffID)
    local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if BuffCfg and BuffCfg.RemoveType then
        return BuffCfg.RemoveType
    end

    return nil
end

---计时或者计次的Buff都要显示
local function IsBuffTimeDisplay(Ty)
    return Ty ~= ProtoRes.REMOVE_TYPE.REMOVE_TYPE_NONE
end

local function RemoveBuffInner(Context, EID, BuffID)
    if not Context.Map[EID] then return end
    local EBuffInfo = Context.Map[EID]
    EBuffInfo.Map[BuffID] = nil
    table.array_remove_item_pred(EBuffInfo.List, function(Item)
        return Item.BuffID == BuffID
    end, 1)
    if #EBuffInfo.List == 0 then
        Context.Map[EID] = nil
    end
end

--[[
    Template
]]
local LifeSkillBuffMgr = LuaClass(MgrBase)

function LifeSkillBuffMgr:OnInit()
    self.Map = {}
    self.IsCrafterProfSkilling = false
    self.CacheMsgBodyList = {}
end

function LifeSkillBuffMgr:OnBegin()
end

function LifeSkillBuffMgr:OnEnd()
end

function LifeSkillBuffMgr:OnShutdown()
    for _, EntityBuff in pairs(self.Map) do
        for _, Buff in pairs(EntityBuff) do
            self:RemoveBuffEfx(Buff)
        end

    end

    self.Map = {}
    self.IsCrafterProfSkilling = false
    self.CacheMsgBodyList = {}

    self:CloseTickTimer()
end

function LifeSkillBuffMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_BUFF_CMD, self.OnNetMsgSkillBuff)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_PULLBUFF_CMD, self.OnNetMsgPullSkillBuff)

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnVisionEnter)	    --进入视野同步
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY, self.OnVisionQuery)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_LEAVE, self.OnVisionLeave)
end

function LifeSkillBuffMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)
    --退出地图   战斗buff、生活buff都要清理
    self:RegisterGameEvent(EventID.WorldPreLoad, self.RemoveAllBuff)

	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfSwitch)

    -- self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)  -- 玩家登录或者断线重连
end

function LifeSkillBuffMgr:OnRegisterTimer()
end

--[[
    Handler
]]
--主角死亡，把所有的生活技能buff都清理掉
function LifeSkillBuffMgr:OnGameEventMajorDead()
	-- _G.UE.FProfileTag.StaticBegin("LifeSkillBuffMgr")

    self:ClearMajorBuffImme()
    -- self:CloseTickTimer() ---check?

	-- _G.UE.FProfileTag.StaticEnd()
end

function LifeSkillBuffMgr:OnPWorldEnter(Params)
    if MajorUtil.IsGpProf() or MajorUtil.IsCrafterProf() then
        self:ClearBuffsAndPull()
    end

    self:OnMajorProfSwitch()
end

function LifeSkillBuffMgr:OnMajorProfSwitch(Params)
    if MajorUtil.IsCrafterProf() then
        self:UnRegisterGameEventDynamic()
        
        self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
        self:RegisterGameEvent(_G.EventID.SkillEnd, self.OnSkillEnd)
        self:RegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
        self:RegisterGameEvent(_G.EventID.CrafterExitRecipeState, self.OnExitRecipeState)
    else
        self:UnRegisterGameEventDynamic()
    end
end

function LifeSkillBuffMgr:UnRegisterGameEventDynamic()
    self:UnRegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
    self:UnRegisterGameEvent(_G.EventID.SkillEnd, self.OnSkillEnd)
    self:UnRegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
    self:UnRegisterGameEvent(_G.EventID.CrafterExitRecipeState, self.OnExitRecipeState)
end

-- function LifeSkillBuffMgr:OnGameEventRoleLoginRes(Params)
--     if Params.bReconnect then
--     end
-- end

function LifeSkillBuffMgr:ClearBuffsAndPull()
    --清空当前的生活技能Buff，重新拉取生活技能Buff进行更新
    self:ClearMajorBuffImme()
    MajorBuffVM:ClearLifeSkillBuffs()
    self:PullBuffs()
end

function LifeSkillBuffMgr:OnSkillEnd(Params)
	-- local SkillID = Params.IntParam2
	-- local EntityID = Params.ULongParam1
    self.IsCrafterProfSkilling = false

    -- self:DoAllCacheMsgList()
end

function LifeSkillBuffMgr:OnMajorUseSkill(Params)
	-- local SkillID = Params.IntParam1
    self.IsCrafterProfSkilling = true
end

function LifeSkillBuffMgr:DoAllCacheMsgList()
    for index = 1, #self.CacheMsgBodyList do
        self:DoNetMsgSkillBuff(self.CacheMsgBodyList[index])
    end

    self.CacheMsgBodyList = {}
end

function LifeSkillBuffMgr:OnEventCrafterSkillRsp(_, AddBuffAnimDelay)
    self.AddBuffAnimDelay = AddBuffAnimDelay
    self:DoAllCacheMsgList()
    self.AddBuffAnimDelay = 0
    self.IsCrafterProfSkilling = false
end

function LifeSkillBuffMgr:OnExitRecipeState(EntityID)
    if not IsMajor(EntityID) then
        return
    end

    local TimerMgr = _G.TimerMgr
    TimerMgr:CancelTimer(self.BuffAnimTimerID)
    self.IsCrafterProfSkilling = false
    self:DoAllCacheMsgList()
end

function LifeSkillBuffMgr:PullBuffs()
    FLOG_INFO("LifeSkillBuffMgr PullBuffs")

    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_PULLBUFF_CMD

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LifeSkillBuffMgr:OnNetMsgPullSkillBuff(MsgBody)
    local BuffRsp = MsgBody.Buff or {}
    FLOG_INFO("LifeSkillBuffMgr OnNetMsgPullSkillBuff")
    if BuffRsp.Type == ProtoCS.LifeSkillBuffOp.LIFE_SKILL_BUFF_ADD then
        self:AddBuffList(BuffRsp.BuffList, MajorEID())
    end
end

function LifeSkillBuffMgr:OnVisionQuery(MsgBody)
    -- print("ZHG LifeSkillBuffMgr:OnVisionQuery MsgBody = " .. table_to_string_block(MsgBody, 10))
    local Msg = MsgBody.Query
    for _, VEntity in ipairs(Msg.Entities or {}) do
        self:SyncVisionBuffAdd(VEntity)
    end
end

function LifeSkillBuffMgr:OnVisionEnter(MsgBody)
    -- print("ZHG LifeSkillBuffMgr:OnVisionEnter MsgBody = " .. table_to_string_block(MsgBody, 10))
    for _, VEntity in ipairs(MsgBody.Enter.Entities or {}) do
        self:SyncVisionBuffAdd(VEntity)
    end
end

function LifeSkillBuffMgr:OnVisionLeave(MsgBody)
    -- print("ZHG LifeSkillBuffMgr:OnVisionLeave MsgBody = " .. table_to_string_block(MsgBody, 10))
    for _, VEntity in ipairs(MsgBody.Entities or {}) do
        self:SyncVisionBuffRemove(VEntity)
    end
end

function LifeSkillBuffMgr:Update(Params, DeltaTime)
    local ServerTime = TimeUtil.GetServerTimeMS()

    for EID, Info in pairs(self.Map) do
        for BuffID, BuffInfo in pairs(Info.Map) do
            --对于计次的buff，是无限生命期的
            --对于计时的buff，需要tick是否结束
            if BuffInfo.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION then
                Info.Map[BuffID].LeftTime = Info.Map[BuffID].LeftTime - DeltaTime

                if BuffInfo.ExpdTime < ServerTime then
                    FLOG_INFO("LifeSkillBuffMgr Update, buffID:%d is overtime", BuffID)

                    --延迟buff
                    if BuffInfo.DelayRemove == 1 and _G.FishMgr:StateKeepDelayRemoveBuff() then
                        Info.Map[BuffID].LeftTime = 0
                    else
                        self:RemoveBuff(BuffID, EID)
                    end
                end

                self:CheckCloseTickTimer()
            -- 有一些无限次数的Buff，他的RemainingCount <= 0，故这里不处理
            -- elseif BuffInfo.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_COUNT then
            --     if BuffInfo.RemainingCount <= 0 then
            --         self:RemoveBuff(BuffID, EID)
            --     end
            end
        end
    end

    local bNoDurationBuff = true
    local LifeSkillBuffCount = 0
    local MajorID = MajorEID()
    for EID, Info in pairs(self.Map) do
        for Idx, BuffInfo in ipairs(Info.List) do
            if BuffInfo.IsBuffTimeDisplay == true then
                LifeSkillBuffCount = LifeSkillBuffCount + 1
                bNoDurationBuff = false
                BuffInfo.LeftTime = (BuffInfo.ExpdTime - ServerTime) / 1000
                _G.EventMgr:SendEvent(_G.EventID.UpdateBuffTimeLife, BuffInfo)
                if EID == MajorID then
                    _G.EventMgr:SendEvent(_G.EventID.MajorInfoRefreshBuffTime, Idx, false, BuffInfo.LeftTime)
                end
            end
        end
    end

    if LifeSkillBuffCount == 0 or bNoDurationBuff then
        self:CloseTickTimer()
    end
end

function LifeSkillBuffMgr:OnNetMsgSkillBuff(MsgBody)
    local EID = MsgBody.ObjID
    local BuffRsp = MsgBody.Buff

    if (not EID) or (not BuffRsp) then return end

    --只缓存主角自己的
    if self.IsCrafterProfSkilling and EID == MajorUtil.GetMajorEntityID() then
        table.insert(self.CacheMsgBodyList, MsgBody)
        return 
    end

    if #self.CacheMsgBodyList > 0 then
        -- 保证时序, 如果有Cache的Buff未处理, 先处理完
        FLOG_WARNING("[LifeSkillBuffMgr:OnNetMsgSkillBuff] Unprocessed data detected, DoAllCacheMsgList first.")
        self:DoAllCacheMsgList()
    end
    self:DoNetMsgSkillBuff(MsgBody)
end

function LifeSkillBuffMgr:DoNetMsgSkillBuff(MsgBody)
    local EID = MsgBody.ObjID
    local BuffRsp = MsgBody.Buff

    if (not EID) or (not BuffRsp) then return end
    if BuffRsp.Type == ProtoCS.LifeSkillBuffOp.LIFE_SKILL_BUFF_ADD then
        self:AddBuffList(BuffRsp.BuffList, EID)
    elseif BuffRsp.Type == ProtoCS.LifeSkillBuffOp.LIFE_SKILL_BUFF_UPDATE then
        self:OnUpdateBuff(BuffRsp.BuffList, EID)
    elseif BuffRsp.Type == ProtoCS.LifeSkillBuffOp.LIFE_SKILL_BUFF_REMOVE then
        self:RemoveBuffList(BuffRsp.BuffList, EID)
    end
end

--[[
    Data Operater
]]

function LifeSkillBuffMgr:SyncVisionBuffAdd(VEntity)
    if VEntity.Role then
        local BuffList = VEntity.Role.LifeBuffList
        if BuffList then
            for _, Data in ipairs(BuffList.BuffList or {}) do
                -- 视野同步的Buff，不播特效和声音
                self:AddBuff(Data, VEntity.ID, true)
            end
        end

    end
end

function LifeSkillBuffMgr:SyncVisionBuffRemove(VEntity)
    self:ClearEntityBuffImme(VEntity.ID)
end

function LifeSkillBuffMgr:RemoveAllBuff()
	self:CloseTickTimer()

    self:ClearMajorBuffImme()

	self.Map = {}
    MajorBuffVM:UpdateBuffs()
end

function LifeSkillBuffMgr:AddBuffList(BuffList, EID)
    for Idx = 1, #BuffList do
        self:AddBuff(BuffList[Idx], EID)
    end
end

function LifeSkillBuffMgr:AddBuff(BuffData, EID, NotDisplay)
    if not self.Map[EID] then
        self.Map[EID] = MakeBuffInfo()
    end
    local BuffMap = self.Map[EID].Map

    local ServerTime = TimeUtil.GetServerTimeMS()

    local BuffID =BuffData.BuffID
    local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if not BuffCfg then
        return
    end

    local BuffInfo = BuffMap[BuffID]
    if not BuffInfo then
        local BuffRemoveType = BuffCfg.RemoveType
        BuffInfo = {
            EntityID = EID,
            BuffType = BuffDefine.BuffSkillType.Life,
            BuffID =BuffData.BuffID,
            DelayRemove = BuffCfg.DelayRemove,
            ExpdTime =BuffData.ExpdTime,
            LeftTime =BuffData.ExpdTime - ServerTime,
            RemainingCount =BuffData.RemainingCount or BuffData.RemainCount, -- Actor 和 Major协议不同， 兼容下
            BuffRemoveType = BuffRemoveType,
            bShowFlyTextWhenPileIncreased = BuffCfg.bShowFlyTextWhenPileIncreased == 1 and true or false,
            IsBuffTimeDisplay = IsBuffTimeDisplay(BuffRemoveType),
            GiverID = EID, -- 规定生活buf的Giver就是自己
            Pile = BuffData.Pile or 0,
            AddedTime = BuffData.AddedTime or 0,  -- 对于计次buff，该值为添加工次
        }

        AddBuffInner(self, EID, BuffInfo, BuffID)
        if not NotDisplay then
            self:OnAddBuff(BuffInfo, EID)
        end
        self:AddBuffNtf(BuffInfo, EID)
        FLOG_INFO("LifeSkillBuffMgr AddBuffList, id:%d", BuffID)
    else
        BuffInfo = {}
        BuffInfo.ExpdTime =BuffData.ExpdTime
        BuffInfo.LeftTime =BuffData.ExpdTime - ServerTime
        BuffInfo.RemainingCount =BuffData.RemainingCount
        BuffInfo.IsAlreadyHas = true
        BuffInfo.DelayRemove = BuffCfg.DelayRemove
        BuffInfo.BuffID = BuffData.BuffID
        BuffInfo.Pile = BuffData.Pile or 0  -- # TODO 视野更新包里面的Buff不带Pile层数, 不过好像也没啥影响
        BuffInfo.AddedTime = BuffData.AddedTime or 0

        self:UpdateBuff(BuffInfo, EID)
        FLOG_WARNING("LifeSkillBuffMgr AddBuffList, but already has: %d", BuffID)
    end

    if BuffInfo.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION and not self.TickTimer then
        self.TickTimer = TimerMgr:AddTimer(self, self.Update, 0, 1, 0)
        FLOG_INFO("LifeSkillBuffMgr Start TickTimer")
    end
end

function LifeSkillBuffMgr:OnAddBuff(BuffInfo, EID)
    local BuffID = BuffInfo.BuffID

    -- 播特效
    self:AddBuffEfx(BuffInfo, EID)

    if IsMajor(EID) then
         -- 播加buf音效
        local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)

        local OnAddAudio = BuffCfg.OnAddAudio
        if nil ~= OnAddAudio and "" ~= OnAddAudio then
            AudioUtil.LoadAndPlay2DSound(OnAddAudio)
        end
    end
end

function LifeSkillBuffMgr:AddBuffNtf(BuffInfo, EID)
    local EBuffInfo = self.Map[EID]

    if IsMajor(EID) then
        local AddBuffAnimDelay = self.AddBuffAnimDelay or 0

        local VMAddBuffFunc = function()
            MajorBuffVM:AddOrUpdateBuff(BuffInfo.BuffID, BuffDefine.BuffSkillType.Life, BuffInfo)
            _G.EventMgr:SendEvent(EventID.AddLifeSkillBuff, BuffInfo)
        end

        if AddBuffAnimDelay > 0 then
            self.BuffAnimTimerID = _G.TimerMgr:AddTimer(self, VMAddBuffFunc, AddBuffAnimDelay, 0, 1)
        else
            VMAddBuffFunc()
        end

        -- 暂时放这， 貌似和MajorInfoAddBuff重合的
        _G.EventMgr:SendEvent(EventID.MajorAddBuffLife, BuffInfo, AddBuffAnimDelay)
        _G.EventMgr:SendEvent(_G.EventID.MajorInfoAddBuff, BuffInfo, false, EBuffInfo.List)
        _G.EventMgr:SendEvent(_G.EventID.MajorInfoRefreshBuff, EBuffInfo.List, false)
    else
        _G.EventMgr:SendEvent(EventID.AddLifeSkillBuff, BuffInfo)
    end
end

--目前是没用到这个remove
function LifeSkillBuffMgr:RemoveBuffList(BuffList, EID)
    for index = 1, #BuffList do
        local BuffID = BuffList[index].BuffID
        self:RemoveBuff(BuffID, EID)
    end

    self:CheckCloseTickTimer()
end


--真正移除buff的时候会到这里来
function LifeSkillBuffMgr:RemoveBuff(BuffID, EID, NotDisplay)
    if not self.Map[EID] then return end
    local Buff = self.Map[EID].Map[BuffID]
    if not Buff then return end
    RemoveBuffInner(self, EID, BuffID)
    if not NotDisplay then
        self:OnRemoveBuff(Buff)
    end
    self:RemoveBuffNtf(Buff, EID)
end

function LifeSkillBuffMgr:OnRemoveBuff(Buff, EID)
    local BuffID = Buff.BuffID
    local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if not BuffCfg then
        return
    end

    -- 播特效
    self:RemoveBuffEfx(Buff)

    if IsMajor(EID) then
        -- 播音效
        local OnRemoveAudio = BuffCfg.OnRemoveAudio
        if nil ~= OnRemoveAudio and "" ~= OnRemoveAudio then
            AudioUtil.LoadAndPlay2DSound(OnRemoveAudio)
        end
    end
end

function LifeSkillBuffMgr:RemoveBuffNtf(BuffInfo, EID)
    _G.EventMgr:SendEvent(EventID.RemoveLifeSkillBuff, BuffInfo)
    if IsMajor(EID) then
       -- 暂时放这， 貌似和MajorInfoAddBuff重合的
       _G.EventMgr:SendEvent(EventID.MajorRemoveBuffLife, BuffInfo, self.AddBuffAnimDelay)
       MajorBuffVM:RemoveBuff(BuffInfo.BuffID, BuffInfo.GiverID, BuffDefine.BuffSkillType.Life)
       _G.EventMgr:SendEvent(_G.EventID.MajorInfoRefreshBuff, self.Map[EID] == nil and {} or self.Map[EID].List, false)
   end
end

function LifeSkillBuffMgr:ClearEntityBuffImme(EID)
    local EntityBuff = self.Map[EID]
    if not EntityBuff then return end

    for BuffID, _ in pairs(EntityBuff.Map) do
        self:RemoveBuff(BuffID, EID, true)
    end
end

function LifeSkillBuffMgr:CheckCloseTickTimer()
    local ShouldClose = true
    for _, EBuffInfo in pairs(self.Map) do
        for _, Buff in pairs(EBuffInfo.Map) do
            if Buff.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION then
                ShouldClose = false
                break
            end
        end

        if not ShouldClose then
            break
        end
    end

    if ShouldClose then
        self:CloseTickTimer()
    end
end

function LifeSkillBuffMgr:CloseTickTimer()
    if self.TickTimer then
        TimerMgr:CancelTimer(self.TickTimer)
        FLOG_INFO("LifeSkillBuffMgr Close TickTimer")
        self.TickTimer = nil
    end
end

--计次的才会update下来，计时的不会update下来
function LifeSkillBuffMgr:OnUpdateBuff(BuffList, EID)
    if not self.Map[EID] then return end
    local EBuffInfo = self.Map[EID]

    local ServerTime = TimeUtil.GetServerTimeMS()

    for index = 1, #BuffList do
        local BuffID = BuffList[index].BuffID
        local BuffInfo = EBuffInfo.Map[BuffID]

        if not BuffInfo then
            self:AddBuff(BuffList[index], EID)
            FLOG_WARNING("LifeSkillBuffMgr OnUpdateBuff, but don't has: %d", BuffID)
        else
            -- local lastRemainingCount = self.BuffMap[BuffID].RemainingCount
            -- if BuffList[index].RemainingCount > lastRemainingCount then         --加层数
            -- elseif BuffList[index].RemainingCount < lastRemainingCount then     --减层数
            -- end
            if BuffInfo.BuffRemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_COUNT then
                -- -1表示buff常驻
                if BuffList[index].RemainingCount == 0 then
                    self:RemoveBuff(BuffID, EID)
                    FLOG_INFO("LifeSkillBuffMgr OnUpdateBuff, id:%d, remaining cnt = 0, need remove", BuffID)
                else
                    self:UpdateBuff(BuffList[index], EID)
                    FLOG_INFO("LifeSkillBuffMgr OnUpdateBuff, id:%d, remaining cnt:%d", BuffID, BuffInfo.RemainingCount)
                end
            end
        end
    end
end

function LifeSkillBuffMgr:UpdateBuff(BuffData, EID)
    local BuffID = BuffData.BuffID
    local EBuffInfo = self.Map[EID]
    if not EBuffInfo then return end

    local Buff = EBuffInfo.Map[BuffID]
    if not Buff then
        self:AddBuff(BuffData, EID)
        return
    else
        Buff.IsAlreadyHas = true
    end

    local ServerTime = TimeUtil.GetServerTimeMS()
    BuffData.LeftTime = BuffData.ExpdTime - ServerTime

    if Buff.Pile < BuffData.Pile then
        Buff.bIsPileIncreased = true
    else
        Buff.bIsPileIncreased = false
    end

    for K, V in pairs(BuffData) do
        Buff[K] = V
    end

    if not Buff.EffectID or Buff.EffectID == 0 then
        FLOG_ERROR("LifeSkillBuffMgr OnUpdateBuff, id:%d, no effect, need play", BuffID)
        self:AddBuffEfx(Buff, EID)
    end

    _G.EventMgr:SendEvent(EventID.UpdateLifeSkillBuff, Buff)

    if IsMajor(EID) then
        local VMUpdateBuffFunc = function()
            MajorBuffVM:AddOrUpdateBuff(Buff.BuffID, BuffDefine.BuffSkillType.Life, Buff)
        end

        local AddBuffAnimDelay = self.AddBuffAnimDelay or 0
        if AddBuffAnimDelay > 0 then
            self.BuffAnimTimerID = _G.TimerMgr:AddTimer(self, VMUpdateBuffFunc, AddBuffAnimDelay, 0, 1)
        else
            VMUpdateBuffFunc()
        end

        _G.EventMgr:SendEvent(EventID.MajorUpdateBuffLife, Buff, AddBuffAnimDelay)
    end
end

--[[
    Method
]]

function LifeSkillBuffMgr:AddBuffEfx(BuffInfo, EID)
    --local FXParam = _G.UE.FActorFXParam()
    local VfxParameter = _G.UE.FVfxParameter()
    
    local Actor = ActorUtil.GetActorByEntityID(EID)
    local BuffID = BuffInfo.BuffID

    local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if not BuffCfg then
        FLOG_ERROR("LifeskillEffectCfg %d need Config", BuffID)
    else
        BuffInfo.EffectPath = BuffCfg.SpecialEffect
    end

    if Actor and BuffCfg then
        --[[ if BuffCfg.ActionType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION then
             FXParam.TimeLimit = BuffInfo.LeftTime
         else
             --使用默认值，c++构造-100
         end]]

        if BuffInfo.EffectID and BuffInfo.EffectID ~= 0 then
            EffectUtil.StopVfx(EffectID)
            --EffectUtil.BreakEffect(BuffInfo.EffectID)
        end
        VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(BuffInfo.EffectPath)
        VfxParameter.LODMethod = 2
        VfxParameter.LODLevel = 0
        VfxParameter.PlaySourceType= _G.UE.EVFXPlaySourceType.PlaySourceType_AetherCurrents
        local AttachPointType = _G.UE.EVFXAttachPointType.AttachPointType_Body
        VfxParameter:SetCaster(Actor, 0, AttachPointType, 0)
        --FXParam.AttachedComponent = Actor:GetMeshComponent()
        --FXParam.FXPath = BuffInfo.EffectPath
        --FXParam.LODMethod = 2
        --FXParam.LODLevel = 0
        --FXParam.SocketName = BuffCfg.EffectSocketName or ""
        -- local HalfHeight = Major:GetCapsuleHalfHeight()

        --[[if BuffCfg.EffectDeviation then
            local PosTable = string.split(BuffCfg.EffectDeviation, ",")
            FXParam.RelativeLocation =
                _G.UE.FVector(tonumber(PosTable[1]), tonumber(PosTable[2]), tonumber(PosTable[3]))
        end]]
        -- FXParam.SocketName  Relative*等 使用默认值
        BuffInfo.EffectID = EffectUtil.PlayVfx(VfxParameter)
        --BuffInfo.EffectID = EffectUtil.PlayEffect(FXParam)
    end
end

function LifeSkillBuffMgr:RemoveBuffEfx(BuffInfo)
    if BuffInfo.EffectPath and BuffInfo.EffectID and BuffInfo.EffectID ~= 0 then
        EffectUtil.StopVfx(BuffInfo.EffectID)
        --EffectUtil.BreakEffect(BuffInfo.EffectID)
    end
end

function LifeSkillBuffMgr:IsDurationBuff(BuffID)
    local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if BuffCfg and BuffCfg.RemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_DURATION then
        return true
    end

    return false
end

function LifeSkillBuffMgr:IsCountBuff(BuffID)
    local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if BuffCfg and BuffCfg.RemoveType == ProtoRes.REMOVE_TYPE.REMOVE_TYPE_COUNT then
        return true
    end

    return false
end

--[[
    Major相关
]]

function LifeSkillBuffMgr:GetMajorBuffInfo()
    local EID = MajorUtil.GetMajorEntityID()
    return self.Map[EID]
end

function LifeSkillBuffMgr:ClearMajorBuffImme()
    local EID = MajorUtil.GetMajorEntityID()
    self:ClearEntityBuffImme(EID)
end

--[[
    Public
]]

function LifeSkillBuffMgr:GetBuffInfo(BuffID, EID)
    if not self.Map[EID] then return end
    return self.Map[EID].Map[BuffID]
end

function LifeSkillBuffMgr:IsMajorContainBuff(BuffID)
    local MajorBuffInfo = self:GetMajorBuffInfo()
    if not MajorBuffInfo then return end
    return MajorBuffInfo.Map[BuffID] ~= nil
end

--- 实体是否有buff
---@param EntityID
---@param BuffID
function LifeSkillBuffMgr:HasBuff(EntityID, BuffID)
    local EBuffInfo = self.Map[EntityID]
    if not EBuffInfo then return end
    return EBuffInfo.Map[BuffID] ~= nil
end

function LifeSkillBuffMgr:GetMajorBuffList()
    local MajorBuffInfo = self:GetMajorBuffInfo()
    if not MajorBuffInfo then
        return {}
    end

    return MajorBuffInfo.List or {}
end

function LifeSkillBuffMgr:GetBuffList(EID)
    if not EID or not self.Map or not self.Map[EID] then return end
    return self.Map[EID].List or {}
end

function LifeSkillBuffMgr:GetMajorBuffPile(BuffID)
    local MajorBuffInfo = self:GetMajorBuffInfo()
    if not MajorBuffInfo then
        return
    end
    local BuffInfo = MajorBuffInfo.Map[BuffID]
    if BuffInfo then
        return BuffInfo.Pile
    end
end

function LifeSkillBuffMgr:MajorInitAllBuffInView(View, OnBuffAdd)
    local BuffMap = self:GetMajorBuffInfo()
	if not BuffMap or not View or not OnBuffAdd then
		return
	end
	BuffMap = BuffMap.Map
	if not BuffMap then
		return
	end
	for _, BuffInfo in pairs(BuffMap) do
        OnBuffAdd(View, BuffInfo)
	end
end

return LifeSkillBuffMgr