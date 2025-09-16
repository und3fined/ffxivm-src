---
--- Author: sammrli
--- DateTime: 2025-3-26
--- Description:客户端行为 开启区域相位
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorShowAreaScene
local BehaviorShowAreaScene = LuaClass(BehaviorBase, true)

function BehaviorShowAreaScene:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
    self.AreaID = tonumber(Properties[2])
    self.TargetPWorldID = tonumber(Properties[3])
end

function BehaviorShowAreaScene:DoStartBehavior()
    _G.QuestMgr.QuestRegister:RegisterAreaScene(self.MapID, self.AreaID)
end

return BehaviorShowAreaScene