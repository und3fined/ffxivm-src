local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")


local LSTR = _G.LSTR

---@class CompanySealList2ItemVM : UIViewModel
local CompanySealList2ItemVM = LuaClass(UIViewModel)

---Ctor
function CompanySealList2ItemVM:Ctor()
	self.Name = nil
	self.ItemQualityIcon = nil
	self.CurID = nil
	self.Index = nil
	self.TargetItemNum = nil
	self.ExchangeID = nil
	self.CarryList = nil
	self.EquipGID = nil
	self.TextQuantity = nil
	self.TextLevel = nil
	self.IconChoose = nil
	self.ImgFocusVisible = nil
	self.CurChosedState = nil
	self.ItemVisilbe = nil
	self.NameVisilbe = nil
end

function CompanySealList2ItemVM:OnInit()

end

---UpdateVM
---@param List table
function CompanySealList2ItemVM:UpdateVM(List)
	if not List.ResID or List.ResID == 0 then
		self.ItemVisilbe = false
		self.NameVisilbe = false
		self.CurChosedState = false
		self.ImgFocusVisible = false
		self.CurID = nil
		self.EquipGID = nil
		return
	end
	self.NameVisilbe = true
	self.ItemVisilbe = true
	self.EquipGID = List.GID
	local CarryList = List.Attr.Equip.GemInfo.CarryList or {}
	self.CarryList = CarryList
	self.TargetItemNum = List.TargetItemNum or 0
	self.Index = List.Index
	self.CurID = List.ResID
	self.Name = ItemUtil.GetItemName(List.ResID)
	local IconID = ItemUtil.GetItemIcon(List.ResID)
	local Path = UIUtil.GetIconPath(IconID)
	self.ItemIcon = Path
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(List.ResID)
	self.CurChosedState = false
	self.ImgFocusVisible = false
end

function CompanySealList2ItemVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end


return CompanySealList2ItemVM