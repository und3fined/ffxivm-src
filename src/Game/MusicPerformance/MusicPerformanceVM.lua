local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local AudioUtil = require("Utils/AudioUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local TimeUtil = require("Utils/TimeUtil")

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
	self.StartTime = 0
	self.BeginTimeMs = 0
	self.LastCountDownTime = 0

	self.EnsembleMetronome = {} --队长设置的合奏数据(这4个属性：Ready=true、Assistant=true、BPM=120、Beat=4)
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

	self:PlaySoundCountDownTime(self.ReadyTime)
end

function MusicPerformanceVM:BeginReady(ReadyTime, Offset, Callback)
	MusicPerformanceUtil.Log(string.format("MusicPerformanceVM:BeginReady %f %f", ReadyTime, Offset))
	self:CancelTimer()
	self.StartTime = TimeUtil.GetServerTime() - Offset
	self.ReadyTime = ReadyTime
	self.ReadyTimer = _G.TimerMgr:AddTimer(self, self.TickReadyTime, 0, 0.05, 0, {Offset = Offset, ReadyTime = ReadyTime, Callback = Callback})
end

function MusicPerformanceVM:CancelTimer()
	_G.TimerMgr:CancelTimer(self.ReadyTimer)
	self.StartTime = 0
	self.ReadyTimer = nil
	self.LastCountDownTime = 0
end

--播放倒计时音效（需要“暂时收起”UI面板后也能播）
function MusicPerformanceVM:PlaySoundCountDownTime(Value)
	local IntPart, DecimalPart = math.modf(Value)
	if IntPart + 1 > self.LastCountDownTime then
		self.LastCountDownTime = self.LastCountDownTime + 1
		--播放提示音效
		AudioUtil.LoadAndPlay2DSound(MPDefines.Ensemble.CountDownTimeSoundPath)
	end
end

function MusicPerformanceVM:OnBegin()
end

function MusicPerformanceVM:OnEnd()
	self:Reset()
end

function MusicPerformanceVM:OnShutdown()
end

return MusicPerformanceVM