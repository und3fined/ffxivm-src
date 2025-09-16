
local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local ReportDefine = require("Game/Report/ReportDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local CS_CMD = ProtoCS.CS_CMD

local UIViewMgr
local GameNetworkMgr
local LSTR

---@class ReportMgr : MgrBase
local ReportMgr = LuaClass(MgrBase)

---OnInit
function ReportMgr:OnInit()
end

---OnBegin
function ReportMgr:OnBegin()
	UIViewMgr = _G.UIViewMgr
	GameNetworkMgr = _G.GameNetworkMgr
	LSTR = _G.LSTR
end

function ReportMgr:OnEnd()
end

function ReportMgr:OnShutdown()
end

function ReportMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PLAYERREPORT, 0 , self.OnPlayerReportRsp)
end

function ReportMgr:OnRegisterGameEvent()
end

--------- 协议相关
---@class PlayerBaseInfo
---@field string OpenID = 1; // 举报者的OpenID
---@field int32 WorldID = 2; // 举报者的区服ID
---@field int32 ChannelID = 3; // 举报者的登录渠道id 1 - 微信(WeChat)，2 - 手Q(mqq)，3 - 游客(Guest)，4 - Facebook，5 - GameCenter，6 - GooglePlay，7 - IEGPass，9 - Twitter，10 - garena，11 - SelfAccount，12 - EGame，14 - Line，15 - Signin with Apple，17 - Kwai，19 - VK，21 - steam
---@field int32 PlatID = 4; // 举报者的平台ID 0 -IOS  - 1 Android, 3 PC ....
---@field uint64 RoleID = 5; // 举报者的RoleID
---@field string RoleName = 6; // 举报者的RoleName

---@class PlayerReportReq
---@field PlayerBaseInfo Informant = 1; // 必选 举报者玩家基础信息
---@field PlayerBaseInfo Reported = 2; // 必选 被举报者玩家基础信息
---@field int32 ReportCategory = 3; // 必选 举报大类
---@field repeated int32 ReportSeason	 = 4; // 必选 举报原因类型
---@field int32 ReportScene	 = 5; // 必选 举报场景id
---@field string ReportDesc	= 6; // 选填 举报者补充的详细描述
---@field string ReportContent= 7; // 选填 根据举报对象上报对应的被举报文本内容
---@field repeated string PicUrlArray	= 8; // 选填 举报的图片url列表,单条最大长度=4096字节,列表最大长度=12
---@field repeated string VideoUrlArray	= 9;  // 选填 举报的视频url列表,单条最大长度=4096字节,列表最大长度=12
---@field repeated string VoiceUrlArray	= 10; // 选填 语音url
---@field string ReportGroupID	= 11; // 选填 被举报的组织id
---@field string ReportGroupName = 12; // 选填 被举报的组织名称
---@field int32 ReportEntrance = 13; // 选填 举报入口id

function ReportMgr:PlayerReportReq(ReportParams)
	local MsgID = CS_CMD.CS_CMD_PLAYERREPORT
	local SubMsgID = 0
	local MsgBody = ReportParams

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ReportMgr:OnPlayerReportRsp(MsgBody)
	if MsgBody ~= nil and MsgBody.Code == 0 then
		MsgTipsUtil.ShowTipsByID(355002)  -- "系统已收到您的举报，我们会及时处理"
	end
end

-----------------

--- 打开“会话发言”场景举报界面
--- Params.ReportContent = “被举报的指定的单条发言文本”
-----离线语言
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.CallbackList = { "msgtype" = "", "fileid" = "" }  msgtype:0-文本 1-语音
--- Params.VoiceUrlArray = { "语音url" }
function ReportMgr:OpenViewBySpeech(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.Speech
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“个人资料”场景举报界面
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.ReportContentList = { "Signature" = "被举报者的签名文本", "PetId" = "搭档id", "PetName" = "搭档名称" }
function ReportMgr:OpenViewByPersonalInfo(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.PersonalInfo
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“部队列表”场景举报界面
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.GroupID    部队ID
--- Params.GroupName    部队名称
--- Params.ReportContentList  = { "Abbreviation" = "部队简称文本", "RecruitmentSlogan" = "招募标语文本"}
function ReportMgr:OpenViewByArmyList(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.ArmyList
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“部队信息”场景举报界面
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.GroupID    部队ID
--- Params.GroupName    部队名称
--- Params.ReportContentList  = { "Abbreviation" = "部队简称文本", "Announcement" = "部队公告文本" }
function ReportMgr:OpenViewByArmyInfo(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.ArmyInfo
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“通讯贝”场景举报界面
--- Params.GroupID    通讯贝ID
--- Params.GroupName    通讯贝名称
--- Params.ReportContentList  = { "Announcement" = "通讯贝公告文本", "RecruitmentSlogan" = "通讯贝招募宣言文本" }
function ReportMgr:OpenViewByLinkShell(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.LinkShell
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“好友申情”场景举报界面
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.ReportContent = “好友申请消息文本”
function ReportMgr:OpenViewByFriendRequest(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.FriendRequest
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“部队申情消息”场景举报界面
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.ReportContent = “部队申请消息文本”
function ReportMgr:OpenViewByArmyRequest(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.ArmyRequest
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“通讯贝邀请消息”场景举报界面
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.ReportContent = “通讯贝邀请消息文本”
function ReportMgr:OpenViewByLinkShellInvitation(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.LinkShellInvitation
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--- 打开“队伍招募信息”场景举报界面
--- Params.ReporteeRoleID  被举报人RoleID 必填
--- Params.ReportContent = “队伍招募留言文本”
function ReportMgr:OpenViewByTeamRecruitment(Params)
	Params = Params or {}
	Params.ReportGroupType = ReportDefine.ReportScene.TeamRecruitment
	UIViewMgr:ShowView(UIViewID.ReportPanel, Params)
end

--要返回当前类
return ReportMgr
