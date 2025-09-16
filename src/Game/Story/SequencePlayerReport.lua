---
--- Author: sammrli
--- DateTime: 2024-10-14
--- Description:过场动画sequence流水上报
---

local LuaClass = require("Core/LuaClass")

local TimeUtil = require("Utils/TimeUtil")
local DataReportUtil = require("Utils/DataReportUtil")

local SequencePlayerReport = LuaClass()

function SequencePlayerReport:Ctor()
    self.StartTimeMS = nil
    self.Route = nil
    self.ISSkip = false
end

function SequencePlayerReport:RecordPlay()
    self.StartTimeMS = TimeUtil.GetLocalTimeMS()
end

function SequencePlayerReport:RecordRoute(Route)
    if not string.isnilorempty(Route) then
        local Array = string.split(Route, ".")
        local Length = #Array
        local Name = Array[Length]
        Name = string.gsub(Name, "'", "")
        self.Route = Name
    end
end

function SequencePlayerReport:RecordBreak()
    self.ISSkip = true
end

function SequencePlayerReport:Clear()
    self.StartTimeMS = nil
    self.Route = nil
    self.ISSkip = false
end

function SequencePlayerReport:RecordStop()
    if self.StartTimeMS then
        local NowMS = TimeUtil.GetLocalTimeMS()
        local TP = math.floor((NowMS - self.StartTimeMS) * 0.001)
        DataReportUtil.ReportSequenceFlowData(self.Route, TP, self.ISSkip)
    end
    self:Clear()
end

return SequencePlayerReport
