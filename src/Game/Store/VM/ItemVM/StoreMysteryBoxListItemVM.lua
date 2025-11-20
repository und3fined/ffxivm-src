
--- 盲盒包含列表itemVM
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemDefine = require("Game/Item/ItemDefine")

---@class StoreMysteryBoxListItemVM : UIViewModel
local StoreMysteryBoxListItemVM = LuaClass(UIViewModel)

---Ctor
function StoreMysteryBoxListItemVM:Ctor()
	self.ID = 0
	self.Icon = 0
	self.Part = 0
	self.EquipmentID = 0
	self.ItemType = 0
    self.bOwned = false
	self.ResID = 0
	self.NumVisible = false
	self.HideItemLevel = true
	self.IconChooseVisible = false
	self.ItemLevelVisible = false
	self.IsMask = false
    self.IsSelect = false
	self.ItemName = ""
	self.BtnViewVisible = false
	self.ItemQualityIcon = ""
end

function StoreMysteryBoxListItemVM:OnInit()

end

function StoreMysteryBoxListItemVM:IsEqualVM()
	return true
end

function StoreMysteryBoxListItemVM:UpdateVM(Value)
	self.ID = Value.ID
	self.Icon = Value.Icon
	if string.isnilorempty(Value.Icon) then
		local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
		if nil ~= Cfg then
			if Cfg.IconID ~= nil and Cfg.IconID ~= 0 then
				self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
			end
		end
	end
	self.ItemName = ItemCfg:GetItemName(Value.ID)
	self.ResID = Value.ResID
	self.Part = Value.Part
	self.bOwned = _G.StoreMysteryBoxMgr.CheckItemOwned(Value.ID)
	self.IsMask = self.bOwned
	self.ItemType = Value.ItemType
	self.EquipmentID = Value.EquipmentID

	local TempItemCfg = ItemCfg:FindCfgByKey(Value.ID)
	if TempItemCfg ~= nil then
		self.ItemQualityIcon = ItemDefine.ItemIconColorType[TempItemCfg.ItemColor]
	end
end

function StoreMysteryBoxListItemVM:OnSelectedChange(IsSelect)
    self.IsSelect = IsSelect
end

function StoreMysteryBoxListItemVM:SetIconPath(IconPath)
	self.Icon = IconPath
end

return StoreMysteryBoxListItemVM