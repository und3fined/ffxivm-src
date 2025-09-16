---
--- Author: moodliu
--- DateTime: 2023-03-08 15:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PayUtil = require("Utils/PayUtil")
local MSDKDefine = require("Define/MSDKDefine")
local AccountUtil = require("Utils/AccountUtil")
local ObjectGCType = require("Define/ObjectGCType")
local PathMgr = require("Path/PathMgr")
local CommonUtil = require("Utils/CommonUtil")

local MediaUtil = _G.UE.UMediaUtil

---@class SDKMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AutoLoginBtn UFButton
---@field BalanceQueryBtn UFButton
---@field CBLogin UComboBoxString
---@field CBLoginETxt UComboBoxString
---@field CanvasPanel_0 UCanvasPanel
---@field ClearLogBtn UFButton
---@field CloseBtn UFButton
---@field DaysETxt UFGMEditableText
---@field ImageBG UImage
---@field ImgTakePhoto UFImage
---@field Logger UMultiLineEditableTextBox
---@field LoginETxt UEditableText
---@field LoginTestBtn1 UFButton
---@field LoginTestBtn10 UFButton
---@field LoginTestBtn2 UFButton
---@field LoginTestBtn3 UFButton
---@field LoginTestBtn4 UFButton
---@field LoginTestBtn5 UFButton
---@field LoginTestBtn6 UFButton
---@field LoginTestBtn7 UFButton
---@field LoginTestBtn8 UFButton
---@field LoginTestBtn9 UFButton
---@field MonthsETxt UFGMEditableText
---@field PayBtn UFButton
---@field PayItemBtn UButton
---@field PayItemIdETxt UFGMEditableText
---@field PayItemQuantETxt UFGMEditableText
---@field PayMonthCardBtn UFButton
---@field PayStallETxt UFGMEditableText
---@field QQBtn UFButton
---@field SavePhotoBtn UFButton
---@field SubscribeBtn UFButton
---@field SubscribeTypeCbs UComboBoxString
---@field TBLoginInfo UTextBlock
---@field TakePhotoBtn UFButton
---@field TakePhotoNoUIBtn UFButton
---@field TakePhotoToImgBtn UFButton
---@field TxtTestLogin1 UTextBlock
---@field TxtTestLogin10 UTextBlock
---@field TxtTestLogin2 UTextBlock
---@field TxtTestLogin3 UTextBlock
---@field TxtTestLogin4 UTextBlock
---@field TxtTestLogin5 UTextBlock
---@field TxtTestLogin6 UTextBlock
---@field TxtTestLogin7 UTextBlock
---@field TxtTestLogin8 UTextBlock
---@field TxtTestLogin9 UTextBlock
---@field WXBtn UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SDKMainPanelView = LuaClass(UIView, true)

function SDKMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AutoLoginBtn = nil
	--self.BalanceQueryBtn = nil
	--self.CBLogin = nil
	--self.CBLoginETxt = nil
	--self.CanvasPanel_0 = nil
	--self.ClearLogBtn = nil
	--self.CloseBtn = nil
	--self.DaysETxt = nil
	--self.ImageBG = nil
	--self.ImgTakePhoto = nil
	--self.Logger = nil
	--self.LoginETxt = nil
	--self.LoginTestBtn1 = nil
	--self.LoginTestBtn10 = nil
	--self.LoginTestBtn2 = nil
	--self.LoginTestBtn3 = nil
	--self.LoginTestBtn4 = nil
	--self.LoginTestBtn5 = nil
	--self.LoginTestBtn6 = nil
	--self.LoginTestBtn7 = nil
	--self.LoginTestBtn8 = nil
	--self.LoginTestBtn9 = nil
	--self.MonthsETxt = nil
	--self.PayBtn = nil
	--self.PayItemBtn = nil
	--self.PayItemIdETxt = nil
	--self.PayItemQuantETxt = nil
	--self.PayMonthCardBtn = nil
	--self.PayStallETxt = nil
	--self.QQBtn = nil
	--self.SavePhotoBtn = nil
	--self.SubscribeBtn = nil
	--self.SubscribeTypeCbs = nil
	--self.TBLoginInfo = nil
	--self.TakePhotoBtn = nil
	--self.TakePhotoNoUIBtn = nil
	--self.TakePhotoToImgBtn = nil
	--self.TxtTestLogin1 = nil
	--self.TxtTestLogin10 = nil
	--self.TxtTestLogin2 = nil
	--self.TxtTestLogin3 = nil
	--self.TxtTestLogin4 = nil
	--self.TxtTestLogin5 = nil
	--self.TxtTestLogin6 = nil
	--self.TxtTestLogin7 = nil
	--self.TxtTestLogin8 = nil
	--self.TxtTestLogin9 = nil
	--self.WXBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SDKMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

local SelectedLoginMode = {
	Login = "Login",
	Friend = "Friend",
	Send = "Send",
	Share = "Share",
}

local LoginETxtTips = {
	QQFriendOpenID = "14875320627751246853",
	WXFriendOpenID = "9688394870728922382",
}

local LinkSample = {
	WebLink = "http://www.qq.com",
	PicLink = "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png"
}

function SDKMainPanelView:OnInit()
	self.CurChannel = ""
	self.ScreenshotPath = ""
	self:RefreshUIText()
	self:ResetComboBox()
	-- SDKMgr.MainPanel = self
end

function SDKMainPanelView:SetComboBoxOptions(CB, OptionArr, UseKey)
	CB:ClearOptions()

	for Key, Value in pairs(OptionArr) do
		local Option = UseKey and Key or Value
		CB:AddOption(Option)
	end

	--CB:SetSelectedIndex(0)
end

function SDKMainPanelView:ResetComboBox()
	self:SetComboBoxOptions(self.CBLogin, SelectedLoginMode, true)
	self:SetComboBoxOptions(self.CBLoginETxt, LoginETxtTips, true)
end

function SDKMainPanelView:RefreshUIText()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
		self.TxtTestLogin1:SetText("UL Test")
		self.TxtTestLogin2:SetText("Logout")
		self.TxtTestLogin3:SetText("Cur Login Ret")
	elseif CurMode == SelectedLoginMode.Friend then
		self.TxtTestLogin1:SetText("Query User Info")
		self.TxtTestLogin2:SetText("Add Friend")
		self.TxtTestLogin3:SetText("Other 3")
	elseif CurMode == SelectedLoginMode.Send then
		self.TxtTestLogin1:SetText("Send Text")
		self.TxtTestLogin2:SetText("Send Link")
		self.TxtTestLogin3:SetText("Send IMG")
		self.TxtTestLogin4:SetText("Send MiniApp")
		self.TxtTestLogin5:SetText("Send Music")
		self.TxtTestLogin6:SetText("Send Invite")
		self.TxtTestLogin7:SetText("Pull up MINI_APP")
		self.TxtTestLogin8:SetText("Send URL Video")
		self.TxtTestLogin9:SetText("Send Local Video")
		self.TxtTestLogin10:SetText("Send WXState")
	elseif CurMode == SelectedLoginMode.Share then
		self.TxtTestLogin1:SetText("Share Text")
		self.TxtTestLogin2:SetText("Share Link")
		self.TxtTestLogin3:SetText("Share IMG")
		self.TxtTestLogin4:SetText("Share Music")
		self.TxtTestLogin5:SetText("Share Invite")
		self.TxtTestLogin6:SetText("Share QQ MiniApp")
		self.TxtTestLogin7:SetText("Share WX GameLine")
		-- self.TxtTestLogin8:SetText("Send URL Video")
		-- self.TxtTestLogin9:SetText("Send Local Video")
		-- self.TxtTestLogin10:SetText("Send WXState")
	end
end

function SDKMainPanelView:OnDestroy()

end

function SDKMainPanelView:OnShow()
	UIUtil.SetIsVisible(self.ImgTakePhoto, false)
end

function SDKMainPanelView:OnHide()

end

function SDKMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CBLogin, self.OnLoginSelectedModeChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.CBLoginETxt, self.OnLoginSelectedTextChanged)

	UIUtil.AddOnClickedEvent(self, self.QQBtn, self.OnClickQQBtn)
	UIUtil.AddOnClickedEvent(self, self.WXBtn, self.OnClickWXBtn)
	UIUtil.AddOnClickedEvent(self, self.AutoLoginBtn, self.OnClickAutoLoginBtn)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn1, self.OnClickLoginTestBtn1)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn2, self.OnClickLoginTestBtn2)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn3, self.OnClickLoginTestBtn3)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn4, self.OnClickLoginTestBtn4)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn5, self.OnClickLoginTestBtn5)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn6, self.OnClickLoginTestBtn6)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn7, self.OnClickLoginTestBtn7)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn8, self.OnClickLoginTestBtn8)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn9, self.OnClickLoginTestBtn9)
	UIUtil.AddOnClickedEvent(self, self.LoginTestBtn10, self.OnClickLoginTestBtn10)

	UIUtil.AddOnClickedEvent(self, self.ClearLogBtn, self.OnClickClearLogBtn)
	UIUtil.AddOnClickedEvent(self, self.PayBtn, self.OnClickPayBtn)
	UIUtil.AddOnClickedEvent(self, self.PayItemBtn, self.OnClickPayItemBtn)
	UIUtil.AddOnClickedEvent(self, self.BalanceQueryBtn, self.OnClickBalanceQueryBtn)
	UIUtil.AddOnClickedEvent(self, self.PayMonthCardBtn, self.OnClickPayMonthCardBtn)
	UIUtil.AddOnClickedEvent(self, self.SubscribeBtn, self.OnClickSubscribeBtn)
	UIUtil.AddOnClickedEvent(self, self.TakePhotoBtn, self.OnClickTakePhotoBtn)
	UIUtil.AddOnClickedEvent(self, self.TakePhotoNoUIBtn, self.OnClickTakePhotoNoUIBtn)
	UIUtil.AddOnClickedEvent(self, self.SavePhotoBtn, self.OnClickSavePhotoBtn)
	UIUtil.AddOnClickedEvent(self, self.TakePhotoToImgBtn, self.OnClickTakePhotoToImgBtn)
	UIUtil.AddOnClickedEvent(self, self.CloseBtn, self.OnClickCloseBtn)
end

function SDKMainPanelView:OnLoginSelectedModeChanged()
	self:RefreshUIText()
end

function SDKMainPanelView:OnLoginSelectedTextChanged()
	local SelectedKey = self.CBLoginETxt:GetSelectedOption()
	local SelectedValue = LoginETxtTips[SelectedKey]

	self.LoginETxt:SetText(SelectedValue)
end

function SDKMainPanelView:GetLoginTxt()
	return self.LoginETxt:GetText()
end

function SDKMainPanelView:OnClickQQBtn()
	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.QQ, MSDKDefine.LoginPermissions.QQ.All, "", "")
	self:UpdateLoginInfo("QQ")
	self.CurChannel = "QQ"
end

function SDKMainPanelView:OnClickWXBtn()
	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.WeChat,
		table.concat(MSDKDefine.LoginPermissions.WeChat, ",") -- 获取所有权限
		, "", "")
	self:UpdateLoginInfo("WeChat")
	self.CurChannel = "WeChat"
end

function SDKMainPanelView:UpdateLoginInfo(CurChannel)
	self.TBLoginInfo:SetText(string.format("Cur Channel : %s", CurChannel))
end

function SDKMainPanelView:GetLoginFuncMode()
	local SelectedItem = self.CBLogin:GetSelectedOption()
	SelectedItem = string.isnilorempty(SelectedItem) and SelectedLoginMode.Login or SelectedItem
	return SelectedItem
end

function SDKMainPanelView:OnClickAutoLoginBtn()
	_G.UE.UAccountMgr.Get():AutoLogin()
end

function SDKMainPanelView:OnClickLoginTestBtn1()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
		-- 目前只支持微信端UniversalLink
		_G.UE.UAccountMgr.Get():CheckUniversalLink("Wechat", "", "")
	elseif CurMode == SelectedLoginMode.Friend then
		_G.UE.UAccountMgr.Get():QueryUserInfo()
	elseif CurMode == SelectedLoginMode.Send then
		-- 不支持QQ
		AccountUtil.SendText(self.CurChannel, self:GetLoginTxt(), false, "Desc")
	elseif CurMode == SelectedLoginMode.Share then
		AccountUtil.ShareText(self.CurChannel, "Share Text")
	end
end

function SDKMainPanelView:OnClickLoginTestBtn2()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
		_G.UE.UAccountMgr.Get():Logout()
	elseif CurMode == SelectedLoginMode.Friend then
		local FriendReqInfo = _G.UE.FAccountFriendReqInfo()
		FriendReqInfo.Title = "title"
		FriendReqInfo.Desc = "desc"
		FriendReqInfo.Type = UE.MSDKFriendReqType.kMSDKFriendReqTypeText
		FriendReqInfo.User = self:GetLoginTxt()
		_G.UE.UAccountMgr.Get():AddFriend(FriendReqInfo, self.CurChannel)
	elseif CurMode == SelectedLoginMode.Send then
		AccountUtil.SendLink(self.CurChannel, self:GetLoginTxt(), false, "Desc", LinkSample.WebLink, LinkSample.PicLink, nil)
	elseif CurMode == SelectedLoginMode.Share then
		AccountUtil.ShareLink(self.CurChannel, "https://www.qq.com", "QQ Link")
	end
end

function SDKMainPanelView:OnClickLoginTestBtn3()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
		local LoginRet = _G.UE.FAccountLoginRetData()
		local _ = _G.UE.UAccountMgr.Get():GetLoginRet(LoginRet)
		_G.SDKMgr:AppendToInfo("LoginRet = ", LoginRet, MSDKDefine.ClassMembers.LoginRetData)
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
		AccountUtil.SendIMG(self.CurChannel, self:GetLoginTxt(), false, self.ScreenshotPath, self.ScreenshotPath)
	elseif CurMode == SelectedLoginMode.Share then
		AccountUtil.SharePicture(self.CurChannel, self.ScreenshotPath)
	end
end

function SDKMainPanelView:OnClickLoginTestBtn4()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
		if self.CurChannel == MSDKDefine.Channel.QQ then
			AccountUtil.SendQQMiniApp("http://www.qq.com", "QQ小程序", "QQ小程序描述", "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png", 
			"1109878856", "pages/index/index", "www.qq.com", 3)
		elseif self.CurChannel == MSDKDefine.Channel.WeChat then
			AccountUtil.SendWechatMiniApp("https://www.qq.com", "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png", 
				"gh_e9f675597c15", 0, "MSG_INVITE", nil)
		end
	elseif CurMode == SelectedLoginMode.Share then
		AccountUtil.ShareMusic("http://y.qq.com/#type=song&mid=000cz9pr0xlAId", "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png")
	end
end

function SDKMainPanelView:OnClickLoginTestBtn5()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
		AccountUtil.SendMusic(self.CurChannel, "http://y.qq.com/#type=song&mid=000cz9pr0xlAId", "Music Tile", "Musid desc",
		"http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png", "http://music.163.com/song/media/outer/url?id=317151.mp3")
	elseif CurMode == SelectedLoginMode.Share then
		AccountUtil.ShareInvite("http://m.gamecenter.qq.com/directout/detail/1106977030?_wv=2147484679&_wwv=4&ADTAG=gamecenter&autodownload=1&pf=invite&appid=1106977030&asyncMode=3&appType=1&_nav_bgclr=ffffff&_nav_titleclr=ffffff&_nav_txtclr=ffffff&_nav_anim=true&_nav_alpha=0")
	end
end

function SDKMainPanelView:OnClickLoginTestBtn6()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
		AccountUtil.SendInvite(self.CurChannel, self:GetLoginTxt(), false, "http://gamecenter.qq.com/gcjump?appid=100703379&pf=invite&from=iphoneqq&plat=qq&originuin=111&ADTAG=gameobj.msg_invite",
			"Invite Title", "Invite Desc", "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png")
	elseif CurMode == SelectedLoginMode.Share then
		AccountUtil.ShareQQMiniApp("QQ小程序分享", "QQ小程序Desc", "http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png",
			"http://www.qq.com", "1109878856", "pages/index/index", "www.qq.com", 3)
	end
end

function SDKMainPanelView:OnClickLoginTestBtn7()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
		if self.CurChannel == MSDKDefine.Channel.QQ then
			AccountUtil.SendPullUpQQMiniApp("1109878856", "pages/component/pages/launchApp813/launchApp813?1=2&2=4", 3)
		elseif self.CurChannel == MSDKDefine.Channel.WeChat then
			AccountUtil.SendPullUpWechatMiniApp("pages/indexSelAddr/indexSelAddr", "gh_e9f675597c15", 1, 0)
		end
	elseif CurMode == SelectedLoginMode.Share then
		AccountUtil.ShareWXGameLine("http://mat1.gtimg.com/www/qq2018/imgs/qq_logo_2018x2.png", "Title", "shareWXGameLinePic")
	end
end

function SDKMainPanelView:OnClickLoginTestBtn8()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
		local ExtraJson = AccountUtil.MakeOpenBusinessView_URLVideo("nativeShareToGameHaoWan", "https://qt.qq.com/php_cgi/cod_video/php/get_video_url.php?vid=2a495e10fc03426fb8e4def77fc68a57&game_id=1007039",
			"http://shp.qpic.cn/record_smoba/0/53209e869e71dc351129059fbb5f748dT1552892652598430/", 1, "game12345")
		AccountUtil.SendOpenBusinessView(ExtraJson)
	end
end

function SDKMainPanelView:OnClickLoginTestBtn9()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
	end
end

function SDKMainPanelView:OnClickLoginTestBtn10()
	local CurMode = self:GetLoginFuncMode()
	if CurMode == SelectedLoginMode.Login then
	elseif CurMode == SelectedLoginMode.Friend then
	elseif CurMode == SelectedLoginMode.Send then
		AccountUtil.SendWXStatePhoto("Test Wechat State", "https://game.weixin.qq.com/cgi-bin/h5/static/circlecenter/mixed_circle.html?tabid=7&appid=wx95a3a4d7c627e07d&ssid=46#wechat_redirect",
			self.ScreenshotPath, "1019")
	end
end

function SDKMainPanelView:OnClickClearLogBtn()
	self:ClearLog()
end

function SDKMainPanelView:AppendLog(Log, Category)
	Category = Category or "Info"
	local Text = self.Logger:GetText()
	Text = Text .. string.format("\t[%s] %s\n", Category, Log)
	print(string.format("[SDKMainPanelView %s] %s\n", Category, Log))
	self.Logger:SetText(Text)
end

function SDKMainPanelView:AppendInfo(Log)
	self:AppendLog(Log)
end

function SDKMainPanelView:AppendWarn(Log)
	self:AppendLog(Log, "Warn")
end

function SDKMainPanelView:AppendError(Log)
	self:AppendLog(Log, "Error")
end

function SDKMainPanelView:ClearLog()
	self.Logger:SetText("")
end

function SDKMainPanelView:LoginExpiredCallback()
	self:AppendInfo("Login expired!")
end

function SDKMainPanelView:BillReceivedCallback(BillData)
	if BillData == nil then
		self:AppendError("Cannot get pay bill data")
		return
	end

	if BillData.URL == "" then
		self:AppendError("Pay bill is empty")
	end
end

function SDKMainPanelView:PayFinishedCallback(PayReturnData)
	self:AppendInfo("Pay finished...")
	if PayReturnData == nil then
		self:AppendError("Cannot get pay return data")
		return
	end

	if PayReturnData.ResultCode == -1 then
		self:AppendInfo("Network error.")
	elseif PayReturnData.ResultCode == 0 then
		self:AppendInfo("Pay succeeded.")
		if self.ReceivedGoods ~= true then
			self:AppendInfo("Waiting for goods...")
			self.PayFinished = true
		else
			self:OnRechargeFinished()
		end
	elseif PayReturnData.ResultCode == 2 then
		self:AppendInfo("Pay canceled.")
	else
		self:AppendError("Pay failed. Error code: "..PayReturnData.ResultCode)
	end
	self:AppendInfo("Pay amount: "..PayReturnData.RealSaveNum)
	self:AppendInfo("Pay channel: "..PayReturnData.PayChannel)
	self:AppendInfo("Pay app extends: "..PayReturnData.AppExtends)
	self:AppendInfo("Pay request type: "..PayReturnData.ReqType)
end

function SDKMainPanelView:GoodsReceivedCallback(GoodsData)
	self:AppendInfo("Goods received.")
	if self.PayFinished ~= true then
		self:AppendInfo("Waiting for pay to finish...")
		self.ReceivedGoods = true
	else
		self:OnRechargeFinished()
	end
end

function SDKMainPanelView:OnRechargeFinished()
	self.PayFinished = false
	self.ReceivedGoods = false
	self:AppendInfo("Recharging process finished.")
end

function SDKMainPanelView:OnClickPayBtn()
	local Stall = tonumber(self.PayStallETxt:GetText())
	if Stall < 1 or Stall > 8 then
		self:AppendError("Pay stall out of range!")
		return
	end
	PayUtil.BuyCoins(Stall,
	function(_, BillData) self:BillReceivedCallback(BillData) end,
	function(_) self:LoginExpiredCallback() end,
	function(_, PayReturnData) self:PayFinishedCallback(PayReturnData) end,
	function(_, GoodsData) self:GoodsReceivedCallback(GoodsData) end,
	self)
end

function SDKMainPanelView:OnClickPayItemBtn()
	PayUtil.BuyItems(self.PayItemIdETxt:GetText(), tonumber(self.PayItemQuantETxt:GetText()),
	function(_) self:LoginExpiredCallback() end,
	function(_, PayReturnData) self:PayFinishedCallback(PayReturnData) end)
end

function SDKMainPanelView:OnClickPayMonthCardBtn()
	PayUtil.BuyMonthCard(tonumber(self.DaysETxt:GetText()),
	function(_) self:LoginExpiredCallback() end,
	function(_, PayReturnData) self:PayFinishedCallback(PayReturnData) end)
end

function SDKMainPanelView:OnClickSubscribeBtn()
	PayUtil.Subscribe(self.SubscribeTypeCbs:GetSelectedIndex() + 1, tonumber(self.MonthsETxt:GetText()),
	function(_) self:LoginExpiredCallback() end,
	function(_, PayReturnData) self:PayFinishedCallback(PayReturnData) end)
end

function SDKMainPanelView:OnClickTakePhotoBtn()
	_G.UE.UMediaUtil.TakeScreenshotRequest("fmgame", true, true, function(_, Width, Height, Colors)
		self:OnScreenshotCaptured(Width, Height, Colors,
			 "Texture2D'/Game/UI/Texture/Collection/UI_Collect_Btn_ActiveSkill.UI_Collect_Btn_ActiveSkill'")
	end)
end

function SDKMainPanelView:OnClickTakePhotoNoUIBtn()
	MediaUtil.SelectAlbumPhoto()
end

function SDKMainPanelView:OnClickSavePhotoBtn()
	self:AppendInfo(self.ScreenshotPath)
	local PlatformName = CommonUtil.GetPlatformName()
	if PlatformName == "Android" then
		local AlbumPath = UE.UMediaUtil.GetAlbumPath()
		self:AppendInfo("AlbumPath : " .. AlbumPath)
		self:AppendInfo("ScreenshotPath : " .. self.ScreenshotPath)
		self:AppendInfo("GetCleanFilename : " .. PathMgr.GetBaseFilename(self.ScreenshotPath, true))
		local DesPath = string.format("%s/%s", AlbumPath, PathMgr.GetCleanFilename(self.ScreenshotPath))
		self:AppendInfo(DesPath)
		if UE.UCommonUtil.MoveFile(DesPath, self.ScreenshotPath, true) then
			UE.UMediaUtil.NotifyAlbumUpdate(DesPath)
			self:AppendInfo(LSTR("保存成功"))
		else
			self:AppendInfo(LSTR("保存失败"))
		end
	elseif PlatformName == "IOS" then
		MediaUtil.SaveNativeScreenshot(self.ScreenshotPath)
	end
end

function SDKMainPanelView:OnClickTakePhotoToImgBtn()
	_G.UE.UMediaUtil.TakeScreenshot(false, function(_, Width, Height, Colors)
		self:AppendInfo(string.format("TakePhotoToImg success, Width: %s, Height: %s ", Width, Height))

		local Texture2D = _G.UE.UMediaUtil.CovertColorsToTexture2D("", Colors, Width, Height)
		UIUtil.ImageSetBrushResourceObject(self.ImgTakePhoto, Texture2D)
		UIUtil.SetIsVisible(self.ImgTakePhoto, true)
	end)
end

function SDKMainPanelView:OnClickCloseBtn()
	self:Hide()
end

function SDKMainPanelView:GetScreenshotFilePath(Filename)
	return  MediaUtil.GetScreenshotPath() .. PathMgr.GetCleanFilename(Filename)
end

function SDKMainPanelView:OnScreenshotCaptured(Width, Height, Colors, WaterMaskPath)
	local ScreenshotFilename = MediaUtil.BitmapToSavedFile(Width, Height, Colors, true)
	self.ScreenshotPath = self:GetScreenshotFilePath(ScreenshotFilename)
	self:AppendInfo("ScreenshotPath : "..self.ScreenshotPath)
	self:AppendInfo("Test" .. _G.UE.UFlibAppHelper.ConvertToAbsolutePathForExternalAppForRead(UE.UBlueprintPathsLibrary.ProjectSavedDir()))
end

function SDKMainPanelView:BalanceCallback(BalanceReturnData)
	self:AppendInfo("Balance query finished...")
	if BalanceReturnData.bSuccess then
		self:AppendInfo("Balance query succeeded")
		self:AppendInfo("Balance: "..BalanceReturnData.Balance)
	else
		self:AppendError("Balance query failed")
	end
end

function SDKMainPanelView:OnClickBalanceQueryBtn()
	local function BalanceCallback(_, BalanceReturnData)
		self:AppendInfo("Balance query finished...")
		if BalanceReturnData.bSuccess then
			self:AppendInfo("Balance query succeeded")
			self:AppendInfo("Balance: "..BalanceReturnData.Balance)
		else
			self:AppendError("Balance query failed")
		end
	end

	PayUtil.GetBalance(BalanceCallback)
end

function SDKMainPanelView:AlbumPhotoSelectedNotify(Base64Str)
	local Texture = MediaUtil.ConvertBase64ToTexture2D(Base64Str)
	UIUtil.ImageSetBrushResourceObject(self.ImageBG, Texture)
end

function SDKMainPanelView:SelectPhoto(PhotoPath, Angle, RetCode)
	local Texture = MediaUtil.GetTextureFromFile(PhotoPath)
	UIUtil.ImageSetBrushResourceObject(self.ImageBG, Texture)
end

function SDKMainPanelView:OnRegisterGameEvent()
	local EventID = require("Define/EventID")
	self:RegisterGameEvent(EventID.AlbumPhotoSelectedNotify, self.AlbumPhotoSelectedNotify)
	self:RegisterGameEvent(EventID.TakePhoto, self.SelectPhoto)
end

function SDKMainPanelView:OnRegisterBinder()

end

return SDKMainPanelView