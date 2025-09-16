---
--- Author: guanjiewu
--- DateTime: 2024-01-11 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BagMgr = _G.BagMgr
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local LegendaryWeaponVM = require("Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM")

local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
---@class LegendaryWeaponMaterialItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field EFF_1 UFCanvasPanel
---@field EFF_2 UFCanvasPanel
---@field EFF_Activate_1 UFCanvasPanel
---@field EFF_Activate_2 UFCanvasPanel
---@field ImgMaterial UFImage
---@field MI_DX_2_b UFImage
---@field MI_DX_Common_LegendaryWeapon_1_b UFImage
---@field MI_DX_Common_LegendaryWeapon_2_b UFImage
---@field SizeBoxIcon USizeBox
---@field TextAmount UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponMaterialItemView = LuaClass(UIView, true)

function LegendaryWeaponMaterialItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.EFF_1 = nil
	--self.EFF_2 = nil
	--self.EFF_Activate_1 = nil
	--self.EFF_Activate_2 = nil
	--self.ImgMaterial = nil
	--self.MI_DX_2_b = nil
	--self.MI_DX_Common_LegendaryWeapon_1_b = nil
	--self.MI_DX_Common_LegendaryWeapon_2_b = nil
	--self.SizeBoxIcon = nil
	--self.TextAmount = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponMaterialItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponMaterialItemView:OnInit()

end

function LegendaryWeaponMaterialItemView:OnDestroy()

end

function LegendaryWeaponMaterialItemView:OnShow()
	if self.TextAmount then
		UIUtil.SetIsVisible(self.TextAmount, true)
	end
end

function LegendaryWeaponMaterialItemView:SetData(bIsSpecial, ItemData, SpecialIcon, Percent)
	self.bIsSpecial = bIsSpecial
	self.ItemData = ItemData
	self.SpecialIcon = SpecialIcon
	self.Percent = Percent
	self.bIsInit = true	
	self:UpdateCostItemNum()
	self:PlayAnimation(self.AnimIn)
	self:SetColor()
end

function LegendaryWeaponMaterialItemView:UpdateCostItemNum()
	if not self.bIsInit then
		return
	end
	if self.bIsSpecial == false then
		self.ResID = self.ItemData.ResID
		local CurNumber = BagMgr:GetItemNum(self.ItemData.ResID)
		if EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND)) or EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND)) then
			CurNumber = CurNumber + EquipmentMgr:GetEquipedItemNum(self.ItemData.ResID)
		end
		self.TextAmount:SetText(string.format("%d/%d", CurNumber, self.ItemData.Num))
		local Cfg = ItemCfg:FindCfgByKey(self.ItemData.ResID)
		if Cfg == nil then
			_G.FLOG_WARNING(string.format("[传奇武器]存在无效的物品ID = %d", self.ItemData.ResID))
		end
		if Cfg ~= nil and Cfg.IconID then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgMaterial, UIUtil.GetIconPath(Cfg.IconID))
		end
		self.ActivateColor = CurNumber >= self.ItemData.Num
	else
		local CurNumber = 0
		local TotalCount = 0
		self.ResID = nil
		for _, Item in pairs(self.ItemData) do
			if Item.ResID ~= 0 then
				TotalCount = TotalCount + 1
				if BagMgr:GetItemNum(Item.ResID) > 0 then
					CurNumber = CurNumber + 1
				end
				-- 默认选第一个
				if self.ResID == nil then
					self.ResID = Item.ResID
				end
			end
		end
		self.TextAmount:SetText(string.format("%d/%d", CurNumber, TotalCount))
		self.Percent:SetPercent(CurNumber/TotalCount)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgMaterial, self.SpecialIcon)
		self.ActivateColor = CurNumber >= TotalCount
	end
end

function LegendaryWeaponMaterialItemView:OnHide()

end

function LegendaryWeaponMaterialItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnMaterialBtnClick)
end

function LegendaryWeaponMaterialItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagUpdate, self.UpdateCostItemNum)
	self:RegisterGameEvent(EventID.LegendaryPlayCompletionAnim, self.PlayCompletion)
	self:RegisterGameEvent(EventID.LegendaryCompletionEnd, self.CompletionEnd)
end

function LegendaryWeaponMaterialItemView:OnRegisterBinder()

end

function LegendaryWeaponMaterialItemView:PlayCompletion()
	if self.TextAmount then
		UIUtil.SetIsVisible(self.TextAmount, false)
	end
	if self.Btn then
		UIUtil.SetIsVisible(self.Btn, false)
	end
end

function LegendaryWeaponMaterialItemView:CompletionEnd()
	if self.TextAmount then
		UIUtil.SetIsVisible(self.TextAmount, true)
	end
	if self.Btn then
		UIUtil.SetIsVisible(self.Btn, true, true, true)
	end
end

function LegendaryWeaponMaterialItemView:OnMaterialBtnClick()
	_G.LegendaryWeaponMainPanelVM.MaterialResID = self.ResID
	_G.EventMgr:SendEvent(EventID.LegendaryMatItemClick, self.bIsSpecial, self.ResID)
	-- if self.bIsSpecial == false then
	-- 	ItemTipsUtil.ShowTipsByResID(self.ResID, self)
	-- else
	-- 	-- 跳转到材料详情
	-- end
end

--- 动效颜色
function LegendaryWeaponMaterialItemView:SetColor()
	if self.ItemData.ResID == nil or self.ItemData.ResID < 0 then
		if self.bIsSpecial == false then
			return
		end
	end

	-- local Cfg = ItemCfg:FindCfgByKey(self.ItemData.ResID)
	-- if Cfg ~= nil then
	-- 	print("======== 资产：", Cfg.ItemName, "颜色：", Cfg.ItemColor, "是否满足数量：", self.ActivateColor)
	-- end

	local ColorList = LegendaryWeaponVM:GetItemColor(self.ItemData.ResID)
	if ColorList then
		--蓝、绿、紫色
		UIUtil.SetIsVisible(self.EFF_1, false)
		UIUtil.SetIsVisible(self.EFF_2, true)
		if self.ActivateColor then
			UIUtil.SetIsVisible(self.EFF_Activate_2, true)
		else
			UIUtil.SetIsVisible(self.EFF_Activate_2, false)
		end
		UIUtil.ImageSetBrushTintColorHex(self.MI_DX_Common_LegendaryWeapon_1_b, ColorList[1])
		UIUtil.ImageSetBrushTintColorHex(self.MI_DX_Common_LegendaryWeapon_2_b, ColorList[2])
		UIUtil.ImageSetBrushTintColorHex(self.MI_DX_2_b, ColorList[3])
	else
		--白色
		UIUtil.SetIsVisible(self.EFF_1, true)
		UIUtil.SetIsVisible(self.EFF_2, false)
		if self.ActivateColor then
			UIUtil.SetIsVisible(self.EFF_Activate_1, true)
		else
			UIUtil.SetIsVisible(self.EFF_Activate_1, false)
		end
	end
	self.ActivateColor = nil
end

return LegendaryWeaponMaterialItemView