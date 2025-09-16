---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FishSlotItemVM = require("Game/FishNotes/ItemVM/FishSlotItemVM")

---@class FishIngholeFishListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FishNotesSlot FishNotesSlotItemView
---@field IconTime UFImage
---@field ProBarCD UProgressBar
---@field TextName URichTextBox
---@field TextPlace URichTextBox
---@field TextTime UFTextBlock
---@field ToggleButton_0 UToggleButton
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeFishListItemView = LuaClass(UIView, true)

function FishIngholeFishListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FishNotesSlot = nil
	--self.IconTime = nil
	--self.ProBarCD = nil
	--self.TextName = nil
	--self.TextPlace = nil
	--self.TextTime = nil
	--self.ToggleButton_0 = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeFishListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishNotesSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeFishListItemView:OnInit()
	self.Binders = {
		{ "TextPlace", UIBinderSetText.New(self, self.TextPlace) },
		{ "ClockFishName", UIBinderSetText.New(self, self.TextName) },
		{ "ClockTime", UIBinderSetText.New(self, self.TextTime) },
		{ "ClockInWindowTimeColor",UIBinderSetColorAndOpacityHex.New(self,self.TextName)},
		{ "ClockInWindowTimeColor",UIBinderSetColorAndOpacityHex.New(self,self.TextTime)},
		{ "ClockInWindowTimeColor",UIBinderSetColorAndOpacityHex.New(self,self.TextPlace)},
		{ "ClockIsSelected", UIBinderSetIsChecked.New(self, self.ToggleButton_0)},
		{ "bActive", UIBinderSetIsVisible.New(self, self.IconTime)},
		{ "bActive", UIBinderSetIsVisible.New(self, self.ProBarCD)},
		{ "ProgressValue", UIBinderValueChangedCallback.New(self, nil, self.SetAnimProBar) },
		{ "SlotData", UIBinderValueChangedCallback.New(self, nil, self.SetSlotData) },
	}
	self.ToggleButton_0:SetChecked(false)
	self.SlotVM = _G.ObjectPoolMgr:AllocObject(FishSlotItemVM)
end

function FishIngholeFishListItemView:SetSlotData(Value)
	self.SlotVM:UpdateVM(Value)
end

function FishIngholeFishListItemView:OnDestroy()
	_G.ObjectPoolMgr:FreeObject(FishSlotItemVM, self.SlotVM)
	self.ItemVM = nil
end

function FishIngholeFishListItemView:OnShow()
end

function FishIngholeFishListItemView:OnHide()
end

function FishIngholeFishListItemView:OnRegisterUIEvent()
end

function FishIngholeFishListItemView:OnRegisterGameEvent()
end

function FishIngholeFishListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	--local SlotVM = ViewModel.SlotVM
	self.FishNotesSlot:SetParams({Data = self.SlotVM})
end

function FishIngholeFishListItemView:SetAnimProBar(Progress, OldProgress)
	if Progress == nil then
		self:PlayAnimationTimeRange(self.AnimProBar, 1, 1.01, 1, nil, 1.0, false)
		return
	end
	if OldProgress == nil or Progress > OldProgress then
		OldProgress = Progress + 0.01
	end
	self:PlayAnimationTimeRange(self.AnimProBar, 1-OldProgress, 1-Progress, 1, nil, 1.0, false)
end

return FishIngholeFishListItemView