---
--- Author: anypkvcai
--- DateTime: 2021-11-10 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatSetting = require("Game/Chat/ChatSetting")
local ChatVM = require("Game/Chat/ChatVM")
local EventID = require("Define/EventID")
local ChatUtil = require("Game/Chat/ChatUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class ChatMsgSystemItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageTag UFImage
---@field PanelChannelTag UFCanvasPanel
---@field RichTextMsg URichTextBox
---@field TextChannel URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMsgSystemItemView = LuaClass(UIView, true)

function ChatMsgSystemItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImageTag = nil
	--self.PanelChannelTag = nil
	--self.RichTextMsg = nil
	--self.TextChannel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMsgSystemItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMsgSystemItemView:OnInit()
	self.Binders = {
		{ "Content", UIBinderSetText.New(self, self.RichTextMsg) },
		{ "ChannelTagVisible", UIBinderSetIsVisible.New(self, self.PanelChannelTag) },
	}
end

function ChatMsgSystemItemView:OnDestroy()

end

function ChatMsgSystemItemView:OnShow()

end

function ChatMsgSystemItemView:OnHide()

end

function ChatMsgSystemItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextMsg, self.OnHyperlinkClicked)
end

function ChatMsgSystemItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChatUpdateColor, self.OnGameEventUpdateColor)
end

function ChatMsgSystemItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)

	local Channel = ViewModel.Channel
	self.Channel = Channel
	self.ChannelID = ViewModel.ChannelID

	-- 频道名
	local Name = ChatUtil.GetChannelName(Channel)
	self.TextChannel:SetText(Name or "")

	self:UpdateColor()
end

function ChatMsgSystemItemView:OnGameEventUpdateColor()
	self:UpdateColor()
end

function ChatMsgSystemItemView:OnHyperlinkClicked(_, LinkID)
	ChatVM:HrefClicked(self.ViewModel, tonumber(LinkID))
end

function ChatMsgSystemItemView:UpdateColor()
	local Color = ChatSetting.GetChannelColor(self.Channel, self.ChannelID)
	UIUtil.ImageSetColorAndOpacityHex(self.ImageTag, Color)
end

return ChatMsgSystemItemView