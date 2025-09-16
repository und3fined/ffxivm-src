--
-- Author: anypkvcai
-- Date: 2020-08-05 15:45:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetBrushTintColor : UIBinder
local UIBinderSetBrushTintColor = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetBrushTintColor:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue FSlateColor
---@param OldValue FSlateColor
function UIBinderSetBrushTintColor:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local SlateColor = NewValue

	self.Widget:SetBrushTintColor(SlateColor)
end

return UIBinderSetBrushTintColor