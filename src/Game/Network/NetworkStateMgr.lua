--
-- Author: anypkvcai
-- Date: 2023-05-30 9:59
-- Description:
--


--[[
多语言ID说明
1260043 提示
1260044	重连失败，是否继续尝试重连？
1260045 返回登录
1260046 继续重连
1260047 退出游戏
1260048 确定
--]]

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")
--local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local NetworkConfig = require("Define/NetworkConfig")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")

local CS_CMD = ProtoCS.CS_CMD
local ConnectorState = NetworkConfig.ConnectorState
local EErrorCode = NetworkConfig.EErrorCode
local ErrorCodeConfig = NetworkConfig.ErrorCodeConfig

local LSTR
local FLOG_INFO
local FLOG_WARNING
local GameNetworkMgr   ---@type GameNetworkMgr
local EventMgr         ---@type EventMgr
local UIViewMgr        ---@type UIViewMgr
local LoginMgr         ---@type LoginMgr
local WorldMsgMgr      ---@type WorldMsgMgr
local NetworkImplMgr   ---@type NetworkImplMgr

--RelayConnect尝试次数
local RELAY_CONNECT_MAX_COUNT = 1

--RelayConnect超时时间
local RELAY_CONNECT_TIMEOUT = 3

--自动Connect尝试次数
local AUTO_CONNECT_MAX_COUNT = 2

--自动Reconnect超时时间
local AUTO_RECONNECT_TIMEOUT = 3

--Reconnect超时时间
local RECONNECT_TIMEOUT = 5

--Reconnect提示的延迟时间
local RECONNECT_SHOW_TIPS_DELAY_TIME = 0.3

---@class NetworkStateMgr : MgrBase
local NetworkStateMgr = LuaClass(MgrBase)

---OnInit
function NetworkStateMgr:OnInit()

end

---OnBegin
function NetworkStateMgr:OnBegin()
	self.bReconnectEnable = false
	self.bRelayConnect = false
	self.bReconnecting = false
	self.bAutoReconnect = true
	self.ReconnectCount = 0

	LSTR = _G.LSTR
	FLOG_INFO = _G.FLOG_INFO
	FLOG_WARNING = _G.FLOG_WARNING
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
	UIViewMgr = _G.UIViewMgr
	LoginMgr = _G.LoginMgr
	WorldMsgMgr = _G.WorldMsgMgr
	NetworkImplMgr = _G.NetworkImplMgr
end

function NetworkStateMgr:OnEnd()
	self.bReconnectEnable = false
	self.bRelayConnect = false
	self.bReconnecting = false
	self.bAutoReconnect = true
	self.ReconnectCount = 0
end

function NetworkStateMgr:OnShutdown()

end

function NetworkStateMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_RECONNECT, 0, self.OnNetMsgReconnect)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGOUT, 0, self.OnNetMsgRoleLogoutRes)
end

function NetworkStateMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.NetworkConnected, self.OnGameEventNetworkConnected)
	self:RegisterGameEvent(EventID.NetworkDisConnected, self.OnGameEventNetworkDisConnected)
	self:RegisterGameEvent(EventID.NetworkStateChanged, self.OnGameEventNetworkStateChanged)
	self:RegisterGameEvent(EventID.NetworkRelayConnected, self.OnGameEventNetworkRelayConnected)
	self:RegisterGameEvent(EventID.NetworkHeartBeatTimeOut, self.OnGameEventNetworkHeartBeatTimeOut)
	self:RegisterGameEvent(EventID.NetworkSendDataFailed, self.OnGameEventNetworkSendDataFailed)
	--self:RegisterGameEvent(EventID.RoleLogoutRes, self.OnGameEventRoleLogoutRes)
end

function NetworkStateMgr:SendReconnectMsg(RoleID, ServerSeq)
	local MsgID = CS_CMD.CS_CMD_RECONNECT

	local MsgBody = {
		RoleID = RoleID,
		ServerSeq = ServerSeq,
	}

	GameNetworkMgr:SendMsg(MsgID, 0, MsgBody)
end

---OnNetMsgReconnect
---@param MsgBody table
function NetworkStateMgr:OnNetMsgReconnect(MsgBody)
	FLOG_INFO("NetworkStateMgr:OnNetMsgReconnect ErrorCode=%s DemoMajorType=%s", MsgBody.ErrorCode, _G.DemoMajorType)

	if MsgBody.ErrorCode then
		self:ReturnToLogin()
		return
	end

	local RoleID = MsgBody.RoleID
	local bNeedLogin = MsgBody.NeedLogin

	if bNeedLogin then
		_G.UE.UGameNetworkMgr.Get():ClearCachedMsg()

		-- if _G.IsDemoMajor then
		if _G.DemoMajorType == 1 then
			_G.LoginUIMgr:BackToProfPhase(true)
			-- local function ReturnToProfPhase()
			-- 	_G.LoginUIMgr:BackToProfPhase(false)
			-- end
		elseif _G.DemoMajorType == 2 then
			_G.LoginUIMgr:BornSceneBackToLoginCreate()
		else
			LoginMgr:ReLogin(RoleID)
		end
	else
		_G.UE.UGameNetworkMgr.Get():ResendCachedMsg(MsgBody.ClientSeq)
	end

	-- 是否闪断 非闪断的情况要重新登录
	local bRelay = not bNeedLogin

	EventMgr:SendEvent(EventID.NetworkReconnected, { RoleID = RoleID, bRelay = bRelay })

	local EventParams = EventMgr:GetEventParams()
	EventParams.ULongParam1 = RoleID
	EventParams.BoolParam1 = bRelay
	EventMgr:SendCppEvent(EventID.NetworkReconnected, EventParams)
end

function NetworkStateMgr:ReturnToLogin()
	self:StopReconnect()
	GameNetworkMgr:Disconnect()
	self.bReconnectEnable = false
	LoginMgr:ReturnToLogin(false)
end

function NetworkStateMgr:OnNetMsgRoleLogoutRes(MsgBody)
	local Reason = MsgBody.Reason
	if ProtoCS.LogoutReason.ExitDemo == Reason or ProtoCS.LogoutReason.SwitchRole == Reason then
		return
	end

	FLOG_INFO("NetworkStateMgr:OnNetMsgRoleLogoutRes")
	GameNetworkMgr:Disconnect()
	self.bReconnectEnable = false
end

function NetworkStateMgr:OnGameEventNetworkConnected(Params)
	local ErrorCode = Params.ErrorCode
	local bSuccess = EErrorCode.kSuccess == ErrorCode
	local bReconnecting = self.bReconnecting

	NetworkImplMgr:StopAllWaiting()

	if bSuccess then
		self.bReconnectEnable = true
		local bLoginScene = WorldMsgMgr:IsLogin()
		FLOG_INFO("NetworkStateMgr:OnGameEventNetworkConnected Success, bReconnecting=%s ReconnectCount=%d bLoginScene=%s", bReconnecting, self.ReconnectCount, bLoginScene)

		EventMgr:SendEvent(EventID.NetworkConnectSuccess, { bReconnect = bReconnecting })

		if bLoginScene then
			if not bReconnecting then
				LoginMgr:SendModuleConfigReq()
			elseif _G.WorldMsgMgr.IsShowLoadingView then
				self:ReturnToLogin()
			end
		else
			self:SendReconnectMsg(MajorUtil.GetMajorRoleID(), _G.UE.UGameNetworkMgr.Get():GetServerMsgSeq())
		end

		self:StopReconnect()

		UIViewMgr:HideView(UIViewID.NetworkReconnectMsgBox, nil, true)
	else
		FLOG_WARNING("NetworkStateMgr:OnGameEventNetworkConnected Failed, bReconnecting=%s ReconnectCount=%d", bReconnecting, self.ReconnectCount)

		self:OnNetworkError(ErrorCode, Params.Extend, bReconnecting)
	end
end

function NetworkStateMgr:OnGameEventNetworkDisConnected(Params)

end

function NetworkStateMgr:OnGameEventNetworkStateChanged(Params)
	if ConnectorState.kConnectorStateError ~= Params.State then
		return
	end

	self:OnNetworkError(Params.ErrorCode, Params.Extend, true)
end

function NetworkStateMgr:OnGameEventNetworkRelayConnected(Params)
	local bSuccess = EErrorCode.kSuccess == Params.ErrorCode
	if bSuccess then
		self:StopReconnect()
	end
end

function NetworkStateMgr:OnGameEventNetworkHeartBeatTimeOut(Params)
	self:StartReconnect(false, true)
end

function NetworkStateMgr:OnGameEventNetworkSendDataFailed(Params)
	self:StartReconnect(true, true)
end

function NetworkStateMgr:OnTimerTimeout()
	local bLoading = _G.PWorldMgr:IsLoadingWorld() or _G.LoadingMgr:IsLoadingView()
	FLOG_INFO("NetworkStateMgr:OnTimerTimeout bLoading=%s", bLoading)

	local ReconnectCount = self.ReconnectCount + 1
	self.ReconnectCount = ReconnectCount

	if self.bRelayConnect then
		if ReconnectCount < RELAY_CONNECT_MAX_COUNT then
			self:Reconnect(true, true)
		else
			self.ReconnectCount = 0
			self:Reconnect(false, true)
		end
	else
		if ReconnectCount < AUTO_CONNECT_MAX_COUNT or bLoading then
			self:Reconnect(false, true)
		else
			local function Continue()
				self:Reconnect(false, false)
			end

			local function ReturnToLogin()
				FLOG_INFO("NetworkStateMgr:OnTimerTimeout ReturnToLogin")
				self:ReturnToLogin(false)
			end

			self:ShowMsgBox(LSTR(1260043), LSTR(1260044), LSTR(1260045), ReturnToLogin, LSTR(1260046), Continue, Continue)
		end
	end
end

function NetworkStateMgr:Reconnect(bRelay, bAuto)
	local bRelayConnect = bRelay and NetworkConfig.RelayEnable

	self.bRelayConnect = bRelayConnect
	self.bAutoReconnect = bAuto

	self:UnRegisterAllTimer()

	if bRelayConnect then
		if GameNetworkMgr:RelayConnect() then
			FLOG_INFO("NetworkStateMgr:Reconnect RelayConnect Success")
		else
			FLOG_INFO("NetworkStateMgr:Reconnect RelayConnect Failed")
		end

		self:RegisterTimer(self.OnTimerTimeout, RELAY_CONNECT_TIMEOUT)
	else
		local Info = GameNetworkMgr:GetLastConnectInfo()
		if nil == Info then
			FLOG_INFO("NetworkStateMgr:Reconnect ReturnToLogin")
			self:ReturnToLogin(false)
			return
		end

		_G.UE.UGameNetworkMgr.Get():Disconnect()
		if GameNetworkMgr:Connect(Info.URL, Info.AuthType, Info.AppID, Info.Channel, Info.OpenID, Info.Token, Info.Expire, Info.ExtInfo) then
			FLOG_INFO("NetworkStateMgr:Reconnect Connect Success")
		else
			FLOG_INFO("NetworkStateMgr:Reconnect Connect Failed")
		end

		self:RegisterTimer(self.OnTimerTimeout, bAuto and AUTO_RECONNECT_TIMEOUT or RECONNECT_TIMEOUT)
	end

	if self.ReconnectCount == 0 then
		local function Callback()
			--弹框时触发事件
			EventMgr:SendEvent(EventID.NetworkReconnectStart)
			UIViewMgr:ShowView(UIViewID.NetworkReconnectTips)
		end

		self:RegisterTimer(Callback, RECONNECT_SHOW_TIPS_DELAY_TIME)
	end
end

function NetworkStateMgr:StartReconnect(bRelay, bAutoReconnect)
	if not NetworkConfig.ReconnectEnable or not self.bReconnectEnable or self.bReconnecting then
		return
	end

	self.bReconnecting = true
	self.ReconnectCount = 0
	self:Reconnect(bRelay, bAutoReconnect)
end

function NetworkStateMgr:StopReconnect()
	self.bRelayConnect = false
	self.bReconnecting = false
	self.bAutoReconnect = false
	self.ReconnectCount = 0
	self:UnRegisterAllTimer()
	UIViewMgr:HideView(UIViewID.NetworkReconnectTips)
end

function NetworkStateMgr:FindErrorCodeConfig(ErrorCode, Extend)
	local Cfg = ErrorCodeConfig[ErrorCode]
	if nil == Cfg then
		return ErrorCodeConfig[EErrorCode.kDefault]
	end

	local ExtendCfg = Cfg[Extend]
	if nil ~= ExtendCfg then
		return ExtendCfg
	end

	return Cfg
end

function NetworkStateMgr:OnNetworkError(ErrorCode, Extend, bReconnect)
	FLOG_INFO("NetworkStateMgr:OnNetworkError, ErrorCode=%s Extend=%s bReconnect=%s", ErrorCode, Extend, bReconnect)

	local Cfg = self:FindErrorCodeConfig(ErrorCode, Extend)
	if nil == Cfg or Cfg.bIgnore then
		return
	end

	if bReconnect and Cfg.bReconnect then
		self:StartReconnect(Cfg.bRelay, true)
		return
	end

	self:StopReconnect()

	self.bReconnectEnable = false

	if Cfg.bQuitGame then
		self:ShowMsgBox(LSTR(1260043), LSTR(Cfg.ErrMsg), LSTR(1260047), CommonUtil.QuitGame, nil, nil, CommonUtil.QuitGame)
	elseif Cfg.bReturnToLogin then
		local function ReturnToLogin()
			self:ReturnToLogin(false)
		end
		self:ShowMsgBox(LSTR(1260043), LSTR(Cfg.ErrMsg), LSTR(1260045), ReturnToLogin, nil, nil, ReturnToLogin)
	else
		self:ShowMsgBox(LSTR(1260043), LSTR(Cfg.ErrMsg), LSTR(1260048))
	end
end

---SetReconnectEnable @修改ReconnectEnable的配置
---@param bEnable boolean
function NetworkStateMgr:SetReconnectEnable(bEnable)
	NetworkConfig.ReconnectEnable = bEnable
end

function NetworkStateMgr:ShowMsgBox(Title, Content, LeftText, LeftCallback, RightText, RightCallback, DefaultCallback)
	local Params = { View = self, Title = Title, Content = Content, LeftText = LeftText, LeftCallback = LeftCallback, RightText = RightText, RightCallback = RightCallback, DefaultCallback = DefaultCallback }
	UIViewMgr:ShowView(UIViewID.NetworkReconnectMsgBox, Params)
end

---Disconnect
function NetworkStateMgr:Disconnect()
	EventMgr:SendEvent(EventID.NetworkStopHeartBeat)
	self:StopReconnect()
	GameNetworkMgr:Disconnect()
	self.bReconnectEnable = false
end

---TestDisconnect @测试断线
---GM界面：客户端->测试->模拟断线
---控制台：Net.Disconnect
function NetworkStateMgr.TestDisconnect()
	NetworkStateMgr:SetReconnectEnable(false)
	_G.UE.UGameNetworkMgr.Get():Disconnect()
end

---TestReconnect @测试重连
---GM界面：客户端->测试->模拟重连
---控制台：Net.Reconnect
function NetworkStateMgr.TestReconnect()
	NetworkStateMgr:SetReconnectEnable(true)
	NetworkStateMgr:StartReconnect(false, false)
end

return NetworkStateMgr

