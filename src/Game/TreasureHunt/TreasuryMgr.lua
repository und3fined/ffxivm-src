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
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local PWorldTriggerActionExecMgr = require("Game/PWorld/PWorldTriggerActionExecMgr")
local BitUtil = require("Utils/BitUtil")
local UserDataID = require("Define/UserDataID")
local HUDType = require("Define/HUDType")
local BehitRadialBlurCfg = require("TableCfg/BehitRadialBlurCfg")
local UIViewID = require("Define/UIViewID")
local TimeUtil = require("Utils/TimeUtil")
local CS_CMD = ProtoCS.CS_CMD

local GIMMICK_PATHMOVEFLAG = {
    GIMMICK_PATHMOVEFLAG_NONE = 0,
    GIMMICK_PATHMOVEFLAG_START_ON_PATH = 1,
    GIMMICK_PATHMOVEFLAG_RUN_GROUND = 2,
    GIMMICK_PATHMOVEFLAG_SERVER_CONDITION = 4,
    GIMMICK_PATHMOVEFLAG_FALL = 8,
    GIMMICK_PATHMOVEFLAG_INVINCIBLE = 16,
    GIMMICK_PATHMOVEFLAG_END_LOOP = 32
}

local MapEditorActorConfig = _G.MapEditorActorConfig
local CenterPos = nil
local GameNetworkMgr = nil
local UIViewMgr = nil
local MsgTipsUtil = nil
local MsgBoxUtil = nil
local EventMgr = nil
local RollMgr = nil
local EventID = nil
local LSTR = nil
local FLOG_INFO = nil
local FLOG_ERROR = _G.FLOG_ERROR
local TreasureHuntMainVM = nil
local TreasureHuntSkillPanelVM = nil
local UAudioMgr = nil
local VariableIDForAtomos = 999 -- 关卡编辑器约定的，阿托莫斯变量ID
local VariableIDForBlackMask = 998 -- 关卡编辑器约定，出现黑幕的ID
local TreasureTempleMapID = 2015
local BlurEffectKey = 12

local m_rouletteSpin = {}
local RING_TIMELINES = {}
local SceneSGObjIDTable = nil
local RouletteType = ProtoRes.Game.RouletteType
local CS_CMD_TREASURE_HUNT = ProtoCS.CS_CMD.CS_CMD_TREASURE_HUNT
local SUB_MSG_ID = ProtoCS.Game.TreasureHunt.CmdTreasureHunt
local MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local CircleRingResID = 2009602
local BGMNull = 1 -- 空的BGM，为的是停掉当前的bgm
local CameraEventIDTable = {}
local DelayShowCircle = 4 -- 收到协议后，延迟，显示光圈
local AtomosThunderEventID = 2400021 -- 阿托莫斯雷劈，及下沉
local AtomosSummonEventID = 2400028 -- 阿托莫斯出现事件
local SummonAtomosTimeDelay = 6
local AtomosPlayInhaleTimeDelay = 3
local AtomosPlayCPathTimeDelay = AtomosPlayInhaleTimeDelay + 1.5
local AtomosThunderEventTimeDelay = AtomosPlayCPathTimeDelay + 6.5
local AtomosMonsterDeadTimeDelay = AtomosThunderEventTimeDelay + 5

local ROULETTE_ROTATION_UNIT_RAD = 3.1415926 * 2 / 12.0
local MandelaTeamIconTable = {}
--local ROULETTE_ROTATION_UNIT_RAD = 30

-- 开始转动的时候，背景音乐
local SE_ID_THD_ROULETTE_DRUM =
    "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_146/Play_SE_Event_146.Play_SE_Event_146'"

local TreasuryMgr = LuaClass(MgrBase)
---OnInit
function TreasuryMgr:OnInit()
    MandelaTeamIconTable[1] = "Texture2D'/Game/Assets/Icon/060000/UI_Icon_060687.UI_Icon_060687"
    MandelaTeamIconTable[2] = "Texture2D'/Game/Assets/Icon/060000/UI_Icon_060688.UI_Icon_060688"
    MandelaTeamIconTable[3] = "Texture2D'/Game/Assets/Icon/060000/UI_Icon_060689.UI_Icon_060689"
    MandelaTeamIconTable[4] = "Texture2D'/Game/Assets/Icon/060000/UI_Icon_060690.UI_Icon_060690"
    MandelaTeamIconTable[5] = "Texture2D'/Game/Assets/Icon/060000/UI_Icon_060691.UI_Icon_060691"

    --只初始化自身模块的数据，不能引用其他的同级模块
    CameraEventIDTable[1] = {} -- 原地停止
    CameraEventIDTable[1][ProtoRes.Game.RouletteType.RouletteType_Good] = 2400027 -- 下级
    CameraEventIDTable[1][ProtoRes.Game.RouletteType.RouletteType_Great] = 2400027 -- 中级
    CameraEventIDTable[1][ProtoRes.Game.RouletteType.RouletteType_Excellent] = 2400029 -- 上级
    CameraEventIDTable[1][ProtoRes.Game.RouletteType.RouletteType_Bonus] = 2400029 -- 召唤式变动
    CameraEventIDTable[1][ProtoRes.Game.RouletteType.RouletteType_BonusContinue] = 2400029 -- 召唤式变动继续
    CameraEventIDTable[1][ProtoRes.Game.RouletteType.RouletteType_Rare] = 2400029 -- 特殊召唤
    CameraEventIDTable[1][ProtoRes.Game.RouletteType.RouletteType_Lose] = 2400030 -- 真阿托莫斯，退出副本

    CameraEventIDTable[2] = {} -- 前进一格
    CameraEventIDTable[2][ProtoRes.Game.RouletteType.RouletteType_Good] = 2400031 -- 下级
    CameraEventIDTable[2][ProtoRes.Game.RouletteType.RouletteType_Great] = 2400031 -- 中级
    CameraEventIDTable[2][ProtoRes.Game.RouletteType.RouletteType_Excellent] = 2400032 -- 上级
    CameraEventIDTable[2][ProtoRes.Game.RouletteType.RouletteType_Bonus] = 2400032 -- 召唤式变动
    CameraEventIDTable[2][ProtoRes.Game.RouletteType.RouletteType_BonusContinue] = 2400032 -- 召唤式变动继续
    CameraEventIDTable[2][ProtoRes.Game.RouletteType.RouletteType_Rare] = 2400032 -- 特殊召唤
    CameraEventIDTable[2][ProtoRes.Game.RouletteType.RouletteType_Lose] = 2400033 -- 真阿托莫斯，退出副本

    CameraEventIDTable[3] = {} -- 前进两格
    CameraEventIDTable[3][ProtoRes.Game.RouletteType.RouletteType_Good] = 2400034 -- 下级
    CameraEventIDTable[3][ProtoRes.Game.RouletteType.RouletteType_Great] = 2400034 -- 中级
    CameraEventIDTable[3][ProtoRes.Game.RouletteType.RouletteType_Excellent] = 2400035 -- 上级
    CameraEventIDTable[3][ProtoRes.Game.RouletteType.RouletteType_Bonus] = 2400035 -- 召唤式变动
    CameraEventIDTable[3][ProtoRes.Game.RouletteType.RouletteType_BonusContinue] = 2400035 -- 召唤式变动继续
    CameraEventIDTable[3][ProtoRes.Game.RouletteType.RouletteType_Rare] = 2400035 -- 特殊召唤
    CameraEventIDTable[3][ProtoRes.Game.RouletteType.RouletteType_Lose] = 2400036 -- 真阿托莫斯，退出副本

    self.CPathIDTable = {}
    self.CPathIDTable[1] = {} -- 阿托莫斯复活的
    self.CPathIDTable[1][1] = {CPathID = 7689185}
    self.CPathIDTable[1][2] = {CPathID = 7689186}
    self.CPathIDTable[1][3] = {CPathID = 7689187}
    self.CPathIDTable[1][4] = {CPathID = 7689188}
    self.CPathIDTable[1][5] = {CPathID = 7689189}
    self.CPathIDTable[1][6] = {CPathID = 7689190}
    self.CPathIDTable[1][7] = {CPathID = 7689191}
    self.CPathIDTable[1][8] = {CPathID = 7689192}
    self.CPathIDTable[1][9] = {CPathID = 7689193}
    self.CPathIDTable[1][10] = {CPathID = 7689194}
    self.CPathIDTable[1][11] = {CPathID = 7689195}
    self.CPathIDTable[1][12] = {CPathID = 7689196}

    self.CPathIDTable[2] = {} -- 阿托莫斯结束
    self.CPathIDTable[2][1] = {CPathID = 7703912}
    self.CPathIDTable[2][2] = {CPathID = 7703913}
    self.CPathIDTable[2][3] = {CPathID = 7703914}
    self.CPathIDTable[2][4] = {CPathID = 7703915}
    self.CPathIDTable[2][5] = {CPathID = 7703916}
    self.CPathIDTable[2][6] = {CPathID = 7703917}
    self.CPathIDTable[2][7] = {CPathID = 7703919}
    self.CPathIDTable[2][8] = {CPathID = 7703920}
    self.CPathIDTable[2][9] = {CPathID = 7703922}
    self.CPathIDTable[2][10] = {CPathID = 7703923}
    self.CPathIDTable[2][11] = {CPathID = 7712475}
    self.CPathIDTable[2][12] = {CPathID = 7712476}
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
    RollMgr = _G.RollMgr
    EventID = _G.EventID
    UAudioMgr = _G.UE.UAudioMgr.Get()

    FLOG_INFO = _G.FLOG_INFO
    LSTR = _G.LSTR

    TreasureHuntMainVM = _G.TreasureHuntMainVM
    TreasureHuntSkillPanelVM = _G.TreasureHuntSkillPanelVM

    _G.UE.FTickHelper.GetInst():SetTickIntervalByFrame(self.TickTimerID, 1)
    _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
    self:ShutdownTimeTick()

    CenterPos = _G.UE.FVector(10000.0, -10000, 10)

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
    RING_TIMELINES[1] = {}
    RING_TIMELINES[1].livenUpTimelineNo = 5
    RING_TIMELINES[1].moveCenterTimelineNo = 10 -- 对应端游的11

    -- 欺骗表演，移动一格
    RING_TIMELINES[2] = {}
    RING_TIMELINES[2].livenUpTimelineNo = 7
    RING_TIMELINES[2].moveCenterTimelineNo = 11 -- 对应端游的13

    -- 欺骗表演，移动两格
    RING_TIMELINES[3] = {}
    RING_TIMELINES[3].livenUpTimelineNo = 9
    RING_TIMELINES[3].moveCenterTimelineNo = 12 -- 对应端游的15

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
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_152/Play_SE_Event_152.Play_SE_Event_152'"

    -- 中级召唤
    self.SpinResultSE[RouletteType.RouletteType_Great] =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_153/Play_SE_Event_153.Play_SE_Event_153'"

    -- 上级召唤
    self.SpinResultSE[RouletteType.RouletteType_Excellent] =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_154/Play_SE_Event_154.Play_SE_Event_154'"

    -- 特殊召唤
    self.SpinResultSE[RouletteType.RouletteType_Rare] =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_156/Play_SE_Event_156.Play_SE_Event_156'"

    -- 退出副本
    self.SpinResultSE[RouletteType.RouletteType_Lose] =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_157/Play_SE_Event_157.Play_SE_Event_157'"

    -- 召唤式变动
    self.SpinResultSE[RouletteType.RouletteType_Bonus] =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_155/Play_SE_Event_155.Play_SE_Event_155'"
    self.SpinResultSE[RouletteType.RouletteType_BonusContinue] = self.SpinResultSE[RouletteType.RouletteType_Bonus]

    self.SpinCursorSE =
        "AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_147/Play_SE_Event_147.Play_SE_Event_147'"
end

function TreasuryMgr:OnEnd()
    _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
    self:ShutdownTimeTick()
    --和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
    if (self.bHideHud) then
        -- 这里是延迟恢复所有的HUD显示
        self:InternalSetHUDVisible(true)
        self.bHideHud = false
    end
end

function TreasuryMgr:OnShutdown()
    --和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
    _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
    self:ShutdownTimeTick()
end

function TreasuryMgr:ShutdownTimeTick()
    if (self.TimeTickID ~= nil) then
        self:UnRegisterTimer(self.TimeTickID)
        self.TimeTickID = nil
    end
end

function TreasuryMgr:OnRegisterNetMsg()
    -- 宝物库服务器下发消息和广播
    self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, SUB_MSG_ID.EnterTreasury, self.OnNetMsgEnterTreasuryRsp)
    self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, SUB_MSG_ID.GuessCardNotify, self.OnNetMsgNotifyGuessCard)
    self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, SUB_MSG_ID.TreasurySpin, self.OnNetMsgTreasurySpinRsp)
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_VISION,
        ProtoCS.CS_VISION_CMD.CS_VISION_CMD_USER_DATA_CHG,
        self.OnVisionUserDataChg
    )
end

function TreasuryMgr:OnVisionUserDataChg(MsgBody)
    if (MsgBody == nil or MsgBody.UserDataChg == nil) then
        FLOG_ERROR("协议转换出错，请检查")
        return
    end
    local NPCEntityID = MsgBody.UserDataChg.EntityID
    local ActorVM = _G.HUDMgr:GetActorVM(NPCEntityID)
    if (ActorVM ~= nil and ActorVM.HUDType == HUDType.MonsterInfo) then
        ActorVM:UpdateMonStateIcon()
    end
end

function TreasuryMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.PWorldReady, self.OnGameEventPWorldReady)
    self:RegisterGameEvent(EventID.PWorldVariableDataChange, self.OnPWorldVariableDataChange)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
    self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function TreasuryMgr:OnGameEventAppEnterBackground()
    -- 进入后台了
    _G.FLOG_ERROR("测试 ： 进入后台了")
end

function TreasuryMgr:OnGameEventAppEnterForeground()
    -- 恢复
    _G.FLOG_ERROR("测试 ： 恢复后台了")
end

function TreasuryMgr:OnPWorldExit(Params)
    -- 这里在退出的时候，保险起见，关闭一下这个界面
    self:RegisterTimer(
        function()
            _G.UIViewMgr:HideView(_G.UIViewID.CommonFadePanelLowLayer)
        end,
        1.5,
        1
    )
end

-- 是否在转盘动画中，这里包含了阿托莫斯动画
function TreasuryMgr:IsInRouletteAnim()
    return self.bPlayRouletteSpin or self.bPlayAtomos
end

function TreasuryMgr:OnPWorldVariableDataChange(Params)
    if (not self:IsCurMapTreasureTemple()) then
        return
    end
    local VariableList = Params
    if (VariableList == nil or #VariableList < 1) then
        return
    end

    if (VariableList[1].ID == VariableIDForAtomos) then
        self.bPlayAtomos = true
        -- 阿托莫斯
        local TeamMemberList = _G.TeamMgr:GetMemberList()
        if (TeamMemberList ~= nil and #TeamMemberList > 0) then
            for Key, Value in pairs(TeamMemberList) do
                if (Value ~= nil) then
                    local EID = ActorUtil.GetEntityIDByRoleID(Value.RoleID)
                    if (EID ~= nil) then
                        self:StartPlayCPath(EID, not self.bNeedKillAtomos)
                    else
                        _G.FLOG_ERROR("StartPlayCPath 错误 无法通过 RoleID : %s ， 获取 EntityID,请检查", Value.RoleID)
                    end
                end
            end
        else
            local MajorEnittyID = MajorUtil.GetMajorEntityID()
            self:StartPlayCPath(MajorEnittyID, not self.bNeedKillAtomos)
        end
        local BlurCfg = BehitRadialBlurCfg:FindCfgByKey(BlurEffectKey)
        local RelativeLocation = _G.UE.FVector(BlurCfg.PointOffsetX, BlurCfg.PointOffsetY, BlurCfg.PointOffsetZ)
        local Major = MajorUtil.GetMajor()
        local Duration = 9
        _G.UE.UCameraPostEffectMgr.Get():StartRadialBlur(
            BlurCfg.SocketName,
            BlurCfg.BlurDst,
            BlurCfg.BlurRadius,
            BlurCfg.BlurStrength,
            Duration,
            Major,
            RelativeLocation,
            math.floor(BlurCfg.RadialBlurWeight),
            BlurCfg.RadialBlurType,
            BlurCfg.BlurDstPower,
            BlurCfg.BlurRadiusPower,
            true
        )
    elseif (VariableList[1].ID == VariableIDForBlackMask) then
        local FadeParams = {}
        FadeParams.FadeColorType = 3
        FadeParams.Duration = 0.8
        FadeParams.DelayHide = 20 -- 延迟消失，保底处理，这里20秒后再自动消失，服务器下发退出会自动清理掉的

        _G.UIViewMgr:ShowView(_G.UIViewID.CommonFadePanelLowLayer, FadeParams)
    end
end

-- 当前地图是不是寻宝神殿
function TreasuryMgr:IsCurMapTreasureTemple()
    local Result = PWorldMgr.BaseInfo.CurrMapResID == TreasureTempleMapID

    return Result
end

function TreasuryMgr:OnGameEventEnterWorld(Params)
    self.CPathActorArray = nil
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
    if RollMgr:HasAssignedReward() then
        MsgTipsUtil.ShowTipsByID(40868) -- 未分配完不能进入
        return
    end

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
    if MsgBody == nil then
        return
    end
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

    _G.TreasureHuntHouseWinVM:UpdateData(NotifyGuessCard)

    if NotifyGuessCard.State == 2 then
        UIViewMgr:HideView(_G.UIViewID.TreasureHuntHouseWinPanel)
    elseif NotifyGuessCard.State == 1 then
        UIViewMgr:ShowView(_G.UIViewID.TreasureHuntHouseWinPanel)
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
        local EntityID =
            _G.ClientVisionMgr:DoClientActorEnterVision(
            CircleRingResID,
            EobjData,
            MapEditorActorConfig.EObj,
            CircleRingResID
        )
        self.CircleLightEobjActor = ActorUtil.GetActorByEntityID(EntityID)
    end

    return self.CircleLightEobjActor
end

function TreasuryMgr:InternalSetRingRotation(InRotateValue)
    if (self.CircleLightEobjActor == nil or not CommonUtil.IsObjectValid(self.CircleLightEobjActor)) then
        return
    end
    self.RingRotateValue = InRotateValue.Yaw
    self.CircleLightEobjActor:K2_SetActorRotation(InRotateValue, false)
    self.CircleLightEobjActor:RefreshSharedGroupTrans()
end

function TreasuryMgr:SetRingRotationByQuat(InQuatParamValue)
    local TargetRotator = self:CalcRotationByQuat(InQuatParamValue)
    self:InternalSetRingRotation(TargetRotator)
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

    self:StartRouletteSpin(MsgBody.TreasurySpin)
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
    local totalRotCount =
        (((stopNumberIndex + 12) - ((startNumberIndex + self.RingMinimumRotationCount) % 12)) % 12) +
        self.RingMinimumRotationCount

    local startParam = startNumberIndex * ROULETTE_ROTATION_UNIT_RAD
    local endParam = (startNumberIndex + totalRotCount) * ROULETTE_ROTATION_UNIT_RAD
    self.QuatParam = 0
    m_rouletteSpin = {}
    m_rouletteSpin.stopNumberIndex = stopNumberIndex
    m_rouletteSpin.ResultNumberIndex = InMsgData.ResultNumberIndex
    m_rouletteSpin.pRingObject = self.CircleLightEobjActor
    m_rouletteSpin.startParam = startParam
    m_rouletteSpin.endParam = endParam
    m_rouletteSpin.ringLivenUpType = InMsgData.RingAnim + 1
    --m_rouletteSpin.ringSpinType = RING_SPIN_TYPE_STEP
    m_rouletteSpin.resultNumberLayoutId = InMsgData.ResultNumberIndex + 1
    m_rouletteSpin.startWaitTime = self.StartWaitTime
    m_rouletteSpin.accelerationTime = self.AccelerationTime
    m_rouletteSpin.topSpeedTime = self.TopSpeedTime
    m_rouletteSpin.decelerationTime = self.DecelerationTime
    m_rouletteSpin.ringLivenUpWaitTime = self.RingLivenUpWaitTime
    m_rouletteSpin.ringLivenUpHighlightTime = self.RingLivenUpPlayTime[m_rouletteSpin.ringLivenUpType]
    m_rouletteSpin.ringLivenUpHighlightSeId = self.SpinResultSE[InMsgData.PerformResult]
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

    self:SetRingRotationByQuat(startParam)

    self:RegisterTimer(
        function()
            -- 初始化设置
            if (m_rouletteSpin.pRingObject) then
                m_rouletteSpin.pRingObject:PlaySharedGroupTimelineByIndex(1, 0)
                self.BGMNullUniqueID = UAudioMgr:PlayBGM(BGMNull, _G.UE.EBGMChannel.AreaZone)
                AudioUtil.LoadAndPlay2DSound(SE_ID_THD_ROULETTE_DRUM)
            end
        end,
        DelayShowCircle
    )

    -- 开启 Tick
    _G.UE.FTickHelper.GetInst():SetTickEnable(self.TickTimerID)
    self.StartTimeStamp = TimeUtil.GetServerLogicTimeMS()

    -- 播放镜头动画
    local StepType = m_rouletteSpin.ringLivenUpType
    -- 前进几步，需要去表格获取的，所以 + 1
    self.bNeedKillAtomos = false
    local CameraData = CameraEventIDTable[StepType]
    if (CameraData == nil) then
        _G.FLOG_ERROR("镜头错误，StepType : %s，将使用默认的类型1", StepType)
        m_rouletteSpin.ringLivenUpType = 1
    else
        local TriggerEventID = CameraData[InMsgData.PerformResult]
        self:TriggerEvent(TriggerEventID)

        local bLose = InMsgData.PerformResult == ProtoRes.Game.RouletteType.RouletteType_Lose
        if (bLose) then
            -- 这里是要召唤阿托莫斯
            self.bNeedKillAtomos = InMsgData.PerformResult ~= InMsgData.RealResult
        end
    end

    self.DelayShowCircleTime = DelayShowCircle
end

function TreasuryMgr.OnTick(DeltaTime)
    _G.TreasuryMgr:UpdateRouletteSpin(DeltaTime)
end

function TreasuryMgr:TryGetMandelaIconPath(InEntityID)
    if (not self:IsCurMapTreasureTemple()) then
        return nil
    end
    local TargetUserData = ActorUtil.GetUserData(InEntityID, UserDataID.TreasureMandela)
    if (TargetUserData == nil) then
        return nil
    end

    if (TargetUserData.AwardID ~= nil and TargetUserData.AwardID > 0 and TargetUserData.Rule == 1) then
        return MandelaTeamIconTable[TargetUserData.AwardIndex + 1]
    else
        return nil
    end
end

function TreasuryMgr:UpdateRouletteSpin()
    if (m_rouletteSpin.isActive == false or m_rouletteSpin.pRingObject == nil) then
        return
    end

    local CurTimeMS = TimeUtil.GetServerLogicTimeMS()
    local DeltaTime = (CurTimeMS - self.StartTimeStamp) * 0.001
    self.StartTimeStamp = TimeUtil.GetServerLogicTimeMS()

    if (self.DelayShowCircleTime > 0) then
        self.DelayShowCircleTime = self.DelayShowCircleTime - DeltaTime
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
            if (self.BGMNullUniqueID ~= nil) then
                UAudioMgr:StopBGM(self.BGMNullUniqueID)
                self.BGMNullUniqueID = nil
            end
            _G.UE.FTickHelper.GetInst():SetTickDisable(self.TickTimerID)
            self:ShutdownTimeTick()
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
                    FLOG_ERROR("无法找到场景中的SG物件，ID是:%s", SGID)
                else
                    local SgActor = DynData.MapDynamicAssetModel:Cast(_G.UE.ASgLayoutActorBase)
                    if (SgActor ~= nil) then
                        local LastIndex = SgActor:GetLastPlayedTimelineIndex()
                        DynData:UpdateState(LastIndex + 1)
                    else
                        _G.FLOG_ERROR("无法转化为 _G.UE.ASgLayoutActorBase , SGID : %s", SGID)
                    end
                end
                m_rouletteSpin.isResultNumberHighlighted = true
            end
            -- 播放对应的音效
            if
                (m_rouletteSpin.isResultNumberHighlightSePlayed == false and
                    m_rouletteSpin.ringLivenUpElapsedTime >=
                        m_rouletteSpin.ringLivenUpHighlightTime + m_rouletteSpin.ringLivenUpHighlightSeWaitTime)
             then
                AudioUtil.LoadAndPlay2DSound(m_rouletteSpin.ringLivenUpHighlightSeId)
                m_rouletteSpin.isResultNumberHighlightSePlayed = true
            end

            -- 移动到中心的特效
            if
                (m_rouletteSpin.isRingMoveCenterStarted == false and
                    m_rouletteSpin.ringLivenUpElapsedTime >=
                        m_rouletteSpin.ringLivenUpHighlightTime + m_rouletteSpin.ringMoveCenterWaitTime)
             then
                local TimelineIndex = RING_TIMELINES[m_rouletteSpin.ringLivenUpType].moveCenterTimelineNo
                m_rouletteSpin.pRingObject:PlaySharedGroupTimelineByIndex(TimelineIndex, 0)
                m_rouletteSpin.isRingMoveCenterStarted = true
            end
            return
        else
            -- 开始欺骗表演等待
            m_rouletteSpin.ringLivenUpElapsedWaitTime = m_rouletteSpin.ringLivenUpElapsedWaitTime + elapsedTime
            if (m_rouletteSpin.ringLivenUpElapsedWaitTime >= m_rouletteSpin.ringLivenUpWaitTime) then
                -- 播放欺骗表演的动画
                local PlayIndex = RING_TIMELINES[m_rouletteSpin.ringLivenUpType].livenUpTimelineNo
                m_rouletteSpin.pRingObject:PlaySharedGroupTimelineByIndex(PlayIndex, 0)
                m_rouletteSpin.isRingLienUpStarted = true
            end
        end
    elseif (m_rouletteSpin.elapsedTime <= m_rouletteSpin.accelerationTime) then
        -- 处于加速时间内
        local accelerationElapsedTime = m_rouletteSpin.elapsedTime
        currentParam =
            m_rouletteSpin.startParam +
            (m_rouletteSpin.accelerationSpeed * accelerationElapsedTime * accelerationElapsedTime) / 2.0
        currentParam = math.floor(currentParam / ROULETTE_ROTATION_UNIT_RAD) * ROULETTE_ROTATION_UNIT_RAD
    elseif (m_rouletteSpin.elapsedTime <= m_rouletteSpin.TopSpeedTotalTime) then
        -- 处于最高时速时间内
        local acceleratedParam =
            (m_rouletteSpin.accelerationSpeed * m_rouletteSpin.accelerationTime * m_rouletteSpin.accelerationTime) / 2.0
        local topSpeedElapsedTime = m_rouletteSpin.elapsedTime - m_rouletteSpin.accelerationTime
        currentParam = m_rouletteSpin.startParam + acceleratedParam + (m_rouletteSpin.topSpeed * topSpeedElapsedTime)
        currentParam = math.floor((currentParam / ROULETTE_ROTATION_UNIT_RAD)) * ROULETTE_ROTATION_UNIT_RAD
    elseif (m_rouletteSpin.elapsedTime <= m_rouletteSpin.totalTime) then
        -- 处于减速时间内
        local acceleratedParam =
            (m_rouletteSpin.accelerationSpeed * m_rouletteSpin.accelerationTime * m_rouletteSpin.accelerationTime) / 2.0
        local topSpeedParam = m_rouletteSpin.topSpeed * m_rouletteSpin.topSpeedTime
        local decelerationElapsedTime =
            m_rouletteSpin.elapsedTime - m_rouletteSpin.accelerationTime - m_rouletteSpin.topSpeedTime
        currentParam =
            m_rouletteSpin.startParam + acceleratedParam + topSpeedParam +
            (m_rouletteSpin.topSpeed * decelerationElapsedTime) +
            ((m_rouletteSpin.decelerationSpeed * decelerationElapsedTime * decelerationElapsedTime) / 2.0)
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

function TreasuryMgr:GetCPathActorAndPosArrayByID(InIDValue)
    if (self.CPathActorArray == nil) then
        self.CPathActorArray = UE.TArray(_G.UE.AClientPathActor)
        local World = GameplayStaticsUtil:GetWorld()
        _G.UE.UGameplayStatics.GetAllActorsOfClass(World, _G.UE.AClientPathActor.StaticClass(), self.CPathActorArray)
    end

    local TargetActor = nil
    local ActorLength = self.CPathActorArray:Length()
    for i = 1, ActorLength do
        local Actor = self.CPathActorArray:Get(i)
        local CPathActor = Actor:Cast(_G.UE.AClientPathActor)
        if (CPathActor ~= nil and CPathActor:IsSameInstanceID(InIDValue)) then
            TargetActor = CPathActor
            break
        end
    end

    if (TargetActor == nil) then
        _G.FLOG_ERROR("无法获得 CPathActor , ID : %s", InIDValue)
        return
    end
    local PosTable = TargetActor:GetPathControlPoints()
    return TargetActor, PosTable
end

function TreasuryMgr:TriggerEvent(InEventID)
    local TargetEvent = _G.MapEditDataMgr:GetEventByID(InEventID)
    if (TargetEvent == nil) then
        _G.FLOG_ERROR("TreasuryMgr:TriggerEvent 出错， ID : %s 无法获取", InEventID)
        return
    end

    for Key, TriggerAction in pairs(TargetEvent.ActionList) do
        local ActionType = TriggerAction.Type
        if (ActionType == ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_REFRESH_ENTITY) then
            -- 创建实体
            local ListID = TriggerAction.Param3
            local Monster = MapEditDataMgr:GetMonsterByListID(ListID)
            if (Monster == nil) then
                _G.FLOG_ERROR("错误，无法获取 ListID : %s", ListID)
                return
            end

            local ResID = Monster.ID
            local BirthMapPoint = Monster.BirthPoint
            local BirthLocation = BirthMapPoint and _G.UE.FVector(BirthMapPoint.X, BirthMapPoint.Y, BirthMapPoint.Z)
            local NPCRotation = _G.UE.FRotator(0, Monster.BirthDir, 0)
            self.CameraEntityID = _G.UE.UActorManager:Get():CreateClientActor(
                _G.UE.EActorType.Monster,
                Monster.ListID,
                ResID,
                BirthLocation,
                NPCRotation
            )

            if (self.CameraEntityID == nil or self.CameraEntityID <= 0) then
                _G.FLOG_ERROR("ClientVisionMgr:DoClientActorEnterVision 创建失败，ListID : %s", ListID)
            end
            self.bPlayRouletteSpin = true
        elseif (ActionType == ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_RECYCLE_ENTITY) then
            -- 回收实体
            local FinalAction = TriggerAction
            local DelayTime = FinalAction.Delay * 0.001
            self:RegisterTimer(
                function()
                    local AnimComp = ActorUtil.GetActorAnimationComponent(self.CameraEntityID)
                    if (AnimComp ~= nil) then
                        local AnimationInstance = AnimComp:GetAnimInstance()
                        if (AnimationInstance ~= nil) then
                            AnimationInstance:Montage_Stop(0.0)
                        end
                    end
                    _G.UE.UActorManager:Get():RemoveClientActor(self.CameraEntityID)
                end,
                DelayTime
            )
            self:RegisterTimer(
                function()
                    if (self.bNeedKillAtomos) then
                        _G.LuaCameraMgr:ResumeCamera(false)
                    end
                end,
                DelayTime + 0.1
            )
            self.bPlayAtomos = false
            self.bPlayRouletteSpin = false
        elseif (ActionType == ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_SHOW_UI) then
            local FinalAction = TriggerAction
            local DelayTime = FinalAction.Param3
            self:InternalTriggerAction(ActionType, FinalAction)

            -- 关闭所有的HUD显示
            self:InternalSetHUDVisible(false)
            self.bHideHud = true
            self:RegisterTimer(
                function()
                    if (self.bHideHud) then
                        -- 这里是延迟恢复所有的HUD显示
                        self:InternalSetHUDVisible(true)
                        self.bHideHud = false
                    end
                end,
                DelayTime
            )
        elseif (ActionType == ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_ENTITY_ATL_SWITCH) then
            -- 播放 ATL
            local FinalAction = TriggerAction
            -- 这里延迟触发，避免怪物没有创建出来
            self:RegisterTimer(
                function()
                    if (self.CameraEntityID ~= nil and self.CameraEntityID > 0) then
                        self:InternalTriggerAction(ActionType, FinalAction)
                    end
                end,
                0.1
            )
        else
            -- 其他的不需要Entities的，直接执行就可以了
            self:InternalTriggerAction(ActionType, TriggerAction)
        end
    end
end

function TreasuryMgr:InternalSetHUDVisible(InbVisible)
    local HUDMgr = _G.HUDMgr
    if (InbVisible) then
        HUDMgr:ShowAllActors()
        HUDMgr:ShowAllNpc()
    else
        HUDMgr:HideAllActors()
        HUDMgr:HideAllNpc()
    end
end

function TreasuryMgr:InternalTriggerAction(ActionType, TriggerAction)
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

    if (self.CameraEntityID ~= nil and self.CameraEntityID > 0) then
        ActionParams.TriggerEntityID = self.CameraEntityID
        ActionParams.Entities = {}
        ActionParams.Entities[1] = self.CameraEntityID
    end

    PWorldTriggerActionExecMgr:OnTriggerActionExec(ActionType, ActionParams)
end

function TreasuryMgr:InternalKillAtomos()
    if (self.AtomosEntityID == nil) then
        return
    end

    local TargetActor = ActorUtil.GetActorByEntityID(self.AtomosEntityID)
    if (TargetActor ~= nil) then
        TargetActor:OnMonsterDead()
    end

    self.AtomosEntityID = nil
end

function TreasuryMgr:StartPlayCPath(InEntityID, InbDead)
    local UMoveMgr = _G.UE.UMoveMgr:Get()
    if (UMoveMgr == nil) then
        _G.FLOG_ERROR("没有 UMoveMgr , 请检查!")
        return
    end

    local TargetCPathTable = nil
    if (InbDead) then
        TargetCPathTable = self.CPathIDTable[2] -- 结束的
    else
        TargetCPathTable = self.CPathIDTable[1] -- 复活的
    end
    local TargetActor = ActorUtil.GetActorByEntityID(InEntityID)
    if (TargetActor == nil) then
        _G.FLOG_ERROR("TreasuryMgr:StartPlayCPath 错误，无法获取角色，EntityID : %s", InEntityID)
        return
    end
    local TargetActorPos = TargetActor:K2_GetActorLocation()
    local ActorOriginPos = TargetActorPos
    -- 中心(パス0の終点)からプレイヤーの位置へのベクトルをY軸回り90度時計回り回転した位置から始点が一番近いパスを探す
    local CenterPos = self:GetCenterPos()
    local dir = TargetActorPos - CenterPos

    self:RotateZ(dir, 3.1415926 * 0.5)
    local basePos = CenterPos + dir
    local nearestLengthSquare = 100.0 * 100.0

    local TargetID = 0
    local FinalEndPos = ActorOriginPos
    for Key, Value in pairs(TargetCPathTable) do
        local CPathActor, PosArray = self:GetCPathActorAndPosArrayByID(Value.CPathID)
        if (CPathActor ~= nil) then
            local CPathActorPos = CPathActor:K2_GetActorLocation()
            local BeginPos = CPathActorPos + PosArray:Get(1)
            local lengthSquare = self:GetLengthSquare(BeginPos - basePos)
            if (lengthSquare < nearestLengthSquare or TargetID == 0) then
                TargetID = Value.CPathID
                nearestLengthSquare = lengthSquare
                FinalEndPos = CPathActorPos + PosArray:Get(PosArray:Length())
            end
        end
    end

    local Flag = 0
    local FinalDir = 0
    if (InbDead) then
        Flag = Flag + GIMMICK_PATHMOVEFLAG.GIMMICK_PATHMOVEFLAG_END_LOOP
    else
        FinalEndPos = ActorOriginPos
    end

    local CalcType = 1 -- 1 表示计算速度，2 表示计算时间
    local CalcValue = 17000

    UMoveMgr:RequestGimmickPathMove(InEntityID, TargetID, FinalEndPos, FinalDir, CalcType, CalcValue, Flag, 0)
end

function TreasuryMgr:GetLengthSquare(InVector)
    return InVector.X * InVector.X + InVector.Y * InVector.Y + InVector.Z * InVector.Z
end

function TreasuryMgr:RotateZ(InVectorValue, InAngleValue)
    local cs = math.cos(InAngleValue)
    local sn = math.sin(InAngleValue)

    local X = InVectorValue.X * cs - InVectorValue.Y * sn
    InVectorValue.Y = InVectorValue.Y * cs + InVectorValue.X * sn
    InVectorValue.X = X
end

function TreasuryMgr:GetCenterPos()
    if (self.CPathBasePos ~= nil) then
        return self.CPathBasePos
    end

    local TargetAreaID = 7621806
    local AreaData = _G.MapEditDataMgr:GetArea(TargetAreaID)

    if (AreaData ~= nil) then
        local PosData = AreaData.Pop.RandomPositions[1]
        self.CPathBasePos = _G.UE.FVector(PosData.X, PosData.Y, PosData.Z)
    else
        _G.FLOG_ERROR("无法获取计算用的基准位置，AreaID : %s", TargetAreaID)
    end

    return self.CPathBasePos
end

return TreasuryMgr
