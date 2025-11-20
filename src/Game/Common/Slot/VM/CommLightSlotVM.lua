local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemDefine = require("Game/Item/ItemDefine")
local UIUtil = require("Utils/UIUtil")

---@class CommLightSlotVM : UIViewModel
local CommLightSlotVM = LuaClass(UIViewModel)


function CommLightSlotVM:Ctor()
    self.Icon = nil
    self.ItemQualityIcon = nil
    self.NumVisible = nil
    self.ItemNum = nil
    self.IsSelect = nil
    self.IsMask = nil
    self.IsWearable = nil
end

function CommLightSlotVM:IsEqualVM(Value)
    return nil ~= Value and self.ID == Value.ID
end

function CommLightSlotVM:UpdateVM(Value)
    self.ItemID = Value.ItemID
    self.ID = Value.ID

    local ItemData = ItemCfg:FindCfgByKey(Value.ItemID)
    if ItemData then
        local IsHQ = (1 == ItemData.IsHQ)
        if IsHQ then
            self.ItemQualityIcon = ItemDefine.HQLightSlotColotType[ItemData.ItemColor]
        else
            self.ItemQualityIcon = ItemDefine.LightSlotColotType[ItemData.ItemColor]
        end

        self.Icon = UIUtil.GetIconPath(ItemData.IconID)
        self.ItemNum = Value.Num
        self.NumVisible = Value.IsShowNum and (ItemData.MaxPile > 1 or self.ItemNum > 1)
      
        self.IsMask = Value.IsMask or false
        self.IsWearable = Value.IsWearable or false
    end

    self.IsSelect = Value.IsSelect or false 
end

function CommLightSlotVM:OnSelectChanged(bSelect)
    self.IsSelect = bSelect
end

--要返回当前类
return CommLightSlotVM