---
--- Author: lydianwang
--- DateTime: 2021-10-22
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local QuestHelper = require("Game/Quest/QuestHelper")

local ProtoRes = require("Protocol/ProtoRes")
local CONNECT_TYPE = ProtoRes.target_connect_type

local QuestRegister = nil

---@class TargetFinishDialog
local TargetFinishDialog = LuaClass(TargetBase, true)

function TargetFinishDialog:Ctor(_, Properties)
    self.NpcID = tonumber(Properties[1])
    self.DialogID = tonumber(Properties[2])
    self.EObjID = tonumber(Properties[3])

    self.bAutoDone = false

    QuestRegister = _G.QuestMgr.QuestRegister
end

function TargetFinishDialog:DoStartTarget()
    local DialogID = self:GetDialogID()
    if DialogID ~= 0 then
        local NextTarget = self:GetNextTarget()
        if (NextTarget and QuestHelper.CheckTargetPlaySeq(NextTarget))
        or self.bTeleportAfterTarget then
            QuestRegister:RegisterBlackScreenOnStopDialogOrSeq(DialogID)
        end
        if QuestHelper.CheckTeleportAfterContinuousSequence(self) then
            QuestRegister:RegisterTeleportAfterSequence(DialogID)
        end
    end
end

function TargetFinishDialog:PostStartTarget()
    if (self.Cfg.ConnectType == CONNECT_TYPE.COMBINED)
    and (self.Cfg.PrevTarget > 0) then
        self:AutoDoTarget()
    end
end

function TargetFinishDialog:DoClearTarget()
    self.bAutoDone = false

    local DialogID = self:GetDialogID()
    if DialogID ~= 0 then
        QuestRegister:UnRegisterBlackScreenOnStopDialogOrSeq(DialogID)
        QuestRegister:UnRegisterTeleportAfterSequence(DialogID)
    end
end

function TargetFinishDialog:AutoDoTarget()
    if self.bAutoDone then return end
    self.bAutoDone = true

    if self.NpcID > 0 then
        QuestHelper.AutoNPCDialog(self.QuestID, self.TargetID, self.NpcID, self.DialogID)
    elseif self.EObjID > 0 then
        QuestHelper.AutoEObjDialog(self.QuestID, self.TargetID, self.EObjID, self.DialogID)
    end
end

function TargetFinishDialog:GetNpcID()
    return self.NpcID or 0
end

function TargetFinishDialog:GetEObjID()
    return self.EObjID or 0
end

function TargetFinishDialog:GetDialogID()
    return self.DialogID or 0
end

---先只处理TargetFinishSequence的连续播放
function TargetFinishDialog:PreprocessTarget(PreSequenceID)
end

return TargetFinishDialog