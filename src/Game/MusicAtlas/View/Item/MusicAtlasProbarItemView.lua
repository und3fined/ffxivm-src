---
--- Author: xingcaicao
--- DateTime: 2023-03-21 10:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MusicAtlasProbarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProgressBar UProgressBar
---@field Slider USlider
---@field SliderLine USlider
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicAtlasProbarItemView = LuaClass(UIView, true)

function MusicAtlasProbarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProgressBar = nil
	--self.Slider = nil
	--self.SliderLine = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicAtlasProbarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicAtlasProbarItemView:OnInit()
	self.CaptureEndCallBack = nil
end

function MusicAtlasProbarItemView:OnDestroy()

end

function MusicAtlasProbarItemView:OnShow()
	self.LastValue = nil
end

function MusicAtlasProbarItemView:OnHide()

end

function MusicAtlasProbarItemView:OnRegisterUIEvent()
	UIUtil.AddOnMouseCaptureBeginEvent(self, self.Slider, self.OnSliderMouseCaptureBegin)
	UIUtil.AddOnValueChangedEvent(self, self.Slider, self.OnValueChangedSlider)
	UIUtil.AddOnMouseCaptureEndEvent(self, self.Slider, self.OnSliderMouseCaptureEnd)

end

function MusicAtlasProbarItemView:OnRegisterGameEvent()

end

function MusicAtlasProbarItemView:OnRegisterBinder()

end

function MusicAtlasProbarItemView:OnValueChangedSlider(_, Value)
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
function MusicAtlasProbarItemView:OnSliderMouseCaptureBegin()
	if self.CaptureBeginCallBack ~= nil then
		self.CaptureBeginCallBack()
	end
end

---拖动松手回调
function MusicAtlasProbarItemView:OnSliderMouseCaptureEnd()
	if self.CaptureEndCallBack ~= nil then
		self.CaptureEndCallBack()
	end
end

---设置滑动条值
---@param Value float 0-1
function MusicAtlasProbarItemView:SetValue(Value)
	self.LastValue = Value
	self.ProgressBar:SetPercent(Value)
	self.Slider:SetValue(Value)
end

function MusicAtlasProbarItemView:SetSliderLineVisiable(Value, TotalTime)
	--UIUtil.SetIsVisible(self.SliderLine, Value)
	if Value then
		--需配置
		local CurTime = 30
		local CurTotalTime = TotalTime
		local NewValue = CurTime / CurTotalTime
		--self:SetSliderLineValue(NewValue)
	end
end

function MusicAtlasProbarItemView:SetSliderLineValue(Value)
	self.SliderLine:SetValue(Value)
end

function MusicAtlasProbarItemView:SetValueChangedCallback( func )
	self.ValueChangedCallback = func 
end

function MusicAtlasProbarItemView:SetCaptureBeginCallBack( func )
	self.CaptureBeginCallBack = func 
end

function MusicAtlasProbarItemView:SetCaptureEndCallBack( func )
	self.CaptureEndCallBack = func 
end

function MusicAtlasProbarItemView:SetSliderClickVisible( Value )
	UIUtil.SetIsVisible(self.Slider, true, Value)
end

return MusicAtlasProbarItemView