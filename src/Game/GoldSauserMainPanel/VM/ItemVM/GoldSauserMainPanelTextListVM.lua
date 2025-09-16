---
--- Author: star
--- DateTime: 2024-01-05 10:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSaucerGameDescCfg = require("TableCfg/GoldSaucerGameDescCfg")

---@class GoldSauserMainPanelTextListVM : UIViewModel
---@field ID number @条目ID
---@field DescriptionStr number @条目ID
---@field ID number @条目ID
local GoldSauserMainPanelTextListVM = LuaClass(UIViewModel)

function GoldSauserMainPanelTextListVM:Ctor()
    self.ID = nil
    self.DescriptionStr = nil
end

function GoldSauserMainPanelTextListVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

---UpdateVM
---@param Value table
function GoldSauserMainPanelTextListVM:UpdateVM(Value)
    self.ID = Value.ID
    self.DescriptionStr = Value.DescriptionStr
end

return GoldSauserMainPanelTextListVM
