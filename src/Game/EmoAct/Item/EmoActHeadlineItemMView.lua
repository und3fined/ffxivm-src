---
--- Author: Administrator
--- DateTime: 2025-08-19 20:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class EmoActHeadlineItemMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextTitle URichTextBox
---@field TextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActHeadlineItemMView = LuaClass(UIView, true)

function EmoActHeadlineItemMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextTitle = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActHeadlineItemMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActHeadlineItemMView:OnInit()

end

function EmoActHeadlineItemMView:OnDestroy()

end

function EmoActHeadlineItemMView:OnShow()
	if self.Params and self.Params.Data then
		if self.RichTextTitle then
			self.RichTextTitle:SetText(self.Params.Data.Title)
		end
		if self.TextContent then
			self.TextContent:SetText(self.Params.Data.Content)
		end
	end
end

function EmoActHeadlineItemMView:OnHide()

end

function EmoActHeadlineItemMView:OnRegisterUIEvent()

end

function EmoActHeadlineItemMView:OnRegisterGameEvent()

end

function EmoActHeadlineItemMView:OnRegisterBinder()

end

return EmoActHeadlineItemMView