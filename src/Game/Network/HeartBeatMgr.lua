--
-- Author: anypkvcai
-- Date: 2023-05-16 10:05
-- Description: 心跳协议和网络延迟协议合并了， UpdateTimeSlot暂时先保留
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")

local EventMgr            ---@type EventMgr
local ETimeSlotType

---@class HeartBeatMgr : MgrBase
local HeartBeatMgr = LuaClass(MgrBase)

function HeartBeatMgr:OnInit()
	self.CurrentTimeSlot = 0
end

function HeartBeatMgr:OnBegin()
	EventMgr = _G.EventMgr
	ETimeSlotType = _G.UE.ETimeSlotType
end

function HeartBeatMgr:OnEnd()

end

function HeartBeatMgr:OnShutdown()

end

function HeartBeatMgr:UpdateTimeSlot()
	local TargetTimeSlot
	local AozyHour = TimeUtil.GetAozyHour()

	-- 黎明和黄昏暂时不管, 昼夜的分割线是6和18
	-- # TODO - 策划明确规则后, 更改判定的方式
	if AozyHour >= 6 and AozyHour < 18 then
		TargetTimeSlot = ETimeSlotType.Daytime
	else
		TargetTimeSlot = ETimeSlotType.Night
	end

	if TargetTimeSlot == self.CurrentTimeSlot then
		return
	end

	self.CurrentTimeSlot = TargetTimeSlot
	local Params = EventMgr:GetEventParams()
	Params.IntParam1 = self.CurrentTimeSlot
	EventMgr:SendCppEvent(EventID.TimeSlotChange, Params)
end

return HeartBeatMgr