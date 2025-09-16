---
--- Author: xingcaicao
--- DateTime: 2023-03-21 10:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommSliderHorizontalView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProgressBar UProgressBar
---@field Slider USlider
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSliderHorizontalView = LuaClass(UIView, true)

function CommSliderHorizontalView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProgressBar = nil
	--self.Slider = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSliderHorizontalView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSliderHorizontalView:OnInit()
	self.CaptureEndCallBack = nil
end

function CommSliderHorizontalView:OnDestroy()

end

function CommSliderHorizontalView:OnShow()
	self.LastValue = nil
end

function CommSliderHorizontalView:OnHide()

end

function CommSliderHorizontalView:OnRegisterUIEvent()
	UIUtil.AddOnMouseCaptureBeginEvent(self, self.Slider, self.OnSliderMouseCaptureBegin)
	UIUtil.AddOnValueChangedEvent(self, self.Slider, self.OnValueChangedSlider)
	UIUtil.AddOnMouseCaptureEndEvent(self, self.Slider, self.OnSliderMouseCaptureEnd)

end

function CommSliderHorizontalView:OnRegisterGameEvent()

end

function CommSliderHorizontalView:OnRegisterBinder()

end

function CommSliderHorizontalView:OnValueChangedSlider(_, Value)
	if Value == self.LastValue then  -- 用于解决超出滑动区域后，仍然会触发函数值变化
		return
	end

	self.LastValue = Value

	self.ProgressBar:SetPercent(Value)

	if self.ValueChangedCallback ~= nil then
		self.ValueChangedCallback(Value)
	end
end

---按下
function CommSliderHorizontalView:OnSliderMouseCaptureBegin()
	if self.CaptureBeginCallBack ~= nil then
		self.CaptureBeginCallBack()
	end
end

---拖动松手回调
function CommSliderHorizontalView:OnSliderMouseCaptureEnd()
	if self.CaptureEndCallBack ~= nil then
		self.CaptureEndCallBack()
	end
end

---设置滑动条值
---@param Value float 0-1
function CommSliderHorizontalView:SetValue(Value)
	self.LastValue = Value
	self.ProgressBar:SetPercent(Value)
	self.Slider:SetValue(Value)
end

function CommSliderHorizontalView:GetValue()
	return self.LastValue or self.Slider:GetValue()
end

function CommSliderHorizontalView:SetValueChangedCallback( func )
	self.ValueChangedCallback = func 
end

function CommSliderHorizontalView:SetCaptureBeginCallBack( func )
	self.CaptureBeginCallBack = func 
end

function CommSliderHorizontalView:SetCaptureEndCallBack( func )
	self.CaptureEndCallBack = func 
end

function CommSliderHorizontalView:SetSliderClickVisible(Value)
	UIUtil.SetIsVisible(self.Slider, true, Value)
end

return CommSliderHorizontalView