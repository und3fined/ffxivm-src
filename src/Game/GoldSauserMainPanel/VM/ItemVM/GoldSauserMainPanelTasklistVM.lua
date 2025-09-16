---
--- Author: alex
--- DateTime: 2024-01-05 10:41
--- Description:金碟主界面玩法事件Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class GoldSauserMainPanelTasklistVM : UIViewModel
---@field ID number @条目ID
---@field DescriptionStr string @描述文本
---@field Num number @已完成进度
---@field MaxNum number @需要完成的数量
---@field RightWidgetIndex number @控件选择下标
local GoldSauserMainPanelTasklistVM = LuaClass(UIViewModel)

function GoldSauserMainPanelTasklistVM:Ctor()
    self.ID = nil
    self.Num = nil
    self.MaxNum = nil
    self.DescriptionStr = nil
    self.RightWidgetIndex = nil
    self.CompletePercentText = ""
    self.ProcessVisible = true
    self.TextColorHex = nil
    self.bNeedRefresh = false
end

function GoldSauserMainPanelTasklistVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

---UpdateVM
---@param Value table
function GoldSauserMainPanelTasklistVM:UpdateVM(Value)
    self.ID = Value.ID
    local CompleteNum = Value.Num or 0
    local TotalNum = Value.MaxNum or 0
    self.CompletePercentText = string.format("%d/%d", CompleteNum, TotalNum)
    self.DescriptionStr = Value.DescriptionStr

    local bRewardCanReceive = Value.bRewardCanReceive
    local WidgetSwitchIndex = Value.RightWidgetIndex
    self.RightWidgetIndex = WidgetSwitchIndex
    self.ProcessVisible = WidgetSwitchIndex ~= 0 or not bRewardCanReceive
    self.TextColorHex = self.ProcessVisible and "313131ff" or "828282ff"
    self.bNeedRefresh = Value.bNeedRefresh
end

return GoldSauserMainPanelTasklistVM
