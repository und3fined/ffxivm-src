--
-- Author: anypkvcai
-- Date: 2020-08-05 15:45:51
-- Description: 一般建议用UIBinderSetIsChecked 只用bool值更简单
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetCheckedState : UIBinder
local UIBinderSetCheckedState = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UToggleButton
function UIBinderSetCheckedState:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue EToggleButtonState
---@param OldValue EToggleButtonState
function UIBinderSetCheckedState:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	-- _G.UE.EToggleButtonState.Unchecked
	-- _G.UE.EToggleButtonState.Checked
	-- _G.UE.EToggleButtonState.Locked
	-- _G.UE.EToggleButtonState.Other


	local ButtonState = NewValue

	self.Widget:SetCheckedState(ButtonState)
end

return UIBinderSetCheckedState