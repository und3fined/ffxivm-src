---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:领取奖励界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local AudioUtil = require("Utils/AudioUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local MagicCardVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local UE = _G.UE

---@class CardsTourneyFinalSettlementWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose_1 UFButton
---@field BtnGet CommBtnLView
---@field FCanvasEffect UFCanvasPanel
---@field Geted UFTextBlock
---@field ImgNode02 UFImage
---@field ImgNode04 UFImage
---@field ImgNode06 UFImage
---@field ImgNode08 UFImage
---@field ImgRankIcon UFImage
---@field NodeReward01 CommBackpackSlotView
---@field NodeReward02 CommBackpackSlotView
---@field NodeReward03 CommBackpackSlotView
---@field NodeReward04 CommBackpackSlotView
---@field NodeReward05 CommBackpackSlotView
---@field NodeReward06 CommBackpackSlotView
---@field NodeReward07 CommBackpackSlotView
---@field NodeReward08 CommBackpackSlotView
---@field PanelBtnDone UFCanvasPanel
---@field PanelNode01 UFCanvasPanel
---@field PanelNode02 UFCanvasPanel
---@field PanelNode03 UFCanvasPanel
---@field PanelNode04 UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field Probar UProgressBar
---@field ScaleSelf UScaleBox
---@field SelfReward01 CommBackpack58SlotView
---@field SelfReward02 CommBackpack58SlotView
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
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyFinalSettlementWinView = LuaClass(UIView, true)

function CardsTourneyFinalSettlementWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose_1 = nil
	--self.BtnGet = nil
	--self.FCanvasEffect = nil
	--self.Geted = nil
	--self.ImgNode02 = nil
	--self.ImgNode04 = nil
	--self.ImgNode06 = nil
	--self.ImgNode08 = nil
	--self.ImgRankIcon = nil
	--self.NodeReward01 = nil
	--self.NodeReward02 = nil
	--self.NodeReward03 = nil
	--self.NodeReward04 = nil
	--self.NodeReward05 = nil
	--self.NodeReward06 = nil
	--self.NodeReward07 = nil
	--self.NodeReward08 = nil
	--self.PanelBtnDone = nil
	--self.PanelNode01 = nil
	--self.PanelNode02 = nil
	--self.PanelNode03 = nil
	--self.PanelNode04 = nil
	--self.PanelProbar = nil
	--self.PopUpBG = nil
	--self.Probar = nil
	--self.ScaleSelf = nil
	--self.SelfReward01 = nil
	--self.SelfReward02 = nil
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
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyFinalSettlementWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.NodeReward01)
	self:AddSubView(self.NodeReward02)
	self:AddSubView(self.NodeReward03)
	self:AddSubView(self.NodeReward04)
	self:AddSubView(self.NodeReward05)
	self:AddSubView(self.NodeReward06)
	self:AddSubView(self.NodeReward07)
	self:AddSubView(self.NodeReward08)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.SelfReward01)
	self:AddSubView(self.SelfReward02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyFinalSettlementWinView:OnInit()
	self.RankListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRankList, nil, true, false)
	self.Binders = {
		{"TourneyRankList", UIBinderUpdateBindableList.New(self, self.RankListAdapter)},
		{"PlayerName", UIBinderSetText.New(self, self.TextSelfPlayerName)},
		{"PlayerScore", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerScoreChanged)},
		{"PlayerRank", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerRankChanged)},
		{"ScoreProgress", UIBinderSetPercent.New(self, self.Probar)},
		{"AwardCollected", UIBinderSetIsVisible.New(self, self.PanelBtnDone)},  --- 已领奖按钮
		--{"IsActive", UIBinderSetIsVisible.New(self, self.TextAfterGet)},   --- 不可领奖
		{"CanAwardCollect", UIBinderSetIsVisible.New(self, self.BtnGet)}, --- 重构 领奖按钮
	}
	-- 设置奖励
	self.AwardWidgetRef = 
	{
		[1] = {[1] = self.NodeReward01, [2] = self.NodeReward02},
		[2] = {[1] = self.NodeReward03, [2] = self.NodeReward04},
		[3] = {[1] = self.NodeReward05, [2] = self.NodeReward06},
		[4] = {[1] = self.NodeReward07, [2] = self.NodeReward08},
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
		[1] = self.SelfReward02,
		[2] = self.SelfReward01,
	}
end

function CardsTourneyFinalSettlementWinView:OnDestroy()

end

function CardsTourneyFinalSettlementWinView:SetLSTR()
    self.TextTitle:SetText(_G.LSTR(1150061))--("幻卡大赛结算")
	self.Text01:SetText(_G.LSTR(1150062))--("排名")
	self.Text02:SetText(_G.LSTR(1150063))--("选手")
	self.Text03:SetText(_G.LSTR(1150064))--("积分")
	self.Text04:SetText(_G.LSTR(1150065))--("奖励")
	self.Geted:SetText(_G.LSTR(1150066))--("已领取")
	self.BtnGet:SetButtonText(_G.LSTR(1150067))--("领取")
end

function CardsTourneyFinalSettlementWinView:OnShow()
	self:SetLSTR()
	AudioUtil.LoadAndPlayUISound(TourneyDefine.SoundPath.Common)
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
				AwardWidget:SetClickButtonCallback(self, self.OnNodeRewardClicked)
			end
			-- 刷新玩家积分对应的奖励
			if PlayerScore >= NodeScore then
				if AwardWidget then
					UIUtil.SetIsVisible(AwardWidget.FImg_Select, true)
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
	Percent = math.clamp(Percent, 0, 1)
	UIUtil.SetIsVisible(self.FCanvasEffect, Percent > 0)
	if EffectNode then
		local Size = UIUtil.GetWidgetSize(self.Probar)
		local PanelNodeSize = UIUtil.GetWidgetSize(EffectNode)
		local ProBarPosition = UIUtil.CanvasSlotGetPosition(self.PanelProbar)
		local NewPosition = UE.FVector2D(Percent * Size.X - Size.X/2 - PanelNodeSize.X - ProBarPosition.X - GetProgressWidgetSize.X/4, 0)
		UIUtil.CanvasSlotSetPosition(EffectNode, NewPosition)
	end
	----

	UIUtil.SetIsVisible(self.SelfReward01.ImgSelect, true)
	local Secs = TourneyVM:GetRemainTimeForReward()
	local LocalRemainTime = LocalizationUtil.GetCountdownTimeForLongTime(Secs) --天小时 _G.DateTimeTools.TimeFormat(Secs, "dd:hh", true) 
	local TimeText = string.format(TourneyDefine.RemainTimeForAwardText, LocalRemainTime)
	self.TextTime01:SetText(TimeText)
end

function CardsTourneyFinalSettlementWinView:OnHide()

end

function CardsTourneyFinalSettlementWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose_1, self.OnClose)
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnBtnClickedGetReward)
end

function CardsTourneyFinalSettlementWinView:OnRegisterGameEvent()

end

function CardsTourneyFinalSettlementWinView:OnRegisterBinder()
	if TourneyVM then
		self:RegisterBinders(TourneyVM, self.Binders)
	end
end

function CardsTourneyFinalSettlementWinView:OnPlayerRankChanged(Rank)
	local RankText = MagicCardVMUtils.GetRankText(Rank)
	self.TextSelfRank:SetText(RankText)

	-- 获取排名奖励
	local TourneyID = TourneyVM:GetTourneyID()
	self.RankAwardList = MagicCardVMUtils.GetAwardListByRank(Rank, TourneyID)

	for _, SelfRewardWidget in ipairs(self.SelfRewardWidgetRef) do
		UIUtil.SetIsVisible(SelfRewardWidget.IconChoose, false)
		SelfRewardWidget:SetItemLevelVisibility(false)
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
			local IsReward = MagicCardTourneyMgr:IsCanGetReward()
			UIUtil.SetIsVisible(SelfRewardWidget.ImgSelect, false)
			UIUtil.SetIsVisible(SelfRewardWidget.PanelAvailable, IsReward)
			SelfRewardWidget:SetClickButtonCallback(self, self.OnRewardClicked)
			if RankAward.ResID and RankAward.ResID > 0 then
				local Cfg = ItemCfg:FindCfgByKey(RankAward.ResID)
				local ImgPath = Cfg and ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
				SelfRewardWidget:SetIconImg(ImgPath)
			end
			local RewardNum = RankAward.Num
			if RewardNum > 1 then
				SelfRewardWidget:SetNum(RewardNum)
			else
				SelfRewardWidget:SetNumVisible(false)
			end
		end
	end
end

function CardsTourneyFinalSettlementWinView:OnRewardClicked(ItemView)
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

function CardsTourneyFinalSettlementWinView:OnNodeRewardClicked(ItemView)
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

function CardsTourneyFinalSettlementWinView:OnPlayerScoreChanged(Score)
	self.TextSelfCount:SetText(Score)
	-- if self.AwardCfgList == nil then
	-- 	return
	-- end

	-- -- 领奖时高亮显示奖品UI
	-- for index, AwardCfg in ipairs(self.AwardCfgList) do
	-- 	local Widget = self.AwardWidgetRef[index][1]
	-- 	if Widget and Score >= AwardCfg.Arg then
	-- 		UIUtil.SetIsVisible(Widget.FImg_Select, true)
	-- 	end
	-- end
end


function CardsTourneyFinalSettlementWinView:OnClose()
	self:Hide()
end

function CardsTourneyFinalSettlementWinView:OnBtnClickedGetReward()
	self:Hide()
	if MagicCardTourneyMgr then
		MagicCardTourneyMgr:SendMsgClaimReward()
		MagicCardTourneyMgr:EndInteraction()
	end
end


return CardsTourneyFinalSettlementWinView