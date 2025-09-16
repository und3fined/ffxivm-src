---
--- Author: Administrator
--- DateTime: 2023-12-22 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local EventMgr = _G.EventMgr
---@class CompanionArchiveFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanionArchiveFilterItemView = LuaClass(UIView, true)

function CompanionArchiveFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanionArchiveFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionArchiveFilterItemView:OnInit()
	self.Binders = {
		{ "Title", UIBinderValueChangedCallback.New(self, nil, self.OnTitleChange) },
		{ "IsSelect", UIBinderSetIsChecked.New(self, self.CheckBox, true) },
	}
end

function CompanionArchiveFilterItemView:OnDestroy()

end

function CompanionArchiveFilterItemView:OnShow()

end

function CompanionArchiveFilterItemView:OnHide()

end

function CompanionArchiveFilterItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox, self.OnCheckBoxClicked)
end

function CompanionArchiveFilterItemView:OnRegisterGameEvent()

end

function CompanionArchiveFilterItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function CompanionArchiveFilterItemView:OnTitleChange(NewValue, OldValue)
	if NewValue == nil and OldValue == nil then return end
	self.CheckBox:SetText(NewValue)
end

function CompanionArchiveFilterItemView:OnCheckBoxClicked(ToggleButton, ButtonState)
	local IsCheck = UIUtil.IsToggleButtonChecked(ButtonState)

	self.ViewModel.IsSelect = IsCheck
	EventMgr:SendEvent(EventID.CompanionArchiveFilterUpdate, IsCheck, self.ViewModel.Type, self.ViewModel.Value)
end

return CompanionArchiveFilterItemView