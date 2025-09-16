---
--- Author: guanjiewu
--- DateTime: 2024-01-29 15:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local BagMgr = _G.BagMgr
local EventID = require("Define/EventID")
local ItemUtil = require("Utils/ItemUtil")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local MainPanelVM = require("Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM")
---@class LegendaryWeaponListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field CommBackpack96Slot CommBackpack96SlotView
---@field ImgBg UFImage
---@field ImgBgSelect UFImage
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponListItemView = LuaClass(UIView, true)

function LegendaryWeaponListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.CommBackpack96Slot = nil
	--self.ImgBg = nil
	--self.ImgBgSelect = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponListItemView:OnInit()

end

function LegendaryWeaponListItemView:OnDestroy()

end

function LegendaryWeaponListItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end
	local ItemInfo = Params.Data
	self.ResID = ItemInfo.ResID
	local Cfg = ItemCfg:FindCfgByKey(ItemInfo.ResID)
	if Cfg == nil then
		_G.FLOG_WARNING(string.format("[传奇武器]无效的物品ID = %d", ItemInfo.ResID))
	end
	if Cfg ~= nil and Cfg ~= Cfg.IconID then
		self.CommBackpack96Slot:SetIconImg(UIUtil.GetIconPath(Cfg.IconID))
	end
	self.CommBackpack96Slot:SetQualityImg(ItemUtil.GetItemColorIcon(ItemInfo.ResID))
	self.CommBackpack96Slot:CommSetVisible(self.CommBackpack96Slot.RedDot2, false)
	self.CommBackpack96Slot:CommSetVisible(self.CommBackpack96Slot.RichTextQuantity, false)
	self.CommBackpack96Slot:CommSetVisible(self.CommBackpack96Slot.RichTextLevel, false)
	self.CommBackpack96Slot:CommSetVisible(self.CommBackpack96Slot.IconChoose, false)

	self:UpdataCurNumber()
	self.TextName:SetText(ItemCfg:GetItemName(ItemInfo.ResID))
	UIUtil.SetIsVisible(self.ImgBgSelect, self.ResID == MainPanelVM.SelectItemID)
end

function LegendaryWeaponListItemView:OnHide()

end

function LegendaryWeaponListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnBtnClick)
end

function LegendaryWeaponListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LegendaryInnerMatClick, self.OnInnerMatClick)
	self:RegisterGameEvent(EventID.BagUpdate, self.UpdataCurNumber)
end

function LegendaryWeaponListItemView:OnInnerMatClick(ResID)
	UIUtil.SetIsVisible(self.ImgBgSelect, self.ResID == ResID)
end

function LegendaryWeaponListItemView:OnRegisterBinder()

end

function LegendaryWeaponListItemView:OnBtnClick()
	_G.LegendaryWeaponMainPanelVM.MaterialResID = self.ResID
	_G.EventMgr:SendEvent(EventID.LegendaryInnerMatClick, self.ResID)
--	_G.EventMgr:SendEvent(_G.EventID.LegendaryUpdateEquipTips, {IsActive = false})
end

function LegendaryWeaponListItemView:UpdataCurNumber()
	if self.TextLevel then
		local Params = self.Params
		if nil == Params then return end
		local ItemInfo = Params.Data
		if nil == ItemInfo then return end
		self.CurNumber = BagMgr:GetItemNum(ItemInfo.ResID)
		if EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND)) or EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND)) then
			self.CurNumber = self.CurNumber + EquipmentMgr:GetEquipedItemNum(self.ResID)
		end
		self.TextLevel:SetText(string.format("%d/%d", self.CurNumber, ItemInfo.Num))
		local IsCanNum = self.CurNumber >= ItemInfo.Num
		local Color = IsCanNum and "#E9C962FF" or "#FFFFFFFF"
		UIUtil.SetColorAndOpacityHex(self.TextLevel, Color)
	end
end

return LegendaryWeaponListItemView