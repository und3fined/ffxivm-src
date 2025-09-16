local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetIsDisabledState : UIBinder
local UIBinderSetIsDisabledState = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetIsDisabledState:Ctor(View, Widget, IsInverted, IsHitTestVisible)
	self.IsInverted = IsInverted
	self.IsHitTestVisible = IsHitTestVisible
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsDisabledState:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	if type(NewValue) == "number" then
		NewValue = NewValue ~= 0
	end
	
	local bDisabledState = NewValue
	if self.IsInverted then
		bDisabledState = not bDisabledState
	end

	self.Widget:SetIsDisabledState(bDisabledState, self.IsHitTestVisible)
end

return UIBinderSetIsDisabledState