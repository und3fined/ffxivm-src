---
--- Author: anypkvcai
--- DateTime: 2021-11-25 9:50
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ChatMsgItemVM = require("Game/Chat/VM/ChatMsgItemVM")
local ChatDefine = require("Game/Chat/ChatDefine")

local ShowMsgTimeInterval = ChatDefine.ShowMsgTimeInterval
local MsgItemSortFunc = ChatDefine.MsgItemSortFunc

---@class ChatChannelVM : UIViewModel
local ChatChannelVM = LuaClass(UIViewModel)

---Ctor
function ChatChannelVM:Ctor(Channel, ChannelID)
	self.Channel = Channel
	self.ChannelID = ChannelID 
	self.CurrentMsgID = 0
	self.BindableListMsg = UIBindableList.New(ChatMsgItemVM)
	self.SendTimeCD = 0
	self.NewMsgNum = 0
	self.IsRedDotVisible = false
	self.MapMsgID = {} -- ID大于0

	self.MaxMsgNum = 200
	self.TrimNum = 50 
end

function ChatChannelVM:GetChannel()
	return self.Channel
end

---GetChannelID
function ChatChannelVM:GetChannelID()
	if nil ~= self.ChannelID and self.ChannelID > 0 then
		return self.ChannelID
	end
end

function ChatChannelVM:GetHelpInfoID()
	return 0 
end

function ChatChannelVM:AddMsg(Channel, MsgType, ChatMsg, Content, IsRead, ChannelID)
	if not IsRead then
		if self:IsNeedUpdateNewMsgNum() then
			self.NewMsgNum = self.NewMsgNum + 1
		end
	end

	local Value = { 
		Channel 		= Channel, 
		ChannelID 		= ChannelID, 
		MsgType 		= MsgType,
		ChatMsg 		= ChatMsg, 
		Content 		= Content, 
	}

	local MsgItemVM = self.BindableListMsg:AddByValue(Value)
	self:CheckNewMsgTimeVisible(MsgItemVM)
	self:SetMapMsgID(MsgItemVM.ID, true)

	return MsgItemVM 
end

function ChatChannelVM:IsNeedUpdateNewMsgNum()
	return true
end

function ChatChannelVM:SetMapMsgID(MsgID, Value)
	if nil == MsgID or MsgID <= 0 then
		return
	end

	self.MapMsgID[MsgID] = Value
end

function ChatChannelVM:IsExist(MsgID)
	local MapID = self.MapMsgID
	if nil == MsgID or nil == MapID then
		return false
	end

	return MapID[MsgID]
end

function ChatChannelVM:SortMsgVM()
	return self.BindableListMsg:Sort(MsgItemSortFunc)
end

function ChatChannelVM:SetCurrentMsgID(MsgID)
	self.CurrentMsgID = MsgID
end

function ChatChannelVM:GetCurrentMsgID()
	return self.CurrentMsgID
end

function ChatChannelVM:IsNeedPull()
	return false
end

function ChatChannelVM:IsNeedActive()
	return false
end

function ChatChannelVM:TrimChatMsg()
	local BindableListMsg = self.BindableListMsg
	if BindableListMsg:Length() > self.MaxMsgNum then
		local ChatVM = _G.ChatVM

		BindableListMsg:RemoveItems(1, self.TrimNum, nil, 
			function(e) 
				-- 综合频道
				ChatVM:DeleteComprehensiveChannelChatMsg(e)
				self:SetMapMsgID(e.ID, nil) 
			end)
	end
end

function ChatChannelVM:GetSendTimeCD()
	return self.SendTimeCD
end

function ChatChannelVM:SetSendTimeCD(Time)
	self.SendTimeCD = Time
end

function ChatChannelVM:GetRedDotNum()
	return self.NewMsgNum
end

function ChatChannelVM:ClearRedDot()
	self:ClearUnreadInfo()
end

function ChatChannelVM:ClearUnreadInfo()
	self.NewMsgNum = 0
	self:UpdateRedDot()
end

function ChatChannelVM:UpdateRedDot()
	local Num = self.NewMsgNum or 0
	self.IsRedDotVisible = Num > 0
end

function ChatChannelVM:CheckNewMsgTimeVisible(MsgItemVM)
	if nil == MsgItemVM then
		return
	end

	if MsgItemVM:ForceShowTime() then
		MsgItemVM:SetTimeVisible(true)
		return
	end

	local CurMsgTime = MsgItemVM.Time or 0
	local LastMsgTime = self.LastMsgTime or 0
	MsgItemVM:SetTimeVisible((CurMsgTime - LastMsgTime) > ShowMsgTimeInterval)

	self.LastMsgTime = CurMsgTime
end

function ChatChannelVM:DeleteChatMsgByPredicate(Predicate)
	local ChatVM = _G.ChatVM
	self.BindableListMsg:RemoveItemsByPredicate(Predicate, nil, function(e) 
		ChatVM:DeleteComprehensiveChannelChatMsg(e)
		self:SetMapMsgID(e.ID, nil) 
	end)
end

function ChatChannelVM:ClearMsg()
	-- 综合频道
	local VM = _G.ChatVM.ComprehensiveChannelVM
	if VM then
		local Channel = self.Channel
		VM.BindableListMsg:RemoveItemsByPredicate(function(e) return e:GetChannel() == Channel end, true)
	end

	self.MapMsgID = {}
	self.BindableListMsg:Clear()
	self:ClearRedDot()
	self.CurrentMsgID = 0
end

function ChatChannelVM:CheckGoToVisible()
	return false
end

function ChatChannelVM:CheckExitVisible()
	return false
end

function ChatChannelVM:GetChatBarWidgetVisible()
	return false
end

function ChatChannelVM:SetMsgToHistory()
	local BindableList = self.BindableListMsg
	local Length = BindableList:Length()

	for i = 1, Length do
		local Item = BindableList:Get(i)
		self:SetMapMsgID(Item.ID, nil)
		Item:SetHistoryMsg()
	end

	self:SetCurrentMsgID(0)
end

function ChatChannelVM:CheckIsInChannel()
	return self:GetChatBarWidgetVisible()
end

function ChatChannelVM:GetLatestMsg()
	local BindableList = self.BindableListMsg
	return BindableList:Get(BindableList:Length())
end

return ChatChannelVM