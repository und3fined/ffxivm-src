---
--- Author: anypkvcai
--- DateTime: 2021-04-28 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ColorDefine = require("Define/ColorDefine")

---@class CommonButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnText UTextBlock
---@field MainBtn UFButton
---@field ButtonText string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonButtonView = LuaClass(UIView, true)

function CommonButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY

	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.ColorAndOpacity = nil
end

function CommonButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonButtonView:OnInit()
	self.ColorAndOpacity = self.BtnText.ColorAndOpacity:GetSpecifiedColor()
end

function CommonButtonView:OnDestroy()

end

function CommonButtonView:OnShow()

end

function CommonButtonView:OnHide()

end

function CommonButtonView:OnRegisterUIEvent()

end

function CommonButtonView:OnRegisterGameEvent()

end

function CommonButtonView:OnRegisterTimer()

end

function CommonButtonView:OnRegisterBinder()

end

function CommonButtonView:SetButtonText(Text)
	self.BtnText:SetText(Text)
end

function CommonButtonView:SetOnClickedEvent(View, ClickedEventCallback)
	UIUtil.AddOnClickedEvent(View, self.MainBtn, ClickedEventCallback)

end

function CommonButtonView:SetIsEnabled(IsEnabled)
	self.MainBtn:SetIsEnabled(IsEnabled)

	if IsEnabled then
		self.BtnText:SetColorAndOpacity(self.ColorAndOpacity)
	else
		self.BtnText:SetColorAndOpacity(ColorDefine.LinearColor.Gray)
	end
end

return CommonButtonView