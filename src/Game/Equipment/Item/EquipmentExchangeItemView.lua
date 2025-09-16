---
--- Author: Administrator
--- DateTime: 2024-11-17 16:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class EquipmentExchangeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BillSlot CommBackpack96SlotView
---@field EquipmentSlot EquipmentSwapEquipmentItemView
---@field SingleBox CommSingleBoxView
---@field TextEquipment UFTextBlock
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentExchangeItemView = LuaClass(UIView, true)

function EquipmentExchangeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BillSlot = nil
	--self.EquipmentSlot = nil
	--self.SingleBox = nil
	--self.TextEquipment = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentExchangeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BillSlot)
	self:AddSubView(self.EquipmentSlot)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentExchangeItemView:OnInit()

end

function EquipmentExchangeItemView:OnDestroy()

end

function EquipmentExchangeItemView:OnShow()
	self:OnItemUpdate()
end

function EquipmentExchangeItemView:OnHide()

end

function EquipmentExchangeItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox.ToggleButton, self.OnFinishToggleBtnStateChange)
end

function EquipmentExchangeItemView:OnRegisterGameEvent()

end

function EquipmentExchangeItemView:OnRegisterBinder()

end

function EquipmentExchangeItemView:OnFinishToggleBtnStateChange(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		self.Params.Data.isChoise = true 
	else
		self.Params.Data.isChoise = false 
	end
	EventMgr:SendEvent(EventID.ExchangeNumUpdate)
end

function EquipmentExchangeItemView:OnItemUpdate()
	if self.Params and self.Params.Data then
		local ItemData = self.Params.Data.Cfg
		local ItemVM1 = ItemVM.New()
		ItemVM1.IsQualityVisible = true 
		ItemVM1.ItemQualityIcon = ItemUtil.GetItemColorIcon(ItemData.ID)
		ItemVM1.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ItemData.ID))
		ItemVM1.IsValid = true
		ItemVM1.ResID = ItemData.ID
		ItemVM1.HideItemLevel = true
		ItemVM1.NumVisible = false
		ItemVM1.GID = self.Params.Data.GID
		self.EquipmentSlot:SetItemParams({ Data = ItemVM1 })

		local ItemVM2 = ItemVM.New()
		ItemVM2.IsQualityVisible = true 
		ItemVM2.ItemQualityIcon = ItemUtil.GetItemColorIcon(ItemData.MaterialID)
		ItemVM2.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ItemData.MaterialID))
		ItemVM2.IsValid = true
		ItemVM2.Num = ItemData.Num
		ItemVM2.HideItemLevel = true
		ItemVM2.NumVisible = true
		self.BillSlot:SetParams({ Data = ItemVM2 })

		local CallBack = function ()
			if ItemData.MaterialID and ItemData.MaterialID ~= 0 then
				ItemTipsUtil.ShowTipsByResID(ItemData.MaterialID, self.BillSlot, nil, nil, 30)
			end
		end
		self.BillSlot:SetClickButtonCallback(self, CallBack)
		
		self.TextEquipment:SetText(ItemUtil.GetItemName(ItemData.ID))
		self.SingleBox.ToggleButton:SetCheckedState(self.Params.Data.isChoise and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.UnChecked, false)
	end
end

return EquipmentExchangeItemView