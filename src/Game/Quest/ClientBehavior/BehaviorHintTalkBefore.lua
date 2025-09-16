---
--- Author: lydianwang
--- DateTime: 2023-02-15
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")

---@class BehaviorHintTalkBefore
local BehaviorHintTalkBefore = LuaClass(BehaviorBase, true)

function BehaviorHintTalkBefore:Ctor(_, Properties, ExtraParams)
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

function BehaviorHintTalkBefore:DoStartBehavior()
    -- 设置放在激活过程里，任务开始时只负责移除
    local QuestRegister = _G.QuestMgr.QuestRegister
    if self.NpcID ~= 0 then
        QuestRegister:SetHintTalk(self.NpcID, nil)
    elseif self.EObjID ~= 0 then
        QuestRegister:SetHintTalk(nil, self.EObjID)
    end
end

function BehaviorHintTalkBefore:RegisterHintTalk()
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

    -- DoStartBehavior清除HintTalk
    local QuestMgr = _G.QuestMgr
    QuestMgr.QuestRegister:SetHintTalk(self.NpcID, self.EObjID, self.DialogID, Callback)
end

return BehaviorHintTalkBefore