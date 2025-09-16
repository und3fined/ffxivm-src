---
--- Author: Administrator
--- DateTime: 2024-02-22 15:38
--- Description:评分结算界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")

---@class FashionEvaluationSettlementPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnConform CommInforBtnView
---@field BtnFightingAgain CommBtnMView
---@field BtnFraction CommInforBtnView
---@field BtnHave CommInforBtnView
---@field BtnLeave_1 CommBtnMView
---@field BtnStart CommBtnLView
---@field EFF_Score1 UFCanvasPanel
---@field EFF_Score2 UFCanvasPanel
---@field EFF_Score3 UFCanvasPanel
---@field EFF_Score4 UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelCalculatingTheScore UFCanvasPanel
---@field PanelExteriorSettlement UFCanvasPanel
---@field PanelSclass UFCanvasPanel
---@field PanelTargetSettlement UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelTips1 UFCanvasPanel
---@field RossTips FashionEvaluationRossTipsView
---@field TableViewList1 UTableView
---@field TableViewList2 UTableView
---@field TableViewSlot UTableView
---@field Target FashionEvaluationTargetItemView
---@field TextAward UFTextBlock
---@field TextConformQuantity UFTextBlock
---@field TextConformScore UFTextBlock
---@field TextFarction UFTextBlock
---@field TextFraction UFTextBlock
---@field TextHaveQuantity UFTextBlock
---@field TextHaveScore UFTextBlock
---@field TextNumberOfChallenges_1 UFTextBlock
---@field TextSclassQuantity UFTextBlock
---@field TextSclassScore UFTextBlock
---@field TextScore1 UFTextBlock
---@field TextTips UFTextBlock
---@field TextTips1 UFTextBlock
---@field ToggleBtnFlipPage UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimTargetIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationSettlementPanelView = LuaClass(UIView, true)

function FashionEvaluationSettlementPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnConform = nil
	--self.BtnFightingAgain = nil
	--self.BtnFraction = nil
	--self.BtnHave = nil
	--self.BtnLeave_1 = nil
	--self.BtnStart = nil
	--self.EFF_Score1 = nil
	--self.EFF_Score2 = nil
	--self.EFF_Score3 = nil
	--self.EFF_Score4 = nil
	--self.PanelBtn = nil
	--self.PanelCalculatingTheScore = nil
	--self.PanelExteriorSettlement = nil
	--self.PanelSclass = nil
	--self.PanelTargetSettlement = nil
	--self.PanelTips = nil
	--self.PanelTips1 = nil
	--self.RossTips = nil
	--self.TableViewList1 = nil
	--self.TableViewList2 = nil
	--self.TableViewSlot = nil
	--self.Target = nil
	--self.TextAward = nil
	--self.TextConformQuantity = nil
	--self.TextConformScore = nil
	--self.TextFarction = nil
	--self.TextFraction = nil
	--self.TextHaveQuantity = nil
	--self.TextHaveScore = nil
	--self.TextNumberOfChallenges_1 = nil
	--self.TextSclassQuantity = nil
	--self.TextSclassScore = nil
	--self.TextScore1 = nil
	--self.TextTips = nil
	--self.TextTips1 = nil
	--self.ToggleBtnFlipPage = nil
	--self.AnimIn = nil
	--self.AnimTargetIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationSettlementPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BtnConform)
	self:AddSubView(self.BtnFightingAgain)
	self:AddSubView(self.BtnFraction)
	self:AddSubView(self.BtnHave)
	self:AddSubView(self.BtnLeave_1)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.RossTips)
	self:AddSubView(self.Target)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationSettlementPanelView:OnInit()
	self.ProgressAwardAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList2, nil, true, false)
	self.EquipsAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList1, nil, true, false)
	self.RewardAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, nil, true, false)
	self.Binders = {
		{"CurChallengeEquipVMList", UIBinderUpdateBindableList.New(self, self.EquipsAdapterTableView)},
		{"SettlementProgressAwardVMList", UIBinderUpdateBindableList.New(self, self.ProgressAwardAdapterTableView)},
		{"CurResultRewardVMList", UIBinderUpdateBindableList.New(self, self.RewardAdapterTableView)},
		{"IsGetReward", UIBinderSetIsVisible.New(self, self.TextAward)},
		{"IsGetReward", UIBinderSetIsVisible.New(self, self.PanelTips1, true)},
		{"SettlementTipText", UIBinderSetText.New(self, self.TextTips1)},
		{"CurScore", UIBinderSetText.New(self, self.TextFraction)},
		{"RemainTimesText", UIBinderSetText.New(self, self.TextNumberOfChallenges_1)},
		{"IsRemainTimesNotEnough", UIBinderValueChangedCallback.New(self, nil, self.OnIsRemainTimesNotEnoughChanged) },
		{"WeekRemainTimesColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumberOfChallenges_1) },
		{"EndSettlement", UIBinderValueChangedCallback.New(self, nil, self.OnEndSettlementChanged) },

		{"BaseScoreText", UIBinderSetText.New(self, self.TextScore1)},
		{"MatchNumText", UIBinderSetText.New(self, self.TextConformQuantity)},
		{"MatchScoreText", UIBinderSetText.New(self, self.TextConformScore)},
		{"OwnNumText", UIBinderSetText.New(self, self.TextHaveQuantity)},
		{"OwnScoreText", UIBinderSetText.New(self, self.TextHaveScore)},
		{"SuperMatchNumText", UIBinderSetText.New(self, self.TextSclassQuantity)},
		{"SuperMatchScoreText", UIBinderSetText.New(self, self.TextSclassScore)},
		{"IsShowSuperMatchInfo", UIBinderSetIsVisible.New(self, self.PanelSclass)},
	}

	self.ScoreEffectWidgetList = {
		[1] = self.EFF_Score1,
		[2] = self.EFF_Score2,
		[3] = self.EFF_Score3,
		[4] = self.EFF_Score4,
	} 
end

function FashionEvaluationSettlementPanelView:OnDestroy()

end

function FashionEvaluationSettlementPanelView:OnShow()
	self:SetLSTR()
	UIUtil.SetIsVisible(self.RossTips, false)
	UIUtil.SetIsVisible(self.BackBtn, false, true)
	UIUtil.SetIsVisible(self.PanelTargetSettlement, false, true)
	UIUtil.SetIsVisible(self.PanelExteriorSettlement, true, true)
	UIUtil.SetIsVisible(self.PanelTips, false)
	UIUtil.SetIsVisible(self.PanelBtn, false)
	self:OnCurScoreChanged(FashionEvaluationVM.CurScore)
	self:UpdateScoreEffect(FashionEvaluationVM.CurScore)
	FashionEvaluationMgr:PlayMajorAnimation(FashionEvaluationVM.CurScore)
	_G.HUDMgr:SetIsDrawHUD(false)

	if self.AnimIn then
		local function ShowBtnStart()
			UIUtil.SetIsVisible(self.BtnStart, true)
			self.BtnStart:SetRenderOpacity(1.0)
		end
		local AnimInLen = self.AnimIn:GetEndTime()
		self:RegisterTimer(ShowBtnStart, AnimInLen) -- 保底显示，防止动效失灵
	end

	local function TryShowAdventure()
		_G.LeftSidebarMgr:TryShowNextInfoView()
	end
	self:RegisterTimer(TryShowAdventure, 1)
end

function FashionEvaluationSettlementPanelView:SetLSTR()
	self.TextTips:SetText(_G.LSTR(1120048))--1120048("分数不错，可以标记外观来追踪获取")
	self.TextAward:SetText(_G.LSTR(1120050))--1120050("奖励")
	self.BtnStart:SetBtnName(_G.LSTR(1120051))--1120051("继  续")
	self.BtnFightingAgain:SetButtonText(_G.LSTR(1120052))--1120052("再  战")
	self.BtnLeave_1:SetButtonText(_G.LSTR(1120053))--1120053("离  开")
	self.TextFarction:SetText(_G.LSTR(1120035))--1120035("基础分")
end

function FashionEvaluationSettlementPanelView:OnHide()
	FashionEvaluationMgr:RestoreRoleAvatar()
end

function FashionEvaluationSettlementPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnContinueClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnLeave_1, self.OnBtnLeaveClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnFightingAgain.Button, self.OnBtnAgainFittingClicked)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnFlipPage, self.OnToggleBtnFlipPage)
end

function FashionEvaluationSettlementPanelView:OnRegisterGameEvent()

end

function FashionEvaluationSettlementPanelView:OnRegisterBinder()
	self.IsEndSettlement = FashionEvaluationVM.EndSettlement
	self.CurScore = FashionEvaluationVM.CurScore
	self:RegisterBinders(FashionEvaluationVM, self.Binders)
end

function FashionEvaluationSettlementPanelView:OnToggleBtnFlipPage(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	UIUtil.SetIsVisible(self.PanelTargetSettlement, IsChecked, true)
	UIUtil.SetIsVisible(self.PanelExteriorSettlement, not IsChecked, true)
	UIUtil.SetIsVisible(self.BtnStart, false)
end

---------------------------外观评分信息--------------------------------
---@type 继续
function FashionEvaluationSettlementPanelView:OnBtnContinueClicked()
	--显示积分奖励信息
	UIUtil.SetIsVisible(self.PanelTargetSettlement, true, true)
	UIUtil.SetIsVisible(self.PanelExteriorSettlement, false, true)
	UIUtil.SetIsVisible(self.PanelBtn, true, true)
	self.PanelBtn:SetRenderOpacity(0)
	for _, ItemView in ipairs(self.ProgressAwardAdapterTableView.ItemViewList) do
		if UIUtil.IsVisible(ItemView) then
			ItemView:OnShow()
		end
	end 
	UIUtil.SetIsVisible(self.RossTips, false)
	--UIUtil.SetIsVisible(self.PanelTips, false)
	-- if self.TrackTipsTimer then
	-- 	self:UnRegisterTimer(self.TrackTipsTimer)
	-- 	self.TrackTipsTimer = nil
	-- end

	self:OnEndSettlementChanged(self.IsEndSettlement)
end

---@type 外观追踪提示
function FashionEvaluationSettlementPanelView:OnCurScoreChanged(Score)
	if Score == nil then
		return
	end
	--大于80分，且有外观未解锁
	if Score >= FashionEvaluationDefine.TrackTipScore and not FashionEvaluationVM.IsOwnAll then
		--UIUtil.SetIsVisible(self.PanelTips, true)
		UIUtil.SetIsVisible(self.RossTips, true)
		self.RossTips:ShowSingleTips(nil, FashionEvaluationDefine.SettlementTipTextRetry, 3)
		-- self.TrackTipsTimer = self:RegisterTimer(
		-- 	function() 
		-- 		UIUtil.SetIsVisible(self.PanelTips, false)
		-- 		self:UnRegisterTimer(self.TrackTipsTimer)
		-- 		self.TrackTipsTimer = nil
		-- 	end, 3
		-- )
	end
end

---@type 分数动效
function FashionEvaluationSettlementPanelView:UpdateScoreEffect(Score)
	if self.ScoreEffectWidgetList == nil then
		return
	end
	for _, EffectWidget in ipairs(self.ScoreEffectWidgetList) do
		UIUtil.SetIsVisible(EffectWidget, false)
	end

	local Level = FashionEvaluationVMUtils.GetScoreLevelForAnim(Score)
	local ShowEffect = self.ScoreEffectWidgetList[Level]
	if ShowEffect == nil then
		return
	end
	UIUtil.SetIsVisible(ShowEffect, true)
end
---------------------------结算信息--------------------------------

---@type 离开
function FashionEvaluationSettlementPanelView:OnBtnLeaveClicked()
	self:Hide()
	FashionEvaluationVM:SetSettlementViewVisible(false)
	--FashionEvaluationMgr:ShowFashionMainView(true)
	FashionEvaluationMgr:OnExitFashionEvaluation()
end 

---@type 再次试衣
function FashionEvaluationSettlementPanelView:OnBtnAgainFittingClicked()
	self:Hide()
	FashionEvaluationVM:SetSettlementViewVisible(false)
	FashionEvaluationMgr:ShowFittingView(true, true)
	--清空外观
	local FittingVM = FashionEvaluationVM:GetFittingVM()
	if FittingVM then
		FittingVM:UpdateThemePartList()
	end
	FashionEvaluationMgr:RestoreUICharacterAvatar()
end

function FashionEvaluationSettlementPanelView:OnIsRemainTimesNotEnoughChanged(IsRemainTimesNotEnough)
	self.BtnFightingAgain:SetIsEnabled(not IsRemainTimesNotEnough, false)
end

function FashionEvaluationSettlementPanelView:OnEndSettlementChanged(IsEndSettlement)
	if IsEndSettlement then
		self:PlayAnimation(self.AnimTargetIn, 0, 1,nil, 1.0, false)
		local function LootDrop()
			local Coins = FashionEvaluationVM.Coins
			if Coins > 0 then
				local LootItem = { Type = 1, Item = { GID = 0, ResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, Value = Coins } }
				local CommList = {LootItem}
				_G.LootMgr:ShowSysChatDropList(CommList)
				_G.LootMgr:HandleMultipleDrop(CommList)
			end
		end
		local AnimDuration = self.AnimTargetIn:GetEndTime()
		self:RegisterTimer(LootDrop, AnimDuration)
	end
end

return FashionEvaluationSettlementPanelView