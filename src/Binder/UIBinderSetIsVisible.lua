--
-- Author: anypkvcai
-- Date: 2020-08-14 14:49:31
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetIsVisible : UIBinder
local UIBinderSetIsVisible = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
---@param IsInverted boolean
---@param IsHitTestVisible boolean
function UIBinderSetIsVisible:Ctor(View, Widget, IsInverted, IsHitTestVisible, IsHidden)
	self.IsInverted = IsInverted
	self.IsHitTestVisible = IsHitTestVisible
	self.IsHidden = IsHidden
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsVisible:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if type(NewValue) == "number" then
		NewValue = NewValue ~= 0
	end

	local IsVisible = NewValue
	if self.IsInverted then
		IsVisible = not IsVisible
	end

	UIUtil.SetIsVisible(self.Widget, IsVisible, self.IsHitTestVisible, self.IsHidden)
end

return UIBinderSetIsVisible