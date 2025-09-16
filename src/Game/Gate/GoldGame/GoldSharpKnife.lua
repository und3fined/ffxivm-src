--[[
Author: lightpaw_Leo, michaelyang_lightpaw
Date: 2023-10-12 14:35:12
Description: 快刀斩魔
--]]
local LuaClass = require("Core/LuaClass")
local GoldGameNewBase = require("Game/Gate/GoldGame/GoldGameNewBase")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local MsgTipsUtil = nil
local ClientVisionMgr = require("Game/Actor/ClientVisionMgr")
local TimeUtil = require("Utils/TimeUtil")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local AudioUtil = require("Utils/AudioUtil")
local ActorUtil = require("Utils/ActorUtil")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoCS = require("Protocol/ProtoCS")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")

local LSTR = _G.LSTR
local GoldSauserMgr = nil
local UAudioMgr = nil

local TimeOffset = 19500 -- 等待时间，19.5秒
local PickupGoldTextID = 40236 -- 拾取了金币，客户端显示的提示
-- local FirstPauseToPlayBGMID = 1 -- 第一次触发暂停时播放的BGM 70 - 80
local SecondPauseMusicPath = nil
local DoubleCointSoundPath =
    "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_Tresure_M/Play_Zingle_Tresure_M.Play_Zingle_Tresure_M'"

local FirstPauseTime = 70000 -- 第一次暂停的时间，报名结束后的时间
local FirstPauseTimeOffset = 72000 -- 第一次暂停的时间Offset，避免重连的时候再播放一次
local FirstContinueTime = 80000 -- 第一次暂停继续的时间，报名结束后的时间

local SecondPauseTime = 170000 -- 第二次暂停的时间，报名结束后的时间
local SecondPauseTimeOffset = 172000 -- 第二次暂停时间OFFSET，避免重新登陆再播一次
local SecondContinueTime = 183000 -- 第二次暂停继续，报名结束后的时间

local FirstTutorialTime = 43000 -- 第一次新手引导的出现时间
local FirstTutorialTimeOffset = 45000 -- 第一次新手引导时间Offset
local SecondTutorialTime = 81000 -- 第二次新手引导的出现时间
local SecondTutorialTimeOffset = 83000 -- 第二次新手引导时间Offset

local MaxStage = 3
local BGMNull = 1 -- 空的BGM，为的是停掉当前的
local CoinDoubleTextDelayTime = 2 --金币翻倍的文字显示延迟时间

local CupStopRotateTime = 160000
local CupStopRotateTimeOffset = 162000
local CupStopRotateSound = nil
local CupCountThreeTime = 173000
local CupCountThreeTimeOffset = 175000
local CupCountThreeSound = nil

-- 服务器下发的更新状态类型
local GameInfoUpdateType = ProtoCS.GoldSauserUpdateGameStateType

-- 阶段类型，总共6种
local RewardStageType = {
    BaseReward = 0, -- 加入就给的奖励
    RewardStageOne = 1, -- 第一阶段奖励
    RewardStageTwo = 2, -- 第二阶段奖励
    RewardStageThree = 3, -- 第三阶段奖励
    RewardStageFour = 4, -- 第四阶段奖励
    RewardStageFive = 5 -- 第五阶段奖励
}

---@class GoldSharpKnife
local GoldSharpKnife = LuaClass(GoldGameNewBase)

function GoldSharpKnife:InitPauseParams()
    --快刀第一次暂停BGM时间(秒)
    local TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_FIRST_PAUSE_TIME)
    if (TableData ~= nil) then
        FirstPauseTime = TableData.Value[1] * 1000
        FirstPauseTimeOffset = FirstPauseTime + 2000
    end
    -- end

    --快刀第一次继续BGM时间(秒)
    TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_FIRST_CONTINUE_TIME)
    if (TableData ~= nil) then
        FirstContinueTime = TableData.Value[1] * 1000
    end
    -- end

    --快刀第二次暂停BGM时间(秒)
    TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_SECOND_PAUSE_TIME)
    if (TableData ~= nil) then
        SecondPauseTime = TableData.Value[1] * 1000
        SecondPauseTimeOffset = SecondPauseTime + 2000
    end
    -- end

    --快刀第二次继续BGM时间(秒)
    TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_SECOND_CONTINUE_TIME)
    if (TableData ~= nil) then
        SecondContinueTime = TableData.Value[1] * 1000
    end
    -- end

    --快刀第二次暂停BGMID
    TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_SECOND_PAUSE_BGMID)
    if (TableData ~= nil) then
        SecondPauseMusicPath = TableData.ValueStr[1]
    end
    -- end

    -- 快刀金币翻倍延迟显示时间
    TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_COIN_DOUBLE_DELAY)
    if (TableData ~= nil) then
        CoinDoubleTextDelayTime = TableData.Value[1]
    end
    -- end

    -- 篓子旋转停止时
    TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_STOPROTATE_SOUND)
    if (TableData ~= nil) then
        CupStopRotateTime = TableData.Value[1] * 1000
        CupStopRotateTimeOffset = CupStopRotateTime + 2000
        CupStopRotateSound = TableData.ValueStr[1]
    end
    -- end

    -- 倒计时到“三”时
    TableData = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_GS_SN_COUNTTHREE_TIME)
    if (TableData ~= nil) then
        CupCountThreeTime = TableData.Value[1] * 1000
        CupCountThreeTimeOffset = CupCountThreeTime + 2000
        CupCountThreeSound = TableData.ValueStr[1]
    end
    -- end
end

function GoldSharpKnife:Ctor()
    MsgTipsUtil = require("Utils/MsgTipsUtil")
    GoldSauserMgr = require("Game/Gate/GoldSauserMgr")

    self.bHasFirstPauseBGM = false -- 是否已经暂停了BGM
    self.bHasFirstContinueBGM = false -- 是否已经暂停了BGM
    self.bHasSecondPauseBGM = false -- 是否已经
    self.bHasSecondContinueBGM = false -- 第二次是否已经继续
    self.bHasPlayUniqueBGM = false -- 是否已经播放独特的BGM
    self.bHasPlayCupStop = false -- 篓子旋转停止时
    self.bHasPlayCountThree = false -- 倒数3停止时候

    self.bHasPlayFirstTutorial = false -- 是否播放了第一次新手引导
    self.bHasPlaySecondTutorial = false -- 是否播放了第二次新手引导

    self.TotalCoin = 0 -- 总金币数，服务端那边是阶段性下发，说是因为计算起来比较难，而且工期比较紧
    local _key = ProtoRes.Game.game_global_cfg_id.GAME_CFG_SLICE_IS_RIGHT_REWARD
    self.RewardTable = GameGlobalCfg:FindValue(_key, "Value")
    self.PickUpGoldList = {}
    self.Times = 1
    self.Stage = 0
    self.ShowStage = 0
    self.UniqueBGMID = 242

    UAudioMgr = _G.UE.UAudioMgr.Get()
    self.HasPlayUniqueBGM = false

    self:InitPauseParams()
end

---@param InGameVM    Type GoldSauserVM
---@param InGameState Type ProtoCS.GoldSauserEntertainState
---@return  Type Description
function GoldSharpKnife:OnRefreshInfoWhenStateChange(InGameMgr, InGameVM, InGameState)
    if (InGameState == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_SignUp) then
        InGameVM.bShowPanelAvoid = false
        InGameVM.bShowPanelGet = false
        InGameVM.bActivityDescVisible = true
        InGameVM.bShowPanelCountdown = true
    else
        InGameVM.bShowPanelAvoid = true
        InGameVM.bShowPanelGet = true
        InGameVM.bActivityDescVisible = false
        InGameVM.bShowPanelCountdown = false
    end
    InGameVM.AvoidText = string.format(LSTR(1270001), self.ShowStage, MaxStage) -- 躲避次数：%s/%s
    InGameVM.GoldText = string.format(LSTR(1270002), self.TotalCoin) -- 当前获得的金碟币：%s
end

function GoldSharpKnife:OnGameStateToInProgress(InGameMgr, InGameVM)
    self:OnCancelAllTimer()
    local bPlayerSignUp = InGameMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp
    if (bPlayerSignUp) then
        self.BGMTimer = _G.TimerMgr:AddTimer(self, self.TickForUniqueBGM, 0, 1, -1)
    end
end

function GoldSharpKnife:TryPlayBGM(InGameMgr)
    local GameState = InGameMgr.Entertain.State
    local bInProgress = GameState == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_InProgress
    local bInSignUp = GameState == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_SignUp
    local bPlayerSignUp = InGameMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp
    if (not bInProgress and not bInSignUp) then
        return
    end

    if (not bPlayerSignUp) then
        return
    end

    if (self.BGMID ~= nil and self.BGMID > 0 and InGameMgr.PlayedBGMUniqueID == 0) then
        local SignUpEndTime = InGameMgr.SignUpEndTime
        local CurTime = TimeUtil.GetServerLogicTimeMS()
        local TimeSpan = CurTime - SignUpEndTime
        if (TimeSpan >= TimeOffset) then
            InGameMgr.PlayedBGMUniqueID = UAudioMgr:PlayBGM(self.UniqueBGMID, _G.UE.EBGMChannel.AreaZone)
            self.bHasPlayUniqueBGM = true
        else
            InGameMgr.PlayedBGMUniqueID = UAudioMgr:PlayBGM(self.BGMID, _G.UE.EBGMChannel.AreaZone)
        end

        self:OnCancelAllTimer()
        self.BGMTimer = _G.TimerMgr:AddTimer(self, self.TickForUniqueBGM, 0, 1, -1)
    end
end

function GoldSharpKnife:TryRestoreBGM(InGameMgr)
    if (InGameMgr.PlayedBGMUniqueID ~= nil and InGameMgr.PlayedBGMUniqueID > 0) then
        UAudioMgr:StopBGM(InGameMgr.PlayedBGMUniqueID)
        InGameMgr.PlayedBGMUniqueID = 0
    end

    if (self.BGMNullUniqueID ~= nil) then
        UAudioMgr:StopBGM(self.BGMNullUniqueID)
        self.BGMNullUniqueID = nil
    end
end

function GoldSharpKnife:TickForUniqueBGM()
    local PlayerState = GoldSauserMgr.Player
    if (PlayerState  ~= ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp) then
        self:OnCancelAllTimer()
        self:TryRestoreBGM(GoldSauserMgr)
        return
    end

    local SignUpEndTime = GoldSauserMgr.SignUpEndTime
    local CurTime = TimeUtil.GetServerLogicTimeMS()
    if (SignUpEndTime == nil) then
        SignUpEndTime = CurTime
        _G.FLOG_ERROR("无法获取当前活动的报名结束时间，请检查，使用当前服务器时间代替")
    end
    local TimeSpan = CurTime - SignUpEndTime

    local bShouldPlayUniqueBGM = self.bHasPlayUniqueBGM == false and TimeSpan >= TimeOffset
    if (bShouldPlayUniqueBGM) then
        self.bHasPlayUniqueBGM = true
        GoldSauserMgr.PlayedBGMUniqueID = UAudioMgr:PlayBGM(self.UniqueBGMID, _G.UE.EBGMChannel.AreaZone)
    end

    if (not self.bHasPlayFirstTutorial) then
        if (TimeSpan >= FirstTutorialTime and TimeSpan <= FirstTutorialTimeOffset) then
            -- 播放第一次新手引导，躲竹子
            self.bHasPlayFirstTutorial = true

            local function ShowSharpKnifeStageTutorialOne(Params)
                local EventParams = _G.EventMgr:GetEventParams()
                EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition
                --新手引导触发类型
                EventParams.Param1 = TutorialDefine.GameplayType.Yojimbo
                EventParams.Param2 = TutorialDefine.GamePlayStage.YojimboBambooFalls
                _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
            end

            local TutorialConfig = {
                Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
                Callback = ShowSharpKnifeStageTutorialOne,
                Params = {}
            }
            _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
        end
    end

    if (not self.bHasPlaySecondTutorial) then
        if (TimeSpan >= SecondTutorialTime and TimeSpan <= SecondTutorialTimeOffset) then
            -- 播放第二次新手引导 , 大五郎
            self.bHasPlaySecondTutorial = true

            local function ShowSharpKnifeStageTutorialTwo(Params)
                local EventParams = _G.EventMgr:GetEventParams()
                EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition
                --新手引导触发类型
                EventParams.Param1 = TutorialDefine.GameplayType.Yojimbo
                EventParams.Param2 = TutorialDefine.GamePlayStage.YojimboDuoBi
                _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
            end

            local TutorialConfig = {
                Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
                Callback = ShowSharpKnifeStageTutorialTwo,
                Params = {}
            }
            _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
        end
    end

    if (not self.bHasPlayCupStop) then
        if (TimeSpan >= CupStopRotateTime and TimeSpan <= CupStopRotateTimeOffset) then
            self.bHasPlayCupStop = true
            AudioUtil.LoadAndPlay2DSound(CupStopRotateSound)
        elseif TimeSpan > CupStopRotateTimeOffset then
            self.bHasPlayCupStop = true
        end
    end
    if (not self.bHasPlayCountThree) then
        if (TimeSpan >= CupCountThreeTime and TimeSpan <= CupCountThreeTimeOffset) then
            AudioUtil.LoadAndPlay2DSound(CupCountThreeSound)
            self.bHasPlayCountThree = true
        end
    end

    if (not self.bHasFirstPauseBGM) then
        -- 第一次暂停 BGM
        if (TimeSpan >= FirstPauseTime and TimeSpan <= FirstPauseTimeOffset) then
            self.BGMNullUniqueID = UAudioMgr:PlayBGM(BGMNull, _G.UE.EBGMChannel.SpecialEvent)
            self.bHasFirstPauseBGM = true
        elseif (TimeSpan > FirstPauseTimeOffset) then
            self.bHasFirstPauseBGM = true
        end
    end
    if (not self.bHasFirstContinueBGM and self.bHasFirstPauseBGM) then
        if (TimeSpan >= FirstContinueTime) then
            self.bHasFirstContinueBGM = true
            if (self.BGMNullUniqueID ~= nil) then
                UAudioMgr:StopBGM(self.BGMNullUniqueID)
            end
            self.BGMNullUniqueID = nil
        end
    end
    if (not self.bHasSecondPauseBGM) then
        -- 第2次暂停
        if (TimeSpan >= SecondPauseTime and TimeSpan <= SecondPauseTimeOffset) then
            self.BGMNullUniqueID = UAudioMgr:PlayBGM(BGMNull, _G.UE.EBGMChannel.SpecialEvent)
            AudioUtil.LoadAndPlay2DSound(SecondPauseMusicPath)

            self.bHasSecondPauseBGM = true
        elseif (TimeSpan > SecondPauseTimeOffset) then
            self.bHasSecondPauseBGM = true
        end
    end
    if (not self.bHasSecondContinueBGM and self.bHasSecondPauseBGM) then
        if (TimeSpan >= SecondContinueTime) then
            self.bHasSecondContinueBGM = true
            if (self.BGMNullUniqueID ~= nil) then
                UAudioMgr:StopBGM(self.BGMNullUniqueID)
            end
            self.BGMNullUniqueID = nil
        end
    end

    if (self.bHasSecondContinueBGM and self.BGMTimer ~= nil) then
        self:OnCancelAllTimer()
    end
end

function GoldSharpKnife:OnCancelAllTimer()
    if (self.BGMTimer ~= nil) then
        _G.TimerMgr:CancelTimer(self.BGMTimer)
        self.BGMTimer = nil
    end
end

--- 这里是直接刷新的，用于进入地图后，刷新数据 MsgData 是 GoldSauserUpdateRsp
function GoldSharpKnife:DirectRefreshInfoData(InGameMgr, InGameVM, MsgData)
    if (MsgData == nil) then
        _G.FLOG_ERROR("DirectRefreshInfoData错误，传入的 Data 为空")
        return
    end

    -- 这里写入数据
    self.Stage = MsgData.Stage
    self.Times = MsgData.PlayerSIR.Times

    self.PickUpGoldList = {}
    for Key, ObjID in pairs(MsgData.PlayerSIR.ObjIDs) do
        table.insert(self.PickUpGoldList, ObjID)
        ClientVisionMgr:DestoryClientActor(ObjID)
    end

    local _tempCoin = self:CalculateCoin(self.Stage, self.Times)
    self.TotalCoin = _tempCoin

    local newStage = math.ceil(self.Stage / 2)
    self.ShowStage = newStage

    InGameVM.AvoidText = string.format(LSTR(1270001), self.ShowStage, MaxStage)
    InGameVM.GoldText = string.format(LSTR(1270002), self.TotalCoin) -- 当前获得的金碟币：%s
    InGameVM.bAvoidTimesChanged = not InGameVM.bAvoidTimesChanged
end

--- @type 动态更新游戏信息
function GoldSharpKnife:OnNetUpdateGameData(InMsgData, InGameMgr, InGameVM)
    if (InMsgData == nil) then
        _G.FLOG_ERROR("GoldSharpKnife:UpdateGameInfoData 出错，传入的 InMsgData 为空，请检查")
        return
    end
    local _needShowMultiTimesInfo = false
    local StageChanged = false
    if (InMsgData.Type == GameInfoUpdateType.GoldSauserUpdateGameStateType_Stage) then
        self.Stage = InMsgData.Stage
        local newStage = math.ceil(self.Stage / 2)
        if (newStage ~= self.ShowStage) then
            StageChanged = true
            self.ShowStage = newStage
        end
    elseif (InMsgData.Type == GameInfoUpdateType.GoldSauserUpdateGameStateType_ObjID) then
        self.Stage = RewardStageType.RewardStageTwo -- 拾金币就第二阶段有
        local _pickedCount = #self.PickUpGoldList
        if (InMsgData.ObjID > 0 and _pickedCount < 2) then -- ID要大于0，并且最多可以拾取2个金币堆
            local _exit = false
            for i = 1, #self.PickUpGoldList do
                if (self.PickUpGoldList[i] == InMsgData.ObjID) then
                    _exit = true
                    break
                end
            end

            if (not _exit) then
                local DelayTime = 0.5
                local HUDMgr = require("Game/HUD/HUDMgr")
                HUDMgr:HideActorInfo(InMsgData.ObjID)
                table.insert(self.PickUpGoldList, InMsgData.ObjID)
                local Actor = ActorUtil.GetActorByEntityID(InMsgData.ObjID)
                if (Actor ~= nil) then
                    Actor:SetSharedGroupTimelineState(8)
                    _G.TimerMgr:AddTimer(
                        self,
                        function()
                            ClientVisionMgr:DestoryClientActor(InMsgData.ObjID)
                            MsgTipsUtil.ShowTipsByID(PickupGoldTextID)
                        end,
                        DelayTime,
                        0,
                        1
                    )
                else
                    ClientVisionMgr:DestoryClientActor(InMsgData.ObjID)
                    MsgTipsUtil.ShowTipsByID(PickupGoldTextID)
                end
            end
        end
    elseif (InMsgData.Type == GameInfoUpdateType.GoldSauserUpdateGameStateType_SIRtimes) then
        if (InMsgData.SIRtimes > self.Times) then
            if (self.Times ~= InMsgData.SIRtimes) then
                _needShowMultiTimesInfo = true
            end

            self.Times = InMsgData.SIRtimes
            self.Stage = RewardStageType.RewardStageFour -- 就第四阶段有
        end
    else
        _G.FLOG_ERROR("错误，无效的类型：" .. InMsgData.Type)
    end

    local _tempCoin = self:CalculateCoin(self.Stage, self.Times)

    if (_needShowMultiTimesInfo) then
        local _preTimes = self.Times - 1
        if (_preTimes < 1) then
            _preTimes = 1
        end

        local LoopTime = 1 --只执行一次
        local Interval = 0
        _G.TimerMgr:AddTimer(
            self,
            function()
                local SecondDelayTime = 3.5
                _G.TimerMgr:AddTimer(
                    self,
                    function()
                        local _preCoin = self:CalculateCoin(self.Stage, _preTimes)
                        local _addCoin = _tempCoin - _preCoin
                        local SysNoticeID = 40238 -- 金碟币增加
                        local Data = SysnoticeCfg:FindCfgByKey(SysNoticeID)
                        if (Data ~= nil) then
                            local _content = string.format(Data.Content[1], _addCoin)
                            MsgTipsUtil.ShowTipsByID(SysNoticeID, _content)
                        else
                            _G.FLOG_ERROR("错误，无法获取系统通知信息，ID是：" .. tostring(SysNoticeID))
                        end
                    end,
                    SecondDelayTime,
                    Interval,
                    LoopTime
                )

                local SysNoticeID2 = 40237 -- 金碟币翻倍
                local Data = SysnoticeCfg:FindCfgByKey(SysNoticeID2)
                if (Data ~= nil) then
                    MsgTipsUtil.ShowTipsByID(SysNoticeID2)
                else
                    _G.FLOG_ERROR("错误，无法获取系统通知信息，ID是：" .. tostring(SysNoticeID2))
                end

                -- 播放音效
                AudioUtil.LoadAndPlay2DSound(DoubleCointSoundPath)
            end,
            CoinDoubleTextDelayTime,
            Interval,
            LoopTime
        )
    end

    self.TotalCoin = _tempCoin

    InGameVM.AvoidText = string.format(LSTR(1270001), self.ShowStage, 3)
    InGameVM.GoldText = string.format(LSTR(1270002), self.TotalCoin) -- 当前获得的金碟币：%s

    if (StageChanged) then
        InGameVM.bAvoidTimesChanged = not InGameVM.bAvoidTimesChanged
    end
end

-- 弹出倒计时的时间，需要的话，覆写一下，返回大于0的时间即可
function GoldSharpKnife:OnGetTimeCountDownRedTime()
    return 10
end

function GoldSharpKnife:OnShowInfoAfterSignup(InGameMgr)
    -- 解锁快刀系统
    local function ShowGoldSauserCommTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.UnlockGameplay
        --新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.Yojimbo
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {
        Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
        Callback = ShowGoldSauserCommTutorial,
        Params = {}
    }
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
    -- END

    local SignUpEndTime = InGameMgr.SignUpEndTime
    local ServerTime = TimeUtil.GetServerLogicTimeMS()
    if (SignUpEndTime == nil) then
        SignUpEndTime = ServerTime
    end

    local RemainTime = SignUpEndTime - ServerTime
    local RemainSec = math.floor(RemainTime / 1000)

    -- 大于倒计时2秒才显示，要不感受不好
    if (RemainSec > (self:OnGetTimeCountDownRedTime() + 2)) then
        -- 如果是快刀斩魔，那么播放文本 40200
        local TipsID = 40200
        MsgTipsUtil.ShowTipsByID(TipsID)

        local WaitID = 40286 -- 挑战即将开始，请耐心等待
        MsgTipsUtil.ShowTipsByID(WaitID)
    end
end

function GoldSharpKnife:CalculateCoin(StageValue, TargetTimes)
    local _tempCoin = 100
    local _pickUpCount = #self.PickUpGoldList
    local _times = TargetTimes
    if (StageValue == RewardStageType.BaseReward) then
        _tempCoin = self.RewardTable[1]
    elseif (StageValue == RewardStageType.RewardStageOne) then
        _tempCoin = self.RewardTable[2]
    elseif (StageValue == RewardStageType.RewardStageTwo) then
        _tempCoin = self.RewardTable[2] + self.RewardTable[5] * _pickUpCount
    elseif (StageValue == RewardStageType.RewardStageThree) then
        _tempCoin = self.RewardTable[2] + self.RewardTable[3] + self.RewardTable[5] * _pickUpCount
    elseif (StageValue == RewardStageType.RewardStageFour) then
        _tempCoin = (self.RewardTable[2] + self.RewardTable[3] + self.RewardTable[5] * _pickUpCount) * _times
    elseif (StageValue == RewardStageType.RewardStageFive) then
        _tempCoin =
            (self.RewardTable[2] + self.RewardTable[3] + self.RewardTable[5] * _pickUpCount) * _times +
            self.RewardTable[4]
    else
        -- 这里要斟酌一下，看看服务器那边的情况
        _G.FLOG_ERROR("快刀斩魔阶段错误，传入的值是：" .. tostring(StageValue))
    end

    return _tempCoin
end

return GoldSharpKnife
