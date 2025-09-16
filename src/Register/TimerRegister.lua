--
-- Author: anypkvcai
-- Date: 2020-08-11 18:26:42
-- Description:
--

local LuaClass = require("Core/LuaClass")
local RegisterUtil = require("Register/RegisterUtil")

---@class TimerRegister
local TimerRegister = LuaClass()

function TimerRegister:Ctor()
	self.Registers = {}
end

---Register
---@param Listener table| nil   @如果回调函数是类成员函数 Listener为self 其他情况为nil
---@param Callback function     @Callback function
---@param Delay number           @Delay time
---@param Interval number        @Timer interval 执行一次回调间隔的时间
---@param LoopNumber number      @循环次数 默认执行1次 >0时为最多执行次数 <=0时一直执行
---@param Params any          @会在Callback函数里传递回去
---@return number               @TimerID
function TimerRegister:Register(Listener, Callback, Delay, Interval, LoopNumber, Params)
	local ListenerName = RegisterUtil.GetListenerName(Listener)
	local TimerID = _G.TimerMgr:AddTimer(Listener, Callback, Delay, Interval, LoopNumber, Params, ListenerName, self)
	table.insert(self.Registers, TimerID)
	return TimerID
end

---UnRegister
---@param TimerID table         @TimerID
function TimerRegister:UnRegister(TimerID)
	table.remove_item(self.Registers, TimerID)
	_G.TimerMgr:CancelTimer(TimerID)
end

function TimerRegister:UnRegisterAll()
	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		_G.TimerMgr:CancelTimer(v)
	end

	table.clear(self.Registers)
end

---RemoveTimer
---@param TimerID table         @TimerID
function TimerRegister:RemoveTimer(TimerID)
	table.remove_item(self.Registers, TimerID)
end

return TimerRegister