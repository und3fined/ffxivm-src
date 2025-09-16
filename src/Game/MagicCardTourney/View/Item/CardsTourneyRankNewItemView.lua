---
--- Author: Administrator
--- DateTime: 2023-11-24 19:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CardsTourneyRankNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ImgBG02 UFImage
---@field ImgRankIcon UFImage
---@field Reward01 CommBackpack58SlotView
---@field Reward02 CommBackpack58SlotView
---@field ScaleReward UScaleBox
---@field TextMark UFTextBlock
---@field TextName UFTextBlock
---@field TextNumber_1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyRankNewItemView = LuaClass(UIView, true)

function CardsTourneyRankNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ImgBG02 = nil
	--self.ImgRankIcon = nil
	--self.Reward01 = nil
	--self.Reward02 = nil
	--self.ScaleReward = nil
	--self.TextMark = nil
	--self.TextName = nil
	--self.TextNumber_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyRankNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Reward01)
	self:AddSubView(self.Reward02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyRankNewItemView:OnInit()
	self.Binders = {
		{ "PlayerName", UIBinderSetText.New(self, self.TextName)},
		{ "Score", UIBinderSetText.New(self, self.TextMark)},
		{ "IsPlayerSelf", UIBinderSetIsVisible.New(self, self.ImgBG02)},
		{ "IsCupIconVisible", UIBinderSetIsVisible.New(self, self.ImgRankIcon)},
		{ "CupIcon", UIBinderSetImageBrush.New(self, self.ImgRankIcon) },
		{ "Rank", UIBinderValueChangedCallback.New(self, nil, self.OnRankChanged)}
	}

	self.SelfRewardWidgetRef = 
	{
		[1] = self.Reward02,
		[2] = self.Reward01,
	}
end

function CardsTourneyRankNewItemView:OnDestroy()

end

function CardsTourneyRankNewItemView:OnShow()
end

function CardsTourneyRankNewItemView:OnHide()

end

function CardsTourneyRankNewItemView:OnRegisterUIEvent()

end

function CardsTourneyRankNewItemView:OnRegisterGameEvent()

end

function CardsTourneyRankNewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CardsTourneyRankNewItemView:OnRankChanged(Value)
	-- 设置背景
	local CanShowBG = math.fmod(Value, 2) == 0
	UIUtil.SetIsVisible(self.ImgBG, CanShowBG)
	-- 设置排名
	self.TextNumber_1:SetText(Value)

	-- 设置排名奖励
	for _, SelfRewardWidget in ipairs(self.SelfRewardWidgetRef) do
		UIUtil.SetIsVisible(SelfRewardWidget.IconChoose, false)
		SelfRewardWidget:SetItemLevelVisibility(false)
		UIUtil.SetIsVisible(SelfRewardWidget, false)
	end

	-- 获取排名奖励
	local TourneyID = TourneyVM:GetTourneyID()
	self.RankAwardList = MagicCardVMUtils.GetAwardListByRank(Value, TourneyID)
	if self.RankAwardList == nil or next(self.RankAwardList) == nil then
		return
	end
	
	for index, RankAward in ipairs(self.RankAwardList) do
		local SelfRewardWidget = self.SelfRewardWidgetRef[index]
		if SelfRewardWidget then
			UIUtil.SetIsVisible(SelfRewardWidget, true)
			UIUtil.SetIsVisible(SelfRewardWidget.ImgSelect, false)
			local IsReward = MagicCardTourneyMgr:IsCanGetReward()
			UIUtil.SetIsVisible(SelfRewardWidget.PanelAvailable, IsReward)
			SelfRewardWidget:SetClickButtonCallback(self, self.OnRewardClicked)
			local Cfg = ItemCfg:FindCfgByKey(RankAward.ResID)
			if Cfg then
				local ImgPath = ItemCfg.GetIconPath(Cfg.IconID) or ""
				SelfRewardWidget:SetIconImg(ImgPath)
			else
				FLOG_WARNING(string.format("幻卡大赛配置的奖励ID %s 无法在物品表中找到，请检查！", RankAward.ResID or 0))
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

function CardsTourneyRankNewItemView:OnRewardClicked(ItemView)
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

return CardsTourneyRankNewItemView