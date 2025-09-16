---
--- Author: moodliu
--- DateTime: 2024-05-11 16:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PerformanceFinishPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg1 UFImage
---@field ImgBg2 UFImage
---@field ImgBg3 UFImage
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceFinishPageView = LuaClass(UIView, true)

function PerformanceFinishPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg1 = nil
	--self.ImgBg2 = nil
	--self.ImgBg3 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceFinishPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceFinishPageView:OnInit()

end

function PerformanceFinishPageView:OnDestroy()

end

function PerformanceFinishPageView:OnShow()

end

function PerformanceFinishPageView:OnHide()

end

function PerformanceFinishPageView:OnRegisterUIEvent()

end

function PerformanceFinishPageView:OnRegisterGameEvent()

end

function PerformanceFinishPageView:OnRegisterBinder()

end

function PerformanceFinishPageView:GetAnimationTime()
	return self.AnimIn:GetEndTime()
end

function PerformanceFinishPageView:SetTextTitle(Name)
	self.TextTitle:SetText(Name or "")
end

return PerformanceFinishPageView