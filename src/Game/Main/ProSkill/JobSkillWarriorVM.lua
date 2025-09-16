local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class JobSkillWarriorVM : UIViewModel
local JobSkillWarriorVM = LuaClass(UIViewModel)

function JobSkillWarriorVM:Ctor()
    self.WrathPercent = 0        -- 兽魂值(百分制)
    self.bIs50AnimPlay = false   -- 50~100的动画是否播放
    self.bIs100AnimPlay = false  -- 100的动画是否播放
end

return JobSkillWarriorVM