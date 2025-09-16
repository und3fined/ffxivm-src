---
--- Author: lydianwang
--- DateTime: 2022-05-30
---

local LuaClass = require("Core/LuaClass")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local QUEST_STATUS_NOT_STARTED = QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED
local QUEST_STATUS_IN_PROGRESS = QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS
local QUEST_STATUS_CAN_SUBMIT  = QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT
local QUEST_STATUS_FINISHED = QUEST_STATUS.CS_QUEST_STATUS_FINISHED
local QUEST_STATUS_FAILED = QUEST_STATUS.CS_QUEST_STATUS_FAILED
local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local QUEST_TYPE = ProtoRes.QUEST_TYPE

local QuestMgr = nil
local QuestRegister = nil

local StatusChangeFunc = {}
local function AddStatusChangeFunc(OldStatus, NewStatus, Func)
    StatusChangeFunc[OldStatus][NewStatus] = Func
end

for _, OldStatus in pairs(CHAPTER_STATUS) do
    StatusChangeFunc[OldStatus] = {} -- CHAPTER_STATUS从1起，最后只会保留table数组部分
end

---@class Chapter
local Chapter = LuaClass()

-- ==================================================
-- 玩家实际体验到的任务，由一系列Quest节点组成。
-- 名字源于任务编辑器
-- ==================================================

function Chapter:Ctor(ChapterID, Cfg)
    self.ChapterID = ChapterID
    self.Cfg = Cfg

    self.CurrQuestID = nil
    self.Status = CHAPTER_STATUS.NOT_STARTED
    self.SubmitTime = nil

    QuestMgr = _G.QuestMgr
    QuestRegister = QuestMgr.QuestRegister
end

function Chapter:InitEndChapterStatus(EndQuestID, EndQuestStatus, EndQuestTime)
    if EndQuestID == self.Cfg.EndQuest then
        if EndQuestStatus == QUEST_STATUS_FINISHED then
            self.Status = CHAPTER_STATUS.FINISHED
            self.SubmitTime = EndQuestTime
        elseif EndQuestStatus == QUEST_STATUS_FAILED then
            self.Status = CHAPTER_STATUS.FAILED
        end
    end
    self.CurrQuestID = self.Cfg.EndQuest
    _G.QuestMainVM:AddEndChapterVM(self.ChapterID)
end

---@param UpdatedQuest Quest
function Chapter:InitChapterStatus(UpdatedQuest)
    local NewStatus = self:MakeChapterStatus(UpdatedQuest)
    if NewStatus == nil then
        QuestHelper.PrintQuestError("InitChapterStatus() Failed on chapter #%d", self.ChapterID)
        return
    end
    self.CurrQuestID = UpdatedQuest.QuestID
    self.Status = NewStatus
end

---@param UpdatedQuest Quest
function Chapter:UpdateStatusByQuest(UpdatedQuest)
    if (UpdatedQuest == nil) then
        QuestHelper.PrintQuestError("UpdateStatusByQuest failed, UpdateQuest param is nil!")
        return
    end

    local NewStatus = self:MakeChapterStatus(UpdatedQuest)
    self:UpdateStatus(NewStatus, UpdatedQuest.QuestID, UpdatedQuest.IsTargetChanged)
end

---@param NewStatus CHAPTER_STATUS
---@param CurrQuestID int32
function Chapter:UpdateStatus(NewStatus, CurrQuestID, IsTargetChanged)
    if NewStatus == nil then
        QuestHelper.PrintQuestError("UpdateStatus() Failed on chapter #%d", self.ChapterID)
        return
    end

    local StChangeParams = {
        OldStatus = self.Status,
        NewStatus = NewStatus,
        IsTargetChanged = IsTargetChanged
    }
    QuestMgr:AddChapterStatusChange(self.ChapterID, StChangeParams)

    local Func = StatusChangeFunc[self.Status][NewStatus]
    self.CurrQuestID = CurrQuestID
    self.Status = NewStatus
    if Func then Func(self) end
end

-- ==================================================
-- 状态变化逻辑
-- ==================================================

function Chapter:Accept()
    if self.Cfg.ProfessionFixed == 1 then
        QuestRegister:RegisterFixedProf(self.ChapterID)
    end
    QuestMgr.OfferSequenceCollector:RemoveOfferSequence(self.ChapterID)
end

function Chapter:ImmediateCanSubmit()
    self:Accept()
end

function Chapter:UpdateProgress()
end

function Chapter:CanSubmit()
end

function Chapter:Finish()
    self.SubmitTime = QuestMgr.EndChapterSubmitTimeMap[self.ChapterID]

    local QuestGenreID = self.Cfg.QuestGenreID or 0
    local QuestType = QuestGenreID // 10000 - 1
    if QuestType <= QUEST_TYPE.QUEST_TYPE_BRANCH then --其他类型任务不记录完成任务
        QuestMgr.EndChapterMap[self.ChapterID] = self
    end

    QuestMgr:AddChapterPendingToRemove(self.ChapterID)
    QuestRegister:OnRemoveQuest(self.Cfg.QuestGenreID)

    if self.Cfg.ProfessionFixed == 1 then
        QuestRegister:UnRegisterFixedProf(self.ChapterID)
    end

    _G.TravelLogMgr:AddFinishChapter(self.ChapterID)
end

function Chapter:Remove()
    QuestMgr.EndChapterMap[self.ChapterID] = nil

    QuestMgr:AddChapterPendingToRemove(self.ChapterID)
    QuestRegister:OnRemoveQuest(self.Cfg.QuestGenreID)

    if self.Cfg.ProfessionFixed == 1 then
        QuestRegister:UnRegisterFixedProf(self.ChapterID)
    end
end

AddStatusChangeFunc(CHAPTER_STATUS.NOT_STARTED, CHAPTER_STATUS.IN_PROGRESS, Chapter.Accept)
AddStatusChangeFunc(CHAPTER_STATUS.NOT_STARTED, CHAPTER_STATUS.CAN_SUBMIT, Chapter.ImmediateCanSubmit)
AddStatusChangeFunc(CHAPTER_STATUS.NOT_STARTED, CHAPTER_STATUS.FINISHED, Chapter.Finish)

AddStatusChangeFunc(CHAPTER_STATUS.IN_PROGRESS, CHAPTER_STATUS.NOT_STARTED, Chapter.Remove)
AddStatusChangeFunc(CHAPTER_STATUS.IN_PROGRESS, CHAPTER_STATUS.IN_PROGRESS, Chapter.UpdateProgress)
AddStatusChangeFunc(CHAPTER_STATUS.IN_PROGRESS, CHAPTER_STATUS.CAN_SUBMIT, Chapter.CanSubmit)
AddStatusChangeFunc(CHAPTER_STATUS.IN_PROGRESS, CHAPTER_STATUS.FINISHED, Chapter.Finish)

AddStatusChangeFunc(CHAPTER_STATUS.CAN_SUBMIT, CHAPTER_STATUS.NOT_STARTED, Chapter.Remove)
AddStatusChangeFunc(CHAPTER_STATUS.CAN_SUBMIT, CHAPTER_STATUS.IN_PROGRESS, Chapter.UpdateProgress)
AddStatusChangeFunc(CHAPTER_STATUS.CAN_SUBMIT, CHAPTER_STATUS.FINISHED, Chapter.Finish)

AddStatusChangeFunc(CHAPTER_STATUS.FINISHED, CHAPTER_STATUS.NOT_STARTED, Chapter.Remove)

-- ==================================================
-- 其他
-- ==================================================

---@param Quest Quest
---@return CHAPTER_STATUS
function Chapter:MakeChapterStatus(Quest)
    if Quest == nil then return nil end
    local NewStatus = nil
    local QuestID = Quest.QuestID
    local QuestStatus = Quest.Status

    -- TODO[lydianwang]: 需要增加失败规则

    local function CanChapterSubmit()
        -- 调用时已保证(QuestID == self.Cfg.EndQuest)
        return (QuestStatus == QUEST_STATUS_CAN_SUBMIT) or (
            (QuestStatus == QUEST_STATUS_IN_PROGRESS)
            and (Quest.Cfg.IsAutoFinish == 1)
            and Quest:IsOneDisplayTarget()
        )
    end

    if self.Cfg.StartQuest == self.Cfg.EndQuest
    and QuestID == self.Cfg.StartQuest then
        if CanChapterSubmit() then
            NewStatus = CHAPTER_STATUS.CAN_SUBMIT

        else
            -- 为了方便，采用这种换算，要求CHAPTER_STATUS和QUEST_STATUS严格对应
            NewStatus = Quest.Status + 1
        end

    elseif QuestID == self.Cfg.EndQuest then
        if CanChapterSubmit() then
            NewStatus = CHAPTER_STATUS.CAN_SUBMIT

        elseif QuestStatus == QUEST_STATUS_FINISHED then
            NewStatus = CHAPTER_STATUS.FINISHED

        else
            NewStatus = CHAPTER_STATUS.IN_PROGRESS
        end

    elseif QuestID == self.Cfg.StartQuest then
        if QuestStatus == QUEST_STATUS_NOT_STARTED then
            NewStatus = CHAPTER_STATUS.NOT_STARTED

        else
            NewStatus = CHAPTER_STATUS.IN_PROGRESS
        end

    elseif Quest.ChapterID == self.ChapterID then
        NewStatus = CHAPTER_STATUS.IN_PROGRESS
    end

    return NewStatus
end

return Chapter