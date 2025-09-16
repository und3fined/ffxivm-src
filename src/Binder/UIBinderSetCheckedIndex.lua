---
--- Author: anypkvcai
--- DateTime: 2021-08-24 16:04
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderSetCheckedIndex : UIBinder
local UIBinderSetCheckedIndex = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UToggleGroup
---@param IsStartFromZero boolean @索引是否从0开始 Lua默认是1开始传递到C++需要减1
---@param IsBroadcasting boolean @是否广播回调
function UIBinderSetCheckedIndex:Ctor(View, Widget, IsStartFromZero, IsBroadcasting)
	self.IsStartFromZero = IsStartFromZero
	self.IsBroadcasting = IsBroadcasting
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetCheckedIndex:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local CheckedIndex = self.IsStartFromZero and NewValue or NewValue - 1

	if CheckedIndex == self.Widget:GetCheckedIndex() then
		return
	end

	self.Widget:SetCheckedIndex(CheckedIndex, self.IsBroadcasting)
end

return UIBinderSetCheckedIndex