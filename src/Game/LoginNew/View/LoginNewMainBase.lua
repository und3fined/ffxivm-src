---
--- Author: richyczhou
--- DateTime: 2024-06-25 10:00
--- Description:
---

local CommonDefine = require("Define/CommonDefine")
local CommonUtil = require("Utils/CommonUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LuaClass = require("Core/LuaClass")
local MSDKDefine = require("Define/MSDKDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local PreDownloadMgr = require("Game/LoginNew/Mgr/PreDownloadMgr")
local SaveKey = require("Define/SaveKey")
local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local OperationUtil = require("Utils/OperationUtil")
local QueueMgr = require("Game/LoginNew/Mgr/QueueMgr")
local IOS26ResDownloadMgr = require("Game/LoginNew/Mgr/IOS26ResDownloadMgr")

local AudioMgr = _G.UE.UAudioMgr:Get()
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local FTAIAuthUtil = _G.UE.FTAIAuthUtil
local USaveMgr = _G.UE.USaveMgr
local ESlateVisibility = _G.UE.ESlateVisibility
local EDataReportLoginPhase = _G.UE.EDataReportLoginPhase
local LoginStrID = LoginNewDefine.LoginStrID

local DEFAULT_WORLD_ID = 10    --IDC每日构建
local DEFAULT_TEST_WORLD_ID = 11    --IDC稳定测试

---@class LoginNewMainBase : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgeTips UFButton
---@field BtnCG UFButton
---@field BtnCheck UFButton
---@field BtnCustomerService UFButton
---@field BtnDownload LoginNewDownloadItemView
---@field BtnHelp UFButton
---@field BtnLogout UFButton
---@field BtnNotice UFButton
---@field BtnQQ UFButton
---@field BtnQQ2 UFButton
---@field BtnRepair UFButton
---@field BtnResearch UFButton
---@field BtnScan UFButton
---@field BtnSever UFButton
---@field BtnTAIAuthLogout UFButton
---@field BtnVolume UToggleButton
---@field BtnWeChat2 UFButton
---@field BtnWechat UFButton
---@field CoverImage UImage
---@field FHorizontalAgree UFHorizontalBox
---@field FHorizontalBoxServer UFHorizontalBox
---@field FVerticalBox UFVerticalBox
---@field HorizontalLogin UHorizontalBox
---@field IconQQ2 UFImage
---@field IconWeChat UFImage
---@field ImgCheck UFImage
---@field ImgCheckBg UFImage
---@field ImgCheckFx UFImage
---@field ImgQQ UFImage
---@field ImgResearch UFImage
---@field ImgVolume UFImage
---@field ImgVolumeClose UFImage
---@field ImgWechat UFImage
---@field InputBox CommInputBoxView
---@field LoginLogoPage LoginLogoPageView
---@field LoginMovieImage UFImage
---@field LoginNewProBar LoginNewProBarItemView
---@field LoginNewSeverState LoginNewSeverItemView
---@field PanelCheck UFCanvasPanel
---@field PanelFriends UFCanvasPanel
---@field PanelFx UFCanvasPanel
---@field PanelInput UFCanvasPanel
---@field PanelLogin UFCanvasPanel
---@field PanelLogout UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field PanelScan UFCanvasPanel
---@field PanelScanLogin UFCanvasPanel
---@field PanelSever UFCanvasPanel
---@field PanelText UFCanvasPanel
---@field PanelTextNotice UFCanvasPanel
---@field RichText URichTextBox
---@field TAIAuthPanel UFCanvasPanel
---@field TableViewFriends UTableView
---@field TextCopyright1 UFTextBlock
---@field TextCopyright2 UFTextBlock
---@field TextFriends UFTextBlock
---@field TextHealthy UFTextBlock
---@field TextLogout UFTextBlock
---@field TextNotice1 UFTextBlock
---@field TextNotice2 UFTextBlock
---@field TextNum UFTextBlock
---@field TextNum1 UFTextBlock
---@field TextNum2 UFTextBlock
---@field TextNum3 UFTextBlock
---@field TextPrepare UFTextBlock
---@field TextQQ UFTextBlock
---@field TextQQ2 UFTextBlock
---@field TextResearch UFTextBlock
---@field TextScan UFTextBlock
---@field TextSever UFTextBlock
---@field TextTAIAuthLogout UFTextBlock
---@field TextTAIAuthUser UFTextBlock
---@field TextWeChat2 UFTextBlock
---@field TextWechat UFTextBlock
---@field AnimFHorizontalIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewMainBase = LuaClass(UIView, true)

function LoginNewMainBase:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgeTips = nil
	--self.BtnCG = nil
	--self.BtnCheck = nil
	--self.BtnCustomerService = nil
	--self.BtnDownload = nil
	--self.BtnHelp = nil
	--self.BtnLogout = nil
	--self.BtnNotice = nil
	--self.BtnQQ = nil
	--self.BtnQQ2 = nil
	--self.BtnRepair = nil
	--self.BtnResearch = nil
	--self.BtnScan = nil
	--self.BtnSever = nil
	--self.BtnTAIAuthLogout = nil
	--self.BtnVolume = nil
	--self.BtnWeChat2 = nil
	--self.BtnWechat = nil
	--self.CoverImage = nil
	--self.FHorizontalAgree = nil
	--self.FHorizontalBoxServer = nil
	--self.FVerticalBox = nil
	--self.HorizontalLogin = nil
	--self.IconQQ2 = nil
	--self.IconWeChat = nil
	--self.ImgCheck = nil
	--self.ImgCheckBg = nil
	--self.ImgCheckFx = nil
	--self.ImgQQ = nil
	--self.ImgResearch = nil
	--self.ImgVolume = nil
	--self.ImgVolumeClose = nil
	--self.ImgWechat = nil
	--self.InputBox = nil
	--self.LoginLogoPage = nil
	--self.LoginMovieImage = nil
	--self.LoginNewProBar = nil
	--self.LoginNewSeverState = nil
	--self.PanelCheck = nil
	--self.PanelFriends = nil
	--self.PanelFx = nil
	--self.PanelInput = nil
	--self.PanelLogin = nil
	--self.PanelLogout = nil
	--self.PanelMain = nil
	--self.PanelProBar = nil
	--self.PanelScan = nil
	--self.PanelScanLogin = nil
	--self.PanelSever = nil
	--self.PanelText = nil
	--self.PanelTextNotice = nil
	--self.RichText = nil
	--self.TAIAuthPanel = nil
	--self.TableViewFriends = nil
	--self.TextCopyright1 = nil
	--self.TextCopyright2 = nil
	--self.TextFriends = nil
	--self.TextHealthy = nil
	--self.TextLogout = nil
	--self.TextNotice1 = nil
	--self.TextNotice2 = nil
	--self.TextNum = nil
	--self.TextNum1 = nil
	--self.TextNum2 = nil
	--self.TextNum3 = nil
	--self.TextPrepare = nil
	--self.TextQQ = nil
	--self.TextQQ2 = nil
	--self.TextResearch = nil
	--self.TextScan = nil
	--self.TextSever = nil
	--self.TextTAIAuthLogout = nil
	--self.TextTAIAuthUser = nil
	--self.TextWeChat2 = nil
	--self.TextWechat = nil
	--self.AnimFHorizontalIn = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewMainBase:OnRegisterSubView()

end

function LoginNewMainBase:OnInit()
	-- 蓝图UKey新规则
	self.TextResearch:SetText(LSTR(LoginStrID.ResearchLogin))
	self.InputBox:SetHintText(LSTR(LoginStrID.InputHint))
	self.TextLogout:SetText(LSTR(LoginStrID.Logout))
	if self.TextTAIAuthLogout then
		self.TextTAIAuthLogout:SetText(LSTR(LoginStrID.Logout))
	end

	self.IsShowLoginMain = true
	self.HasAutoShowNotice = false

	DataReportUtil.ReportLoginFlowData(EDataReportLoginPhase.EnterLogin)
	_G.UE.UGPMMgr.Get():PostLoginStepEvent(EDataReportLoginPhase.EnterLogin, 0, 0, "success", "", false, false)

	-- 拉取角色最后登录的信息
	USaveMgr = _G.UE.USaveMgr
	local OpenID = USaveMgr.GetString(SaveKey.LastLoginOpenID, "", false)
	if string.isnilorempty(OpenID) and LoginMgr.OpenID then
		-- 如果SaveMgr出错取不到数据，看看LoginMgr.OpenID是否有数据，有则使用
		OpenID = LoginMgr.OpenID
	end
	local WorldID = USaveMgr.GetInt(SaveKey.LastLoginWorldID, LoginNewDefine:GetDefaultWorldID(), false)
	if CommonDefine.IsTestVersion then
		WorldID = DEFAULT_TEST_WORLD_ID
	end
	self.WorldID = WorldID
	LoginMgr.WorldID = WorldID

	-- 研发登录
	if not UE.UCommonUtil.IsShipping() then
		self.InputBox:SetCallback(self, self.OnTextIDInputChanged)
	end

	--LoginNewVM.OpenID = OpenID
	--LoginNewVM.DevLogin = false
	--LoginNewVM.NoLogin = true
	--LoginNewVM.ShowStartBtn = false
	--LoginNewVM.ShowFriendList = false
	--LoginNewVM.ShowResearchBtn = not UE.UCommonUtil.IsShipping()
	--if not LoginNewVM.NeedShowUpdateAgreementView then
	--	LoginNewVM.AgreeProtocol = OpenID ~= ""
	--end

	LoginNewVM:SetPropertyValue("OpenID", OpenID)
	FLOG_INFO("[LoginNewMainBase:OnInit] OpenID:%s, WorldID:%d", OpenID, WorldID)

	self.IsMute = USaveMgr.GetInt(SaveKey.IsCGMute, 0, false) == 1
	self.BtnVolume:SetChecked(self.IsMute);
	AudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Music, self.IsMute and 0 or 1)

	--if not LoginNewVM.HasShowAnimIn then
	--	FLOG_INFO("[LoginNewMainBase:OnInit] LoginLogoPage.AnimInManual")
	--	LoginNewVM.HasShowAnimIn = true
	--	--self.LoginLogoPage:ShowLoginAnim()
	--	self.LoginLogoPage:PlayAnimation(self.LoginLogoPage.AnimInManual, 0)
	--
	--	LoginNewVM.IsCanRestoreLoginAnim = false
	--	self:RegisterTimer(function()
	--		LoginNewVM.IsCanRestoreLoginAnim = true
	--		FLOG_INFO("[LoginNewMainBase:OnInit] StopLoginAnim")
	--	end, 1)
	--end

	--self.CoverImage:SetVisibility(ESlateVisibility.Collapsed)
	--self.BtnRepair:SetVisibility(ESlateVisibility.Collapsed)

	if LoginNewVM.NoLogin and not LoginMgr.IsWakeUpFromLaunch then
		FLOG_INFO("[LoginNewMainBase:OnInit] AutoLogin")
		_G.UE.UAccountMgr.Get():AutoLogin()
	end

	if LoginMgr.OpenID then
		FLOG_INFO("[LoginNewMainBase:OnInit] RequireMaple")
		_G.UE.UMapleMgr.Get():RequireMaple()
	end

	LoginMgr.LoginFailTime = USaveMgr.GetInt(SaveKey.LoginFailTime, 0, false)
	LoginMgr.LoginFailCount = USaveMgr.GetInt(SaveKey.LoginFailCount, 0, false)
	FLOG_INFO("[LoginNewMainBase:OnInit] LoginFailCount:%d, LoginFailTime:%d", LoginMgr.LoginFailCount, LoginMgr.LoginFailTime)
end

function LoginNewMainBase:OnDestroy()
	FLOG_INFO("[LoginNewMainBase:OnDestroy]")
end

function LoginNewMainBase:OnShow()
	FLOG_INFO("[LoginNewMainBase:OnShow]")
	self:HideOtherGameTips()

	LoginMgr.IsStartGame = false
	LoginMgr.bRoleLogin = false
	self.IsShowLoginMain = true

	self.PanelMain:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
	if not LoginNewVM.DevLogin then
		self.PanelInput:SetVisibility(ESlateVisibility.Collapsed)
	end

	-- 转场动画恢复
	--if self.IsCanRestoreLoginAnim then
	--	FLOG_INFO("[LoginNewMainBase:OnShow] LoginLogoPage:StopLoginAnim")
	--	--self.LoginLogoPage:StopLoginAnim()
	--end

	--Windows上获取在线配置列表
	--if CommonUtil.GetPlatformName() == "Windows" then
	_G.UE.UGameNetworkMgr.Get():GetOnlineConfig()
	--_G.UE.UGameNetworkMgr.Get():GetOnlineConfig()
	--end

	-- 版本号
	self.TextNum3:SetText(string.format("%s%s", LSTR(LoginStrID.AppVer), _G.UE.UVersionMgr.GetGameVersion()))
	self.TextNum:SetText(string.format("%s%s", LSTR(LoginStrID.ResourceVer), _G.UE.UVersionMgr.GetResourceVersion()))
	-- 资源版本号 _G.UE.UFlibAppHelper.GetSourceVersion()

	if FTAIAuthUtil.IsEnable() then
		self.TextTAIAuthUser:SetText(LSTR(LoginStrID.TaiHuVer) .. FTAIAuthUtil.GetUserName())
	end

	if LoginMgr.IsNeedLogout then
		_G.NetworkImplMgr:StopAllWaiting()

		LoginMgr.IsNeedLogout = false
		LoginMgr.bShowHopeView = false
		self:OnLogout()
	end
	-- 登录界面停止心跳和断开网络连接
	_G.NetworkStateMgr:Disconnect()

	if LoginNewVM.NeedShowUpdateAgreementView then
		UIViewMgr:ShowView(UIViewID.UserAgreementUpdate)
	end

	_G.LoginMapMgr:OnLoginMainShow()

	LoginMgr:OnShowLoginScene()
	_G.LoginUIMgr.bFirstCreate = true
	--self.LoginLogoPage:ShowLoginAnim()
	--self:PlayAnimIn()
	--self.LoginLogoPage:ShowLoopAnim()

	if not PreDownloadMgr.bHasCheckPreDownload then
		PreDownloadMgr.bHasCheckPreDownload = true
		FLOG_INFO("[LoginNewMainBase:OnInit] Check PreDownload... ")
		PreDownloadMgr:CheckPreDownload()
	end

	local bNoShowNoticeAgain = USaveMgr.GetInt(SaveKey.NoShowNoticeAgain, 0, false) == 1
	--FLOG_INFO("[LoginNewMainBase:OnShow] bNoShowNoticeAgain:%s", tostring(bNoShowNoticeAgain))
	if not bNoShowNoticeAgain and not self.HasAutoShowNotice then
		self:RegisterTimer(function()
			self:OnClickBtnNoticeInternal(false)
		end, 2)
	end

	if not LoginNewVM.HasShowAnimIn then
		FLOG_INFO("[LoginNewMainBase:OnShow] AnimInManual")
		LoginNewVM.HasShowAnimIn = true
		self:PlayAnimation(self.AnimInManual, 0)
		self.LoginLogoPage:PlayAnimation(self.LoginLogoPage.AnimInManual, 0)
	else if LoginNewVM.HasLogin then
		FLOG_INFO("[LoginNewMainBase:OnShow] HasLogin")
		local AnimFHorizontalInTime = self.AnimFHorizontalIn:GetEndTime()
		self:PlayAnimation(self.AnimFHorizontalIn, AnimFHorizontalInTime)
		local AnimInManualTime = self.AnimInManual:GetEndTime()
		self:PlayAnimation(self.AnimInManual, AnimInManualTime)

		local AnimInManualTime1 = self.LoginLogoPage.AnimInManual:GetEndTime()
		self.LoginLogoPage:PlayAnimation(self.LoginLogoPage.AnimInManual, AnimInManualTime1)
		local AnimPanelGoTime = self.LoginLogoPage.AnimPanelGo:GetEndTime()
		self.LoginLogoPage:PlayAnimation(self.LoginLogoPage.AnimPanelGo, AnimPanelGoTime)
	end
	end

	--if _G.CgMgr.IsCanPlayMovie then
	--	FLOG_INFO("[LoginNewMainBase:OnShow] IsCanPlayMovie")
	--	_G.CgMgr:SetCGPath(_G.CgMgr:GetVideoPath())
	--	UIViewMgr:ShowView(UIViewID.LoginCG)
	--
	--	self:RegisterTimer(function()
	--		UIViewMgr:HideView(UIViewID.LoginCG)
	--		_G.CgMgr.IsCanPlayMovie = false
	--	end, 56)
	--end

	self:PlayMedia()
	self:CheckAccountCancellation()

	if nil ~= OperationUtil.IsEnableCustomService and not OperationUtil.IsEnableCustomService() then
		UIUtil.SetIsVisible(self.BtnHelp, false)
	end

	IOS26ResDownloadMgr:CheckIOS26Res()
end

function LoginNewMainBase:OnHide()
	FLOG_INFO("[LoginNewMainBase:OnHide]")
	self:StopMedia()
	self.PanelMain:SetVisibility(ESlateVisibility.Hidden)
end

function LoginNewMainBase:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSever, self.OnClickBtnServer)
	UIUtil.AddOnClickedEvent(self, self.BtnResearch, self.OnClickBtnResearch)
	UIUtil.AddOnClickedEvent(self, self.BtnLogout, self.OnClickBtnLogout)
	UIUtil.AddOnClickedEvent(self, self.BtnHelp, self.OnClickBtnHelp)

	if FTAIAuthUtil.IsEnable() then
		UIUtil.AddOnClickedEvent(self, self.BtnTAIAuthLogout, self.OnClickBtnTAIAuthLogout)
	end

	UIUtil.AddOnClickedEvent(self, self.BtnVolume, self.OnClickBtnVolume)
	UIUtil.AddOnClickedEvent(self, self.BtnNotice, self.OnClickBtnNotice)
	UIUtil.AddOnClickedEvent(self, self.BtnRepair, self.OnClickBtnRepair)
	UIUtil.AddOnClickedEvent(self, self.BtnCG, self.OnClickBtnCG)
	FLOG_INFO("[LoginNewMainBase:OnRegisterUIEvent]")
end

function LoginNewMainBase:OnRegisterGameEvent()
	FLOG_INFO("[LoginNewMainBase:OnRegisterGameEvent]")
	--self:RegisterGameEvent(EventID.LoginSelectServer, self.OnGameEventLoginSelectServer)
	--self:RegisterGameEvent(EventID.MSDKLoginRetNotify, self.OnGameEventMSDKLogin)
	--self:RegisterGameEvent(EventID.MapleAllNodeInfoNotify, self.OnGameEventNodeInfoNotify)
	self:RegisterGameEvent(EventID.LoginShowMainPanel, self.OnLoginShowMainPanel)
	self:RegisterGameEvent(EventID.ShowPreDownload, self.OnShowPreDownload)
	self:RegisterGameEvent(EventID.HidePreDownload, self.OnHidePreDownload)
	self:RegisterGameEvent(EventID.PlayLoginBGM, self.OnPlayLoginBGM)
	self:RegisterGameEvent(EventID.LoginToRoleSuccess, self.OnPlayLoginToRoleAnim)
	self:RegisterGameEvent(EventID.LoginConnectEvent, self.OnLoginConnectEvent)
	self:RegisterGameEvent(EventID.ErrorCode, self.OnGameEventErrorCode)
	self:RegisterGameEvent(EventID.LoginRefuseAgreement, self.OnLoginRefuseAgreement)
	self:RegisterGameEvent(EventID.LoginQueueFinishEvent, self.OnLoginQueueFinishEvent)
	self:RegisterGameEvent(EventID.AccountCancellationEvent, self.OnAccountCancellationEvent)
	self:RegisterGameEvent(EventID.DoLogoutEvent, self.OnDoLogoutEventEvent)
	self:RegisterGameEvent(EventID.MSDKWebViewOptNotify, self.OnWebViewOptNotify)
end

function LoginNewMainBase:OnRegisterBinder()

end

function LoginNewMainBase:OnClickBtnServer()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnClickBtnServer] IsStartGame ")
		return
	end

	if not LoginMgr.AllMapleNodeInfo then
		FLOG_WARNING("[LoginNewMainBase:OnClickBtnServer] AllMapleNodeInfo is nil")
		return
	end

	-- 日方监修测试版
	if CommonDefine.IsTestVersion then return end

	FLOG_INFO("[LoginNewMainBase:OnClickBtnServer] ")
	_G.UE.UMapleMgr.Get():RequireMaple()

	self.IsShowLoginMain = false
	-- 播放视频崩溃上报比较多，减少调用次数，不重复播放:打开服务器列表
	--self:StopMedia()
	UIViewMgr:ShowView(UIViewID.LoginServerList)
end

function LoginNewMainBase:OnClickBtnResearch()
	FLOG_INFO("LoginNewMainBase:OnClickBtnResearch")
	self:OnResearchLogin()
end

function LoginNewMainBase:OnClickBtnLogout()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnClickBtnLogout] IsStartGame ")
		return
	end
	self:OnLogout()
end

function LoginNewMainBase:OnClickBtnTAIAuthLogout()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnClickBtnTAIAuthLogout] IsStartGame ")
		return
	end

	if FTAIAuthUtil.IsEnable() then
		FTAIAuthUtil.Logout()
	end
end

--[[
---@param LoginRet FAccountLoginRetData
function LoginNewMainBase:OnGameEventMSDKLogin(LoginRet)
	self:OnLogin(LoginRet)
end
]]

function LoginNewMainBase:OnNodeInfoNotify()
	FLOG_INFO("[LoginNewMainBase:OnNodeInfoNotify]  ")
	--LoginVM:SetPropertyValue("WorldID", self.WorldID)
	if LoginNewVM.NoLogin then
		FLOG_INFO("[LoginNewMainBase:OnNodeInfoNotify] NoLogin ")
		return
	end

	local NodeInfo = LoginMgr:GetMapleNodeInfo(self.WorldID)
	if NodeInfo then
		LoginNewVM.WorldState = NodeInfo.State
		LoginNewVM.NodeTag = NodeInfo.Tag
		LoginMgr.OverseasSvrAreaId = NodeInfo.CustomValue2
	else
		self.WorldID = LoginMgr.RecommendWorldId;
		NodeInfo = LoginMgr:GetMapleNodeInfo(self.WorldID)
		if NodeInfo then
			LoginNewVM.WorldState = NodeInfo.State
			LoginNewVM.NodeTag = NodeInfo.Tag
		else
			LoginNewVM.WorldState = LoginNewDefine.ServerStateEnum.Full
			LoginNewVM.NodeTag = LoginNewDefine.ServerTagEnum.None
		end
		LoginMgr.OverseasSvrAreaId = LoginNewDefine.OverseasSvrAreaId.None
	end

	LoginNewVM.ShowStartBtn = true
	LoginNewVM.WorldID = self.WorldID
end

---@param LoginRet FAccountLoginRetData
function LoginNewMainBase:OnLogin(LoginRet)
	-- 播放视频崩溃上报比较多，减少调用次数，不重复播放:自动登录
	--self:PlayMedia()

	local RetCode = LoginRet.RetCode
	local MethodNameID = LoginRet[MSDKDefine.ClassMembers.LoginRetData.MethodNameID]
	FLOG_INFO("[Login][LoginNewMainBase:OnGameEventMSDKLogin] Login Ret. RetCode:%d, MethodNameID:%d", RetCode, MethodNameID)
	if MethodNameID == MSDKDefine.MethodName.AutoLogin then
		if RetCode == MSDKDefine.MSDKError.LOGIN_NO_CACHED_DATA or RetCode == MSDKDefine.MSDKError.LOGIN_CACHED_DATA_EXPIRED then
			-- 无缓存 静默退出
			return
		elseif LoginRet.RetCode ~= MSDKDefine.MSDKError.SUCCESS then
			return
		else
			LoginNewVM:SetAgreeProtocol(true)
		end
	else
		-- 手动登录授权
		self:PlayMedia()
		if RetCode ~= MSDKDefine.MSDKError.SUCCESS then
			FLOG_ERROR("[LoginNewMainBase:OnGameEventMSDKLogin] Login failed，Msg:%s RetCode:%d", LoginRet.RetMsg, RetCode)
			if RetCode == MSDKDefine.MSDKError.CANCEL then
				-- 用户取消登录
				MsgTipsUtil.ShowTips(LSTR(LoginStrID.LoginCancel))
				LoginMgr:ResetWakeUpState()
				return
			end

			if RetCode == MSDKDefine.MSDKError.NEED_REALNAME or RetCode == MSDKDefine.MSDKError.REALNAME_FAIL then
				return
			end

			if RetCode == MSDKDefine.MSDKError.MSDK_SERVER_ERROR then
				if LoginRet.ThirdCode == MSDKDefine.ThirdCode.INVALID_VERIFY_CODE then
					-- 470139 验证码错误，登录失败
					MsgTipsUtil.ShowTips(LSTR(470139))
					return
				end
			end

			DataReportUtil.ReportLoginFlowData(EDataReportLoginPhase.AuthFailure)
			_G.UE.UGPMMgr.Get():PostLoginStepEvent(EDataReportLoginPhase.AuthFailure, 1, 1, "Failed", "", true, false)
			local function Callback()
				self:OpenFeedbackPage()
			end
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LoginStrID.TipsTitle), string.format(LSTR(LoginStrID.LoginFailed), RetCode), nil, Callback, LSTR(LoginStrID.Feedback), LSTR(LoginStrID.ConfirmBtnStr))
			return
		end
	end

	LoginNewVM.HasLogin = true
	--self.LoginLogoPage:ShowStartAnim()
	--self:ShowStartAnim()
	self:PlayAnimation(self.AnimFHorizontalIn)
	self.LoginLogoPage:PlayAnimation(self.LoginLogoPage.AnimPanelGo)

	-- TODO 海外隐私合规弹窗（待接入中控）
	--if not CommonUtil.IsInternationalChina() then
	--	_G.UIViewMgr:ShowView(UIViewID.LoginAgreementsWin)
	--end

	LoginMgr.OpenID = LoginRet.OpenID
	LoginMgr.Token = LoginRet.Token
	LoginMgr.ChannelID = LoginRet.ChannelID
	LoginMgr:ReqMyAndFriendSevers()

	FLOG_INFO("[Login] LoginNewMainBase:OnGameEventMSDKLogin LoginRet.OpenID:%s, LoginNewVM.OpenID:%s", LoginRet.OpenID, LoginNewVM.OpenID)
	--if LoginNewVM.OpenID ~= LoginRet.OpenID then
	--	LoginNewVM.AgreeProtocol = false
	--end
	LoginNewVM.OpenID = LoginRet.OpenID
	self.InputBox:SetText(LoginRet.OpenID)

	local CopyParamNames = {
		[1] = MSDKDefine.ClassMembers.LoginRetData.OpenID,
		[2] = MSDKDefine.ClassMembers.LoginRetData.TokenExpire,
		[3] = MSDKDefine.ClassMembers.LoginRetData.ChannelID,
		[4] = MSDKDefine.ClassMembers.LoginRetData.Token,
	}
	LoginMgr.MSDKLoginParam = {}
	for k, v in ipairs(CopyParamNames) do
		LoginMgr.MSDKLoginParam[v] = LoginRet[v]
	end

	LoginNewVM.DevLogin = false
	LoginNewVM.NoLogin = false
	LoginNewVM.ShowResearchBtn = false

	--self.InputBox:SetIsReadOnly(true)
	self.PanelInput:SetVisibility(ESlateVisibility.Collapsed)

	DataReportUtil.SendPublicIPAddressInfoRequest()
	DataReportUtil.ReportLoginFlowData(EDataReportLoginPhase.AuthSuccess)
	DataReportUtil.ReportPlayerLoginForUA()
	OperationUtil.InitTDM(LoginMgr.ChannelID, LoginMgr.OpenID)
	OperationUtil.ReportASAAdInfo()
	_G.UE.UGPMMgr.Get():PostLoginStepEvent(EDataReportLoginPhase.AuthSuccess, 0, 0, "success", "", true, false)
	_G.UE.UHttpDNSMgr.Get():SetOpenID(LoginRet.OpenID);
end

function LoginNewMainBase:OnLoginShowMainPanel()
	FLOG_INFO("[Login] LoginNewMainBase:OnLoginShowMainPanel ")
	self.IsShowLoginMain = true
	self.PanelMain:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
	-- 播放视频崩溃上报比较多，减少调用次数，不重复播放（关闭服务器列表）
	--self:PlayMedia()
end

function LoginNewMainBase:OnShowPreDownload()
	FLOG_INFO("[Login] LoginNewMainBase:OnShowPreDownload ")
	LoginNewVM.ShowPreDownloadBtn = true
end

function LoginNewMainBase:OnHidePreDownload()
	FLOG_INFO("[Login] LoginNewMainBase:OnHidePreDownload ")
	LoginNewVM.ShowPreDownloadBtn = false
end

function LoginNewMainBase:OnPlayLoginBGM()
	FLOG_INFO("[Login] LoginNewMainBase:OnPlayLoginBGM ")
	-- 从CG返回
	self:PlayMedia()
end

function LoginNewMainBase:OnPlayLoginToRoleAnim()
	FLOG_INFO("[LoginNewMainBase:OnPlayLoginToRoleAnim] ")
	self.IsShowLoginMain = false
	self:HideOtherLoginView()
	-- 播放转场动画
	LoginMgr:ShowLoginToCreateRoleAnim()

	--self.LoginLogoPage:ShowLoginToRoleAnim()
	--self:ShowLoginToRoleAnim()

	local EndTime = self.AnimFHorizontalIn:GetEndTime()
	self:PlayAnimation(self.AnimFHorizontalIn, EndTime)
	self.LoginLogoPage:PlayAnimation(self.LoginLogoPage.AnimClickGo)
end

function LoginNewMainBase:OnGameEventErrorCode(ErrorCode)
	FLOG_INFO("[LoginNewMainBase:OnGameEventErrorCode] ErrorCode:%d", ErrorCode)
	local isCriticalError = (ErrorCode > 120000 and ErrorCode <= 121000) or
			(ErrorCode == 1008) or
			(ErrorCode == 143039) or
			(ErrorCode > 100000 and ErrorCode <= 100010)

	if isCriticalError then
		LoginMgr.IsStartGame = false
		self.IsShowLoginMain = true

		if self.StartGameTimerID then
			_G.TimerMgr:CancelTimer(self.StartGameTimerID)
			self.StartGameTimerID = nil
		end

		-- 登录界面进入游戏失败，断开连接并停止心跳
		_G.NetworkStateMgr:Disconnect()

		LoginMgr.LoginFailCount = LoginMgr.LoginFailCount + 1
		if LoginMgr.LoginFailCount >= 3 then
			LoginMgr.LoginFailTime = _G.TimeUtil.GetServerTime()
		else
			LoginMgr.LoginFailTime = 0
		end
		USaveMgr.SetInt(SaveKey.LoginFailTime, LoginMgr.LoginFailTime, false)
		USaveMgr.SetInt(SaveKey.LoginFailCount, LoginMgr.LoginFailCount, false)
		FLOG_WARNING("[LoginNewMainBase:OnGameEventErrorCode] LoginFailCount:%d, LoginFailTime:%d", LoginMgr.LoginFailCount, LoginMgr.LoginFailTime)
	end
end

function LoginNewMainBase:OnLoginRefuseAgreement()
	FLOG_INFO("[LoginNewMainBase:OnLoginRefuseAgreement] ")
	self:OnLogout()
end

function LoginNewMainBase:OnLoginConnectEvent(WorldRegPercent)
	FLOG_INFO("[LoginNewMainBase:OnLoginConnectEvent] WorldRegPercent:%d", WorldRegPercent)
	LoginMgr.IsStartGame = false
	QueueMgr:StartQueue(WorldRegPercent)
	UIViewMgr:ShowView(UIViewID.LoginQueueWin)
end

function LoginNewMainBase:OnLoginQueueFinishEvent()
	FLOG_INFO("[LoginNewMainBase:OnLoginQueueFinishEvent]")
	LoginMgr.IsLoginQueueFinish = true
	self:OnStartGame()
end

function LoginNewMainBase:OnAccountCancellationEvent()
	FLOG_INFO("[LoginNewMainBase:OnAccountCancellationEvent]")
	--local AllAccountInfos = LoginMgr.AllAccountInfos
	--if AllAccountInfos == nil then
	--	return
	--end
	--
	--local ret = true
	--for _, InfoItem in ipairs(AllAccountInfos) do
	--	--FLOG_INFO("[LoginMgr:OnAccountCancellationResponse] AccountInfos: --------------------->")
	--	--FLOG_INFO("RoleName:%s, \nRoleID:%s, \nGroupChat:%s, \nFriend:%s, \nNewChannel:%s, \nTeam:%s", InfoItem.RoleName, InfoItem.RoleID,
	--	--		InfoItem.GroupChat and "true" or "false", InfoItem.Friend and "true" or "false", InfoItem.NewChannel and "true" or "false", InfoItem.Team and "true" or "false")
	--	if InfoItem.GroupChat == true or InfoItem.Friend == true or InfoItem.NewChannel == true or InfoItem.Team == true then
	--		ret = false
	--		break
	--	end
	--end

	if UIViewMgr:IsViewVisible(UIViewID.CommonMsgBox) then
		UIViewMgr:HideView(UIViewID.CommonMsgBox)
	end
	if UIViewMgr:IsViewVisible(UIViewID.AccountCancellationWait) then
		UIViewMgr:HideView(UIViewID.AccountCancellationWait)
	end

	if LoginMgr.AccountCancellationCheckResult == true then
		-- 检查通过，显示二次确认弹窗
		local function Callback()
			_G.AccountUtil.DeleteAccount()
		end

		-- 470133 账号注销
		-- 470157 请确认是否对账号下所有角色进行注销？点击确认后将进入游戏账号注销页面。
		-- 10002 确认
		-- 10003 取消
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(470133), LSTR(470157), Callback, nil, LSTR(10003), LSTR(10002))
	else
		-- 检查不通过，显示检查结果列表
		UIViewMgr:ShowView(UIViewID.AccountCancellationList)
	end
end

function LoginNewMainBase:OnDoLogoutEventEvent()
	FLOG_INFO("[LoginNewMainBase:OnDoLogoutEventEvent]")
	self:OnLogout()
end

---@param WebViewRet FAccountWebViewRet
function LoginNewMainBase:OnWebViewOptNotify(WebViewRet)
	local MethodNameID = WebViewRet.MethodNameID
	if MethodNameID then
		FLOG_INFO("[LoginMgr:OnGameEventWebViewOptNotify] MethodNameID:%d", MethodNameID)
		if MethodNameID == MSDKDefine.MethodName.kMethodNameCloseWebViewURL then
			self:PlayMedia()
		end
	end
end

function LoginNewMainBase:OnStartGame()
	--FLOG_INFO("[Login] LoginNewMainBase:OnStartGame")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnStartGame] IsStartGame ")
		return
	end
	
	if LoginNewVM.DevLogin then
		local OpenId = UIUtil:Trim(self.InputBox:GetText())
		LoginNewVM.OpenID = OpenId
	end
	local OpenID = LoginNewVM.OpenID
	local WorldID = LoginNewVM.WorldID

	if string.isnilorempty(OpenID) then
		FLOG_INFO("[LoginNewMainBase:OnStartGame] Empty OpenID ")
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.InputOpenID))
		return
	end

	LoginMgr.OpenID = OpenID
	LoginMgr.WorldID = WorldID
	LoginMgr.WorldState = LoginNewVM.WorldState
	if LoginNewVM.WorldState == LoginNewDefine.ServerStateEnum.Maintenance and LoginNewVM.NodeTag == LoginNewDefine.ServerTagEnum.Limit then
		-- 服务器正在维护中，客户端不拦截，交给服务器处理
		-- 服务器停服，客户端拦截
		FLOG_WARNING("[LoginNewMainBase:OnStartGame] ServerStateEnum.Maintenance ")
		_G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(LoginStrID.TipsTitle), LSTR(LoginStrID.SvrMaintenance), nil, LSTR(LoginStrID.ConfirmBtnStr))
		return
	end

	if self:CheckLoginRetryLimit() then
		return
	end

	self.IsShowLoginMain = false

	--[sammrli] 登录使用多地址随机策略
	local URL = LoginMgr:GetServerUrl()
	local Name = LoginMgr:GetMapleNodeName(WorldID)

	-- _G.LoginUIMgr.IsAlreadySwitchCamera = false
	DataReportUtil.ReportLoginFlowData(EDataReportLoginPhase.LeaveLogin)
	_G.UE.UGPMMgr.Get():PostLoginStepEvent(EDataReportLoginPhase.LeaveLogin, 0, 0, "success", "", false, false)

	LoginMgr.IsStartGame = true
	self.StartGameTimerID = self:RegisterTimer(function()
		LoginMgr.IsStartGame = false
		self.IsShowLoginMain = true
		FLOG_INFO("[LoginNewMainBase:OnStartGame] StopLoginAnim && Update IsStartGame = false")
	end, 5)

	if LoginMgr.MSDKLoginParam == nil then
		FLOG_INFO("[Login] LoginNewMainBase:OnStartGame - Dev Connect URL=%s OpenID=%s WorldID=%d ServerName=%s", URL, OpenID, WorldID, Name)
		GameNetworkMgr:Connect(URL, LoginNewDefine.LoginConnectAuthType.kAuthNone, "10000", 0, OpenID, "", 0)
	else
		local AppId = _G.UE.UGCloudMgr.Get():GetMSDKGameId()
		FLOG_INFO("[Login] LoginNewMainBase:OnStartGame - Connect URL=%s OpenID=%s WorldID=%d ServerName=%s", URL, LoginMgr.MSDKLoginParam[MSDKDefine.ClassMembers.LoginRetData.OpenID], WorldID, Name)
		GameNetworkMgr:Connect(URL, LoginNewDefine.LoginConnectAuthType.kAuthMSDKv5, AppId,
				LoginMgr.MSDKLoginParam[MSDKDefine.ClassMembers.LoginRetData.ChannelID],
				LoginMgr.MSDKLoginParam[MSDKDefine.ClassMembers.LoginRetData.OpenID],
				LoginMgr.MSDKLoginParam[MSDKDefine.ClassMembers.LoginRetData.Token],
				LoginMgr.MSDKLoginParam[MSDKDefine.ClassMembers.LoginRetData.TokenExpire])
	end

	USaveMgr.SetString(SaveKey.LastLoginOpenID, OpenID, false)
	USaveMgr.SetInt(SaveKey.LastLoginWorldID, WorldID, false)
end

function LoginNewMainBase:OnLogout()
	FLOG_INFO("LoginNewMainBase:OnLogout")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnLogout] IsStartGame ")
		return
	end

	-- 研发登录下退出登录不触发MSDK登出
	if not LoginNewVM.DevLogin then
		_G.UE.UAccountMgr.Get():Logout()
	end

	--LoginNewVM.OpenID = ""
	LoginNewVM.DevLogin = false
	LoginNewVM.NoLogin = true
	LoginNewVM.ShowStartBtn = false
	LoginNewVM.ShowResearchBtn = not UE.UCommonUtil.IsShipping()
	LoginNewVM.ShowFriendList = false
	LoginNewVM:SetAgreeProtocol(false)

	LoginMgr.MSDKLoginParam = nil
	LoginMgr.FriendServers = nil
	LoginMgr.AllMapleNodeInfo = nil

	self.PanelInput:SetVisibility(ESlateVisibility.Collapsed)
end

--- 研发登录
function LoginNewMainBase:OnResearchLogin()
	local OpenId = UIUtil:Trim(LoginNewVM.OpenID)
	self.InputBox:SetText(OpenId)
	FLOG_INFO("LoginNewMainBase:OnResearchLogin OpenID：[%s]", OpenId)

	LoginNewVM.DevLogin = true
	LoginNewVM.NoLogin = false
	LoginNewVM.ShowResearchBtn = false
	LoginMgr.MSDKLoginParam = nil

	self.PanelInput:SetVisibility(ESlateVisibility.Visible)

	LoginMgr.OpenID = OpenId
	LoginMgr.Token = "root"
	LoginMgr.ChannelID = "10"

	local LoginRet = _G.UE.FAccountLoginRetData()
	LoginRet.OpenID = OpenId
	LoginRet.ResultCode = 0

	--EventMgr:SendEvent(EventID.MSDKLoginRetNotify, LoginRet)
	--_G.UE.UMapleMgr.Get():SetMapleTreeId(1)
	_G.UE.UMapleMgr.Get():OnLogin(LoginRet)

	if CommonUtil.IsWithEditor() then
		LoginMgr:ReqMyAndFriendSevers()
	end

	LoginNewVM.HasLogin = true
	--self.LoginLogoPage:ShowStartAnim()
	--self:ShowStartAnim()
	self:PlayAnimation(self.AnimFHorizontalIn)
	self.LoginLogoPage:PlayAnimation(self.LoginLogoPage.AnimPanelGo)
end

function LoginNewMainBase:OnClickBtnVolume()
	-- 切换静音/未静音状态
	self.IsMute = not self.IsMute
	self.BtnVolume:SetChecked(self.IsMute, false)
	FLOG_INFO("LoginNewMainBase:OnClickBtnVolume %s", tostring(self.IsMute))
	USaveMgr.SetInt(SaveKey.IsCGMute, self.IsMute and 1 or 0, false)

	if not self.IsMute then
		--_G.LoginMapMgr:RestoreBGM()
		_G.UE.UAudioMgr.Get():PlayBGM(238, UE.EBGMChannel.BaseZone)
	end
	AudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Music, self.IsMute and 0 or 1)

	--local MsgBody = {
	--	Cmd = 1,
	--	Data = "UpdateClient",
	--	UpdateClient = {
	--		ClientVersion = "0.0.8569.1",
	--		ForceUpdate = false,
	--	}
	--}
	--LoginMgr:OnNetMsgUpdateClientRes(MsgBody)
end

function LoginNewMainBase:OnClickBtnRepair()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnClickBtnRepair] IsStartGame ")
		return
	end

	-- 显示修复提示弹窗
	local function ResetCallback()
		-- 游戏重置
		LoginMgr:RepairHotUpdate(true)
	end
	local function RepairCallback()
		-- 游戏修复
		LoginMgr:RepairHotUpdate(false)
	end
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LoginStrID.TipsTitle), LSTR(LoginStrID.RepairContent), RepairCallback, ResetCallback, LSTR(LoginStrID.ResetBtnStr), LSTR(LoginStrID.RepairBtnStr))
end

---显示CG
function LoginNewMainBase:OnClickBtnCG()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnClickBtnCG] IsStartGame ")
		return
	end

	-- 从CG界面退出时，调用StopMedia，手动提前关闭视频并设置 IsMoviePlaying 标志
	self:StopMedia()

	--if _G.CgMgr:PlayCGVideo(_G.CgMgr:GetCGPath()) then
	--	self.IsShowLoginMain = false
	--	UIViewMgr:ShowView(UIViewID.LoginCG)
	--end
	self.IsShowLoginMain = false

	_G.CgMgr:SetCGPath(_G.CgMgr:GetCGPath())
	--_G.CgMgr:SetCGPath(_G.CgMgr:GetVideoPath())
	UIViewMgr:ShowView(UIViewID.LoginCG)
end

function LoginNewMainBase:OnClickBtnNotice()
	self:OnClickBtnNoticeInternal(true)
end

function LoginNewMainBase:OnClickBtnNoticeInternal(IsClick)
	FLOG_INFO("[LoginNewMainBase:OnClickBtnNoticeInternal]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnClickBtnNoticeInternal] IsStartGame ")
		return
	end

	FLOG_INFO("[LoginNewMainBase:OnClickBtnNoticeInternal] LoginMainNew is not showing:%s", self.IsShowLoginMain)
	if not self.IsShowLoginMain then
		return
	end

	local NoticeMgr = _G.UE.UNoticeMgr:Get()
	if not (NoticeMgr and NoticeMgr:HasValidNotice()) then
		if IsClick then
			MsgTipsUtil.ShowTips(LSTR(LoginStrID.NoNotice))
		end
		return
	end

	self.HasAutoShowNotice = true
	UIViewMgr:ShowView(UIViewID.LoginNotice)
end

function LoginNewMainBase:OnClickBtnHelp()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainBase:OnClickBtnHelp] IsStartGame ")
		return
	end

	-- local HelpUrl
	-- if CommonUtil.IsInternationalChina() then
	-- 	HelpUrl = LoginNewDefine.HelpUrl
	-- else
	-- 	HelpUrl = LoginNewDefine.HelpUrlOversea
	-- end
	-- _G.AccountUtil.OpenUrl(HelpUrl, 1, false, true, "", false)
	self.IsShowLoginMain = false
	self:RegisterTimer(function()
		self.IsShowLoginMain = true
	end, 2)

	self:OpenFeedbackPage()
end

function LoginNewMainBase:OnTextIDInputChanged(Text, Len)
	--FLOG_INFO("[LoginNewMainBase:OnTextIDInputChanged] OpenID:%s", Text)
	--LoginMgr.MSDKLoginParam = nil
	rawset(LoginNewVM, "OpenID", Text)
end

function LoginNewMainBase:GetHost(WorldID)
	--return ServerDirCfg:FindValue(WorldID, "Host")
	return LoginMgr:GetMapleNodeHost(WorldID)
end

function LoginNewMainBase:OpenFeedbackPage()
	--OperationUtil.OpenFeedback()
	self:StopMedia()
	OperationUtil.OpenCustomService(OperationUtil.CustomServiceSceneID.Login)
end

function LoginNewMainBase:HideOtherLoginView()
	if UIViewMgr:IsViewVisible(UIViewID.LoginNotice) then
		UIViewMgr:HideView(UIViewID.LoginNotice)
	end
	if UIViewMgr:IsViewVisible(UIViewID.LoginServerList) then
		UIViewMgr:HideView(UIViewID.LoginServerList)
	end
	if UIViewMgr:IsViewVisible(UIViewID.LoginCG) then
		UIViewMgr:HideView(UIViewID.LoginCG)
	end
end

function LoginNewMainBase:HideOtherGameTips()
	if UIViewMgr:IsViewVisible(UIViewID.ActiveSystemErrorTips) then
		FLOG_INFO("[LoginNewMainBase:HideOtherGameTips] CommonTips ")
		UIViewMgr:HideView(UIViewID.ActiveSystemErrorTips)
	end
	if UIViewMgr:IsViewVisible(UIViewID.InfoAreaTips) then
		UIViewMgr:HideView(UIViewID.InfoAreaTips)
	end
end

function LoginNewMainBase:PlayMedia()
	self:TryPlayBGM()
	self:ShowLoginMovie()
end

function LoginNewMainBase:StopMedia()
	LoginMgr.IsMoviePlaying = false
	_G.CgMgr:StopCGVideo()
	_G.LoginMapMgr:StopBGM()
end

function LoginNewMainBase:TryPlayBGM()
	FLOG_INFO("[LoginNewMainBase:TryPlayBGM] ")
	self.IsShowLoginMain = true
	self.IsMute = USaveMgr.GetInt(SaveKey.IsCGMute, 0, false) == 1
	AudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Music, self.IsMute and 0 or 1)

	if not self.IsMute then
		--_G.LoginMapMgr:RestoreBGM()
		_G.UE.UAudioMgr.Get():PlayBGM(238, UE.EBGMChannel.BaseZone)
	end
end

function LoginNewMainBase:ShowLoginMovie()
	-- 视频正在播放，则跳过，不重复播放
	if LoginMgr.IsMoviePlaying then
		FLOG_WARNING("[LoginNewMainBase:ShowLoginMovie] IsMoviePlaying...")
		return
	end
	LoginMgr.IsMoviePlaying = true

	FLOG_INFO("[LoginNewMainBase:ShowLoginMovie] ")
	self.LoginMovieImage:SetVisibility(ESlateVisibility.Collapsed)
	_G.CgMgr:SetCGPath(_G.CgMgr:GetLoginMoviePath())
	_G.CgMgr:PlayCGVideo(self.LoginMovieImage, true)
	_G.CgMgr:SetNativeVolume(0)
	_G.CgMgr:SetAutoClear(false)
	-- _G.CgMgr:SetNoFlushSinks(true)
end

function LoginNewMainBase:CheckAccountCancellation()
	if LoginMgr.IsAccountCancellation then
		FLOG_INFO("[LoginNewMainBase:CheckAccountCancellation] ")

		UIViewMgr:ShowView(UIViewID.AccountCancellationWait)
		LoginMgr:QueryAccountCancellation()
		LoginMgr.IsAccountCancellation = false
	end
end

function LoginNewMainBase:CheckLoginRetryLimit()
	if not LoginMgr.LoginFailTime or LoginMgr.LoginFailTime == 0 then
		return false
	end

	if LoginMgr.LoginFailCount < 3 then
		return false
	end

	local CurrentTime = _G.TimeUtil.GetServerTime()
	local DeltaTime = CurrentTime - LoginMgr.LoginFailTime
	local CountdownTime = 0

	if LoginMgr.LoginFailCount >= 6 then
		-- 5分钟CD
		CountdownTime = 300 - DeltaTime
	elseif LoginMgr.LoginFailCount >= 3 then
		-- 10秒CD
		CountdownTime = 10 - DeltaTime
	end
	FLOG_INFO("[LoginNewMainBase:CheckLoginRetryLimit] FailCount:%d, DeltaTime:%d, CountdownTime:%d", LoginMgr.LoginFailCount, DeltaTime, CountdownTime)

	if CountdownTime > 0 then
		MsgTipsUtil.ShowTips(string.format(LSTR(LoginStrID.LoginRetryTips), math.ceil(CountdownTime)))
		return true
	end

	return false
end

return LoginNewMainBase