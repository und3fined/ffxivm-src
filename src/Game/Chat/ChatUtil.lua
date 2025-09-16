---
--- Author: anypkvcai
--- DateTime: 2021-12-07 10:10
--- Description:
---

local MajorUtil = require("Utils/MajorUtil")
local ChatEmojiCfg = require("TableCfg/ChatEmojiCfg")
local ChatGifCfg = require("TableCfg/ChatGifCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local PathMgr = require("Path/PathMgr")
local Json = require("Core/Json")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatSetting = require("Game/Chat/ChatSetting")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local MapUtil = require("Game/Map/MapUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local ChatMsgType = ChatDefine.ChatMsgType
local ChatChannelConfig = ChatDefine.ChatChannelConfig
local ChatMacros = ChatDefine.ChatMacros
local ChatChannel = ChatDefine.ChatChannel
local HyperlinkLocationFlag = ChatDefine.HyperlinkLocationFlag
local HyperlinkLocationPattern = ChatDefine.HyperlinkLocationPattern

local LSTR = _G.LSTR

---@class ChatUtil
local ChatUtil = {
	IsCheckPrivateChatDir = true,
	IsOpenEmoji = nil,
}

function ChatUtil.GetChannelName(Channel)
	local Config = ChatUtil.FindChatChannelConfig(Channel)
	if nil == Config then
		return ""
	end

	return Config.Name
end

function ChatUtil.FindChatChannelConfig(Channel)
	for _, v in ipairs(ChatChannelConfig) do
		if v.Channel == Channel then
			return v
		end
	end
end

---获取消息数据的扩展内容
---@param ChannelType ChatDefine.ChatChannel @渠道类型
---@return string @扩展内容字符串
function ChatUtil.GetMsgExtend(ChannelType)
	local Extends = {}

	-- 公会阶级ID
	if ChannelType == ChatChannel.Army then
		Extends.ArmyRankID = (_G.ArmyMgr:GetSelfRoleInfo() or {}).CategoryID
	end

	local MajorRoleVM = MajorUtil.GetMajorRoleVM()
	if MajorRoleVM then
		-- 玩家状态信息, {玩家身份，玩家主动设置的在线状态ID, 玩家在线状态}
		Extends.Status = {MajorRoleVM.Identity, MajorRoleVM.OnlineStatusCustomID, MajorRoleVM.OnlineStatus} 

		-- 当前服务器ID
		Extends.CurWorldID = MajorRoleVM.CurWorldID
	end

	if table.empty(Extends) then
		return
	end

	local Str = Json.encode(Extends)
	return Str
end

---解析消息扩展内容数据
---@param StrExtend string @扩展内容字符串
---@return table @扩展内容
function ChatUtil.ParseMsgExtendData(StrExtend)
	local Ret = string.isnilorempty(StrExtend) and {} or Json.decode(StrExtend)
	return Ret
end

function ChatUtil.GetPrivateChatDir()
	-- 检查私聊缓存文件目录
	local Dir = string.format("%s/Chat/%s", _G.FDIR_PERSISTENT(), MajorUtil.GetMajorRoleID())
	if ChatUtil.IsCheckPrivateChatDir then
		if not PathMgr.ExistDir(Dir) then
			PathMgr.CreateDir(Dir, false)
		end

		ChatUtil.IsCheckPrivateChatDir = false
	end

	return Dir 
end

function ChatUtil.GetPrivateLogFilePath(ChannelID)
	return string.format("%s/%s.log", ChatUtil.GetPrivateChatDir(), ChannelID)
end

function ChatUtil:GetPrivateSessionFilePath()
	return string.format("%s/PrivateSessions.dat", ChatUtil.GetPrivateChatDir())
end

function ChatUtil.GetVoiceMsgBgWidth( VoiceLength )
	if VoiceLength <= 2 then
		return 140

	elseif VoiceLength > 2 and VoiceLength < 14 then
		return 140 + (VoiceLength - 2) * 20

	else
		return 380 
	end
end

function ChatUtil.GetVoiceIconRichText()
	local Path = "/Game/UI/Atlas/Main/Frames/UI_Main_Chat_Icon_Voice_png.UI_Main_Chat_Icon_Voice_png"
	return RichTextUtil.GetTexture(Path, 40, 40, -8) or ""
end

function ChatUtil.GetDiffServerIconRichText()
	local Path = "/Game/UI/Atlas/Main/Frames/UI_Main_Chat_Icon_CorssServer_png.UI_Main_Chat_Icon_CorssServer_png"
	return RichTextUtil.GetTexture(Path, 40, 40, -8) or ""
end

--- 获取状态图标富文本
---@param Channel number @频道ID
---@param Identity Bitset @玩家身份
---@param StatusID number @玩家主动设置的在线状态ID
---@param OnlineStatus number @在线状态
function ChatUtil.GetStatusIconRichText(Channel, Identity, StatusID, OnlineStatus)
	local Icon = ChatUtil.GetStatusIcon(Channel, Identity, StatusID, OnlineStatus)
	if nil == Icon then
		return ""
	else
		return RichTextUtil.GetTexture(Icon, 40, 40, -10) or ""
	end
end

--- 获取状态图标
---@param Channel number @频道ID
---@param Identity number @身份
---@param StatusID number @在线状态ID
---@param OnlineStatus number @在线状态
function ChatUtil.GetStatusIcon(Channel, Identity, StatusID, OnlineStatus)
	if Channel == ChatChannel.Newbie then
		return OnlineStatusUtil.GetChatNewbieChannelStatusIcon(Identity, StatusID, OnlineStatus)

	elseif Channel == ChatChannel.Team or Channel == ChatChannel.SceneTeam then
		return OnlineStatusUtil.GetChatTeamChannelStatusIcon(Identity, StatusID, OnlineStatus)

	elseif Channel == ChatChannel.Recruit then
		return OnlineStatusUtil.GetChatRecruitChannelStatusIcon(Identity, StatusID, OnlineStatus)

	else
		return OnlineStatusUtil.GetChatChannelStatusIcon(Identity, StatusID, OnlineStatus)
	end
end

function ChatUtil.IsOpenEmojiModule()
	local Ret = ChatUtil.IsOpenEmoji
	if Ret ~= nil then 
		return Ret
	end

	Ret = ChatEmojiCfg:FindCfgByKey(1) ~= nil

	ChatUtil.IsOpenEmoji = Ret

	return Ret
end

--- 获取Emoji表情富文本
---@param ID number
function ChatUtil.GetEmojiIconRichText(ID)
	local Cfg = ChatEmojiCfg:FindCfgByKey(ID)
	if nil == Cfg then
		return
	end

	local Path = Cfg.Icon
	if string.isnilorempty(Path) then
		return
	end

	return RichTextUtil.GetTexture(Path, 48, 48, -12)
end

--- 获取Gif表情富文本
---@param GifID number @ Gif表情ID
function ChatUtil.GetGifRichText(GifID)
	local Path = ChatGifCfg:GetIcon(GifID)
	if string.isnilorempty(Path) then
		return
	end

	return RichTextUtil.GetTexture(Path, 48, 48, -12)
end

---分析处理Emoji表情
---@param Text string @消息文本
---@return string
function ChatUtil.ParseEmojis(Text)
	if not ChatUtil.IsOpenEmojiModule() then
		return Text
	end

	if string.isnilorempty(Text) then
		return Text
	end

	if not string.find(Text, '&%d+') then
		return Text
	end

	local NewText = Text 

	for k, _ in string.gmatch(NewText, "&(%d+)") do
		local RtText = ChatUtil.GetEmojiIconRichText(tonumber(k))
		if RtText then
			NewText = string.gsub(NewText, "&" .. k, RtText, 1)
		end
	end

	return NewText
end

--- 获取新人超链接内容文本
---@param Newbie cschatc.NewbieMessage @新人超链接数据信息
---@param NameColor string @玩家名颜色
function ChatUtil.GetNewbieHrefContentText(Newbie)
	local Ret = ""

	if nil == Newbie then
		return Ret
	end

	local Channel = ChatChannel.Newbie

	-- 图标富文本 
	local IconRText = ChatUtil.GetStatusIconRichText(Channel, Newbie.Identity, Newbie.StatusID)
	local TargetIconRText = ChatUtil.GetStatusIconRichText(Channel, Newbie.TargetIdentity, Newbie.TargetStatusID)

	-- 玩家名
	local NameColor = "4d85b4"
	local Name = RichTextUtil.GetText(Newbie.Name, NameColor) or ""
	local TargetName = RichTextUtil.GetText(Newbie.TargetName, NameColor) or ""

	-- 原因
	local Remark = Newbie.Remark
	if string.isnilorempty(Remark) then
		-- "%s被%s移出新人频道。"
		Ret = string.format(LSTR(50032), TargetIconRText .. TargetName, IconRText .. Name)
	else
		-- "%s被%s移出新人频道。
		-- 原因:%s "
		Ret = string.format(LSTR(50033), TargetIconRText .. TargetName, IconRText .. Name, Remark)
	end

	return Ret
end

function ChatUtil.GetTeamRecruitMacro()
	return ChatMacros.TeamRecruit
end

function ChatUtil.GetChatSimpleDesc(MsgItemVM)
	if nil == MsgItemVM then
		return
	end

	local Ret = ""
	local Content = MsgItemVM:GetContent()
	Content = string.gsub(Content, "[\n\r\t]", "") 

	local MsgType = MsgItemVM:GetMsgType()
	if MsgType ==  ChatMsgType.EmotionTips then -- 情感动作
		Ret = Content

	else
		local Channel = MsgItemVM:GetChannel()
		local ChannelID = MsgItemVM:GetChannelID()
		local ChannelName = "" 
		if Channel ~= ChatChannel.Person then -- 私聊无标签
			ChannelName = _G.ChatVM:GetChannelRealName(Channel, ChannelID) 
			local Color = ChatSetting.GetChannelColor(Channel, ChannelID)
			ChannelName = RichTextUtil.GetText(string.format("[%s]", ChannelName), Color)
		end

		local RoleName = "" 
		local OnlineStatusIconRText = ""

		if MsgType == ChatMsgType.RemovedNewbie then -- 玩家被从新人频道移除公告消息
		else
			if MsgType == ChatMsgType.Voice then -- 语音
				Ret = ChatUtil.GetVoiceIconRichText()

			elseif MsgType == ChatMsgType.Gif then -- Gif表情
				Ret = ChatUtil.GetGifRichText(MsgItemVM.GifID)
				Content = ""

			elseif MsgType == ChatMsgType.TeamRecruit then -- 队伍招募
				Content = ChatUtil.GetTeamRecruitHrefDesc(MsgItemVM.TeamRecruitMsg)

			elseif MsgType == ChatMsgType.TaskShare then -- 任务分享
				Content = ChatUtil.GetTaskShareDesc(MsgItemVM.TaskMsg)
			end

			local Extend = nil 
			local Sender = MsgItemVM.Sender
			if Sender and Sender > 0 then
				local RoleVM = _G.RoleInfoMgr:FindRoleVM(Sender)
				if RoleVM then
					if RoleVM.IsMajor or Channel == ChatChannel.Person then
						RoleName = string.format("%s:", RoleVM.Name)
					else
						Extend = ChatUtil.ParseMsgExtendData(MsgItemVM.Extend) or {}
						local CurWorldID = Extend.CurWorldID
						if CurWorldID and CurWorldID > 0 and CurWorldID ~= _G.PWorldMgr:GetCurrWorldID() then
							RoleName = string.format("%s%s:", RoleVM.Name, ChatUtil.GetDiffServerIconRichText())
						else
							RoleName = string.format("%s:", RoleVM.Name)
						end
					end
				end
			end

			--  新人频道需要显示指导者状态图标
			if Channel == ChatChannel.Newbie then
				if nil == Extend then
					Extend = ChatUtil.ParseMsgExtendData(MsgItemVM.Extend) or {}
				end

				local Status = Extend.Status
				OnlineStatusIconRText = ChatUtil.GetStatusIconRichText(Channel, Status[1], Status[2], Status[3])
			end
		end

		Ret = string.format("%s%s%s%s%s", ChannelName, OnlineStatusIconRText, RoleName, Ret, Content)
	end

	return Ret
end

function ChatUtil.GetChatContent(MsgItemVM)
	if nil == MsgItemVM then
		return
	end

	local Ret = ""
	local Content = MsgItemVM:GetContent()
	Content = string.gsub(Content, "[\n\r\t]", "") 

	local MsgType = MsgItemVM:GetMsgType()
	if MsgType ==  ChatMsgType.EmotionTips then -- 情感动作
		Ret = Content

	else
		if MsgType == ChatMsgType.RemovedNewbie then -- 玩家被从新人频道移除公告消息
		else
			if MsgType == ChatMsgType.Voice then -- 语音
				Ret = ChatUtil.GetVoiceIconRichText()

			elseif MsgType == ChatMsgType.Gif then -- Gif表情
				Ret = ChatUtil.GetGifRichText(MsgItemVM.GifID)
				Content = ""

			elseif MsgType == ChatMsgType.TeamRecruit then -- 队伍招募
				Content = ChatUtil.GetTeamRecruitHrefDesc(MsgItemVM.TeamRecruitMsg)

			elseif MsgType == ChatMsgType.TaskShare then -- 任务分享
				Content = ChatUtil.GetTaskShareDesc(MsgItemVM.TaskMsg)
			end
		end

		Ret = string.format("%s%s", Ret, Content)
	end

	return Ret
end

--- 获取队伍招募超链接文本描述
---@param Data cschatc.TeamRecruitMessage @队伍招募超链接数据信息
function ChatUtil.GetTeamRecruitHrefDesc(Data)
	if nil == Data then
		return ""
	end

	local Path = "/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_RecruitCard_png.UI_Chat_Icon_RecruitCard_png"
	local RichText1 = RichTextUtil.GetTexture(Path, 40, 40, -10) or ""
	
	local MemLocList = Data.LocList or {}
	local RecruitedMems = table.find_all_by_predicate(MemLocList, function(e) return e == 1 end) or {}

	local Cfg = TeamRecruitCfg:FindCfgByKey(Data.ResID) or {}
	local Desc = TeamRecruitUtil.IsRecruitUnlocked(Data.ResID) and (Cfg.TaskName or "") or LSTR(50035)  -- "未解锁招募内容"
	local Ret = string.format('%s<span color="#A4FFFFFF">%s[%s/%s]</>', RichText1, Desc, #RecruitedMems, #MemLocList)
	return Ret
end

--- 获取任务分享描述
---@param Data cschatc.TaskHrefMessage @任务分享超链接数据信息
function ChatUtil.GetTaskShareDesc(Data)
	local Ret = ""
	if nil == Data then
		return Ret 
	end

	local Info = _G.QuestMgr:GetShareInfo(Data.TaskID)
	if nil == Info then
		return Ret 
	end

	local Path = "/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_TaskCard_png.UI_Chat_Icon_TaskCard_png"
	local LinkIconRT = RichTextUtil.GetTexture(Path, 40, 40, -10) or ""
	local NonActivatedTaskDesc = LSTR(50021) --"未解锁任务"
	Ret = string.format('%s<span color="#A4FFFFFF">%s</>', LinkIconRT, Info.IsActive and (Info.Name or "") or NonActivatedTaskDesc)

	return Ret 
end

function ChatUtil.GetLocationShareIconRichText()
	local Path = "/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_Loction2_png.UI_Chat_Icon_Loction2_png"
	return RichTextUtil.GetTexture(Path, 40, 40, -10)
end

--- 获取位置分享描述
---@param Content string @文本内容
---@param MapMsg hreF.MapMessage @地图超链信息
function ChatUtil.GetLocationShareDesc(Content, Map)
	local Ret = ""
	if nil == Map then
		return Ret
	end

	local MapID = Map.MapID 
	if nil == MapID or MapID <= 0 then
		return Ret
	end

	local LocDesc = string.format("%s(%.1f,%.1f)", MapUtil.GetChatHyperlinkMapName(MapID) or "", Map.X or 0, Map.Y or 0)
	local LinkIconRT = ChatUtil.GetLocationShareIconRichText() 

	Content = string.gsub(Content or "", HyperlinkLocationPattern, function(str)
		return LinkIconRT .. string.gsub(str, HyperlinkLocationFlag, LocDesc)
	end)

	return Content
end

--- 获取物品聊天功能中的描述（含超链)
---@param ResID 物品ResID
---@param LinkID number @超链接ID，默认1
function ChatUtil.GetGoodsChatDesc(ResID, LinkID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		_G.FLOG_WARNING("ChatUtil.GetGoodsDesc can't find item cfg, ResID =%d", ResID)
		return
	end

	local Name = string.format("[%s]", ItemCfg:GetItemName(ResID))
	local Ret = RichTextUtil.GetHyperlink(Name, LinkID or 1, ItemUtil.GetItemQualityColor(Cfg.ItemColor), nil, nil, nil, nil, nil, false)
	return Ret 
end

-------------------------------------------------------------------------------------------------
--- TLOG数据埋点

---@type 语音功能使用上报
---@param ChannelType CHANNEL_TYPE_DEFINE @聊天频道类型
---@param SpeechType number @类型 1-语音转文字，2-语音
---@param SpeechToTextResult number @当Type为1时，转换结果(0-失败，1-成功)
function ChatUtil.ReportVoiceData(ChannelType, SpeechType, SpeechToTextResult)
	local DataReportUtil = require("Utils/DataReportUtil")
    DataReportUtil.ReportData("SpeechtotextFlow", true, false, true,
        "ChatType", 	tostring(ChannelType) or "",
        "SpeechType", 	tostring(SpeechType) or "",
        "Result", 		tostring(SpeechToTextResult) or "")
end

-------------------------------------------------------------------------------------------------

function ChatUtil.ChannelPosToSortID(Pos)
	if nil == Pos then
		return 999
	end

	return Pos * 100
end

function ChatUtil.GetChannelPos(Channel)
	if nil == Channel then
		return
	end

	local PosMap = ChatSetting.ChannelPosMap or {}
	local Pos = PosMap[Channel]
	if nil == Pos then
		local Config = ChatUtil.FindChatChannelConfig(Channel)
		if Config then
			Pos = Config.Pos 
		end
	end

	return Pos
end

function ChatUtil.GetChannelSortID(Channel)
	if nil == Channel then
		return
	end

	local Pos = ChatUtil.GetChannelPos(Channel) 
	return ChatUtil.ChannelPosToSortID(Pos) 
end

function ChatUtil.IsHideChannel(Channel)
	if nil == Channel then
		return true
	end

	--ToDo.. 临时处理
	if Channel == ChatChannel.SceneTeam then
		Channel = ChatChannel.Team
	end

	local Channels = ChatSetting.HideChannels
	if table.is_nil_empty(Channels) then
		return false
	end

	local Value = table.find_by_predicate(Channels, function(v)
		return v == Channel
	end)

	return Value ~= nil
end

function ChatUtil.GetPioneerChannelSpeakLevel()
	local Data = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GlobalCfgVanGuardChannelSpeakLevel, "Value")
	if nil == Data then
		return 50
	end

	return tonumber(Data[1]) or 50 
end

return ChatUtil