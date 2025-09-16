---
--- Author: Alex
--- DateTime: 2023-8-29 09:30:17
--- Description: 风脉泉系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")

---@class AetherCurrentSkillPanelVM : UIViewModel
local AetherCurrentSkillPanelVM = LuaClass(UIViewModel)

---Ctor
function AetherCurrentSkillPanelVM:Ctor()
    -- Main Part
    self:InitData()
end

function AetherCurrentSkillPanelVM:UpdateVM(Value)
    self.TextCD = Value.TextCD
    self.CDPercent = Value.CDPercent
end

--- 更新与最近的风脉泉的距离(m)
function AetherCurrentSkillPanelVM:UpdateClosestPointDistance(DisContent)
    self.ClosestPointDis = DisContent
end

function AetherCurrentSkillPanelVM:UpdateSkillPanelShowAfterRangeStageChange(RangeIndex)
    self.RangeIndex = RangeIndex
end

function AetherCurrentSkillPanelVM:InitData()
    self.TextCD = ""
    self.CDPercent = 0
    self.bShowCDPanel = false
    self.bShowPanelSkillBtn = false
    self.ClosestPointDis = 0
    self.RangeIndex = 0
    self:SetNoCheckValueChange("RangeIndex", true)
    self.bShowSkillPanelDisContent = false

    self.bShowGoldSauserMainBtn = false -- 是否切换显示金碟主界面入口
end

--- 控制风脉仪的可视化
---@param bVisible boolean
function AetherCurrentSkillPanelVM:SetPanelSkillBtnVisible(bVisible)
    self.bShowPanelSkillBtn = bVisible
    if not bVisible then
        local RangeList = AetherCurrentDefine.MachineDetectRange
        self:UpdateSkillPanelShowAfterRangeStageChange(#RangeList + 1) -- 由于音效与动效绑定，所以即使不显示风脉仪也需要更新动效变化
    end--]]
end

--- 控制风脉仪的可视化
---@param bVisible boolean
function AetherCurrentSkillPanelVM:GetPanelSkillBtnVisible()
    return self.bShowPanelSkillBtn
end

return AetherCurrentSkillPanelVM