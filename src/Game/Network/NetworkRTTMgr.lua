--
-- Author: anypkvcai
-- Date: 2024-04-01 11:06
-- Description: round trip time
-- https://dl.acm.org/doi/pdf/10.17487/RFC6298

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local CommonUtil = require("Utils/CommonUtil")

local CS_CMD = ProtoCS.CS_CMD
local LatencyType = ProtoCS.LatencyType

local UTimerMgr         ---@type UTimerMgr
local GameNetworkMgr    ---@type GameNetworkMgr
local EventMgr          ---@type EventMgr
local FLOG_INFO

--最小RTT 单位：毫秒
local MIN_RTT = 8

--可接受的服务器时间误差 单位：毫秒
local SERVERTIME_TOLERANCE = 100

--最大SRTT 单位：毫秒
local MAX_SRTT = 460

--SRTT = (1 - alpha) * SRTT + alpha * R'
--alpha = 1⁄8
--local SRTT_ALPHA = 7

--RTTVAR = (1 - beta) * RTTVAR + beta * |SRTT - R'|
--beta = 1⁄4
--local RTTVAR_BETA = 3

--RTO = SRTT + max (G, K * RTTVAR)
--local RTO_K = 4

--单位：毫秒
--local RTO_LBOUND = 100
--local RTO_UBOUND = 60000

-- 计时器间隔 单位：秒
local TIMER_INTERVAL = 1

--心跳包发送间隔 单位：毫秒 服务器建议是5秒
local HEART_BEAT_INTERVAL = 4.9 * 1000

--心跳包超时时间 单位：毫秒
local HEART_BEAT_TIMEOUT = 1.9 * 1000

--心跳超时次数
local HEART_BEAT_TIMEOUT_MAX_COUNT = 3

---@class NetworkRTTMgr : MgrBase
local NetworkRTTMgr = LuaClass(MgrBase)

function NetworkRTTMgr:OnInit()
	self.LatencyPingSeq = 0
	--self.bEnterBackground = false

	self.LatencyPingMsgBody = { type = LatencyType.LatencyTypePing, seq = 0, timestamp_send = 0 }
	self.LatencyPongMsgBody = { type = LatencyType.LatencyTypePong, seq = 0, timestamp_send = 0, timestamp_attach = 0 }

	self.TimerID = 0
	self.bRTTEnable = false
	self.MinRTT = nil

	self.RTT = 0
	self.SRTT = 0
	--self.RTTVAR = 0
	--self.RTO = 0

	self.SendMsgTime = 0
	self.TimeOutCount = 0
	self.bWaitingForRes = false
	self.EnterBackgroundTime = 0
end

function NetworkRTTMgr:OnBegin()
	UTimerMgr = _G.UE.UTimerMgr:Get()
	GameNetworkMgr = _G.GameNetworkMgr
	NetworkRTTMgr = _G.NetworkRTTMgr
	EventMgr = _G.EventMgr
	FLOG_INFO = _G.FLOG_INFO

	if CommonUtil.IsWithEditor() then
		--编辑器下心跳超时次数
		HEART_BEAT_TIMEOUT_MAX_COUNT = 30
	end
end

function NetworkRTTMgr:OnEnd()
	self:Stop()
end

function NetworkRTTMgr:OnShutdown()

end

function NetworkRTTMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LATENCY, 0, self.OnNetMsgLatency)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGOUT, 0, self.OnNetMsgRoleLogoutRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGIC_TIME, 0, self.OnNetMsgLogicTime)
end

function NetworkRTTMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.NetworkConnectSuccess, self.OnGameEventNetworkConnectSuccess)
	self:RegisterGameEvent(EventID.NetworkStartHeartBeat, self.OnGameEventNetworkStartHeartBeat)
	self:RegisterGameEvent(EventID.NetworkStopHeartBeat, self.OnGameEventNetworkStopHeartBeat)
	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	--self:RegisterGameEvent(EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
	--self:RegisterGameEvent(EventID.WorldPostLoad, self.OnGameEventWorldPostLoad)
end

function NetworkRTTMgr:OnNetMsgLatency(MsgBody)
	local Type = MsgBody.type
	local LatencySeq = MsgBody.seq
	local TimeStampSend = MsgBody.timestamp_send

	if LatencyType.LatencyTypePing == Type then
		--服务器请求延迟，客户端收到服务器主动下发的ping包，给服务器回一个pong包
		self:SendLatencyPongMsg(LatencySeq, TimeStampSend)
	elseif LatencyType.LatencyTypePong == Type then
		self.TimeOutCount = 0
		self.bWaitingForRes = false

		--客户端请求延迟，数据包type填ping，后台会回一个pong包，pong包回把客户端请求包里所有字段原样返回，并在attach字段附带服务器时间戳
		local TimeStampAttach = MsgBody.timestamp_attach
		local ServerTime = TimeUtil.GetServerTimeMS()
		local RTT1 = ServerTime - TimeStampSend
		local RTT2 = 2 * (TimeStampAttach - TimeStampSend)
		local RTT = RTT2 > 0 and math.min(RTT1, RTT2) or RTT1

		self:UpdateRTT(RTT)
		self:UpdateTime(ServerTime, TimeStampAttach, RTT1)

		--FLOG_INFO("NetworkRTTMgr:OnNetMsgLatency RTT1=%d RTT2=%d RTT=%d LT-TA=%d ST-LT=%s", RTT1, RTT2, RTT, TimeUtil.GetLocalTimeMS() - TimeStampAttach, TimeUtil.GetServerTimeMS() - TimeUtil.GetLocalTimeMS())
	end
end

function NetworkRTTMgr:OnNetMsgRoleLogoutRes(MsgBody)
	local Reason = MsgBody.Reason
	if ProtoCS.LogoutReason.ExitDemo == Reason or ProtoCS.LogoutReason.SwitchRole == Reason then
		return
	end

	self.LatencyPingSeq = 0
	self.MinRTT = nil

	self:Stop()
end

function NetworkRTTMgr:OnNetMsgLogicTime(MsgBody)
	UTimerMgr:UpdateServerLogicTime(MsgBody.ServerLogicTime)
end

function NetworkRTTMgr:OnGameEventNetworkConnectSuccess(Params)
	self:Start()
end

function NetworkRTTMgr:OnGameEventNetworkStartHeartBeat(Params)
	self:Start()
end

function NetworkRTTMgr:OnGameEventNetworkStopHeartBeat(Params)
	self:Stop()
end

function NetworkRTTMgr:OnGameEventAppEnterBackground(Params)
	FLOG_INFO("NetworkRTTMgr:OnGameEventAppEnterBackground")
	self.EnterBackgroundTime = TimeUtil.GetServerTimeMS()

	--self.bEnterBackground = true
	--self.bRTTEnable = false
end

function NetworkRTTMgr:OnGameEventAppEnterForeground(Params)
	local Time = TimeUtil.GetServerTimeMS()
	local bTimeOut = Time - self.EnterBackgroundTime > HEART_BEAT_INTERVAL * HEART_BEAT_TIMEOUT_MAX_COUNT

	FLOG_INFO("NetworkRTTMgr:OnGameEventAppEnterForeground %s", bTimeOut)
	if bTimeOut and GameNetworkMgr:IsConnected() then
		EventMgr:SendEvent(EventID.NetworkHeartBeatTimeOut)
		self:Stop()
	end

	--self.bEnterBackground = false
	--self.bRTTEnable = true
end

--function NetworkRTTMgr:OnGameEventWorldPreLoad(Params)
--	--FLOG_INFO("NetworkRTTMgr:OnGameEventWorldPreLoad")
--	self.bRTTEnable = false
--end
--
--function NetworkRTTMgr:OnGameEventWorldPostLoad(Params)
--	--FLOG_INFO("NetworkRTTMgr:OnGameEventWorldPostLoad")
--	self.bRTTEnable = true
--end

function NetworkRTTMgr:OnGameEventLoginRes()
	self:SendQueryLogicTime()
end

function NetworkRTTMgr:SendLatencyPingMsg()
	local LatencyPingSeq = self.LatencyPingSeq + 1
	self.LatencyPingSeq = LatencyPingSeq

	local MsgBody = self.LatencyPingMsgBody
	MsgBody.seq = LatencyPingSeq
	MsgBody.timestamp_send = TimeUtil.GetServerTimeMS()

	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_LATENCY, 0, MsgBody)
end

function NetworkRTTMgr:SendLatencyPongMsg(LatencySeq, TimeStampSend)
	local MsgBody = self.LatencyPongMsgBody
	MsgBody.seq = LatencySeq
	MsgBody.timestamp_send = TimeStampSend
	MsgBody.timestamp_attach = TimeUtil.GetServerTimeMS()

	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_LATENCY, 0, MsgBody)
end

function NetworkRTTMgr:SendQueryLogicTime()
	local MsgBody = {}

	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_LOGIC_TIME, 0, MsgBody)
end

function NetworkRTTMgr:UpdateRTT(RTT)
	if not self.bRTTEnable then
		return
	end

	if RTT < MIN_RTT then
		RTT = MIN_RTT
	end

	local SRTT = self.SRTT
	local NewSRTT

	if SRTT <= 0 then
		NewSRTT = RTT
		--self.RTTVAR = RTT >> 1
	else
		--local Delta = math.abs(RTT - SRTT)
		--self.RTTVAR = (RTTVAR_BETA * SRTT + Delta) >> 2
		--NewSRTT = (SRTT_ALPHA * SRTT + RTT) >> 3
		NewSRTT = (self.RTT + RTT) >> 1
	end

	NewSRTT = math.min(math.max(0, NewSRTT), MAX_SRTT)

	self.RTT = RTT
	self.SRTT = NewSRTT

	--self.RTO = math.min(RTO_UBOUND, math.max(RTO_LBOUND, self.SRTT + RTO_K * self.RTTVAR))

	UTimerMgr:SetRTT(RTT)
	UTimerMgr:SetSRTT(NewSRTT)

	--FLOG_INFO(string.format("NetworkRTTMgr:UpdateRTT RTT=%d SRTT=%d", RTT, self.SRTT))
	--FLOG_INFO(string.format("NetworkRTTMgr:UpdateRTT RTT=%d SRTT=%d RTTVAR=%d RTO=%d", RTT, self.SRTT, self.RTTVAR, self.RTO))
end

---GetRTT
---@return number
function NetworkRTTMgr:GetRTT()
	return self.RTT
end

---GetSRTT
---@return number
function NetworkRTTMgr:GetSRTT()
	return self.SRTT
end

function NetworkRTTMgr:OnTimer()
	if not self.bRTTEnable then
		return
	end

	local SendMsgTime = self.SendMsgTime
	local Time = TimeUtil.GetGameTimeMS()
	if Time < SendMsgTime then
		Time = SendMsgTime
	end

	if self.bWaitingForRes then
		if SendMsgTime > 0 and Time >= SendMsgTime + HEART_BEAT_TIMEOUT then
			self.bWaitingForRes = false
			local TimeOutCount = self.TimeOutCount
			TimeOutCount = TimeOutCount + 1
			self.TimeOutCount = TimeOutCount
			if self.TimeOutCount >= HEART_BEAT_TIMEOUT_MAX_COUNT then
				FLOG_INFO("NetworkRTTMgr:OnTimer TimeOut")
				EventMgr:SendEvent(EventID.NetworkHeartBeatTimeOut)
				self:Stop()
			else
				self.SendMsgTime = Time
				self.bWaitingForRes = true
				self:SendLatencyPingMsg()
			end
		end
	else
		if SendMsgTime <= 0 or Time >= SendMsgTime + HEART_BEAT_INTERVAL then
			self.SendMsgTime = Time
			self.bWaitingForRes = true
			self:SendLatencyPingMsg()
		end
	end
end

function NetworkRTTMgr:Start()
	FLOG_INFO("NetworkRTTMgr:Start")

	--self.bEnterBackground = false

	self:RemoveTimer()

	self.bRTTEnable = true

	self.LatencyPingSeq = 0

	self.SendMsgTime = 0
	self.TimeOutCount = 0
	self.bWaitingForRes = false

	self.TimerID = self:RegisterTimer(self.OnTimer, 0, TIMER_INTERVAL, 0)
end

function NetworkRTTMgr:Stop()
	FLOG_INFO("NetworkRTTMgr:Stop")

	self:RemoveTimer()

	self.bRTTEnable = false

	self.SendMsgTime = 0
	self.TimeOutCount = 0
	self.bWaitingForRes = false
end

function NetworkRTTMgr:RemoveTimer()
	local TimerID = self.TimerID
	if TimerID > 0 then
		self:UnRegisterTimer(TimerID)
		self.TimerID = 0
	end
end

function NetworkRTTMgr:UpdateTime(ServerTime, TimeStampAttach, RTT)
	local MinRTT = self.MinRTT
	local NewServerTime = TimeStampAttach + math.floor(RTT / 2)
	if nil == MinRTT or RTT <= MinRTT then
		UTimerMgr:UpdateServerTime(NewServerTime)
		FLOG_INFO("NetworkRTTMgr:UpdateTime1 ServerTime=%s TimeStampAttach=%s RTT=%s MinRTT=%s", ServerTime, TimeStampAttach, RTT, self.MinRTT)
		self.MinRTT = RTT
	elseif math.abs(ServerTime - NewServerTime) > SERVERTIME_TOLERANCE and RTT < 2 * MinRTT then
		UTimerMgr:UpdateServerTime(NewServerTime)
		FLOG_INFO("NetworkRTTMgr:UpdateTime2 ServerTime=%s TimeStampAttach=%s RTT=%s MinRTT=%s", ServerTime, TimeStampAttach, RTT, self.MinRTT)
		self.MinRTT = RTT
	end

	_G.HeartBeatMgr:UpdateTimeSlot()
end

--[[
function NetworkRTTMgr:Debug()
	local function Callback()
		local L = TimeUtil.GetLocalTime()
		local S = TimeUtil.GetServerTime()
		local SL = TimeUtil.GetServerLogicTime()

		local LF = TimeUtil.GetTimeFormat("%Y-%m-%d %H:%M:%S", L)
		local SF = TimeUtil.GetTimeFormat("%Y-%m-%d %H:%M:%S", S)
		local SLF = TimeUtil.GetTimeFormat("%Y-%m-%d %H:%M:%S", SL)

		local LMS = TimeUtil.GetLocalTimeMS()
		local SMS = TimeUtil.GetServerTimeMS()
		local SLMS = TimeUtil.GetServerLogicTimeMS()
		local GMS = TimeUtil.GetGameTimeMS()

		print(string.format("NetworkRTTMgr:Debug Local=%s Server=%s %s Logic=%s Game=%s Logic-Server=%s Local-Server=%s", LF, SMS, SF, SLF, GMS, SLMS - SMS, LMS - SMS))
	end

	self:RegisterTimer(Callback, 0, 1, 0)
end
--]]

return NetworkRTTMgr