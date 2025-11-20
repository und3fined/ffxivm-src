
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/House/View/HouseAssetsPanelItemVM") 
local UIBindableList = require("UI/UIBindableList")
local ItemCfg = require("TableCfg/ItemCfg")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

local HouseAssetsPanelVM = LuaClass(UIViewModel)

function HouseAssetsPanelVM:Ctor()
    self.RecycleList = UIBindableList.New(ItemVM)
    self.UnRecycleList = UIBindableList.New(ItemVM)
end

function HouseAssetsPanelVM:UpdateRecycleItem(RecyclyData, UnRecycleData)
    local RecycltItemsData = self:MakeItemData(RecyclyData)
    local UnRecycltItemsData = self:MakeItemData(UnRecycleData)
    self.RecycleList:UpdateByValues(RecycltItemsData)
    self.UnRecycleList:UpdateByValues(UnRecycltItemsData)
end

function HouseAssetsPanelVM:MakeItemData(ItemListData)
    local Data = {}
    for i, v in ipairs(ItemListData) do
        local Cfg = ItemCfg:FindCfgByKey(v.ResID)
        local ItemVMData = {}
        if Cfg then
            ItemVMData.Icon = UIUtil.GetIconPath(Cfg.IconID)
            ItemVMData.ResID = v.ResID
            ItemVMData.ItemNum = v.Num
            ItemVMData.ItemQualityIcon = ItemUtil.GetItemColorIcon(v.ResID)

            table.insert(Data, ItemVMData)
        end
    end

    return Data
end

return HouseAssetsPanelVM