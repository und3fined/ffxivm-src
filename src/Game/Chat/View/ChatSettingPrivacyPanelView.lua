---
--- Author: xingcaicao
--- DateTime: 2025-04-17 11:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatMgr = require("Game/Chat/ChatMgr")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local EventID = require("Define/EventID")

local LSTR = _G.LSTR

---@class ChatSettingPrivacyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBoxBlockStranger CommSingleBoxView
---@field CheckBoxRejectFriendRequest CommSingleBoxView
---@field CheckBoxRejectStrangerEmail CommSingleBoxView
---@field FTextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingPrivacyPanelView = LuaClass(UIView, true)

function ChatSettingPrivacyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBoxBlockStranger = nil
	--self.CheckBoxRejectFriendRequest = nil
	--self.CheckBoxRejectStrangerEmail = nil
	--self.FTextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingPrivacyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBoxBlockStranger)
	self:AddSubView(self.CheckBoxRejectFriendRequest)
	self:AddSubView(self.CheckBoxRejectStrangerEmail)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingPrivacyPanelView:OnInit()

end

function ChatSettingPrivacyPanelView:OnDestroy()

end

function ChatSettingPrivacyPanelView:OnShow()
	self:InitConstInfo()

	self.CheckBoxBlockStranger:SetIsEnabled(false)

	-- 获取玩家设置-拒收非好友消息状态
	self.IsBlockStranger = nil
	ChatMgr:SendGetBlockStranger()

	-- 是否拒绝好友申请
	local IsReject = FriendMgr:IsRejectFriendRequest()
	self.CheckBoxRejectFriendRequest:SetChecked(IsReject)
end

function ChatSettingPrivacyPanelView:OnHide()
	local IsBlock = self.IsBlockStranger
	if nil ~= IsBlock and IsBlock ~= self.IsBlockStrangerServer then
		ChatMgr:SendSetBlockStranger(IsBlock)
	end

	self.IsBlockStrangerServer = nil

	local IsReject = FriendMgr:IsRejectFriendRequest()
	local IsChecked = self.CheckBoxRejectFriendRequest:GetChecked()
	if IsReject ~= IsChecked then
		FriendMgr:SendSetRejectFriendRequest(IsChecked)
	end
end

function ChatSettingPrivacyPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxBlockStranger, self.OnToggleStateChangedBlockStranger)
end

function ChatSettingPrivacyPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ChatGetIsBlockStranger, 	self.OnEventChatGetIsBlockStranger)
end

function ChatSettingPrivacyPanelView:OnRegisterBinder()

end

function ChatSettingPrivacyPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.FTextTitle:SetText(LSTR(50184)) -- "隐私防护"
	self.CheckBoxBlockStranger:SetText(LSTR(50125)) -- "拒收非好友私聊"
	self.CheckBoxRejectFriendRequest:SetText(LSTR(50185)) -- "拒收好友申请"
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatSettingPrivacyPanelView:OnEventChatGetIsBlockStranger(IsBlock)
	self.IsBlockStrangerServer = IsBlock
	self.IsBlockStranger = IsBlock

	self.CheckBoxBlockStranger:SetIsEnabled(true)
	self.CheckBoxBlockStranger:SetChecked(IsBlock, false)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatSettingPrivacyPanelView:OnToggleStateChangedBlockStranger(ToggleButton, State)
	self.IsBlockStranger = UIUtil.IsToggleButtonChecked(State)
end

return ChatSettingPrivacyPanelView