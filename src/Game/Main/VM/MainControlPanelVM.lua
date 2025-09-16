
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")



local BtnSwitchDefaultIcon = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Btn_Switch_png.UI_Skill_Btn_Switch_png'"
local BtnSwitchDisableIcon = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Btn_SwitchDisable_png.UI_Skill_Btn_SwitchDisable_png'"


local DefaultBG = {
    [1] = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_GenAttack_Btn_Base_png.UI_Skill_GenAttack_Btn_Base_png'",
    [2] = "Texture2D'/Game/UI/Texture/MainSkill/UI_Skill_Btn_UpBG.UI_Skill_Btn_UpBG'",
    [3] = "Texture2D'/Game/UI/Texture/MainSkill/UI_Skill_Btn_DownBG.UI_Skill_Btn_DownBG'",
}


---@class MainControlPanelVM : UIViewModel
local MainControlPanelVM = LuaClass(UIViewModel)

function MainControlPanelVM:Ctor()
    rawset(self, "BtnSwitchTips", 0)
    self.BtnSwitchIcon = BtnSwitchDefaultIcon
    self.bFightStatus = false
    self.SkillSprintVisible = true  --疾跑跳跃
    self.bLimitCastState = true
    self.LimitGenAttackVisible = true

    self:ResetDefaultBG()
end

function MainControlPanelVM:OnInit()
end

function MainControlPanelVM:OnBegin()

end

function MainControlPanelVM:OnEnd()
end

function MainControlPanelVM:OnShutdown()
end

function MainControlPanelVM:SetFightStatus(bFight)
    self.bFightStatus = bFight
    self:UpdateSwitchDisplay()
end

local EBtnSwitchCondition = {
    FightToPeace = 1,
    PeaceToFight = 2,
}
MainControlPanelVM.EBtnSwitchCondition = EBtnSwitchCondition

-- Condition表示在什么场景下置灰, 目前有 Peace切Fight 和 Fight切Peace 两个场景
-- 默认场景为FightToPeace
function MainControlPanelVM:SetBtnSwitchTips(TipsID, Condition)
    rawset(self, "BtnSwitchTips", TipsID)
    rawset(self, "BtnSwitchCondition", Condition or EBtnSwitchCondition.FightToPeace)
    self:UpdateSwitchDisplay()
end

function MainControlPanelVM:GetBtnSwitchTips()
    return rawget(self, "BtnSwitchTips")
end

function MainControlPanelVM:UpdateSwitchDisplay()
    local Condition = rawget(self, "BtnSwitchCondition") or 0
    local bConditionValid = false
    if Condition > 0 then
        if Condition == EBtnSwitchCondition.FightToPeace then
            bConditionValid = self.bFightStatus
        elseif Condition == EBtnSwitchCondition.PeaceToFight then
            bConditionValid = not self.bFightStatus
        end
    end
        
    if rawget(self, "BtnSwitchTips") > 0 and bConditionValid then
        self.BtnSwitchIcon = BtnSwitchDisableIcon
    else
        self.BtnSwitchIcon = BtnSwitchDefaultIcon
    end
end

function MainControlPanelVM:SkillSprintVisibleModify(bVisible)
    self.SkillSprintVisible = bVisible
end

function MainControlPanelVM:SetLimitGenAttackVisible(bVisible)
    self.LimitGenAttackVisible = bVisible
end

function MainControlPanelVM:ResetDefaultBG()
    for i = 1, #DefaultBG do
        self[string.format("BGIcon_%d", i)] = DefaultBG[i]
    end
end

return MainControlPanelVM