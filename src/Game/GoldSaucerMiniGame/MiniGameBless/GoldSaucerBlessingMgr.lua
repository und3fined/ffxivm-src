---
--- Author: Alex, Leo
--- DateTime: 2025-06-11 16:07:00
--- Description: 金蝶赐福管理
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local EffectUtil = require("Utils/EffectUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MapUtil = require("Game/Map/MapUtil")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local FairyBlessedTimeCfg = require("TableCfg/FairyBlessedTimeCfg")
local FairyBlessedWeightCfg = require("TableCfg/FairyBlessedWeightCfg")
local FairyBlessedTargetCfg = require("TableCfg/FairyBlessedTargetCfg")
local MainPanelVM = require("Game/Main/MainPanelVM")
local GoldSaucerBlessingVM = require("Game/GoldSaucerMiniGame/MiniGameBless/GoldSaucerBlessingVM")

local PWorldMgr
local GameNetworkMgr
local PWorldDynDataMgr
local ModuleOpenMgr
local RangeCheckTriggerMgr
local MapEditDataMgr

local CS_CMD = ProtoCS.CS_CMD
local MapDynType = ProtoCommon.MapDynType
local EffectType = MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local BLESSED_KIND = ProtoCS.Game.FairyBlessed.BLESSED_KIND
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState
local GoldSauserMapID = GoldSauserMainPanelDefine.GoldSauserMapID --目前赐福只对金碟游乐场地图生效 12060
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local MapMarkerNpc2GameID = GoldSaucerBlessingDefine.MapMarkerNpc2GameID
local MarkerIconWithState = GoldSaucerBlessingDefine.MarkerIconWithState
local GameID2Name = GoldSaucerBlessingDefine.GameID2Name
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local SecDef = 60


---@class GoldSaucerBlessingMgr : MgrBase
local GoldSaucerBlessingMgr = LuaClass(MgrBase)

function GoldSaucerBlessingMgr:OnInit()
    self.BlessEndTimer = nil                       -- 时间自然结束重新拉取下轮赐福信息的计时器
    self.BlessWarningTimer = nil                   -- 阶段结束预警计时器
    self.BlessStartTimer = nil                     -- 开始计时器由准备特效转为正式特效

    self.PrepareNpcListID2MachineID = nil          -- 表格配置预热npc与机器id映射
    self.RunningNpcListID2MachineID = nil          -- 表格配置进行npc与机器id映射
    self:LoadConfigDataForQuickSearch()
end

function GoldSaucerBlessingMgr:OnBegin()
    PWorldMgr = _G.PWorldMgr
    GameNetworkMgr = require("Network/GameNetworkMgr")
    PWorldDynDataMgr = require("Game/PWorld/DynData/PWorldDynDataMgr")
    ModuleOpenMgr = _G.ModuleOpenMgr
    RangeCheckTriggerMgr = _G.RangeCheckTriggerMgr
    MapEditDataMgr = _G.MapEditDataMgr
    self:InitBlessData()
end

function GoldSaucerBlessingMgr:OnEnd()
    self:ClearBlessData()
end

function GoldSaucerBlessingMgr:OnShutdown()
    self.PrepareNpcListID2MachineID = nil 
end

function GoldSaucerBlessingMgr:InitBlessData()
    self:StopTheRoundEndTimer()
    self.VfxHaneleIDMap = {}                       -- VfxMap Key为InstanceID Value为Vfx的HandleID
    self.MachineID = 0                             -- 赐福的机器ID
    self.BlessKind = 0                             -- 大赐福还是小赐福
    self.ServerStartTimestamp = 0                  -- 服务器下发赐福开始时间(当前进行中的赐福或下次开始的赐福时间) 单位：秒
    self.bMajorCompleted = false                   -- 玩家是否完成赐福(需保证及时更新)
end

function GoldSaucerBlessingMgr:ClearBlessData()
    self:StopTheRoundEndTimer()
    RangeCheckTriggerMgr:RemoveRangeCheckCustomMap(TriggerGamePlayType.GoldSauserBlessMachineCheck, self.MachineID)
    self.VfxHaneleIDMap = nil        -- VfxMap Key为InstanceID Value为Vfx的HandleID
    self.MachineID = nil                             -- 赐福的机器ID
    self.BlessKind = nil                             -- 大赐福还是小赐福
    self.ServerStartTimestamp = nil                -- 服务器下发赐福开始时间(当前进行中的赐福或下次开始的赐福时间)
    self.bMajorCompleted = nil
end

function GoldSaucerBlessingMgr:LoadConfigDataForQuickSearch()
    -- 加载活动权重表所有数据
    local WeightAllCfg = FairyBlessedWeightCfg:FindAllCfg()
    if not WeightAllCfg then
        FLOG_ERROR("GoldSaucerBlessingMgr:LoadConfigDataForQuickSearch Cannot Read Weight Data")
        return
    end
    local PrepareNpcListID2MachineID = self.PrepareNpcListID2MachineID or {}
    for _, WeightCfg in ipairs(WeightAllCfg) do
        local MachineID = WeightCfg.SgbID
        local PrepareNpcList = WeightCfg.PrepareNpcList
        if PrepareNpcList and MachineID then
            for _, NpcListID in ipairs(PrepareNpcList) do
                PrepareNpcListID2MachineID[NpcListID] = MachineID
            end
        end
    end
    self.PrepareNpcListID2MachineID = PrepareNpcListID2MachineID

    local RunningNpcListID2MachineID = self.RunningNpcListID2MachineID or {}
    for _, WeightCfg in ipairs(WeightAllCfg) do
        local MachineID = WeightCfg.SgbID
        local RunningNpcList = WeightCfg.RunningNpcList
        if RunningNpcList and MachineID then
            for _, NpcListID in ipairs(RunningNpcList) do
                RunningNpcListID2MachineID[NpcListID] = MachineID
            end
        end
    end
    self.RunningNpcListID2MachineID = RunningNpcListID2MachineID
end

function GoldSaucerBlessingMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify) --系统解锁
    self:RegisterGameEvent(EventID.PWorldDynAssetOnLandLoad, self.OnDynamicAssetLoadInLand)
    self:RegisterGameEvent(EventID.PWorldDynAssetOnLandUnLoad, self.OnDynamicAssetUnLoadInLand)
end

function GoldSaucerBlessingMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_BLESSED, ProtoCS.Game.FairyBlessed.CS_FAIRY_BLESSED_CMD.CS_FAIRY_BLESSED_CMD_GET, self.OnGetBlessStateRsp)
end

function GoldSaucerBlessingMgr:OnDynamicAssetLoadInLand(Params)
    if Params.ObjectParam == nil then
        return
    end

    local CurBlessState = self:GetBlessState()
    if CurBlessState == EBlessingState.NotBegin then
        return
    end

    local SgActor = Params.ObjectParam:Cast(_G.UE.ASgLayoutActorBase)
    if SgActor == nil then
        return
    end

    local InstanceID = PWorldMgr:FindSgActorInstanceID(SgActor)
    if not InstanceID then
        return
    end

    local CurMachineID = self.MachineID
    if not CurMachineID or CurMachineID ~= InstanceID then
        return
    end
  
    self:TryPlayBlessingVfx(CurMachineID)
end

function GoldSaucerBlessingMgr:OnDynamicAssetUnLoadInLand(Params)
    if (Params.ObjectParam == nil) then
        return
    end

    local CurBlessState = self:GetBlessState()
    if CurBlessState == EBlessingState.NotBegin then -- 非赐福模式不需要在动态物件卸载时回收特效
        return
    end
   
    local SgActor = Params.ObjectParam:Cast(_G.UE.ASgLayoutActorBase)
    if SgActor == nil then
        return
    end

    local InstanceID = PWorldMgr:FindSgActorInstanceID(SgActor)
    if not InstanceID then
        return
    end

    local CurMachineID = self.MachineID
    if not CurMachineID or CurMachineID ~= InstanceID then
        return
    end

    self:TryStopBlessingVfx(CurMachineID)
end


--- @type 当加载完世界
function GoldSaucerBlessingMgr:OnPWorldMapEnter(Params)
    if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGoldSauserMain) then
        return
    end
    if _G.DemoMajorType ~= 0 then
        return
    end
    local CurrMapResID = Params.CurrMapResID
    if CurrMapResID == GoldSauserMapID then
        self:SendMsgCheckBlessStateReq()
    else
        self:ClearBlessData() -- 如果
    end
end

function GoldSaucerBlessingMgr:OnModuleOpenNotify(InModuleID)
    if InModuleID == ProtoCommon.ModuleID.ModuleIDGoldSauserMain then
        local CurrMapResID = PWorldMgr:GetCurrMapResID()
        if CurrMapResID == GoldSauserMapID then -- 功能解锁时如果处于金碟游乐场需要拉取一次信息，如果不是不需要，因为进入地图时会拉取
            self:SendMsgCheckBlessStateReq()
        end
    end
end

function GoldSaucerBlessingMgr:OnPWorldExit(_, LeaveMapResID)
    if LeaveMapResID == GoldSauserMapID then
        self:ClearBlessData()  
    end
end

------ Msg Start ------
--- @type 查看赐福信息
function GoldSaucerBlessingMgr:SendMsgCheckBlessStateReq()
    local MsgID = CS_CMD.CS_CMD_FAIRY_BLESSED
    local SubMsgID = ProtoCS.Game.FairyBlessed.CS_FAIRY_BLESSED_CMD.CS_FAIRY_BLESSED_CMD_GET
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 赐福信息回包
function GoldSaucerBlessingMgr:OnGetBlessStateRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    local BlessedGetRsp = MsgBody.BlessedGetRsp
    if BlessedGetRsp == nil then
        return
    end

    local ServerStartTimestamp = BlessedGetRsp.StartTime
    local FormatTime = TimeUtil.GetTimeFormat("%Y-%m-%d %H:%M:%S", ServerStartTimestamp)
    FLOG_INFO("GoldSaucerBlessingMgr:OnGetBlessStateRsp ServerTime:%s", FormatTime)
    local ServerKind = BlessedGetRsp.BlessKind  -- 赐福类型 BLESSED_KIND
    if not ServerStartTimestamp or not ServerKind then
        return
    end
    local OldMachineID = self.MachineID
    self:InitBlessData()

    self.ServerStartTimestamp = ServerStartTimestamp
    self.BlessKind = ServerKind
    self.bMajorCompleted = BlessedGetRsp.Finish -- 以服务器为准

    local MachineID = BlessedGetRsp.MachineID
    if not MachineID then
        FLOG_ERROR("GoldSaucerBlessingMgr:OnGetBlessStateRsp MachineID is nil")
        return
    end
    
    self.MachineID = MachineID

    local BlessState = self:GetBlessState()
    if not BlessState then
        FLOG_ERROR("GoldSaucerBlessingMgr:OnGetBlessStateRsp BlessState is nil")
        return
    end
    
    if BlessState ~= EBlessingState.NotBegin then
        self:NotifyUpdateMapMarkerBlessStateChange(OldMachineID, MachineID)
        self:StartTheRoundEndTimer()
    else
        -- 当前赐福未开始，不更新新的机器标记的状态
        self:NotifyUpdateMapMarkerBlessStateChange(OldMachineID, nil)

        -- 如果预热开始时间位于当前时间之后,则开启定时器在预热时间开始后启动预热阶段
        local CurTimestamp = TimeUtil.GetServerLogicTime()
        local DelayToPrepareTime = 0
        local BlessTimeCfg = FairyBlessedTimeCfg:FindCfgByKey(ServerKind)
        if not BlessTimeCfg then
            FLOG_ERROR("GoldSaucerBlessingMgr:OnGetBlessStateRsp Cannot find the kind Bless")
            return
        end
        local PrepareSec = (BlessTimeCfg.PrepareTime or 0) * SecDef
        local PrepareStartTimestamp = ServerStartTimestamp - PrepareSec
        DelayToPrepareTime = PrepareStartTimestamp - CurTimestamp
        if DelayToPrepareTime > 0 then
            self:RegisterTimer(function()
                local BlessState = self:GetBlessState()
                if not BlessState then
                    FLOG_ERROR("GoldSaucerBlessingMgr:OnGetBlessStateRsp BlessState is nil")
                    return
                end
                local MachineID = self.MachineID
                if not MachineID then
                    return
                end
                
                self:NotifyUpdateMapMarkerBlessStateChange(nil, MachineID) -- 客户端计时开始赐福，更新当前赐福机器标记状态
                self:StartTheRoundEndTimer()
            end, DelayToPrepareTime)
        end
    end
end
------ Msg End ------

------ private ------

--- 通知地图标记模块更新标记状态 机器变化区别直接作为参数传入，判断是否有机器变化的逻辑由外部处理
function GoldSaucerBlessingMgr:NotifyUpdateMapMarkerBlessStateChange(OldMachineID, NewMachineID)
    local EvtParams = {}
    if OldMachineID then
        -- OldMachineID为脱离赐福状态的机器
        local OldWeightCfg = FairyBlessedWeightCfg:FindCfg(string.format("SgbID = %d", OldMachineID))
        if OldWeightCfg then
            local OldGameID = OldWeightCfg.Activity
            if OldGameID then
                local ExitMarkerParams = {
                    GameID = OldGameID, 
                    IconPath = self:GetTheMiniGameTypeMarkerIcon(OldGameID),
                    BlessState = EBlessingState.NotBegin,
                    BlessKind = BLESSED_KIND.BLESSED_KIND_NONE,
                }
                EvtParams.ExitMarkerParams = ExitMarkerParams
                if OldMachineID ~= NewMachineID then -- 不是同一台机器才进行回收特效的操作，同一台机器播放时会自行先回收旧的特效
                    self:TryStopBlessingVfx(OldMachineID)
                end
                RangeCheckTriggerMgr:RemoveRangeCheckCustomMap(TriggerGamePlayType.GoldSauserBlessMachineCheck, OldMachineID)
               
            end
        end
    end

    if NewMachineID then
        local NewWeightCfg = FairyBlessedWeightCfg:FindCfg(string.format("SgbID = %d", NewMachineID))
        if NewWeightCfg then
            local NewGameID = NewWeightCfg.Activity
            if NewGameID then
                local EnterMarkerParams = {
                    GameID = NewGameID, 
                    IconPath = self:GetTheMiniGameTypeMarkerIcon(NewGameID),
                    BlessState = self:GetBlessState(),
                    BlessKind = self:GetBlessKind(),
                }
                EvtParams.EnterMarkerParams = EnterMarkerParams
                self:TryPlayBlessingVfx(NewMachineID)
                RangeCheckTriggerMgr:AddRangeCheckCustomMap(TriggerGamePlayType.GoldSauserBlessMachineCheck, NewMachineID)
            end
        end
    end
    _G.EventMgr:SendEvent(EventID.MiniGameMarkerBlessStateChange, EvtParams)
end

--- 能否创建对应氛围Npc
function GoldSaucerBlessingMgr:CanCreateNpc(NpcList)
    local CurBlessState = self:GetBlessState()
    if not CurBlessState then -- 状态不合法
        return
    end
    local CurMachineID = self.MachineID
    if not CurMachineID then
        return -- 无合法机器
    end

    if CurBlessState == EBlessingState.Prepare then
        local PrepareNpcListID2MachineID = self.PrepareNpcListID2MachineID
        if not PrepareNpcListID2MachineID or not next(PrepareNpcListID2MachineID) then
            return -- 配置数据未读取
        end
        return PrepareNpcListID2MachineID[NpcList] == CurMachineID
    elseif CurBlessState == EBlessingState.InBlessingNormal or CurBlessState == EBlessingState.InBlessingWarning then
        local RunningNpcListID2MachineID = self.RunningNpcListID2MachineID
        if not RunningNpcListID2MachineID or not next(RunningNpcListID2MachineID) then
            return -- 配置数据未读取
        end
        return RunningNpcListID2MachineID[NpcList] == CurMachineID
    end
end

--- @type 尝试播放仙人赐福的特效
function GoldSaucerBlessingMgr:TryPlayBlessingVfx(InstanceID)
    self:TryStopBlessingVfx(InstanceID)
    local BlessState = self:GetBlessState()
    if BlessState == EBlessingState.NotBegin then
        return
    end
    
    local VfxEffectPath = GoldSaucerBlessingDefine.VfxEffectPath
    if not VfxEffectPath then
        return
    end

    local BlessKind = self:GetBlessKind()
    local VfxPath = VfxEffectPath.LittleVfx
    if BlessState == EBlessingState.Prepare then
        VfxPath = VfxEffectPath.PrepareVfx
    else
        if BlessKind == BLESSED_KIND.BLESSED_KIND_BIG then
            VfxPath = VfxEffectPath.BigVfx
        end
    end

    local SgTransform = _G.UE.FTransform()
    local bTheSgActorFound = PWorldMgr:GetInstanceAssetTransform(InstanceID, SgTransform)
    --local SgLocation = SgTransform:GetLocation()
    if bTheSgActorFound then
        local VfxParameter = _G.UE.FVfxParameter()
        VfxParameter.VfxRequireData.EffectPath = VfxPath
        -- VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_MiniGameCuff  后面要加新的Type
        VfxParameter.VfxRequireData.VfxTransform = SgTransform
        VfxParameter.VfxRequireData.bAlwaysSpawn = true
        local HandleID = EffectUtil.PlayVfx(VfxParameter)
        if BlessState == EBlessingState.InBlessingWarning then
            EffectUtil.KickTriggerByID(HandleID, 1)
        else
            EffectUtil.KickTriggerByID(HandleID, 0)
        end
        local VfxHaneleIDMap = self.VfxHaneleIDMap or {}
        VfxHaneleIDMap[InstanceID] = HandleID
        self.VfxHaneleIDMap = VfxHaneleIDMap
    end
end

-- lua GoldSaucerBlessingMgr:TryStopBlessingVfx(5360362)
--- @type 停止播放仙人赐福的特效
function GoldSaucerBlessingMgr:TryStopBlessingVfx(InstanceID)
    local VfxHaneleIDMap = self.VfxHaneleIDMap
    if not VfxHaneleIDMap then
        return
    end
    local HandleID = VfxHaneleIDMap[InstanceID]
    if HandleID ~= nil then
        --EffectUtil.KickTriggerByID(HandleID, 1)
        EffectUtil.StopVfx(HandleID)
        VfxHaneleIDMap[InstanceID] = nil
    end
end

--- 启动自然结束计时器
function GoldSaucerBlessingMgr:StartTheRoundEndTimer()
    local RoundStartTimestamp = self.ServerStartTimestamp
    if not RoundStartTimestamp then
        return
    end
  
    local BlessKind = self.BlessKind
    if not BlessKind or BlessKind == BLESSED_KIND.BLESSED_KIND_NONE then
        return
    end
   
    local TimeCfg = FairyBlessedTimeCfg:FindCfgByKey(BlessKind)
    if not TimeCfg then
        FLOG_ERROR("GoldSaucerBlessingMgr:StartTheRoundEndTimer FairyBlessedTimeCfg = nil")
        return
    end

    local function SendMsgGetNextRoundInfo()
        self:SendMsgCheckBlessStateReq()
    end

    local function PlayMachineWarningVfx()
        local MachineID = self.MachineID
        if not MachineID then
            return
        end
        local VfxHaneleIDMap = self.VfxHaneleIDMap
        if not VfxHaneleIDMap then
            return
        end

        local VfxID = VfxHaneleIDMap[MachineID]
        if VfxID then
            self:NotifyUpdateMapMarkerBlessStateChange(nil, self.MachineID)
        end
    end

    local BlessTime = TimeCfg.BlessTime * SecDef
    local WarningTime = TimeCfg.WarningTime * SecDef
    local CurTimestamp = TimeUtil.GetServerLogicTime()

    local DelayTimeToEndCall = RoundStartTimestamp + BlessTime - CurTimestamp
    local DelayTimeToWarningCall = DelayTimeToEndCall - WarningTime
    local DelayTimeToStartCall = RoundStartTimestamp - CurTimestamp

    -- 由未开始到开始后切换一次特效，若判定一开始则已在NotifyUpdateMapMarkerBlessStateChange内进行了PlayVfx操作
    if DelayTimeToStartCall > 0 then
        local BlessStartTimer = self.BlessStartTimer
        if BlessStartTimer then
            self:UnRegisterTimer(BlessStartTimer)
        end
        self.BlessStartTimer = self:RegisterTimer(function()
            self:NotifyUpdateMapMarkerBlessStateChange(nil, self.MachineID)
        end, DelayTimeToStartCall) 
    end


    if DelayTimeToWarningCall > 0 then
        local BlessWarningTimer = self.BlessWarningTimer
        if BlessWarningTimer then
            self:UnRegisterTimer(BlessWarningTimer)
        end
        self.BlessWarningTimer = self:RegisterTimer(PlayMachineWarningVfx, DelayTimeToWarningCall) 
    end
    

    if DelayTimeToEndCall > 0 then
        local BlessEndTimer = self.BlessEndTimer
        if BlessEndTimer then
            self:UnRegisterTimer(BlessEndTimer)
        end
        self.BlessEndTimer = self:RegisterTimer(SendMsgGetNextRoundInfo, DelayTimeToEndCall)
    end
end

--- 停止自然结束计时器
---@param bSaveEndTimer boolean@是否保留结束计时器
function GoldSaucerBlessingMgr:StopTheRoundEndTimer(bSaveEndTimer)
    local BlessEndTimer = self.BlessEndTimer
    if BlessEndTimer and not bSaveEndTimer then
        self:UnRegisterTimer(BlessEndTimer)
        self.BlessEndTimer = nil
    end
    local BlessWarningTimer = self.BlessWarningTimer
    if BlessWarningTimer then
        self:UnRegisterTimer(BlessWarningTimer)
        self.BlessWarningTimer = nil
    end

    local BlessStartTimer = self.BlessStartTimer
    if BlessStartTimer then
        self:UnRegisterTimer(BlessStartTimer)
        self.BlessStartTimer = nil
    end

    -- 理论上当前赐福结束时清除所有特效
    local VfxHaneleIDMap = self.VfxHaneleIDMap
    if not VfxHaneleIDMap or not next(VfxHaneleIDMap) then
        return
    end
    for MachineID, _ in pairs(VfxHaneleIDMap) do
        self:TryStopBlessingVfx(MachineID)
    end

    self:HideRightTopPanel()
end

--- 启动面板倒计时计时器
function GoldSaucerBlessingMgr:StartTheTopRightPanelCountDownTimer()
    local TopRightPanelCountDownTimer = self.TopRightPanelCountDownTimer
    if TopRightPanelCountDownTimer then
        self:UnRegisterTimer(TopRightPanelCountDownTimer)
    end
  
    -- 随时间变化内容更新
    self.TopRightPanelCountDownTimer = self:RegisterTimer(function()
        local BlessState = self:GetBlessState()
        local RemainSec = 0
        if BlessState == EBlessingState.Prepare then
            RemainSec = self:GetTheSecToTheRoundStart()
        elseif BlessState ~= EBlessingState.NotBegin then
            RemainSec = self:GetTheSecToRoundEnd()
        end
        GoldSaucerBlessingVM:SetNameAndCountDownTitleVisible(BlessState, self:GetBlessKind())
        GoldSaucerBlessingVM:UpdateTimeText(RemainSec)
    end, 0, 0.2, 0)
end

--- 停止面板倒计时计时器
function GoldSaucerBlessingMgr:StopTheTopRightPanelCountDownTimer()
    local TopRightPanelCountDownTimer = self.TopRightPanelCountDownTimer
    if not TopRightPanelCountDownTimer then
        return
    end

    self:UnRegisterTimer(TopRightPanelCountDownTimer)
    self.TopRightPanelCountDownTimer = nil
end

--- 进入主界面右上方显示活动信息界面范围
function GoldSaucerBlessingMgr:EnterTheShowRightTopPanelRange()
    self:TryShowRightTopPanel()
end

--- 离开主界面右上方显示活动信息界面范围
function GoldSaucerBlessingMgr:ExitTheShowRightTopPanelRange()
    self:HideRightTopPanel()
end

------ private end ------

------ public ------
--- @type 检测是否存在赐福
function GoldSaucerBlessingMgr:CheckHasBless()
    local CurBlessState = self:GetBlessState()
    return (CurBlessState == EBlessingState.InBlessingNormal or CurBlessState == EBlessingState.InBlessingWarning) -- 普通进行中以及临近结束均算作赐福进行中
end

--- @检测是否存在赐福包含预热阶段
function GoldSaucerBlessingMgr:CheckHasBlessIncludePrepare()
    local CurBlessState = self:GetBlessState()
    return CurBlessState ~= EBlessingState.NotBegin
end

--- @type 检测游戏机是否处于仙人赐福状态
function GoldSaucerBlessingMgr:GetSgIsInBlessing(InstanceID)
    return self.MachineID == InstanceID and self:CheckHasBless() 
end

--- @type 获取赐福类型
function GoldSaucerBlessingMgr:GetBlessKind()
    return self.BlessKind
end

--- @type 查看赐福的状态
function GoldSaucerBlessingMgr:GetBlessState()
    local StartTime = self.ServerStartTimestamp
    if not StartTime then
        return 
    end

    local BlessKind = self.BlessKind
    if not BlessKind or BlessKind == BLESSED_KIND.BLESSED_KIND_NONE then
        return
    end

    -- 如果玩家已完成当前赐福，认为此轮赐福已结束
    local bMajorCompleted = self.bMajorCompleted
    if bMajorCompleted then
        return EBlessingState.NotBegin
    end

    local CurTime = TimeUtil.GetServerLogicTime()
    local TimeCfg = FairyBlessedTimeCfg:FindCfgByKey(BlessKind)
    if not TimeCfg then
        FLOG_ERROR("GoldSaucerBlessingMgr:GetBlessState FairyBlessedTimeCfg = nil")
        return
    end

    -- 分钟计配表数据
    local CfgBlessTime = TimeCfg.BlessTime
    local CfgWarningTime = TimeCfg.WarningTime
    local CfgPrepareTime = TimeCfg.PrepareTime
    if not CfgBlessTime or not CfgWarningTime or not CfgPrepareTime then
        FLOG_ERROR("GoldSaucerBlessingMgr:GetBlessState FairyBlessedTimeCfg Time is InValid")
        return
    end

    local BlessTimeSec = CfgBlessTime * SecDef
    local WarningSec = CfgWarningTime * SecDef
    local PrepareSec = CfgPrepareTime * SecDef

    -- 各阶段开始时间戳
    local PrepareStartTimestamp = StartTime - PrepareSec
    local WarningStartTimestamp = StartTime + BlessTimeSec - WarningSec
    local EndTimestamp = StartTime + BlessTimeSec
    
    if CurTime >= PrepareStartTimestamp and CurTime < StartTime then
        return EBlessingState.Prepare
    elseif CurTime >= StartTime and CurTime < WarningStartTimestamp then
        return EBlessingState.InBlessingNormal
    elseif CurTime >= WarningStartTimestamp and CurTime < EndTimestamp then
        return EBlessingState.InBlessingWarning
    else
        return EBlessingState.NotBegin
    end
end

--- 赐福小游戏完成后修改本轮赐福主角已完成标记
function GoldSaucerBlessingMgr:SetMajorCompletedCurRoundAfterMiniGame()
    self.bMajorCompleted = true
    self:NotifyUpdateMapMarkerBlessStateChange(self.MachineID, nil) -- 提前结束为纯客户端判断，需手动提前清除
    self:StopTheRoundEndTimer(true) -- 当前轮次完成过赐福则默认结束赐福模式但保留赐福时间段结束拉取新赐福信息计时器
end

--- 获取距离开始的时间
function GoldSaucerBlessingMgr:GetTheSecToTheRoundStart()
    local StartTimestamp = self.ServerStartTimestamp
    if not StartTimestamp then
        return
    end

    local CurTimestamp = TimeUtil.GetServerLogicTime()
    local RemainSec = StartTimestamp - CurTimestamp
    return RemainSec > 0 and RemainSec or 0
end

--- 获取距离结束的时间
function GoldSaucerBlessingMgr:GetTheSecToRoundEnd()
    local StartTimestamp = self.ServerStartTimestamp
    if not StartTimestamp then
        return
    end

    local BlessKind = self.BlessKind
    if not BlessKind or BlessKind == BLESSED_KIND.BLESSED_KIND_NONE then
        return
    end
    local TimeCfg = FairyBlessedTimeCfg:FindCfgByKey(BlessKind)
    if not TimeCfg then
        FLOG_ERROR("GoldSaucerBlessingMgr:GetBlessState FairyBlessedTimeCfg = nil")
        return
    end

    local BlessTimeSec = (TimeCfg.BlessTime or 0) * SecDef
    local EndTimestamp = StartTimestamp + BlessTimeSec
    local CurTimestamp = TimeUtil.GetServerLogicTime()
    local RemainSec = EndTimestamp - CurTimestamp
    return RemainSec > 0 and RemainSec or 0
end

--- 尝试打开右上赐福信息面板
function GoldSaucerBlessingMgr:TryShowRightTopPanel()
    self:HideRightTopPanel()
    local GateInfoVisible = MainPanelVM:GetTheGoldSaucerGatePanelVisible()
    if GateInfoVisible then
        FLOG_ERROR("GoldSauserBlessMachineCheck ShowRightTopPanel Hide By GateInfo")
        return -- 优先级低于机遇临门
    end

    local BlessState = self:GetBlessState()
    if not BlessState or BlessState == EBlessingState.NotBegin then
        FLOG_ERROR("GoldSauserBlessMachineCheck ShowRightTopPanel BlessState is error")
        return -- 未开始阶段不显示界面
    end

    local CurMapResID = PWorldMgr:GetCurrMapResID()
    if CurMapResID ~= GoldSauserMapID then
        return -- 非金碟游乐场不显示界面
    end
   
    MainPanelVM:SetGoldSauserBlessInfoVisible(true)
    GoldSaucerBlessingVM:SetPanelData(BlessState, self:GetBlessKind())
    self:StartTheTopRightPanelCountDownTimer()
    FLOG_INFO("GoldSauserBlessMachineCheck ShowRightTopPanel SetShow")
end

--- 关闭右上赐福信息面板
function GoldSaucerBlessingMgr:HideRightTopPanel()
    self:StopTheTopRightPanelCountDownTimer()
    MainPanelVM:SetGoldSauserBlessInfoVisible(false)
    FLOG_INFO("GoldSauserBlessMachineCheck HideRightTopPanel SetHide")
end

--- 触发新手引导
function GoldSaucerBlessingMgr:NotifyTriggerTheTutorial()
    local function OnTutorial()
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.NearTargetField --新手引导触发类型
        EventParams.Param1 = TutorialDefine.NearTargetFieldType.GoldSauserBlessMachine
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--- 根据EObjResID获取对应的交互Icon
function GoldSaucerBlessingMgr:GetTheBlessInteractiveIcon(EObjResID)
    -- 非赐福时间不更改图标
    local BlessState = self:GetBlessState()
    if BlessState ~= EBlessingState.InBlessingNormal and BlessState ~= EBlessingState.InBlessingWarning then
        return
    end

    local WeightCfg = FairyBlessedWeightCfg:FindCfg(string.format("EObjResID = %d", EObjResID))
    if not WeightCfg then
        return
    end

    local TargetCfg = FairyBlessedTargetCfg:FindCfgByKey(WeightCfg.Activity)
    if not TargetCfg then
        return
    end
    
    return TargetCfg.InteractiveIcon
end

--- 获取小游戏玩法的地图标记Icon
---@param GameID ProtoRes.Game.GameID
function GoldSaucerBlessingMgr:GetTheMiniGameTypeMarkerIcon(GameID)
    local IconRlt = MarkerIconWithState.Normal -- 默认普通图标

    local BlessState = self:GetBlessState()
    if BlessState and BlessState ~= EBlessingState.NotBegin then
        local MachineID = self.MachineID
        local WeightCfg = FairyBlessedWeightCfg:FindCfg(string.format("SgbID = %d", MachineID))
        if WeightCfg and WeightCfg.Activity == GameID then
            IconRlt = MarkerIconWithState.Bless
        end
    end
    return IconRlt
end

function GoldSaucerBlessingMgr:CreateMarkersDataSource(UIMapID)
    if not UIMapID or type(UIMapID) ~= "number" then
        return
    end

    if not MapMarkerNpc2GameID or not next(MapMarkerNpc2GameID) then
        return
    end

    local MapID = MapUtil.GetMapID(UIMapID)
    if not MapID then
        return
    end

    local MapEditCfg = MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if not MapEditCfg then
        return
    end

    local SrcResult = {}
    for NpcResID, GameID in pairs(MapMarkerNpc2GameID) do
        local NpcData = MapEditDataMgr:GetNpc(NpcResID, MapEditCfg)
        if NpcData then
            local MarkerParams = {
                GameID = GameID,
                PointLocation = NpcData.BirthPoint,
                IconPath = self:GetTheMiniGameTypeMarkerIcon(GameID),
                Name = GameID2Name[GameID],
                BlessState = self:GetCurBlessMachineGameID() == GameID and self:GetBlessState() or EBlessingState.NotBegin,
                BlessKind = self:GetCurBlessMachineGameID() == GameID and self:GetBlessKind() or BLESSED_KIND.BLESSED_KIND_NONE,
            }
            
            table.insert(SrcResult, MarkerParams)
        end
    end
    MapEditDataMgr:ClearOtherMapEditCfgByMapID(MapID)
    return SrcResult
end

--- 获取当前赐福机器的玩法类型
function GoldSaucerBlessingMgr:GetCurBlessMachineGameID()
    local MachineID = self.MachineID
    if not MachineID then
        return
    end
    local WeightCfg = FairyBlessedWeightCfg:FindCfg(string.format("SgbID = %d", MachineID))
    if WeightCfg then
        return WeightCfg.Activity
    end
end

return GoldSaucerBlessingMgr
