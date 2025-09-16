---
--- Author: lydianwang
--- DateTime: 2021-10-22
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local ProtoRes = require("Protocol/ProtoRes")

local TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE

---@class TargetCreateKillEnemy
local TargetCreateKillEnemy = LuaClass(TargetBase, true)

function TargetCreateKillEnemy:Ctor(_, Properties)
    self.MonsterIDList = {}
    local MonsterIDStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(MonsterIDStrList) do
        table.insert(self.MonsterIDList, tonumber(Str))
    end

    -- 策划保证此节点一定会放在组合目标中，无需显示计数
    -- local MaxCountStrList = string.split(Properties[2], "|")

    -- local PointIDStrList = string.split(Properties[3], "|")
    -- self.RangeCM = tonumber(Properties[4])
end

function TargetCreateKillEnemy:GetMonsterIDList()
    return self.MonsterIDList
end

function TargetCreateKillEnemy:DoStartTarget()
    if self.Cfg then
        local PrevTargetCfg = QuestHelper.GetTargetCfgItem(self.QuestID, self.Cfg.PrevTarget)
        if PrevTargetCfg then
            --满足触怪圈-(创怪杀怪)-交互 组合,增强目标感
            if PrevTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_TRIGGER then
                local NextTargetCfg = QuestHelper.GetTargetCfgItem(self.QuestID, self.Cfg.NextTarget)
                if NextTargetCfg then
                    if NextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT
                        or NextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_DIALOG then
                        self.NpcID = tonumber(NextTargetCfg.Properties[1])
                        self.EObjID = tonumber(NextTargetCfg.Properties[4])
                    end
                end
            end
            --满足触怪圈-交互-(创怪杀怪) 组合,增强目标感
            if PrevTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT
                or PrevTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_DIALOG then
                local PrevPrevTargetCfg = QuestHelper.GetTargetCfgItem(self.QuestID, PrevTargetCfg.PrevTarget)
                if PrevPrevTargetCfg then
                    if PrevPrevTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_TRIGGER then
                        self.NpcID = tonumber(PrevTargetCfg.Properties[1])
                        self.EObjID = tonumber(PrevTargetCfg.Properties[4])
                    end
                end
            end
        end
     end
end

function TargetCreateKillEnemy:GetNpcID()
    return self.NpcID or 0
end

function TargetCreateKillEnemy:GetEObjID()
    return self.EObjID or 0
end

return TargetCreateKillEnemy