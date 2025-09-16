---
--- Author: lydianwang
--- DateTime: 2022-01-18
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local QuestHelper = require("Game/Quest/QuestHelper")

---@class BehaviorPlaySequence
local BehaviorPlaySequence = LuaClass(BehaviorBase, true)

function BehaviorPlaySequence:Ctor(_, Properties)
    self.SequenceID = tonumber(Properties[1])

    self.bDoNextAsCallback = true
end

function BehaviorPlaySequence:DoStartBehavior()
    self:PlaySequence()
end

function BehaviorPlaySequence:PlaySequence()
    if self.SequenceID > 0 then
        local function SequenceStoppedCallback(_)
            _G.NpcDialogMgr:CheckNeedEndInteraction()
            -- print("BehaviorPlaySequence:OnSequenceStopped")
            -- self:OnSequenceStopped()
        end
        QuestHelper.QuestPlaySequence(self.SequenceID, SequenceStoppedCallback)
    end
end

-- function BehaviorPlaySequence:OnSequenceStopped()
--     self:DoNextBehaviors()
-- end

return BehaviorPlaySequence