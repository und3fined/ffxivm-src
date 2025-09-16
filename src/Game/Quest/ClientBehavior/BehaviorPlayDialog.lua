---
--- Author: lydianwang
--- DateTime: 2022-12-27
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local ActorUtil = require("Utils/ActorUtil")
local NpcDialogMgr = require("Game/NPC/NpcDialogMgr")
local QuestHelper = require("Game/Quest/QuestHelper")

---@class BehaviorPlayDialog
local BehaviorPlayDialog = LuaClass(BehaviorBase, true)

function BehaviorPlayDialog:Ctor(_, Properties)
    self.DialogID = tonumber(Properties[1])
    self.NpcID = tonumber(Properties[2])
end

function BehaviorPlayDialog:DoStartBehavior()
    if (self.DialogID == 0) or (self.NpcID == 0) then
        QuestHelper.PrintQuestError("BehaviorPlayDialog - InValid DialogID or NpcID")
        return
    end

    local EntityID = nil
    local Actor = ActorUtil.GetActorByResID(self.NpcID)
    if Actor then
        local AttrComp = Actor:GetAttributeComponent()
        if AttrComp then EntityID = AttrComp.EntityID end
    end

    NpcDialogMgr:PlayDialogLib(self.DialogID, EntityID)
end

return BehaviorPlayDialog