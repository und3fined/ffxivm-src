--
-- Author: anypkvcai
-- Date: 2022-05-04 9:54
-- Description:
--

local ChatDefine = require("Game/Chat/ChatDefine")
local SaveKey = require("Define/SaveKey")
local Json = require("Core/Json")

local ChatChannelColor = ChatDefine.ChatChannelColor
local ChatDefaultSetting = ChatDefine.ChatDefaultSetting
local ChatChannel = ChatDefine.ChatChannel
local MapChatMsgTypeAndSysMsgType = ChatDefine.MapChatMsgTypeAndSysMsgType
local DefaultOpenSetting = ChatDefine.DefaultOpenSetting

local USaveMgr
local StrDefault = "default"

---@class ChatSetting
local ChatSetting = {
	ComprehensiveChannelBit = 0,
	ComprehensiveChannels = {}, -- 综合频道显示的频道
	ComprehensiveChannelSysMsgTypeBit = 0,
	ComprehensiveChannelSysMsgTypes = {}, -- 综合频道显示的系统消息类型
	ComprehensiveChannelBlockGroupIDs = {}, -- 综合频道屏蔽的通讯贝
	HideChannels = {}, -- 隐藏的频道
	ChannelPosMap = {}, -- 聊天频道显示位置
	ChannelColorIndices = {
		{ Channel = ChatChannel.Pioneer, ColorIndex = 1 },
		{ Channel = ChatChannel.Recruit, ColorIndex = 1 },
		{ Channel = ChatChannel.Newbie, ColorIndex = 1 },
		{ Channel = ChatChannel.Army, ColorIndex = 1 },
		{ Channel = ChatChannel.Area, ColorIndex = 1 },
		{ Channel = ChatChannel.Nearby, ColorIndex = 1 },
		{ Channel = ChatChannel.Team, ColorIndex = 1 },
		{ Channel = ChatChannel.System, ColorIndex = 1 },
	},
	GroupColorIndices = {}, -- 通讯贝频道标签颜色
	OpenPrivateRedDotTip = table.clone(DefaultOpenSetting.PrivateRedDotTip, true), -- 私聊红点提示
	OpenPrivateSidebar = table.clone(DefaultOpenSetting.PrivateSidebar, true), -- 私聊侧边栏
	OpenPrivateDanmaku = table.clone(DefaultOpenSetting.PrivateDanmaku, true), -- 私聊弹幕
	OpenTeamDanmaku = table.clone(DefaultOpenSetting.TeamDanmaku, true), -- 私聊弹幕
}

function ChatSetting.InitSetting()
	USaveMgr = _G.UE.USaveMgr

	local ParseSaveString = function(SKey)
		local Str = USaveMgr.GetString(SKey, StrDefault, false)
		if Str == StrDefault then
			return
		end

		local SplitStr = string.split(Str, ",")
		local Ret = {}

		for _, v in ipairs(SplitStr) do
			table.insert(Ret, tonumber(v))
		end

		return Ret
	end
	
	local ParseSaveStringJsonMap = function(SKey)
		local Str = USaveMgr.GetString(SKey, "", false)
		local Ret = {}
		if string.isnilorempty(Str) then
			return Ret
		end

		local Info = Json.decode(Str) or {}

		for _, v in pairs(Info) do
			if #v > 1 then
				local Key = v[1]
				if Key then
					Ret[Key] = v[2]
				end
			end
		end

		return Ret
	end

	-- 综合频道显示的频道
	ChatSetting.SetComprehensiveChannels(ParseSaveString(SaveKey.ChatComprehensiveChannel))

	-- 综合频道显示的系统消息类型
	ChatSetting.SetComprehensiveChannelSysMsgTypes(ParseSaveString(SaveKey.ChatComprehensiveChannelSysMsgType))

	-- 综合频道屏蔽的通讯贝ID
	ChatSetting.SetComprehensiveChannelBlockGroupIDs(ParseSaveString(SaveKey.ChatComprehensiveChannelBlockGroupID))

	-- 频道标签颜色
	do
		local IndicesStr = USaveMgr.GetString(SaveKey.ChatColorIndices, "", false)
		local Indices = string.split(IndicesStr, ",")
		local MaxNum = #ChatChannelColor 

		for i, v in ipairs(ChatSetting.ChannelColorIndices) do
			local IndexStr = Indices[i]
			local Index = tonumber(IndexStr)
			if nil == Index or Index <= 0 or Index > MaxNum then
				Index = ChatSetting.GetDefaultChannelColorIndex(v.Channel)
			end

			v.ColorIndex = Index
		end
	end

	-- 通讯贝标签颜色
	ChatSetting.GroupColorIndices = ParseSaveStringJsonMap(SaveKey.ChatColorIndicesGroup) 

	-- 隐藏的频道
	ChatSetting.HideChannels = ParseSaveString(SaveKey.ChatHideChannels)

	-- 聊天频道显示位置
	ChatSetting.ChannelPosMap = ParseSaveStringJsonMap(SaveKey.ChatChannelShowPos)

	local ParseSaveStringPair = function(SKey, Setting)
		local IndicesStr = USaveMgr.GetString(SKey, "", false)
		local Indices = string.split(IndicesStr, ",")

		for i=1, 2 do	
			local Index = tonumber(Indices[i])
			if Index then
				Setting[i] = Index == 1
			end
		end
	end

	-- 聊天是否开启私聊红点提示, {迷宫内，迷宫外}
	ParseSaveStringPair(SaveKey.ChatOpenPrivateRedDotTip, ChatSetting.OpenPrivateRedDotTip)

	-- 聊天是否开启私聊侧边栏, {迷宫内，迷宫外}
	ParseSaveStringPair(SaveKey.ChatOpenPrivateSidebar, ChatSetting.OpenPrivateSidebar)

	-- 是否开启私聊弹幕, {迷宫内，迷宫外}
	ParseSaveStringPair(SaveKey.ChatOpenPrivateDanmaku, ChatSetting.OpenPrivateDanmaku)

	-- 是否开启队伍弹幕, {迷宫内，迷宫外}
	ParseSaveStringPair(SaveKey.ChatOpenTeamDanmaku, ChatSetting.OpenTeamDanmaku)
end

function ChatSetting.IsDisplayInComprehensiveChannel(Channel, ChannelID, ChatMsgType)
	if nil == Channel then
		return false
	end

	local Bit = ChatSetting.ComprehensiveChannelBit or 0
	if (1 << Channel & Bit) == 0 then
		return false
	end

	if Channel == ChatChannel.System then
		return ChatSetting.IsDisplayInComprehensiveChannelBySysMsgType(ChatMsgType)

	elseif Channel == ChatChannel.Group then
		return ChatSetting.IsDisplayInComprehensiveChannelByGroupID(ChannelID)
	end

	return true
end

function ChatSetting.IsDisplayInComprehensiveChannelBySysMsgType(ChatMsgType)
	if nil == ChatMsgType then
		return true 
	end

	-- 消息类型转系统消息类型
	local SysMsgType = MapChatMsgTypeAndSysMsgType[ChatMsgType]
	if nil == SysMsgType then
		return false
	end

	local Bit = ChatSetting.ComprehensiveChannelSysMsgTypeBit or 0
	return (1 << SysMsgType & Bit) ~= 0
end

function ChatSetting.IsDisplayInComprehensiveChannelByGroupID(GroupID)
	if nil == GroupID then
		return true 
	end

	local BlockIDs = ChatSetting.ComprehensiveChannelBlockGroupIDs or {}
	if #BlockIDs <= 0 then
		return true 
	end

	return nil == table.find_item(BlockIDs, GroupID)
end

function ChatSetting.IsOpenPrivateRedDotTip()
	local Settings = ChatSetting.OpenPrivateRedDotTip or DefaultOpenSetting.PrivateRedDotTip 
    if _G.PWorldMgr:CurrIsInDungeon() then
		return Settings[1]
	else
		return Settings[2]
	end
end

function ChatSetting.IsOpenPrivateSidebar()
	local Settings = ChatSetting.OpenPrivateSidebar or DefaultOpenSetting.PrivateSidebar
    if _G.PWorldMgr:CurrIsInDungeon() then
		return Settings[1]
	else
		return Settings[2]
	end
end

function ChatSetting.IsOpenPrivateDanmaku()
	local Settings = ChatSetting.OpenPrivateDanmaku or DefaultOpenSetting.PrivateDanmaku
    if _G.PWorldMgr:CurrIsInDungeon() then
		return Settings[1]
	else
		return Settings[2]
	end
end

function ChatSetting.IsOpenTeamDanmaku()
	local Settings = ChatSetting.OpenTeamDanmaku or DefaultOpenSetting.TeamDanmaku
    if _G.PWorldMgr:CurrIsInDungeon() then
		return Settings[1]
	else
		return Settings[2]
	end
end

function ChatSetting.GetComprehensiveChannels()
	return ChatSetting.ComprehensiveChannels
end

function ChatSetting.GetComprehensiveChannelSysMsgTypes()
	return ChatSetting.ComprehensiveChannelSysMsgTypes
end

function ChatSetting.GetComprehensiveChannelBlockGroupIDs()
	return ChatSetting.ComprehensiveChannelBlockGroupIDs
end

--- 移除综合频道屏蔽通讯贝数据中玩家不在的通讯贝
function ChatSetting.RemoveComprehensiveChannelBlockGroupIDs(RemovedGroupID)
	if nil == RemovedGroupID then
		return
	end

	local SettingIDs = ChatSetting.ComprehensiveChannelBlockGroupIDs
	if table.is_nil_empty(SettingIDs) then
		return
	end

	if table.remove_item(SettingIDs, RemovedGroupID) then
		ChatSetting.SetComprehensiveChannelBlockGroupIDs(SettingIDs, true)
	end
end

function ChatSetting.GetChannelColorIndex(Channel, ChannelID)
	if Channel == ChatChannel.Group then
		if nil == ChannelID then
			return ChatSetting.GetDefaultChannelColorIndex(Channel)
		end

		return ChatSetting.GroupColorIndices[ChannelID] or ChatSetting.GetDefaultChannelColorIndex(Channel)
	end

	--ToDo.. 临时处理
	if Channel == ChatChannel.SceneTeam then
		Channel = ChatChannel.Team
	end

	for _, v in ipairs(ChatSetting.ChannelColorIndices) do
		if v.Channel == Channel then
			return v.ColorIndex
		end
	end
end

function ChatSetting.GetChannelColor(Channel, ChannelID)
	--ToDo.. 临时处理
	if Channel == ChatChannel.SceneTeam then
		Channel = ChatChannel.Team
	end

	local Index = ChatSetting.GetChannelColorIndex(Channel, ChannelID)
	if nil == Index then
		return "FFFFFFFF"
	end

	return ChatChannelColor[Index]
end

function ChatSetting.SetComprehensiveChannels(Channels)
	--ToDo.. 临时处理
	if Channels then
		if table.contain(Channels, ChatChannel.Team) then 
			if not table.contain(Channels, ChatChannel.SceneTeam) then
				table.insert(Channels, ChatChannel.SceneTeam)
			end
		else
			if table.contain(Channels, ChatChannel.SceneTeam) then
				table.remove_item(Channels, ChatChannel.SceneTeam)
			end
		end
	end

	Channels = Channels or table.shallowcopy(ChatDefaultSetting.ComprehensiveChannels)

	local Bit = 0

	for _, v in ipairs(Channels) do
		Bit = Bit | (1 << v)
	end

	if Bit == ChatSetting.ComprehensiveChannelBit then
		return false
	end

	ChatSetting.ComprehensiveChannels = Channels
	ChatSetting.ComprehensiveChannelBit = Bit

	local Str = table.concat(Channels, ",")
	USaveMgr.SetString(SaveKey.ChatComprehensiveChannel, Str, false)

	return true
end

function ChatSetting.SetComprehensiveChannelSysMsgTypes(MsgTypes)
	MsgTypes = MsgTypes or table.shallowcopy(ChatDefaultSetting.ComprehensiveChannelSysMsgTypes)

	local Bit = 0

	for _, v in ipairs(MsgTypes) do
		Bit = Bit | (1 << v)
	end

	if Bit == ChatSetting.ComprehensiveChannelSysMsgTypeBit then
		return false
	end

	ChatSetting.ComprehensiveChannelSysMsgTypes = MsgTypes 
	ChatSetting.ComprehensiveChannelSysMsgTypeBit = Bit

	local Str = table.concat(MsgTypes, ",")
	USaveMgr.SetString(SaveKey.ChatComprehensiveChannelSysMsgType, Str, false)

	return true
end

function ChatSetting.SetComprehensiveChannelBlockGroupIDs(IDs, IsForceSave)
	IDs = IDs or {}

	table.sort(IDs)

	if not IsForceSave and table.compare_table(ChatSetting.ComprehensiveChannelBlockGroupIDs, IDs) then
		return false
	end

	ChatSetting.ComprehensiveChannelBlockGroupIDs = IDs

	local Str = table.concat(IDs, ",")
	USaveMgr.SetString(SaveKey.ChatComprehensiveChannelBlockGroupID, Str, false)

	return true
end

function ChatSetting.GetDefaultChannelColorIndex(Channel)
	--ToDo.. 临时处理
	if Channel == ChatChannel.SceneTeam then
		Channel = ChatChannel.Team
	end

	for _, v in ipairs(ChatDefaultSetting.ChannelColorIndices) do
		if v.Channel == Channel then
			return v.ColorIndex
		end
	end
end

function ChatSetting.SetChannelColorIndex(Channel, Index, ChannelID)
	Index = Index or ChatSetting.GetDefaultChannelColorIndex(Channel)

	if Channel == ChatChannel.Group then
		if nil == ChannelID then
			return
		end

		-- 检测通讯贝的合法性
		local IDs = _G.LinkShellMgr:GetLinkShellIDs()
		if not table.contain(IDs, ChannelID) then
			return
		end

		local Indeices = ChatSetting.GroupColorIndices
		if Indeices[ChannelID] == Index then -- 未发生变化
			return
		end

		Indeices[ChannelID] = Index
		local JsonData = {}

		for k, v in pairs(Indeices) do
			-- 检测玩家是否仍然在通讯贝
			if not table.contain(IDs, k) then
				Indeices[k] = nil
			else
				table.insert(JsonData, {k, v})
			end
		end

		local Str = Json.encode(JsonData) 
		USaveMgr.SetString(SaveKey.ChatColorIndicesGroup, Str, false)

		return
	end

	--ToDo.. 临时处理
	if Channel == ChatChannel.SceneTeam then
		Channel = ChatChannel.Team
	end

	local Colors = {}
	for _, v in ipairs(ChatSetting.ChannelColorIndices) do
		if v.Channel == Channel then
			v.ColorIndex = Index
		end

		table.insert(Colors, v.ColorIndex)
	end

	local Str = table.concat(Colors, ",")
	USaveMgr.SetString(SaveKey.ChatColorIndices, Str, false)
end

--- 设置私聊红点提示
--- @param bDungeon boolean @迷宫内
--- @param bOther boolean @迷宫外
function ChatSetting.SetIsOpenPrivateRedDotTip(bDungeon, bOther)
	local CurSettings = ChatSetting.OpenPrivateRedDotTip or {}
	if bDungeon == CurSettings[1] and bOther == CurSettings[2] then
		return
	end

 	CurSettings[1] = bDungeon
	CurSettings[2] = bOther

	local Data = {bDungeon and 1 or 0, bOther and 1 or 0}
	local Str = table.concat(Data, ",")
	USaveMgr.SetString(SaveKey.ChatOpenPrivateRedDotTip, Str, false)

	_G.EventMgr:SendEvent(_G.EventID.ChatOpenPrivateRedDotTipChanged)
end

--- 设置是否开启私聊侧边栏
--- @param bDungeon boolean @迷宫内
--- @param bOther boolean @迷宫外
function ChatSetting.SetIsOpenPrivateSidebar(bDungeon, bOther)
	local CurSettings = ChatSetting.OpenPrivateSidebar or {}
	if bDungeon == CurSettings[1] and bOther == CurSettings[2] then
		return
	end

	CurSettings[1] = bDungeon
	CurSettings[2] = bOther

	local Data = {bDungeon and 1 or 0, bOther and 1 or 0}
	local Str = table.concat(Data, ",")
	USaveMgr.SetString(SaveKey.ChatOpenPrivateSidebar, Str, false)

	_G.EventMgr:SendEvent(_G.EventID.ChatOpenPrivateSidebarChanged)
end

--- 设置是否开启私聊弹幕
--- @param bDungeon boolean @迷宫内
--- @param bOther boolean @迷宫外
function ChatSetting.SetIsOpenPrivateDanmaku(bDungeon, bOther)
	local CurSettings = ChatSetting.OpenPrivateDanmaku or {}
	if bDungeon == CurSettings[1] and bOther == CurSettings[2] then
		return
	end

	CurSettings[1] = bDungeon
	CurSettings[2] = bOther

	local Data = {bDungeon and 1 or 0, bOther and 1 or 0}
	local Str = table.concat(Data, ",")
	USaveMgr.SetString(SaveKey.ChatOpenPrivateDanmaku, Str, false)

	_G.EventMgr:SendEvent(_G.EventID.ChatOpenPrivateDanmakuChanged)
end

--- 设置是否开启队伍弹幕
--- @param bDungeon boolean @迷宫内
--- @param bOther boolean @迷宫外
function ChatSetting.SetIsOpenTeamDanmaku(bDungeon, bOther)
	local CurSettings = ChatSetting.OpenTeamDanmaku or {}
	if bDungeon == CurSettings[1] and bOther == CurSettings[2] then
		return
	end

	CurSettings[1] = bDungeon
	CurSettings[2] = bOther

	local Data = {bDungeon and 1 or 0, bOther and 1 or 0}
	local Str = table.concat(Data, ",")
	USaveMgr.SetString(SaveKey.ChatOpenTeamDanmaku, Str, false)

	_G.EventMgr:SendEvent(_G.EventID.ChatOpenTeamDanmakuChanged)
end

function ChatSetting.SaveHideChannels(Channels)
	if nil == Channels then
		return false
	end

	if table.compare_table(ChatSetting.HideChannels, Channels) then
		return false
	end

	ChatSetting.HideChannels = Channels

	local Str = table.concat(Channels, ",")
	print(Str)
	USaveMgr.SetString(SaveKey.ChatHideChannels, Str, false)

	return true
end

function ChatSetting.SaveChannelShowPosMap(PosMap)
	if nil == PosMap then
		return false
	end

	if table.compare_table(ChatSetting.ChannelPosMap, PosMap) then
		return false
	end

	ChatSetting.ChannelPosMap = PosMap

	local JsonData = {}

	for k, v in pairs(PosMap) do
		table.insert(JsonData, {k, v})
	end

	local Str = Json.encode(JsonData) 
	print(Str)
	USaveMgr.SetString(SaveKey.ChatChannelShowPos, Str, false)

	return true
end

return ChatSetting
