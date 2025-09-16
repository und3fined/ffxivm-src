---
--- Author: anypkvcai
--- DateTime: 2021-02-08 11:19
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetActiveWidgetIndexBool : UIBinder
---@deprecated @建议用UIBinderSetActiveWidgetIndex
local UIBinderSetActiveWidgetIndexBool = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UWidgetSwitcher
function UIBinderSetActiveWidgetIndexBool:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetActiveWidgetIndexBool:OnValueChanged(NewValue, OldValue)
	local Index = NewValue and 1 or 0

	self.Widget:SetActiveWidgetIndex(Index)
end

return UIBinderSetActiveWidgetIndexBool