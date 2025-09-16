local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local DepotVM = require("Game/Depot/DepotVM")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local BagMgr = require("Game/Bag/BagMgr")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsMedicineVM = require("Game/ItemTips/VM/ItemTipsMedicineVM")
local ItemTipsCollectionVM = require("Game/ItemTips/VM/ItemTipsCollectionVM")
local LSTR = _G.LSTR

local ItemFishingBaitTipsFrameView = LuaClass(UIViewModel)

function ItemFishingBaitTipsFrameView:Ctor()
    self.Item = nil
    self.ResID = nil

    self.TypeName = nil
    self.ItemName = nil
    self.LevelText = nil
    self.DepotNumText = nil
    self.BagNumText = nil
    self.ToGetVisible = nil

    self.IconID = nil

    self.ItemTipsMedicineVM = ItemTipsMedicineVM.New()
    self.ItemTipsCollectionVM = ItemTipsCollectionVM.New()
end

function ItemFishingBaitTipsFrameView:UpdateVM(Value)
    local ItemResID = Value.ResID
	if ItemResID == nil then
		return
	end
	self.Item = Value
    self.ResID = ItemResID
	local Cfg = ItemCfg:FindCfgByKey(ItemResID)

    local CfgItemType = Cfg.ItemType
	self.TypeName = ItemTypeCfg:GetTypeName(CfgItemType)
    self.ItemName = ItemCfg:GetItemName(ItemResID)
    self.LevelText = string.format(LSTR(1020028), Cfg.ItemLevel)
    self.DepotNumText = DepotVM:GetDepotItemNum(ItemResID)
    self.BagNumText = BagMgr:GetItemNum(ItemResID) + EquipmentMgr:GetEquipedItemNum(ItemResID)
    self.IconID = Cfg.IconID

    local CommGetWayItems = ItemUtil.GetItemGetWayList(ItemResID)
    if CommGetWayItems ~= nil and #CommGetWayItems > 0 then
        self.ToGetVisible = true
    else
        self.ToGetVisible = false
    end
    self.ItemTipsMedicineVM:UpdateVM(Value)
    self.ItemTipsCollectionVM:UpdateVM(Value)
end

return ItemFishingBaitTipsFrameView