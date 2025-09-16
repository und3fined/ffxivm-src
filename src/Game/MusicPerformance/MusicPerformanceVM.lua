local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local EnsembleStatus = ProtoCS.EnsembleStatus

---@class MusicPerformanceVM : UIViewModel
local MusicPerformanceVM = LuaClass(UIViewModel)


function MusicPerformanceVM:Ctor()
end

function MusicPerformanceVM:OnInit()
	self:Reset()
end

function MusicPerformanceVM:Reset()
	self:CancelTimer()

	self.Status = EnsembleStatus.EnsembleStatusNone
	self.ReadyTime = 0
	self.BeginTimeMs = 0

	self.EnsembleMetronome = {}
	self.EnsembleConfirmStatus = {}
end

function MusicPerformanceVM:TickReadyTime(Params, ElapsedTime)
	local Offset = Params.Offset or 0
	if ElapsedTime + Offset > Params.ReadyTime then
		self.ReadyTime = Params.ReadyTime
		self:CancelTimer()
		if Params.Callback then
			Params.Callback()
		end
	else
		self.ReadyTime = ElapsedTime + Offset
	end
end

function MusicPerformanceVM:BeginReady(ReadyTime, Offset, Callback)
	MusicPerformanceUtil.Log(string.format("MusicPerformanceVM:BeginReady %f %f", ReadyTime, Offset))
	self:CancelTimer()
	self.ReadyTime = ReadyTime
	self.ReadyTimer = _G.TimerMgr:AddTimer(self, self.TickReadyTime, 0, 0.05, 0, {Offset = Offset, ReadyTime = ReadyTime, Callback = Callback})
end

function MusicPerformanceVM:CancelTimer()
	_G.TimerMgr:CancelTimer(self.ReadyTimer)
	self.ReadyTimer = nil
end

function MusicPerformanceVM:OnBegin()
end

function MusicPerformanceVM:OnEnd()
	self:Reset()
end

function MusicPerformanceVM:OnShutdown()
end

return MusicPerformanceVM