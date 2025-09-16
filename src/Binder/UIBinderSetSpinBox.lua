local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

local UIBinderSetSpinBox = LuaClass(UIBinder)

---Ctor
---@param View UUserWidget
---@param Widget USpinBox
function UIBinderSetSpinBox:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetSpinBox:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Percent = NewValue

	self.Widget:SetValue(Percent)
end

return UIBinderSetSpinBox