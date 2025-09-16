--
-- Author: anypkvcai
-- Date: 2023-12-12 10:27
-- Description:
--


---@class UIBindableObject
---@field Property UIBindableProperty
local UIBindableObject = {}

---Ctor
function UIBindableObject:Ctor()
	self.Property = nil
end

---SetBindableProperty
---@param Property UIBindableProperty
function UIBindableObject:SetBindableProperty(Property)
	self.Property = Property
end

---OnValueChanged
function UIBindableObject:OnValueChanged()
	local Property = self.Property
	if nil ~= Property then
		Property:OnValueChanged(Property:GetValue(), self)
	end
end

return UIBindableObject