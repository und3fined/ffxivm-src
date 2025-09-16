---
--- Author: Administrator
--- DateTime: 2023-11-24 19:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CardsTourneyRankItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG02 UFImage
---@field Reward01 CommBackpackSlotView
---@field Reward02 CommBackpackSlotView
---@field ScaleReward UScaleBox
---@field TextMark UFTextBlock
---@field TextName UFTextBlock
---@field TextNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyRankItemView = LuaClass(UIView, true)

function CardsTourneyRankItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG02 = nil
	--self.Reward01 = nil
	--self.Reward02 = nil
	--self.ScaleReward = nil
	--self.TextMark = nil
	--self.TextName = nil
	--self.TextNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyRankItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Reward01)
	self:AddSubView(self.Reward02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyRankItemView:OnInit()
	self.Binders = {
		{ "PlayerName", UIBinderSetText.New(self, self.TextName)},
		{ "Score", UIBinderSetText.New(self, self.TextMark)},
		{ "IsPlayerSelf", UIBinderSetIsVisible.New(self, self.ImgBG02)},
		{ "Rank", UIBinderValueChangedCallback.New(self, nil, self.OnRankChanged)}
	}
end

function CardsTourneyRankItemView:OnDestroy()

end

function CardsTourneyRankItemView:OnShow()
	-- 第二个奖励暂时不用隐藏
	if self.Reward02 then
		UIUtil.SetIsVisible(self.Reward02, false)
	end
end

function CardsTourneyRankItemView:OnHide()

end

function CardsTourneyRankItemView:OnRegisterUIEvent()

end

function CardsTourneyRankItemView:OnRegisterGameEvent()

end

function CardsTourneyRankItemView:OnRegisterBinder()
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

function CardsTourneyRankItemView:OnRankChanged(Value)
	-- 设置排名
	self.TextNumber:SetText(Value)
	-- 设置排名奖励
	local Type = ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_RANK
	local SearchConditions = string.format("Type=%d and Arg=%d", Type, Value)
	local AwardCfg = AwardCfg:FindCfg(SearchConditions)
	if AwardCfg == nil then
		return
	end

	if self.Reward01 then
		UIUtil.SetIsVisible(self.Reward01.RichTextNum, true)
		self.Reward01.RichTextNum:SetText(AwardCfg.Coin)
	end
end

return CardsTourneyRankItemView