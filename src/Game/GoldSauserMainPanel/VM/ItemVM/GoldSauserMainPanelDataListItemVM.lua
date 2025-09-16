---
--- Author: star
--- DateTime: 2024-01-05 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class GoldSauserMainPanelDataListItemVM : UIViewModel
---@field ID number @条目ID
---@field Percentage number @条目ID
---@field DescriptionStr number @条目ID
---@field ID number @条目ID
local GoldSauserMainPanelDataListItemVM = LuaClass(UIViewModel)

function GoldSauserMainPanelDataListItemVM:Ctor()
    self.ID = nil
    self.Percentage = nil
    self.PercentageStr = nil
    self.DescriptionStr = nil
    self.BgPath = nil
end

function GoldSauserMainPanelDataListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

---UpdateVM
---@param Value table
function GoldSauserMainPanelDataListItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.Percentage = Value.Percentage
    self.PercentageStr = string.format("%0.1f%%", self.Percentage)
    self.DescriptionStr = Value.DescriptionStr
    self.BgPath = Value.BgPath
end

return GoldSauserMainPanelDataListItemVM
