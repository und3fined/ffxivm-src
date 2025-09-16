---
--- Author: lydianwang
--- DateTime: 2021-10-22
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

---@class TargetKillAppointTypeEnemy
local TargetKillAppointTypeEnemy = LuaClass(TargetBase, true)

function TargetKillAppointTypeEnemy:Ctor(_, Properties)
    self.MonsterIDList = {}
    local MonIDStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(MonIDStrList) do
        table.insert(self.MonsterIDList, tonumber(Str))
    end

    self.MaxCount = tonumber(Properties[2])
end

function TargetKillAppointTypeEnemy:GetMonsterIDList()
    return self.MonsterIDList
end

return TargetKillAppointTypeEnemy