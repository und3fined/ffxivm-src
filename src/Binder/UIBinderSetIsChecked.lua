--
-- Author: anypkvcai
-- Date: 2020-08-05 15:45:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetIsChecked : UIBinder
local UIBinderSetIsChecked = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UToggleButton | CommCheckBoxView | CommSingleBoxView
function UIBinderSetIsChecked:Ctor(View, Widget, IsBroadcasting, IsInverted)
	self.IsBroadcasting = IsBroadcasting
	self.IsInverted = IsInverted
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsChecked:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if type(NewValue) == "number" then
		NewValue = NewValue ~= 0
	end

	local IsChecked = NewValue

	if self.IsInverted then
		IsChecked = not IsChecked
	end

	self.Widget:SetChecked(IsChecked, self.IsBroadcasting)
end

return UIBinderSetIsChecked