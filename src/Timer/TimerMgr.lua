--
-- Author: anypkvcai
-- Date: 2020-08-07 15:07:04
-- Description:
--

local LuaClass = require("Core/LuaClass")
local LinkedList = require("Core/LinkedList")
local MgrBase = require("Common/MgrBase")
local TimeUtil = require("Utils/TimeUtil")
local CommonUtil = require("Utils/CommonUtil")

local DefaultListenerName = "UnKnown"

local XPCall = CommonUtil.XPCall

local FLOG_ERROR
local FLOG_WARNING

---@class TimerMgr : MgrBase
local TimerMgr = LuaClass(MgrBase)

function TimerMgr:OnInit()
	self.TimerID = 0
	self.Timers = LinkedList.New()
	self.TimersPendingToAdd = LinkedList.New()
	self.TimersPendingToRemove = LinkedList.New()
	self.bUpdatingTimer = false
end

function TimerMgr:OnBegin()
	FLOG_ERROR = _G.FLOG_ERROR
	FLOG_WARNING = _G.FLOG_WARNING

	_G.UE.FTickHelper.GetInst():SetTickInterval(self.TickTimerID, 0)
end

function TimerMgr.OnTick(DeltaTime)
	TimerMgr:UpdateTimer(DeltaTime)
end

function TimerMgr:OnEnd()
	self:CancelAllTimer()
end

function TimerMgr:OnShutdown()
end

function TimerMgr:GenTimerID()
	self.TimerID = self.TimerID + 1
	return self.TimerID
end

---AddTimer                     @时间单位：秒 Tick间隔0.05  不要直接调用，建议用Mgr或View的RegisterTimer，会自动反注册
---@param Listener table | nil  @如果回调函数是类成员函数 Listener为self 其他情况为nil
---@param Callback function     @Callback function
---@param Delay table           @Delay time
---@param Interval table        @Timer interval 执行一次回调间隔的时间
---@param LoopNumber table      @循环次数 默认执行1次 >0时为最多执行次数 <=0时一直执行
---@param Params table          @会在Callback函数里传递回去
---@param ListenerName string
---@param Register TimerRegister
---@return number               @TimerID
function TimerMgr:AddTimer(Listener, Callback, Delay, Interval, LoopNumber, Params, ListenerName, Register)
	if nil == Callback then
		FLOG_WARNING("TimerMgr:AddTimer Callback is nil traceback=%s", debug.traceback())
		return
	end

	if nil == self.Timers then
		FLOG_ERROR("TimerMgr:AddTimer Timers is nil")
		return
	end

	local TimerID = self:GenTimerID()
	local Timer = {
		Listener = Listener,
		Callback = Callback,
		Delay = Delay or 0,
		Interval = Interval or 0,
		LoopNumber = LoopNumber,
		TimerID = TimerID,
		LoopCount = 0,
		StartTime = TimeUtil.GetGameTimeMS(),
		CallTime = Delay or 0,
		Params = Params,
		ListenerName = ListenerName or DefaultListenerName,
		Register = Register,
	}

	if self.bUpdatingTimer then
		--print("TimerMgr:AddTimer when updating timer", TimerID)
		self.TimersPendingToAdd:AddTail(Timer)
	else
		self.Timers:AddTail(Timer)
	end

	return TimerID
end

----避免tick卡帧的时候影响Timer delay执行
--function TimerMgr:RefreshLastTickTime()
--	self.LastTickTime = TimeUtil.GetGameTimeMS()
--end

---CancelTimer
---@param TimerID number        @TimerID
function TimerMgr:CancelTimer(TimerID)
	if nil == TimerID then
		return
	end

	if self.bUpdatingTimer then
		--print("TimerMgr:CancelTimer when updating timer", TimerID)
		self.TimersPendingToRemove:AddTail(TimerID)
	else
		self.Timers:RemoveByName("TimerID", TimerID)
	end
end

---FlushTimer
---@param TimerID number        @TimerID
function TimerMgr:FlushTimer(TimerID)
	if TimerID == nil then
		return
	end
	-- 正在更新的情况下不允许刷新
	if self.bUpdatingTimer then
		return
	end
	-- 已经要被销毁的计时器也不允许刷新
	if self.TimersPendingToRemove:Find(TimerID) then
		return
	end
	local Node = self.Timers:FindByName("TimerID", TimerID)
	if Node == nil then
		return
	end
	local GameTime = TimeUtil.GetGameTimeMS()
	local Time = math.max(GameTime - Node.StartTime, 0) / 1000
	if nil == Node.LoopNumber or Node.LoopNumber == 1 then
		-- 只播放一次的用Delay刷新时间
		Node.CallTime = Time + Node.Delay
	else
		-- 循环播放的用Interval刷新时间
		Node.CallTime = Time + Node.Interval
	end
end

---CancelAllTimer
function TimerMgr:CancelAllTimer()
	self.TimerID = 0
	self.Timers:Empty()
	self.TimersPendingToAdd:Empty()
	self.TimersPendingToRemove:Empty()
end

---RemoveTimer
---@param TimerID number
---@param Timers LinkedList
local function RemoveTimer(TimerID, Timers)
	local Timer = Timers:RemoveByName("TimerID", TimerID)
	if nil == Timer then
		return
	end

	local Register = Timer.Register
	if nil == Register then
		return
	end

	Register:RemoveTimer(TimerID)
end

---UpdateTimer
---@param DeltaTime number      @lua定时器暂定0.05秒执行一次
function TimerMgr:UpdateTimer(DeltaTime)
	local Timers = self.Timers
	if nil == Timers then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("TimerMgr:UpdateTimer(lua)")

	local GameTime = TimeUtil.GetGameTimeMS()

	local Node = Timers:GetHead()
	if nil == Node then
		return
	end

	self.bUpdatingTimer = true

	local TimersPendingToRemove = self.TimersPendingToRemove

	while Node do
		local v = Node.Data
		local Time = math.max(GameTime - v.StartTime, 0) / 1000
		if Time >= v.CallTime and not TimersPendingToRemove:Find(v.TimerID) then
			local _ <close> = CommonUtil.MakeProfileTag(v.ListenerName)
			XPCall(v.Listener, v.Callback, v.Params, Time)
			v.LoopCount = v.LoopCount + 1
			if nil == v.LoopNumber or (v.LoopNumber > 0 and v.LoopCount >= v.LoopNumber) then
				if not TimersPendingToRemove:Find(v.TimerID) then
					--print("TimerMgr:UpdateTimer remove timer", v.TimerID)
					TimersPendingToRemove:AddTail(v.TimerID)
				end
			else
				v.CallTime = v.CallTime + v.Interval
			end
		end
		Node = Node.Next
	end

	self.bUpdatingTimer = false

	local TimersPendingToAdd = self.TimersPendingToAdd

	if TimersPendingToRemove:GetNum() > 0 then
		--print("TimerMgr:UpdateTimer TimersPendingToRemove")
		--TimersPendingToRemove:PrintAll()
		TimersPendingToRemove:Traverse(RemoveTimer, Timers)
		TimersPendingToRemove:Traverse(RemoveTimer, TimersPendingToAdd)
		TimersPendingToRemove:Empty()
	end

	if TimersPendingToAdd:GetNum() > 0 then
		--print("TimerMgr:UpdateTimer TimersPendingToAdd")
		--TimersPendingToAdd:PrintAll()
		Timers:Merge(TimersPendingToAdd, true)
	end
end

function TimerMgr:Dump()
	self.Timers:PrintAll()
end

function TimerMgr:DumpName()
	print("TimerMgr:DumpName------------------------------------------------------------------------------------------")
	local Timers = self.Timers
	if nil == Timers then
		return
	end

	local Node = Timers:GetHead()
	if nil == Node then
		return
	end

	while Node do
		print(Node.Data.ListenerName)
		Node = Node.Next
	end
end

return TimerMgr
