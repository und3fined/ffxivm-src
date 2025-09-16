--
-- Author: anypkvcai
-- Date: 2022-05-05 12:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local NewbieMgr = require("Game/Newbie/NewbieMgr")

---@class ChatChannelNewbieVM : ChatChannelVM
local ChatChannelNewbieVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelNewbieVM:Ctor()
end

---GetChannelID
function ChatChannelNewbieVM:GetChannelID()
	return _G.LoginMgr.WorldID
end

function ChatChannelNewbieVM:GetHelpInfoID()
	return 10001 
end

function ChatChannelNewbieVM:IsNeedPull()
	return NewbieMgr:IsInNewbieChannel()
end

function ChatChannelNewbieVM:IsNeedActive()
	return NewbieMgr:IsInNewbieChannel()
end

function ChatChannelNewbieVM:CheckGoToVisible()
	return NewbieMgr:IsInNewbieChannel()
end

function ChatChannelNewbieVM:GetChatBarWidgetVisible()
	return NewbieMgr:IsCanSpeakInNewbieChannel()
end

return ChatChannelNewbieVM