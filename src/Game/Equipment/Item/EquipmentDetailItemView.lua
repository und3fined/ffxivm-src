---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class EquipmentDetailItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgWearing UFImage
---@field InforCommItem EquipmentInforCommItemView
---@field SelectImg UFImage
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentDetailItemView = LuaClass(UIView, true)

function EquipmentDetailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgWearing = nil
	--self.InforCommItem = nil
	--self.SelectImg = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentDetailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.InforCommItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentDetailItemView:OnInit()

end

function EquipmentDetailItemView:OnDestroy()

end

function EquipmentDetailItemView:OnShow()

end

function EquipmentDetailItemView:OnHide()

end

function EquipmentDetailItemView:OnRegisterUIEvent()

end

function EquipmentDetailItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MagicsparInlaySucc, self.OnInlaySucc)
	self:RegisterGameEvent(_G.EventID.MagicsparUnInlaySucc, self.OnUnInlaySucc)
end

function EquipmentDetailItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "bSelect", UIBinderSetIsVisible.New(self, self.SelectImg) },
		{ "GID", UIBinderValueChangedCallback.New(self, nil, self.OnGIDChange) },
		{ "EquipmentNameColor", UIBinderSetColorAndOpacityHex.New(self, self.InforCommItem.Text_IconName) },
		{ "ItemLevelColor", UIBinderSetColorAndOpacityHex.New(self, self.InforCommItem.Text_Class) },
		{ "ItemLevelColor", UIBinderSetColorAndOpacityHex.New(self, self.InforCommItem.Text_Class_1) },
		{ "bIsTaslkItem", UIBinderSetIsVisible.New(self, self.InforCommItem.EquipSlot.IconTask)},
		{ "bIsEquiped", UIBinderSetIsVisible.New(self, self.ImgWearing)},
		{ "bIsEquiped", UIBinderValueChangedCallback.New(self, nil, self.OnChangeEquiped) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentDetailItemView:OnChangeEquiped()
	local IsEquiped  = self.ViewModel.bIsEquiped
	local bIsTaslkItem = self.ViewModel.bIsTaslkItem
	if self.ViewModel.bIsTaslkItem and not self.ViewModel.bIsEquiped then
		UIUtil.SetIsVisible(self.InforCommItem.EquipSlot.IconTask, true)
	elseif self.ViewModel.bIsEquiped then
		UIUtil.SetIsVisible(self.InforCommItem.EquipSlot.IconTask, false)
	end
	self.InforCommItem:InitItem(self.ViewModel.ResID, self.ViewModel.GID, self.ViewModel.Part)
end

function EquipmentDetailItemView:OnGIDChange()
	self.InforCommItem:InitItem(self.ViewModel.ResID, self.ViewModel.GID, self.ViewModel.Part)
end

function EquipmentDetailItemView:OnSelectChanged(bSelect)
	if self.ViewModel then
		self.ViewModel:SetSelect(bSelect)
	end
end

function EquipmentDetailItemView:OnInlaySucc(Params)
	if (Params.GID == self.ViewModel.GID) then
		self.InforCommItem:UpdateInlayAllSlot()
	end
end

function EquipmentDetailItemView:OnUnInlaySucc(Params)
	if (Params.GID == self.ViewModel.GID) then
		self.InforCommItem:UpdateInlayAllSlot()
	end
end

return EquipmentDetailItemView