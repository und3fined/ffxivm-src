---
--- Author: Administrator
--- DateTime: 2024-10-31 11:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FashionEvaluationOpeningPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProgress UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationOpeningPanelView = LuaClass(UIView, true)

function FashionEvaluationOpeningPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--self.AnimProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationOpeningPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationOpeningPanelView:OnInit()

end

function FashionEvaluationOpeningPanelView:OnDestroy()

end

function FashionEvaluationOpeningPanelView:OnShow()
	self.CurPercent = 0
	self:PlayAnimationTimeRange(self.AnimProgress, 0, 0.01, 1, nil, 1, false)
end

function FashionEvaluationOpeningPanelView:OnHide()

end

function FashionEvaluationOpeningPanelView:OnRegisterUIEvent()

end

function FashionEvaluationOpeningPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnFashionNPCLoadingProgress, self.OnGameEventNPCLoadingProgress)
end

function FashionEvaluationOpeningPanelView:OnRegisterBinder()

end

function FashionEvaluationOpeningPanelView:OnGameEventNPCLoadingProgress(Percent)
	local Start = self.AnimProgress:GetEndTime() * self.CurPercent
	local AnimTimeEnd = self.AnimProgress:GetEndTime() * Percent
	self:PlayAnimationTimeRange(self.AnimProgress, Start, AnimTimeEnd, 1, nil, 1, false)
	self.CurPercent = Percent
end

return FashionEvaluationOpeningPanelView