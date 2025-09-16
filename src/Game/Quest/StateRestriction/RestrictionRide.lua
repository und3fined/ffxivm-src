---
--- Author: lydianwang
--- DateTime: 2022-11-21
---

local LuaClass = require("Core/LuaClass")
local RestrictionBase = require("Game/Quest/BasicClass/RestrictionBase")
local MajorUtil = require("Utils/MajorUtil")

---@class RestrictionRide
local RestrictionRide = LuaClass(RestrictionBase, true)

function RestrictionRide:Ctor(_, Properties)
    self.MountID = tonumber(Properties[1])

    self:UpdateQuestAtEvent(_G.EventID.MountCall)
    self:UpdateQuestAtEvent(_G.EventID.MountBack)
end

---@return boolean
function RestrictionRide:CheckPassRestriction()
    return _G.MountMgr:IsRidingOnResID(self.MountID)
end

---@return boolean
function RestrictionRide:CheckNeedUpdateQuest(Params)
    if (Params == nil) or (Params.EntityID == nil) then return false end
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    return (MajorEntityID == Params.EntityID)
end

return RestrictionRide