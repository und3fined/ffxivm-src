---
--- Author: anypkvcai
--- DateTime: 2021-11-04 15:58
--- Description:
---

local ProtoCS = require("Protocol/ProtoCS")
local CHANNEL_TYPE = ProtoCS.CHANNEL_TYPE_DEFINE

local LSTR = _G.LSTR
local ShowMsgTimeInterval = 180 -- 显示聊天消息时间的间隔 单位：秒
local MaxHistoryTextNum = 4 
local MaxRecentGifNum = 21
local MaxHyperlinkNum = 3 -- 一条消息最多超链接数量
local MaxPrivateSessionNum = 200
local PrivateSessionTrimNum = 10
local MaxNumVoiceFileStorePublic = 100 
local MaxNumVoiceFileStorePrivate = 200 
local NewbieChannelLowestLevel = 10

local PrivateUnredRedDotID = 46 -- 私聊未读信息汇总红点
local PionnerChannelCloseShowTime = 604800 -- 关闭展示时间 7 天后删除

local ChatMsgEntryWidgetIndex = {
	PlayerMsgRight = 0, -- 头像在右边（自己发的消息）
	PlayerMsgLeft = 1, -- 头像在左边（别人发的消息）
	SystemMsg = 2, --系统消息
	TextMsg = 3, -- 文本消息 类似系统消息 但是没有系统消息类型标签 只有一行文字
}

local ChatCategory = {
	Public = 1, -- 公聊
	Private = 2, -- 私聊
}

local ChatMsgType = {
	Msg 			= 1,
	Tips			= 2,
	TaskShare 		= 3,
	Voice 			= 4,
	Gif 			= 5,
	RemovedNewbie 	= 6,
	FriendTips 		= 7,
	TeamRecruit 	= 8,
	EmotionTips		= 9,
	Location		= 10,
	FriendRename 	= 11,
	SystemNotice 	= 12, -- 系统通知
	SystemBattle 	= 13, -- 系统战斗信息
	SystemStory		= 14, -- 系统剧情信息
	TextTipsCenter 	= 15, -- 文本提示中间
}

local ParseEmojisMsgTypeMap = {
	[ChatMsgType.Msg] = true,
	[ChatMsgType.Voice] = true,
	[ChatMsgType.Location] = true,
}

local ChatChannel = {
	Newbie = CHANNEL_TYPE.CHANNEL_TYPE_NEWBIE, --新人频道
	Army = CHANNEL_TYPE.CHANNEL_TYPE_ARMY, --部队频道
	Area = CHANNEL_TYPE.CHANNEL_TYPE_AREA, --区域频道
	Nearby = CHANNEL_TYPE.CHANNEL_TYPE_NEIGHBOUR, --附近频道 消息直接下
	Team = CHANNEL_TYPE.CHANNEL_TYPE_TEAM, --队伍频道
	Person = CHANNEL_TYPE.CHANNEL_TYPE_PERSON, --私聊频道
	Group = CHANNEL_TYPE.CHANNEL_TYPE_GROUP, --通讯贝频道
	System = CHANNEL_TYPE.CHANNEL_TYPE_SYSTEM, --系统频道 消息直直接下
	SceneTeam = CHANNEL_TYPE.CHANNEL_TYPE_SCENE_TEAM, --副本小队频道
	Pioneer = CHANNEL_TYPE.CHANNEL_TYPE_VANGUARD, -- 先锋频道
	Recruit = CHANNEL_TYPE.CHANNEL_TYPE_RECRUIT, -- 招募频道

	Comprehensive = 100, -- 综合频道, "聊天设置" 可以设置综合频道包含的具体频道
}

local ChatChannelConfig = {
	{
		Channel = ChatChannel.Comprehensive, Name = LSTR(50001), -- "综合"
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_AllNormal_png.UI_Chat_Tab_Icon_AllNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_AllSelect_png.UI_Chat_Tab_Icon_AllSelect_png'",
		CannotHide = true, Pos = 1,
	},
	{
		Channel = ChatChannel.Pioneer, Name = LSTR(50156), -- "先锋"
		MsgLength = 100, MsgCD = 10000,
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_PioneerNormal_png.UI_Chat_Tab_Icon_PioneerNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_PioneerSelect_png.UI_Chat_Tab_Icon_PioneerSelect_png'",
		Pos = 2,
	},
	{
		Channel = ChatChannel.Recruit, Name = LSTR(50157), -- "招募"
		MsgLength = 100, MsgCD = 1000,
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_RecruitNormal_png.UI_Chat_Tab_Icon_RecruitNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_RecruitSelect_png.UI_Chat_Tab_Icon_RecruitSelect_png'",
		Pos = 3,
	},
	{
		Channel = ChatChannel.Newbie, Name = LSTR(50002), -- "新人"
		MsgLength = 100, MsgCD = 1000,
		GoToIcon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_TitleJoy_png.UI_Chat_Icon_TitleJoy_png'",
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_NewcomerNormal_png.UI_Chat_Tab_Icon_NewcomerNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_NewcomerSelect_png.UI_Chat_Tab_Icon_NewcomerSelect_png'",
		Pos = 4,
	},
	{
		Channel = ChatChannel.Army, Name = LSTR(50004), -- "部队"
		MsgLength = 100, MsgCD = 1000, 
		GoToIcon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_TitleArmy_png.UI_Chat_Icon_TitleArmy_png'",
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_ArmyNormal_png.UI_Chat_Tab_Icon_ArmyNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_ArmySelect_png.UI_Chat_Tab_Icon_ArmySelect_png'",
		Pos = 5,
	},
	{
		Channel = ChatChannel.Team, Name = LSTR(50005), -- "队伍"
		MsgLength = 100, MsgCD = 1000, 
		GoToIcon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_TitleTeam_png.UI_Chat_Icon_TitleTeam_png'",
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_TeamNormal_png.UI_Chat_Tab_Icon_TeamNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_TeamSelect_png.UI_Chat_Tab_Icon_TeamSelect_png'",
		Pos = 6,
	},
	{
		Channel = ChatChannel.SceneTeam, Name = LSTR(50005), -- "队伍"
		MsgLength = 100, MsgCD = 1000,
		GoToIcon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_TitleTeam_png.UI_Chat_Icon_TitleTeam_png'",
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_TeamNormal_png.UI_Chat_Tab_Icon_TeamNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_TeamSelect_png.UI_Chat_Tab_Icon_TeamSelect_png'",
		Pos = 6,
	},
	{
		Channel = ChatChannel.System, Name = LSTR(50007), -- "系统"
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_SystemNormal_png.UI_Chat_Tab_Icon_SystemNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_SystemSelect_png.UI_Chat_Tab_Icon_SystemSelect_png'",
		CannotHide = true, Pos = 7,
	},
	{
		Channel = ChatChannel.Nearby, Name = LSTR(50006), -- "附近"
		MsgLength = 100, MsgCD = 1000,
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_NearbyNormal_png.UI_Chat_Tab_Icon_NearbyNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_NearbySelect_png.UI_Chat_Tab_Icon_NearbySelect_png'",
		Pos = 8,
	},
	{
		Channel = ChatChannel.Area, Name = LSTR(50003), -- "区域"
		MsgLength = 100, MsgCD = 1000,
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_AreaNormal_png.UI_Chat_Tab_Icon_AreaNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_AreaSelect_png.UI_Chat_Tab_Icon_AreaSelect_png'",
		Pos = 9,
	},
	{
		Channel = ChatChannel.Group, Name = LSTR(50008), -- "通讯贝"
		MsgLength = 100, MsgCD = 1000, 
		GoToIcon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_TitleLinkshells_png.UI_Chat_Icon_TitleLinkshells_png'",
		Icon = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_ShellNormal_png.UI_Chat_Tab_Icon_ShellNormal_png'",
		IconSelect = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Tab_Icon_ShellSelect_png.UI_Chat_Tab_Icon_ShellSelect_png'",
		Pos = 10,
	},
	{
		Channel = ChatChannel.Person, Name = LSTR(50009), -- "私聊"
		MsgLength = 100, MsgCD = 1000,
	},
}

local SettingSortChannels = {
	ChatChannel.Comprehensive,
	ChatChannel.Pioneer,
	ChatChannel.Recruit,
	ChatChannel.Newbie,
	ChatChannel.Army,
	ChatChannel.Team,
	ChatChannel.System,
	ChatChannel.Nearby,
	ChatChannel.Area,
	ChatChannel.Group,
}

local ChatChannelColor = {
	"d9d981ff", "decf92ff", "f46b4bff", "a2b0e7ff", "cb9b46ff", "f09c60ff", "97e5f6ff", "87b641ff", "flaed3ff", "77cfc0ff",
	"79bb67ff", "41ac89ff", "8a6fddff", "5985c8ff", "fa8bfaff", "ff6d82ff",
}

local SysMsgType = {
	All = 1, 
	Notice = 2,
	Battle = 3,
	Story = 4,
}

local ChatDefaultSetting = {
	ComprehensiveChannels = { ChatChannel.Pioneer, ChatChannel.Recruit, ChatChannel.Newbie, ChatChannel.Army, ChatChannel.Area, ChatChannel.Nearby, ChatChannel.Team, ChatChannel.System, ChatChannel.Group },
	ComprehensiveChannelSysMsgTypes = {SysMsgType.Notice, SysMsgType.Story}, -- 综合频道显示的系统消息类型
	ChannelColorIndices = {
		{ Channel = ChatChannel.Newbie, ColorIndex = 8 },
		{ Channel = ChatChannel.Army, ColorIndex = 7 },
		{ Channel = ChatChannel.Area, ColorIndex = 6 },
		{ Channel = ChatChannel.Nearby, ColorIndex = 4 },
		{ Channel = ChatChannel.Team, ColorIndex = 3 },
		{ Channel = ChatChannel.Group, ColorIndex = 1 },
		{ Channel = ChatChannel.System, ColorIndex = 2 },
		{ Channel = ChatChannel.Pioneer, ColorIndex = 5 },
		{ Channel = ChatChannel.Recruit, ColorIndex = 10 },
	}
}

local MapChatMsgTypeAndSysMsgType = {
	[ChatMsgType.SystemNotice] = SysMsgType.Notice,
	[ChatMsgType.SystemBattle] = SysMsgType.Battle,
	[ChatMsgType.SystemStory] = SysMsgType.Story,
} 

local SystemMsgFilterTypes = {
    {
        SysType = SysMsgType.All,
		NameUkey = 50013, -- "全部"
    },
    {
        SysType = SysMsgType.Notice,
		NameUkey = 50014, -- "系统通知"
    },
    {
        SysType = SysMsgType.Battle,
		NameUkey = 50015, -- "战斗信息"
    },
    {
        SysType = SysMsgType.Story,
		NameUkey = 50036, -- "剧情信息"
    },
}

local PrivateItemType = {
    All     	= 1,
    Friend  	= 2,
    NotFriend 	= 3,
}

local PrivateFilterTypes = {
    {
        Type = PrivateItemType.All,
		Name = LSTR(50013), -- "全部"
    },
    {
        Type = PrivateItemType.Friend,
		Name = LSTR(50016), -- "游戏好友"
    },
    {
        Type = PrivateItemType.NotFriend,
		Name = LSTR(50017), -- "非好友"
    },
} 

local HyperlinkLocationType = {
	MyLocation 	= 1,
	OpenMap 	= 2,
}

local HyperlinkLocationFlag = "{pos}"
local HyperlinkLocationPattern = '<a [^>]+ linkid="[0-9]+" underline="false">{pos}</>'

local ChatMacros = {
	TeamRecruit = "{pfinfer}", --队伍招募超链接
}

local MsgItemSortFunc = function(lhs, rhs)
	if lhs.Time ~= rhs.Time then
		return lhs.Time < rhs.Time
	end

	if lhs.SortID ~= rhs.SortID then
		return lhs.SortID < rhs.SortID
	end

	return false
end

local function ServerMsgSortFunc(lhs, rhs)
	if lhs.Time ~= rhs.Time then
		return lhs.Time < rhs.Time
	end

	return false
end

-- 打开聊天界面来源类型
local OpenSource = {
	ArmyWin = 1, -- 部队界面
	LinkShellWin = 2, -- 通讯贝界面
}

local BarWidgetIndex = {
	KeyboardInit = 0, -- 键盘初始状态, "键盘输入" 
	Input = 1, -- 输入状态
	RecordToText = 2, -- 录音转文字状态
	Voice = 3, -- 语音状态 
	Recroding = 4, -- 录音状态
}

local NewbieMemberType = {
    All = 1,
    NewcomerAndReturner = 2, -- 新人和回归者
    Mentor 	= 3, -- 指导者
}

local NewbieMemberFilterConfig = {
    {
        Type = NewbieMemberType.All,
		NameUkey = 50143, -- "全部参与者"
    },
    {
        Type = NewbieMemberType.NewcomerAndReturner,
		NameUkey = 50144, -- "新人和回归者"
    },
    {
        Type = NewbieMemberType.Mentor,
		NameUkey = 50145, -- "指导者"
    },
}

--战斗记录类型
local SysChatMsgBattleType = {
	AttackEffectChange = 1,
	BuffUpdate = 2,
	UseItem = 3,
	MajorRevive = 4,
	MajorDie = 5,
}

-- "- %m月%d日 %H:%M -"
local MsgTimeFormat = LSTR(50072)

local ChannelState = {
    Joining    = 1,    -- 加入中（初始化/主动进入）
    Exited     = 2,    -- 已退出（主动离开）
    Closed     = 3,    -- 已关闭（管理员操作）
    Deleted    = 4     -- 已删除（实体移除）
}

local DefaultPublicChannels = {
	ChatChannel.Comprehensive,
	ChatChannel.Recruit,
	ChatChannel.Newbie,
	ChatChannel.Army,
	ChatChannel.System,
	ChatChannel.Nearby,
	ChatChannel.Area,
}

--- 默认聊天开关设置
local DefaultOpenSetting = {	
	PrivateRedDotTip = {true, true}, 	-- 私聊红点提示， {迷宫内，迷宫外}
	PrivateSidebar = {false, true}, 	-- 私聊侧边栏， {迷宫内，迷宫外}
	PrivateDanmaku = {false, true}, 	-- 私聊弹幕， {迷宫内，迷宫外}
	TeamDanmaku = {true, true}, 		-- 队伍弹幕， {迷宫内，迷宫外}
}

-- ID值取自于 "H红点表.xlsx|红点名字表"
local SetTipsRedDotID = 92

local ChatDefine = {
	ChatMsgEntryWidgetIndex = ChatMsgEntryWidgetIndex,
	ChatCategory 			= ChatCategory,
	ChatMsgType				= ChatMsgType,
	ParseEmojisMsgTypeMap	= ParseEmojisMsgTypeMap,
	ChatChannel 			= ChatChannel,
	ChatChannelConfig 		= ChatChannelConfig,
	ShowMsgTimeInterval 	= ShowMsgTimeInterval,
	MaxHistoryTextNum 		= MaxHistoryTextNum,
	MaxRecentGifNum 		= MaxRecentGifNum,
	ChatChannelColor 		= ChatChannelColor,
	SettingSortChannels		= SettingSortChannels,
	ChatDefaultSetting 		= ChatDefaultSetting,
	SysMsgType 				= SysMsgType,
	SystemMsgFilterTypes 	= SystemMsgFilterTypes,
	MaxHyperlinkNum 		= MaxHyperlinkNum,
	MaxPrivateSessionNum 	= MaxPrivateSessionNum,
	PrivateSessionTrimNum	= PrivateSessionTrimNum,
    PrivateItemType 		= PrivateItemType,
    PrivateFilterTypes 		= PrivateFilterTypes,
	HyperlinkLocationType	= HyperlinkLocationType,

	HyperlinkLocationFlag 	= HyperlinkLocationFlag,
	HyperlinkLocationPattern = HyperlinkLocationPattern,

	MaxNumVoiceFileStorePublic	= MaxNumVoiceFileStorePublic,
	MaxNumVoiceFileStorePrivate	= MaxNumVoiceFileStorePrivate,
	NewbieChannelLowestLevel = NewbieChannelLowestLevel,

	PrivateUnredRedDotID = PrivateUnredRedDotID,
	PionnerChannelCloseShowTime = PionnerChannelCloseShowTime,

	ChatMacros = ChatMacros,
	MsgItemSortFunc = MsgItemSortFunc,
	ServerMsgSortFunc = ServerMsgSortFunc,
	OpenSource = OpenSource,
	BarWidgetIndex = BarWidgetIndex,

	MapChatMsgTypeAndSysMsgType = MapChatMsgTypeAndSysMsgType,
	NewbieMemberType = NewbieMemberType,
	NewbieMemberFilterConfig = NewbieMemberFilterConfig,

	MsgTimeFormat = MsgTimeFormat,

	SysChatMsgBattleType = SysChatMsgBattleType,
	ChannelState = ChannelState,
	DefaultPublicChannels = DefaultPublicChannels,
	DefaultOpenSetting = DefaultOpenSetting,
	SetTipsRedDotID = SetTipsRedDotID,
}

return ChatDefine