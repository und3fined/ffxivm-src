---
--- Author: Administrator
--- DateTime: 2024-04-16 17:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NPCTextBubbleNormalItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCTextBubbleNormalItemView = LuaClass(UIView, true)

function NPCTextBubbleNormalItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCTextBubbleNormalItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCTextBubbleNormalItemView:OnInit()

end

function NPCTextBubbleNormalItemView:OnDestroy()

end

function NPCTextBubbleNormalItemView:OnShow()

end

function NPCTextBubbleNormalItemView:OnHide()

end

function NPCTextBubbleNormalItemView:OnRegisterUIEvent()

end

function NPCTextBubbleNormalItemView:OnRegisterGameEvent()

end

function NPCTextBubbleNormalItemView:OnRegisterBinder()

end

function NPCTextBubbleNormalItemView:SetContent(Content)
	if self.Text then
		self.Text:SetText(Content)
	end
end

return NPCTextBubbleNormalItemView