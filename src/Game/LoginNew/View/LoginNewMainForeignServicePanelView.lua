---
--- Author: richyczhou
--- DateTime: 2024-06-25 10:00
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")
local LoginNewMainBase = require("Game/LoginNew/View/LoginNewMainBase")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local LoginMgr = require("Game/Login/LoginMgr")
local LuaClass = require("Core/LuaClass")
local MSDKDefine = require("Define/MSDKDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetServerName = require("Binder/UIBinderSetServerName")
local UIBinderSetServerState = require("Binder/UIBinderSetServerState")
local UIBinderSetIsReadOnly = require("Binder/UIBinderSetIsReadOnly")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

local FTAIAuthUtil = _G.UE.FTAIAuthUtil
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class LoginNewMainForeignServicePanelView : LoginNewMainBase
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnApple UFButton
---@field BtnAssemble UFButton
---@field BtnCG UFButton
---@field BtnDownload LoginNewDownloadItemView
---@field BtnEmail UFButton
---@field BtnFacebook UFButton
---@field BtnGoogle UFButton
---@field BtnGuest UFButton
---@field BtnHelp UFButton
---@field BtnLanguage UFButton
---@field BtnLogout UFButton
---@field BtnMore UFButton
---@field BtnNotice UFButton
---@field BtnRepair UFButton
---@field BtnResearch UFButton
---@field BtnSever UFButton
---@field BtnTAIAuthLogout UFButton
---@field BtnVolume UToggleButton
---@field CoverImage UImage
---@field FHorizontalBoxServer UFHorizontalBox
---@field FVerticalBox UFVerticalBox
---@field HorizontalLogin UHorizontalBox
---@field ImgApple UFImage
---@field ImgArrowL UFImage
---@field ImgArrowR UFImage
---@field ImgEmail UFImage
---@field ImgFacebook UFImage
---@field ImgGoogle UFImage
---@field ImgGuest UFImage
---@field ImgMore UFImage
---@field ImgResearch UFImage
---@field ImgVolume UFImage
---@field ImgVolumeClose UFImage
---@field InputBox CommInputBoxView
---@field LoginLogoPage LoginLogoPageView
---@field LoginMovieImage UFImage
---@field LoginNewSeverState LoginNewSeverItemView
---@field PanelArrow UFCanvasPanel
---@field PanelInput UFCanvasPanel
---@field PanelLoginWith UFCanvasPanel
---@field PanelLogout UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelSever UFCanvasPanel
---@field PanelText UFCanvasPanel
---@field TAIAuthPanel UFCanvasPanel
---@field TextApple UFTextBlock
---@field TextCopyright UFTextBlock
---@field TextEmail UFTextBlock
---@field TextFacebook UFTextBlock
---@field TextGoogle UFTextBlock
---@field TextGuest UFTextBlock
---@field TextLoginwith UFTextBlock
---@field TextLogout UFTextBlock
---@field TextMore UFTextBlock
---@field TextNum UFTextBlock
---@field TextNum3 UFTextBlock
---@field TextResearch UFTextBlock
---@field TextSever UFTextBlock
---@field TextTAIAuthLogout UFTextBlock
---@field TextTAIAuthUser UFTextBlock
---@field AnimFHorizontalIn UWidgetAnimation
---@field AnimInManual UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewMainForeignServicePanelView = LuaClass(LoginNewMainBase, true)

function LoginNewMainForeignServicePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnApple = nil
	--self.BtnAssemble = nil
	--self.BtnCG = nil
	--self.BtnDownload = nil
	--self.BtnEmail = nil
	--self.BtnFacebook = nil
	--self.BtnGoogle = nil
	--self.BtnGuest = nil
	--self.BtnHelp = nil
	--self.BtnLanguage = nil
	--self.BtnLogout = nil
	--self.BtnMore = nil
	--self.BtnNotice = nil
	--self.BtnRepair = nil
	--self.BtnResearch = nil
	--self.BtnSever = nil
	--self.BtnTAIAuthLogout = nil
	--self.BtnVolume = nil
	--self.CoverImage = nil
	--self.FHorizontalBoxServer = nil
	--self.FVerticalBox = nil
	--self.HorizontalLogin = nil
	--self.ImgApple = nil
	--self.ImgArrowL = nil
	--self.ImgArrowR = nil
	--self.ImgEmail = nil
	--self.ImgFacebook = nil
	--self.ImgGoogle = nil
	--self.ImgGuest = nil
	--self.ImgMore = nil
	--self.ImgResearch = nil
	--self.ImgVolume = nil
	--self.ImgVolumeClose = nil
	--self.InputBox = nil
	--self.LoginLogoPage = nil
	--self.LoginMovieImage = nil
	--self.LoginNewSeverState = nil
	--self.PanelArrow = nil
	--self.PanelInput = nil
	--self.PanelLoginWith = nil
	--self.PanelLogout = nil
	--self.PanelMain = nil
	--self.PanelSever = nil
	--self.PanelText = nil
	--self.TAIAuthPanel = nil
	--self.TextApple = nil
	--self.TextCopyright = nil
	--self.TextEmail = nil
	--self.TextFacebook = nil
	--self.TextGoogle = nil
	--self.TextGuest = nil
	--self.TextLoginwith = nil
	--self.TextLogout = nil
	--self.TextMore = nil
	--self.TextNum = nil
	--self.TextNum3 = nil
	--self.TextResearch = nil
	--self.TextSever = nil
	--self.TextTAIAuthLogout = nil
	--self.TextTAIAuthUser = nil
	--self.AnimFHorizontalIn = nil
	--self.AnimInManual = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewMainForeignServicePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnDownload)
	self:AddSubView(self.InputBox)
	self:AddSubView(self.LoginLogoPage)
	self:AddSubView(self.LoginNewSeverState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewMainForeignServicePanelView:OnInit()
	self.Super:OnInit()
	--UIUtil.SetIsVisible(self.ImgBg, true)

	self.LoginLogoPage.PanelChina:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
	self.LoginLogoPage.PanelEnglish:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
	self.LoginLogoPage.PanelGoChina:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
	self.LoginLogoPage.PanelGoEnglish:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)

	self.TextGuest:SetText(LSTR(LoginStrID.Guest))
	self.TextFacebook:SetText(LSTR(LoginStrID.Facebook))
	self.TextEmail:SetText(LSTR(LoginStrID.Email))
	self.TextApple:SetText(LSTR(LoginStrID.Apple))
	self.TextGoogle:SetText(LSTR(LoginStrID.Google))
	self.TextMore:SetText(LSTR(LoginStrID.More))
	self.TextLoginwith:SetText(LSTR(LoginStrID.LoginWith))
	self.TextCopyright:SetText(LSTR(LoginStrID.OverseaCopyright))
	self.LoginLogoPage.TextTap:SetText(LSTR(LoginStrID.EnterGame))

	self:InitBinders()
end

function LoginNewMainForeignServicePanelView:OnDestroy()
	self.Super:OnDestroy()
end

function LoginNewMainForeignServicePanelView:OnShow()
	self.Super:OnShow()
end

function LoginNewMainForeignServicePanelView:OnHide()
	self.Super:OnHide()
end

function LoginNewMainForeignServicePanelView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()

	UIUtil.AddOnClickedEvent(self, self.LoginLogoPage.BtnGoBig, self.OnClickBtnStart)
	--UIUtil.AddOnClickedEvent(self, self.LoginLogoPage.BtnGo, self.OnClickBtnStart)
	--UIUtil.AddOnClickedEvent(self, self.LoginLogoPage.BtnGo_1, self.OnClickBtnStart)

	UIUtil.AddOnClickedEvent(self, self.BtnEmail, self.OnClickBtnEmail)
	UIUtil.AddOnClickedEvent(self, self.BtnGuest, self.OnClickBtnGuest)
	UIUtil.AddOnClickedEvent(self, self.BtnFacebook, self.OnClickBtnFacebook)
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickBtnMore)

	if CommonUtil.IsIOSPlatform() then
		UIUtil.AddOnClickedEvent(self, self.BtnApple, self.OnClickBtnApple)
	else
		UIUtil.AddOnClickedEvent(self, self.BtnGoogle, self.OnClickBtnGoogle)
	end

	UIUtil.AddOnClickedEvent(self, self.BtnLanguage, self.OnClickBtnLanguage)
end

function LoginNewMainForeignServicePanelView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	FLOG_INFO("[Login] LoginNewMainForeignServicePanelView:OnRegisterGameEvent")
	self:RegisterGameEvent(EventID.MSDKLoginRetNotify, self.OnGameEventMSDKLogin)
	self:RegisterGameEvent(EventID.MapleAllNodeInfoNotify, self.OnGameEventNodeInfoNotify)
	self:RegisterGameEvent(EventID.MapleFriendServerNotify, self.OnFriendServerNotify)
end

function LoginNewMainForeignServicePanelView:OnRegisterBinder()
	self:RegisterBinders(LoginNewVM, self.Binders)
end

function LoginNewMainForeignServicePanelView:InitBinders()
	local Binders = {
		-- 预下载
		{ "ShowPreDownloadBtn", UIBinderSetIsVisible.New(self, self.BtnDownload) },
		-- 公告
		{ "ShowNoticeBtn", UIBinderSetIsVisible.New(self, self.BtnNotice, false, true) },

		-- 服务器名称
		{ "WorldID", UIBinderSetServerName.New(self, self.TextSever) },
		{ "WorldState", UIBinderSetServerState.New(self, self.LoginNewSeverState.ImgSeverState) },

		---// 登录前 //---
		-- 登录按钮
		{ "NoLogin", UIBinderSetIsVisible.New(self, self.PanelLoginWith) },

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

	if CommonUtil.IsIOSPlatform() then
		self.BtnApple:SetVisibility(_G.UE.ESlateVisibility.Visible)
		self.BtnGoogle:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
		table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.BtnApple, false, true) })
	else
		self.BtnApple:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
		self.BtnGoogle:SetVisibility(_G.UE.ESlateVisibility.Visible)
		table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.BtnGoogle, false, true) })
	end

	-- 研发登录
	if not UE.UCommonUtil.IsShipping() then
		table.insert(Binders, { "OpenID", UIBinderSetText.New(self, self.InputBox) })
		--table.insert(Binders, { "DevLogin", UIBinderSetIsReadOnly.New(self, self.InputBox, true) })
		table.insert(Binders, { "ShowResearchBtn", UIBinderSetIsVisible.New(self, self.BtnResearch, false, true) })
		table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.PanelInput, true) })
		--table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.InputBox.RichTextNumber, true) })
	end

	if FTAIAuthUtil.IsEnable() then
		table.insert(Binders, { "NoLogin", UIBinderSetIsVisible.New(self, self.TAIAuthPanel) })
	end

	self.Binders = Binders
end

---@param LoginRet FAccountLoginRetData
function LoginNewMainForeignServicePanelView:OnGameEventMSDKLogin(LoginRet)
	FLOG_INFO("[Login] LoginNewMainForeignServicePanelView:OnGameEventMSDKLogin ")
	self:OnLogin(LoginRet)

	if UIViewMgr:IsViewVisible(UIViewID.LoginMoreWin) then
		UIViewMgr:HideView(UIViewID.LoginMoreWin)
	end

	if UIViewMgr:IsViewVisible(UIViewID.LoginEmailMain) and LoginRet.RetCode == MSDKDefine.MSDKError.SUCCESS then
		UIViewMgr:HideView(UIViewID.LoginEmailMain)
	end
end

function LoginNewMainForeignServicePanelView:OnGameEventNodeInfoNotify()
	FLOG_INFO("[Login] LoginNewMainForeignServicePanelView:OnGameEventNodeInfoNotify ")
	self:OnNodeInfoNotify()
end

function LoginNewMainForeignServicePanelView:OnFriendServerNotify()
	FLOG_INFO("[Login] LoginNewMainForeignServicePanelView:OnFriendServerNotify ")
	LoginNewVM:UpdateFriendList()
end

function LoginNewMainForeignServicePanelView:OnClickBtnStart()
	--FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnStart] ")
	self:OnStartGame()
end

function LoginNewMainForeignServicePanelView:OnClickBtnEmail()
	--FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnEmail]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnEmail] IsStartGame ")
		return
	end

	_G.UIViewMgr:ShowView(UIViewID.LoginEmailMain)
end

function LoginNewMainForeignServicePanelView:OnClickBtnGuest()
	FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnGuest]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnGuest] IsStartGame ")
		return
	end

	local function Callback()
		self:StopMedia()
		_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.Guest, "", "", "")
	end
	_G.MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(LoginStrID.TipsTitle), LSTR(LoginStrID.GuestTips), Callback)
end

function LoginNewMainForeignServicePanelView:OnClickBtnFacebook()
	print("[LoginNewMainForeignServicePanelView:OnClickBtnFacebook] ")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnFacebook] IsStartGame ")
		return
	end

	self:StopMedia()
	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.Facebook, table.concat(MSDKDefine.LoginPermissions.Facebook, ","), "", "")
end

function LoginNewMainForeignServicePanelView:OnClickBtnApple()
	FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnApple]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnApple] IsStartGame ")
		return
	end

	self:StopMedia()
	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.Apple, table.concat(MSDKDefine.LoginPermissions.Apple, ","), "", "")
end

function LoginNewMainForeignServicePanelView:OnClickBtnGoogle()
	FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnGoogle]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnGoogle] IsStartGame ")
		return
	end

	self:StopMedia()
	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.Google, "", "", "")
end

function LoginNewMainForeignServicePanelView:OnClickBtnMore()
	FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnMore]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnMore] IsStartGame ")
		return
	end

	_G.UIViewMgr:ShowView(UIViewID.LoginMoreWin)
end

function LoginNewMainForeignServicePanelView:OnClickBtnLanguage()
	print("[LoginNewMainForeignServicePanelView:OnClickBtnLanguage]")
	if LoginMgr.IsStartGame then
		FLOG_INFO("[LoginNewMainForeignServicePanelView:OnClickBtnLanguage] IsStartGame ")
		return
	end

	_G.UIViewMgr:ShowView(UIViewID.LoginLanguageWin)
end

return LoginNewMainForeignServicePanelView