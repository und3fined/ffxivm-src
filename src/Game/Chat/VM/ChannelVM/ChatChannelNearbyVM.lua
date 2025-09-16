--
-- Author: anypkvcai
-- Date: 2022-05-05 12:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")

---@class ChatChannelNearbyVM : ChatChannelVM
local ChatChannelNearbyVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelNearbyVM:Ctor()
end

---GetChannelID
function ChatChannelNearbyVM:GetChannelID()
	return 1 
end

function ChatChannelNearbyVM:GetHelpInfoID()
	return 11092 
end

function ChatChannelNearbyVM:GetChatBarWidgetVisible()
	return true
end

function ChatChannelNearbyVM:CheckIsInChannel()
	return true
end

return ChatChannelNearbyVM