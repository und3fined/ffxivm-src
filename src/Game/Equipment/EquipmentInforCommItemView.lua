---
--- Author: enqingchen
--- DateTime: 2022-03-28 19:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EquipmentInforCommItemVM = require("Game/Equipment/VM/EquipmentInforCommItemVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

---@class EquipmentInforCommItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EquipSlot EquipmentSlotItemView
---@field InlaySlot UFWrapBox
---@field InlaySlotItem1 MagicsparInlaySlotView
---@field InlaySlotItem2 MagicsparInlaySlotView
---@field InlaySlotItem3 MagicsparInlaySlotView
---@field InlaySlotItem4 MagicsparInlaySlotView
---@field InlaySlotItem5 MagicsparInlaySlotView
---@field Text_Class UFTextBlock
---@field Text_Class_1 UFTextBlock
---@field Text_IconName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentInforCommItemView = LuaClass(UIView, true)

function EquipmentInforCommItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EquipSlot = nil
	--self.InlaySlot = nil
	--self.InlaySlotItem1 = nil
	--self.InlaySlotItem2 = nil
	--self.InlaySlotItem3 = nil
	--self.InlaySlotItem4 = nil
	--self.InlaySlotItem5 = nil
	--self.Text_Class = nil
	--self.Text_Class_1 = nil
	--self.Text_IconName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentInforCommItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EquipSlot)
	self:AddSubView(self.InlaySlotItem1)
	self:AddSubView(self.InlaySlotItem2)
	self:AddSubView(self.InlaySlotItem3)
	self:AddSubView(self.InlaySlotItem4)
	self:AddSubView(self.InlaySlotItem5)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentInforCommItemView:OnInit()
	self.ViewModel = EquipmentInforCommItemVM.New()
end

function EquipmentInforCommItemView:OnDestroy()

end

function EquipmentInforCommItemView:OnShow()
	self.Text_Class_1:SetText(_G.LSTR(1060028)) -- "品级"
end

function EquipmentInforCommItemView:OnHide()

end

function EquipmentInforCommItemView:OnRegisterUIEvent()

end

function EquipmentInforCommItemView:OnRegisterGameEvent()

end

function EquipmentInforCommItemView:OnRegisterBinder()
	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.Text_IconName) },
		{ "Level", UIBinderSetTextFormat.New(self, self.Text_Class, "%d") },
		{ "bShowInlaySlot", UIBinderSetIsVisible.New(self, self.InlaySlot) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentInforCommItemView:UpdateInlayAllSlot()
	if nil == self.ViewModel.Item then
		return
	end
	local lst = self.ViewModel.Item.Attr.Equip.GemInfo.CarryList
	local iNomalCount = self.ViewModel.MagicsparInlayCfg.NomalCount
	local iBanCount = self.ViewModel.MagicsparInlayCfg.BanCount
	for i = 1, 2 do
		self:UpdateInlaySlot(i, lst[i], true, i <= iNomalCount)
	end
	for i = 1, 3 do
		self:UpdateInlaySlot(2 + i, lst[2 + i], false, i <= iBanCount)
	end
end

function EquipmentInforCommItemView:UpdateInlaySlot(Index, ResID, bNomal, bShow)
	local InlaySlotItem = self["InlaySlotItem"..Index]
	InlaySlotItem.ViewModel:InitMagicsparSlot(ResID, Index, bNomal)
	UIUtil.SetIsVisible(InlaySlotItem, bShow)
end

function EquipmentInforCommItemView:InitItem(InResID, InGID, InPart)
	self.ViewModel:InitItem(InResID, InGID, InPart)
	--设置Slot
	self.EquipSlot.ViewModel:SetPart(self.ViewModel.Part, self.ViewModel.ResID, self.ViewModel.GID)
    self.EquipSlot.ViewModel.bBtnVisibel = false
    self.EquipSlot.ViewModel.bCheckShowRepair = false
	self.EquipSlot.ViewModel:CheckInUse()
	local NeedUpdate = _G.EquipmentMgr:CheckCanMosic(InResID)
	--设置魔晶石
	if NeedUpdate then
		self:UpdateInlayAllSlot()
	end
end

return EquipmentInforCommItemView