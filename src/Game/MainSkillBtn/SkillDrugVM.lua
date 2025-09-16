---
--- Author: v_zanchang
--- DateTime: 2021-08-16 20:32
--- Description:
---



local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class SkillDrugVM : UIViewModel
local SkillDrugVM = LuaClass(UIViewModel)

---Ctor
function SkillDrugVM:Ctor()
    self.ResID = nil -- 设置战斗药品的资源ID
    self.DrugGID = nil
    self.IsHaveCD = false --战斗药品CD
    self.GroupID = nil -- 战斗药品背包CD组
end

function SkillDrugVM:OnInit()

end

return SkillDrugVM