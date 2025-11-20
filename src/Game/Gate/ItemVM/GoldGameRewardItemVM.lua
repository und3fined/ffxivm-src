---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")

---@class GoldGameRewardItemVM : UIViewModel

local GoldGameRewardItemVM = LuaClass(UIViewModel)

---Ctor
function GoldGameRewardItemVM:Ctor()
    -- Main Part
    self.ID = 0
    self.Num = ""
    self.Icon = ""
    self.NumVisible = true
    self.ItemName = ""
end

function GoldGameRewardItemVM:IsEqualVM(Value)
    if (Value == nil) then
        return false
    end

    return Value.ID == self.ID
end

function GoldGameRewardItemVM:UpdateVM(Value)
    self.ID = Value.ID
    if (Value.ResID ~= nil) then
        self.ResID = Value.ResID
    else
        self.ResID = self.ID
    end
    
    self.OriginalNum = Value.OriginalNum
    self.IncrementedNum = Value.IncrementedNum
    self.Value = Value.Value
    self.PlayAddEffect = Value.PlayAddEffect
    if (self.PlayAddEffect) then
        self.NumVisible = false
    else
        self.NumVisible = true
        self.Num = ItemUtil.GetItemNumText(tonumber(Value.Num))
    end
    self.IsSelect = Value.IsSelect or false
    self.IsMask = Value.IsMask or false
    self.IconChooseVisible = Value.IconChooseVisible or false

    local Cfg = ItemCfg:FindCfgByKey(self.ID)
    if (Cfg == nil) then
        Cfg = ItemCfg:FindCfgByKey(self.ResID)
    end

    if (Cfg ~= nil) then
        self.ItemName = ItemCfg:GetItemName(self.ID)
        self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
    else
        _G.FLOG_ERROR("无法找到物品数据，ID是: %s 或者 ResID : %s", self.ID, self.ResID)
    end
end

return GoldGameRewardItemVM
