--
-- Author: xingcaicao 
-- Date: 2025-03-22 19:17
-- Description: 先锋频道
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local MajorUtil = require("Utils/MajorUtil")
local ChatUtil = require("Game/Chat/ChatUtil")

---@class ChatChannelPioneerVM : ChatChannelVM
local ChatChannelPioneerVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelPioneerVM:Ctor()
    self.SendMsgLevel = ChatUtil.GetPioneerChannelSpeakLevel()
end

---GetChannelID
function ChatChannelPioneerVM:GetChannelID()
	return _G.ChatMgr:GetPioneerChannelID()
end

function ChatChannelPioneerVM:IsNeedActive()
	return true	
end

function ChatChannelPioneerVM:GetHelpInfoID()
	return _G.ChatVM:IsClosedPioneerChannel() and 0 or 11129
end

function ChatChannelPioneerVM:CheckExitVisible()
    return self:CheckIsInChannel() 
end

function ChatChannelPioneerVM:GetChatBarWidgetVisible()
	return self:CheckIsInChannel() and MajorUtil.GetMaxProfLevel() >= self.SendMsgLevel
end

function ChatChannelPioneerVM:CheckIsInChannel()
	return _G.ChatVM:IsInPioneerChannel()
end

return ChatChannelPioneerVM