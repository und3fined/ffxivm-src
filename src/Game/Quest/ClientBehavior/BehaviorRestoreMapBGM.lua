---
--- Author: lydianwang
--- DateTime: 2022-07-04
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorRestoreMapBGM
local BehaviorRestoreMapBGM = LuaClass(BehaviorBase, true)

function BehaviorRestoreMapBGM:Ctor(_, Properties)
    self.MapID = tonumber(Properties[1])
end

function BehaviorRestoreMapBGM:DoStartBehavior()
    _G.QuestMgr.QuestRegister:UnRegisterMapBGM(self.MapID)
end

return BehaviorRestoreMapBGM