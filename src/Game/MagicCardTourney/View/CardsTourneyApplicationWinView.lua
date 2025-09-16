---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:报名界面/下次大赛界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")
local CardRaceCfg = require("TableCfg/FantasyCardRaceCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")

---@class CardsTourneyApplicationWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnJoin CommBtnLView
---@field CardItem CardsBigCardItemView
---@field PopUpBG CommonPopUpBGView
---@field RichTextContent URichTextBox
---@field RichTextDate URichTextBox
---@field TextNoOpen UFTextBlock
---@field TextRewardName UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyApplicationWinView = LuaClass(UIView, true)

function CardsTourneyApplicationWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnJoin = nil
	--self.CardItem = nil
	--self.PopUpBG = nil
	--self.RichTextContent = nil
	--self.RichTextDate = nil
	--self.TextNoOpen = nil
	--self.TextRewardName = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyApplicationWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnJoin)
	self:AddSubView(self.CardItem)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyApplicationWinView:OnInit()
	self.Binders = {
		{"TourneyDate", UIBinderSetText.New(self, self.RichTextDate) },
		{"CanSingUp", UIBinderSetIsVisible.New(self, self.BtnJoin) },
		{"TourneyDes", UIBinderSetText.New(self, self.RichTextContent) },
		{"RewardName", UIBinderSetText.New(self, self.TextRewardName) },
		{"TourneyName", UIBinderSetText.New(self, self.TextTitle) },
		{"TourneyID", UIBinderValueChangedCallback.New(self, nil, self.SetAwardCardInfo)}
	}
end

function CardsTourneyApplicationWinView:OnDestroy()

end

function CardsTourneyApplicationWinView:OnShow()
	local ParamList = self.Params
	--如果有俩个参数，当前界面为下次大赛信息
	if ParamList and #ParamList > 1 then
		TourneyVM:UpdateNextTourneyInfo()
	else
		TourneyVM:UpdateSignUpVM()
	end
end

function CardsTourneyApplicationWinView:OnHide()

end

function CardsTourneyApplicationWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,self.BtnClose,self.CloseView)
	UIUtil.AddOnClickedEvent(self,self.BtnJoin,self.SignUp)
end

function CardsTourneyApplicationWinView:OnRegisterGameEvent()

end

function CardsTourneyApplicationWinView:OnRegisterBinder()
	if TourneyVM then
		local ViewModel = TourneyVM.TourneySignUpVM
		self:RegisterBinders(ViewModel, self.Binders)
	end
	self.CardItem:UnRegisterAllBinder()
end

function CardsTourneyApplicationWinView:CloseView()
	self:Hide()
end

function CardsTourneyApplicationWinView:SignUp()
	if MagicCardTourneyMgr then
		MagicCardTourneyMgr:OnSignUp()
	end
end

function CardsTourneyApplicationWinView:SetAwardCardInfo(TourneyID)
	if TourneyID == nil then
		FLOG_ERROR("CardsTourneyApplicationWinView:TourneyID is nil")
		return
	end

	if TourneyID <= 0 then
		FLOG_ERROR("CardsTourneyApplicationWinView:TourneyID is 0")
		return
	end

	local AwardCardCfg = AwardCfg:FindCfgByKey(1) -- 第一名特殊奖励
	local CardID = AwardCardCfg.LootID[TourneyID]
	if CardID == nil then
		return
	end
	
	UIUtil.SetIsVisible(self.CardItem.PanelContent, true)
	local ItemCfg = CardCfg:FindCfgByKey(CardID)
	if nil == ItemCfg then
		_G.FLOG_WARNING("CardsTourneyApplicationWinView:Award CardId error: [%d]", CardID)
		return
	end

	--self.ViewModel.CardName = ItemCfg.Name
	UIUtil.SetIsVisible(self.CardItem.ImgBack, false)
	UIUtil.SetIsVisible(self.CardItem.CardDisable, false)
	if (self.CardItem.TextCardName ~= nil) then
		self.CardItem.TextCardName:SetText(ItemCfg.Name)
	end

	if (self.CardItem.TextNameOnTop ~= nil) then
		self.CardItem.TextNameOnTop:SetText(ItemCfg.Name)
	end

	if (ItemCfg.ShowImage == nil or ItemCfg.ShowImage == "") then
		UIUtil.SetIsVisible(self.CardItem.ImgIcon, false)
	else
		UIUtil.SetIsVisible(self.CardItem.ImgIcon, true)
		UIUtil.ImageSetBrushFromAssetPath(self.CardItem.ImgIcon, ItemCfg.ShowImage)
	end

	local StarCfg = CardStarCfg:FindCfgByKey(ItemCfg.Star)
	if StarCfg ~= nil then
		UIUtil.ImageSetBrushFromAssetPath(self.CardItem.ImgStar, StarCfg.StarImage)
	end

	self.CardItem.CardsNumber:SetNumbes(ItemCfg.Up, ItemCfg.Down, ItemCfg.Left, ItemCfg.Right)
	if ItemCfg.Race == 0 then
		UIUtil.SetIsVisible(self.CardItem.ImgRace, false)
	else
		local RaceCfg = CardRaceCfg:FindCfgByKey(ItemCfg.Race)
		if RaceCfg ~= nil then
			UIUtil.SetIsVisible(self.CardItem.ImgRace, true)
			UIUtil.ImageSetBrushFromAssetPath(self.CardItem.ImgRace, RaceCfg.RaceImage)
		end
	end

	if (ItemCfg.FrameType == 0) then
		UIUtil.SetIsVisible(self.CardItem.ImgFrame, true)
		UIUtil.SetIsVisible(self.CardItem.ImgFrame_Silver, false)
	elseif (ItemCfg.FrameType == 1) then
		UIUtil.SetIsVisible(self.CardItem.ImgFrame, false)
		UIUtil.SetIsVisible(self.CardItem.ImgFrame_Silver, true)
	else
		UIUtil.SetIsVisible(self.CardItem.ImgFrame, true)
		UIUtil.SetIsVisible(self.CardItem.ImgFrame_Silver, false)
		_G.FLOG_ERROR("未确认的边框类型：" .. ItemCfg.FrameType)
	end
end

return CardsTourneyApplicationWinView