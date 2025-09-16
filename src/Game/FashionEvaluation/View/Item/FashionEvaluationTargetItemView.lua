---
--- Author: Administrator
--- DateTime: 2024-11-01 19:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")

---@class FashionEvaluationTargetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTarget UFButton
---@field CommonRedDot CommonRedDotView
---@field TextTargetQuantity UFTextBlock
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationTargetItemView = LuaClass(UIView, true)

function FashionEvaluationTargetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTarget = nil
	--self.CommonRedDot = nil
	--self.TextTargetQuantity = nil
	--self.AnimClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationTargetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationTargetItemView:OnInit()
	UIUtil.SetRenderOpacity(self.TextTargetQuantity, 0)
end

function FashionEvaluationTargetItemView:OnDestroy()

end

function FashionEvaluationTargetItemView:OnShow()
	self.TextTargetQuantity:SetText("+1")
	local RedDotName = FashionEvaluationMgr:GetRedDotName()
	self.CommonRedDot:SetRedDotData(nil, RedDotName, RedDotDefine.RedDotStyle.NormalStyle)
end

function FashionEvaluationTargetItemView:OnHide()

end

function FashionEvaluationTargetItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTarget, self.OnBtnTargetClicked)
end

function FashionEvaluationTargetItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnAppearanceTrackStateChanged, self.OnAppearanceTrackStateChanged)
end

function FashionEvaluationTargetItemView:OnRegisterBinder()

end

function FashionEvaluationTargetItemView:OnAppearanceTrackStateChanged(AppearanceID, IsTrack)
	if IsTrack then
		self:PlayAnimation(self.AnimClick)
	end
end

function FashionEvaluationTargetItemView:OnBtnTargetClicked()
	FashionEvaluationMgr:ShowTrackTargetView()
end

return FashionEvaluationTargetItemView