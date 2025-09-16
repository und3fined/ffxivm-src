---
--- Author: Administrator
--- DateTime: 2024-08-19 19:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChocoboFeeDingApertureItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_1 UFCanvasPanel
---@field PanelAperture UFCanvasPanel
---@field PanelScale UFCanvasPanel
---@field PanelStatic UFCanvasPanel
---@field AnimAvailable UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimScale UWidgetAnimation
---@field AnimScale0 UWidgetAnimation
---@field AnimScale1 UWidgetAnimation
---@field AnimShow UWidgetAnimation
---@field AnimSuccessHide UWidgetAnimation
---@field CurveScale CurveFloat
---@field ValueScaleMin float
---@field ValueScaleMax float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboFeeDingApertureItemView = LuaClass(UIView, true)

function ChocoboFeeDingApertureItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_1 = nil
	--self.PanelAperture = nil
	--self.PanelScale = nil
	--self.PanelStatic = nil
	--self.AnimAvailable = nil
	--self.AnimHide = nil
	--self.AnimScale = nil
	--self.AnimScale0 = nil
	--self.AnimScale1 = nil
	--self.AnimShow = nil
	--self.AnimSuccessHide = nil
	--self.CurveScale = nil
	--self.ValueScaleMin = nil
	--self.ValueScaleMax = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingApertureItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboFeeDingApertureItemView:OnInit()

end

function ChocoboFeeDingApertureItemView:OnDestroy()

end

function ChocoboFeeDingApertureItemView:OnShow()
end

function ChocoboFeeDingApertureItemView:OnHide()

end

function ChocoboFeeDingApertureItemView:OnRegisterUIEvent()

end

function ChocoboFeeDingApertureItemView:OnRegisterGameEvent()

end

function ChocoboFeeDingApertureItemView:OnRegisterBinder()

end

function ChocoboFeeDingApertureItemView:SetScale(NewValue)
    self.PanelStatic:SetRenderScale(_G.UE.FVector2D(NewValue, NewValue))
end

function ChocoboFeeDingApertureItemView:GameBegin(InSpeed)
    self:PlayAnimation(self.AnimScale, 0, 0, 2, InSpeed or 1)
end

function ChocoboFeeDingApertureItemView:GetAnimScaleEndTime()
    return self.AnimScale:GetEndTime()
end

function ChocoboFeeDingApertureItemView:StopAnimScale()
    self:StopAnimation(self.AnimScale)
end

function ChocoboFeeDingApertureItemView:PlayAnimShow()
    self.PanelScale:SetRenderOpacity(1)
    self.PanelScale:SetRenderScale(_G.UE.FVector2D(1, 1))
    self:PlayAnimation(self.AnimShow)
end

function ChocoboFeeDingApertureItemView:PlayAnimSuccessHide()
    self:PlayAnimation(self.AnimSuccessHide)
end

function ChocoboFeeDingApertureItemView:PlayAnimHide()
    self:PlayAnimation(self.AnimHide)
end

function ChocoboFeeDingApertureItemView:GetCurInnerCircle()
    local Transform = self.PanelStatic.RenderTransform
    if Transform == nil or Transform.Scale == nil then
        return 0
    end

    return Transform.Scale.X or 0
end

function ChocoboFeeDingApertureItemView:GetCurOuterCircle()
    local Transform = self.PanelScale.RenderTransform
    if Transform == nil or Transform.Scale == nil then
        return 0
    end

    return Transform.Scale.X or 0
end

return ChocoboFeeDingApertureItemView