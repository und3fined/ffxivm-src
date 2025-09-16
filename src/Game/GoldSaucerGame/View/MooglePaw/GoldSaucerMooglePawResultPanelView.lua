---
--- Author: bowxiong
--- DateTime: 2024-09-25 16:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MooglePawParamsCfg = require("TableCfg/MooglePawParamsCfg")
local LoopControlCfg = require("TableCfg/MooglePawRoundCfg")
local ProtoRes = require("Protocol/ProtoRes")
local CatchBallParamType = ProtoRes.Game.CatchBallParamType
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

local CriticalAnimDelayChangeNumTime = 1.5
local LSTR = _G.LSTR

---@class GoldSaucerMooglePawResultPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Award GoldSaucerGameCuffAwardItemView
---@field Btn1 CommBtnMView
---@field Btn2 CommBtnMView
---@field BtnGo CommBtnMView
---@field ChallengeResults GoldSaucerMoogglePawChallengeResultsItemView
---@field Critical GoldSaucerGameCommCriticalItemView
---@field GoPanel UFCanvasPanel
---@field MoneySlot CommMoneySlotView
---@field PanelBtncontinue UFCanvasPanel
---@field PanelChallengeFailurePrompt UFCanvasPanel
---@field PanelChallengeRecordList UFVerticalBox
---@field PanelCold UFCanvasPanel
---@field PanelResult UFCanvasPanel
---@field TableViewList UTableView
---@field TextAward UFTextBlock
---@field TextGo UFTextBlock
---@field TextHint1 UFTextBlock
---@field TextQuantity_1 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSettlementIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawResultPanelView = LuaClass(UIView, true)

function GoldSaucerMooglePawResultPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Award = nil
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.BtnGo = nil
	--self.ChallengeResults = nil
	--self.Critical = nil
	--self.GoPanel = nil
	--self.MoneySlot = nil
	--self.PanelBtncontinue = nil
	--self.PanelChallengeFailurePrompt = nil
	--self.PanelChallengeRecordList = nil
	--self.PanelCold = nil
	--self.PanelResult = nil
	--self.TableViewList = nil
	--self.TextAward = nil
	--self.TextGo = nil
	--self.TextHint1 = nil
	--self.TextQuantity_1 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimSettlementIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawResultPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Award)
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.ChallengeResults)
	self:AddSubView(self.Critical)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawResultPanelView:InitConstStringInfo()
	self.TextAward:SetText(LSTR(360033))
	self.TextGo:SetText(LSTR(360031))
	self.TextQuantity_1:SetText("1")
	self.TextHint1:SetText(LSTR(360036))
end

function GoldSaucerMooglePawResultPanelView:InitSubViewConstStringInfo()
	self.Btn1:SetButtonText(LSTR(360034))
	self.BtnGo:SetButtonText(LSTR(360029))
	self.Btn2:SetButtonText(LSTR(360035))
end

function GoldSaucerMooglePawResultPanelView:OnInit()
	self.AdapterTableViewList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		-- 结果展示
		{"ResultVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewList)},
	}
	self.ScoreItem = ItemVM.New({})
	self.bRewarStart = false
	self:InitConstStringInfo()
end

function GoldSaucerMooglePawResultPanelView:OnDestroy()

end

function GoldSaucerMooglePawResultPanelView:OnShow()
	self:PlayAnimation(self.AnimSettlementIn)
	self:UpdateSettlementView(self.VM)
	self:InitSubViewConstStringInfo()
end

function GoldSaucerMooglePawResultPanelView:OnHide()
	self:StopAllAnimations()
	self:UnRegisterAllTimer()
end

function GoldSaucerMooglePawResultPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnBtn1Click)
	UIUtil.AddOnPressedEvent(self, self.Btn2.Button, self.OnBtnRewarClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnBtnGoClick)
end

function GoldSaucerMooglePawResultPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function GoldSaucerMooglePawResultPanelView:OnRegisterBinder()
	self.VM = self.Params and self.Params.Data
    self:RegisterBinders(self.VM, self.Binders)
	local BackpackSlot = self.Award.Comm96Slot
	if BackpackSlot then
		BackpackSlot:SetParams({Data = self.ScoreItem})
	end
end

function GoldSaucerMooglePawResultPanelView:OnMoneyUpdate()
	self.MoneySlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)
	self:UpdateNextRoundGamePanel()
end

-- 点击离开按钮
function GoldSaucerMooglePawResultPanelView:OnBtn1Click()
	GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MooglesPaw)
end

-- 点击再战按钮
function GoldSaucerMooglePawResultPanelView:OnBtnRewarClick()
	local bRewarStart = self.bRewarStart
	if bRewarStart then
		return
	else
		self.bRewarStart = true
	end
	GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MooglesPaw, true)
	if self.VM then
		self.VM:ResetVMInfo()
	end
	
	GoldSaucerMiniGameMgr:OnBtnFightAgainClick(MiniGameType.MooglesPaw)
end

-- 点击获取金碟币按钮
function GoldSaucerMooglePawResultPanelView:OnBtnGoClick()
	_G.JumboCactpotMgr:GetJDcoin()
	if self.VM == nil then
		return
	end

	if not self.VM.bShowGameOrSettlementPanel then
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MooglesPaw)
	end
end

function GoldSaucerMooglePawResultPanelView:UpdateSettlementView(ViewModel)
	if not ViewModel then
		return
	end

	local MiniGameInst = ViewModel.MiniGame
	if MiniGameInst == nil then
		return
	end

	self.MoneySlot:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, true, nil, true)

	local EndState = MiniGameInst:GetRoundEndState()
	local bShowSuccessPanel = EndState == MiniGameRoundEndState.Success
	local ChallengeResults = self.ChallengeResults
	if ChallengeResults then
		ChallengeResults:UpdateChallengeResult(EndState)
	end
	UIUtil.SetIsVisible(self.PanelChallengeRecordList, bShowSuccessPanel)
	UIUtil.SetIsVisible(self.PanelChallengeFailurePrompt, not bShowSuccessPanel)

	local CriticalWidget = self.Critical
	if CriticalWidget then
		UIUtil.SetIsVisible(CriticalWidget, false)
	end

	if bShowSuccessPanel then
		local RoundId = MiniGameInst:GetCurRoundId()
		local LoopCfg = LoopControlCfg:FindCfgByKey(RoundId)
		local EmotionIDToPlay = LoopCfg and LoopCfg.EmotionID or 0
		GoldSaucerMiniGameMgr:PlayEmotionActInSettlementStage(MiniGameType.MooglesPaw, true, EmotionIDToPlay)
		local RoundIndex = MiniGameInst:GetRoundIndex() + 1
		ViewModel:UpdateResultList(RoundIndex)
		local AwardBP = self.Award
		if AwardBP then
			local ScoreItemView = AwardBP.Comm96Slot
			local ValueText = AwardBP.TextQuantity
			if ScoreItemView and ValueText then
				UIUtil.SetColorAndOpacityHex(ValueText, "FFF9E1FF")
				local EndItem = ItemUtil.CreateItem(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
				EndItem.Num = nil
				self.ScoreItem:UpdateVM(EndItem, {HideItemLevel = true})
				local RewardGot = MiniGameInst:GetResultRewardSev() or 0
				local bRewardCritical = MiniGameInst:GetRltCritical()
				if bRewardCritical then
					local ParamCfg = MooglePawParamsCfg:FindCfgByKey(CatchBallParamType.CatchBallParamTypeCriticalHitTimes)
					if ParamCfg then
						local CriticalMutiply = ParamCfg.Value or 1
						-- 暴击特效
						FLOG_INFO("莫古抓球机小游戏暴击了！！")
						if CriticalWidget then
							UIUtil.SetIsVisible(CriticalWidget, true)
							CriticalWidget:ShowCriticalTips(string.format(LSTR(360038), tostring(CriticalMutiply)))
						end
						ValueText:SetText(tostring(math.floor(RewardGot / CriticalMutiply)))
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
			end
		end
	else
		GoldSaucerMiniGameMgr:PlayEmotionActInSettlementStage(MiniGameType.MooglesPaw, false)
	end

	self:UpdateNextRoundGamePanel()
end


--- 更新再战和获取途径面板切换
function GoldSaucerMooglePawResultPanelView:UpdateNextRoundGamePanel()
	-- 货币是否充足的不同显示
	local ReplayCost
	local ClientCfg = MiniGameClientConfig[MiniGameType.MooglesPaw]
	if ClientCfg then
		ReplayCost = ClientCfg.Cost or 1
	else
		ReplayCost = 0
	end
	local PlayerHaveScore = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	local bShowReplayPanel = PlayerHaveScore >= ReplayCost
	UIUtil.SetIsVisible(self.PanelBtncontinue, bShowReplayPanel)
	UIUtil.SetIsVisible(self.GoPanel, not bShowReplayPanel)
end

return GoldSaucerMooglePawResultPanelView