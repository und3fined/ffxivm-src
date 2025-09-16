--
-- Author: anypkvcai
-- Date: 2022-05-05 12:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")

---@class ChatChannelAreaVM : ChatChannelVM
local ChatChannelAreaVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelAreaVM:Ctor()
end

---GetChannelID
function ChatChannelAreaVM:GetChannelID()
	return _G.PWorldMgr.BaseInfo.CurrPWorldInstID
end

function ChatChannelAreaVM:IsNeedActive()
	return true 
end

function ChatChannelAreaVM:GetChatBarWidgetVisible()
	return true 
end

function ChatChannelAreaVM:CheckIsInChannel()
	return true
end

return ChatChannelAreaVM