---
--- Author: Administrator
--- DateTime: 2024-02-19 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetZOrder = require("Binder/UIBinderSetZOrder")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderSetOutlineColor = require("Binder/UIBinderSetOutlineColor")
local TimeUtil = require("Utils/TimeUtil")
local AudioUtil = require("Utils/AudioUtil")
local MonsterTossAudioDefine = require("Game/GoldSaucerMiniGame/MonsterToss/MonsterTossAudioDefine")
local MiniGameCuffAudioDefine = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuffAudioDefine")
local ObjectGCType = require("Define/ObjectGCType")

local EventID = _G.EventID
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local UE = _G.UE
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local ColorType = MiniGameClientConfig[MiniGameType.MonsterToss].ColorType
local ActionPath = MiniGameClientConfig[MiniGameType.MonsterToss].ActionPath
local ZOrderPriority = MiniGameClientConfig[MiniGameType.MonsterToss].ZOrder
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local DelayTime = GoldSaucerMiniGameDefine.DelayTime
local BasketballType = ProtoCS.BasketballType
local BasketballParamType = ProtoRes.Game.BasketballParamType

local DynaID = {Success = 1, Defeat = 3,}
local PointerAngle = {Min = -90, Max = 90, RightBorder = -86, LefeBorder = 86 }
local MaxAngle = 180
local ShootingTipsBPName = "GoldSaucerGame/MonsterToss/Item/GoldSaucer_MonsterTossShootingTipsItem_UIBP"

---@class GoldSaucerMonsterTossMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Award GoldSaucerGameCuffAwardItemView
---@field Ball1 GoldSaucerMonsterTossBallItemView
---@field Ball2 GoldSaucerMonsterTossBallItemView
---@field Ball3 GoldSaucerMonsterTossBallItemView
---@field Ball4 GoldSaucerMonsterTossBallItemView
---@field BallBox1 UScaleBox
---@field BallBox2 UScaleBox
---@field BallBox3 UScaleBox
---@field BallBox4 UScaleBox
---@field BottomPanel MainLBottomPanelView
---@field Btn1 CommBtnMView
---@field Btn2 CommBtnMView
---@field BtnShoot UFButton
---@field ChallengeBegins GoldSaucerCuffchallengeBeginsItemView
---@field ChallengeResults GoldSaucerMonsterTossChallengeResultsItemView
---@field CloseBtn CommonCloseBtnView
---@field Critical GoldSaucerGameCommCriticalItemView
---@field FCanvasPanel UFCanvasPanel
---@field GoldSaucer_MonsterTossMultiplePointsItem_UIBP1 GoldSaucerMonsterScoreboardMultiplierItemView
---@field HorizontalReward UFHorizontalBox
---@field IconGold UFImage
---@field ImgArrow_1 UFImage
---@field ImgPointerFocus UFImage
---@field ImgPointerNormal UFImage
---@field ImgShootDisable UFImage
---@field ImgTurntableColor1 URadialImage
---@field ImgTurntableColor2 URadialImage
---@field ImgTurntableColor3 URadialImage
---@field ImgTurntableColor4 URadialImage
---@field MainTeamPanel MainTeamPanelView
---@field MoneySlot CommMoneySlotView
---@field MultiplePoints GoldSaucerMonsterTossMultiplePointsItemView
---@field P_DX_TheFinerMiner_7 UUIParticleEmitter
---@field PanelAward UFCanvasPanel
---@field PanelChallengeFailurePrompt UFCanvasPanel
---@field PanelChallengeRecordList UFVerticalBox
---@field PanelCold UFCanvasPanel
---@field PanelGearCrack UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field PanelPointer UFCanvasPanel
---@field PanelResult UFCanvasPanel
---@field PanelTurntableCrack UFCanvasPanel
---@field PanelTurtableColor UFCanvasPanel
---@field ProgressBarDeco1 UFImage
---@field ProgressBarDeco2 UFImage
---@field ProgressBarDeco3 UFImage
---@field ProgressBarDeco4 UFImage
---@field ProgressBarDeco5 UFImage
---@field ProgressBarDeco6 UFImage
---@field ProgressBarDeco7 UFImage
---@field ProgressBarFull UProgressBar
---@field Score GoldSaucerGameCuffScoreItemView
---@field TableViewList UTableView
---@field TextAward UFTextBlock
---@field TextFraction UFTextBlock
---@field TextFraction1 UFTextBlock
---@field TextHighestScore UFTextBlock
---@field TextHint1 UFTextBlock
---@field TextNumberReward UFTextBlock
---@field TextQuantity_1 UFTextBlock
---@field TextScore UFTextBlock
---@field TextTime UFTextBlock
---@field TextTime1 UFTextBlock
---@field TextTime2 UFTextBlock
---@field TextTips UFTextBlock
---@field AnimBallBoom UWidgetAnimation
---@field AnimBtnShootLoop UWidgetAnimation
---@field AnimConsecutiveHits1 UWidgetAnimation
---@field AnimConsecutiveHits2 UWidgetAnimation
---@field AnimConsecutiveHits3 UWidgetAnimation
---@field AnimConsecutiveHitsStop UWidgetAnimation
---@field AnimDropBall UWidgetAnimation
---@field AnimGearLoop UWidgetAnimation
---@field AnimGearShakeLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimNextBall UWidgetAnimation
---@field AnimProgressBar UWidgetAnimation
---@field AnimRefreshHighestScore UWidgetAnimation
---@field AnimResult UWidgetAnimation
---@field AnimScoreMultiplierIn2 UWidgetAnimation
---@field AnimScoreMultiplierIn3 UWidgetAnimation
---@field AnimScoreMultiplierIn5 UWidgetAnimation
---@field AnimScoreShow UWidgetAnimation
---@field AnimShootRight UWidgetAnimation
---@field AnimShootWrong UWidgetAnimation
---@field AnimStart UWidgetAnimation
---@field AnimTips UWidgetAnimation
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimProgressBarStart float
---@field ValueAnimProgressBarEnd float
---@field ValueAnimGearLoopSpeed float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMonsterTossMainPanelView = LuaClass(UIView, true)

function GoldSaucerMonsterTossMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Award = nil
	--self.Ball1 = nil
	--self.Ball2 = nil
	--self.Ball3 = nil
	--self.Ball4 = nil
	--self.BallBox1 = nil
	--self.BallBox2 = nil
	--self.BallBox3 = nil
	--self.BallBox4 = nil
	--self.BottomPanel = nil
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.BtnShoot = nil
	--self.ChallengeBegins = nil
	--self.ChallengeResults = nil
	--self.CloseBtn = nil
	--self.Critical = nil
	--self.FCanvasPanel = nil
	--self.GoldSaucer_MonsterTossMultiplePointsItem_UIBP1 = nil
	--self.HorizontalReward = nil
	--self.IconGold = nil
	--self.ImgArrow_1 = nil
	--self.ImgPointerFocus = nil
	--self.ImgPointerNormal = nil
	--self.ImgShootDisable = nil
	--self.ImgTurntableColor1 = nil
	--self.ImgTurntableColor2 = nil
	--self.ImgTurntableColor3 = nil
	--self.ImgTurntableColor4 = nil
	--self.MainTeamPanel = nil
	--self.MoneySlot = nil
	--self.MultiplePoints = nil
	--self.P_DX_TheFinerMiner_7 = nil
	--self.PanelAward = nil
	--self.PanelChallengeFailurePrompt = nil
	--self.PanelChallengeRecordList = nil
	--self.PanelCold = nil
	--self.PanelGearCrack = nil
	--self.PanelNormal = nil
	--self.PanelPointer = nil
	--self.PanelResult = nil
	--self.PanelTurntableCrack = nil
	--self.PanelTurtableColor = nil
	--self.ProgressBarDeco1 = nil
	--self.ProgressBarDeco2 = nil
	--self.ProgressBarDeco3 = nil
	--self.ProgressBarDeco4 = nil
	--self.ProgressBarDeco5 = nil
	--self.ProgressBarDeco6 = nil
	--self.ProgressBarDeco7 = nil
	--self.ProgressBarFull = nil
	--self.Score = nil
	--self.TableViewList = nil
	--self.TextAward = nil
	--self.TextFraction = nil
	--self.TextFraction1 = nil
	--self.TextHighestScore = nil
	--self.TextHint1 = nil
	--self.TextNumberReward = nil
	--self.TextQuantity_1 = nil
	--self.TextScore = nil
	--self.TextTime = nil
	--self.TextTime1 = nil
	--self.TextTime2 = nil
	--self.TextTips = nil
	--self.AnimBallBoom = nil
	--self.AnimBtnShootLoop = nil
	--self.AnimConsecutiveHits1 = nil
	--self.AnimConsecutiveHits2 = nil
	--self.AnimConsecutiveHits3 = nil
	--self.AnimConsecutiveHitsStop = nil
	--self.AnimDropBall = nil
	--self.AnimGearLoop = nil
	--self.AnimGearShakeLoop = nil
	--self.AnimIn = nil
	--self.AnimNextBall = nil
	--self.AnimProgressBar = nil
	--self.AnimRefreshHighestScore = nil
	--self.AnimResult = nil
	--self.AnimScoreMultiplierIn2 = nil
	--self.AnimScoreMultiplierIn3 = nil
	--self.AnimScoreMultiplierIn5 = nil
	--self.AnimScoreShow = nil
	--self.AnimShootRight = nil
	--self.AnimShootWrong = nil
	--self.AnimStart = nil
	--self.AnimTips = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimProgressBarStart = nil
	--self.ValueAnimProgressBarEnd = nil
	--self.ValueAnimGearLoopSpeed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Award)
	self:AddSubView(self.Ball1)
	self:AddSubView(self.Ball2)
	self:AddSubView(self.Ball3)
	self:AddSubView(self.Ball4)
	self:AddSubView(self.BottomPanel)
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2)
	self:AddSubView(self.ChallengeBegins)
	self:AddSubView(self.ChallengeResults)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.Critical)
	self:AddSubView(self.GoldSaucer_MonsterTossMultiplePointsItem_UIBP1)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.MultiplePoints)
	self:AddSubView(self.Score)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMonsterTossMainPanelView:OnInit()
	-- self.EBasketBallState = EBallState.Noraml
	self.MainTeamPanel.nforBtn.HelpInfoID = 11041

	self.Binders = {
		{"PointerAngle", UIBinderSetRenderTransformAngle.New(self, self.PanelPointer)},

		{"bResultVisible", UIBinderSetIsVisible.New(self, self.PanelResult)}, --
		{"bNormalVisible", UIBinderSetIsVisible.New(self, self.PanelNormal)},
		{"bResultMoneyVisible", UIBinderSetIsVisible.New(self, self.MoneySlot)},
		{"bGameTipVisible", UIBinderSetIsVisible.New(self, self.HorizontalTitle)},
		-- {"bGameTipVisible", UIBinderSetIsVisible.New(self, self.FHorizontalBox_57)},

		{"bGameTipVisible", UIBinderSetIsVisible.New(self, self.MainTeamPanel.PanelCountdown)},
		{"bGameTipVisible", UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalGold)},
		{"bGameTipVisible", UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalObtain)},

		{"bMultipleTipVisible", UIBinderSetIsVisible.New(self, self.GoldSaucer_MonsterTossMultiplePointsItem_UIBP1)},
		{"MultipleTipText", UIBinderSetText.New(self, self.GoldSaucer_MonsterTossMultiplePointsItem_UIBP1.TextScore1)},

		-- {"ComboPercent", UIBinderSetPercent.New(self, self.ProgressBarFull)},
		{"bImgPointerFocusVisible", UIBinderSetIsVisible.New(self, self.ImgPointerFocus)},
		{"bAddScoreTextVisible", UIBinderSetIsVisible.New(self, self.Score)},
		{"AddScoreText", UIBinderSetText.New(self, self.Score.FTextBlock_44)},
		{"AddScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.Score.FTextBlock_44)},
		{"AddScoreOutLineColor", UIBinderSetOutlineColor.New(self, self.Score.FTextBlock_44)},
		{"AddScorePos", UIBinderCanvasSlotSetPosition.New(self, self.Score, true)},

		{"MonsterTossTimeText", UIBinderSetText.New(self, self.TextTime1)},
		{"TimeTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTime1)},
		{"bTenthsVisible", UIBinderSetIsVisible.New(self, self.TextTime2)},
		{"TenthsText", UIBinderSetText.New(self, self.TextTime2)},
		{"TimeTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTime2)},
		{"TotalTimeTextTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextTime)},

		{"MaxScore", UIBinderSetText.New(self, self.TextFraction)},
		{"MaxScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.TextFraction)},

		{"CurScore", UIBinderSetText.New(self, self.TextScore)},
		{"CurScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.TextScore)},

		{"PurpleProportOrder", UIBinderSetZOrder.New(self, self.ImgTurntableColor1)},
		{"BlueProportOrder", UIBinderSetZOrder.New(self, self.ImgTurntableColor2)},
		{"RedProportOrder", UIBinderSetZOrder.New(self, self.ImgTurntableColor3)},

		{"PurplePercent", UIBinderSetPercent.New(self, self.ImgTurntableColor1)},
		{"BluePercent", UIBinderSetPercent.New(self, self.ImgTurntableColor2)},
		{"RedPercent", UIBinderSetPercent.New(self, self.ImgTurntableColor3)},

        {"GameState", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameStateChanged)},
		{"bActBtnEnable", UIBinderSetIsVisible.New(self, self.BtnShoot, nil, true)},
		{"bActBtnEnable", UIBinderSetIsVisible.New(self, self.ImgShootDisable, true)},

		{"RewardGotEnd",  UIBinderSetText.New(self, self.TextNumberReward)},
		{"RewardGot",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber)},

		{"CriticalText",  UIBinderSetText.New(self, self.Critical.TextQuantity)},
		
	}
	self.ResultTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

	self.ResultBinders = {
		{"bSuccess", UIBinderSetIsVisible.New(self, self.ChallengeResults.ImgMonsterNormal)},
		{"bFail", UIBinderSetIsVisible.New(self, self.ChallengeResults.TextTimesup)},
		{"bSuccess", UIBinderSetIsVisible.New(self, self.ChallengeResults.TextSuccess)},
		{"bFail", UIBinderSetIsVisible.New(self, self.ChallengeResults.TextFail)},

		{"bIconGoldVisible", UIBinderSetIsVisible.New(self, self.IconGold)},
		{"TryAgainTip", UIBinderSetText.New(self, self.TextQuantity_1)}, 
		{"TryAgainTipColor", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity_1)}, 
		{"BtnText", UIBinderSetText.New(self, self.Btn2.TextContent)}, 

		{"bFail", UIBinderSetIsVisible.New(self, self.PanelChallengeFailurePrompt)},
		{"bSuccess", UIBinderSetIsVisible.New(self, self.PanelChallengeRecordList)},
		{"ResultVMList", UIBinderUpdateBindableList.New(self, self.ResultTableViewAdapter)},
		{"RewardGot", UIBinderSetTextFormatForMoney.New(self, self.Award.TextQuantity)},
		{"AwardIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Award.Comm96Slot.Icon)},

	}
end

function GoldSaucerMonsterTossMainPanelView:OnDestroy()

end

function GoldSaucerMonsterTossMainPanelView:OnShow()
	-- UIUtil.SetIsVisible(self.TextNumber1, true)
	self.IsHide = false
	self:HideRelateUI()
	self:ReInitGame()
	UIUtil.SetIsVisible(self.BottomPanel, false)

	self.TextHighestScore:SetText(LSTR(270045)) -- 最高分
	self.TextTime:SetText(LSTR(270046)) -- 时间
	self.TextFraction1:SetText(LSTR(270004)) -- 得分
	self.TextTips:SetText(LSTR(270048)) -- 看准颜色，投篮得分
	self.TextHint1:SetText(LSTR(270047)) -- 不要气馁，再挑战看看吧！
	self.TextAward:SetText(LSTR(250017)) -- 奖励
	self.Btn1.TextContent:SetText(LSTR(10036)) -- 离 开
	self.TextQuantity_1:SetText(1) -- 阿拉伯数字1
end

function GoldSaucerMonsterTossMainPanelView:ReInitGame()
	self.Btn2.Button:SetIsEnabled(true)
	self.Btn1.Button:SetIsEnabled(true)

	self.Award:StopAllAnimations()

	UIUtil.SetIsVisible(self.CloseBtn, true)

	UIUtil.SetIsVisible(self.Critical, false)

	--self.BottomPanel:SetButtonEmotionVisible(false)
	--self.BottomPanel:SetButtonPhotoVisible(false)
	self.MainTeamPanel:SwitchTab(4)
	self.MainTeamPanel:SetShowGameInfo()
	self.MainTeamPanel.TextGameName:SetText(LSTR(270001)) -- 怪物投篮 
	self.MainTeamPanel.TextGameName_1:SetText(LSTR(270053)) -- 当前奖励
	local IconGamePath = MiniGameClientConfig[MiniGameType.MonsterToss].IconGamePath
	UIUtil.ImageSetBrushFromAssetPath(self.MainTeamPanel.IconGame, IconGamePath)
	-- self.EBasketBallState = EBallState.Noraml
	self.bWaitBegin = true
	self:SetStartProValue(0)
	self:SetEndProValue(0)
	self.ProgressBarFull:SetPercent(0)
	self:UnRegisterAllTimer()
	self:PlayAnimation(self.AnimConsecutiveHitsStop)
	if self.CurShootBall ~= nil then
		self.CurShootBall:PlayAnimation(self.CurShootBall.AnimResume)
	end
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	ViewModel.PointerAngle = PointerAngle.Min
	self:SetActBtnEnbale(false)
	
	for i = 1, 4 do
		local NameIndex = string.format("BallBox%d", i)
		UIUtil.SetRenderOpacity(self[NameIndex], 0)
	end

	if self.ShowCriticalTimer ~= nil then
		self:UnRegisterTimer(self.ShowCriticalTimer)
		self.ShowCriticalTimer = nil
	end

	UIUtil.SetColorAndOpacityHex(self.Award.TextQuantity, "FFF9E1FF")
	AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.AnimInAudio)
	self.ExploreAlarmHandle = nil
end

function GoldSaucerMonsterTossMainPanelView:OnHide()
	self:PointerStopRotation()
	FLOG_INFO("MonsterToss PointerRotateAudioStop OnHide")
	self.IsHide = true
	self:StopAllAnimations()
	self.Award:StopAllAnimations()
	self:UnRegisterAllTimer()
end

function GoldSaucerMonsterTossMainPanelView:OnExistGame()
	self.Btn2.Button:SetIsEnabled(false)
	self.Btn1.Button:SetIsEnabled(false)

	self:UnRegisterAllTimer()
	self:StopAllAnimations()
	self:HideShootingTips()
	for i = 1, 4 do
		local NameIndex = string.format("Ball%d", i)
		self[NameIndex]:PlayAnimation(self[NameIndex].AnimResume)
	end
end

function GoldSaucerMonsterTossMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn1.Button, self.OnLeaveBtnClick)
	UIUtil.AddOnPressedEvent(self, self.Btn2.Button, self.OnFightAgainBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnShoot, self.OnBtnShootClick)
	self:BindBtnCloseCallBack()
end

function GoldSaucerMonsterTossMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MonsterTossEndEvent, self.OnReciveMonsterTossEndEvent)
	self:RegisterGameEvent(EventID.MiniGameMainPanelPlayAnim, self.MiniGameMonsterTossMainPlayAnimEvent)
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnReciveMonsterTossEndEvent)

end

function GoldSaucerMonsterTossMainPanelView:OnRegisterBinder()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
    self:RegisterBinders(ViewModel, self.Binders)

	local AllBallVM = ViewModel:GetAllBallVM()
	for i = 1, 4 do
		local NameIndex = string.format("Ball%d", i)
		self[NameIndex]:SetParams({Data = AllBallVM[i]})
	end

	self.MultiplePoints:SetParams({Data = ViewModel})

	local ResultPanelVM = ViewModel:GetResultPanelVM()
	self:RegisterBinders(ResultPanelVM, self.ResultBinders)
end

function GoldSaucerMonsterTossMainPanelView:ShowShootingTips()
	if self.ShootingTips then
		return
	end
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	local ShootTipVM = ViewModel:GetMonsterTossShootingResultTipVM()
	if ShootTipVM == nil then
		return
	end
	local Params = { Data = ShootTipVM }
	self.ShootingTips = _G.UIViewMgr:CreateViewByName(ShootingTipsBPName, ObjectGCType.NoCache, self, true, true, Params)
	if self.ShootingTips == nil then
		return
	end
	self.FCanvasPanel:AddChildToCanvas(self.ShootingTips)
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0.5, 0)
	Anchor.Maximum = _G.UE.FVector2D(0.5, 0)
	local Alignment = _G.UE.FVector2D(0.5, 0)
	local Size = _G.UE.FVector2D(100, 30)
	local Position = _G.UE.FVector2D(0, 84)
	UIUtil.CanvasSlotSetAnchors(self.ShootingTips, Anchor)
	UIUtil.CanvasSlotSetAlignment(self.ShootingTips, Alignment)
	UIUtil.CanvasSlotSetSize(self.ShootingTips, Size)
	UIUtil.CanvasSlotSetPosition(self.ShootingTips, Position)
	UIUtil.CanvasSlotSetAutoSize(self.ShootingTips, true)
	_G.UIViewMgr:ShowSubView(self.ShootingTips, Params)
end

function GoldSaucerMonsterTossMainPanelView:HideShootingTips()
	if self.ShootingTips == nil then
		return
	end
	_G.UIViewMgr:HideSubView(self.ShootingTips)
	self.FCanvasPanel:RemoveChild(self.ShootingTips)
	_G.UIViewMgr:RecycleView(self.ShootingTips)
	self.ShootingTips = nil
end

--- @type 当游戏结束时
function GoldSaucerMonsterTossMainPanelView:OnReciveMonsterTossEndEvent()
	local JDResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
	self.MoneySlot:UpdateView(JDResID, true, -1, true)
end

function GoldSaucerMonsterTossMainPanelView:MiniGameMonsterTossMainPlayAnimEvent(InAnim, bCritical)
	local Anim = MiniGameClientConfig[MiniGameType.MonsterToss].Anim
	local ChallengeResults = self.ChallengeResults
	local CurShootBall = self.CurShootBall
	
	if InAnim == Anim.AnimNextBall then
		UIUtil.SetIsVisible(self.MultiplePoints, true)
		self:RegisterTimer(function() UIUtil.SetIsVisible(self.MultiplePoints, false) end, 1) -- 无论是否投进都要消失
		CurShootBall:PlayAnimation(CurShootBall.AnimResume)
		self:PlayAnimation(self.AnimNextBall)
	elseif InAnim == Anim.AnimObtainNumberIn then
		self:PlayAnimation(self.AnimObtainNumberIn)
	elseif InAnim == Anim.AnimScoreMultiplierIn2 then
		self:PlayAnimation(self.AnimScoreMultiplierIn2)
	elseif InAnim == Anim.AnimScoreMultiplierIn3 then
		self:PlayAnimation(self.AnimScoreMultiplierIn3)
	elseif InAnim == Anim.AnimScoreMultiplierIn5 then
		self:PlayAnimation(self.AnimScoreMultiplierIn5)
	elseif InAnim == Anim.AnimConsecutiveHits1 then
		self:PlayAnimation(self.AnimConsecutiveHits1)
	elseif InAnim == Anim.AnimConsecutiveHits2 then
		self:PlayAnimation(self.AnimConsecutiveHits2)
	elseif InAnim == Anim.AnimConsecutiveHits3 then
		self:PlayAnimation(self.AnimConsecutiveHits3)
	elseif InAnim == Anim.AnimConsecutiveHitsStop then
		self:PlayAnimation(self.AnimConsecutiveHitsStop)
	elseif InAnim == Anim.AnimResult then
		self:OnPlayAnimResult()
	elseif InAnim == Anim.AnimBombReady then
		CurShootBall:PlayAnimation(CurShootBall.AnimBombReady)
	elseif InAnim == Anim.AnimResume then
		CurShootBall:PlayAnimation(CurShootBall.AnimResume)
	elseif InAnim == Anim.AnimBallBoom then
		self:PlayAnimation(self.AnimBallBoom)
	elseif InAnim == Anim.AnimIn then
		self:PlayAnimation(self.AnimIn)
	elseif InAnim == Anim.AnimTimesup then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimTimesup)
		AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.PointerRotateStop)
		FLOG_INFO("MonsterToss PointerRotateAudioStop AnimTimesup")
		self:TryStopExploreAlarmAudio()
	elseif InAnim == Anim.AnimSuccess then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimSuccess)
		AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.GameSuccess)
		AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.PointerRotateStop)
		FLOG_INFO("MonsterToss PointerRotateAudioStop AnimSuccess")
		self:TryStopExploreAlarmAudio()
	elseif InAnim == Anim.AnimRefreshHighestScore then
		self:PlayAnimation(self.AnimRefreshHighestScore)
	elseif InAnim == Anim.AnimProgressBar then
		local GameInst = self:GetMiniGameInst()
		self:SetStartProValue(self:GetEndProValue())
		self:SetEndProValue(math.clamp(GameInst.ComboNum / 8, 0, 1))
		self:PlayAnimation(self.AnimProgressBar)
	end
	if bCritical then
		self:OnActiveCritical()
	end
end

function GoldSaucerMonsterTossMainPanelView:OnPlayAnimResult()
	self:PlayAnimation(self.AnimResult)
	UIUtil.SetIsVisible(self.CloseBtn, false)
	self.Btn1.Button:SetIsEnabled(true)
	self.Btn2.Button:SetIsEnabled(true)

	local SubViews = self.ResultTableViewAdapter.SubViews
	for _, View in pairs(SubViews) do
		-- View:Reset()
		View:CheckPlayAnim()
	end
	-- self:RegisterTimer(function() 
		
	-- end, 0.5)

	-- local function PlaySubViewAnim()
	-- 	local SubViews = self.ResultTableViewAdapter.SubViews
	-- 	for _, View in pairs(SubViews) do
	-- 		View:CheckPlayAnim()
	-- 	end
	-- end
	-- self:RegisterTimer(PlaySubViewAnim, 1.5)
end

function GoldSaucerMonsterTossMainPanelView:OnActiveCritical()
	local MiniGameInst = self:GetMiniGameInst()
	if MiniGameInst == nil then
		return
	end
	local VM = self:GetTheParamsVM()
	if VM == nil then
		return
	end
	local ShowEndAnimTime = 1.83
	UIUtil.SetIsVisible(self.Critical, false)
	self.ShowCriticalTimer = self:RegisterTimer(function()
		if UIUtil.IsVisible(self.PanelResult) then
			UIUtil.SetIsVisible(self.Critical, true)
			self.Critical:PlayAnimation(self.Critical.AnimCriticalIn)
			self.Award:PlayAnimation(self.Award.AnimCriticalIn)
			MiniGameInst:MultiRewardGot()
			self:RegisterTimer(function() VM:UpdateRewardGotSingle() end, 1.5)
		end
		self.ShowCriticalTimer = nil
	end, ShowEndAnimTime)
end

--- 动画结束统一回调
function GoldSaucerMonsterTossMainPanelView:OnAnimationFinished(Animation)
	if self.IsHide then
		return
	end
	if Animation == self.AnimIn or Animation == self.AnimNormalIn then
		self:OnReady()
		-- 临时代码等动效好了	
		self:RegisterTimer(self.OnBegin, DelayTime.PerpareToBegin, 0, 1, self)
	elseif Animation == self.AnimBallBoom  then
		-- self:PlayAnimation(self.AnimGearLoop)
		if self.P_DX_TheFinerMiner_7 then
			self.P_DX_TheFinerMiner_7:ResetParticle()
		end
	end
end

--- @type 隐藏相关UI
function GoldSaucerMonsterTossMainPanelView:HideRelateUI()
	-- UIUtil.SetIsVisible(self.HelpTips, false)
	UIUtil.SetIsVisible(self.MultiplePoints, false)

	UIUtil.SetIsVisible(self.TextTips, false)
	UIUtil.SetIsVisible(self.ImgTurntableColor1, false)
	UIUtil.SetIsVisible(self.ImgTurntableColor2, false)
	UIUtil.SetIsVisible(self.ImgTurntableColor3, false)
	-- UIUtil.SetIsVisible(self.FHorizontalBox_57, false)

	for i = 1, 4 do
		local NameIndex = string.format("Ball%d", i)
		UIUtil.SetIsVisible(self[NameIndex], false)
	end
end

-- 点击离开按钮
function GoldSaucerMonsterTossMainPanelView:OnLeaveBtnClick()
	self:OnExistGame()
	GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MonsterToss, false)
	FLOG_INFO("GoldSaucerMonsterTossMainPanelView Begin Hide")
	self:Hide()
end

-- 点击再战按钮
function GoldSaucerMonsterTossMainPanelView:OnFightAgainBtnClick()
	local OwnJdCoinNum = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) --持有的金碟币
	if OwnJdCoinNum >= 1 then
		self:ReInitGame()
		self.Btn1.Button:SetIsEnabled(false)
		GoldSaucerMiniGameMgr:OnBtnFightAgainClick(MiniGameType.MonsterToss)
	else
		_G.JumboCactpotMgr:GetJDcoin()
		self:OnLeaveBtnClick()
	end
end

--- @type 设置显示哪个指针
function GoldSaucerMonsterTossMainPanelView:ChangeShowPointerType(bHit, bPlayAnim)
	if bPlayAnim then
		if bHit then
			self:PlayAnimation(self.AnimShootRight)
		else
			self:PlayAnimation(self.AnimShootWrong)
		end
	end
end

--- @type 开始时显示相关UI
function GoldSaucerMonsterTossMainPanelView:ShowRelateUI()
	UIUtil.SetIsVisible(self.TextTips, true)
	UIUtil.SetIsVisible(self.ImgTurntableColor1, true)
	UIUtil.SetIsVisible(self.ImgTurntableColor2, true)
	UIUtil.SetIsVisible(self.ImgTurntableColor3, true)
	-- UIUtil.SetIsVisible(self.FHorizontalBox_57, true)

	self:ShowBallUI()
	self:PlayAnimation(self.AnimTips)
	-- 提示3s后隐藏
	self:RegisterTimer(function() UIUtil.SetIsVisible(self.TextTips, false) end, 3)
end

function GoldSaucerMonsterTossMainPanelView:ShowBallUI()
	for i = 1, 4 do
		local NameIndex = string.format("Ball%d", i)
		UIUtil.SetIsVisible(self[NameIndex], true)
	end
end

--- @type 准备开始
function GoldSaucerMonsterTossMainPanelView:OnReady()
	self:ChangeShowPointerType(true, false)
	UIUtil.SetIsVisible(self.challengeBegins, true)
	self.challengeBegins:SetPrepare()

	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	ViewModel:UpdateProportLayOut()
	ViewModel:SetGameInstVM()

	AudioUtil.LoadAndPlayUISound(MiniGameCuffAudioDefine.AudioPath.OnReady)			-- 暂时复用重击加美什的音效

	self:RegisterTimer(function()
		AudioUtil.LoadAndPlayUISound(MiniGameCuffAudioDefine.AudioPath.OnBegin)		-- 暂时复用重击加美什的音效
		self.challengeBegins:SetBegin()
	end, DelayTime.ReadyToBegin, 0, 1)
end

--- @type 当开始时
function GoldSaucerMonsterTossMainPanelView.OnBegin(self)
	self.bIsShootOnce = false
	self.CurShootBall = self.Ball1
	UIUtil.SetIsVisible(self.challengeBegins, false)
	self.CurShootBall:PlayAnimation(self.CurShootBall.AnimResume)

	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	self.Ball1:SetMiniGameVM(ViewModel)
	local MiniGameInst = ViewModel.MiniGame
	if MiniGameInst == nil then
		return
	end
	local PosData = self:ConstructPosData()
	MiniGameInst:SetPosData(PosData)


	self:ShowRelateUI()

	-- self:RegisterTimer(function() 
	-- 	if not self.bIsShootOnce then
	-- 		self:PlayAnimation(self.AnimBtnShootLoop, 0, 0) 
	-- 	end
	-- end, 5, 0, 1, self)
	self:PlayAnimation(self.AnimBtnShootLoop, 0, 0)
	self.bWaitBegin = false

	local AnimStartTime = self.AnimStart:GetEndTime()
	self:PlayAnimation(self.AnimStart)
	local function OnStartAnimEnd()
		self:SetActBtnEnbale(true)
		self:OnCanShoot(false)
		MiniGameInst:StartGameTimeLoop(MiniGameInst.GameRun)
	end
	self:RegisterTimer(OnStartAnimEnd, AnimStartTime) 

end

--- @type 开始旋转
function GoldSaucerMonsterTossMainPanelView:PointerBeginRotation()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	local GameInst = self:GetMiniGameInst()

	local function LoopRotatePointer()
		if tonumber(GameInst.RemainSeconds) <= 0 then
			self:UnRegisterTimer(self.AngleLoopTimer)
			return
		end

		local CurStageDiffParams = GameInst:GetCurStageDiffParams()
		if next(CurStageDiffParams) ~= nil then
			self.RotateOnceTime = CurStageDiffParams.RotateOnceTime / 1000
			self.OneLoopAngle = MaxAngle / (self.RotateOnceTime / 0.05)
			local bAddAngle = self.bAddAngle
			if bAddAngle then
				ViewModel.PointerAngle = ViewModel.PointerAngle + self.OneLoopAngle
			else
				ViewModel.PointerAngle = ViewModel.PointerAngle - self.OneLoopAngle
			end
			if ViewModel.PointerAngle >= PointerAngle.LefeBorder then
				self.bAddAngle = false
				ViewModel.PointerAngle = PointerAngle.LefeBorder
			elseif ViewModel.PointerAngle <= PointerAngle.RightBorder then
				self.bAddAngle = true
				ViewModel.PointerAngle = PointerAngle.RightBorder
			end
		else
			FLOG_ERROR(" CurStageDiffParams is null table")
		end
	end
	self.AngleLoopTimer = self:RegisterTimer(LoopRotatePointer, 0, 0.05, 0)
	AudioUtil.SyncLoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.PointerRotate)
	FLOG_INFO("MonsterToss PointerRotateAudioStop BeginPlay")
end

--- @type 停止旋转
function GoldSaucerMonsterTossMainPanelView:PointerStopRotation()
	local AngleLoopTimer = self.AngleLoopTimer
	if AngleLoopTimer ~= nil then
		self:UnRegisterTimer(AngleLoopTimer)
		self.AngleLoopTimer = nil
	end
	AudioUtil.SyncLoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.PointerRotateStop)
	FLOG_INFO("MonsterToss PointerRotateAudioStop StopPlay")
end

--- @type 重置指针位置
function GoldSaucerMonsterTossMainPanelView:ResetPointer()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	math.randomseed(TimeUtil.GetServerTime())
	local TempNum = math.random(1, 10)
	if TempNum <= 5 then
		ViewModel.PointerAngle = PointerAngle.Min
		self.bAddAngle = true
	else
		ViewModel.PointerAngle = PointerAngle.Max
		self.bAddAngle = false
	end
end

--- 储存位置Score控件的位置信息
function GoldSaucerMonsterTossMainPanelView:ConstructPosData()
	local PosData = {}
	local Y = 10.5  -- 适配为10.5
	local MaxComboNum = 8
	local XOffset = 25
	for i = 1, 7 do
		local NameIndex = string.format("Pos%d", i)
		local X = UIUtil.CanvasSlotGetPosition(self[string.format("ProgressBarDeco%d", i)]).X + XOffset
		PosData[NameIndex] = UE.FVector2D(X, Y)
	end
	local EndXOffset = 30
	PosData[string.format("Pos%d", MaxComboNum)] = PosData[string.format("Pos%d", MaxComboNum - 1)] + UE.FVector2D(EndXOffset, 0)
	return PosData
end


--- @type show投篮结果提示
function GoldSaucerMonsterTossMainPanelView:ShowShootResultTip(bHit, GameInst)
	local function SetShootTop()
		self:ShowShootingTips()
		if bHit then
			AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.ShootSuccessTipAudio)
		end
		if self.ShootingTips then
			self.ShootingTips:ShowResult(bHit)
		end
	end
	if self.ShootingTips then
		self.ShootingTips:StopAllAnimations()
	end
	self.ShowTipTimer = self:RegisterTimer(SetShootTop, 1.5)
	-- self.HideTipTimer = self:RegisterTimer(function() GameInst:SetbShootTipVisible(false) end, 2 + 2)
end

--- @type 当按钮按下时
function GoldSaucerMonsterTossMainPanelView:OnBtnShootClick()
	--- OnShoot
	local GameInst = self:GetMiniGameInst()
	if GameInst == nil or self.bWaitBegin or tonumber(GameInst.RemainSeconds) <= 0 then
		return
	end
	-- if self:IsAnimationPlaying(self.AnimBtnShootLoop) then
	-- 	self:StopAnimation(self.AnimBtnShootLoop)
	-- end
	self:ClearShootTimer()
	self.bIsShootOnce = true
	self:SetActBtnEnbale(false)
	local CurShootBall = self.CurShootBall
	local ViewModel = CurShootBall:GetViewModel()
	local Type = ViewModel:GetType()
	if Type == BasketballType.BasketballType_Bang then
		CurShootBall:PlayAnimation(CurShootBall.AnimResume)
	end
	self:PlayAnimation(self.AnimDropBall) -- UI丢球动画

	--- Shoot
	self:Shoot(GameInst)

	--- Update By Shoot Result
	local bHit = self:CheckIsHit(Type)
	self:UpdateByShootResult(Type, bHit,GameInst)

	--- OnShootEnd
	self:OnShootEnd(GameInst)
end

--- @type 投篮
function GoldSaucerMonsterTossMainPanelView:Shoot(GameInst)
	GameInst:StopMajorSlotAnimation(GoldSaucerMiniGameDefine.DefaultSlot) -- 停止动画
	local Path = self:SelectActionTimeLineByRace()
	GameInst:PlayActionTimeLineByPath(Path)	-- 播放投篮动画
	
	self:TryStopExploreAlarmAudio()

	self:RegisterTimer(function() AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.BallInAir) end, 0.5)
end

--- @type 当篮球投出 
function GoldSaucerMonsterTossMainPanelView:OnShootEnd(GameInst)
	local function RePlayIdleAnim()
		local Path = GameInst:GetIdlePathByRaceID()
		GameInst:PlayAnyAsMontageLoopByPath(Path, GoldSaucerMiniGameDefine.DefaultSlot, 9999, true)
	end
	self.PlayIdleTimer = self:RegisterTimer(RePlayIdleAnim, 1.6) -- 1.6s后恢复等待投篮动画

	local function ReActiveShootBtn()
		if GameInst.RemainSeconds >= 0.1 then
			self:SetActBtnEnbale(true)
			self:OnCanShoot(true)
		end
	end
	self:RegisterTimer(ReActiveShootBtn, 2, nil, 1) -- 2s后激活投篮按钮
end

--- @type 根据投篮结果更新游戏动态
function GoldSaucerMonsterTossMainPanelView:UpdateByShootResult(Type, bHit, GameInst)
	_G.FLOG_INFO("Shoot Result is %s", bHit)
	self:ChangeShowPointerType(bHit, true) 					-- 根据结果更新指针
	self:UpdateDynaByResult(bHit, GameInst)										-- 根据结果更新动态物件
	GoldSaucerMiniGameMgr:SendMsgBaskMonsterShootReq(bHit, false)			-- 告诉服务器结果
	GameInst:SetMultiScoreByType(Type, bHit) 									-- 设置加倍得分
	GameInst:SetbOnShoot(true)													-- 当前正在投篮
	GameInst:SetDelayFinishTime()

	self:ShowShootResultTip(bHit, GameInst) 					-- 展示投篮结果提示
	if bHit then
		self:UpdateScoreMultByType(Type)										-- 更新几倍得分
		self:RegisterTimer(function() 
			self:PlayAnimation(self.AnimScoreShow) 
		end, 1) 
		self:RegisterTimer(function() AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.BallEnterNet) end, 1.2)
	else
		-- self.ValueAnimProgressBarStart = 0
		-- self.ValueAnimProgressBarEnd = 0
	end
end

--- @type 清除上一次投篮注册的Timer
function GoldSaucerMonsterTossMainPanelView:ClearShootTimer()
	if self.WaitExplodeTimer ~= nil then
		self:UnRegisterTimer(self.WaitExplodeTimer)
		self.WaitExplodeTimer = nil
	end
	if self.CanShootTimer ~= nil then
		self:UnRegisterTimer(self.CanShootTimer)
		self.CanShootTimer = nil
	end
	if self.SendMsgTimer ~= nil then
		self:UnRegisterTimer(self.SendMsgTimer)
		self.SendMsgTimer = nil
	end
	if self.HideTipTimer ~= nil then
		self:UnRegisterTimer(self.HideTipTimer)
		self.HideTipTimer = nil
	end
end

function GoldSaucerMonsterTossMainPanelView:SelectActionTimeLineByRace()
	local MajorUtil = require("Utils/MajorUtil")
	local RaceID = MajorUtil.GetMajorRaceID()
	return ActionPath[RaceID]
end

--- @type 更新动态物件
function GoldSaucerMonsterTossMainPanelView:UpdateDynaByResult(bHit, GameInst)
	self:ResetSharedGroupState(GameInst)
	local InstanceID = GameInst.DynAssetID
	local NeedID
	if bHit then
		NeedID = DynaID.Success
	else
		NeedID = DynaID.Defeat
	end
	PWorldMgr:PlaySharedGroupTimeline(InstanceID, NeedID)
end

function GoldSaucerMonsterTossMainPanelView:ResetSharedGroupState(GameInst)
	local InstanceID = GameInst.DynAssetID
	PWorldMgr:PlaySharedGroupTimeline(InstanceID, 0)
	FLOG_INFO("ResetSharedGroup")
end

--- @type 当重新激活可投篮
function GoldSaucerMonsterTossMainPanelView:OnCanShoot(bResetPointer)
	local CurShootBall = self.CurShootBall
	local ItemVM = CurShootBall:GetViewModel()
	local Type = ItemVM:GetType()
	CurShootBall:PlayAnimation(CurShootBall.AnimResume)
	local GameInst = self:GetMiniGameInst()
	GameInst:SetbOnShoot(false)

	self:PointerStopRotation()
	FLOG_INFO("MonsterToss PointerRotateAudioStop Restart")
	if bResetPointer then
		self:ResetPointer()
	end
	if tonumber(GameInst.RemainSeconds) > 0 then
		self:PointerBeginRotation()
		FLOG_INFO("MonsterToss PointerRotateAudioStop BeginRotate")
	end
	self:ChangeShowPointerType(true, false)

	local ViewModel = self:GetTheParamsVM()
	if bResetPointer then
		GameInst:CaculateZOreder()			--- 重置布局
		ViewModel:UpdateProportLayOut()		--- 重置布局
	end

	if Type == BasketballType.BasketballType_Bang then
		local GlobalParams = GameInst.GlobalParams
		local DelayExplodeTime = GlobalParams[BasketballParamType.BasketballParamTypeBangTime].Value / 1000 -- 1.6S
		local ExplodeAnimTime = 2.2 -- 2.2s就会动画播放到爆炸效果
		local PlayRate = ExplodeAnimTime / DelayExplodeTime
		CurShootBall:PlayAnimation(CurShootBall.AnimBombReady, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlayRate)
		self.ExploreAlarmHandle = AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.ExploreAlarm)
		local StiffTime = GlobalParams[BasketballParamType.BasketballParamTypeBangBallTime].Value / 1000 --爆炸造成僵直时间
		local ReActiveTime = DelayExplodeTime + StiffTime
		self.WaitExplodeTimer = self:RegisterTimer(function() self:SetActBtnEnbale(false) end, DelayExplodeTime - 0.1)
		self.SendMsgTimer = self:RegisterTimer(function()
			if tonumber(GameInst.RemainSeconds) > 0 then
				self:OnBallExplode(GameInst, StiffTime)
			end
		end, DelayExplodeTime)

		self.CanShootTimer = self:RegisterTimer(function() 
			if GameInst.RemainSeconds >= 0.1 then
				self:SetActBtnEnbale(true)
				self:OnCanShoot(true)
			end
		end, ReActiveTime)
	end
end

--- @type 当爆炸球爆炸
function GoldSaucerMonsterTossMainPanelView:OnBallExplode(GameInst, StiffTime)
	self:PlayAnimation(self.AnimBallBoom)
	GoldSaucerMiniGameMgr:SendMsgBaskMonsterShootReq(false, true)
	self:PointerStopRotation()
	FLOG_INFO("MonsterToss PointerRotateAudioStop BallExplode")
	GameInst:PlayExplodeVfx()
	-- GameInst:PlayerChangeColor(StiffTime)
	AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.ExploreAudio)
	self:TryStopExploreAlarmAudio()
end

--- @type 如果有预警声音停掉预警声音
function GoldSaucerMonsterTossMainPanelView:TryStopExploreAlarmAudio()
	if nil ~= self.ExploreAlarmHandle then
		AudioUtil.StopAsyncAudioHandle(self.ExploreAlarmHandle)
		FLOG_INFO("MonsterToss PointerRotateAudioStop StopExploreAlarmHandle")
		self.ExploreAlarmHandle = nil
	end
end

--- @type 检测是否命中
function GoldSaucerMonsterTossMainPanelView:CheckIsHit(Type)
	self:PointerStopRotation()
	FLOG_INFO("MonsterToss PointerRotateAudioStop Check Is Hit")
	local ViewModel = self:GetTheParamsVM()
	local CurAngle = ViewModel.PointerAngle
	if CurAngle < 0 then
		CurAngle = PointerAngle.Max + CurAngle
	else
		CurAngle = CurAngle + PointerAngle.Max
	end
	local GameInst = self:GetMiniGameInst()
	local CurZOrderData = GameInst.CurZOrderData
	local CurStageDiffParams = GameInst:GetCurStageDiffParams()
	if CurStageDiffParams == nil then
		return
	end
	local ZOrderCfg = CurStageDiffParams.ZOrderCfg
	local BlueMaxAngle, PurpleMaxAngle, RedMaxAngle
	local Data = self:ConstructColorData(ZOrderCfg, CurStageDiffParams)
	local MaxZOrderColorAngle = self:GetMaxZOrderColorAngle(CurZOrderData, CurStageDiffParams)
	for _, v in pairs(Data) do
		local SubData = v
		if ColorType.Blue == SubData.ColorType then
			BlueMaxAngle = self:GetMaxAngle(SubData.ZOrder, SubData.Proportion, MaxZOrderColorAngle)
		elseif ColorType.Red == SubData.ColorType then
			RedMaxAngle = self:GetMaxAngle(SubData.ZOrder, SubData.Proportion, MaxZOrderColorAngle)
		elseif ColorType.Purple == SubData.ColorType then
			PurpleMaxAngle = self:GetMaxAngle(SubData.ZOrder, SubData.Proportion, MaxZOrderColorAngle)
		end	
	end
	local NeedData = {
		{ MaxAngle = BlueMaxAngle, ZOrder = ZOrderCfg.BlueProportOrder, ColorType = ColorType.Blue},
		{ MaxAngle = RedMaxAngle, ZOrder = ZOrderCfg.RedProportOrder, ColorType = ColorType.Red},
		{ MaxAngle = PurpleMaxAngle, ZOrder = ZOrderCfg.PurpleProportOrder, ColorType = ColorType.Purple},
	}
	local function SortByZOrder(Right, Left)
		return Right.ZOrder > Left.ZOrder
	end
	table.sort(NeedData, SortByZOrder)
	local StopColor = self:GetStopColor(CurAngle, NeedData)
	local bSuccess = false
	if StopColor == ColorType.Red and Type == BasketballType.BasketballType_Bang then
		bSuccess = true
	elseif StopColor == ColorType.Blue and Type == BasketballType.BasketballType_Normal then
		bSuccess = true
	elseif StopColor == ColorType.Purple and Type == BasketballType.BasketballType_Super then
		bSuccess = true
	end
	return bSuccess
end

function GoldSaucerMonsterTossMainPanelView:GetStopColor(CurAngle, NeedData)
	for _, v in ipairs(NeedData) do
		local Elem = v
		if CurAngle <= Elem.MaxAngle then
			return Elem.ColorType
		end
	end

end

function GoldSaucerMonsterTossMainPanelView:GetMaxAngle(ZOrder, Proportion, MaxZOrderColorAngle)
	if ZOrder == ZOrderPriority.Max then
		return MaxAngle * (Proportion / 100)
	elseif ZOrder == ZOrderPriority.Middle then
		return MaxZOrderColorAngle + MaxAngle * (Proportion / 100)
	elseif ZOrder == ZOrderPriority.Min then
		return MaxAngle
	end
	return
end

function GoldSaucerMonsterTossMainPanelView:GetMaxZOrderColorAngle(CurZOrderData, CurStageDiffParams)
	local MaxZOrderColorType
    for _, v in pairs(CurZOrderData) do
        local Elem = v
        if Elem.ZOrder == ZOrderPriority.Max then
            MaxZOrderColorType = Elem.ColorType
		end
	end
	local Proportion
	if MaxZOrderColorType == ColorType.Blue then
		Proportion = CurStageDiffParams.BlueProportion
	elseif MaxZOrderColorType == ColorType.Red then
		Proportion = CurStageDiffParams.RedProportion
	else--if MaxZOrderColorType == ColorType.Purple then
		Proportion = CurStageDiffParams.PurpleProportion
	end
	return MaxAngle * (Proportion / 100)
end

function GoldSaucerMonsterTossMainPanelView:ConstructColorData(ZOrderCfg, CurStageDiffParams)
	local RedProportion = CurStageDiffParams.RedProportion
	local PurpleProportion = CurStageDiffParams.PurpleProportion
	local BlueProportion = CurStageDiffParams.BlueProportion
	local Data = {
		{ZOrder = ZOrderCfg.BlueProportOrder, ColorType = ColorType.Blue, Proportion = BlueProportion },
		{ZOrder = ZOrderCfg.PurpleProportOrder, ColorType = ColorType.Purple, Proportion = PurpleProportion },
		{ZOrder = ZOrderCfg.RedProportOrder, ColorType = ColorType.Red, Proportion = RedProportion },
	}
	-- table.sort(Data)
	return Data
end

--- @type 更新几倍得分
function GoldSaucerMonsterTossMainPanelView:UpdateScoreMultByType(Type)	
	local NeedAnim
	local MultiplePoints = self.MultiplePoints
    if Type == BasketballType.BasketballType_Bang then
        NeedAnim = MultiplePoints.AnimScoreMultiple5
    elseif Type == BasketballType.BasketballType_Normal then
        -- bVisible = false
    elseif Type == BasketballType.BasketballType_Super then
		NeedAnim = MultiplePoints.AnimScoreMultiple2
    end
	if NeedAnim ~= nil then
		MultiplePoints:PlayAnimation(NeedAnim) -- 预播放，当显示出来后会播放此动画
	end
	UIUtil.SetIsVisible(self.MultiplePoints, false) -- 先隐藏，投进了再显示
end

--- 
function GoldSaucerMonsterTossMainPanelView:SetActBtnEnbale(bEnable)
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	ViewModel.bActBtnEnable = bEnable
end

function GoldSaucerMonsterTossMainPanelView:UpdateEndStateInfo()
	local GameInst = self:GetMiniGameInst()
	local DelayTime = 0.1
	if GameInst:GetbOnShoot() then
		DelayTime = GameInst.DelayFinishTime
	end
	self:RegisterTimer(function() GoldSaucerMiniGameMgr:SendMsgBaskMonsterFinishReq(true) end, DelayTime)
end

--- @type 每当游戏的状态改变时调用
function GoldSaucerMonsterTossMainPanelView:OnMiniGameStateChanged(NewValue, OldValue)
	FLOG_INFO("GoldSaucerMonsterTossMainPanelView:OnMiniGameStateChanged NewValue:%s, OldValue:%s", NewValue, OldValue)
    if OldValue == MiniGameStageType.Enter and NewValue == MiniGameStageType.DifficultySelect then

	elseif OldValue == MiniGameStageType.Update and NewValue == MiniGameStageType.End then
		self:HideShootingTips()
		self:UpdateEndStateInfo()
    end
end

function GoldSaucerMonsterTossMainPanelView:BindBtnCloseCallBack()
	local function EnsureFailQuit()
		local GameInst = self:GetMiniGameInst()
		self:OnExistGame()
		self:Hide()
		GameInst:SetIsForceEnd(true)
		AudioUtil.LoadAndPlay2DSound(MonsterTossAudioDefine.AudioPath.PointerRotateStop)
		FLOG_INFO("MonsterToss PointerRotateAudioStop ForceQuit")
		self:TryStopExploreAlarmAudio()
		GoldSaucerMiniGameMgr:SendMsgBaskMonsterFinishReq(false)
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MonsterToss, false)
	end

	local function RecoverGameLoop()
		local GameInst = self:GetMiniGameInst()
		if GameInst ~= nil then
			--GameInst:RecoverGameTimeLoop()
 		end
	end	

	local function OnBtnCloseClick(View)
		local GameInst = self:GetMiniGameInst()

		local GameState = GameInst:GetGameState()
		if GameState == MiniGameStageType.Reward then
			GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MonsterToss, false)
			self:Hide()
			return
		end
		--GameInst:StopGameTimeLoop(true)

		GoldSaucerMiniGameMgr:ShowEnsureExitTip(MiniGameType.MonsterToss, EnsureFailQuit, RecoverGameLoop)
	end
	self.CloseBtn:SetCallback(self, OnBtnCloseClick)
end

--- 获取UIView关联的VM
function GoldSaucerMonsterTossMainPanelView:GetTheParamsVM()
    local Params = self.Params
    if Params == nil then
        return
    end

    local ViewModel = Params.Data
    if ViewModel == nil then
        return
    end
    return ViewModel
end

--- @type 获得小游戏实例
function GoldSaucerMonsterTossMainPanelView:GetMiniGameInst()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end
	return GameInst
end

return GoldSaucerMonsterTossMainPanelView