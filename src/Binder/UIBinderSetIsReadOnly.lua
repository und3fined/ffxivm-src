local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetIsReadOnly : UIBinder
local UIBinderSetIsReadOnly = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetIsReadOnly:Ctor(View, Widget, IsInverted)
	self.IsInverted = IsInverted
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsReadOnly:OnValueChanged(NewValue, OldValue)
	if self.IsInverted then
		NewValue = not NewValue
	end
	if nil ~= self.Widget and nil ~= NewValue then
		self.Widget:SetIsReadOnly(NewValue)
		return
	end
end

return UIBinderSetIsReadOnly