--[[
Author: michaelyang_lightpaw
Date: 2024-11-01
Description: 虚景跳跳乐
--]]
local LuaClass = require("Core/LuaClass")
local GoldGameNewBase = require("Game/Gate/GoldGame/GoldGameNewBase")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local GateMainVM = require("Game/Gate/View/VM/GateMainVM")
local DialogCfg = require("TableCfg/DialogCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local LocalizationUtil = require("Utils/LocalizationUtil")

local EPlayer = ProtoCS.GoldSauserPlayer
local LSTR = _G.LSTR
local PWorldMgr = nil
local GoldSauserMgr = nil
local TeamMgr = nil

---@class GoldGameLeapOfFaith
local GoldGameLeapOfFaith = LuaClass(GoldGameNewBase)

-- --Ctor
function GoldGameLeapOfFaith:Ctor()
    PWorldMgr = _G.PWorldMgr
    GoldSauserMgr = _G.GoldSauserMgr
    TeamMgr = _G.TeamMgr
end

---@param InGameVM    Type GoldSauserVM
---@param InGameState Type ProtoCS.GoldSauserEntertainState
---@return  Type Description
function GoldGameLeapOfFaith:OnRefreshInfoWhenStateChange(InGameMgr, InGameVM, InGameState)
    if (not _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
        InGameMgr:SetToggleInfoPanel(false)
    end

    InGameVM.bShowPanelGet = true
    InGameVM.bActivityDescVisible = true
    InGameVM.bShowPanelCountdown = true
    InGameVM.CountDownTitleText = LSTR(1270004) -- 距离结束
    InGameVM.bShowBtnQuit = true
    local TotalCoin = _G.GoldSauserLeapOfFaithMgr:GetTotalCoin()
    InGameVM.GoldText = string.format(LSTR(1270002), TotalCoin) -- 当前获得的金碟币：%s
end

-- 玩家自己的游戏状态已经完成后，和NPC对话的ID，子类子类覆写
function GoldGameLeapOfFaith:OnGetFinishDialogID(InTableData)
    return InTableData.FinishLibID
end

function GoldGameLeapOfFaith:OnNeedCheckNotInTeam()
    return true
end

function GoldGameLeapOfFaith:RegisterSignUpTimeCountDown(InGameMgr, InGameVM)
end

function GoldGameLeapOfFaith:RegisterPlayTimeCountDown(InGameMgr, InGameVM)
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
function GoldGameLeapOfFaith:OnCanRegisterSignUpTimeCountDown()
    return _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()
end

--- @type 主动结束游戏
function GoldGameLeapOfFaith:EndGame(isSuccess)
    GoldSauserMgr:SendEndGameReq(GateMainVM:GetScore(), isSuccess)
end

-- 机遇临门奖励动画播放完成后
function GoldGameLeapOfFaith:AfterGateOpportunityRewardAnimEnd(Params)
    if (_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
        UIViewMgr:ShowView(UIViewID.GateLeapOfFaithResultPanel, Params)
        _G.GoldSauserLeapOfFaithMgr:ShowEndingPose()
    else
        local IsInPanelMiniGame = _G.GoldSauserMainPanelMgr:BlockByMiniGameInPanel(true) -- 小游戏过程中防止触发影响小游戏
        if IsInPanelMiniGame then
            return
        end

        local Title = LSTR(1270005)
        local HideCallback = function()
            _G.GoldSauserMgr:RecoverSpecialJumpTips()
        end
        _G.GoldSauserMgr:ShowCommRewardPanel(Params.RewardData, Title, HideCallback)
    end
end

function GoldGameLeapOfFaith:OnGetTimeCountDownFinishCallback()
    _G.GoldSauserLeapOfFaithMgr:SendEndGameReq()
end

function GoldGameLeapOfFaith:OnBtnExitClicked()
    -- 点击了退出按钮，先弹出确认
    _G.GoldSauserLeapOfFaithMgr:ShowLeaveConfirm()
end

function GoldGameLeapOfFaith:OnCustomCheck()
    if (_G.PWorldMatchMgr:IsMatching()) then
        -- 提示在匹配中，无法加入游戏
        MsgTipsUtil.ShowTipsByID(109512)
        return false
    end

    if (_G.MagicCardTourneyMgr:IsMatching()) then
        -- 提示正在匹配中，无法加入游戏
        MsgTipsUtil.ShowTipsByID(109512)
        return false
    end
    return true
end

return GoldGameLeapOfFaith
