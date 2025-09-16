---
--- Author: xingcaicao
--- DateTime: 2024-12-16 11:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class ChatHyperlinkHistoryTextItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButtonItem UFButton
---@field TextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatHyperlinkHistoryTextItemView = LuaClass(UIView, true)

function ChatHyperlinkHistoryTextItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButtonItem = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkHistoryTextItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkHistoryTextItemView:OnInit()
	self.Binders = {
		{"Content", UIBinderSetText.New(self, self.TextContent)},
	}
end

function ChatHyperlinkHistoryTextItemView:OnDestroy()

end

function ChatHyperlinkHistoryTextItemView:OnShow()

end

function ChatHyperlinkHistoryTextItemView:OnHide()

end

function ChatHyperlinkHistoryTextItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.TextContent, self.OnHyperlinkClicked)

	UIUtil.AddOnClickedEvent(self, self.FButtonItem, self.OnClickButtonItem)
end

function ChatHyperlinkHistoryTextItemView:OnRegisterGameEvent()

end

function ChatHyperlinkHistoryTextItemView:OnRegisterBinder()
	local Data = self.Params.Data
	if nil == Data then
		return
	end

	self:RegisterBinders(Data, self.Binders)
end

function ChatHyperlinkHistoryTextItemView:OnHyperlinkClicked()
	self:OnClickButtonItem()
end

function ChatHyperlinkHistoryTextItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ItemData = Params.Data
	if nil == ItemData then
		return
	end

	_G.EventMgr:SendEvent(_G.EventID.ChatHyperLinkSelectHistoryItem, ItemData)
end

return ChatHyperlinkHistoryTextItemView