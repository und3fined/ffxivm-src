local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local JobSkillMonkVM = LuaClass(UIViewModel)

function JobSkillMonkVM:Ctor()
    self.CurPile = 0
    self.ChakraVisible = false
end

return JobSkillMonkVM