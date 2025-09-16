---
--- Author: anypkvcai
--- DateTime: 2022-05-02 16:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommCheckBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextContent UFTextBlock
---@field ToggleButton UToggleButton
---@field CheckValue int
---@field Content text
---@field CheckedColor LinearColor
---@field UnCheckedColor LinearColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommCheckBoxView = LuaClass(UIView, true)

function CommCheckBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextContent = nil
	--self.ToggleButton = nil
	--self.CheckValue = nil
	--self.Content = nil
	--self.CheckedColor = nil
	--self.UnCheckedColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommCheckBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommCheckBoxView:OnInit()
	self.OnStateChanged = self.ToggleButton.OnStateChanged
end

function CommCheckBoxView:OnDestroy()
	self.OnStateChanged = nil
end

function CommCheckBoxView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Text = Params.Text
	if nil == Text then
		return
	end

	self.TextContent:SetText(Text)
end

function CommCheckBoxView:OnHide()

end

function CommCheckBoxView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton, self.OnStateChangedEvent)
end

function CommCheckBoxView:OnRegisterGameEvent()

end

function CommCheckBoxView:OnRegisterBinder()

end

---SetStateChangedCallback
---@param View UIView
---@param Callback function
---@param CallbackParams any
---@deprecated @建议使用UIUtil.AddOnStateChangedEvent
function CommCheckBoxView:SetStateChangedCallback(View, Callback, CallbackParams)
	self.View = View
	self.Callback = Callback
	self.CallbackParams = CallbackParams
end

function CommCheckBoxView:OnStateChangedEvent(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)

	self:UpdateColor(IsChecked)

	local Callback = self.Callback
	if nil ~= Callback then
		Callback(self.View, IsChecked, self.CallbackParams, self.CheckValue)
	end
end

function CommCheckBoxView:SetChecked(IsChecked, InBroadcastDelegate)
	self.ToggleButton:SetChecked(IsChecked, InBroadcastDelegate)

	self:UpdateColor(IsChecked)
end

function CommCheckBoxView:GetChecked()
	return self.ToggleButton:GetChecked()
end

function CommCheckBoxView:UpdateColor(IsChecked)
	self.TextContent:SetColorAndOpacity(IsChecked and self.CheckedColor or self.UnCheckedColor)
end

function CommCheckBoxView:SetText(Text)
	self.TextContent:SetText(Text)
end

function CommCheckBoxView:SetClickable( IsClickable )
	UIUtil.SetIsVisible(self.ToggleButton, true, IsClickable)
end

return CommCheckBoxView