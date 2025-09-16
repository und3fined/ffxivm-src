---
--- Author: xingcaicao
--- DateTime: 2024-12-13 18:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChatGifItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgGif UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatGifItemView = LuaClass(UIView, true)

function ChatGifItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgGif = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatGifItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatGifItemView:OnInit()

end

function ChatGifItemView:OnDestroy()

end

function ChatGifItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	UIUtil.ImageSetBrushFromAssetPath(self.ImgGif, Data.Icon)
end

function ChatGifItemView:OnHide()

end

function ChatGifItemView:OnRegisterUIEvent()

end

function ChatGifItemView:OnRegisterGameEvent()

end

function ChatGifItemView:OnRegisterBinder()

end

return ChatGifItemView