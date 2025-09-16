local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE


---@class MedicineSlotVM : UIViewModel
local MedicineSlotVM = LuaClass(UIViewModel)


---Ctor
function MedicineSlotVM:Ctor()
	self.Icon = nil
	self.ItemQualityIcon = nil
end


function MedicineSlotVM:UpdateVM(Value)
	local ValueResID = Value.ResID

	local Cfg = ItemCfg:FindCfgByKey(ValueResID)
	if nil == Cfg then
		return
	end
	
	self.Icon = UIUtil.GetIconPath(Cfg.IconID)
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(ValueResID)
end

return MedicineSlotVM
