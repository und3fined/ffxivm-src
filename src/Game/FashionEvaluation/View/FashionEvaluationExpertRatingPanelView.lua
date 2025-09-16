---
--- Author: Administrator
--- DateTime: 2024-02-20 16:40
--- Description:达人评分界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")

local EFashionView = FashionEvaluationDefine.EFashionView

---@class FashionEvaluationExpertRatingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnArrowLeft UFButton
---@field BtnArrowRight UFButton
---@field BtnStart CommBtnLView
---@field EFF_Score1 UFCanvasPanel
---@field EFF_Score2 UFCanvasPanel
---@field EFF_Score3 UFCanvasPanel
---@field EFF_Score4 UFCanvasPanel
---@field TableViewDrop UTableView
---@field TableView_43 UTableView
---@field Target FashionEvaluationTargetItemView
---@field TextFraction UFTextBlock
---@field TextNumberOfChallenges UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationExpertRatingPanelView = LuaClass(UIView, true)

function FashionEvaluationExpertRatingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnArrowLeft = nil
	--self.BtnArrowRight = nil
	--self.BtnStart = nil
	--self.EFF_Score1 = nil
	--self.EFF_Score2 = nil
	--self.EFF_Score3 = nil
	--self.EFF_Score4 = nil
	--self.TableViewDrop = nil
	--self.TableView_43 = nil
	--self.Target = nil
	--self.TextFraction = nil
	--self.TextNumberOfChallenges = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationExpertRatingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.Target)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationExpertRatingPanelView:OnInit()
	self.NPCIndexsAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewDrop, nil, true, false)
	self.AppearanceListAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_43, nil, true, false)
	self.Binders = {
		{"NPCIndexVMList", UIBinderUpdateBindableList.New(self, self.NPCIndexsAdapterTableView)},
		{"CurSelectNPCAppVMList", UIBinderUpdateBindableList.New(self, self.AppearanceListAdapterTableView)},
		{"CurSelectedNPCScore", UIBinderSetText.New(self, self.TextFraction)},
		{"RemainTimesText", UIBinderSetText.New(self, self.TextNumberOfChallenges)},
		{"WeekRemainTimesColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumberOfChallenges) },
		{"IsRemainTimesNotEnough", UIBinderValueChangedCallback.New(self, nil, self.OnIsRemainTimesNotEnoughChanged) },
	}
	self.CreatedNPCList = {}

	self.ScoreEffectWidgetList = {
		[1] = self.EFF_Score1,
		[2] = self.EFF_Score2,
		[3] = self.EFF_Score3,
		[4] = self.EFF_Score4,
	} 
end

function FashionEvaluationExpertRatingPanelView:OnDestroy()
	
end

function FashionEvaluationExpertRatingPanelView:OnShow()
	self:SetLSTR()
	if self.Params == nil then
		return
	end
	local NPCIndex = self.Params.NPCIndex
	if NPCIndex == nil then
		return
	end

	self.NPCIndexsAdapterTableView:SetSelectedIndex(NPCIndex)
	self.CreatedNPCList = FashionEvaluationMgr:GetCreatedNPCList()
	self:SwitchNPC(NPCIndex)
end

function FashionEvaluationExpertRatingPanelView:OnHide()

end

function FashionEvaluationExpertRatingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BackBtn.Button, self.OnBtnCloseClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnFittingClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnArrowLeft, self.OnBtnUpClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnArrowRight, self.OnBtnNextClicked)
end

function FashionEvaluationExpertRatingPanelView:OnRegisterGameEvent()

end

function FashionEvaluationExpertRatingPanelView:OnRegisterBinder()
	self:RegisterBinders(FashionEvaluationVM, self.Binders)
end

function FashionEvaluationExpertRatingPanelView:SetLSTR()
	self.TextTitle:SetText(_G.LSTR(1120037)) -- 1120037("达人评分")
	self.BtnStart:SetBtnName(_G.LSTR(1120032)) --1120032("开始挑战")
end

function FashionEvaluationExpertRatingPanelView:OnBtnCloseClicked()
	FashionEvaluationMgr:ShowFashionNPCView(false)
end

function FashionEvaluationExpertRatingPanelView:OnBtnUpClicked()
	local NewIndex = FashionEvaluationVM:UpNPCEquips()

	if NewIndex then
		self.NPCIndexsAdapterTableView:SetSelectedIndex(NewIndex)
		self:SwitchNPC(NewIndex)
	end
end

function FashionEvaluationExpertRatingPanelView:OnBtnNextClicked()
	local NewIndex = FashionEvaluationVM:NextNPCEquips()

	if NewIndex then
		self.NPCIndexsAdapterTableView:SetSelectedIndex(NewIndex)
		self:SwitchNPC(NewIndex)
	end
end

function FashionEvaluationExpertRatingPanelView:OnBtnFittingClicked()
	FashionEvaluationMgr:ShowFashionNPCView(false)
	FashionEvaluationMgr:ShowFittingView(true, true)
end

---@type 设置NPC到场景中间
function FashionEvaluationExpertRatingPanelView:SwitchNPC(NPCIndex)
	if NPCIndex == nil then
		return
	end
	local EntityID = self.CreatedNPCList[NPCIndex]

	if self.CurNPCEntityID then
		_G.UE.UActorManager.Get():HideActor(self.CurNPCEntityID, true)
	end

	local NPCActor = ActorUtil.GetActorByEntityID(EntityID)
	if NPCActor == nil then
		return
	end
	_G.UE.UActorManager.Get():HideActor(EntityID, false)
	local NPCLocZ = NPCActor:K2_GetActorLocation().Z
	local Location, Rotation = FashionEvaluationVMUtils.GetShowLocationAndRotation(EFashionView.NPCEquip)
	if Location then
		local NewLocation = _G.UE.FVector(Location.X, Location.Y, NPCLocZ)
		NPCActor:K2_SetActorLocation(NewLocation, false, nil, false)
	end

	if Rotation then
		NPCActor:K2_SetActorRotation(Rotation, false)
	end
	
	self.CurNPCEntityID = EntityID
	_G.EventMgr:SendEvent(_G.EventID.OnFashionNPCSelectedChanged, NPCIndex)

	self:UpdateScoreEffect(FashionEvaluationVM.CurSelectedNPCScore)
	self:PlayNPCAnimation(NPCActor, FashionEvaluationVM.CurSelectedNPCScore)
end

function FashionEvaluationExpertRatingPanelView:OnIsRemainTimesNotEnoughChanged(IsRemainTimesNotEnough)
	self.BtnStart:SetIsEnabled(not IsRemainTimesNotEnough, false)
end

function FashionEvaluationExpertRatingPanelView:UpdateScoreEffect(Score)
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
	self:PlayAnimation(self.AnimRefresh)
end

function FashionEvaluationExpertRatingPanelView:PlayNPCAnimation(NpcActor, Score)
	if NpcActor == nil then
		return
	end
	local AnimComp = NpcActor:GetAnimationComponent()
	if AnimComp == nil then
		return
	end
	local AnimPath = FashionEvaluationVMUtils.GetAnimPathByScore(Score, NpcActor)
	if not string.isnilorempty(AnimPath) then
		AnimComp:PlayAnimation(AnimPath, 1.0, 0.25, 0.25, true)
	end
end

return FashionEvaluationExpertRatingPanelView