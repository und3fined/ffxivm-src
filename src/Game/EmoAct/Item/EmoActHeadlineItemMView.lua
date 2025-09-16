---
--- Author: Administrator
--- DateTime: 2023-10-20 20:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EmoActPanelVM = require("Game/EmoAct/EmoActPanelVM")

---@class EmoActHeadlineItemMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActHeadlineItemMView = LuaClass(UIView, true)

function EmoActHeadlineItemMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActHeadlineItemMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActHeadlineItemMView:OnInit()
	-- self.Binders = {
	-- 	{ "RichTextContent", UIBinderSetText.New(self, self.RichTextContent) },
	-- }
end

function EmoActHeadlineItemMView:OnDestroy()

end

function EmoActHeadlineItemMView:OnShow()
	if self.RichTextContent and self.Params.Data then
		self.RichTextContent:SetText(self.Params.Data)
	end
end

function EmoActHeadlineItemMView:OnHide()

end

function EmoActHeadlineItemMView:OnRegisterUIEvent()
	-- self:RegisterBinders(EmoActPanelVM, self.Binders)
end

function EmoActHeadlineItemMView:OnRegisterGameEvent()

end

function EmoActHeadlineItemMView:OnRegisterBinder()

end

return EmoActHeadlineItemMView