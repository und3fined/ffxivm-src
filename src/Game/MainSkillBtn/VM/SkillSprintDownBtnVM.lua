local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SkillSprintDownBtnVM : UIViewModel
local SkillSprintDownBtnVM = LuaClass(UIViewModel)

function SkillSprintDownBtnVM:Ctor()
    self.SkillCD = nil
    self.bSkillValid = true
end

function SkillSprintDownBtnVM:SetSkillCD(SkillCD)
    if SkillCD > 0 then
        self.bSkillValid = false
        self.SkillCD = tostring(math.ceil(SkillCD))
    else
        self.bSkillValid = true
        self.SkillCD = nil
    end
end

function SkillSprintDownBtnVM:GetSkillCD()
    return self.SkillCD or 0
end

function SkillSprintDownBtnVM:IsSkillValid()
    return self.bSkillValid
end

return SkillSprintDownBtnVM