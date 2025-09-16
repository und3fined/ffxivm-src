local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SkillCustomDefine = require("Game/Skill/SkillCustomDefine")



---@class SkillCustomBtnBaseVM : UIViewModel
local SkillCustomBtnBaseVM = LuaClass(UIViewModel)

function SkillCustomBtnBaseVM:Ctor()
    self.SkillIcon = nil
    self.Opacity = 1
    self.Scale = 1
    self.ImgSwitchOn = true

    self.ButtonState = SkillCustomDefine.EButtonState.Unavailable
end

return SkillCustomBtnBaseVM