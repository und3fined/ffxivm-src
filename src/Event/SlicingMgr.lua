
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local TimeUtil = require("Utils/TimeUtil")
local Deque = require("Core/Deque")

local XPCall = CommonUtil.XPCall
local isyieldable = coroutine.isyieldable
local yield = coroutine.yield

--处理事件时间的放大倍数
local TickTimeMultiple = 1

--每次Tick处理事件的默认时间（毫秒）
local TickTimePerTick = 1

--当前Tick处理事件的最大时间（毫秒）
-- 由于GetLocalTimeMS精度限制为整数，Task在1ms粒度下总时间可能最多+1ms
local MaxTickTimePerTick = 1

---@class SlicedTask
local SlicedTask = {}

local AllocTaskID = 0

-- ===================================
-- SlicedTask
-- ===================================

function SlicedTask.New(Caller, Callback, ...)
	AllocTaskID = AllocTaskID + 1
	local Object = {
		ID = AllocTaskID,
        Caller = Caller,
        Callback = Callback,
        Params = { ... },
		bIsCoroutine = false,
		bTaskFinished = false,
	}
	setmetatable(Object, { __index = SlicedTask })
	return Object
end

function SlicedTask.NewCoroutine(co_handle, ...)
	local Task = SlicedTask.New(nil, co_handle, ...)
	Task.bIsCoroutine = true
	return Task
end

function SlicedTask:Exec()
	if (nil == self.Callback) then return end

	if not self.bIsCoroutine then
		XPCall(self.Caller, self.Callback, table.unpack(self.Params))
		self.bTaskFinished = true
		return
	end

	local resume_stat, value = coroutine.resume(self.Callback, table.unpack(self.Params))
	self.bTaskFinished = ("dead" == coroutine.status(self.Callback))
	assert(resume_stat, value)
end

-- ===================================
-- SlicingMgr
-- ===================================

---@class SlicingMgr : MgrBase
local SlicingMgr = LuaClass(MgrBase)

function SlicingMgr:OnInit()
	self.TaskQueue = Deque.New()
	self.bEnableTick = true
	-- FLOG_INFO("SlicingMgr:OnInit")
	FLOG_ERROR("SlicingMgr:OnInit")
end

-- function SlicingMgr:OnBegin()
-- end

function SlicingMgr:OnEnd()
	self.TaskQueue:Empty()
	FLOG_ERROR("SlicingMgr:OnEnd")
end

function SlicingMgr:OnShutdown()
	-- FLOG_INFO("SlicingMgr:OnShutdown")
	self.TaskQueue:Empty()
end

function SlicingMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.05, 0)
end

-- -----------------------------------
-- public
-- -----------------------------------

---@param Caller table | nil	@如果回调函数是类成员函数 Caller为self 其他情况为nil
---@param Callback function		@回调函数
---@return number				@TaskID
function SlicingMgr:EnqueueTask(Caller, Callback, ...)
    local Task = SlicedTask.New(Caller, Callback, ...)
    self.TaskQueue:AddTail(Task)
	return Task.ID
end

---@param co_handle thread		@coroutine
---@return number				@TaskID
function SlicingMgr:EnqueueCoroutine(co_handle, ...)
    local Task = SlicedTask.NewCoroutine(co_handle, ...)
    self.TaskQueue:AddTail(Task)
	return Task.ID
end

---@param co_handle thread		@coroutine
---@return number				@TaskID
function SlicingMgr:EnqueueCoroutineHighPriority(co_handle, ...)
    local Task = SlicedTask.NewCoroutine(co_handle, ...)
    self.TaskQueue:AddHead(Task)
	return Task.ID
end

---加入队列并执行一次
---@param co_handle thread		@coroutine
---@return number				@TaskID
function SlicingMgr:EnqueueCoroutineAndExecOnce(co_handle, ...)
    local Task = SlicedTask.NewCoroutine(co_handle, ...)
    self.TaskQueue:AddTail(Task)
	Task:Exec()
	return Task.ID
end

---@param TaskID number
function SlicingMgr:StopTask(TaskID)
	if not TaskID then return end
	local TaskQueue = self.TaskQueue
	local Task = TaskQueue:GetHead()
	if not Task then return end
	if Task.ID == TaskID then
		TaskQueue:RemoveHead()
	end
end

function SlicingMgr.YieldCoroutine()
    if isyieldable() then yield() end
end

---@param TaskID number			@TaskID
function SlicingMgr:ForceExec(TaskID)
	if (nil == TaskID) then return end

	self.bEnableTick = false

	local TaskQueue = self.TaskQueue
	local First = TaskQueue:GetFirst()
	local Last = TaskQueue:GetLast()
	local Task
	for i = Last, First do
		local CurrTask = TaskQueue:GetValue(i)
		if (nil ~= CurrTask) and (CurrTask.ID == TaskID) then
			Task = CurrTask
			break
		end
	end

	if (nil == Task) then
		self.bEnableTick = true
		return
	end

	while not Task.bTaskFinished do
		Task:Exec()
	end
	self.bEnableTick = true
end

-- -----------------------------------
-- private
-- -----------------------------------

---@private
function SlicingMgr:OnTimer()
	if not self.bEnableTick then return end

	local TaskQueue = self.TaskQueue
	local Task = TaskQueue:GetHead()
	if not Task then return end

	local _ <close> = CommonUtil.MakeProfileTag("SlicingMgr_OnTimer")

	local StartTime = TimeUtil.GetLocalTimeMS()
	local Time
	local bTimeOut = false

	while Task and (not bTimeOut) do

		while not (Task.bTaskFinished or bTimeOut) do

			local _ <close> = CommonUtil.MakeProfileTag(string.format("SlicingMgr_OnTimer_%d", Task.ID))
			Task:Exec()

			Time = TimeUtil.GetLocalTimeMS()
			bTimeOut = (Time - StartTime >= MaxTickTimePerTick) -- 这里Time为整数，必须用[>=]
		end

		if Task.bTaskFinished then
			TaskQueue:RemoveHead()
		end

		Task = TaskQueue:GetHead()
	end

	-- if TaskQueue:IsEmpty() then
	-- 	MaxTickTimePerTick = TickTimePerTick;
	-- else
	-- 	MaxTickTimePerTick = MaxTickTimePerTick * TickTimeMultiple;
	-- end
end

return SlicingMgr