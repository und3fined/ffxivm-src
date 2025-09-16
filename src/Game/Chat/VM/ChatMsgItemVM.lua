---
--- Author: anypkvcai
--- DateTime: 2021-11-18 11:16
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local ProtoCS = require("Protocol/ProtoCS")
local ChatUtil = require("Game/Chat/ChatUtil")

local PARAM_TYPE_DEFINE = ProtoCS.PARAM_TYPE_DEFINE
local SPECIAL_TIPS_TYPE  = ProtoCS.SPECIAL_TIPS_TYPE
local ChatMsgEntryWidgetIndex = ChatDefine.ChatMsgEntryWidgetIndex
local ChatMsgType = ChatDefine.ChatMsgType
local MsgTimeFormat = ChatDefine.MsgTimeFormat
local ParseEmojisMsgTypeMap = ChatDefine.ParseEmojisMsgTypeMap

local LSTR = _G.LSTR

---@class ChatMsgItemVM : UIViewModel
local ChatMsgItemVM = LuaClass(UIViewModel)

---Ctor
function ChatMsgItemVM:Ctor()
	self.Sender = nil
	self.ID = nil 
	self.SysMsgID = nil 
	self.RawContent = nil
	self.Content = nil
	self.Channel = nil
	self.ChannelID = nil
	self.Time = nil
	self.TimeVisible = false 
	self.TimeText = nil
	self.ChatMsg = nil
	self.SortID = 0
	self.IsMajor = nil
	self.MsgType = ChatMsgType.Msg
	self.MsgData = nil
	self.Extend = nil
	self.ComprehensiveInvisible = nil -- 综合频道不可见
	self.ChannelTagVisible = nil

	-- 语音
	self.VoiceID = nil 
	self.VoiceLength = nil 
	self.VoiceLanguage = nil 

	-- Gif表情ID
	self.GifID = nil

	-- 队伍寻宝
	self.TreasureMapMsg = nil

	-- 队伍招募
	self.TeamRecruitMsg = nil

	-- 任务分享 
	self.TaskMsg = nil

	self.WidgetIndex = nil
end

function ChatMsgItemVM:AdapterOnGetWidgetIndex()
	return self.WidgetIndex or self:GetWidgetIndex()
end

function ChatMsgItemVM:IsEqualVM(Value)
	return self.ID == Value.ID 
		and self.Channel == Value.Channel
		and self.ChannelID == Value.ChannelID
		and self.Time == Value.Time
		and self.SortID == Value.SortID
end

function ChatMsgItemVM:GetWidgetIndex()
	local MsgType = self:GetMsgType() 
	if MsgType == ChatMsgType.Tips
		or MsgType == ChatMsgType.FriendTips 
		or MsgType == ChatMsgType.FriendRename
		or MsgType == ChatMsgType.RemovedNewbie 
		or MsgType == ChatMsgType.EmotionTips
		or MsgType == ChatMsgType.TextTipsCenter then

		return ChatMsgEntryWidgetIndex.TextMsg
	end

	local RoleID = self.Sender
	if 0 == RoleID then
		return ChatMsgEntryWidgetIndex.SystemMsg
	end

	if self.IsMajor then
		return ChatMsgEntryWidgetIndex.PlayerMsgRight
	else
		return ChatMsgEntryWidgetIndex.PlayerMsgLeft
	end
end

function ChatMsgItemVM:UpdateVM(Value)
	self.Channel = Value.Channel
	self.ChannelID = Value.ChannelID
	self.MsgType = Value.MsgType or ChatMsgType.Msg

	local ChatMsg = Value.ChatMsg
	self.ChatMsg = ChatMsg
	self.ID = ChatMsg.ID
	self.Time = ChatMsg.Time
	self.SortID = ChatMsg.SortID or 0

	local Sender = ChatMsg.Sender
	self.Sender = Sender
	self.IsMajor = Sender and Sender > 0 and MajorUtil.IsMajorByRoleID(Sender)

	self.TimeText = nil

	local Task = nil
	local Voice = nil
	local Map = nil
	local Newbie = nil
	local Gif = nil
	local SpecTips = nil
	local TeamRecruit = nil
	local TeamTreasureHunt = nil

	local MsgData = ChatMsg.Data
	self.MsgData = MsgData
	self.Extend = MsgData.Extend
	self.SysMsgID = MsgData.SysMsgID

	local ParamList = MsgData.ParamList -- 超链内容

	for _, v in ipairs(ParamList) do
		local Type = v.Type
		if Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TASK 		-- 任务 
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_VOICE 	-- 语音
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_MAP 		-- 位置
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_NEWBIE 	-- 新人
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_GIF		-- Gif表情
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_SPC_TIPS	-- 特殊提示 
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_RECRUIT	--  队伍招募
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_TREASUREHUNT	--  队伍寻宝 
		then
			local SimpleHref = _G.ChatMgr:DecodeChatParams(v.Param)
			if SimpleHref then
				Task 	= Task or SimpleHref.Task
				Voice 	= Voice or SimpleHref.Voice
				Map 	= Map or SimpleHref.Map
				Newbie 	= Newbie or SimpleHref.Newbie
				Gif 	= Gif or SimpleHref.Gif

				SpecTips 	= SpecTips or SimpleHref.SpecTips
				TeamRecruit = TeamRecruit or SimpleHref.TeamRecruit
				TeamTreasureHunt = TeamTreasureHunt or SimpleHref.TeamTreasureHunt
			end
		end
	end

	local Content = Value.Content
	self.RawContent = Content

	if Task then -- 任务分享
		self.TaskMsg = Task 
		self.MsgType = ChatMsgType.TaskShare

	elseif Voice then --语音
		local VoiceID = Voice.ID
		local VoiceLength = Voice.Length
		self.VoiceID = VoiceID 
		self.VoiceLength = VoiceLength
		self.VoiceLanguage = Voice.Language

		if not string.isnilorempty(VoiceID) then
			self.MsgType = ChatMsgType.Voice
		end

	elseif Map then --位置
		local MapID = Map.MapID 
		if MapID > 0 then
			self.MsgType = ChatMsgType.Location
			Content = ChatUtil.GetLocationShareDesc(Content, Map)
		end

	elseif Newbie then --新人
		Content = ChatUtil.GetNewbieHrefContentText(Newbie)
		self.MsgType = ChatMsgType.RemovedNewbie

	elseif Gif then --Gif表情
		self.GifID = (Gif or {}).ID
		self.MsgType = ChatMsgType.Gif

	elseif SpecTips then --特殊提示
		local Params = SpecTips.Params or {}
		local Type = SpecTips.Type
		if Type == SPECIAL_TIPS_TYPE.ACCEPT_FRIEND_APPLY then -- 接受好友申请
			self.MsgType = ChatMsgType.FriendTips
			Content = LSTR(50060) -- "- 已通过好友验证请求 -"
			self.ID = 0 -- 提示类的私聊信息无需客户端离线保存

		elseif Type == SPECIAL_TIPS_TYPE.RENAME then -- 好友改名
			self.MsgType = ChatMsgType.FriendRename
			local Fmt = LSTR(50134) -- - “%s”已更名为<span color="#7ECEF4FF">%s</> -
			Content = string.format(Fmt, Params[1] or "", Params[2] or "") 

		elseif Type == SPECIAL_TIPS_TYPE.APPLY_FRIEND_SUC then -- 申请添加好友成功 
			self.MsgType = ChatMsgType.FriendTips
			Content = LSTR(50098) -- "- 已通过好友申请 -"
			self.ID = 0 
		end

	elseif TeamRecruit then --队伍招募
		self.TeamRecruitMsg = TeamRecruit
		self.MsgType = ChatMsgType.TeamRecruit
	elseif TeamTreasureHunt then --队伍寻宝
		self.TreasureMapMsg = TeamTreasureHunt
	end

	local MsgType = self.MsgType

	-- Emoji表情
	if ParseEmojisMsgTypeMap[MsgType] then
		Content = ChatUtil.ParseEmojis(Content)
	end

	self.Content = Content

	local IsCompInvisible = MsgData.ComprehensiveInvisible
	if nil == IsCompInvisible then
		IsCompInvisible = MsgType == ChatMsgType.Tips or MsgType == ChatMsgType.TextTipsCenter
	end

	self.ComprehensiveInvisible = IsCompInvisible
	self.ChannelTagVisible = MsgData.ChannelTagVisible

	self.WidgetIndex = self:GetWidgetIndex()
end

function ChatMsgItemVM:GetChannel()
	return self.Channel
end

function ChatMsgItemVM:GetChannelID()
	return self.ChannelID
end

function ChatMsgItemVM:GetMsgType()
	return self.MsgType or ChatMsgType.Msg
end

function ChatMsgItemVM:GetSysMsgID()
	return self.SysMsgID
end

function ChatMsgItemVM:GetChatMsg()
	return self.ChatMsg
end

function ChatMsgItemVM:GetContent()
	return self.Content or ""
end

function ChatMsgItemVM:SetVoiceTranslateText(Text)
	if self.MsgType ~= ChatMsgType.Voice then
		return
	end

	self.Content = Text or ""
end

function ChatMsgItemVM:GetTime()
	return self.Time
end

function ChatMsgItemVM:SetTimeVisible(Visible)
	if Visible then
		self.TimeText = os.date(MsgTimeFormat, self.Time)
	end

	self.TimeVisible = Visible
end

-- 强制显示时间 
function ChatMsgItemVM:ForceShowTime()
	local MsgType = self.MsgType
	return MsgType == ChatMsgType.FriendTips or MsgType == ChatMsgType.FriendRename
end

--设置消息为历史消息
-- 历史消息（当前用于退出队伍后，仍然需要保存队伍聊天信息）
function ChatMsgItemVM:SetHistoryMsg(  )
	self.ChannelID = nil
	self.ID = nil 
end

function ChatMsgItemVM:IsComprehensiveInvisible()
	return self.ComprehensiveInvisible
end

function ChatMsgItemVM:IsOtherPlayerMsg()
	return self.WidgetIndex == ChatMsgEntryWidgetIndex.PlayerMsgLeft
end

return ChatMsgItemVM