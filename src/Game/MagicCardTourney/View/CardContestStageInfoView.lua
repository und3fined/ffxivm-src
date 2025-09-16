---
--- Author: Administrator
--- DateTime: 2023-11-29 14:30
--- Description:右上方的大赛提醒/大赛匹配
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local ProtoRes = require("Protocol/ProtoRes")
local TourneyMgr = _G.MagicCardTourneyMgr
local EToggleButtonState = _G.UE.EToggleButtonState
local UIInteractiveUtil = require("Game/PWorld/UIInteractive/UIInteractiveUtil")

---@class CardContestStageInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExit UFButton
---@field BtnExit_1 UFButton
---@field BtnFold UToggleButton
---@field BtnGuide UFButton
---@field BtnStart UFButton
---@field BtnStartGrey UFButton
---@field BtnStartGrey_1 UFButton
---@field ImgDown UFImage
---@field ImgGuideLight UFImage
---@field ImgTime UFImage
---@field ImgUp UFImage
---@field PanelBtn_1 UFCanvasPanel
---@field PanelCountDown UFCanvasPanel
---@field PanelCup UFCanvasPanel
---@field PanelDescribe02 UFCanvasPanel
---@field PanelDescribe_1 UFCanvasPanel
---@field PanelEnroll UFCanvasPanel
---@field PanelHighlight UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelMark UFCanvasPanel
---@field TextBtn UFTextBlock
---@field TextBtn_1 UFTextBlock
---@field TextBtn_3 UFTextBlock
---@field TextCup UFTextBlock
---@field TextDescribe02 UFTextBlock
---@field TextDescribe03 UFTextBlock
---@field TextDescribe_1 UFTextBlock
---@field TextExpect UFTextBlock
---@field TextGameName UFTextBlock
---@field TextMark UFTextBlock
---@field TextMark02 UFTextBlock
---@field TextName UFTextBlock
---@field TextStage UFTextBlock
---@field TextStartGrey UFTextBlock
---@field TextTime UFTextBlock
---@field AnimGuideLightLoop UWidgetAnimation
---@field AnimHighlightIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardContestStageInfoView = LuaClass(UIView, true)

function CardContestStageInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExit = nil
	--self.BtnExit_1 = nil
	--self.BtnFold = nil
	--self.BtnGuide = nil
	--self.BtnStart = nil
	--self.BtnStartGrey = nil
	--self.BtnStartGrey_1 = nil
	--self.ImgDown = nil
	--self.ImgGuideLight = nil
	--self.ImgTime = nil
	--self.ImgUp = nil
	--self.PanelBtn_1 = nil
	--self.PanelCountDown = nil
	--self.PanelCup = nil
	--self.PanelDescribe02 = nil
	--self.PanelDescribe_1 = nil
	--self.PanelEnroll = nil
	--self.PanelHighlight = nil
	--self.PanelInfo = nil
	--self.PanelMark = nil
	--self.TextBtn = nil
	--self.TextBtn_1 = nil
	--self.TextBtn_3 = nil
	--self.TextCup = nil
	--self.TextDescribe02 = nil
	--self.TextDescribe03 = nil
	--self.TextDescribe_1 = nil
	--self.TextExpect = nil
	--self.TextGameName = nil
	--self.TextMark = nil
	--self.TextMark02 = nil
	--self.TextName = nil
	--self.TextStage = nil
	--self.TextStartGrey = nil
	--self.TextTime = nil
	--self.AnimGuideLightLoop = nil
	--self.AnimHighlightIn = nil
	--self.AnimIn = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardContestStageInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardContestStageInfoView:OnInit()
	self.StageInfoVisible = true
	UIUtil.SetIsVisible(self.BtnStartGrey, false)
	self.MultiBinders = {
		{
			ViewModel = TourneyVM,
			Binders = {
				--对局室外
				{ "StageInfoScoreText", UIBinderSetText.New(self, self.TextCup) },--积分
				{ "StageAndRoundText", UIBinderSetText.New(self, self.TextMark) },--阶段与回合数
				{ "StageInfoVisible", UIBinderSetIsVisible.New(self, self.TextMark) },--对局室外阶段
				{ "TourneyFullName", UIBinderSetText.New(self, self.TextGameName) },--全名
				{ "TipText", UIBinderSetText.New(self, self.TextDescribe_1) },--提醒
				--对局室内
				{ "RuleText", UIBinderSetText.New(self, self.TextDescribe02) },--规则 
				{ "RuleTextVisible", UIBinderSetIsVisible.New(self, self.TextDescribe02) }, 
				{ "TipText", UIBinderSetText.New(self, self.TextDescribe03) },--提醒
				{ "RuleTextVisible", UIBinderSetIsVisible.New(self, self.TextDescribe03, true) }, 
				{ "StageInfoScoreText", UIBinderSetText.New(self, self.TextMark02) },--积分
				{ "StageAndRoundText", UIBinderSetText.New(self, self.TextStage) },--阶段与回合数
				{ "StageInfoVisible", UIBinderSetIsVisible.New(self, self.TextStage) },
				{ "ExitVisible", UIBinderSetIsVisible.New(self, self.BtnExit_1, false, true) },--退出按钮
			}
		},
		{
			ViewModel = TourneyVM.StageInfoVM,
			Binders = {
				{ "IsSignUp", UIBinderSetIsVisible.New(self, self.PanelMark) },
				{ "ExpectText", UIBinderSetText.New(self, self.TextExpect) },
				{ "MatchBtnText", UIBinderSetText.New(self, self.TextBtn) },
				{ "MatchBtnText", UIBinderSetText.New(self, self.TextBtn_1) },
				{ "StartBtnVisible", UIBinderSetIsVisible.New(self, self.BtnStart, false, true) },
				{ "GuideBtnVisible", UIBinderSetIsVisible.New(self, self.BtnGuide, false, true) },
				{ "CheckState", UIBinderValueChangedCallback.New(self, nil, self.OnCheckStateChange) },
				{ "PanelEnrollVisible", UIBinderValueChangedCallback.New(self, nil, self.OnPanelEnrollVisibleChange) },
				{ "PanelInfoVisible", UIBinderValueChangedCallback.New(self, nil, self.OnPanelInfoVisibleChange) },
				{ "IsStartMatch", UIBinderValueChangedCallback.New(self, nil, self.OnIsStartMatchChange) },
				{ "StartBtnGreyVisible", UIBinderSetIsVisible.New(self, self.BtnStartGrey, false, true) },
			}
		},
	}
end

function CardContestStageInfoView:OnDestroy()

end

function CardContestStageInfoView:SetLSTR()
	self.TextBtn_3:SetText(TourneyDefine.EnterMatchRoomText)
	self.TextName:SetText(TourneyDefine.Title)
end

function CardContestStageInfoView:OnShow()
	self:SetLSTR()
	self:PlayAnimation(self.AnimGuideLightLoop, 0, 0)
	UIUtil.SetIsVisible(self.PanelCountDown, false)
	UIUtil.SetIsVisible(self.TextStartGrey, false)
	local IsShowStartOutSide = TourneyMgr:IsSignUpTourney() and TourneyMgr:IsTourneyActive()
	UIUtil.SetIsVisible(self.PanelBtn_1, IsShowStartOutSide)
	UIUtil.ImageSetBrushResourceObject()
end

---@type 匹配新手指引
function CardContestStageInfoView:CheckMatchTutorial()
	if not TourneyMgr:GetIsInTourneyRomm() then
		return
	end

	if not TourneyMgr:IsTourneyActive() then
		return
	end

	if not TourneyMgr:IsSignUpTourney() then
		return
	end

	if TourneyVM.CurStageIndex > 1 or TourneyVM.CurBattleCount > 0 then
		return
	end

	if TourneyVM.CurEffectInfo == nil then
		return
	end

	local function ShowMatchCheckRecptTutorial(Params)
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
		EventParams.Param1 = TutorialDefine.GameplayType.MagicCard
		EventParams.Param2 = TutorialDefine.GamePlayStage.MagicCardMatch
		_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
	end
	local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowMatchCheckRecptTutorial, Params = {}}
	_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig) --玩法节点
end

function CardContestStageInfoView:OnHide()

end

function CardContestStageInfoView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnFold, self.OnBtnFoldStateChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnMatchClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStartGrey, self.OnBtnMatchClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGuide, self.OnBtnGuidelClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnExit_1, self.OnBtnExitClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStartGrey_1, self.OnBtnEnterClicked)
end

function CardContestStageInfoView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MagicCardTourneyEffectSelected, self.OnEffectSelected)
end

function CardContestStageInfoView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

function CardContestStageInfoView:OnBtnFoldStateChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	MainPanelVM:SetFunctionVisible(IsChecked, MainPanelConfig.TopRightInfoType.MagicCardTourneyInfo)
	if TourneyVM and TourneyVM.StageInfoVM then
		TourneyVM.StageInfoVM:OnFold(IsChecked)
	end
end

function CardContestStageInfoView:OnCheckStateChange(NewState)
	local IsChecked = UIUtil.IsToggleButtonChecked(NewState)
	self.BtnFold:SetChecked(IsChecked)
end

function CardContestStageInfoView:OnPanelEnrollVisibleChange(IsVisible)
	UIUtil.SetIsVisible(self.PanelEnroll, IsVisible)
	if IsVisible then
		self:PlayAnimation(self.AnimUnfold)
	end
end

function CardContestStageInfoView:OnPanelInfoVisibleChange(IsVisible)
	UIUtil.SetIsVisible(self.PanelInfo, IsVisible)
	if IsVisible then
		self:PlayAnimation(self.AnimUnfold)
	end
end

function CardContestStageInfoView:OnIsStartMatchChange(IsStartMatch)
	UIUtil.SetIsVisible(self.TextExpect, IsStartMatch)
	UIUtil.SetIsVisible(self.PanelHighlight, not IsStartMatch)
	if not IsStartMatch then
		self:PlayAnimation(self.AnimHighlightIn)
	end
end

-- 点击匹配
function CardContestStageInfoView:OnBtnMatchClicked()
	TourneyMgr:OnStartMatch()
end

-- 点击比赛详情
function CardContestStageInfoView:OnBtnGuidelClicked()
	self:StopAnimation(self.AnimGuideLightLoop)
	TourneyMgr:ShowTourneyDetailView()
end

--退出对局室
function CardContestStageInfoView:OnBtnExitClicked()
	TourneyMgr:ReqExitMatchRoom()
end

--进入对局室
function CardContestStageInfoView:OnBtnEnterClicked()
	TourneyMgr:ReqEnterMatchRoom()
end

--阶段效果选择完成
function CardContestStageInfoView:OnEffectSelected()
	self:CheckMatchTutorial()
end

return CardContestStageInfoView