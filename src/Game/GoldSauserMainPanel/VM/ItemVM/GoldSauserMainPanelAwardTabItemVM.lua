---
--- Author: alex
--- DateTime: 2025-03-11 14:50
--- Description:金碟奖励一览导航页签
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSaucerAwardTypeCfg = require("TableCfg/GoldSaucerAwardTypeCfg")

---@class GoldSauserMainPanelAwardTabItemVM : UIViewModel
local GoldSauserMainPanelAwardTabItemVM = LuaClass(UIViewModel)

function GoldSauserMainPanelAwardTabItemVM:Ctor()
    self.AwardType = nil
    self.Icon = nil
    self.IconSelected = nil
    self.bChecked = false
end

function GoldSauserMainPanelAwardTabItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.AwardType == self.AwardType
end

---UpdateVM
---@param Value table
function GoldSauserMainPanelAwardTabItemVM:UpdateVM(Value)
    local AwardType = Value.AwardType
    self.AwardType = AwardType
    local TabChecked = Value.bChecked
    self.IconSelected = GoldSaucerAwardTypeCfg:FindValue(AwardType, "AwardIconSelected")
    self.Icon = GoldSaucerAwardTypeCfg:FindValue(AwardType, "AwardIcon")
    self.bChecked = TabChecked
end

return GoldSauserMainPanelAwardTabItemVM
