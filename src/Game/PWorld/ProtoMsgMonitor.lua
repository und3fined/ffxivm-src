--
-- Author: haialexzhou
-- Date: 2022-04-08
-- Description:网络协议消息监视器
-- 处理网络问题导致协议丢包问题，指定重发次数

local LuaClass = require("Core/LuaClass")

local ProtoMsgMonitor = LuaClass()

function ProtoMsgMonitor:Ctor()
    self.Listener = nil
    self.TimerID = 0
    self.CallbackFunc = nil
    self.CallbackFuncParams = nil
    self.TimeoutCallbackFunc = nil
    self.TimeoutCallbackFuncParams = nil
    self.ExecCountMax = 0
    self.ExecCount = 0
end

function ProtoMsgMonitor:Destroy()
    if (self.TimerID ~= nil and self.TimerID ~= 0) then
		_G.TimerMgr:CancelTimer(self.TimerID)
        self.TimerID = 0
		self:Ctor()
	end
end

function ProtoMsgMonitor:ExecFunction()
    if (self.CallbackFunc) then
       _G.CommonUtil.XPCall(self.Listener, self.CallbackFunc, self.CallbackFuncParams)
        self.ExecCount = self.ExecCount + 1
    end

    if (self.ExecCount >= self.ExecCountMax) then
        if (self.TimeoutCallbackFunc) then
            _G.CommonUtil.XPCall(self.Listener, self.TimeoutCallbackFunc, self.TimeoutCallbackFuncParams)
         end

        self:Destroy()
    end
end

function ProtoMsgMonitor:Register(Listener, Callback, Delay, Interval, ExecCountMax, TimeoutCallback, CallbackParams, TimeoutCallbackParams)
    if (self.TimerID == 0) then
        self.Listener = Listener
        self.CallbackFunc = Callback
        self.CallbackFuncParams = CallbackParams
        self.TimeoutCallbackFunc = TimeoutCallback
        self.TimeoutCallbackFuncParams = TimeoutCallbackParams
        self.ExecCount = 0
        self.ExecCountMax = ExecCountMax
		self.TimerID = _G.TimerMgr:AddTimer(self, self.ExecFunction, Delay, Interval, ExecCountMax)
	end
end

return ProtoMsgMonitor