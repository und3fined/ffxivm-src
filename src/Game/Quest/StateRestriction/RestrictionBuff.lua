---
--- Author: lydianwang
--- DateTime: 2022-11-21
---

local LuaClass = require("Core/LuaClass")
local RestrictionBase = require("Game/Quest/BasicClass/RestrictionBase")
local BuffUtil = require("Utils/BuffUtil")

---@class RestrictionBuff
local RestrictionBuff = LuaClass(RestrictionBase, true)

function RestrictionBuff:Ctor(_, Properties)
    self.BuffIDList = {}

    local BuffIDStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(BuffIDStrList) do
        table.insert(self.BuffIDList, tonumber(Str))
    end

    self:UpdateQuestAtEvent(_G.EventID.MajorInfoRefreshBuff)
end

---@return boolean
function RestrictionBuff:CheckPassRestriction()
    for i = 1, #self.BuffIDList do
        local BuffID = self.BuffIDList[i]
        if not BuffID then return false end

        if not BuffUtil.IsMajorBuffExist(BuffID) then return false end
    end

    return true
end

return RestrictionBuff