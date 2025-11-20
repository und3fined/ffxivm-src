---
--- Author: zhangyuhao_ds
--- DateTime: 2025-05-15 19:47
--- Description: CheckBoxBase
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")
local SearchBtnColorType = UIDefine.SearchBtnColorType

local TextColor = {
	Dark = "D5D5D5FF",
	Light = "313131FF",
}

local ResourceData = 
{
	GaryAddNum = 2,
	LightStart = 0,
	DarkStart = 4
}

---@class CommCheckBoxBaseView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckColorType SearchBtnColorType
---@field TextWidget FTextBlock
---@field Content text
---@field LightTextColor SlateColor
---@field IsGary bool
---@field DarkTextColor SlateColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommCheckBoxBaseView = LuaClass(UIView, true)

function CommCheckBoxBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckColorType = nil
	--self.TextWidget = nil
	--self.Content = nil
	--self.LightTextColor = nil
	--self.IsGary = nil
	--self.DarkTextColor = nil
	--self.ToggleButton = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommCheckBoxBaseView:OnInit()
	self.OnStateChanged = self.ToggleButton.OnStateChanged
end

function CommCheckBoxBaseView:OnShow()
	local Params = self.Params
	if nil == Params then return end
		
	local Text = Params.Text
	if nil == Text then return end

	self:SetText(Text)
end

function CommCheckBoxBaseView:OnDestroy()
	self.OnStateChanged = nil
end

--- 0 - 3 Light Uncheck Check DisableUncheck DisableChecked 
--- 4 - 7 Dark  Uncheck Check DisableUncheck DisableChecked 
function CommCheckBoxBaseView:GetResourceUnCheckIndex()
	local Index = ResourceData.LightStart
	if self.IsGary then
		Index = Index + ResourceData.GaryAddNum
	end

	if self.CheckColorType == SearchBtnColorType.Dark then
		Index = Index + ResourceData.DarkStart
	end

	return Index
end

function CommCheckBoxBaseView:UpdateCheckBoxShow(ImgData, CheckWidget, UnCheckWidget)
	local Index = self:GetResourceUnCheckIndex()
	UIUtil.ImageSetBrushFromAssetPath(CheckWidget, ImgData[Index + 1])
	UIUtil.ImageSetBrushFromAssetPath(UnCheckWidget, ImgData[Index])

	local Color = self.CheckColorType == SearchBtnColorType.Dark and TextColor.Dark or TextColor.Light
	UIUtil.SetColorAndOpacityHex(self.TextContent, Color)
end

function CommCheckBoxBaseView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton, self.OnStateChangedEvent)
end

---SetStateChangedCallback
---@param View UIView
---@param Callback function
---@param CallbackParams any
---@deprecated @建议使用UIUtil.AddOnStateChangedEvent
function CommCheckBoxBaseView:SetStateChangedCallback(View, Callback, CallbackParams)
	self.View = View
	self.Callback = Callback
	self.CallbackParams = CallbackParams
end

function CommCheckBoxBaseView:OnStateChangedEvent(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)

	local Callback = self.Callback
	if nil ~= Callback then
		Callback(self.View, IsChecked, self.CallbackParams)
	end
end

function CommCheckBoxBaseView:SetClickable(IsClickable)
	UIUtil.SetIsVisible(self.ToggleButton, true, IsClickable)
end

function CommCheckBoxBaseView:SetText(Text)
	self.TextContent:SetText(Text)
end

function CommCheckBoxBaseView:SetChecked(IsChecked, InBroadcastDelegate)
	self.ToggleButton:SetChecked(IsChecked, InBroadcastDelegate)
end

function CommCheckBoxBaseView:GetChecked()
	return self.ToggleButton:GetChecked()
end

function CommCheckBoxBaseView:SetCheckedState(IsChecked)
	self.ToggleButton:SetChecked(IsChecked)
end

function CommCheckBoxBaseView:SetToggleState(State)
	self.ToggleButton:SetCheckedState(State)
end

function CommCheckBoxBaseView:SetIsEnabled(bEnabled)
	self.ToggleButton:SetIsEnabled(bEnabled)
end

--- SetColorType 更新Dark or Light 及Gary状态
---@param ColorType SearchBtnColorType
---@param IsGary 	Boolean
function CommCheckBoxBaseView:SetColorType(ColorType, IsGary)
	if ColorType ~= self.CheckColorType or (IsGary ~= nil and  IsGary ~= self.IsGary) then
		self.IsGary = IsGary
		self.CheckColorType = ColorType
		self:UpdateCheckBoxShow(self.Style, self.FImg_Check, self.FImg_UnCheck)
	end
end

return CommCheckBoxBaseView