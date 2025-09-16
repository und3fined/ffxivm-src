---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

---@class FishIngholeTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClock UToggleButton
---@field FishNotesSlot FishNotesSlotItemView
---@field ImgClock UFImage
---@field ProBarCD UProgressBar
---@field TextNum UFTextBlock
---@field TextNum2 UFTextBlock
---@field TextState UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeTipsItemView = LuaClass(UIView, true)

function FishIngholeTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClock = nil
	--self.FishNotesSlot = nil
	--self.ImgClock = nil
	--self.ProBarCD = nil
	--self.TextNum = nil
	--self.TextNum2 = nil
	--self.TextState = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishNotesSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeTipsItemView:OnInit()
	self.TextNum:SetText(_G.LSTR(180087))--"钓起数量："
	self.Binders = {
		{ "TextState", UIBinderSetText.New(self, self.TextState) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },
		{ "ClockState", UIBinderSetCheckedState.New(self, self.BtnClock)},
		{ "bClockEnabled", UIBinderSetIsEnabled.New(self, self.BtnClock)},
		{ "bClockVisible", UIBinderSetIsVisible.New(self, self.BtnClock, false, true)},
		{ "bProBarCDVisible", UIBinderSetIsVisible.New(self, self.ImgClock)},
		{ "bProBarCDVisible", UIBinderSetIsVisible.New(self, self.ProBarCD)},
		{ "ProgressValue", UIBinderSetPercent.New(self, self.ProBarCD)},
		{ "Num", UIBinderSetText.New(self, self.TextNum2) },
	}
	UIUtil.SetIsVisible(self.FishNotesSlot.BtnItem, true, true, true)
end

function FishIngholeTipsItemView:OnDestroy()

end

function FishIngholeTipsItemView:OnShow()

end

function FishIngholeTipsItemView:OnHide()

end

function FishIngholeTipsItemView:OnRegisterUIEvent()

end

function FishIngholeTipsItemView:OnRegisterGameEvent()

end

function FishIngholeTipsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	local SlotVM = ViewModel.SlotVM
	self.FishNotesSlot:SetParams({Data = SlotVM})
end

return FishIngholeTipsItemView