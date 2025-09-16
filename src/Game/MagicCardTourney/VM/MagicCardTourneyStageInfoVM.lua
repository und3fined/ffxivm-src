--
-- Author: Carl
-- Date: 2023-10-08 16:57:14
-- Description:右上方的大赛信息栏VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EMatchState = MagicCardTourneyDefine.EMatchState
local EToggleStage = _G.UE.EToggleButtonState
-- _G.UE.EToggleButtonState.Checked/Unchecked

---@class MagicCardTourneyStageInfoVM : UIViewModel


---@field PanelEnrollVisible boolean @大赛提示显示
---@field PanelInfoVisible boolean @大赛信息显示
------进入对局室后显示内容
---@field RuleText string @当前规则说明
---@field MatchBtnText string @匹配按钮文本
---
------进入对局室前提示信息

---
local MagicCardTourneyStageInfoVM = LuaClass(UIViewModel)

function MagicCardTourneyStageInfoVM:Ctor()
    self.PanelEnrollVisible = true
    self.PanelInfoVisible = false
    self.IsStartMatch = false
    self.StartBtnVisible = false
    self.StartBtnGreyVisible = false
    self.GuideBtnVisible = false
    self.EcpectsTimeVisible = false
    self.ExpectText = ""
    self.CheckState = EToggleStage.Unchecked
    self.MatchBtnText = MagicCardTourneyDefine.MatchText
    self.MatchState = EMatchState.Default
    self.CanMatch = false
    self.IsSignUp = false
    self.IsActive = false
end

function MagicCardTourneyStageInfoVM:OnTourneyInfoChanged(TourneyInfo)
    if TourneyInfo == nil then
        return
    end
    self.IsSignUp = TourneyInfo.IsSignUp
    self.IsActive = TourneyInfo.IsActive
    self.CanMatch = self.IsActive and self.IsSignUp and self.MatchState ~= EMatchState.EnterCD
    self.StartBtnVisible = self.CanMatch
    self.StartBtnGreyVisible = self.MatchState == EMatchState.EnterCD
    self.GuideBtnVisible = self.StartBtnVisible or self.StartBtnGreyVisible

    local ExpectTime = TourneyVMUtils.GetExpectsTime()
    local LocalExpectText = LocalizationUtil.GetTimerForHighPrecision(ExpectTime) --计时本地化
    self.ExpectText = string.format(MagicCardTourneyDefine.ExpectTimeText, LocalExpectText) 
    local MaxBattleCount = TourneyVMUtils.GetMaxBattleCount()
    local CurBattleCount = TourneyInfo.BattleCount
    if self.IsSignUp and CurBattleCount >= MaxBattleCount then
        self:UpdateMatchTextByState(EMatchState.Finished)
    elseif self.MatchState == EMatchState.Finished then
        self:UpdateMatchTextByState(EMatchState.Default)
    end
end

function MagicCardTourneyStageInfoVM:OnStartMatch()
    self.IsStartMatch = true
end

function MagicCardTourneyStageInfoVM:OnCancelMatch()
    self.IsStartMatch = false
end

function MagicCardTourneyStageInfoVM:IsMatching()
    return self.MatchState == EMatchState.Matching
end

function MagicCardTourneyStageInfoVM:OnCancelEnter(IsManual)
    if IsManual then
        self.StartBtnGreyVisible = true
        self.StartBtnVisible = false
        CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatFantasyCard, false)
    else
        self:UpdateMatchTextByState(EMatchState.Default) -- 因对方原因被动取消，无惩罚
    end
end

function MagicCardTourneyStageInfoVM:OnFinishedTourney()
    self.StartBtnGreyVisible = false
    self.StartBtnVisible = false
end

-- 恢复匹配按钮默认状态
function MagicCardTourneyStageInfoVM:ResetMatchBtnToDefault()
    self.IsStartMatch = false
    self.MatchBtnText = MagicCardTourneyDefine.MatchText
    self.StartBtnGreyVisible = false
    self.StartBtnVisible = self.CanMatch
end

function MagicCardTourneyStageInfoVM:UpdateMatchTextByState(MatchState, Value)
    self.MatchState = MatchState
    self.CanMatch = self.IsActive and self.IsSignUp and self.MatchState ~= EMatchState.EnterCD
	CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatFantasyCard, MatchState == EMatchState.Matching
		or MatchState == EMatchState.Confirm)
    if MatchState == EMatchState.Default then
        self:ResetMatchBtnToDefault()
    elseif MatchState == EMatchState.Matching then
        local LocalTimeCount = LocalizationUtil.GetTimerForHighPrecision(Value) --计时本地化
        self.MatchBtnText = string.format(MagicCardTourneyDefine.MatchingText, LocalTimeCount)
    elseif MatchState == EMatchState.EnterCD then
        self.MatchBtnText = string.format(MagicCardTourneyDefine.CanNotMatchText, Value)
        if Value <= 0 then
            self:ResetMatchBtnToDefault()
        end
    elseif MatchState == EMatchState.Finished then
        self.StartBtnVisible = false
        self.StartBtnGreyVisible = false
        self.MatchBtnText = MagicCardTourneyDefine.FinishedText
    end
end

function MagicCardTourneyStageInfoVM:OnEnterMatchRoom()
    self.PanelEnrollVisible = false
    self.PanelInfoVisible = true
    self.LastEnrollVisible = self.PanelEnrollVisible
    self.LastInfoVisible = self.PanelInfoVisible
end

function MagicCardTourneyStageInfoVM:OnExitMatchRoom()
    self.PanelEnrollVisible = true
    self.PanelInfoVisible = false
    self.LastEnrollVisible = self.PanelEnrollVisible
    self.LastInfoVisible = self.PanelInfoVisible
end

function MagicCardTourneyStageInfoVM:OnCheckStageChanged(IsShow)
    if IsShow then
        self.CheckState = EToggleStage.Unchecked
    else
        self.CheckState = EToggleStage.Checked
    end
end

function MagicCardTourneyStageInfoVM:OnFold(IsFold)
    if IsFold then
        -- 先保存收起之前的状态
        self.LastEnrollVisible = self.PanelEnrollVisible
        self.LastInfoVisible = self.PanelInfoVisible
        self.PanelEnrollVisible = false
        self.PanelInfoVisible = false
    else
        self.PanelEnrollVisible = self.LastEnrollVisible
        self.PanelInfoVisible = self.LastInfoVisible
    end
end

function MagicCardTourneyStageInfoVM:SetMatchState(NewMatchState)
    self.MatchState = NewMatchState
    self.CanMatch = self.IsActive and self.IsSignUp and self.MatchState ~= EMatchState.EnterCD
end

function MagicCardTourneyStageInfoVM:GetMatchState()
    return self.MatchState
end

return MagicCardTourneyStageInfoVM