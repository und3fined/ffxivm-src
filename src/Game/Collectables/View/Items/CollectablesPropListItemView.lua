---
--- Author: Administrator
--- DateTime: 2025-03-04 15:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CollectablesVM = require("Game/Collectables/CollectablesVM")

local ESlateVisibility = _G.UE.ESlateVisibility

---@class CollectablesPropListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field TextPropNum UFTextBlock
---@field ToggleBtnProp UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CollectablesPropListItemView = LuaClass(UIView, true)

function CollectablesPropListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--self.TextPropNum = nil
	--self.ToggleBtnProp = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CollectablesPropListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CollectablesPropListItemView:OnInit()
	self.Binders = {
		{ "CollectValue", UIBinderSetText.New(self, self.TextPropNum) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.Icon) },
		{ "bIsSelect", UIBinderSetIsVisible.New(self, self.Comm96Slot.ImgSelect) },
	}
	UIUtil.SetIsVisible(self.Comm96Slot.RedDot2, false)
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, false)
	self.Comm96Slot:SetVisibility(ESlateVisibility.HitTestInvisible)
end

function CollectablesPropListItemView:OnDestroy()

end

function CollectablesPropListItemView:OnShow()

end

function CollectablesPropListItemView:OnHide()

end

function CollectablesPropListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnProp, self.OnToggleBtnPropClick)
end

function CollectablesPropListItemView:OnRegisterGameEvent()

end

function CollectablesPropListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

---@type 点击ToggleBtn
function CollectablesPropListItemView:OnToggleBtnPropClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	CollectablesVM:OnPossSelectChanged(ViewModel)
end

return CollectablesPropListItemView