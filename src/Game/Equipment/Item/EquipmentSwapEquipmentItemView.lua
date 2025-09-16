---
--- Author: Administrator
--- DateTime: 2024-11-28 17:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class EquipmentSwapEquipmentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field IconMounted UFImage
---@field IconSet UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentSwapEquipmentItemView = LuaClass(UIView, true)

function EquipmentSwapEquipmentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm96Slot = nil
	--self.IconMounted = nil
	--self.IconSet = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentSwapEquipmentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentSwapEquipmentItemView:SetItemParams(Param)
	self.Comm96Slot:SetParams(Param)
	local CallBack = function ()
		if Param.Data.GID and Param.Data.GID ~= 0 then
			ItemTipsUtil.ShowTipsByGID(Param.Data.GID, self.Comm96Slot, nil, nil)
		elseif Param.Data.ResID and Param.Data.ResID ~= 0 then
			ItemTipsUtil.ShowTipsByResID(Param.Data.GID, self.Comm96Slot, nil, nil)
		end
	end
	self.Comm96Slot:SetClickButtonCallback(self, CallBack)

	local bShowSchemeIcon = false
	local bShowGemIcon = false
	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	for key, value in pairs(RoleDetail.Prof.ProfList) do
		local Equipscheme = value.EquipScheme
		if Equipscheme and next(Equipscheme) then
			for _, data in pairs(Equipscheme) do
				if Param.Data.GID == data.GID then
					bShowSchemeIcon = true
				end
			end
		end
	end
	--魔晶石
	local Item = _G.EquipmentMgr:GetItemByGID(Param.Data.GID)
	if Item and Item.Attr and Item.Attr.Equip and Item.Attr.Equip.GemInfo and Item.Attr.Equip.GemInfo.CarryList then
		if next(Item.Attr.Equip.GemInfo.CarryList) then
			bShowGemIcon = true
		end
	end

	UIUtil.SetIsVisible(self.IconSet, bShowSchemeIcon)
	UIUtil.SetIsVisible(self.IconMounted, bShowGemIcon)
end

return EquipmentSwapEquipmentItemView