---
--- Author: anypkvcai
--- DateTime: 2021-11-25 10:39
--- Description:
---

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local UIBindableList = require("UI/UIBindableList")
local ChatDefine = require("Game/Chat/ChatDefine")

---@class ChatChannelComprehensiveVM : ChatChannelVM
local ChatChannelComprehensiveVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelComprehensiveVM:Ctor()
	self.Channel = ChatDefine.ChatChannel.Comprehensive 
	self.ChannelID = 0 

	self.MaxMsgNum = 400
	self.TrimNum = 50 

	self.BindableListMsg = UIBindableList.New()
end

function ChatChannelComprehensiveVM:GetChannel()
	return self.Channel
end

---GetChannelID
function ChatChannelComprehensiveVM:GetChannelID()
	return 0
end

function ChatChannelComprehensiveVM:TrimChatMsg()
	if self.BindableListMsg:Length() > self.MaxMsgNum then
		self.BindableListMsg:RemoveItems(1, self.TrimNum, true)
	end
end

function ChatChannelComprehensiveVM:AddMsg()

end

function ChatChannelComprehensiveVM:Add(ViewModel)
	self.BindableListMsg:Add(ViewModel)
end

function ChatChannelComprehensiveVM:DeleteChatMsgByPredicate(Predicate)

end

function ChatChannelComprehensiveVM:ClearMsg()

end

function ChatChannelComprehensiveVM:GetChatBarWidgetVisible()
	return not table.is_nil_empty(_G.ChatVM.CompSpeakChannelList) 
end

function ChatChannelComprehensiveVM:CheckIsInChannel()
	return true
end

function ChatChannelComprehensiveVM:IsNeedUpdateNewMsgNum()
	return false
end

return ChatChannelComprehensiveVM