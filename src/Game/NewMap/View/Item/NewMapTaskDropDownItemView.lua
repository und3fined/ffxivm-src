---
--- Author: lydianwang
--- DateTime: 2024-05-30 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ExpandColorHex = "#FFF4D0"
local CollapseColorHex = "#9C9788"

---@class NewMapTaskDropDownItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconClose UFImage
---@field IconExpand UFImage
---@field Title URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMapTaskDropDownItemView = LuaClass(UIView, true)

function NewMapTaskDropDownItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconClose = nil
	--self.IconExpand = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMapTaskDropDownItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewMapTaskDropDownItemView:OnInit()
	self.Binders = {
		{ "IsExpanded", UIBinderSetIsVisible.New(self, self.IconClose) },
		{ "IsExpanded", UIBinderSetIsVisible.New(self, self.IconExpand, true) },
		{ "IsExpanded", UIBinderValueChangedCallback.New(self, nil, self.OnExpandedChanged) },
		{ "QuestTypeName", UIBinderSetText.New(self, self.Title) },
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.Title)},
	}
end

function NewMapTaskDropDownItemView:OnDestroy()

end

function NewMapTaskDropDownItemView:OnShow()

end

function NewMapTaskDropDownItemView:OnHide()

end

function NewMapTaskDropDownItemView:OnRegisterUIEvent()

end

function NewMapTaskDropDownItemView:OnRegisterGameEvent()

end

function NewMapTaskDropDownItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then return end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel

	self:RegisterBinders(self.ViewModel, self.Binders)
end

function NewMapTaskDropDownItemView:OnExpandedChanged(NewValue, OldValue)
	if self.ViewModel then
		self.ViewModel.TextColor = NewValue and ExpandColorHex or CollapseColorHex
	end
end

return NewMapTaskDropDownItemView