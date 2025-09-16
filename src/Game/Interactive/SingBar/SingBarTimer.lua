---
--- Author: sammrli
--- DateTime: 2023-05-23 20:56
--- Description:定时器组
---

local LuaClass = require("Core/LuaClass")

local TimerMgr = _G.TimerMgr

----@class SingBarTimer
local SingBarTimer = LuaClass()

function SingBarTimer:Ctor()
    self.TimerList = {}
    self.DoneNum = 0
end

function SingBarTimer:AddTimer(Function, Delay)
    if Function == nil then
        return
    end
    if not Delay or Delay <= 0 then
        Function()
    else
        local Callback = function()
            Function()
            self:OnTimerOver()
        end
        local TimerID = TimerMgr:AddTimer(self, Callback, Delay)
        table.insert(self.TimerList, TimerID)
    end
end

function SingBarTimer:Clear()
    for i=1,#self.TimerList do
        TimerMgr:CancelTimer(self.TimerList[i])
    end
    self.TimerList = {}
end

function SingBarTimer:OnTimerOver()
    self.DoneNum = self.DoneNum + 1
    if self.DoneNum >= #self.TimerList then
        self:Clear()
    end
end

return SingBarTimer