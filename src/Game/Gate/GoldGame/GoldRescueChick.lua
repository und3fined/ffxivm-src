-- Author: Leo
-- Date: 2023-10-18 16:54
-- Description:小雏鸟营救小游戏
--

local LuaClass = require("Core/LuaClass")
local GoldGameNewBase = require("Game/Gate/GoldGame/GoldGameNewBase")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local GoldSauseGateCfg = require("TableCfg/GoldSauserGateCfg")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local DialogCfg = require("TableCfg/DialogCfg")
local ActorUtil = require("Utils/ActorUtil")
local CliffHangerCfg = require("TableCfg/CliffHangerCfg")
local ClientVisionMgr = require("Game/Actor/ClientVisionMgr")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoCommon = require("Protocol/ProtoCommon")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")

local EntertainGameID = ProtoRes.Game.GameID

local UAudioMgr = nil
local LSTR = _G.LSTR
local TimerMgr = _G.TimerMgr
local GoldSauserMgr = nil
local BirdActionTimelineID = 4 -- 交互完成后，小鸟播放的动作
local BirdActionWaitTime = 1.5 -- 播放动作后等待时间

local LeaveMinHeightOne = 540 -- 科瑞尔山的最低高度
local EnterMinHeightOne = 640 -- 科瑞尔山的判断的最高高度

local EnterMinHeightTwo = 1200 -- 圆形广场的最低高度
local LeaveMinHeightTwo = 1200 -- 圆形广场

local LeaveMinHeight = 0 -- 离开弹窗的检测最低高度
local EnterMinHeight = 0 -- 进入检测的最低高度

---@class GoldRescueChick
local GoldRescueChick = LuaClass(GoldGameNewBase)

-- --Ctor
function GoldRescueChick:Ctor()
    GoldSauserMgr = require("Game/Gate/GoldSauserMgr")

    UAudioMgr = _G.UE.UAudioMgr.Get()
    self.HeightCheckActive = false
    self.OnTimerID = 0
end

function GoldRescueChick:Init(InGameMgr)
    self.GameCfg = CliffHangerCfg:FindCfgByKey(InGameMgr:GoldRescueChickGetStage())
end

function GoldRescueChick:OnRefreshInfoWhenStateChange(InGameMgr, InGameVM, InGameState)
    InGameVM.CountDownTitleText = LSTR(1270004) -- 距离结束
    -- 这里去重新设置一下内容和描述
    local TargetKey = InGameMgr:GoldRescueChickGetStage()

    if nil ~= self.GameCfg then
        InGameVM.ActivityDesc = self.GameCfg.RescueChickenGameDesc
    end
    self:JudgeForNeedCheckHeight()

    if (not self.IsPlayChickenAnim) then
        local bPlayerEnd = InGameMgr.Player ~= nil and InGameMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End
        if (bPlayerEnd) then
            local ChickenEntityID = GoldSauserMgr.ChickenEntityID
            if (ChickenEntityID ~= nil) then
                ClientVisionMgr:DestoryClientActor(ChickenEntityID)
            end
        end
    end

    if (InGameMgr.ChickenEntityID == nil or InGameMgr.ChickenEntityID == 0) then
        -- 这里有可能被下发的通知清理掉了，需要重新在确认一下看看
        for Key, Value in pairs(GoldSauserDefine.RescueChickenResID) do
            local TargetActor = ActorUtil.GetActorByResID(Key)
            if (TargetActor ~= nil) then
                local AttrComp = TargetActor:GetAttributeComponent()
                if (AttrComp ~= nil) then
                    InGameMgr:InternalSetChickenEntityID(AttrComp.EntityID)
                    break
                end
            end
        end
    end
    InGameMgr:UpdateChickenIcon()
end

function GoldRescueChick:OnGameStateToEnd(InGameMgr, InGameVM)
    local ChickenEntityID = GoldSauserMgr.ChickenEntityID
    if (ChickenEntityID ~= nil) then
        local bPlayerEndGame = InGameMgr.Player ~= nil and InGameMgr.Player == ProtoCS.GoldSauserPlayer.GoldSauserPlayer_End
        if (bPlayerEndGame) then
            ClientVisionMgr:DestoryClientActor(ChickenEntityID)
        end
    end
    self:StopTickForHeightCheck()
end

--- @type 当游戏结束时
function GoldRescueChick:OnPlayerGameEnd(InGameMgr, InGameVM, InMsgData)
    self:OnInteractBirdFinish()
end

-- 小雏鸟营救小游戏结束后的表现
function GoldRescueChick:OnInteractBirdFinish()
    self:StopTickForHeightCheck()
    local ChickenEntityID = GoldSauserMgr.ChickenEntityID
    local AnimComp = ActorUtil.GetActorAnimationComponent(ChickenEntityID)
    if (AnimComp ~= nil) then
        self.IsPlayChickenAnim = true
        AnimComp:PlayActionTimeline(BirdActionTimelineID)
        _G.TimerMgr:AddTimer(
            self,
            function()
                self.IsPlayChickenAnim = false
                ClientVisionMgr:DestoryClientActor(ChickenEntityID)
            end,
            BirdActionWaitTime,
            0,
            1
        )
    else
        _G.FLOG_ERROR("无法获取小雏鸟对象的组件 ，EntityID 是 : " .. ChickenEntityID)
    end
end

-- 玩家自己的游戏状态已经完成后，和NPC对话的ID
function GoldRescueChick:OnGetFinishDialogID(InTableData)
    return InTableData.FinishLibID
end

-- 子类用
function GoldRescueChick:OnNetPlayerSignUp(InGameMgr, InGameVM)
    InGameMgr:UpdateChickenIcon()
end

--- @type 根据游戏当前状态返回对话的回调
function GoldRescueChick:GetDialogCallBack(InGameMgr, DialogID)
    local SignUpEndTime = InGameMgr.SignUpEndTime

    local GameCfg = self.GameCfg
    if GameCfg == nil then
        _G.FLOG_ERROR("GoldRescueChick:GetDialogCallBack 出错 ， GameCfg is nil")
        return
    end

    local ConfirmCallBack = nil
    local CurGameRound = _G.GoldSauserMgr.Round
    local function SignUp()
        InGameMgr:SendSignUpGame(CurGameRound) -- 报名
    end
    local function Teleport()
        InGameMgr:SendTeleToStageReq() -- 传送回舞台
    end

    local Content = GameCfg.SignUpTipContent
    if (DialogID == GameCfg.OnSignUpLibID) then
        ConfirmCallBack = SignUp
    elseif (DialogID == GameCfg.AlreadySignUpLibID) then
        -- 重复挑战的
        ConfirmCallBack = Teleport
        Content = GameCfg.RepeatChallengeCotent
    end

    local Title = ProtoEnumAlias.GetAlias(ProtoCommon.ENTERTAIN_ID, ProtoCommon.ENTERTAIN_ID.ENTERTAIN_ID_CLIFFHANGER)

    local function CallBack()
        InGameMgr:ShowChallengeTip(Content, ConfirmCallBack, Title, LSTR(10033), LSTR(10034))
    end
    return CallBack
end

function GoldRescueChick:OnRegisterSignUpTimeCountDown()
    self.OnTimerID = TimerMgr:AddTimer(self, self.TickForHeightCheck, 0, 0.5, 0)
end

function GoldRescueChick:OnCancelAllTimer()
    if (self.OnTimerID ~= nil and self.OnTimerID > 0) then
        TimerMgr:CancelTimer(self.OnTimerID)
        self.OnTimerID = 0
    end
end

-- 游戏期间的高度检测，需要报名后才开启
function GoldRescueChick:TickForHeightCheck()
    if (self.HeightCheckActive == false) then
        return
    end

    if (LeaveMinHeight == 0) then
        return
    end

    local Major = MajorUtil.GetMajor()
    if (Major ~= nil) then
        local MajorLocation = Major:FGetActorLocation()

        if (MajorLocation.Z < LeaveMinHeight and not Major.CharacterMovement:IsFalling()) then
            self.HeightCheckActive = false

            -- 这里弹出提示
            self:ShowConfirm()
        end
    end
end

function GoldRescueChick:StopTickForHeightCheck()
    self.HeightCheckActive = false
end

function GoldRescueChick:JudgeForNeedCheckHeight()
    if (_G.GoldSauserMgr == nil or _G.GoldSauserMgr.Entertain == nil) then
        return
    end

    -- 没有报名不检测
    if (_G.GoldSauserMgr.Player ~= ProtoCS.GoldSauserPlayer.GoldSauserPlayer_SignUp) then
        return
    end

    -- 没有进入区域不检测
    if (_G.GoldSauserMgr.EnterRescueChickenArea == false) then
        return
    end

    -- 这里需要做判断，下线后重新上线
    if (_G.GoldSauserMgr:GoldRescueChickGetStage() == 1) then
        LeaveMinHeight = LeaveMinHeightOne
        EnterMinHeight = EnterMinHeightOne
    else
        LeaveMinHeight = LeaveMinHeightTwo
        EnterMinHeight = EnterMinHeightTwo
    end

    local Major = MajorUtil.GetMajor()
    if (Major == nil) then
        _G.FLOG_ERROR("无法获取主角，请检查")
        return
    end

    local MajorLocation = Major:FGetActorLocation()
    if (MajorLocation.Z < EnterMinHeight) then
        return
    end

    self.HeightCheckActive = true
end

function GoldRescueChick:ShowInfoAfterSignup(InGameMgr)
    self:JudgeForNeedCheckHeight()

    if (InGameMgr.HasPlaySignUp == false and InGameMgr.bHasPlayerSignUp == true) then
        InGameMgr.HasPlaySignUp = true

        InGameMgr:ShowGoldSauserOpportunityForBegin(
            function()
                do
                    -- 先解锁小雏鸟系统玩法
                    local function ShowGoldSauserCommTutorial(Params)
                        local EventParams = _G.EventMgr:GetEventParams()
                        EventParams.Type = TutorialDefine.TutorialConditionType.UnlockGameplay
                        --新手引导触发类型
                        EventParams.Param1 = TutorialDefine.GameplayType.GoldSauser
                        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
                    end

                    local TutorialConfig = {
                        Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
                        Callback = ShowGoldSauserCommTutorial,
                        Params = {}
                    }
                    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
                    -- END
                end
                
                do
                    -- 小雏鸟单独的玩法节点
                    local function ShowGoldSauserStageTutorial(Params)
                        local EventParams = _G.EventMgr:GetEventParams()
                        EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition
                        --新手引导触发类型
                        EventParams.Param1 = TutorialDefine.GameplayType.GoldSauser
                        EventParams.Param2 = TutorialDefine.GamePlayStage.GoldSauserStart
                        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
                    end

                    local TutorialConfig = {
                        Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
                        Callback = ShowGoldSauserStageTutorial,
                        Params = {}
                    }
                    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
                    -- 小雏鸟结束
                end

                -- 机遇临门通用的新手引导
                _G.GoldSauserMgr:ShowOpportunityNewTutorial()
                -- 通用结束

                self:TryPlayBGM(InGameMgr)

                local RecordGameID = ProtoRes.Game.GameID.GameIDCliffhanger
                InGameMgr:ShowEnableSpecialJumpMsgBox(RecordGameID)
            end
        )
    else
        self:OnShowInfoAfterSignup(InGameMgr)
    end
end

function GoldRescueChick:ShowConfirm()
    local function ConfirmCallBack()
        -- 直接报名传送
        _G.GoldSauserMgr:SendTeleToStageReq()
    end

    local function CancelCallBack()
        -- 这里弹出提示
        MsgTipsUtil.ShowTips(LSTR(1270008)) -- 可以找到解说员重新开始挑战
    end

    local Params = {
        View = nil,
        Title = LSTR(1270009), -- 再次尝试
        Content = LSTR(1270010), --确认要再次尝试营救小雏鸟吗？
        ConfirmCallBack = ConfirmCallBack,
        CancelCallBack = CancelCallBack,
        ConfirmParams = nil,
        CancelParams = nil,
        TextYes = LSTR(10033),
        TextNo = LSTR(10034)
    }
    UIViewMgr:ShowView(UIViewID.PlayStyleCommWin, Params)
end

return GoldRescueChick
