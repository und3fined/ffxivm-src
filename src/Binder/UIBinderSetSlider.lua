local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

local UIBinderSetSlider = LuaClass(UIBinder)

---Ctor
---@param View UUserWidget
---@param Widget USlider
function UIBinderSetSlider:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetSlider:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Percent = NewValue

	self.Widget:SetValue(Percent)
end

return UIBinderSetSlider