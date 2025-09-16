---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")

---@class FishTimeProbarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg UFImage
---@field BtnClock UToggleButton
---@field FishTimeProbar FishTimeProbarView
---@field TextState UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTimeProbarItemView = LuaClass(UIView, true)

function FishTimeProbarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnClock = nil
	--self.FishTimeProbar = nil
	--self.TextState = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTimeProbarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishTimeProbar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTimeProbarItemView:OnInit()
	self.Binders = {
		{ "FishDetailsTimeState", UIBinderSetText.New(self, self.TextState) },
		{ "FishDetailsTime", UIBinderSetText.New(self, self.TextTime) },
		{ "FishDetailClockState", UIBinderSetCheckedState.New(self, self.BtnClock)},
		{ "bFishDetailClockEnabled", UIBinderSetIsEnabled.New(self, self.BtnClock)},
		{ "bFishDetailClockVisible", UIBinderSetIsVisible.New(self, self.BtnClock, false, true)},
		{ "bFishDetailProBarCDVisible", UIBinderSetIsVisible.New(self, self.FishTimeProbar)},
		{ "bFishDetailProBarCDVisible", UIBinderSetIsVisible.New(self, self.Bg, true)},
		{ "FishDetailsProgress", UIBinderValueChangedCallback.New(self, nil, self.SetAnimProBar) },
	}
end

function FishTimeProbarItemView:OnDestroy()

end

function FishTimeProbarItemView:OnShow()

end

function FishTimeProbarItemView:OnHide()

end

function FishTimeProbarItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClock, self.OnClickButtonClock)
end

function FishTimeProbarItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.FishNoteClockSubscribeChanged, self.OnUpdateClockButtonState)
end

function FishTimeProbarItemView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

function FishTimeProbarItemView:OnClickButtonClock()
	local Result = FishIngholeVM:ChangeFishClockState()
	if Result == false then
		self.BtnClock:SetCheckedState(_G.UE.EToggleButtonState.UnChecked)
	end
end

function FishTimeProbarItemView:OnUpdateClockButtonState(ItemID, IsSubscribe)
	FishIngholeVM:UpdateFishClockButtonState(ItemID, IsSubscribe)
end

function FishTimeProbarItemView:SetAnimProBar(Progress, OldProgress)
	self.FishTimeProbar:SetAnimProBar(Progress, OldProgress)
end

return FishTimeProbarItemView