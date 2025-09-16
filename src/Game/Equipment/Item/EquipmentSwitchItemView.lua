--[[
Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
Date: 2024-11-17 22:40:18
LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
LastEditTime: 2024-11-17 22:43:55
FilePath: \Script\Game\Equipment\Item\EquipmentSwitchItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: Administrator
--- DateTime: 2024-11-17 22:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")

local ItemType = {
	Equipment = 1,
	Material = 2
}
---@class EquipmentSwitchItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EuipmentSlot CommBackpack96SlotView
---@field ImgSelect UFImage
---@field PanelClass UFHorizontalBox
---@field RichTextNumeric URichTextBox
---@field TextSlot UFTextBlock
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentSwitchItemView = LuaClass(UIView, true)

function EquipmentSwitchItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EuipmentSlot = nil
	--self.ImgSelect = nil
	--self.PanelClass = nil
	--self.RichTextNumeric = nil
	--self.TextSlot = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentSwitchItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EuipmentSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentSwitchItemView:OnInit()

end

function EquipmentSwitchItemView:OnDestroy()

end

function EquipmentSwitchItemView:OnShow()
	self:UpdateView()
end

function EquipmentSwitchItemView:OnHide()

end

function EquipmentSwitchItemView:OnRegisterUIEvent()

end

function EquipmentSwitchItemView:OnRegisterGameEvent()

end

function EquipmentSwitchItemView:OnRegisterBinder()

end

function EquipmentSwitchItemView:UpdateView()
	if self.Params and self.Params.Data then
		local Data = self.Params.Data
		UIUtil.SetIsVisible(self.PanelClass, Data.ItemType ~= ItemType.Material)
		self.TextSlot:SetText(ItemUtil.GetItemName(Data.ItemID))

		local ItemVM1 = ItemVM.New()
		ItemVM1.IsQualityVisible = true 
		ItemVM1.ItemQualityIcon = ItemUtil.GetItemColorIcon(Data.ItemID)
		ItemVM1.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Data.ItemID))
		ItemVM1.IsValid = true
		ItemVM1.HideItemLevel = true
		ItemVM1.NumVisible = false
		self.EuipmentSlot:SetParams({ Data = ItemVM1 })
		--装备装分
		if Data.ItemType == ItemType.Equipment then
			local ExchangeIDItemCfg = ItemCfg:FindCfgByKey(Data.ItemID)
			if (ExchangeIDItemCfg) then
				local Score = ExchangeIDItemCfg.ItemLevel or 0
				self.RichTextNumeric:SetText(Score)
			end
		end
	end
end

function EquipmentSwitchItemView:OnSelectChanged(bSelect)
	UIUtil.SetIsVisible(self.ImgSelect, bSelect)
end

return EquipmentSwitchItemView