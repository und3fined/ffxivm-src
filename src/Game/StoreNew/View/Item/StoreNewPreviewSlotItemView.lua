---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class StoreNewPreviewSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnView UToggleButton
---@field Comm96Slot CommBackpack96SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewPreviewSlotItemView = LuaClass(UIView, true)

function StoreNewPreviewSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnView = nil
	--self.Comm96Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewPreviewSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewPreviewSlotItemView:OnInit()
	self.Binders = {
		{"SelectBtnState", UIBinderSetIsChecked.New(self, self.BtnView)},
		{"BtnViewVisible", UIBinderSetIsVisible.New(self, self.BtnView, false, true)},
		{"bOwned", UIBinderValueChangedCallback.New(self, nil, self.OnbOwnedValueChanged)},
	}
end

function StoreNewPreviewSlotItemView:OnDestroy()

end

function StoreNewPreviewSlotItemView:OnShow()

end

function StoreNewPreviewSlotItemView:OnHide()
end

function StoreNewPreviewSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnView, self.OnChangedToggleBtnView)
end

function StoreNewPreviewSlotItemView:OnChangedToggleBtnView(ToggleGroup, BtnState)
	local Params = self.Params
    if nil == Params then return end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

	self.IsClickBtnView = true
    Adapter:OnItemClicked(self, Params.Index)
end
function StoreNewPreviewSlotItemView:OnRegisterGameEvent()

end

function StoreNewPreviewSlotItemView:OnRegisterBinder()
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

function StoreNewPreviewSlotItemView:OnbOwnedValueChanged(NewValue)
	UIUtil.SetIsVisible(self.Comm96Slot.ImgMask, NewValue)
    UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, NewValue)
end

return StoreNewPreviewSlotItemView