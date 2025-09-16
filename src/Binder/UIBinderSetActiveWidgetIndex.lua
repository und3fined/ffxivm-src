---
--- Author: anypkvcai
--- DateTime: 2021-02-08 11:19
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetActiveWidgetIndex : UIBinder
local UIBinderSetActiveWidgetIndex = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UWidgetSwitcher
function UIBinderSetActiveWidgetIndex:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetActiveWidgetIndex:OnValueChanged(NewValue, OldValue)
	if type(NewValue) ~= "number" then
		NewValue = NewValue and 1 or 0
	end

	local Index = NewValue

	self.Widget:SetActiveWidgetIndex(Index)
end

return UIBinderSetActiveWidgetIndex