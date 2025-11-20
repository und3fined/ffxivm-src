---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description: 对局室外大赛排名界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")


---@class CardsTourneyRankNewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field ImgRankIcon UFImage
---@field MaskBG CommonPopUpBGView
---@field Reward01 CommBackpack58SlotView
---@field Reward02 CommBackpack58SlotView
---@field ScaleReward UScaleBox
---@field TableViewRankList UTableView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field TextDate UFTextBlock
---@field TextMark UFTextBlock
---@field TextName UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyRankNewWinView = LuaClass(UIView, true)

function CardsTourneyRankNewWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.ImgRankIcon = nil
	--self.MaskBG = nil
	--self.Reward01 = nil
	--self.Reward02 = nil
	--self.ScaleReward = nil
	--self.TableViewRankList = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.TextDate = nil
	--self.TextMark = nil
	--self.TextName = nil
	--self.TextNumber = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	--ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_SCORE
	

	

end

function CardsTourneyRankNewWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MaskBG)
	self:AddSubView(self.Reward01)
	self:AddSubView(self.Reward02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyRankNewWinView:OnInit()
	self.RankListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRankList, nil, true, false)
	self.Binders = {
		{"PlayerName", UIBinderSetText.New(self, self.TextName)},
		{"PlayerScore", UIBinderSetText.New(self, self.TextMark)},
		{"PlayerRank", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerRankChanged)},
		--{"SettlementDateText", UIBinderSetText.New(self, self.TextDate)},
		{"TourneyRankList", UIBinderUpdateBindableList.New(self, self.RankListAdapter)},
	}

	self.SelfRewardWidgetRef = 
	{
		[1] = self.Reward02,
		[2] = self.Reward01,
	}
end

function CardsTourneyRankNewWinView:OnDestroy()

end

function CardsTourneyRankNewWinView:SetLSTR()
    self.TextTitle:SetText(_G.LSTR(1150068))--("幻卡大赛排行榜")
	self.Text01:SetText(_G.LSTR(1150062))--("排名")
	self.Text02:SetText(_G.LSTR(1150063))--("选手")
	self.Text03:SetText(_G.LSTR(1150064))--("积分")
	self.Text04:SetText(_G.LSTR(1150065))--("奖励")
end

function CardsTourneyRankNewWinView:OnShow()
	MagicCardTourneyMgr:SendMsgRankInfo()
	self:SetLSTR()
end

function CardsTourneyRankNewWinView:OnHide()
	_G.InteractiveMgr:ExitInteractive()
end

function CardsTourneyRankNewWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.Hide)
end

function CardsTourneyRankNewWinView:OnRegisterGameEvent()

end

function CardsTourneyRankNewWinView:OnRegisterBinder()
	if TourneyVM then
		self:RegisterBinders(TourneyVM, self.Binders)
	end
end

function CardsTourneyRankNewWinView:OnPlayerRankChanged(Rank)
	local RankText = MagicCardVMUtils.GetRankText(Rank)
	self.TextNumber:SetText(RankText)
	
	local IsTourneyActive = TourneyVM.IsActive
	local Secs = TourneyVM:GetNextTourneyTime() - _G.TimeUtil.GetServerTime()
	local LocalRemainTime = LocalizationUtil.GetCountdownTimeForLongTime(Secs) --天小时
	local NextTimeText = string.format(TourneyDefine.RemainTimeForNextText, LocalRemainTime)
	local DateText = IsTourneyActive and TourneyVM.SettlementDateText or NextTimeText
	if DateText then
		self.TextDate:SetText(DateText)
	end

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
	local CupIcon = MagicCardVMUtils.GetRankIcon(Rank)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgRankIcon, CupIcon)

	for index, RankAward in ipairs(self.RankAwardList) do
		local SelfRewardWidget = self.SelfRewardWidgetRef[index]
		if SelfRewardWidget then
			UIUtil.SetIsVisible(SelfRewardWidget, true)
			local IsReward = MagicCardTourneyMgr:IsCanGetReward()
			UIUtil.SetIsVisible(SelfRewardWidget.IconChoose, false)
			UIUtil.SetIsVisible(SelfRewardWidget.ImgSelect, false)
			UIUtil.SetIsVisible(SelfRewardWidget.PanelAvailable, IsReward)
			SelfRewardWidget:SetClickButtonCallback(self, self.OnSelfRewardClicked)
			local Cfg = ItemCfg:FindCfgByKey(RankAward.ResID or 0 )
			if Cfg then
				local ImgPath = ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
				SelfRewardWidget:SetIconImg(ImgPath)
			else
				FLOG_WARNING(string.format("幻卡大赛配置的奖励ID %s 无法再物品表中找到，请检查！", RankAward.ResID or 0))
			end

			local RewardNum = RankAward.Num
			if RewardNum > 1 then
				local NumText = RewardNum
				local ProtoCommon = require("Protocol/ProtoCommon")
				local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
				if Cfg and Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_CURRENCY then
					NumText = _G.ScoreMgr.FormatScore(RewardNum)
				end
				SelfRewardWidget:SetNumVisible(true)
				SelfRewardWidget:SetNum(NumText)
			else
				SelfRewardWidget:SetNumVisible(false)
			end
		end
	end
end

function CardsTourneyRankNewWinView:OnSelfRewardClicked(ItemView)
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

return CardsTourneyRankNewWinView