---
--- Author: anypkvcai
--- DateTime: 2022-04-20 15:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatSetting = require("Game/Chat/ChatSetting")
local ChatUtil = require("Game/Chat/ChatUtil")
local ChatVM = require("Game/Chat/ChatVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EventID = require("Define/EventID")

local ChatMsgType = ChatDefine.ChatMsgType

---@class ChatMsgTextItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageTag UFImage
---@field PanelChannelTag UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field RichTextMsgCenter URichTextBox
---@field RichTextMsgLeft URichTextBox
---@field RichTextTime URichTextBox
---@field TextChannel URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMsgTextItemView = LuaClass(UIView, true)

function ChatMsgTextItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImageTag = nil
	--self.PanelChannelTag = nil
	--self.PanelTime = nil
	--self.RichTextMsgCenter = nil
	--self.RichTextMsgLeft = nil
	--self.RichTextTime = nil
	--self.TextChannel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMsgTextItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMsgTextItemView:OnInit()
	self.Binders = {
		{ "TimeText", 	 		UIBinderSetText.New(self, self.RichTextTime) },
		{ "Content", 	 		UIBinderSetText.New(self, self.RichTextMsgLeft) },
		{ "Content", 	 		UIBinderSetText.New(self, self.RichTextMsgCenter) },
		{ "TimeVisible", 		UIBinderSetIsVisible.New(self, self.PanelTime) },
		{ "ChannelTagVisible", 	UIBinderSetIsVisible.New(self, self.PanelChannelTag) },
		{ "MsgType", 	 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMsgType) },
		{ "Channel", 	 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedChannel) },
	}
end

function ChatMsgTextItemView:OnDestroy()

end

function ChatMsgTextItemView:OnShow()

end

function ChatMsgTextItemView:OnHide()

end

function ChatMsgTextItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextMsgCenter, self.OnHyperlinkClicked)
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextMsgLeft, self.OnHyperlinkClicked)
end

function ChatMsgTextItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChatUpdateColor, self.OnGameEventUpdateColor)
end

function ChatMsgTextItemView:OnRegisterBinder()
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
end

function ChatMsgTextItemView:UpdateColor(Channel)
	local Color = ChatSetting.GetChannelColor(Channel)
	UIUtil.ImageSetColorAndOpacityHex(self.ImageTag, Color)
end

function ChatMsgTextItemView:OnValueChangedMsgType( ItemType )
	local IsAlignCenter = ItemType == ChatMsgType.TextTipsCenter or ItemType == ChatMsgType.FriendTips or ItemType == ChatMsgType.FriendRename
	UIUtil.SetIsVisible(self.RichTextMsgCenter, IsAlignCenter)
	UIUtil.SetIsVisible(self.RichTextMsgLeft, not IsAlignCenter)
end

function ChatMsgTextItemView:OnValueChangedChannel(Channel)
	if nil == Channel then
		return
	end

	-- 频道名
	local Name = ChatUtil.GetChannelName(Channel)
	self.TextChannel:SetText(Name or "")

	-- 标签颜色
	self:UpdateColor(Channel)
end

function ChatMsgTextItemView:OnGameEventUpdateColor()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self:UpdateColor(Params.Data.Channel)
end

function ChatMsgTextItemView:OnHyperlinkClicked(_, LinkID)
	ChatVM:HrefClicked(self.ViewModel, tonumber(LinkID))
end

return ChatMsgTextItemView