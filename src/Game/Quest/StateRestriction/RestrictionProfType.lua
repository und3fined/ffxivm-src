---
--- Author: sammrli
--- DateTime: 2024-10-25
--- 职业类限制
---

local LuaClass = require("Core/LuaClass")
local RestrictionBase = require("Game/Quest/BasicClass/RestrictionBase")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")

---@class RestrictionProfType
local RestrictionProfType = LuaClass(RestrictionBase, true)

function RestrictionProfType:Ctor(_, Properties)
    self.PropClassID = tonumber(Properties[1]) or 0

    self:UpdateQuestAtEvent(EventID.MajorProfSwitch)
end

---@return boolean
function RestrictionProfType:CheckPassRestriction()
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if not RoleSimple then
        return false
    end
    local CurrProf = RoleSimple.Prof
    return _G.ProfMgr.CheckProfClass(CurrProf, self.PropClassID)
end

---@return boolean
function RestrictionProfType:CheckNeedUpdateQuest(Params)
    if Params and Params.ProfID then
        return _G.ProfMgr.CheckProfClass(Params.ProfID, self.PropClassID)
    end
    return false
end

return RestrictionProfType