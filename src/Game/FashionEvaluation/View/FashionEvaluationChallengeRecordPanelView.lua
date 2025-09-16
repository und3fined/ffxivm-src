---
--- Author: Administrator
--- DateTime: 2024-02-20 16:40
--- Description:挑战记录界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local LSTR = _G.LSTR

---@class FashionEvaluationChallengeRecordPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnConform CommInforBtnView
---@field BtnFraction CommInforBtnView
---@field BtnHave CommInforBtnView
---@field BtnWear CommBtnLView
---@field EFF_Score1 UFCanvasPanel
---@field EFF_Score2 UFCanvasPanel
---@field EFF_Score3 UFCanvasPanel
---@field EFF_Score4 UFCanvasPanel
---@field PanelCalculatingTheScore UFCanvasPanel
---@field PanelExteriorSettlement UFCanvasPanel
---@field PanelSclass UFCanvasPanel
---@field TableViewList1 UTableView
---@field TableViewTab UTableView
---@field Target FashionEvaluationTargetItemView
---@field TextConformQuantity UFTextBlock
---@field TextConformScore UFTextBlock
---@field TextFarction UFTextBlock
---@field TextFraction UFTextBlock
---@field TextHaveQuantity UFTextBlock
---@field TextHaveScore UFTextBlock
---@field TextSclassQuantity UFTextBlock
---@field TextSclassScore UFTextBlock
---@field TextScore1 UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationChallengeRecordPanelView = LuaClass(UIView, true)

function FashionEvaluationChallengeRecordPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnConform = nil
	--self.BtnFraction = nil
	--self.BtnHave = nil
	--self.BtnWear = nil
	--self.EFF_Score1 = nil
	--self.EFF_Score2 = nil
	--self.EFF_Score3 = nil
	--self.EFF_Score4 = nil
	--self.PanelCalculatingTheScore = nil
	--self.PanelExteriorSettlement = nil
	--self.PanelSclass = nil
	--self.TableViewList1 = nil
	--self.TableViewTab = nil
	--self.Target = nil
	--self.TextConformQuantity = nil
	--self.TextConformScore = nil
	--self.TextFarction = nil
	--self.TextFraction = nil
	--self.TextHaveQuantity = nil
	--self.TextHaveScore = nil
	--self.TextSclassQuantity = nil
	--self.TextSclassScore = nil
	--self.TextScore1 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BtnConform)
	self:AddSubView(self.BtnFraction)
	self:AddSubView(self.BtnHave)
	self:AddSubView(self.BtnWear)
	self:AddSubView(self.Target)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordPanelView:OnInit()
	self.HistoryIndexsAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnHistoryIndexSelected, true, false)
	self.HistoryAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList1, nil, true, false)
	self.Binders = {
		{"EvaluationHistoryIndexVMList", UIBinderUpdateBindableList.New(self, self.HistoryIndexsAdapterTableView)},
		{"EvaluationHistoryVMList", UIBinderUpdateBindableList.New(self, self.HistoryAdapterTableView)},
		{"CurSelectedHistoryScore", UIBinderSetText.New(self, self.TextFraction)},
		--{"CurSelectedHistoryScoreBG", UIBinderSetBrushFromAssetPath.New(self, self.Img_FashionScoreBG)}, -- TODO
	}

	self.ScoreEffectWidgetList = {
		[1] = self.EFF_Score1,
		[2] = self.EFF_Score2,
		[3] = self.EFF_Score3,
		[4] = self.EFF_Score4,
	} 
end

function FashionEvaluationChallengeRecordPanelView:OnDestroy()
	
end

function FashionEvaluationChallengeRecordPanelView:OnShow()
	self:SetLSTR()
	self.HistoryIndexsAdapterTableView:SetSelectedIndex(1)
end

function FashionEvaluationChallengeRecordPanelView:OnHide()

end

function FashionEvaluationChallengeRecordPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BackBtn.Button, self.OnBtnCloseClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnWear, self.OnBtnFittingAllClicked)
end

function FashionEvaluationChallengeRecordPanelView:OnRegisterGameEvent()

end

function FashionEvaluationChallengeRecordPanelView:OnRegisterBinder()
	self.FittingVM = FashionEvaluationVM:GetFittingVM()
	if self.FittingVM then
		self:RegisterBinders(self.FittingVM, self.Binders)
	end
end

function FashionEvaluationChallengeRecordPanelView:OnBtnCloseClicked()
	FashionEvaluationMgr:ShowHistoryScoreView(false)
end

function FashionEvaluationChallengeRecordPanelView:OnHistoryIndexSelected(Index, ItemData, ItemView)
	self.FittingVM:OnHistoryIndexSelected(Index)
	local EquipList = self.FittingVM:GetCurSelectedHistoryList()
	FashionEvaluationMgr:WearAppearanceList(EquipList)
	FashionEvaluationMgr:PlayMajorAnimation(self.FittingVM.CurSelectedHistoryScore)
	self:UpdateScoreEffect(self.FittingVM.CurSelectedHistoryScore)
	self:UpdateScoreDetail()
end

function FashionEvaluationChallengeRecordPanelView:SetLSTR()
	self.TextTitle:SetText(LSTR(1120034)) -- 1120034("挑战记录")
	self.TextFarction:SetText(LSTR(1120035)) --1120035("基础分")
	self.BtnWear:SetBtnName(LSTR(1120036))--1120036("一键穿戴")
	self.TextConformQuantity:SetText(LSTR(FashionEvaluationDefine.MatchScoreUKey))
	self.TextHaveQuantity:SetText(LSTR(FashionEvaluationDefine.OwnScoreUKey))
	self.TextSclassQuantity:SetText(LSTR(FashionEvaluationDefine.SuperMatchScoreUKey))
end

---@type 更新得分明细
function FashionEvaluationChallengeRecordPanelView:UpdateScoreDetail()
	local SelectedHistoryInfo = self.FittingVM:GetCurSelectedHistoryInfo()
	if SelectedHistoryInfo == nil then
		return
	end

	local MatchScore = SelectedHistoryInfo.MatchScore
	local SuperMatchScore = SelectedHistoryInfo.SuperMatchScore
	local BaseScore = SelectedHistoryInfo.BaseScore
	local OwnScore = SelectedHistoryInfo.OwnScore
	local OwnNum = SelectedHistoryInfo.OwnNum
	local MatchNum = SelectedHistoryInfo.MatchNum
	local SuperMatchNum = SelectedHistoryInfo.SuperMatchNum
	if SuperMatchNum <= 0 then
		UIUtil.SetIsVisible(self.PanelSclass, false)
	else
		self.TextSclassScore:SetText(string.format("+%s", SuperMatchScore))
	end
	--基础分
	self.TextScore1:SetText(string.format("+%s", BaseScore))
	--符合分
	self.TextConformScore:SetText(string.format("+%s", MatchScore))
	--拥有分
	self.TextHaveScore:SetText(string.format("+%s", OwnScore))
end

---@type 一键穿戴
function FashionEvaluationChallengeRecordPanelView:OnBtnFittingAllClicked()
	self.FittingVM:FittingSelectedHistoryEquips()
	FashionEvaluationMgr:ShowHistoryScoreView(false)
	FashionEvaluationMgr:ShowFittingView(true, true)
end

---@type 分数动效
function FashionEvaluationChallengeRecordPanelView:UpdateScoreEffect(Score)
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


return FashionEvaluationChallengeRecordPanelView