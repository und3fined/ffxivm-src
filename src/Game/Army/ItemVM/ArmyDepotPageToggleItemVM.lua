---
--- Author: star
--- DateTime: 2024-10-29 15:00
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GroupStoreIconCfg = require("TableCfg/GroupStoreIconCfg")
local GroupStoreCfg = require("TableCfg/GroupStoreCfg")

---@class ArmyDepotPageToggleItemVM : UIViewModel
local ArmyDepotPageToggleItemVM = LuaClass(UIViewModel)

---Ctor
function ArmyDepotPageToggleItemVM:Ctor()
	self.PageIndex = 0
	self.PageType = 0
	self.PageName = ""
	self.PageIcon = ""
	self.IconColor = "ffffffff"

end

function ArmyDepotPageToggleItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Index == self.PageIndex
end

---UpdateVM
---@param Value DepotSimple
function ArmyDepotPageToggleItemVM:UpdateVM(Value)
	self.PageIndex = Value.Index
	self.ItemNum = Value.ItemNum
	self.Capacity = Value.Capacity
	self:UpdateInfo(Value.Type, Value.DepotName)
	self:UpdateIconColor()
end

function ArmyDepotPageToggleItemVM:UpdateInfo(Type, Name)
	self.PageType = Type
	if Name == "" then
		local StoreCfg = GroupStoreCfg:FindCfgByKey(self.PageIndex)
		if StoreCfg then
            -- LSTR string:默认仓库名
            self.PageName = StoreCfg.GroupDefaultName or LSTR(910277)
        end
	else
		self.PageName = Name
	end
	local IconCfg = GroupStoreIconCfg:FindCfgByKey(Type)
	if IconCfg then
		self.PageIcon = IconCfg.Icon
	end
end

function ArmyDepotPageToggleItemVM:OnItemUpdate()
	self:UpdateIconColor()
end

function ArmyDepotPageToggleItemVM:UpdateIconColor()
	self.IconColor = self:GetIconColor()
end

function ArmyDepotPageToggleItemVM:GetIconColor()
	--绿色：66efa0
	--黄色：cdb271
	--红色：d05758

	local ItemNum = self.ItemNum
	if ItemNum <= 10 then
		return "66efa0ff"
	elseif ItemNum <= 20 then
		return "cdb271ff"
	else
		return "d05758"
	end
end

return ArmyDepotPageToggleItemVM