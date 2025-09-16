--
-- Author: anypkvcai
-- Date: 2022-05-05 12:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local TeamMgr = require("Game/Team/TeamMgr")

---@class ChatChannelTeamVM : ChatChannelVM
local ChatChannelTeamVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelTeamVM:Ctor()
end

---GetChannelID
function ChatChannelTeamVM:GetChannelID()
	return TeamMgr.TeamID
end

function ChatChannelTeamVM:IsNeedActive()
	return TeamMgr:IsInTeam()
end

function ChatChannelTeamVM:CheckGoToVisible()
	--判断是否加入队伍
	return TeamMgr:IsInTeam()
end

function ChatChannelTeamVM:GetChatBarWidgetVisible()
	return TeamMgr:IsInTeam()
end

return ChatChannelTeamVM