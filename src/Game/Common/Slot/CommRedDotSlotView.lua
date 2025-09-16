---
--- Author: anypkvcai
--- DateTime: 2022-04-27 14:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class CommRedDotSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelRedDot UFCanvasPanel
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommRedDotSlotView = LuaClass(UIView, true)

function CommRedDotSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelRedDot = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommRedDotSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommRedDotSlotView:OnInit()
	self.Binders = {
		{ "Num", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedNum) },
		{ "IsVisible", UIBinderSetIsVisible.New(self, self.PanelRedDot) },
	}
end

function CommRedDotSlotView:OnDestroy()

end

function CommRedDotSlotView:OnShow()

end

function CommRedDotSlotView:OnHide()

end

function CommRedDotSlotView:OnRegisterUIEvent()

end

function CommRedDotSlotView:OnRegisterGameEvent()

end

function CommRedDotSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	if type(Params) ~= "table" then
		return
	end

	local ViewModel = Params

	if nil == ViewModel.Num then
		ViewModel = Params.Data
	end

	if type(ViewModel) ~= "table" then
		return
	end

	if nil == ViewModel.Num then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function CommRedDotSlotView:OnValueChangedNum(NewValue)
	if NewValue and NewValue > 0 then
		self:SetTextNum(NewValue > 99 and "99+" or NewValue)
	end
end

function CommRedDotSlotView:SetTextNum(Str)
	self.TextNum:SetText(Str)
end

return CommRedDotSlotView