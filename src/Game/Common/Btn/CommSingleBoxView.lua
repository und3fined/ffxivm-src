---
--- Author: anypkvcai
--- DateTime: 2022-05-25 10:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")

local SearchBtnColorType = UIDefine.SearchBtnColorType
local EToggleButtonState = _G.UE.EToggleButtonState
---@class CommSingleBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Box_Dark UFImage
---@field FImg_Box_Light UFImage
---@field FImg_Check_Dark UFImage
---@field FImg_Check_Light UFImage
---@field TextContent UFTextBlock
---@field ToggleButton UToggleButton
---@field CheckValue int
---@field Content text
---@field UnCheckedColor LinearColor
---@field CheckedColor LinearColor
---@field ParamColor SearchBtnColorType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSingleBoxView = LuaClass(UIView, true)

function CommSingleBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Box_Dark = nil
	--self.FImg_Box_Light = nil
	--self.FImg_Check_Dark = nil
	--self.FImg_Check_Light = nil
	--self.TextContent = nil
	--self.ToggleButton = nil
	--self.CheckValue = nil
	--self.Content = nil
	--self.UnCheckedColor = nil
	--self.CheckedColor = nil
	--self.ParamColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSingleBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSingleBoxView:OnInit()
	self.OnStateChanged = self.ToggleButton.OnStateChanged
	self:SetColorType(self.ParamColor)
end

function CommSingleBoxView:OnDestroy()
	self.OnStateChanged = nil
end

function CommSingleBoxView:OnShow()
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

function CommSingleBoxView:OnHide()

end

function CommSingleBoxView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton, self.OnStateChangedEvent)
end

function CommSingleBoxView:OnRegisterGameEvent()

end

function CommSingleBoxView:OnRegisterBinder()

end

---SetStateChangedCallback
---@param View UIView
---@param Callback function
---@param CallbackParams any
---@deprecated @建议使用UIUtil.AddOnStateChangedEvent
function CommSingleBoxView:SetStateChangedCallback(View, Callback, CallbackParams)
	self.View = View
	self.Callback = Callback
	self.CallbackParams = CallbackParams
end

function CommSingleBoxView:OnStateChangedEvent(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)

	self:UpdateColor(IsChecked)

	local Callback = self.Callback
	if nil ~= Callback then
		Callback(self.View, IsChecked, self.CallbackParams, self.CheckValue)
	end
end

function CommSingleBoxView:SetChecked(IsChecked, InBroadcastDelegate)
	self.ToggleButton:SetChecked(IsChecked, InBroadcastDelegate)

	self:UpdateColor(IsChecked)
end
function CommSingleBoxView:SetCheckedState(IsChecked)
	self.ToggleButton:SetChecked(IsChecked)

	self:UpdateColor(IsChecked)
end
function CommSingleBoxView:GetChecked()
	return self.ToggleButton:GetChecked()
end

function CommSingleBoxView:UpdateColor(IsChecked)
	self.TextContent:SetColorAndOpacity(IsChecked and self.CheckedColor or self.UnCheckedColor)
end

function CommSingleBoxView:SetText(Text)
	self.TextContent:SetText(Text)
end

function CommSingleBoxView:SetToggleState(State)
	self.ToggleButton:SetCheckedState(State)

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	self:UpdateColor(IsChecked)
end

--- 置灰状态
function CommSingleBoxView:SetIsGray(IsGary)
	local State = IsGary and EToggleButtonState.Locked or EToggleButtonState.Unchecked
	self.ToggleButton:SetCheckedState(State)
	self:UpdateColor(false)
end

--SetColorType
---@param ColorType SearchBtnColorType
---@private
function CommSingleBoxView:SetColorType(ColorType)
	self.ColorType = ColorType
	self:UpdateColorType()
end

---UpdateColorType
---@private
function CommSingleBoxView:UpdateColorType()
	self:UpdateImage(self.ColorType)
end

---UpdateImage
---@param ColorType SearchBtnColorType
---@private
function CommSingleBoxView:UpdateImage(ColorType)
	UIUtil.SetIsVisible(self.FImg_Box_Light, 		SearchBtnColorType.Light == ColorType)
	UIUtil.SetIsVisible(self.FImg_Check_Light, 		SearchBtnColorType.Light == ColorType)
	UIUtil.SetIsVisible(self.ImgLightDisable, 		SearchBtnColorType.Light == ColorType)
	UIUtil.SetIsVisible(self.FImg_Box_Dark, 		SearchBtnColorType.Dark == ColorType)
	UIUtil.SetIsVisible(self.FImg_Check_Dark, 		SearchBtnColorType.Dark == ColorType)
	UIUtil.SetIsVisible(self.ImgDarkDisable, 		SearchBtnColorType.Dark == ColorType)
end

function CommSingleBoxView:SetIsEnabled(bEnabled)
	self.ToggleButton:SetIsEnabled(bEnabled)
end

return CommSingleBoxView