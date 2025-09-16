---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class StoreNewCouponsListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommCheckBoxView
---@field Comm96Slot CommBackpack96SlotView
---@field TextExplain UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewCouponsListItemView = LuaClass(UIView, true)

function StoreNewCouponsListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--self.Comm96Slot = nil
	--self.TextExplain = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewCouponsListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewCouponsListItemView:OnInit()
	self.Binders = {
		{ "TittleText", 		UIBinderSetText.New(self, self.TextTitle) },
		{ "ExplainText", 		UIBinderSetText.New(self, self.TextExplain) },
		{ "TimeText", 			UIBinderSetText.New(self, self.TextTime) },
		{ "CheckBoxEnable", 	UIBinderSetIsChecked.New(self, self.CheckBox.ToggleButton)},
		{ "bCanSelect",            UIBinderSetIsVisible.New(self, self.CheckBox.ImgDisabledMask, true, true)}
	}

end

function StoreNewCouponsListItemView:OnDestroy()

end

function StoreNewCouponsListItemView:OnShow()
	self.Comm96Slot:SetParams({ Data = self.ViewModel.ItemSlotData })
end

function StoreNewCouponsListItemView:OnHide()

end

function StoreNewCouponsListItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox.ToggleButton, self.OnStateChangedEvent)
end

function StoreNewCouponsListItemView:OnRegisterGameEvent()

end

function StoreNewCouponsListItemView:OnStateChangedEvent(ToggleGroup, ToggleButton, BtnState)
	-- BtnState == _G.UE.EToggleButtonState.Unchecked
	_G.StoreMainVM:UpdateCouponChoose(self.ViewModel.Index, self.ViewModel.ResID, not self.ViewModel.CheckBoxEnable)
	_G.StoreMainVM:UpdateCouponsSelectedState()
end

function StoreNewCouponsListItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreNewCouponsListItemView