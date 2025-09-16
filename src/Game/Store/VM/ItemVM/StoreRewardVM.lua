---
---@author Lucas
---DateTime: 2023-05-8 12:11:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")

local StoreDefine = require("Game/Store/StoreDefine")
local ItemCfg = require("TableCfg/ItemCfg")

---@class StoreRewardVM: UIViewModel
---@field ItemIcon string @物品图标
---@field ItemNum string @物品数量
---@field bShowNum boolean @是否显示数量
---@field ItemName string @物品名称
---@field ItemQuality string @物品品质
local StoreRewardVM = LuaClass(UIViewModel)

function StoreRewardVM:Ctor()
    self.ItemIcon = ""
    self.ItemNum = ""
    self.bShowNum = false
    self.ItemName = ""
    self.ItemQuality = ""
end

function StoreRewardVM:IsEqualVM(Value)
	return nil ~= Value
end

function StoreRewardVM:UpdateVM(Value)
    self.bShowNum = false
    local Config = ItemCfg:FindCfgByKey(Value.ItemID)

    self.ItemIcon = UIUtil.GetIconPath(Config.IconID)
    self.ItemName = ItemCfg:GetItemName(Value.ItemID)

    local Quality = StoreDefine.ItemQuality[Config.ItemColor]
    Quality = Quality or StoreDefine.ItemQuality[1]
    self.ItemQuality = Quality

    if Value.Num > 1 then
        self.bShowNum = true
        self.ItemNum = Value.Num
    end
end

return StoreRewardVM