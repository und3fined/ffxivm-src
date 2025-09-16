---
--- Author: xingcaicao
--- DateTime: 2023-09-05 19:53
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ChatUtil = require("Game/Chat/ChatUtil")
local ChatDefine = require("Game/Chat/ChatDefine")

local ChatChannel = ChatDefine.ChatChannel

---@class ChatPublicChannelItemVM : UIViewModel
local ChatPublicChannelItemVM = LuaClass(UIViewModel)

---Ctor
function ChatPublicChannelItemVM:Ctor( )
	self.Channel = nil
	self.ChannelID = nil
	self.Name = nil 
	self.Icon = nil 
	self.IconSelect = nil 
	self.SortID = 999
end

function ChatPublicChannelItemVM:IsEqualVM(Value)
	return false 
end

function ChatPublicChannelItemVM:UpdateVM(Value)
	if nil == Value then
		Value = {}
	end

	local Channel = Value.Channel
	self.Channel = Channel 
	self.ChannelID = nil
	self.SortID = Value.SortID or 999  

	local Config = ChatUtil.FindChatChannelConfig(Channel)
	if nil == Config then
		return
	end

	self.Icon = Config.Icon
	self.IconSelect = Config.IconSelect
	self.Name = Config.Name
end

--- 更新数据（通讯贝）
---@param LinkShellItem LinkShellItemVM @通讯贝VM
function ChatPublicChannelItemVM:UpdateByGroup(LinkShellItem)
	self.ChannelID = LinkShellItem.ID 
	self.Name = LinkShellItem.Name
end

function ChatPublicChannelItemVM:SetName(Name)
	self.Name = Name or ""
end

function ChatPublicChannelItemVM:GetName()
	return self.Name or ""
end
function ChatPublicChannelItemVM:GetSubName()
	if self.Channel == ChatChannel.Pioneer then
		return _G.ChatVM.PioneerChannelCloseTimeStr or ""
	end
end

return ChatPublicChannelItemVM