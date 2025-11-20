local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

---@class SkillHandleRunBtnVM : UIViewModel
local SkillHandleRunBtnVM = LuaClass(UIViewModel)


local prof_type = ProtoCommon.prof_type

local AllIconPath = {
	[prof_type.PROF_TYPE_FISHER] = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Btn_SitDown_png.UI_Skill_Btn_SitDown_png'",
	[prof_type.PROF_TYPE_NULL] = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Main_Skill_Btn_Sprint2_png.UI_Main_Skill_Btn_Sprint2_png'",
}

function SkillHandleRunBtnVM:Ctor()
    self.SkillCD = nil
    self.bSkillValid = true
    self.NormalCDPercent = 0
    self.SkillIcon = ""
    self.IsSpeedSkill = true
    self.SkillCDUpadting = true
end

function SkillHandleRunBtnVM:SetSkillCD(SkillCD, BaseCD)
    if self.IsSpeedSkill and SkillCD > 0 then
        self.bSkillValid = false
        self.SkillCD = tostring(math.ceil(SkillCD))
        if BaseCD and BaseCD > 0 then
            self.NormalCDPercent = 1 - SkillCD/BaseCD
        end
        self.SkillCDUpadting = true
    else
        self.bSkillValid = true
        self.SkillCD = nil
        self.NormalCDPercent = 0
        self.SkillCDUpadting = false
    end
end

function SkillHandleRunBtnVM:GetSkillCD()
    return self.SkillCD or 0
end

function SkillHandleRunBtnVM:IsSkillValid()
    return self.bSkillValid
end

function SkillHandleRunBtnVM:GetIsSpeedSkill()
    return self.IsSpeedSkill
end

function SkillHandleRunBtnVM:SetSpeedSkillIcon(IsSpeedSkill)
    local IsFishingProf = MajorUtil.IsFishingProf()
    if IsSpeedSkill then
        self.SkillIcon = AllIconPath[prof_type.PROF_TYPE_NULL]
        self.IsSpeedSkill = true
    elseif not IsSpeedSkill and IsFishingProf then
        self.SkillIcon = AllIconPath[prof_type.PROF_TYPE_FISHER]
        self.IsSpeedSkill = false
    end
end

return SkillHandleRunBtnVM