
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local HouseAssetsPanelItemVM = LuaClass(UIViewModel)

function HouseAssetsPanelItemVM:Ctor()
    self.Icon = ""
    self.ItemQualityIcon = ""
    self.ItemNum = nil
    self.NumVisible = true
    self.ResID = 0
end

function HouseAssetsPanelItemVM:IsEqualVM(Value)
    return self.ResID == Value.ResID
end

function HouseAssetsPanelItemVM:UpdateVM(Value)
    self.Icon = Value.Icon
    self.ItemQualityIcon = Value.ItemQualityIcon
    self.ItemNum = Value.ItemNum
    self.ResID = Value.ResID
end

return HouseAssetsPanelItemVM