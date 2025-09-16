--
-- Author: anypkvcai
-- Date: 2022-10-24 16:31
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetRenderTransformAngle : UIBinder
local UIBinderSetRenderTransformAngle = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetRenderTransformAngle:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetRenderTransformAngle:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Angle = NewValue
	self.Widget:SetRenderTransformAngle(Angle)
end

return UIBinderSetRenderTransformAngle