---
--- Author: xingcaicao
--- DateTime: 2023-05-27 17:40
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

---@class TeamRecruitFuncEditVM : UIViewModel
local TeamRecruitFuncEditVM = LuaClass(UIViewModel)

---Ctor
function TeamRecruitFuncEditVM:Ctor()
    self.Name = ""
    self.Icon = "" ---职业Icon
    self.ClassType = 0
    self.ProfInfoList = {}
    self.IsLastItem = false
end

function TeamRecruitFuncEditVM:IsEqualVM(Value)
    return nil ~= Value and self.ClassType == Value.ClassType
end

function TeamRecruitFuncEditVM:UpdateVM(Value)
    self.Name = Value.Name or ""
    self.Icon = Value.Icon or ""
    self.ClassType = Value.ClassType or 0
    self.IsLastItem = Value.IsLastItem == true

    local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
    self.ProfInfoList = TeamRecruitUtil.GetViewingOpenProfs(self.ClassType)
end

return TeamRecruitFuncEditVM