--
-- Author: haialexzhou
-- Date: 2020-08-21
-- Description:副本管理器(parallel world)
-- 处理CS_CMD_PWORLD协议
-- 其他副本玩法不要放到这里

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoRes = require ("Protocol/ProtoRes")
local ProtoBuff = require("Network/ProtoBuff")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local MainPanelVM = require("Game/Main/MainPanelVM")
local PathMgr = require("Path/PathMgr")
local PWorldDynDataMgr = require("Game/PWorld/DynData/PWorldDynDataMgr")
local PWorldMechanismDataMgr = require("Game/PWorld/PWorldMechanismDataMgr")
local PWorldElevatorMgr = require("Game/PWorld/InteractObj/PWorldElevatorMgr")
local MapQuestObjMgr = require("Game/PWorld/MapQuestObj/MapQuestObjMgr")
local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")
local LineEffectPlayer = require("Game/PWorld/RelevanceLineEffectPlayer")
local PWorldTriggerActionExecMgr = require("Game/PWorld/PWorldTriggerActionExecMgr")
local ClientVisionMgr = require("Game/Actor/ClientVisionMgr")
local ProtoMsgMonitor = require("Game/PWorld/ProtoMsgMonitor")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local TransHelper = require("Game/Trans/TransHelper")
local TeamHelper = require("Game/Team/TeamHelper")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")

local ActorManager = _G.UE.UActorManager
local CPWorldMgr = _G.UE.UPWorldMgr
local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local EBGMChannel = _G.UE.EBGMChannel

local MapCfg = require("TableCfg/MapCfg")
local MapResCfg = require("TableCfg/MapresCfg")
local PWorldCfg = require("TableCfg/PworldCfg")
local PworldLineCfg = require("TableCfg/PworldLineCfg")
local FestivalLayersetCfg = require("TableCfg/FestivalLayersetCfg")

local MoveConfig = require("Define/MoveConfig")

local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

local FMath = _G.UE.UKismetMathLibrary


---@class PWorldMgr : MgrBase
local PWorldMgr = LuaClass(MgrBase)

local MsgBoxUtil = _G.MsgBoxUtil

local MapLoadStatus = {
    Loading = 1,
    LoadFinish = 2,
    EnterMapFinish = 3,
}

function PWorldMgr:OnInit()
    self.MajorEntityID = 0 --主角ID
    self.MajorBirthPos = _G.UE.FVector(0, 0, 0) --主角出生点
    self.MajorBirthRotator = _G.UE.FVector(0, 0, 0) --主角出生朝向
    self.SceneLevel = 0 --副本等级
    self.IsDailyRandom = false --是否是每日随机副本
    self.CurWorldID = 0
    --副本基础信息
    self.BaseInfo = {
        CurrPWorldResID = 0, --当前副本ID
        CurrMapResID = 0, --当前地图ID
        CurrPWorldInstID = 0, --当前副本实例ID
        LastPWorldResID = 0, --上个副本ID
        LastMapResID = 0, --上个地图ID
        LastTransMapResID = 0, --上个传送地图ID
        LastPWorldInstID = 0,--上个副本实例ID
        BeginTime = 0, --副本开始时间
        EndTime = 0, --副本结束时间
        MapCountDownTime = 0, --地图倒计时
        LayersetList = {}, --副本的LayersetList
        CurrLineID = 0, --当前分线ID
        LastLineID = 0, --上个分线ID
        CurrWorldID = 0, --当前副本所在服务器ID
        LastWorldID = 0, --上个副本所在服务器ID
        LineList = {}, --分线列表
        EnterTags = {}, --标签列表，参考PWorldEnterTag：{新人数量，每日随机副本ID，是否匹配，传送ID，是否已经结束， 分线ID}
        OwnerID = 0,    -- 副本所属玩家ID
    }

    self.EnterMapServerFlag = 0 --服务器下发的进入副本标志位，见PWorldEnterRsp.Flag, 0 - 准备期间进入； 1 - 断线重连; 2 - 开始后进入

    self.MapTravelInfo = {
        bShowLoading = true, --是否显示Loading界面
        bIsTransInSameMap = false, -- 是否同个地图内传送
        bEnterSameMapInReconnect = false, --是否断线重连重新进入当前地图
        TravelStatus = MapLoadStatus.EnterMapFinish, -- 地图加载状态
    }

    self.CacheLevelSequenceActors = nil --缓存当前地图放置的Cut levelsequenceactor

    CrystalPortalMgr:OnInit()
end

function PWorldMgr:ResetMap()
    FLOG_INFO("PWorldMgr:ResetMap")
    self.CacheLevelSequenceActors = nil
    PWorldDynDataMgr:Reset()
    PWorldElevatorMgr:Reset()
    MapQuestObjMgr:Reset()
    CrystalPortalMgr:ResetMap()
    ClientVisionMgr:ResetMap()
    PWorldMechanismDataMgr:Reset()

    _G.MapAreaImageMgr:Reset()
end

function PWorldMgr:ResetPWorld(bLeavePWorld)
    FLOG_INFO("PWorldMgr:ResetPWorld bLeavePWorld=%s", bLeavePWorld)
    self:ResetMap()

    --离开副本的时候正常赋值，如果是进入副本时调用，判断下是不是重复执行了,(弱网络时，后台不会重发leave副本，只重发进入副本。此时需要在进入副本的时候重置下数据)
    --LastPWorldResID放到这里赋值，没有放到Enter是因为玩家从设置返回登录界面进行创角再进入游戏的时候ID没有变化
    if (bLeavePWorld or (not bLeavePWorld and self.BaseInfo.CurrPWorldResID ~= 0)) then
        local LastPWorldResID = self.BaseInfo.CurrPWorldResID
        local LastMapResID = self.BaseInfo.CurrMapResID
        local LastPWorldInstID = self.BaseInfo.CurrPWorldInstID
        self.BaseInfo.LastPWorldResID = LastPWorldResID
        self.BaseInfo.LastMapResID = LastMapResID
        self.BaseInfo.LastLineID = self.BaseInfo.CurrLineID
        self.BaseInfo.LastWorldID = self.BaseInfo.CurrWorldID
        self.BaseInfo.LastPWorldInstID = LastPWorldInstID
        self.BaseInfo.MapCountDownTime = 0

        self.StoppedDynDataSeqID = 0
    end

    self.BaseInfo.CurrPWorldInstID = 0
    self.BaseInfo.CurrPWorldResID = 0
    self.BaseInfo.CurrMapResID = 0
    self.BaseInfo.CurrLineID = 0
    self.BaseInfo.CurrWorldID = 0
    self.BaseInfo.EnterTags = {}
    self.BaseInfo.OwnerID = 0

    self.bSendReady = false
    self.bRspReady = false

    _G.PWorldStageMgr:Reset()
    _G.PWorldWarningMgr:Reset()

    _G.MapEditDataMgr:ClearAdjacentMapEditCfg()
    _G.MapEditDataMgr:ClearFestivalMapEditCfg()
    -- _G.MapEditDataMgr:ClearOtherMapEditCfg()
end

function PWorldMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_ENTER, self.OnPWorldRespEnter)--进入副本
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_LEAVE, self.OnPWorldRespLeave) --退出副本
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_RESULT, self.OnPWorldRespResult) --副本结果
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_PROGRESS, self.OnPWorldRespProgress)--副本进度
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_TRANS, self.OnPWorldRespTrans)   --副本内传送
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_READY, self.OnPWorldRespReady)--玩家准备就 绪
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_BEGIN, self.OnPWorldRespBegin)--玩家开始
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_TRIGGER_ACTION_EXEC, self.OnPWorldRespTriggerActionExec)--触发器行为执行【服务器->客户端】
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_WARNING, self.OnPWorldRespWarning)--获取警戒列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_BOSS_TRANS, self.OnPWorldRespBossTrans)--BOSS区传送机制
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_MAP_DYN_DATA_LIST, self.OnPWorldRespMapDynDataList) --动态数据列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_MAP_DYN_DATA_UPDATE, self.OnPWorldRespMapDynDataUpdate)--动态数据变更
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_SWITCH_CAMERA, self.OnPWorldRespSwitchCamera)--切换摄像机
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_PLAY_AUDIO, self.OnPWorldRespPlayAudio)--播放音频
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_FINISHED, self.OnPWorldRespFinished)--副本完成
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_LAYER_SET_CHANGED, self.OnPWorldRespLayersetChange)--Layerset变化
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_PROGRESS_SLOT, self.OnPWorldBattleProgressSlot)--进度槽
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_COUNT_DOWN, self.OnPWorldCountDown)--战斗开始倒计时
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_MAP_COUNT_DOWN, self.OnPWorldMapCountDown)--副本倒计时
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_LINE_QUERY, self.OnPWorldLineQuery)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_LINE_ENTER, self.OnPWorldLineEnter)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_MECHANISM_DATA, self.OnPWorldMechanismData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGIN, 0, self.OnNetMsgRoleLoginRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_QUERY_ROLE_DATA, self.OnNetMsgRoleData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_VARIABLE_LIST, self.OnPWorldRespVariableList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_VARIABLE_UPDATE, self.OnPWorldRespVariableUpdate)

    CrystalPortalMgr:RegisterGameNetMsg(self)
end

function PWorldMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldDynAssetOnLandLoad, self.OnDynamicAssetLoadInLand)
    self:RegisterGameEvent(EventID.PWorldDynAssetOnLandUnLoad, self.OnDynamicAssetUnLoadInLand)
    self:RegisterGameEvent(EventID.ManualSelectTarget, self.OnManualSelectTarget)
    self:RegisterGameEvent(EventID.CombatGetRelateEnmityList, self.OnCombatGetRelateEnmityList)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)

    CrystalPortalMgr:OnRegisterGameEvent(self)
end

--退出游戏 回到登陆界面会执行这里 _G.LifeMgrModule.ShutdownRoleLife()-->
function PWorldMgr:OnEnd()
    self:ResetPWorld(true)
end

function PWorldMgr:OnShutdown()
    CrystalPortalMgr:OnShutdown()
end

-- 进入单人副本
function PWorldMgr:EnterSinglePWorld(ID)
    local UIInteractiveUtil = require("Game/PWorld/UIInteractive/UIInteractiveUtil")
    local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
    if InteractivedescCfg:FindCfgByKey(ID) ~= nil then
        UIInteractiveUtil.SendInteractiveReq(ID)
    else
        FLOG_ERROR("PWorldMgr:EnterSinglePWorld invalid interative id " ..tostring(ID))
    end
end

--region------------------------------------------发送协议包相关代码Start----------------------------

function PWorldMgr:MakePWorldMsgBody(SubMsgID)
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.PWorldInstID = self.BaseInfo.CurrPWorldInstID
    return MsgBody
end

--进入副本
function PWorldMgr:SendEnterPWorld(PWorldID, MapID, Mode)
    if (not PWorldID and not MapID) then
        return
    end

    local PWorldEnterReq = {}
    PWorldEnterReq.PWorldResID = PWorldID
    PWorldEnterReq.MapResID = MapID
    PWorldEnterReq.Mode = Mode

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_ENTER
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.Enter = PWorldEnterReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

--退出副本
function PWorldMgr:SendLeavePWorld(PWorldID)
    if (PWorldID == nil) then
        PWorldID = self.BaseInfo.CurrPWorldResID
    end

    local PWorldLeaveReq = {}
    PWorldLeaveReq.PWorldResID = PWorldID

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_LEAVE
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.Leave  = PWorldLeaveReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

--获取地图动态数据
function PWorldMgr:SendGetMapDynData()
    if (self:IsLoadingWorld()) then
        FLOG_INFO("PWorldMgr:SendGetMapDynData IsLoadingWorld")
        return
    end

    local MapDynDataListReq = {}
    MapDynDataListReq.MapResID = self.BaseInfo.CurrMapResID

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_MAP_DYN_DATA_LIST
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.MapDynDataList  = MapDynDataListReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)

    FLOG_INFO("PWorldMgr:SendGetMapDynData")

    if (self.MapDynDataMsgMonitor == nil) then
        self.MapDynDataMsgMonitor = ProtoMsgMonitor.New()
        self.MapDynDataMsgMonitor:Register(self, self.SendGetMapDynData, 5, 3, 3, self.OnEnterMapFinish, nil, true)
    end
end

--获取地图电梯数据
function PWorldMgr:SendGetMapElevatorData()
    local ElevatorListReq = {}
    ElevatorListReq.MapResID = self.BaseInfo.CurrMapResID
    ElevatorListReq.IDList = {}

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_ELEVATOR_LIST
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.ElevatorList  = ElevatorListReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

---发送副本传送(传送点)
---@param TransType PWORLD_TRANS_TYPE 传送类型
---@param TransParam number 传送参数
function PWorldMgr:SendTrans(TransType, TransParam)
    local Position = {}
    local Major = ActorManager:Get():GetMajor()
    if (Major ~= nil) then
        local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
        Position.X = math.floor(MajorPos.X)
        Position.Y = math.floor(MajorPos.Y)
        Position.Z = math.floor(MajorPos.Z)
    end

    local PWorldTransReq = {}
    PWorldTransReq.Type = TransType
    PWorldTransReq.Param = tonumber(TransParam)
    PWorldTransReq.Pos  = Position

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_TRANS
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.Trans  = PWorldTransReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

--发送过场动画开始
function PWorldMgr:SendMovieBegin(MovieID, VideoType)
    --print("PWorldMgr:SendMovieBegin!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    local PWorldVideoBeginReq = {}
    PWorldVideoBeginReq.PWorldInstID = self.BaseInfo.CurrPWorldInstID
    PWorldVideoBeginReq.VideoID = MovieID
    PWorldVideoBeginReq.VideoType = VideoType

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_VIDEO_BEGIN
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.VideoBegin  = PWorldVideoBeginReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
    _G.ClientReportMgr:SendClientReport(ProtoCS.ReportType.ReportTypeEnterCutScenes)
end

--发送过场动画结束
function PWorldMgr:SendMovieEnd(MovieID, VideoType, Flag)
    --print("PWorldMgr:SendMovieEnd!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Flag=" .. Flag)
    local PWorldVideoEndReq = {}
    PWorldVideoEndReq.PWorldInstID = self.BaseInfo.CurrPWorldInstID
    PWorldVideoEndReq.VideoID = MovieID
    PWorldVideoEndReq.VideoType = VideoType
    PWorldVideoEndReq.Flag = Flag

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_VIDEO_END
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.VideoEnd  = PWorldVideoEndReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
    _G.ClientReportMgr:SendClientReport(ProtoCS.ReportType.ReportTypeQuitCutScenes)
end

--上报已经准备好了
function PWorldMgr:SendReady()
    FLOG_INFO("PWorldMgr:SendReady!!!!!!!")
    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_READY
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
    self.bSendReady = true

    --确保后台可以收到Ready包
    if (self.ReadyMsgMonitor == nil) then
        self.ReadyMsgMonitor = ProtoMsgMonitor.New()
        self.ReadyMsgMonitor:Register(self, self.SendReady, 5, 3, 3)
    end
end

--发送战斗开始倒计时广播请求
function PWorldMgr:SendCountDown(Duration)
	local CountDown = {}
	CountDown.PWorldInstID = self:GetCurrPWorldInstID()
	CountDown.Duration = Duration

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_COUNT_DOWN
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
	MsgBody.CountDown = CountDown
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

--分线查询
function PWorldMgr:SendLineQuery(PWorldResID)
    if (PWorldResID == nil) then
        PWorldResID = self.BaseInfo.CurrPWorldResID
    end

    local PWorldLineQueryReq = {}
    PWorldLineQueryReq.PWorldResID = PWorldResID

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_LINE_QUERY
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.LineQuery = PWorldLineQueryReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

--分线进入
function PWorldMgr:SendLineEnter(PWorldResID, LineID, CrystalID)
    if (not PWorldResID or not LineID or not CrystalID) then
        return
    end

    local PWorldLineEnterReq = {}
    PWorldLineEnterReq.PWorldResID = PWorldResID
    PWorldLineEnterReq.LineID = LineID
    PWorldLineEnterReq.CrystalID = CrystalID

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_LINE_ENTER
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.LineEnter = PWorldLineEnterReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

---关卡资源缺失上报
function PWorldMgr:SendLackOfResource()
    local PWorldLackOfResourceReq = {}
    PWorldLackOfResourceReq.PWorldInstID = self:GetCurrPWorldInstID()
    PWorldLackOfResourceReq.Type = ProtoCS.ResourceType.Map

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_LACK_OF_RESOURCE
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    MsgBody.LackOfResource = PWorldLackOfResourceReq
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

function PWorldMgr:SendMechanismData()
    local CurrMapResID = PWorldMgr:GetCurrMapResID()
    if not (CurrMapResID == 6510 or CurrMapResID == 6512) then
        -- 只有指定的活动地图（亡灵府邸闹鬼庄园）才有地图机制数据，后面用的多时把配置加到地图配表里
        return
    end

    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_MECHANISM_DATA
    local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

function PWorldMgr:SendPullVariableList()
    local SubMsgID = CS_PWORLD_CMD.CS_PWORLD_CMD_VARIABLE_LIST
     local MsgBody = self:MakePWorldMsgBody(SubMsgID)
    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_PWORLD, SubMsgID, MsgBody)
end

--endregion------------------------------------------发送协议包相关代码End---------------------------


--region------------------------------------------协议回包相关代码Start------------------------------

function PWorldMgr:OnEnterPWorld(MsgBody)
    local PWorldEnterRsp = MsgBody.Enter
    if not PWorldEnterRsp then
        FLOG_ERROR("PWorldMgr:OnEnterPWorld msg is nil")
        return
    end

    --关卡数据如果没有初始化，不走重连逻辑，需要初始化一遍
    local bDynDataIsInited = PWorldDynDataMgr:IsInited()

    FLOG_INFO("PWorldMgr:OnEnterPWorld PWorldResID=%d MapResID=%d Flag=%d bDynDataIsInited=%s", PWorldEnterRsp.PWorldResID, PWorldEnterRsp.MapResID, PWorldEnterRsp.Flag, tostring(bDynDataIsInited))

    --副本和角色实例ID不变，且不是断线重连
    if (bDynDataIsInited and self.BaseInfo.CurrPWorldInstID == PWorldEnterRsp.PWorldInstID and self.MajorEntityID == PWorldEnterRsp.EntityID and not self:RspFlagIsReconnect(PWorldEnterRsp.Flag)) then
        FLOG_INFO("PWorldMgr:OnEnterPWorld repeat receipt!!!")
        return
    end

    local bIsLoadingWorld = self:IsLoadingWorld()
    --在加载地图的过程中，收到切换到新地图协议（比如双人坐骑在传送线来回切换），先走一遍上个地图进入完成流程，防止一些数据未清除，比如天气,会叠加导致天气叠加，过曝全白
    if (bIsLoadingWorld) then
        local CurrPWorldResID = self.BaseInfo.CurrPWorldResID
        local CurrMapResID = self.BaseInfo.CurrMapResID
        if (CurrPWorldResID ~= PWorldEnterRsp.PWorldResID or CurrMapResID ~= PWorldEnterRsp.MapResID) then
            self:NotifyEnterMapFinish()
        end
    end
    --如果正在播放Sequence的时候收到进副本的包，也需要走断线重连逻辑，（后台发送重连包会在PWorldMgr:OnNetMsgRoleLoginRes调用ResetMap, 清除关卡数据)
    self.MapTravelInfo.bEnterSameMapInReconnect = _G.StoryMgr:SequenceIsPlaying() and (not bDynDataIsInited)
    -- 如果本地当前地图和服务器下发的地图不一致，判断为本地上次切地图没有成功，重置本地数据，走切地图流程
    if self.BaseInfo.CurrPWorldResID ~= 0 and self.BaseInfo.CurrMapResID ~= 0 then
        local bSamePWorldRes = (PWorldEnterRsp.PWorldResID == self.BaseInfo.CurrPWorldResID and PWorldEnterRsp.MapResID == self.BaseInfo.CurrMapResID)
        if not bSamePWorldRes then
            self.MapTravelInfo.bEnterSameMapInReconnect = false
            self:LeavePWorldImpl()
        end

        if (self:RspFlagIsReconnect(PWorldEnterRsp.Flag) and PWorldEnterRsp.PWorldInstID == self.BaseInfo.CurrPWorldInstID and bSamePWorldRes) then
            if (bIsLoadingWorld) then
                FLOG_INFO("PWorldMgr:OnEnterPWorld bIsLoadingWorld")
                return --同一地图断线重连的时候 正在切地图，不做后续处理
            end

            self.MapTravelInfo.bEnterSameMapInReconnect = true
        end
    end

    self:SetMajorLocationAndRotator(PWorldEnterRsp.Pos, PWorldEnterRsp.Dir)

    self.BaseInfo.CurrPWorldInstID = PWorldEnterRsp.PWorldInstID
    self.BaseInfo.BeginTime = PWorldEnterRsp.BeginTime
    self.BaseInfo.EndTime = PWorldEnterRsp.EndTime
    self.BaseInfo.EnterTags = PWorldEnterRsp.Tags
    self.BaseInfo.OwnerID = PWorldEnterRsp.OwnerID

    local EnterTagDailyRandomID = self:GetEnterTag(ProtoCS.PWorldEnterTag.PWorldEnterTagDailyRandomID)
    local EnterTagIsMatch = self:GetEnterTag(ProtoCS.PWorldEnterTag.PWorldEnterTagIsMatch)
    local EnterTagTransID = self:GetEnterTag(ProtoCS.PWorldEnterTag.PWorldEnterTagTransID)
    local EnterTagIsFinished = self:GetEnterTag(ProtoCS.PWorldEnterTag.PWorldEnterTagIsFinished)
    local EnterTagLineID = self:GetEnterTag(ProtoCS.PWorldEnterTag.PWorldEnterTagLineID)
    local EnterMajorPerformID = self:GetEnterTag(ProtoCS.PWorldEnterTag.PWorldEnterTagPerform)

    self.MajorEntityID = PWorldEnterRsp.EntityID
    self.EnterMapServerFlag = PWorldEnterRsp.Flag
    self.SceneLevel = PWorldEnterRsp.Level
    self.MapTravelInfo.bIsTransInSameMap = false
    self.MapTravelInfo.TravelStatus = MapLoadStatus.Loading
    self.Mode = PWorldEnterRsp.Mode
    self.IsMatch = EnterTagIsMatch > 0
    self.BaseInfo.TransID = EnterTagTransID
    self.IsFinished = EnterTagIsFinished > 0
    self.BaseInfo.CurrLineID = EnterTagLineID
    self.BaseInfo.CurrWorldID = PWorldEnterRsp.WorldID
    self.DailyRandomID = EnterTagDailyRandomID
    self.IsDailyRandom = PWorldEnterRsp.IsDailyRandom or (self.DailyRandomID ~= 0)

    local RoleVM = MajorUtil.GetMajorRoleVM()
    local CurWorldID = PWorldEnterRsp.WorldID or 0
    ----- 主角需要这里更新跨服ID curworldid为0 在副本 不更新
    if RoleVM and CurWorldID ~= 0 then
        local OriginWorldID = _G.LoginMgr:GetWorldID()  -- 原始WorldID
        RoleVM:SetCrossZoneWorldID(OriginWorldID == CurWorldID and 0 or CurWorldID)
        _G.EventMgr:SendEvent(EventID.PWorldCrossWorld, self.CurWorldID, CurWorldID) --- 上一次的WorldID 和当前的WorldID
        FLOG_INFO(string.format("PWorldMgr:OnEnterPWorld LastWorld=%d CurWorldID=%d", self.CurWorldID, CurWorldID))
    end

    self.CurWorldID = CurWorldID --- 在副本的时候会是0
    local PWorldMgrInstance = CPWorldMgr:Get()
    PWorldMgrInstance:SetPWorldInstID(self.BaseInfo.CurrPWorldInstID)
    PWorldMgrInstance:SetPWorldResID(PWorldEnterRsp.PWorldResID)
    PWorldMgrInstance:SetMapResID(PWorldEnterRsp.MapResID)

    self.BaseInfo.CurrPWorldResID = PWorldEnterRsp.PWorldResID
    self.BaseInfo.CurrMapResID = PWorldEnterRsp.MapResID

    local LastPWorldResID = self.BaseInfo.LastPWorldResID
    local LastMapResID = self.BaseInfo.LastMapResID
    PWorldMgrInstance:SetLastMapResID(LastMapResID)
    PWorldMgrInstance:SetLastPWorldResID(LastPWorldResID)

    PWorldMgrInstance:ResetLayersetList()
    PWorldMgrInstance:AddLaysetName(self:GetMapLayersetName(PWorldEnterRsp.MapResID))

    if #PWorldEnterRsp.LayerSetList > 0 then
        local FestivalLayersetIDs = {}
        for k,v in ipairs(PWorldEnterRsp.LayerSetList) do
            table.insert(FestivalLayersetIDs,v)
        end

        local FestivalLayersetInfoList = self:GetFestivalLayersetInfo(FestivalLayersetIDs)

        for k,v in pairs(FestivalLayersetInfoList) do
            PWorldMgrInstance:AddLaysetName(v[1])
            --加载节日地图逻辑单元数据

            if table.length(v) > 1 then
                PWorldMgrInstance:LoadFestivalMapEditCfg(v[2])
            end

        end
    end

    local bPWorldOrMapIsChanged = true
    local bChangeLine = false
    local bCrossWorld = false
    if (LastPWorldResID == PWorldEnterRsp.PWorldResID and LastMapResID == PWorldEnterRsp.MapResID) then
        if self.BaseInfo.LastWorldID ~= PWorldEnterRsp.WorldID then
            bPWorldOrMapIsChanged = false
            bCrossWorld = true
        else
            bPWorldOrMapIsChanged = false
            bChangeLine = self:IsChangeLine()
        end
    end

    --切地图或者切分线的时候延迟执行, 放到EventID.PWorldMapExit执行之后，否则RemoveAllBuff会使用的新EntityID导致失效
    if (self.MapTravelInfo.bEnterSameMapInReconnect or (not bPWorldOrMapIsChanged and not bChangeLine and not bCrossWorld)) then
        self:UpdateMajorEntityID()
    end

    -- 同步副本等级
    MajorUtil.SetPWorldLevel(PWorldEnterRsp.Level)
    _G.MusicPerformanceMgr:OnNotityMajorPerformanceState(EnterMajorPerformID)

    --网络重连
    if (self.MapTravelInfo.bEnterSameMapInReconnect) then
        self:PostLoadWorldForReconnectInSameMap(bDynDataIsInited)
        PWorldMgrInstance:OnPostLoadWorldForReconnectInSameMap()

    elseif (bPWorldOrMapIsChanged) then
        if self:IsStopChangeMap(PWorldEnterRsp.PWorldResID) then
            self:UpdateMajorEntityID()
            self:SetMapTravelStatusFinish()
            FLOG_INFO("PWorldMgr:OnEnterPWorld return by Stop")
            return
        end
        if self:IsChangePhaseMap() then
            FLOG_INFO("PWorldMgr:OnEnterPWorld change phase map")
            self:PlayChangeMapSequence()
            self:ChangeMap(PWorldEnterRsp.MapResID, true)
        else
            FLOG_INFO("PWorldMgr:OnEnterPWorld change map")
            self:ChangeMap(PWorldEnterRsp.MapResID, true)
        end

    elseif bChangeLine or bCrossWorld then
        -- 地图切线、跨界传送，模拟切换地图前、后的处理流程
        FLOG_INFO("PWorldMgr:OnEnterPWorld change line or cross world")
        self:RegisterTimer(function()
            self:PlayChangeMapSequence()
        end, 0.5)

        local UWorldMgr = _G.UE.UWorldMgr:Get()
        if (UWorldMgr ~= nil) then
            local CurrentMapName = UWorldMgr:GetWorldName()
            -- PreLoadWorld和PostLoadWorld需要配对使用，不然有些逻辑可能漏掉
            _G.WorldMsgMgr:PreLoadWorld(CurrentMapName, CurrentMapName)
	        _G.WorldMsgMgr:PostLoadWorld(CurrentMapName, CurrentMapName, _G.UE.ELoadWorldReason.Normal)
        end

        _G.HUDMgr:UpdateMajorEntityID(self.MajorEntityID)
    else
        self:PostLoadWorld()
    end

    _G.PWorldTeamMgr:PWorldEnter()

    if self:CurrIsInDungeon() then
        _G.PWorldStageMgr:UpdateProcess(PWorldEnterRsp.PWorldResID, 1, 0)
    end
end

function PWorldMgr:LeavePWorldImpl()
    if self.BaseInfo == nil then
        return
    end
    FLOG_INFO("PWorldMgr:OnLeavePWorld")
    local LeavePWorldResID = self.BaseInfo.CurrPWorldResID
    local LeaveMapResID = self.BaseInfo.CurrMapResID

    self:ResetPWorld(true)

    FLOG_INFO("PWorldMgr:OnLeavePWorld test1")

    -- 清理图片下载器中缓存的一些数据
    _G.UE.UImageDownloader.ClearHashPathMap()

    FLOG_INFO("PWorldMgr:OnLeavePWorld test2")

    local Params = _G.EventMgr:GetEventParams()
    _G.EventMgr:SendCppEvent(EventID.PWorldExit, Params)
    FLOG_INFO("PWorldMgr:OnLeavePWorld test3")
    _G.EventMgr:SendEvent(EventID.PWorldExit, LeavePWorldResID, LeaveMapResID)
    FLOG_INFO("PWorldMgr:OnLeavePWorld test4")
end

function PWorldMgr:OnLeavePWorld(MsgBody)
    -- filter out empty packet
    if not MsgBody.Leave then
        return
    end
    self:LeavePWorldImpl()
end

--副本结果
function PWorldMgr:OnPWorldResult(MsgBody)
    _G.FLOG_INFO("PWorldMgr:OnPWorldResult MsgBody = " .. table.tostring_block(MsgBody))
    local Rlt = MsgBody.Result
    if Rlt then

        _G.EventMgr:SendEvent(EventID.PWorldResult, Rlt.Result, Rlt.LeaveTime, Rlt.CostTime, Rlt.Score)
    end
end

function PWorldMgr:OnPWorldFinished(MsgBody)
    _G.FLOG_INFO("PWorldMgr:OnPWorldFinished MsgBody = " .. table.tostring_block(MsgBody))
    local Finished = MsgBody.Finished
    self.IsFinished = true
    if Finished then
        _G.EventMgr:SendEvent(EventID.PWorldFinished, Finished.PWorldResID)
    end
end


--副本进度
function PWorldMgr:OnPWorldProgress(MsgBody)
    _G.FLOG_INFO("PWorldMgr:OnPWorldProgress")
    local PWorldProgressRsp = MsgBody.Progress
    if (self.BaseInfo.CurrPWorldResID == PWorldProgressRsp.PWorldResID) then
        _G.PWorldStageMgr:UpdateProcess(PWorldProgressRsp.PWorldResID, PWorldProgressRsp.CurStep, PWorldProgressRsp.CurProgress)
    end
end


--副本内传送回包
function PWorldMgr:OnPWorldTrans(MsgBody)
    local PWorldTransRsp = MsgBody.Trans
    if (PWorldTransRsp == nil) then
        print("PWorldMgr:OnPWorldTrans, Trans is null!!!")
        -- 如果当前显示黑屏且fade in状态,则fade out
        _G.EventMgr:SendEvent(EventID.CommonFadePanelFadeOut)
        return
    end

    --切地图的过程中收到同地图传送协议，不处理
    local bIsLoadingWorld = self:IsLoadingWorld()
    if (bIsLoadingWorld) then
        print("PWorldMgr:OnPWorldTrans, IsLoadingWorld!!!")
        return
    end
    print("PWorldMgr:OnPWorldTrans MapResID=" .. tostring(PWorldTransRsp.MapResID))

    --防止Sequence结束了，但RestoreLayerset还未完成，Restore完成后又重新设置Major坐标
    if not _G.StoryMgr:SequenceIsPlaying() then
        _G.StoryMgr:RestoreVisionActorsTransform()
    end

    self:SetMajorLocationAndRotator(PWorldTransRsp.Pos, PWorldTransRsp.Dir)
    local IsOnlyChangeLocation = false

    -- 重置分线数据，避免影响后续的副本内传送判断
    self.BaseInfo.LastLineID = self.BaseInfo.CurrLineID
    self.EnterMapServerFlag = 0

    self.BaseInfo.LastTransMapResID = PWorldTransRsp.MapResID
    local CurrMapResID = self.BaseInfo.CurrMapResID
    if (CurrMapResID ~= PWorldTransRsp.MapResID) then
        self:ResetMap()
        self.MapTravelInfo.bIsTransInSameMap = false
        self.MapTravelInfo.TravelStatus = MapLoadStatus.Loading
        self.BaseInfo.CurrMapResID = PWorldTransRsp.MapResID
        self.BaseInfo.LastMapResID = CurrMapResID
        self.BaseInfo.TransID = PWorldTransRsp.TransID
        local PWorldMgrInstance = CPWorldMgr:Get()
        PWorldMgrInstance:SetMapResID(self.BaseInfo.CurrMapResID)
        PWorldMgrInstance:SetLastMapResID(CurrMapResID)
        self:ChangeMap(PWorldTransRsp.MapResID, false)
    else
        local CurrPWorldInstID = self.BaseInfo.CurrPWorldInstID
        self.BaseInfo.LastPWorldInstID = CurrPWorldInstID
        self.BaseInfo.CurrPWorldInstID = PWorldTransRsp.PWorldInstID

        --大世界地图需要处理子关卡加载问题
        local UWorldMgr = _G.UE.UWorldMgr:Get()
        if (UWorldMgr ~= nil) then
           local TransLoadType = UWorldMgr:CheckTransLoadType(
                self.MajorBirthPos, self.MajorBirthRotator, PWorldTransRsp.HideLoading)

            --sequence播放过场中进行同地图传送，不走地图加载流程，否则ncut中的模型可能被清除掉，而且ncut过程中加载子level也会导致卡顿
            if TransLoadType ~= _G.UE.EPWorldTransLoadType.Normal and (_G.StoryMgr:SequenceIsPlayingStatus() or _G.StoryMgr:SequenceIsPausedStatus()) then
                TransLoadType = _G.UE.EPWorldTransLoadType.Normal
            end

            if (TransLoadType ~= _G.UE.EPWorldTransLoadType.Normal) then
                self:ResetMap()

                self.MapTravelInfo.bIsTransInSameMap = true
                self.MapTravelInfo.TravelStatus = MapLoadStatus.Loading

                --传送前禁用主角tick、重力，否则会掉落
                ActorManager:Get():DisableMajor()
                local CurrentMapName = UWorldMgr:GetWorldName()
                _G.WorldMsgMgr:PreLoadWorld(CurrentMapName, CurrentMapName)

            else
                local Major = MajorUtil.GetMajor()
                if Major then
                    --不切换地图的时候 及时设置角色坐标，防止客户端同步给server的时候坐标是错的
                    if Major:IsInFly() then
                        Major:SwitchFly(false, false)
                    end

                    self:SetMajorPosAndRotationToBirthPoint()

                    local CamControlComp = Major:GetCameraControllComponent()
                    if nil ~= CamControlComp then
                        CamControlComp:ResetSpringArm(false)
                    end
                    IsOnlyChangeLocation = true
                end

                if not _G.StoryMgr:SequenceIsPlaying() and _G.UIViewMgr:IsViewVisible(_G.UIViewID.CommonFadePanel) then
                    local Params = {}
                    Params.FadeColorType = 1
                    Params.Duration = 1
                    Params.bAutoHide = true
                    _G.UIViewMgr:ShowView(_G.UIViewID.CommonFadePanel, Params)
                    -- FLOG_INFO("loiafeng debug: WorldMsgMgr Show CommonFadePanel")
                end
            end
        end
    end

    _G.EventMgr:SendEvent(EventID.PWorldTransBegin, IsOnlyChangeLocation)
end

--上报回包
function PWorldMgr:OnPWorldReady(MsgBody)
    if (self.ReadyMsgMonitor ~= nil) then
        self.ReadyMsgMonitor:Destroy()
        self.ReadyMsgMonitor = nil
    end
    self.bRspReady = true

    _G.EventMgr:SendEvent(EventID.PWorldReady)
end

function PWorldMgr:OnPWorldBegin(MsgBody)
    _G.EventMgr:SendEvent(EventID.PWorldBegin)
end


--处理后台通知的触发器行为
function PWorldMgr:OnTriggerActionExec(MsgBody)
    local TriggerActionExec = MsgBody.TriggerActionExec
    local function _GetParamValue(Index)
        if (#TriggerActionExec.Params >= Index) then
            return TriggerActionExec.Params[Index]
        end
        return 0
    end

    local TriggerAction = _G.MapEditDataMgr:GetTriggerAction(TriggerActionExec.ActionID)
    --_G.FLOG_ERROR("OnTriggerActionExec!!!!!!!!!!! ActionID=%d", TriggerActionExec.ActionID)
    if (TriggerAction ~= nil) then
        local ActionParams = {}
        ActionParams.StrParam = TriggerAction.StrParam
        ActionParams.ParamBool = TriggerAction.ParamBool
        ActionParams.Param1 = TriggerAction.Param1
        ActionParams.Param2 = TriggerAction.Param2
        ActionParams.Param3 = TriggerAction.Param3
        ActionParams.Param4 = TriggerAction.Param4
        ActionParams.Param5 = TriggerAction.Param5
        ActionParams.Param6 = TriggerAction.Param6
        ActionParams.Param7 = TriggerAction.Param7
        ActionParams.Param8 = TriggerAction.Param8
        ActionParams.Param9 = TriggerAction.Param9
        ActionParams.Param10 = TriggerAction.Param10
        ActionParams.Param11 = TriggerAction.Param11
        ActionParams.TriggerEntityID = TriggerActionExec.TriggerEntityID
        ActionParams.Entities = TriggerActionExec.Entities
        local ActionType = TriggerAction.Type
        PWorldTriggerActionExecMgr:OnTriggerActionExec(ActionType, ActionParams)
    end
end

function PWorldMgr:OnUpdateWarningData(WarningID, BeginTime)
    _G.PWorldWarningMgr:UpdateWarningData(WarningID, BeginTime)
end

function PWorldMgr:OnBossAreaTrans(BossTransData)
    local function OkBtnCallback()
		self:SendTrans(ProtoCS.PWORLD_TRANS_TYPE.PWORLD_TRANS_TYPE_BOSS, BossTransData.RegionID)
	end
    local ShowTime = BossTransData.EndTime - _G.TimeUtil.GetServerTime()
    if (ShowTime > 0) then
        ---@type MsgBoxExParams
        local ExParams = {
            ["LeftTime"] = ShowTime,
            ["LeftTimeStrFmt"] = LSTR(10064)
        }
        local Title = nil
        MsgBoxUtil.ShowMsgBoxTwoOp(self, Title, LSTR(800011), OkBtnCallback, nil, nil, nil, ExParams)
    else
        -- 关闭传送的时候，关闭提示窗
        if BossTransData.RegionID == 0 then
            local CommonMsgBoxView = _G.UIViewMgr:FindView(_G.UIViewID.CommonMsgBox)
            if CommonMsgBoxView ~= nil and CommonMsgBoxView.Params ~= nil and CommonMsgBoxView.Params.UIView ~= nil then
                if CommonMsgBoxView.Params.UIView.Name == self.Name then
                    _G.MsgBoxUtil.CloseMsgBox()
                end
            end
        end
    end
end

function PWorldMgr:OnSwitchCamera(SwitchCamera)
    if (SwitchCamera.PWorldInstID ~= self.BaseInfo.CurrPWorldInstID) then
        return
    end
    --锁定地图某个坐标点
    local LookAtLocation = _G.UE.FVector(0.0, 0.0, 0.0)
    local MapPoint = _G.MapEditDataMgr:GetMapPoint(SwitchCamera.MapPointID)
    if (MapPoint ~= nil) then
        LookAtLocation.X = MapPoint.Point.X
        LookAtLocation.Y = MapPoint.Point.Y
        LookAtLocation.Z = MapPoint.Point.Z
    end

    local PWorldMgrInstance = CPWorldMgr:Get()
    PWorldMgrInstance:OnSwitchCamera(SwitchCamera.MonsterListID, SwitchCamera.IsLock, LookAtLocation, SwitchCamera.CameraParam)
end

--进入副本(开始游戏后，每次切地图都会走这个协议)
function PWorldMgr:OnPWorldRespEnter(MsgBody)
    self:OnEnterPWorld(MsgBody)
end

--退出副本
function PWorldMgr:OnPWorldRespLeave(MsgBody)
    self:OnLeavePWorld(MsgBody)
end

--副本结果
function PWorldMgr:OnPWorldRespResult(MsgBody)
    self:OnPWorldResult(MsgBody)
end

--副本完成
function PWorldMgr:OnPWorldRespFinished(MsgBody)
    self:OnPWorldFinished(MsgBody)
end

--副本进度
function PWorldMgr:OnPWorldRespProgress(MsgBody)
    self:OnPWorldProgress(MsgBody)
end

--副本内传送
function PWorldMgr:OnPWorldRespTrans(MsgBody)
    self:OnPWorldTrans(MsgBody)
end

--玩家准备就绪
function PWorldMgr:OnPWorldRespReady(MsgBody)
    self:OnPWorldReady(MsgBody)
end

--玩家开始
function PWorldMgr:OnPWorldRespBegin(MsgBody)
    self:OnPWorldBegin(MsgBody)
end

--触发器行为执行【服务器->客户端】
function PWorldMgr:OnPWorldRespTriggerActionExec(MsgBody)
    self:OnTriggerActionExec(MsgBody)
end

--获取警戒列表
function PWorldMgr:OnPWorldRespWarning(MsgBody)
    local PWorldWarning = MsgBody.Warning
    if (self:CheckPWorldAndMapIsValid(PWorldWarning)) then
        self:OnUpdateWarningData(PWorldWarning.WarningID, PWorldWarning.BeginTime)
    end
end

--BOSS区传送机制
function PWorldMgr:OnPWorldRespBossTrans(MsgBody)
    local PWorldBossTrans = MsgBody.BossTrans
    if (self:CheckPWorldAndMapIsValid(PWorldBossTrans)) then
        self:OnBossAreaTrans(PWorldBossTrans)
    end
end

--动态数据列表
function PWorldMgr:OnPWorldRespMapDynDataList(MsgBody)
    if (self.MapDynDataMsgMonitor ~= nil) then
        self.MapDynDataMsgMonitor:Destroy()
        self.MapDynDataMsgMonitor = nil
    end

    if (self:IsLoadingWorld()) then
        FLOG_INFO("PWorldMgr:OnPWorldRespMapDynDataList IsLoadingWorld")
        return
    end

    local MapDynDataList = MsgBody.MapDynDataList
    PWorldDynDataMgr:UpdateDynDataList(MapDynDataList, true)

    self:OnEnterMapFinish()
end

--动态数据变更
function PWorldMgr:OnPWorldRespMapDynDataUpdate(MsgBody)
    local MapDynDataList = MsgBody.MapDynDataUpdate
    PWorldDynDataMgr:UpdateDynDataList(MapDynDataList, false)
end

--切换摄像机
function PWorldMgr:OnPWorldRespSwitchCamera(MsgBody)
    local SwitchCamera = MsgBody.SwitchCamera
    self:OnSwitchCamera(SwitchCamera)
end

--播放音频
function PWorldMgr:OnPWorldRespPlayAudio(MsgBody)
    local PlayAudio = MsgBody.PlayAudio
    PWorldDynDataMgr:PlaySound(PlayAudio.FileName, PlayAudio.Intensity)
end

--Layerset变化
function PWorldMgr:OnPWorldRespLayersetChange(MsgBody)
    local PWorldMgrInstance = CPWorldMgr:Get()
    ---节日开启
    if #MsgBody.LayerSetChanged.LayerSetList > 0 then
        local FestivalLayersetInfoList = self:GetFestivalLayersetInfo(MsgBody.LayerSetChanged.LayerSetList)

        --加载关卡编辑器数据， 加载后从c++调用lua函数OnLoadMapEditCfg
        for k,v in pairs(FestivalLayersetInfoList) do
            PWorldMgrInstance:AddLaysetName(v[1])

            if table.length(v) > 1 then
                PWorldMgrInstance:LoadFestivalMapEditCfg(v[2])
            end
        end

        PWorldMgrInstance:AddFestivalLayerset()
    else
        ---节日结束
        PWorldMgrInstance:ClearFestivalLayerset()
    end
end

--拉哈布雷亚的魔力变化
function PWorldMgr:OnPWorldBattleProgressSlot(MsgBody)
    local ProgressSlot = MsgBody.ProgressSlot

    if self:GetCurrPWorldInstID() == ProgressSlot.PWorldInstID then
        _G.EventMgr:SendEvent(EventID.PWorldProgressSlot,{Content = ProgressSlot})
    end
end

--战斗开始倒计时
function PWorldMgr:OnPWorldCountDown(MsgBody)
	_G.SignsMgr.IsDuringCountDown = MsgBody.CountDown.EndTime ~= 0
	if MsgBody.CountDown.EndTime == 0 then
		_G.TeamBeginCDTipsVM:OnCancleCountDown(MsgBody.CountDown)
	else
		_G.TeamBeginCDTipsVM:OnBeginCountDown(MsgBody.CountDown)
	end
	_G.EventMgr:SendEvent(EventID.TeamBtnStateChanged)
end

--副本倒计时
function PWorldMgr:OnPWorldMapCountDown(MsgBody)
    --_G.FLOG_INFO("OnPWorldMapCountDown: MsgBody.MapCountDown:%s", MsgBody.MapCountDown.EndTime)
    --后台给过来的时间是纳秒，这边转换成秒数来存储
    self.BaseInfo.MapCountDownTime = math.floor(MsgBody.MapCountDown.EndTime / 1000000000)
    _G.EventMgr:SendEvent(EventID.PWorldMapEndTimeSwitch)
end

--分线查询
function PWorldMgr:OnPWorldLineQuery(MsgBody)
    local PWorldLineQueryRsp = MsgBody.LineQuery

    self.BaseInfo.LineList = PWorldLineQueryRsp.Lines

    local bHasPWorldBranch = #self.BaseInfo.LineList > 1 -- 超过1条分线才显示副本分线
    _G.EventMgr:SendEvent(EventID.PWorldLineQueryResult, { bHasPWorldBranch = bHasPWorldBranch, })
end

--分线进入
function PWorldMgr:OnPWorldLineEnter(MsgBody)
    local PWorldLineEnterRsp = MsgBody.LineEnter
end

function PWorldMgr:OnPWorldMechanismData(MsgBody)
    local PWorldMechanismData = MsgBody.MechanismData
    PWorldMechanismDataMgr:OnPWorldMechanismData(PWorldMechanismData)
end


--后台触发客户端发起重新登陆(断线5分钟或者后台重连缓存满了)，接着会下发进入副本协议（协议里的flag可能是1或者2），所以这里需要先清除地图动态数据，避免重复创建
function PWorldMgr:OnNetMsgRoleLoginRes(MsgBody)
	if MsgBody.ReConnected then
        self:ResetMap()
	end
end

function PWorldMgr:OnNetMsgRoleData(MsgBody)
    _G.EventMgr:SendEvent(EventID.PWorldRoleSceneData, MsgBody)
end

function PWorldMgr:OnPWorldRespVariableList(MsgBody)
    local VariableList = MsgBody.VariableList
    if VariableList then
        _G.EventMgr:SendEvent(EventID.PWorldVariableDataChange, VariableList.Variables)
    end
end

function PWorldMgr:OnPWorldRespVariableUpdate(MsgBody)
    local VariableUpdate = MsgBody.VariableUpdate
    if VariableUpdate then
        _G.EventMgr:SendEvent(EventID.PWorldVariableDataChange, VariableUpdate.Variables)
    end
end

--endregion--------------------------------------------协议回包相关代码End----------------------------


--获取副本表数据配置
function PWorldMgr:GetPWorldTableCfg(PWorldResID)
    return PWorldCfg:FindCfgByKey(PWorldResID)
end

--获取当前副本表数据配置
function PWorldMgr:GetCurrPWorldTableCfg()
    if (self.BaseInfo == nil) then
        return nil
    end
    return PWorldCfg:FindCfgByKey(self.BaseInfo.CurrPWorldResID)
end

--获取上一个副本表数据配置
function PWorldMgr:GetLastPWorldTableCfg()
    if (self.BaseInfo == nil) then
        return nil
    end
    return PWorldCfg:FindCfgByKey(self.BaseInfo.LastPWorldResID)
end

--获取地图表数据配置
function PWorldMgr:GetMapTableCfg(MapResID)
    return MapCfg:FindCfgByKey(MapResID)
end

--获取地图资源表数据配置
function PWorldMgr:GetMapResTableCfg(LevelID)
    return MapResCfg:FindCfgByKey(LevelID)
end

--获取当前地图表数据配置
function PWorldMgr:GetCurrMapTableCfg()
    if (self.BaseInfo == nil) then
        return nil
    end
    return MapCfg:FindCfgByKey(self.BaseInfo.CurrMapResID)
end

function PWorldMgr:GetAllPworldTableCfg()
    return PWorldCfg:FindAllCfg()
end

function PWorldMgr:GetCurrPWorldType()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
    local PWorldType = (PWorldTableCfg ~= nil and PWorldTableCfg.Type or 0)
    return PWorldType
end

function PWorldMgr:GetCurrPWorldSubType()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
    local PWorldSubType = (PWorldTableCfg ~= nil and PWorldTableCfg.SubType or 0)
    return PWorldSubType
end

--主城
function PWorldMgr:CurrIsInMainCity()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
	if (PWorldTableCfg ~= nil) then
		return PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY
	end
    return false
end

--野外
function PWorldMgr:CurrIsInField()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
	if (PWorldTableCfg ~= nil) then
		return PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_FIELD
	end
    return false
end

--副本
function PWorldMgr:CurrIsInDungeon()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
	if (PWorldTableCfg ~= nil) then
		return PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON
	end
    return false
end

-- 水晶冲突
function PWorldMgr:CurrIsInPVPColosseum()
    local CurWorldSubType = self:GetCurrPWorldSubType()
    local bCurWorldSubType = CurWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_COLOSSEUM
    return bCurWorldSubType
end

-- 纷争前线
function PWorldMgr:CurrIsInPVPFrontLine()
    local CurWorldSubType = self:GetCurrPWorldSubType()
    local bCurWorldSubType = CurWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_FRONT_LINE
    return bCurWorldSubType
end

-- 冒险游商团
function PWorldMgr:CurrIsInMerchant()
    local CurWorldSubType = self:GetCurrPWorldSubType()
    local bIsMerchant = CurWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_MERCHANT
    return bIsMerchant
end


--是否是特殊类型的副本,非正常全屏蔽
function PWorldMgr:CurrIsSpecialTypeMap()
    local CurWorldSubType = self:GetCurrPWorldSubType()
    local bCurWorldType = self:GetCurrPWorldType()
    local bCurWorldIsSpecial = false

    if bCurWorldType == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON  then
        bCurWorldIsSpecial  = true
    elseif CurWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_FRONT_LINE  then
        bCurWorldIsSpecial  = true
    elseif CurWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_DUNGEON  then
        bCurWorldIsSpecial  = true
    elseif CurWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_COLOSSEUM  then
        bCurWorldIsSpecial  = true
    elseif CurWorldSubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_4R  then
        bCurWorldIsSpecial  = true
    elseif CurWorldSubType == ProtoRes.pworld_type.PWORLD_SUB_TYPE_8R  then
        bCurWorldIsSpecial  = true
    elseif self:CurrIsInSingleDungeon()  then
        bCurWorldIsSpecial  = true
    elseif self:CurrIsInPrivateDungeon()  then
        bCurWorldIsSpecial  = true
    end

    return bCurWorldIsSpecial
end

function PWorldMgr:LastIsInDungeon()
    local PWorldTableCfg = self:GetLastPWorldTableCfg()
	if (PWorldTableCfg ~= nil) then
		return PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON
	end
    return false
end

--单人副本
function PWorldMgr:CurrIsInSingleDungeon()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
	if (PWorldTableCfg ~= nil) then
		return PWorldTableCfg.MinPlayerNum == 1 and PWorldTableCfg.MaxPlayerNum == 1
	end
    return false
end

--私人副本(界面表现上跟主城一致，但功能上是副本，每个玩家都有一个副本实例，而不像主城是共享)
function PWorldMgr:CurrIsInPrivateDungeon()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
	if (PWorldTableCfg ~= nil) then
		return PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_PRIVATE
	end
    return false
end

--当前地图是否需要根据视点坐标动态加载LevelStreaming
function PWorldMgr:IsNeedStreamingLevelInViewLocation()
    local PWorldTableCfg = self:GetCurrPWorldTableCfg()
    if (PWorldTableCfg == nil) then
        return false
    end

	if (PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON or PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY
    or PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_FIELD or PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_PRIVATE) then
        return true
	end

    return false
end

---当前是否是从副本中退出来（当前非副本、上一个场景是副本）
function PWorldMgr:CurrIsFromDungeonExit()
	return self:LastIsInDungeon() and not self:CurrIsInDungeon()
end

--获取地图Festival LayersetName
function PWorldMgr:GetFestivalLayersetInfo(LayerSetList)
    if LayerSetList ~= nil then
        local Cfgs = FestivalLayersetCfg:FindAllCfg()
        local LayersetInfoList = {}
        if Cfgs then
            for i = 1, #Cfgs do
                local Cfg = Cfgs[i]
                for k, v in ipairs(LayerSetList) do
                    if Cfg.LayerSetID == v then
                        if Cfg.HolidayEditFile ~= nil and Cfg.HolidayEditFile ~= "" then
                            table.insert(LayersetInfoList,{Cfg.LayersetName,Cfg.HolidayEditFile})
                        else
                            table.insert(LayersetInfoList,{Cfg.LayersetName})
                        end
                    end
                end
            end

            return LayersetInfoList
        end
    else
        return {}
    end
end

--获取地图LAYERSET
function PWorldMgr:GetMapLayersetName(MapResID)
    if (MapResID == nil or MapResID == 0) then
        return 0
    end

    FLOG_INFO("MapResID is %d",MapResID)

    local MapTableCfg = self:GetMapTableCfg(MapResID)
    if (MapTableCfg == nil) then
        return ""
    end

    FLOG_INFO("Layerset Name is %s",MapTableCfg.LayersetName)

    return MapTableCfg.LayersetName
end


function PWorldMgr:SetMajorLocationAndRotator(Pos, Dir)
    if (Pos ~= nil) then
        --等地图切换完成后再给major赋值
        self.MajorBirthPos = _G.UE.FVector(Pos.X, Pos.Y, Pos.Z)
    else
        self.MajorBirthPos = _G.UE.FVector(0, 0, 0)
    end

    if (Dir ~= nil) then
        self.MajorBirthRotator = _G.UE.FRotator(0, Dir, 0)
    else
        self.MajorBirthRotator = _G.UE.FRotator(0, 0, 0)
    end
end

function PWorldMgr:GetMajorBirthPos()
    if (self.MajorBirthPos == nil) then
        return _G.UE.FVector(0, 0, 0)
    end

    return self.MajorBirthPos
end

function PWorldMgr:GetMajorBirthRot()
    if (self.MajorBirthRotator == nil) then
        return _G.UE.FRotator(0, 0, 0)
    end

    return self.MajorBirthRotator
end

function PWorldMgr:CheckPWorldAndMapIsValid(RspData)
    if (self.BaseInfo.CurrPWorldInstID == RspData.PWorldInstID and self.BaseInfo.CurrMapResID == RspData.MapResID) then
        return true
    end
    return false
end

--是否显示切换地图loading，副本内传送不显示
function PWorldMgr:IsShowLoading()
    if (self.MapTravelInfo == nil) then
       return false
    end
    return self.MapTravelInfo.bShowLoading
end

--切换地图到客户端本地场景，比如login、选角、登录的环境展示地图
function PWorldMgr:ChangeToLocalMap(MapPath, bShowLoading)
    if (self.MapTravelInfo ~= nil) then
        self.MapTravelInfo.bShowLoading = bShowLoading
    end

    local UWorldMgr = _G.UE.UWorldMgr:Get()
    if UWorldMgr then
        self.LoadWorldReason = _G.UE.ELoadWorldReason.Normal
        UWorldMgr:LoadWorld(MapPath, self.LoadWorldReason)
    end
end

--切换地图到客户端本地场景，给sequence切换地图用
function PWorldMgr:ChangeMapForCutScene(MapPath, bShowLoading, LoadWorldReason, bSkipLoadLayerSet, bSkipLoadLevelStreaming)
    self.CurWorldPath = nil
    local UWorldMgr = _G.UE.UWorldMgr:Get()
    if UWorldMgr then
        if (self.MapTravelInfo ~= nil) then
            self.MapTravelInfo.bShowLoading = bShowLoading

            --sequence播放完成后需要切回原场景，走正常LoadWorld流程； 地图Loading过程中是不能播放Sequence的，所以ELoadWorldReason::CutScene不能设置TravelStatus为MapLoadStatus.Loading
            if (LoadWorldReason == _G.UE.ELoadWorldReason.Normal or LoadWorldReason == _G.UE.ELoadWorldReason.RestoreNormal) then
                self.MapTravelInfo.TravelStatus = MapLoadStatus.Loading
            end
        end

        --LoadWorld的时候 切换地图之前FSeamlessTravelHandler::Tick()中会执行到ACutSceneSequenceActor的EndPlay，会调用Sequence的Stop
        --但PossessableActorTArray里的对象在Stop之前的某个时候释放掉了，导致崩溃，所以这里先清除数据
        local bClearSequenceCacheInfo = false
        if (LoadWorldReason == _G.UE.ELoadWorldReason.RestoreNormal) then
            bClearSequenceCacheInfo = true
        end

        self:ResetMap() --清除本地图动态创建的Actor

        _G.EventMgr:SendEvent(EventID.LoadWorldInCutScene, bClearSequenceCacheInfo)

        self.LoadWorldReason = LoadWorldReason

        self.CurWorldPath = MapPath
        UWorldMgr:LoadWorldForNCut(MapPath, LoadWorldReason, bSkipLoadLayerSet, bSkipLoadLevelStreaming)
    end
end

function PWorldMgr:CreateMajor()
    local BirthPos = self.MajorBirthPos
    local InElevator, OutPos = PWorldMgr:ComputeFloorPosInElevator(self.MajorBirthPos)
    if InElevator then
        BirthPos = OutPos
    end
    ActorManager:Get():CreateMajor(self.MajorEntityID, BirthPos, self.MajorBirthRotator, true)
end

-- 遍历副本表, 创建MapResID和对应主城或野外地图BGM的索引
function PWorldMgr:InitMapResBGMTable()
    self.MapResBGMTable = {}
    local InvalidMapResTable = {}
    local AllPWorldCfg = self:GetAllPworldTableCfg()
    for _, Value in ipairs(AllPWorldCfg) do
        local MapType = Value.Type
        local MapID = Value.MapList[1]
        if MapType == ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY or MapType == ProtoRes.pworld_type.PWORLD_CATEGORY_FIELD then
            local MapTableCfg = self:GetMapTableCfg(MapID)
            if MapTableCfg ~= nil then
                local MapResId = MapTableCfg.LevelID
                local BGMusic = MapTableCfg.BGMusic
                if InvalidMapResTable[MapResId] == nil then
                    -- 如果有主城的资源ID相同, 但是BGM不同, 直接跳过
                    if self.MapResBGMTable[MapResId] and self.MapResBGMTable[MapResId] ~= BGMusic then
                        self.MapResBGMTable[MapResId] = nil
                        InvalidMapResTable[MapResId] = true
                    else
                        self.MapResBGMTable[MapResId] = BGMusic
                    end
                end
            end
        end
    end
end

-- 根据MapResID找到场景BGM
---@param MapResID number @地图资源ID, 对应地图表LevelID
function PWorldMgr:GetSceneBGM(MapResID)
    -- 第一次查找的时候遍历副本表建立映射关系
    if self.MapResBGMTable == nil then
        self:InitMapResBGMTable()
    end
    return self.MapResBGMTable[MapResID]
end

-- 有些NCut里面没有配置BGM, 切完场景之后需要用当前场景的BGM
-- 只考虑主城和野外地图的BGM, 副本之类的地图需要策划手动补一下
function PWorldMgr:PlaySceneBGMForCutScene()
    if not self.CurWorldPath then
        FLOG_ERROR("[PWorldMgr:PlaySceneBGMForCutScene]CurWorldPath is nil")
        return
    end
    local MapResTableCfg = MapResCfg:FindCfg(string.format("PersistentLevelPath = \"%s\"", self.CurWorldPath))
    if MapResTableCfg == nil then
        FLOG_ERROR("[PWorldMgr:PlaySceneBGMForCutScene]Cannot find MapResTableCfg, WorldPath = %s", self.CurWorldPath)
        return
    end
    local LevelID = MapResTableCfg.LevelID or 0
    local MapBGM = self:GetSceneBGM(LevelID)
    if MapBGM == nil then
        FLOG_ERROR("[PWorldMgr:PlaySceneBGMForCutScene]Cannot find MapBGM, LevelID = %s", LevelID)
        return
    end
    PWorldDynDataMgr:PlayMusicBySceneID(MapBGM)
end

--sequence内客户端本地切换地图回调
function PWorldMgr:PostLoadWorldForCutScene()
    self:ExecSetSOCType()

    self:CreateMajor()

    --关闭Major的CharacterMovement和重力，防止在某些没有配置Major的虚空场景中播放ncut，Major出现掉落
    --不能直接调用DisableMajor()，会关闭动画tick
    local Major = MajorUtil.GetMajor()
    if (Major ~= nil) then
        local CharacterMovement = Major.CharacterMovement
        if (CharacterMovement ~= nil) then
            CharacterMovement:SetComponentTickEnabled(false)
            CharacterMovement.GravityScale = 0
        end
    end

    _G.ActorMgr:PreCreateActors()
    -- 播放场景默认BGM
    self:PlaySceneBGMForCutScene()
    self:SetMapTravelStatusFinish()    

    local bReconnectFlag = false
    local bLoadWorldForCutScene = true
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.IntParam1 = self.BaseInfo.CurrMapResID
    EventParams.IntParam2 = self.BaseInfo.CurrPWorldResID
    EventParams.BoolParam1 = bReconnectFlag
    EventParams.BoolParam2 = bLoadWorldForCutScene

    --发消息给c++端，执行加载关卡数据等流程
    _G.EventMgr:SendCppEvent(EventID.PWorldMapEnter, EventParams)
    --发消息给lua端
    _G.EventMgr:SendEvent(EventID.PWorldMapEnter, { CurrMapResID = self.BaseInfo.CurrMapResID
        , CurrPWorldResID = self.BaseInfo.CurrPWorldResID
        , bReconnect = bReconnectFlag
        , bChangeMap = true
        , bIsChangeMapLevel = true
        , bChangeLine = false
        , bFromCutScene = true })
end

--切换地图
function PWorldMgr:ChangeMap(MapResID, bShowLoading)
    if (MapResID == nil or MapResID == 0) then
        return
    end

    self.MapTravelInfo.bShowLoading = bShowLoading

    _G.MapLoadingStateMgr:LoadMap(MapResID)
end

function PWorldMgr:PlayChangeMapSequence()
    FLOG_INFO("PWorldMgr:PlayChangeMapSequence")
    local SequencePath = "LevelSequence'/Game/Assets/Effect/Particles/UI/Sequence/Tangent_01.Tangent_01'"
    _G.StoryMgr:PlayIndependentSequenceByPath(SequencePath)
end

---是否切换地图
function PWorldMgr:IsChangeMap()
    local bChangeMap = false
    if (self.BaseInfo.LastMapResID ~= self.BaseInfo.CurrMapResID) then
        bChangeMap = true
    end

    if (self:IsTransInSameMap() or self:IsReconnectInSameMap()) then
        bChangeMap = false
    end

    return bChangeMap
end

---是否切换地图Level资源
---切换同关卡资源时，会保留主角，具体参考PWorldMapExit事件的处理
function PWorldMgr:IsChangeMapLevel()
    if (self.BaseInfo == nil) then
        return false
    end

    local bChangeMap = self:IsChangeMap()
    if bChangeMap then
        -- 切换地图，并且LevelID不同
        local LastMapTableCfg = self:GetMapTableCfg(self.BaseInfo.LastMapResID)
        local CurrMapTableCfg = self:GetMapTableCfg(self.BaseInfo.CurrMapResID)
        if LastMapTableCfg and CurrMapTableCfg
            and LastMapTableCfg.LevelID ~= CurrMapTableCfg.LevelID then
            return true
        end
    end

    return false
end

---是否切换相位副本
function PWorldMgr:IsChangePhaseMap()
    if (self.BaseInfo == nil) then
        return false
    end
    local Major = MajorUtil.GetMajor()
    if (Major == nil) then
        return false
    end

    --[[切换条件：
        地图关卡资源相同
        出生点位置和主角当前位置相同，设了一定容错距离
        地图表配了相位副本传送
    --]]
    local LastMapTableCfg = self:GetMapTableCfg(self.BaseInfo.LastMapResID)
    local CurrMapTableCfg = self:GetMapTableCfg(self.BaseInfo.CurrMapResID)
    if LastMapTableCfg and CurrMapTableCfg
        and LastMapTableCfg.LevelID == CurrMapTableCfg.LevelID
        and (LastMapTableCfg.PhaseMapChange == 1 or CurrMapTableCfg.PhaseMapChange == 1) then
        local Location = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
        local Dist = _G.UE.FVector.Dist(self.MajorBirthPos, Location)
        local LimitDistance = 1000
        if Dist < LimitDistance then
            return true
        end
    end

    return false
end

---是否当前地图切线
function PWorldMgr:IsChangeLine()
    if (self.BaseInfo == nil) then
        return false
    end

    local bChangeLine = false
    if (self.BaseInfo and self.BaseInfo.LastPWorldResID == self.BaseInfo.CurrPWorldResID
        and self.BaseInfo.LastMapResID == self.BaseInfo.CurrMapResID
        and self.BaseInfo.LastLineID ~= self.BaseInfo.CurrLineID) then
        bChangeLine = true
    end

    return bChangeLine
end

---是否跨界传送
function PWorldMgr:IsCrossWorld()
    if (self.BaseInfo == nil) then
        return false
    end

    local bCrossWorld = false
    if (self.BaseInfo and self.BaseInfo.LastPWorldResID == self.BaseInfo.CurrPWorldResID
        and self.BaseInfo.LastMapResID == self.BaseInfo.CurrMapResID
        and self.BaseInfo.LastWorldID ~= self.BaseInfo.CurrWorldID) then
        bCrossWorld = true
    end

    return bCrossWorld
end

---IsChangePWorld 判断副本实例 与“IsChangeLine”的区别在于，副本销毁重新创建后，Line一样但是实例ID不一样
---@return boolean
function PWorldMgr:IsChangePWorld()
    if self.BaseInfo == nil then
        return false
    end

    local bChangePWorld = false
    if self.BaseInfo.LastPWorldInstID > 0 and  self.BaseInfo.LastPWorldInstID ~= self.BaseInfo.CurrPWorldInstID then
        bChangePWorld = true
    end

    return bChangePWorld
end

---是否停止切地图
function PWorldMgr:IsStopChangeMap(PWorldResID)
    --情况一：新手副本直接播sequence
    if _G.NewbieMgr:IsNewbiePWorld(PWorldResID) then
        return _G.NewbieMgr:PlayCutScene()
    end
    return false
end

--进入地图完成，这是切地图最后一步
function PWorldMgr:OnEnterMapFinish(IsTimeout)
    FLOG_INFO("PWorldMgr:OnEnterMapFinish IsTimeout=%s", tostring(IsTimeout))
    if (self.MapDynDataMsgMonitor ~= nil) then
        self.MapDynDataMsgMonitor:Destroy()
        self.MapDynDataMsgMonitor = nil
    end

    local Major = MajorUtil.GetMajor()
    local InElevator, OutPos = PWorldMgr:ComputeFloorPosInElevator(self.MajorBirthPos, Major)

    if InElevator and Major then
        Major:FSetVectorForServer(OutPos, _G.UE.EXLocationType.ServerLoc)
        Major:AdjustGround(false)
        local FinalPos = Major:FGetActorLocation()
        FLOG_INFO("OnEnterMapFinish, MajorBirthPos In Elevator: %f, %f, %f", FinalPos.X, FinalPos.Y, FinalPos.Z)
    end

    _G.MapLoadingStateMgr:EnterMapFinish()

    _G.EventMgr:SendEvent(EventID.EnterMapFinish)
end

--地图加载完成，开始初始化数据
function PWorldMgr:OnLoadWorldFinish()
    if (self.MapTravelInfo.TravelStatus == MapLoadStatus.LoadFinish or self.MapTravelInfo.TravelStatus == MapLoadStatus.EnterMapFinish) then
        return
    end

    _G.MapLoadingStateMgr:LoadMapFinish()

    _G.EventMgr:SendEvent(EventID.LoadMapFinish)
end

--切地图的原因是客户端本地重置
function PWorldMgr:LoadWorldInClientRestore()
    return self.LoadWorldReason == _G.UE.ELoadWorldReason.RestoreNormal
end

function PWorldMgr:UpdateMapDynDataInClientRestore()
    return self:LoadWorldInClientRestore()
end

function PWorldMgr:UpdateMajorEntityID()
    local MajorActor = MajorUtil.GetMajor()
    if (MajorActor ~= nil) then --刚进入游戏的时候Major可能为nil，CreateMajor的时候会赋值
        _G.UE.UActorManager:Get():UpdateMajorEntityID(self.MajorEntityID)
    end
end

---InPos 用于计算的坐标
---PlayerToIgnore 检查电梯地面时，射线检测需要忽略的玩家，通常是设置坐标的玩家自身
---返回是否在电梯内，以及电梯内的贴地坐标
function PWorldMgr:ComputeFloorPosInElevator(InPos, PlayerToIgnore)
    local OutPos = InPos

    FLOG_INFO("ComputeFloorPosInElevator InPos: %f, %f, %f", InPos.X, InPos.Y, InPos.Z)
    local InElevator, TopZ, Height = _G.MapAreaMgr:GetElevatorTopByPos(InPos.X, InPos.Y, InPos.Z)
    FLOG_INFO("ComputeFloorPosInElevator, InElevator: %s, TopZ: %f, Height: %f", tostring(InElevator) , TopZ, Height)
    if InElevator then
        local TraceBeginLocation = _G.UE.FVector(InPos.X, InPos.Y, TopZ)
        local TraceDirection = _G.UE.FVector(0, 0, -1 * Height)
        local TraceEndLocation = TraceBeginLocation + TraceDirection
        local TraceUtil = _G.UE.UTraceUtil
        if TraceUtil then
            local HitOut = _G.UE.FHitResult()
            local Channel = _G.UE.ECollisionChannel.ECC_Pawn
            local World = _G.UE.UFGameInstance.Get():GetWorld()
            if TraceUtil.LineTrace(World, PlayerToIgnore, TraceBeginLocation, TraceEndLocation, HitOut, Channel, false, true) then
                local HitActorName = HitOut.Actor and HitOut.Actor:GetName() or "NONE"
                local HitCompName = HitOut.Component and HitOut.Component:GetName() or "NONE"
                FLOG_INFO("HitFloor: %f, %s/%s", HitOut.Location.Z, HitActorName, HitCompName)
                OutPos.Z = HitOut.Location.Z + 5
            end
        end
    end
    FLOG_INFO("ComputeFloorPosInElevator OutPos: %f, %f, %f", OutPos.X, OutPos.Y, OutPos.Z)

    return InElevator, OutPos
end

--同地图网络重连
function PWorldMgr:PostLoadWorldForReconnectInSameMap(bDynDataIsInited)
    local Major = MajorUtil.GetMajor()
    if not _G.StoryMgr:SequenceIsPlaying() and Major then
        FLOG_INFO("PostLoadWorldForReconnectInSameMap MajorBirthPos: %f, %f, %f", self.MajorBirthPos.X, self.MajorBirthPos.Y, self.MajorBirthPos.Z)
        Major:FSetRotationForServerNoInterp(self.MajorBirthRotator)

        local BirthPos = self.MajorBirthPos
        local InElevator, OutPos = PWorldMgr:ComputeFloorPosInElevator(self.MajorBirthPos, Major)
        if InElevator then
            BirthPos = OutPos
            local FinalPos = Major:FGetActorLocation()
            FLOG_INFO("OnEnterMapFinish, MajorBirthPos In Elevator: %f, %f, %f", FinalPos.X, FinalPos.Y, FinalPos.Z)
        end

        local LastPos = Major:FGetActorLocation()
        if Major:IsPathWalking() then
            -- 自动寻路断线重连重设坐标发事件
            local BirthDist = _G.UE.FVector.Dist2D(LastPos, BirthPos)
            if BirthDist > MoveConfig.FindPathServerLimitDist then
                _G.EventMgr:SendEvent(EventID.AutoPathServerPull)
            end
        end
        -- 防止前后台精度误差的坐标偏移造成的碰撞渗透
        if FMath.abs(LastPos.X - BirthPos.X) < 1.0 then
            BirthPos.X = LastPos.X
        end
        if FMath.abs(LastPos.Y - BirthPos.Y) < 1.0 then
            BirthPos.Y = LastPos.Y
        end

        Major:FSetVectorForServer(BirthPos, _G.UE.EXLocationType.ServerLoc)
        if not Major:IsInFly() then
            Major:AdjustGround(false)
        end
        --LoadMapFinishState里也会执行，这里判断下避免重复执行
        if (bDynDataIsInited) then
            Major:OnMajorCreate(self.MajorEntityID, true, true)
        end

        if InElevator then
            local FinalPos = Major:FGetActorLocation()
            FLOG_INFO("PostLoadWorldForReconnectInSameMap MajorBirthPos In Elevator: %f, %f, %f", FinalPos.X, FinalPos.Y, FinalPos.Z)
        end
    end

     --NCUT中切换地图重连情况
     if (_G.StoryMgr:SequenceIsPlaying() and (self.LoadWorldReason == _G.UE.ELoadWorldReason.RestoreNormal
        or self.LoadWorldReason == _G.UE.ELoadWorldReason.CutScene)) then
        FLOG_INFO("PWorldMgr: Reconnect in samemap for cutscene!")
        self:SetMapTravelStatusFinish()
        return
    end

    if (bDynDataIsInited) then
        self:SetMapTravelStatusFinish()
        self:SendGetMapData()
    else
        PWorldDynDataMgr:Init()
        self:OnLoadWorldFinish()
    end
end

--地图加载完成回调
function PWorldMgr:PostLoadWorld()
    if (self.BaseInfo == nil) then
        print("PWorldMgr:PostLoadWorld BaseInfo is null!!!")
        return
    end

    local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    --不重新加载MapEditCfg
    if (self:LoadWorldInClientRestore() and CurrMapEditCfg ~= nil) then
        PWorldDynDataMgr:Init()
        self:OnLoadWorldFinish()
    else
        _G.MapLoadingStateMgr:LoadMapEditCfg(self.BaseInfo.CurrMapResID)
    end
end


--加载关卡编辑器地图数据(c++代码里回调)
function PWorldMgr.OnLoadMapEditCfg(BodyBuffer)
    _G.MapLoadingStateMgr:OnLoadMapEditCfg(BodyBuffer)
end

function PWorldMgr:GetEnterMapServerFlag()
    return self.EnterMapServerFlag
end

function PWorldMgr:NeedLoadSublevelsInAutoSequence()
    if (self.EnterMapServerFlag ~= 0) then
        return false
    end

    if (not self:CurrIsInDungeon()) then
        return false
    end

    --同地图传送
    if (self:IsTransInSameMap()) then
        return false
    end

    return true
end

function PWorldMgr:OnGameEventLoginRes(Params)
	print("PWorldMgr:OnGameEventLoginRes")

	if Params.bReconnect then
        self:CheckReconnectAutoPlayBeforeReady()

        self:SendMechanismData()
	end

    CrystalPortalMgr:OnLoginRsp()
end

function PWorldMgr:CheckReconnectAutoPlayBeforeReady()
    if not PWorldDynDataMgr.bDynDataLoaded then
        -- LoginRes是Post事件，但判断AutoPlay依赖DynData，需要等DynData加载完
        FLOG_INFO("PWorldMgr:CheckReconnectAutoPlayBeforeReady wait to load DynData")
        PWorldDynDataMgr.bCheckReconnectAutoPlay = true
        return
    end

    local StoryMgr = _G.StoryMgr
    local bAutoPlayingSeq = false
    local CutSceneSequence = PWorldDynDataMgr:GetAutoPlaySequence()
    if StoryMgr:SequenceIsPlaying() then
        if CutSceneSequence and CutSceneSequence.ID > 0 then
            local CurrSeqID = StoryMgr:GetCurrentSequenceID()
            bAutoPlayingSeq = CutSceneSequence.ID == CurrSeqID
        end
    end

    if not bAutoPlayingSeq then
        if (self.bSendReady and not self.bRspReady and CutSceneSequence) then     -- 准备期间断线重连
            self:SendMovieEnd(CutSceneSequence.ID, 1, 0)
        end

        local bLoadingViewVisible = _G.LoadingMgr:IsLoadingView()
        if (not bLoadingViewVisible) then
            if (self.ReadyMsgMonitor ~= nil) then
                self.ReadyMsgMonitor:Destroy()
                self.ReadyMsgMonitor = nil
            end

            self:SendReady()
        end
    end
end
function PWorldMgr:OnGameEventPWorldMapEnter(Params)
    local SelfExecuteActions = _G.MapEditDataMgr:GetSelfExecuteActions()
    if (SelfExecuteActions ~= nil and #SelfExecuteActions > 0) then
        for _, Value in ipairs(SelfExecuteActions) do
            local TriggerAction = _G.MapEditDataMgr:GetTriggerAction(Value)
            --_G.FLOG_ERROR("OnGameEventPWorldMapEnter!!!!!!!!!!! ActionID=%d", Value)
            if (TriggerAction ~= nil) then
                local ActionParams = {}
                ActionParams.StrParam = TriggerAction.StrParam
                ActionParams.ParamBool = TriggerAction.ParamBool
                ActionParams.Param1 = TriggerAction.Param1
                ActionParams.Param2 = TriggerAction.Param2
                ActionParams.Param3 = TriggerAction.Param3
                ActionParams.Param4 = TriggerAction.Param4
                ActionParams.Param5 = TriggerAction.Param5
                ActionParams.Param6 = TriggerAction.Param6
                ActionParams.Param7 = TriggerAction.Param7
                ActionParams.Param8 = TriggerAction.Param8
                ActionParams.Param9 = TriggerAction.Param9
                ActionParams.Param10 = TriggerAction.Param10
                ActionParams.Param11 = TriggerAction.Param11
                --ActionParams.TriggerEntityID = TriggerActionExec.TriggerEntityID
                --ActionParams.Entities = TriggerActionExec.Entities
                local ActionType = TriggerAction.Type
                PWorldTriggerActionExecMgr:OnTriggerActionExec(ActionType, ActionParams)
            end
        end
    end

    self:SendMechanismData()
end

function PWorldMgr:OnDynamicAssetLoadInLand(Params)
    if (Params.ObjectParam == nil) then
        return
    end

    local DynamicAssetActor = Params.ObjectParam:Cast(_G.UE.AMapDynamicAssetBase)
    if (DynamicAssetActor ~= nil) then
        local EDynamicAssetType = _G.UE.EMapDynamicAssetType
        if (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Effect) then
            PWorldDynDataMgr:OnDynamicAssetLoadInLand(DynamicAssetActor)

        elseif (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Elevator) then
            PWorldElevatorMgr:OnDynamicAssetLoadInLand(DynamicAssetActor)
        end
    end

    local SgActor = Params.ObjectParam:Cast(_G.UE.ASgLayoutActorBase)
    if (SgActor ~= nil) then
        PWorldDynDataMgr:OnSgActorLoadInLand(SgActor)
    end
end

function PWorldMgr:OnDynamicAssetUnLoadInLand(Params)
    if (Params.ObjectParam == nil) then
        return
    end
    local DynamicAssetActor = Params.ObjectParam:Cast(_G.UE.AMapDynamicAssetBase)
    if (DynamicAssetActor ~= nil) then
        local EDynamicAssetType = _G.UE.EMapDynamicAssetType
        if (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Effect) then
            PWorldDynDataMgr:OnDynamicAssetUnLoadInLand(DynamicAssetActor)

        elseif (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Elevator) then
            PWorldElevatorMgr:OnDynamicAssetUnLoadInLand(DynamicAssetActor)
        end
    end

    local SgActor = Params.ObjectParam:Cast(_G.UE.ASgLayoutActorBase)
    if (SgActor ~= nil) then
        PWorldDynDataMgr:OnSgActorUnLoadInLand(SgActor)
    end
end

function PWorldMgr:PlayMonsterRelevanceLineEffect(SelectedTarget)
    local AttrComponent = SelectedTarget:GetAttributeComponent()
    if (AttrComponent == nil) then
        return
    end
    --因为副本内怪物组是关联仇恨的，所以选中的怪物如果处于战斗中，其他关联的怪物的状态也应该是战斗中，此时不需要关联仇恨线
    if (self:CurrIsInDungeon()) then
        local StateComponent = SelectedTarget:GetStateComponent()
        if (StateComponent == nil or StateComponent:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT)) then
            return
        end
    end

    local MonsterListIDs = _G.MapEditDataMgr:GetMonstersInSameTaunt(AttrComponent.ListID)
    if (MonsterListIDs == nil or #MonsterListIDs == 0) then
        --非副本内
        if (not self:CurrIsInDungeon()) then
            _G.CombatMgr:SendGetRelateEnmityListReq(AttrComponent.EntityID)
        end

        return
    end

    local RelevanceTargetIDs = {}
    for i = 1, #MonsterListIDs do
        local Monster = _G.UE.UActorManager:Get():GetMonsterByListID(MonsterListIDs[i])
        if (Monster ~= nil) then
            local MonsterAttrComponent = Monster:GetAttributeComponent()
            if (MonsterAttrComponent ~= nil and MonsterAttrComponent.EntityID ~= AttrComponent.EntityID) then
                if (self:CurrIsInDungeon()) then
                    table.insert(RelevanceTargetIDs, MonsterAttrComponent.EntityID)
                else
                    local StateComponent = Monster:GetStateComponent()
                    --不处于战斗中
                    if (StateComponent ~= nil and not StateComponent:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT)) then
                        table.insert(RelevanceTargetIDs, MonsterAttrComponent.EntityID)
                    end
                end
            end
        end
    end
    LineEffectPlayer:Start(SelectedTarget, RelevanceTargetIDs)
end

--手动选择目标
function PWorldMgr:OnManualSelectTarget(Params)
    if (self.RencentlyManualSelectTime == nil) then
        self.RencentlyManualSelectTime = -1
    end
    local NowTime = _G.TimeUtil.GetServerTimeMS()
    if ((NowTime - self.RencentlyManualSelectTime) < 500) then
        return
    end
    self.RencentlyManualSelectTime = NowTime

    local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
    if (SelectedTarget == nil) then
        return
    end
    local TargetType = SelectedTarget:GetActorType()
    --只处理怪物的，播放仇恨关联表现
    if (TargetType == _G.UE.EActorType.Monster and _G.SettingsMgr:GetValueBySaveKey("ShowRelevanceLine") == 1) then
        self:PlayMonsterRelevanceLineEffect(SelectedTarget)
    end
end

function PWorldMgr:OnCombatGetRelateEnmityList(Params)
    local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
    if (SelectedTarget == nil) then
        return
    end

    local EnmityList = Params.EntityID
    if (#EnmityList == 0) then
        return
    end
    local RelevanceTargetIDs = {}
    for _, Value in ipairs(EnmityList) do
        table.insert(RelevanceTargetIDs, Value)
    end

    LineEffectPlayer:Start(SelectedTarget, RelevanceTargetIDs)
end

function PWorldMgr:OnUpdateQuest(Params)
    -- MapQuestObjMgr:LoadMapQuestObj()
    MapQuestObjMgr:OnUpdateQuest()
end

--本地客户端改变DynData状态
--InType		MapDynData类型，参考common::MapDynType
--InId		    策划负责配置的当前MapDynData的id
--InState		要设置的State
function PWorldMgr:LocalUpdateDynData(InType, InId, InState)
    local MapDynData = {}
    MapDynData.Type = InType
    MapDynData.ID = InId
    MapDynData.Status = InState
    PWorldDynDataMgr:UpdateDynData(MapDynData)
end

--当前的world
--如果想获取原始的world，使用_G.LoginMgr:GetWorldID()
function PWorldMgr:GetCurrWorldID()
    local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
        return RoleVM.CurWorldID
    else
        FLOG_ERROR("PWorldMgr:GetCurrWorldID EmptyRoleVM Get Value 0 ")
        return 0
    end
end

function PWorldMgr:GetCurrPWorldResID()
	local BaseInfo = self.BaseInfo
	if nil == BaseInfo then return 0 end

	return BaseInfo.CurrPWorldResID
end

function PWorldMgr:GetCurrPWorldInstID()
    local BaseInfo = self.BaseInfo
	if nil == BaseInfo then return 0 end

	return BaseInfo.CurrPWorldInstID
end

function PWorldMgr:GetLastPWorldResID()
	local BaseInfo = self.BaseInfo
	if nil == BaseInfo then return 0 end

	return BaseInfo.LastPWorldResID
end

function PWorldMgr:GetCurrMapResID()
	local BaseInfo = self.BaseInfo
	if nil == BaseInfo then return 0 end

	return BaseInfo.CurrMapResID
end

function PWorldMgr:GetLastMapResID()
    local BaseInfo = self.BaseInfo
    if nil == BaseInfo then return 0 end

    return BaseInfo.LastMapResID
end

function PWorldMgr:GetLastTransMapResID()
    local BaseInfo = self.BaseInfo
    if nil == BaseInfo then return 0 end

    return self.BaseInfo.LastTransMapResID
end

function PWorldMgr:GetWorldOriginLocation()
    local OriginLocation = _G.UE.FVector(0, 0, 0)
    local UWorldMgr = _G.UE.UWorldMgr:Get()
    if (UWorldMgr ~= nil) then
        OriginLocation = UWorldMgr:GetOriginLocation()
    end
    return OriginLocation
end

function PWorldMgr:GetGroudPosByLineTrace(Pos, ZOffset, bIgnoreWater)
    if nil == Pos then
        return nil, false
    end

    bIgnoreWater = bIgnoreWater or false
    local OutFloorPoint = _G.UE.FVector()
    local Rlt = _G.UE.UWorldMgr.Get():GetGroudPosByLineTrace(OutFloorPoint, Pos, ZOffset, false, bIgnoreWater)

    return OutFloorPoint, Rlt
end

function PWorldMgr:GetStartTime()
    if self.BaseInfo and self.BaseInfo.BeginTime then
        return self.BaseInfo.BeginTime
    end

    return 0
end

function PWorldMgr:GetEndTime()
    if self.BaseInfo and self.BaseInfo.EndTime then
        return self.BaseInfo.EndTime
    end

    return 0
end

function PWorldMgr:GetOwnerID()
    local BaseInfo = self.BaseInfo
	if nil == BaseInfo then return 0 end

	return BaseInfo.OwnerID
end

function PWorldMgr:GetDuringTime()
    local Now = _G.TimeUtil.GetServerTime()
    local StartTime = PWorldMgr:GetStartTime() or 0
    local Delta = Now - StartTime
    return Delta
end

function PWorldMgr:GetRemainTime()
    local Now = _G.TimeUtil.GetLocalTime()
    local EndTime = PWorldMgr:GetEndTime() or 0
    local Delta = EndTime - Now
    -- print("zhg GetRemainTime = " .. tostring(Delta))
    return Delta
end

function PWorldMgr:GetMode()
    return self.Mode
end

function PWorldMgr:IsFromMatch()
    return self.IsMatch
end

function PWorldMgr:GetSceneLevel()
    return self.SceneLevel or 0
end

---获取主角所在副本分线ID
function PWorldMgr:GetCurrPWorldLineID()
	local BaseInfo = self.BaseInfo
	if nil == BaseInfo then return 0 end

	return BaseInfo.CurrLineID
end

---获取当前副本分线列表
function PWorldMgr:GetCurrPWorldLineList()
	local BaseInfo = self.BaseInfo
	if nil == BaseInfo then return {} end

	return BaseInfo.LineList
end

---是否显示副本分线信息
function PWorldMgr:IsShowPWorldLine()
    local PWorldLineCfgItem = PworldLineCfg:FindCfgByKey(self:GetCurrPWorldResID())
    if nil == PWorldLineCfgItem then
        return false
    end

    return PWorldLineCfgItem.IsShowLine > 0
end

---获取副本分线状态图标
function PWorldMgr:GetPWorldLineStateIconPath(PlayerNum)
    -- 默认，流畅
    local LineStateIconPath = "Texture2D'/Game/UI/Texture/Map/UI_Map_Icon_SwitchBranch_Flow.UI_Map_Icon_SwitchBranch_Flow'"

    local PWorldLineCfgItem = PworldLineCfg:FindCfgByKey(self.BaseInfo.CurrPWorldResID)
    if nil == PWorldLineCfgItem then
        FLOG_ERROR("[PWorldMgr:GetPWorldLineStateIconPath] no c_pworld_line_cfg PWorldResID=%d", self.BaseInfo.CurrPWorldResID)
        return LineStateIconPath
    end

    if PlayerNum >= PWorldLineCfgItem.HardLimit then
        -- 硬上限，爆满
        LineStateIconPath = "Texture2D'/Game/UI/Texture/Map/UI_Map_Icon_SwitchBranch_BePacked.UI_Map_Icon_SwitchBranch_BePacked'"
    elseif PlayerNum >= PWorldLineCfgItem.SoftLimit * 0.5 then
        -- 软上限的50%，繁忙
        LineStateIconPath = "Texture2D'/Game/UI/Texture/Map/UI_Map_Icon_SwitchBranch_Busy.UI_Map_Icon_SwitchBranch_Busy'"
    end

	return LineStateIconPath
end

--重置背景音乐(这里后面需要干掉，现在不需要逻辑来控制Restore，停掉当前业务播放的BGM后，会自动切回场景的BGM)
function PWorldMgr:RestoreBGMusic()
    -- 临时处理下片尾动画结束后的BGM切换，后续看下怎么和过场动画统一
    if (PWorldDynDataMgr.MapBGMusic ~= nil and PWorldDynDataMgr.MapBGMusic ~= "") then
        PWorldDynDataMgr:PlayMusicBySceneID(PWorldDynDataMgr.MapBGMusic)
    else
        -- 一些场景没有BGM，直接停掉
        _G.UE.UAudioMgr.Get():StopSceneBGM()
    end
end

--开场动画结束（或者没有开场动画）
function PWorldMgr:OnAutoPlaySequenceFinish()
    if self:CurrIsInDungeon() then
        PWorldDynDataMgr:PlayDungeonBGM()
    end

    --避免发送两次，OnGameEventLoginRes里也会发送ready
    if (not self.bSendReady) or (not self:IsReconnectInSameMap()) then
        self:SendReady()
    end
end

--切换地图默认背景音乐（出地图后失效）
function PWorldMgr:SwitchMapDefaultBGMusic(MusicName)
    PWorldDynDataMgr:SwitchMapDefaultBGMusic(MusicName)
end

function PWorldMgr:SendGetMapData()
    self:SendGetMapDynData()
end

--是否完成restore layerset
function PWorldMgr:IsRestoreLayersetFinish()
    local PWorldMgrInstance = CPWorldMgr:Get()
    return PWorldMgrInstance:IsRestoreLayersetFinish()
end

--region 关卡编辑器地图数据相关

--按地图ID加载关卡编辑器数据
function PWorldMgr:LoadMapEditCfgByMapID(MapID, CallBackFunName)
    if (MapID == nil) or (MapID == 0) then
        return
    end
    local PWorldMgrInstance = CPWorldMgr:Get()
    PWorldMgrInstance:LoadOtherMapEditCfg(MapID, CallBackFunName)
end

--加载相邻地图的关卡编辑器的地图数据
function PWorldMgr.OnLoadAdjacentMapEditCfg(BodyBuffer)
    _G.MapLoadingStateMgr:OnLoadAdjacentMapEditCfg(BodyBuffer)
end

--加载节日相关关卡编辑器地图数据
function PWorldMgr.OnLoadFestivalMapEditCfg(BodyBuffer)
    _G.MapLoadingStateMgr:OnLoadFestivalMapEditCfg(BodyBuffer)
end

--加载其他地图的关卡编辑器地图数据
function PWorldMgr.OnLoadOtherMapEditCfg(BodyBuffer)
    local _ <close> = CommonUtil.MakeProfileTag("PWorldMgr.OnLoadOtherMapEditCfg")
	local MapEditCfg = ProtoBuff:Decode("mapedit.MapEditCfg", BodyBuffer)
    if (MapEditCfg ~= nil) then
        _G.MapEditDataMgr:InitOtherMapEditCfg(MapEditCfg)

        -- 这里写法应该改进
        _G.QuestTrackMgr:OnMapEditCfgLoaded(MapEditCfg)
    end
end

--加载关卡编辑器地图染色区域图片数据
function PWorldMgr.OnLoadMapEditAreaImageCfg(BodyBuffer)
	local AreaImageData = ProtoBuff:Decode("mapedit.MapAreaImageData", BodyBuffer)
    if (AreaImageData ~= nil) then
        local CurrMapResID = PWorldMgr:GetCurrMapResID()
        _G.MapAreaImageMgr:Init(CurrMapResID, AreaImageData)
    end
end

--endregion 关卡编辑器地图数据相关

function PWorldMgr:SetShowDownloadResMsgBox()
    self.bShouldShowDownloadResMsgBox = true
end

function PWorldMgr:ShowDownloadResMsgBox()
     -- 提审版本资源下载弹窗提示
     if self.bShouldShowDownloadResMsgBox then
        CommonUtil.ShowDownloadResMsgBox()
        self.bShouldShowDownloadResMsgBox = false
    end
end

function PWorldMgr:SetMapTravelStatusFinish()
    self.MapTravelInfo.TravelStatus = MapLoadStatus.LoadFinish
end

function PWorldMgr:SetMapTravelStatusEnterMapFinish()
    self.MapTravelInfo.TravelStatus = MapLoadStatus.EnterMapFinish
end

function PWorldMgr:SetLoadWorldReason(LoadWorldReason)
    self.LoadWorldReason = LoadWorldReason
end

function PWorldMgr:GetLoadWorldReason()
    return self.LoadWorldReason
end

function PWorldMgr:GetCrystalPortalMgr()
    return CrystalPortalMgr
end

function PWorldMgr:GetPWorldDynDataMgr()
    return PWorldDynDataMgr
end

function PWorldMgr:GetPWorldMechanismDataMgr()
    return PWorldMechanismDataMgr
end

function PWorldMgr:GetPWorldElevatorMgr()
    return PWorldElevatorMgr
end

function PWorldMgr:GetMapQuestObjMgr()
    return MapQuestObjMgr
end

function PWorldMgr:GetMajorEntityID()
    return self.MajorEntityID
end

function PWorldMgr:SetMajorPosAndRotationToBirthPoint()
    local Major = MajorUtil.GetMajor()
    if Major then
        Major:FSetRotationForServerNoInterp(self.MajorBirthRotator)
        Major:FSetVectorForServer(self.MajorBirthPos, _G.UE.EXLocationType.ServerLoc)
    end
end


--获取场景的sequence资源对象
function PWorldMgr:GetSequenceActorFromLevel(SequencePath)
    if (self.CacheLevelSequenceActors == nil) then
        self.CacheLevelSequenceActors = {}
    end
    local SequenceActor = self.CacheLevelSequenceActors[SequencePath]
    if (SequenceActor == nil) then
        local PWorldMgrInstance = CPWorldMgr:Get()
        SequenceActor = PWorldMgrInstance:GetLevelSequenceActor(SequencePath)
        self.CacheLevelSequenceActors[SequencePath] = SequenceActor
    end
    return SequenceActor
end

function PWorldMgr:ResetFadeWhenSequenceStop()
    local PWorldMgrInstance = CPWorldMgr:Get()
    PWorldMgrInstance:ResetFadeWhenSequenceStop()
end

function PWorldMgr:GetAutoPlaySequenceFromDynData()
    return PWorldDynDataMgr:GetAutoPlaySequence()
end

function PWorldMgr:ExecSetSOCType()
    local CurrMapTableCfg = self:GetCurrMapTableCfg()
    if (CurrMapTableCfg ~= nil) then
        local PWorldMgrInstance = CPWorldMgr:Get()
        local SocType = CurrMapTableCfg.SOCType
        SocType = (SocType ~= "" and SocType or "0")
        local SOCTypeList = string.split(SocType, ',')
        for _, SOCType in ipairs(SOCTypeList) do
            local Cmd = string.format("r.Mobile.AllowSoftwareOcclusion %s", SOCType)
            --print("ExecSetSOCType cmd=" .. Cmd)
            PWorldMgrInstance:ExecEngineCmd(Cmd)
        end
    end
end


function PWorldMgr:NotifyEnterMapFinish()
    local bReconnectFlag =  self:RspFlagIsReconnect()
    local CurrMapResIDTemp = self:GetCurrMapResID()
    local CurrPWorldResIDTemp = self:GetCurrPWorldResID()
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.IntParam1 = CurrMapResIDTemp
    EventParams.IntParam2 = CurrPWorldResIDTemp
    EventParams.BoolParam1 = bReconnectFlag
    EventParams.BoolParam2 = false
    --发消息给c++端，执行加载关卡数据等流程
    _G.EventMgr:SendCppEvent(EventID.PWorldMapEnter, EventParams)
    --发消息给lua端
    _G.EventMgr:SendEvent(EventID.PWorldMapEnter, { CurrMapResID = CurrMapResIDTemp
        , CurrPWorldResID = CurrPWorldResIDTemp
        , bReconnect = bReconnectFlag
        , bChangeMap = self:IsChangeMap()
        , bIsChangeMapLevel = self:IsChangeMapLevel()
        , bChangeLine = self:IsChangeLine() })
end


function PWorldMgr:IsLoadingWorld()
    if (self.MapTravelInfo == nil) then
        return false
    end

    return self.MapTravelInfo.TravelStatus == MapLoadStatus.Loading
end

function PWorldMgr:IsEnterMapFinish()
    if (self.MapTravelInfo == nil) then
        return false
    end

    return self.MapTravelInfo.TravelStatus == MapLoadStatus.EnterMapFinish
end

--副本实例ID是否无效，离开副本的时候会置0
function PWorldMgr:PWorldInstIDIsInvalid()
    return self.BaseInfo.CurrPWorldInstID == 0
end

function PWorldMgr:IsTransInSameMap()
    if (self.MapTravelInfo == nil) then
        return false
    end

    return self.MapTravelInfo.bIsTransInSameMap
end

function PWorldMgr:IsReconnectInSameMap()
    if (self.MapTravelInfo == nil) then
        return false
    end

    return self.MapTravelInfo.bEnterSameMapInReconnect
end

function PWorldMgr:GetIsDailyRandom()
    return self.IsDailyRandom
end

function PWorldMgr:GetEnterTag(PWorldEnterTag)
    if (self.BaseInfo.EnterTags ~= nil) then
        --中途进入队伍的不包括
        local EnterTag = self.BaseInfo.EnterTags[PWorldEnterTag]
        if (EnterTag ~= nil) then
            return EnterTag
        end
    end

    return 0
end

--进入副本时队伍是否有未通关的新人
function PWorldMgr:HasNewbieInTeam()
    local bHasNewbie = false
    if (self.BaseInfo.EnterTags ~= nil) then
        --中途进入队伍的不包括
        local EnterTagNewbie = self:GetEnterTag(ProtoCS.PWorldEnterTag.PWorldEnterTagNewbie)
        if (EnterTagNewbie > 0) then
            bHasNewbie = true
        end
    end

    if (not bHasNewbie) then
        bHasNewbie = _G.PWorldTeamMgr:HasFirstPassMem()
    end

    return bHasNewbie
end


--通过InstanceId切换地图里的动态物件状态（一般用于纯客户端效果），后台通知的方式走DynData的UpdateState
function PWorldMgr:PlaySharedGroupTimeline(InstanceID, State)
    local PWorldMgrInstance = CPWorldMgr:Get()
    PWorldMgrInstance:PlaySharedGroupTimeline(InstanceID, State)
end

--- @type 通过InstanceID获得SgActor的Transform
function PWorldMgr:GetInstanceAssetTransform(InstanceID, InTransform)
    local PWorldMgrInstance = CPWorldMgr:Get()
    return PWorldMgrInstance:GetInstanceAssetTransform(InstanceID, InTransform)
end

function PWorldMgr:GetMajorPerchRadiusThreshold(MapID)
	local CurrMapCfg = PWorldMgr:GetMapTableCfg(MapID)
	if not CurrMapCfg then
		return 0
	end
    return CurrMapCfg.MajorCharacterPerchRadiusThreshold;
end

function PWorldMgr:RspFlagIsReconnect(RspFlag)
    RspFlag = RspFlag or self.EnterMapServerFlag
    return RspFlag == 1 or RspFlag == 3
end

--- 检查是否在狼狱停船厂
function PWorldMgr:CurrIsWolvesDenPierStage()
	local PWorldIDCfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_PVPMAINCITY_SCENERESID)
	if PWorldIDCfg then
		local WolvesDenPierPWorldID = PWorldIDCfg.Value[1]
		return self:GetCurrPWorldResID() == WolvesDenPierPWorldID
	end

	return false
end

function PWorldMgr:QueryRoleSceneData(RoleIDs)
    local MsgID = CS_CMD.CS_CMD_PWORLD
    local SubMsgID = ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_QUERY_ROLE_DATA
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, {
        Cmd = SubMsgID,
        QueryRole = {RoleIDs = RoleIDs},
        PWorldInstID = self.BaseInfo.CurrPWorldInstID
    })
end

return PWorldMgr