---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:报名界面/下次大赛界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")
local CardRaceCfg = require("TableCfg/FantasyCardRaceCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local AudioUtil = require("Utils/AudioUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local MagicCardVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")

---@class CardsTourneyApplicationNewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose_1 CommonCloseBtnView
---@field BtnJoin CommBtnLView
---@field FImage_11 UFImage
---@field FImage_12 UFImage
---@field FImage_13 UFImage
---@field FImage_236 UFImage
---@field FTextBlock UFTextBlock
---@field FTextBlock_1 UFTextBlock
---@field FTextBlock_102 UFTextBlock
---@field FTextBlock_121 UFTextBlock
---@field FTextBlock_182 UFTextBlock
---@field FTextBlock_2 UFTextBlock
---@field FTextBlock_3 UFTextBlock
---@field FTextBlock_4 UFTextBlock
---@field FTextBlock_5 UFTextBlock
---@field ImgRing UFImage
---@field PopUpBG CommonPopUpBGView
---@field RichTextContent URichTextBox
---@field RichTextContent_1 URichTextBox
---@field RichTextDate URichTextBox
---@field TextNoOpen UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyApplicationNewWinView = LuaClass(UIView, true)

function CardsTourneyApplicationNewWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose_1 = nil
	--self.BtnJoin = nil
	--self.FImage_11 = nil
	--self.FImage_12 = nil
	--self.FImage_13 = nil
	--self.FImage_236 = nil
	--self.FTextBlock = nil
	--self.FTextBlock_1 = nil
	--self.FTextBlock_102 = nil
	--self.FTextBlock_121 = nil
	--self.FTextBlock_182 = nil
	--self.FTextBlock_2 = nil
	--self.FTextBlock_3 = nil
	--self.FTextBlock_4 = nil
	--self.FTextBlock_5 = nil
	--self.ImgRing = nil
	--self.PopUpBG = nil
	--self.RichTextContent = nil
	--self.RichTextContent_1 = nil
	--self.RichTextDate = nil
	--self.TextNoOpen = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyApplicationNewWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose_1)
	self:AddSubView(self.BtnJoin)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyApplicationNewWinView:OnInit()
	self.Binders = {
		{"TourneyDate", UIBinderSetText.New(self, self.RichTextDate) },
		{"CanSingUp", UIBinderSetIsVisible.New(self, self.BtnJoin) },
		{"CanSingUp", UIBinderSetIsVisible.New(self, self.TextNoOpen, true) },
		{"TourneyDes", UIBinderSetText.New(self, self.RichTextContent) },
		{"TourneyName", UIBinderSetText.New(self, self.TextTitle) },
		{"TourneyID", UIBinderValueChangedCallback.New(self, nil, self.SetNumOneAwardInfo)}
	}
	self.RichTextContent_1:SetText(MagicCardTourneyDefine.TournneyDesc)

	self.AwardWidgetRef = 
	{
		[1] = self.FTextBlock_182,
		[2] = self.FTextBlock_1,
		[3] = self.FTextBlock_3,
		[4] = self.FTextBlock_5,
	}

	self.AwardNodeWidgetRef = 
	{
		[1] = self.FTextBlock_102,
		[2] = self.FTextBlock,
		[3] = self.FTextBlock_2,
		[4] = self.FTextBlock_4,
	}
end

function CardsTourneyApplicationNewWinView:OnDestroy()

end

function CardsTourneyApplicationNewWinView:SetLSTR()
	self.FTextBlock_121:SetText("NO.1")
    self.TextNoOpen:SetText(_G.LSTR(1150059))--("'- 尚未开启，敬请期待 -")
	self.BtnJoin:SetButtonText(_G.LSTR(1150060))--("报名参加")
end

function CardsTourneyApplicationNewWinView:OnShow()
	self:SetLSTR()
	AudioUtil.LoadAndPlayUISound(MagicCardTourneyDefine.SoundPath.SignOpenView)
	local ParamList = self.Params
	--如果有俩个参数，当前界面为下次大赛信息
	if ParamList and #ParamList > 1 then
		TourneyVM:UpdateNextTourneyInfo()
		UIUtil.SetIsVisible(self.ImgRing, false) -- 隐藏羽毛装饰图，防止遮挡文本
	else
		TourneyVM:UpdateSignUpVM()
		UIUtil.SetIsVisible(self.ImgRing, true)
	end

	self:SetAwardScoreInfo()
end

function CardsTourneyApplicationNewWinView:OnHide()

end

function CardsTourneyApplicationNewWinView:OnRegisterUIEvent()
	self.BtnClose_1:SetCallback(self, self.CloseView)
	UIUtil.AddOnClickedEvent(self,self.BtnJoin,self.SignUp)
end

function CardsTourneyApplicationNewWinView:OnRegisterGameEvent()

end

function CardsTourneyApplicationNewWinView:OnRegisterBinder()
	if TourneyVM then
		local ViewModel = TourneyVM.TourneySignUpVM
		self:RegisterBinders(ViewModel, self.Binders)
	end
end

function CardsTourneyApplicationNewWinView:CloseView()
	self:Hide()
end

function CardsTourneyApplicationNewWinView:SignUp()
	if MagicCardTourneyMgr then
		MagicCardTourneyMgr:OnSignUp()
	end
end

function CardsTourneyApplicationNewWinView:SetAwardScoreInfo()
	local ScoreAwardInfo = MagicCardVMUtils.GetScoreAwardInfo()
	for NodeIndex, Award in ipairs(ScoreAwardInfo) do
		local NodeScore = Award.AwardScore
		local NodeAwardList = Award.AwardList
		-- 设置金碟币奖励需要达成的积分
		local NodeWidget = self.AwardNodeWidgetRef[NodeIndex]
		if NodeWidget then
			local ScoreText = ScoreMgr.FormatScore(NodeScore)
			NodeWidget:SetText(ScoreText)
		end
		-- 设置奖励
		local AwardWidget = self.AwardWidgetRef[NodeIndex]
		if NodeAwardList then
			local AwardText = ""
			local AwardScore = NodeAwardList[1]
			local CoinStr = AwardScore and ScoreMgr.FormatScore(AwardScore.Num) or ""
			if #NodeAwardList >= 2 then
				local AwardCard = NodeAwardList[2]
				local Cfg = ItemCfg:FindCfgByKey(AwardCard.ResID or 0 )
				local AwardName = Cfg and Cfg.ItemName or ""
				local AwardNum = AwardCard and AwardCard.Num or 1
				AwardText = string.format(MagicCardTourneyDefine.AwardCoinAndCardText, CoinStr, AwardName, AwardNum)
			else
				AwardText = CoinStr
			end
			AwardWidget:SetText(AwardText)
		end
	end
end

---@type 设置第一名奖励
function CardsTourneyApplicationNewWinView:SetNumOneAwardInfo(TourneyID)
	if TourneyID == nil or TourneyID <= 0 then
		FLOG_ERROR("CardsTourneyApplicationNewWinView:TourneyID is nil or 0")
		return
	end
	local CardID = nil
	local AwardList = MagicCardVMUtils.GetAwardListByRank(1, TourneyID)
	for _, RankAward in ipairs(AwardList) do
		if RankAward.ResID and RankAward.ResID > 0 then
			local Cfg = ItemCfg:FindCfgByKey(RankAward.ResID)
			local ItemType = Cfg.ItemType
			if ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD then
				CardID = RankAward.ResID
			end 
		end
	end

	if CardID == nil then
		return
	end
	
	local ItemCfg = CardCfg:FindCfgByKey(CardID)
	if nil == ItemCfg then
		_G.FLOG_WARNING("CardsTourneyApplicationNewWinView:Award CardId error: [%d]", CardID)
		return
	end

	if (ItemCfg.ShowImage ~= "") then
		UIUtil.ImageSetBrushFromAssetPath(self.FImage_12, ItemCfg.ShowImage) -- 幻卡图片
	end

	local StarCfg = CardStarCfg:FindCfgByKey(ItemCfg.Star)
	if StarCfg ~= nil then
		UIUtil.ImageSetBrushFromAssetPath(self.FImage_236, StarCfg.StarImage) -- 星级
	end

	-- if ItemCfg.Race == 0 then
	-- 	UIUtil.SetIsVisible(self.CardItem.ImgRace, false)
	-- else
	-- 	local RaceCfg = CardRaceCfg:FindCfgByKey(ItemCfg.Race)
	-- 	if RaceCfg ~= nil then
	-- 		UIUtil.SetIsVisible(self.CardItem.ImgRace, true)
	-- 		UIUtil.ImageSetBrushFromAssetPath(self.CardItem.ImgRace, RaceCfg.RaceImage)
	-- 	end
	-- end

	-- if (ItemCfg.FrameType == 0) then
	-- 	UIUtil.SetIsVisible(self.CardItem.ImgFrame, true)
	-- 	UIUtil.SetIsVisible(self.CardItem.ImgFrame_Silver, false)
	-- elseif (ItemCfg.FrameType == 1) then
	-- 	UIUtil.SetIsVisible(self.CardItem.ImgFrame, false)
	-- 	UIUtil.SetIsVisible(self.CardItem.ImgFrame_Silver, true)
	-- end
end

return CardsTourneyApplicationNewWinView