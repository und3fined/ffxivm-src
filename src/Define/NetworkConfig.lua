--
-- Author: anypkvcai
-- Date: 2020-09-12 16:33:08
-- Description:
--

local ProtoCS = require("Protocol/ProtoCS")

local CS_CMD = ProtoCS.CS_CMD
local LSTR = _G.LSTR

local ConnectorState = {
	kConnectorStateRunning = 0,
	kConnectorStateReconnecting = 1, -- Reconnecting to the server
	kConnectorStateReconnected = 2,
	kConnectorStateStayInQueue = 3, -- In queue
	kConnectorStateError = 4, -- Error occured
}

local EErrorCode = {
	-- Common
	kDefault = -1,
	kSuccess = 0,
	kErrorInnerError = 1,
	kErrorNetworkException = 2,
	kErrorTimeout = 3,
	kErrorInvalidArgument = 4,
	kErrorLengthError = 5,
	kErrorUnknown = 6,
	kErrorEmpty = 7,

	kErrorNotInitialized = 9,
	kErrorNotSupported = 10,
	kErrorNotInstalled = 11,
	kErrorSystemError = 12,
	kErrorNoPermission = 13,
	kErrorInvalidGameId = 14,

	-- AccountService, from 100
	kErrorInvalidToken = 100,
	kErrorNoToken = 101,
	kErrorAccessTokenExpired = 102,
	kErrorRefreshTokenExpired = 103,
	kErrorPayTokenExpired = 104,
	kErrorLoginFailed = 105,
	kErrorUserCancel = 106,
	kErrorUserDenied = 107,
	kErrorChecking = 108,
	kErrorNeedRealNameAuth = 109,

	-- Connector, from 200
	kErrorNoConnection = 200,
	kErrorConnectFailed = 201,
	kErrorIsConnecting = 202,
	kErrorGcpError = 203,
	kErrorPeerCloseConnection = 204,
	kErrorPeerStopSession = 205,
	kErrorPkgNotCompleted = 206,
	kErrorSendError = 207,
	kErrorRecvError = 208,
	kErrorStayInQueue = 209,
	kErrorSvrIsFull = 210,
	kErrorTokenSvrError = 211,
	kErrorAuthFailed = 212,
	kErrorOverflow = 213,
	kErrorDNS = 214,
}

local ErrorCodeConfig = {
	[EErrorCode.kDefault] = { bIgnore = true, bReconnect = false, bRelay = false, bQuitGame = false, ErrMsg = 1260001 }, --网络异常
	[EErrorCode.kSuccess] = { bReconnect = false, bRelay = false, bQuitGame = false, ErrMsg = 1260002 }, --成功
	[EErrorCode.kErrorInnerError] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260003 }, --内部错误
	[EErrorCode.kErrorNetworkException] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260004 }, --连接失败
	[EErrorCode.kErrorTimeout] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260005 }, --网络超时
	[EErrorCode.kErrorInvalidArgument] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260006 }, --参数错误
	[EErrorCode.kErrorLengthError] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260007 }, --长度错误
	[EErrorCode.kErrorUnknown] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260008 }, --未知错误
	[EErrorCode.kErrorEmpty] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260009 }, --网络错误

	[EErrorCode.kErrorNotInitialized] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260010 }, --没有初始化
	[EErrorCode.kErrorNotSupported] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260011 }, --不支持
	[EErrorCode.kErrorNotInstalled] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260012 }, --未安装
	[EErrorCode.kErrorSystemError] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260013 }, --系统错误
	[EErrorCode.kErrorNoPermission] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260014 }, --没有权限
	[EErrorCode.kErrorInvalidGameId] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260015 }, --无效的GameID

	[EErrorCode.kErrorInvalidToken] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260016 }, --无效的Token
	[EErrorCode.kErrorNoToken] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260017 }, --缺少Token
	[EErrorCode.kErrorAccessTokenExpired] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260018 }, --AccessToken失效
	[EErrorCode.kErrorRefreshTokenExpired] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260019 }, --RefreshToken过期
	[EErrorCode.kErrorPayTokenExpired] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260020 }, --PayToken过期
	[EErrorCode.kErrorLoginFailed] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260021 }, --登录失败
	[EErrorCode.kErrorUserCancel] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260022 }, --用户取消
	[EErrorCode.kErrorUserDenied] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260023 }, --用户禁止
	[EErrorCode.kErrorChecking] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260024 }, --正在检查
	[EErrorCode.kErrorNeedRealNameAuth] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260025 }, --请先进行实名认证

	[EErrorCode.kErrorNoConnection] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260026 }, --未连接服务器
	[EErrorCode.kErrorConnectFailed] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260027 }, --连接失败，当前无网络或者服务器不可达
	[EErrorCode.kErrorIsConnecting] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260028 }, --正在连接，请稍后再试
	[EErrorCode.kErrorGcpError] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260029 }, --内部异常
	[EErrorCode.kErrorPeerCloseConnection] = {
		bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260030, --无法连接到服务器
		[-10] = { bReconnect = true, bRelay = false, bReturnToLogin = false, ErrMsg = 1260030 } --无法连接到服务器
	},
	[EErrorCode.kErrorPeerStopSession] = {
		bReconnect = true, bRelay = true, bReturnToLogin = false, ErrMsg = 1260031, --对端关闭会话
		[7] = { bIgnore = true },
	},
	[EErrorCode.kErrorPkgNotCompleted] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260032 }, --客户端文件不完整
	[EErrorCode.kErrorSendError] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260033 }, --发送错误
	[EErrorCode.kErrorRecvError] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260034 }, --接收错误
	[EErrorCode.kErrorStayInQueue] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260035 }, --当前服务器人数较多，需要排队登录
	[EErrorCode.kErrorSvrIsFull] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260036 }, --服务器人数已满
	[EErrorCode.kErrorTokenSvrError] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260037 }, --安全服务器异常
	[EErrorCode.kErrorAuthFailed] = { bReconnect = false, bRelay = true, bReturnToLogin = true, ErrMsg = 1260038 }, --鉴权失败
	[EErrorCode.kErrorOverflow] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260039 }, --内部buffer溢出
	[EErrorCode.kErrorDNS] = { bReconnect = true, bRelay = true, bQuitGame = false, ErrMsg = 1260040 }, --DNS解析失败
}

local LogBlackList = {
	CS_CMD.CS_CMD_HEARTBEAT,
	CS_CMD.CS_CMD_MOVE,
	CS_CMD.CS_CMD_COMBAT,
	CS_CMD.CS_CMD_TARGET,
	CS_CMD.CS_CMD_VISION,
	CS_CMD.CS_CMD_LATENCY,
	CS_CMD.CS_CMD_CHOCOBO_RACE,
	CS_CMD.CS_CMD_WEATHER,
	CS_CMD.CS_CMD_CLOSET,
	CS_CMD.CS_CMD_FOG,
	CS_CMD.CS_CMD_PROF,
	CS_CMD.CS_CMD_BAG,
}

---@class NetworkConfig
local NetworkConfig = {
	ConnectorState = ConnectorState,

	EErrorCode = EErrorCode,

	ErrorCodeConfig = ErrorCodeConfig,

	LogBlackList = LogBlackList,

	--断线重连是否生效
	ReconnectEnable = true,

	-- Relay是否生效
	RelayEnable = false,
}

return NetworkConfig