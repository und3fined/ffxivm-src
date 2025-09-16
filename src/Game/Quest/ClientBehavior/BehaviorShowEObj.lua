---
--- Author: lydianwang
--- DateTime: 2023-02-15
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local ClientVisionMgr = require("Game/Actor/ClientVisionMgr")

---@class BehaviorShowEObj
local BehaviorShowEObj = LuaClass(BehaviorBase, true)

function BehaviorShowEObj:Ctor(_, Properties)
    self.EObjID = tonumber(Properties[1])
end

function BehaviorShowEObj:DoStartBehavior()
    _G.QuestMgr.QuestRegister:RegisterEObj(self.EObjID)
    ClientVisionMgr:VisionTick()
end

return BehaviorShowEObj