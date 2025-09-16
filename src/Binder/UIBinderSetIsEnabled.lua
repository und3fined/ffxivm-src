--
-- Author: anypkvcai
-- Date: 2020-08-05 15:45:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetIsEnabled : UIBinder
local UIBinderSetIsEnabled = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetIsEnabled:Ctor(View, Widget, IsInverted, IsHitTestVisible)
	self.IsInverted = IsInverted
	self.IsHitTestVisible = IsHitTestVisible
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsEnabled:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if type(NewValue) == "number" then
		NewValue = NewValue ~= 0
	end
	
	local IsEnabled = NewValue
	if self.IsInverted then
		IsEnabled = not IsEnabled
	end

	self.Widget:SetIsEnabled(IsEnabled, self.IsHitTestVisible)
end

return UIBinderSetIsEnabled