--[[
Description  : 聊天频道VM -- 私聊 
Author       : xingcaicao
Date         : 2022-12-15 10:28:17
--]]

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local ChatDefine = require("Game/Chat/ChatDefine")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")

---@class ChatChannelPrivateVM : ChatChannelVM
local ChatChannelPrivateVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelPrivateVM:Ctor()
	self.ParentRedDotID = ChatDefine.PrivateUnredRedDotID 
	self.RedDotName = nil

	self.MaxMsgNum = 500
	self.TrimNum = 50 
end

function ChatChannelPrivateVM:GetChatBarWidgetVisible()
	return true
end

function ChatChannelPrivateVM:CheckIsInChannel()
	return true
end

function ChatChannelPrivateVM:UpdateRedDot()
	local RedDotName = self.RedDotName
	local Num = self.NewMsgNum or 0
	if Num <= 0 and nil == RedDotName then 
		return
	end

	-- 创建小红点
	if nil == self.RedDotName then
		RedDotName = RedDotMgr:GetRedDotNameByParentID(self.ParentRedDotID, self.ChannelID)
		if string.isnilorempty(RedDotName) then
			return
		end

		self.RedDotName = RedDotName
	end

	-- 设置小红点
	RedDotMgr:SetRedDotNodeValueByName(RedDotName, Num, false)

	if Num <= 0 then
		self.RedDotName = nil
	end
end

function ChatChannelPrivateVM:ClearRedDot()
	self:ClearUnreadInfo()

	_G.ChatMgr:SetPrivateChatHaveRead(self:GetChannelID(), self:GetCurrentMsgID())
end

return ChatChannelPrivateVM