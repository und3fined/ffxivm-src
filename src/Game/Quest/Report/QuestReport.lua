---
--- Author: sammrli
--- DateTime: 2024-10-15
--- Description:任务流水上报
---

local LuaClass = require("Core/LuaClass")

local QuestHelper = require("Game/Quest/QuestHelper")
local DataReportUtil = require("Utils/DataReportUtil")

local SaveKey = require("Define/SaveKey")

local UE = _G.UE

local QuestSourceType =
{
    Npc = 1,        --Npc
    Recommend = 2,  --推荐
    Functional = 3, --职能
}

local QuestReport = LuaClass()

function QuestReport:Ctor()
    self:InitSaveData()
end

function QuestReport:InitSaveData()
    self.SaveStr = UE.USaveMgr.GetString(SaveKey.SetMarkFollowRecord, "", true)
    self.Markers = string.split(self.SaveStr, ',')
end

function QuestReport:MarkFollowQuestID(QuestID)
    if QuestID == 0 then
        return
    end
    if not self:IsCondition(QuestID) then --不是目标任务
        return
    end
    local IDString = tostring(QuestID)
    for i=1,#self.Markers do
        if IDString == self.Markers[i] then
            return
        end
    end
    table.insert(self.Markers, IDString)
    self.SaveStr = self.SaveStr..IDString..","
    UE.USaveMgr.SetString(SaveKey.SetMarkFollowRecord, self.SaveStr, true)
end

function QuestReport:UnMarkFollowQuestID(Index)
    table.remove(self.Markers, Index)
    self.SaveStr = ""
    for i=1, #self.Markers do
        self.SaveStr = self.SaveStr..tostring(self.Markers[i])..","
    end
    UE.USaveMgr.SetString(SaveKey.SetMarkFollowRecord, self.SaveStr, true)
end

---是否满足条件(推进任务或职业任务)
---@param QuestID number
---@return boolean
function QuestReport:IsCondition(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem then
        local ChapterID = QuestCfgItem.ChapterID
        local RecommendCfgIDList = _G.AdventureRecommendTaskMgr.RecommendCfgIDList
        if RecommendCfgIDList and table.contain(RecommendCfgIDList, ChapterID) then
            return true
        end
        local CareerChapterCfg = _G.AdventureCareerMgr:GetChapterCfgData(ChapterID)
        if CareerChapterCfg then
            return true
        end
    end
    return false
end

function QuestReport:GetRecieveType(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem then
        local ChapterID = QuestCfgItem.ChapterID
        local RecommendCfgIDList = _G.AdventureRecommendTaskMgr.RecommendCfgIDList
        if RecommendCfgIDList and table.contain(RecommendCfgIDList, ChapterID) then
            return QuestSourceType.Recommend
        end
    end
    return QuestSourceType.Functional
end

function QuestReport:ReportAccept(QuestID)
    local IDString = tostring(QuestID)
    for i=1,#self.Markers do
        if IDString == self.Markers[i] then
            local SourceType = self:GetRecieveType(QuestID)
            DataReportUtil.ReportQuestRecieveFlowData(QuestID, SourceType)
            self:UnMarkFollowQuestID(i)
            return
        end
    end
    DataReportUtil.ReportQuestRecieveFlowData(QuestID, QuestSourceType.Npc)
end

-- ==================================================
-- 任务追踪流水
-- ==================================================

--TaskTrackingType
--1-通过跨地图追踪标进入地图快捷传送界面，2-点击弹出的触发替换追踪，3-点击主线追踪进行任务追踪刷新
function QuestReport:ReportTaskTracking(TaskID, TaskChapterID, TaskSortID, TaskTrackingType)
    DataReportUtil.ReportData("TaskTrackingFlow", true, false, true,
        "TaskID", tostring(TaskID),
        "TaskChapterID", tostring(TaskChapterID),
        "TaskSortID", tostring(TaskSortID),
        "TaskTrackingType", tostring(TaskTrackingType or 1))
    --FLOG_ERROR(string.format("[Report]TaskTrackingFlow TaskID=%s ChapterID=%s SortID=%s Type=%s", tostring(TaskID), tostring(TaskChapterID),tostring(TaskSortID), tostring(TaskTrackingType)))
end

function QuestReport:ReportReplaceTaskTracking(ChapterID)
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
    if ChapterCfgItem then
        self:ReportTaskTracking(ChapterCfgItem.StartQuest, ChapterID,  ChapterCfgItem.QuestGenreID, 2)
    end
end

function QuestReport:ReportChangeTaskTracking(ChapterID)
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
    if ChapterCfgItem then
        self:ReportTaskTracking(ChapterCfgItem.StartQuest, ChapterID,  ChapterCfgItem.QuestGenreID, 3)
    end
end

-- ==================================================
-- 跨图任务流水
-- ==================================================
local function ReportCrossTask(TaskID, TaskChapterID, TaskSortID, Result)
    DataReportUtil.ReportData("CrossTaskFlow", true, false, true,
        "TaskID", tostring(TaskID),
        "TaskChapterID", tostring(TaskChapterID),
        "TaskSortID", tostring(TaskSortID),
        "Result", tostring(Result))
    --FLOG_ERROR(string.format("[Report]CrossTaskFlow TaskID=%s ChapterID=%s SortID=%s Result=%s", tostring(TaskID), tostring(TaskChapterID),tostring(TaskSortID), tostring(Result)))
end

function QuestReport:RecordCrossTask(QuestID, ChapterID, GenreID)
    if not QuestID then
        self.CrossTaskRecord = nil
        return
    end
    local Record =
    {
        TaskID = QuestID,
        TaskChapterID = ChapterID,
        TaskSortID = GenreID
    }
    self.CrossTaskRecord = Record
end

function QuestReport:DeleteCrossTask()
    if self.CrossTaskRecord then
        local Record = self.CrossTaskRecord
        ReportCrossTask(Record.TaskID, Record.TaskChapterID, Record.TaskSortID, 0)
    end
    self.CrossTaskRecord = nil
end

function QuestReport:ReportCrossTask()
    if not self.CrossTaskRecord then
        return
    end
    local Record = self.CrossTaskRecord
    ReportCrossTask(Record.TaskID, Record.TaskChapterID, Record.TaskSortID, 1)
    self.CrossTaskRecord = nil --置空,避免DeleteRecord时上报不追踪流水
end

-- ==================================================
-- 任务日志流水
-- ==================================================

---任务日志流水上报
---ReportTaskLog
---@param OpType nunber@1=点击追踪按钮 2=取消追踪按钮 3=目标定位按钮进入地图 4=放弃按钮 5=查看已完成日志 6=成功搜索 7=成功筛选 8=点击地图任务列表
---@param TaskID number
---@param TaskChapterID number
---@param Arg1 number
function QuestReport:ReportTaskLog(OpType, TaskID, TaskChapterID, Arg1)
    if not TaskChapterID then
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(TaskID)
        if QuestCfgItem then
            TaskChapterID = QuestCfgItem.ChapterID
        end
    end
    local TaskSortID = nil
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(TaskChapterID)
    if ChapterCfgItem then
        TaskSortID = ChapterCfgItem.QuestGenreID
    end
    DataReportUtil.ReportData("TaskLogFlow", true, false, true,
        "OpType", tostring(OpType),
        "TaskID", tostring(TaskID),
        "TaskChapterID", tostring(TaskChapterID),
        "TaskSortID", tostring(TaskSortID),
        "Arg1", tostring(Arg1))
end

return QuestReport