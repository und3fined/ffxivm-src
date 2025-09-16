---
--- Author: sammrli
--- DateTime: 2025-3-26
--- Description:客户端行为 关闭区域相位
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorHideAreaScene
local BehaviorHideAreaScene = LuaClass(BehaviorBase, true)

function BehaviorHideAreaScene:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
    self.AreaID = tonumber(Properties[2])
end

function BehaviorHideAreaScene:DoStartBehavior()
    _G.QuestMgr.QuestRegister:UnRegisterAreaScene(self.MapID, self.AreaID)
end

return BehaviorHideAreaScene