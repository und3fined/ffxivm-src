---
--- Author: Administrator
--- DateTime: 2023-11-16 19:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local EventID = require("Define/EventID")
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local CutResultStage = GoldSaucerMiniGameDefine.CutResultStage
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local AudioType = GoldSaucerMiniGameDefine.AudioType
local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local ScoreMgr = require("Game/Score/ScoreMgr")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local OutOnALimbParamCfg = require("TableCfg/OutOnALimbParamCfg")
local LoopControlCfg = require("TableCfg/TheFinerMinerLoopControlCfg")
local alone_tree_ore_search_param_type = ProtoRes.Game.alone_tree_ore_search_param_type

local CriticalAnimDelayChangeNumTime = 1.5
local AnimInRltNumShowTimeline = 0.9
local AnimSuccessTimeRltNumShowTimeline = 0.77

---@class TheFinerMinerSettlementPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot GoldSaucerGameCuffAwardItemView
---@field BottomPanel MainLBottomPanelView
---@field BtnClose CommonCloseBtnView
---@field BtnGo CommBtnMView
---@field BtnLeave CommBtnMView
---@field BtnRewar CommBtnMView
---@field Critical GoldSaucerGameCommCriticalItemView
---@field GoPanel UFCanvasPanel
---@field GravelPanel UFCanvasPanel
---@field GravelTimePanel UFCanvasPanel
---@field HorizontalObtain UFHorizontalBox
---@field HorizontalReward UFHorizontalBox
---@field ImgArrow UFImage
---@field ImgBgBlack UFImage
---@field ImgGravel1 UFImage
---@field ImgGravel2 UFImage
---@field ImgGravel3 UFImage
---@field ImgGravel4 UFImage
---@field ImgGravel5 UFImage
---@field ImgGravelTime1 UFImage
---@field ImgGravelTime2 UFImage
---@field ImgGravelTime3 UFImage
---@field ImgGravelTime4 UFImage
---@field ImgGravelTime5 UFImage
---@field ImgLine UFImage
---@field ImgLoseBg UFImage
---@field ImgPriceIcon UFImage
---@field ImgSuccessAxe UFImage
---@field ImgSuccessDecorate UFImage
---@field ImgSuccessLight UFImage
---@field ImgSuccessStone UFImage
---@field ImgTimeAxe UFImage
---@field ImgTimeDecorate UFImage
---@field ImgTimeLight UFImage
---@field ImgTimeStone UFImage
---@field ImgTipsBg UFImage
---@field ImgTipsBg1 UFImage
---@field MainTeamPanel MainTeamPanelView
---@field MoneySlot CommMoneySlotView
---@field PanelTimes1 UFCanvasPanel
---@field PanelTimes2 UFCanvasPanel
---@field RewarPanel UFCanvasPanel
---@field SuccessPanel UFCanvasPanel
---@field TextGo UFTextBlock
---@field TextLoseTips UFTextBlock
---@field TextNewRecord1 UFTextBlock
---@field TextNewRecord2 UFTextBlock
---@field TextNumber UFTextBlock
---@field TextNumber1 UFTextBlock
---@field TextNumberReward UFTextBlock
---@field TextReward UFTextBlock
---@field TextSuccess UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field TextTips1 UFTextBlock
---@field TextUndone UFTextBlock
---@field TextUnfinished UFTextBlock
---@field TimeOverPanel UFCanvasPanel
---@field TipsLosePanel UFCanvasPanel
---@field TipsPanel UFCanvasPanel
---@field TipsPanel1 UFCanvasPanel
---@field TitlePanel UFCanvasPanel
---@field TitlePanel1 UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimSuccessTimeCost UWidgetAnimation
---@field AnimSuccessTimes23 UWidgetAnimation
---@field AnimSuccessTimes45 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TheFinerMinerSettlementPanelView = LuaClass(UIView, true)

function TheFinerMinerSettlementPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.BottomPanel = nil
	--self.BtnClose = nil
	--self.BtnGo = nil
	--self.BtnLeave = nil
	--self.BtnRewar = nil
	--self.Critical = nil
	--self.GoPanel = nil
	--self.GravelPanel = nil
	--self.GravelTimePanel = nil
	--self.HorizontalObtain = nil
	--self.HorizontalReward = nil
	--self.ImgArrow = nil
	--self.ImgBgBlack = nil
	--self.ImgGravel1 = nil
	--self.ImgGravel2 = nil
	--self.ImgGravel3 = nil
	--self.ImgGravel4 = nil
	--self.ImgGravel5 = nil
	--self.ImgGravelTime1 = nil
	--self.ImgGravelTime2 = nil
	--self.ImgGravelTime3 = nil
	--self.ImgGravelTime4 = nil
	--self.ImgGravelTime5 = nil
	--self.ImgLine = nil
	--self.ImgLoseBg = nil
	--self.ImgPriceIcon = nil
	--self.ImgSuccessAxe = nil
	--self.ImgSuccessDecorate = nil
	--self.ImgSuccessLight = nil
	--self.ImgSuccessStone = nil
	--self.ImgTimeAxe = nil
	--self.ImgTimeDecorate = nil
	--self.ImgTimeLight = nil
	--self.ImgTimeStone = nil
	--self.ImgTipsBg = nil
	--self.ImgTipsBg1 = nil
	--self.MainTeamPanel = nil
	--self.MoneySlot = nil
	--self.PanelTimes1 = nil
	--self.PanelTimes2 = nil
	--self.RewarPanel = nil
	--self.SuccessPanel = nil
	--self.TextGo = nil
	--self.TextLoseTips = nil
	--self.TextNewRecord1 = nil
	--self.TextNewRecord2 = nil
	--self.TextNumber = nil
	--self.TextNumber1 = nil
	--self.TextNumberReward = nil
	--self.TextReward = nil
	--self.TextSuccess = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TextTips1 = nil
	--self.TextUndone = nil
	--self.TextUnfinished = nil
	--self.TimeOverPanel = nil
	--self.TipsLosePanel = nil
	--self.TipsPanel = nil
	--self.TipsPanel1 = nil
	--self.TitlePanel = nil
	--self.TitlePanel1 = nil
	--self.AnimIn = nil
	--self.AnimSuccessTimeCost = nil
	--self.AnimSuccessTimes23 = nil
	--self.AnimSuccessTimes45 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TheFinerMinerSettlementPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	self:AddSubView(self.BottomPanel)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.BtnLeave)
	self:AddSubView(self.BtnRewar)
	self:AddSubView(self.Critical)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TheFinerMinerSettlementPanelView:InitConstStringInfo()
	self.TextGo:SetText(LSTR(380020))
	self.TextSuccess:SetText(LSTR(380024))
	self.TextTips1:SetText(LSTR(380027))
	self.TextNewRecord2:SetText(LSTR(380026))
	self.TextUnfinished:SetText(LSTR(380028))
	self.TextTips:SetText(LSTR(380025))
	self.TextNewRecord1:SetText(LSTR(380026))
	self.TextReward:SetText(LSTR(380029))
	self.TextLoseTips:SetText(LSTR(380030))
end

function TheFinerMinerSettlementPanelView:InitSubViewConstStringInfo()
	self.BtnLeave:SetButtonText(LSTR(380021))
	self.BtnRewar:SetButtonText(LSTR(380022))
	self.BtnGo:SetButtonText(LSTR(380023))
end

function TheFinerMinerSettlementPanelView:OnInit()
	self.ScoreItem = ItemVM.New()
	self.SuccessScoreChangeTimerID = nil
	self.Binders = {
		--- 队伍通用面板绑定
		{"GameName", UIBinderSetText.New(self, self.MainTeamPanel.TextGameName)},
		{"GoldPanelTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextGameName_1)},
		{"TotalTimeTextTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextTime)},
		{"RewardGot",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber)},
		{"RewardAdd",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber1)},
		--{"bShowRewardAdd",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalObtain1)},
		{"bShowObtainPanel",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalGold)},
		{"bShowObtainPanel",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalObtain)},
		{"bShowPanelCountDown", UIBinderSetIsVisible.New(self, self.MainTeamPanel.PanelCountdown)}
	}
	self.bRewar = false
	self.GuarateeOnceClickOfRefight = false -- 再战按钮保证只生效一次
	self:InitConstStringInfo()
end

function TheFinerMinerSettlementPanelView:OnDestroy()

end

function TheFinerMinerSettlementPanelView:OnShow()
	self:InitSubViewConstStringInfo()
	UIUtil.SetIsVisible(self.BottomPanel, false)
	local BottomPanel = self.BottomPanel
	local MainTeamPanel = self.MainTeamPanel
	local CriticalTipWidget = self.Critical

	if BottomPanel then
		--BottomPanel:SetButtonEmotionVisible(false)
		--BottomPanel:SetButtonPhotoVisible(false)
	end
	
	if MainTeamPanel then
		MainTeamPanel:SetShowGameInfo()
		--- 图标显示逻辑
		local GameIconWidget = MainTeamPanel.IconGame
		local ClientDef = MiniGameClientConfig[MiniGameType.OutOnALimb]
		if GameIconWidget and ClientDef then
			UIUtil.ImageSetBrushFromAssetPath(GameIconWidget, ClientDef.IconGamePath)
		end
		self:SetTheHelpInfoTips(MiniGameStageType.Update)
	end

	local ViewModel = self.Params
	if not ViewModel then
		return
	end

	ViewModel.bShowPanelCountDown = false
	ViewModel.bShowObtainPanel = false
	UIUtil.SetIsVisible(CriticalTipWidget, false)

	local MiniGameInst = ViewModel.MiniGame
	if MiniGameInst == nil then
		return
	end

	self.MoneySlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)

	local EndState = MiniGameInst:GetRoundEndState()
	local bShowSuccessPanel = EndState == MiniGameRoundEndState.Success
	UIUtil.SetIsVisible(self.SuccessPanel, bShowSuccessPanel)
	UIUtil.SetIsVisible(self.TimeOverPanel, not bShowSuccessPanel)

	if bShowSuccessPanel then
		GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleSuccessResult)
		self:UpdateChallengeRltPanelInfo()
		local RoundIndex = MiniGameInst:GetRoundIndex() + 1
		local LoopCfg = LoopControlCfg:FindCfgByKey(RoundIndex)
		local EmotionIDToPlay = LoopCfg and LoopCfg.EmotionID or 0
		GoldSaucerMiniGameMgr:PlayEmotionActInSettlementStage(MiniGameType.TheFinerMiner, true, EmotionIDToPlay)
		local AwardBP = self.BackpackSlot
		local ValueText = AwardBP.TextQuantity
		if AwardBP and ValueText then
			UIUtil.SetColorAndOpacityHex(ValueText, "FFF9E1FF")
			ValueText:SetText("")
			local RewardBasic = MiniGameInst:GetTheRewardGotInTheRoundInternal(0)
			local BasicItem = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
			BasicItem.Num = nil
			self.ScoreItem:UpdateVM(BasicItem)
			local RewardGot = MiniGameInst:GetResultRewardSev()
			local bRewardCritical = MiniGameInst:GetRltCritical()
			if bRewardCritical then
				local ParamCfg = OutOnALimbParamCfg:FindCfgByKey(alone_tree_ore_search_param_type.ALONE_TREE_ORE_SEARCH_PARAM_TYPE_CRITICAL_HIT_TIMES)
				if ParamCfg then
					local CriticalMutiply = ParamCfg.Value or 1
					-- 暴击特效
					FLOG_INFO("矿脉小游戏暴击了！！")
					UIUtil.SetIsVisible(CriticalTipWidget, true)
					CriticalTipWidget:ShowCriticalTips(string.format(LSTR(380015), tostring(CriticalMutiply)))

					local CriticalAnim = AwardBP.AnimCriticalIn
					if CriticalAnim then
						AwardBP:PlayAnimation(CriticalAnim)
					end
					self:RegisterTimer(function()
						ValueText:SetText(tostring(RewardGot))
					end, CriticalAnimDelayChangeNumTime)
				end
			else
				ValueText:SetText(tostring(RewardGot))
			end
			--GoldSaucerMiniGameMgr:SendMsgAloneTreeExitReward(MiniGameType.TheFinerMiner) -- 发放奖励飘窗
			local RewardChangeNum = RewardGot - RewardBasic
			UIUtil.SetIsVisible(self.TextNumberReward, RewardChangeNum > 0)
			UIUtil.SetIsVisible(self.ImgArrow, RewardChangeNum > 0)
			if RewardChangeNum > 0 then
				local RewardChangeContent = tostring(RewardChangeNum)
				if RewardChangeContent then
					self.TextNumberReward:SetText(RewardChangeContent)
				end
				--[[self.SuccessScoreChangeTimerID = self:RegisterTimer(function()
					RewardBasic = math.floor(RewardBasic + 0.05 / GoldSaucerMiniGameDefine.CutResultScoreChangeTime * RewardChangeNum)
					if RewardBasic >= RewardGot  then
						RewardBasic = RewardGot
					end
					local EndItem = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, RewardBasic)
					self.ScoreItem:UpdateVM(EndItem)
					if RewardBasic == RewardGot then
						self:UnRegisterTimer(self.SuccessScoreChangeTimerID)
						
					end
				end, 0, 0.05, 0)--]]
			end
		end
	else
		local FailTitle
		if EndState == MiniGameRoundEndState.FailTime then
			FailTitle = LSTR(380016)
		elseif EndState == MiniGameRoundEndState.FailChance  then
			FailTitle = LSTR(380017)
		end
		self.TextTime:SetText(FailTitle or "")
		GoldSaucerMiniGameMgr:PlayEmotionActInSettlementStage(MiniGameType.TheFinerMiner, false)
	end
	self:UpdateNextRoundGamePanel()
	_G.UIViewMgr:HideView(_G.UIViewID.TheFinerMinerMainPanel)
end

function TheFinerMinerSettlementPanelView:OnHide()
	GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.TheFinerMiner, self.bRewar)
end

function TheFinerMinerSettlementPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnBtnGoClick)
	UIUtil.AddOnClickedEvent(self, self.BtnLeave, self.OnBtnLeaveClick)
	UIUtil.AddOnClickedEvent(self, self.BtnRewar, self.OnBtnRewarClick)
	self.BtnClose:SetCallback(self, self.OnBtnLeaveClick)
end

function TheFinerMinerSettlementPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function TheFinerMinerSettlementPanelView:OnRegisterBinder()
	self.BackpackSlot:SetParams({Data = self.ScoreItem})
	local ViewModel = self.Params
    if ViewModel == nil then
        return
    end
	
    self:RegisterBinders(ViewModel, self.Binders)
	local BackpackSlot = self.BackpackSlot
	if BackpackSlot then
		local BpSlot = BackpackSlot.Comm96Slot
		if BpSlot then
			BpSlot:SetParams({Data = self.ScoreItem})
		end
	end
end

--- 更新再战和获取途径面板切换
function TheFinerMinerSettlementPanelView:UpdateNextRoundGamePanel()
	local ReplayCost
	local ClientCfg = MiniGameClientConfig[MiniGameType.OutOnALimb]
	if ClientCfg then
		ReplayCost = ClientCfg.Cost or 0
	else
		ReplayCost = 0
	end
	local PlayerHaveScore = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	local bShowReplayPanel = PlayerHaveScore >= ReplayCost
	UIUtil.SetIsVisible(self.RewarPanel, bShowReplayPanel)
	UIUtil.SetIsVisible(self.GoPanel, not bShowReplayPanel)
	if bShowReplayPanel then
		self.TextNumber1:SetText(tostring(ReplayCost))
	end
end

function TheFinerMinerSettlementPanelView:OnMoneyUpdate()
	self.MoneySlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)
	self:UpdateNextRoundGamePanel()
end

function TheFinerMinerSettlementPanelView:OnBtnGoClick()
	-- TODO 前往获取
	_G.JumboCactpotMgr:GetJDcoin()
	self.bRewar = false
	self:Hide()
end

function TheFinerMinerSettlementPanelView:OnBtnLeaveClick()
	self.bRewar = false
	self:Hide()
end

function TheFinerMinerSettlementPanelView:OnBtnRewarClick()
	local GuarateeOnceClickOfRefight = self.GuarateeOnceClickOfRefight
	if GuarateeOnceClickOfRefight then
		return
	end
	self.GuarateeOnceClickOfRefight = true
	self.bRewar = true
	self:Hide()
	GoldSaucerMiniGameMgr:OnBtnFightAgainClick(MiniGameType.TheFinerMiner)
end

--- 刷新挑战结果面板信息
function TheFinerMinerSettlementPanelView:UpdateChallengeRltPanelInfo()
	local ViewModel = self.Params
	if not ViewModel then
		return
	end

	local MiniGameInst = ViewModel.MiniGame
	if MiniGameInst == nil then
		return
	end

	-- 更新完成次数条目
	local CompleteTimesText = self.TextUndone
	local CompleteTimesNewRecordText = self.TextNewRecord1
	local CompleteTimesNewRecordAnim = self.AnimSuccessTimeCost
	local RoundIndex = MiniGameInst:GetRoundIndex() + 1
	CompleteTimesText:SetText(string.format(LSTR(380018), tostring(RoundIndex)))
	if RoundIndex >= CutResultStage.Weak then
		self:PlayAnimation(self.AnimSuccessTimes23)
	elseif RoundIndex >= CutResultStage.Strong then
		self:PlayTheSettlementAnimAlignTimeline(CompleteTimesNewRecordAnim)
	end
	local bCompleteChallengeNewRecord = MiniGameInst:GetCompleteChallengeNewRecord()
	UIUtil.SetIsVisible(CompleteTimesNewRecordText, bCompleteChallengeNewRecord)

	-- 更新完美挑战条目
	local PerfectChallengeTimeText = self.TextNumber
	local NotPerfectChallengeText = self.TextUnfinished
	local PerfectChallengeNewRecordText = self.TextNewRecord2
	local PerfectChallengeAnim = self.AnimSuccessTimes45
	local bPerfectChallenge = MiniGameInst:GetIsPerfectChallenge()
	UIUtil.SetIsVisible(PerfectChallengeTimeText, bPerfectChallenge)
	UIUtil.SetIsVisible(NotPerfectChallengeText, not bPerfectChallenge)
	
	local bPerfectChallengeNewRecord = MiniGameInst:GetPerfectChallengeNewRecord()
	UIUtil.SetIsVisible(PerfectChallengeNewRecordText, bPerfectChallengeNewRecord)

	if bPerfectChallenge then
		self:PlayTheSettlementAnimAlignTimeline(PerfectChallengeAnim)
		local PerfectChallengeTime = MiniGameInst:GetPerfectChallengeTime() or 0
		local ChallengeTimeText = string.format(LSTR(380019), PerfectChallengeTime)
		PerfectChallengeTimeText:SetText(ChallengeTimeText)
	end
end

function TheFinerMinerSettlementPanelView:PlayTheSettlementAnimAlignTimeline(Anim)
	if Anim == self.AnimSuccessTimeCost then
		self:RegisterTimer(function()
			self:PlayAnimation(Anim)
		end, AnimInRltNumShowTimeline)
	elseif Anim == self.AnimSuccessTimes45 then
		self:RegisterTimer(function()
			self:PlayAnimation(Anim)
		end, AnimInRltNumShowTimeline - AnimSuccessTimeRltNumShowTimeline)
	end
end

--- 设定功能说明信息
---@param GameStageType GoldSaucerMiniGameDefine.MiniGameStageType
function TheFinerMinerSettlementPanelView:SetTheHelpInfoTips(GameStageType)
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

return TheFinerMinerSettlementPanelView