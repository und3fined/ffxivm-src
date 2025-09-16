local AccountUtil = require("Utils/AccountUtil")
local CommonUtil = require("Utils/CommonUtil")
local MSDKDefine = require("Define/MSDKDefine")
local Json = require("Core/Json")
local MajorUtil = require ("Utils/MajorUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local OperationMenuItemsCfg = require("TableCfg/OperationMenuItemsCfg")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")
local TimeUtil = require("Utils/TimeUtil")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local OperationChannelFunctionCfg = require("TableCfg/OperationChannelFunctionCfg")

local OperationUtil = {}

OperationUtil.CustomServiceUrl = "https://kf.qq.com/touch/sy/prod/A10935/v2/index.html?scene_id="
OperationUtil.CustomServiceSceneID = {
	Login = "CSCE20250312161258MGAVRVxb",
	Settings = "CSCE20250312162337izcLGQEA",
	Recharge = "CSCE20250312161319BfYuGYys",
	MainPanel = "CSCE20250312162337izcLGQEA",
	OpsActivity = "CSCE20250312161422BwNClRTR"
}

OperationUtil.FeedbackUrl = "https://in.weisurvey.com/v2/?sid=66e03c4c348c930d66013191"

OperationUtil.SocialRedDotID = 20
OperationUtil.GameBotRedDotID = 80

OperationUtil.HasInitOperationMenuItems = false
OperationUtil.OperationMenuItems = {}

OperationUtil.FreeFlowInfoUrl = "https://chong.kingcard.qq.com/cgi/kingcard/GetFreeFlowInfo"
OperationUtil.FreeFlowSignKey = ""

OperationUtil.WeChatWelfareUrl = "https://game.weixin.qq.com/cgi-bin/comm/openlink?auth_appid=wx62d9035fd4fd2059&url=https%3A%2F%2Fgame.weixin.qq.com%2Fcgi-bin%2Fh5%2Flite%2Fcirclecenter%2Findex.html%3Fwechat_pkgid%3Dlite_circlecenter%26liteapp%3Dliteapp%253A%252F%252Fwxalited17d79803d8c228a7eac78129f40484c%253Fpath%253Dpages%25252Findex%25252Findex%26appid%3Dwx46ed1d4c1d7f9c01%26tab_id%3D7%26ssid%3D46%23wechat_redirect#wechat_redirect"
OperationUtil.QQWelfareUrl = "https://pd.qq.com/g/593787374034744164?mode=1&utm_source=ingame"
OperationUtil.QQPinDaoUrl = "https://pd.qq.com/publish?mode=1&utm_source=ingame&guildId=593787374034744164&subc=673555450&type=pic"

OperationUtil.GameCenterUrl = "https://static.gamecenter.qq.com/xgame/gc-assets/pages/game-detail/index.html?page_name=QQGameCenterShell&open_kuikly_info=%7B%22url%22%3A%22%3FFFROMSCHEMA%3D%26detail_appid%3D1111319132%26adtag%3Dtest%22%2C%22page_name%22%3A%22QQGameCenterShell%22%2C%22bundle_name%22%3A%22gamecenter_shell%22%2C%22ssr_page_name%22%3A%22QQGameCenterRootPage%22%2C%22ssr_bundle_name%22%3A%22gamecenter%22%7D"

OperationUtil.ShareQRCodePath = {
	Oversea = "Texture2D'/Game/UI/Atlas/Share/Frames/Ul_Share_lcon_QRCode_OS_png.Ul_Share_lcon_QRCode_OS_png'",
	WeChat = "Texture2D'/Game/UI/Atlas/Share/Frames/Ul_Share_lcon_QRCode_WX_png.Ul_Share_lcon_QRCode_WX_png'",
	QQ = "Texture2D'/Game/UI/Atlas/Share/Frames/Ul_Share_lcon_QRCode_QQ_png.Ul_Share_lcon_QRCode_QQ_png'"
}

function OperationUtil.OpenFeedback()
	local NewUrl = string.format("%s&openid=%s", OperationUtil.FeedbackUrl, _G.LoginMgr:GetOpenID())
    _G.UE.UAccountMgr.Get():OpenMURSurvey(NewUrl, "", 1, false, true, "", false, false)
end

function OperationUtil.OpenMURSurvey(Url, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
	local PlatfromStr = ""
	if CommonUtil.IsIOSPlatform() then
		PlatfromStr = "&sPlatId=0"
	elseif CommonUtil.IsAndroidPlatform() then
		PlatfromStr = "&sPlatId=1"
	end
	local ChannelStr = "&sArea=".._G.LoginMgr:GetChannelID()
	local MajorRoleID = "&sRoleId="..MajorUtil.GetMajorRoleID()
	local AMSParams = PlatfromStr..ChannelStr..MajorRoleID
	_G.UE.UAccountMgr.Get():OpenMURSurvey(Url, AMSParams, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
end

function OperationUtil.IsEnableCustomService()
	local Cfg = OperationUtil.GetOperationChannelFuncConfig()
	if nil ~= Cfg and nil ~= Cfg.IsEnableCustomerServiceAll and Cfg.IsEnableCustomerServiceAll == 0 then
		return false
	end
	return true
end

function OperationUtil.OpenCustomService(SceneID)
	if not string.isnilorempty(OperationUtil.CustomServiceUrl) then
		local IsInstalledQQ = AccountUtil.IsQQInstalled() and 1 or 0
		local IsInstalledWeChat = AccountUtil.IsWeChatInstalled() and 1 or 0
		local PlatID = -1
		local PlatformName = CommonUtil.GetPlatformName()
		if PlatformName == "Android" then
			PlatID = 1
		elseif PlatformName == "IOS" then
			PlatID = 0
		end
		local AppID = ""
		if _G.LoginMgr:IsQQLogin() then
			AppID = MSDKDefine.Config.QQAPPID
		elseif _G.LoginMgr:IsWeChatLogin() then
			AppID = MSDKDefine.Config.WechatAppID
		end
		local OpenID = _G.LoginMgr:GetOpenID() or 0
		local ZoneID = _G.LoginMgr:GetWorldID() or 0
		local ZoneName = ""
		local RoleName = ""
		local RoleID = _G.LoginMgr:GetRoleID() or 0
		local AttributeComponent = MajorUtil.GetMajorAttributeComponent()
		if nil ~= AttributeComponent then
			RoleName = AttributeComponent.ActorName
		end
		RoleName = CommonUtil.GetUrlEncodeStr(RoleName)
		local NewUrl = string.format("%s&qi=%d&wi=%d&platid=%d&z=%d&zn=%s&role=%s&roleid=%d&openid=%s&appid=%s",
		OperationUtil.CustomServiceUrl..SceneID, IsInstalledQQ, IsInstalledWeChat, PlatID, ZoneID, ZoneName, RoleName, RoleID, tostring(OpenID), AppID)
		--local ExtraJson = "{\"isEmbedWebView\":true}"
		local ExtraJson = ""
		_G.FLOG_INFO("OperationUtil.OpenCustomService, NewUrl:%s", NewUrl)
		_G.UE.UAccountMgr.Get():OpenUrl(NewUrl, 1, false, true, ExtraJson, false)
	end
end

function OperationUtil.GetXinYuePanelUrl(OriginUrl)
	local GID = "1491"
	local PID = "174"
	local Secret = "Bui1tin#t@Clu8"
	local Platform = CommonUtil.GetPlatformName()
	local PlatformType = ""
	if Platform == "Android" then
		PlatformType = "1"
	elseif Platform == "IOS" then
		PlatformType = "0"
	end
	local WorldID = tostring(_G.LoginMgr:GetWorldID())
	local AppID = ""
	local AccountType = ""
	local AreaID = WorldID
	if _G.LoginMgr:IsWeChatLogin() then
		AccountType = "2"
		AppID = MSDKDefine.Config.WechatAppID
		if CommonUtil.IsShipping() then
			AreaID = "1"
		end
	end
	if _G.LoginMgr:IsQQLogin() then
		AccountType = "1"
		AppID = MSDKDefine.Config.QQAPPID
		if CommonUtil.IsShipping() then
			AreaID = "2"
		end
	end

	-- 1. 约定的参数构造为json串
	local Params = {
		gid = GID,										-- 心悦游戏id
		pid = PID,										-- 内置面板id
		reg = "1",										-- 大区服（1:正式服；2:抢先服；3:体验服、测试服）
		plat = PlatformType,							-- 平台id（0: 表示iOS；1: 表示android）
		ch = AccountType,								-- 账号类型（1:表示qq；2:表示wx）
		area = AreaID,									-- 大区id
		part = WorldID,									-- 小区id
		openid = tostring(_G.LoginMgr:GetOpenID()),
		appid = AppID,
		role = tostring(_G.LoginMgr:GetRoleID()),
		msdkt = _G.LoginMgr:GetToken(),					-- 手Q登录返回的skey或者微信登录返回的access token
		t = tostring(os.time()),
		r = tostring(math.random(1000, 10000)),
		ava = _G.LoginMgr:GetAvatarUrl(),
		nick = _G.LoginMgr:GetNickName(),
		channelid = tostring(_G.LoginMgr:GetInstallChannel()),
		vt = "0"										-- 内置面板是否横竖版展示（0横版，1竖版）默认是横版
	}
	_G.FLOG_INFO("OperationUtil.GetXinYuePanelUrl, Params:%s", table_to_string(Params))
	local JsonParams = Json.encode(Params)
	-- 2. base64编码上面的json串
	local Base64Str = CommonUtil.GetBase64String(JsonParams)
	-- 3. 将上面base64串中+替换为-,  /替换为_, 去掉=
	Base64Str = string.gsub(Base64Str, "+", "-")
	Base64Str = string.gsub(Base64Str, "/", "_")
	Base64Str = string.gsub(Base64Str, "=", "")
	-- 4. 将约定密钥（由心悦提供）拼接在上面base64字符串后面再做md5得到32位消息摘要
	local MD5Str = CommonUtil.GetMD5String(Base64Str..Secret)
	-- 5. 从第9位开始（包含第9位）到24位（包含24位），截取上面md5字符串中间16位字符串得到签名码
	local SignStr = string.sub(MD5Str, 9, 24)
	-- 6. 将签名码附加到上面的base64串后面得到code
	local Code = Base64Str..SignStr
	--local XinYuePannelUrl = string.format("https://api.xinyue.qq.com/builtin/dispatch?code=%s&gid=%s&pid=%s", Code, GID, PID)
	local XinYuePannelUrl = string.format("%scode=%s&gid=%s&pid=%s", OriginUrl, Code, GID, PID)
	_G.FLOG_INFO("OperationUtil.GetXinYuePanelUrl, Url:%s", XinYuePannelUrl)
	return XinYuePannelUrl
end

function OperationUtil.GetGameBotOpenArgs(Question)
	local Platform = CommonUtil.GetPlatformName()
	local PlatformType = -1
	if Platform == "Android" then
		PlatformType = 1
	elseif Platform == "IOS" then
		PlatformType = 0
	end

	local AppID = ""
	local AccountType = ""
	if _G.LoginMgr:IsWeChatLogin() then
		AppID = MSDKDefine.Config.WechatAppID
		AccountType = 2
	end
	if _G.LoginMgr:IsQQLogin() then
		AppID = MSDKDefine.Config.QQAPPID
		AccountType = 1
	end
	-- 1. 约定的参数构造为json串
	local Params = {
		itopGameId = "27887",									-- 游戏的MSDK GameId
		itopSigKey = "ef4834d149cef0cac9cd0de4119d96c3",		-- 游戏的MSDK sig key
		itopOpenId = tostring(_G.LoginMgr:GetOpenID()),		-- 当前用户的OpenId
		itopToken = _G.LoginMgr:GetToken(),						-- 手Q登录返回的skey或者微信登录返回的access token
		itopChannelId = _G.LoginMgr:GetChannelID(),				-- 当前用户的ChannelId
		gameId = "21225",										-- 游戏的知几ID
		--gameId = "20004",										-- 测试游戏的知几ID
		appId = AppID,
		systemId = AccountType,									-- 游戏系统(1: QQ, 2: WeChat), 端游为1
		platId = PlatformType,									-- 游戏平台id(0: iOS, 1: Android, 2: pc)
		areaId = _G.LoginMgr:GetWorldID(),						-- 大区id
		partitionId = "0",										-- 小区id
		roleId = tostring(_G.LoginMgr:GetRoleID()),			-- 角色id
		gameCode = "ff14",										-- 可以在 AMS 查询
		headerUrlStr = _G.LoginMgr:GetAvatarUrl(),				-- 用户头像 URL
		question = Question,									-- 首次进入知几带的问题, 用于打开知几的同时触发提问 ，一般用在场景化入口
		scene = "",												-- 场景编码, "0"或不填代表知几主界面场景，其余视游戏情况代表不同场景，比如玲珑朋友圈、MDNF变强等
		voiceType = "",											-- 用于设置TTS语音播报角色
		oriented = "",											-- 用于设置横屏或者竖屏时加载不同的样式布局。注意：只有横竖屏切换的游戏才需要传入该参数。
		isLandscape = 1,										-- 1为横屏，0为竖屏，默认为横屏
		newActivity = 0,										-- 1为在新页面加载知几，0为在原游戏页面加载，默认为新页面加载知几
		--ext = "",												-- 可选，根据游戏定制化需求填入不同用户画像参数，如：{ "genre": "xxx", "seasonlevel": 100 }
		msdkEnv = 0												-- 用于标识MSDK环境： 0/不填写：正式环境 1:测试环境
	}

	local CurRoleName = ""
	local AttributeComponent = MajorUtil.GetMajorAttributeComponent()
	if nil ~= AttributeComponent then
		CurRoleName = AttributeComponent.ActorName
	end
	local MajorProfID = MajorUtil.GetMajorProfID()
	local CurMajorProfName = RoleInitCfg:FindRoleInitProfName(MajorProfID)
	local CurMajorLevel = MajorUtil.GetMajorLevel()	--主角当前职业等级
	Params.ext = { RoleName = CurRoleName, MajorProfName = CurMajorProfName,  MajorLevel = CurMajorLevel }

	local JsonParams = Json.encode(Params)
	_G.FLOG_INFO("OperationUtil.GetGameBotOpenArgs, JsonParams:%s", JsonParams)
	return JsonParams
end

function OperationUtil.OpenGameBot(Question)
	local OpenArgs = OperationUtil.GetGameBotOpenArgs(Question)
	_G.UE.UGameBotMgr.Get():OpenPage(OpenArgs)
end

OperationUtil.GameBotRedDotType = {
	Main2ndPanel = 1,
	FriendListPanel = 2
}

function OperationUtil.ShowGameBotRedDot(IsShow, RedDotIndex)
	local RedDotID = OperationUtil.GameBotRedDotID
	if IsShow then
		--_G.RedDotMgr:AddRedDotByID(OperationUtil.SocialRedDotID)
		_G.RedDotMgr:AddRedDotByID(RedDotID)
	else
		--_G.RedDotMgr:DelRedDotByID(OperationUtil.SocialRedDotID)
		_G.RedDotMgr:DelRedDotByID(RedDotID)
		_G.MainPanelMgr:OnCancelGameBotRedDot(RedDotIndex)
	end
end


function OperationUtil.GetOperationMenuItems()
	if not OperationUtil.HasInitOperationMenuItems then
		OperationUtil.OperationMenuItems = {}
		local MenuItemsCfg = OperationMenuItemsCfg:FindAllCfg()
		local MoreMenuType = Main2ndPanelDefine.MoreMenuType
		local RowNum = 0
		local OperationMenuSubList = {}

		local Cfg = OperationUtil.GetOperationChannelFuncConfig()

		for _, Info in ipairs(MenuItemsCfg) do
			local IsEnabledEntrance = true
			if nil ~= Cfg then
				if (Info.BtnEntranceID == MoreMenuType.Questionnaire and Cfg.IsEnableQuestionareEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.GiftCenter and Cfg.IsEnableGiftPackCenterEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.GameCenter and Cfg.IsEnableGameCenterEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.XinYue and Cfg.IsEnableXinYueEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.GameCircle and Cfg.IsEnableGameCircleEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.FreeFlow and Cfg.IsEnableFreeFlowEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.GrowthGuardian and Cfg.IsEnableGrowthGurdianEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.CustomService and Cfg.IsEnableCustomServiceEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.InviteQQFriends and Cfg.IsEnableInviteQQEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.InviteWXFriends and Cfg.IsEnableInviteWeChatEntrance == 0) or
					(Info.BtnEntranceID == MoreMenuType.InviteWXMoments and Cfg.IsEnableInviteMomentsEntrance == 0) then
					--_G.FLOG_INFO("[OperationUtil.GetOperationMenuItems] BtnEntranceID:%d is disabled by config", Info.BtnEntranceID)
					IsEnabledEntrance = false
				end
			end

			if IsEnabledEntrance then
				if (_G.LoginMgr:IsWeChatLogin() and Info.IsShowForWeChat == 1) or
					(_G.LoginMgr:IsQQLogin() and Info.IsShowForQQ == 1) then
					local Item = {}
					Item.ID = Info.ID
					Item.ChannelID = Info.ChannelID
					Item.Icon = Info.Icon
					Item.BtnName = Info.BtnName
					Item.BtnEntranceID = Info.BtnEntranceID
					Item.IsNeedShowRedDot = Info.IsNeedShowRedDot == 1 and true or false
					Item.OpenType = Info.OpenType
					Item.Url = Info.Url
					if Item.BtnEntranceID ~= MoreMenuType.Questionnaire or _G.MURSurveyMgr:IsNeedShowQuestionnaire() then
						--_G.FLOG_INFO("[OperationUtil.GetOperationMenuItems] BtnName:%s, ID:%d, Channel:%d", Info.BtnName, Info.ID, Info.ChannelID)
						table.insert(OperationMenuSubList, Item)
						RowNum = RowNum + 1
						if RowNum >= 4 then
							table.insert(OperationUtil.OperationMenuItems, OperationMenuSubList)
							RowNum = 0
							OperationMenuSubList = {}
						end
					end
				end
			end
		end

		if RowNum > 0 then
			table.insert(OperationUtil.OperationMenuItems, OperationMenuSubList)
		end
	end

	OperationUtil.HasInitOperationMenuItems = true

	return OperationUtil.OperationMenuItems
end

function OperationUtil.GetFreeFlowInfoRequestData()
	local RequestData = {}
	RequestData.systemParameter = {}
	RequestData.systemParameter.coopId = ""														-- 合作方标识，通讯侧分配
	RequestData.systemParameter.version = "1.0.1"
	local RequestTime = os.time()
	RequestData.systemParameter.seqId = tostring(RequestTime)								-- 消息序列号，每次请求唯一
	RequestData.systemParameter.time = os.date("%Y-%m-%d %H:%M:%S", RequestTime)	 -- 请求发起时间，如：2023-01-01 00:00:00，有效期为5分钟，被调方需进行校验。该值每次请求时需重新生成。
	RequestData.systemParameter.signType = "GM_SM3_HMAC"
	RequestData.systemParameter.signSerial = "1"												-- 报文签名密钥版本号 初始值填1，换密钥时分配新值
	RequestData.systemParameter.sign = OperationUtil.GetFreeFlowInfoSign()
	--以下为可选字段
	--RequestData.systemParameter.secretType = "GM_SM4_GCM"
	--RequestData.systemParameter.secretSerial = ""

	RequestData.businessParameter = {}
	RequestData.businessParameter.appId = ""												-- 应用APP标识，由联通王卡团队分配
	RequestData.businessParameter.privateIpV4 = DataReportUtil.IPV4Address					-- 用户私网IPV4
	RequestData.businessParameter.privateIpV6 = _G.UE.UPlatformUtil.GetIPAddress(false)		-- 用户私网IPV6
	--以下为可选字段
	--RequestData.businessParameter.publicIp = ""		-- 用户的公网IP
	--RequestData.businessParameter.imsi = ""			-- sim卡标识
	--RequestData.businessParameter.mobile = ""			-- 用户号码
	--RequestData.businessParameter.vendor = ""			-- 用户当前使用的蜂窝网络所属运营商：unicom：联通 gmcc：移动 cdma：电信 other：其他
	--RequestData.businessParameter.scenes = ""			-- 请求场景：app_init：应用初始化 change_simcard：用户切换sim卡 change_net：用户网络切换
	return RequestData
end

function OperationUtil.GetFreeFlowInfo()
	local RequestJsonData = Json.encode(OperationUtil.GetFreeFlowInfoRequestData())
	if _G.HttpMgr:Post(OperationUtil.FreeFlowInfoUrl, "", RequestJsonData, OperationUtil.GetFreeFlowInfoCallback, OperationUtil) then
        _G.FLOG_INFO("OperationUtil.GetFreeFlowInfo, send request success!")
    end
end

function OperationUtil.GetFreeFlowInfoSign()
	local RequestParams = OperationUtil.GetFreeFlowInfoRequestData()
	local SignSrc = string.format("businessParameter=appId=%s&privateIpV4=%s&privateIpV6=%s&systemParameter=coopId=%s&version=%s&seqId=%s&time=%s&signType=%s&signSerial=%s",
		RequestParams.businessParameter.appId,
		RequestParams.businessParameter.privateIpV4,
		RequestParams.businessParameter.privateIpV6,
		RequestParams.systemParameter.coopId,
		RequestParams.systemParameter.version,
		RequestParams.systemParameter.seqId,
		RequestParams.systemParameter.time,
		RequestParams.systemParameter.signType,
		RequestParams.systemParameter.signSerial)
	local SignStr = _G.UE.UOperationUtil.GetSM3HMACString(SignSrc, OperationUtil.FreeFlowSignKey)
	_G.FLOG_INFO("OperationUtil.GetFreeFlowInfoSign, SignSrc:%s, SignStr:%s", SignSrc, SignStr)
	return SignStr
end

function OperationUtil.GetFreeFlowInfoCallback(MsgBody, Result)
    _G.FLOG_INFO("OperationUtil.GetFreeFlowInfoCallback, result: %s", tostring(Result))
end

function OperationUtil.BindDevice()
	local MapData = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	MapData:Add("openid", tostring(_G.LoginMgr:GetOpenID()));
	MapData:Add("roleid", tostring(_G.LoginMgr:GetRoleID()));
	MapData:Add("areaid", tostring(_G.LoginMgr:GetWorldID()));

	local AppID = ""
	local AccountType = ""
	if _G.LoginMgr:IsWeChatLogin() then
		AccountType = "Wechat"
		AppID = MSDKDefine.Config.WechatAppID
	end
	if _G.LoginMgr:IsQQLogin() then
		AccountType = "QQ"
		AppID = MSDKDefine.Config.QQAPPID
	end

	MapData:Add("appid", AppID);
	MapData:Add("platid", AccountType);
	MapData:Add("mainversion", _G.UE.UVersionMgr.GetAppVersion());
	MapData:Add("subversion", _G.UE.UVersionMgr.GetResourceVersion());
	MapData:Add("gopenid", tostring(_G.LoginMgr:GetOpenID()));
	_G.UE.UGPMMgr.Get():UpdateGameInfoWithMapData("DeviceBind", MapData);
end

function OperationUtil.InitTDM(ChannelID, UserOpenId)
	--_G.FLOG_INFO("OperationUtil.InitTDM, ChannelID:%s, UserOpenId:%s", ChannelID, UserOpenId)
	_G.UE.UTDMMgr.Get():SetReportCheckCount(3)
	--_G.UE.UTDMMgr.Get():SetEnableLog(true)
	--_G.UE.UTDMMgr.Get():EnableDeviceInfo(true)
	_G.UE.UTDMMgr.Get():EnableReport(true)
	_G.UE.UTDMMgr.Get():SetUserInfo(ChannelID, UserOpenId)
end

function OperationUtil.ReportASAAdInfo()
	_G.UE.UTDMMgr.Get():ReportASAEvent()
end

function OperationUtil.OpenPlatformWelfare()
	_G.FLOG_INFO("OperationUtil.OpenPlatformWelfare")
	if _G.LoginMgr:IsWeChatLogin() then
		_G.AccountUtil.OpenUrl(OperationUtil.WeChatWelfareUrl, 1, false, true, "", false)
	elseif _G.LoginMgr:IsQQLogin() then
		local Platform = CommonUtil.GetPlatformName()
		local PlatID = ""
		if Platform == "Android" then
			PlatID = "1"
		elseif Platform == "IOS" then
			PlatID = "0"
		end
		local ViewportSize = UIUtil.GetViewportSize()
		local OpenUrl = string.format("%s&platid=%s&timestamp=%d&width=%f&height=%f",
			OperationUtil.QQWelfareUrl, PlatID, TimeUtil.GetServerTimeMS(), ViewportSize.X, ViewportSize.Y)
		local ExtraJson = {}
		ExtraJson.WEBVIEW_LANDSCAPE_BAR_HIDEABLE = true
		ExtraJson.closeLoadingView = true
		local ExtraJsonStr = Json.encode(ExtraJson)
		_G.FLOG_INFO("OperationUtil.OpenPlatformWelfare, OpenUrl:%s, ExtraJsonStr:%s", OpenUrl, ExtraJsonStr)
		_G.AccountUtil.OpenUrl(OpenUrl, 3, true, true, ExtraJsonStr, false)
	end
end

function OperationUtil.GetOperationChannelFuncConfig()
	local InstallChannelID = _G.LoginMgr:GetInstallChannel()
	local Config = OperationChannelFunctionCfg:FindCfgByKey(InstallChannelID)

	if nil == Config then
		_G.FLOG_WARNING("OperationUtil.GetOperationChannelFuncConfig, no config found for InstallChannelID:%d", InstallChannelID)
	end
	return Config
end

return OperationUtil
