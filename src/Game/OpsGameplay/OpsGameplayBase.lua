--
-- Author: sammrli
-- Date: 2025-5-28 15:14
-- Description: 活动玩法基类
--

local LuaClass = require("Core/LuaClass")

local GameEventRegister = require("Register/GameEventRegister")
local TimerRegister = require("Register/TimerRegister")

---@class OpsGameplayBase
local OpsGameplayBase = LuaClass()

function OpsGameplayBase:Ctor()
end

function OpsGameplayBase:Init()
    self:OnInit()
end

function OpsGameplayBase:Begin()
    self:OnBegin()
	self:OnRegisterGameEvent()
	self:OnRegisterTimer()
end

function OpsGameplayBase:End()
	if nil ~= self.GameEventRegister then
		self.GameEventRegister:UnRegisterAll()
	end

	if nil ~= self.TimerRegister then
		self.TimerRegister:UnRegisterAll()
	end
    self:OnEnd()
end

-- ==================================================
-- 子类接口
-- ==================================================

function OpsGameplayBase:OnInit()
end

function OpsGameplayBase:OnBegin()
end

function OpsGameplayBase:OnEnd()
end

function OpsGameplayBase:OnRegisterGameEvent()
end

function OpsGameplayBase:OnRegisterTimer()
end

function OpsGameplayBase:RegisterGameEvent(EventID, Callback)
	local Register = self.GameEventRegister
	if nil == Register then
		Register = GameEventRegister.New()
		self.GameEventRegister = Register
	end

	if nil ~= Register then
		Register:Register(EventID, self, Callback)
	end
end

function OpsGameplayBase:UnRegisterGameEvent(EventID, Callback)
	if nil ~= self.GameEventRegister then
		self.GameEventRegister:UnRegister(EventID, self, Callback)
	end
end

function OpsGameplayBase:RegisterTimer(Callback, Delay, Interval, LoopNumber, Params)
	local Register = self.TimerRegister
	if nil == Register then
		Register = TimerRegister.New()
		self.TimerRegister = Register
	end

	if nil ~= Register then
		return Register:Register(self, Callback, Delay, Interval, LoopNumber, Params)
	end
end

function OpsGameplayBase:UnRegisterTimer(TimerID)
	if nil ~= self.TimerRegister then
		self.TimerRegister:UnRegister(TimerID)
	end
end

return OpsGameplayBase