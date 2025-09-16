---
--- Author: lydianwang
--- DateTime: 2023-02-15
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local QuestHelper = require("Game/Quest/QuestHelper")

---@class BehaviorHintTalk
local BehaviorHintTalk = LuaClass(BehaviorBase, true)

function BehaviorHintTalk:Ctor(_, Properties, ExtraParams)
    self.NpcID = tonumber(Properties[1]) or 0
    self.EObjID = tonumber(Properties[2]) or 0
    self.DialogID = tonumber(Properties[3])

    local QuestMgr = _G.QuestMgr

    self.QuestID = ExtraParams.QuestID
    self.EndCliBehaviors = {}
    for _, BehaviorID in ipairs(ExtraParams.EndCliBehavior) do
        local Behavior = QuestMgr.CreateClientBehavior(self.QuestID, BehaviorID)
        table.insert(self.EndCliBehaviors, Behavior)
    end
    self.EndSvrBehaviorIDs = ExtraParams.EndSvrBehavior or {}
end

function BehaviorHintTalk:DoStartBehavior()
    local CliBehaviors = self.EndCliBehaviors
    local SvrBehaviorIDs = self.EndSvrBehaviorIDs
    local function Callback()
        local QuestMgr = _G.QuestMgr
        for _, Behavior in ipairs(CliBehaviors) do
            Behavior:StartBehavior()
        end
        for _, ID in ipairs(SvrBehaviorIDs) do
            QuestMgr:SendTriggerSvrBehavior(ID)
        end
    end

    -- 由Quest清除HintTalk
    local QuestMgr = _G.QuestMgr
    QuestMgr.QuestRegister:SetHintTalk(self.NpcID, self.EObjID, self.DialogID, Callback)
    local ParentQuest = QuestMgr.QuestMap[self.QuestID]
    if self.NpcID ~= 0 then
        table.insert(ParentQuest.HintTalkNpcs, self.NpcID)
    elseif self.EObjID ~= 0 then
        table.insert(ParentQuest.HintTalkEObjs, self.EObjID)
    end
end

return BehaviorHintTalk