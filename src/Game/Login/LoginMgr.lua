--
-- Author: anypkvcai
-- Date: 2020-08-06 10:32:07
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local RaceCfg = require("TableCfg/RaceCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ModuleType = ProtoRes.module_type

local MSDKDefine = require("Define/MSDKDefine")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local NetworkConfig = require("Define/NetworkConfig")
local SaveKey = require("Define/SaveKey")
local CommonUtil = require("Utils/CommonUtil")
local UIUtil = require("Utils/UIUtil")
local ActorMgr = require("Game/Actor/ActorMgr")
local DataReportUtil = require("Utils/DataReportUtil")
local Json = require("Core/Json")
local PathMgr = require("Path/PathMgr")
local VoiceDefine = require("Game/Voice/VoiceDefine")

local LoginRoleMainPanelVM = require("Game/LoginRole/LoginRoleMainPanelVM")
local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.SampleCmd
local LogoutReason = ProtoCS.LogoutReason
local SUB_MSG_ID = ProtoCS.Profile.Mix.CsMixNotifyClientCmd

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LoginConfig = require("Define/LoginConfig")
local UILayer = require("UI/UILayer")
local OperationUtil = require("Utils/OperationUtil")
local LoginUtils = require("Game/LoginNew/LoginUtils")
local GlobalCfg = require("TableCfg/GlobalCfg")
local HttpDNSUtil = require("Utils/HttpDNSUtil")

local LSTR
local FLOG_INFO
local FLOG_WARNING
local FLOG_ERROR
local GameNetworkMgr

local VersionMgr = _G.UE.UVersionMgr

local MapleErrorCode = {
	TimeOut = 3,
	SystemErr = 12,
	SendErr = 207,
	RecvErr = 208,
}

_G.DataReportLoginPhase = 
{
	LoginCreateRaceGender = 21,	--	种族性别选择界面
	LoginCreateTribe = 22,
	LoginCreateAvatar = 23,
	LoginCreateCustomAppearance = 24,
	LoginCreateBirthday = 25,
	LoginCreateGod = 26,
	LoginCreateProf = 27,
	LoginCreateMakeName = 28,
	LoginCreateFinish = 29,
}

---@class LoginMgr : MgrBase
local LoginMgr = LuaClass(MgrBase)

function LoginMgr:OnInit()
	self.OpenID = nil
	self.Token = nil
	self.ChannelID = nil
	self.WorldID = nil
	self.WorldState = nil
	self.OverseasSvrAreaId = LoginNewDefine.OverseasSvrAreaId.None
	self.tbRoleSimple = nil
	self.RoleID = nil
	self.RoleDetail = nil
	self.SwitchList = nil
	self.EnableWaterMark = false
	self.LastRoleLogOutReason = nil
	self.IsWaitRoleListMsg = false
	self.ConnectUrlIndex = 0

	---所有区服数据节点
	---@type table<number, ServerListItem>
	self.AllMapleNodeInfo = {}
	---所有区服数据节点
	---@type table<number, RoleItem>
	self.AllMyRoles = nil
	-- 区服信息
	self.TreeInfo = nil

	-- 是否点击进入游戏，在点击进入游戏后界面所有操作都禁止
	self.IsStartGame = false

	--是否重连成功 true=成功(不会返回登陆) false则是从登陆进来的
	self.bReconnect = false

	self.NickName = ""
	self.AvatarUrl = ""
	self.RegChannelDis = ""
	self.IsLoginSuccess = false
	self.IsNeedSwitchAccountByWakeUp = false
	self.IsNeedChangeWeChatAccount = false
	self.IsNeedChangeQQAccount = false
	self.IsWechatWakeUp = false
	self.IsQQWakeUp = false
	self.IsNeedLoginFromGameCenter = false
	-- 从游戏中心拉起游戏并触发异账号
	self.IsWakeUpFromLaunch = false

	self.bRoleLogin = false
	-- 是否排队结束
	self.IsLoginQueueFinish = false
	-- 是否账号注销
	self.IsAccountCancellation = false
	-- 是否退出登录
	self.IsNeedLogout = false

	-- 登录界面进入游戏失败次数
	self.LoginFailCount = 0
	-- 登录界面进入游戏失败之后重试次数
	self.LoginRetryCount = 0

	self.bCancelAccountCancellation = false

	-- 是否正在显示中控提示界面
	self.bShowHopeView = false
	-- 是否正在显示中控Web页面
	self.bShowPrajnaWebView = false

	-- MSDK登录参数
	self.MSDKLoginParam = nil

	-- 是否正在播放视频
	self.IsMoviePlaying = false
end

function LoginMgr:OnBegin()
	LSTR = _G.LSTR
	FLOG_INFO = _G.FLOG_INFO
	FLOG_WARNING = _G.FLOG_WARNING
	FLOG_ERROR = _G.FLOG_ERROR
	GameNetworkMgr = _G.GameNetworkMgr

	self.bBackToSelectRoleFromCreate = false

	DataReportUtil.SendPublicIPAddressInfoRequest()
end

function LoginMgr:OnEnd()
end

function LoginMgr:OnShutdown()
	-- GameNetworkMgr:UnRegisterMsg(self, CS_CMD.CS_CMD_QUERY_ROLELIST, self.OnNetMsgQueryRoleListByOpenIDRes)
	-- GameNetworkMgr:UnRegisterMsg(self, CS_CMD.CS_CMD_REGISTER, self.OnNetMsgRegisterRoleRes)
	self.LastRoleLogOutReason = nil
	self.IsWaitRoleListMsg = false
end

function LoginMgr:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.NetworkConnected, self.OnGameEventNetworkConnected)
	self:RegisterGameEvent(EventID.MSDKBaseRetNotify, self.OnGameEventMSDKBaseRetNotify)
	self:RegisterGameEvent(EventID.MSDKLoginRetNotify, self.OnGameEventMSDKLoginRetNotify)
	self:RegisterGameEvent(EventID.NetworkConnected, self.OnGameEventNetworkConnected)
	self:RegisterGameEvent(EventID.MapleNotify, self.OnGameEventMapleNotify)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldMapExit)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
    self:RegisterGameEvent(EventID.NetworkReconnectStart, self.OnReconnectStart)
	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
	self:RegisterGameEvent(EventID.MSDKWebViewOptNotify, self.OnGameEventWebViewOptNotify)
	self:RegisterGameEvent(EventID.NetworkReconnected, self.OnGameEventNetworkReconnected)
end

function LoginMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_ROLELIST, 0, self.OnNetMsgQueryRoleListByOpenIDRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_REGISTER, 0, self.OnNetMsgRegisterRoleRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SAMPLE, CS_SUB_CMD.SampleCmdRegister, self.OnNetMsgSampleRegisterRes)	--技能体验相关的回包
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SAMPLE, CS_SUB_CMD.SampleCmdLogin, self.OnNetMsgDemoRoleLoginRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SAMPLE, CS_SUB_CMD.SampleCmdEnter, self.OnNetMsgDemoLoginEnter)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SAMPLE, CS_SUB_CMD.SampleCmdExit, self.OnNetMsgDemoLoginExit)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHECK_NAME, 0, self.OnNetMsgCheckName)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGIN, 0, self.OnNetMsgRoleLoginRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGOUT, 0, self.OnNetMsgRoleLogoutRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGIN_ENTER, 0, self.OnNetMsgLoginEnter)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CONFIG, 0, self.OnNetMsgModuleConfigRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_HOPE, ProtoCS.CS_HOPE_CMD.CS_CMD_HOPE_EXECUTEINSTRUCTION, self.OnGameEventNetworkHopeRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASY_MEDICINE, 0, self.OnGameEventNetworkFantasyMedicineRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MIXNOTIFY, SUB_MSG_ID.CS_MIX_UPDATE_CLIENT, self.OnNetMsgUpdateClientRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MIXNOTIFY, SUB_MSG_ID.CS_MIX_CLIENT_CMD, self.OnNetMsgMixNotify)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MIXNOTIFY, SUB_MSG_ID.CS_MIX_PLAYER_GVOICE, self.OnNetMsgMixNotifyGVoice)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MIXNOTIFY, SUB_MSG_ID.CS_MIX_PLAYER_PRIVACY, self.OnNetMsgPlayerPrivacyRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PLAYPRIVACY, 0, self.OnNetMsgPlayPrivacyRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
end

function LoginMgr:OnGameEventMSDKBaseRetNotify(BaseRet)
	local RetCode = BaseRet[MSDKDefine.ClassMembers.BaseRet.RetCode]
	local MethodNameID = BaseRet[MSDKDefine.ClassMembers.BaseRet.MethodNameID]
	local RetMsg = BaseRet[MSDKDefine.ClassMembers.BaseRet.RetMsg]
	local ThirdCode = BaseRet[MSDKDefine.ClassMembers.BaseRet.ThirdCode]
	local ThirdMsg = BaseRet[MSDKDefine.ClassMembers.BaseRet.ThirdMsg]
	local ExtraJson = BaseRet[MSDKDefine.ClassMembers.BaseRet.ExtraJson]
	FLOG_INFO("LoginMgr:OnGameEventMSDKBaseRetNotify, MethodNameID: %d, RetCode: %d, RetMsg: %s, ThirdCode: %d, ThirdMsg: %s, ExtraJson: %s",
		MethodNameID, RetCode, RetMsg, ThirdCode, ThirdMsg, ExtraJson)

	if RetCode ~= MSDKDefine.MSDKError.NEED_REALNAME and RetCode ~= MSDKDefine.MSDKError.REALNAME_FAIL then
		self.bShowPrajnaWebView = false
	end

	if (MethodNameID == MSDKDefine.MethodName.Logout) or (RetCode == MSDKDefine.MSDKError.REALNAME_FAIL and nil ~= self.MSDKModal and self.MSDKModal == 1) then
		FLOG_INFO("MSDK log out by base ret")
		self:RoleLogOut(ProtoCS.LogoutReason.Logout)

		if self.bShowHopeView then
			self.IsNeedLogout = true
			EventMgr:SendEvent(EventID.DoLogoutEvent)
		end
	end

	if MethodNameID == MSDKDefine.MethodName.WakeUp then
		self:OnWakeUpSuccess(ExtraJson)
		if RetCode == MSDKDefine.MSDKError.LOGIN_NEED_SELECT_ACCOUNT then
			local CurWorldName = _G.WorldMsgMgr:GetWorldName()
			if CurWorldName == "LightSpeed" or CurWorldName == "Login" then
				self.IsWakeUpFromLaunch = true
			end

			self:OnWakeUpNeedSelectAccount()
		elseif RetCode == MSDKDefine.MSDKError.LOGIN_NEED_LOGIN then
			self.IsNeedLoginFromGameCenter = true
			EventMgr:SendEvent(EventID.LoginFromGameCenter)
		else
			if self.IsLoginSuccess then
				self:SaveWakeUpInfo()
			end
		end
	end
end

function LoginMgr:OnGameEventMSDKLoginRetNotify(LoginRet)
	local RetCode = LoginRet[MSDKDefine.ClassMembers.LoginRetData.RetCode]
	self.NickName = LoginRet[MSDKDefine.ClassMembers.LoginRetData.UserName]
	self.AvatarUrl = LoginRet[MSDKDefine.ClassMembers.LoginRetData.PictureUrl]
	self.RegChannelDis = LoginRet[MSDKDefine.ClassMembers.LoginRetData.RegChannelDis]
	FLOG_INFO("LoginMgr:OnGameEventMSDKLoginRetNotify, RetCode: %d, NickName: %s, AvatarUrl: %s, RegChannelDis: %s",
		RetCode, self.NickName, self.AvatarUrl, self.RegChannelDis)

	if RetCode ~= MSDKDefine.MSDKError.NEED_REALNAME and RetCode ~= MSDKDefine.MSDKError.REALNAME_FAIL then
		self.bShowPrajnaWebView = false
	end

	if RetCode == MSDKDefine.MSDKError.REALNAME_FAIL and nil ~= self.MSDKModal and self.MSDKModal == 1 then
		FLOG_INFO("MSDK log out by login ret")
		self:RoleLogOut(ProtoCS.LogoutReason.Logout)

		if self.bShowHopeView then
			self.IsNeedLogout = true
			EventMgr:SendEvent(EventID.DoLogoutEvent)
		end
	end
end

function LoginMgr:OnGameEventNetworkConnected(Params)
	if Params.ErrorCode ~= 0 then --连接失败
		self.ConnectUrlIndex = self.ConnectUrlIndex + 1
	end

    if Params.ErrorCode == LoginNewDefine.ErrCodeAuthFailed then
        self.IsNeedLogout = true
        EventMgr:SendEvent(EventID.DoLogoutEvent)
		FLOG_INFO("[LoginMgr:OnGameEventNetworkConnected] Auth Failed, please logout")
    end
end

---@param TreeInfo FTreeInfo
function LoginMgr:OnGameEventMapleNotify(TreeInfo)
	local ErrorCode = TreeInfo.ErrorCode

	self.TreeInfo = { ErrorCode = ErrorCode, NodeList = {} }
	if ErrorCode == 0 then
		self.AllMapleNodeInfo = {}
		local TempRecommendServer = {}
		local TempAllServer = {}

		local NodeList = TreeInfo.NodeList
		local NodeCount = NodeList:Num()

		for i = 1, NodeCount do
			---@type FNodeWrapper
			local NodeWrapper = NodeList:Get(i)
			table.insert(self.TreeInfo.NodeList, NodeWrapper)

			if NodeWrapper.Type == UE.ETreeNodeType.TnTypeLeaf then
				local LeafNode = NodeWrapper.Leaf

				--if LoginNewUnitTest.WorldId and LoginNewUnitTest.WorldId == LeafNode.Id then
				--	LeafNode.Flag = LoginNewUnitTest.NewFlag
				--end
				--print(string.format("[LoginMgr:OnGameEventMapleNotify] Leaf ---> Id:%d, ParentId:%d, Name:%s, Flag:%d, Tag:%d, Url:%s, CustomValue1:%d, CustomValue2:%d"
				--	, LeafNode.Id, LeafNode.ParentId, LeafNode.Name, LeafNode.Flag, LeafNode.Tag, LeafNode.Url, LeafNode.CustomData.Attr1, LeafNode.CustomData.Attr2))

				---@type ServerListItem
				local ServerListItem = {}
				ServerListItem.WorldID = LeafNode.Id
				ServerListItem.Name = _G.U3TR(LeafNode.Name)
				ServerListItem.Host = LeafNode.Url
				ServerListItem.State = LeafNode.Flag
				ServerListItem.Tag = LeafNode.Tag
				ServerListItem.CustomValue1 = LeafNode.CustomData.Attr1
				ServerListItem.CustomValue2 = LeafNode.CustomData.Attr2
				self.AllMapleNodeInfo[LeafNode.Id] = ServerListItem
				--self.AllMapleNodeInfo[LeafNode.Id] = { WorldID = LeafNode.Id, GroupID = LeafNode.ParentId, Name = LeafNode.Name, Host = LeafNode.Url }

				-- Recommend
				if LeafNode.Tag & LoginNewDefine.ServerTagEnum.Recommend ~= 0 then
					table.insert(TempRecommendServer, ServerListItem)
				else
					table.insert(TempAllServer, ServerListItem)
				end
			end
		end

		if #TempRecommendServer > 0 then
			self.RecommendWorldId = TempRecommendServer[#TempRecommendServer].WorldID
		elseif #TempAllServer > 0 then
			self.RecommendWorldId = TempAllServer[#TempAllServer].WorldID
		else
			self.RecommendWorldId = LoginNewDefine:GetDefaultWorldID()
		end

		EventMgr:SendEvent(EventID.MapleAllNodeInfoNotify)
	else
		local function RetryCallback()
			_G.UE.UMapleMgr.Get():RequireMaple()
		end
		local function LogoutCallback()
			local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
			LoginNewVM.NoLogin = true
			LoginNewVM.ShowStartBtn = false
			LoginNewVM.ShowResearchBtn = not UE.UCommonUtil.IsShipping()
			LoginNewVM.ShowFriendList = false
			_G.UE.UAccountMgr.Get():Logout()

			if UIViewMgr:IsViewVisible(UIViewID.AccountCancellationWait) then
				self.bCancelAccountCancellation = true
				UIViewMgr:HideView(UIViewID.AccountCancellationWait)
			end
		end
		if ErrorCode == MapleErrorCode.TimeOut or ErrorCode == MapleErrorCode.SystemErr
				or ErrorCode == MapleErrorCode.SendErr or ErrorCode == MapleErrorCode.RecvErr then
			-- 10002(确  认)
			-- 10004(提  示)
			-- 470001(服务器列表获取失败\n错误码：)
			-- 470002(重  试)
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), string.format(LSTR(LoginStrID.ServerListFailed), ErrorCode), RetryCallback, LogoutCallback, LSTR(10002), LSTR(LoginStrID.Retry))
		else
			_G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(10004), string.format(LSTR(LoginStrID.ServerListFailed), ErrorCode), LogoutCallback)
		end
	end
end

function LoginMgr:OnGameEventNetworkHopeRes(MsgBody)
	local MsgInstruction = MsgBody.ExecuteInstruction
	local Instruction = {
		RuleName = MsgInstruction.RuleName,
		TraceId = MsgInstruction.TraceId
	}
	local bShowMessageBox = false
	local MessageBoxCallback = nil
	local bExecuteInstructionLater = false
	if MsgInstruction.InstructionType == ProtoCS.INSTRUCTIONTYPE.INSTRUCTIONTYPE_TIPS then
		FLOG_INFO("HOPE: Open tips")
		bShowMessageBox = true
	elseif MsgInstruction.InstructionType == ProtoCS.INSTRUCTIONTYPE.INSTRUCTIONTYPE_LOGOUT then
		FLOG_INFO("HOPE: Log out")
		bShowMessageBox = true
		MessageBoxCallback = function()
			FLOG_INFO("[LoginMgr:OnGameEventNetworkHopeRes] INSTRUCTIONTYPE_LOGOUT Callback ")
			self.bShowHopeView = false
			_G.NetworkStateMgr:ReturnToLogin()
			self.IsNeedLogout = true
			EventMgr:SendEvent(EventID.DoLogoutEvent)

			self:ExecuteHopeInstruction(Instruction)
		end
		bExecuteInstructionLater = true
		self.bShowHopeView = true
	elseif MsgInstruction.InstructionType == ProtoCS.INSTRUCTIONTYPE.INSTRUCTIONTYPE_OPENURL then
		self.MSDKModal = MsgInstruction.Modal
		local JsonStr = ""
		if MsgInstruction.Modal == 1 then
            JsonStr = "{\"url\": \""..MsgInstruction.Url.."\", \"show_titlebar\": \"0\", \"show_title\": \"0\", \"buttons\": [] }"
        else
            JsonStr = "{\"url\": \""..MsgInstruction.Url.."\", \"show_titlebar\": \"0\", \"show_title\": \"0\", \"buttons\": [{\"buttonId\": \"1\", \"name\": \"返回游戏\", \"action\": \"0\"}] }"
		end
		FLOG_INFO("HOPE: Open Prajna webview parameter %s", JsonStr)
		_G.UE.UAccountMgr.Get():OpenPrajnaWebView(JsonStr)
		self.bShowPrajnaWebView = true
		self.bShowHopeView = true
	elseif MsgInstruction.InstructionType == ProtoCS.INSTRUCTIONTYPE.INSTRUCTIONTYPE_PRELOGOUT then
		FLOG_INFO("HOPE: Pre logout")
		bShowMessageBox = true
		MessageBoxCallback = function()
			_G.TimerMgr:AddTimer(nil, function()
				FLOG_INFO("[LoginMgr:OnGameEventNetworkHopeRes] INSTRUCTIONTYPE_PRELOGOUT Callback ")
				self.bShowHopeView = false
				_G.NetworkStateMgr:ReturnToLogin()
				self.IsNeedLogout = true
				EventMgr:SendEvent(EventID.DoLogoutEvent)

				self:ExecuteHopeInstruction(Instruction)
			end,
			MsgInstruction.LogoutTime - TimeUtil.GetServerTime(), 0, 1)
		end
		bExecuteInstructionLater = true
		self.bShowHopeView = true
	else
		FLOG_ERROR("HOPE: Undefined or unused instruction type %d", MsgInstruction.InstructionType)
		return
	end

	if bShowMessageBox then
		_G.MsgBoxUtil.ShowLongMsgBoxOneOpRight(Instruction, MsgInstruction.Title, MsgInstruction.Msg, MessageBoxCallback, nil,
		{bHideOnClickBG = false})
	end

	if not bExecuteInstructionLater then
		self:ExecuteHopeInstruction(Instruction)
	end
end

function LoginMgr:ExecuteHopeInstruction(Instruction)
	local MsgID = CS_CMD.CS_CMD_HOPE
	local SubMsgID = ProtoCS.CS_HOPE_CMD.CS_CMD_HOPE_EXECUTEINSTRUCTION

	local LoginRet = _G.UE.FAccountLoginRetData()
	_G.UE.UAccountMgr.Get():GetLoginRet(LoginRet)
	local MsgBody = {
		Cmd = SubMsgID,
		ExecuteRet = {
			UserId = LoginRet.OpenID,
			RuleName = Instruction.RuleName,
			InstrTraceId = Instruction.TraceId,
			ExecTime = TimeUtil.GetServerTime(),
			Ret = 0 -- 0即成功
		}
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:OnGameEventNetworkFantasyMedicineRes(MsgBody)
	FLOG_INFO("LoginMgr:OnGameEventNetworkFantasyMedicineRes")
	--C++在UAttributeMsgHandler::OnNetFantasyMedicineRes中处理角色换装
	--lua这边只处理lua侧的状态和幻想药流程
	if MsgBody.Cmd == ProtoCS.FantasyMedicineCmd.FantasyMedicineCmdUse then
		if MsgBody.UseRsp and MsgBody.UseRsp.Simple then
			local simple = MsgBody.UseRsp.Simple

			_G.LoginUIMgr:HideCreateRoleView()
			_G.LoginUIMgr:Reset()	--要在后面，否则之前的view没有hide掉
			_G.LoginUIMgr:EndFantasia(true, simple)

			--更新ActorMgr里的RoleDetail的Simple数据
			local RoleDetail = ActorMgr:GetMajorRoleDetail()
			local OldSimple = RoleDetail.Simple
			RoleDetail.Simple = table.deepcopy(simple)
			ActorMgr:SetMajorRoleDetail(RoleDetail, true)
			
			local Params = {OldSimple = OldSimple, NewSimple = RoleDetail.Simple}
			EventMgr:SendEvent(EventID.FantasiaSuccessChangeRole, Params)

			--离开幻想药
			_G.PWorldMgr:SendLeavePWorld()
			CommonUtil.ShowJoyStick()
			return
		end
	end
	_G.LoginUIMgr.HasSendFantasiaMsg = false
end

function LoginMgr:OnNetMsgUpdateClientRes(MsgBody)
	if nil == MsgBody then
		return
	end
	FLOG_INFO("[LoginMgr:OnNetMsgUpdateClientRes] Cmd:%d", MsgBody.Cmd)

	if MsgBody.Cmd == SUB_MSG_ID.CS_MIX_UPDATE_CLIENT and MsgBody.UpdateClient then
		local AppVersion = _G.UE.UVersionMgr.GetResourceVersion()
		FLOG_INFO("[LoginMgr:OnNetMsgUpdateClientRes] AppVer:%s, ClientVersion:%s, AndroidClientVer:%s, IOSClientVer:%s, ForceUpdate:%s",
				AppVersion, MsgBody.UpdateClient.ClientVersion, MsgBody.UpdateClient.AndroidClientVersion, MsgBody.UpdateClient.IosClientVersion, tostring(MsgBody.UpdateClient.ForceUpdate))
		local LocalAppVerParams = string.split(AppVersion, '.')
		local NewAppVerParams
		if CommonUtil.IsAndroidPlatform() then
			NewAppVerParams = string.split(MsgBody.UpdateClient.AndroidClientVersion, '.')
		elseif CommonUtil.IsIOSPlatform() then
			NewAppVerParams = string.split(MsgBody.UpdateClient.IosClientVersion, '.')
		else
			NewAppVerParams = string.split(MsgBody.UpdateClient.ClientVersion, '.')
		end

		if #LocalAppVerParams ~= #NewAppVerParams then
			FLOG_WARNING("[LoginMgr:OnNetMsgUpdateClientRes] Invalid Version")
			return
		end

		for i = 1, #LocalAppVerParams do
			if tonumber(NewAppVerParams[i]) > tonumber(LocalAppVerParams[i]) then
				local function Callback()
					FLOG_INFO("[LoginMgr:OnNetMsgUpdateClientRes] QuitGame ")
					CommonUtil.RestartGame()
				end
				-- 10002(确  认), 10004(提  示), 470132(客户端新版本已发布，点击确认退出游戏，重新启动更新至最新版。)
				if MsgBody.UpdateClient.ForceUpdate then
					MsgBoxUtil.ShowMsgBoxOneOpRightMustClick(self, LSTR(10004), LSTR(470132), Callback, LSTR(10002), { HideCloseBtn = true })
				else
					MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(10004), LSTR(470132), Callback)
				end
				break
			else if tonumber(NewAppVerParams[i]) < tonumber(LocalAppVerParams[i]) then
				break
			end
			end
		end

	end
end

function LoginMgr:OnNetMsgPlayerPrivacyRes(MsgBody)
	if nil == MsgBody then
		return
	end
	FLOG_INFO("[LoginMgr:OnNetMsgPlayerPrivacyRes] Cmd:%d", MsgBody.Cmd)

	--{
	--	"Cmd": 2,
	--	"Data": "Privacy",
	--	"Privacy": {
	--		"OpenID": "9813432316435096332",
	--		"PrivacyList": [{
	--			"PrivacyType": 0,
	--			"Reason": "",
	--			"BanEndTime": 3805825900
	--		}]
	--	}
	--}
	if MsgBody.Cmd == SUB_MSG_ID.CS_MIX_PLAYER_PRIVACY and MsgBody.Privacy then
		FLOG_INFO("[LoginMgr:OnNetMsgPlayerPrivacyRes] OpenID:%s", MsgBody.Privacy.OpenID)
		if MsgBody.Privacy.PrivacyList then
			for _, PrivacyData in ipairs(MsgBody.Privacy.PrivacyList) do
				FLOG_INFO("[LoginMgr:OnNetMsgPlayerPrivacyRes] PrivacyType:%s, BanEndTime:%d", PrivacyData.PrivacyType, PrivacyData.BanEndTime)
				local AllState = PrivacyData.PrivacyType == ProtoCS.Profile.Mix.PlayerPrivacyType.PlayerPrivacyAll
				if AllState then
					local function Callback()
						_G.NetworkStateMgr:ReturnToLogin()
						self.IsNeedLogout = true
						EventMgr:SendEvent(EventID.DoLogoutEvent)
					end
					-- 10002(确  认), 10004(提  示), 470164(您已取消授权，将为您退出游戏至登录界面。)
					MsgBoxUtil.ShowMsgBoxOneOpRightMustClick(self, LSTR(10004), LSTR(470164), Callback, LSTR(10002), { HideCloseBtn = true })
				end

				local PlayerPrivacyInfoState = PrivacyData.PrivacyType == ProtoCS.Profile.Mix.PlayerPrivacyType.PlayerPrivacyInfo
				local RelationshipState = PrivacyData.PrivacyType == ProtoCS.Profile.Mix.PlayerPrivacyType.PlayerPrivacyRelationship
				DataReportUtil.ReportAuthFlowData(AllState, PlayerPrivacyInfoState, RelationshipState)
				--DataReportUtil.ReportPlayerLoginForUA(PlayerPrivacyInfoState, RelationshipState)
			end
		end
	end
end

function LoginMgr:OnNetMsgPlayPrivacyRes(MsgBody)
	if nil == MsgBody then
		return
	end
	FLOG_INFO("[LoginMgr:OnNetMsgPlayPrivacyRes] Cmd:%d", MsgBody.Cmd)


end

function LoginMgr:OnNetMsgError(MsgBody)
	if not MsgBody then
		return
	end

	local ErrorCode = MsgBody.ErrCode
	if ErrorCode == LoginNewDefine.VersionErrCode then
		local function Callback()
			FLOG_INFO("[LoginMgr:OnNetMsgError] 120006 - QuitGame and restart")
			CommonUtil.RestartGame()
		end
		-- 10002(确  认), 10004(提  示), 470132(客户端新版本已发布，点击确认退出游戏，重新启动更新至最新版。)
		_G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(10004), LSTR(470132), Callback, LSTR(10002), { HideCloseBtn = true })
	end
end

function LoginMgr:OnNetMsgMixNotify(MsgBody)
	-- print('LoginMgr:OnNetMsgMixNotify %s', MsgBody)
	if MsgBody and MsgBody.GVoice then
		self:MixNotifyGVoice(MsgBody.GVoice)
	end
end

function LoginMgr:OnNetMsgMixNotifyGVoice(MsgBody)
	-- print('LoginMgr:OnNetMsgMixNotifyGVoice %s', MsgBody)
	if MsgBody and MsgBody.GVoice then
		self:MixNotifyGVoice(MsgBody.GVoice)
	end
end

---@private
function LoginMgr:MixNotifyGVoice(Data)
	if Data == nil then
		return
	end

	local OpenID = Data.OpenID
	local BanEndTime = Data.BanEndTime

	if self.GVoiceBanData == nil then
		self.GVoiceBanData = {}
	end

	local bOldIsBanned = self:IsGVoiceBanned()
	if OpenID then
		self.GVoiceBanData[OpenID] = {EndTime = BanEndTime}
	end

	if bOldIsBanned ~= self:IsGVoiceBanned() then
		self:TipGVoiceBanned()
		_G.EventMgr:SendEvent(EventID.GVoiceBanned, self:IsGVoiceBanned())
	end
end

function LoginMgr:TipGVoiceBanned()
	local Secs = self:GetGVoiceBanRemainSeconds()
	local Info = self:GetGVoiceBanInfo()
	if Secs > 0 and Info then
		local LocalizationUtil = require("Utils/LocalizationUtil")
		_G.MsgTipsUtil.ShowTipsByID(103101, Info.Reason, LocalizationUtil.GetCountdownTimeForLongTime(Secs))
	end
end

function LoginMgr:IsGVoiceBanned()
	return self:GetGVoiceBanRemainSeconds() > 0
end

function LoginMgr:GetGVoiceBanRemainSeconds()
	local local_time = os.time()
    local utc_time = os.time(os.date("!*t", local_time))
	return self:GetGVoiceBanEndTime() - utc_time
end

function LoginMgr:GetGVoiceBanEndTime()
	if self.GVoiceBanData == nil then
		return 0
	end

	local Time
	if self.OpenID then
		Time = (self.GVoiceBanData[self.OpenID] or {}).EndTime
	end

	return Time or 0
end

function LoginMgr:GetGVoiceBanInfo()
	if self.OpenID and self.GVoiceBanData then
		local Info = self.GVoiceBanData[self.OpenID]
		if Info then
			return table.clone(Info)
		end
	end
end

--function LoginMgr:OnGameEventNetworkConnected(Params)
--	print("LoginMgr:OnGameEventNetworkConnected")
--
--	if Params.bSuccess then
--		self:SendModuleConfigReq()
--	end
--end

function LoginMgr:QueryRoleList()
	self:SendQueryRoleListByOpenIDReq(self.WorldID, self.OpenID)
end

function LoginMgr:SendQueryRoleListByOpenIDReq(worldID, openID)
	local MsgID = CS_CMD.CS_CMD_QUERY_ROLELIST
	local SubMsgID = 0

	local MsgBody = {
		WorldID = worldID,
		OpenID = openID,
		ClientVersion = _G.UE.UVersionMgr.GetResourceVersion(),
		IsReplay=_G.LevelRecordMgr.bIsOpenReplay,
		DeviceType = CommonUtil.GetDeviceType(),
	}

	self.IsWaitRoleListMsg = true
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--正式角色的注册，创角技能演示的角色走新的单独协议了
function LoginMgr:SendRegisterRoleReq(RoleRegister)
	if _G.DemoMajorType == 0 then
		_G.LoginUIMgr.LoginReConnectMgr:ExitCreateRole()
		FLOG_WARNING("LoginMgr:Send CS_CMD_REGISTER, but DemoMajorType = 0")
		return
	end

	-- local ProtoCommon = require("Protocol/ProtoCommon")
	local MsgID = CS_CMD.CS_CMD_REGISTER
	local SubMsgID = 0

	local MsgBody = {}
	MsgBody.WorldID = self.WorldID
	MsgBody.OpenID = self.OpenID
	MsgBody.RoleRegister = RoleRegister
	MsgBody.DeviceInfo = self:GetDeviceInfo()
	MsgBody.RoleID = self.RoleID

	MsgBody.RegChannel = self:GetRegChannel()
	MsgBody.PkgChannel = self:GetInstallChannel()

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:GetRegChannel()
	return tonumber(self.RegChannelDis) or 0
end

function LoginMgr:GetLoginChannel()
	local LoginChannel = 0
	if self:IsWeChatLogin() then
		if not self.IsWechatWakeUp then
			local IsLastWechatWakeUp = self:IsWakeUpByWeChatOrQQ(MSDKDefine.ChannelID.WeChat)
			if IsLastWechatWakeUp then
				LoginChannel = MSDKDefine.ChannelID.WeChat
			end
		else
			LoginChannel = MSDKDefine.ChannelID.WeChat
		end
	elseif self:IsQQLogin() then
		if not self.IsQQWakeUp then
			local IsLastQQWakeUp = self:IsWakeUpByWeChatOrQQ(MSDKDefine.ChannelID.QQ)
			if IsLastQQWakeUp then
				LoginChannel = MSDKDefine.ChannelID.QQ
			end
		else
			LoginChannel = MSDKDefine.ChannelID.QQ
		end
	end

	return LoginChannel
end

--注册创角技能演示的角色走新的单独协议
function LoginMgr:SendRegisterDemoRoleReq(RoleRegister)
	self.bBackToSelectRoleFromCreate = false

	local MsgID = CS_CMD.CS_CMD_SAMPLE
	local SubMsgID = CS_SUB_CMD.SampleCmdRegister

	local MsgBody = {}
	MsgBody.Cmd = CS_SUB_CMD.SampleCmdRegister
	MsgBody.Register = {}
	MsgBody.Register.WorldID = self.WorldID
	MsgBody.Register.OpenID = self.OpenID
	MsgBody.Register.RoleRegister = RoleRegister
	self.DemoRoleRegister = RoleRegister

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--幻想药
function LoginMgr:SendUseFantasyMedicineReq(Profile)
	local MsgID = CS_CMD.CS_CMD_FANTASY_MEDICINE
	local SubMsgID = 0

	local MsgBody = {}
	MsgBody.Cmd = ProtoCS.FantasyMedicineCmd.FantasyMedicineCmdUse
	MsgBody.UseReq = {}
	MsgBody.UseReq.ProfileUpdate = Profile

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:CheckNameRepeat(RoleName)
	local MsgID = CS_CMD.CS_CMD_CHECK_NAME
	local SubMsgID = 0

	local MsgBody = {}
	MsgBody.Name = RoleName
	MsgBody.OpenID = self.OpenID
	MsgBody.WorldID = self.WorldID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:SendRoleLoginReq(RoleID, bReconnect, bBackOrignServer)
	local MsgID = CS_CMD.CS_CMD_LOGIN
	local SubMsgID = 0

	local MsgBody = {}
	MsgBody.RoleID = RoleID
	MsgBody.ClientVersion = _G.UE.UVersionMgr.GetResourceVersion()
	MsgBody.DeviceInfo = self:GetDeviceInfo()
	MsgBody.ReConnected = bReconnect

	MsgBody.LoginChannel = self:GetLoginChannel()

	MsgBody.PkgChannel = self:GetInstallChannel()
	self.bBackOrignServer = bBackOrignServer

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:SendDemoRoleLoginReq(RoleID, bReconnect)
	local MsgID = CS_CMD.CS_CMD_SAMPLE
	local SubMsgID = CS_SUB_CMD.SampleCmdLogin

	local MsgBody = {}
	MsgBody.Cmd = CS_SUB_CMD.SampleCmdLogin
	MsgBody.Login = {}
	MsgBody.Login.RoleID = RoleID
	MsgBody.Login.WorldID = self.WorldID
	MsgBody.Login.OpenID = self.OpenID
	MsgBody.Login.ReConnected = bReconnect
	MsgBody.Login.RoleRegister = self.DemoRoleRegister or {}
	
	MsgBody.Login.LoginChannel = self:GetLoginChannel()
	MsgBody.Login.PkgChannel = self:GetInstallChannel()
	MsgBody.Login.DeviceInfo = self:GetDeviceInfo()

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:RoleLogOut(Reason)
	Reason = Reason or ProtoCS.LogoutReason.Logout

	self.LastRoleLogOutReason = Reason

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	self:SendRoleLogoutReq(MajorRoleID, Reason)
end

function LoginMgr:SendRoleLogoutReq(RoleID, Reason)
	if not self.bRoleLogin then
		FLOG_INFO("LoginMgr:SendRoleLogoutReq Warning, bRoleLogin = false")
		return 
	end

	local MsgID = CS_CMD.CS_CMD_LOGOUT
	local SubMsgID = 0

	FLOG_INFO("LoginMgr:SendRoleLogoutReq")

	local MsgBody = {}
	MsgBody.RoleID = RoleID
	MsgBody.Reason = Reason

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:SendModuleConfigReq()
	local MsgID = CS_CMD.CS_CMD_CONFIG
	local SubMsgID = 0

	local MsgBody = {}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--正式角色的进副本
function LoginMgr:SendLoginEnter()
	local MsgID = CS_CMD.CS_CMD_LOGIN_ENTER

	local MsgBody = {}
	if self.bBackOrignServer then
		MsgBody.BackSelfWorld = true
	end

	self.bBackOrignServer = nil

	GameNetworkMgr:SendMsg(MsgID, 0, MsgBody)
end

--创角技能体验，也类似正式角色那样，需要一条进副本的协议
function LoginMgr:SendDemoRoleEnter()
	local MsgID = CS_CMD.CS_CMD_SAMPLE

	local MsgBody = {}
	MsgBody.Cmd = CS_SUB_CMD.SampleCmdEnter
	MsgBody.Enter = {}
	MsgBody.Enter.RoleID = self.RoleID
	MsgBody.Enter.WorldID = self.WorldID
	MsgBody.Enter.OpenID = self.OpenID
	MsgBody.Enter.RoleRegister = self.DemoRoleRegister or {}

	GameNetworkMgr:SendMsg(MsgID, CS_SUB_CMD.SampleCmdEnter, MsgBody)
end

function LoginMgr:SendDemoRoleExit(Reason)
	Reason = Reason or ProtoCS.LogoutReason.Logout
	self.LastRoleLogOutReason = Reason
	FLOG_INFO("LoginMgr:SendDemoRoleExit")

	local MsgID = CS_CMD.CS_CMD_SAMPLE

	local MsgBody = {}
	MsgBody.Cmd = CS_SUB_CMD.SampleCmdExit
	MsgBody.Exit = {}
	MsgBody.Exit.EntityID = _G.PWorldMgr.MajorEntityID or 0
	MsgBody.Exit.PWorldInstID = _G.PWorldMgr.BaseInfo.CurrPWorldInstID or 0
	MsgBody.Exit.MapResID = _G.PWorldMgr.BaseInfo.MapResID or 0
	MsgBody.Exit.RoleID = self.RoleID
	-- FLOG_INFO("LoginMgr SendDemoRoleExit RoleID:%d EntityID:%d", MsgBody.Exit.RoleID, MsgBody.Exit.EntityID)

	GameNetworkMgr:SendMsg(MsgID, CS_SUB_CMD.SampleCmdExit, MsgBody)
end

function LoginMgr:SendPlayerPrivacyReq()
	FLOG_INFO("LoginMgr:SendPlayerPrivacyReq")
	local MsgID = CS_CMD.CS_CMD_PLAYPRIVACY
	local SubMsgID = 0

	local MsgBody = {}
	MsgBody.OpenID = self.OpenID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMgr:HasRoleCount()
	if self.tbRoleSimple then
		return #self.tbRoleSimple
	end

	return 0
end

function LoginMgr:GetPreName()
	return self.PreName
end

function LoginMgr:OnNetMsgQueryRoleListByOpenIDRes(MsgBody)
	FLOG_INFO("[LoginMgr:OnNetMsgQueryRoleListByOpenIDRes] WorldRegPercent:%d", MsgBody.WorldRegPercent)
	if MsgBody.WorldRegPercent and MsgBody.WorldRegPercent > 0 then
		if self.LastQueueOpenId and self.LastQueueOpenId ~= LoginMgr.OpenID then
			self.IsLoginQueueFinish = false
		end

		if not self.IsLoginQueueFinish and (nil == MsgBody.RoleList or #MsgBody.RoleList <= 0) then
			self.LastQueueOpenId = LoginMgr.OpenID
			EventMgr:PostEvent(EventID.LoginConnectEvent, MsgBody.WorldRegPercent)
			return
		end
	end

	-- MsgBody.PreName = "pcw"
	-- self.NickName = "pcw"
	self.PreName = MsgBody.PreName or ""

	self.IsWaitRoleListMsg = false

	LifeMgrModule.StartAccountLife("AccountLife")

	--将来有切换账号功能、退出游戏功能的时候再    LifeMgrModule.ShutdownAccountLife()

	self.tbRoleSimple = MsgBody.RoleList

	table.sort(self.tbRoleSimple, function(Left, Right)
		local LT = Left.LoginTime or 0
		local RT = Right.LoginTime or 0
		return LT > RT
	end)


	local IsHideWaterMark = UE.UCommonUtil.IsHideWaterMark()

	if MsgBody.RoleRight ~= nil and not IsHideWaterMark then
		self.EnableWaterMark = MsgBody.RoleRight.EnableWaterMark
	end

	if self.bBackToSelectRoleFromCreate then
		FLOG_INFO("LoginMgr bBackToSelectRoleFromCreate = true")
		_G.LoginUIMgr:DoExitCreateRole()
		self.bBackToSelectRoleFromCreate = false

		return
	end

	local LastMajorBornRoleID = _G.UE.USaveMgr.GetInt(SaveKey.MajorBornRoleID, 0, false)
	if LastMajorBornRoleID and LastMajorBornRoleID > 0 and _G.DemoMajorType == 2 then
		local bAlreadyCreate = false
		local RoleCnt = #MsgBody.RoleList
		for index = 1, RoleCnt do
			local RoleSimple = self.tbRoleSimple[index]
			if RoleSimple.RoleID == LastMajorBornRoleID then
				bAlreadyCreate = true
			end
		end
		FLOG_INFO("LoginMgr MajorBornRoleID %d bAlreadyCreate:%s", LastMajorBornRoleID, tostring(bAlreadyCreate))

		--出生场景返回（临时角色）   断线重连后，返回到确认信息这个ui或者选角ui（如果已经创建的话）
		if not bAlreadyCreate then
			self:OnNetMsgDemoLoginExit()
		else
			_G.UE.USaveMgr.SetInt(SaveKey.LastLoginRoleID, LastMajorBornRoleID, false)
			self:ReturnToSelectRoleView()
			_G.LoginUIMgr.LoginReConnectMgr:ExitCreateRole()
		end

		return
	end

	_G.EventMgr:SendEvent(_G.EventID.LoginToRoleSuccess)

	--系统配置初始化放到Account Life结束后执行
	--确保绝大多数模块初始化完成
	-- local CfgEntrance = require("Game/SystemConfig/CfgEntrance")
	-- CfgEntrance.LoadConfig()

	--不统一先隐藏登录主界面，因为要等进图或者切到选人、创角的界面才需要隐藏
	-- UIViewMgr:HideView(UIViewID.LoginMain)

	local CreateRoleRaceID = 1
	if nil == MsgBody.RoleList or #MsgBody.RoleList <= 0 then
		self:RegisterTimer(function()
            UIViewMgr:HideView(self:GetLoginMainViewId())
			UIViewMgr:HideView(UIViewID.LoginServerList)
			_G.LoginUIMgr:ShowCreateRoleView(true)
		end, 1.0)

	else
		CreateRoleRaceID = MsgBody.RoleList[1].Race
		if not self:IsModuleSwitchOn(ModuleType.MODULE_ROLE_SHOW) then
			local RoleID = MsgBody.RoleList[1].RoleID

			self:SendRoleLoginReq(RoleID)
		else
			self:RegisterTimer(function()
				UIViewMgr:HideView(self:GetLoginMainViewId())
				UIViewMgr:HideView(UIViewID.LoginServerList)
				_G.LoginUIMgr:ShowSelectRoleView(true)
			end, 1.0)
		end
	end

	_G.LoginUIMgr:CreateCamerAnim(CreateRoleRaceID)
	
	if _G.LevelRecordMgr then
		_G.LevelRecordMgr:SetCurrentRecordID(MsgBody.ReplayID)
		_G.LevelRecordMgr:AutoUpLoadLogs()
	end

	-- 初始化GVoice
	_G.UE.UVoiceMgr.Get():Initialize(self.OpenID, LoginUtils:GetGVoiceServerUrl(), VoiceDefine.OpenGVoiceLog == true)

	local USaveMgr = _G.UE.USaveMgr
	LoginMgr.LoginFailTime = 0
	LoginMgr.LoginFailCount = 0
	USaveMgr.SetInt(SaveKey.LoginFailTime, LoginMgr.LoginFailTime, false)
	USaveMgr.SetInt(SaveKey.LoginFailCount, LoginMgr.LoginFailCount, false)
end

function LoginMgr:OnNetMsgCheckName(MsgBody)
	if MsgBody.ErrorCode then
		-- if MsgBody.ErrorCode == 100004 then
			-- _G.LoginUIMgr:PlayEmotionAnim(LoginConfig.RegisterFailedEmotionID, nil)
			_G.LoginUIMgr:OnMakeNameCheckRsp(true)	--重复了
		-- end

		self.IsClickFinishCreateBtn = false
		return
	end

	-- _G.LoginUIMgr:PlayEmotionAnim(LoginConfig.RegisterSuccessEmotionID, nil)
	_G.LoginUIMgr:OnMakeNameCheckRsp(false)	--名字没重复

	if CommonUtil.GetPlatformName() == "Windows" and self.IsClickFinishCreateBtn then
		-- local function DelayFinishCreate()
		-- 	_G.LoginUIMgr:SwitchToNextPhase()

		-- 	self.IsClickFinishCreateBtn = false
		-- end

		-- _G.LoginUIMgr:SetMakeNameBtnEnable(false)
		-- _G.TimerMgr:AddTimer(nil, DelayFinishCreate, 3, 1, 1)
		self.IsClickFinishCreateBtn = false
		_G.LoginUIMgr:ClickMakeNameBtn()
	end

	return 
end

function LoginMgr:OnNetMsgRegisterRoleRes(MsgBody)
	local ErrCode = MsgBody.ErrorCode
	if ErrCode then
		FLOG_INFO("LoginMgr:OnNetMsgRegisterRoleRes Error:%d", ErrCode)
		if ErrCode == 120007 then
			local function Callback()
				_G.LoginMgr:ReturnToLogin(true)
			end

			-- 10002(确  认), 10004(提  示), 470132(当前服务器注册人数已满，请选择其他服)
			_G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(LoginStrID.SvrFull), LSTR(LoginStrID.SvrQueueTips)
				, Callback, LSTR(10002), { HideCloseBtn = true })

			return
		end
		
		return
	end

	if not MsgBody.RoleSimple then
		return 
	end

	FLOG_INFO("LoginMgr:OnNetMsgRegisterRoleRes")

	self.IsClickFinishCreateBtn = false
	-- if _G.LoginUIMgr:GetCurRolePhase() == LoginRolePhase.SetName then
	-- 	self.NewRegisterRoleID = MsgBody.RoleSimple.RoleID
	-- 	FLOG_INFO("LoginMgr RegisterRoleID: %d", self.NewRegisterRoleID)
		
	-- 	-- local function OnAnimFinish()
	-- 	-- 	FLOG_WARNING("Login MakeName OnAnim Finish")
	-- 		self:MakeNameUIAnim()
	-- 	-- end

	-- 	-- _G.LoginUIMgr:PlayEmotionAnim(LoginConfig.RegisterSuccessEmotionID, OnAnimFinish)
	-- 	return 
	-- end

	self.NewRegisterRoleID = MsgBody.RoleSimple.RoleID
	FLOG_INFO("LoginMgr RegisterRoleID: %d", self.NewRegisterRoleID)

	self.PreName = nil
	--并且会发起登录
	self:OnFinishMakeName()
end

--创角的进技能体验 （注册和login 这2步合并为一步为 SampleRegister的回包(带RoleDetail)
function LoginMgr:OnNetMsgSampleRegisterRes(MsgBody)
	FLOG_INFO("LoginMgr:OnNetMsgSampleRegisterRes")

	if not MsgBody.Register or not MsgBody.Register.Simple then
		return
	end

	local RoleID = MsgBody.Register.Simple.RoleID
	if self.DemoRoleRegister and self.DemoRoleRegister.IsNewbie then
		FLOG_INFO("LoginMgr Record DemoRoleID")
		_G.UE.USaveMgr.SetInt(SaveKey.MajorBornRoleID, RoleID, false)
	end

	self:SendDemoRoleLoginReq(RoleID)
	
	_G.LoginUIMgr:OnSendRoleLoginReqAfterRegister(true)
end

-- function LoginMgr:MakeNameUIAnim()
-- 	local MakeNameView = UIViewMgr:FindView(UIViewID.LoginRoleName)
-- 	if MakeNameView then
-- 		local Time = MakeNameView:GetHideViewDelayTime() + 0.5
-- 		FLOG_WARNING("Login MakeName UIAnim, delay:%f", Time)
		
-- 		local function DelayMakeNameLogin()
-- 			FLOG_WARNING("Login MakeName login")
-- 			self:MakeNameLogin()
-- 		end

-- 		_G.LoginUIMgr:HideMakeNameView()
-- 		-- MakeNameView:PlayAnimOut()
-- 		_G.TimerMgr:AddTimer(nil, DelayMakeNameLogin, Time, 1, 1)
-- 	end
-- end

function LoginMgr:OnFinishMakeName()
	if self.NewRegisterRoleID then
		_G.LoginUIMgr.LoginReConnectMgr:ExitCreateRole()
		self:SendRoleLoginReq(self.NewRegisterRoleID)
		-- _G.LoginUIMgr:OnSendRoleLoginReqAfterRegister(true)
		_G.LoginUIMgr:Reset()
	
		local BeginCreateRoleTime = _G.LoginUIMgr.BeginCreateRoleTime
		if BeginCreateRoleTime then
			local CreateTime = _G.TimeUtil.GetServerTime() - BeginCreateRoleTime
			DataReportUtil.ReportSystemFlowData("PlayerRegister"
				, tostring(_G.LoginAvatarMgr:GetReportOpType())
				, tostring(CreateTime)
				, tostring(_G.LoginAvatarMgr:GetReportRdTimes()))
		end

		_G.UE.UGPMMgr.Get():PostLoginStepEvent(_G.DataReportLoginPhase.LoginCreateFinish
			, 0, 0, "Success", "", false, true)

		_G.StoryMgr:ContinueSequence()
	end
end

-- function LoginMgr:MakeNameLogin()
-- 	if self.NewRegisterRoleID then
-- 		_G.LoginUIMgr.LoginReConnectMgr:ExitCreateRole()
-- 		self:SendRoleLoginReq(self.NewRegisterRoleID)
-- 		_G.LoginUIMgr:OnSendRoleLoginReqAfterRegister(true)
-- 		_G.LoginUIMgr:HideCreateRoleView()
-- 		_G.LoginUIMgr:Reset()
		
-- 		local AppStartTime = CommonUtil.GetAppStartTime()
-- 		DataReportUtil.ReportLoginCreateData(
-- 			"29", _G.UE.UPlatformUtil.GetDeviceName()	--29: 起名完成开始游戏
-- 			, _G.LoginMgr.OpenID, tostring(AppStartTime), tostring(self.NewRegisterRoleID))

-- 		local BeginCreateRoleTime = _G.LoginUIMgr.BeginCreateRoleTime
-- 		if BeginCreateRoleTime then
-- 			local CreateTime = _G.TimeUtil.GetServerTime() - BeginCreateRoleTime
-- 			DataReportUtil.ReportSystemFlowData("PlayerRegister"
-- 				, tostring(_G.LoginAvatarMgr:GetReportOpType())
-- 				, tostring(CreateTime)
-- 				, tostring(_G.LoginAvatarMgr:GetReportRdTimes()))
-- 		end
-- 	end
-- end

function LoginMgr:OnLoginRsp(IsSuccess, ErrorCode)
	print("[LoginMgr:OnLoginRsp] ", IsSuccess, ErrorCode)
	-- LoginRoleMainPanelVM:ClearWaitLoginRspingFlag()

	if IsSuccess then
		return
	end

	if ErrorCode == LoginNewDefine.VersionErrCode then
		return
	end

	--if _G.WorldMsgMgr:IsLogin() then
	--	return
	--end

	local function Callback()
		LoginMgr:ReturnToLogin(false)
	end

	-- 10004 提 示
	-- 470140 当前网络连接异常，请重新登录
	-- 470141 返回登录
	local Params = { Title = LSTR(10004), Content = LSTR(470140), LeftCallback = Callback, LeftText = LSTR(470141) }
	UIViewMgr:ShowView(UIViewID.NetworkReconnectMsgBox, Params)
end

function LoginMgr:OnNetMsgRoleLoginRes(MsgBody)
	if MsgBody.ErrorCode then
		self:OnLoginRsp(false, MsgBody.ErrorCode)
		return
	end
	FLOG_INFO("LoginMgr:OnNetMsgRoleLoginRes")
	self:OnLoginRsp(true, MsgBody.ErrorCode)

	-- 登录前，检查是否被封
	local RoleDetail = MsgBody.RoleDetail
	local BanEndTime = RoleDetail.Simple.BanEndTime
	if nil ~= BanEndTime and BanEndTime > TimeUtil.GetServerTime() then
		print("[LoginMgr:OnNetMsgRoleLoginRes] BanEndTime: ", BanEndTime)
		-- 470128 当前账号已被封禁，解除时间%Y年%m月%d日%H时%M分
		local Message = TimeUtil.GetTimeFormat(LSTR(470128), BanEndTime)
		-- 10004(提  示)
		MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(10004), Message)
		return
	end

	-- _G.LoginUIMgr:DiscardCreateRoleData()

	-- 正常登录
	self.RoleID = MsgBody.RoleID

	local USaveMgr = _G.UE.USaveMgr
	USaveMgr.SetMajorRoleID(self.RoleID)
	USaveMgr.SetInt(SaveKey.LastLoginRoleID, self.RoleID, false)

	self.bReconnect = MsgBody.ReConnected
	self.bRoleLogin = true

	local bNeedSendLoginEnter = _G.DemoMajorType ~= 2
	
	_G.DemoMajorType = 0

	if self.bReconnect then
		UIViewMgr:HideAllUIInReconnect()
		-- UIViewMgr:HideAllUIByLayer(UILayer.All ~ UILayer.Loading)
	else
		LifeMgrModule.StartRoleLife("RoleLife")
	end

	-- if not _G.IsDemoMajor then
	if _G.DemoMajorType == 0 then
		_G.ModuleOpenMgr:UpdateOpenedList(MsgBody.OpenedList)
	end

	if bNeedSendLoginEnter then
		self:SendLoginEnter()
	end

	self.RoleDetail = RoleDetail

	-- if not _G.IsDemoMajor then
	if _G.DemoMajorType == 0 then
		local EventParams = EventMgr:GetEventParams()
		EventParams.BoolParam1 = self.bReconnect
		EventMgr:SendCppEvent(EventID.RoleLoginRes, EventParams)
		EventMgr:PostEvent(EventID.RoleLoginRes, { bReconnect = self.bReconnect })
	end


	if self.bReconnect then
		local LoginMapType = _G.LoginMapMgr:GetCurLoginMapType()
		local bPlayingSeq = _G.StoryMgr:SequenceIsPlaying()
		if (not bPlayingSeq) and LoginMapType ~= _G.LoginMapType.HairCut and LoginMapType ~= _G.LoginMapType.Fantasia then
			if _G.DemoMajorType ~= 1 then
				-- _G.BusinessUIMgr:RestoreMainPanel()
			else
				UIViewMgr:ShowView(UIViewID.LoginDemoSkill)
			end
		end
		
		EventMgr:SendEvent(EventID.NetworkReconnectLoginFinished)
	end

	self:OnLoginSuccess(self.bReconnect)
	-- NetworkStateMgr.TestDisconnect()
	-- local UWorldMgr = _G.UE.UWorldMgr:Get()
	-- if nil == UWorldMgr then
	-- 	return
	-- end
end

function LoginMgr:OnNetMsgDemoRoleLoginRes(MsgBody)
	if MsgBody.ErrorCode then
		self:OnLoginRsp(false, MsgBody.ErrorCode)
		return
	end

	FLOG_INFO("LoginMgr:OnNetMsgDemoRoleLoginRes")

	local RoleDetail = MsgBody.Login.RoleDetail
	self.RoleDetail = RoleDetail
	self.RoleID = RoleDetail and RoleDetail.Simple.RoleID or 0
	
	local USaveMgr = _G.UE.USaveMgr
	USaveMgr.SetMajorRoleID(self.RoleID)
	-- USaveMgr.SetInt(SaveKey.LastLoginRoleID, self.RoleID, false)

	self.bRoleLogin = true
	self.bReconnect = MsgBody.Login.ReConnected

	if self.bReconnect then
		UIViewMgr:HideAllUIInReconnect()
		-- UIViewMgr:HideAllUIByLayer(UILayer.All ~ UILayer.Loading)
	else
		LifeMgrModule.StartRoleLife("RoleLife")
	end

	self:SendDemoRoleEnter()

	if _G.DemoMajorType == 2 then
		local EventParams = EventMgr:GetEventParams()
		EventParams.BoolParam1 = self.bReconnect
		EventMgr:SendCppEvent(EventID.RoleLoginRes, EventParams)
		EventMgr:PostEvent(EventID.RoleLoginRes, { bReconnect = self.bReconnect })
	end

	if self.bReconnect then
		UIViewMgr:ShowView(UIViewID.LoginDemoSkill)
	end
end

function LoginMgr:OnReconnectStart(MsgBody)
	self.bReconnect = false --开始断线时，重置状态
end

function LoginMgr:OnGameEventAppEnterBackground(Params)
	FLOG_INFO("LoginMgr:OnGameEventAppEnterBackground")
	CommonUtil.StopTGPATaskCheck()
	--_G.WorldMsgMgr:MarkLevelFinished()
end

function LoginMgr:OnGameEventAppEnterForeground(Params)
	FLOG_INFO("LoginMgr:OnGameEventAppEnterForeground")
	CommonUtil.StartTGPATaskCheck()
	--_G.WorldMsgMgr:MarkLevelLoad()
end

---@param WebViewRet FAccountWebViewRet
function LoginMgr:OnGameEventWebViewOptNotify(WebViewRet)
	FLOG_INFO("[LoginMgr:OnGameEventWebViewOptNotify] ")
	local MethodNameID = WebViewRet.MethodNameID
	if MethodNameID then
		FLOG_INFO("[LoginMgr:OnGameEventWebViewOptNotify] MethodNameID:%d", MethodNameID)
		if MethodNameID == MSDKDefine.MethodName.kMethodNameWebViewJsCall then
			local MsgType = WebViewRet.MsgType
			if MsgType == 101 then -- js调用Native
				-- '{"MsdkMethod":"jsCallNative","type":"gacc:write_off_success","value":"注销游戏账号申请提交成功"}'
				-- '{"MsdkMethod":"jsCallNative","type":"gacc:write_off_fail","value":"$code|$datamore_seq_id|$message"}'
				local ExtraJson = WebViewRet.MsgJsonData
				print("[LoginMgr:OnGameEventWebViewOptNotify] MsgJsonData:", ExtraJson)
				local ExtraJsonData = string.isnilorempty(ExtraJson) and {} or Json.decode(ExtraJson)
				if string.find(ExtraJsonData.type, "write_off_success") then
					-- 销号成功，断开连接退出登录
					--_G.NetworkStateMgr:ReturnToLogin()
					EventMgr:SendEvent(EventID.DoLogoutEvent)
				end
			end

		elseif MethodNameID == MSDKDefine.MethodName.kMethodNameCloseWebViewURL then
			if self.bShowPrajnaWebView then
				FLOG_INFO("[LoginMgr:OnGameEventWebViewOptNotify] bShowPrajnaWebView")
				self.bShowPrajnaWebView = false
				_G.NetworkStateMgr:ReturnToLogin()
				self.IsNeedLogout = true
				EventMgr:SendEvent(EventID.DoLogoutEvent)
			end
		end
	end
end

function LoginMgr:OnGameEventNetworkReconnected(Params)
	if nil == Params or Params.bRelay then
		return
	end

	if self.bShowHopeView then
		FLOG_INFO("[LoginMgr:OnGameEventNetworkReconnected] bShowHopeView")
		self.bShowHopeView = false

		_G.NetworkStateMgr:ReturnToLogin()
		self.IsNeedLogout = true
		EventMgr:SendEvent(EventID.DoLogoutEvent)
	end
end

function LoginMgr:OnNetMsgRoleLogoutRes(MsgBody)
	FLOG_INFO("LoginMgr:OnNetMsgRoleLogoutRes RoleID=%d Reason=%d", MsgBody.RoleID, MsgBody.Reason)
	
	local Reason = MsgBody.Reason
	local MsgBoxParams = { HideCloseBtn = true }

	if LogoutReason.OtherLogin == Reason or LogoutReason.ServerBan == Reason then
		UIViewMgr:HideView(UIViewID.CommonMsgBox)
	end

	-- 10004(提  示)
	-- 470131 返回登录
	if LogoutReason.OtherLogin == Reason then
		local function Callback()
			local ChannelID = self:GetChannelID()
			FLOG_INFO("[LoginMgr:OnNetMsgRoleLogoutRes] OtherLogin ChannelID:%d", ChannelID)
			if ChannelID == MSDKDefine.ChannelID.WeChat then
				self.IsNeedLogout = true
				EventMgr:SendEvent(EventID.DoLogoutEvent)
			end
			self:OnRoleLogout()
		end
		-- 470129 帐号已在他处登录，点击确定退出游戏。如非本人操作，请注意帐号安全。
		MsgBoxUtil.ShowMsgBoxOneOpRightMustClick(self, LSTR(10004), LSTR(470129), Callback, LSTR(470131), MsgBoxParams)
	elseif LogoutReason.ServerBan == Reason then
		-- 470130 帐号已被封禁。
		MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(10004), LSTR(470130), self.OnRoleLogout, LSTR(470131), MsgBoxParams)
	elseif LogoutReason.LogoutByWorldKick == Reason then
		-- 服务器维护踢人
		-- 10002(确  认), 10004(提  示), 470149(服务器维护中，连接已断开，点击确定退出游戏。)
		MsgBoxUtil.ShowMsgBoxOneOpRightMustClick(self, LSTR(10004), LSTR(470149), self.OnRoleLogout, LSTR(10002), MsgBoxParams)
	else
		self:OnRoleLogout()
	end
	_G.UE.UAntiCheatMgr.Get():SetTssDataReportInterval(0.0)
end

function LoginMgr:OnNetMsgLoginEnter(MsgBody)
	if MsgBody.ErrorCode then
		self:OnLoginRsp(false, MsgBody.ErrorCode)
	end
end

function LoginMgr:OnNetMsgDemoLoginEnter(MsgBody)
	if MsgBody.ErrorCode then
		self:OnLoginRsp(false, MsgBody.ErrorCode)
	end
end

--MsgBody在断线的时候，直接传nil过来的
function LoginMgr:OnNetMsgDemoLoginExit(MsgBody)
	UIViewMgr:HideAllUI()
	UIViewMgr:ReleaseAllPoolWidgets()

	--先把主角释放掉
	_G.UE.UActorManager:Get():DestroyMajor()
	_G.StoryMgr:ResetStatusAndCacheData()

	_G.RoleInfoMgr:Reset()

	_G.LifeMgrModule.ShutdownRoleLife()
	
	--返回到选职业界面,恢复到之前的场景
	_G.LoginMapMgr:RestorLoginMap()
	-- _G.PWorldMgr:ChangeToLocalMap("/Game/Maps/Login", true)
end

---OnRoleLogout @把之前OnNetMsgRoleLogoutRes的逻辑提取成一个函数，方便其他地方调用
function LoginMgr:OnRoleLogout()
	if _G.QueueMgr.bQueueDoing then
		FLOG_INFO("[LoginMgr:OnRoleLogout] QueueMgr.bQueueDoing = true")
		_G.QueueMgr.bQueueDoing = false
		_G.QueueMgr:CancelQueue()
		--return
	end

	local Params = _G.EventMgr:GetEventParams()
	Params.IntParam1 = self.LastRoleLogOutReason
	EventMgr:SendCppEvent(EventID.RoleLogoutRes, Params)
	EventMgr:SendEvent(EventID.RoleLogoutRes, {LogOutReason = self.LastRoleLogOutReason})

	UIViewMgr:HideAllUI()
	UIViewMgr:ReleaseAllPoolWidgets()

	self.bRoleLogin = false
	--先把主角释放掉
	_G.UE.UActorManager:Get():DestroyMajor()
	_G.StoryMgr:StopSequenceInException()

	--有可能不经过logout请求直接到这里，所以在这里统一处理
	-- _G.PWorldMgr.BaseInfo = _G.PWorldMgr.BaseInfo or {}
	-- _G.PWorldMgr.BaseInfo.CurrMapResID = 1047

	_G.RoleInfoMgr:Reset()

	_G.LifeMgrModule.ShutdownRoleLife()

	if self.LastRoleLogOutReason ~= ProtoCS.LogoutReason.ExitDemo then
		_G.LifeMgrModule.ShutdownAccountLife()
	end
	
	if self.LastRoleLogOutReason == ProtoCS.LogoutReason.SwitchRole then
		_G.LoginMapMgr:ChangeLoginMap()	--不传参数就是选角场景
	else
		-- if _G.IsDemoMajor then
		if _G.DemoMajorType > 0 then
			--返回到选职业界面,恢复到之前的场景
			_G.LoginMapMgr:RestorLoginMap()
			-- _G.PWorldMgr:ChangeToLocalMap("/Game/Maps/Login", true)
		else
			_G.PWorldMgr:ChangeToLocalMap("/Game/Maps/Login", true)
		end
	end

end

function LoginMgr:OnNetMsgModuleConfigRes(MsgBody)
	FLOG_INFO("LoginMgr:OnNetMsgModuleConfigRes")

	self.SwitchList = MsgBody.SwitchList

	local DBMgr = require ("DB/DBMgr")
	DBMgr.SetResTableKeys(MsgBody.ResTableKeys)

	self:QueryRoleList()
end

function LoginMgr:SetLastRoleLogOutReason(Reason)
	self.LastRoleLogOutReason = Reason
end

function LoginMgr:GetLastRoleLogOutReason()
	return self.LastRoleLogOutReason
end

function LoginMgr:GetIsWaitRoleListMsg()
	return self.IsWaitRoleListMsg
end

function LoginMgr:GetRaceName(RaceID)
	return RaceCfg:GetRaceName(RaceID)
end

function LoginMgr:GetRaceTribeName(TribeID)
	return RaceCfg:GetRaceTribeName(TribeID)
end

function LoginMgr:CheckRoleName(Name)
	local NameLower = string.lower(Name)
	local NameBlacklist = require("Define/NameBlacklist")

	if #NameLower == 0 then
		-- 请输入角色名
		MsgTipsUtil.ShowTips(LSTR(470142))
		return false
	end

	for _, v in ipairs(NameBlacklist) do
		local pattern = v

		if (string.match(NameLower, pattern)) then
			-- 角色名不合法
			MsgTipsUtil.ShowTips(LSTR(470143))
			return false
		end
	end

	return true
end

function LoginMgr:FindModuleSwitch(ModuleID)
	local SwitchList = self.SwitchList
	if nil == SwitchList then
		return
	end

	for _, v in ipairs(SwitchList) do
		if v.ModuleID == ModuleID then
			return v
		end
	end
end

---IsModuleSwitchOn @模块开关是否打开 服务器没下发 默认是开着
---@param ModuleID boolean
function LoginMgr:IsModuleSwitchOn(ModuleID)
	if ModuleID == 1 then return true end -- @patch always enable GM
	local Switch = self:FindModuleSwitch(ModuleID)
	if nil == Switch then
		return true
	end

	return not Switch.bOff
end

function LoginMgr:CheckModuleSwitchOn(ModuleID, IsShowTips)
	local IsOn = self:IsModuleSwitchOn(ModuleID)

	if not IsOn and IsShowTips then
		-- 功能开发过程中，暂未开放
		MsgTipsUtil.ShowTips(LSTR(470144))
	end

	return IsOn
end

---ReLogin 断线重连重新登录
function LoginMgr:ReLogin(RoleID)
	self:SendRoleLoginReq(RoleID, true)
end

---ReturnToLogin @返回登录
---@param IsSendLoginOutMsg boolean @IsLoginOut为true时，需要相服务器发送退出登录消息，具体逻辑在服务器回包后处理，IsLoginOut为false时时直接执行OnRoleLogout逻辑
function LoginMgr:ReturnToLogin(IsSendLoginOutMsg)
	-- _G.IsDemoMajor = false
	_G.DemoMajorType = 0

	if IsSendLoginOutMsg then
		self:RoleLogOut()
	else
		self:OnRoleLogout()
	end
	_G.PandoraMgr:ReturnToLogin()
end

---ReturnToSelectRoleView @返回角色列表界面
function LoginMgr:ReturnToSelectRoleView()
	FLOG_INFO("LoginMgr:ReturnToSelectRoleView")
	self:RoleLogOut(ProtoCS.LogoutReason.SwitchRole)
end

function LoginMgr:GetOpenID()
	return self.OpenID
end

function LoginMgr:GetRoleID()
	return self.RoleID or 0
end

function LoginMgr:GetNickName()
	return self.NickName
end

function LoginMgr:GetAvatarUrl()
	return self.AvatarUrl
end

function LoginMgr:GetInstallChannel()
	local InstallChannelID = 0
	local Platform = CommonUtil.GetPlatformName()
	if Platform == "Android" then
		local ConfigChannel = _G.UE.UCommonUtil.GetConfigChannel("")
		InstallChannelID = tonumber(ConfigChannel) or 0
	elseif Platform == "IOS" then
		InstallChannelID = 1001
	end
	_G.FLOG_INFO("[LoginMgr:GetInstallChannel] InstallChannelID:%d", InstallChannelID)
	return InstallChannelID
end

function LoginMgr:GetToken()
	return self.Token
end

function LoginMgr:GetChannelID()
	return self.ChannelID
end

--获取原始的world
--如果想获取当前的world，局内可以使用_G.PWorldMgr:GetCurrWorldID() 
function LoginMgr:GetWorldID()
	return self.WorldID
end

---GetServerUrl @获取服务器地址
---@return string
function LoginMgr:GetServerUrl()
	if not self.WorldID then
		FLOG_ERROR("[LoginMgr] WorldID is nil !")
		return nil
	end
	if self.WorldID ~= self.LastWorldID or not self.ServerUrlList then
		self.LastWorldID = self.WorldID
		self.ServerUrlList = {}
		--local Host = ServerDirCfg:FindValue(self.WorldID, "Host")
		local Host = LoginMgr:GetMapleNodeHost(self.WorldID)

		if type(Host) == "string" then
			if string.find(Host, "tcp://") then
				table.insert(self.ServerUrlList, Host)
			else
				table.insert(self.ServerUrlList, string.format("tcp://%s", Host))
			end
		elseif type(Host) == "table" then
			for _,V in pairs(Host) do
				if string.find(V, "tcp://") then
					table.insert(self.ServerUrlList, V)
				else
					table.insert(self.ServerUrlList, string.format("tcp://%s", V))
				end
			end
		end

		table.shuffle(self.ServerUrlList)
	end
	local Count = #self.ServerUrlList
	return self.ServerUrlList[math.fmod(self.ConnectUrlIndex, Count) + 1]
end

function LoginMgr:GetDeviceInfo()
	local ViewportSize = UIUtil.GetViewportSize()
	local Platform = CommonUtil.GetPlatformName()
	local AndroidOAID = ""
	local OldIosCAID = ""
	local IosCAID = ""
	local UserAgent = ""
	if Platform == "Android" then
		AndroidOAID = _G.UE.UTDMMgr.Get():GetDeviceInfo("OAID")
	elseif Platform == "IOS" then
		OldIosCAID = _G.UE.UGPMMgr.Get():GetDataFromTGPA("DeviceToken", "PreVersion")
		IosCAID = _G.UE.UTDMMgr.Get():GetDeviceInfo("CAID")
		UserAgent = _G.UE.UTDMMgr.Get():GetDeviceInfo("UserAgent")
	end
	--DataReportUtil.GetIPAddressInfo()
    local DeviceInfo = {
        DeviceType = CommonUtil.GetDeviceType(),--设备类型ios 0 android 1  2-windows，3-mac，4-其他 5-模拟器
        ClientVersion = _G.UE.UVersionMgr.GetResourceVersion(),        -- 客户端版本号
        SystemSoftware = _G.UE.UPlatformUtil.GetOSVersion(),       -- 移动终端操作系统版本
        SystemHardware = _G.UE.UPlatformUtil.GetDeviceName(),       -- 移动终端机型
        TelecomOper = "TelecomOper",         -- 运营商
        Network =  CommonUtil.GetNetworkConnectionType(),
		ScreenWidth = ViewportSize.X,
		ScreenHeight = ViewportSize.Y,
        DeviceID = _G.UE.UPlatformUtil.GetDeviceID(),            -- 设备ID
        -- RealIMEI = _G.UE.UPlatformUtil.GetIMEI(),            -- 真实IMEI
        ClientIP = DataReportUtil.IPV4Address,              -- 客户端IP
		ClientIPv6 = DataReportUtil.IPV6Address,
		AndroidOAID = AndroidOAID,
		OldCAID = OldIosCAID,
		IosCAID = IosCAID,
		UserAgent = UserAgent,
		ChannelID = self.ChannelID ~= "10" and self.ChannelID or 0
    }

	print("LoginMgr:GetDeviceInfo, " .. _G.table_to_string(DeviceInfo))
	--_G.UE.UAntiCheatMgr.Get():SetEnableLog(true)
	_G.UE.UAntiCheatMgr.Get():GetSdkCoreData()

	return DeviceInfo
end

function LoginMgr:GetMapleTreeInfo()
	return self.TreeInfo
end

function LoginMgr:GetMapleNodeInfo(WorldID)
	local NodeInfo
	if self.AllMapleNodeInfo then
		NodeInfo = self.AllMapleNodeInfo[WorldID]
	end
	return NodeInfo
end

function LoginMgr:GetMapleNodeName(WorldID)
	local NodeName = ""
	if WorldID == nil then
		FLOG_WARNING("[LoginMgr:GetMapleNodeName] WorldID is nil")
		return NodeName
	end

	if self.AllMapleNodeInfo and self.AllMapleNodeInfo[WorldID] then --  and table.contain(self.AllMapleNodeInfo, WorldID)
		NodeName = self.AllMapleNodeInfo[WorldID].Name
	else
		NodeName = "Unknown Name"
		FLOG_WARNING("[LoginMgr:GetMapleNodeName] Can't found MapleNodeInfo by WorldID:%d", WorldID)
	end
	return NodeName
end

function LoginMgr:GetMapleNodeHost(WorldID)
	local NodeHost = ""
	if WorldID == nil then
		FLOG_WARNING("[LoginMgr:GetMapleNodeHost] WorldID is nil")
		return NodeHost
	end

	if self.AllMapleNodeInfo and self.AllMapleNodeInfo[WorldID] then --  and table.contain(self.AllMapleNodeInfo, WorldID)
		NodeHost = self.AllMapleNodeInfo[WorldID].Host
	else
		NodeHost = "Unknown Host"
		FLOG_ERROR("[LoginMgr:GetMapleNodeHost] Can't found Host by WorldID:%d", WorldID)
	end
	return NodeHost
end

function LoginMgr:GetMapleNodeOpenServerTS(WorldID)
	if not WorldID then
		return 0
	end
	if self.AllMapleNodeInfo then
		local NodeInfo = self.AllMapleNodeInfo[WorldID]
		if NodeInfo then
			return NodeInfo.CustomValue1 or 0
		end
	end
	return 0
end

function LoginMgr:OnLoginSuccess(IsReconnect)
	self.IsLoginSuccess = true
	local CurChannelID = self.ChannelID or 0
	FLOG_INFO("LoginMgr:OnLoginSuccess, IsReconnect:%s, ChannelId:%d, OpenId:%s, Token:%s, NickName:%s",
		tostring(IsReconnect), CurChannelID, self.OpenID, self.Token, self.NickName)
	local UserOpenId = tostring(self.OpenID)
	_G.UE.UAntiCheatMgr.Get():SetTssDataReportInterval(5.0)
	_G.UE.UAntiCheatMgr.Get():SetUserInfo(self.ChannelID, UserOpenId)

	OperationUtil.InitTDM(self.ChannelID, UserOpenId)

	--_G.UE.UGPMMgr.Get():SetEnableLog(true)
	if self.ChannelID == 1 or self.ChannelID == 2 then
		_G.UE.UGPMMgr.Get():UpdateGameInfoEx("OpenID", UserOpenId)
		CommonUtil.StartTGPATaskCheck()
	end

	--_G.MURSurveyMgr:BeginQueryQuestionnaire()

	if not IsReconnect then
		self:SaveWakeUpInfo()
	end

	CommonUtil.SetQuality()

	_G.PandoraMgr:InitGamelet(self.ChannelID, UserOpenId, self.RoleID, false, false)

	CommonUtil.ReportPerformanceMetricsData()

	OperationUtil.BindDevice()
end

function LoginMgr:ResetLoginSuccessStatus()
	self.IsLoginSuccess = false
end

function LoginMgr:ReqMyAndFriendSevers()
	--FLOG_INFO("[Login] LoginMgr:ReqMyAndFriendSevers")
	local Os
	if CommonUtil.IsAndroidPlatform() then
		Os = "1"
	elseif CommonUtil.IsIOSPlatform() then
		Os = "2"
	else
		Os = "5"
	end

	local OpenID = self.OpenID
	local Token = self.Token
	local ChannelID = self.ChannelID

	-- TEST
	if CommonUtil.IsWithEditor() then
		if Token == nil or Token == "root" then
			OpenID = "458258285616225238"
			Token = "2052cd8460e14b6eb4f2071f4264dfcaf584a5a8"
			ChannelID = 3
		end
	end


	-- 我的服务器列表
	self.AllMyRoles = {}
	--local NewMyUrl = HttpDNSUtil.GetAddrUrl(LoginNewDefine:GetMyServerUrl())
	self:ReqSevers(LoginNewDefine:GetMyServerUrl(self.WorldID), self.OnMyServersResponse, ChannelID, Os, OpenID, Token)
	-- 好友服务器列表
	self.FriendServers = {}
	--全部好友服务器列表
	self.AllFriendServers = {}
	--local NewFriendUrl = HttpDNSUtil.GetAddrUrl(LoginNewDefine:GetFriendServerUrl())
	self:ReqSevers(LoginNewDefine:GetFriendServerUrl(self.WorldID), self.OnFriendServersResponse, ChannelID, Os, OpenID, Token)
end

--- 请求我的服务器列表 QueryRolesByMSdk，请求好友服务器列表 QueryRolesOfFriendByMSdk
---@param Url string
---@param Callback function
---@param ChannelID string 参考LoginNewDefine.ChannelIDs
---@param Os string 参考LoginNewDefine.Os
---@param OpenID string
---@param Token string
function LoginMgr:ReqSevers(Url, Callback, ChannelID, Os, OpenID, Token)
	FLOG_INFO(string.format("[LoginMgr:ReqSevers] Url:%s, ChannelID:%s, Os:%s, OpenID:%s, Token:%s", Url, ChannelID, Os, OpenID, Token))

	local SendData = { ChannelID = ChannelID, Os = Os, OpenID = OpenID, Token = Token }
	if _G.HttpMgr:Get(Url, Token, SendData, Callback, self, false) then
		FLOG_INFO(string.format('[LoginMgr:ReqSevers] require success'))
	end
end

function LoginMgr:OnMyServersResponse(MsgBody, bSucceeded)
	if not bSucceeded or string.isnilorempty(MsgBody) then
		print("[LoginMgr:OnMyServersResponse] bSucceeded or MsgBody is nil: ", bSucceeded, MsgBody)
		return
	end
	--{
	--	"Roles":[
	--	{
	--		"RoleID":"27665088573358744",
	--		"WorldID":14,
	--		"OpenID":"10093262986685645012",
	--		"Name":"淩雲",
	--		"Prof":7,
	--		"Level":2,
	--		"LoginTime":"1735199663",
	--		"HeadPortraitID":0,
	--		"LoginChannel":0,
	--		"IsOnline":false,
	--		"HeadData":{
	--			"HeadID":0,
	--			"HeadType":0,
	--			"HeadUrl":""
	--		},
	--		"Gender":1,
	--		"Race":1,
	--		"Tribe":1
	--	}
	--	]
	--}
	FLOG_INFO("[LoginMgr:OnMyServersResponse] MsgBody:%s, bSucceeded:%s", tostring(MsgBody), tostring(bSucceeded))

--region 我的服务器测试
	if CommonUtil.IsWithEditor() then
		local TestRoles = {}
		local TestWorldIDs = {10, 11, 12, 13}
		for i = 1, #TestWorldIDs do
			local TestRoleItem = {}
			TestRoleItem.OpenID = "TEST_OPENID"
			TestRoleItem.WorldID = TestWorldIDs[i]
			TestRoleItem.RoleID = "TEST_ROLE_ID"
			TestRoleItem.Name = "TEST_NAME"
			TestRoleItem.Level = 50
			TestRoleItem.Prof = 4
			TestRoleItem.LoginTime = "1718973549"
			TestRoleItem.HeadPortraitID = 10001
			TestRoleItem.LoginChannel = 1
			TestRoleItem.IsOnline = false
			TestRoleItem.HeadData = { HeadID = 2, HeadType = 1, HeadUrl = "https://fmgame-image-1258344700.cos.ap-nanjing.tencentcos.cn/portrait/17210223786192167222111_1740035929.png" }
			TestRoleItem.Gender = 1
			TestRoleItem.Race = 1
			TestRoleItem.Tribe = 1
			table.insert(TestRoles, TestRoleItem)
		end
		local TestMsgBody = Json.encode({Roles = TestRoles})
		MsgBody = TestMsgBody
		FLOG_INFO(string.format("[LoginMgr:OnMyServersResponse] TestMsgBody:%s", table.tostring(MsgBody)))
	end
--endregion 我的服务器测试

	local MyServerRolesData = string.isnilorempty(MsgBody) and {} or Json.decode(MsgBody)
	--self.MyServerRoles = {}
	self.AllMyRoles = {}
	--local MyServerRoles = self.MyServerRoles
	local AllMyRoles = self.AllMyRoles

	if MyServerRolesData.Roles and #MyServerRolesData.Roles > 0 then
		for _, Role in ipairs(MyServerRolesData.Roles) do
			FLOG_INFO("[LoginMgr:OnMyServersResponse] Name:%s, RoleID:%s, WorldID:%d, LoginTime:%s",
					Role.Name, Role.RoleID, Role.WorldID, Role.LoginTime)

			---- 我的服务器角色数据
			--local MyServerItem = self.AllMapleNodeInfo[Role.WorldID]
			--if MyServerItem then
			--	--MyServerItem.RoleItem = Role
			--	table.insert(MyServerRoles, MyServerItem)
			--end

			AllMyRoles[Role.WorldID] = Role
		end
	end
end

function LoginMgr:OnFriendServersResponse(MsgBody, bSucceeded)
	if not bSucceeded or string.isnilorempty(MsgBody) then
		print("[LoginMgr:OnFriendServersResponse] bSucceeded or MsgBody is nil: ", bSucceeded, MsgBody)
		return
	end

	FLOG_INFO("[LoginMgr:OnFriendServersResponse] MsgBody:%s, bSucceeded:%s", tostring(MsgBody), tostring(bSucceeded))

	--{
	--	"Accounts":[
	--	{
	--		"Name":"策士",
	--		"HeadUrl":"https://thirdqq.qlogo.cn/ek_qqapp/AQAczwCwmzou6R21iayQlriaSsdrXFY9uC2He7zBP1RrTpxnoXcuBFWePRwZguibg/",
	--		"Role":{
	--			"RoleID":"27666145278860380",
	--			"WorldID":14,
	--			"OpenID":"10371924097176034046",
	--			"Name":"策士1",
	--			"Prof":3,
	--			"Level":2,
	--			"LoginTime":"1735200431",
	--			"HeadPortraitID":0,
	--			"LoginChannel":0,
	--			"IsOnline":false,
	--			"HeadData":{
	--				"HeadID":0,
	--				"HeadType":0,
	--				"HeadUrl":""
	--			},
	--			"Gender":1,
	--			"Race":1,
	--			"Tribe":1
	--		}
	--	}
	--	]
	--}
--region 好友测试
	if CommonUtil.IsWithEditor() then
		local TestFriends = {}
		self.IsDiffTest = not self.IsDiffTest
		if self.IsDiffTest then
			local Friend1 = { Name = "异常测试1", HeadUrl = "https://wx.qlogo.cn/mmhead/E2ueVyF77TUyNOn5PcaXlEUuPzD7OxibBadPOs2Gfsa0DhbAsibXzbh7PRyxzIfSAd2DA8icla7So0", Role = {
				OpenID = "OpenID1", WorldID = 10, RoleID = "RoleID1", Name = "Name1", Level = 1, Prof = 4, LoginTime = "1739448000", HeadPortraitID = 10001, IsOnline = true,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend2 = { Name = "异常测试2", HeadUrl = "", Role = {
				OpenID = "OpenID2", WorldID = 16, RoleID = "RoleID2", Name = "Name2", Level = 1, Prof = 4, LoginTime = "1739534400", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend3 = { Name = "异常测试3", HeadUrl = "", Role = {
				OpenID = "OpenID3", WorldID = 15, RoleID = "RoleID3", Name = "Name3", Level = 1, Prof = 4, LoginTime = "1740053495", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			table.insert(TestFriends, Friend1)
			table.insert(TestFriends, Friend2)
			table.insert(TestFriends, Friend3)
		else
			local Friend1 = { Name = "Friend1", HeadUrl = "https://thirdqq.qlogo.cn/ek_qqapp/AQVvCiacWFjwwxRpiaut7ql7bRTNaMj2l43Pricia2S2IY6bib75JgQE/", Role = {
				OpenID = "OpenID1", WorldID = 10, RoleID = "1680489699841714508", Name = "Name1", Level = 1, Prof = 4, LoginTime = "1739448000", HeadPortraitID = 10001, IsOnline = true,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend2 = { Name = "Friend2", HeadUrl = "https://thirdqq.qlogo.cn/ek_qqapp/AQCwbvx38eNbscS92fjzEJoTYUYz4YpLQKtKs5xS0ibjIN7EOKK6mSFyKfnZjnWibviaPzSGOV0ZgYcddlPfLY/", Role = {
				OpenID = "OpenID2", WorldID = 16, RoleID = "3639584276556433705", Name = "Name2", Level = 1, Prof = 4, LoginTime = "1739534400", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend3 = { Name = "Friend3", HeadUrl = "https://thirdqq.qlogo.cn/ek_qqapp/AQC4Cvd7cibeCl5T1vP1rdQgdkee4AordSf1ZxznukZGCtWPdJrHicHE9icgqhYuadiaZg0yp7805K2s7l9VVex25e4m1JhlZsTdZTw9rubKzxtEgqwBB5M/", Role = {
				OpenID = "OpenID3", WorldID = 15, RoleID = "3535999271137152426", Name = "Name3", Level = 1, Prof = 4, LoginTime = "1740053495", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend4 = { Name = "Friend4", HeadUrl = "https://thirdqq.qlogo.cn/ek_qqapp/AQXJ96ZUmr2GxSU0lg0F3AR8mBAG1fhZNUStN9Y5IqvBJv4Be2NuDwm06T4oUA/", Role = {
				OpenID = "OpenID4", WorldID = 17, RoleID = "3252268311187115867", Name = "Name4", Level = 1, Prof = 4, LoginTime = "1739967400", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend5 = { Name = "Friend5", HeadUrl = "https://thirdqq.qlogo.cn/ek_qqapp/AQGvyVIRUuVRocbYKAMOPHRIk0Mr1nk3Ijj1CXBkT9hn4iaV4188/", Role = {
				OpenID = "OpenID5", WorldID = 12, RoleID = "1608431369358599588", Name = "Name5", Level = 1, Prof = 4, LoginTime = "1739793600", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend6 = { Name = "Friend6", HeadUrl = "https://pic1.zhimg.com/v2-3b88207fdadae5cb1e2f84bcc847986c_xll.jpg?source=32738c0c/", Role = {
				OpenID = "OpenID6", WorldID = 11, RoleID = "1594920299768897356", Name = "Name6", Level = 1, Prof = 4, LoginTime = "1739880000", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			local Friend7 = { Name = "Friend7", HeadUrl = "https://thirdqq.qlogo.cn/ek_qqapp/AQLEs0c5M1xib6OLOgdARGxPfeueuDIa67V1aXtLNAnicJ4kHWW8h3ftLVapSAtg/", Role = {
				OpenID = "OpenID7", WorldID = 19, RoleID = "1576905845047616337", Name = "Name7", Level = 1, Prof = 4, LoginTime = "1739966400", HeadPortraitID = 10001, IsOnline = false,
				HeadData = {HeadID = 0, HeadType = 0, HeadUrl = ""}, Gender = 1, Race = 1, Tribe = 1
			}
			}
			table.insert(TestFriends, Friend1)
			table.insert(TestFriends, Friend2)
			table.insert(TestFriends, Friend3)
			table.insert(TestFriends, Friend4)
			table.insert(TestFriends, Friend5)
			table.insert(TestFriends, Friend6)
			table.insert(TestFriends, Friend7)
		end
		--------------------------------------------------------------------------------------------------------------
		local TestMsgBody = Json.encode({Accounts = TestFriends})
		MsgBody = TestMsgBody
		FLOG_INFO(string.format("[LoginMgr:OnFriendServersResponse] TestMsgBody:%s", table.tostring(MsgBody)))
	end
--endregion 好友测试

	local NormalServerListData = {}
	local MaintenanceServerListData = {}

	-- https://docs.msdk.qq.com/v5/zh-CN/Server/friendlists.html
	---@type ServerFriends
	local FriendServersData = string.isnilorempty(MsgBody) and {} or Json.decode(MsgBody)
	if FriendServersData.Accounts and #FriendServersData.Accounts > 0 then
		for _, Account in ipairs(FriendServersData.Accounts) do
			-- 判断Account.HeadUrl是否是/结尾
			local HeadUrl = Account.HeadUrl
			if not string.isnilorempty(HeadUrl) then
				if not string.match(HeadUrl, "/$") then
					HeadUrl = HeadUrl .. "/"
				end

				if MSDKDefine.ChannelID.QQ == LoginMgr.ChannelID then
					-- QQ 好友头像 URL，必须在 URL 后追加参数 /40 或 /100
					HeadUrl = HeadUrl .. "100" or nil
				elseif MSDKDefine.ChannelID.WeChat == LoginMgr.ChannelID then
					-- 微信好友头像 URL，必须在 URL 后追加参数 /0、/46、/64、/96 或 /132
					HeadUrl = HeadUrl .. "132" or nil
				else
					HeadUrl = HeadUrl .. "100" or nil
				end
			end
			Account.HeadUrl = HeadUrl

			local NodeInfo = LoginMgr:GetMapleNodeInfo(Account.Role.WorldID)
			if NodeInfo and NodeInfo.State ~= LoginNewDefine.ServerStateEnum.Maintenance then
				table.insert(NormalServerListData, Account)
			else
				table.insert(MaintenanceServerListData, Account)
			end

			FLOG_INFO("[LoginMgr:OnFriendServersResponse] Account name:%s, headUrl:%s ---------->", Account.Name, Account.HeadUrl or "nil")
		end
	end

	local function MySort(A, B)
		-- 优先按在线状态排序
		if A.Role.IsOnline ~= B.Role.IsOnline then
			return A.Role.IsOnline
		end

		-- 在线角色按世界ID排序，离线角色按登录时间倒序
		if A.Role.IsOnline then
			return A.Role.WorldID < B.Role.WorldID
		else
			return tonumber(A.Role.LoginTime) > tonumber(B.Role.LoginTime)
		end
	end

	table.sort(NormalServerListData, MySort)
	table.sort(MaintenanceServerListData, MySort)

	self.FriendServers = {}
	self.AllFriendServers = {}
	local function AddServers(serverList)
		for i = 1, #serverList do
			--其他地方可能用到全部好友数据
			table.insert(self.AllFriendServers, serverList[i])
			
			--登录仅显示六个数据
			if #self.FriendServers < 6 then
				table.insert(self.FriendServers, serverList[i])
			end
		end
	end
	AddServers(NormalServerListData)
	AddServers(MaintenanceServerListData)

	EventMgr:SendEvent(EventID.MapleFriendServerNotify)
end

--- 账号注销条件查询
function LoginMgr:QueryAccountCancellation()
	local Os
	if CommonUtil.IsAndroidPlatform() then
		Os = "1"
	elseif CommonUtil.IsIOSPlatform() then
		Os = "2"
	else
		Os = "5"
	end

	local Url = LoginNewDefine:GetAccountCancellationUrl(self.WorldID)
	local OpenID = self.OpenID
	local Token = self.Token
	local ChannelID = self.ChannelID

	-- TEST
	if CommonUtil.IsWithEditor() then
		if Token == nil or Token == "root" then
			OpenID = "458258285616225238"
			Token = "2052cd8460e14b6eb4f2071f4264dfcaf584a5a8"
			ChannelID = 3
		end
	end

	FLOG_INFO(string.format("[LoginMgr:QueryAccountCancellation] Url:%s, ChannelID:%s, Os:%s, OpenID:%s, Token:%s", Url, ChannelID, Os, OpenID, Token))

	self.bCancelAccountCancellation = false

	local SendData = { ChannelID = ChannelID, Os = Os, OpenID = OpenID, Token = Token }
	if _G.HttpMgr:Get(Url, Token, SendData, self.OnAccountCancellationResponse, self, false) then
		FLOG_INFO(string.format('[LoginMgr:QueryAccountCancellation] require success'))
	end
end

function LoginMgr:OnAccountCancellationResponse(MsgBody, bSucceeded)
	if self.bCancelAccountCancellation == true then
		FLOG_WARNING("[LoginMgr:OnAccountCancellationResponse] bCancelAccountCancellation == true")
		return
	end

	if not bSucceeded then
		FLOG_ERROR("[LoginMgr:OnAccountCancellationResponse] Failed : %s", MsgBody)
		return
	end

	--{
	--	"Data": [
	--		{
	--			"RoleID": "5154520592365684",
	--			"RoleName": "dsfger",
	--			"GroupChat": false,
	--			"Friend": false,
	--			"NewChannel": false,
	--			"Team": false
	--		},
	--		{
	--			"RoleID": "5154522502598718",
	--			"RoleName": "grt",
	--			"GroupChat": false,
	--			"Friend": false,
	--			"NewChannel": false,
	--			"Team": false
	--		}
	--	]
	--}
	FLOG_INFO(string.format("[LoginMgr:OnAccountCancellationResponse] MsgBody:%s, bSucceeded:%s", MsgBody, tostring(bSucceeded)))
	if string.isnilorempty(MsgBody) then
		FLOG_ERROR("[LoginMgr:OnAccountCancellationResponse] invalid MsgBody : [%s]", MsgBody)
	end

--region 我的服务器测试
	if CommonUtil.IsWithEditor() then
		local TestData = {}
		for i = 1, 2 do
			local AccountInfoItem = {}
			AccountInfoItem.RoleID = "TEST_ROLE_ID"
			AccountInfoItem.RoleName = "TEST_NAME"
			AccountInfoItem.GroupChat = false
			AccountInfoItem.Friend = false
			AccountInfoItem.NewChannel = true
			AccountInfoItem.Team = true
			table.insert(TestData, AccountInfoItem)
		end
		local TestMsgBody = Json.encode({Data = TestData})
		MsgBody = TestMsgBody
		FLOG_INFO(string.format("[LoginMgr:OnAccountCancellationResponse] TestMsgBody:%s", table.tostring(MsgBody)))
	end
--endregion 我的服务器测试

	self.AllAccountInfos = {}
	local AllAccountInfos = self.AllAccountInfos

	local AccountInfoData = string.isnilorempty(MsgBody) and {} or Json.decode(MsgBody)
	if AccountInfoData.Data and #AccountInfoData.Data > 0 then
		--for _, InfoItem in ipairs(AccountInfoData.Data) do
		--
		--	FLOG_INFO("[LoginMgr:OnAccountCancellationResponse] AccountInfos: --------------------->")
		--	FLOG_INFO("RoleName:%s, \nRoleID:%s, \nGroupChat:%s, \nFriend:%s, \nNewChannel:%s, \nTeam:%s", InfoItem.RoleName, InfoItem.RoleID,
		--			InfoItem.GroupChat and "true" or "false", InfoItem.Friend and "true" or "false", InfoItem.NewChannel and "true" or "false", InfoItem.Team and "true" or "false")
		--	table.insert(AllAccountInfos, InfoItem)
		--end
		self.AccountCancellationCheckResult = true

		for i = 1, #AccountInfoData.Data do
			local InfoItem = AccountInfoData.Data[i]
			InfoItem.Index = i
			FLOG_INFO("[LoginMgr:OnAccountCancellationResponse] AccountInfos: --------------------->")
			FLOG_INFO("Index:%d \nRoleName:%s, \nRoleID:%s, \nGroupChat:%s, \nFriend:%s, \nNewChannel:%s, \nTeam:%s", InfoItem.Index, InfoItem.RoleName, InfoItem.RoleID,
					InfoItem.GroupChat and "true" or "false", InfoItem.Friend and "true" or "false", InfoItem.NewChannel and "true" or "false", InfoItem.Team and "true" or "false")

			if InfoItem.GroupChat == true or InfoItem.Friend == true or InfoItem.NewChannel == true or InfoItem.Team == true then
				self.AccountCancellationCheckResult = false
			end
			--table.insert(AllAccountInfos, InfoItem)

			local AccountCheckTitleInfo = {}
			AccountCheckTitleInfo.ItemViewType = 0
			AccountCheckTitleInfo.Index = i
			AccountCheckTitleInfo.RoleID = InfoItem.RoleID
			AccountCheckTitleInfo.RoleName = InfoItem.RoleName
			table.insert(AllAccountInfos, AccountCheckTitleInfo)

			local AccountCheckItemInfo1 = {}
			AccountCheckItemInfo1.ItemViewType = 1
			AccountCheckItemInfo1.Type = LoginNewDefine.AccountCancellationCheckType.GroupChat
			AccountCheckItemInfo1.CheckResult = InfoItem.GroupChat
			table.insert(AllAccountInfos, AccountCheckItemInfo1)
			local AccountCheckItemInfo2 = {}
			AccountCheckItemInfo2.ItemViewType = 1
			AccountCheckItemInfo2.Type = LoginNewDefine.AccountCancellationCheckType.Friend
			AccountCheckItemInfo2.CheckResult = InfoItem.Friend
			table.insert(AllAccountInfos, AccountCheckItemInfo2)
			local AccountCheckItemInfo3 = {}
			AccountCheckItemInfo3.ItemViewType = 1
			AccountCheckItemInfo3.Type = LoginNewDefine.AccountCancellationCheckType.NewChannel
			AccountCheckItemInfo3.CheckResult = InfoItem.NewChannel
			table.insert(AllAccountInfos, AccountCheckItemInfo3)
			local AccountCheckItemInfo4 = {}
			AccountCheckItemInfo4.ItemViewType = 1
			AccountCheckItemInfo4.Type = LoginNewDefine.AccountCancellationCheckType.Team
			AccountCheckItemInfo4.CheckResult = InfoItem.Team
			table.insert(AllAccountInfos, AccountCheckItemInfo4)
		end
	end

	EventMgr:SendEvent(EventID.AccountCancellationEvent)
end

function LoginMgr:OnGameEventPWorldMapExit()
	self:ReleaseLoginScene()
end

--第一次登录、进创角几个场景
function LoginMgr:CreateLoginScene(bFirstLogin)
	if not _G.LoginMapMgr:IsSelectRoleMap() then
		return
	end

	FLOG_INFO("LoginMgr:CreateLoginScene")
	self:ReleaseLoginScene()
	if not self.LoginScene then
		local ActorPath = "Blueprint'/Game/UMG/3DUI/LoginScene/LoginScene_Blueprint.LoginScene_Blueprint_C'"
		local ActorClass = _G.ObjectMgr:LoadClassSync(ActorPath)
		if (ActorClass) then
			local Pos = _G.UE.FRotator(0, 0, 0)
			self.LoginScene = _G.CommonUtil.SpawnActor(ActorClass, Pos)
			self.LoginSceneRef = UnLua.Ref(self.LoginScene)

			if not bFirstLogin then
				if self.LoginScene then
					--预览场景切图后，更早的显示圆台
					self.LoginScene:ShowLoginCreateAnim()
					self:TodPostProcessComBlendWeight(1)
				end
			else
				self:OnLoginSceneBeginPlay()
			end
		end
	end
end

function LoginMgr:OnLoginSceneBeginPlay()
	if self.LoginScene then
		self.LoginScene:ShowLoginAnim()
	end
end

function LoginMgr:SwitchLoginCamera()
	-- if self.LoginScene then
	-- 	local CameraMgr = _G.UE.UCameraMgr.Get()
	-- 	if CameraMgr then
	-- 		CameraMgr:SwitchCamera(self.LoginScene, 0)
	-- 	end
	-- end
end

--进登录界面(第一次进，从创角返回，从局内返回)
function LoginMgr:OnShowLoginScene()
	self.bBackToSelectRoleFromCreate = false
	if self.LoginScene then
		self.LoginScene:ShowLoginAnim()
		-- self:SwitchLoginCamera()
		
		self:TodPostProcessComBlendWeight(0)
	end
end

function LoginMgr:TodPostProcessComBlendWeight(Weight)
	local TODMainActor = _G.UE.UEnvMgr:Get():GetTodSystem()
	if nil ~= TODMainActor and nil ~= TODMainActor.PostProcessCom then
		TODMainActor.PostProcessCom.BlendWeight = Weight
	end
end

--到创角/选角
--这些不用处理相机了
function LoginMgr:ShowLoginToCreateRoleAnim()
	if self.LoginScene then
		self.LoginScene:ShowLoginToRoleAnim()

		-- --要进入创角了
		-- _G.LoginUIMgr:CreateCameraActor()

		local function DelaySetBlendWeight()
			self:TodPostProcessComBlendWeight(1)
		end
		_G.TimerMgr:AddTimer(nil, DelaySetBlendWeight, 1.5, 1, 1)
	end
end

--从选角返回登录界面  todo，从创角到登录也要处理
--这些不用处理相机了
function LoginMgr:ShowBackLoginAnim()
	if self.LoginScene then
		FLOG_INFO("[LoginMgr:ShowBackLoginAnim] ")
		_G.NetworkStateMgr:Disconnect()

		self.IsStartGame = false
		self.LoginScene:ShowBackLoginAnim()
		-- self:SwitchLoginCamera()
		self:TodPostProcessComBlendWeight(0)
		_G.LoginUIMgr:ResetCreateCamersParams()
	end
end

function LoginMgr:ResetTodPostProcessComBlendWeight()
	self:TodPostProcessComBlendWeight(1)
	local function DelaySetBlendWeight()
		self:TodPostProcessComBlendWeight(0)
	end
	self:RegisterTimer(DelaySetBlendWeight, 0.25)
end

function LoginMgr:ReleaseLoginScene()
	FLOG_INFO("[LoginMgr:ReleaseLoginScene] ")
	if self.LoginSceneRef and self.LoginScene and CommonUtil.IsObjectValid(self.LoginScene) then

		UnLua.Unref(self.LoginScene)
		self.LoginSceneRef = nil
		self.LoginScene = nil
	end

	if self.LoginScene then
		self.LoginScene = nil
	end
end

function LoginMgr:RepairHotUpdate(bReset)
	FLOG_INFO("[LoginMgr:RepairHotUpdate] start ------------------------------> bReset:%s", tostring(bReset))
	local ResVer
	local ClearDir

	if bReset then
		ResVer = VersionMgr.GetBreakedAppVersion()
		ClearDir = VersionMgr.GetGameSrcDownloaderBaseDir()
	else
		ResVer = VersionMgr.GetBreakedResourceVersion()
		if ResVer.Four <= 1 then
			FLOG_WARNING("[LoginMgr:RepairHotUpdate] No need to update resource version")
		else
			ResVer.Four = 1
		end
		ClearDir = _G.UE.UDolphinMgr.Get():GetDolphinDownloadDir(true)
	end

	--修改本地资源的版本号
	VersionMgr.SetResourceVersion(ResVer)
	FLOG_INFO("[LoginMgr:RepairHotUpdate] SetResourceVersion:%s.%s.%s.%s", ResVer.One, ResVer.Two, ResVer.Three, ResVer.Four)

	if bReset then
		--【重置】调用 GetReleasePatchRecorder().ClearReuseVerAndHierarchy()，然后 SaveRecorderToDisk
		VersionMgr.Get():ClearReuseVerAndHierarchy()
		VersionMgr.Get():SaveRecorderToDisk()
		FLOG_INFO("[LoginMgr:RepairHotUpdate] SaveRecorderToDisk")

		--【重置】先删掉Downloader/[Version]/Puffer 目录下的 puffer_temp 和 puffer_res.eifs
		local PufferResRet = false
		local PufferTempRet = false
		local PufferDownloaderDir = _G.UE.UPufferMgr.Get():GetPufferDownloadDir()
		local PufferResPath = string.format("%s/%s", PufferDownloaderDir, "puffer_res.eifs")
		if PathMgr.ExistFile(PufferResPath) then
			PufferResRet = PathMgr.DeleteFile(PufferResPath)
		end
		local PufferTempPath = string.format("%s/%s", PufferDownloaderDir, "puffer_temp")
		if PathMgr.ExistDir(PufferTempPath) then
			PufferTempRet = PathMgr.DeleteDir(PufferTempPath)
		end
		FLOG_INFO("[LoginMgr:RepairHotUpdate] Clear puffer info. [puffer_res.eifs:%s], [puffer_temp:%s]", tostring(PufferResRet), tostring(PufferTempRet))
	end

	-- Unmount
	FLOG_INFO("[LoginMgr:RepairHotUpdate] Unmount start --->")
	local PakPaths = UE.TArray(UE.FString)
	PathMgr.FindFilesRecursively(PakPaths, ClearDir, "*.pak", true, true, true)
	if PakPaths:Num() > 0 then
		for i = 1, PakPaths:Num() do
			local PakPath = PakPaths:Get(i)
			local Ret = _G.UE.UVersionMgr.Get():UnMountPak(PakPath)
			FLOG_INFO("[LoginMgr:RepairHotUpdate] Unmount pak result (%s) -> %s", tostring(Ret), PakPath)
		end
	end
	FLOG_INFO("[LoginMgr:RepairHotUpdate] Unmount end <---")

	-- 尝试实际删除文件（不一定能删掉，有异步加载可能会导致引擎崩溃）
	local ClearRet = false
	if PathMgr.ExistDir(ClearDir) then
		ClearRet = PathMgr.DeleteDir(ClearDir)
	end
	FLOG_INFO("[LoginMgr:RepairHotUpdate] Clear result %s : (%s)", ClearDir, tostring(ClearRet))

	-- 提示重启
	-- 470003(已重置客户端，请重启游戏)
	-- 470004(已修复客户端，请重启游戏)
	local TipStr = bReset and LSTR(LoginStrID.ResetAndRestart) or LSTR(LoginStrID.RepairAndRestart)
	self:RegisterTimer(function()
		local MsgBoxParams = { HideCloseBtn = true }
		local function Callback()
			FLOG_INFO("[LoginMgr:RepairHotUpdate] QuitGame and restart")
			CommonUtil.RestartGame()
		end
		-- 10004(提  示)
		-- 10002(确  认)
		MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(10004), TipStr, Callback, LSTR(10002), MsgBoxParams)
	end, 0.25)
end

function LoginMgr:ChangeMSDKEnv()
	_G.UE.UGCloudMgr.Get():ChangeMSDKEnv()

	local MsgBoxParams = { HideCloseBtn = true }
	local function Callback()
		FLOG_INFO("[LoginMgr:ChangeMSDKEnv] QuitGame and restart")
		CommonUtil.RestartGame()
	end
	-- 10002(确  认)
	-- 10004(提  示)
	-- 470005(MSDK环境已切换，重启生效)
	MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(10004), LSTR(LoginStrID.MSDKEvnChanged), Callback, LSTR(10002), MsgBoxParams)
end

-- https://hktest.itop.qq.com
-- https://itop.qq.com
function LoginMgr:ChangeMSDKUrlTest()
	self:ChangeMSDKUrl("https://itop.qq.com")
end

function LoginMgr:ChangeMSDKUrl(MSDKUrl)
	_G.UE.UGCloudMgr.Get():ChangeMSDKUrl(MSDKUrl)

	-- 470005(MSDK环境已切换，重启生效)
	local TipsContent = string.format("%s\n%s", LSTR(LoginStrID.MSDKEvnChanged), MSDKUrl)
	local MsgBoxParams = { HideCloseBtn = true }
	local function Callback()
		FLOG_INFO("[LoginMgr:ChangeMSDKUrl] QuitGame and restart")
		CommonUtil.RestartGame()
	end
	-- 10002(确  认)
	-- 10004(提  示)
	MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(10004), TipsContent, Callback, LSTR(10002), MsgBoxParams)
end

function LoginMgr:OnWakeUpSuccess(ExtraParams)
	--FLOG_INFO("LoginMgr:OnWakeUpSuccess, ExtraParams:%s", ExtraParams)
	local Params = Json.decode(ExtraParams)
	--FLOG_INFO("LoginMgr:OnWakeUpSuccess, Params:%s", _G.TableToString(Params))
	if nil ~= Params.game_data then
		if Params.game_data == "WX_GameCenter" then
			self.IsWechatWakeUp = true
		elseif Params.game_data == "sq_gamecenter" then
			self.IsQQWakeUp = true
		else
			local InnerParams = Json.decode(Params.params)
			if nil ~= InnerParams and nil ~= InnerParams.launchfrom and InnerParams.launchfrom == "sq_gamecenter" then
				self.IsQQWakeUp = true
				--FLOG_INFO("LoginMgr:OnWakeUpSuccess, qq wakeup success!")
			end
		end
	end
end

function LoginMgr:OnWakeUpNeedSelectAccount()
	local function OkBtnCallback()
		self.IsNeedSwitchAccountByWakeUp = true
		if self.IsLoginSuccess then
			_G.LoginMgr:ReturnToLogin(true)
		else
			UIViewMgr:HideAllUI()
			UIViewMgr:ReleaseAllPoolWidgets()
			UIViewMgr:ShowView(self:GetLoginMainViewId())
			_G.LifeMgrModule.ShutdownAccountLife()
		end
	end

	local function CancelBtnCallback()
		self:ResetWakeUpState()
	end

	local Tips = ""
	if self.IsWechatWakeUp then
		-- 100005 微信帐号与游戏登录的帐号不一致，是否切换帐号？
		Tips = _G.LSTR(100005)
		self.IsNeedChangeWeChatAccount = true
	elseif self.IsQQWakeUp then
		-- 100006 QQ帐号与游戏登录的帐号不一致，是否切换帐号？
		Tips = _G.LSTR(100006)
		self.IsNeedChangeQQAccount = true
	end
	MsgBoxUtil.MessageBox(Tips, _G.LSTR(10002), _G.LSTR(10003), OkBtnCallback, CancelBtnCallback)
end

function LoginMgr:ResetWakeUpSwitchState()
	self.IsLoginSuccess = false
	self.IsNeedSwitchAccountByWakeUp = false
	self.IsNeedChangeWeChatAccount = false
	self.IsNeedChangeQQAccount = false
	self.IsWakeUpFromLaunch = false
end

function LoginMgr:SaveWakeUpInfo()
	local SaveTime = TimeUtil.GetServerTime()
	local OpenIDStr = tostring(self.OpenID)
	FLOG_INFO("LoginMgr:SaveWakeUpInfo, IsWechatWakeUp:%s, IsQQWakeUp:%s, OpenIDStr:%s, SaveTime:%d",
		tostring(self.IsWechatWakeUp), tostring(self.IsQQWakeUp), OpenIDStr, SaveTime)
	if self.IsWechatWakeUp then
		local WeChatLaunchPrivilegeList = {}
		local LastSaveData = _G.UE.USaveMgr.GetString(SaveKey.WeChatLaunchPrivilege, "", false)
		if not string.isnilorempty(LastSaveData) then
			FLOG_INFO("LoginMgr:SaveWakeUpInfo, IsWechatWakeUp, LastSaveData:%s", LastSaveData)
			WeChatLaunchPrivilegeList = Json.decode(LastSaveData)
			if nil == WeChatLaunchPrivilegeList then
				WeChatLaunchPrivilegeList = {}
			end
		else
			FLOG_INFO("LoginMgr:SaveWakeUpInfo, IsWechatWakeUp, LastSaveData is nil or empty!")
		end
		WeChatLaunchPrivilegeList[OpenIDStr] = SaveTime
		local SaveValue = Json.encode(WeChatLaunchPrivilegeList)
		FLOG_INFO("LoginMgr:SaveWakeUpInfo, IsWechatWakeUp, SaveValue:%s",SaveValue)
		_G.UE.USaveMgr.SetString(SaveKey.WeChatLaunchPrivilege, SaveValue, false)
	elseif self.IsQQWakeUp then
		local QQLaunchPrivilegeList = {}
		local LastSaveData = _G.UE.USaveMgr.GetString(SaveKey.QQLaunchPrivilege, "", false)
		if not string.isnilorempty(LastSaveData) then
			FLOG_INFO("LoginMgr:SaveWakeUpInfo, IsQQWakeUp, LastSaveData:%s", LastSaveData)
			QQLaunchPrivilegeList = Json.decode(LastSaveData)
			if nil == QQLaunchPrivilegeList then
				QQLaunchPrivilegeList = {}
			end
		else
			FLOG_INFO("LoginMgr:SaveWakeUpInfo, IsQQWakeUp, LastSaveData is nil or empty!")
		end
		QQLaunchPrivilegeList[OpenIDStr] = SaveTime
		local SaveValue = Json.encode(QQLaunchPrivilegeList)
		FLOG_INFO("LoginMgr:SaveWakeUpInfo, IsQQWakeUp, SaveValue:%s",SaveValue)
		_G.UE.USaveMgr.SetString(SaveKey.QQLaunchPrivilege, SaveValue, false)
	end

	self:ResetWakeUpState()
end

function LoginMgr:ResetWakeUpState()
	FLOG_INFO("[LoginMgr:ResetWakeUpState] ")
	self.IsWechatWakeUp = false
	self.IsQQWakeUp = false
	self.IsNeedLoginFromGameCenter = false
	self.IsWakeUpFromLaunch = false
end

function LoginMgr:IsWakeUpByWeChatOrQQ(ChannelID)
	local LastSaveValue = ""
	if ChannelID == MSDKDefine.ChannelID.WeChat then
		LastSaveValue = _G.UE.USaveMgr.GetString(SaveKey.WeChatLaunchPrivilege, "", false)
	end
	if ChannelID == MSDKDefine.ChannelID.QQ then
		LastSaveValue = _G.UE.USaveMgr.GetString(SaveKey.QQLaunchPrivilege, "", false)
	end

	if not string.isnilorempty(LastSaveValue) then
		FLOG_INFO("LoginMgr:IsWakeUpByWeChatOrQQ, LastSaveValue:%s", LastSaveValue)
		local JsonValue = Json.decode(LastSaveValue)
		if nil == JsonValue then
			FLOG_WARNING("LoginMgr:IsWakeUpByWeChatOrQQ, JsonValue is nil")
			return false
		end

		local OpenIDStr = tostring(self.OpenID)
		if nil == JsonValue[OpenIDStr] then
			FLOG_WARNING("LoginMgr:IsWakeUpByWeChatOrQQ, OpenID: %s is not exist!", OpenIDStr)
			return false
		end

        local LastSaveTime = JsonValue[OpenIDStr]
		local CurTime = TimeUtil.GetServerTime()
		local CurDay = math.ceil(CurTime / 86400)
		local LastSaveDay = math.ceil(LastSaveTime / 86400)
		FLOG_INFO("LoginMgr:IsWakeUpByWeChatOrQQ, ChannelID:%d, OpenIDStr:%s, CurDay:%d, LastSaveDay:%d", ChannelID, OpenIDStr, CurDay, LastSaveDay)
		if LastSaveTime ~= 0 and (CurDay - LastSaveDay) == 0 then
			return true
		end
	else
		FLOG_WARNING("LoginMgr:IsWakeUpByWeChatOrQQ, LastSaveValue is nil or empty!")
	end

	return false
end

---GetIsReconnect
---@return boolean @是否通过断线重连登录
function LoginMgr:GetIsReconnect()
	return self.bReconnect
end

---GetLoginMainViewId
function LoginMgr:GetLoginMainViewId()
	if CommonUtil.IsInternationalChina() then
		return UIViewID.LoginMainNew
	else
		return UIViewID.LoginMainOversea
	end
end

---GetIsResearchLogin
---@return boolean @是否研发登录
function LoginMgr:GetIsResearchLogin()
	local IsResearchLogin = false
    if self.Token == "root" and self.ChannelID == "10" then
		IsResearchLogin = true
    end
    return IsResearchLogin
end

function LoginMgr:IsQQLogin()
    return self.ChannelID == MSDKDefine.ChannelID.QQ
end

function LoginMgr:IsWeChatLogin()
    return self.ChannelID == MSDKDefine.ChannelID.WeChat
end

function LoginMgr:QueryIntegration()
	local Url = LoginNewDefine:GetIntegrationUrl(self.WorldID)
	FLOG_INFO(string.format("[LoginMgr:QueryIntegration] Url:%s", Url))

	local SendData = { Version = 1 }

	if _G.HttpMgr:Get(Url, "", SendData, self.OnQueryIntegrationResponse, self, false) then
	    FLOG_INFO(string.format('[LoginMgr:QueryIntegration] request success'))
	end
end

function LoginMgr:OnQueryIntegrationResponse(MsgBody, bSucceeded)
	if not bSucceeded then
		FLOG_WARNING("[LoginMgr:OnQueryIntegrationResponse] Failed : %s", MsgBody)
		return
	end

	FLOG_INFO(string.format("[LoginMgr:OnQueryIntegrationResponse] MsgBody:%s, bSucceeded:%s", MsgBody, tostring(bSucceeded)))
	if string.isnilorempty(MsgBody) then
		FLOG_WARNING("[LoginMgr:OnQueryIntegrationResponse] invalid MsgBody : [%s]", MsgBody)
	end

	--{
	--	"head": {
	--	"PacketLen": 0,
	--	"Cmdid": 4280,
	--	"Seqid": 0,
	--	"ServiceName": "",
	--	"SendTime": 0,
	--	"Version": 0,
	--	"Authenticate": "",
	--	"Result": 0,
	--	"RetErrMsg": "success"
	--},
	--	"body": {
	--		"CommunicationData": {
	--		"ID": 3,
	--		"Title": "fff",
	--		"ShowLocation": 1,
	--		"ChannelVersionCfg": [{
	--			"ActivityURL": "11",
	--			"ChannelID": "1"
	--		}],
	--		"ChannelVersionCfg_count": 1
	--	},
	--		"Result": 0,
	--		"RetMsg": "success"
	--	}
	--}
	local Data = string.isnilorempty(MsgBody) and {} or Json.decode(MsgBody)
	if Data then

	end
end

return LoginMgr