local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

local BuddyMgr
---@class BuddySurfaceNewSlotVM : UIViewModel
local BuddySurfaceNewSlotVM = LuaClass(UIViewModel)

---Ctor
function BuddySurfaceNewSlotVM:Ctor()
	BuddyMgr = _G.BuddyMgr

	self.ImgCheckVisible = nil
	self.Icon = nil
	self.EquipmentText = nil
	self.IsSelect = nil

	self.ResID = nil
end

function BuddySurfaceNewSlotVM:UpdateVM(Value)
	self.ResID = Value.ResID
	
	self.Icon = UIUtil.GetIconPath((ItemUtil.GetItemIcon(Value.ResID)))
	self.EquipmentText = ItemUtil.GetItemName(Value.ResID) or ""

	local Armor = BuddyMgr:GetSurfaceArmor()
	if Armor == nil then
		self.ImgCheckVisible = false
		return 
	end

	self.ImgCheckVisible = Value.ResID == Armor.Head or Value.ResID == Armor.Body or Value.ResID == Armor.Feet

	self:ResetSelected()
end

function BuddySurfaceNewSlotVM:UpdateIconState(ID)
	self.IsSelect = ID == self.ResID
end

function BuddySurfaceNewSlotVM:ResetSelected()
	self.IsSelect = false
end


function BuddySurfaceNewSlotVM:IsEqualVM(Value)
	return nil ~= Value and Value.ResID == self.ResID
end


--要返回当前类
return BuddySurfaceNewSlotVM