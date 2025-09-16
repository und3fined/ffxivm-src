---
--- Author: lydianwang
--- DateTime: 2024-12-26
---

local LuaClass = require("Core/LuaClass")
local RestrictionBase = require("Game/Quest/BasicClass/RestrictionBase")
local MajorUtil = require("Utils/MajorUtil")

---@class RestrictionBuddy
local RestrictionBuddy = LuaClass(RestrictionBase, true)

function RestrictionBuddy:Ctor(_, _)
    self:UpdateQuestAtEvent(_G.EventID.BuddyCreate)
    self:UpdateQuestAtEvent(_G.EventID.BuddyDestroy)
end

---@return boolean
function RestrictionBuddy:CheckPassRestriction()
    return _G.BuddyMgr:IsBuddyOuting()
end

---@return boolean
function RestrictionBuddy:CheckNeedUpdateQuest(Params)
    if (Params == nil) or (Params.ULongParam2 == nil) then return false end
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    return (MajorEntityID == Params.ULongParam2)
end

return RestrictionBuddy