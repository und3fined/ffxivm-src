---
--- Author: Administrator
--- DateTime: 2023-05-10 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")

local MarketExchangeWinVM = require("Game/Market/VM/MarketExchangeWinVM")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetScoreIcon = require("Binder/UIBinderSetScoreIcon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local ScoreConvertCfg = require("TableCfg/ScoreConvertCfg")
local MsgTipsID = require("Define/MsgTipsID")
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local ScoreMgr = _G.ScoreMgr
local MsgTipsUtil = _G.MsgTipsUtil

---@class MarketExchangeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnExchange CommBtnLView
---@field BtnSwitch UFButton
---@field CountSlider CommCountSliderView
---@field ImgExchangeIcon UFImage
---@field ImgFromIcon UFImage
---@field ImgToIcon UFImage
---@field RichTextRecommend URichTextBox
---@field TextFromAmount UFTextBlock
---@field TextFromName UFTextBlock
---@field TextRecommend UFTextBlock
---@field TextToAmount UFTextBlock
---@field TextToName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketExchangeWinView = LuaClass(UIView, true)

function MarketExchangeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnCancel = nil
	--self.BtnExchange = nil
	--self.BtnSwitch = nil
	--self.CountSlider = nil
	--self.ImgExchangeIcon = nil
	--self.ImgFromIcon = nil
	--self.ImgToIcon = nil
	--self.RichTextRecommend = nil
	--self.TextFromAmount = nil
	--self.TextFromName = nil
	--self.TextRecommend = nil
	--self.TextToAmount = nil
	--self.TextToName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketExchangeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnExchange)
	self:AddSubView(self.CountSlider)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketExchangeWinView:OnInit()
	self.RecommendedValue = nil
	self.Binders = {
		{ "ScoreIconID", UIBinderSetScoreIcon.New(self, self.ImgFromIcon) },
		{ "TargetIconID", UIBinderSetScoreIcon.New(self, self.ImgToIcon) },
		{ "ScoreName", UIBinderSetText.New(self, self.TextFromName) },
		{ "TargetName", UIBinderSetText.New(self, self.TextToName) },
		{ "ScoreNumCount", UIBinderSetTextFormatForMoney.New(self, self.TextFromAmount) },
		{ "TargetNumCount", UIBinderSetTextFormatForMoney.New(self, self.TextToAmount) },
		{ "RecommendedInfoVisible", UIBinderSetIsVisible.New(self, self.RichTextRecommend) },
		{ "RecommendedInfoVisible", UIBinderSetIsVisible.New(self, self.TextRecommend) },
		{ "RecommendedInfo", UIBinderSetTextFormat.New(self, self.RichTextRecommend, "%d") },
		{ "ImgExchangeVisible", UIBinderSetIsVisible.New(self, self.ImgExchangeIcon) },
		{ "ImgExchangeVisible", UIBinderSetIsEnabled.New(self, self.BtnSwitch)},
		{ "BtnExchangeEnabled", UIBinderSetIsEnabled.New(self, self.BtnExchange)},
		{ "ExchangeTitleText", UIBinderSetText.New(self, self.Bg.FText_Title)},
	}	
end

function MarketExchangeWinView:OnDestroy()

end

function MarketExchangeWinView:OnShow()
	if self.Params ~= nil then
		local TargetID = self.Params.ScoreID
		local SourceScoreID = self:GetSourceScoreID(TargetID)
		MarketExchangeWinVM:UpdateMV(SourceScoreID, TargetID, 1)


		self.CountSlider:SetSliderValueMaxMin(ScoreMgr:GetScoreValueByID(self:GetSourceScoreID(TargetID)), 1)
		self.CountSlider:SetSliderValueMaxTips(LSTR(1010034))
		self.CountSlider:SetSliderValueMinTips(LSTR(1010034))
		self.CountSlider:SetValueChangedCallback(function (v)
			self:OnValueChangedSlider(v)
		end)

		if nil ~= self.Params.RecommendedExchange then
			self.RecommendedValue = self.Params.RecommendedExchange
			self:SetRecommendedExchange(SourceScoreID, TargetID)
		else
			MarketExchangeWinVM:HideRecommendedExchange()
		end

	end

end

function MarketExchangeWinView:SetRecommendedExchange(SourceScoreID, TargetID)
	if SourceScoreID == nil or TargetID == nil then
		return
	end
	if nil ~= self.RecommendedValue then
		local SearchConditions = string.format("DeductID = %d and TargetID = %d", SourceScoreID, TargetID)
		local ScoreConvertData = ScoreConvertCfg:FindCfg(SearchConditions)
		if ScoreConvertData ~= nil then
			local TargetNum = ScoreConvertData.TargetNum
			if TargetNum > 0 then
				local NeedSourceScore =  math.ceil(self.RecommendedValue / TargetNum)
				if NeedSourceScore <= ScoreMgr:GetScoreValueByID(SourceScoreID) then
					MarketExchangeWinVM:SetRecommendedExchange(NeedSourceScore)
					self.CountSlider:SetSliderValue(NeedSourceScore)
				else
					MarketExchangeWinVM:HideRecommendedExchange()
				end
			end
		end
	end
end

function MarketExchangeWinView:GetSourceScoreID(ScoreID)
	if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_SILVER_CODE then
        return ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
    elseif ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
        return ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS
    end
end

function MarketExchangeWinView:OnHide()

end

function MarketExchangeWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickedSwitchBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancelBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnExchange.Button, self.OnClickedExchangeBtn)
end

function MarketExchangeWinView:OnRegisterGameEvent()

end

function MarketExchangeWinView:OnRegisterBinder()
	if nil == self.Binders then return end
	self:RegisterBinders(MarketExchangeWinVM, self.Binders)

	self.Bg:SetTitleText(LSTR(1010019))
	self.TextRecommend:SetText(LSTR(1010056))
	self.BtnCancel:SetText(LSTR(10003))
	self.BtnExchange:SetText(LSTR(1010057))
end

function MarketExchangeWinView:OnValueChangedSlider(Value)
	MarketExchangeWinVM:UpdateMV(MarketExchangeWinVM.ScoreIconID, MarketExchangeWinVM.TargetIconID, Value)
end

function MarketExchangeWinView:OnClickedSwitchBtn()
	local CurSourceID = MarketExchangeWinVM.ScoreIconID
	if CurSourceID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
		CurSourceID = ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS
	elseif CurSourceID == ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS then
		CurSourceID = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
	end

	MarketExchangeWinVM:UpdateMV(CurSourceID, MarketExchangeWinVM.TargetIconID, 1)
	self.CountSlider:SetSliderValueMaxMin(ScoreMgr:GetScoreValueByID(CurSourceID), 1)

	if nil ~= self.Params.RecommendedExchange then
		self.RecommendedValue = self.Params.RecommendedExchange
		self:SetRecommendedExchange(CurSourceID, MarketExchangeWinVM.TargetIconID)
	else
		MarketExchangeWinVM:HideRecommendedExchange()
	end

end

function MarketExchangeWinView:OnClickedCancelBtn()
	UIViewMgr:HideView(UIViewID.MarketExchangeWin)
end

function MarketExchangeWinView:OnClickedExchangeBtn()
	if ScoreMgr:GetScoreValueByID(MarketExchangeWinVM.ScoreIconID) == 0  then
		if MarketExchangeWinVM.ScoreIconID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
			MsgTipsUtil.ShowTips(LSTR(1010035))
		elseif MarketExchangeWinVM.ScoreIconID == ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS then
			MsgTipsUtil.ShowTips(LSTR(1010036))
		end
		return
	end

	local SearchConditions = string.format("DeductID = %d and TargetID = %d", MarketExchangeWinVM.ScoreIconID, MarketExchangeWinVM.TargetIconID)
	local ScoreConvertData = ScoreConvertCfg:FindCfg(SearchConditions)
	if ScoreConvertData ~= nil then
		local AddValue = MarketExchangeWinVM.ScoreNumCount * ScoreConvertData.TargetNum

		if AddValue + ScoreMgr:GetScoreValueByID(MarketExchangeWinVM.TargetIconID) > ScoreMgr:GetScoreMaxValue(MarketExchangeWinVM.TargetIconID) then
			if MarketExchangeWinVM.TargetIconID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
				MsgTipsUtil.ShowTipsByID(MsgTipsID.ExchangeGoldLimitExceeded)
			elseif MarketExchangeWinVM.TargetIconID == ProtoRes.SCORE_TYPE.SCORE_TYPE_SILVER_CODE then
				MsgTipsUtil.ShowTipsByID(MsgTipsID.ExchangeSilverLimitExceeded)
			end
			return
		end
	end


	ScoreMgr:ConvertScoreByID(MarketExchangeWinVM.ScoreIconID, MarketExchangeWinVM.ScoreNumCount, MarketExchangeWinVM.TargetIconID)
	UIViewMgr:HideView(UIViewID.MarketExchangeWin)
end

return MarketExchangeWinView