local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateTargetCfgTable = require("TableCfg/FateTargetCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")

local LSTR = _G.LSTR

local FateFinishRewardItemVM = LuaClass(UIViewModel)

function FateFinishRewardItemVM:Ctor()
    self.ItemResID = 0
    self.Num = 0
    self.ItemName = ""
    self.NumVisible = true
end

function FateFinishRewardItemVM:OnBegin()

end

function FateFinishRewardItemVM:IsEqualVM(Value)
    return self.ItemResID == Value.ItemResID
end

function FateFinishRewardItemVM:UpdateVM(Value)
    self.ItemResID = Value.ItemResID
    self.Num = Value.Num
    self.HideItemLevel = true
    self.IconChooseVisible = false
    local TableData = ItemCfg:FindCfgByKey(self.ItemResID)
    if (TableData ~= nil) then
        self.IsQualityVisible = true
        local TempIconID = ItemUtil.GetItemIcon(self.ItemResID)
        self.Icon = UIUtil.GetIconPath(TempIconID) 
        self.ItemQualityIcon = ItemUtil.GetItemColorIcon(self.ItemResID)
        self.IsMask = false
        self.IsSelect = false
        self.ItemName = TableData.ItemName
        self.Name = TableData.ItemName
    end
end

return FateFinishRewardItemVM