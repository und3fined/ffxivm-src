---
--- Author: xingcaicao
--- DateTime: 2024-11-27 20:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChatEmojiItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgEmoji UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatEmojiItemView = LuaClass(UIView, true)

function ChatEmojiItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgEmoji = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatEmojiItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatEmojiItemView:OnInit()

end

function ChatEmojiItemView:OnDestroy()

end

function ChatEmojiItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	UIUtil.ImageSetBrushFromAssetPath(self.ImgEmoji, Data.Icon)
end

function ChatEmojiItemView:OnHide()

end

function ChatEmojiItemView:OnRegisterUIEvent()

end

function ChatEmojiItemView:OnRegisterGameEvent()

end

function ChatEmojiItemView:OnRegisterBinder()

end

return ChatEmojiItemView