---
--- Author: alex
--- DateTime: 2025-03-13 17:21
--- Description:金碟奖励一览详情面板成就路径Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSaucerAwardTypeCfg = require("TableCfg/GoldSaucerAwardTypeCfg")

---@class GoldSauserMainPanelAwardGetWayItemVM : UIViewModel
local GoldSauserMainPanelAwardGetWayItemVM = LuaClass(UIViewModel)

function GoldSauserMainPanelAwardGetWayItemVM:Ctor()
    self.AchievementID = nil
    self.Icon = nil
    self.bGot = false
    self.AchievementName = nil
end

function GoldSauserMainPanelAwardGetWayItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.AchievementID == self.AchievementID
end

---UpdateVM
---@param Value table
function GoldSauserMainPanelAwardGetWayItemVM:UpdateVM(Value)
    self.AchievementID = Value.AchievementID
    self.Icon = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_903704.UI_Icon_903704'"--Value.Icon
    self.bGot = Value.bGot
    self.AchievementName = Value.AchievementName
end

return GoldSauserMainPanelAwardGetWayItemVM
