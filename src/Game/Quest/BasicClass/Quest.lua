---
--- Author: lydianwang
--- DateTime: 2022-05-30
---

local LuaClass = require("Core/LuaClass")
local QuestHelper = require("Game/Quest/QuestHelper")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local CONNECT_TYPE = ProtoRes.target_connect_type
local QUEST_STATUS =    ProtoCS.CS_QUEST_STATUS

local STATUS_NOT_STARTED = QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED
local STATUS_IN_PROGRESS = QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS
local STATUS_CAN_SUBMIT  = QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT
local STATUS_FINISHED    = QUEST_STATUS.CS_QUEST_STATUS_FINISHED
-- local STATUS_FAILED      = QUEST_STATUS.CS_QUEST_STATUS_FAILED

local QuestMgr = nil

local StatusChangeFunc = {}
local function AddStatusChangeFunc(OldStatus, NewStatus, Func)
    StatusChangeFunc[OldStatus + 1][NewStatus + 1] = Func
end

for _, OldStatus in pairs(QUEST_STATUS) do
    StatusChangeFunc[OldStatus + 1] = {} -- QUEST_STATUS从0起，此处改为从1起，避免table保留哈希表
end

-- ==================================================
-- 由诸多配置项和Target节点组成。
-- ==================================================

---@class Quest
local Quest = LuaClass()

function Quest:Ctor(QuestID, Cfg)
    self.QuestID = QuestID
    self.Cfg = Cfg

    self.ChapterID = self.Cfg.ChapterID
    self.AcceptTimeMS = 0
    self.Status = STATUS_NOT_STARTED

    self.Targets = {}
    self.AcceptClientBehavior = {}
    self.FinishClientBehavior = {}
    self.StateRestrictions = {}
    self.FaultTolerants = {}
    self.IsTargetChanged = false

    self.HintTalkNpcs = {}
    self.HintTalkEObjs = {}

    QuestMgr = _G.QuestMgr
end

function Quest:UpdateTargetStatus(IsTargetChanged)
    self.IsTargetChanged = IsTargetChanged
end

function Quest:UpdateStatus(NewStatus)
    local Func = StatusChangeFunc[self.Status + 1][NewStatus + 1]
    self.Status = NewStatus
    if Func then Func(self) end
end

-- ==================================================
-- 任务状态变化逻辑
-- ==================================================

function Quest:Accept()
    -- QuestHelper.PrintQuestInfo("Accept quest #%d", self.QuestID)
    for _, Behavior in pairs(self.AcceptClientBehavior) do
        Behavior:StartBehavior()
    end
    QuestHelper.RemoveNpcActivatedQuest(self.Cfg)
    -- 反注册互斥、相同任务在OnQuestConditionUpdate()执行
end

function Quest:ImmediateCanSubmit()
    self:Accept()
    self:CanSubmit()
end

function Quest:ImmediateFinish()
    self:Accept()
    self:AutoFinish()
end

function Quest:UpdateProgress()
    -- QuestHelper.PrintQuestInfo("Update quest #%d progress", self.QuestID)
end

function Quest:CanSubmit()
    QuestHelper.PrintQuestInfo("Can submit quest #%d", self.QuestID)

    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(self.Cfg.ChapterID)
    -- 最后一个任务节点配置【自动提交】时，后台只会下发可提交，前台播完UI主动上报提交
    if (ChapterCfgItem ~= nil)
    and (self.QuestID == ChapterCfgItem.EndQuest)
    and (self.Cfg.IsAutoFinish == 1) then
        QuestHelper.PreFinish(self.QuestID, nil)
        return
    end

    if self.Cfg.FinishNpc ~= 0 then
        QuestHelper.AddNpcCanSubmitQuest(self.Cfg)
    end

    -- 处理提交前自动对话
    if QuestHelper.CheckAutoDialogSubmit(self.Cfg) then
        QuestHelper.AutoNPCDialog(self.QuestID, nil, self.Cfg.FinishNpc, self.Cfg.FinishDialogID)
    end
end

function Quest:AutoFinish()
    QuestHelper.PrintQuestInfo("Auto finish quest #%d", self.QuestID)
    self:DoFinish()
end

function Quest:Finish()
    QuestHelper.PrintQuestInfo("Finish quest #%d", self.QuestID)
    self:DoFinish()
end

function Quest:DoFinish()
    QuestMgr:AddQuestPendingToRemove(self.QuestID, self.ChapterID)

    for _, StateRestriction in pairs(self.StateRestrictions) do
        StateRestriction:ClearRestriction()
    end

    for _, Behavior in pairs(self.FinishClientBehavior) do
        Behavior:StartBehavior()
    end

    for _, FaultTolerant in pairs(self.FaultTolerants) do
        FaultTolerant:ClearFaultTolerant()
    end

    QuestHelper.RemoveNpcActivatedQuest(self.Cfg)
    QuestHelper.RemoveNpcCanSubmitQuest(self.Cfg)

    local Chapter = QuestMgr.ChapterMap[self.ChapterID]
    if Chapter and QuestHelper.CheckCanReactivate(self.QuestID, self.Cfg, Chapter.Cfg) then
        QuestHelper.ActivateQuest(self.Cfg, Chapter.Cfg)
    end

    -- 注册相同任务
    self:AddAffectedNpcSameQuest()

    -- 任务完成后检查一下是否有任务奖励
    QuestHelper.CheckBagLeftNum(self.Cfg)

    self:ClearHintTalk()
end

function Quest:Remove()
    QuestHelper.PrintQuestInfo("Remove quest #%d", self.QuestID)
    QuestMgr:AddQuestPendingToRemove(self.QuestID, self.ChapterID)

    for _, Target in pairs(self.Targets) do
        Target:ClearTarget()
    end
    for _, StateRestriction in pairs(self.StateRestrictions) do
        StateRestriction:ClearRestriction()
    end
    for _, FaultTolerant in pairs(self.FaultTolerants) do
        FaultTolerant:ClearFaultTolerant()
    end

    QuestHelper.RemoveNpcActivatedQuest(self.Cfg)
    QuestHelper.RemoveNpcCanSubmitQuest(self.Cfg)

    -- 注册互斥&相同任务
    self:AddAffectedNpcExclusiveQuest()
    self:AddAffectedNpcSameQuest()

    self:ClearHintTalk()
end

AddStatusChangeFunc(STATUS_NOT_STARTED, STATUS_IN_PROGRESS, Quest.Accept)
AddStatusChangeFunc(STATUS_NOT_STARTED, STATUS_CAN_SUBMIT, Quest.ImmediateCanSubmit)
AddStatusChangeFunc(STATUS_NOT_STARTED, STATUS_FINISHED, Quest.ImmediateFinish)

AddStatusChangeFunc(STATUS_IN_PROGRESS, STATUS_NOT_STARTED, Quest.Remove)
AddStatusChangeFunc(STATUS_IN_PROGRESS, STATUS_IN_PROGRESS, Quest.UpdateProgress)
AddStatusChangeFunc(STATUS_IN_PROGRESS, STATUS_CAN_SUBMIT, Quest.CanSubmit)
AddStatusChangeFunc(STATUS_IN_PROGRESS, STATUS_FINISHED, Quest.AutoFinish)

AddStatusChangeFunc(STATUS_CAN_SUBMIT, STATUS_NOT_STARTED, Quest.Remove)
AddStatusChangeFunc(STATUS_CAN_SUBMIT, STATUS_IN_PROGRESS, Quest.UpdateProgress)
AddStatusChangeFunc(STATUS_CAN_SUBMIT, STATUS_FINISHED, Quest.Finish)

-- ==================================================
-- 其他
-- ==================================================

---更新NPC身上的互斥任务
---@param QuestID int32
function Quest:AddAffectedNpcExclusiveQuest()
    local ExclusiveQuestIDs = QuestMgr.QuestRegister.AffectedExclusiveQuest[self.QuestID]
    if ExclusiveQuestIDs == nil then return end

    for _, ExclusiveQuestID in ipairs(ExclusiveQuestIDs) do
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(ExclusiveQuestID)
        local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
        QuestMgr.TryActivateQuest(QuestCfgItem, ChapterCfgItem)
    end
end

---更新NPC身上的相同任务
---@param QuestID int32
function Quest:AddAffectedNpcSameQuest()
    local SameQuestIDs = QuestMgr.QuestRegister.AffectedSameQuest[self.QuestID]
    if SameQuestIDs == nil then return end

    for _, SameQuestID in ipairs(SameQuestIDs) do
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(SameQuestID)
        local ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
        QuestMgr.TryActivateQuest(QuestCfgItem, ChapterCfgItem)
    end
end

---任务节点里是否只有一个目标（包括组合目标）（不包括连续目标）
---@param QuestID int32
function Quest:IsOneDisplayTarget()
    if #(self.Cfg.TargetParamID or {}) == 1 then return true end

    local FirstSubTargetNum = 0
    for _, Target in pairs(self.Targets) do
        if (Target.Cfg.ConnectType ~= CONNECT_TYPE.COMBINED) then return false end
        if (Target.Cfg.PrevTarget == -1) then
            FirstSubTargetNum = FirstSubTargetNum + 1
        end
    end

    return (FirstSubTargetNum == 1)
end

function Quest:ClearHintTalk()
    for _, NpcID in ipairs(self.HintTalkNpcs) do
        QuestMgr.QuestRegister:SetHintTalk(NpcID, nil)
    end
    for _, EObjID in ipairs(self.HintTalkEObjs) do
        QuestMgr.QuestRegister:SetHintTalk(nil, EObjID)
    end
    self.HintTalkNpcs = {}
    self.HintTalkEObjs = {}
end

return Quest
