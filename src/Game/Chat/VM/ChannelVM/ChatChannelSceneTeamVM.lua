--
-- Author: anypkvcai
-- Date: 2022-05-05 12:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local PWorldTeamMgr = require("Game/PWorld/Team/PWorldTeamMgr")

---@class ChatChannelSceneTeamVM : ChatChannelVM
local ChatChannelSceneTeamVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelSceneTeamVM:Ctor()
end

---GetChannelID
function ChatChannelSceneTeamVM:GetChannelID()
	return PWorldTeamMgr.TeamID
end

function ChatChannelSceneTeamVM:IsNeedActive()
	return PWorldTeamMgr:IsInTeam()	
end

function ChatChannelSceneTeamVM:CheckGoToVisible()
	--判断是否加入队伍
	return PWorldTeamMgr:IsInTeam()	
end

function ChatChannelSceneTeamVM:GetChatBarWidgetVisible()
	return PWorldTeamMgr:IsInTeam()
end

return ChatChannelSceneTeamVM