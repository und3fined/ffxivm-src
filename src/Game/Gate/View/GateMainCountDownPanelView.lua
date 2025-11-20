---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-03-19 17:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local TimeUtil = require("Utils/TimeUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoRes = require("Protocol/ProtoRes")

local GoldSauserEntertainState = ProtoCS.GoldSauserEntertainState
local PlayerState = ProtoCS.GoldSauserPlayer
local LSTR = _G.LSTR

---@class GateMainCountDownPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonShowTips UFButton
---@field PanelTips UFCanvasPanel
---@field TextContent UFTextBlock
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateMainCountDownPanelView = LuaClass(UIView, true)

function GateMainCountDownPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ButtonShowTips = nil
    --self.PanelTips = nil
    --self.TextContent = nil
    --self.TextTips = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.bShowTips = false
end

function GateMainCountDownPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateMainCountDownPanelView:OnInit()
    UIUtil.SetIsVisible(self.TextContent, false)

    self.UIAdapterCountDown = UIAdapterCountDown.CreateAdapter(
        self, self.TextContent, "mm:ss", nil, self.OnTimeOverCallback, nil, nil
    )
end

function GateMainCountDownPanelView:OnTimeOverCallback()
    self:UpdateByGoldSauserState()
end

function GateMainCountDownPanelView:OnDestroy()
end

function GateMainCountDownPanelView:OnShow()
    UIUtil.SetIsVisible(self.PanelTips, false)
    self:UpdateByGoldSauserState()
end

function GateMainCountDownPanelView:OnHide()
end

function GateMainCountDownPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ButtonShowTips, self.OnClickButtonShowTips)
end

function GateMainCountDownPanelView:OnClickButtonShowTips()
    self.bShowTips = not self.bShowTips

    self:OnTipsVisibleChanged()
end

function GateMainCountDownPanelView:OnTipsVisibleChanged()
    if (self.bShowTips) then
        UIUtil.SetIsVisible(self.PanelTips, true)
        self:PlayAnimation(self.AnimPanelTipsIn)
    else
        self:PlayAnimation(self.AnimPanelTipsOut)
    end
end

function GateMainCountDownPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
    if (self.bShowTips == nil or self.bShowTips == false) then
        return
    end
    local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
    if not UIUtil.IsUnderLocation(self.PanelTips, MousePosition) then
        self.bShowTips = false
        self:OnTipsVisibleChanged()
    end
end

function GateMainCountDownPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
    self:RegisterGameEvent(EventID.GoldSauserStateUpdate, self.OnGoldSauserStateUpdate)
end

function GateMainCountDownPanelView:OnGoldSauserStateUpdate()
    self:UpdateByGoldSauserState()
end

function GateMainCountDownPanelView:UpdateByGoldSauserState()
    if (_G.GoldSauserMgr.Entertain == nil or _G.GoldSauserMgr.Player == nil) then
        self.UIAdapterCountDown:ManuallyStop()
        UIUtil.SetIsVisible(self.TextContent, true)
        self.TextContent:SetText(LSTR(1270036))
        local CurGameName = ""
        local FormatStr = LSTR(1270035)
        self.TextTips:SetText(string.format(FormatStr, CurGameName))

        -- 取消特效
        self:PlayAnimation(self.AnimBoxEFFOut)
        _G.FLOG_WARNING("当前金碟状态还未下发，使用默认状态")
        return
    end

    local StateValue = _G.GoldSauserMgr.Entertain.State
    local CurPlayerState = _G.GoldSauserMgr.Player

    local bEnd = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_End
    local bEarlyEnd = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_EarlyEnd
    local bPlayerEnd = CurPlayerState == PlayerState.GoldSauserPlayer_End

    if (bEnd or bEarlyEnd or bPlayerEnd) then
        self:ShowNextGame()
        return
    end

    local GameID = _G.GoldSauserMgr.Entertain.ID
    local EntertainGameID = ProtoRes.Game.GameID
    local bSharpeKnifeOrSpray = GameID == EntertainGameID.GameIDAnyWayWindBlows or GameID == EntertainGameID.GameIDSliceIsRight
    local bInProgress = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_InProgress
    local bInSignUp = StateValue == GoldSauserEntertainState.GoldSauserEntertainState_SignUp

    -- 这里要区分一下，因为服务器没法在陆行鸟广场获取金碟游乐场的机遇临门数据，需要根据时间来做一下判断
    if (bSharpeKnifeOrSpray) then
        -- 这里，先判断一下，是否已经过了报名时间，如果过了，报名时间，那么认为已经结束失败，显示下一个
        local _SignUpRemainTime = _G.GoldSauserMgr:GetRemainSignUpTime() * 0.001
        if (_SignUpRemainTime > 0) then
            self:ShowInProgress(StateValue)
            self:RegisterTimer(
                function()
                    local bPlayerSignup = CurPlayerState == PlayerState.GoldSauserEntertainState_SignUp
                    if (not bPlayerSignup) then
                        self:ShowNextGame()
                    else
                        if (bInProgress or bInSignUp) then
                            self:ShowInProgress(StateValue)
                        end
                    end
                end,
                _SignUpRemainTime,
                0,
                1
            )
        else
            local bPlayerSignup = CurPlayerState == PlayerState.GoldSauserEntertainState_SignUp
            if (not bPlayerSignup) then
                self:ShowNextGame()
            else
                if (bInProgress or bInSignUp) then
                    self:ShowInProgress(StateValue)
                    return
                end
            end
        end
        return
    else
        if (bInProgress or bInSignUp) then
            self:ShowInProgress(StateValue)
            return
        end
    end

    do
        self.UIAdapterCountDown:ManuallyStop()
        UIUtil.SetIsVisible(self.TextContent, true)
        self.TextContent:SetText(LSTR(1270036))
        local CurGameName = _G.GoldSauserMgr:GetCurGameName() or ""
        local FormatStr = LSTR(1270035)
        self.TextTips:SetText(string.format(FormatStr, CurGameName))

        -- 取消特效
        self:PlayAnimation(self.AnimBoxEFFOut)
    end

    _G.FLOG_ERROR("当前状态错误，将使用默认显示。请检，状态是：%s", StateValue)
end

function GateMainCountDownPanelView:ShowInProgress(InGameState)
    local bInSignUp = InGameState == GoldSauserEntertainState.GoldSauserEntertainState_SignUp
    -- 如果正在进行中，那么不显示时间，并且点击显示的文字是机遇临门进行中
    self.UIAdapterCountDown:ManuallyStop()
    UIUtil.SetIsVisible(self.TextContent, true)
    self.TextContent:SetText(LSTR(1270036))
    local CurGameName = _G.GoldSauserMgr:GetCurGameName() or ""
    local FormatStr = LSTR(1270035)
    self.TextTips:SetText(string.format(FormatStr, CurGameName))
    if (bInSignUp) then
        -- 这里播放呼吸特效
        self:PlayAnimation(self.AnimBoxEFFIn)
    else
        -- 这里隐藏呼吸特效
        self:PlayAnimation(self.AnimBoxEFFOut)
    end
end

function GateMainCountDownPanelView:ShowNextGame()
    -- 这里是游戏状态结束了，或者玩家玩完了，那么进入倒计时显示
    local NextGameName = _G.GoldSauserMgr:GetNextActivityName(true) or ""
    local FormatStr = LSTR(1270034)
    self.TextTips:SetText(string.format(FormatStr, NextGameName))
    UIUtil.SetIsVisible(self.TextContent, true)
    local EndTimeMS = self:GetEndTimeMS()
    self.UIAdapterCountDown:Start(EndTimeMS, 1, true, false)
    -- 这里隐藏呼吸特效
    self:PlayAnimation(self.AnimBoxEFFOut)
end

function GateMainCountDownPanelView:GetEndTimeMS()
    local NeedMin = 0
    local CurMin = tonumber(TimeUtil.GetServerTimeFormat("%M"))
    local CurHour = tonumber(TimeUtil.GetServerTimeFormat("%H"))
    local CurYear = tonumber(TimeUtil.GetServerTimeFormat("%Y"))
    local CurMonth = tonumber(TimeUtil.GetServerTimeFormat("%m"))
    local CurDay = tonumber(TimeUtil.GetServerTimeFormat("%d"))
    if CurMin >= 0 and CurMin < 20 then
        NeedMin = 0
    elseif CurMin >= 20 and CurMin < 40 then
        NeedMin = 20
    elseif CurMin >= 40 and CurMin < 60 then
        NeedMin = 40
    end
    NeedMin = NeedMin + 20
    local Time = os.time({year = CurYear, month = CurMonth, day = CurDay, hour = CurHour, min = NeedMin, sec = 0})
    return Time
end

function GateMainCountDownPanelView:OnRegisterBinder()
    if (self.Binders == nil) then
        self.Binders = {
            {"MiniMapPanelVisible", UIBinderValueChangedCallback.New(self, nil, self.OnMiniMapPanelVisibleChanged)}
        }
    end

    self:RegisterBinders(MainPanelVM, self.Binders)
end

function GateMainCountDownPanelView:OnMiniMapPanelVisibleChanged(NewValue)
    if NewValue then
        self:PlayAnimation(self.AnimMiniMapIn)
    else
        self:PlayAnimation(self.AnimMiniMapOut)
    end
end

return GateMainCountDownPanelView
