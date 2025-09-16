---
--- Author: Administrator
--- DateTime: 2024-02-20 16:40
--- Description:得分 通用Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FashionEvaluationProgressScoreItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextQuantity UFTextBlock
---@field AnimScoring1 UWidgetAnimation
---@field AnimScoring2 UWidgetAnimation
---@field AnimScoring3 UWidgetAnimation
---@field AnimScoring4 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationProgressScoreItemView = LuaClass(UIView, true)

function FashionEvaluationProgressScoreItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextQuantity = nil
	--self.AnimScoring1 = nil
	--self.AnimScoring2 = nil
	--self.AnimScoring3 = nil
	--self.AnimScoring4 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationProgressScoreItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationProgressScoreItemView:OnInit()
	self.ScoreAnimList = {
		[1] = self.AnimScoring1,
		[2] = self.AnimScoring2,
		[3] = self.AnimScoring3,
		[4] = self.AnimScoring4,
	}
end

function FashionEvaluationProgressScoreItemView:OnDestroy()

end

function FashionEvaluationProgressScoreItemView:OnShow()

end

function FashionEvaluationProgressScoreItemView:OnHide()
	self:StopAllAnimations()
end

function FashionEvaluationProgressScoreItemView:OnRegisterUIEvent()

end

function FashionEvaluationProgressScoreItemView:OnRegisterGameEvent()

end

function FashionEvaluationProgressScoreItemView:OnRegisterBinder()

end

function FashionEvaluationProgressScoreItemView:PlayAnimationByScoreLevel(ScoreLevel)
	if ScoreLevel == nil or ScoreLevel <= 0 then
		return 0
	end

	if self.ScoreAnimList == nil then
		return 0
	end

	if self.Anim then
		self:PlayAnimationTimeRange(self.Anim, 0.0, 0.01, 1, nil, 1.0, false)
	end

	self.Anim = self.ScoreAnimList[ScoreLevel]
	if self.Anim == nil then
		return 0
	end

	self:PlayAnimation(self.Anim, 0, 1,nil, 1.0, false)
	return self.Anim:GetEndTime()
end

return FashionEvaluationProgressScoreItemView