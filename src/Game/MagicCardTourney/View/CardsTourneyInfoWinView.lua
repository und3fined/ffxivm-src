---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description: 大赛详情界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
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

---@class CardsTourneyInfoWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnInfo UFButton
---@field BtnRank UFButton
---@field ImgNode02 UFImage
---@field ImgNode04 UFImage
---@field ImgNode06 UFImage
---@field ImgNode08 UFImage
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
---@field RichTextTitle01 URichTextBox
---@field RichTextTitle02 URichTextBox
---@field ScaleSelf UScaleBox
---@field SelfReward01 CommBackpackSlotView
---@field SelfReward02 CommBackpackSlotView
---@field TableViewBattleInfo UTableView
---@field TableViewRankList UTableView
---@field TextNodeCount01 UFTextBlock
---@field TextNodeCount02 UFTextBlock
---@field TextNodeCount03 UFTextBlock
---@field TextNodeCount04 UFTextBlock
---@field TextSelfCount UFTextBlock
---@field TextSelfPlayerName UFTextBlock
---@field TextSelfRank UFTextBlock
---@field TextTime01 UFTextBlock
---@field TextTime02 UFTextBlock
---@field WidgetSwitcherTab UFWidgetSwitcher
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyInfoWinView = LuaClass(UIView, true)

function CardsTourneyInfoWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnInfo = nil
	--self.BtnRank = nil
	--self.ImgNode02 = nil
	--self.ImgNode04 = nil
	--self.ImgNode06 = nil
	--self.ImgNode08 = nil
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
	--self.RichTextTitle01 = nil
	--self.RichTextTitle02 = nil
	--self.ScaleSelf = nil
	--self.SelfReward01 = nil
	--self.SelfReward02 = nil
	--self.TableViewBattleInfo = nil
	--self.TableViewRankList = nil
	--self.TextNodeCount01 = nil
	--self.TextNodeCount02 = nil
	--self.TextNodeCount03 = nil
	--self.TextNodeCount04 = nil
	--self.TextSelfCount = nil
	--self.TextSelfPlayerName = nil
	--self.TextSelfRank = nil
	--self.TextTime01 = nil
	--self.TextTime02 = nil
	--self.WidgetSwitcherTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	--ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_SCORE
	

	

end

function CardsTourneyInfoWinView:OnRegisterSubView()
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

function CardsTourneyInfoWinView:OnInit()
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
		[1] = {[1] = self.NodeReward01, [2] = self.NodeReward02},
		[2] = {[1] = self.NodeReward03, [2] = self.NodeReward04},
		[3] = {[1] = self.NodeReward05, [2] = self.NodeReward06},
		[4] = {[1] = self.NodeReward07, [2] = self.NodeReward08},
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
end

function CardsTourneyInfoWinView:OnDestroy()

end

function CardsTourneyInfoWinView:OnShow()
	self:ShowInfoContent(true)
	UIUtil.SetIsVisible(self.SelfReward02, false)
	
	local Type = ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_SCORE
	local SearchConditions = string.format("Type == %d", Type)
	local AwardCfgList = AwardCfg:FindAllCfg(SearchConditions)
	for index, AwardCfg in ipairs(AwardCfgList) do
		-- 设置金碟币奖励
		local NodeScore = AwardCfg.Arg
		local PlayerScore = TourneyVM:GetPlayerScore()
		local AwardWidget = self.AwardWidgetRef[index][1]
		if AwardWidget then
			UIUtil.SetIsVisible(AwardWidget.RichTextNum, true)
			AwardWidget.RichTextNum:SetText(AwardCfg.Coin)
			if PlayerScore >= NodeScore then
				UIUtil.SetIsVisible(AwardWidget.FImg_Select, true)
			end
		end

		-- 第二个奖励暂时不用隐藏
		local AwardWidgetSecond = self.AwardWidgetRef[index][2]
		if AwardWidgetSecond then
			UIUtil.SetIsVisible(AwardWidgetSecond, false)
		end

		-- 设置金碟币奖励需要达成的积分
		local NodeWidget = self.AwardNodeWidgetRef[index]
		if NodeWidget then
			NodeWidget:SetText(NodeScore)
		end
		
		-- 动态设置奖励节点位置
		local PanelNode = self.PanelNodeWidgetRef[index]
		if PanelNode then
			local Size = UIUtil.GetWidgetSize(self.Probar)
			local PanelNodeSize = UIUtil.GetWidgetSize(PanelNode)
			local ProBarPosition = UIUtil.CanvasSlotGetPosition(self.PanelProbar)
			local Percent = NodeScore/TourneyDefine.MaxScore
			local NewPosition = UE.FVector2D(Percent * Size.X - Size.X/2 - PanelNodeSize.X/2 - ProBarPosition.X, 0)
			UIUtil.CanvasSlotSetPosition(PanelNode, NewPosition)
		end
	end
end

function CardsTourneyInfoWinView:OnHide()

end

function CardsTourneyInfoWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRank, self.OnBtnRankClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnBtnInfoClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.Hide)
end

function CardsTourneyInfoWinView:OnRegisterGameEvent()

end

function CardsTourneyInfoWinView:OnRegisterBinder()
	if TourneyVM then
		self:RegisterBinders(TourneyVM, self.Binders)
	end
end

function CardsTourneyInfoWinView:OnBtnRankClicked()
	self:ShowInfoContent(false)
end

function CardsTourneyInfoWinView:OnBtnInfoClicked()
	self:ShowInfoContent(true)
end

function CardsTourneyInfoWinView:OnPlayerRankChanged(Rank)
	local RankText = MagicCardVMUtils.GetRankText(Rank)
	self.TextSelfRank:SetText(RankText)
	self.TextNow01:SetText(string.format(TourneyDefine.CurRankText, RankText))
	-- 设置排名奖励
	local Type = ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_RANK
	local SearchConditions = string.format("Type=%d and Arg=%d", Type, Rank)
	local AwardCfg = AwardCfg:FindCfg(SearchConditions)
	-- 排名未达到奖励
	if AwardCfg == nil then
		UIUtil.SetIsVisible(self.SelfReward01, false)
		return
	end

	if self.SelfReward01 then
		UIUtil.SetIsVisible(self.SelfReward01, true)
		UIUtil.SetIsVisible(self.SelfReward01.RichTextNum, true)
		self.SelfReward01.RichTextNum:SetText(AwardCfg.Coin)
	end
end

function CardsTourneyInfoWinView:ShowInfoContent(IsShow)
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

return CardsTourneyInfoWinView