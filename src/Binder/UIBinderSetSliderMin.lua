local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

local UIBinderSetSliderMin = LuaClass(UIBinder)

---Ctor
---@param View UUserWidget
---@param Widget USlider
function UIBinderSetSliderMin:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetSliderMin:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Percent = NewValue

	self.Widget:SetMinValue(Percent)
end

return UIBinderSetSliderMin