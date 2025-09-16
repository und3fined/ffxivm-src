---
--- Author: Administrator
--- DateTime: 2024-06-04 20:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EventID = require("Define/EventID")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")




---@class CompanySealList2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack96Slot_UIBP CommBackpack96SlotView
---@field CommBackpackSlot_UIBP CommBackpackSlotView
---@field ImgFocus UFImage
---@field RichTextName URichTextBox
---@field SingleBox CommSingleBoxView
---@field AnimFadeOut UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealList2ItemView = LuaClass(UIView, true)

function CompanySealList2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack96Slot_UIBP = nil
	--self.CommBackpackSlot_UIBP = nil
	--self.ImgFocus = nil
	--self.RichTextName = nil
	--self.SingleBox = nil
	--self.AnimFadeOut = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealList2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack96Slot_UIBP)
	self:AddSubView(self.CommBackpackSlot_UIBP)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealList2ItemView:OnInit()
	UIUtil.SetIsVisible(self.ImgFocus, false)
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.RichTextName) },
		{ "ItemIcon", UIBinderSetImageBrush.New(self, self.CommBackpack96Slot_UIBP.Icon)},
		{ "ItemQualityIcon", UIBinderSetImageBrush.New(self, self.CommBackpack96Slot_UIBP.ImgQuanlity)},
		{ "TextQuantity", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot_UIBP.RichTextQuantity)},
		{ "TextLevel", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot_UIBP.RichTextLevel)},
		{ "IconChoose", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot_UIBP.IconChoose)},
		{ "ToggleButtonState", UIBinderSetCheckedState.New(self, self.SingleBox.ToggleButton) },
		{ "ImgFocusVisible", UIBinderSetIsVisible.New(self, self.ImgFocus)},
		{ "ItemVisilbe", UIBinderSetIsVisible.New(self, self.CommBackpack96Slot_UIBP)},
		{ "NameVisilbe", UIBinderSetIsVisible.New(self, self.RichTextName) },
	}
end

function CompanySealList2ItemView:OnDestroy()

end

function CompanySealList2ItemView:OnShow()
	self:PlayAnimation(self.AnimRefresh)
end

function CompanySealList2ItemView:OnHide()

end

function CompanySealList2ItemView:OnRegisterUIEvent()
	self.CommBackpack96Slot_UIBP:SetClickButtonCallback(self, self.OnTaskItemClicked)
end

function CompanySealList2ItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CompanySealPlaySubAni, self.PlaySubAni)
end

function CompanySealList2ItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function CompanySealList2ItemView:OnTaskItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	ItemTipsUtil.ShowTipsByGID(ViewModel.EquipGID, self.CommBackpack96Slot_UIBP, _G.UE4.FVector2D(0, 0))
end

function CompanySealList2ItemView:PlaySubAni(List)
	for i = 1, #List do
		local EquipGID = List[i].EquipGID
		if EquipGID and EquipGID == self.ViewModel.EquipGID then
			self:PlayAnimation(self.AnimFadeOut)
		end
	end
end

-- function CompanySealList2ItemView:OnSelectChanged(NewValue)
-- 	self.ViewModel:SetToggleBtnState(NewValue)
-- end

return CompanySealList2ItemView