---
--- Author: zimuyi
--- DateTime: 2023-08-22 11:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderSetSliderMin = require("Binder/UIBinderSetSliderMin")
local UIBinderSetSliderMax = require("Binder/UIBinderSetSliderMax")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CameraSettingsDefine = require("Game/CameraSettings/CameraSettingsDefine")

---@class CameraSettingsSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EditableTextValue UFGMEditableText
---@field SliderValue USlider
---@field TextTitle UFTextBlock
---@field MinValue float
---@field MaxValue float
---@field Title string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CameraSettingsSliderView = LuaClass(UIView, true)

function CameraSettingsSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EditableTextValue = nil
	--self.SliderValue = nil
	--self.TextTitle = nil
	--self.MinValue = nil
	--self.MaxValue = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CameraSettingsSliderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CameraSettingsSliderView:OnInit()
end

function CameraSettingsSliderView:OnDestroy()

end

function CameraSettingsSliderView:OnShow()
end

function CameraSettingsSliderView:OnHide()

end

function CameraSettingsSliderView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.SliderValue, self.OnSliderValueChanged)
	UIUtil.AddOnTextCommittedEvent(self, self.EditableTextValue, self.OnEditableTextChanged)
end

function CameraSettingsSliderView:OnRegisterGameEvent()

end

function CameraSettingsSliderView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	self.ViewModel = self.Params.Data

	if nil == self.Binders then
		self.NumberFormat = "%.2f"
		if nil ~= self.ViewModel.NumberType and self.ViewModel.NumberType == CameraSettingsDefine.NumberType.Integer then
			self.bIsInteger = true
			self.NumberFormat = "%d"
		end

		self.Binders =
		{
			{ "PropName", UIBinderSetText.New(self, self.TextTitle) },
			{ "CurrentValue", UIBinderSetTextFormat.New(self, self.EditableTextValue, self.NumberFormat) },
			{ "CurrentValue", UIBinderSetSlider.New(self, self.SliderValue) },
			{ "CurrentValue", UIBinderValueChangedCallback.New(self, nil, self.OnCurrentValueChanged) },
			{ "MinValue", UIBinderSetSliderMin.New(self, self.SliderValue) },
			{ "MaxValue", UIBinderSetSliderMax.New(self, self.SliderValue) },
		}
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CameraSettingsSliderView:OnSliderValueChanged()
	local NewValue = self.SliderValue:GetValue()
	if self.bIsInteger then
		NewValue = math.floor(NewValue)
	end

	self.ViewModel.CurrentValue = NewValue
end

function CameraSettingsSliderView:OnEditableTextChanged()
	local NewValue = tonumber(self.EditableTextValue.Text)
	if nil == NewValue then
		self.EditableTextValue:SetText(string.format(self.NumberFormat, self.ViewModel.CurrentValue))
		return
	end
	if self.bIsInteger then
		NewValue = math.floor(NewValue)
	end
	if NewValue <= self.ViewModel.MaxValue and NewValue >= self.ViewModel.MinValue then
		self.ViewModel.CurrentValue = NewValue
	else
		self.EditableTextValue:SetText(string.format(self.NumberFormat, self.ViewModel.CurrentValue))
	end
end

function CameraSettingsSliderView:OnCurrentValueChanged(NewValue)
	_G.EventMgr:SendEvent(_G.EventID.CameraSettingsUpdate, {Group = self.ViewModel.GroupKey, Property = self.ViewModel.PropKey, Value = NewValue})
end

return CameraSettingsSliderView