---
--- Author: xingcaicao
--- DateTime: 2023-05-19 16:17
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class TeamRecruitTypeVM : UIViewModel
local TeamRecruitTypeVM = LuaClass(UIViewModel)

---Ctor
function TeamRecruitTypeVM:Ctor()
    self.TypeID = nil
	self.Name = ""
	self.Icon = ""
end

function TeamRecruitTypeVM:UpdateVM(Value)
    self.TypeID = Value.ID
    self.Name = Value.Name
    self.Icon = Value.Icon
    self.PatternIcon = Value.Icon
end

function TeamRecruitTypeVM:IsEqualVM(Value)
    return nil ~= Value and self.TypeID == Value.TypeID
end

return TeamRecruitTypeVM