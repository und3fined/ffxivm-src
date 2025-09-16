---
--- Author: eddardchen
--- DateTime: 2021-03-25 16:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class GMButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonText UTextBlock
---@field GMButton UButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMButtonView = LuaClass(UIView, true)

function GMButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonText = nil
	--self.GMButton = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMButtonView:OnInit()

end

function GMButtonView:OnDestroy()

end

function GMButtonView:OnShow()
	if self.Params ~= nil and self.Params.Desc ~= nil then
		self.ButtonText:SetText(self.Params.Desc)
	end
end

function GMButtonView:OnHide()

end

function GMButtonView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GMButton, self.OnGMButtonClick)
end

function GMButtonView:OnRegisterGameEvent()

end

function GMButtonView:OnRegisterTimer()

end

function GMButtonView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	local Binders =
	{
		{ "IsVisible", UIBinderSetIsVisible.New(self, self.GMButton, nil ,true) },
		{ "Desc", UIBinderValueChangedCallback.New(self, nil, self.OnDescValueChangedCallback) },

	}
	self:RegisterBinders(ViewModel, Binders)
end

function GMButtonView:OnDescValueChangedCallback()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = self.Params.Data
	if nil == self.ViewModel then
		return
	end
	self.ButtonText:SetText(self.ViewModel.Desc)
end

function GMButtonView:OnGMButtonClick()
	local EventID = require("Define/EventID")
	_G.EventMgr:SendEvent(EventID.GMButtonClick, self.ViewModel.Params)
end

return GMButtonView