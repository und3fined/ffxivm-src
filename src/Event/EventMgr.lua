--
-- Author: anypkvcai
-- Date: 2020-08-06 14:07:40
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
local TimeUtil = require("Utils/TimeUtil")
local Deque = require("Core/Deque")

local EventIDToName
local UEventMgr
local FTickHelper

local ShallowCopyArray = CommonUtil.ShallowCopyArray
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local XPCall = CommonUtil.XPCall


--处理事件时间的放大倍数
local TickTimeMultiple = 2

--每次Tick处理事件的默认时间（毫秒）
local TickTimePerTick = 2

--当前Tick处理事件的最大时间（毫秒）
local MaxTickTimePerTick = TickTimePerTick

local function AssignParams(DstParams, SrcParams)
	DstParams.IntParam1 = SrcParams.IntParam1
	DstParams.IntParam2 = SrcParams.IntParam2
	DstParams.IntParam3 = SrcParams.IntParam3
	DstParams.IntParam4 = SrcParams.IntParam4

	DstParams.ULongParam1 = SrcParams.ULongParam1
	DstParams.ULongParam2 = SrcParams.ULongParam2
	DstParams.ULongParam3 = SrcParams.ULongParam3
	DstParams.ULongParam4 = SrcParams.ULongParam4

	DstParams.BoolParam1 = SrcParams.BoolParam1
	DstParams.BoolParam2 = SrcParams.BoolParam2
	DstParams.BoolParam3 = SrcParams.BoolParam3
	DstParams.BoolParam4 = SrcParams.BoolParam4

	DstParams.FloatParam1 = SrcParams.FloatParam1
	DstParams.FloatParam2 = SrcParams.FloatParam2
	DstParams.FloatParam3 = SrcParams.FloatParam3
	DstParams.FloatParam4 = SrcParams.FloatParam4

	DstParams.StringParam1 = SrcParams.StringParam1
	DstParams.StringParam2 = SrcParams.StringParam2
	DstParams.StringParam3 = SrcParams.StringParam3
	DstParams.StringParam4 = SrcParams.StringParam4

	DstParams.ObjectParam = SrcParams.ObjectParam
end

---@class EventMgr : MgrBase
local EventMgr = LuaClass(MgrBase)

function EventMgr:OnInit()
	self.Subscriptions = {}
	self.EventQueue = Deque.New()
	self.TickEnable = false

	local EventID = require("Define/EventID")

	EventIDToName = EventID.IDToName

	FLOG_INFO("EventMgr:OnInit")
end

function EventMgr:OnBegin()
	UEventMgr = _G.UE.UEventMgr.Get()
	FTickHelper = _G.UE.FTickHelper.GetInst()

	FTickHelper:SetTickDisable(self.TickTimerID)
	self.TickEnable = false
end

function EventMgr:OnEnd()
	self.Subscriptions = {}
	self.EventQueue:Empty()
end

function EventMgr:OnShutdown()
	FLOG_INFO("EventMgr:OnShutdown")
end

---RegisterEvent
---@param EventID number            @EventID
---@param Listener table | nil      @如果回调函数是类成员函数 Listener为self 其他情况为nil
---@param Callback function         @Callback function
---@param ListenerName string
function EventMgr:RegisterEvent(EventID, Listener, Callback, ListenerName)
	if nil == self.Subscriptions then
		self.Subscriptions = {}
	end

	if nil == EventID then
		FLOG_ERROR("EventMgr:RegisterEvent EventID is nil!")
		return
	end

	if self:IsEventRegistered(EventID, Listener, Callback) then
		FLOG_WARNING("EventMgr:RegisterEvent Callback is already registered, EventID=%d", EventID)
		return
	end

	local Subscriptions = self.Subscriptions[EventID]
	if nil == Subscriptions then
		Subscriptions = {}
		self.Subscriptions[EventID] = Subscriptions
	end

	table.insert(Subscriptions, { Listener = Listener, Callback = Callback, ListenerName = ListenerName })
end

---IsEventRegistered
---@param EventID number            @EventID
---@param Callback function          @Callback function
function EventMgr:IsEventRegistered(EventID, Listener, Callback)
	if nil == self.Subscriptions then
		return
	end

	local Subscriptions = self.Subscriptions[EventID]
	if nil == Subscriptions then
		return false
	end

	for i = 1, #Subscriptions do
		if Subscriptions[i].Callback == Callback
				and Subscriptions[i].Listener == Listener then
			return true
		end
	end

	return false
end

---SendEvent 发送事件到Lua
---@param EventID number            @EventID
function EventMgr:SendEvent(EventID, ...)
	if nil == EventID or EventID <= 0 then
		FLOG_ERROR("EventMgr:SendEvent EventID is invalid, %s", debug.traceback())
		return
	end
	--print("EventMgr:SendEvent", EventID)

	if nil == self.Subscriptions then
		return
	end

	local Subscriptions = self.Subscriptions[EventID]
	if nil == Subscriptions or #Subscriptions <= 0 then
		return
	end

	local ClonedSubscriptions = ShallowCopyArray(Subscriptions)
	--_G.UE.FProfileTag.StaticEnd()

	local _ <close> = CommonUtil.MakeProfileTag(string.format("EventMgr:SendEvent_%s", EventIDToName(EventID)))

	for i = 1, #ClonedSubscriptions do
		local v = ClonedSubscriptions[i]
		if nil ~= v and nil ~= v.Callback then
			local _ <close> = CommonUtil.MakeProfileTag(v.ListenerName)
			XPCall(v.Listener, v.Callback, ...)
		end
	end
end

---PostEvent 发送事件到Lua，放到事件队列里分帧处理，接收事件会有延迟，处理事件时要做一些保护性的判断
---@param EventID number            @EventID
function EventMgr:PostEvent(EventID, ...)
	if nil == EventID or EventID <= 0 then
		FLOG_ERROR("EventMgr:PostEvent EventID is invalid, %s", debug.traceback())
		return
	end

	if nil == self.Subscriptions then
		return
	end

	local Subscriptions = self.Subscriptions[EventID]
	if nil == Subscriptions then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("EventMgr_PostEvent_%d", EventID))
	local Params = { ... }
	local EventQueue = self.EventQueue

	for i = 1, #Subscriptions do
		local Event = { Subscription = Subscriptions[i], EventID = EventID, Params = Params }
		EventQueue:AddTail(Event)
	end

	if not self.TickEnable then
		FTickHelper:SetTickEnable(self.TickTimerID)
		self.TickEnable = true
	end
end

---UnRegisterEvent
---@param EventID number            @EventID
---@param Listener table | nil      @如果回调函数是类成员函数 Listener为self 其他情况为nil
---@param Callback function         @Callback function
function EventMgr:UnRegisterEvent(EventID, Listener, Callback)
	if nil == self.Subscriptions then
		return
	end

	local Subscriptions = self.Subscriptions[EventID]
	if nil == Subscriptions then
		return
	end

	for i = 1, #Subscriptions do
		local v = Subscriptions[i]
		if nil ~= v and v.Listener == Listener and v.Callback == Callback then
			table.remove(Subscriptions, i)
			return
		end
	end
end

---UnRegisterAllEvent
---@param EventID number        @EventID
function EventMgr:UnRegisterAllEvent(EventID)
	if nil == self.Subscriptions then
		return
	end

	self.Subscriptions[EventID] = nil
end
---OnTick
function EventMgr.OnTick()
	EventMgr:OnTimer()
end

---OnTimer
function EventMgr:OnTimer()
	local EventQueue = self.EventQueue
	if nil == EventQueue then
		return
	end

	local Event = EventQueue:RemoveHead()
	if not Event then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("EventMgr:OnTimer")

	local StartTime = TimeUtil.GetGameTimeMS()
	local Time

	while Event do
		local Subscription = Event.Subscription
		local Callback = Subscription.Callback
		if nil ~= Callback and self:IsEventRegistered(Event.EventID, Subscription.Listener, Callback) then
			local _ <close> = CommonUtil.MakeProfileTag(string.format("%s_%s", Subscription.ListenerName, EventIDToName(Event.EventID)))
			XPCall(Subscription.Listener, Callback, table.unpack(Event.Params))
		end

		Time = TimeUtil.GetGameTimeMS()
		if Time - StartTime >= MaxTickTimePerTick then
			break
		end

		Event = EventQueue:RemoveHead()
	end

	if EventQueue:IsEmpty() then
		MaxTickTimePerTick = TickTimePerTick
		FTickHelper:SetTickDisable(self.TickTimerID)
		self.TickEnable = false
	else
		MaxTickTimePerTick = MaxTickTimePerTick * TickTimeMultiple;
	end
end

---GetEventParams lua侧通过table当做参数发送，C++侧转为FEventParams
---@return table
function EventMgr:GetEventParams()
	return {}
end

---SendCppEvent @发送事件到Cpp 参数是lua表, 参数内容应该是FEventParams的属性
---@param EventID number            @EventID
---@param EventParams {}
function EventMgr:SendCppEvent(EventID, EventParams)
	if nil == EventParams then
		UEventMgr:LuaSendEvent(EventID, EventParams)
		return
	end

	--print("EventMgr:SendCppEvent")
	--_G.UE.FProfileTag.StaticBegin("EventMgr:SendCppEvent_Params")
	local Params = UEventMgr:Get():GetParams()

	AssignParams(Params, EventParams)

	--_G.UE.FProfileTag.StaticEnd()

	--_G.UE.FProfileTag.StaticBegin("EventMgr:SendCppEvent_Send")
	UEventMgr:LuaSendEvent(EventID, Params)
	--_G.UE.FProfileTag.StaticEnd()
end

---OnReceiveCppSendEvent
---@param EventID EventID
function EventMgr.OnReceiveCppSendEvent(EventID, ...)
	--print("EventMgr.OnReceiveCppSendEvent EventID=", EventID, ...)

	--_G.UE.FProfileTag.StaticBegin("EventMgr:OnReceiveCppSendEvent")
	EventMgr:SendEvent(EventID, ...)
	--_G.UE.FProfileTag.StaticEnd()
end

---OnReceiveCppPostEvent
---@param EventID EventID
function EventMgr.OnReceiveCppPostEvent(EventID, ...)
	--print("EventMgr.OnReceiveCppPostEvent EventID=", EventID, ...)

	--_G.UE.FProfileTag.StaticBegin("EventMgr:OnReceiveCppPostEvent")
	EventMgr:PostEvent(EventID, ...)
	--_G.UE.FProfileTag.StaticEnd()
end

---OnReceiveCppSendEventWithEventParams
---@param EventID EventID
---@param EventParams FEventParams
function EventMgr.OnReceiveCppSendEventWithEventParams(EventID, EventParams)
	--print("OnReceiveCppSendEventWithEventParams", EventID, EventParams)

	EventMgr:SendEvent(EventID, EventParams)
end

---OnReceiveCppPostEventWithEventParams
---@param EventID EventID
---@param EventParams FEventParams
function EventMgr.OnReceiveCppPostEventWithEventParams(EventID, EventParams)
	--print("OnReceiveCppPostEventWithEventParams", EventID, EventParams)

	if nil == EventParams then
		EventMgr:PostEvent(EventID)
		return
	end

	--_G.UE.FProfileTag.StaticBegin("EventMgr:OnReceiveCppPostEventWithEventParams")

	local Params = {}

	AssignParams(Params, EventParams)

	--_G.UE.FProfileTag.StaticEnd()

	EventMgr:PostEvent(EventID, Params)
end

function EventMgr:Dump()
	FLOG_INFO(table.tostring_block(self.Subscriptions, 3))
end

function EventMgr:DumpName()
	print("EventMgr:DumpName------------------------------------------------------------------------------------------")

	local Subscriptions = self.Subscriptions
	if nil == Subscriptions then
		return
	end

	for k, v in pairs(Subscriptions) do
		print("EventID---------------------------------------------------------------", k)
		for _, item in ipairs(v) do
			print(item.ListenerName)
		end
	end

end

return EventMgr