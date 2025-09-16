--
-- Author: anypkvcai
-- Date: 2020-08-06 10:27:07
-- Description:
--

local GameNetMsgRegister
local GameEventRegister
local TimerRegister

---@class MgrBase
local MgrBase = {}

function MgrBase:Ctor()
	self.MgrID = nil
end

function MgrBase:Init()
	self:OnInit()
end

function MgrBase:Begin()
	GameNetMsgRegister = require("Register/GameNetMsgRegister")
	GameEventRegister = require("Register/GameEventRegister")
	TimerRegister = require("Register/TimerRegister")

	self:OnBegin()
	self:OnRegisterNetMsg()
	self:OnRegisterGameEvent()
	self:OnRegisterTimer()
end

function MgrBase:End()
	if nil ~= self.GameNetMsgRegister then
		self.GameNetMsgRegister:UnRegisterAll()
	end

	if nil ~= self.GameEventRegister then
		self.GameEventRegister:UnRegisterAll()
	end

	if nil ~= self.TimerRegister then
		self.TimerRegister:UnRegisterAll()
	end

	self:OnEnd()
end

function MgrBase:Shutdown()
	self:OnShutdown()
end

function MgrBase:OnInit()

end

function MgrBase:OnBegin()

end

function MgrBase:OnEnd()

end

function MgrBase:OnShutdown()

end

function MgrBase:OnRegisterNetMsg()

end

function MgrBase:OnRegisterGameEvent()

end

function MgrBase:OnRegisterTimer()

end

---RegisterGameNetMsg
---@param MsgID number          @ProtoCS.CS_CMD
---@param SubMsgID number
---@param Callback function     @Callback function
function MgrBase:RegisterGameNetMsg(MsgID, SubMsgID, Callback)
	local Register = self.GameNetMsgRegister
	if nil == Register then
		Register = GameNetMsgRegister.New()
		self.GameNetMsgRegister = Register
	end

	if nil ~= Register then
		Register:Register(MsgID, SubMsgID, self, Callback)
	end
end

---UnRegisterGameNetMsg
---@param MsgID number          @ProtoCS.CS_CMD
---@param SubMsgID number
function MgrBase:UnRegisterGameNetMsg(MsgID, SubMsgID, Callback)
	if nil ~= self.GameNetMsgRegister then
		self.GameNetMsgRegister:UnRegister(MsgID, SubMsgID, self, Callback)
	end
end

---UnRegisterAllGameNetMsg
function MgrBase:UnRegisterAllGameNetMsg()
	if nil ~= self.GameNetMsgRegister then
		self.GameNetMsgRegister:UnRegisterAll()
	end
end

---RegisterGameEvent
---@param EventID number        @EventID
---@param Callback function     @Callback function
function MgrBase:RegisterGameEvent(EventID, Callback)
	local Register = self.GameEventRegister
	if nil == Register then
		Register = GameEventRegister.New()
		self.GameEventRegister = Register
	end

	if nil ~= Register then
		Register:Register(EventID, self, Callback)
	end
end

---UnRegisterGameEvent  一般不用主动掉，会在End的时候自动反注册所有的； 需要动态反注册的时候才用得着，如同Timer
---@param EventID number        @EventID
---@param Callback function     @Callback function
function MgrBase:UnRegisterGameEvent(EventID, Callback)
	if nil ~= self.GameEventRegister then
		self.GameEventRegister:UnRegister(EventID, self, Callback)
	end
end

---RegisterTimer
---@param Callback function     @Callback function
---@param Delay number          @Delay time
---@param Interval number       @Timer interval 执行一次回调间隔的时间
---@param LoopNumber number     @循环次数 默认执行1次 >0时为最多执行次数 <=0时一直执行
---@param Params any         	@会在Callback函数里传递回去
---@return number               @TimerID
function MgrBase:RegisterTimer(Callback, Delay, Interval, LoopNumber, Params)
	local Register = self.TimerRegister
	if nil == Register then
		Register = TimerRegister.New()
		self.TimerRegister = Register
	end

	if nil ~= Register then
		return Register:Register(self, Callback, Delay, Interval, LoopNumber, Params)
	end
end

---UnRegisterTimer
---@param TimerID number        @TimerID
function MgrBase:UnRegisterTimer(TimerID)
	if nil ~= self.TimerRegister then
		self.TimerRegister:UnRegister(TimerID)
	end
end

---UnRegisterAllTimer
function MgrBase:UnRegisterAllTimer()
	if nil ~= self.TimerRegister then
		self.TimerRegister:UnRegisterAll()
	end
end

function MgrBase:SetName(Name)
	rawset(self, "Name", Name)
end

function MgrBase:GetName()
	return rawget(self, "Name")
end

return MgrBase