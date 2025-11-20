---
--- Author: anypkvcai
--- DateTime: 2021-11-30 16:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatUtil = require("Game/Chat/ChatUtil")
local UIViewID = require("Define/UIViewID")

---@class MainChatMsgItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextMsg URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainChatMsgItemView = LuaClass(UIView, true)

function MainChatMsgItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextMsg = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainChatMsgItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainChatMsgItemView:OnShow()
	self:UpdateMsg()
end

function MainChatMsgItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextMsg, self.OnHyperlinkClicked)
end

function MainChatMsgItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ChatUpdateColor, self.OnGameEventUpdateColor)
	self:RegisterGameEvent(_G.EventID.FriendSetNicknameSuc, self.OnGameEventFriendSetNickName)
	self:RegisterGameEvent(_G.EventID.FriendRemoved, self.OnGameEventFriendRemoved)
end

function MainChatMsgItemView:OnHyperlinkClicked()
	if _G.UIViewMgr:IsViewVisible(UIViewID.ChatMainPanel) then
		return
	end

	_G.ChatMgr:ShowChatView(nil, nil, nil, nil, true)
end

function MainChatMsgItemView:OnGameEventUpdateColor()
	self:UpdateMsg()
end

function MainChatMsgItemView:OnGameEventFriendSetNickName(RoleID)
	if RoleID == self:GetChatSender() then
		self:UpdateMsg()
	end
end

function MainChatMsgItemView:OnGameEventFriendRemoved(RoleIDs)
	if table.find_item(RoleIDs, self:GetChatSender()) then
		self:UpdateMsg()
	end
end

function MainChatMsgItemView:UpdateMsg()
	local Params = self.Params
	if nil == Params then
		return
	end

	---@type ChatMsgItemVM
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	local Text = ChatUtil.GetChatSimpleDesc(ViewModel) or ""
	self.RichTextMsg:SetText(Text)
end

function MainChatMsgItemView:GetChatSender()
	if self.Params and self.Params.Data then
		return self.Params.Data.Sender
	end
end

return MainChatMsgItemView