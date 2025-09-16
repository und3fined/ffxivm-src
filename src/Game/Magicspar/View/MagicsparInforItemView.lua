---
--- Author: jamiyang
--- DateTime: 2023-07-26 11:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MagicsparInforItemVM = require("Game/Magicspar/VM/MagicsparInforItemVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MagicsparInforItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSwitch UFButton
---@field EquipSlot EquipmentSlotItemView
---@field ImgWearable UFImage
---@field InlaySlotItem1 MagicsparInforSlotItemView
---@field InlaySlotItem2 MagicsparInforSlotItemView
---@field InlaySlotItem3 MagicsparInforSlotItemView
---@field InlaySlotItem4 MagicsparInforSlotItemView
---@field InlaySlotItem5 MagicsparInforSlotItemView
---@field Text_Class UFTextBlock
---@field Text_Class_1 UFTextBlock
---@field Text_IconName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInforItemView = LuaClass(UIView, true)

function MagicsparInforItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSwitch = nil
	--self.EquipSlot = nil
	--self.ImgWearable = nil
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

function MagicsparInforItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EquipSlot)
	self:AddSubView(self.InlaySlotItem1)
	self:AddSubView(self.InlaySlotItem2)
	self:AddSubView(self.InlaySlotItem3)
	self:AddSubView(self.InlaySlotItem4)
	self:AddSubView(self.InlaySlotItem5)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInforItemView:OnInit()
	self.ViewModel = MagicsparInforItemVM.New()
end

function MagicsparInforItemView:OnDestroy()

end

function MagicsparInforItemView:OnShow()
	self.Text_Class_1:SetText(_G.LSTR(1060028)) -- "品级"
end

function MagicsparInforItemView:OnHide()

end

function MagicsparInforItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnEquipSwitchClick)
end

function MagicsparInforItemView:OnRegisterGameEvent()

end

function MagicsparInforItemView:OnRegisterBinder()
	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.Text_IconName) },
		{ "Level", UIBinderSetTextFormat.New(self, self.Text_Class, "%d") },
		--{ "ItemLevelColor", UIBinderSetColorAndOpacityHex.New(self, self.Text_Class) },
		--{ "ItemLevelColor", UIBinderSetColorAndOpacityHex.New(self, self.Text_Class_1) },
		{ "ItemLevelColor", UIBinderSetColorAndOpacityHex.New(self, self.Text_IconName) },
		{ "bShowSwitch", UIBinderSetIsVisible.New(self, self.BtnSwitch, false, true) },
		{ "bShowSwitch", UIBinderSetIsVisible.New(self, self.ImgWearable, false) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function MagicsparInforItemView:OnEquipSwitchClick()
	local Params = {Part = self.ViewModel.Part, GID = self.ViewModel.GID, ResID = self.ViewModel.ResID}
	UIViewMgr:ShowView(UIViewID.MagicsparSwitchPanel, Params)
end

function MagicsparInforItemView:UpdateInlayAllSlot()
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

function MagicsparInforItemView:UpdateInlaySlot(Index, ResID, bNomal, bShow)
	local InlaySlotItem = self["InlaySlotItem"..Index]
	InlaySlotItem.ViewModel:InitMagicsparSlot(ResID, Index, bNomal)
	UIUtil.SetIsVisible(InlaySlotItem, bShow)
end

function MagicsparInforItemView:InitItem(InResID, InGID, InPart)
	self.ViewModel:InitItem(InResID, InGID, InPart)
	--设置Slot
	self.EquipSlot.ViewModel:SetPart(self.ViewModel.Part, self.ViewModel.ResID, self.ViewModel.GID)
    self.EquipSlot.ViewModel.bBtnVisibel = false
    self.EquipSlot.ViewModel.bCheckShowRepair = false
	self.EquipSlot.ViewModel:CheckInUse()
	--设置魔晶石
	self:UpdateInlayAllSlot()
end

return MagicsparInforItemView