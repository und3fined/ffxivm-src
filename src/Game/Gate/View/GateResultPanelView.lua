---
--- Author: sammrli
--- DateTime: 2023-09-20 15:46
--- Description:金蝶结算界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")

local GateResultVM = require("Game/Gate/View/VM/GateResultVM")

local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")

local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR

---@class GateResultPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExit CommBtnLView
---@field CommBackpackSlot CommBackpackSlotView
---@field ImgTitle UFImage
---@field Scale01 UScaleBox
---@field Scale02 UScaleBox
---@field Scale03 UScaleBox
---@field ScaleReward UScaleBox
---@field TableViewList UTableView
---@field TextCoinNumber UFTextBlock
---@field TextCountdown UFTextBlock
---@field TextMark UFTextBlock
---@field TextNumber UFTextBlock
---@field TextReward UFTextBlock
---@field TextTitle01 UFTextBlock
---@field TextTitle02 UFTextBlock
---@field TextTitle03 UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateResultPanelView = LuaClass(UIView, true)

function GateResultPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExit = nil
	--self.CommBackpackSlot = nil
	--self.ImgTitle = nil
	--self.Scale01 = nil
	--self.Scale02 = nil
	--self.Scale03 = nil
	--self.ScaleReward = nil
	--self.TableViewList = nil
	--self.TextCoinNumber = nil
	--self.TextCountdown = nil
	--self.TextMark = nil
	--self.TextNumber = nil
	--self.TextReward = nil
	--self.TextTitle01 = nil
	--self.TextTitle02 = nil
	--self.TextTitle03 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.ViewModel = nil ---@type GateResultVM
	self.TimerID = nil
	self.CountDownSecond = 0
end

function GateResultPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnExit)
	self:AddSubView(self.CommBackpackSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateResultPanelView:OnInit()
	self.AdapterRecordList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.ViewModel = GateResultVM.New()
	UIUtil.SetIsVisible(self.CommBackpackSlot.RichTextNum, true)
end

function GateResultPanelView:OnDestroy()

end

function GateResultPanelView:OnShow()
	self.ViewModel:SetResult()
	if self.Params then
		self.ViewModel:SetCoinNum(self.Params.AwardCoins)
	end
	self.CountDownSecond = 60 * 5

	self.TimerID = self:RegisterTimer(self.OnCountDown, 0, 1, -1)
	self.TextCountdown:SetText("")

	self.TextMark:SetText(LSTR(570007)) --570007("总得分")
	self.TextReward:SetText(LSTR(570008)) --570008("奖励")
	self.BtnExit:SetBtnName(LSTR(10036)) --10036("离开")

	local IconID = ItemUtil.GetItemIcon(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	if IconID then
		local IconPath = UIUtil.GetIconPath(IconID)
		if IconPath then
			self.CommBackpackSlot:SetIconImg()
		end
	end

	_G.LootMgr:SetDealyState(false)
end

function GateResultPanelView:OnHide()
end

function GateResultPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickedExitHandle)
	self.CommBackpackSlot:SetClickButtonCallback(self, self.OnClickedSlotItemHandle)
end

function GateResultPanelView:OnRegisterGameEvent()

end

function GateResultPanelView:OnRegisterBinder()
	local Binders = {
		{ "RecordTableList", UIBinderUpdateBindableList.New(self, self.AdapterRecordList) },
		{ "TotalScore", UIBinderSetText.New(self, self.TextNumber) },
		{ "CoinNum", UIBinderSetItemNumFormat.New(self, self.CommBackpackSlot.RichTextNum) },
		{ "ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.CommBackpackSlot.FImg_Icon) },
		{ "ScoreGrade", UIBinderValueChangedCallback.New(self, nil, self.OnScoreGradeChange)},
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function GateResultPanelView:OnClickedExitHandle()
	local Params = {}
	Params.FadeColorType = 3
	Params.Duration = 0.6
	Params.bAutoHide = false
	_G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)
	self:RegisterTimer(self.OnFadeOutOver, 0.5)
end

function GateResultPanelView:OnClickedSlotItemHandle()
	ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, self.CommBackpackSlot)
end

function GateResultPanelView:OnCountDown()
	if self.CountDownSecond > 0 then
		self.CountDownSecond = self.CountDownSecond - 1
	end
	if self.CountDownSecond == 1 then
		local Params = {}
		Params.FadeColorType = 3
		Params.Duration = 0.6
		Params.bAutoHide = false
		_G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)
	end
	if self.CountDownSecond == 0 then
		if self.TimerID then
			self:UnRegisterTimer(self.TimerID)
			self.TimerID = nil
		end
		_G.PWorldMgr:SendLeavePWorld()
	end
end

function GateResultPanelView:OnFadeOutOver()
	_G.PWorldMgr:SendLeavePWorld()
end

function GateResultPanelView:OnScoreGradeChange(Grade)
	local TextNodeIndex = GoldSauserDefine.AirForceConfig.TextNode[Grade]
	local TextContent = GoldSauserDefine.AirForceConfig.TextContent[Grade]
	for i=1, 3 do
		local NodeName = string.format("Scale0%d", i)
		local Node = self[NodeName]
		if Node then
			UIUtil.SetIsVisible(Node, TextNodeIndex == i)
		end
	end
	self.TextTitle01:SetText(TextContent)
	self.TextTitle02:SetText(TextContent)
	self.TextTitle03:SetText(TextContent)
end

return GateResultPanelView