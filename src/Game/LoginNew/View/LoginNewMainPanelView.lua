---
--- Author: richyczhou
--- DateTime: 2024-06-25 10:00
--- Description:
---

local AccountUtil = require("Utils/AccountUtil")
local CommonDefine = require("Define/CommonDefine")
local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local LoginNewMainBase = require("Game/LoginNew/View/LoginNewMainBase")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginUtils = require("Game/LoginNew/LoginUtils")
local LuaClass = require("Core/LuaClass")
local MSDKDefine = require("Define/MSDKDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local SaveKey = require("Define/SaveKey")
local TimeUtil = require("Utils/TimeUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetServerName = require("Binder/UIBinderSetServerName")
local UIBinderSetServerState = require("Binder/UIBinderSetServerState")
local UIBinderSetIsReadOnly = require("Binder/UIBinderSetIsReadOnly")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

local ESlateVisibility = _G.UE.ESlateVisibility
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local USaveMgr = _G.UE.USaveMgr
local LSTR = _G.LSTR

local FTAIAuthUtil = _G.UE.FTAIAuthUtil

---@class LoginNewMainPanelView : LoginNewMainBase
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgeTips UFButton
---@field BtnAssemble UFButton
---@field BtnCG UFButton
---@field BtnCheck UFButton
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
---@field IconQQBg UFImage
---@field IconResearchBg UFImage
---@field IconWeChat UFImage
---@field IconWechatBg UFImage
---@field ImgBubble2 UFImage
---@field ImgBubble3 UFImage
---@field ImgCheck UFImage
---@field ImgCheckBg UFImage
---@field ImgCheckFx UFImage
---@field ImgQQ UFImage
---@field ImgResearch UFImage
---@field ImgShare UFImage
---@field ImgUELogo UFImage
---@field ImgVolume UFImage
---@field ImgVolumeClose UFImage
---@field ImgWechat UFImage
---@field InputBox CommInputBoxView
---@field LoginLogoPage LoginLogoPageView
---@field LoginMovieImage UFImage
---@field LoginNewProBar LoginNewProBarItemView
---@field LoginNewSeverState LoginNewSeverItemView
---@field PanelBubble UFCanvasPanel
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
---@field AnimBubbleAwardLoop UWidgetAnimation
---@field AnimBubbleIn UWidgetAnimation
---@field AnimBubbleOut UWidgetAnimation
---@field AnimBubbleShareLoop UWidgetAnimation
---@field AnimFHorizontalIn UWidgetAnimation
---@field AnimInManual UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewMainPanelView = LuaClass(LoginNewMainBase, true)

function LoginNewMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgeTips = nil
	--self.BtnAssemble = nil
	--self.BtnCG = nil
	--self.BtnCheck = nil
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
	--self.IconQQBg = nil
	--self.IconResearchBg = nil
	--self.IconWeChat = nil
	--self.IconWechatBg = nil
	--self.ImgBubble2 = nil
	--self.ImgBubble3 = nil
	--self.ImgCheck = nil
	--self.ImgCheckBg = nil
	--self.ImgCheckFx = nil
	--self.ImgQQ = nil
	--self.ImgResearch = nil
	--self.ImgShare = nil
	--self.ImgUELogo = nil
	--self.ImgVolume = nil
	--self.ImgVolumeClose = nil
	--self.ImgWechat = nil
	--self.InputBox = nil
	--self.LoginLogoPage = nil
	--self.LoginMovieImage = nil
	--self.LoginNewProBar = nil
	--self.LoginNewSeverState = nil
	--self.PanelBubble = nil
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
	--self.AnimBubbleAwardLoop = nil
	--self.AnimBubbleIn = nil
	--self.AnimBubbleOut = nil
	--self.AnimBubbleShareLoop = nil
	--self.AnimFHorizontalIn = nil
	--self.AnimInManual = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnDownload)
	self:AddSubView(self.InputBox)
	self:AddSubView(self.LoginLogoPage)
	self:AddSubView(self.LoginNewProBar)
	self:AddSubView(self.LoginNewSeverState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewMainPanelView:OnInit()
	self.Super:OnInit()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnInit")
	--UIUtil.SetIsVisible(self.ImgBg, true)

	-- 蓝图UKey新规则
	self.TextNotice1:SetText(LSTR(LoginStrID.MainInfo))
	self.TextNotice2:SetText(LSTR(LoginStrID.MainInfo2))
	self.TextHealthy:SetText(LSTR(LoginStrID.MainHealthy))
	self.TextNum1:SetText(LSTR(LoginStrID.MainInfo3))
	self.TextNum2:SetText(LSTR(LoginStrID.MainInfo4))
	self.TextWechat:SetText(LSTR(LoginStrID.WXLogin))
	self.TextWeChat2:SetText(LSTR(LoginStrID.WXLogin))
	self.TextQQ:SetText(LSTR(LoginStrID.QQLogin))
	self.TextQQ2:SetText(LSTR(LoginStrID.QQLogin))
	self.TextScan:SetText(LSTR(LoginStrID.ScanLogin))
	self.TextPrepare:SetText(LSTR(LoginStrID.Prepare))
	self.TextFriends:SetText(LSTR(LoginStrID.Friend))
	self.TextCopyright1:SetText(LSTR(LoginStrID.Copyright1))
	self.TextCopyright2:SetText(LSTR(LoginStrID.Copyright2))
	self.LoginLogoPage.TextGo:SetText(LSTR(LoginStrID.EnterGame))

	self.PanelLogin:SetVisibility(ESlateVisibility.Collapsed)

	self.LoginLogoPage.PanelChina:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
	self.LoginLogoPage.PanelEnglish:SetVisibility(ESlateVisibility.Collapsed)
	self.LoginLogoPage.PanelGoChina:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
	self.LoginLogoPage.PanelGoEnglish:SetVisibility(ESlateVisibility.Collapsed)

	local HyperLink1 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.License), 1, "#D5D5D5FF",
			nil, nil, nil, nil, nil)
	local HyperLink2 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.FFPrivacy), 2, "#D5D5D5FF",
			nil, nil, nil, nil, nil)
	local HyperLink3 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.ChildrenPrivacy), 3, "#D5D5D5FF",
			nil, nil, nil, nil, nil)
	local HyperLink4 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.InfoShareList), 4, "#D5D5D5FF",
			nil, nil, nil, nil, nil)
	local NormalText1 = LSTR(LoginStrID.ReadAndAgree)
	local NormalText2 = LSTR(LoginStrID.And)
	local Text = string.format("%s %s、%s、%s%s%s", NormalText1, HyperLink1, HyperLink2, HyperLink3, NormalText2, HyperLink4)
	self.RichText:SetText(Text)

	self.FriendsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewFriends, nil, nil, nil, true)

	self:InitBinders()
end

function LoginNewMainPanelView:OnDestroy()
	self.Super:OnDestroy()
	FLOG_INFO("[LoginNewMainPanelView:OnDestroy]")
end

function LoginNewMainPanelView:OnShow()
	self.Super:OnShow()
	FLOG_INFO("[LoginNewMainPanelView:OnShow]")

	--UIUtil.SetIsVisible(self.BtnCustomerService, true, true)
	--UIUtil.SetIsVisible(self.BtnHelp, false)

	local IsChinese = CommonUtil.IsCurCultureChinese()
	UIUtil.SetIsVisible(self.PanelTextNotice, IsChinese)
	UIUtil.SetIsVisible(self.TextHealthy, IsChinese)
	UIUtil.SetIsVisible(self.TextNum1, IsChinese)
	UIUtil.SetIsVisible(self.TextNum2, IsChinese)

	local IsUserAgreementChecked = USaveMgr.GetInt(SaveKey.UserAgreementChecked, 0, false) == 1
	LoginNewVM:SetAgreeProtocolNoSave(IsUserAgreementChecked and true or false)

	_G.LoginMgr:ResetLoginSuccessStatus()

	self:HandleLoginAccount()
	_G.WorldMsgMgr:MarkLevelFinished()

	--_G.PandoraMgr:CloseGameletSDK()
	--_G.PandoraMgr:ResetOnceAppOpenState()
	self:OnLoginFromGameCenter()

	self.bNeedShowIntegration = _G.UE.UIntegrationMgr.Get():IsNeedShowIntegration();
	if self.bNeedShowIntegration then
		local OpeningTimestamp = _G.UE.UIntegrationMgr.Get():GetOpeningTimestamp();
		self.OpeningTimestamp = OpeningTimestamp - 28800;
		FLOG_INFO("[LoginNewMainPanelView:OnShow] OpeningTimestamp: %d", self.OpeningTimestamp)
		if self.OpeningTimestamp > 0 then
			self:CheckIntegration();
			self.IntegrationTimerId = self:RegisterTimer(function()
				self:CheckIntegration();
			end, 1, 1, 0)
		else
			UIUtil.SetIsVisible(self.BtnAssemble, false)
		end
	else
		UIUtil.SetIsVisible(self.BtnAssemble, false)
	end

	self:CheckCurCultureNameValid()
end

function LoginNewMainPanelView:OnHide()
	self.Super:OnHide()
	FLOG_INFO("[LoginNewMainPanelView:OnHide]")
end

function LoginNewMainPanelView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()

	UIUtil.AddOnClickedEvent(self, self.LoginLogoPage.BtnGoBig, self.OnClickBtnStart)
	--UIUtil.AddOnClickedEvent(self, self.LoginLogoPage.BtnGo, self.OnClickBtnStart)
	--UIUtil.AddOnClickedEvent(self, self.LoginLogoPage.BtnGo_1, self.OnClickBtnStart)

	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichText, self.OnClickRichTextAgreement, nil)
	UIUtil.AddOnClickedEvent(self, self.BtnScan, self.OnClickBtnScan)
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickBtnAgreement)
	UIUtil.AddOnClickedEvent(self, self.BtnQQ, self.OnClickBtnQQ)
	UIUtil.AddOnClickedEvent(self, self.BtnQQ2, self.OnClickBtnQQ2)
	UIUtil.AddOnClickedEvent(self, self.BtnWechat, self.OnClickBtnWechat)
	UIUtil.AddOnClickedEvent(self, self.BtnWechat2, self.OnClickBtnWechat2)
	UIUtil.AddOnClickedEvent(self, self.BtnAgeTips, self.OnClickBtnAgeTips)
	UIUtil.AddOnClickedEvent(self, self.BtnAssemble, self.OnClickBtnAssemble)
	FLOG_INFO("[LoginNewMainPanelView:OnRegisterUIEvent]")
end

function LoginNewMainPanelView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	FLOG_INFO("[LoginNewMainPanelView:OnRegisterGameEvent]")
	self:RegisterGameEvent(EventID.MSDKLoginRetNotify, self.OnGameEventMSDKLogin)
	self:RegisterGameEvent(EventID.MapleAllNodeInfoNotify, self.OnGameEventNodeInfoNotify)
	self:RegisterGameEvent(EventID.MapleFriendServerNotify, self.OnFriendServerNotify)
	self:RegisterGameEvent(EventID.LoginFromGameCenter, self.OnLoginFromGameCenter)
end

function LoginNewMainPanelView:OnRegisterBinder()
	self:RegisterBinders(LoginNewVM, self.Binders)
end

function LoginNewMainPanelView:InitBinders()
	local Binders = {
		--更新进度条
		{ "ShowUpdating", UIBinderSetIsVisible.New(self, self.PanelProBar) },
		-- 同玩好友列表
		{ "ShowFriendList", UIBinderSetIsVisible.New(self, self.PanelFriends) },
		{ "FriendList", UIBinderUpdateBindableList.New(self, self.FriendsTableViewAdapter) },
		-- 预下载
		{ "ShowPreDownloadBtn", UIBinderSetIsVisible.New(self, self.BtnDownload) },
		-- 公告
		{ "ShowNoticeBtn", UIBinderSetIsVisible.New(self, self.BtnNotice, false, true) },

		-- 服务器
		{ "WorldID", UIBinderSetServerName.New(self, self.TextSever) },
		{ "WorldState", UIBinderSetServerState.New(self, self.LoginNewSeverState.ImgSeverState) },

		-- 协议同意
		{ "AgreeProtocol", UIBinderSetIsVisible.New(self, self.ImgCheck) },
		{ "ShowAgreeProtocolGuide", UIBinderSetIsVisible.New(self, self.ImgCheckFx) },

		---// 登录前 //---
		-- 游戏许可及服务协议
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.FHorizontalAgree) },
		-- 登录按钮
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.HorizontalLogin) },
		-- 扫码登录
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.PanelScanLogin, false) },
		-- 游戏公约和忠告
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.TextNotice1, false) },
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.TextNotice2, false) },
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.TextHealthy, false) },
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.TextNum1, false) },
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.TextNum2, false) },

		---// 登录后 //---
		-- 服务器列表
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.FHorizontalBoxServer, true) },
		-- 注销登录
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.BtnLogout, true, true, true) },

		-- 显示启动游戏
		--{ "ShowStartBtn", UIBinderSetIsVisible.New(self, self.PanelGo, false) },
		{ "ShowStartBtn", UIBinderSetIsVisible.New(self, self.LoginLogoPage.PanelGo, false, true) },
		{ "ShowStartBtn", UIBinderSetIsVisible.New(self, self.LoginLogoPage.BtnGoBig, false, true) },
		--{ "ShowStartBtn", UIBinderSetIsVisible.New(self, self.LoginLogoPage.PanelGoChina, false) },
		--{ "ShowStartBtn", UIBinderSetIsVisible.New(self, self.LoginLogoPage.PanelGoEnglish, false) },
	}

	-- 研发登录
	table.insert(Binders, { "ShowResearchBtn", UIBinderSetIsVisible.New(self, self.BtnResearch, false, true) })
	if not UE.UCommonUtil.IsShipping() then
		table.insert(Binders, { "OpenID", UIBinderSetText.New(self, self.InputBox) })
		--table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.PanelInput, true) })
	else
		self.PanelInput:SetVisibility(ESlateVisibility.Collapsed)
	end

	if FTAIAuthUtil.IsEnable() then
		table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.TAIAuthPanel) })
	end

	-- 未安装微信的话，安卓使用二维码来登录，iOS直接不显示
	if AccountUtil.IsWeChatInstalled() then
		table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.BtnWechat, false, true) })
	else
		local PlatformName = CommonUtil.GetPlatformName()
		if PlatformName == "Android" then
			table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.BtnWechat, false, true) })
		elseif PlatformName == "IOS" then
			UIUtil.SetIsVisible(self.BtnWechat, false)
		else
			table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.BtnWechat, false, true) })
		end
	end

	self.Binders = Binders
end

---@param LoginRet FAccountLoginRetData
function LoginNewMainPanelView:OnGameEventMSDKLogin(LoginRet)
	FLOG_INFO("[Login] LoginNewMainPanelView:OnGameEventMSDKLogin ")
	self:OnLogin(LoginRet)
end

function LoginNewMainPanelView:OnGameEventNodeInfoNotify()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnGameEventNodeInfoNotify ")
	self:OnNodeInfoNotify()

	if LoginMgr.FriendServers and LoginMgr.AllMapleNodeInfo then
		LoginNewVM:UpdateFriendList()
	end
end

function LoginNewMainPanelView:OnFriendServerNotify()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnFriendServerNotify ")
	if LoginMgr.FriendServers and LoginMgr.AllMapleNodeInfo then
		LoginNewVM:UpdateFriendList()
	end
end

function LoginNewMainPanelView:OnLoginFromGameCenter()
	if LoginMgr.IsNeedLoginFromGameCenter == true then
		LoginMgr.IsNeedLoginFromGameCenter = false
		if LoginMgr.IsWechatWakeUp == true then
			FLOG_INFO("[LoginNewMainPanelView:OnLoginFromGameCenter] Login from WX GameCenter")
			self:OnClickBtnWechat()
		end
		if LoginMgr.IsQQWakeUp == true then
			FLOG_INFO("[LoginNewMainPanelView:OnLoginFromGameCenter] Login from QQ GameCenter")
			self:OnClickBtnQQ()
		end
	end
end

function LoginNewMainPanelView:OnCheckPreDownload()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnCheckPreDownload ")
	LoginNewVM.ShowPreDownloadBtn = true
end

function LoginNewMainPanelView:OnClickRichTextAgreement(_, LinkID)
	FLOG_INFO("[LoginNewMainPanelView:OnClickRichTextAgreement] LinkID：%d ", tonumber(LinkID))
	self:StopMedia()
	LoginUtils:OpenAgreementUrl(tonumber(LinkID));
end

function LoginNewMainPanelView:OnClickBtnStart()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnClickBtnStart OpenID:%s", LoginNewVM.OpenID)
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnStart] IsStartGame ")
		return
	end
	self:OnStartGame()
end

function LoginNewMainPanelView:OnClickBtnAgeTips()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnAgeTips] IsStartGame ")
		return
	end
	UIViewMgr:ShowView(UIViewID.LoginAgeAppropriate)
end

function LoginNewMainPanelView:OnClickBtnScan()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnScan] IsStartGame ")
		return
	end

	if self.PanelLogin:IsVisible() then
		self.PanelLogin:SetVisibility(ESlateVisibility.Collapsed)
	else
		self.PanelLogin:SetVisibility(ESlateVisibility.Visible)
	end
end

function LoginNewMainPanelView:OnClickBtnAgreement()
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnAgreement] IsStartGame ")
		return
	end

	--FLOG_INFO("[Login] LoginNewMainPanelView:OnClickBtnAgreement")
	LoginNewVM.ShowAgreeProtocolGuide = false

	if LoginNewVM.NeedShowUpdateAgreementView and LoginNewVM:GetAgreeProtocol() then
		UIViewMgr:ShowView(UIViewID.UserAgreementUpdate)
	end
	LoginNewVM:SetAgreeProtocol(not LoginNewVM.AgreeProtocol)
end

function LoginNewMainPanelView:OnClickBtnQQ()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnClickBtnQQ")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnQQ] IsStartGame ")
		return
	end

	if LoginNewVM:GetAgreeProtocol() then
		self:StopMedia()
		_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.QQ, MSDKDefine.LoginPermissions.QQ.All, "", "")
		--if AccountUtil.IsQQInstalled() then
		--	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.QQ, MSDKDefine.LoginPermissions.QQ.All, "", "")
		--else
		--	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.QQ, MSDKDefine.LoginPermissions.QQ.All, "", "{\"QRCode\":true}")
		--end
	else
		self:ShowAgreeProtocolTips()
	end
end

function LoginNewMainPanelView:OnClickBtnQQ2()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnClickBtnQQ2 Protocol:%s", tostring(LoginNewVM:GetAgreeProtocol()))
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnQQ2] IsStartGame ")
		return
	end

	if LoginNewVM:GetAgreeProtocol() then
		self:StopMedia()
		_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.QQ, MSDKDefine.LoginPermissions.QQ.All, "", "{\"QRCode\":true}")
	else
		self:ShowAgreeProtocolTips()
	end
end

function LoginNewMainPanelView:OnClickBtnWechat()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnClickBtnWechat")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnWechat] IsStartGame ")
		return
	end

	if LoginNewVM:GetAgreeProtocol() then
		self:StopMedia()
		if AccountUtil.IsWeChatInstalled() then
			_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.WeChat,
					table.concat(MSDKDefine.LoginPermissions.WeChat, ",") -- 获取所有权限
			, "", "")
		else
			_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.WeChat,
					table.concat(MSDKDefine.LoginPermissions.WeChat, ",") -- 获取所有权限
			, "", "{\"QRCode\":true}")
		end
		--_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.WeChat, table.concat(MSDKDefine.LoginPermissions.WeChat, ",") , "", "")
	else
		self:ShowAgreeProtocolTips()
	end
end

function LoginNewMainPanelView:OnClickBtnWechat2()
	FLOG_INFO("[Login] LoginNewMainPanelView:OnClickBtnWechat2")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnWechat2] IsStartGame ")
		return
	end

	if LoginNewVM:GetAgreeProtocol() then
		self:StopMedia()
		_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.WeChat, table.concat(MSDKDefine.LoginPermissions.WeChat, ",") , "", "{\"QRCode\":true}")
	else
		self:ShowAgreeProtocolTips()
	end
end

function LoginNewMainPanelView:ShowAgreeProtocolTips()
	LoginNewVM.ShowAgreeProtocolGuide = true
	MsgTipsUtil.ShowTips(LSTR(LoginStrID.CheckAgreement))
end

function LoginNewMainPanelView:ShowAgreeProtocolMsgPanel()
	UIViewMgr:ShowView(UIViewID.LoginLicensePrivacy)
end

function LoginNewMainPanelView:SwitchLoginAccount()
	FLOG_INFO("[LoginNewMainPanelView:SwitchLoginAccount] ")
	if LoginMgr.IsNeedChangeQQAccount then
		self:OnClickBtnQQ()
	elseif LoginMgr.IsNeedChangeWeChatAccount then
		self:OnClickBtnWechat()
	end
end

function LoginNewMainPanelView:OnClickBtnAssemble()
	FLOG_INFO("[LoginNewMainPanelView:OnClickBtnNoticeInternal]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainPanelView:OnClickBtnNoticeInternal] IsStartGame ")
		return
	end

	FLOG_INFO("[LoginNewMainPanelView:OnClickBtnNoticeInternal] LoginMainNew is not showing:%s", self.IsShowLoginMain)
	if not self.IsShowLoginMain then
		return
	end

	UIViewMgr:ShowView(UIViewID.IntegrationView)
	EventMgr:SendEvent(EventID.ShowIntegration)
end

function LoginNewMainPanelView:CheckIntegration()
	if not self.bNeedShowIntegration then
		self.BtnAssemble:SetVisibility(ESlateVisibility.Collapsed);
		self:UnRegisterTimer(self.IntegrationTimerId);
		return
	end

	local CurServerTime = TimeUtil.GetServerTime();
	local RemainingSeconds = self.OpeningTimestamp - CurServerTime;
	--FLOG_INFO("[LoginNewMainPanelView:CheckIntegration] RemainingSeconds :%d", RemainingSeconds)
	if RemainingSeconds >= 0 then
		self.BtnAssemble:SetVisibility(ESlateVisibility.Visible);
		self.PanelBubble:SetVisibility(ESlateVisibility.Visible);
		if not self.bHasPlayBubbleAnim then
			self.bHasPlayBubbleAnim = true
			-- 向蓝图发送事件
			self:OnPlayBubbleAnim()
		end
	else
		self.BtnAssemble:SetVisibility(ESlateVisibility.Collapsed);
		self.PanelBubble:SetVisibility(ESlateVisibility.Collapsed);
		self:UnRegisterTimer(self.IntegrationTimerId);
	end
end

function LoginNewMainPanelView:HandleLoginAccount()
	if LoginMgr.IsNeedSwitchAccountByWakeUp then
		self:SwitchLoginAccount()
	end

	if LoginMgr.IsWakeUpFromLaunch then
		local Tips = ""
		if LoginMgr.IsWechatWakeUp then
			-- 100005 微信帐号与游戏登录的帐号不一致，是否切换帐号？
			Tips = _G.LSTR(100005)
			LoginMgr.IsNeedChangeWeChatAccount = true
			FLOG_INFO("[LoginNewMainPanelView:HandleLoginAccount] IsWakeUpFromLaunch Wx")
		elseif LoginMgr.IsQQWakeUp then
			-- 100006 QQ帐号与游戏登录的帐号不一致，是否切换帐号？
			Tips = _G.LSTR(100006)
			LoginMgr.IsNeedChangeQQAccount = true
			FLOG_INFO("[LoginNewMainPanelView:HandleLoginAccount] IsWakeUpFromLaunch QQ")
		end

		local function OkBtnCallback()
			self:SwitchLoginAccount()
			LoginMgr:ResetWakeUpState()
		end

		local function CancelBtnCallback()
			_G.UE.UAccountMgr.Get():AutoLogin()
			LoginMgr:ResetWakeUpState()
		end
		MsgBoxUtil.MessageBox(Tips, _G.LSTR(10002), _G.LSTR(10003), OkBtnCallback, CancelBtnCallback)
	else
		LoginMgr:ResetWakeUpSwitchState()
	end
end

--- 检查当前语言是否有效(编辑器模式下)
function LoginNewMainPanelView:CheckCurCultureNameValid()
	if not CommonUtil.IsWithEditor() then
		return
	end

	local CultureName = CommonDefine.CultureName
	local CurCultureName = CommonUtil.GetCurrentCultureName() 

	for _, v in pairs(CultureName) do
		if CurCultureName == v then
			return
		end
	end

	-- 编辑器检测，不用把中文添加到多语言
	local Content = string.format("检测到游戏内语言标识异常(%s), 已强制切换回中文, 请重新登录游戏！", CurCultureName)

	MsgBoxUtil.ShowMsgBoxOneOpRightMustClick(
		nil, 
		LSTR(10004), --"提 示"
		Content, 
		function()
			CommonUtil.QuitGame()
		end, LSTR(10002)) -- "取 消"、"确 认"

	CommonUtil.SetCurrentCulture(CultureName.Chinese, true)
end

return LoginNewMainPanelView