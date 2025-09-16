---
--- Author: Administrator
--- DateTime: 2023-11-15 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameProgressType = GoldSaucerMiniGameDefine.MiniGameProgressType
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local MiniGameDifficulty = GoldSaucerMiniGameDefine.MiniGameDifficulty
local TheFinerMinerCircleSize = GoldSaucerMiniGameDefine.TheFinerMinerCircleSize
local TheFinerMinerCircleType = GoldSaucerMiniGameDefine.TheFinerMinerCircleType
local AudioType = GoldSaucerMiniGameDefine.AudioType
local AnimTimeLineSourceKey = GoldSaucerMiniGameDefine.AnimTimeLineSourceKey
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local TimerMgr = _G.TimerMgr
local FVector2D = _G.UE.FVector2D
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local DifficultControlCfg = require("TableCfg/TheFinerMinerDifficultyControlCfg")
local ObjectGCType = require("Define/ObjectGCType")

local ShootingTipsBPName = "TheFinerMiner/GoldSaucer_TheFinerMinerShootingTipsItem_UIBP"
local ShootTipsAnimTime = 2 -- 手感Tips显示时间
local ShootTipsDelayTime = 1.3 -- 手感Tips延迟显示时间

---@class TheFinerMinerMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AimPanel UFCanvasPanel
---@field BluePanel UFCanvasPanel
---@field BtnClose CommonCloseBtnView
---@field BtnCut UFButton
---@field BtnCut1 UFButton
---@field BtnCutPanel UFCanvasPanel
---@field BtnInfo UFButton
---@field BtnPanel UFCanvasPanel
---@field ChooseDifficulty OutOnALimbChooseItemView
---@field CutPanel UFCanvasPanel
---@field DifficultyPanel UFCanvasPanel
---@field EFF_1 UFCanvasPanel
---@field HorizontalObtain UFHorizontalBox
---@field HorizontalObtain1 UFHorizontalBox
---@field ImgAimBg UFImage
---@field ImgAimSimple UFImage
---@field ImgArrow UFImage
---@field ImgAxe UFImage
---@field ImgBgBlack UFImage
---@field ImgCircleBlue UFImage
---@field ImgCircleRed UFImage
---@field ImgCircleYellow UFImage
---@field ImgCutAxe UFImage
---@field ImgDecorate2 UFImage
---@field ImgDifficulty UFImage
---@field ImgDifficulty2 UFImage
---@field ImgLetter1 UFImage
---@field ImgLetter2 UFImage
---@field ImgLetter3 UFImage
---@field ImgLetter4 UFImage
---@field ImgLetter5 UFImage
---@field ImgLetter6 UFImage
---@field ImgMedium UFImage
---@field ImgMedium2 UFImage
---@field ImgNoCut UFImage
---@field ImgNoCut1 UFImage
---@field ImgPriceIcon UFImage
---@field ImgSimple UFImage
---@field ImgSimple2 UFImage
---@field ImgState UFImage
---@field ImgStateYellow UFImage
---@field ImgStone1 UFImage
---@field ImgStone2 UFImage
---@field ImgTime UFImage
---@field ImgTimerBlue UFImage
---@field ImgTimerRed UFImage
---@field ImgTopLine UFImage
---@field LevelPanel1 UFCanvasPanel
---@field LevelPanel2 UFCanvasPanel
---@field MainLBottomPanel MainLBottomPanelView
---@field MainTeamPanel MainTeamPanelView
---@field NumberPanel UFCanvasPanel
---@field ObtainPanel UFCanvasPanel
---@field P_EFF_OutOnALimb_1 UUIParticleEmitter
---@field P_EFF_OutOnALimb_2 UUIParticleEmitter
---@field P_EFF_OutOnALimb_3 UUIParticleEmitter
---@field P_EFF_OutOnALimb_4 UUIParticleEmitter
---@field ProBarBlue UFImage
---@field ProBarChoose UFCanvasPanel
---@field ProBarGreen1 UProgressBar
---@field ProBarGreen2 UProgressBar
---@field ProBarPanel UFCanvasPanel
---@field ProBarPanel1 UFCanvasPanel
---@field ProBarPanel2 UFCanvasPanel
---@field ProBarRed1 UProgressBar
---@field ProBarRed2 UProgressBar
---@field ProBarYellow UFImage
---@field ProBarYellow1 UProgressBar
---@field ProBarYellow2 UProgressBar
---@field StatePanel UFCanvasPanel
---@field TextDifficulty UFTextBlock
---@field TextNumber UFTextBlock
---@field TextNumber1 UFTextBlock
---@field TextObtain UFTextBlock
---@field TextPanel UFCanvasPanel
---@field TextPanel2 UFCanvasPanel
---@field TextPointerNumber UFTextBlock
---@field TextPointerNumber_1 UFTextBlock
---@field TextPointerTime UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips OutOnALimbTextTipsItemView
---@field TextTips1 UFTextBlock
---@field TextTitle UFTextBlock
---@field TheFinerMinerPanel UFCanvasPanel
---@field TimePanel UFCanvasPanel
---@field TitlePanel UFCanvasPanel
---@field TitleTimePanel UFCanvasPanel
---@field AnimCircleRedLight UWidgetAnimation
---@field AnimCircleYellowLoop UWidgetAnimation
---@field AnimCutPanelCut UWidgetAnimation
---@field AnimCutPanelCutResume UWidgetAnimation
---@field AnimCutPanelDoubling13 UWidgetAnimation
---@field AnimCutPanelDoubling45 UWidgetAnimation
---@field AnimCutPanelIn UWidgetAnimation
---@field AnimCutPanelLoop UWidgetAnimation
---@field AnimDifficultyPanelCut UWidgetAnimation
---@field AnimDifficultyPanelLoop UWidgetAnimation
---@field AnimDifficultyTips UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimObtainNumberIn UWidgetAnimation
---@field AnimPointerNumberTrigger UWidgetAnimation
---@field AnimPointerTimeTrigger UWidgetAnimation
---@field AnimProBarChooseLoop UWidgetAnimation
---@field AnimProBarYellow UWidgetAnimation
---@field AnimStateIn UWidgetAnimation
---@field AnimTips UWidgetAnimation
---@field AnimTopTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TheFinerMinerMainPanelView = LuaClass(UIView, true)

function TheFinerMinerMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AimPanel = nil
	--self.BluePanel = nil
	--self.BtnClose = nil
	--self.BtnCut = nil
	--self.BtnCut1 = nil
	--self.BtnCutPanel = nil
	--self.BtnInfo = nil
	--self.BtnPanel = nil
	--self.ChooseDifficulty = nil
	--self.CutPanel = nil
	--self.DifficultyPanel = nil
	--self.EFF_1 = nil
	--self.HorizontalObtain = nil
	--self.HorizontalObtain1 = nil
	--self.ImgAimBg = nil
	--self.ImgAimSimple = nil
	--self.ImgArrow = nil
	--self.ImgAxe = nil
	--self.ImgBgBlack = nil
	--self.ImgCircleBlue = nil
	--self.ImgCircleRed = nil
	--self.ImgCircleYellow = nil
	--self.ImgCutAxe = nil
	--self.ImgDecorate2 = nil
	--self.ImgDifficulty = nil
	--self.ImgDifficulty2 = nil
	--self.ImgLetter1 = nil
	--self.ImgLetter2 = nil
	--self.ImgLetter3 = nil
	--self.ImgLetter4 = nil
	--self.ImgLetter5 = nil
	--self.ImgLetter6 = nil
	--self.ImgMedium = nil
	--self.ImgMedium2 = nil
	--self.ImgNoCut = nil
	--self.ImgNoCut1 = nil
	--self.ImgPriceIcon = nil
	--self.ImgSimple = nil
	--self.ImgSimple2 = nil
	--self.ImgState = nil
	--self.ImgStateYellow = nil
	--self.ImgStone1 = nil
	--self.ImgStone2 = nil
	--self.ImgTime = nil
	--self.ImgTimerBlue = nil
	--self.ImgTimerRed = nil
	--self.ImgTopLine = nil
	--self.LevelPanel1 = nil
	--self.LevelPanel2 = nil
	--self.MainLBottomPanel = nil
	--self.MainTeamPanel = nil
	--self.NumberPanel = nil
	--self.ObtainPanel = nil
	--self.P_EFF_OutOnALimb_1 = nil
	--self.P_EFF_OutOnALimb_2 = nil
	--self.P_EFF_OutOnALimb_3 = nil
	--self.P_EFF_OutOnALimb_4 = nil
	--self.ProBarBlue = nil
	--self.ProBarChoose = nil
	--self.ProBarGreen1 = nil
	--self.ProBarGreen2 = nil
	--self.ProBarPanel = nil
	--self.ProBarPanel1 = nil
	--self.ProBarPanel2 = nil
	--self.ProBarRed1 = nil
	--self.ProBarRed2 = nil
	--self.ProBarYellow = nil
	--self.ProBarYellow1 = nil
	--self.ProBarYellow2 = nil
	--self.StatePanel = nil
	--self.TextDifficulty = nil
	--self.TextNumber = nil
	--self.TextNumber1 = nil
	--self.TextObtain = nil
	--self.TextPanel = nil
	--self.TextPanel2 = nil
	--self.TextPointerNumber = nil
	--self.TextPointerNumber_1 = nil
	--self.TextPointerTime = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TextTips1 = nil
	--self.TextTitle = nil
	--self.TheFinerMinerPanel = nil
	--self.TimePanel = nil
	--self.TitlePanel = nil
	--self.TitleTimePanel = nil
	--self.AnimCircleRedLight = nil
	--self.AnimCircleYellowLoop = nil
	--self.AnimCutPanelCut = nil
	--self.AnimCutPanelCutResume = nil
	--self.AnimCutPanelDoubling13 = nil
	--self.AnimCutPanelDoubling45 = nil
	--self.AnimCutPanelIn = nil
	--self.AnimCutPanelLoop = nil
	--self.AnimDifficultyPanelCut = nil
	--self.AnimDifficultyPanelLoop = nil
	--self.AnimDifficultyTips = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimObtainNumberIn = nil
	--self.AnimPointerNumberTrigger = nil
	--self.AnimPointerTimeTrigger = nil
	--self.AnimProBarChooseLoop = nil
	--self.AnimProBarYellow = nil
	--self.AnimStateIn = nil
	--self.AnimTips = nil
	--self.AnimTopTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TheFinerMinerMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.ChooseDifficulty)
	self:AddSubView(self.MainLBottomPanel)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.TextTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TheFinerMinerMainPanelView:OnInit()
	self.Binders = {
        --{"GameName", UIBinderSetText.New(self, self.TextTitleName_GameName)},
		--{"TotalTimeTextTitle", UIBinderSetText.New(self, self.TextTime)},
		{"TotalTimeText", UIBinderSetText.New(self, self.TextPointerTime)},
		{"RoundRemainChances", UIBinderSetText.New(self, self.TextPointerNumber)},
		{"RoundRemainChances", UIBinderValueChangedCallback.New(self, nil, self.OnPlayNumberTrigger)},
		{"TextTipsTitle", UIBinderSetText.New(self, self.TextTips1)},
		{"TextTipsTitle", UIBinderSetText.New(self, self.TextDifficulty)},
        {"ProgressCounter", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameProgressChanged)},
        {"GameState", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameStateChanged)},
		{"bShowDifficultyPanel", UIBinderSetIsVisible.New(self, self.DifficultyPanel)},
		{"bShowCutPanel", UIBinderSetIsVisible.New(self, self.CutPanel)},
		{"bActBtnEnable", UIBinderSetIsVisible.New(self, self.BtnCut, nil, true)},
		{"bActBtnEnable", UIBinderSetIsVisible.New(self, self.BtnCut1, nil, true)},
		{"bActBtnEnable", UIBinderSetIsVisible.New(self, self.ImgNoCut, true)},
		{"bActBtnEnable", UIBinderSetIsVisible.New(self, self.ImgNoCut1, true)},
		{"DifficultyIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgAimSimple)},
		--{"bTopTipsShow", UIBinderSetIsVisible.New(self, self.TopTips)}, 不使用binder，因为异步可能导致状态错乱
		{"bKeyTime", UIBinderValueChangedCallback.New(self, nil, self.OnComeInKeyTime)},
		--{"RewardGot",  UIBinderSetText.New(self, self.TextNumber)},
		--{"RewardAdd",  UIBinderSetText.New(self, self.TextNumber1)},
		--{"bShowRewardAdd",  UIBinderSetIsVisible.New(self, self.HorizontalObtain1)},
		--{"bShowObtainPanel",  UIBinderSetIsVisible.New(self, self.ObtainPanel)},
		{"bShowCutTimePanel",  UIBinderSetIsVisible.New(self, self.TimePanel)},

		--- 队伍通用面板绑定
		{"GameName", UIBinderSetText.New(self, self.MainTeamPanel.TextGameName)},
		{"GoldPanelTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextGameName_1)},
		{"TotalTimeTextTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextTime)},
		{"RewardGot",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber)},
		{"RewardAdd",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber1)},
		{"bShowRewardAdd",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalObtain1)},
		{"bShowObtainPanel",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalGold)},
		{"bShowObtainPanel",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalObtain)},
		{"bShowPanelCountDown", UIBinderSetIsVisible.New(self, self.MainTeamPanel.PanelCountdown)},
		{"ReconnectSuccess", UIBinderValueChangedCallback.New(self, nil, self.OnReconnectSuccess)},
	}

	self.TheFinerMinerDCfg = MiniGameClientConfig[MiniGameType.TheFinerMiner]

    self.DifficultySelectBarPercent = 0.0 -- 难度条的百分比长度
	self.bBottomToTop = true -- 进度条来回移动是否为自底向上

	self.DifficultyBarPauseTime = nil -- 选择难度条动画暂停时间点
	self.CircleYellowPauseTime = nil -- 玩法面板圆圈来回缩放暂停时间点
	self.bLarger = true -- 是否扩大

    self.ActBtnRecoverNeedNum = 0 -- 操作按钮恢复点击状态计数器
	self.HandFeelDelayTimer = nil -- 操作手感延迟显示计时器

	self:InitCirclePanelState()
	self.DifficultyLen = 0 -- 初始化获得进度条长度
	local Size = UIUtil.CanvasSlotGetSize(self.ProBarRed1)
	if Size then
		self.DifficultyLen = Size.Y or 0
	end

	self.bWaitConfirmForceQuit = false -- 是否处于等待强退确认中
end

function TheFinerMinerMainPanelView:OnDestroy()

end

function TheFinerMinerMainPanelView:OnShow()
	self:SetActBtnEnbale(true) -- 弱网重连后会重新打开界面，此时需打开按钮的禁用状态
	UIUtil.SetIsVisible(self.MainLBottomPanel, false)
	--self.MainLBottomPanel:SetButtonEmotionVisible(false)
	--self.MainLBottomPanel:SetButtonPhotoVisible(false)
	self.MainTeamPanel:SetShowGameInfo()
	--- 图标显示逻辑
	local GameIconWidget = self.MainTeamPanel.IconGame
	local ClientDef = self.TheFinerMinerDCfg
	if GameIconWidget and ClientDef then
		UIUtil.ImageSetBrushFromAssetPath(GameIconWidget, ClientDef.IconGamePath)
	end
end

function TheFinerMinerMainPanelView:OnHide()
	self:ClearAllTheTimer()
	self:StopAllAnimations()
	self:StopAllLoopAudio()
	self.ChooseDifficulty:ClearCallBack()
	--ViewModel.bForceEmotionBtnHide = false
end

function TheFinerMinerMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCut, self.OnDifficultyActBtnClick) -- 选择难度
	UIUtil.AddOnClickedEvent(self, self.BtnCut1, self.OnCutActBtnClick) -- 采矿动作
	UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnBtnInfoClick)
	self:BindBtnCloseCallBack()
end

function TheFinerMinerMainPanelView:OnRegisterGameEvent()

end

function TheFinerMinerMainPanelView:OnRegisterBinder()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

--- 获取UIView关联的VM
function TheFinerMinerMainPanelView:GetTheParamsVM()
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

--- 获取表格内的最大半径
function TheFinerMinerMainPanelView:GetTheMaxRadius()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	local DifficultyLv = MiniGameInst:GetDifficulty()
	local DifficultyCfg = DifficultControlCfg:FindCfgByKey(DifficultyLv)
	if DifficultyCfg == nil then
		return
	end
	local MaxRadius = DifficultyCfg.TotalValue or 140
	return MaxRadius
end

--- 初始化采矿提示圈状态
function TheFinerMinerMainPanelView:InitCirclePanelState()
	local CircleRed = self.ImgCircleRed
	if CircleRed then
		UIUtil.SetIsVisible(CircleRed, false)
	end

	local CircleBlue = self.BluePanel
	if CircleBlue then
		UIUtil.SetIsVisible(CircleBlue, false)
	end

	local CircleYellow = self.ImgCircleYellow
	if CircleYellow then
		UIUtil.SetIsVisible(CircleYellow, true)
		CircleYellow:SetRenderScale(FVector2D(0, 0))
	end
end

--- 清除所有timer
function TheFinerMinerMainPanelView:ClearAllTheTimer()
	local MainPanelPointerMoveTimer = self.MainPanelPointerMoveTimer
	if MainPanelPointerMoveTimer then
		TimerMgr:CancelTimer(MainPanelPointerMoveTimer)
		self.MainPanelPointerMoveTimer = nil
	end

	local HandFeelDelayTimer = self.HandFeelDelayTimer  
	if HandFeelDelayTimer then
		TimerMgr:CancelTimer(HandFeelDelayTimer)
		self.HandFeelDelayTimer = nil
	end
end

--- 设定界面功能说明内容
function TheFinerMinerMainPanelView:SetThePanelUseTips(Widget, Content)
	if Widget == nil then
		return
	end
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	ViewModel.TextTipsTitle = Content
end

--- 设定特定圆圈的半径
function TheFinerMinerMainPanelView:SetTheCircleRadius(CircleType, ScalePercent)
	local ImgCircle
	if CircleType == TheFinerMinerCircleType.Yellow then
		ImgCircle = self.ImgCircleYellow
	elseif CircleType == TheFinerMinerCircleType.Blue then
		ImgCircle = self.ImgCircleBlue
		UIUtil.SetIsVisible(self.BluePanel, true)
	elseif CircleType == TheFinerMinerCircleType.Red then
		ImgCircle = self.ImgCircleRed
	end

	if ImgCircle == nil then
		return
	end

	local ScaleX = TheFinerMinerCircleSize[CircleType] * ScalePercent
	UIUtil.CanvasSlotSetSize(ImgCircle, FVector2D(ScaleX, ScaleX))
	
end

--- 游戏开始刷新界面组件状态
function TheFinerMinerMainPanelView:ResetSubViewState()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	self:HideShootingTips()
	self:UnRegisterTimer(self.HandFeelDelayTimer)
	ViewModel.bShowDifficultyPanel = false -- 隐藏选择难度界面
	ViewModel.bShowCutPanel = true -- 显示砍伐面板
	self:SetActBtnEnbale(false) --恢复按钮点击状态
	-- 清除动画暂停时间点
	self.CircleYellowPauseTime = nil 
	self.DifficultyBarPauseTime = nil
	
	ViewModel.bShowCutTimePanel = true
	self:InitCirclePanelState() -- 重置圆圈状态
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarBlue, "ProgressEnd", 1)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressStart", 1)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressEnd", 1)
	self:PlayAnimation(self.AnimProBarYellow)
end

--- 启动难度条动画
function TheFinerMinerMainPanelView:StartDifficultyBarSwingTimer(bInit)
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
	return
	end

	local AniBarSwing = self.AnimProBarChooseLoop
	if AniBarSwing == nil then
		return
	end
	-- 设定难度选择条动画播放速度
	local ClientDef = self.TheFinerMinerDCfg
	local DifficultyMoveSpeed = ClientDef.DifficultySpeed
	local PauseTimePoint = self.DifficultyBarPauseTime or 0
	self:PlayAnimation(AniBarSwing, bInit and 0 or PauseTimePoint, 0, nil, DifficultyMoveSpeed)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultLoop)
end

--- 停止难度条摆动计时器
function TheFinerMinerMainPanelView:StopDifficultyBarSwingTimer()
	self.DifficultyBarPauseTime = self:PauseAnimation(self.AnimProBarChooseLoop)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultStop)
end

--- 启动圆圈移动动计时器
function TheFinerMinerMainPanelView:StartCircleSwingTimer()
	if self.bWaitConfirmForceQuit then
		return
	end

	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
	return
	end

	local AniCircleSwing = self.AnimCircleYellowLoop
	if AniCircleSwing == nil then
		return
	end

	local Speed = GameInst:GetTheSpeedInTheRound() or 0
	local PauseTimePoint = self.CircleYellowPauseTime or 0
	self:PlayAnimation(AniCircleSwing, PauseTimePoint, 0, nil, Speed)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.CircleLoop)
	GoldSaucerMiniGameMgr.ChangeUISoundRTPCValue("Speed_circle", GameInst:GetRoundIndex())
end

--- 停止圆圈摆动计时器
function TheFinerMinerMainPanelView:StopCircleSwingTimer()
	self.CircleYellowPauseTime = self:PauseAnimation(self.AnimCircleYellowLoop)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.CircleLoopStop)
end

--- 显示手感UI
function TheFinerMinerMainPanelView:ShowTextTips()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	local GameInst = ViewModel.MiniGame
    if GameInst == nil then
        return
    end

	self:ShowShootingTips()
	self.ShootingTips:UpdateMainPanelData(ViewModel)
	self.HandFeelDelayTimer = self:RegisterTimer(function()
		self:CheckActBtnRecover()
		self.HandFeelDelayTimer = nil
		GameInst:ViewProcessEnd()
	end, ShootTipsAnimTime, 0, 1)
end

function TheFinerMinerMainPanelView:ShowShootingTips()
	if self.ShootingTips then
		return
	end
	self.ShootingTips = _G.UIViewMgr:CreateViewByName(ShootingTipsBPName, ObjectGCType.NoCache, self, true, true, nil)
	if self.ShootingTips == nil then
		return
	end
	self.TheFinerMinerPanel:AddChildToCanvas(self.ShootingTips)
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
	_G.UIViewMgr:ShowSubView(self.ShootingTips)
end

function TheFinerMinerMainPanelView:HideShootingTips()
	if self.ShootingTips == nil then
		return
	end
	_G.UIViewMgr:HideSubView(self.ShootingTips)
	self.TheFinerMinerPanel:RemoveChild(self.ShootingTips)
	_G.UIViewMgr:RecycleView(self.ShootingTips)
	self.ShootingTips = nil
end

--- 更新游戏进度条实际表现
function TheFinerMinerMainPanelView:UpdateProgresChangeView(CurProgress, LastProgress)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarBlue, "ProgressEnd", CurProgress)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressStart", CurProgress)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressEnd", LastProgress)
	self:PlayAnimation(self.AnimProBarYellow)
	--self:RegisterTimer(, GoldSaucerMiniGameDefine.ProgressCutTimeCost, 0, 1)
end

function TheFinerMinerMainPanelView:OnMiniGameProgressChanged(NewValue)
    if NewValue == 0 then
		return
	end

	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	local CurProgress = ViewModel.Progress
	local LastProgress = ViewModel.LastProgress
	
	self:RegisterTimer(function()
		self:UpdateProgresChangeView(CurProgress, LastProgress)
		self:ShowTextTips()
	end, ShootTipsDelayTime)
end

--- 设定难度进度条标志位置
function TheFinerMinerMainPanelView:SetLevelPosition(DifficultyType, bShowPanelFirst)
	local WidgetLevelMark
	if DifficultyType == MiniGameDifficulty.Sabotender then
		WidgetLevelMark = bShowPanelFirst and self.ImgSimple or self.ImgSimple2
	elseif DifficultyType == MiniGameDifficulty.Morbol then
		WidgetLevelMark = bShowPanelFirst and self.ImgMedium or self.ImgMedium2
	elseif DifficultyType == MiniGameDifficulty.Titan then
		WidgetLevelMark = bShowPanelFirst and self.ImgDifficulty or self.ImgDifficulty2
	end

	if WidgetLevelMark == nil then
		return
	end

	local Position = UIUtil.CanvasSlotGetPosition(WidgetLevelMark)
	if Position == nil then
		return
	end

	local PositionX = Position.X or 0
	local ProBarLen = self.DifficultyLen
	if ProBarLen == nil then
		return
	end
	local ClientDef = self.TheFinerMinerDCfg
	if ClientDef == nil then
		return
	end

	local DifficultyPercentage = ClientDef.DifficultyPercentage
	if DifficultyPercentage == nil then
		return
	end

	local Percent = DifficultyPercentage[DifficultyType] or 0
	local PositionPercent 
	if DifficultyType == MiniGameDifficulty.Sabotender then
		PositionPercent = bShowPanelFirst and 1 - Percent / 2 or Percent / 2
	else
		PositionPercent = bShowPanelFirst and 1 - Percent or Percent
	end

	if PositionPercent then
		local PositionY = ProBarLen * PositionPercent
		UIUtil.CanvasSlotSetPosition(WidgetLevelMark, _G.UE.FVector2D(PositionX, PositionY))
	end
end

--- 设定难度进度条分段长度
function TheFinerMinerMainPanelView:SetProBarPercent(DifficultyType, bShowPanelFirst)
	local WidgetProBar
	if DifficultyType == MiniGameDifficulty.Sabotender then
		WidgetProBar = bShowPanelFirst and self.ProBarGreen1 or self.ProBarGreen2
	elseif DifficultyType == MiniGameDifficulty.Morbol then
		WidgetProBar = bShowPanelFirst and self.ProBarYellow1 or self.ProBarYellow2
	elseif DifficultyType == MiniGameDifficulty.Titan then
		WidgetProBar = bShowPanelFirst and self.ProBarRed1 or self.ProBarRed2
	end

	if WidgetProBar == nil then
		return
	end

	local ClientDef = self.TheFinerMinerDCfg
	if ClientDef == nil then
		return
	end

	local DifficultyPercentage = ClientDef.DifficultyPercentage
	if DifficultyPercentage == nil then
		return
	end

	local Percent = DifficultyPercentage[DifficultyType] or 0
	WidgetProBar:SetPercent(Percent)

	self:SetLevelPosition(DifficultyType, bShowPanelFirst)
end

--- 初始化难度选择面板进度条内容
function TheFinerMinerMainPanelView:InitDifficultyPanelView(bShowPanelFirst)
	self:SetProBarPercent(MiniGameDifficulty.Sabotender, bShowPanelFirst)
	self:SetProBarPercent(MiniGameDifficulty.Morbol, bShowPanelFirst)
	self:SetProBarPercent(MiniGameDifficulty.Titan, bShowPanelFirst)
end

--- 初始化难度进度条状态
function TheFinerMinerMainPanelView:InitDifficultySelectPanel()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	ViewModel.bShowObtainPanel = false
	ViewModel.bShowDifficultyPanel = true
    ViewModel.bShowCutPanel = false

	self:SetActBtnEnbale(true)
	-- 随机难度条panel
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	local RandomNum = math.random(1, 2)
	local bShowPanelFirst = RandomNum == 1
	UIUtil.SetIsVisible(self.ProBarPanel1, bShowPanelFirst)
	UIUtil.SetIsVisible(self.LevelPanel1, bShowPanelFirst)
	UIUtil.SetIsVisible(self.ProBarPanel2, not bShowPanelFirst)
	UIUtil.SetIsVisible(self.LevelPanel2, not bShowPanelFirst)
	self.bBottomToTop = bShowPanelFirst
	self:InitDifficultyPanelView(bShowPanelFirst)
	self.ProBarChoose:SetRenderScale(_G.UE.FVector2D(1, 0))
end

--- 刷新选择难度状态
function TheFinerMinerMainPanelView:UpdateDifficultySelectedInfo()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel then
		ViewModel.bShowPanelCountDown = true
	end

	local GameInst = ViewModel.MiniGame
	if not GameInst then
		return
	end
	
	local bRewar = GameInst:GetIsReChallenge()
	if bRewar then
		self:PlayAnimIn()
	end
    -- 播放选择难度标题动画
	self:SetThePanelUseTips(self.TextDifficulty, LSTR(380011))
	self:SetTheHelpInfoTips(MiniGameStageType.DifficultySelect)
	self:PlayAnimation(self.AnimDifficultyTips)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultChooseTips)
	UIUtil.SetIsVisible(self.ChooseDifficulty, false)
	self:HideShootingTips()
	self:UnRegisterTimer(self.HandFeelDelayTimer)
	self:InitDifficultySelectPanel()
	self:StartDifficultyBarSwingTimer(true)
	self:PlayAnimation(self.AnimDifficultyPanelLoop, 0, 0, nil, 1.0)
end

--- 显示难度展示界面
function TheFinerMinerMainPanelView:ShowDifficultyShowPanel()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

    local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	ViewModel.bShowDifficultyPanel = false
	local ShowDifficultyPanel = self.ChooseDifficulty
	if ShowDifficultyPanel then
		UIUtil.SetIsVisible(ShowDifficultyPanel, true)
		ShowDifficultyPanel:UpdateMainPanel(ViewModel, function()
			UIUtil.SetIsVisible(ShowDifficultyPanel, false)
			self:StartDelayShowPanel()
		end)
	end
end

--- 显示游戏开始提示信息
function TheFinerMinerMainPanelView:StartDelayShowPanel()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

    local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	self:ResetSubViewState()
	self:SetThePanelUseTips(self.TextTips1, LSTR(380031))
	self:SetTheHelpInfoTips(MiniGameStageType.Update)
	self:PlayAnimation(self.AnimCutPanelIn)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.CutPanelIn)
	self:PlayAnimation(self.AnimTips)
	self:PlayAnimation(self.AnimPointerTimeTrigger, 0.73)
	--- 设定背景特效
	local RoundIndex = MiniGameInst:GetRoundIndex() + 1 or 1
	local bShowEffect = RoundIndex > 1
	UIUtil.SetIsVisible(self.EFF_1, bShowEffect)
	if bShowEffect then
		if RoundIndex <= GoldSaucerMiniGameDefine.CutPanelBGEffectLimit then
			self:PlayAnimation(self.AnimCutPanelDoubling13)
			self.P_EFF_OutOnALimb_2:ResetParticle()
			self.P_EFF_OutOnALimb_4:ResetParticle()
		else
			self:PlayAnimation(self.AnimCutPanelDoubling45)
			self.P_EFF_OutOnALimb_1:ResetParticle()
			self.P_EFF_OutOnALimb_3:ResetParticle()
		end
	end
	_G.ObjectMgr:CollectGarbage(false)
end

--- 刷新开始阶段界面状态(选择难度后)
function TheFinerMinerMainPanelView:UpdateStartInfoAfterDifficultSelected()
	-- 播放收起选择难度界面
	self:PlayAnimation(self.AnimDifficultyPanelCut)
	self:StopDifficultyBarSwingTimer() -- 去除音效
	-- 回调中显示难度展示界面
end

--- 刷新当前轮数实际能够获取的奖励数量
function TheFinerMinerMainPanelView:UpdateRewardPanel()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	ViewModel.bShowObtainPanel = true

	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end

	ViewModel.RewardGot = tostring(GameInst:GetTheRewardGotInTheRound())
end

--- 初始化游戏进行状态的界面信息
function TheFinerMinerMainPanelView:UpdateRunTimeInfo()
	self:UpdateRewardPanel()
	self:SetActBtnEnbale(true)
    self:StartCircleSwingTimer()
	self:PlayAnimation(self.AnimCutPanelLoop, 0, 0, nil, 1.0)
end

--- 清理游戏单局动画for再次挑战二次确认菜单
function TheFinerMinerMainPanelView:UpdateEndStateInfo()
	
end

--- 刷新结算界面信息
function TheFinerMinerMainPanelView:UpdateRewardInfo()
	GoldSaucerMiniGameMgr:SendMsgAloneTreeExitReq(MiniGameType.TheFinerMiner)
end

--- 刷新失败信息展示信息
function TheFinerMinerMainPanelView:UpdateFailInfoShow()
    local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

    local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end

	ViewModel.bShowCutTimePanel = false
	UIUtil.SetIsVisible(self.ImgCircleYellow, false)
	UIUtil.SetIsVisible(self.StatePanel, false)
    -- 展示标准位置
    local FailPos = MiniGameInst:GetFailReasonPos()
    if FailPos == 0 then
        FLOG_ERROR("TheFinerMinerMainPanelView:UpdateFailInfoShow zero is not valid")
        return
    end
	local RedCircle = self.ImgCircleRed
	if RedCircle == nil then
		return
	end
	local MaxRadius = self:GetTheMaxRadius()
	if not UIUtil.IsVisible(RedCircle) then
		UIUtil.SetIsVisible(RedCircle, true)
	end
	local ScalePercent = FailPos / MaxRadius
	self:SetTheCircleRadius(TheFinerMinerCircleType.Red, ScalePercent)
	self:PlayAnimation(self.AnimCircleRedLight)

	local EndState = MiniGameInst:GetRoundEndState()
    if EndState == MiniGameRoundEndState.FailChance then
        -- 播放原因tips（次数耗尽）
		self:SetThePanelUseTips(self.TextTips1, LSTR(380017))
    elseif EndState == MiniGameRoundEndState.FailTime then
        -- 播放错误原因tips（时间结束）
		self:SetThePanelUseTips(self.TextTips1, LSTR(380016))
		UIUtil.SetIsVisible(self.ImgCircleBlue, false)
    end
	self:PlayAnimation(self.AnimTips)
	self:SetActBtnEnbale(false)
    local function ShowFailRewardPanel()
        -- 动画后展示失败结算界面
		UIViewMgr:ShowView(UIViewID.TheFinerMinerSettlementPanel, ViewModel)
		if RedCircle then
			UIUtil.SetIsVisible(RedCircle, false)
		end
    end
	self:RegisterTimer(ShowFailRewardPanel, GoldSaucerMiniGameDefine.FailShowConstantTime, 0, 1)
end

--- 刷新新一轮的奖励变化
function TheFinerMinerMainPanelView:ShowRewardChangeInNewRound()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	local MiniGameInst = ViewModel.MiniGame
	if MiniGameInst == nil then
		return
	end
	-- 播放奖励变化动画
	ViewModel.bShowRewardAdd = true
	local RewardLastRound = ViewModel.RewardGot
	local RewardThisRound = MiniGameInst:GetTheRewardGotInTheRound()
	local RewardAdd = RewardThisRound - RewardLastRound
	ViewModel.RewardAdd = tostring(RewardAdd)
	local function TeamObtainAnimCallBack()
		ViewModel.bShowRewardAdd = false
		self:UpdateRewardPanel()
	end
	local MainTeamWidget = self.MainTeamPanel
	if MainTeamWidget then
		MainTeamWidget.AnimObtainNumberInCallBack = TeamObtainAnimCallBack
		MainTeamWidget:PlayAnimation(MainTeamWidget.AnimObtainNumberIn)
	end
	--self:PlayAnimation(self.AnimObtainNumberIn)
	--[[self:RegisterTimer(function()
		ViewModel.bShowRewardAdd = false
	end, 1.5, 0, 1)--]]
end

--- 刷新再次挑战展示信息
function TheFinerMinerMainPanelView:UpdateRestartInfo()
	self:ShowRewardChangeInNewRound()
    self:StartDelayShowPanel()
end

function TheFinerMinerMainPanelView:OnMiniGameStateChanged(NewValue, OldValue)
	FLOG_INFO("TheFinerMinerMainPanelView:OnMiniGameStateChanged NewValue:%s, OldValue:%s", NewValue, OldValue)
    if OldValue == MiniGameStageType.Enter and NewValue == MiniGameStageType.DifficultySelect then
        self:UpdateDifficultySelectedInfo()
    elseif OldValue == MiniGameStageType.DifficultySelect and NewValue == MiniGameStageType.Start then
        self:UpdateStartInfoAfterDifficultSelected()
    elseif OldValue == MiniGameStageType.Start and NewValue == MiniGameStageType.Update then
        self:UpdateRunTimeInfo()
	elseif OldValue == MiniGameStageType.Update and NewValue == MiniGameStageType.End then
		self:HideShootingTips()
		self:StopCircleSwingTimer()
    elseif OldValue == MiniGameStageType.End and NewValue == MiniGameStageType.Reward then
        self:UpdateRewardInfo()
    elseif OldValue == MiniGameStageType.Reward and NewValue == MiniGameStageType.FailInfoShow then
        self:UpdateFailInfoShow()
    elseif OldValue == MiniGameStageType.End and NewValue == MiniGameStageType.Restart then
        self:UpdateRestartInfo()
    elseif OldValue == MiniGameStageType.Restart and NewValue == MiniGameStageType.Update then
        self:UpdateRunTimeInfo()
    end
end

--- 控制操作按钮的点击状态l
function TheFinerMinerMainPanelView:SetActBtnEnbale(bEnable)
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	ViewModel.bActBtnEnable = bEnable
end

--- 显示上次挖采记录
function TheFinerMinerMainPanelView:ShowLastCutRecord()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

    local GameInst = ViewModel.MiniGame
    if GameInst == nil then
        return
    end

    local LastCutPos = GameInst:GetLatestActPos()
    if LastCutPos == nil then
		return
	end

	local BlueCircle = self.ImgCircleBlue
	if BlueCircle == nil then
		return
	end
	local MaxRadius = self:GetTheMaxRadius()
	if not UIUtil.IsVisible(BlueCircle) then
		UIUtil.SetIsVisible(BlueCircle, true)
	end
	local ScalePercent = LastCutPos / MaxRadius
	self:SetTheCircleRadius(TheFinerMinerCircleType.Blue, ScalePercent)
	
	-- 显示上一次挖采距离指示器
	UIUtil.SetIsVisible(self.StatePanel, false)
	local LatestProgressLv = GameInst:GetLatestProgressLv()
	if LatestProgressLv == nil or LatestProgressLv == MiniGameProgressType.Bad then
		return
	end

	UIUtil.SetIsVisible(self.StatePanel, true)
	self:PlayAnimation(self.AnimStateIn)
	if LatestProgressLv == MiniGameProgressType.Good then
		UIUtil.SetIsVisible(self.ImgState, true)
		UIUtil.SetIsVisible(self.ImgStateYellow, false)
	else
		UIUtil.SetIsVisible(self.ImgState, false)
		UIUtil.SetIsVisible(self.ImgStateYellow, true)
	end
	
	if LatestProgressLv == MiniGameProgressType.Perfect then
		-- TODO 发光特效
	end
end

--- 检查操作按钮是否可以恢复
function TheFinerMinerMainPanelView:CheckActBtnRecover()
    self.ActBtnRecoverNeedNum = self.ActBtnRecoverNeedNum - 1
    local CurNeedNum = self.ActBtnRecoverNeedNum
    if CurNeedNum > 0 then
        return
    end
	self:SetActBtnEnbale(true)
	self:PlayAnimation(self.AnimCutPanelCutResume)
    GoldSaucerMiniGameMgr:ActFeedBackRecoverTimeLoop(MiniGameType.TheFinerMiner)
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

    local GameInst = ViewModel.MiniGame
    if GameInst == nil then
        return
    end

	local Progress = GameInst:GetAchieveRewardProgress()
	if Progress >= 1 then
		UIUtil.SetIsVisible(self.StatePanel, false) 
		return
	end
    self:StartCircleSwingTimer()

	-- 显示上次挖采记录
	self:ShowLastCutRecord()
end

function TheFinerMinerMainPanelView:BindBtnCloseCallBack()
	local function EnsureFailQuit()
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst == nil then
			return
		end
		GameInst:SetIsForceEnd(true)
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.TheFinerMiner)
		GoldSaucerMiniGameMgr:SendMsgAloneTreeExitReq(MiniGameType.TheFinerMiner)
	end

	local function RecoverGameLoop()
		self.bWaitConfirmForceQuit = false
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst == nil then
			return
		end
		local GameState = GameInst:GetGameState()
		if GameState == MiniGameStageType.DifficultySelect then
			self:StartDifficultyBarSwingTimer()
		elseif GameState == MiniGameStageType.Update then
			self:StartCircleSwingTimer()
		end
	end	
	local function OnBtnCloseClick(View)
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst == nil then
			return
		end
		local GameState = GameInst:GetGameState()
		if GameState == MiniGameStageType.DifficultySelect then
			self:StopDifficultyBarSwingTimer()
		elseif GameState == MiniGameStageType.Update then
			self:StopCircleSwingTimer()
			self.bWaitConfirmForceQuit = true
		end
		--GameInst:StopGameTimeLoop(true)
		GoldSaucerMiniGameMgr:ShowEnsureExitTip(MiniGameType.TheFinerMiner, EnsureFailQuit, RecoverGameLoop)
	end
	self.BtnClose:SetCallback(self, OnBtnCloseClick)
end

--- 发送客户端判断的难度结果
function TheFinerMinerMainPanelView:SendTheSelectDifficultResult()
    local DCfg = self.TheFinerMinerDCfg
    if DCfg == nil then
        return
    end

	local BarWidget = self.ProBarChoose
	if BarWidget == nil then
        return
    end
	local BarRenderTransform = BarWidget.RenderTransform
	if BarRenderTransform == nil then
        return
    end

	local WidgetScale = BarRenderTransform.Scale
	if WidgetScale == nil then
		return
	end
	local bUp = self.bBottomToTop
	local AniStopY = WidgetScale.Y
    local SelectPercent = bUp and AniStopY or 1 - AniStopY
    if type(SelectPercent) ~= "number" then
        return
    end
    local DifficultyPercentage = DCfg.DifficultyPercentage
    if DifficultyPercentage == nil or next(DifficultyPercentage) == nil then
        return
    end
    for index, Percent in ipairs(DifficultyPercentage) do
		if SelectPercent <= Percent then
			GoldSaucerMiniGameMgr:SetTheMiniGameDifficulty(MiniGameType.TheFinerMiner, index)
			break
		end
    end
end

--- 选择难度按钮点击回调
function TheFinerMinerMainPanelView:OnDifficultyActBtnClick()
    local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	self:SetActBtnEnbale(false)
	
	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end
	GameInst:StopGameTimeLoop()
	self:StopDifficultyBarSwingTimer()

	--local Dcfg = self.TheFinerMinerDCfg
    local CurGameState = ViewModel.GameState
    if CurGameState == MiniGameStageType.DifficultySelect then
		self:SendTheSelectDifficultResult()
		--[[GameInst:PlayActionTimeLineByMajor(AnimTimeLineSourceKey.MiningAct)
		self:RegisterTimer(function()
			GameInst:PlayActionTimeLineByMajor(AnimTimeLineSourceKey.MiningIdle)
			
		end, 2, nil, 1) --]]
    end
end

--- 判断圆圈位置，发送判断结果
function TheFinerMinerMainPanelView:SendTheCutDownAngleResult()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	local DCfg = self.TheFinerMinerDCfg
    if DCfg == nil then
        return
    end

	local CircleWidget = self.ImgCircleYellow
	if CircleWidget == nil then
        return
    end
	local CircleWidgetRenderTransform = CircleWidget.RenderTransform
	if CircleWidgetRenderTransform == nil then
        return
    end

	local WidgetScale = CircleWidgetRenderTransform.Scale
	if WidgetScale == nil then
		return
	end
	local CurStopPercent = WidgetScale.Y
	local MaxRadius = self:GetTheMaxRadius()
	local AngleMsgUse = MaxRadius * CurStopPercent

	-- 服务器限制，必须在0~139
	if AngleMsgUse >= MaxRadius then
		AngleMsgUse = MaxRadius - 1
	end

	GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound(MiniGameType.TheFinerMiner, AngleMsgUse)
end

--- 挖采结果按钮点击回调
function TheFinerMinerMainPanelView:OnCutActBtnClick()
    local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	self:SetActBtnEnbale(false)
	self:PlayAnimation(self.AnimCutPanelCut)
	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end
	GameInst:LockTheTimeSettle()
	--GameInst:StopGameTimeLoop(true)
	self:StopCircleSwingTimer()
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.PointerStop)
    local CurGameState = ViewModel.GameState
    if CurGameState == MiniGameStageType.Update then
		self:SendTheCutDownAngleResult()-- 为匹配动画播放与特效显示，将协议发送提前至人物动作初始播放阶段
		local DCfg = self.TheFinerMinerDCfg
		self.ActBtnRecoverNeedNum = DCfg.ActBtnRecoverCondNumUpdate
    end
end

--- 小游戏tips
function TheFinerMinerMainPanelView:OnBtnInfoClick()
	UIUtil.SetIsVisible(self.TopTips, true)
	self:PlayAnimation(self.AnimTopTipsIn)
end

--- 动画结束统一回调
function TheFinerMinerMainPanelView:OnAnimationFinished(Animation)
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	
	local GameState = MiniGameInst:GetGameState()
	if Animation == self.AnimProBarYellow and GameState == MiniGameStageType.Update then
		local ActBtnEnable = ViewModel.bActBtnEnable
		if not ActBtnEnable then
			self:CheckActBtnRecover()
		end
	elseif Animation == self.AnimDifficultyPanelCut then
		self:ShowDifficultyShowPanel()
	elseif Animation == self.AnimCutPanelIn then
		FLOG_INFO("TheFinerMinerMainPanelView:OnAnimationFinished GameRun")
		MiniGameInst:StartGameTimeLoop(MiniGameInst.GameRun)
	elseif Animation == self.AnimObtainNumberIn then
		self:UpdateRewardPanel()
	elseif Animation == self.AnimDifficultyTips then
		-- TODO:播放按钮动效
		--[[self:RegisterTimer(function()
			self:StartDifficultyBarSwingTimer(true)
			self:PlayAnimation(self.AnimDifficultyPanelLoop, 0, 0, nil, 1.0)
		end, 0.5, 0, 1)--]]
	elseif Animation == self.AnimCutPanelDoubling13 then
		self.P_EFF_OutOnALimb_1:ResetParticle()
	elseif Animation == self.AnimCutPanelDoubling45 then
		self.P_EFF_OutOnALimb_2:ResetParticle()
	end
end

--- 玩家游玩次数下降
function TheFinerMinerMainPanelView:OnPlayNumberTrigger(NewChances)
	local ChancesNumber = tonumber(NewChances)
	if ChancesNumber and ChancesNumber <= 3 then
		self.TextPointerNumber_1:SetText(NewChances)
		self:PlayAnimation(self.AnimPointerNumberTrigger)
	end
end

--- 玩家游玩时间减少
function TheFinerMinerMainPanelView:OnComeInKeyTime(bInKeyTime)
	if bInKeyTime then
		self:PlayAnimation(self.AnimPointerTimeTrigger, 0, 0, nil, 1.0)
	else
		self:PlayAnimation(self.AnimPointerTimeTrigger, 0.73)
	end
end

--- 重连成功
function TheFinerMinerMainPanelView:OnReconnectSuccess(bSuccess)
	if not bSuccess then
		return
	end

	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	
	local GameState = MiniGameInst:GetGameState()
	if GameState == MiniGameStageType.DifficultySelect then
		self:SendTheSelectDifficultResult()
	end
	ViewModel.ReconnectSuccess = false
end


--- 设定功能说明信息
---@param GameStageType GoldSaucerMiniGameDefine.MiniGameStageType
function TheFinerMinerMainPanelView:SetTheHelpInfoTips(GameStageType)
	local MainTeamPanel = self.MainTeamPanel
	if not MainTeamPanel then
		return
	end

	local nforBtn = MainTeamPanel.nforBtn
	if not nforBtn then
		return
	end

	nforBtn:SetHelpInfoID(GoldSaucerMiniGameMgr:GetThePanelHelpInfoID(MiniGameType.OutOnALimb, GameStageType) or -1)
end

function TheFinerMinerMainPanelView:StopAllLoopAudio()
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultStop)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.CircleLoopStop)
end


return TheFinerMinerMainPanelView