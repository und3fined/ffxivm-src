-- Author: michaelyang_lightpaw
-- Date: 2024-11-15
-- Description:机遇临门游戏基类，因为虚基类性能不好，使用OnXXX来供子类使用
--

local LuaClass = require("Core/LuaClass")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local DialogCfg = require("TableCfg/DialogCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local GoldSauseGateCfg = require("TableCfg/GoldSauserGateCfg")
local ActorUtil = require("Utils/ActorUtil")
local AudioUtil = require("Utils/AudioUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local MsgTipsUtil = nil
local UAudioMgr = nil
local EntertainGameID = ProtoRes.Game.GameID
local EState = ProtoCS.GoldSauserEntertainState
local EPlayer = ProtoCS.GoldSauserPlayer

local LSTR = _G.LSTR
local TimerMgr = _G.TimerMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local GoldSauserMgr = nil
local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldGameNewBase
local GoldGameNewBase = LuaClass()

-- --Ctor
function GoldGameNewBase:Ctor()
    self.MinCountdownShowTime = 2000
    self.MinCountdownCheckTime = 100
    GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
    MsgTipsUtil = require("Utils/MsgTipsUtil")
    UAudioMgr = _G.UE.UAudioMgr.Get()
    self.SignUpTimerID = 0
    self.CountdownRedTime = self:OnGetTimeCountDownRedTime()
    self.bGameEnd = false -- 避免重复调用 GameStateToEnd
    self.BGMID = 251 -- 游戏报名后的BGM
    self.LubbyBGMID = 250 -- 金碟大厅的普通BGM
end

function GoldGameNewBase:Init(InGameMgr)
    self.GameCfg = GoldSauseGateCfg:FindCfgByKey(InGameMgr.Entertain.ID) -- 游戏配置信息
    if (self.GameCfg == nil) then
        _G.FLOG_ERROR("GoldSauseGateCfg:FindCfgByKey 错误，无法获取数据，ID是:%s", tostring(InGameMgr.Entertain.ID))
    end
end

function GoldGameNewBase:ForceEnd()
    self:OnForceEnd() -- 子类去复写
end

-- 子类复写，用于断线重连【非闪断】后，强制清理数据
function GoldGameNewBase:OnForceEnd()
end

-- 游戏结束，主要用于可以不在游戏状态结束的时候完结的，如小雏鸟、空军装甲
function GoldGameNewBase:PlayerGameEnd(InGameMgr, InGameVM, InMsgData)
    self:CancelAllTimer()

    -- 子类
    self:OnPlayerGameEnd(InGameMgr, InGameVM, InMsgData)

    self:RefreshInfoWhenStateChange(InGameMgr, InGameVM)

    self:TryRestoreBGM(InGameMgr)
end

-- 子类用,游戏结束，主要用于可以不在游戏状态结束的时候完结的
function GoldGameNewBase:OnPlayerGameEnd(InGameMgr, InGameVM, InMsgData)
end

-- 游戏状态改变成报名状态
function GoldGameNewBase:GameStateToSignUp(InGameMgr, InGameVM)
    InGameVM.CountDownTitleText = LSTR(1270003)
    self:TryPlayBGM(InGameMgr)
    self:RefreshInfoWhenStateChange(InGameMgr, InGameVM)
    self:RegisterSignUpTimeCountDown(InGameMgr, InGameVM)
    self:OnGameStateToSignUp(InGameMgr, InGameVM)
end

function GoldGameNewBase:RegisterSignUpTimeCountDown(InGameMgr, InGameVM)
    self:CancelSignUpTimer()
    local bSignUp = InGameMgr.Player == EPlayer.GoldSauserPlayer_SignUp or InGameMgr.bHasPlayerSignUp
    if (not bSignUp) then
        return
    end
    local SignUpEndTime = InGameMgr.SignUpEndTime
    local ServerTime = TimeUtil.GetServerLogicTimeMS()

    if (SignUpEndTime == nil or SignUpEndTime == 0) then
        SignUpEndTime = ServerTime
    end

    local RemainTime = SignUpEndTime - ServerTime

    -- 大于 MinCountdownShowTime MS 才倒计时
    if (RemainTime > self.MinCountdownShowTime) then
        -- 这里去开启倒计时
        self.SignUpTimerID = TimerMgr:AddTimer(self, self.InternalCountdownForSignUpTime, 0, 1, 0)
        self:OnRegisterSignUpTimeCountDown()
    else
        InGameVM.ActivityTime = LocalizationUtil.GetTimerForHighPrecision(0)
        self:OnGetTimeCountDownFinishCallback()
    end
end

-- 子类用，判断是否能注册报名倒计时，默认是可以注册的
function GoldGameNewBase:OnCanRegisterSignUpTimeCountDown()
    return true
end

-- 子类用，在成功注册了倒计时的时候，可能想要自己的检测什么的，目前是小雏鸟用到，会检测高度
function GoldGameNewBase:OnRegisterSignUpTimeCountDown()
end

function GoldGameNewBase:OnGameStateToSignUp(InGameMgr, InGameVM)
end

function GoldGameNewBase:NetPlayerSignUp(InGameMgr, InGameVM)
    self:RefreshInfoWhenStateChange(InGameMgr, InGameVM)
    self:RegisterSignUpTimeCountDown(InGameMgr, InGameVM)
    self:OnNetPlayerSignUp(InGameMgr, InGameVM)
end

-- 子类用
function GoldGameNewBase:OnNetPlayerSignUp(InGameMgr, InGameVM)
end

-- 游戏状态变成进行中的状态
function GoldGameNewBase:GameStateToInProgress(InGameMgr, InGameVM)
    InGameVM.bShowPanelCountdown = false
    self:TryPlayBGM(InGameMgr)
    self:RefreshInfoWhenStateChange(InGameMgr, InGameVM)
    self:OnGameStateToInProgress(InGameMgr, InGameVM)
end

function GoldGameNewBase:OnGameStateToInProgress(InGameMgr, InGameVM)
end

-- 游戏状态变成结束状态，这里回收NPC相关
function GoldGameNewBase:GameStateToEnd(InGameMgr, InGameVM)
    if (self.bGameEnd == true) then
        return
    end
    self.bGameEnd = true
    self:CancelAllTimer()
    self:RefreshInfoWhenStateChange(InGameMgr, InGameVM)
    self:TryRestoreBGM(InGameMgr)
    self:OnGameStateToEnd(InGameMgr, InGameVM)
end

function GoldGameNewBase:OnGameStateToEnd(InGameMgr, InGameVM)
end

-- 服务器推送数据变化，子类自行处理
function GoldGameNewBase:NetUpdateGameData(InMsgData, InGameMgr, InGameVM)
    if (InMsgData == nil) then
        FLOG_ERROR("传入的网络数据为空，请检查")
        return
    end
    self:OnNetUpdateGameData(InMsgData, InGameMgr, InGameVM)
end

-- 子类用，服务器推送数据变化，目前是喷风和快刀在用
function GoldGameNewBase:OnNetUpdateGameData(InMsgData, InGameMgr, InGameVM)
end

-- 取消所有的时间
function GoldGameNewBase:CancelAllTimer()
    self:CancelSignUpTimer()
    self:OnCancelAllTimer()
end

-- 子类用
function GoldGameNewBase:OnCancelAllTimer()
end

-- 取消报名时间倒计时
function GoldGameNewBase:CancelSignUpTimer()
    if (self.SignUpTimerID ~= nil and self.SignUpTimerID > 0) then
        TimerMgr:CancelTimer(self.SignUpTimerID)
        self.SignUpTimerID = 0
    end
    self:OnCancelSignUpTimer()
end

-- 子类用，取消计时
function GoldGameNewBase:OnCancelSignUpTimer()
end

--- @逻辑代码开始

--- @type根据不同的小游戏ID获得对话ID，子类可以覆写
function GoldGameNewBase:GetDialogLib(InGameMgr)
    if (InGameMgr == nil) then
        _G.FLOG_ERROR("GoldGameNewBase:GetDialogLib 出错，传入的InGameMgr 为空，请检查")
        return 0
    end

    if (InGameMgr.Entertain == nil) then
        _G.FLOG_ERROR("当前的 Entertain 为空，请检查")
        return 0
    end

    if (InGameMgr.Player == nil) then
        _G.FLOG_ERROR("当前的 Player 无效，请检查")
        return 0
    end

    local NeedDialogID = 0
    local GameCfg = self.GameCfg
    if GameCfg == nil then
        _G.FLOG_ERROR("GameCfg is nil when GetDialog")
        return
    end

    local CurPlayerState = InGameMgr.Player
    local CurGameState = InGameMgr.Entertain.State

    if (CurPlayerState == EPlayer.GoldSauserPlayer_NotSignUp) then
        -- 没有报名
        if (CurGameState == EState.GoldSauserEntertainState_SignUp) then
            -- 游戏还在报名阶段
            NeedDialogID = GameCfg.OnSignUpLibID
        else
            -- 游戏不在报名阶段
            NeedDialogID = GameCfg.AlreadyDeadLineLibID
        end
    elseif (CurPlayerState == EPlayer.GoldSauserPlayer_SignUp) then
        -- 已经报名
        if (CurGameState == EState.GoldSauserEntertainState_SignUp) then
            -- 游戏还在报名阶段
            NeedDialogID = GameCfg.AlreadySignUpLibID
        else
            _G.FLOG_ERROR("报名后，游戏处于非报名阶段了， 这个时候未处理")
        end
    elseif (CurPlayerState == EPlayer.GoldSauserPlayer_End) then
        -- 这里默认游戏结束后，能和NPC对话的都是失败对话
        NeedDialogID = self:OnGetFinishDialogID(GameCfg)
    else
        _G.FLOG_ERROR("当前状态未处理，PlayerState : %s, GameState : %s", tostring(CurPlayerState), tostring(CurGameState))
    end

    return NeedDialogID
end

-- 玩家自己的游戏状态已经完成后，和NPC对话的ID，子类子类覆写
function GoldGameNewBase:OnGetFinishDialogID(InTableData)
    return InTableData.DefeatLibID
end

-- 主动结束游戏，目前只有空军和跳跳乐
function GoldGameNewBase:EndGame(bSuccess)
end

--- @type 根据游戏当前状态返回对话的回调，子类可以覆写
function GoldGameNewBase:GetDialogCallBack(InGameMgr)
    local ConfirmCallBack = nil
    local CurGameRound = _G.GoldSauserMgr.Round
    local function SignUp()
        if (self:OnCustomCheck()) then
            if (self:OnNeedCheckNotInTeam()) then
                if _G.TeamMgr:GetMemberNum() == 0 and not _G.PWorldMatchVM.IsMatching then
                    InGameMgr:SendSignUpGame(CurGameRound) -- 报名
                elseif _G.TeamMgr:GetMemberNum() > 0 then
                    MsgTipsUtil.ShowTips(LSTR(1270032)) -- "玩家处于组队状态无法进入"
                else
                    MsgTipsUtil.ShowTips(LSTR(1270033)) -- "正在申请参加任务，无法重复申请"
                end
            else
                InGameMgr:SendSignUpGame(CurGameRound) -- 报名
            end
        end
    end
    local function Teleport()
        InGameMgr:SendTeleToStageReq() -- 传送回舞台
    end
    local GameCfg = self.GameCfg
    if GameCfg == nil then
        _G.FLOG_ERROR("GameCfg is nil when GetDialogCallBack")
        return
    end

    local CurPlayerState = InGameMgr.Player
    local CurGameState = InGameMgr.Entertain.State

    if (CurGameState == EState.GoldSauserEntertainState_SignUp) then
        if (CurPlayerState == EPlayer.GoldSauserPlayer_NotSignUp) then
            -- 没有报名就走报名
            ConfirmCallBack = SignUp
        elseif (CurPlayerState == EPlayer.GoldSauserPlayer_SignUp) then
            -- 报名了就走传送
            ConfirmCallBack = Teleport
        end
    else
        -- 不是报名状态不做处理
    end

    local Content = GameCfg.SignUpTipContent
    local function CallBack()
        InGameMgr:ShowChallengeTip(Content, ConfirmCallBack)
    end
    return CallBack
end

-- 子类可以覆写，子类的自定义检测
function GoldGameNewBase:OnCustomCheck()
    return true
end

-- 子类覆写，是否需要检查组队状态，目前空军和虚景跳跳乐不能在组队中，子类决定
function GoldGameNewBase:OnNeedCheckNotInTeam()
    return false
end

function GoldGameNewBase:ShowInfoAfterSignup(InGameMgr)
    if (InGameMgr.HasPlaySignUp == false and InGameMgr.bHasPlayerSignUp == true) then
        InGameMgr.HasPlaySignUp = true

        InGameMgr:ShowGoldSauserOpportunityForBegin(
            function()
                self:OnShowInfoAfterSignup(InGameMgr)

                -- 机遇临门通用的新手引导
                InGameMgr:ShowOpportunityNewTutorial()

                self:TryPlayBGM(InGameMgr)
            end
        )
    else
        self:OnShowInfoAfterSignup(InGameMgr)
    end
end

-- 子类覆写
function GoldGameNewBase:OnShowInfoAfterSignup(InGameMgr)
end

-- 报名倒计时相关
function GoldGameNewBase:InternalCountdownForSignUpTime()
    local GameMgr = GoldSauserMgr
    local SignUpEndTime = GameMgr.SignUpEndTime
    local ServerTime = TimeUtil.GetServerLogicTimeMS()
    if (SignUpEndTime == nil or SignUpEndTime == 0) then
        SignUpEndTime = ServerTime
    end

    local RemainTime = SignUpEndTime - ServerTime
    if (RemainTime == nil) then
        RemainTime = 0
    end
    local TargetVM = GameMgr.GoldSauserVM

    -- 显示倒计时
    local RemainSec = math.floor(RemainTime / 1000)

    -- 如果时间到了
    if RemainTime <= self.MinCountdownCheckTime then
        TargetVM.ActivityTime = LocalizationUtil.GetTimerForHighPrecision(RemainSec)
        self:CancelSignUpTimer()
        self:OnGetTimeCountDownFinishCallback()
        return
    end

    if RemainSec <= self.CountdownRedTime and RemainSec > 1 then
        if (self.bShowCountDownUIView ~= true) then
            self.bShowCountDownUIView = true
            local Params = {}
            Params.RedTime = self.CountdownRedTime
            Params.TimeInterval = 1
            Params.TimeDelay = 0
            Params.BeginTime = RemainSec + 1
            Params.RedTimePlaySound = GameMgr.BeginCountDownMusicPath

            UIViewMgr:ShowView(UIViewID.InfoCountdownTipsView, Params)
        end
    end

    TargetVM.ActivityTime = LocalizationUtil.GetTimerForHighPrecision(RemainSec)
end

-- 这里点击退出的按钮，子类处理
function GoldGameNewBase:OnBtnExitClicked()
end

-- 弹出倒计时的时间，需要的话，覆写一下，返回大于0的时间即可
function GoldGameNewBase:OnGetTimeCountDownRedTime()
    return 0
end

-- 子类覆写，倒计时结束了
function GoldGameNewBase:OnGetTimeCountDownFinishCallback()
end

function GoldGameNewBase:TryPlayBGM(InGameMgr)
    if (InGameMgr == nil or InGameMgr.Entertain == nil) then
        return
    end
    local GameState = InGameMgr.Entertain.State
    local bInProgress = GameState == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_InProgress
    local bInSignUp = GameState == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_SignUp
    local bPlayerSignUp =
        InGameMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp or InGameMgr.bHasPlayerSignUp
    if (not bInProgress and not bInSignUp) then
        return
    end

    if (not bPlayerSignUp) then
        return
    end

    if (self.BGMID ~= nil and self.BGMID > 0 and InGameMgr.PlayedBGMUniqueID == 0) then
        -- 普通的场景BGM 是 EBGMChannel.BaseZone，这里用 AreaZone 才能正确覆盖，并确保停止后播放的是场景BGM
        InGameMgr.PlayedBGMUniqueID = UAudioMgr:PlayBGM(self.BGMID, _G.UE.EBGMChannel.AreaZone)
        if (InGameMgr.PlayedBGMUniqueID == nil) then
            InGameMgr.PlayedBGMUniqueID = 0
        end
    end
end

function GoldGameNewBase:TryRestoreBGM(InGameMgr)
    if (InGameMgr.PlayedBGMUniqueID ~= nil and InGameMgr.PlayedBGMUniqueID > 0) then
        UAudioMgr:StopBGM(InGameMgr.PlayedBGMUniqueID)
        InGameMgr.PlayedBGMUniqueID = 0
    end
end

--- 当游戏状态发生变化的时候，可以是机遇临门的状态变化了，也可以是玩家的游戏状态变化了
---@param InGameVM    Type GoldSauserVM
---@param InGameState Type ProtoCS.GoldSauserEntertainState
---@return  Type nil
function GoldGameNewBase:RefreshInfoWhenStateChange(InGameMgr, InGameVM)
    if (InGameMgr.Entertain == nil) then
        FLOG_ERROR("机遇临门的 Entertain 为空，请检查")
        return
    end

    if (InGameVM == nil) then
        FLOG_ERROR("传入的 InGameVM 为空，请检查")
        return
    end

    local TableData = GoldSauseGateCfg:FindCfgByKey(InGameMgr.Entertain.ID)
    if TableData == nil then
        FLOG_ERROR("错误，GoldSauseGateCfg:FindCfgByKey 无法获取数据，ID是：" .. tostring(InGameMgr.Entertain.ID))
        return
    end

    local CurPlayerState = InGameMgr.Player
    local CurGameState = InGameMgr.Entertain.State
    local bSignUp = CurPlayerState == EPlayer.GoldSauserPlayer_SignUp or InGameMgr.bHasPlayerSignUp
    local bSignUpState = CurGameState == EState.GoldSauserEntertainState_SignUp
    local bInGameState = CurGameState == EState.GoldSauserEntertainState_InProgress
    if (bSignUp and (bSignUpState or bInGameState)) then
        InGameMgr:SetToggleInfoPanel(true)
        InGameVM.bShowPanelCountdown = true
    else
        InGameVM.bShowPanelCountdown = false
        InGameMgr:SetToggleInfoPanel(false)
    end

    InGameVM.bShowPanelAvoid = false
    InGameVM.bShowPanelGet = false

    InGameVM.ActivityName = ""
    InGameVM.ActivityName = TableData.GameName
    InGameVM.ActivityDesc = TableData.GameDesc

    self:OnRefreshInfoWhenStateChange(InGameMgr, InGameVM, InGameMgr.Entertain.State)

    InGameMgr:RefreshGameNpcIconState()
end

---GoldGameNewBase.OnRefreshGameInfo Description of the function
---@param InGameVM    Type GoldSauserVM
---@param InGameState Type ProtoCS.GoldSauserEntertainState
---@return  Type nil
function GoldGameNewBase:OnRefreshInfoWhenStateChange(InGameMgr, InGameVM, InGameState)
end

function GoldGameNewBase:AfterGateOpportunityRewardAnimEnd(Params)
    local IsInPanelMiniGame = _G.GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true) -- 小游戏过程中防止触发影响小游戏
    if IsInPanelMiniGame then
        return
    end
    local RewardDataList = {}
    for Key, Value in pairs(Params.RewardData.Items) do
        table.insert(RewardDataList, {ResID = Value.ID, Num = Value.Num})
    end

    local RewardItemListVM = _G.GoldSauserMgr:UpdateRewardListVM(RewardDataList)

    local Title = LSTR(1270005)
    local HideCallback = function()
        _G.GoldSauserMgr:RecoverSpecialJumpTips()
    end
    _G.GoldSauserMgr:ShowCommRewardPanel(RewardItemListVM, Title, HideCallback)
end

--- 逻辑代码END

return GoldGameNewBase
