---
--- Author: rock
--- DateTime: 2024-12-18 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

---@class PreviewEquipSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnView UToggleButton
---@field Comm96Slot CommBackpack96SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PreviewEquipSlotItemView = LuaClass(UIView, true)

function PreviewEquipSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnView = nil
	--self.Comm96Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PreviewEquipSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PreviewEquipSlotItemView:OnInit()
	self.Binders = {
		{"SelectBtnState", UIBinderSetIsChecked.New(self, self.BtnView)},
		{"bOwned", UIBinderValueChangedCallback.New(self, nil, self.OnbOwnedValueChanged)},
	}
end

function PreviewEquipSlotItemView:OnDestroy()

end

function PreviewEquipSlotItemView:OnShow()

end

function PreviewEquipSlotItemView:OnHide()
end

function PreviewEquipSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnView, self.OnChangedToggleBtnView)
end

function PreviewEquipSlotItemView:OnChangedToggleBtnView(ToggleGroup, BtnState)
	local Params = self.Params
    if nil == Params then return end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

	self.IsClickBtnView = true
    Adapter:OnItemClicked(self, Params.Index)
end
function PreviewEquipSlotItemView:OnRegisterGameEvent()

end

function PreviewEquipSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function PreviewEquipSlotItemView:OnbOwnedValueChanged(NewValue)
	UIUtil.SetIsVisible(self.Comm96Slot.ImgMask, NewValue)
    UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, NewValue)
end

return PreviewEquipSlotItemView