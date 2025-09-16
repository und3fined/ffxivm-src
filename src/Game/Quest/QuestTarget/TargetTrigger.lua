---
--- Author: lydianwang
--- DateTime: 2021-12-27
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local ProtoRes = require("Protocol/ProtoRes")

local MajorUtil = require("Utils/MajorUtil")

local QuestMgr = nil

local TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE

---@class TargetTrigger
local TargetTrigger = LuaClass(TargetBase, true)

function TargetTrigger:Ctor(_, Properties)
    self.AreaID = tonumber(Properties[1])
    self.MapID = tonumber(Properties[2])

    self.bRevertMark = false

    QuestMgr = _G.QuestMgr
end

function TargetTrigger:DoStartTarget(bRevert)
    if bRevert then
        self.bRevertMark = true
    end
    self:RegisterEvent(_G.EventID.AreaTriggerBeginOverlap, self.OnEnterTrigger)
    self:RegisterEvent(_G.EventID.AreaTriggerEndOverlap, self.OnLeaveTrigger)
    QuestMgr.QuestRegister:RegisterQuestTrigger(self.MapID, self.AreaID)

    if self.Cfg then
        local NextTargetCfg = QuestHelper.GetTargetCfgItem(self.QuestID, self.Cfg.NextTarget)
        if NextTargetCfg then
            --满足 (触怪圈)-杀怪-交互 组合,增强目标感
            if NextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_CREATE_KILL_ENEMY then
                local NextNextTargetCfg = QuestHelper.GetTargetCfgItem(self.QuestID, NextTargetCfg.NextTarget)
                if NextNextTargetCfg then
                    if NextNextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT
                        or NextNextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_DIALOG then
                        self.NpcID = tonumber(NextNextTargetCfg.Properties[1])
                        self.EObjID = tonumber(NextNextTargetCfg.Properties[4])
                    end
                end
            end
             --满足 (触怪圈)-交互-杀怪 组合,增强目标感
            if NextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT
                or NextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_DIALOG then
                local NextNextTargetCfg = QuestHelper.GetTargetCfgItem(self.QuestID, NextTargetCfg.NextTarget)
                if NextNextTargetCfg then
                    if NextNextTargetCfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_CREATE_KILL_ENEMY then
                        self.NpcID = tonumber(NextTargetCfg.Properties[1])
                        self.EObjID = tonumber(NextTargetCfg.Properties[4])
                    end
                end
            end
        end
    end
end

function TargetTrigger:DoClearTarget()
    QuestMgr.QuestRegister:UnRegisterQuestTrigger(self.MapID, self.AreaID)
end

function TargetTrigger:OnEnterTrigger(EventParam)
    local bReverted = self.bRevertMark
    self.bRevertMark = false
    if EventParam.bTriggeredOnCreate and bReverted then
        -- 回退此目标会重新创建触发器，创建时会触发一次
        -- 如果不忽略这次触发，会有反复回退反复触发的问题
        return
    end

    if EventParam.AreaID ~= self.AreaID then
        return
    end

    if self.MapID ~= _G.PWorldMgr:GetCurrMapResID() then
        return
    end

    if not QuestHelper.CheckCanProceed(self.QuestID) then
        _G.GMMgr:MajorIdle()
        QuestHelper.PlayRestrictedDialog(self.QuestID, self.TargetID)
        return
    end

    -- 进入任务触发器先同步一次位置
    MajorUtil.SyncSelfMoveReq(false)

    if _G.MountMgr:IsInRide() then
        local NextTarget = self:GetNextTarget()
        local bMountCancel = NextTarget and QuestHelper.CheckTargetPlaySeq(NextTarget)
        if bMountCancel then
            local MountCancelCallback = function()
                QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
            end
            _G.MountMgr:SendMountCancelCall(MountCancelCallback, true)
            return
        end
    end

    QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
end

function TargetTrigger:OnLeaveTrigger(EventParam)
    if EventParam.AreaID == self.AreaID then
        if self.MapID ~= _G.PWorldMgr:GetCurrMapResID() then
            return
        end
        self.bRevertMark = false
    end
end

function TargetTrigger:GetNpcID()
    return self.NpcID or 0
end

function TargetTrigger:GetEObjID()
    return self.EObjID or 0
end

return TargetTrigger