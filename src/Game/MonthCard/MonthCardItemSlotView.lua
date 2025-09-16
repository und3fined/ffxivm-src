---
--- Author: Administrator
--- DateTime: 2024-06-03 18:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MonthCardItemSlotVM = require("Game/MonthCard/VM/MonthCardItemSlotVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MonthCardItemSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSlot CommBackpackSlotView
---@field RichTextNum URichTextBox
---@field AnimRollFails UWidgetAnimation
---@field AnimRollUpLoop UWidgetAnimation
---@field AnimRollWait UWidgetAnimation
---@field AnimRollWin UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MonthCardItemSlotView = LuaClass(UIView, true)

function MonthCardItemSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSlot = nil
	--self.RichTextNum = nil
	--self.AnimRollFails = nil
	--self.AnimRollUpLoop = nil
	--self.AnimRollWait = nil
	--self.AnimRollWin = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MonthCardItemSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MonthCardItemSlotView:OnInit()
	-- self.MonthCardItemSlotVM = MonthCardItemSlotVM.New()
end

function MonthCardItemSlotView:OnDestroy()

end

function MonthCardItemSlotView:OnShow()

end

function MonthCardItemSlotView:OnHide()

end

function MonthCardItemSlotView:OnRegisterUIEvent()

end

function MonthCardItemSlotView:OnRegisterGameEvent()

end

function MonthCardItemSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		-- { "RichTextNum", UIBinderSetText.New(self, self.CommSlot.RichTextNum)},
		{ "RichTextNumVisible", UIBinderSetIsVisible.New(self, self.RichTextNum)},
	}

	self:RegisterBinders(ViewModel, Binders)
	self.CommSlot:SetParams({Data = ViewModel.ItemVM})
end

return MonthCardItemSlotView