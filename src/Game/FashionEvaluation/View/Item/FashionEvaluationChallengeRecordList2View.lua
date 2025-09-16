---
--- Author: Administrator
--- DateTime: 2024-02-20 20:21
--- Description:结算界面 进度奖励列表Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")

---@class FashionEvaluationChallengeRecordList2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field HorizontalAward UFHorizontalBox
---@field IconSuccess UFImage
---@field TextQuantity UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimComplete1 UWidgetAnimation
---@field AnimComplete2 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationChallengeRecordList2View = LuaClass(UIView, true)

function FashionEvaluationChallengeRecordList2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.HorizontalAward = nil
	--self.IconSuccess = nil
	--self.TextQuantity = nil
	--self.TextTitle = nil
	--self.AnimComplete1 = nil
	--self.AnimComplete2 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordList2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordList2View:OnInit()
	self.Binders = {
		{"ProgressName", UIBinderSetText.New(self, self.TextTitle)},
		{"AwardIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_1)},
		{"AwardNum", UIBinderSetText.New(self, self.TextQuantity)},
		--动效相关
		{"IsNewGet", UIBinderValueChangedCallback.New(self, nil, self.OnIsNewGetChanged) }
	}
end

function FashionEvaluationChallengeRecordList2View:OnDestroy()

end

function FashionEvaluationChallengeRecordList2View:OnShow()
	self:OnShowResult()
end

function FashionEvaluationChallengeRecordList2View:OnHide()

end

function FashionEvaluationChallengeRecordList2View:OnRegisterUIEvent()

end

function FashionEvaluationChallengeRecordList2View:OnRegisterGameEvent()

end

function FashionEvaluationChallengeRecordList2View:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self.IsGetProgress = self.ViewModel.IsGetProgress
	self.AwardIndex = self.ViewModel.UnLockAwardIndex
	self.IsNewGet = self.ViewModel.IsNewGet
	self.IsAdvanced = self.AwardIndex and self.AwardIndex > 2
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function FashionEvaluationChallengeRecordList2View:OnIsNewGetChanged(IsNewGet)
	if IsNewGet then
		UIUtil.SetIsVisible(self.IconSuccess, false)
		UIUtil.SetIsVisible(self.HorizontalAward, true)
	else
		UIUtil.SetIsVisible(self.IconSuccess, self.IsGetProgress)
		UIUtil.SetIsVisible(self.HorizontalAward, not self.IsGetProgress)
		if self.IsGetProgress then
			local EndTime = self.AnimComplete1:GetEndTime()
			self:PlayAnimationTimeRange(self.AnimComplete1, EndTime - 0.01, EndTime, 1, nil, 1.0, false)
		end
	end
end

---@type 播放动效
function FashionEvaluationChallengeRecordList2View:PlayEffectAnim()
	local EffectAnim = self.AnimComplete1
	if self.IsAdvanced then
		EffectAnim = self.AnimComplete2
	end
	UIUtil.SetIsVisible(self, true)
	if self.IsGetProgress then
		self:PlayAnimation(EffectAnim)
		local function SettlementEffect()
			FashionEvaluationVM:OnPlayNewGetEffectFinished(self.AwardIndex)
		end
		self:RegisterTimer(SettlementEffect, EffectAnim:GetEndTime(), 0)
	end
end

function FashionEvaluationChallengeRecordList2View:OnShowResult()
	self.IsNewGet = self.ViewModel and self.ViewModel.IsNewGet
	self.IsGetProgress = self.ViewModel.IsGetProgress
	if self.IsNewGet then
		FashionEvaluationVM:RegisterProgressAward(self.ViewModel, self)
	else
		self.HorizontalAward:SetRenderOpacity(1) --解锁动效会将透明度设为0，所以这里恢复
	end
end

return FashionEvaluationChallengeRecordList2View