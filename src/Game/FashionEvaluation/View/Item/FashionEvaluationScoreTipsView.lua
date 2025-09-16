---
--- Author: Administrator
--- DateTime: 2024-11-04 20:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MatchIcon = "PaperSprite'/Game/UI/Atlas/FashionEvaluation/Frames/UI_FashionEvaluation_Icon_RatingTopic_png.UI_FashionEvaluation_Icon_RatingTopic_png'"
local OwnIcon = "PaperSprite'/Game/UI/Atlas/FashionEvaluation/Frames/UI_FashionEvaluation_Icon_RatingAppearance_png.UI_FashionEvaluation_Icon_RatingAppearance_png'"

---@class FashionEvaluationScoreTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field TextFraction UFTextBlock
---@field TextInfo UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationScoreTipsView = LuaClass(UIView, true)

function FashionEvaluationScoreTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.TextFraction = nil
	--self.TextInfo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationScoreTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationScoreTipsView:OnInit()

end

function FashionEvaluationScoreTipsView:OnDestroy()

end

function FashionEvaluationScoreTipsView:OnShow()

end

function FashionEvaluationScoreTipsView:OnHide()

end

function FashionEvaluationScoreTipsView:OnRegisterUIEvent()

end

function FashionEvaluationScoreTipsView:OnRegisterGameEvent()

end

function FashionEvaluationScoreTipsView:OnRegisterBinder()

end

function FashionEvaluationScoreTipsView:UpdateScoreDetail(Content, Score, IsMatchScore)
	if not string.isnilorempty(Content) then
		self.TextInfo:SetText(Content)
	end
	
	if Score then
		self.TextFraction:SetText(string.format("+%s", Score))
	end
	
	if IsMatchScore then
		UIUtil.ImageSetBrushFromAssetPath(self.Icon, MatchIcon)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.Icon, OwnIcon)
	end
end

return FashionEvaluationScoreTipsView