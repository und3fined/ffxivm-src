local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

local UIBinderSetSliderMax = LuaClass(UIBinder)

---Ctor
---@param View UUserWidget
---@param Widget USlider
function UIBinderSetSliderMax:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetSliderMax:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Percent = NewValue

	self.Widget:SetMaxValue(Percent)
end

return UIBinderSetSliderMax