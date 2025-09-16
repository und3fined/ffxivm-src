local MSDKDefine = {

}

MSDKDefine.Config = {
	WechatAppID = "wx46ed1d4c1d7f9c01",
	QQAPPID = "1111319132",
	APPName = "FMGame",
}

MSDKDefine.MethodName = {
	AutoLogin = 111,
	Logout = 117,
	WakeUp = 119,

	kMethodNameRealName = 138,

	ShareToWall = 211,
	SendMessageToFriend = 212,
    QueryFriend = 213,

	kMethodNameCreateGroup              = 311,
	kMethodNameBindGroup                = 312,
	kMethodNameGetGroupList             = 313,
	kMethodNameGetGroupState            = 314,
	kMethodNameJoinGroup                = 315,
	kMethodNameUnbindGroup              = 316,
	kMethodNameRemindToBindGroup        = 317,
	kMethodNameSendMessageToGroup       = 318,
	kMethodNameGetGroupRelation         = 319,

	kMethodNameCloseWebViewURL          = 411,
	kMethodNameGetEncodeURL             = 412,
	kMethodNameWebViewJsCall            = 413,
	kMethodNameWebViewJsShare           = 414,
	kMethodNameWebViewJsSendMessage     = 415,
	kMethodNameWebViewEmbedProgress     = 416,
	kMethodNameWebViewOpenURL           = 417,

	kMethodNameAccountVerifyCode        	= 1311,
	kMethodNameAccountResetPassword     	= 1312,
	kMethodNameAccountModify            	= 1313,
	kMethodNameAccountLoginWithCode     	= 1314,
	kMethodNameAccountGetRegisterStatus		= 1315,
	kMethodNameAccountGetVerifyCodeStatus	= 1316,
	kMethodNameAccountGetReceiveEmail   	= 1317,
	kMethodNameAccountVerifyPassword    	= 1318,
}

MSDKDefine.MSDKError = {
	UNKNOWN = -1;
	SUCCESS = 0;
	NO_ASSIGN = 1; -- 没有赋值
	CANCEL = 2;
	SYSTEM_ERROR = 3;
	NETWORK_ERROR = 4;
	MSDK_SERVER_ERROR = 5; -- MSDK 后台返回错误，参考第三方错误码
	TIMEOUT = 6;
	NOT_SUPPORT = 7;
	OPERATION_SYSTEM_ERROR = 8;
	NEED_PLUGIN = 9;
	NEED_LOGIN = 10;
	INVALID_ARGUMENT = 11;
	NEED_SYSTEM_PERMISSION = 12;
	NEED_CONFIG = 13;
	SERVICE_REFUSE = 14;
	NEED_INSTALL_APP = 15;
	APP_NEED_UPGRADE = 16;
	INITIALIZE_FAILED = 17;
	EMPTY_CHANNEL = 18;
	FUNCTION_DISABLE = 19;
	NEED_REALNAME = 20; -- 需实名认证
	REALNAME_FAIL = 21; -- 实名认证失败
	IN_PROGRESS = 22; -- 上次操作尚未完成，稍后再试
	API_DEPRECATED = 23;
	LIBCURL_ERROR = 24;
	FREQUENCY_LIMIT = 25; --频率限制
	DINED_BY_APP = 26; -- 被三方拒绝，需要查看具体的错误
	QRCODE_TIMEOUT = 27; --二维码超时

	-- 1000 ~ 1099 字段是 LOGIN 模块相关的错误码
	LOGIN_UNKNOWN_ERROR = 1000;
	LOGIN_NO_CACHED_DATA = 1001; -- 本地没有登录缓存数据
	LOGIN_CACHED_DATA_EXPIRED = 1002; --本地有缓存，但是该缓存已经失效
	LOGIN_KEY_STORE_VERIFY_ERROR = 1004;
	LOGIN_NEED_USER_DATA = 1005;
	LOGIN_CODE_FOR_CONNECT = 1006;

	LOGIN_NEED_USER_DATA_SERVER = 1010;
	LOGIN_URL_USER_LOGIN = 1011; -- 异账号：使用URL登陆成功
	LOGIN_NEED_LOGIN = 1012;	-- 异账号：需要进入登陆页
	LOGIN_NEED_SELECT_ACCOUNT = 1013; -- 异账号：需要弹出异帐号提示
	LOGIN_ACCOUNT_REFRESH = 1014; -- 异账号：通过URL将票据刷新

	CONNECT_NO_CACHED_DATA = 1021; -- 本地没有关联渠道登录缓存数据
	CONNECT_CACHED_DATA_EXPIRED = 1022; --本地有缓存，但是该缓存已经失效
	CONNECT_NO_MATCH_MAIN_OPENID = 1023; --关联账号与主账号不一致

	--1100 ~ 1199 字段是 FRIEND 模块相关的错误码
	FRIEND_UNKNOWN_ERROR = 1100;

	--1200 ~ 1299 字段是 GROUP 模块相关的错误码
	GROUP_UNKNOWN_ERROR = 1200;

	--1300 ~ 1399 字段是 NOTICE 模块相关的错误码
	NOTICE_UNKNOWN_ERROR = 1300;

	--1400 ~ 1499 字段是 Push 模块相关的错误码
	PUSH_RECEIVER_TEXT = 1400; -- 收到推送消息
	PUSH_NOTIFICATION_CLICK = 1401;		-- 在通知栏点击收到的消息
	PUSH_NOTIFICATION_SHOW = 1402;		-- 收到通知之后，通知栏显示

	--1500 ~ 1599 字段是 WEBVIEW 模块相关的错误码
	WEBVIEW_UNKNOWN_ERROR = 1500;

	THIRD_ERROR = 9999;-- 第三方错误情况，参考第三方错误码

	--1600 ~ 1699 字段是 Account 模块相关的错误码
	INVALID_PASSWORD = 1600;
}

MSDKDefine.ThirdCode = {
	INVALID_VERIFY_CODE = 2114;  -- 邮箱登录-验证码错误

	-- 微信群组功能返回码
	-- https://docs.msdk.qq.com/v5/zh-CN/FAQS/ac41cc974f20cb93cedc5e6641a7128b/ef42aaca7d88b317ee14fb21ed30c74d.html
	WX_CREATE_GROUP_LIMIT_DAILY = -10008;	-- 用户达到每天建群上限
}

MSDKDefine.Channel = {
	WeChat = "WeChat",
	QQ = "QQ",
	Guest = "Guest",
	Email = "Email",
	Facebook = "Facebook",
	GameCenter = "GameCenter",
	Apple = "Apple",
	Google = "Google",
	Twitter = "Twitter",
	Line = "Line",
	Self = "Self",		-- 自建账号
	Garena = "Garena",
	HMS = "HMS",
}

MSDKDefine.ChannelID = {
	WeChat = 1,
	QQ = 2,
	Guest = 3,
	Email = 4,		-- 自建账号
	Facebook = 4,
	GameCenter = 5,
	Google = 6,
	Twitter = 9,
	Garena = 10,
	Line = 14,
	Apple = 15,
	HMS = 23,
}

MSDKDefine.LoginPermissions = {
	WeChat = {
		UserInfo = "snsapi_userinfo",		-- 获取用户资料（MSDK 默认权限）
		FriendList = "snsapi_friend",		-- 获取好友列表
		-- SendMessage = "snsapi_message", --发送消息。V5.25 版本开始已废弃
	},
	QQ = {
		All = "all",							-- 所有权限
		UserInfo = "get_user_info",				-- 获取用户信息
		AppFriend = "get_app_friends",			-- 获取 QQ 好友关系
		SimpleUserInfo = "get_simple_userinfo",	-- 获取 QQ 基本信息
		VIPInfo = "get_vip_info",				-- 获取你的 VIP 信息
		VIPRichInfo = "get_vip_rich_info",		-- 获取 QQ 会员详细信息
		FriendsInfo = "get_friends_info",		-- 获取 QQ 同玩陌生好友列表
		AddShare = "add_share",					-- 发表分享到 QQ 空间
	},
	Facebook = {
		"public_profile",
		"email",
	},
	FacebookGaming = {
		"gaming_profile",
		"gaming_user_picture",
	},
	Apple = {
		"fullName",
		"email",
	},
	Line = {
		"profile",
		"openid",
	},
}

MSDKDefine.ClassMembers = {
	BaseRet = {
		MethodNameID = "MethodNameID",
		RetCode = "RetCode",
		RetMsg = "RetMsg",
		ThirdCode = "ThirdCode",
		ThirdMsg = "ThirdMsg",
		ExtraJson = "ExtraJson",
	},
	LoginRetData = {
		-- Begin BaseRet
		MethodNameID = "MethodNameID",
		RetCode = "RetCode",
		RetMsg = "RetMsg",
		ThirdCode = "ThirdCode",
		ThirdMsg = "ThirdMsg",
		ExtraJson = "ExtraJson",
		-- End BaseRet
		MethodNameID = "MethodNameID",
		RetCode = "RetCode",
		RetMsg = "RetMsg",
		ThirdCode = "ThirdCode",
		ThirdMsg = "ThirdMsg",
		ExtraJson = "ExtraJson",
		OpenID = "OpenID",
		Token = "Token",
		TokenExpire = "TokenExpire",
		FirstLogin = "FirstLogin",
		RegChannelDis = "RegChannelDis",
		UserName = "UserName",
		Gender = "Gender",
		Birthdate = "Birthdate",
		PictureUrl = "PictureUrl",
		PF = "PF",
		PFKey = "PFKey",
		RealNameAuth = "RealNameAuth",
		ChannelID = "ChannelID",
		Channel = "Channel",
		ChannelInfo = "ChannelInfo",
	},
	PersonInfo = {
		Gender = "Gender",
		Openid = "Openid",
		UserName = "UserName",
		PictureUrl = "PictureUrl",
		Country = "Country",
		Province = "Province",
		City = "City",
		Language = "Language",
	},
	FriendData = {
		-- Begin BaseRet
		MethodNameID = "MethodNameID",
		RetCode = "RetCode",
		RetMsg = "RetMsg",
		ThirdCode = "ThirdCode",
		ThirdMsg = "ThirdMsg",
		ExtraJson = "ExtraJson",
		-- End BaseRet
		FriendInfoList = "FriendInfoList",
	},
	FriendReqInfo = {
		-- Begin BaseRet
		MethodNameID = "MethodNameID",
		RetCode = "RetCode",
		RetMsg = "RetMsg",
		ThirdCode = "ThirdCode",
		ThirdMsg = "ThirdMsg",
		ExtraJson = "ExtraJson",
		-- End BaseRet
		Type = "Type",
		User = "User",
		Title = "Title",
		Desc = "Desc",
		ImagePath = "ImagePath",
		ThumbPath = "ThumbPath",
		MediaPath = "MediaPath",
		Link = "Link",
		ExtraJson = "ExtraJson",
	},
	WebViewRet = {
		-- Begin BaseRet
		MethodNameID = "MethodNameID",
		RetCode = "RetCode",
		RetMsg = "RetMsg",
		ThirdCode = "ThirdCode",
		ThirdMsg = "ThirdMsg",
		ExtraJson = "ExtraJson",
		-- End BaseRet
		EmbedProgress = "EmbedProgress",
		MsgType = "MsgType",
		MsgJsonData = "MsgJsonData",
		EmbedUrl = "EmbedUrl",
	},
}

MSDKDefine.MapleStructMembers = {
	TDirRoleInfo = {
		OpenId = "OpenId",
		TreeId = "TreeId",
		LeafId = "LeafId",
		LastLoginTime = "LastLoginTime",
		RoleId = "RoleId",
		RoleLevel = "RoleLevel",
		RoleName = "RoleName",
		UserData = "UserData",
	},
	TDirRoleCollection = {
		RoleInfos = "RoleInfos",
	},
	TDirCustomData = {
		Attr1 = "Attr1",
		Attr2 = "Attr2",
		UserData = "UserData",
	},
	TreeNodeBase = {
		Id = "Id",
		ParentId = "ParentId",
		Name = "Name",
		Tag = "Tag",
		CustomData = "CustomData",
	},
	LeafNode = {
		Flag = "Flag",
		Url = "Url",
		RoleCollection = "RoleCollection",
	},
	NodeWrapper = {
		Type = "Type",
		Category = "Category",
		Leaf = "Leaf",
	},
	TreeInfo = {
		ErrorCode = "ErrorCode",
		NodeList = "NodeList",
	},
}

---@class EmailExtraJson
---@field type string 类型: register注册; login账密登录; loginWithCode验证码登录
---@field account string 账号
---@field password string 密码
---@field verifyCode string 验证码
---@field accountType number 账号类型：1-邮箱，2-手机号
---@field langType string 语言类型，指定发送消息的语言
---@field areaCode string 区号，如果输入的手机号，区号为必填，若输入的是邮箱，则区号可不填
---@field extraJson string 扩展字段

return MSDKDefine