---
--- Author: henghaoli
--- DateTime: 2024-10-30 14:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CrafterCarpenterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBlue UFImage
---@field ImgGreen UFImage
---@field ImgPointer UFImage
---@field PanelBlue UFCanvasPanel
---@field PanelGreen UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimLeftHide UWidgetAnimation
---@field AnimLeftShowGreen UWidgetAnimation
---@field AnimLeftShowPurple UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPointer UWidgetAnimation
---@field AnimPointerControl UWidgetAnimation
---@field AnimRightHide UWidgetAnimation
---@field AnimRightShowBlue UWidgetAnimation
---@field AnimRightShowPurple UWidgetAnimation
---@field ThrillCurve CurveFloat
---@field SliderMoveTime float
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimPointerStart float
---@field ValueAnimPointerEnd float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterCarpenterItemView = LuaClass(UIView, true)

function CrafterCarpenterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBlue = nil
	--self.ImgGreen = nil
	--self.ImgPointer = nil
	--self.PanelBlue = nil
	--self.PanelGreen = nil
	--self.AnimIn = nil
	--self.AnimLeftHide = nil
	--self.AnimLeftShowGreen = nil
	--self.AnimLeftShowPurple = nil
	--self.AnimOut = nil
	--self.AnimPointer = nil
	--self.AnimPointerControl = nil
	--self.AnimRightHide = nil
	--self.AnimRightShowBlue = nil
	--self.AnimRightShowPurple = nil
	--self.ThrillCurve = nil
	--self.SliderMoveTime = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimPointerStart = nil
	--self.ValueAnimPointerEnd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterCarpenterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterCarpenterItemView:OnInit()

end

function CrafterCarpenterItemView:OnDestroy()

end

function CrafterCarpenterItemView:OnShow()

end

function CrafterCarpenterItemView:PostShowView()
	local Params = self.Params
	if not Params then
		return
	end
	if Params.bIsReconnect then
		local Animation = self:GetAnimIn()
		if nil ~= Animation and self:IsAnimationPlaying(Animation) then
			local EndTime = Animation:GetEndTime()
			self:PlayAnimationTimeRangeToEndTime(Animation, EndTime)
		end
	end
end

function CrafterCarpenterItemView:OnHide()

end

function CrafterCarpenterItemView:OnRegisterUIEvent()

end

function CrafterCarpenterItemView:OnRegisterGameEvent()

end

function CrafterCarpenterItemView:OnRegisterBinder()

end

return CrafterCarpenterItemView