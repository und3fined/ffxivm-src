---
--- Author: lydianwang
--- DateTime: 2021-11-25
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local ClientVisionMgr = require("Game/Actor/ClientVisionMgr")

---@class BehaviorShowNPC
local BehaviorShowNPC = LuaClass(BehaviorBase, true)

function BehaviorShowNPC:Ctor(_, Properties)
    self.NpcID = tonumber(Properties[1])
end

function BehaviorShowNPC:DoStartBehavior()
    _G.FLOG_INFO("BehaviorShowNPC:DoStartBehavior %d", self.NpcID or 0)
    _G.QuestMgr.QuestRegister:RegisterClientNpc(self.NpcID)
    ClientVisionMgr:VisionTick() -- 先tick一遍，能创建就创建，避免某些情况下出现时序相关问题
end

return BehaviorShowNPC