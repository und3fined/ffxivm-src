--
-- Author: anypkvcai
-- Date: 2022-05-05 12:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatMsgItemVM = require("Game/Chat/VM/ChatMsgItemVM")
local MajorUtil = require("Utils/MajorUtil")
local UIBindableList = require("UI/UIBindableList")

local ChatChannel = ChatDefine.ChatChannel
local SysMsgType = ChatDefine.SysMsgType
local MapChatMsgTypeAndSysMsgType = ChatDefine.MapChatMsgTypeAndSysMsgType

---@class ChatChannelSystemVM : ChatChannelVM
local ChatChannelSystemVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelSystemVM:Ctor()
	self.MaxMsgNum = 500
	self.TrimNum = 50 
	self.Channel = ChatChannel.System
	self.BindableListAllMsg = UIBindableList.New(ChatMsgItemVM)
	self.BindableListMsg = UIBindableList.New()
end

function ChatChannelSystemVM:AddMsg(Channel, MsgType, ChatMsg, Content, IsRead, ChannelID)
	if not IsRead then
		if self:IsNeedUpdateNewMsgNum() then
			self.NewMsgNum = self.NewMsgNum + 1
		end
	end

	local Value = { Channel = Channel, MsgType = MsgType, ChatMsg = ChatMsg, Content = Content }
	local ViewModel = self.BindableListAllMsg:AddByValue(Value)
	if self:IsMsgVisible(ViewModel) then
		self.BindableListMsg:Add(ViewModel)
	end

	return ViewModel
end

function ChatChannelSystemVM:IsMsgVisible(ViewModel)
	if nil == ViewModel then
		return false
	end

	local CurSysMsgType = _G.ChatVM.CurSysMsgType
	if nil == CurSysMsgType then
		return false
	end

	if CurSysMsgType == SysMsgType.All then
		return true
	end

	local MsgType = ViewModel:GetMsgType()
	if nil == MsgType then
		return false
	end

	return MapChatMsgTypeAndSysMsgType[MsgType] == CurSysMsgType
end

function ChatChannelSystemVM:OnFilterChanged()
	self.BindableListMsg:Clear()

	for _, v in ipairs(self.BindableListAllMsg:GetItems()) do
		if self:IsMsgVisible(v) then
			self.BindableListMsg:Add(v)
		end
	end

	self:SortMsgVM()
end

---GetChannelID
function ChatChannelSystemVM:GetChannelID()
	return MajorUtil.GetMajorRoleID()
end

function ChatChannelSystemVM:TrimChatMsg()
	if self.BindableListAllMsg:Length() <= self.MaxMsgNum then
		return
	end

	local ChatVM = _G.ChatVM
	local ListMsg = self.BindableListMsg
	local ListAllMsg = self.BindableListAllMsg
	local Items = ListAllMsg:GetItems()
	local TrimNum = self.TrimNum

	for i = #Items, 1, -1 do
		if i >= 1 and i <= TrimNum then
			local Item = Items[i]

			-- 综合频道
			ChatVM:DeleteComprehensiveChannelChatMsg(Item)

			-- 移除当前显示的消息列表数据
			ListMsg:Remove(Item)

			-- 移除缓存的实际系统消息数据
			ListAllMsg:FreeItem(Item)
			table.remove(Items, i)

			self:SetMapMsgID(Item.ID, nil) 
		end
	end

	ListMsg:OnUpdateList()
end

function ChatChannelSystemVM:CheckIsInChannel()
	return true
end

function ChatChannelSystemVM:IsNeedUpdateNewMsgNum()
	return false
end

return ChatChannelSystemVM