---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description: 大赛详情界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local AudioUtil = require("Utils/AudioUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local MagicCardVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")

local UE = _G.UE

---@class CardsTourneyInfoNewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose_1 UFButton
---@field BtnInfo UFButton
---@field BtnRank UFButton
---@field FCanvasEffect UFCanvasPanel
---@field ImgNode02 UFImage
---@field ImgNode04 UFImage
---@field ImgNode06 UFImage
---@field ImgNode08 UFImage
---@field ImgRankIcon UFImage
---@field NodeRewardNew01 CommBackpack74SlotView
---@field NodeRewardNew02 CommBackpack74SlotView
---@field NodeRewardNew03 CommBackpack74SlotView
---@field NodeRewardNew04 CommBackpack74SlotView
---@field NodeRewardNew05 CommBackpack74SlotView
---@field NodeRewardNew06 CommBackpack74SlotView
---@field NodeRewardNew07 CommBackpack74SlotView
---@field NodeRewardNew08 CommBackpack74SlotView
---@field PanelInfoContent UFCanvasPanel
---@field PanelNode01 UFCanvasPanel
---@field PanelNode02 UFCanvasPanel
---@field PanelNode03 UFCanvasPanel
---@field PanelNode04 UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PanelRankContent UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field Probar UProgressBar
---@field RichTextTitle01 URichTextBox
---@field RichTextTitle02 URichTextBox
---@field ScaleSelf UScaleBox
---@field SelfRewardNew01 CommBackpack58SlotView
---@field SelfRewardNew02 CommBackpack58SlotView
---@field TableViewBattleInfo UTableView
---@field TableViewRankList UTableView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field TextNodeCount01 UFTextBlock
---@field TextNodeCount02 UFTextBlock
---@field TextNodeCount03 UFTextBlock
---@field TextNodeCount04 UFTextBlock
---@field TextSelfCount UFTextBlock
---@field TextSelfPlayerName UFTextBlock
---@field TextSelfRank UFTextBlock
---@field TextTime01 UFTextBlock
---@field TextTime02 UFTextBlock
---@field TextTitle UFTextBlock
---@field WidgetSwitcherTab UFWidgetSwitcher
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyInfoNewWinView = LuaClass(UIView, true)

function CardsTourneyInfoNewWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose_1 = nil
	--self.BtnInfo = nil
	--self.BtnRank = nil
	--self.FCanvasEffect = nil
	--self.ImgNode02 = nil
	--self.ImgNode04 = nil
	--self.ImgNode06 = nil
	--self.ImgNode08 = nil
	--self.ImgRankIcon = nil
	--self.NodeRewardNew01 = nil
	--self.NodeRewardNew02 = nil
	--self.NodeRewardNew03 = nil
	--self.NodeRewardNew04 = nil
	--self.NodeRewardNew05 = nil
	--self.NodeRewardNew06 = nil
	--self.NodeRewardNew07 = nil
	--self.NodeRewardNew08 = nil
	--self.PanelInfoContent = nil
	--self.PanelNode01 = nil
	--self.PanelNode02 = nil
	--self.PanelNode03 = nil
	--self.PanelNode04 = nil
	--self.PanelProbar = nil
	--self.PanelRankContent = nil
	--self.PopUpBG = nil
	--self.Probar = nil
	--self.RichTextTitle01 = nil
	--self.RichTextTitle02 = nil
	--self.ScaleSelf = nil
	--self.SelfRewardNew01 = nil
	--self.SelfRewardNew02 = nil
	--self.TableViewBattleInfo = nil
	--self.TableViewRankList = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.TextNodeCount01 = nil
	--self.TextNodeCount02 = nil
	--self.TextNodeCount03 = nil
	--self.TextNodeCount04 = nil
	--self.TextSelfCount = nil
	--self.TextSelfPlayerName = nil
	--self.TextSelfRank = nil
	--self.TextTime01 = nil
	--self.TextTime02 = nil
	--self.TextTitle = nil
	--self.WidgetSwitcherTab = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	--ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_SCORE
	

	

end

function CardsTourneyInfoNewWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.NodeRewardNew01)
	self:AddSubView(self.NodeRewardNew02)
	self:AddSubView(self.NodeRewardNew03)
	self:AddSubView(self.NodeRewardNew04)
	self:AddSubView(self.NodeRewardNew05)
	self:AddSubView(self.NodeRewardNew06)
	self:AddSubView(self.NodeRewardNew07)
	self:AddSubView(self.NodeRewardNew08)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.SelfRewardNew01)
	self:AddSubView(self.SelfRewardNew02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyInfoNewWinView:OnInit()
	self.SelectedEffectListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBattleInfo, nil, true, false)
	self.RankListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRankList, nil, true, false)
	self.Binders = {
		{"CurStageText", UIBinderSetText.New(self, self.RichTextTitle02) },
		{"TourneyDetailScoreText", UIBinderSetText.New(self, self.RichTextTitle01) },
		{"SelectedEffectVMList", UIBinderUpdateBindableList.New(self, self.SelectedEffectListAdapter)},
		{"PlayerName", UIBinderSetText.New(self, self.TextSelfPlayerName)},
		{"PlayerScore", UIBinderSetText.New(self, self.TextSelfCount)},
		{"SettlementDateText", UIBinderSetText.New(self, self.TextTime01)},
		{"SettlementDateText", UIBinderSetText.New(self, self.TextTime02)},
		{"PlayerRank", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerRankChanged)},
		{"TourneyRankList", UIBinderUpdateBindableList.New(self, self.RankListAdapter)}, 
		{"ScoreProgress", UIBinderSetPercent.New(self, self.Probar)},
	}

	self.AwardWidgetRef = 
	{
		[1] = {[1] = self.NodeRewardNew01, [2] = self.NodeRewardNew02},
		[2] = {[1] = self.NodeRewardNew03, [2] = self.NodeRewardNew04},
		[3] = {[1] = self.NodeRewardNew05, [2] = self.NodeRewardNew06},
		[4] = {[1] = self.NodeRewardNew07, [2] = self.NodeRewardNew08},
	}

	self.GetProgressWidgetRef = 
	{
		[1] = self.ImgNode02,
		[2] = self.ImgNode04,
		[3] = self.ImgNode06,
		[4] = self.ImgNode08,
	}

	self.AwardNodeWidgetRef = 
	{
		[1] = self.TextNodeCount01,
		[2] = self.TextNodeCount02,
		[3] = self.TextNodeCount03,
		[4] = self.TextNodeCount04,
	}

	self.PanelNodeWidgetRef = 
	{
		[1] = self.PanelNode01,
		[2] = self.PanelNode02,
		[3] = self.PanelNode03,
		[4] = self.PanelNode04,
	}

	self.SelfRewardWidgetRef = 
	{
		[1] = self.SelfRewardNew02,
		[2] = self.SelfRewardNew01,
	}
end

function CardsTourneyInfoNewWinView:OnDestroy()

end

function CardsTourneyInfoNewWinView:SetLSTR()
    self.TextTitle:SetText(_G.LSTR(1150025))--("幻卡大赛")
	self.Text01:SetText(_G.LSTR(1150062))--("排名")
	self.Text02:SetText(_G.LSTR(1150063))--("选手")
	self.Text03:SetText(_G.LSTR(1150064))--("积分")
	self.Text04:SetText(_G.LSTR(1150065))--("奖励")
end

function CardsTourneyInfoNewWinView:OnShow()
	self:SetLSTR()
	AudioUtil.LoadAndPlayUISound(TourneyDefine.SoundPath.Common)
	self:ShowInfoContent(true)

	for _, GetProgressWidget in ipairs(self.GetProgressWidgetRef) do
		UIUtil.SetIsVisible(GetProgressWidget, false)
	end

	for _, AwardWidgetList in ipairs(self.AwardWidgetRef) do
		for _, AwardWidget in ipairs(AwardWidgetList) do
			UIUtil.SetIsVisible(AwardWidget, false)
		end
	end

	local PlayerScore = TourneyVM:GetPlayerScore()

	local GetProgressWidgetSize = 0
	-- 初始化所有积分与对应的奖励信息
	local ScoreAwardInfo = MagicCardVMUtils.GetScoreAwardInfo()
	for NodeIndex, Award in ipairs(ScoreAwardInfo) do
		local NodeScore = Award.AwardScore
		local NodeAwardList = Award.AwardList
		-- 设置金碟币奖励需要达成的积分
		local NodeWidget = self.AwardNodeWidgetRef[NodeIndex]
		if NodeWidget then
			NodeWidget:SetText(NodeScore)
		end

		-- 设置奖励
		for AwardIndex, NodeAward in ipairs(NodeAwardList) do
			-- 设置金碟币奖励
			local AwardWidget = self.AwardWidgetRef[NodeIndex][AwardIndex]
			local GetProgressWidget = self.GetProgressWidgetRef[NodeIndex]
			GetProgressWidgetSize = UIUtil.GetWidgetSize(GetProgressWidget)
			if AwardWidget then
				UIUtil.SetIsVisible(AwardWidget, true)
				local Cfg = ItemCfg:FindCfgByKey(NodeAward.ResID or 0 )
				local ImgPath = Cfg and ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
				AwardWidget:SetIconImg(ImgPath)
				AwardWidget:SetNum(NodeAward.Num)
				AwardWidget:SetIconChooseVisible(false)
				AwardWidget:SetClickButtonCallback(self, self.OnNodeRewardClicked)
			end
			-- 刷新玩家积分对应的奖励
			if PlayerScore >= NodeScore then
				if AwardWidget then
					--UIUtil.SetIsVisible(AwardWidget.FImg_Select, true)
					AwardWidget:SetRewardShow(true)
				end
				if GetProgressWidget then
					UIUtil.SetIsVisible(GetProgressWidget, true)
				end
			end
		end
		-- 动态设置奖励节点位置
		local PanelNode = self.PanelNodeWidgetRef[NodeIndex]
		if PanelNode then
			local Size = UIUtil.GetWidgetSize(self.Probar)
			local PanelNodeSize = UIUtil.GetWidgetSize(PanelNode)
			local Percent = NodeScore/TourneyDefine.MaxScore
			local ProBarPosition = UIUtil.CanvasSlotGetPosition(self.PanelProbar)
			local NewPosition = UE.FVector2D(Percent * Size.X - Size.X/2 - PanelNodeSize.X/2 - ProBarPosition.X + GetProgressWidgetSize.X/4, 0)
			UIUtil.CanvasSlotSetPosition(PanelNode, NewPosition)
		end
	end

	-- 动态设置进度动效位置
	local EffectNode = self.FCanvasEffect
	local Percent = PlayerScore/TourneyDefine.MaxScore
	UIUtil.SetIsVisible(self.FCanvasEffect, Percent > 0)
	if EffectNode then
		local Size = UIUtil.GetWidgetSize(self.Probar)
		local PanelNodeSize = UIUtil.GetWidgetSize(EffectNode)
		local ProBarPosition = UIUtil.CanvasSlotGetPosition(self.PanelProbar)
		local NewPosition = UE.FVector2D(Percent * Size.X - Size.X/2 - PanelNodeSize.X - ProBarPosition.X - GetProgressWidgetSize.X/4, 0)
		UIUtil.CanvasSlotSetPosition(EffectNode, NewPosition)
	end
end

function CardsTourneyInfoNewWinView:OnHide()

end

function CardsTourneyInfoNewWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRank, self.OnBtnRankClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnBtnInfoClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnClose_1, self.Hide)
end

function CardsTourneyInfoNewWinView:OnRegisterGameEvent()

end

function CardsTourneyInfoNewWinView:OnRegisterBinder()
	if TourneyVM then
		self:RegisterBinders(TourneyVM, self.Binders)
	end
end

function CardsTourneyInfoNewWinView:OnBtnRankClicked()
	self:ShowInfoContent(false)
end

function CardsTourneyInfoNewWinView:OnBtnInfoClicked()
	self:ShowInfoContent(true)
end

function CardsTourneyInfoNewWinView:OnPlayerRankChanged(Rank)
	local RankText = MagicCardVMUtils.GetRankText(Rank)
	self.TextSelfRank:SetText(RankText)
	
	-- 获取排名奖励
	local TourneyID = TourneyVM:GetTourneyID()
	self.RankAwardList = MagicCardVMUtils.GetAwardListByRank(Rank, TourneyID)

	for _, SelfRewardWidget in ipairs(self.SelfRewardWidgetRef) do
		UIUtil.SetIsVisible(SelfRewardWidget, false)
	end

	-- 排名未达到奖励
	if self.RankAwardList == nil or next(self.RankAwardList) == nil then
		UIUtil.SetIsVisible(self.ImgRankIcon, false)
		return
	end
	
	for index, RankAward in ipairs(self.RankAwardList) do
		local SelfRewardWidget = self.SelfRewardWidgetRef[index]
		if SelfRewardWidget then
			UIUtil.SetIsVisible(SelfRewardWidget, true)
			UIUtil.SetIsVisible(SelfRewardWidget.ImgSelect, false)
			UIUtil.SetIsVisible(SelfRewardWidget.IconChoose, false)
	
			SelfRewardWidget:SetClickButtonCallback(self, self.OnSelfRewardClicked)
			local Cfg = ItemCfg:FindCfgByKey(RankAward.ResID or 0 )
			local ImgPath = Cfg and ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
			SelfRewardWidget:SetIconImg(ImgPath)
			local RewardNum = RankAward.Num
			if RewardNum > 1 then
				SelfRewardWidget:SetNumVisible(true)
				SelfRewardWidget:SetNum(RewardNum)
			else
				SelfRewardWidget:SetNumVisible(false)
			end
		end
	end
end

function CardsTourneyInfoNewWinView:ShowInfoContent(IsShow)
	if IsShow == true then
		self.WidgetSwitcherTab:SetActiveWidgetIndex(1)
		UIUtil.SetIsVisible(self.PanelRankContent, false)
		UIUtil.SetIsVisible(self.PanelInfoContent, true)
	else
		self.WidgetSwitcherTab:SetActiveWidgetIndex(0)
		UIUtil.SetIsVisible(self.PanelRankContent, true)
		UIUtil.SetIsVisible(self.PanelInfoContent, false)
	end
end

function CardsTourneyInfoNewWinView:OnSelfRewardClicked(ItemView)
	for index, RewardWidget in ipairs(self.SelfRewardWidgetRef) do
		if RewardWidget == ItemView then
			local RankAward = self.RankAwardList[index]
			local AwardID = RankAward and RankAward.ResID
			local Cfg = ItemCfg:FindCfgByKey(AwardID)
			if Cfg then
				ItemTipsUtil.ShowTipsByItem({ResID = AwardID}, RewardWidget, {X = -2, Y = -15})
			end
		end
	end
end

function CardsTourneyInfoNewWinView:OnNodeRewardClicked(ItemView)
	local ScoreAwardInfo = MagicCardVMUtils.GetScoreAwardInfo()
	for NodeIndex, Award in ipairs(ScoreAwardInfo) do
		local NodeAwardList = Award.AwardList
		for AwardIndex, NodeAward in ipairs(NodeAwardList) do
			local AwardWidget = self.AwardWidgetRef[NodeIndex][AwardIndex]
			if AwardWidget == ItemView then
				UIUtil.SetIsVisible(AwardWidget, true)
				ItemTipsUtil.ShowTipsByItem({ResID = NodeAward.ResID}, AwardWidget, {X = -2, Y = -15})
			end
		end
	end
end

return CardsTourneyInfoNewWinView