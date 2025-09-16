--[[
Date: 2023-03-02 20:47:13
LastEditors: moody
LastEditTime: 2023-03-02 20:47:13
--]]
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local MSDKDefine = require("Define/MSDKDefine")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require ("Utils/MajorUtil")

local MemFriendReqInfo = MSDKDefine.ClassMembers.FriendReqInfo
local MSDKFriendReqType = _G.UE.MSDKFriendReqType
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR

local AccountUtil = {}

AccountUtil.JsonUtil = {
	ToItem = function(Key, Value, bMatchStr)
		if Value == nil then
			return nil
		end
		local KeyStr = string.format("\"%s\"", Key)
		local ValueStr = tostring(Value)
		if type(Value) == "string" and bMatchStr then
			ValueStr = string.format("\"%s\"", ValueStr)
		end

		return string.format("%s:%s", KeyStr, ValueStr)
	end,
	AddItem = function(Table, Key, Value)
		local Item = AccountUtil.JsonUtil.ToItem(Key, Value, true)
		if nil ~= Item then
			table.insert(Table, Item)
		end
	end,
	AddJson = function(Table, Key, Value)
		local Item = AccountUtil.JsonUtil.ToItem(Key, Value, false)
		if nil ~= Item then
			table.insert(Table, Item)
		end
	end,
	ToJson = function(Table)
		local JsonStr = string.format("{%s}", table.concat(Table, ", "))
		print(JsonStr)
		return JsonStr
	end
}

function AccountUtil.HandleMSDKInitNotify(BaseRet)
	FLOG_INFO("[AccountUtil.HandleMSDKInitNotify] ")
	if BaseRet and BaseRet.RetCode then
		FLOG_INFO("[AccountUtil.HandleMSDKInitNotify] RetCode：%d", BaseRet.RetCode)
	end
	EventMgr:SendEvent(EventID.MSDKInitNotify, BaseRet)
end

function AccountUtil.HandleLoginRetNotify(LoginRet)
	print("[AccountUtil.HandleLoginRetNotify] ", LoginRet.Token)
	EventMgr:SendEvent(EventID.MSDKLoginRetNotify, LoginRet)
end

function AccountUtil.HandleBaseRetNotify(BaseRet)
	EventMgr:SendEvent(EventID.MSDKBaseRetNotify, BaseRet)
end

function AccountUtil.HandleDeliverMessageNotify(BaseRet)
	EventMgr:SendEvent(EventID.MSDKDeliverMessageNotify, BaseRet)
end

function AccountUtil.HandleQueryFriendNotify(FriendRet)
	EventMgr:SendEvent(EventID.MSDKQueryFriendNotify, FriendRet)
end

function AccountUtil.HandleWebViewOptNotify(WebViewRet)
	EventMgr:SendEvent(EventID.MSDKWebViewOptNotify, WebViewRet)
end

function AccountUtil.HandleAlbumPhotoSelected(Base64Str)
	EventMgr:SendEvent(EventID.AlbumPhotoSelectedNotify, Base64Str)
end

function AccountUtil.HandleTakePhoto(Path, Angle, RetCode)
	EventMgr:SendEvent(EventID.TakePhoto, Path, Angle, RetCode)
end

function AccountUtil.HandleMapleNotify(TreeInfo)
	EventMgr:SendEvent(EventID.MapleNotify, TreeInfo)
end

function AccountUtil.HandleCustomAccountNotify(AccountRet)
	EventMgr:SendEvent(EventID.MSDKCustomAccountNotify, AccountRet)
end

function AccountUtil.HandleNoticeNotify(NoticeData)
	EventMgr:SendEvent(EventID.MSDKNoticeNotify, NoticeData)
end

function AccountUtil.HandleDeepLinkNotify(Data)
	EventMgr:SendEvent(EventID.DeepLinkNotify, Data)
end

function AccountUtil.HandleGroupNotify(Data)
	EventMgr:SendEvent(EventID.GroupNotify, Data)
end

function AccountUtil.HandleMicPermissionNotify(Result)
	EventMgr:SendEvent(EventID.MicPermissionNotify, Result)
end

function AccountUtil.HandleStoragePermissionNotify(Result)
	EventMgr:SendEvent(EventID.StoragePermissionNotify, Result)
end

function AccountUtil.OnApplicationWillDeactivate()
	EventMgr:SendEvent(EventID.ApplicationWillDeactivate)
end

function AccountUtil.OnApplicationHasReactivated()
	EventMgr:SendEvent(EventID.ApplicationHasReactivated)
end

--region 分享：消息Send

function AccountUtil.MakeFriendReqInfo()
	return _G.UE.FAccountFriendReqInfo()
end

--- 发送消息给好友
---@param FriendReqInfo FAccountFriendReqInfo
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
function AccountUtil.SendMessage(FriendReqInfo, Channel)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.SendMessage] App not installed")
		return false
	end

	_G.UE.UAccountMgr.Get():SendMessage(FriendReqInfo, Channel)
end

function AccountUtil.Share(FriendReqInfo, Channel)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.Share] App not installed")
		return false
	end

	_G.UE.UAccountMgr.Get():Share(FriendReqInfo, Channel)
end

--- 发送文本 支持微信，Line, SMS, WhatsApp, Garena
--- （1）文本定向分享只支持微信，可以通过 User 传入目标对象的 openid；
--- （2）微信渠道分享的文本大小不能超过 10k；
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param User string 当使用 sopenid 时，必须在extraJson中加上 {\"isFriendInGame\":false}；当使用 gopenid 时，可以在extraJson中加上 {\"isFriendInGame\":true} (非必须)
---@param IsSOpenID boolean 是否是SOpenID
---@param Desc string 分享描述
function AccountUtil.SendText(Channel, User, IsSOpenID, Desc)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.SendText] Channel not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendText] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeText
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.User] = User

	if IsSOpenID then
		FriendReqInfo[MemFriendReqInfo.ExtraJson] = "{\"isFriendInGame\":false}"
	end

	AccountUtil.SendMessage(FriendReqInfo, Channel)
end

--- 发送链接，支持微信，QQ，WhatsApp，Garena，Kwai
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param User string 当使用 sopenid 时，必须在extraJson中加上 {\"isFriendInGame\":false}；当使用 gopenid 时，可以在extraJson中加上 {\"isFriendInGame\":true} (非必须)
---@param IsSOpenID boolean 是否是SOpenID
---@param Title string 分享的标题，QQ、Kwai渠道必填；微信渠道 Android Title 和 Desc 不可以同时为空；其他渠道选填
---@param Desc string 分享的内容, 微信渠道 Android Title 和 Desc 不可以同时为空; 其他渠道选填
---@param Link string 必填。分享的链接
---@param ThumbPath	string 选填（Kwai 渠道必填）。缩略图的 URL
---@param GameData string 选填。游戏自定义透传数据，仅支持 QQ
function AccountUtil.SendLink(Channel, User, IsSOpenID, Title, Desc, Link, ThumbPath, GameData)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.SendLink] Channel not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendLink] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeLink
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.User] = User
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath

	local JsonItems = {}
	if IsSOpenID then
		AccountUtil.JsonUtil.AddItem(JsonItems, "isFriendInGame", false)
	end

	if not string.isnilorempty(GameData) then
		AccountUtil.JsonUtil.AddItem(JsonItems, "game_data", GameData)
	end

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.SendMessage(FriendReqInfo, Channel, ThumbPath)
end

--- 发送图片
---（1）QQ 渠道 图片大小不超过 1M；
---（2）WeChat 渠道 图片不超过 3M；
---（3）发送图片时，要注意 file_provider_paths.xml 配置与图片存储位置相匹配。
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param User string 当使用 sopenid 时，必须在extraJson中加上 {\"isFriendInGame\":false}；当使用 gopenid 时，可以在extraJson中加上 {\"isFriendInGame\":true} (非必须)
---@param IsSOpenID boolean 是否是SOpenID
---@param ImagePath string 必填。图片的路径，支持本地或网络图片，必填
---@param ThumbPath string iOS必填，Android选填。缩略图路径，图片大小不超过 128k
function AccountUtil.SendIMG(Channel, User, IsSOpenID, ImagePath, ThumbPath)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.SendIMG] Channel not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendIMG] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeIMG
	FriendReqInfo[MemFriendReqInfo.User] = User
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath

	if IsSOpenID then
		FriendReqInfo[MemFriendReqInfo.ExtraJson] = "{\"isFriendInGame\":false}"
	end

	AccountUtil.SendMessage(FriendReqInfo, Channel)
end

--- 发送Wx小程序
---@param UserOpenID string 比如静默分享时需要指定分享给指定的用户
---@param Link string 旧版微信中打开小程序时，跳转的页面URL（可填任意 URL），必填
---@param ThumbPath	string Android 必填 /iOS 选填，分享的小程序 icon 图（iOS 分享未入参时，分享的小程序 icon 图为空）；
---@param MiniAppID string 小程序原始 id，如 gh_e9f675597c15，必填
---@param MiniProgramType number 指定小程序版本，分为 Release(0)，Test(1)，Preview(2)三种版本类型，与小程序版本对应，选填
---@param MediaTagName string 此值会传到微信供统计用，详情 点击这里，选填
---@param MediaPath string 选填，小程序 path，可通过该字段指定跳转小程序的某个页面（若填空字符串，默认跳转首页）。对于小游戏，没有页面，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar";
---@param GameData	string 游戏分享时传入的自定义值，通过此消息拉起游戏会通过应用唤醒回调中扩展字段回传给游戏，即透传参数；不需要的话可以填写空串；填写示例：\"game_data\":{\"loobyid\":\"123456\",\"roomid\":\"123456\"} 或者 \"game_data\":\"gameData\，选填
function AccountUtil.SendWechatMiniApp(UserOpenID, Link, ThumbPath, MiniAppID, MiniProgramType, MediaTagName, MediaPath, GameData)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.SendWechatMiniApp] WeChat not installed")
		return false
	end

	FLOG_INFO("AccountUtil.SendWechatMiniApp, UserOpenID:%s, Link:%s, ThumbPath:%s, MiniAppID:%s, MiniProgramType:%d, MediaTagName:%s, MediaPath:%s, GameData:%s",
	UserOpenID, Link, ThumbPath, MiniAppID, MiniProgramType, MediaTagName, MediaPath, GameData)

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendWechatMiniApp] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeMiniApp
	FriendReqInfo[MemFriendReqInfo.User] = UserOpenID
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath
	FriendReqInfo[MemFriendReqInfo.MediaPath] = MediaPath

	local JsonItems = {}
	AccountUtil.JsonUtil.AddItem(JsonItems, "game_data", GameData)
	AccountUtil.JsonUtil.AddItem(JsonItems, "media_tag_name", MediaTagName)
	AccountUtil.JsonUtil.AddItem(JsonItems, "message_action", "WECHAT_SNS_JUMP_URL")
	AccountUtil.JsonUtil.AddItem(JsonItems, "weapp_id", MiniAppID)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_program_type", MiniProgramType)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)
	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--- 发送QQ小程序
---@param UserOpenID string 比如静默分享时需要指定分享给指定的用户
---@param Link string 跳转的页面URL（可填任意 URL），必填
---@param Title	string	分享小程序的标题，必填
---@param Desc	string	分享小程序的内容描述，必填
---@param ThumbPath	string 缩略图路径，必填
---@param MiniAppID string 小程序的AppId，必填
---@param MiniPath string 小程序的展示路径，不填唤起默认小程序首页，可携带参数，例：pages/main/index?a=123&b=123，必填
---@param MiniWebpageUrl string 兼容低版本的网页链接，MSDK 会自动把 link 值赋给 mini_webpage_url（分享到空间时，link 值会赋给 targetURL），游戏无需在 extraJson 中传入该参数，选填
---@param MiniProgramType number 小程序的类型，默认正式版（3），可选测试版（1），选填
function AccountUtil.SendQQMiniApp(UserOpenID, Link, Title, Desc, ThumbPath, MiniAppID, MiniPath, MiniWebpageUrl, MiniProgramType)
	if not AccountUtil.IsQQInstalled() then
		FLOG_WARNING("[AccountUtil.SendQQMiniApp] QQ not installed")
		return false
	end

	FLOG_INFO("AccountUtil.SendQQMiniApp, Link:%s, Title:%s, Desc:%s, MiniAppID:%s, MiniPath:%s, MiniWebpageUrl:%s, MiniProgramType:%d",
	Link, Title, Desc, MiniAppID, MiniPath, MiniWebpageUrl, MiniProgramType)
	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendQQMiniApp] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeMiniApp
	FriendReqInfo[MemFriendReqInfo.User] = UserOpenID
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc

	local JsonItems = {}
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_appid", MiniAppID)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_path", MiniPath)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_webpage_url", MiniWebpageUrl)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_program_type", MiniProgramType)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)
	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.QQ)
end

--- 发送音乐
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param Link string 必填，需填写点击消息后跳转的网络 Url，长度不能超过 10K；
---@param Title string 必填，音乐消息的标题；
---@param Desc string 必填，音乐消息的概述；
---@param ImagePath string 选填，需填写图片，大小不能超过 32K；
---@param MediaPath string 必填，需填写音乐数据网络 Url（例 http:// *.mp3），长度不能超过 10K；
function AccountUtil.SendMusic(Channel, Link, Title, Desc, ImagePath, MediaPath)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.SendMusic] App not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendMusic] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeMusic
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.MediaPath] = MediaPath
	AccountUtil.SendMessage(FriendReqInfo, Channel)
end

--- 发送邀请，支持微信，QQ。QQ 渠道该接口不支持定向分享至好友，微信渠道支持拉起对应好友的聊天界面
--- QQ 和 微信的游戏自定义数据可以通过 game_data 来透传，当触发 MSDK_LOGIN_WAKEUP 事件时，解析 MSDKBaseRet 中的 ExtraJson 字段即可。
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param User string 使用 sopenid 时，必须在extraJson中加上 {\"isFriendInGame\":false}；当使用 gopenid 时，可以在extraJson中加上 {\"isFriendInGame\":true} (非必须)
---@param IsSOpenID boolean 是否是SOpenID
---@param Link string QQ渠道，必填，填写游戏中心详情页
---@param Title string 分享的标题，必填
---@param Desc string 分享的内容，选填
---@param ThumbPath	string	缩略图，支持本地或网络图片，图片大小不超过1M，必填
---@param GameData	string	扩展字段，透传游戏自定义数据，平台会将透传数据做转义处理。其中自定义透传字段 game_data ，Android 为必填项，内容不为空，格式参考示例代码
function AccountUtil.SendInvite(Channel, User, IsSOpenID, Link, Title, Desc, ThumbPath, GameData)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.SendInvite] App not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendInvite] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeInvite
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.User] = User
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath

	local JsonItems = {}
	if IsSOpenID then
		AccountUtil.JsonUtil.AddItem(JsonItems, "isFriendInGame", false)
	end

	AccountUtil.JsonUtil.AddItem(JsonItems, "game_data", GameData)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.SendMessage(FriendReqInfo, Channel)
end

--- 拉起微信小程序
--- 微信拉起小程序功能，没有回调；接口调用的时候，extraJson 字段需要指定 weappid 字段（小程序 ID）。
---@param MediaPath string 选填，小程序path，可通过该字段指定跳转小程序的某个页面（若填空字符串，默认跳转首页）。对于小游戏，没有页面，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"
---@param WEAppID string 小程序原始 id，如 gh_e9f675597c15，必填
function AccountUtil.SendPullUpWechatMiniApp(MediaPath, WEAppID, WithShareTicket, MiniProgramType)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.SendPullUpWechatMiniApp] App not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendPullUpWechatMiniApp] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypePullUpMiniApp
	FriendReqInfo[MemFriendReqInfo.MediaPath] = MediaPath

	local JsonItems = {}

	AccountUtil.JsonUtil.AddItem(JsonItems, "weapp_id", WEAppID)
	AccountUtil.JsonUtil.AddItem(JsonItems, "with_share_ticket", WithShareTicket)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_program_type", MiniProgramType)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--- 拉起QQ小程序
---@param MiniAppID string 小程序的AppId
---@param MiniPath
---@param MiniProgramType
function AccountUtil.SendPullUpQQMiniApp(MiniAppID, MiniPath, MiniProgramType)
	if not AccountUtil.IsQQInstalled() then
		FLOG_WARNING("[AccountUtil.SendPullUpQQMiniApp] App not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendPullUpQQMiniApp] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypePullUpMiniApp
	local JsonItems = {}

	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_appid", MiniAppID)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_path", MiniPath)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_program_type", MiniProgramType)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.QQ)
end

--- QQ Ark功能
--- ExtraJson需要和Ark那边的工作人员沟通 暂时只暴露接口
--- 发送ark消息: http://doc.itop.woa.com/v5/zh-CN/Module/Share.html#39-%E5%8F%91%E9%80%81-ark-%E6%B6%88%E6%81%AF
--- QQ游戏中心图文新模版2024: https://doc.weixin.qq.com/doc/w3_AVwA7gZuAGchI6t5D7BQluKWM0ooy?scode=AJEAIQdfAAorMRkkmxAVwA7gZuAGc
---@param Link string
---@param Title string
---@param Desc string
---@param ImagePath string
---@param ExtraJson string
function AccountUtil.SendArk(Link, Title, Desc, ImagePath, ExtraJson)
	if not AccountUtil.IsQQInstalled() then
		FLOG_WARNING("[AccountUtil.SendArk] App not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendArk] MakeFriendReqInfo failed")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeArk
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath
	FriendReqInfo[MemFriendReqInfo.ExtraJson] = ExtraJson

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.QQ)
end

--- 微信原生化分享（分享至好友）
--- 微信原生分享: http://doc.itop.woa.com/v5/zh-CN/Module/Share.html#314-%E5%BE%AE%E4%BF%A1%E5%8E%9F%E7%94%9F%E5%88%86%E4%BA%AB
--- 原生化分享接入指引: https://mmgame.woa.com/doc/#/article/673
--- 原生化分享接入指引: https://doc.weixin.qq.com/doc/w3_AOIA4gaDACcGr0PKkesQISuGvp0Px?scode=AJEAIQdfAAo5j5cICZAOIA4gaDACc
--- 微信原生分享接入文档: https://iwiki.woa.com/p/4008426990
--- EXTRAJSON&SHAREDATA协议: https://iwiki.woa.com/p/4007509389#EXTRAJSON-%E8%87%AA%E6%B5%8B%E5%B7%A5%E5%85%B7
---@param Title string
---@param Desc string
---@param ThumbPath string
---@param ExtraJson string 参考 https://iwiki.woa.com/p/4008426990 和 https://iwiki.woa.com/p/4007509389
function AccountUtil.SendWxNative(Title, Desc, ThumbPath , ExtraJson)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.SendWxNative] App not installed")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendWxNative] MakeFriendReqInfo failed")
		return false
	end

	FLOG_INFO("[AccountUtil.SendWxNative] Type:%d", MSDKFriendReqType.kMSDKFriendReqTypeWXNativeGamePage)
	-- 10017
	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWXNativeGamePage
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath
	FriendReqInfo[MemFriendReqInfo.ExtraJson] = ExtraJson

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--[[
【选填】查询字符串，格式：key1=val1&key2=val2 （一般为微信内部使用，需要使用时会告知） -- 暂时先不填
needEdit： 网络视频时，1：进入图片、视频编辑页面，0：已加载视频进入分享页面。本地视频时，均会进入视频编辑页面
VideoUrl：视频链接，neededit 为 0 时，填写 QT 视频链接，QT 视频获取需要借助组件。neededit 为 1 时，填写可下载的视频链接，不要求是否为 QT 视频链接
]]
function AccountUtil.MakeOpenBusinessView_URLVideo(BussinessType, VideoUrl, ThumbUrl, NeedEdit, Query)
	local GameInfoJsonItems = {}
	AccountUtil.JsonUtil.AddItem(GameInfoJsonItems, "appid", MSDKDefine.Config.WechatAppID)
	AccountUtil.JsonUtil.AddItem(GameInfoJsonItems, "appName", MSDKDefine.Config.APPName)
	local GameInfoJson = AccountUtil.JsonUtil.ToJson(GameInfoJsonItems)

	local ExtInfoJsonItems = {}
	AccountUtil.JsonUtil.AddItem(ExtInfoJsonItems, "videoUrl", VideoUrl)
	AccountUtil.JsonUtil.AddItem(ExtInfoJsonItems, "thumbUrl", ThumbUrl)
	AccountUtil.JsonUtil.AddItem(ExtInfoJsonItems, "needEdit", NeedEdit)
	AccountUtil.JsonUtil.AddJson(ExtInfoJsonItems, "gameInfo", GameInfoJson)
	local ExtInfoJson = AccountUtil.JsonUtil.ToJson(ExtInfoJsonItems)

	local ResultJsonItems = {}
	AccountUtil.JsonUtil.AddItem(ResultJsonItems, "business_type", BussinessType)
	AccountUtil.JsonUtil.AddJson(ResultJsonItems, "ext_info", ExtInfoJson)
	AccountUtil.JsonUtil.AddItem(ResultJsonItems, "query", Query)

	return AccountUtil.JsonUtil.ToJson(ResultJsonItems)
end

function AccountUtil.MakeOpenBusinessView_iOSVideo(BussinessType, VideoPath, ThumbUrl, NeedEdit, Query)
	local GameInfoJsonItems = {}
	AccountUtil.JsonUtil.AddItem(GameInfoJsonItems, "appid", MSDKDefine.Config.WechatAppID)
	AccountUtil.JsonUtil.AddItem(GameInfoJsonItems, "appName", MSDKDefine.Config.APPName)
	local GameInfoJson = AccountUtil.JsonUtil.ToJson(GameInfoJsonItems)

	local ExtInfoJsonItems = {}
	AccountUtil.JsonUtil.AddItem(ExtInfoJsonItems, "thumbUrl", ThumbUrl)
	AccountUtil.JsonUtil.AddItem(ExtInfoJsonItems, "needEdit", NeedEdit)
	AccountUtil.JsonUtil.AddJson(ExtInfoJsonItems, "gameInfo", GameInfoJson)
	local ExtInfoJson = AccountUtil.JsonUtil.ToJson(ExtInfoJsonItems)

	local ResultJsonItems = {}
	AccountUtil.JsonUtil.AddItem(ResultJsonItems, "business_type", BussinessType)
	AccountUtil.JsonUtil.AddJson(ResultJsonItems, "ext_info", ExtInfoJson)
	AccountUtil.JsonUtil.AddItem(ResultJsonItems, "query", Query)
	AccountUtil.JsonUtil.AddItem(ResultJsonItems, "ext_data", VideoPath)

	return AccountUtil.JsonUtil.ToJson(ResultJsonItems)
end

function AccountUtil.MakeOpenBusinessView_AndroidVideo(BussinessType, VideoPath, NeedEdit, Query)
	local GameInfoJsonItems = {}
	AccountUtil.JsonUtil.AddItem(GameInfoJsonItems, "appid", MSDKDefine.Config.WechatAppID)
	AccountUtil.JsonUtil.AddItem(GameInfoJsonItems, "appName", MSDKDefine.Config.APPName)
	local GameInfoJson = AccountUtil.JsonUtil.ToJson(GameInfoJsonItems)

	local ExtInfoJsonItems = {}
	AccountUtil.JsonUtil.AddItem(ExtInfoJsonItems, "videoPath", VideoPath)
	AccountUtil.JsonUtil.AddItem(ExtInfoJsonItems, "needEdit", NeedEdit)
	AccountUtil.JsonUtil.AddJson(ExtInfoJsonItems, "gameInfo", GameInfoJson)
	local ExtInfoJson = AccountUtil.JsonUtil.ToJson(ExtInfoJsonItems)

	local ResultJsonItems = {}
	AccountUtil.JsonUtil.AddItem(ResultJsonItems, "business_type", BussinessType)
	AccountUtil.JsonUtil.AddJson(ResultJsonItems, "ext_info", ExtInfoJson)
	AccountUtil.JsonUtil.AddItem(ResultJsonItems, "query", Query)

	return AccountUtil.JsonUtil.ToJson(ResultJsonItems)
end

--- 拉起微信业务功能，分享到微信游戏
--- 一个微信提供的通用功能，不单单会拉起小程序，可能会拉起一个链接等，后面会推荐业务使用该方式拉起微信功能。
---@param ExtraJson string
function AccountUtil.SendOpenBusinessView(ExtraJson)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.SendOpenBusinessView] WeChat is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendOpenBusinessView] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeOpenBusinessView
	FriendReqInfo[MemFriendReqInfo.ExtraJson] = ExtraJson

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--[[
MSDK 封装视频号直播接口，通过复用 MSDKFriend.SendMessage 接口
]]
function AccountUtil.SendWXChannelStartLive(ExtraJson)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.SendWXChannelStartLive] WeChat is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendWXChannelStartLive] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWXChannelStartLive
	FriendReqInfo[MemFriendReqInfo.ExtraJson] = ExtraJson

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--[[
MSDK 封装手 Q 小世界分享接口，复用 MSDKFriend.SendMessage 接口
]]
function AccountUtil.SendWithCommonShare(ExtraJson)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.SendWithCommonShare] WeChat is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendWithCommonShare] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWithCommonShare
	FriendReqInfo[MemFriendReqInfo.ExtraJson] = ExtraJson

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.QQ)
end

--[[
发送至状态，支持微信
stateId 可以填写 "1019"，link 为游戏圈地址，title 设置后将作为编辑页默认值，
跳转到微信之后，title 和 stateId 参数均能够自主修改；图片建议 9:16 的尺寸，需使用本地图片路径。
]]
function AccountUtil.SendWXStatePhoto(Title, Link, ImagePath, StateID)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.SendWXStatePhoto] WeChat is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SendWXStatePhoto] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWXStatePhoto
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath

	local JsonItems = {}
	AccountUtil.JsonUtil.AddItem(JsonItems, "stateId", StateID)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.SendMessage(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--endregion 分享：消息Send

--region 分享Share

--- 分享文本，支持朋友圈，QQ 空间，Twitter (仅Android平台)，System
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param Desc string 分享的内容
function AccountUtil.ShareText(Channel, Desc)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.ShareText] Channel app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareText] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeText
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc

	AccountUtil.Share(FriendReqInfo, Channel)
end

--- 分享链接，支持朋友圈，QQ 空间，Facebook，Twitter (仅 Android 平台)，System (iOS 平台）
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param Link string 分享的链接
---@param Title string 标题，QQ 渠道 Title 为必填字段。
function AccountUtil.ShareLink(Channel, Link, Title)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.ShareLink] Channel app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareLink] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeLink
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.Title] = Title

	AccountUtil.Share(FriendReqInfo, Channel)
end

--- 分享图片，支持朋友圈，QQ 空间，Facebook，Twitter (仅 Android 平台)，System
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param ImagePath string 分享的图片
function AccountUtil.SharePicture(Channel, ImagePath)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.SharePicture] Channel app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.SharePicture] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeIMG
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath

	AccountUtil.Share(FriendReqInfo, Channel)
end

--- 分享微信朋友圈音乐
---@param Link string 分享的链接
---@param ImagePath string 分享的图片
function AccountUtil.ShareMusic(Link, ImagePath)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.ShareMusic] WeChat app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareMusic] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeMusic
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath

	AccountUtil.Share(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

---分享邀请，支持 QQ 空间，空间新能力，详细说明参见 空间新能力说明及示例
--- 可能需要title
---@param Link string 分享邀请的链接
function AccountUtil.ShareInvite(Link)
	if not AccountUtil.IsQQInstalled() then
		FLOG_WARNING("[AccountUtil.ShareInvite] QQ app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareInvite] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeInvite
	FriendReqInfo[MemFriendReqInfo.Link] = Link

	AccountUtil.Share(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

---分享视频，支持 QQ 空间，Facebook，Kwai
---@param Channel string 渠道信息，比如“WeChat”、“QQ"、"Line"
---@param MediaPath string 视频本地路径
function AccountUtil.ShareVideo(Channel, MediaPath)
	if not AccountUtil.CheckChannelAppInstalled(Channel) then
		FLOG_WARNING("[AccountUtil.ShareVideo] App is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareVideo] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeVideo
	FriendReqInfo[MemFriendReqInfo.MediaPath] = MediaPath

	AccountUtil.Share(FriendReqInfo, Channel)
end

---分享微信游戏圈，仅支持图片（包括本地图片和网络图片）
---@param ImagePath string
---@param Title string
---@param GameExtra string
function AccountUtil.ShareWXGameLine(ImagePath, Title, GameExtra)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.ShareWXGameLine] WeChat app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareWXGameLine] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWXGameLine
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath
	FriendReqInfo[MemFriendReqInfo.Title] = Title

	local JsonItems = {}
	AccountUtil.JsonUtil.AddItem(JsonItems, "gameextra", GameExtra)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.Share(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--- 分享小程序到 QQ 空间
---@param Title string 选填，分享标题；
---@param Desc string 必填，分享摘要描述，不填部分机型报参数错误；
---@param ThumbPath string 选填，分享的小程序 icon 图；
---@param Link string 必填，兼容低版本的网页链接（可填任意 URL）；
---@param MiniAppID string 小程序的AppId
---@param MiniPath string 小程序的展示路径，不填唤起默认小程序首页，可携带参数，例：pages/main/index?a=123&b=123，必填
---@param MiniWebpageUrl string 兼容低版本的网页链接，MSDK 会自动把 link 值赋给 mini_webpage_url（分享到空间时，link 值会赋给 targetURL），游戏无需在 extraJson 中传入该参数，选填
---@param MiniProgramType number 指定小程序版本，分为 Release(0)，Test(1)，Preview(2)三种版本类型，与小程序版本对应，选填
function AccountUtil.ShareQQMiniApp(Title, Desc, ThumbPath, Link, MiniAppID, MiniPath, MiniWebpageUrl, MiniProgramType)
	if not AccountUtil.IsQQInstalled() then
		FLOG_WARNING("[AccountUtil.ShareQQMiniApp] QQ app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareQQMiniApp] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeMiniApp
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath
	FriendReqInfo[MemFriendReqInfo.Link] = Link

	local JsonItems = {}
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_appid", MiniAppID)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_path", MiniPath)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_webpage_url", MiniWebpageUrl)
	AccountUtil.JsonUtil.AddItem(JsonItems, "mini_program_type", MiniProgramType)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.Share(FriendReqInfo, MSDKDefine.Channel.QQ)
end

---分享至视频号，支持微信视频号
---@param MediaPath string 视频本地路径
function AccountUtil.ShareWXVideo(MediaPath)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.ShareWXVideo] WeChat app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareWXVideo] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWXChannelShareVideo
	FriendReqInfo[MemFriendReqInfo.MediaPath] = MediaPath

	AccountUtil.Share(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--- 分享至状态，支持微信，状态相关信息将显示在微信->我的个人头像下面，点击状态下面应用名称将自动跳转到指定页面
---@param Title string 分享的标题
---@param Link string
---@param ImagePath string
---@param StateID string
function AccountUtil.ShareWXState(Title, Link, ImagePath, StateID)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.ShareWXState] WeChat app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareWXState] MakeFriendReqInfo failed.")
		return false
	end

	FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWXStatePhoto
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Link] = Link
	FriendReqInfo[MemFriendReqInfo.ImagePath] = ImagePath
	local JsonItems = {}
	AccountUtil.JsonUtil.AddItem(JsonItems, "stateId", StateID)

	FriendReqInfo[MemFriendReqInfo.ExtraJson] = AccountUtil.JsonUtil.ToJson(JsonItems)

	AccountUtil.Share(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--- 微信原生化分享（分享至朋友圈）
--- 微信原生分享: http://doc.itop.woa.com/v5/zh-CN/Module/Share.html#412-%E5%BE%AE%E4%BF%A1%E5%8E%9F%E7%94%9F%E5%88%86%E4%BA%AB
--- 原生化分享接入指引: https://mmgame.woa.com/doc/#/article/673
--- 原生化分享接入指引: https://doc.weixin.qq.com/doc/w3_AOIA4gaDACcGr0PKkesQISuGvp0Px?scode=AJEAIQdfAAo5j5cICZAOIA4gaDACc
--- 微信原生分享接入文档: https://iwiki.woa.com/p/4008426990
--- EXTRAJSON&SHAREDATA协议: https://iwiki.woa.com/p/4007509389#EXTRAJSON-%E8%87%AA%E6%B5%8B%E5%B7%A5%E5%85%B7
---@param Title string
---@param Desc string
---@param ThumbPath string
---@param ExtraJson string 参考 https://iwiki.woa.com/p/4008426990 和 https://iwiki.woa.com/p/4007509389
function AccountUtil.ShareWxNative(Title, Desc, ThumbPath , ExtraJson)
	if not AccountUtil.IsWeChatInstalled() then
		FLOG_WARNING("[AccountUtil.ShareWxNative] WeChat app is not installed.")
		return false
	end

	local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		FLOG_WARNING("[AccountUtil.ShareWxNative] MakeFriendReqInfo failed.")
		return false
	end

	--FriendReqInfo[MemFriendReqInfo.Type] = MSDKFriendReqType.kMSDKFriendReqTypeWXNativeGamePage
	FriendReqInfo[MemFriendReqInfo.Type] = 10017
	FriendReqInfo[MemFriendReqInfo.Title] = Title
	FriendReqInfo[MemFriendReqInfo.Desc] = Desc
	FriendReqInfo[MemFriendReqInfo.ThumbPath] = ThumbPath
	FriendReqInfo[MemFriendReqInfo.ExtraJson] = ExtraJson

	AccountUtil.Share(FriendReqInfo, MSDKDefine.Channel.WeChat)
end

--endregion 分享Share

function AccountUtil.OpenUrl(Url, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
	_G.UE.UAccountMgr.Get():OpenUrl(Url, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
end

function AccountUtil.OpenUrlWithParam(Url)
	AccountUtil.OpenUrlWithAllParam(Url, 1, false, true, "", false)
end

function AccountUtil.OpenUrlWithAllParam(Url, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
	local LoginMgr = _G.LoginMgr
	local PlatformId = 5
	if CommonUtil.IsIOSPlatform() then
		PlatformId = 0
	elseif CommonUtil.IsAndroidPlatform() then
		PlatformId = 1
	end
	local AreaId = LoginMgr:GetChannelID() or 0
	local RoleId = MajorUtil.GetMajorRoleID() or 0
	local Partition = LoginMgr:GetWorldID() or 0

	--local NewUrl = string.format("%s&openid=%s", Url, LoginMgr:GetOpenID())
	local separator = string.find(Url, "?") and "&" or "?"
	local NewUrl = string.format("%s%splatId=%d&area=%d&roleId=%d&partition=%d", Url, separator, PlatformId, AreaId, RoleId, Partition)
	_G.UE.UAccountMgr.Get():OpenUrl(NewUrl, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
end

function AccountUtil.OpenTokenLinkUrl(Url, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
	local LoginMgr = _G.LoginMgr
	local PlatformId = 5
	if CommonUtil.IsIOSPlatform() then
		PlatformId = 0
	elseif CommonUtil.IsAndroidPlatform() then
		PlatformId = 1
	end

	local AreaId = LoginMgr:GetChannelID() or 0
	if not CommonUtil.IsShipping() then
		AreaId = LoginMgr:GetWorldID() or 10
	end

	local RoleId = MajorUtil.GetMajorRoleID() or 0
	local Partition = LoginMgr:GetWorldID() or 0

	--local NewUrl = string.format("%s&openid=%s", Url, LoginMgr:GetOpenID())
	local separator = string.find(Url, "?") and "&" or "?"
	local NewUrl = string.format("%s%splatId=%d&area=%d&roleId=%d&partition=%d", Url, separator, PlatformId, AreaId, RoleId, Partition)
	_G.UE.UAccountMgr.Get():OpenUrl(NewUrl, ScreenType, IsFullScreen, IsUseURLEncode, ExtraJson, IsBrowser)
end

function AccountUtil.CheckChannelAppInstalled(ChannelID)
	if ChannelID == MSDKDefine.Channel.QQ then
		return AccountUtil.IsQQInstalled()
	elseif ChannelID == MSDKDefine.Channel.WeChat then
		return AccountUtil.IsWeChatInstalled()
	else
		return false
	end
end

function AccountUtil.IsQQInstalled()
	local IsInstalled = false
	local PlatformName = CommonUtil.GetPlatformName()
	if PlatformName == "Android" then
		IsInstalled = _G.UE.UCommonUtil.IsAppInstalled("com.tencent.mobileqq", "")
	elseif PlatformName == "IOS" then
		IsInstalled = _G.UE.UCommonUtil.IsAppInstalled("QQ", "")
	end
	FLOG_INFO("[AccountUtil.IsQQInstalled] IsInstalled: %s", IsInstalled)
	return IsInstalled
end

function AccountUtil.IsWeChatInstalled()
	local IsInstalled = false
	local PlatformName = CommonUtil.GetPlatformName()
	if PlatformName == "Android" then
		IsInstalled = _G.UE.UCommonUtil.IsAppInstalled("com.tencent.mm", "")
	elseif PlatformName == "IOS" then
		IsInstalled = _G.UE.UCommonUtil.IsAppInstalled("WeChat", "")
	end
	FLOG_INFO("[AccountUtil.IsWeChatInstalled] IsInstalled: %s", IsInstalled)
	return IsInstalled
end

-- https://iwiki.woa.com/p/459104231
-- https://gacc-account-web.odp.qq.com/writeoff.html?ADTAG=client&os=1&gameid=11&channelid=1&itopencodeparam=d9b48147c3b809a2bebbd8b2e96c26f1&outerIp=127.0.0.1
function AccountUtil.DeleteAccount()
	FLOG_INFO("[AccountUtil.DeleteAccount]")
	local LoginMgr = _G.LoginMgr
	-- 拉起Web
	local PlatformOs = 0
	local PlatformName = CommonUtil.GetPlatformName()
	if PlatformName == "Android" then
		PlatformOs = 1
	elseif PlatformName == "IOS" then
		PlatformOs = 2
	elseif PlatformName == "Windows" then
		PlatformOs = 5
	end
	local GameId = _G.UE.UGCloudMgr.Get():GetMSDKGameId()
	local ChannelID = LoginMgr:GetChannelID() or 0
	--local OpenID = LoginMgr:GetOpenID() or 0

	local Url = string.format("%s?ADTAG=client&msdkVersion=V5&os=%d&gameid=%d&channelid=%d&outerIp=127.0.0.1&webview=msdk", _G.UE.UGCloudMgr.Get():GetWriteOffUrl(), PlatformOs, GameId, ChannelID)
	--local Url = string.format("%s?ADTAG=client&msdkVersion=V5&channelid=%d&outerIp=127.0.0.1&webview=msdk", _G.UE.UGCloudMgr.Get():GetWriteOffUrl(), ChannelID)
	--local Url = string.format("https://gacc-account-web-test.odp.qq.com/writeoff.html?ADTAG=client&msdkVersion=V5&os=%d&gameid=%d&channelid=%d&itopencodeparam=%s&outerIp=127.0.0.1&webview=msdk", 1, 16208, ChannelID, OpenID)
	local ExtraJson = ""

	--FLOG_INFO("[AccountUtil.DeleteAccount] Url:%s", Url)
	_G.UE.UAccountMgr.Get():OpenUrl(Url, 1, false, true, ExtraJson, false)
end

return AccountUtil