---
--- Author: lydianwang
--- DateTime: 2022-07-04
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorChangeMapBGM
local BehaviorChangeMapBGM = LuaClass(BehaviorBase, true)

function BehaviorChangeMapBGM:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
    self.BGM = Properties[2]
end

function BehaviorChangeMapBGM:DoStartBehavior()
    _G.QuestMgr.QuestRegister:RegisterMapBGM(self.MapID, self.BGM)
end

return BehaviorChangeMapBGM