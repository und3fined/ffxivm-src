-- Author : easyzhu
-- Desc   : 寻宝-宝物库逻辑

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local MapUtil = require("Game/Map/MapUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local UserDataID = require("Define/UserDataID")
local PWorldDynDataMgr = require("Game/PWorld/DynData/PWorldDynDataMgr")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local MapEditDataMgr = require("Game/PWorld/MapEditDataMgr")
local ProtoRes = require("Protocol/ProtoRes")
local LuaCameraMgr = require("Game/Camera/LuaCameraMgr")
local CommonUtil = require("Utils/CommonUtil")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ProtoCS = require("Protocol/ProtoCS")
local AudioUtil = require("Utils/AudioUtil")

local CenterPos = nil
local FirstIconPos = nil
local DirVector = nil
local GameNetworkMgr = nil
local UIViewMgr = nil
local MsgTipsUtil = nil
local MsgBoxUtil = nil
local EventMgr = nil
local EventID = nil
local LSTR = nil
local FLOG_INFO = nil
local FLOG_ERROR = _G.FLOG_ERROR
local TreasureHuntMainVM = nil
local TreasureHuntSkillPanelVM = nil
local UAudioMgr = nil

local m_rouletteSpin = {}
local RING_TIMELINES = {}
local SceneSGObjIDTable = nil
local RouletteType = ProtoRes.Game.RouletteType
local CS_CMD_TREASURE_HUNT = ProtoCS.CS_CMD.CS_CMD_TREASURE_HUNT
local SUB_MSG_ID = ProtoCS.Game.TreasureHunt.CmdTreasureHunt
local MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local CircleRingResID = 2009602
local BGMNull = 1 -- 空的BGM，为的是停掉当前的bgm

local ROULETTE_ROTATION_UNIT_RAD = 3.1415926 * 2 / 12.0
--local ROULETTE_ROTATION_UNIT_RAD = 30

-- 开始转动的时候，背景音乐
local SE_ID_THD_ROULETTE_DRUM =
    "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_146/Play_SE_Event_146.Play_SE_Event_146'"

local TreasuryMgr = LuaClass(MgrBase)
---OnInit
function TreasuryMgr:OnInit()
    --只初始化自身模块的数据，不能引用其他的同级模块
end

---OnBegin
function TreasuryMgr:OnBegin()
    --可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）

    --其他Mgr、全局对象 建议在OnBegin函数里初始化
    GameNetworkMgr = _G.GameNetworkMgr
    UIViewMgr = _G.UIViewMgr
    MsgTipsUtil = _G.MsgTipsUtil
    MsgBoxUtil = _G.MsgBoxUtil
    EventMgr = _G.EventMgr
    EventID = _G.EventID
    UAudioMgr = _G.UE.UAudioMgr.Get()

    FLOG_INFO = _G.FLOG_INFO
    LSTR = _G.LSTR
    EActorType = _G.UE.EActorType

    TreasureHuntMainVM = _G.TreasureHuntMainVM
    TreasureHuntSkillPanelVM = _G.TreasureHuntSkillPanelVM

    _G.UE.FTickHelper.GetInst():SetTickIntervalByFrame(self.TickTimerID, 1)
    _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)

    CenterPos = _G.UE.FVector(10000, -10000, 40)
    FirstIconPos = _G.UE.FVector(7300, -10000, 40)
    DirVector = FirstIconPos - CenterPos

    -- 顺时针的顺序，EOBJID
    SceneSGObjIDTable = {
        7541027,
        7541023,
        7541029,
        7541025,
        7541030,
        7541031,
        7541026,
        7541028,
        7541032,
        7541034,
        7541033,
        7541024
    }

    -- 欺骗表演，原地不动
    RING_TIMELINES[0] = {}
    RING_TIMELINES[0].livenUpTimelineNo = 5
    RING_TIMELINES[0].moveCenterTimelineNo = 11

    -- 欺骗表演，移动一格
    RING_TIMELINES[1] = {}
    RING_TIMELINES[1].livenUpTimelineNo = 7
    RING_TIMELINES[1].moveCenterTimelineNo = 13

    -- 欺骗表演，移动两格
    RING_TIMELINES[2] = {}
    RING_TIMELINES[2].livenUpTimelineNo = 9
    RING_TIMELINES[2].moveCenterTimelineNo = 15

    local SpinTimeCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_ROULETTE_RING_SPIN_TIME)
    if (SpinTimeCfg == nil) then
        FLOG_ERROR("无法获取 GAME_CFG_ROULETTE_RING_SPIN_TIME 全局配置数据，将使用默认数据，请检查 ")
        self.StartWaitTime = 2 -- 开始等待时间
        self.AccelerationTime = 2 -- 加速时间
        self.TopSpeedTime = 0.5 -- 最高速度旋转时间
        self.DecelerationTime = 4.5 -- 减速时间
    else
        -- 减速时间
        self.StartWaitTime = SpinTimeCfg.Value[1] * 0.001 -- 开始等待时间
        self.AccelerationTime = SpinTimeCfg.Value[2] * 0.001 -- 加速时间
        self.TopSpeedTime = SpinTimeCfg.Value[3] * 0.001 -- 最高速度旋转时间
        self.DecelerationTime = SpinTimeCfg.Value[4] * 0.001 -- 减速时间
    end

    local StopTimeCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_ROULETTE_RING_STOP_TIME)
    if (StopTimeCfg == nil) then
        FLOG_ERROR("无法获取 GAME_CFG_ROULETTE_RING_STOP_TIME 全局配置数据，将使用默认数据，请检查 ")
        self.RingLivenUpWaitTime = 1
        -- 转动停止到欺骗表演开始的等待时间
        self.RingLivenUpPlayTime = {} -- 欺骗表演计时时长，总共有三种，第一种停在原地，第二种往前走一格，第三种往前走两格
        self.RingLivenUpPlayTime[1] = 1.5
        self.RingLivenUpPlayTime[2] = 3.5
        self.RingLivenUpPlayTime[3] = 4.5
        self.ringLivenUpHighlightSeWaitTime = 0.45 -- 高亮一下后，播放声音的等待时间
        self.ringMoveCenterWaitTime = 2.5 -- 召唤环移动到中场的时间
    else
        -- 确认高亮一下，到播放移动到中场的等待时间
        self.RingLivenUpWaitTime = StopTimeCfg.Value[1] * 0.001 -- 转动停止到欺骗表演开始的等待时间
        self.RingLivenUpPlayTime = {} -- 欺骗表演计时时长，总共有三种，第一种停在原地，第二种往前走一格，第三种往前走两格
        self.RingLivenUpPlayTime[1] = StopTimeCfg.Value[2] * 0.001
        self.RingLivenUpPlayTime[2] = StopTimeCfg.Value[3] * 0.001
        self.RingLivenUpPlayTime[3] = StopTimeCfg.Value[4] * 0.001
        self.RingLivenUpHighlightSeWaitTime = StopTimeCfg.Value[5] * 0.001
        -- 高亮一下后，播放声音的等待时间
        self.RingMoveCenterWaitTime = StopTimeCfg.Value[6] * 0.001
    end

    local RingCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_ROULETTE_RING)
    if (RingCfg == nil) then
        FLOG_ERROR("无法获取 GAME_CFG_ROULETTE_RING 全局配置数据，将使用默认数据，请检查 ")
        self.RingMinimumRotationCount = 85
    else
        self.RingMinimumRotationCount = RingCfg.Value[1]
    end

    self.SpinResultSE = {} -- 抽奖结果音效

    -- 下级召唤
    self.SpinResultSE[RouletteType.RouletteType_Good] =
        "AkAudioEvent'/Game/WwiseAudio/Events/bgcommon/sound/wil/wil_spot_o3c2_select/Play_wil_spot_o3c2_select.Play_wil_spot_o3c2_select'"

    -- 中级召唤
    self.SpinResultSE[RouletteType.RouletteType_Great] =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_153/Play_SE_Event_153.Play_SE_Event_153'"

    -- 上级召唤
    self.SpinResultSE[RouletteType.RouletteType_Excellent] =
        "AkAudioEvent'/Game/WwiseAudio/Events/bgcommon/sound/wil/wil_spot_o3c2_select/Play_wil_spot_o3c2_select.Play_wil_spot_o3c2_select'"

    -- 特殊召唤
    self.SpinResultSE[RouletteType.RouletteType_Rare] =
        "AkAudioEvent'/Game/WwiseAudio/Events/bgcommon/sound/wil/wil_spot_o3c2_select/Play_wil_spot_o3c2_select.Play_wil_spot_o3c2_select'"

    -- 退出副本
    self.SpinResultSE[RouletteType.RouletteType_Lose] =
        "AkAudioEvent'/Game/WwiseAudio/Events/bgcommon/sound/wil/wil_spot_o3c2_select/Play_wil_spot_o3c2_select.Play_wil_spot_o3c2_select'"

    -- 召唤式变动
    self.SpinResultSE[RouletteType.RouletteType_Bonus] =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_155/Play_SE_Event_155.Play_SE_Event_155'"
    self.SpinResultSE[RouletteType.RouletteType_BonusContinue] = self.SpinResultSE[RouletteType.RouletteType_Bonus]

    self.SpinCursorSE =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_147/Play_SE_Event_147.Play_SE_Event_147'"
end

function TreasuryMgr:OnEnd()
    --和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function TreasuryMgr:OnShutdown()
    --和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function TreasuryMgr:OnRegisterNetMsg()
    -- 宝物库服务器下发消息和广播
    self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, SUB_MSG_ID.EnterTreasury, self.OnNetMsgEnterTreasuryRsp)
    self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, SUB_MSG_ID.GuessCardNotify, self.OnNetMsgNotifyGuessCard)
    self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, SUB_MSG_ID.TreasurySpin, self.OnNetMsgTreasurySpinRsp)
end

function TreasuryMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldReady, self.OnGameEventPWorldReady)
end

function TreasuryMgr:OnGameEventPWorldReady()
    local CurPWOrldCfg = PWorldMgr:GetCurrPWorldTableCfg()
    if CurPWOrldCfg then
        if CurPWOrldCfg.FunctionUIType == ProtoRes.PWorldFunctionUIType.FUNCTION_TYPE_NORMAL_TREASURE_HUNT then
            self:GetGuessCardInfo()
        end
    end
end

-- 请求进入宝库
function TreasuryMgr:EnterTreasuryReq()
    local SubMsgID = SUB_MSG_ID.EnterTreasury

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.EnterTreasury = {}

    GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

-- 请求普通宝库猜牌开始
function TreasuryMgr:GuessCardReq(OperateReq)
    local SubMsgID = SUB_MSG_ID.GuessCardStart

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.GuessCardGameReq = {}
    MsgBody.GuessCardGameReq.Operate = OperateReq

    GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

--- 断戕重连请求数据刷新UI
--- 回包是空的，请求完会有Notify
function TreasuryMgr:GetGuessCardInfo()
    local SubMsgID = SUB_MSG_ID.GetGuessCardInfo

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.GuessCardInfo = {}

    GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

--进入宝库回包
function TreasuryMgr:OnNetMsgEnterTreasuryRsp(MsgBody)
    if MsgBody == nil then return end
end

-- 打开宝物库强欲陷阱界面
function TreasuryMgr:OpenTreasureHuntHouseWin()
    local GuessCard = {}
    GuessCard.Guesstimes = 3
    GuessCard.StartTime = TimeUtil.GetServerLogicTime()
    GuessCard.Awards = {84200021}
    _G.TreasureHuntHouseWinVM:UpdateData(GuessCard)
    UIViewMgr:ShowView(UIViewID.TreasureHuntHouseWinPanel)
end

-- 打开
function TreasuryMgr:OnInteractiveClick(FuncID, FuncParams)
    -- FuncParams.FuncValue = 500500
    if FuncID ~= 1082 and FuncID ~= 1083 then
        return
    end

    -- 判断是不是玩家的地图
    local EntityID = MajorUtil.GetMajorEntityID()
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    local UserData = ActorUtil.GetUserData(FuncParams.EntityID, UserDataID.TreasureHunt)
    if UserData == nil then
        return
    end

    if UserData.RoleID ~= MajorRoleID then
        local strContent = LSTR(640062)
        MsgTipsUtil.ShowTips(strContent)
        return
    end

    self:EnterTreasuryReq()
end

function TreasuryMgr:OnNetMsgNotifyGuessCard(MsgBody)
    if MsgBody == nil then
        return
    end
    FLOG_INFO("TreasuryMgr.OnNetMsgNotifyGuessCard: " .. _G.table_to_string_block(MsgBody))

    local NotifyGuessCard = MsgBody.GuessCardNotify
    if NotifyGuessCard == nil then
        return
    end

    if NotifyGuessCard.State == 2 then
        UIViewMgr:HideView(UIViewID.TreasureHuntHouseWinPanel)
    elseif NotifyGuessCard.State == 1 then
        _G.TreasureHuntHouseWinVM:UpdateData(NotifyGuessCard)
        UIViewMgr:ShowView(UIViewID.TreasureHuntHouseWinPanel)
    end
end

function TreasuryMgr:TryCreateRingObj()
    if (self.CircleLightEobjActor ~= nil and self.CircleLightEobjActor:IsValid()) then
        return self.CircleLightEobjActor
    end

    local TempActor = ActorUtil.GetActorByResID(CircleRingResID)
    if (TempActor ~= nil) then
        self.CircleLightEobjActor = TempActor
    else
        local EobjData = {
            ID = CircleRingResID,
            ResID = CircleRingResID,
            IsHide = false,
            Dir = _G.UE.FVector(),
            Scale = _G.UE.FVector(1, 1, 1),
            Point = CenterPos,
            Type = _G.UE.EActorType.EObj
        }
        local EntityID = _G.ClientVisionMgr:DoClientActorEnterVision(
            CircleRingResID,
            EobjData,
            _G.MapEditorActorConfig.EObj,
            CircleRingResID
        )
        self.CircleLightEobjActor = ActorUtil.GetActorByEntityID(EntityID)
    end

    return self.CircleLightEobjActor
end

function TreasuryMgr:Test(InValue, StartIndex, ResultIndex, RingAnim, PerformResult)
    if (InValue == 1) then
        -- 开启测试
        self:TestCamera(1)
        local TestMsgData = {}
        TestMsgData.StartNumberIndex = tonumber(StartIndex)
        TestMsgData.ResultNumberIndex = tonumber(ResultIndex)
        TestMsgData.RingAnim = tonumber(RingAnim)
        TestMsgData.PerformResult = tonumber(PerformResult)
        self:StartRouletteSpin(TestMsgData)
    else
        -- 关闭测试
        self:TestCamera(2)
        _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
    end
end

function TreasuryMgr:TestCamera(InType, InChangeDuration)
    if (InType == 1) then
        self.DialogCamera = CommonUtil.SpawnActor(
            _G.UE.ATargetCamera,
            _G.UE.FVector(10000, -10000, 6500),
            _G.UE.FRotator(-90, -180, 0)
        )

        self.DialogCamera:SwitchCollision(false)
        _G.UE.UCameraMgr.Get():SwitchCamera(self.DialogCamera, InChangeDuration or 0) -- 每次都切一下避免调用者忘了切
    else
        _G.UE.UCameraMgr.Get():ResumeCamera(InChangeDuration or 0, true, nil)
    end
end

function TreasuryMgr:SetRingRotation(InRotateZValue)
    if (self.CircleLightEobjActor == nil) then
        return
    end
    self.RingRotateValue = InRotateZValue
    local Rotation = _G.UE.FRotator(0, InRotateZValue, 0)
    local FinalPos = Rotation:RotateVector(DirVector)
    FinalPos = FinalPos + CenterPos
    self.CircleLightEobjActor:K2_SetActorLocation(FinalPos, false, nil, false)
end

function TreasuryMgr:SetRingRotationByQuat(InQuatParamValue)
    local TargetRotator = self:CalcRotationByQuat(InQuatParamValue)
    self:SetRingRotation(TargetRotator.Yaw)
end

function TreasuryMgr:CalcRotationByQuat(InQuatParamValue)
    local axis = _G.UE.FVector(0, 0, 1)
    local Quat = _G.UE.FQuat()
    local sinR = math.sin(InQuatParamValue * 0.5)
    local cosR = math.cos(InQuatParamValue * 0.5)

    Quat.X = sinR * axis.X
    Quat.Y = sinR * axis.Y
    Quat.Z = sinR * axis.Z
    Quat.W = cosR

    local TargetRotator = Quat:ToRotator()
    return TargetRotator
end

function TreasuryMgr:OnNetMsgTreasurySpinRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    FLOG_ERROR("测试 TreasuryMgr.OnNetMsgTreasurySpinRsp: " .. _G.table_to_string_block(MsgBody))

    self:TestCamera(1, 2.5)
    self:RegisterTimer(
        function()
            self:StartRouletteSpin(MsgBody.TreasurySpin)
        end,
        3.5,
        0,
        1
    )
end

function TreasuryMgr:StartRouletteSpin(InMsgData)
    self:TryCreateRingObj()

    if (self.CircleLightEobjActor == nil) then
        FLOG_ERROR("无法获取转盘光圈对象，请检查")
        return
    end

    local startNumberIndex = InMsgData.StartNumberIndex % 12

    -- 这里注意一下，服务器下发的是最终停止的位置，需要减去动画样式ID，即表演了的步长
    local stopNumberIndex = (12 + InMsgData.ResultNumberIndex - InMsgData.RingAnim) % 12
    local totalRotCount = (((stopNumberIndex + 12) - ((startNumberIndex + self.RingMinimumRotationCount) % 12)) % 12) + self.RingMinimumRotationCount

    local startParam = startNumberIndex * ROULETTE_ROTATION_UNIT_RAD
    local endParam = (startNumberIndex + totalRotCount) * ROULETTE_ROTATION_UNIT_RAD
    self.QuatParam = 0
    m_rouletteSpin = {}
    m_rouletteSpin.stopNumberIndex = stopNumberIndex
    m_rouletteSpin.ResultNumberIndex = InMsgData.ResultNumberIndex
    m_rouletteSpin.pRingObject = self.CircleLightEobjActor
    m_rouletteSpin.startParam = startParam
    m_rouletteSpin.endParam = endParam
    m_rouletteSpin.ringLivenUpType = InMsgData.RingAnim
    --m_rouletteSpin.ringSpinType = RING_SPIN_TYPE_STEP
    m_rouletteSpin.resultNumberLayoutId = InMsgData.ResultNumberIndex + 1
    m_rouletteSpin.startWaitTime = self.StartWaitTime
    m_rouletteSpin.accelerationTime = self.AccelerationTime
    m_rouletteSpin.topSpeedTime = self.TopSpeedTime
    m_rouletteSpin.decelerationTime = self.DecelerationTime
    m_rouletteSpin.ringLivenUpWaitTime = self.RingLivenUpWaitTime
    m_rouletteSpin.ringLivenUpHighlightTime = self.RingLivenUpPlayTime[InMsgData.RingAnim + 1]
    m_rouletteSpin.ringLivenUpHighlightSeId = self.SpinResultSE[InMsgData.PerformResult + 1] -- 因为是0开始的，所以要+1
    m_rouletteSpin.ringLivenUpHighlightSeWaitTime = self.RingLivenUpHighlightSeWaitTime
    m_rouletteSpin.ringMoveCenterWaitTime = self.RingMoveCenterWaitTime
    m_rouletteSpin.totalTime = self.AccelerationTime + self.TopSpeedTime + self.DecelerationTime
    m_rouletteSpin.elapsedTime = -self.StartWaitTime
    m_rouletteSpin.ringLivenUpElapsedWaitTime = 0
    m_rouletteSpin.ringLivenUpElapsedTime = 0
    m_rouletteSpin.isActive = true
    m_rouletteSpin.isRingLienUpStarted = false
    m_rouletteSpin.isRingMoveCenterStarted = false
    m_rouletteSpin.isResultNumberHighlighted = false
    m_rouletteSpin.isResultNumberHighlightSePlayed = false
    m_rouletteSpin.TopSpeedTotalTime = self.AccelerationTime + self.TopSpeedTime

    -- 移動量
    local distance = m_rouletteSpin.endParam - m_rouletteSpin.startParam

    -- 最高速度
    m_rouletteSpin.topSpeed = (2.0 * distance) / (m_rouletteSpin.totalTime + m_rouletteSpin.topSpeedTime)

    -- 加速度
    if (m_rouletteSpin.accelerationTime > 0) then
        m_rouletteSpin.accelerationSpeed = m_rouletteSpin.topSpeed / m_rouletteSpin.accelerationTime
    else
        m_rouletteSpin.accelerationSpeed = 0
    end

    -- 減速度
    if (m_rouletteSpin.decelerationTime > 0) then
        m_rouletteSpin.decelerationSpeed = -m_rouletteSpin.topSpeed / m_rouletteSpin.decelerationTime
    else
        m_rouletteSpin.decelerationSpeed = 0
    end

    -- 初始化设置
    if (m_rouletteSpin.pRingObject) then
        self:SetRingRotationByQuat(startParam)
        m_rouletteSpin.pRingObject:PlaySharedGroupTimelineByIndex(1, 0)
        self.BGMNullUniqueID = UAudioMgr:PlayBGM(BGMNull, _G.UE.EBGMChannel.AreaZone)
        AudioUtil.LoadAndPlayUISound(SE_ID_THD_ROULETTE_DRUM)
    end

    -- 开启循环
    _G.UE.FTickHelper.GetInst():SetTickEnable(self.TickTimerID)
end

function TreasuryMgr.OnTick(DeltaTime)
    _G.TreasuryMgr:UpdateRouletteSpin(DeltaTime)
end

function TreasuryMgr:UpdateRouletteSpin(DeltaTime)
    if (m_rouletteSpin.isActive == false or m_rouletteSpin.pRingObject == nil) then
        return
    end

    local elapsedTime = DeltaTime
    m_rouletteSpin.elapsedTime = m_rouletteSpin.elapsedTime + elapsedTime
    local currentParam = 0
    if (m_rouletteSpin.elapsedTime <= 0) then
        -- 开始转动前
        currentParam = m_rouletteSpin.startParam
    elseif (m_rouletteSpin.elapsedTime >= m_rouletteSpin.totalTime) then
        -- 转动停下来了
        currentParam = m_rouletteSpin.endParam
        if (m_rouletteSpin.isRingMoveCenterStarted) then
            -- 圆圈开始移动到中心开始了，这里就去检测一下，当没有继续播放的时候
            local Index = RING_TIMELINES[m_rouletteSpin.ringLivenUpType].moveCenterTimelineNo
            local bIsPlayMoveCenterTimeline = m_rouletteSpin.pRingObject:IsPlaySharedGroupTimelineByIndex(Index)
            if (bIsPlayMoveCenterTimeline) then
                return
            end

            -- 完了
            m_rouletteSpin.isActive = false
            FLOG_ERROR("转盘动画全部播放完成")
            if (self.BGMNullUniqueID ~= nil) then
                UAudioMgr:StopBGM(self.BGMNullUniqueID)
                self.BGMNullUniqueID = nil
            end
            _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
            return
        elseif (m_rouletteSpin.isRingLienUpStarted) then
            -- 已经开始欺骗表演了，这里是准备根据对应的时间去播放音效
            m_rouletteSpin.ringLivenUpElapsedTime = m_rouletteSpin.ringLivenUpElapsedTime + elapsedTime
            -- 如果还没有到指定的等待时间，那么返回
            if (m_rouletteSpin.ringLivenUpElapsedTime < m_rouletteSpin.ringLivenUpHighlightTime) then
                return
            end

            -- 如果最终停下的目标没有播放高亮效果，那么播放一次
            if (m_rouletteSpin.isResultNumberHighlighted == false) then
                local SGID = SceneSGObjIDTable[m_rouletteSpin.resultNumberLayoutId]
                local DynData = PWorldDynDataMgr:GetDynData(MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE, SGID)
                if (DynData == nil) then
                    FLOG_ERROR("无法找到场景中的SG物件，ID是:%s",SGID)
                else
                    DynData:UpdateState(DynData.State + 1)
                end
                m_rouletteSpin.isResultNumberHighlighted = true
            end
            -- 播放对应的音效
            if (m_rouletteSpin.isResultNumberHighlightSePlayed == false and m_rouletteSpin.ringLivenUpElapsedTime >= m_rouletteSpin.ringLivenUpHighlightTime + m_rouletteSpin.ringLivenUpHighlightSeWaitTime) then
                AudioUtil.LoadAndPlaySoundEvent(m_rouletteSpin.ringLivenUpHighlightSeId)
                m_rouletteSpin.isResultNumberHighlightSePlayed = true
            end
            if (m_rouletteSpin.ringLivenUpElapsedTime >= m_rouletteSpin.ringLivenUpHighlightTime + m_rouletteSpin.ringMoveCenterWaitTime) then
                -- 移动到中心的特效

                local TargetRotatorY = (m_rouletteSpin.ResultNumberIndex - 1) * 30
                m_rouletteSpin.pRingObject:K2_SetActorRotation(_G.UE.FRotator(0, TargetRotatorY, 0), false)
                local TimelineIndex = RING_TIMELINES[m_rouletteSpin.ringLivenUpType].moveCenterTimelineNo
                FLOG_ERROR("播放移动到中心的动画, Index : %s，并还原镜头",TimelineIndex)
                m_rouletteSpin.pRingObject:PlaySharedGroupTimelineByIndex(TimelineIndex, 0)
                m_rouletteSpin.pRingObject:K2_SetActorLocation(CenterPos, false, nil, false)
                m_rouletteSpin.isRingMoveCenterStarted = true
                self:TestCamera(2,2)
            end
            return
        else
            -- 开始欺骗表演等待
            m_rouletteSpin.ringLivenUpElapsedWaitTime = m_rouletteSpin.ringLivenUpElapsedWaitTime + elapsedTime;
            if (m_rouletteSpin.ringLivenUpElapsedWaitTime >= m_rouletteSpin.ringLivenUpWaitTime) then
                _G.FLOG_ERROR("播放欺骗表演")
                -- 播放欺骗表演的动画
                m_rouletteSpin.pRingObject:PlaySharedGroupTimelineByIndex(RING_TIMELINES[m_rouletteSpin.ringLivenUpType].livenUpTimelineNo, 0);
                m_rouletteSpin.isRingLienUpStarted = true
                if (m_rouletteSpin.ringLivenUpType == 0) then
                elseif (m_rouletteSpin.ringLivenUpType == 1) then
                    self:RegisterTimer(
                        function()
                            self:SetRingRotation((m_rouletteSpin.stopNumberIndex+1) * 30)
                        end,
                        m_rouletteSpin.ringLivenUpHighlightTime * 0.5,
                        0,
                        1
                    )
                elseif (m_rouletteSpin.ringLivenUpType == 2) then
                    self:RegisterTimer(
                        function()
                            self:SetRingRotation((m_rouletteSpin.stopNumberIndex+1) * 30)
                        end,
                        m_rouletteSpin.ringLivenUpHighlightTime * 0.33,
                        0,
                        1
                    )
                    self:RegisterTimer(
                        function()
                            self:SetRingRotation((m_rouletteSpin.stopNumberIndex+2) * 30)
                        end,
                        m_rouletteSpin.ringLivenUpHighlightTime * 0.66,
                        0,
                        1
                    )
                end
            end
        end
    elseif (m_rouletteSpin.elapsedTime <= m_rouletteSpin.accelerationTime) then
        -- 处于加速时间内
        local accelerationElapsedTime = m_rouletteSpin.elapsedTime
        currentParam = m_rouletteSpin.startParam + (m_rouletteSpin.accelerationSpeed * accelerationElapsedTime * accelerationElapsedTime) / 2.0
        currentParam = math.floor(currentParam / ROULETTE_ROTATION_UNIT_RAD) * ROULETTE_ROTATION_UNIT_RAD
    elseif (m_rouletteSpin.elapsedTime <= m_rouletteSpin.TopSpeedTotalTime) then
        -- 处于最高时速时间内
        local acceleratedParam = (m_rouletteSpin.accelerationSpeed * m_rouletteSpin.accelerationTime * m_rouletteSpin.accelerationTime) / 2.0
        local topSpeedElapsedTime = m_rouletteSpin.elapsedTime - m_rouletteSpin.accelerationTime
        currentParam = m_rouletteSpin.startParam + acceleratedParam + (m_rouletteSpin.topSpeed * topSpeedElapsedTime)
        currentParam = math.floor((currentParam / ROULETTE_ROTATION_UNIT_RAD)) * ROULETTE_ROTATION_UNIT_RAD
    elseif (m_rouletteSpin.elapsedTime <= m_rouletteSpin.totalTime) then
        -- 处于减速时间内
        local acceleratedParam = (m_rouletteSpin.accelerationSpeed * m_rouletteSpin.accelerationTime * m_rouletteSpin.accelerationTime) / 2.0
        local topSpeedParam = m_rouletteSpin.topSpeed * m_rouletteSpin.topSpeedTime
        local decelerationElapsedTime = m_rouletteSpin.elapsedTime - m_rouletteSpin.accelerationTime - m_rouletteSpin.topSpeedTime
        currentParam = m_rouletteSpin.startParam + acceleratedParam + topSpeedParam + (m_rouletteSpin.topSpeed * decelerationElapsedTime) + ((m_rouletteSpin.decelerationSpeed * decelerationElapsedTime * decelerationElapsedTime) / 2.0)
        currentParam = math.floor(currentParam / ROULETTE_ROTATION_UNIT_RAD) * ROULETTE_ROTATION_UNIT_RAD
    else
        FLOG_ERROR("错误的阶段，请检查")
        return
    end
    local TempRotator = self:CalcRotationByQuat(currentParam)
    if (self.RingRotateValue ~= TempRotator.Yaw) then
        AudioUtil.LoadAndPlayUISound(self.SpinCursorSE)
        self:SetRingRotationByQuat(currentParam)
    end
end

return TreasuryMgr
