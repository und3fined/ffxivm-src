---
--- Author: anypkvcai
--- DateTime: 2021-04-26 16:51
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderUpdateCountDown : UIBinder
local UIBinderUpdateCountDown = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UIAdapterCountDown
function UIBinderUpdateCountDown:Ctor(View, Widget, Interval, IsTimeStamp, IsMillisecond)
	self.Interval = Interval or 1
	self.IsTimeStamp = IsTimeStamp
	self.IsMillisecond = IsMillisecond
end

---OnValueChanged
---@param NewValue ESlateVisibility
---@param OldValue ESlateVisibility
function UIBinderUpdateCountDown:OnValueChanged(NewValue, OldValue)
	local Time = NewValue

	self.Widget:Start(Time, self.Interval, self.IsTimeStamp, self.IsMillisecond)
end

return UIBinderUpdateCountDown