--
-- Author: anypkvcai
-- Date: 2020-08-14 14:34:52
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetLineHeightPercentage : UIBinder
local UIBinderSetLineHeightPercentage = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetLineHeightPercentage:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetLineHeightPercentage:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local Value = NewValue

	self.Widget:SetLineHeightPercentage(Value)
end

return UIBinderSetLineHeightPercentage