---
--- Author: Administrator
--- DateTime: 2024-04-16 17:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NPCTextBubbleFocusItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_1 UFCanvasPanel
---@field Text UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCTextBubbleFocusItemView = LuaClass(UIView, true)

function NPCTextBubbleFocusItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_1 = nil
	--self.Text = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCTextBubbleFocusItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCTextBubbleFocusItemView:OnInit()

end

function NPCTextBubbleFocusItemView:OnDestroy()

end

function NPCTextBubbleFocusItemView:OnShow()

end

function NPCTextBubbleFocusItemView:OnHide()

end

function NPCTextBubbleFocusItemView:OnRegisterUIEvent()

end

function NPCTextBubbleFocusItemView:OnRegisterGameEvent()

end

function NPCTextBubbleFocusItemView:OnRegisterBinder()

end

function NPCTextBubbleFocusItemView:SetContent(Content)
	if self.Text then
		self.Text:SetText(Content)
	end
end

return NPCTextBubbleFocusItemView