--
-- Author: anypkvcai
-- Date: 2020-08-06 14:08:03
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonDefine = require("Define/CommonDefine")
local ProtoBuff = require("Network/ProtoBuff")
local CommonUtil = require("Utils/CommonUtil")
local NetworkConfig = require("Define/NetworkConfig")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local NetworkUtil = require("Network/NetworkUtil")
local Json = require("Core/Json")

local UGameNetworkMgr
--local EErrorCode
local FLOG_ERROR
local FLOG_INFO
--local LSTR
local XPCall

---@class GameNetworkMgr : MgrBase
local GameNetworkMgr = LuaClass(MgrBase)

function GameNetworkMgr:OnInit()
	self.Subscriptions = {}
	self.Impl = nil
	self.bConnected = false

	ProtoBuff:LoadProtoBP()
end

function GameNetworkMgr:OnBegin()
	UGameNetworkMgr = _G.UE.UGameNetworkMgr.Get()
	UGameNetworkMgr:SetEnableResend(true)
	--UGameNetworkMgr:SetEnableDiscardMsg(true)
	--EErrorCode = NetworkConfig.EErrorCode
	FLOG_ERROR = _G.FLOG_ERROR
	FLOG_INFO = _G.FLOG_INFO
	--LSTR = _G.LSTR
	XPCall = CommonUtil.XPCall
end

function GameNetworkMgr:OnEnd()
	self.bConnected = false

	self:UnRegisterAllMsg()
end

function GameNetworkMgr:OnShutdown()
	ProtoBuff:UnLoadProtoBP()

	self.Subscriptions = nil
	self.Impl = nil
end

function GameNetworkMgr:SetImpl(Impl)
	self.Impl = Impl
end

---RegisterMsg
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number
---@param Listener table | nil  @如果回调函数是类成员函数 Listener为self 其他情况为nil
---@param Callback function    @回调函数
---@param ListenerName string
function GameNetworkMgr:RegisterMsg(MsgID, SubMsgID, Listener, Callback, ListenerName)
	if nil == MsgID then
		FLOG_ERROR("GameNetworkMgr: RegisterMsg MsgID is nil!")
		return
	end

	if nil == SubMsgID then
		FLOG_ERROR("GameNetworkMgr: RegisterMsg SubMsgID is nil!")
		return
	end

	local MsgKey = NetworkUtil.GetMsgKey(MsgID, SubMsgID)
	if self:IsCallbackRegistered(MsgKey, Callback) then
		FLOG_ERROR(string.format("GameNetworkMgr: Callback is already registered, MsgID=%d SubMsgID=%d", MsgID, SubMsgID))
		return
	end

	UGameNetworkMgr:SetRegisteredMsg(MsgKey, true)

	local Subscription = self.Subscriptions[MsgKey]
	if nil == Subscription then
		Subscription = {}
		self.Subscriptions[MsgKey] = Subscription
	end

	table.insert(Subscription, { Listener = Listener, Callback = Callback, ListenerName = ListenerName })
end

---IsCallbackRegistered
---@param MsgKey number
---@param Callback function
function GameNetworkMgr:IsCallbackRegistered(MsgKey, Callback)
	local Subscription = self.Subscriptions[MsgKey]
	if nil == Subscription then
		return false
	end

	for i = 1, #Subscription do
		local v = Subscription[i]
		if v.Callback == Callback then
			return true
		end
	end

	return false
end

---IsMsgRegistered
---@param MsgKey number
function GameNetworkMgr:IsMsgRegistered(MsgKey)
	local Subscription = self.Subscriptions[MsgKey]
	if nil == Subscription then
		return false
	end

	return #Subscription > 0
end

---UnRegisterMsg
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number
---@param Listener table | nil  @如果回调函数是类成员函数 Listener为self 其他情况为nil
function GameNetworkMgr:UnRegisterMsg(MsgID, SubMsgID, Listener)
	local MsgKey = NetworkUtil.GetMsgKey(MsgID, SubMsgID)

	local Subscription = self.Subscriptions[MsgKey]
	if nil == Subscription then
		return
	end

	for i = 1, #Subscription do
		local v = Subscription[i]
		if nil ~= v and v.Listener == Listener then
			table.remove(Subscription, i)
			if #Subscription == 0 then
				UGameNetworkMgr:SetRegisteredMsg(MsgKey, false)
				self.Subscriptions[MsgKey] = nil
			end
			return
		end
	end
end

---UnRegisterAllMsg
function GameNetworkMgr:UnRegisterAllMsg()
	local Subscription = self.Subscriptions
	if Subscription then
		for k, _ in pairs(Subscription) do
			UGameNetworkMgr:SetRegisteredMsg(k, false)
		end
		self.Subscriptions = {}
	end
end

-- MsgID反查协议名称
local IdToNameMap = nil

local function IDToName(MsgID)
	if not IdToNameMap then
		IdToNameMap = {}
		local ProtoCS = require("Protocol/ProtoCS")
		for key, value in pairs(ProtoCS.CS_CMD) do
			IdToNameMap[value] = key
		end
	end
	return IdToNameMap[MsgID] or "Unknown"
end

---SendMsg
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number        @消息子ID ProtoCS.CS_SUBMSGID_TEAM ProtoCS.CS_COMBAT_CMD
---@param MsgBody table            @消息包内容 不包含包头 packet.proto中定义的cmd_req_name和cmd_res_name对应的内容
function GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	if not self.bConnected then
		return
	end

	local Impl = self.Impl
	if nil ~= Impl then
		if not Impl:OnTrySendMsg(MsgID, SubMsgID) then
			return
		end
	end

	--local _ <close> = CommonUtil.MakeProfileTag(string.format("GameNetworkMgr:SendMsg_Log_%s_%d", IDToName(MsgID), SubMsgID))

	local ProtoName = NetworkUtil.GetProtoReqName(MsgID)
	if nil == ProtoName then
		FLOG_ERROR("GameNetworkMgr:SendMsg proto name is null! MsgID=%d SubMsgID=%d", MsgID, SubMsgID)
		return
	end

	local Buffer = ProtoBuff:Encode(ProtoName, MsgBody)

	local bResend = self:IsMsgEnableResend(MsgID, SubMsgID)
	UGameNetworkMgr:SendData(MsgID, SubMsgID, Buffer, string.len(Buffer), bResend)

	if nil ~= Impl then
		Impl:OnSendMsg(MsgID, SubMsgID)
	end

	if self:IsEnableLog(MsgID, SubMsgID) then
		--local _ <close> = CommonUtil.MakeProfileTag("GameNetworkMgr:SendMsg_Log")
		local Body = ProtoBuff:Decode(ProtoName, Buffer)
		local ConvertedMsg = table.convert_keys_to_strings(Body)
		FLOG_INFO("GameNetworkMgr:SendMsg MsgIDKey=%s MsgID=%d SubMsgID=%d MsgLength=%d ClientSeq=%d MsgBody=%s",
				IDToName(MsgID), MsgID, SubMsgID, string.len(Buffer), UGameNetworkMgr:GetClientMsgSeq(), Json.encode(ConvertedMsg))
	end
end

---DispatchMsg
---@param MsgID number             @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number          @子消息ID
---@param MsgBody table            @消息包内容 不包含包头 packet.proto中定义的cmd_req_name和cmd_res_name对应的内容
function GameNetworkMgr:DispatchMsg(MsgID, SubMsgID, MsgBody)
	local MsgKey = NetworkUtil.GetMsgKey(MsgID, SubMsgID)

	local Subscription = self.Subscriptions[MsgKey]
	if nil == Subscription or #Subscription <= 0 then
		return
	end

	--local _ <close> = CommonUtil.MakeProfileTag(string.format("GameNetworkMgr:DispatchMsg_%s", IDToName(MsgID)))

	for i = #Subscription, 1, -1 do
		local v = Subscription[i]
		if nil ~= v and nil ~= v.Callback then
			local _ <close> = CommonUtil.MakeProfileTag(v.ListenerName)
			XPCall(v.Listener, v.Callback, MsgBody)
		end
	end
end

---OnReceiveMsg
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number         @消息子ID ProtoCS.CS_SUBMSGID_TEAM ProtoCS.CS_COMBAT_CMD
---@param BodyBuffer string
---@param BodyLen number
---@param ServerSeq number
---@param ClientSeq number
function GameNetworkMgr:OnReceiveMsg(MsgID, SubMsgID, BodyBuffer, BodyLen, ServerSeq, ClientSeq)
	local ProtoName = NetworkUtil.GetProtoResName(MsgID)
	if nil == ProtoName then
		FLOG_ERROR("GameNetworkMgr:OnReceiveMsg proto name is null! MsgID=%d SubMsgID=%d", MsgID, SubMsgID)
		return
	end

	local MsgName = IDToName(MsgID)
	local MsgBody
	do
		local _ <close> = CommonUtil.MakeProfileTag("GameNetworkMgr:OnReceiveMsg_Decode")
		MsgBody = ProtoBuff:Decode(ProtoName, BodyBuffer)
	end

	if self:IsEnableLog(MsgID, SubMsgID) then
		local _ <close> = CommonUtil.MakeProfileTag("GameNetworkMgr:OnReceiveMsg_Log")
		local ConvertedMsg = table.convert_keys_to_strings(MsgBody)
		FLOG_INFO("GameNetworkMgr:OnReceiveMsg MsgIDKey=%s MsgID=%d SubMsgID=%d MsgLength=%d ServerSeq=%d ClientSeq=%d MsgBody=%s",
				MsgName, MsgID, SubMsgID, BodyLen, ServerSeq, ClientSeq, Json.encode(ConvertedMsg))
		if _G.AutoTest.CatchGMRecvMsg == true then
			local _ <close> = CommonUtil.MakeProfileTag("GameNetworkMgr:OnReceiveMsg_AutoTest")
			if _G.AutoTest.GMCmd == "" or _G.AutoTest.GMSvr == "" then
				_G.AutoTest.CatchGMRecvMsg = false
				_G.AutoTest.GetLuaReturnVal(table.tostring(MsgBody))
			else
				if MsgBody["Cmd"] == _G.AutoTest.GMCmd and MsgBody["Svr"] == _G.AutoTest.GMSvr then
					_G.AutoTest.CatchGMRecvMsg = false
					_G.AutoTest.GMCmd = ""
					_G.AutoTest.GMSvr = ""
					_G.AutoTest.GetLuaReturnVal(table.tostring(MsgBody))
				end
			end
		end
	end

	local Impl = self.Impl
	if nil ~= Impl then
		Impl:OnReceiveMsg(MsgID, SubMsgID)
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("GameNetworkMgr:OnReceiveMsg_Dispatch_%s_%d", MsgName, SubMsgID))
	self:DispatchMsg(MsgID, SubMsgID, MsgBody)
end

---Connect
---@param URL string                 @Server URL
---@param AuthType number            @GCloud::Conn::AuthType
---@param AppID string               @AppID
---@param Channel number             @Channel
---@param OpenID string              @Use OpenID
---@param Token string               @Token
---@param Expire number              @Expire
---@param ExtInfo string             @ExtInfo
function GameNetworkMgr:Connect(URL, AuthType, AppID, Channel, OpenID, Token, Expire, ExtInfo)
	self.LastConnectInfo = { URL = URL, AuthType = AuthType, AppID = AppID, Channel = Channel, OpenID = OpenID, Token = Token, Expire = Expire, ExtInfo = ExtInfo }
	local bConnected = UGameNetworkMgr:Connect(URL, AuthType, AppID, Channel, OpenID, Token, Expire, ExtInfo)
	if bConnected then
		self.bConnected = true
	end

	return bConnected
end

---RelayConnect
function GameNetworkMgr:RelayConnect()
	return UGameNetworkMgr:RelayConnect()
end

---Disconnect
function GameNetworkMgr:Disconnect()
	self.bConnected = false
	UGameNetworkMgr:ClearCachedMsg()
	UGameNetworkMgr:SetClientMsgSeq(0)
	UGameNetworkMgr:Disconnect()
end

---IsEnableLog
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number
function GameNetworkMgr:IsEnableLog(MsgID, SubMsgID)
	local IsConsoleEnableAllLog = UGameNetworkMgr.IsConsoleEnableAllLog
	if nil ~= IsConsoleEnableAllLog and IsConsoleEnableAllLog() then
		return true
	end

	return self:IsShowNetworkLog(MsgID, SubMsgID)
end

---IsEnableMsgLog
function GameNetworkMgr:CheckShowNetworkLog()
	local IsConsoleEnableLog = UGameNetworkMgr.IsConsoleEnableLog
	if nil ~= IsConsoleEnableLog and IsConsoleEnableLog() then
		return true
	end

	if not CommonDefine.bShowNetworkLog then
		return false
	end

	return true
end

---IsShowNetworkLog
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number
function GameNetworkMgr:IsShowNetworkLog(MsgID, SubMsgID)
	if not self:CheckShowNetworkLog() then
		return false
	end

	local LogBlackList = NetworkConfig.LogBlackList
	for i = 1, #LogBlackList do
		if LogBlackList[i] == MsgID then
			return false
		end
	end

	return true
end

---IsMsgEnableResend
---@param MsgID number
---@param SubMsgID number
function GameNetworkMgr:IsMsgEnableResend(MsgID, SubMsgID)
	local Impl = self.Impl
	if nil ~= Impl then
		return Impl:IsMsgEnableResend(MsgID, SubMsgID)
	end

	return false
end

---IsConnected
function GameNetworkMgr:IsConnected()
	return self.bConnected
end

function GameNetworkMgr:GetLastConnectInfo()
	return self.LastConnectInfo
end

---SetMsgToDiscard 设置是否丢弃网络包
---@param MsgID number
---@param SubMsgID number
---@param bDiscard boolean
function GameNetworkMgr:SetMsgToDiscard(MsgID, SubMsgID, bDiscard)
	if UGameNetworkMgr then
		UGameNetworkMgr:SetMsgToDiscard(MsgID, SubMsgID, bDiscard)
	end
end

---OnConnected
---@param ErrorCode number
---@param Extend number
---@param Extend2 number
---@param Extend3 number
function GameNetworkMgr.OnConnected(ErrorCode, Extend, Extend2, Extend3, Reason)
	FLOG_INFO("GameNetworkMgr.OnConnected ErrorCode=%d Extend=%d Extend2=%d Extend3=%d Reason=%s", ErrorCode, Extend, Extend2, Extend3, Reason)

	local Params = { ErrorCode = ErrorCode, Extend = Extend, Extend2 = Extend2, Extend3 = Extend3, Reason = Reason }
	EventMgr:SendEvent(EventID.NetworkConnected, Params)
end

---OnDisconnectProc
---@param ErrorCode number
---@param Extend number
---@param Extend2 number
---@param Extend3 number
function GameNetworkMgr.OnDisconnectProc(ErrorCode, Extend, Extend2, Extend3, Reason)
	FLOG_INFO("GameNetworkMgr.OnDisconnectProc ErrorCode=%d Extend=%d Extend2=%d Extend3=%d Reason=%s", ErrorCode, Extend, Extend2, Extend3, Reason)

	local Params = { ErrorCode = ErrorCode, Extend = Extend, Extend2 = Extend2, Extend3 = Extend3, Reason = Reason }
	EventMgr:SendEvent(EventID.NetworkDisConnected, Params)
end

---OnStateChangedProc
---@param State number
---@param ErrorCode number
---@param Extend number
---@param Extend2 number
---@param Extend3 number
function GameNetworkMgr.OnStateChangedProc(State, ErrorCode, Extend, Extend2, Extend3, Reason)
	FLOG_INFO("GameNetworkMgr.OnStateChangedProc ErrorCode=%d Extend=%d Extend2=%d Extend3=%d Reason=%s", ErrorCode, Extend, Extend2, Extend3, Reason)

	local Params = { State = State, ErrorCode = ErrorCode, Extend = Extend, Extend2 = Extend2, Extend3 = Extend3, Reason = Reason }
	EventMgr:SendEvent(EventID.NetworkStateChanged, Params)
end

---OnDataRecvedProc
---@param MsgID number            @消息ID  ProtoCS.CS_CMD
---@param SubMsgID number
---@param BodyBuffer string
---@param ExtendBuffer number
---@param ErrorCode number
---@param Extend number
---@param Extend2 number
---@param Extend3 number
function GameNetworkMgr.OnDataRecvedProc(MsgID, SubMsgID, BodyBuffer, ExtendBuffer, ErrorCode, Extend, Extend2, Extend3, Reason, ServerSeq, ClientSeq)
	GameNetworkMgr:OnReceiveMsg(MsgID, SubMsgID, BodyBuffer, string.len(BodyBuffer), ServerSeq, ClientSeq)
end

---OnRelayConnectedProc
---@param ErrorCode number
---@param Extend number
---@param Extend2 number
---@param Extend3 number
function GameNetworkMgr.OnRelayConnectedProc(ErrorCode, Extend, Extend2, Extend3, Reason)
	FLOG_INFO("GameNetworkMgr.OnRelayConnectedProc ErrorCode=%d Extend=%d Extend2=%d Extend3=%d Reason=%s", ErrorCode, Extend, Extend2, Extend3, Reason)

	local Params = { ErrorCode = ErrorCode, Extend = Extend, Extend2 = Extend2, Extend3 = Extend3, Reason = Reason }
	EventMgr:SendEvent(EventID.NetworkRelayConnected, Params)
end

---OnUDPDataRecvedProc
---@param Buffer string
---@param ErrorCode number
---@param Extend number
---@param Extend2 number
---@param Extend3 number
function GameNetworkMgr.OnUDPDataRecvedProc(Buffer, ErrorCode, Extend, Extend2, Extend3, Reason)
	FLOG_INFO("GameNetworkMgr.OnUDPDataRecvedProc", Buffer, ErrorCode, Extend, Extend2, Extend3, Reason)

end

---OnRouteChangedProc
---@param EntityID number
---@param ErrorCode number
---@param Extend number
---@param Extend2 number
---@param Extend3 number
function GameNetworkMgr.OnRouteChangedProc(EntityID, ErrorCode, Extend, Extend2, Extend3, Reason)
	FLOG_INFO("GameNetworkMgr.OnRouteChangedProc", EntityID, ErrorCode, Extend, Extend2, Extend3, Reason)

end

---OnPingProc
---@param Seq number
---@param Rtt number
function GameNetworkMgr.OnPingProc(Seq, Rtt)
	FLOG_INFO("GameNetworkMgr.OnPingProc", Seq, Rtt)

end

return GameNetworkMgr