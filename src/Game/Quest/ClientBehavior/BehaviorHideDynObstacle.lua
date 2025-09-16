---
--- Author: sammrli
--- DateTime: 2023-12-29
--- Description:客户端行为 隐藏动态阻挡
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorHideDynObstacle
local BehaviorHideDynObstacle = LuaClass(BehaviorBase, true)

function BehaviorHideDynObstacle:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
    self.ObstacleID = tonumber(Properties[2])
end

function BehaviorHideDynObstacle:DoStartBehavior()
    _G.QuestMgr.QuestRegister:UnRegisterObstacle(self.MapID, self.ObstacleID)
end

return BehaviorHideDynObstacle