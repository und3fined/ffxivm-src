---
--- Author: Administrator
--- DateTime: 2024-12-11 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FashionEvaluationCelebrationMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GrandCeremonyTips FashionEvaluationGrandCeremonyTipsItemView
---@field MainPanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationCelebrationMainPanelView = LuaClass(UIView, true)

function FashionEvaluationCelebrationMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GrandCeremonyTips = nil
	--self.MainPanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationCelebrationMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GrandCeremonyTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationCelebrationMainPanelView:OnInit()

end

function FashionEvaluationCelebrationMainPanelView:OnDestroy()

end

function FashionEvaluationCelebrationMainPanelView:OnShow()
	if self.Params == nil then
		return
	end

	local EfectFinishedCallback = self.Params.EfectFinishedCallback
	if EfectFinishedCallback then
		local function OnEffectAnimFinished()
			self:Hide()
			EfectFinishedCallback(self.Params.View)
		end
		local AnimInLength = self:GetAnimInTime()
		self:RegisterTimer(OnEffectAnimFinished, AnimInLength)
	end
end

function FashionEvaluationCelebrationMainPanelView:OnHide()

end

function FashionEvaluationCelebrationMainPanelView:OnRegisterUIEvent()

end

function FashionEvaluationCelebrationMainPanelView:OnRegisterGameEvent()

end

function FashionEvaluationCelebrationMainPanelView:OnRegisterBinder()

end

return FashionEvaluationCelebrationMainPanelView