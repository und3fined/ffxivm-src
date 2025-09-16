---
--- Author: Administrator
--- DateTime: 2023-10-20 20:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EmoActPanelVM = require("Game/EmoAct/EmoActPanelVM")

---@class EmoActContentItemMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActContentItemMView = LuaClass(UIView, true)

function EmoActContentItemMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActContentItemMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActContentItemMView:OnInit()
	self.Binders = {
		{ "RichTextContent", UIBinderSetText.New(self, self.RichTextContent) },
	}
end

function EmoActContentItemMView:OnDestroy()

end

function EmoActContentItemMView:OnShow()
	-- 没有使用到
	-- if self.RichTextContent and self.Params.Data then
	-- 	self.RichTextContent:SetText(self.Params.Data)
	-- end
end

function EmoActContentItemMView:OnHide()

end

function EmoActContentItemMView:OnRegisterUIEvent()

	self:RegisterBinders(EmoActPanelVM, self.Binders)
end

function EmoActContentItemMView:OnRegisterGameEvent()

end

function EmoActContentItemMView:OnRegisterBinder()

end

return EmoActContentItemMView