--
-- Author: anypkvcai
-- Date: 2020-08-11 18:33:06
-- Description:
--

local LuaClass = require("Core/LuaClass")
local EventMgr = require("Event/EventMgr")
local RegisterUtil = require("Register/RegisterUtil")

local FLOG_ERROR
local FLOG_WARNING

---@class GameEventRegister
local GameEventRegister = LuaClass()

function GameEventRegister:Ctor()
	FLOG_ERROR = _G.FLOG_ERROR
	FLOG_WARNING = _G.FLOG_WARNING
	self.Registers = {}
end

function GameEventRegister:Register(EventID, Listener, Delegate)
	if nil == EventID then
		FLOG_ERROR("GameEventRegister:Register EventID is nil!")
		FLOG_WARNING(debug.traceback())
		return
	end

	if nil == Delegate then
		FLOG_ERROR("GameEventRegister:Register Callback is nil!")
		FLOG_WARNING(debug.traceback())
		return
	end

	local Registers = self.Registers

	for i = 1, #Registers do
		local v = Registers[i]
		if v.EventID == EventID and Delegate == v.Delegate then
			FLOG_ERROR("GameEventRegister:Repeat Register GameEvent ID:%d", EventID)
			return
		end
	end

	table.insert(self.Registers, { EventID = EventID, Listener = Listener, Delegate = Delegate })

	EventMgr:RegisterEvent(EventID, Listener, Delegate, RegisterUtil.GetListenerName(Listener))
end

function GameEventRegister:UnRegister(EventID, Listener, Delegate)
	if not EventID or not Delegate then
		return
	end

	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		if v.EventID == EventID and Delegate == v.Delegate then
			EventMgr:UnRegisterEvent(EventID, Listener, Delegate)
			table.remove(self.Registers, i)
			return
		end
	end
end

function GameEventRegister:UnRegisterAll()
	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		EventMgr:UnRegisterEvent(v.EventID, v.Listener, v.Delegate)
	end

	table.clear(self.Registers)
end

return GameEventRegister