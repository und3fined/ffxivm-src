--
-- Author: anypkvcai
-- Date: 2020-08-14 14:22:49
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetColorAndOpacity : UIBinder
local UIBinderSetColorAndOpacity = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UWidget
function UIBinderSetColorAndOpacity:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue FLinearColor
---@param OldValue FLinearColor
function UIBinderSetColorAndOpacity:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if nil == NewValue then
		return
	end

	local LinearColor = NewValue

	self.Widget:SetColorAndOpacity(LinearColor)
end

return UIBinderSetColorAndOpacity