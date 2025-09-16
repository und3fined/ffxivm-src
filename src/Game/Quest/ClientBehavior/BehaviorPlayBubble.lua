---
--- Author: lydianwang
--- DateTime: 2021-12-14
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorPlayBubble
local BehaviorPlayBubble = LuaClass(BehaviorBase, true)

function BehaviorPlayBubble:Ctor(_, Properties)
    self.GroupID = tonumber(Properties[1])
end

function BehaviorPlayBubble:DoStartBehavior()
    _G.SpeechBubbleMgr:ShowBubbleGroup(self.GroupID, true)
end

return BehaviorPlayBubble