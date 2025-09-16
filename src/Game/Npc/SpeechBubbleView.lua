---
--- Author: zimuyi
--- DateTime: 2021-08-13 19:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SpeechBubbleView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Border_Speech UBorder
---@field Text_Speech UTextBlock
---@field Anim_Aoto_In UWidgetAnimation
---@field Anim_Aoto_Out UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SpeechBubbleView = LuaClass(UIView, true)

function SpeechBubbleView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.Border_Speech = nil
	self.Text_Speech = nil
	self.Anim_Aoto_In = nil
	self.Anim_Aoto_Out = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SpeechBubbleView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SpeechBubbleView:SetContent(Content)
	if self.Text_Speech then
		self.Text_Speech:SetText(Content)
	end
end

function SpeechBubbleView:OnInit()

end

function SpeechBubbleView:OnDestroy()

end

function SpeechBubbleView:OnShow()

end

function SpeechBubbleView:OnHide()

end

function SpeechBubbleView:OnRegisterUIEvent()

end

function SpeechBubbleView:OnRegisterGameEvent()

end

function SpeechBubbleView:OnRegisterTimer()

end

function SpeechBubbleView:OnRegisterBinder()

end

return SpeechBubbleView