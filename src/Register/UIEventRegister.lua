--
-- Author: anypkvcai
-- Date: 2020-08-11 18:33:22
-- Description:
--

local LuaClass = require("Core/LuaClass")
local CommonUtil = require("Utils/CommonUtil")

local FLOG_ERROR
local FLOG_WARNING

---@class UIEventRegister
---@field Registers table<number,table>
local UIEventRegister = LuaClass()

function UIEventRegister:Ctor()
	FLOG_ERROR = _G.FLOG_ERROR
	FLOG_WARNING = _G.FLOG_WARNING
	self.Registers = {}
end

---Register
---@param Listener table
---@param Callback function
---@param EventName string
---@param Widget UWidget
---@param Params any
function UIEventRegister:Register(Listener, Callback, EventName, Widget, Params)
	if nil == Listener then
		FLOG_ERROR("UIEventRegister:Register Listener is nil")
		FLOG_WARNING(debug.traceback())
		return
	end

	if nil == Callback then
		FLOG_ERROR("UIEventRegister:Register Callback is nil")
		FLOG_WARNING(debug.traceback())
		return
	end

	if nil == Widget then
		FLOG_ERROR("UIEventRegister:Register Widget is nil")
		FLOG_WARNING(debug.traceback())
		return
	end

	local Registers = self.Registers

	local Callbacks = Widget[EventName]
	if nil == Callbacks then
		FLOG_ERROR("UIEventRegister:Register can't find EventName=%s", EventName)
		FLOG_WARNING(debug.traceback())
		return
	end

	if nil ~= Params then
		Callbacks:Add(Listener.Object, function(...)
			Callback(Listener, Params, ...)
		end)
	else
		Callbacks:Add(Listener.Object, function(...)

    -- UI录制记录键盘输入数据
    if _G.LevelRecordMgr ~= nil and _G.LevelRecordMgr:InRecording() then
		local Param1, Param2, Param3 = ...
		local eventType = 0
		if EventName == "OnTextCommitted" then
			eventType = 3
	    end

		if EventName == "OnTextChanged" then
			eventType = 4
	    end
		if eventType > 0 then
			_G.LevelRecordMgr:SaveWidget(Widget,Param2,eventType)
		end
    end
			Callback(Listener, ...)
		end)
	end

	table.insert(Registers, { Listener = Listener, Widget = Widget, EventName = EventName, Callback = Callback, Callbacks = Callbacks })
end

---UnRegisterAll
function UIEventRegister:UnRegisterAll()
	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		v.Callbacks:Clear()
	end

	table.clear(self.Registers)
end

---TriggerEvent @触发控件事件，目前只是给新手引导使用
---@param Widget UWidget
---@param EventName string
---@param Params any
function UIEventRegister:TriggerEvent(Widget, EventName, Params, ...)
	local Registers = self.Registers

	for i = 1, #Registers do
		local v = Registers[i]
		if v.Widget == Widget and v.EventName == EventName then
			CommonUtil.XPCall(v.Listener, v.Callback, Params, ...)
		end
	end
end

return UIEventRegister