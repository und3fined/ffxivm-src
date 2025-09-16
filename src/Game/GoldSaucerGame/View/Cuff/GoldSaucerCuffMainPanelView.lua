---
--- Author: Administrator
--- DateTime: 2024-02-04 11:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local MiniGameCuffAudioDefine = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuffAudioDefine")
local AudioUtil = require("Utils/AudioUtil")
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local ProtoRes = require("Protocol/ProtoRes")
local InteractionCategory = ProtoRes.InteractionCategory
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local DelayTime = GoldSaucerMiniGameDefine.DelayTime
local AudioPath = MiniGameCuffAudioDefine.AudioPath

local LSTR = _G.LSTR
local EventID = _G.EventID
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
---@class GoldSaucerCuffMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Award GoldSaucerGameCuffAwardItemView
---@field BlowBlue GoldSaucerCuffBlowBlueItemView
---@field BlowPurple GoldSaucerCuffBlowPurpleItemView
---@field BlowRed GoldSaucerCuffBlowRedItemView
---@field BlowYellow GoldSaucerCuffBlowYellowItemView
---@field Btn1 CommBtnMView
---@field Btn2 CommBtnMView
---@field ChallengeResults GoldSaucerCuffChallengeResultsItemView
---@field CloseBtn CommonCloseBtnView
---@field Critical GoldSaucerGameCommCriticalItemView
---@field CuffScore GoldSaucerGameCuffScoreItemView
---@field MainTeamPanel MainTeamPanelView
---@field MoneySlot CommMoneySlotView
---@field PanelChallengeFailurePrompt UFCanvasPanel
---@field PanelChallengeRecordList UFVerticalBox
---@field PanelCold UFCanvasPanel
---@field PanelHint UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field PanelResult UFCanvasPanel
---@field PannelBlowMid UFCanvasPanel
---@field ProgressBarFull UProgressBar
---@field TableViewBlow UTableView
---@field TableViewList UTableView
---@field TextAward UFTextBlock
---@field TextHint UFTextBlock
---@field TextHint1 UFTextBlock
---@field TextMultiple UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextStrengthValue UFTextBlock
---@field challengeBegins GoldSaucerCuffchallengeBeginsItemView
---@field AnimBlowDown UWidgetAnimation
---@field AnimBlowHigh UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimNormalIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSettlementIn UWidgetAnimation
---@field AnimTextBreathe UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCuffMainPanelView = LuaClass(UIView, true)

function GoldSaucerCuffMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Award = nil
	--self.BlowBlue = nil
	--self.BlowPurple = nil
	--self.BlowRed = nil
	--self.BlowYellow = nil
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.ChallengeResults = nil
	--self.CloseBtn = nil
	--self.Critical = nil
	--self.CuffScore = nil
	--self.MainTeamPanel = nil
	--self.MoneySlot = nil
	--self.PanelChallengeFailurePrompt = nil
	--self.PanelChallengeRecordList = nil
	--self.PanelCold = nil
	--self.PanelHint = nil
	--self.PanelNormal = nil
	--self.PanelResult = nil
	--self.PannelBlowMid = nil
	--self.ProgressBarFull = nil
	--self.TableViewBlow = nil
	--self.TableViewList = nil
	--self.TextAward = nil
	--self.TextHint = nil
	--self.TextHint1 = nil
	--self.TextMultiple = nil
	--self.TextQuantity = nil
	--self.TextStrengthValue = nil
	--self.challengeBegins = nil
	--self.AnimBlowDown = nil
	--self.AnimBlowHigh = nil
	--self.AnimIn = nil
	--self.AnimNormalIn = nil
	--self.AnimOut = nil
	--self.AnimSettlementIn = nil
	--self.AnimTextBreathe = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Award)
	self:AddSubView(self.BlowBlue)
	self:AddSubView(self.BlowPurple)
	self:AddSubView(self.BlowRed)
	self:AddSubView(self.BlowYellow)
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2)
	self:AddSubView(self.ChallengeResults)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.Critical)
	self:AddSubView(self.CuffScore)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.challengeBegins)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCuffMainPanelView:OnInit()
	self.MainTeamPanel.nforBtn.HelpInfoID = 11042
	self.ResultTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)
	self.InteractiveTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewBlow, nil, false, false, true)
	self.Binders = {
		{"GameState", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameStateChanged)},
		-- {"TotalTimeTextTitle", UIBinderSetText.New(self, self.TextTime)},
		{"TotalTimeTextTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextTime)},

		{"bCuffScoreVisible", UIBinderSetIsVisible.New(self, self.CuffScore)},
		{"bPanelNormalVisible", UIBinderSetIsVisible.New(self, self.PanelNormal, nil, true)},
		{"bPanelResultVisible", UIBinderSetIsVisible.New(self, self.PanelResult, nil, true)},
		{"CuffScore", UIBinderSetText.New(self, self.CuffScore.FTextBlock_44)},
		{"TextStrengthValue", UIBinderSetText.New(self, self.TextStrengthValue)},
		{"StrengthPro", UIBinderSetPercent.New(self, self.ProgressBarFull)},
		{"TextMultiple", UIBinderSetText.New(self, self.TextMultiple)},
		{"bTextMultipleVisible", UIBinderSetIsVisible.New(self, self.TextMultiple)},
		{"bFailed", UIBinderSetIsVisible.New(self, self.PanelChallengeFailurePrompt)},
		{"bSuccessed", UIBinderSetIsVisible.New(self, self.PanelChallengeRecordList)},
		{"ResultVMList", UIBinderUpdateBindableList.New(self, self.ResultTableViewAdapter)},
		{"InteractiveVMList", UIBinderUpdateBindableList.New(self, self.InteractiveTableViewAdapter)},
		{"RewardGot", UIBinderSetTextFormatForMoney.New(self, self.Award.TextQuantity)},
		{"RewardGot", UIBinderSetTextFormatForMoney.New(self, self.MainTeamPanel.TextNumber)},
		{"CuffAddRewardGot",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber1)},

		{"AwardIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Award.Comm96Slot.Icon)},
		{"TextHint", UIBinderSetText.New(self, self.TextHint)},
		{"bTextHintVisible", UIBinderSetIsVisible.New(self, self.PanelHint)}, --
		{"JDCoinColor", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity)},
		{"RightBtnContent", UIBinderSetText.New(self, self.Btn2.TextContent)},
		{"bEnterEndState", UIBinderValueChangedCallback.New(self, nil, self.ChangeShowType)},

		{"CriticalText", UIBinderSetText.New(self, self.Critical.TextQuantity)},
		-- {"bCriticalVisible", UIBinderSetIsVisible.New(self, self.Critical)},
	}
end

function GoldSaucerCuffMainPanelView:OnDestroy()
	self:UnRegisterAllTimer()
end

function GoldSaucerCuffMainPanelView:OnShow()
	self.IsHide = false

	self:SetHidenOnShow()
	self:SetDefaultValue()
	self.bFirstChallenge = true
	self:PlayAnimationIn()
	self:InitLSTRText()
end

function GoldSaucerCuffMainPanelView:InitLSTRText()
	self.TextHint1:SetText(LSTR(250016)) --- 不要气馁，再挑战看看吧！
	self.TextAward:SetText(LSTR(250017)) -- 奖励
	self.TextQuantity:SetText(1) -- 阿拉伯数字1
	self.Btn1.TextContent:SetText(LSTR(10036)) -- 离开

end

function GoldSaucerCuffMainPanelView:PlayAnimationIn()
	self:PlayAnimation(self.AnimNormalIn)
	AudioUtil.LoadAndPlayUISound(AudioPath.EnterGame)
end

function GoldSaucerCuffMainPanelView:OnHide()
	self.IsHide = true
	self:UnRegisterAllTimer()
	local MiniGameInst = self:GetGameInst()
	if MiniGameInst == nil then
		return
	end
	MiniGameInst:SetIsBegin(false)
	self:StopAllAnimations()
	self.Award:StopAllAnimations()

	self.InteractiveTableViewAdapter:ClearChildren()

	-- local ViewModel = self:GetTheParamsVM()
	-- if ViewModel == nil then
	-- 	return
	-- end
	-- ViewModel:Reset()
end

function GoldSaucerCuffMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn1.Button, self.OnLeaveBtnClick)
	UIUtil.AddOnClickedEvent(self, self.Btn2.Button, self.OnFightAgainBtnClick)
	self:BindBtnCloseCallBack()
end

function GoldSaucerCuffMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MiniGameCuffSubViewOnShow, self.MiniGameCuffShowSubViewCanvasEvent)
	self:RegisterGameEvent(EventID.MiniGameCuffShowPunchResult, self.MiniGameCuffShowPunchResultEvent)
	self:RegisterGameEvent(EventID.MiniGameMainPanelPlayAnim, self.MiniGameCuffMainPlayAnimEvent)
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function GoldSaucerCuffMainPanelView:OnRegisterBinder()
	local ViewModel = self:GetTheParamsVM()
    if ViewModel == nil then
        return
    end
	self.BlowRed:SetParams({Data = ViewModel:GetCenterBlowVM()})
	self.BlowYellow:SetParams({Data = ViewModel:GetCenterBlowVM()})
	self.BlowBlue:SetParams({Data = ViewModel:GetCenterBlowVM()})
	self.BlowPurple:SetParams({Data = ViewModel:GetCenterBlowVM()})

    self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSaucerCuffMainPanelView:OnSelectChanged(Index, ItemData, ItemView)
end

--- @type 准备开始
function GoldSaucerCuffMainPanelView:OnReady()
	UIUtil.SetIsVisible(self.challengeBegins, true)
	self.challengeBegins:SetPrepare()

	AudioUtil.LoadAndPlayUISound(AudioPath.OnReady)

	self:RegisterTimer(function()
		self.challengeBegins:SetBegin()
		AudioUtil.LoadAndPlayUISound(AudioPath.OnBegin)
	end, DelayTime.ReadyToBegin, 0, 1)
end

--- @type 当开始时
function GoldSaucerCuffMainPanelView:OnBegin()
	-----Test-----5360362
	-- local StagePoleData = _G.PWorldDynDataMgr:GetDynData(EffectType,  5360362)
	-- local Data = _G.MapEditDataMgr:GetMapEditCfg()
	-----Test-----
	UIUtil.SetIsVisible(self.challengeBegins, false)
	UIUtil.SetIsVisible(self.TextStrengthValue, true)
	local MiniGameInst = self:GetGameInst()
	if MiniGameInst == nil then
		return
	end
	MiniGameInst:StartGameTimeLoop(MiniGameInst.GameRun)
    MiniGameInst:SetTextHint(LSTR(250007), false) -- 点击光圈聚集力量
	MiniGameInst:SetIsBegin(true)

	local ViewModel = self:GetTheParamsVM()
	if ViewModel == nil then
		return
	end
	-- ViewModel:UpdateInteractiveList(ViewModel.InteractiveVMList, MiniGameInst.NextRoundInteractionCfg)
	-- ViewModel:UpdateList(ViewModel.InteractiveVMList, MiniGameInst.NextRoundInteractionCfg)
	-- local ApertureList = GoldSaucerMiniGameMgr.ApertureList 
	-- self:SelectShowBlow(ApertureList)
end

--- @type 把需要出现的显示出来
function GoldSaucerCuffMainPanelView:SelectShowBlow(ApertureList)
	for i = 1, 9 do
		local bShow = false
		for _, v in pairs(ApertureList) do
			local Elem = v
			local Pos = Elem.Pos
			if Pos == i then
				bShow = true
				break
			end
		end
		UIUtil.SetIsVisible(self[string.format("Blow%d", i)].FCanvasPanel_26, bShow, bShow)
		UIUtil.SetIsVisible(self[string.format("Blow%d", i)].Btn, bShow, bShow)
	end
end

--- @type 设置刚开始需要隐藏的部分
function GoldSaucerCuffMainPanelView:SetHidenOnShow()
	-- UIUtil.SetIsVisible(self.HelpTips, false)
	UIUtil.SetIsVisible(self.challengeBegins, false)
	UIUtil.SetIsVisible(self.TextMultiple, false)
	--- 开始先将Blow中的Canvas
	UIUtil.SetIsVisible(self.PannelBlowMid, false)
	UIUtil.SetIsVisible(self.BlowBlue, false)
	UIUtil.SetIsVisible(self.BlowPurple, false)
	UIUtil.SetIsVisible(self.BlowRed, false)
	UIUtil.SetIsVisible(self.BlowYellow, false)
end

--- @type 把不需要动态改变的变量写好
function GoldSaucerCuffMainPanelView:SetDefaultValue()
	-- local CuffTip = GoldSaucerMiniGameDefine.CuffTip
	-- self.HelpTips:SetDefaultValue(CuffTip.Title, CuffTip.Content)
	self.Btn2.Button:SetIsEnabled(true)
	self.ProgressBarFull:SetPercent(0)
	UIUtil.SetRenderOpacity(self.PanelNormal, 1)
	UIUtil.SetIsVisible(self.CloseBtn, true)

	self.MainTeamPanel:SwitchTab(4)
	self.MainTeamPanel:SetShowGameInfo()
	self.MainTeamPanel.TextGameName:SetText(LSTR(250008)) -- 重击伽美什  
	self.MainTeamPanel.TextGameName_1:SetText(LSTR(250009)) -- 当前奖励
	local IconGamePath = MiniGameClientConfig[MiniGameType.Cuff].IconGamePath
	UIUtil.ImageSetBrushFromAssetPath(self.MainTeamPanel.IconGame, IconGamePath)
	UIUtil.SetIsVisible(self.MainTeamPanel.PanelCountdown, true)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalGold, true)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalObtain, true)
	UIUtil.SetColorAndOpacityHex(self.Award.TextQuantity, "FFF9E1FF")
	UIUtil.SetIsVisible(self.Critical, false)
end

--- @type 设置出现游戏名字和时间还是金碟币数量
function GoldSaucerCuffMainPanelView:ChangeShowType(bEnterEndState)
	local bMoneyVisible = bEnterEndState
	local bShowGameDesc = not bEnterEndState
	UIUtil.SetIsVisible(self.MoneySlot, bMoneyVisible)
	-- UIUtil.SetIsVisible(self.PanelCountdown, bShowGameDesc)
	-- UIUtil.SetIsVisible(self.HorizontalTitle, bShowGameDesc)
	UIUtil.SetIsVisible(self.MainTeamPanel.PanelCountdown, not bEnterEndState)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalGold, not bEnterEndState)
	UIUtil.SetIsVisible(self.MainTeamPanel.HorizontalObtain, not bEnterEndState)

	UIUtil.SetIsVisible(self.Btn1, true)
	UIUtil.SetIsVisible(self.Btn2, true)
	UIUtil.SetIsVisible(self.Award, true)
	if bEnterEndState then
		self:OnMoneyUpdate()
	end
end

function GoldSaucerCuffMainPanelView:OnMoneyUpdate()
	local JDResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
	self.MoneySlot:UpdateView(JDResID, true, -1, true)
end

function GoldSaucerCuffMainPanelView:MiniGameCuffShowPunchResultEvent(Power)
	_G.UIViewMgr:ShowView(_G.UIViewID.GoldSaucerCuffShootingTips, { StrengthValue = Power })
end

--- 播放动画
function GoldSaucerCuffMainPanelView:MiniGameCuffMainPlayAnimEvent(InAnim)
	local Anim = MiniGameClientConfig[MiniGameType.Cuff].Anim
	local ChallengeResults = self.ChallengeResults
	if InAnim == Anim.AnimSettlementIn then
		self:OnPlayAnimSettlementIn()
	elseif InAnim == Anim.AnimBlowDown then
		self:PlayAnimation(self.AnimBlowDown)
		AudioUtil.LoadAndPlayUISound(AudioPath.EnterSuccessResult)
	elseif InAnim == Anim.AnimBlowHigh then
		self:PlayAnimation(self.AnimBlowHigh)
		AudioUtil.LoadAndPlayUISound(AudioPath.EnterSuccessResult)
	elseif InAnim == Anim.AnimNormalIn then
		self:PlayAnimationIn()
	elseif InAnim == Anim.AnimTextBreathe then
		self:PlayAnimation(self.AnimTextBreathe)
	elseif InAnim == Anim.AnimSuccess then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimSuccess)
	elseif InAnim == Anim.AnimTimesup then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimTimesup)
	elseif InAnim == Anim.AnimFail then
		ChallengeResults:PlayAnimation(ChallengeResults.AnimFaill)
	elseif InAnim == Anim.Critical then
		self:OnPlayCtiticalAnim()
	end
end

function GoldSaucerCuffMainPanelView:OnPlayAnimSettlementIn()
	self:PlayAnimation(self.AnimSettlementIn)

	UIUtil.SetIsVisible(self.CloseBtn, false)
	self.Btn1.Button:SetIsEnabled(true)
	self.Btn2.Button:SetIsEnabled(true)
	local SubViews = self.ResultTableViewAdapter.SubViews
	for _, View in pairs(SubViews) do
		View:CheckPlayAnim()
		-- View:Reset()
	end
	
	-- local function PlaySubViewAnim()
	-- 	local SubViews = self.ResultTableViewAdapter.SubViews
	-- 	for _, View in pairs(SubViews) do
	-- 		View:CheckPlayAnim()
	-- 	end
	-- end
	-- self:RegisterTimer(PlaySubViewAnim, 1)
end

function GoldSaucerCuffMainPanelView:OnPlayCtiticalAnim()
	local ShowEndAnimTime = 1.67
	local MiniGameInst = self:GetGameInst()
	if MiniGameInst == nil then
		return
	end
	local VM = self:GetTheParamsVM()
	if VM == nil then
		return
	end
	UIUtil.SetIsVisible(self.Critical, false)
	UIUtil.SetIsVisible(self.Award.TextQuantity, false)
	self.ShowCriticalTimer = self:RegisterTimer(function()
		if UIUtil.IsVisible(self.PanelResult) then
			UIUtil.SetIsVisible(self.Critical, true)
			UIUtil.SetIsVisible(self.Award.TextQuantity, true)
			self.Critical:PlayAnimation(self.Critical.AnimCriticalIn)
			self.Award:PlayAnimation(self.Award.AnimCriticalIn)
			AudioUtil.LoadAndPlayUISound(AudioPath.RewardCritical)
			--MiniGameInst:MultiRewardGot()
			VM:SetOriginReward()
			self:RegisterTimer(function() VM:UpdateRewardGotSingle() end, 1.5)
		end
		self.ShowCriticalTimer = nil
	end, ShowEndAnimTime)
end

--- @type
function GoldSaucerCuffMainPanelView:MiniGameCuffShowSubViewCanvasEvent(bVisible)
	local MiniGameInst = self:GetGameInst()
	if MiniGameInst == nil then
		return
	end
	local Type = MiniGameInst.NextRoundInteractionCfg.Type
	UIUtil.SetIsVisible(self.PannelBlowMid, bVisible)
	UIUtil.SetIsVisible(self.BlowBlue, Type == InteractionCategory.CATEGORY_MIDDLE)
	UIUtil.SetIsVisible(self.BlowPurple, Type == InteractionCategory.CATEGORY_HIGH)
	UIUtil.SetIsVisible(self.BlowYellow, Type == InteractionCategory.CATEGORY_LOW)
	local bRedVisible = Type == InteractionCategory.CATEGORY_FINAL_TWO or Type == InteractionCategory.CATEGORY_FINAL_ONE
		or Type == InteractionCategory.CATEGORY_FINAL_THREE or Type == InteractionCategory.CATEGORY_FINAL_FOUR
	UIUtil.SetIsVisible(self.BlowRed, bRedVisible)
end

--- @type 当游戏状态发生改变
function GoldSaucerCuffMainPanelView:OnMiniGameStateChanged(NewValue, OldValue)
	FLOG_INFO("OutOnALimbMainPanelView:OnMiniGameStateChanged NewValue:%s, OldValue:%s", NewValue, OldValue)
end

-- 点击离开按钮
function GoldSaucerCuffMainPanelView:OnLeaveBtnClick()
	self.Btn2.Button:SetIsEnabled(false)
	GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.Cuff, false)
	self:Hide()
end

-- 点击再战按钮
function GoldSaucerCuffMainPanelView:OnFightAgainBtnClick()
	local OwnJdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) --持有的金碟币
	if OwnJdCoinNum >= 1 then
		self.Btn2.Button:SetIsEnabled(false)
		self.bFirstChallenge = false
		local GameInst = self:GetGameInst()
		if GameInst == nil then
			return
		end
		local VM = self:GetTheParamsVM()
		if VM ~= nil then
			VM.TextStrengthValue = string.format(LSTR(250006), 0) -- "力量值0PZ"
			VM:UpdateStrengthPro(0)
		end
		_G.UIViewMgr:HideView(_G.UIViewID.GoldSaucerCuffShootingTips)
		UIUtil.SetRenderOpacity(self.PanelNormal, 1)
		UIUtil.SetIsVisible(self.TextStrengthValue, false)
		UIUtil.SetIsVisible(self.Critical, false)
		UIUtil.SetIsVisible(self.CloseBtn, true)

		UIUtil.SetIsVisible(self.Btn1, false)
		UIUtil.SetIsVisible(self.Award, false)
		UIUtil.SetIsVisible(self.Btn2, false)
		self.Award:StopAllAnimations()

		UIUtil.SetColorAndOpacityHex(self.Award.TextQuantity, "FFF9E1FF")
		if self.ShowCriticalTimer ~= nil then
			self:UnRegisterTimer(self.ShowCriticalTimer)
			self.ShowCriticalTimer = nil
		end
		GameInst:PlayAnyAsMontageLoop(GameInst.IdleStateKey, GoldSaucerMiniGameDefine.DefaultSlot, 9999, true)
		GoldSaucerMiniGameMgr:OnBtnFightAgainClick(MiniGameType.Cuff)
	else
		_G.JumboCactpotMgr:GetJDcoin()
		self:OnLeaveBtnClick()
	end
end

--- @type 给关闭按钮设置回调
function GoldSaucerCuffMainPanelView:BindBtnCloseCallBack()
	local function EnsureFailQuit()
		local GameInst = self:GetGameInst()
		if GameInst == nil then
			return
		end
		local AudioName = MiniGameCuffAudioDefine.AudioName

		GameInst:SetIsForceEnd(true)
		GameInst:UnRegisterTimer()
		GameInst:StopWindEffect()
		GameInst:PlaySoundWithPostEvent(AudioName.StopFistSwish)
		local EGameState = GameInst.DefineCfg.EGameState
		local GameState = GameInst:GetCuffGameState()
		if GameState ~= EGameState.End then
			GoldSaucerMiniGameMgr:SendMsgCuffExistReq(false)
		end
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.Cuff, false)
		self:StopAllAnimations()
		local VM = self:GetTheParamsVM()
		if VM ~= nil then
			VM.InteractiveVMList:Clear()
		end
		self:Hide()
	end

	local function RecoverGameLoop()
		local GameInst = self:GetGameInst()
		if GameInst == nil then
			return
		end
		--GameInst:RecoverGameTimeLoop()
	end	
	local function OnBtnCloseClick(View)
		local GameInst = self:GetGameInst()
		if GameInst == nil then
			return
		end
		local GameState = GameInst:GetCuffGameState()
		local EGameState = GameInst.DefineCfg.EGameState
		if GameState == EGameState.End then
			GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.Cuff, false)
			UIViewMgr:HideView(UIViewID.GoldSaucerCuffBlowTips)
		else
			GoldSaucerMiniGameMgr:ShowEnsureExitTip(MiniGameType.Cuff, EnsureFailQuit, RecoverGameLoop)
		end
	end
	self.CloseBtn:SetCallback(self, OnBtnCloseClick)
end

--- 动画结束统一回调
function GoldSaucerCuffMainPanelView:OnAnimationFinished(Animation)
	if self.IsHide then
		return
	end

	if Animation == self.AnimIn then
		self:OnEnterGame()
	elseif Animation == self.AnimNormalIn and not self.bFirstChallenge then
		if not UIViewMgr:IsViewVisible(self.ViewID) then
			return
		end
		self:OnEnterGame()
	end
end

--- @type 当进入游戏
function GoldSaucerCuffMainPanelView:OnEnterGame()
	self:PlayAnimation(self.AnimTextBreathe)
	self:OnReady()
	-- 临时代码等动效好了	
	self:RegisterTimer(self.OnBegin, DelayTime.PerpareToBegin, 0, 1)

end

--- 获取UIView关联的VM
function GoldSaucerCuffMainPanelView:GetTheParamsVM()
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

function GoldSaucerCuffMainPanelView:GetGameInst()
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

return GoldSaucerCuffMainPanelView