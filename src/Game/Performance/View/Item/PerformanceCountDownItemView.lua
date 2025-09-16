---
--- Author: moodliu
--- DateTime: 2024-01-23 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PerformanceCountDownItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCountDown1 UFImage
---@field ImgCountDown2 UFImage
---@field ImgCountDown3 UFImage
---@field ImgLeft UFImage
---@field ImgRight UFImage
---@field PanelCountDown UFCanvasPanel
---@field TextReady UFTextBlock
---@field TextReady_1 UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceCountDownItemView = LuaClass(UIView, true)

function PerformanceCountDownItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCountDown1 = nil
	--self.ImgCountDown2 = nil
	--self.ImgCountDown3 = nil
	--self.ImgLeft = nil
	--self.ImgRight = nil
	--self.PanelCountDown = nil
	--self.TextReady = nil
	--self.TextReady_1 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceCountDownItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceCountDownItemView:OnInit()

end

function PerformanceCountDownItemView:OnDestroy()

end

function PerformanceCountDownItemView:OnShow()

end

function PerformanceCountDownItemView:StartCountDown()
	self:PlayAnimIn()
end

function PerformanceCountDownItemView:StartCountDownFrom(StartAtTime)
	-- if self:IsAnimationPlaying(self:GetAnimIn()) then
	-- 	local EndTime = self:GetAnimIn():GetEndTime()
	-- 	self:PlayAnimationTimeRange(self:GetAnimIn(), EndTime)
	-- end
	self:StopAllAnimations()
	self:PlayAnimation(self:GetAnimIn(), StartAtTime)
end

function PerformanceCountDownItemView:SetText(Text)
	self.TextReady:SetText(Text)
end

function PerformanceCountDownItemView:SetEndText(Text)
	self.TextReady_1:SetText(Text)
end

function PerformanceCountDownItemView:OnHide()

end

function PerformanceCountDownItemView:OnRegisterUIEvent()

end

function PerformanceCountDownItemView:OnRegisterGameEvent()

end

function PerformanceCountDownItemView:OnRegisterBinder()

end

return PerformanceCountDownItemView