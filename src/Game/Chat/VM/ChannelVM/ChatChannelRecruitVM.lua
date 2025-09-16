--
-- Author: xingcaicao 
-- Date: 2025-03-22 19:17
-- Description: 招募频道
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")

---@class ChatChannelRecruitVM : ChatChannelVM
local ChatChannelRecruitVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelRecruitVM:Ctor()
end

---GetChannelID
function ChatChannelRecruitVM:GetChannelID()
	return 1 
end

function ChatChannelRecruitVM:CheckIsInChannel()
	return true
end

function ChatChannelRecruitVM:IsNeedActive()
	return true	
end

return ChatChannelRecruitVM