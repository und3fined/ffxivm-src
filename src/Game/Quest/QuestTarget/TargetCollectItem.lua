---
--- Author: lydianwang
--- DateTime: 2022-05-17
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

---@class TargetCollectItem
local TargetCollectItem = LuaClass(TargetBase, true)

function TargetCollectItem:Ctor(_, Properties)
    self.ItemID = tonumber(Properties[1])
    self.MaxCount = tonumber(Properties[2])
    -- self.SourceType = tonumber(Properties[3]) -- 废弃

    self.MonsterIDList = {}
    local MonIDStrList = string.split(Properties[4], "|")
    for _, Str in ipairs(MonIDStrList) do
        table.insert(self.MonsterIDList, tonumber(Str))
    end
end

function TargetCollectItem:GetMonsterIDList()
    return self.MonsterIDList
end

return TargetCollectItem