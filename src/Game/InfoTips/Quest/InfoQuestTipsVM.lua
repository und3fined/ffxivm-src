
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local InfoQuestTipsVM = LuaClass(UIViewModel)

---Ctor
function InfoQuestTipsVM:Ctor()
    self.IconPath = ""
    self.MaskPath = ""
end

function InfoQuestTipsVM:OnInit()

end

function InfoQuestTipsVM:OnBegin()

end

function InfoQuestTipsVM:OnEnd()
end


return InfoQuestTipsVM