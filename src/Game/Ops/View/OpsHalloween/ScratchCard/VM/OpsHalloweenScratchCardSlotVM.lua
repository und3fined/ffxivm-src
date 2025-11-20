---
--- Author: michaelyang_lightpaw
--- DateTime: 2025-07-10
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class OpsHalloweenScratchCardSlotVM : UIViewModel
local OpsHalloweenScratchCardSlotVM = LuaClass(UIViewModel)

function OpsHalloweenScratchCardSlotVM:Ctor()
    self.ItemID = 0 -- 物品ID
    self.Icon = "" -- 图片路径
    self.SlotIndex = 0 -- 刮刮乐位置
    self.PhaseIndex = 0 -- 第几期的
    self.Num = 0
    self.Icon = ""
    self.IconChooseVisible = false
    self.ItemQualityIcon = ""
end

function OpsHalloweenScratchCardSlotVM:UpdateVM(InData)
    self.bGetted =InData.bGetted
    self.SlotIndex = InData.SlotIndex
    self.PhaseIndex = InData.PhaseIndex
    self.ItemID = InData.ItemID or 0
    self.Num = InData.Num or 0
    self.Icon = UIUtil.GetItemIconPath(self.ItemID)
    self.ItemQualityIcon = ItemUtil.GetItemColorIcon(self.ItemID)
end

function OpsHalloweenScratchCardSlotVM:IsEqualVM(InData)
    return false
    --return InData.SlotIndex == self.SlotIndex
end

return OpsHalloweenScratchCardSlotVM
