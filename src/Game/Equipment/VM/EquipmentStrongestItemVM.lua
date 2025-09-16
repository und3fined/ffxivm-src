local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemDBCfg = require("TableCfg/ItemCfg")

local EquipmentMgr = _G.EquipmentMgr

---@class EquipmentStrongestItemVM : UIViewModel
local EquipmentStrongestItemVM = LuaClass(UIViewModel)

function EquipmentStrongestItemVM:Ctor()
    self.Part = nil
	self.ResID = nil
	self.EquipmentName = ""
	self.IconPath = nil
end

---@param InPart ProtoCommon.equip_part
function EquipmentStrongestItemVM:SetPart(InPart, InResID)
    self.Part = InPart
	self.ResID = InResID

	if InResID then
    	self.EquipmentName = ItemDBCfg:GetItemName(InResID)
	else
		-- self.EquipmentName = EquipmentMgr:GetPartName(InPart)
		self.EquipmentName = LSTR(1050090)
	end
	self.IconPath = EquipmentMgr:GetPartIcon(InPart)
end

return EquipmentStrongestItemVM