---
--- Author: ashyuan
--- DateTime: 2024-05-01 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TeachingType = require("Game/Pworld/Teaching/TeachingType")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local FLOG_INFO = _G.FLOG_INFO

---@class PWorldTeachingProjectItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FWidgetSwitcher_0 UFWidgetSwitcher
---@field Icon1 UFImage
---@field Icon2 UFImage
---@field Icon3 UFImage
---@field PanelCompleted UFCanvasPanel
---@field PanelOngoing UFCanvasPanel
---@field PanelUnopened UFCanvasPanel
---@field TextCompleted UFTextBlock
---@field TextOngoing UFTextBlock
---@field TextUnopened UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimStatus2In UWidgetAnimation
---@field AnimStatus3In UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeachingProjectItemView = LuaClass(UIView, true)

function PWorldTeachingProjectItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FWidgetSwitcher_0 = nil
	--self.Icon1 = nil
	--self.Icon2 = nil
	--self.Icon3 = nil
	--self.PanelCompleted = nil
	--self.PanelOngoing = nil
	--self.PanelUnopened = nil
	--self.TextCompleted = nil
	--self.TextOngoing = nil
	--self.TextUnopened = nil
	--self.AnimIn = nil
	--self.AnimStatus2In = nil
	--self.AnimStatus3In = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeachingProjectItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeachingProjectItemView:OnInit()

end

function PWorldTeachingProjectItemView:OnDestroy()

end

function PWorldTeachingProjectItemView:OnShow()

end

function PWorldTeachingProjectItemView:OnHide()

end

function PWorldTeachingProjectItemView:OnRegisterUIEvent()

end

function PWorldTeachingProjectItemView:OnRegisterGameEvent()
end

function PWorldTeachingProjectItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	local Binders = {
		{ "Desc", UIBinderSetText.New(self, self.TextCompleted) },
		{ "Desc", UIBinderSetText.New(self, self.TextOngoing) },
		{ "Desc", UIBinderSetText.New(self, self.TextUnopened) },
		{ "State", UIBinderSetActiveWidgetIndex.New(self, self.FWidgetSwitcher_0) },
		{ "State", UIBinderValueChangedCallback.New(self, nil, self.OnStateChange)},
	}
	
	self:RegisterBinders(self.ViewModel, Binders)
end

function PWorldTeachingProjectItemView:OnStateChange()
	if not self.ViewModel then
		return
	end

	FLOG_INFO("TeachingItem StateChange[%s][%d]", self.ViewModel.Desc, self.ViewModel.State)

	local State = self.ViewModel.State
	if State == TeachingType.Item_State.Completed then
		self:PlayAnimation(self.AnimStatus3In)
	elseif State == TeachingType.Item_State.Ongoing then
		self:PlayAnimation(self.AnimStatus2In)
	elseif State == TeachingType.Item_State.UnOpened then
		self:PlayAnimation(self.AnimIn)
	end
end	

return PWorldTeachingProjectItemView