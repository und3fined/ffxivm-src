
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeAppearanceItemVM : UIViewModel
local WardrobeAppearanceItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeAppearanceItemVM:Ctor()
	self.Icon = ""
	self.IsValid = true
	self.NumVisible = true
	self.GID = 0
	self.ResID = 0
	self.Num = 0
	self.ItemNameVisible = false
	self.ItemName = ""
	self.IsQualityVisible = true
	self.IconReceivedVisible = false
	self.IsMask = false
	self.ItemLevelVisible = false
	self.IconChooseVisible = false
end

function WardrobeAppearanceItemVM:OnInit()

end

function WardrobeAppearanceItemVM:OnBegin()

end

function WardrobeAppearanceItemVM:IsEqualVM(Value)
	return true
end

function WardrobeAppearanceItemVM:OnEnd()

end

function WardrobeAppearanceItemVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function WardrobeAppearanceItemVM:UpdateVM(Value, Params)
	local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
	if Cfg ~= nil then
		self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
		self.ItemQualityIcon = ItemUtil.GetItemColorIcon(Value.ResID)
		self.IsQualityVisible = true
		self.NumVisible = Cfg.MaxPile ~= 1
		if Value.ItemNameVisible then
			self.ItemName = Value.ItemName
		end
	else
		self.Icon = ""
		self.ItemName = ""
		self.NumVisible = false
		self.IsQualityVisible = false
	end
	self.IsValid = true
	self.GID = 1
	self.ResID = Value.ResID
	self.Num = Value.Num
	self.IconReceivedVisible = Value.IconReceivedVisible
	self.IsMask = Value.IsMask
	self.ItemNameVisible = Value.ItemNameVisible
end

return WardrobeAppearanceItemVM