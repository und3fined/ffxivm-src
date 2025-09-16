local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FishCfg = require("TableCfg/FishCfg")
local ItemCfg = require("TableCfg/ItemCfg")

---@class FishItemVM : UIViewModel
local FishItemVM = LuaClass(UIViewModel)

function FishItemVM:Ctor()
    self.Index = nil

    self.FishID = 0
    self.FishIcon = ""
    self.FishName = nil
    self.FishLevel = 0
    self.FishCount = 0
    self.FishSize = 0.0
    self.FishCollectionValue = 0
    self.FishEnabled = false
end

function FishItemVM:InitFishInfo(FishID, FishCount, FishSize, FishValue)
    self.FishID = FishID or 0
    if self.FishID > 0 then
        local Cfg = FishCfg:FindCfgByKey(self.FishID)
        local FishName = Cfg and Cfg.Name or ""
        self.FishName = FishName
        self.FishLevel = Cfg and Cfg.Level or 0
        local ItemID = Cfg and Cfg.ItemID or 0
        local Item_Cfg = ItemCfg:FindCfgByKey(ItemID)
        if Item_Cfg then
            self.FishIcon = ItemCfg.GetIconPath(Item_Cfg.IconID)
        end
    end
    self.FishCount = FishCount or 0
    self.FishCollectionValue = FishValue or 0
    self.FishSize = FishSize or 0
    self.FishEnabled = false
end

function FishItemVM:SetFishID(FishID)
    self.FishID = FishID
end

function FishItemVM:GetFishID()
    return self.FishID
end

function FishItemVM:SetFishCount(FishCount)
    self.FishCount = FishCount or 0
    if FishCount > 0 and self.FishEnabled == false then
        self.FishEnabled = true
    end
end

function FishItemVM:GetFishCount()
    return self.FishCount or 0
end

function FishItemVM:IsEqualVM(Value)
    return self.FishID == Value.FishID
end

function FishItemVM:UpdateVM(Value)
    self.FishID = Value.FishID
    rawset(self, "Index", Value.Index)
    local Cfg = FishCfg:FindCfgByKey(self.FishID)
    if Cfg then
        local ItemID = Cfg.ItemID
        local Item_Cfg = ItemCfg:FindCfgByKey(ItemID)
        if Item_Cfg then
            self.FishIcon = ItemCfg.GetIconPath(Item_Cfg.IconID)
        end
    end
end

return FishItemVM