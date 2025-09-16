---
--- Author: anypkvcai
--- DateTime: 2021-04-28 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommBtnBaseView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field TextButton UTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimState01 UWidgetAnimation
---@field AnimState02 UWidgetAnimation
---@field AnimState03 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBtnBaseView = LuaClass(UIView, true)

function CommBtnBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.TextButton = nil
	--self.AnimPressed = nil
	--self.AnimState01 = nil
	--self.AnimState02 = nil
	--self.AnimState03 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBtnBaseView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBtnBaseView:OnInit()
	self.OnClicked = self.Button.OnClicked
end

function CommBtnBaseView:OnDestroy()
	self.OnClicked = nil
end

function CommBtnBaseView:OnShow()

end

function CommBtnBaseView:OnHide()

end

function CommBtnBaseView:OnRegisterUIEvent()

end

function CommBtnBaseView:OnRegisterGameEvent()

end

function CommBtnBaseView:OnRegisterTimer()

end

function CommBtnBaseView:OnRegisterBinder()

end

---SetText
---@param Text string
function CommBtnBaseView:SetText(Text)
	self.TextButton:SetText(Text)
end

---GetText
---@return string
function CommBtnBaseView:GetText()
	self.TextButton:GetText()
end

---SetIsEnabled
---@param IsEnabled boolean
function CommBtnBaseView:SetIsEnabled(IsEnabled)
	self.Button:SetIsEnabled(IsEnabled)
	if IsEnabled then

	else

	end
end

---SetButtonText
---@deprecated @建议使用SetText
function CommBtnBaseView:SetButtonText(Text)
	self.TextButton:SetText(Text)
end

---SetOnClickedEvent
---@deprecated @建议使用UIUtil.AddOnClickedEvent
function CommBtnBaseView:SetOnClickedEvent(View, ClickedEventCallback)
	UIUtil.AddOnClickedEvent(View, self.Button, ClickedEventCallback)
end

---AddClicked
---@deprecated @建议使用UIUtil.AddOnClickedEvent
function CommBtnBaseView:AddClicked(View, Callback)
	UIUtil.AddOnClickedEvent(View, self.Button, Callback)
end

return CommBtnBaseView