---
--- Author: anypkvcai
--- DateTime: 2021-09-28 10:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class ItemSimpleVM : UIViewModel
local ItemSimpleVM = LuaClass(UIViewModel)

---Ctor
function ItemSimpleVM:Ctor()
    self.Num = nil
    self.Name = ""
    self.Icon = nil
    self.QualityVisible = true
    self.IconChooseVisible = false
    self.ItemQualityIcon = ""
    self.NumVisible = true
end

---UpdateVM
---@param Value CommonLootItem
function ItemSimpleVM:UpdateVM(InData)
    self.ItemID = InData.ItemID or 0
    self.ResID = self.ItemID
    self.Num = InData.ItemNum or 0
    self.Icon = UIUtil.GetItemIconPath(self.ItemID)
    self.ItemQualityIcon = ItemUtil.GetItemColorIcon(self.ItemID)
end

---CreateVM
---@param LootItem CommonLootItem
function ItemSimpleVM.CreateVM(InData)
    local ViewModel = ItemSimpleVM.New()
    ViewModel:UpdateVM(InData)
    return ViewModel
end

return ItemSimpleVM
