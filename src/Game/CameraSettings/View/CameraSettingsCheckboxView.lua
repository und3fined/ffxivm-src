---
--- Author: zimuyi
--- DateTime: 2023-08-22 11:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CameraSettingsCheckboxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBoxValue UCheckBox
---@field TextTitle UFTextBlock
---@field Title string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CameraSettingsCheckboxView = LuaClass(UIView, true)

function CameraSettingsCheckboxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBoxValue = nil
	--self.TextTitle = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CameraSettingsCheckboxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CameraSettingsCheckboxView:OnInit()
	self.Binders =
	{
		{ "bIsChecked", UIBinderValueChangedCallback.New(self, nil, self.OnIsCheckedChanged) },
		{ "PropName", UIBinderSetText.New(self, self.TextTitle) },
	}
end

function CameraSettingsCheckboxView:OnDestroy()

end

function CameraSettingsCheckboxView:OnShow()
end

function CameraSettingsCheckboxView:OnHide()

end

function CameraSettingsCheckboxView:OnRegisterUIEvent()
	UIUtil.AddOnCheckStateChangedEvent(self, self.CheckBoxValue, self.OnValueChanged)
end

function CameraSettingsCheckboxView:OnRegisterGameEvent()

end

function CameraSettingsCheckboxView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	self.ViewModel = self.Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CameraSettingsCheckboxView:OnValueChanged(_, bIsChecked)
	self.ViewModel.bIsChecked = bIsChecked
end

function CameraSettingsCheckboxView:OnIsCheckedChanged(NewValue)
	self.CheckBoxValue:SetIsChecked(NewValue)
	_G.EventMgr:SendEvent(_G.EventID.CameraSettingsUpdate, {Group = self.ViewModel.GroupKey, Property = self.ViewModel.PropKey, Value = NewValue})
end

return CameraSettingsCheckboxView