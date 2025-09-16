---
--- Author: lydianwang
--- DateTime: 2022-05-17
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

local EActorType = _G.UE.EActorType

---@class TargetCastSkill
local TargetCastSkill = LuaClass(TargetBase, true)

function TargetCastSkill:Ctor(_, Properties)
    self.SkillIDList = {}
    local SkillIDStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(SkillIDStrList) do
        table.insert(self.SkillIDList, tonumber(Str))
    end

    self.NpcID = tonumber(Properties[2])
    self.MonsterID = tonumber(Properties[3])
    self.MaxCount = tonumber(Properties[4])
    self.EObjID = tonumber(Properties[5])
end

function TargetCastSkill:DoStartTarget()
    local ActorType, ResID
    if self.NpcID > 0 then
        ActorType, ResID = EActorType.Npc, self.NpcID
    elseif self.MonsterID > 0 then
        ActorType, ResID = EActorType.Monster, self.MonsterID
    elseif self.EObjID > 0 then
        ActorType, ResID = EActorType.EObj, self.EObjID
    end
    if (ActorType == nil) or (ResID == nil) then return end

    for _, SkillID in ipairs(self.SkillIDList) do
        _G.SelectTargetMgr:AddSkillTargetByResID(SkillID, ActorType, ResID)
    end
end

function TargetCastSkill:DoClearTarget()
    local ActorType, ResID
    if self.NpcID > 0 then
        ActorType, ResID = EActorType.Npc, self.NpcID
    elseif self.MonsterID > 0 then
        ActorType, ResID = EActorType.Monster, self.MonsterID
    elseif self.EObjID > 0 then
        ActorType, ResID = EActorType.EObj, self.EObjID
    end
    if (ActorType == nil) or (ResID == nil) then return end
    
    for _, SkillID in ipairs(self.SkillIDList) do
        _G.SelectTargetMgr:RemoveSkillTargetByResID(SkillID, ActorType, ResID)
    end
end

function TargetCastSkill:GetNpcID()
    return self.NpcID or 0
end

function TargetCastSkill:GetMonsterID()
    return self.MonsterID or 0
end

function TargetCastSkill:GetEObjID()
    return self.EObjID or 0
end

return TargetCastSkill