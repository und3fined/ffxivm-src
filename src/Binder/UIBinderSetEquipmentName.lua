--[[
Date: 2021-10-19 19:49:19
LastEditors: moody
LastEditTime: 2021-10-19 19:49:19
--]]
local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local ItemDBCfg = require("TableCfg/ItemCfg")

---@class UIBinderSetEquipmentName : UIBinder
local UIBinderSetEquipmentName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetEquipmentName:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetEquipmentName:OnValueChanged(NewValue, OldValue)
	local EquipID = NewValue
	local Name = self:GetEquipName(EquipID)

	self.Widget:SetText(Name)
end

---GetEquipName
---@param EquipID number
---@return string
function UIBinderSetEquipmentName:GetEquipName(EquipID)
	return ItemDBCfg:GetItemName(EquipID)
end

return UIBinderSetEquipmentName