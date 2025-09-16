---
--- Author: xingcaicao
--- DateTime: 2023-02-06 15:16
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ChatUtil = require("Game/Chat/ChatUtil")
local ProtoCS = require("Protocol/ProtoCS")

local PARAM_TYPE_DEFINE = ProtoCS.PARAM_TYPE_DEFINE

---@class ChatHyperlinkHistoryTextItemVM : UIViewModel
local ChatHyperlinkHistoryTextItemVM = LuaClass(UIViewModel)

---Ctor
function ChatHyperlinkHistoryTextItemVM:Ctor()
	self.Content = nil
	self.RawContent = nil
	self.ParamList = nil
end

function ChatHyperlinkHistoryTextItemVM:Clear()
	self.Content = nil
	self.RawContent = nil
	self.ParamList = nil
end

function ChatHyperlinkHistoryTextItemVM:IsEqualVM(Value)
	return Value ~= nil and self.RawContent ~= nil and self.RawContent == Value.RawContent
end

function ChatHyperlinkHistoryTextItemVM:UpdateVM(Value)
	local Content = Value.Content
	self.RawContent = Content

	local TeamRecruit = nil
	local Map = nil

	local ParamList = Value.ParamList -- 超链内容

	for _, v in ipairs(ParamList) do
		local Type = v.Type
		if Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_RECRUIT	-- 队伍招募
			or Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_MAP 			-- 位置
		then
			local SimpleHref = _G.ChatMgr:DecodeChatParams(v.Param)
			if SimpleHref then
				TeamRecruit = TeamRecruit or SimpleHref.TeamRecruit
				Map = Map or SimpleHref.Map
			end
		end
	end

	if TeamRecruit then
		Content = ChatUtil.GetTeamRecruitHrefDesc(TeamRecruit)

	elseif Map then --位置
		local MapID = Map.MapID 
		if MapID > 0 then
			Content = ChatUtil.GetLocationShareDesc(Content, Map)
		end
	end

	-- Emoji表情
	Content = ChatUtil.ParseEmojis(Content)

	self.Content = Content
	self.ParamList = ParamList
end

return ChatHyperlinkHistoryTextItemVM