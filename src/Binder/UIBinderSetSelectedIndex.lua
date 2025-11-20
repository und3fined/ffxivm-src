---
--- Author: enqingchen
--- DateTime: 2022-01-04
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetSelectedIndex : UIBinder
local UIBinderSetSelectedIndex = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UIAdapterTableView
function UIBinderSetSelectedIndex:Ctor(View, Widget, IsAllowNil, ScrollToSelect)
	self.IsAllowNil = IsAllowNil
	self.ScrollToSelect = ScrollToSelect
end

---OnValueChanged
function UIBinderSetSelectedIndex:OnValueChanged(NewValue, OldValue)
	local NewIndex = NewValue

	if nil ~= NewIndex or self.IsAllowNil then
		self.Widget:SetSelectedIndex(NewIndex)
		if self.ScrollToSelect then
			self.Widget:ScrollToIndex(NewIndex)
		end
	end
end

return UIBinderSetSelectedIndex