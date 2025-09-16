--
-- Author: anypkvcai
-- Date: 2023-03-30 20:20
-- Description:
--

local LuaClass = require("Core/LuaClass")
local CommonUtil = require("Utils/CommonUtil")

---@class WidgetCallback
local WidgetCallback = LuaClass()

function WidgetCallback:Ctor()
	self.Callbacks = {}
end

---Add
---@param Callback function
function WidgetCallback:Add(_, Callback)
	if nil == Callback then
		_G.FLOG_ERROR("WidgetCallback:Add Callback is nil")
		_G.FLOG_WARNING(debug.traceback())
		return
	end
	table.insert(self.Callbacks, Callback)
end

---OnTriggered
function WidgetCallback:OnTriggered(...)
	for i = 1, #self.Callbacks do
		local Callback = self.Callbacks[i]
		CommonUtil.XPCall(nil, Callback, ...)
	end
end

---Clear
function WidgetCallback:Clear()
	self.Callbacks = {}
end

return WidgetCallback