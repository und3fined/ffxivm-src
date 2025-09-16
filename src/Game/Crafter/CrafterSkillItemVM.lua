local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CrafterSkillItemVM : UIViewModel
local CrafterSkillItemVM = LuaClass(UIViewModel)

---Ctor
function CrafterSkillItemVM:Ctor()
    self.SkillID = 0

    self.SkillIcon = ""
    self.bCommonMask = false

    -- self.bNormalCD = false
    -- self.NormalCDPercent = 0
    self.SkillCDText = ""

    self.bLevelText = false
    -- self.LevelText = 0
    self.bLockedByLevel = false
end

function CrafterSkillItemVM:OnInit()

end

return CrafterSkillItemVM