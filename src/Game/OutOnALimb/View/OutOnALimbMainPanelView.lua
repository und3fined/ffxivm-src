---
--- Author: alexchen
--- DateTime: 2023-11-09 14:42
--- Description:孤树无援主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
--local EventID = require("Define/EventID")
--local MsgBoxUtil = require("Utils/MsgBoxUtil")
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameDifficulty = GoldSaucerMiniGameDefine.MiniGameDifficulty
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local AudioType = GoldSaucerMiniGameDefine.AudioType
local TimerMgr = _G.TimerMgr
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local DifficultControlCfg = require("TableCfg/OutOnALimbDifficultyControlCfg")
local ObjectGCType = require("Define/ObjectGCType")
local CommonUtil = require("Utils/CommonUtil")

local ShootingTipsBPName = "OutOnALimb/GoldSaucer_OutOnALimbShootingTipsItem_UIBP"
local ShootTipsAnimTime = 2 -- 手感Tips显示时间
local ShootTipsDelayTime = 1.3 -- 手感Tips延迟显示时间

---@class OutOnALimbMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
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
---@field FCanvasPanel UFCanvasPanel
---@field HorizontalObtain UFHorizontalBox
---@field HorizontalObtain1 UFHorizontalBox
---@field ImgArrow UFImage
---@field ImgAxe UFImage
---@field ImgBgBlack UFImage
---@field ImgCutAxe UFImage
---@field ImgCutTree UFImage
---@field ImgCutTree2 UFImage
---@field ImgCutTree3 UFImage
---@field ImgCutTree4 UFImage
---@field ImgDifficulty UFImage
---@field ImgDifficulty2 UFImage
---@field ImgLetter1 UFImage
---@field ImgLetter2 UFImage
---@field ImgLetter3 UFImage
---@field ImgLetter4 UFImage
---@field ImgLetter5 UFImage
---@field ImgLetter6 UFImage
---@field ImgLetter7 UFImage
---@field ImgLetter8 UFImage
---@field ImgMedium UFImage
---@field ImgMedium2 UFImage
---@field ImgNoCut UFImage
---@field ImgNoCut1 UFImage
---@field ImgPointerSimple UFImage
---@field ImgPriceIcon UFImage
---@field ImgSimple UFImage
---@field ImgSimple2 UFImage
---@field ImgTime UFImage
---@field ImgTimerBlue UFImage
---@field ImgTimerRed UFImage
---@field ImgTopLine UFImage
---@field LevelPanel UFCanvasPanel
---@field LevelPanel2 UFCanvasPanel
---@field MI_DX_Common_GoldSaucer_4 UFImage
---@field MainLBottomPanel MainLBottomPanelView
---@field MainTeamPanel MainTeamPanelView
---@field NumberPanel UFCanvasPanel
---@field ObtainPanel UFCanvasPanel
---@field P_EFF_OutOnALimb_1 UUIParticleEmitter
---@field P_EFF_OutOnALimb_2 UUIParticleEmitter
---@field P_EFF_OutOnALimb_3 UUIParticleEmitter
---@field P_EFF_OutOnALimb_4 UUIParticleEmitter
---@field PointerPanel UFCanvasPanel
---@field PointerStateGrey OutOnALimbPointerItemView
---@field PointerStateRed OutOnALimbPointerItemView
---@field PointerStateYellow OutOnALimbPointerItemView
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
---@field TextCutPanel UFCanvasPanel
---@field TextDifficulty UFTextBlock
---@field TextNumber UFTextBlock
---@field TextNumber1 UFTextBlock
---@field TextObtain UFTextBlock
---@field TextPanel UFCanvasPanel
---@field TextPointerNumber UFTextBlock
---@field TextPointerNumber_1 UFTextBlock
---@field TextPointerTime UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips OutOnALimbTextTipsItemView
---@field TextTips1 UFTextBlock
---@field TextTitle UFTextBlock
---@field TimePanel UFCanvasPanel
---@field TitlePanel UFCanvasPanel
---@field TitleTimePanel UFCanvasPanel
---@field TopTips OutOnALimbTopTipsItemView
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
---@field AnimObtainNumberIn UWidgetAnimation
---@field AnimPointerNumberTrigger UWidgetAnimation
---@field AnimPointerStateYellowLoop UWidgetAnimation
---@field AnimPointerTimeHide UWidgetAnimation
---@field AnimPointerTimeTrigger UWidgetAnimation
---@field AnimProBarChooseLoop UWidgetAnimation
---@field AnimProBarYellow UWidgetAnimation
---@field AnimTips UWidgetAnimation
---@field AnimTopTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OutOnALimbMainPanelView = LuaClass(UIView, true)

function OutOnALimbMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
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
	--self.FCanvasPanel = nil
	--self.HorizontalObtain = nil
	--self.HorizontalObtain1 = nil
	--self.ImgArrow = nil
	--self.ImgAxe = nil
	--self.ImgBgBlack = nil
	--self.ImgCutAxe = nil
	--self.ImgCutTree = nil
	--self.ImgCutTree2 = nil
	--self.ImgCutTree3 = nil
	--self.ImgCutTree4 = nil
	--self.ImgDifficulty = nil
	--self.ImgDifficulty2 = nil
	--self.ImgLetter1 = nil
	--self.ImgLetter2 = nil
	--self.ImgLetter3 = nil
	--self.ImgLetter4 = nil
	--self.ImgLetter5 = nil
	--self.ImgLetter6 = nil
	--self.ImgLetter7 = nil
	--self.ImgLetter8 = nil
	--self.ImgMedium = nil
	--self.ImgMedium2 = nil
	--self.ImgNoCut = nil
	--self.ImgNoCut1 = nil
	--self.ImgPointerSimple = nil
	--self.ImgPriceIcon = nil
	--self.ImgSimple = nil
	--self.ImgSimple2 = nil
	--self.ImgTime = nil
	--self.ImgTimerBlue = nil
	--self.ImgTimerRed = nil
	--self.ImgTopLine = nil
	--self.LevelPanel = nil
	--self.LevelPanel2 = nil
	--self.MI_DX_Common_GoldSaucer_4 = nil
	--self.MainLBottomPanel = nil
	--self.MainTeamPanel = nil
	--self.NumberPanel = nil
	--self.ObtainPanel = nil
	--self.P_EFF_OutOnALimb_1 = nil
	--self.P_EFF_OutOnALimb_2 = nil
	--self.P_EFF_OutOnALimb_3 = nil
	--self.P_EFF_OutOnALimb_4 = nil
	--self.PointerPanel = nil
	--self.PointerStateGrey = nil
	--self.PointerStateRed = nil
	--self.PointerStateYellow = nil
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
	--self.TextCutPanel = nil
	--self.TextDifficulty = nil
	--self.TextNumber = nil
	--self.TextNumber1 = nil
	--self.TextObtain = nil
	--self.TextPanel = nil
	--self.TextPointerNumber = nil
	--self.TextPointerNumber_1 = nil
	--self.TextPointerTime = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TextTips1 = nil
	--self.TextTitle = nil
	--self.TimePanel = nil
	--self.TitlePanel = nil
	--self.TitleTimePanel = nil
	--self.TopTips = nil
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
	--self.AnimObtainNumberIn = nil
	--self.AnimPointerNumberTrigger = nil
	--self.AnimPointerStateYellowLoop = nil
	--self.AnimPointerTimeHide = nil
	--self.AnimPointerTimeTrigger = nil
	--self.AnimProBarChooseLoop = nil
	--self.AnimProBarYellow = nil
	--self.AnimTips = nil
	--self.AnimTopTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OutOnALimbMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.ChooseDifficulty)
	self:AddSubView(self.MainLBottomPanel)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.PointerStateGrey)
	self:AddSubView(self.PointerStateRed)
	self:AddSubView(self.PointerStateYellow)
	self:AddSubView(self.TextTips)
	self:AddSubView(self.TopTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OutOnALimbMainPanelView:OnInit()
	self.Binders = {
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
		--{"YellowPointerAngle", UIBinderSetRenderTransformAngle.New(self, self.PointerStateYellow, true)},
		{"RedPointerAngle", UIBinderSetRenderTransformAngle.New(self, self.PointerStateRed, true)},
		{"GreyPointerAngle", UIBinderSetRenderTransformAngle.New(self, self.PointerStateGrey)},
		{"DifficultyIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgPointerSimple)},
		--{"bTopTipsShow", UIBinderSetIsVisible.New(self, self.TopTips)},
		{"bKeyTime", UIBinderValueChangedCallback.New(self, nil, self.OnComeInKeyTime)},
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

	self.OutOnALimbDCfg = MiniGameClientConfig[MiniGameType.OutOnALimb]
    self.ProgressValueChanged = 1 -- 进度条变化值

    self.DifficultySelectBarPercent = 0.0 -- 难度条的百分比长度
	self.bBottomToTop = true -- 进度条来回移动是否为自底向上

	self.DifficultyBarPauseTime = nil -- 难度条暂停时间点
    self.PointerYellowPauseTime = nil -- 玩法面板指针摇动暂停时间点

    self.ActBtnRecoverNeedNum = 0 -- 操作按钮恢复点击状态计数器
	self.HandFeelDelayTimer = nil -- 操作手感延迟显示计时器
	
	self.bProgressBarInit = true -- 进度条状态是否为初始化，初始化不执行动画结束回调

	self:SetTheCutPointerSource()
	self:InitCutPointerState()

	self.DifficultyLen = 0 -- 初始化获得进度条长度
	local Size = UIUtil.CanvasSlotGetSize(self.ProBarRed1)
	if Size then
		self.DifficultyLen = Size.Y or 0
	end


end

function OutOnALimbMainPanelView:OnDestroy()

end

function OutOnALimbMainPanelView:OnShow()
	self:SetActBtnEnable(true) -- 弱网重连后会重新打开界面，此时需打开按钮的禁用状态
	UIUtil.SetIsVisible(self.TopTips, false)
	UIUtil.SetIsVisible(self.MainLBottomPanel, false)
	--self.MainLBottomPanel:SetButtonEmotionVisible(false)
	--self.MainLBottomPanel:SetButtonPhotoVisible(false)
	self.MainTeamPanel:SetShowGameInfo()

	--- 图标显示逻辑
	local GameIconWidget = self.MainTeamPanel.IconGame
	local ClientDef = self.OutOnALimbDCfg
	if GameIconWidget and ClientDef then
		UIUtil.ImageSetBrushFromAssetPath(GameIconWidget, ClientDef.IconGamePath)
	end
end

function OutOnALimbMainPanelView:OnHide()
	self:ClearAllTheTimer()
	self:StopAllAnimations()
	self:StopAllLoopAudio()
	self.ChooseDifficulty:ClearCallBack()
	--ViewModel.bForceEmotionBtnHide = false
end

function OutOnALimbMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCut, self.OnDifficultyActBtnClick) -- 选择难度
	UIUtil.AddOnClickedEvent(self, self.BtnCut1, self.OnCutActBtnClick) -- 砍伐动作
	UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnBtnInfoClick)
	self:BindBtnCloseCallBack()
end

function OutOnALimbMainPanelView:OnRegisterGameEvent()

end

function OutOnALimbMainPanelView:OnRegisterBinder()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

--- 获取UIView关联的VM
function OutOnALimbMainPanelView:GetTheParamsVM()
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

--- 获取表格内的最大角度
function OutOnALimbMainPanelView:GetTheMaxAngle()
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
	local MaxAngle = DifficultyCfg.TotalValue or 90
	return MaxAngle
end

--- 清除所有timer
function OutOnALimbMainPanelView:ClearAllTheTimer()
	local HandFeelDelayTimer = self.HandFeelDelayTimer  
	if HandFeelDelayTimer then
		TimerMgr:CancelTimer(HandFeelDelayTimer)
		self.HandFeelDelayTimer = nil
	end
	--self.PointerYellowPauseTime = nil
end

function OutOnALimbMainPanelView:BindBtnCloseCallBack()
	local function EnsureFailQuit()
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst == nil then
			return
		end
		
		GameInst:SetIsForceEnd(true)
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.OutOnALimb)
		GoldSaucerMiniGameMgr:SendMsgAloneTreeExitReq(MiniGameType.OutOnALimb)
		--self:StopAllAnimations()
	end

	local function RecoverGameLoop()
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst == nil then
			return
		end

		local GameState = GameInst:GetGameState()
		if GameState == MiniGameStageType.DifficultySelect then
			self:StartDifficultyBarSwingTimer()
		elseif GameState == MiniGameStageType.Update then
			self:StartPointerSwingTimer()
		end
		--GameInst:RecoverGameTimeLoop()
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
			self:StopPointerSwingTimer()
		end
		--GameInst:StopGameTimeLoop(true)
		GoldSaucerMiniGameMgr:ShowEnsureExitTip(MiniGameType.OutOnALimb, EnsureFailQuit, RecoverGameLoop)
	end
	self.BtnClose:SetCallback(self, OnBtnCloseClick)
end

function OutOnALimbMainPanelView:SetTheCutPointerSource()
	local ClientDefine = self.OutOnALimbDCfg
    if ClientDefine == nil then
        return
    end

	local PointerPathDef = ClientDefine.PointSourceDefine
	if PointerPathDef == nil then
		return
	end

	local GreyPointer = self.PointerStateGrey
	if GreyPointer then
		local GreyPath = PointerPathDef.GreyPointerPath
		GreyPointer:SetPointerPath(GreyPath)
	end

	local RedPointer = self.PointerStateRed
	if RedPointer then
		local RedPath = PointerPathDef.RedPointerPath
		RedPointer:SetPointerPath(RedPath)
	end

	local YellowPointer = self.PointerStateYellow
	if YellowPointer then
		local YellowPath = PointerPathDef.YellowPointerPath
		YellowPointer:SetPointerPath(YellowPath)
	end
end

function OutOnALimbMainPanelView:InitCutPointerState()
	local GreyPointer = self.PointerStateGrey
	if GreyPointer then
		GreyPointer:SetMarkState(false)
		UIUtil.SetIsVisible(GreyPointer, false)
	end

	local RedPointer = self.PointerStateRed
	if RedPointer then
		RedPointer:SetMarkState(false)
		UIUtil.SetIsVisible(RedPointer, false)
	end

	local YellowPointer = self.PointerStateYellow
	if YellowPointer then
		YellowPointer:SetMarkState(false)
		UIUtil.SetIsVisible(YellowPointer, true)
		YellowPointer:SetRenderTransformAngle(-45)
	end
end

--- 设定界面功能说明内容
function OutOnALimbMainPanelView:SetThePanelUseTips(Widget, Content)
	if Widget == nil then
		return
	end
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	ViewModel.TextTipsTitle = Content
end

--- 控制操作按钮的点击状态
function OutOnALimbMainPanelView:SetActBtnEnable(bEnable)
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	ViewModel.bActBtnEnable = bEnable
end

--- 检查操作按钮是否可以恢复(时间也开始恢复)
function OutOnALimbMainPanelView:CheckActBtnRecover()
    self.ActBtnRecoverNeedNum = self.ActBtnRecoverNeedNum - 1
    local CurNeedNum = self.ActBtnRecoverNeedNum
    if CurNeedNum > 0 then
        return
    end
	self:SetActBtnEnable(true)
    GoldSaucerMiniGameMgr:ActFeedBackRecoverTimeLoop(MiniGameType.OutOnALimb)
	self:PlayAnimation(self.AnimCutPanelCutResume)
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
		self.PointerStateGrey:SetMarkState(false)
		return
	end
    self:StartPointerSwingTimer()

	-- 显示上次砍树记录
	self:ShowLastCutRecord()
	
end

--- 显示上次砍树记录
function OutOnALimbMainPanelView:ShowLastCutRecord()
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

	local GreyPointer = self.PointerStateGrey
	if GreyPointer == nil then
		return
	end
	local MaxAngle = self:GetTheMaxAngle()
	if not UIUtil.IsVisible(GreyPointer) then
		UIUtil.SetIsVisible(GreyPointer, true)
	end
	ViewModel.GreyPointerAngle = LastCutPos - MaxAngle / 2
	GreyPointer:SetMarkState(false)
	local LatestProgressLv = GameInst:GetLatestProgressLv()
	if LatestProgressLv == nil then
		return
	end

	local DcCfg = self.OutOnALimbDCfg
	if DcCfg == nil then
		return
	end

	local ProgressLevelCfg = DcCfg.ProgressLevel
	if ProgressLevelCfg == nil then
		return
	end

	local LatestProgressCfg = ProgressLevelCfg[LatestProgressLv]
	if LatestProgressCfg == nil then
		return
	end

	local MarkPath = LatestProgressCfg.MarkPath
	if MarkPath then
		GreyPointer:SetMarkState(true)
		GreyPointer:SetMarkPath(MarkPath)
	end
end

--- 发送客户端判断的难度结果
function OutOnALimbMainPanelView:SendTheSelectDifficultResult()
    local DCfg = self.OutOnALimbDCfg
    if DCfg == nil then
        return
    end
    --[[if self.DifficultySelectBarTimer then
        TimerMgr:CancelTimer(self.DifficultySelectBarTimer)
        self.DifficultySelectBarTimer = nil
    end--]]

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
			GoldSaucerMiniGameMgr:SetTheMiniGameDifficulty(MiniGameType.OutOnALimb, index)
			break
		end
    end
end

--- 选择难度按钮点击回调
function OutOnALimbMainPanelView:OnDifficultyActBtnClick()
    local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	self:SetActBtnEnable(false)
	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end
	GameInst:StopGameTimeLoop()
	self:StopDifficultyBarSwingTimer()
	self:StopAnimation(self.AnimDifficultyPanelLoop)
	--local Dcfg = self.OutOnALimbDCfg
    local CurGameState = ViewModel.GameState
    if CurGameState == MiniGameStageType.DifficultySelect then
		self:SendTheSelectDifficultResult()
		--GameInst:PlayActionTimeLineByMajor(AnimTimeLineSourceKey.FellingAct)
		--[[self:RegisterTimer( function()
			--GameInst:PlayActionTimeLineByMajor(AnimTimeLineSourceKey.FellingIdle)
		end, 2, nil, 1) --]]
    end
end

--- 判断指针位置，发送判断结果
function OutOnALimbMainPanelView:SendTheCutDownAngleResult()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	local PointerYellow = self.PointerStateYellow
	if PointerYellow == nil then
		return
	end

	local PointerYellowRenderTransform = PointerYellow.RenderTransform
	if PointerYellow == nil then
        return
    end

	local WidgetAngle = PointerYellowRenderTransform.Angle
	if WidgetAngle == nil then
		return
	end
	local CurStopAngle = WidgetAngle or 0
	local MaxAngle = self:GetTheMaxAngle()
	local AngleMsgUse = CurStopAngle + MaxAngle / 2
	-- 服务器限制，必须在0~89
	if AngleMsgUse >= MaxAngle then
		AngleMsgUse = MaxAngle - 1
	end
	GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound(MiniGameType.OutOnALimb, AngleMsgUse)
end

--- 砍伐结果按钮点击回调
function OutOnALimbMainPanelView:OnCutActBtnClick()
    local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	self:SetActBtnEnable(false)
	self:PlayAnimation(self.AnimCutPanelCut)
	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end
	GameInst:LockTheTimeSettle()
	--GameInst:StopGameTimeLoop(true) -- 2期需求，去除时间暂停
	self:StopPointerSwingTimer()
	self.PointerStateYellow:PlayYellowPointerLight()
    local CurGameState = ViewModel.GameState
    if CurGameState == MiniGameStageType.Update then
		self:SendTheCutDownAngleResult()-- 为匹配动画播放与特效显示，将协议发送提前至人物动作初始播放阶段
		local DCfg = self.OutOnALimbDCfg
		self.ActBtnRecoverNeedNum = DCfg.ActBtnRecoverCondNumUpdate
    end
end

--- 小游戏tips
function OutOnALimbMainPanelView:OnBtnInfoClick()
	UIUtil.SetIsVisible(self.TopTips, true)
	self:PlayAnimation(self.AnimTopTipsIn)
end

--- 显示手感UI
function OutOnALimbMainPanelView:ShowTextTips()
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
		self:UnRegisterTimer(self.HandFeelDelayTimer)
		self.HandFeelDelayTimer = nil
		GameInst:ViewProcessEnd()
	end, ShootTipsAnimTime)
end

function OutOnALimbMainPanelView:ShowShootingTips()
	if self.ShootingTips then
		return
	end
	self.ShootingTips = _G.UIViewMgr:CreateViewByName(ShootingTipsBPName, ObjectGCType.NoCache, self, true, true, nil)
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
	_G.UIViewMgr:ShowSubView(self.ShootingTips)
end

function OutOnALimbMainPanelView:HideShootingTips()
	if self.ShootingTips == nil then
		return
	end
	_G.UIViewMgr:HideSubView(self.ShootingTips)
	self.FCanvasPanel:RemoveChild(self.ShootingTips)
	_G.UIViewMgr:RecycleView(self.ShootingTips)
	self.ShootingTips = nil
end

--- 更新游戏进度条实际表现
function OutOnALimbMainPanelView:UpdateProgresChangeView(CurProgress, LastProgress)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarBlue, "ProgressEnd", CurProgress)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressStart", CurProgress)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressEnd", LastProgress)
	self:PlayAnimation(self.AnimProBarYellow)
end

function OutOnALimbMainPanelView:OnMiniGameProgressChanged(NewValue)
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
		FLOG_INFO("OutOnALimbMainPanelView:OnMiniGameProgressChanged NewValue:%s, OldValue:%s", CurProgress, LastProgress)
		self:UpdateProgresChangeView(CurProgress, LastProgress)
		self:ShowTextTips()
	end, ShootTipsDelayTime)
end

function OutOnALimbMainPanelView:OnMiniGameStateChanged(NewValue, OldValue)
	FLOG_INFO("OutOnALimbMainPanelView:OnMiniGameStateChanged NewValue:%s, OldValue:%s", NewValue, OldValue)
    if OldValue == MiniGameStageType.Enter and NewValue == MiniGameStageType.DifficultySelect then
        self:UpdateDifficultySelectedInfo()
    elseif OldValue == MiniGameStageType.DifficultySelect and NewValue == MiniGameStageType.Start then
        self:UpdateStartInfoAfterDifficultSelected()
    elseif OldValue == MiniGameStageType.Start and NewValue == MiniGameStageType.Update then
        self:UpdateRunTimeInfo()
	elseif OldValue == MiniGameStageType.Update and NewValue == MiniGameStageType.End then
		self:UpdateEndStateInfo()
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

--- 设定难度进度条标志位置
function OutOnALimbMainPanelView:SetLevelPosition(DifficultyType, bShowPanelFirst)
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
	local ClientDef = self.OutOnALimbDCfg
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
function OutOnALimbMainPanelView:SetProBarPercent(DifficultyType, bShowPanelFirst)
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

	local ClientDef = self.OutOnALimbDCfg
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
function OutOnALimbMainPanelView:InitDifficultyPanelView(bShowPanelFirst)
	self:SetProBarPercent(MiniGameDifficulty.Sabotender, bShowPanelFirst)
	self:SetProBarPercent(MiniGameDifficulty.Morbol, bShowPanelFirst)
	self:SetProBarPercent(MiniGameDifficulty.Titan, bShowPanelFirst)
end

--- 初始化难度进度条状态
function OutOnALimbMainPanelView:InitDifficultySelectPanel()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	ViewModel.bShowObtainPanel = false
	ViewModel.bShowDifficultyPanel = true
    ViewModel.bShowCutPanel = false
	self:SetActBtnEnable(true)
	-- 随机难度条panel
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	local RandomNum = math.random(1, 2)
	local bShowPanelFirst = RandomNum == 1
	UIUtil.SetIsVisible(self.ProBarPanel1, bShowPanelFirst)
	UIUtil.SetIsVisible(self.LevelPanel, bShowPanelFirst)
	UIUtil.SetIsVisible(self.ProBarPanel2, not bShowPanelFirst)
	UIUtil.SetIsVisible(self.LevelPanel2, not bShowPanelFirst)
	self.bBottomToTop = bShowPanelFirst
	self:InitDifficultyPanelView(bShowPanelFirst)
	self.ProBarChoose:SetRenderScale(_G.UE.FVector2D(1, 0))
end

--- 刷新选择难度状态
function OutOnALimbMainPanelView:UpdateDifficultySelectedInfo()
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
	self:SetThePanelUseTips(self.TextDifficulty, LSTR(370011))
	self:SetTheHelpInfoTips(MiniGameStageType.DifficultySelect)
	self:PlayAnimation(self.AnimDifficultyTips)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultChooseTips)
	UIUtil.SetIsVisible(self.ChooseDifficulty, false)
	self:HideShootingTips()
	--self:UnRegisterTimer(self.HandFeelDelayTimer)
	self:InitDifficultySelectPanel()
	self:StartDifficultyBarSwingTimer(true)
	self:PlayAnimation(self.AnimDifficultyPanelLoop, 0, 0, nil, 1.0)
end

--- 显示难度展示界面
function OutOnALimbMainPanelView:ShowDifficultyShowPanel()
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
function OutOnALimbMainPanelView:StartDelayShowPanel()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

    local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	self:ResetSubViewState()
	self:SetThePanelUseTips(self.TextTips1, LSTR(370042))
	self:SetTheHelpInfoTips(MiniGameStageType.Update)
	self:PlayAnimation(self.AnimTips)
	self:PlayAnimation(self.AnimCutPanelIn)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.CutPanelIn)
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
function OutOnALimbMainPanelView:UpdateStartInfoAfterDifficultSelected()
	-- 播放收起选择难度界面
	self:PlayAnimation(self.AnimDifficultyPanelCut)
	self:StopDifficultyBarSwingTimer() -- 去除音效
	-- 回调中显示难度展示界面
end

--- 启动难度条动画
function OutOnALimbMainPanelView:StartDifficultyBarSwingTimer(bInit)
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
	local ClientDef = self.OutOnALimbDCfg
	local DifficultyMoveSpeed = ClientDef.DifficultySpeed
	local PauseTimePoint = self.DifficultyBarPauseTime or 0
	self:PlayAnimation(AniBarSwing, bInit and 0 or PauseTimePoint, 0, nil, DifficultyMoveSpeed)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultLoop)
end

--- 停止难度条摆动计时器
function OutOnALimbMainPanelView:StopDifficultyBarSwingTimer()
	self.DifficultyBarPauseTime = self:PauseAnimation(self.AnimProBarChooseLoop)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultStop)
end

--- 启动指针摆动计时器
function OutOnALimbMainPanelView:StartPointerSwingTimer()
	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end

	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end

	local AniPointerSwing = self.AnimPointerStateYellowLoop
	if AniPointerSwing == nil then
		return
	end

	local Speed = GameInst:GetTheSpeedInTheRound() or 0
	local PauseTimePoint = self.PointerYellowPauseTime or 0
	self:PlayAnimation(AniPointerSwing, PauseTimePoint, 0, nil, Speed)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.PointerLoop)
	--GoldSaucerMiniGameMgr.ChangeUISoundRTPCValue("Speed_circle", GameInst:GetRoundIndex())
end

--- 停止指针摆动计时器
function OutOnALimbMainPanelView:StopPointerSwingTimer()
	self.PointerYellowPauseTime = self:PauseAnimation(self.AnimPointerStateYellowLoop)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.PointerLoopStop)
end

--- 刷新当前轮数实际能够获取的奖励数量
function OutOnALimbMainPanelView:UpdateRewardPanel()
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
function OutOnALimbMainPanelView:UpdateRunTimeInfo()
	self:UpdateRewardPanel()
	self:SetActBtnEnable(true)
	self:StartPointerSwingTimer()
	self:PlayAnimation(self.AnimCutPanelLoop, 0, 0, nil, 1.0)
end

--- 初始化游戏进行状态的界面信息
function OutOnALimbMainPanelView:UpdateEndStateInfo()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

	local GameInst = ViewModel.MiniGame
	if GameInst == nil then
		return
	end
	self:StopPointerSwingTimer()
	self:ClearAllTheTimer()
	self.PointerYellowPauseTime = nil
	self:HideShootingTips()
end

--- 刷新结算界面信息
function OutOnALimbMainPanelView:UpdateRewardInfo()
	GoldSaucerMiniGameMgr:SendMsgAloneTreeExitReq(MiniGameType.OutOnALimb)
end

--- 刷新失败信息展示信息
function OutOnALimbMainPanelView:UpdateFailInfoShow()
    local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end

    local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	self:PlayAnimation(self.AnimPointerTimeHide)
	
	UIUtil.SetIsVisible(self.PointerStateYellow, false)
	self.PointerStateGrey:SetMarkState(false)
    -- 展示标准位置
    local FailPos = MiniGameInst:GetFailReasonPos()
    if FailPos == 0 then
        FLOG_ERROR("OutOnALimbView:UpdateFailInfoShow zero is not valid")
        return
    end
	local RedPointer = self.PointerStateRed
	if RedPointer == nil then
		return
	end
	local MaxAngle = self:GetTheMaxAngle()
	if not UIUtil.IsVisible(RedPointer) then
		UIUtil.SetIsVisible(RedPointer, true)
		RedPointer:PlayRedPointerLight()
	end
	ViewModel.RedPointerAngle = FailPos - MaxAngle / 2

	local EndState = MiniGameInst:GetRoundEndState()
    if EndState == MiniGameRoundEndState.FailChance then
        -- 播放原因tips（次数耗尽）
		self:SetThePanelUseTips(self.TextTips1, LSTR(370028))
    elseif EndState == MiniGameRoundEndState.FailTime then
        -- 播放错误原因tips（时间结束）
		self:SetThePanelUseTips(self.TextTips1, LSTR(370027))
		UIUtil.SetIsVisible(self.PointerStateGrey, false)
    end
	self:PlayAnimation(self.AnimTips)
	self:SetActBtnEnable(false)
    local function ShowFailRewardPanel()
		if RedPointer then
			RedPointer:HideRedPointerLight()
			--UIUtil.SetIsVisible(RedPointer, false)
		end
        -- 动画后展示失败结算界面
		UIViewMgr:ShowView(UIViewID.OutOnALimbSettlementPanel, ViewModel)
    end
	self:RegisterTimer(ShowFailRewardPanel, GoldSaucerMiniGameDefine.FailShowConstantTime, 0, 1)
end

--- 刷新新一轮的奖励变化
function OutOnALimbMainPanelView:ShowRewardChangeInNewRound()
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
	--[[self:RegisterTimer(function()
		ViewModel.bShowRewardAdd = false
	end, 1.5, 0, 1)--]]
end

--- 刷新再次挑战展示信息
function OutOnALimbMainPanelView:UpdateRestartInfo()
	self:ShowRewardChangeInNewRound()
    self:StartDelayShowPanel()
end

--- 游戏开始刷新界面组件状态
function OutOnALimbMainPanelView:ResetSubViewState()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	self:HideShootingTips()
	self:UnRegisterTimer(self.HandFeelDelayTimer)
	ViewModel.bShowDifficultyPanel = false -- 隐藏选择难度界面
	ViewModel.bShowCutPanel = true -- 显示砍伐面板
	self:SetActBtnEnable(false) --恢复按钮点击状态
	-- 清除动画暂停时间点
	self.PointerYellowPauseTime = nil 
	self.DifficultyBarPauseTime = nil
	ViewModel.bShowCutTimePanel = true
	self:InitCutPointerState() -- 重置指针状态
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarBlue, "ProgressEnd", 1)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressStart", 1)
	UIUtil.ImageSetMaterialScalarParameterValue(self.ProBarYellow, "ProgressEnd", 1)
	self:PlayAnimation(self.AnimProBarYellow)
	--self:PlayAnimation(self.AnimCutPanelDoubling13, 0.69, 1, _G.UE.EUMGSequencePlayMode.Reverse, 1)
	--self:PlayAnimation(self.AnimCutPanelDoubling45, 0.69, 1, _G.UE.EUMGSequencePlayMode.Reverse, 1)
end

--- 动画结束统一回调
function OutOnALimbMainPanelView:OnAnimationFinished(Animation)
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
		FLOG_ERROR("OutOnALimbMainPanelView.DifficultSelect:AnimDifficultyPanelCut Animation Finished")
		self:ShowDifficultyShowPanel()
	elseif Animation == self.AnimCutPanelIn then
		MiniGameInst:StartGameTimeLoop(MiniGameInst.GameRun)
	elseif Animation == self.AnimPointerTimeHide then
		ViewModel.bShowCutTimePanel = false
	elseif Animation == self.AnimObtainNumberIn then
		
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
function OutOnALimbMainPanelView:OnPlayNumberTrigger(NewChances)
	local ChancesNumber = tonumber(NewChances)
	if ChancesNumber and ChancesNumber <= 3 then
		self.TextPointerNumber_1:SetText(NewChances)
		self:PlayAnimation(self.AnimPointerNumberTrigger)
	end
end

--- 玩家游玩时间减少
function OutOnALimbMainPanelView:OnComeInKeyTime(bInKeyTime)
	if bInKeyTime then
		self:PlayAnimation(self.AnimPointerTimeTrigger, 0, 0, nil, 1.0)
	else
		self:PlayAnimation(self.AnimPointerTimeTrigger, 0.73)
	end
end

--- 重连成功
function OutOnALimbMainPanelView:OnReconnectSuccess(bSuccess)
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
function OutOnALimbMainPanelView:SetTheHelpInfoTips(GameStageType)
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

function OutOnALimbMainPanelView:StopAllLoopAudio()
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultStop)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.PointerLoopStop)
end

return OutOnALimbMainPanelView