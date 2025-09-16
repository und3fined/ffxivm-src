---
--- Author: Administrator
--- DateTime: 2024-04-01 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class FootPrintDataTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field ImgFocus UFImage
---@field TextTitle UFTextBlock
---@field TexxtSchedule UFTextBlock
---@field AnimNumberRoll UWidgetAnimation
---@field ValueAnimDepositCoin float
---@field CurveAnimDepositCoin CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintDataTabItemView = LuaClass(UIView, true)

function FootPrintDataTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.ImgFocus = nil
	--self.TextTitle = nil
	--self.TexxtSchedule = nil
	--self.AnimNumberRoll = nil
	--self.ValueAnimDepositCoin = nil
	--self.CurveAnimDepositCoin = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintDataTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintDataTabItemView:OnInit()
	self.Binders = {
		{"ParentTypeName", UIBinderSetText.New(self, self.TextTitle)},
		{"ScoreSchedule", UIBinderSetText.New(self, self.TexxtSchedule)},
		{"bSelected", UIBinderSetIsVisible.New(self, self.ImgFocus)},
		{"ScoreAdded", UIBinderValueChangedCallback.New(self, nil, self.OnScoreAnimAdded)},
		{"TypeIconPath", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{"TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTitle)},
		{"TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TexxtSchedule)},
	}

	self.ScoreChangeQueue = {} -- 分数变化显示队列
end

function FootPrintDataTabItemView:OnDestroy()
	self.ScoreChangeQueue = nil
end

function FootPrintDataTabItemView:OnShow()

end

function FootPrintDataTabItemView:OnHide()

end

function FootPrintDataTabItemView:OnRegisterUIEvent()

end

function FootPrintDataTabItemView:OnRegisterGameEvent()

end

function FootPrintDataTabItemView:OnRegisterBinder()
	local ViewModel = self:GetTheItemViewModel()
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function FootPrintDataTabItemView:GetTheItemViewModel()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	return ViewModel
end

--- 获取待播放特效的分数
function FootPrintDataTabItemView:GetTheScoreToPlay()
	local ScoreWaitForPlay = self.ScoreChangeQueue
	if not ScoreWaitForPlay or not next(ScoreWaitForPlay) then
		return
	end
	return ScoreWaitForPlay[1]
end


function FootPrintDataTabItemView:OnScoreAnimAdded(ScoreAdded)
	if ScoreAdded == 0 then
		return
	end

	local ViewModel = self:GetTheItemViewModel()
	if not ViewModel then
		return
	end

	local BeginScore = ViewModel.ScoreStart or 0
	table.insert(self.ScoreChangeQueue, { BeginScore = BeginScore, ChangeScore = ScoreAdded})

	if not self:IsAnimationPlaying(self.AnimNumberRoll) then
		self:PlayAnimation(self.AnimNumberRoll)
	end
end

function FootPrintDataTabItemView:SequenceEvent_AnimNumberRoll()
	self:GetValueAnimNumberRoll()
	local AnimRunPercent = self.ValueAnimDepositCoin
	if not AnimRunPercent then
		return
	end

	local ScoreToPlay = self:GetTheScoreToPlay()
	if not ScoreToPlay then
		return
	end

	local ViewModel = self:GetTheItemViewModel()
	if not ViewModel then
		return
	end
	
	local BeginScore = ScoreToPlay.BeginScore
	local ChangeScore = ScoreToPlay.ChangeScore
	if ChangeScore <= 0 then
		return
	end
	local CurrentScore = BeginScore + ChangeScore * AnimRunPercent
	ViewModel:UpdateParentTypeScoreInView(CurrentScore)
end

function FootPrintDataTabItemView:OnAnimationFinished(Animation)
	if Animation == self.AnimNumberRoll then
		table.remove(self.ScoreChangeQueue, 1)
		local ScoreToPlay = self:GetTheScoreToPlay()
		if not ScoreToPlay then
			local ViewModel = self:GetTheItemViewModel()
			if not ViewModel then
				return
			end
			ViewModel:ShowParentTypeScoreInView()
		else
			self:PlayAnimation(self.AnimNumberRoll)
		end 
	end
end

return FootPrintDataTabItemView