---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description: 新阶段结算界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local AudioUtil = require("Utils/AudioUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local MagicCardTourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local FMath = _G.UE.UMathUtil
local UE = _G.UE

---@class CardsTourneyStageSettlementWinView : UIView
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
---@field ImgcardIcon UFImage
---@field ImgcardIconBG UFImage
---@field NodeReward01 CommBackpackSlotView
---@field NodeReward02 CommBackpackSlotView
---@field NodeReward03 CommBackpackSlotView
---@field NodeReward04 CommBackpackSlotView
---@field NodeReward05 CommBackpackSlotView
---@field NodeReward06 CommBackpackSlotView
---@field NodeReward07 CommBackpackSlotView
---@field NodeReward08 CommBackpackSlotView
---@field PanelInfoContent UFCanvasPanel
---@field PanelNode01 UFCanvasPanel
---@field PanelNode02 UFCanvasPanel
---@field PanelNode03 UFCanvasPanel
---@field PanelNode04 UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PanelRankContent UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field Probar UProgressBar
---@field ScaleSelf UScaleBox
---@field SelfReward01 CommBackpackSlotView
---@field SelfReward02 CommBackpackSlotView
---@field TableViewRankList UTableView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field TextBuffName UFTextBlock
---@field TextIntegral UFTextBlock
---@field TextIntegral02 UFTextBlock
---@field TextMark02 UFTextBlock
---@field TextMark03 UFTextBlock
---@field TextMark04 UFTextBlock
---@field TextMark05 UFTextBlock
---@field TextNodeCount01 UFTextBlock
---@field TextNodeCount02 UFTextBlock
---@field TextNodeCount03 UFTextBlock
---@field TextNodeCount04 UFTextBlock
---@field TextNow01 UFTextBlock
---@field TextNow02 URichTextBox
---@field TextNow03 URichTextBox
---@field TextNow04 URichTextBox
---@field TextNow05 URichTextBox
---@field TextSelfCount UFTextBlock
---@field TextSelfPlayerName UFTextBlock
---@field TextSelfRank UFTextBlock
---@field TextTime01 UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field WidgetSwitcherTab UFWidgetSwitcher
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyStageSettlementWinView = LuaClass(UIView, true)

function CardsTourneyStageSettlementWinView:Ctor()
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
	--self.ImgcardIcon = nil
	--self.ImgcardIconBG = nil
	--self.NodeReward01 = nil
	--self.NodeReward02 = nil
	--self.NodeReward03 = nil
	--self.NodeReward04 = nil
	--self.NodeReward05 = nil
	--self.NodeReward06 = nil
	--self.NodeReward07 = nil
	--self.NodeReward08 = nil
	--self.PanelInfoContent = nil
	--self.PanelNode01 = nil
	--self.PanelNode02 = nil
	--self.PanelNode03 = nil
	--self.PanelNode04 = nil
	--self.PanelProbar = nil
	--self.PanelRankContent = nil
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
	--self.TextBuffName = nil
	--self.TextIntegral = nil
	--self.TextIntegral02 = nil
	--self.TextMark02 = nil
	--self.TextMark03 = nil
	--self.TextMark04 = nil
	--self.TextMark05 = nil
	--self.TextNodeCount01 = nil
	--self.TextNodeCount02 = nil
	--self.TextNodeCount03 = nil
	--self.TextNodeCount04 = nil
	--self.TextNow01 = nil
	--self.TextNow02 = nil
	--self.TextNow03 = nil
	--self.TextNow04 = nil
	--self.TextNow05 = nil
	--self.TextSelfCount = nil
	--self.TextSelfPlayerName = nil
	--self.TextSelfRank = nil
	--self.TextTime01 = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.WidgetSwitcherTab = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	--ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_SCORE
	

	

end

function CardsTourneyStageSettlementWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
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

function CardsTourneyStageSettlementWinView:OnInit()
	--self.SelectedEffectListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBattleInfo, nil, true, false)
	self.RankListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRankList, nil, true, false)
	self.Binders = {
		--{"CurStageText", UIBinderSetText.New(self, self.RichTextTitle02) },
		--{"TourneyDetailScoreText", UIBinderSetText.New(self, self.RichTextTitle01) },
		--{"SelectedEffectVMList", UIBinderUpdateBindableList.New(self, self.SelectedEffectListAdapter)},
		{"CurEffectName", UIBinderSetText.New(self, self.TextBuffName)},
		{"PlayerName", UIBinderSetText.New(self, self.TextSelfPlayerName)},
		{"PlayerScore", UIBinderSetText.New(self, self.TextSelfCount)},
		{"PlayerScore", UIBinderSetText.New(self, self.TextIntegral)},
		{"SettlementDateText", UIBinderSetText.New(self, self.TextTime01)},
		{"CurStageEffectResultText", UIBinderSetText.New(self, self.TextNow02)},
		{"CurStageScoreChange", UIBinderSetText.New(self, self.TextMark02)},
		{"SettlementDateText", UIBinderSetText.New(self, self.TextTips)},
		{"PlayerRank", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerRankChanged)},
		{"TourneyRankList", UIBinderUpdateBindableList.New(self, self.RankListAdapter)}, 
		{"ScoreProgress", UIBinderSetPercent.New(self, self.Probar)},
		{"CurStageStats", UIBinderValueChangedCallback.New(self, nil, self.OnCurBattleCountChanged)},
		
	}

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
	self.ScoreGrowDuration = 2
	self.NodeScoreList = {}
end

function CardsTourneyStageSettlementWinView:OnDestroy()

end

function CardsTourneyStageSettlementWinView:SetLSTR()
    self.TextTitle:SetText(_G.LSTR(1150068))--("幻卡大赛排行榜")
	self.Text01:SetText(_G.LSTR(1150062))--("排名")
	self.Text02:SetText(_G.LSTR(1150063))--("选手")
	self.Text03:SetText(_G.LSTR(1150064))--("积分")
	self.Text04:SetText(_G.LSTR(1150065))--("奖励")
	self.TextIntegral02:SetText(_G.LSTR(1150064))--("积分")
end

function CardsTourneyStageSettlementWinView:OnShow()
	self:SetLSTR()
	local GetProgressWidget = self.GetProgressWidgetRef[1]
	self.GetProgressWidgetSize = UIUtil.GetWidgetSize(GetProgressWidget)
	AudioUtil.LoadAndPlayUISound(TourneyDefine.SoundPath.Common)
	self:PlayAnimation(self.AnimLoop)
	self:OnPerformScoreGrowAnim()
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
	-- 初始化所有积分与对应的奖励信息
	local ScoreAwardInfo = MagicCardTourneyVMUtils.GetScoreAwardInfo()
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
			local NewPosition = UE.FVector2D(Percent * Size.X - Size.X/2 - PanelNodeSize.X/2 - ProBarPosition.X + self.GetProgressWidgetSize.X/4, 0)
			UIUtil.CanvasSlotSetPosition(PanelNode, NewPosition)
		end
	end

	-- 标题 最后阶段显示最终阶段结算
	local CurStageIndex = TourneyVM.CurStageIndex
	if CurStageIndex ~= nil then
		local StageName = TourneyDefine.StageName[CurStageIndex]
		local LastStageName = TourneyDefine.LastStageName
		StageName = CurStageIndex < 4 and StageName or LastStageName
		local TitleText = string.format(TourneyDefine.StageSettlementText, StageName)
		self.TextTitle:SetText(TitleText)
	end

	-- 右侧阶段效果信息
	local EffectInfo = MagicCardTourneyVMUtils.GetEffectInfoByEffectID(self.EffectID)
	if EffectInfo then
		local EffectIconPath = EffectInfo.IconPath
		UIUtil.ImageSetBrushFromAssetPath(self.Widget, EffectIconPath)
	end

end

---@type 积分增长动效
function CardsTourneyStageSettlementWinView:OnPerformScoreGrowAnim()
	self.CurPerformPercent = 0
	self.TargetScorePercent = TourneyVM.ScoreProgress
	self.TimeCount = 0
	local function Grow()
		self.TimeCount = self.TimeCount + 0.05
		self.CurPerformPercent = FMath.Lerp(0, self.TargetScorePercent, self.TimeCount * (1/self.ScoreGrowDuration))
		if self.CurPerformPercent >= self.TargetScorePercent then
			if self.GrowTimer then
				self:UnRegisterTimer(self.GrowTimer)
				self.GrowTimer = nil
			end
		end
		self.CurPerformPercent = math.clamp(self.CurPerformPercent, 0, self.TargetScorePercent)
		self.Probar:SetPercent(self.CurPerformPercent)
		-- 动态设置进度动效位置
		local PanelNode = self.FCanvasEffect
		UIUtil.SetIsVisible(self.FCanvasEffect, self.CurPerformPercent > 0)
		if PanelNode then
			local Size = UIUtil.GetWidgetSize(self.Probar)
			local PanelNodeSize = UIUtil.GetWidgetSize(PanelNode)
			local ProBarPosition = UIUtil.CanvasSlotGetPosition(self.PanelProbar)
			local NewPosition = UE.FVector2D(self.CurPerformPercent * Size.X - Size.X/2 - PanelNodeSize.X - ProBarPosition.X - self.GetProgressWidgetSize.X/4, 0)
			UIUtil.CanvasSlotSetPosition(PanelNode, NewPosition)
		end
		-- 设置相关节点显示
		for Index, NodeScore in ipairs(self.NodeScoreList) do
			local NodePercent = NodeScore/TourneyDefine.MaxScore
			if self.CurPerformPercent >= NodePercent then
				local AwardWidget = self.AwardWidgetRef[Index][1]
				local GetProgressWidget = self.GetProgressWidgetRef[Index]
				if AwardWidget and GetProgressWidget then
					UIUtil.SetIsVisible(AwardWidget.FImg_Select, true)
					-- TODO 播放奖励物品动效
					UIUtil.SetIsVisible(GetProgressWidget, true)
				end
			end
		end
	end

	if self.GrowTimer then
		self:UnRegisterTimer(self.GrowTimer)
		self.GrowTimer = nil
	end
	self.GrowTimer = self:RegisterTimer(Grow, 0, 0.05, 0)
end

function CardsTourneyStageSettlementWinView:OnHide()
	if MagicCardTourneyMgr:IsFinishedTourney() then
		MagicCardTourneyMgr:OnFinishedTourney()
	elseif MagicCardTourneyMgr:IsWillBeNextStage() then -- 显示阶段效果选择界面
		MagicCardTourneyMgr:ShowStageEffectSelectView()
	end
end

function CardsTourneyStageSettlementWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRank, self.OnBtnRankClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnBtnInfoClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnClose_1, self.Hide)
end

function CardsTourneyStageSettlementWinView:OnRegisterGameEvent()

end

function CardsTourneyStageSettlementWinView:OnRegisterBinder()
	if TourneyVM then
		self:RegisterBinders(TourneyVM, self.Binders)
	end
end

function CardsTourneyStageSettlementWinView:OnBtnRankClicked()
	self:ShowInfoContent(false)
end

function CardsTourneyStageSettlementWinView:OnBtnInfoClicked()
	self:ShowInfoContent(true)
end

function CardsTourneyStageSettlementWinView:OnPlayerRankChanged(Rank)
	local RankText = MagicCardTourneyVMUtils.GetRankText(Rank)
	self.TextSelfRank:SetText(RankText)
	self.TextNow01:SetText(string.format(TourneyDefine.CurRankText, RankText))
	-- 获取排名奖励
	local TourneyID = TourneyVM:GetTourneyID()
	self.RankAwardList = MagicCardTourneyVMUtils.GetAwardListByRank(Rank, TourneyID)

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
			UIUtil.SetIsVisible(SelfRewardWidget.FImg_Select, true)
			SelfRewardWidget:SetClickButtonCallback(self, self.OnRewardClicked)
			local Cfg = ItemCfg:FindCfgByKey(RankAward.ResID or 0 )
			local ImgPath = Cfg and ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
			SelfRewardWidget:SetIconImg(ImgPath)
			local RewardNum = RankAward.Num
			if RewardNum > 1 then
				SelfRewardWidget:SetNum(RewardNum)
			end
		end
	end
end

function CardsTourneyStageSettlementWinView:OnRewardClicked(ItemView)
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

function CardsTourneyStageSettlementWinView:OnNodeRewardClicked(ItemView)
	local ScoreAwardInfo = MagicCardTourneyVMUtils.GetScoreAwardInfo()
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

function CardsTourneyStageSettlementWinView:OnCurBattleCountChanged(CurStageStats)
	if CurStageStats == nil then
		return
	end
	local ResultCountList = CurStageStats.StageBattle
	local ScoreList = CurStageStats.StageScore
	if ResultCountList and #ResultCountList>= 3 then
		local WinCount = ResultCountList[1]
		local DefeatCount = ResultCountList[2]
		local DrawCount = ResultCountList[3]
		local WinTotalScore = ScoreList[1]
		local DefeatScore = ScoreList[2]
		local DrawScore = ScoreList[3]
		local WinText = string.format(TourneyDefine.WinCountText, WinCount)
		local DefeatText = string.format(TourneyDefine.DefeatCountText, DefeatCount)
		local DrawText = string.format(TourneyDefine.DrawCountText, DrawCount)
		self.TextNow03:SetText(WinText) --胜场
		self.TextMark03:SetText(WinTotalScore) --胜分
		self.TextNow04:SetText(DrawText) --平场
		self.TextMark04:SetText(DrawScore) --平分
		self.TextNow05:SetText(DefeatText) --负场
		self.TextMark05:SetText(DefeatScore) --负分
	end
end

function CardsTourneyStageSettlementWinView:ShowInfoContent(IsShow)
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

return CardsTourneyStageSettlementWinView