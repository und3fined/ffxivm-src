local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local ExistAttachIcon = "PaperSprite'/Game/UI/Atlas/Mail/Frames/UI_Mail_Icon_UnReceive_png.UI_Mail_Icon_UnReceive_png'"
local NoExistAttachIcon = "PaperSprite'/Game/UI/Atlas/Mail/Frames/UI_Mail_Icon_Receive_png.UI_Mail_Icon_Receive_png'"
local UnReadIcon = "PaperSprite'/Game/UI/Atlas/Mail/Frames/UI_Mail_Icon_UnBrowse_png.UI_Mail_Icon_UnBrowse_png'"
local ReadIcon = "PaperSprite'/Game/UI/Atlas/Mail/Frames/UI_Mail_Icon_Browse_png.UI_Mail_Icon_Browse_png'"

local OutBoxMailIcon = "PaperSprite'/Game/UI/Atlas/Mail/Frames/UI_Mail_Icon_Gift_Give_png.UI_Mail_Icon_Gift_Give_png'"

local FirstFlyInStep1AnimPath = "AnimSequence'/Game/Assets/Character/Demihuman/d1013/Animation/a0001/event/A_d1013a0001_event-cbfm_item.A_d1013a0001_event-cbfm_item'"
local FirstFlyInStep2AnimPath = "AnimSequence'/Game/Assets/Character/Demihuman/d1013/Animation/a0001/event/A_d1013a0001_event-cbfm_greeting.A_d1013a0001_event-cbfm_greeting'"
local FirstFlyInStep4AnimPath = "AnimSequence'/Game/Assets/Character/Demihuman/d1013/Animation/a0102/normal/A_d1013a0102_normal-cbnm_id0.A_d1013a0102_normal-cbnm_id0'" 

---   点击
local ClickAnimPath = {
	"AnimSequence'/Game/Assets/Character/Demihuman/d1013/Animation/a0001/event/A_d1013a0001_event-cbfm_joy_big.A_d1013a0001_event-cbfm_joy_big'",
	"AnimSequence'/Game/Assets/Character/Demihuman/d1013/Animation/a0001/event/A_d1013a0001_event-cbfm_disappoint.A_d1013a0001_event-cbfm_disappoint'",
	"AnimSequence'/Game/Assets/Character/Demihuman/d1013/Animation/a0001/event/A_d1013a0001_event-cbfm_talk_angry.A_d1013a0001_event-cbfm_talk_angry'"
}

local NewMailNotifyAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_notice_new.Play_SE_UI_SE_UI_notice_new'"
local FlyInAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/bgcommon/sound/hou/hou_spot_Mog_DollEx_on/Play_hou_spot_Mog_DollEx_on_new.Play_hou_spot_Mog_DollEx_on_new'"

local  ClickAudioPathList = {
	"AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/mon/3098/Play_3098_SE_Foot_Fly_new.Play_3098_SE_Foot_Fly_new'",
	"AkAudioEvent'/Game/WwiseAudio/Events/sound/event/SE_Event_068/Play_SE_Event_068_new.Play_SE_Event_068_new'"
}

local LSTR = _G.LSTR

-- RedDot
local MailMenuRedDotID = 11


---@class MailType @邮件类型
local MailType = {
	System = ProtoRes.MailType.MailTypeSystem, -- 系统
	Gift = ProtoRes.MailType.MailTypeGift, -- 赠礼
}

---@class MailBoxType @邮件箱类型
local MailBoxType = {
	InBox = 0,        	-- 收件箱
	OutBox = 1,			-- 发件箱
}

-- 邮件后台重构后没有发件箱的概念，这个设置各类型对应的发件箱id
---@class OutBoxMailID 
local OutBoxMailID = {
	{ InBoxID = MailType.Gift, OutBoxID = ProtoRes.RoleMailType.RoleMailTypeOutboxGift },
}

---@class MailType @邮件类型信息
local MailTypeInfo = {
	[MailType.System] = {
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Mail_System.UI_Icon_Tab_Mail_System'",
		NameText = ProtoEnumAlias.GetAlias(ProtoRes.MailType, MailType.System or ""),
		PanelEmptyText = LSTR(740010),
		OutBoxPanelEmptyText = LSTR(740010),
	},

	[MailType.Gift] = {
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Mail_Gift.UI_Icon_Tab_Mail_Gift'",
		NameText =  ProtoEnumAlias.GetAlias(ProtoRes.MailType, MailType.Gift or ""),
		PanelEmptyText = LSTR(740008),
		OutBoxPanelEmptyText = LSTR(740009),
	},
}

---@class MailDefine
local MailDefine = {
	MailType = MailType,
	MailBoxType = MailBoxType,
	OutBoxMailID = OutBoxMailID,
	MailTypeInfo = MailTypeInfo,
	ExistAttachIcon = ExistAttachIcon,
	NoExistAttachIcon = NoExistAttachIcon,
	UnReadIcon = UnReadIcon,
	ReadIcon = ReadIcon,
	OutBoxMailIcon = OutBoxMailIcon,

	FirstFlyInStep1AnimPath = FirstFlyInStep1AnimPath,
	FirstFlyInStep2AnimPath = FirstFlyInStep2AnimPath,
	FirstFlyInStep4AnimPath = FirstFlyInStep4AnimPath,
	ClickAnimPath = ClickAnimPath,

	FlyInAudioPath = FlyInAudioPath,
	ClickAudioPathList = ClickAudioPathList,	
	NewMailNotifyAudioPath = NewMailNotifyAudioPath,
	MailMenuRedDotID = MailMenuRedDotID,
}

return MailDefine


--[[       邮件多语言id 内容注释
    740001,    --%Y年%m月%d日
    740002,    --%s已达上限，是否继续领取当前邮件?
    740003,    --亲爱的%s:
    740004,    --删除成功
    740005,    --提示
    740006,    --时间: %s
    740007,    --暂不领取
    740008,    --暂无礼物库啵
    740009,    --暂无赠礼记录库啵
    740010,    --暂无邮件库啵
    740011,    --未找到目标邮件
    740012,    --来自%s的礼物
    740013,    --来自: %s
    740014,    --继续领取
    740015,    --获得物品
    740016,    --距离过期: %s
	740017,    --莫古邮件
	740018,    --赠礼
	740019,    --收到礼物
	740020,    --赠礼记录
	740021,    --打开礼物
	740022,    --（请清理邮件，避免超上限丢失）
]]--
