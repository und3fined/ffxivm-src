---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:阶段结算界面/领取奖励界面  废弃
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
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

local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local UE = _G.UE

---@class CardsTourneySettlementWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnGet CommBtnLView
---@field ImgNode02 UFImage
---@field ImgNode04 UFImage
---@field ImgNode06 UFImage
---@field ImgNode08 UFImage
---@field NodeReward01 CardsTourneyRewardItemView
---@field NodeReward02 CardsTourneyRewardItemView
---@field NodeReward03 CardsTourneyRewardItemView
---@field NodeReward04 CardsTourneyRewardItemView
---@field NodeReward05 CardsTourneyRewardItemView
---@field NodeReward06 CardsTourneyRewardItemView
---@field NodeReward07 CardsTourneyRewardItemView
---@field NodeReward08 CardsTourneyRewardItemView
---@field PanelDone UFCanvasPanel
---@field PanelNode01 UFCanvasPanel
---@field PanelNode02 UFCanvasPanel
---@field PanelNode03 UFCanvasPanel
---@field PanelNode04 UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field Probar UProgressBar
---@field ScaleSelf UScaleBox
---@field SelfReward01 CardsTourneyRewardItemView
---@field SelfReward02 CardsTourneyRewardItemView
---@field TableViewRankList UTableView
---@field TextAfterGet UFTextBlock
---@field TextNodeCount01 UFTextBlock
---@field TextNodeCount02 UFTextBlock
---@field TextNodeCount03 UFTextBlock
---@field TextNodeCount04 UFTextBlock
---@field TextSelfCount UFTextBlock
---@field TextSelfPlayerName UFTextBlock
---@field TextSelfRank UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneySettlementWinView = LuaClass(UIView, true)

function CardsTourneySettlementWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnGet = nil
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
	--self.PanelDone = nil
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
	--self.TextAfterGet = nil
	--self.TextNodeCount01 = nil
	--self.TextNodeCount02 = nil
	--self.TextNodeCount03 = nil
	--self.TextNodeCount04 = nil
	--self.TextSelfCount = nil
	--self.TextSelfPlayerName = nil
	--self.TextSelfRank = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneySettlementWinView:OnRegisterSubView()
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

function CardsTourneySettlementWinView:OnInit()
	self.RankListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRankList, nil, true, false)
	self.Binders = {
		{"TourneyRankList", UIBinderUpdateBindableList.New(self, self.RankListAdapter)},
		{"PlayerName", UIBinderSetText.New(self, self.TextSelfPlayerName)},
		{"PlayerScore", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerScoreChanged)},
		{"PlayerRank", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerRankChanged)},
		{"ScoreProgress", UIBinderSetPercent.New(self, self.Probar)},
		{"AwardCollected", UIBinderSetIsVisible.New(self, self.PanelDone)},  --- 已领奖按钮
		{"IsActive", UIBinderSetIsVisible.New(self, self.TextAfterGet)},   --- 不可领奖
		{"CanAwardCollect", UIBinderSetIsVisible.New(self, self.BtnGet)}, --- 领奖按钮
	}
	-- 设置奖励
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

function CardsTourneySettlementWinView:OnDestroy()

end

function CardsTourneySettlementWinView:OnShow()
	local TitleText = "幻卡大赛结算"
	local ParamList = self.Params
	local StageIndex = TourneyVM.CurStageIndex
	--如果有参数，当前界面为领取奖励界面
	if ParamList and #ParamList >= 1 then
		self.IsStageSettlement = false
	else
		self.IsStageSettlement = true
		if StageIndex ~= nil then
			local StageName = TourneyDefine.StageName[StageIndex]
			if StageName then
				TitleText = StageName.."结算"
			end
		end
	end

	self.TextTitle:SetText(TitleText)

	local Type = ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_SCORE
	local SearchConditions = string.format("Type == %d", Type)
	self.AwardCfgList = AwardCfg:FindAllCfg(SearchConditions)
	local PlayerScore = TourneyVM:GetPlayerScore()
	for index, AwardCfg in ipairs(self.AwardCfgList) do
		-- 设置金碟币奖励
		local NodeScore = AwardCfg.Arg
		local AwardWidget = self.AwardWidgetRef[index][1]
		if AwardWidget then
			AwardWidget:SetRewardText(AwardCfg.Coin)
			if PlayerScore >= NodeScore then
				if self.IsStageSettlement == false then
					AwardWidget:OnSelectPerform()
				end
			end
		end
		
		-- 第二个奖励暂时不用隐藏
		local AwardWidgetSecond = self.AwardWidgetRef[index][2]
		if AwardWidgetSecond then
			UIUtil.SetIsVisible(AwardWidgetSecond, false)
		end
		UIUtil.SetIsVisible(self.SelfReward02, false)
		-- 设置金碟币奖励需要达成的积分
		local NodeWidget = self.AwardNodeWidgetRef[index]
		if NodeWidget then
			NodeWidget:SetText(NodeScore)
		end

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

	if self.IsStageSettlement == false then
		self.SelfReward01:OnSelectPerform()
	end
end

function CardsTourneySettlementWinView:OnHide()

end

function CardsTourneySettlementWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClose)
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnBtnClickedGetReward)
end

function CardsTourneySettlementWinView:OnRegisterGameEvent()

end

function CardsTourneySettlementWinView:OnRegisterBinder()
	if TourneyVM then
		self:RegisterBinders(TourneyVM, self.Binders)
	end
end

function CardsTourneySettlementWinView:OnPlayerRankChanged(Rank)
	local RankText = MagicCardVMUtils.GetRankText(Rank)
	self.TextSelfRank:SetText(RankText)

	-- 获取排名奖励
	local RankAward = MagicCardVMUtils.GetAwardByRank(Rank)
	-- 排名未达到奖励
	if RankAward == nil then
		UIUtil.SetIsVisible(self.SelfReward01, false)
		UIUtil.SetIsVisible(self.SelfReward02, false)
		return
	end

	if self.SelfReward01 then
		UIUtil.SetIsVisible(self.SelfReward01, true)
		self.SelfReward01:SetRewardText(RankAward.Coin)
	end
end

function CardsTourneySettlementWinView:OnPlayerScoreChanged(Score)
	self.TextSelfCount:SetText(Score)
	if self.IsStageSettlement == true then
		return
	end

	if self.AwardCfgList == nil then
		return
	end

	-- 领奖时高亮显示奖品UI
	for index, AwardCfg in ipairs(self.AwardCfgList) do
		local Widget = self.AwardWidgetRef[index][1]
		if Widget and Score >= AwardCfg.Arg then
			if self.IsStageSettlement == false then
				Widget:OnSelectPerform()
			end
		end
	end
end


function CardsTourneySettlementWinView:OnClose()
	self:Hide()
	--领奖界面
	if not self.IsStageSettlement then
		return
	end

	if MagicCardTourneyMgr:IsFinishedTourney() then
		MagicCardTourneyMgr:OnFinishedTourney()
	elseif MagicCardTourneyMgr:IsWillBeNextStage() then -- 显示阶段效果选择界面
		MagicCardTourneyMgr:ShowStageEffectSelectView()
	end
end

function CardsTourneySettlementWinView:OnBtnClickedGetReward()
	self:Hide()
	if MagicCardTourneyMgr then
		MagicCardTourneyMgr:SendMsgClaimReward()
		MagicCardTourneyMgr:EndInteraction()
	end
end


return CardsTourneySettlementWinView