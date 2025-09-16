---
--- Author: Administrator
--- DateTime: 2024-02-20 20:21
--- Description:挑战结算/挑战记录界面 外观列表ItemView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")

---@class FashionEvaluationChallengeRecordListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconHave UFImage
---@field ImgBtnBg UFImage
---@field ImgQualified UFImage
---@field ImgSclass UFImage
---@field ImgThing UFImage
---@field ImgUnqualified UFImage
---@field MI_DX_Common_FashionEvaluation_9 UFImage
---@field PanelSclass UFCanvasPanel
---@field TextName UFTextBlock
---@field TextType UFTextBlock
---@field ToggleButton_61 UToggleButton
---@field AnimInRecord UWidgetAnimation
---@field AnimInSettlement UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationChallengeRecordListView = LuaClass(UIView, true)

function FashionEvaluationChallengeRecordListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconHave = nil
	--self.ImgBtnBg = nil
	--self.ImgQualified = nil
	--self.ImgSclass = nil
	--self.ImgThing = nil
	--self.ImgUnqualified = nil
	--self.MI_DX_Common_FashionEvaluation_9 = nil
	--self.PanelSclass = nil
	--self.TextName = nil
	--self.TextType = nil
	--self.ToggleButton_61 = nil
	--self.AnimInRecord = nil
	--self.AnimInSettlement = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordListView:OnInit()
	self.Binders = {
		{"MatchIconVisible", UIBinderSetIsVisible.New(self, self.ImgQualified)},
		{"NotMatchIconVisible", UIBinderSetIsVisible.New(self, self.ImgUnqualified)},
		{"SuperMatchIconVisible", UIBinderSetIsVisible.New(self, self.PanelSclass)},
		{"AppearanceName", UIBinderSetText.New(self, self.TextName)},
		{"PartThemeName", UIBinderSetText.New(self, self.TextType)},
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgThing)},
		{"IsOwn", UIBinderSetIsVisible.New(self, self.IconHave)},
		{"IsEmpty", UIBinderSetIsVisible.New(self, self.ImgBtnBg, true, false)},
		{"IsEmpty", UIBinderSetIsVisible.New(self, self.ToggleButton_61, true, true)},
		{"IsTracked", UIBinderSetIsChecked.New(self, self.ToggleButton_61)}, 
		{"EquipIconOpacity", UIBinderSetOpacity.New(self, self.ImgThing)},
	}
end

function FashionEvaluationChallengeRecordListView:OnDestroy()

end

function FashionEvaluationChallengeRecordListView:OnShow()
	self:UpdateEffect()
end

function FashionEvaluationChallengeRecordListView:OnHide()

end

function FashionEvaluationChallengeRecordListView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton_61, self.OnChangedToggleBtnTrack)
end

function FashionEvaluationChallengeRecordListView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnAppearanceTrackStateChanged, self.OnAppearanceTrackStateChanged)
end

function FashionEvaluationChallengeRecordListView:OnRegisterBinder()
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

function FashionEvaluationChallengeRecordListView:OnAppearanceTrackStateChanged(AppearanceID, IsTrack)
	-- 同步追踪界面衣橱目标
	self.CurSelectAppID = self.ViewModel.AppearanceID
	if self.CurSelectAppID == AppearanceID then
		if not IsTrack then
			self.ToggleButton_61:SetChecked(false)
		end
	end
end

function FashionEvaluationChallengeRecordListView:OnChangedToggleBtnTrack()
	self.CurSelectAppID = self.ViewModel.AppearanceID
	if self.CurSelectAppID == nil or self.CurSelectAppID <= 0 then
		return
	end

	local IsChecked = self.ToggleButton_61:GetChecked()
	if not FashionEvaluationMgr:OnEquipTrackClicked(self.CurSelectAppID, IsChecked) then
		if self.ToggleButton_61:GetChecked() then
			self.ToggleButton_61:SetChecked(false)
		end
	end 
end

function FashionEvaluationChallengeRecordListView:UpdateEffect()
	if self.ViewModel then
		local ViewType = self.ViewModel.ViewType
		if ViewType == FashionEvaluationDefine.EFashionView.Record then
			self:PlayAnimation(self.AnimInRecord)
		elseif ViewType == FashionEvaluationDefine.EFashionView.Settlement then
			self:PlayAnimation(self.AnimInSettlement)
		end
	end
end


return FashionEvaluationChallengeRecordListView