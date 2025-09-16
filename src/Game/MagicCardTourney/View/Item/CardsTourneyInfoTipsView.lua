---
--- Author: Administrator
--- DateTime: 2024-01-09 20:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CardsTourneyInfoTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichText01 URichTextBox
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyInfoTipsView = LuaClass(UIView, true)

function CardsTourneyInfoTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichText01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyInfoTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyInfoTipsView:OnInit()
	self.Binders = {
		{ "CurStageName", UIBinderSetText.New(self, self.TextTitle) },--阶段名
		{ "EffectAndProgressText", UIBinderSetText.New(self, self.RichText01) },--阶段与效果进度
		{ "CurEffectDesc", UIBinderSetText.New(self, self.Text02) },--效果说明
	}
end

function CardsTourneyInfoTipsView:OnDestroy()

end

function CardsTourneyInfoTipsView:OnShow()
	UIUtil.SetIsVisible(self.Text03, false)
	UIUtil.SetIsVisible(self.Text04, false)

	if self.Params == nil then
		return
	end
	local TargetAbsolutePos = self.Params.AbsolutePos
	if TargetAbsolutePos then
		local TargetPosition = UIUtil.AbsoluteToViewport(TargetAbsolutePos)
		self:SetRenderTranslation(TargetPosition)
	end
	-- 3秒后自动隐藏
	self:RegisterTimer(self.Hide, 3)
end

function CardsTourneyInfoTipsView:OnHide()

end

function CardsTourneyInfoTipsView:OnRegisterUIEvent()

end

function CardsTourneyInfoTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function CardsTourneyInfoTipsView:OnRegisterBinder()
	if TourneyVM == nil then
		return
	end
	self:RegisterBinders(TourneyVM, self.Binders)
end

function CardsTourneyInfoTipsView:OnPreprocessedMouseButtonDown()
	self:Hide()
end

return CardsTourneyInfoTipsView