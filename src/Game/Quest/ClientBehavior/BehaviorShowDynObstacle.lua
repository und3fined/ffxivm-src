---
--- Author: sammrli
--- DateTime: 2023-12-29
--- Description:客户端行为 显示动态阻挡
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorShowDynObstacle
local BehaviorShowDynObstacle = LuaClass(BehaviorBase, true)

function BehaviorShowDynObstacle:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
    self.ObstacleID = tonumber(Properties[2])
end

function BehaviorShowDynObstacle:DoStartBehavior()
    _G.QuestMgr.QuestRegister:RegisterObstacle(self.MapID, self.ObstacleID)
end

return BehaviorShowDynObstacle