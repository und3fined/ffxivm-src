---
--- Author: loiafeng
--- DateTime: 2023-03-29 15:58
--- Description:
---

local ProtoRes = require("Protocol/ProtoRes")
local ProtoOnlineStatusRes = ProtoRes.OnlineStatus
local ProtoOnlineStatusIdentify = ProtoRes.OnlineStatusIdentify
--local StatusUpdateNotifyID = 999999

local UnverifiedMentorIcon = "PaperSprite'/Game/UI/Atlas/OnlineStatus/Frames/UI_OnlineStatus_Icon_NotReset1_png.UI_OnlineStatus_Icon_NotReset1_png'"

-- 通知文本
local NotifyText = {
    EnterLeave =        730002,             --一段时间内没有进行任何操作，已经自动切换为离开状态。
    QuitLeave =         730008,             --离开状态已经解除。
    StatusChanged =     730003,             --个人信息已更新。
    StatusChangedFail = 730004,             --个人信息更新失败。
    StatusDisappear =   730001,             --%s已失效。
    OnlineStatusTitle = 730005,             --在线状态。
    DisappearTime =     730006,             --将于%Y年%m月%d日失效。
    MentorConfirmContent = 730009,          --<span color="#d5d5d5FF">将在线状态设置为“指导者”。</> ...
    SettingConfirm =    730010,             --设置确认
    Refresh =           730011,             --更  新
    CurStatusText =     730012,             --当前状态:
}

-- 场景中忽略以下在线状态
local VisionStatusIgnore = {
	[ProtoOnlineStatusRes.OnlineStatusCloseTask] = true,
	[ProtoOnlineStatusRes.OnlineStatusOffline] = true,
	[ProtoOnlineStatusRes.OnlineStatusOnline] = true,
}

-- 队友相关状态在线状态
local TeammatesStatus = {
	[ProtoOnlineStatusRes.OnlineStatusCaptain] = true,
	[ProtoOnlineStatusRes.OnlineStatusTeamMem] = true,
	[ProtoOnlineStatusRes.OnlineStatusSceneCaptain] = true,
    [ProtoOnlineStatusRes.OnlineStatusSceneTeamMem] = true,
}

--异常状态
local ExceptionStatus = {
	[ProtoOnlineStatusRes.OnlineStatusElectrocardiogram] = true,
	[ProtoOnlineStatusRes.OnlineStatusCutscene] = true,
	[ProtoOnlineStatusRes.OnlineStatusOffline] = true,
}

--玩家 忽略后台发送自己的相关状态
local MajorStatusIgnore = {
	[ProtoOnlineStatusRes.OnlineStatusElectrocardiogram] = true,
	[ProtoOnlineStatusRes.OnlineStatusOffline] = true,
}

--指导者/回归者/新人相关状态集合  不包含 未认证相关状态
local MentorReturnerNewbieStatus = {
	[ProtoOnlineStatusRes.OnlineStatusNewHand] = true,
	[ProtoOnlineStatusRes.OnlineStatusJoinNewbieChannel] = true,
    [ProtoOnlineStatusRes.OnlineStatusMentor] = true,
	[ProtoOnlineStatusRes.OnlineStatusCombatMentor] = true,
    [ProtoOnlineStatusRes.OnlineStatusMakeMentor] = true,
	[ProtoOnlineStatusRes.OnlineStatusFightMentor] = true,
    [ProtoOnlineStatusRes.OnlineStatusReturner] = true,
}

--未认证指导者相关身份 
local UnverifiedMentorIdentitys = {
    [ProtoOnlineStatusIdentify.OnlineStatusIdentifyUnverifiedMentor] = true,
	[ProtoOnlineStatusIdentify.OnlineStatusIdentifyUnverifiedBattleMentor] = true,
    [ProtoOnlineStatusIdentify.OnlineStatusIdentifyUnverifiedMakeMentor] = true,
}

--指导者相关状态集合
local MentorStatus = {
	[ProtoOnlineStatusRes.OnlineStatusMentor] = true,
	[ProtoOnlineStatusRes.OnlineStatusFightMentor] = true,
    [ProtoOnlineStatusRes.OnlineStatusRedFlowerMentor] = true,
	[ProtoOnlineStatusRes.OnlineStatusMakeMentor] = true,
    [ProtoOnlineStatusRes.OnlineStatusCombatMentor] = true,
}

--指导者相关身份集合
local MentorIdentitys = {
	[ProtoOnlineStatusIdentify.OnlineStatusIdentifyMentor] = true,
	[ProtoOnlineStatusIdentify.OnlineStatusIdentifyMakeMentor] = true,
    [ProtoOnlineStatusIdentify.OnlineStatusIdentifyRedFlowerMentor] = true,
	[ProtoOnlineStatusIdentify.OnlineStatusIdentifyBattleMentor] = true,
}


local OnlineStatusDefine = {
    ---状态更新的通知ID
    --StatusUpdateNotifyID = StatusUpdateNotifyID,

    ---未认证的指导者Icon路径
    UnverifiedMentorIcon = UnverifiedMentorIcon,
    ---场景中忽略的在线状态
    VisionStatusIgnore = VisionStatusIgnore,
    TeammatesStatus = TeammatesStatus,
    ExceptionStatus = ExceptionStatus,
    MajorStatusIgnore = MajorStatusIgnore,
    MentorReturnerNewbieStatus = MentorReturnerNewbieStatus,
    UnverifiedMentorIdentitys = UnverifiedMentorIdentitys,
    MentorStatus = MentorStatus,
    MentorIdentitys = MentorIdentitys,
    ---通知文本
    NotifyText = NotifyText
}


return OnlineStatusDefine