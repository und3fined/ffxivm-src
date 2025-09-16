--
-- Author: anypkvcai
-- Date: 2023-10-30 15:25
-- Description:
--


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local NetworkMsgConfig = require("Define/NetworkMsgConfig")
local NetworkUtil = require("Network/NetworkUtil")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")

local CS_CMD = ProtoCS.CS_CMD
local DEFAULT_WAITING_TIME = 10000  --默认等待时间：10000毫秒

local LSTR
local EventMgr
local GameNetworkMgr   ---@type GameNetworkMgr

---@class NetworkImplMgr : MgrBase
local NetworkImplMgr = LuaClass(MgrBase)

---OnInit
function NetworkImplMgr:OnInit()

end

---OnBegin
function NetworkImplMgr:OnBegin()
	self.LastSentTimes = {}
	self.WaitingInfos = {}

	LSTR = _G.LSTR
	EventMgr = _G.EventMgr
	GameNetworkMgr = _G.GameNetworkMgr
	GameNetworkMgr:SetImpl(self)
end

function NetworkImplMgr:OnEnd()
	self.LastSentTimes = {}

	self:StopAllWaiting()

	GameNetworkMgr:SetImpl(nil)
end

function NetworkImplMgr:OnShutdown()

end

function NetworkImplMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
end

function NetworkImplMgr:OnRegisterGameEvent()

end

function NetworkImplMgr:OnNetMsgError(MsgBody)
	local Msg = MsgBody
	if nil == Msg then
		return
	end

	local Cmd = Msg.Cmd
	if nil == Cmd then
		return
	end

	self:OnReceiveMsg(Cmd, Msg.SubCmd or 0)
end

function NetworkImplMgr:OnTrySendMsg(MsgID, SubMsgID)
	local MsgKey = NetworkUtil.GetMsgKey(MsgID, SubMsgID)
	if self:IsWaiting(MsgKey) then
		return false
	end

	if nil == NetworkMsgConfig then
		return true
	end

	local Config = NetworkMsgConfig.GetSendMsgConfig(MsgID, SubMsgID)
	if nil == Config then
		return true
	end

	if not Config.bSendLimit then
		return true
	end

	local LastSentTimes = self.LastSentTimes
	local LastSentTime = LastSentTimes[MsgKey]
	local Time = TimeUtil.GetGameTimeMS()
	if nil == LastSentTime then
		LastSentTimes[MsgKey] = Time
		return true
	end

	local SendInterval = Config.SendInterval or NetworkMsgConfig.DefaultSendInterval
	if Time > LastSentTime and Time - LastSentTime < SendInterval then
		if Config.bShowTips then
			MsgTipsUtil.ShowTips(LSTR(Config.Tips or NetworkMsgConfig.DefaultSendTips))
		end
		return false
	end

	LastSentTimes[MsgKey] = Time

	return true
end

function NetworkImplMgr:OnSendMsg(MsgID, SubMsgID)
	if nil == NetworkMsgConfig then
		return
	end

	local Config = NetworkMsgConfig.GetReceiveMsgConfig(MsgID, SubMsgID)
	if nil == Config then
		return
	end

	if not Config.bWaitForRes then
		return
	end

	local MsgKey = NetworkUtil.GetMsgKey(MsgID, SubMsgID)

	local Time = Config.WaitTime or NetworkMsgConfig.DefaultWaitResTime
	local Tips

	if not Config.bDontShowTips then
		Tips = Config.Tips or NetworkMsgConfig.DefaultWaitTips
	end

	self:StartWaiting(MsgKey, Time, Tips, Config.bReturnToLogin, Config.bReconnect)
end

function NetworkImplMgr:OnReceiveMsg(MsgID, SubMsgID)
	local MsgKey = NetworkUtil.GetMsgKey(MsgID, SubMsgID)
	self:StopWaiting(MsgKey)
end

---OnTimerTimeout
---@param MsgKey number | nil
---@private
function NetworkImplMgr:OnTimerTimeout(MsgKey)
	self:StopWaiting(MsgKey, true)
end

---IsWaiting
---@param MsgKey table
function NetworkImplMgr:IsWaiting(MsgKey)
	local WaitingInfos = self.WaitingInfos
	if nil == WaitingInfos then
		return false
	end

	return nil ~= WaitingInfos[MsgKey or 0]
end

---StartWaiting
---@param MsgKey number | nil
---@param Time number | nil
---@param Tips string | nil
---@param bReturnToLogin boolean | nil
---@param bReconnect boolean | nil
function NetworkImplMgr:StartWaiting(MsgKey, Time, Tips, bReturnToLogin, bReconnect)
	if self:IsWaiting(MsgKey) then
		return
	end
	--_G.FLOG_INFO(string.format("NetworkImplMgr:StartWaiting MsgKey=%s", MsgKey))
	EventMgr:SendEvent(EventID.NetworkStartWaiting)

	MsgKey = MsgKey or 0
	local Delay = Time or DEFAULT_WAITING_TIME
	local TimerID = self:RegisterTimer(self.OnTimerTimeout, Delay * 0.001, 0, nil, MsgKey)
	local Info = { MsgKey = MsgKey, TimerID = TimerID, Tips = Tips, bReturnToLogin = bReturnToLogin, bReconnect = bReconnect }
	self.WaitingInfos[MsgKey] = Info
end

---StopWaiting
---@param MsgKey number | nil
function NetworkImplMgr:StopWaiting(MsgKey, bTimeOut)
	local WaitingInfos = self.WaitingInfos
	if nil == WaitingInfos then
		return
	end

	MsgKey = MsgKey or 0
	local Info = WaitingInfos[MsgKey]
	WaitingInfos[MsgKey] = nil
	if nil == Info then
		return
	end

	--_G.FLOG_INFO(string.format("StopWaiting:StopWaiting MsgKey=%s", MsgKey))
	self:UnRegisterTimer(Info.TimerID)

	if not next(WaitingInfos) then
		EventMgr:SendEvent(EventID.NetworkStopWaiting)
	end

	if not bTimeOut then
		return
	end

	if Info.Tips then
		MsgTipsUtil.ShowTips(LSTR(Info.Tips))
	end

	if Info.bReturnToLogin then
		_G.FLOG_INFO("NetworkImplMgr:StopWaiting ReturnToLogin MsgKey=%s", MsgKey)
		_G.NetworkStateMgr:ReturnToLogin()
	elseif Info.bReconnect then
		_G.FLOG_INFO("NetworkImplMgr:StopWaiting Reconnect MsgKey=%s", MsgKey)
		_G.NetworkStateMgr:StartReconnect(false, true)
	end
end

---StopAllWaiting
function NetworkImplMgr:StopAllWaiting()
	local WaitingInfos = self.WaitingInfos
	if nil == WaitingInfos then
		return
	end

	self:UnRegisterAllTimer()

	self.WaitingInfos = {}

	EventMgr:SendEvent(EventID.NetworkStopWaiting)
end

---IsMsgEnableResend
---@param MsgID number
---@param SubMsgID number
function NetworkImplMgr:IsMsgEnableResend(MsgID, SubMsgID)
	if nil == NetworkMsgConfig then
		_G.FLOG_ERROR("NetworkImplMgr:IsMsgEnableResend NetworkMsgConfig is nil")
		return false
	end

	local Config = NetworkMsgConfig.GetSendMsgConfig(MsgID, SubMsgID)
	if nil == Config then
		--_G.FLOG_INFO("NetworkImplMgr:IsMsgEnableResend Config is nil MsgID=%d SubMsgID=%d", MsgID, SubMsgID)
		return false
	end

	--if not Config.bResend then
	--	_G.FLOG_INFO("NetworkImplMgr:IsMsgEnableResend bResend is false MsgID=%d SubMsgID=%d", MsgID, SubMsgID)
	--end

	return Config.bResend
end

return NetworkImplMgr