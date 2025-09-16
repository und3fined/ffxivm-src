---
--- Author: jamiyang
--- DateTime: 2025-02-25 11:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MagicsparSwitchItemVM = require("Game/Magicspar/VM/MagicsparSwitchItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MagicsparSwitchItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EquipmentSlotItem EquipmentSlotItemView
---@field ImgWearable UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparSwitchItemView = LuaClass(UIView, true)

function MagicsparSwitchItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EquipmentSlotItem = nil
	--self.ImgWearable = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparSwitchItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EquipmentSlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparSwitchItemView:OnInit()
	self.ViewModel = MagicsparSwitchItemVM.New()
end

function MagicsparSwitchItemView:OnDestroy()

end

function MagicsparSwitchItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end
	self:InitItem(Item.ResID, Item.GID, Item.Part, Item.bSelect)
end

function MagicsparSwitchItemView:OnHide()

end

function MagicsparSwitchItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.EquipmentSlotItem.FBtn_Item, self.OnClickButtonItem)
end

function MagicsparSwitchItemView:OnRegisterGameEvent()

end

function MagicsparSwitchItemView:OnRegisterBinder()
	local Binders = {
		--{ "bSelect", UIBinderSetIsVisible.New(self, self.EquipmentSlotItem.FImg_Select, false) },
		{ "bHasMagicspar", UIBinderSetIsVisible.New(self, self.ImgWearable, false) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function MagicsparSwitchItemView:InitItem(InResID, InGID, InPart, bSelect)
	self.ViewModel:InitItem(InResID, InGID, InPart, bSelect)
	--设置Slot
	self.EquipmentSlotItem.ViewModel:SetPart(self.ViewModel.Part, self.ViewModel.ResID, self.ViewModel.GID)
    self.EquipmentSlotItem.ViewModel.bBtnVisibel = true
    self.EquipmentSlotItem.ViewModel.bCheckShowRepair = false
	self.EquipmentSlotItem.ViewModel.bSelect = bSelect
	self.EquipmentSlotItem.ViewModel:CheckInUse()
	self.EquipmentSlotItem.ViewModel.bShowProgress = false
	self.EquipmentSlotItem.ViewModel.bMask = not self.ViewModel.bCanInlay
	-- if bSelect then
	-- 	self:OnClickButtonItem()
	-- end
end

function MagicsparSwitchItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	if self.ViewModel then
		self.ViewModel:CheckCanSelect()
		if self.ViewModel.bSelect then
			Adapter:OnItemClicked(self, Params.Index)
		end
	end
end

function MagicsparSwitchItemView:OnSelectChanged(IsSelected)
	if self.ViewModel and self.ViewModel.OnSelectedChange then
		self.ViewModel:OnSelectedChange(IsSelected)
		self.EquipmentSlotItem.ViewModel.bSelect = self.ViewModel.bSelect
	end
end

return MagicsparSwitchItemView