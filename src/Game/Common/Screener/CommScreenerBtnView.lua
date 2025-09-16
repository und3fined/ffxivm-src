---
--- Author: Administrator
--- DateTime: 2024-02-07 10:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")

local SearchBtnColorType = UIDefine.SearchBtnColorType
---@class CommScreenerBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgScreenerDark UFImage
---@field ImgScreenerLight UFImage
---@field ImgUnScreenerDark UFImage
---@field ImgUnScreenerLight UFImage
---@field ToggleButton UToggleButton
---@field ParamColor SearchBtnColorType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommScreenerBtnView = LuaClass(UIView, true)

function CommScreenerBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgScreenerDark = nil
	--self.ImgScreenerLight = nil
	--self.ImgUnScreenerDark = nil
	--self.ImgUnScreenerLight = nil
	--self.ToggleButton = nil
	--self.ParamColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommScreenerBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommScreenerBtnView:OnInit()
	self.OnStateChanged = self.ToggleButton.OnStateChanged
	self:SetColorType(self.ParamColor)
end

function CommScreenerBtnView:OnDestroy()
	self.OnStateChanged = nil
end

function CommScreenerBtnView:OnShow()

end

function CommScreenerBtnView:OnHide()

end

function CommScreenerBtnView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton, self.OnStateChangedEvent)
end

function CommScreenerBtnView:OnRegisterGameEvent()

end

function CommScreenerBtnView:OnRegisterBinder()

end

---SetStateChangedCallback
---@param View UIView
---@param Callback function
---@param CallbackParams any
---@deprecated @建议使用UIUtil.AddOnStateChangedEvent
function CommScreenerBtnView:SetStateChangedCallback(View, Callback, CallbackParams)
	self.View = View
	self.Callback = Callback
	self.CallbackParams = CallbackParams
end

function CommScreenerBtnView:OnStateChangedEvent(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)

	local Callback = self.Callback
	if nil ~= Callback then
		Callback(self.View, IsChecked, self.CallbackParams, self.CheckValue)
	end
end

function CommScreenerBtnView:SetChecked(IsChecked, InBroadcastDelegate)
	self.ToggleButton:SetChecked(IsChecked, InBroadcastDelegate)
end

function CommScreenerBtnView:GetChecked()
	return self.ToggleButton:GetChecked()
end

function CommScreenerBtnView:SetToggleState(State)
	self.ToggleButton:SetCheckedState(State)
end

--SetColorType
---@param ColorType SearchBtnColorType
---@private
function CommScreenerBtnView:SetColorType(ColorType)
	self.ColorType = ColorType
	self:UpdateColorType()
end

---UpdateColorType
---@private
function CommScreenerBtnView:UpdateColorType()
	self:UpdateImage(self.ColorType)
end

---UpdateImage
---@param ColorType SearchBtnColorType
---@private
function CommScreenerBtnView:UpdateImage(ColorType)
	UIUtil.SetIsVisible(self.ImgScreenerLight, 		SearchBtnColorType.Light == ColorType)
	UIUtil.SetIsVisible(self.ImgUnScreenerLight, 		SearchBtnColorType.Light == ColorType)
	UIUtil.SetIsVisible(self.ImgScreenerDark, 		SearchBtnColorType.Dark == ColorType)
	UIUtil.SetIsVisible(self.ImgUnScreenerDark, 		SearchBtnColorType.Dark == ColorType)
end


return CommScreenerBtnView