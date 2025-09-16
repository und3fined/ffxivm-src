--[[
Description  : 聊天频道VM -- 通讯贝
Author       : xingcaicao
Date         : 2022-12-09 17:12:57
--]]

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")

---@class ChatChannelGroupVM : ChatChannelVM
local ChatChannelGroupVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelGroupVM:Ctor()
end

function ChatChannelGroupVM:IsNeedPull()
	return true
end

function ChatChannelGroupVM:IsNeedActive()
	return true 
end

function ChatChannelGroupVM:CheckGoToVisible()
	return true
end

function ChatChannelGroupVM:GetChatBarWidgetVisible()
	return true
end

function ChatChannelGroupVM:CheckIsInChannel()
	return true
end

return ChatChannelGroupVM