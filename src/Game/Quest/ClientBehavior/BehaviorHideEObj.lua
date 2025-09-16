---
--- Author: lydianwang
--- DateTime: 2023-02-15
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorHideEObj
local BehaviorHideEObj = LuaClass(BehaviorBase, true)

function BehaviorHideEObj:Ctor(_, Properties)
    self.EObjID = tonumber(Properties[1])
end

function BehaviorHideEObj:DoStartBehavior()
    local QuestRegister = _G.QuestMgr.QuestRegister
    QuestRegister:UnRegisterEObj(self.EObjID)
    QuestRegister:UnRegisterEObjState(self.EObjID)
end

return BehaviorHideEObj