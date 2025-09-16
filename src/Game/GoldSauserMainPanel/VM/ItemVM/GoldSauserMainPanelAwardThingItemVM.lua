---
--- Author: alex
--- DateTime: 2025-03-12 09:57
--- Description:金碟奖励一览内容Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class GoldSauserMainPanelAwardThingItemVM : UIViewModel
local GoldSauserMainPanelAwardThingItemVM = LuaClass(UIViewModel)

function GoldSauserMainPanelAwardThingItemVM:Ctor()
    self.ID = nil -- 配置唯一ID
    self.bSelected = false -- 是否已选中
    self.bMarked = false -- 是否已收藏
    self.Name = nil
    self.BelongTypeName = nil

    --- ItemSlot Use
    self.ItemQualityIcon = nil
    self.IsQualityVisible = false
    self.Icon = nil
    self.NumVisible = false -- default hide
    self.ItemLevelVisible = false -- default hide
    self.IconChooseVisible = false -- default hide
    self.IconReceivedVisible = false -- default hide
    self.IsMask = false -- default hide
end

function GoldSauserMainPanelAwardThingItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

---UpdateVM
---@param Value table
function GoldSauserMainPanelAwardThingItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.bMarked = Value.bMarked

    local QualityVisible = Value.IsQualityVisible
    self.IsQualityVisible = QualityVisible
    if QualityVisible then
        self.ItemQualityIcon = Value.ItemQualityIcon
    end
    self.Icon = Value.Icon
    local IconReceivedVisible = Value.IconReceivedVisible
    self.IconReceivedVisible = IconReceivedVisible
    self.IsMask = IconReceivedVisible

    self.BelongTypeName = Value.BelongTypeName
    self.Name = Value.Name
end

function GoldSauserMainPanelAwardThingItemVM:SetSelected(bSelect)
    self.bSelected = bSelect
end

return GoldSauserMainPanelAwardThingItemVM
