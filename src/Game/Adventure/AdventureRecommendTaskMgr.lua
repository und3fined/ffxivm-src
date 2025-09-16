--
--Author: ds_jan
--Date: 2024-06-06 11:30:29
--Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local QuestMgr = require("Game/Quest/QuestMgr")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local ActorMgr = require("Game/Actor/ActorMgr")
local MajorUtil = require("Utils/MajorUtil")
local QuestDefine = require("Game/Quest/QuestDefine")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local RecommendQuestCfg = require("TableCfg/RecommendQuestCfg")
local ProfClassCfg = require("TableCfg/ProfClassCfg")
local SaveKey = require("Define/SaveKey")
local Json = require("Core/Json")
local USaveMgr = _G.UE.USaveMgr
local CommonUtil = require("Utils/CommonUtil")
local TimeUtil = require("Utils/TimeUtil")
local QuestHelper = require("Game/Quest/QuestHelper")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local CHAPTER_STATUS =  QuestDefine.CHAPTER_STATUS
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local ProtoCommon = require("Protocol/ProtoCommon")

---@class AdventureRecommendTaskMgr : MgrBase
local AdventureRecommendTaskMgr = LuaClass(MgrBase)

---OnInit
function AdventureRecommendTaskMgr:OnInit()
    self.RecommendCfgIDList = {}

    self.RecommendTask = {}
	self.GameRecommendTask = {}
    self.BattleRecommendTask = {}
    self.MazeRecommendTask = {}

    self.GameRecommendTaskRedList = {}
    self.BattleRecommendTaskRedList = {}
    self.HugeRecommendTaskRedList = {}
    self.MazeRecommendTaskRedList = {}
    self.HasNewTips = false
end

---OnBegin
function AdventureRecommendTaskMgr:OnBegin()
end

function AdventureRecommendTaskMgr:OnEnd()
end

function AdventureRecommendTaskMgr:OnShutdown()
    self.RecommendCfgIDList = {}
    self.RecommendTask = {}
	self.GameRecommendTask = {}
    self.BattleRecommendTask = {}
    self.HugeRecommendTask = {}
    self.GameRecommendTaskRedList = {}
    self.BattleRecommendTaskRedList = {}
    self.HugeRecommendTaskRedList = {}
    self.HasNewTips = false
end

function AdventureRecommendTaskMgr:OnRegisterNetMsg()
end

function AdventureRecommendTaskMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnRecommendTaskModuleOpen)
end

function AdventureRecommendTaskMgr:OnGameEventLoginRes()
    self:LoadCfg()
end

function AdventureRecommendTaskMgr:LoadCfg()
    if not table.is_nil_empty(self.RecommendCfgIDList) then
       return
    end
    local Cfgs = RecommendQuestCfg:FindAllCfg(string.format("ChapterID > 0"))

    for _, v in ipairs(Cfgs) do
        table.insert(self.RecommendCfgIDList, v.ChapterID)
    end
end

function AdventureRecommendTaskMgr:GetAllAdventureRecommendFinished()
    for _, chapterID in ipairs(self.RecommendCfgIDList) do
        local Cfg = QuestHelper.GetChapterCfgItem(chapterID)
        local RecommendTaskCfgs = RecommendQuestCfg:FindAllCfg(string.format("ChapterID = %d", chapterID))
        local RecommendTaskCfg = RecommendTaskCfgs[1]
        if RecommendTaskCfg ~= nil and Cfg ~= nil and Cfg.EndQuest ~= nil then
            if not self:CheckUpTime(RecommendTaskCfg.UpTime) or not self:CheckVersion(Cfg.VersionName) then
                return false
            end
            local FinisihedQuestCfg = QuestHelper.GetQuestCfgItem(Cfg.EndQuest)
            if FinisihedQuestCfg ~= nil and FinisihedQuestCfg.id ~= nil then
                local FinishedStatus = QuestMgr:GetQuestStatus(FinisihedQuestCfg.id)
                if FinishedStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                    return false
                end
            end
        end
    end
    return true
end

function AdventureRecommendTaskMgr:GetAdventureRecommendFinished(List)
    for _, chapterID in ipairs(List or {}) do
        local Cfg = QuestHelper.GetChapterCfgItem(chapterID)
        local RecommendTaskCfgs = RecommendQuestCfg:FindAllCfg(string.format("ChapterID = %d", chapterID))
        local RecommendTaskCfg = RecommendTaskCfgs[1]
        if RecommendTaskCfg ~= nil and Cfg ~= nil and Cfg.EndQuest ~= nil then
            if not self:CheckUpTime(RecommendTaskCfg.UpTime) or not self:CheckVersion(Cfg.VersionName) then
                return false
            end
            local FinisihedQuestCfg = QuestHelper.GetQuestCfgItem(Cfg.EndQuest)
            if FinisihedQuestCfg ~= nil and FinisihedQuestCfg.id ~= nil then
                local FinishedStatus = QuestMgr:GetQuestStatus(FinisihedQuestCfg.id)
                if FinishedStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                    return false
                end
            end
        end
    end
    return true
end


function AdventureRecommendTaskMgr:OnRecommendTaskModuleOpen(ModuleID)
    if ModuleID == ProtoCommon.ModuleID.ModuleIDAdviseTask then
        self:OnUpdateQuest()
    end
end

function AdventureRecommendTaskMgr:OnUpdateQuest(Params)
    local _ <close> = CommonUtil.MakeProfileTag(string.format("AdventureRecommendTaskMgr_OnUpdateQuest"))
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAdviseTask) then
        return 
    end

    local Table_Chapter_Status = self.Table_Chapter_Status or { CHAPTER_STATUS.NOT_STARTED, CHAPTER_STATUS.CAN_SUBMIT, CHAPTER_STATUS.IN_PROGRESS, CHAPTER_STATUS.FAILED }
    local Table_Remove_Chapter_Status = self.Table_Remove_Chapter_Status or { CHAPTER_STATUS.FINISHED }

    local currentRecommendTasks = {}
    for _, task in ipairs(self.RecommendTask) do
        currentRecommendTasks[task] = true
    end

    local allQuests = QuestMgr:GetChapterIDList(QUEST_TYPE.QUEST_TYPE_IMPORTANT, Table_Chapter_Status)
    local removeQuests = QuestMgr:GetChapterIDList(QUEST_TYPE.QUEST_TYPE_IMPORTANT, Table_Remove_Chapter_Status)

    local RecommendTaskNewStateTable = self:GetNewStateTable()
    local toRemove = {}  -- 使用哈希表加速删除操作
    local toAdd = {}     -- 使用哈希表记录待添加任务
    self.HasNewTips = false
    -- 处理需要移除的任务
    for _, chapterID in ipairs(removeQuests) do
        if currentRecommendTasks[chapterID] then
            toRemove[chapterID] = true
            RecommendTaskNewStateTable[tostring(chapterID)] = nil
        end
    end

    -- 处理需要添加的任务
    for _, quests in ipairs(allQuests) do
        for _, chapterID in pairs(quests) do
            if self:CheckRecommendTask(chapterID) and not currentRecommendTasks[chapterID] then
                local profLimit, levelLimit = self:GetProfLevelLimit(chapterID)
                if self:CheckCondition(profLimit, levelLimit) then
                    toAdd[chapterID] = true
                    if RecommendTaskNewStateTable[tostring(chapterID)] == nil then
                        self.HasNewTips = true
                        RecommendTaskNewStateTable[tostring(chapterID)] = true
                    end
                end
            end
        end
    end

    local newRecommendTasks = {}
    for _, task in ipairs(self.RecommendTask) do
        if not toRemove[task] then
            table.insert(newRecommendTasks, task)
        end
    end
    for task in pairs(toAdd) do
        table.insert(newRecommendTasks, task)
    end
    self.RecommendTask = newRecommendTasks

    local taskCategories = {
        [AdventureDefine.RecommendTasks.Game] = { list = {}, hasNew = false },
        [AdventureDefine.RecommendTasks.Battle] = { list = {}, hasNew = false },
        [AdventureDefine.RecommendTasks.Huge] = { list = {}, hasNew = false },
        [AdventureDefine.RecommendTasks.Maze] = { list = {}, hasNew = false }
    }

    for _, chapterID in ipairs(self.RecommendTask) do
        local Cfgs = RecommendQuestCfg:FindAllCfg(string.format("ChapterID = %d", chapterID))
        if Cfgs and #Cfgs > 0 and self:CheckGrandCompanyCondition(Cfgs) then
            local cfg = Cfgs[1]
            if cfg then
                local category = taskCategories[cfg.Type]
                if category then
                    table.insert(category.list, chapterID)
                    if RecommendTaskNewStateTable[tostring(chapterID)] then
                        -- 合并红点更新操作
                        category.hasNew = true
                        if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAdviseTask) then
                            self:AddRedDot(cfg.Type, chapterID, self:GetParentRedDotIDByType(cfg.Type))
                        end
                    else
                        self:DelRedDot(cfg.Type, chapterID)
                    end
                end
            end
        end
    end

    -- 批量设置页签红点
    for taskType, data in pairs(taskCategories) do
        self:SetTabRedDot(taskType, data.hasNew)
        if taskType == AdventureDefine.RecommendTasks.Game then
            self.GameRecommendTask = data.list
        elseif taskType ==  AdventureDefine.RecommendTasks.Battle then
            self.BattleRecommendTask =  data.list
        elseif taskType == AdventureDefine.RecommendTasks.Huge then
            self.HugeRecommendTask =  data.list
        elseif taskType == AdventureDefine.RecommendTasks.Maze then
            self.MazeRecommendTask =  data.list
        end
    end

    self:SaveNewStateTable(RecommendTaskNewStateTable)

    if self.HasNewTips and #self.RecommendTask > 0 then
        EventMgr:SendEvent(EventID.RecommendTaskNewTip)
    end
    EventMgr:SendEvent(EventID.RecommendTaskUpdate)

end

function AdventureRecommendTaskMgr:CheckCondition(ProfLimit, LevelLimit)
    if ProfLimit == nil or LevelLimit == nil then
        return false
    end

    local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()

    if ProfLimit == 0 then
        if  MajorRoleDetail ~= nil and MajorRoleDetail.Prof ~= nil then
            for _, ProfData in pairs(MajorRoleDetail.Prof.ProfList) do
                local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfData.ProfID) or 0
                if MajorLevel >= LevelLimit then
                    return true
                end
            end
            return false 
        end
    end

    local ProfCfg = ProfClassCfg:FindCfgByKey(ProfLimit)
    if ProfCfg == nil then
        return false
    end

    for _, ProfID in ipairs(ProfCfg.Prof) do
        local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID) or 0
        if MajorLevel >= LevelLimit then
            return true
        end
    end

    return false

end

function AdventureRecommendTaskMgr:CheckGrandCompanyCondition(Cfg)
    local CompoanySealInfo = _G.CompanySealMgr:GetCompanySealInfo()
    local CurGrandCompanyID = CompoanySealInfo.GrandCompanyID
    local ChapterCfg = Cfg[1]
    if ChapterCfg.GrandCompanyLimit and ChapterCfg.GrandCompanyLimit ~= 0 and CurGrandCompanyID ~= 0 then
        return ChapterCfg.GrandCompanyLimit == CurGrandCompanyID
    end

    return true
end

function AdventureRecommendTaskMgr:CheckVersion(AssignedVersionName)
    if string.isnilorempty(AssignedVersionName) then
		return true
    end
	return _G.UE.UVersionMgr.IsBelowOrEqualGameVersion(AssignedVersionName)
end

function AdventureRecommendTaskMgr:CheckUpTime(Uptime)
    if string.isnilorempty(Uptime) then
        return true
    end

    local ServerTime = TimeUtil.GetServerLogicTime()
    local TaskUpTime = TimeUtil.GetTimeFromString(Uptime)
    if ServerTime>= TaskUpTime and TaskUpTime > 0 then
        return true
    end

    return false
end

function AdventureRecommendTaskMgr:CheckRecommendTask(ChapterID)
    local Cfg = RecommendQuestCfg:FindAllCfg(string.format("ChapterID = %s", ChapterID))
    return (not table.is_nil_empty(Cfg)) and true or false
end

function AdventureRecommendTaskMgr:GetProfLevelLimit(ChapterID)
    local Cfgs = RecommendQuestCfg:FindAllCfg(string.format("ChapterID = %s", ChapterID))
    if table.is_nil_empty(Cfgs) then
        return
    end

    local Cfg = Cfgs[1]
    return Cfg.ProfLimit, Cfg.LevelLimit
end

function AdventureRecommendTaskMgr:GetRecommendTask()
    return self.RecommendTask
end

function AdventureRecommendTaskMgr:GetGameRecommendTask()
    return self.GameRecommendTask
end

function AdventureRecommendTaskMgr:GetBattleRecommendTask()
    return self.BattleRecommendTask
end

function AdventureRecommendTaskMgr:GetHugeRecomendTask()
    return self.HugeRecommendTask
end

function AdventureRecommendTaskMgr:GetMazeRecomendTask()
    return self.MazeRecommendTask
end

function AdventureRecommendTaskMgr:GetRecommendTaskByType(Type)
    if Type == AdventureDefine.RecommendTasks.Game then
        return self:GetGameRecommendTask()
    elseif Type == AdventureDefine.RecommendTasks.Battle then
        return self:GetBattleRecommendTask()
    elseif Type == AdventureDefine.RecommendTasks.Huge then
        return self:GetHugeRecomendTask()
    elseif Type ==  AdventureDefine.RecommendTasks.Maze then
        return self:GetMazeRecomendTask()
    end
end

function AdventureRecommendTaskMgr:SetTrackRecommendTaskID(QuestID)
    self.TrackRecommendTaskID = QuestID
end

function AdventureRecommendTaskMgr:GetTrackRecommendTaskID()
    return self.TrackRecommendTaskID
end

function AdventureRecommendTaskMgr:GetRecommendTaskType(ChapterID)
    local Cfgs = RecommendQuestCfg:FindAllCfg(string.format("ChapterID = %d", ChapterID))
    if table.is_nil_empty(Cfgs) then
        return
    end

    local Cfg = Cfgs[1]
    return Cfg.Type
end

------------------------------------ 红点相关逻辑 ------------------------------
--- 获取页签红点
function AdventureRecommendTaskMgr:GetTabRedDotIDByType(Type)
    if Type == AdventureDefine.RecommendTasks.Game then
        return 2008
    elseif Type == AdventureDefine.RecommendTasks.Battle then
        return 2009
    elseif Type == AdventureDefine.RecommendTasks.Huge then
        return 20091
    elseif Type == AdventureDefine.RecommendTasks.Maze then
        return 20092
    end
end

--- 获取列表红点
function AdventureRecommendTaskMgr:GetParentRedDotIDByType(Type)
    if Type == AdventureDefine.RecommendTasks.Game then
        return 12001
    elseif Type == AdventureDefine.RecommendTasks.Battle then
        return 12002
    elseif Type == AdventureDefine.RecommendTasks.Huge then
        return 12003
    elseif Type == AdventureDefine.RecommendTasks.Maze then
        return 12004
    end
end

function AdventureRecommendTaskMgr:SetTabRedDot(Type, bShow)
    local RetDotID = self:GetTabRedDotIDByType(Type)
    if not RetDotID  then return end
	
	if bShow then
        _G.FLOG_INFO(" AdventureRecommendTaskMgr:SetTabRedDot(Type) ")
		RedDotMgr:AddRedDotByID(RetDotID, nil, false)
	end

	if not bShow then
		RedDotMgr:DelRedDotByID(RetDotID)
	end
end

function AdventureRecommendTaskMgr:InsertRedDotDataList(Type, ChapterID, RedDotName)
    if Type == AdventureDefine.RecommendTasks.Game then
        if self.GameRecommendTaskRedList[ChapterID] == nil then
            self.GameRecommendTaskRedList[ChapterID] = RedDotName
        end
    end

    if Type == AdventureDefine.RecommendTasks.Battle then
        if self.BattleRecommendTaskRedList[ChapterID] == nil then
            self.BattleRecommendTaskRedList[ChapterID] = RedDotName
        end
    end

    if Type == AdventureDefine.RecommendTasks.Huge then
        if self.HugeRecommendTaskRedList[ChapterID] == nil then
            self.HugeRecommendTaskRedList[ChapterID] = RedDotName
        end
    end

    if Type == AdventureDefine.RecommendTasks.Maze then
        if self.MazeRecommendTaskRedList[ChapterID] == nil then
            self.MazeRecommendTaskRedList[ChapterID] = RedDotName
        end
    end
end

function AdventureRecommendTaskMgr:DelRedDotDataList(Type, ChapterID)
    if Type == AdventureDefine.RecommendTasks.Game then
        self.GameRecommendTaskRedList[ChapterID] = nil
    end

    if Type == AdventureDefine.RecommendTasks.Battle then
        self.BattleRecommendTaskRedList[ChapterID] = nil
    end

    if Type == AdventureDefine.RecommendTasks.Huge then
        self.HugeRecommendTaskRedList[ChapterID] = nil
    end

    if Type == AdventureDefine.RecommendTasks.Maze then
        self.MazeRecommendTaskRedList[ChapterID] = nil
    end  
end

function AdventureRecommendTaskMgr:GetRedDotName(Type, ChapterID)
    if Type == AdventureDefine.RecommendTasks.Game then
        return self.GameRecommendTaskRedList[ChapterID]
    end

    if Type == AdventureDefine.RecommendTasks.Battle then
        return self.BattleRecommendTaskRedList[ChapterID]
    end

    if Type == AdventureDefine.RecommendTasks.Huge then
        return self.HugeRecommendTaskRedList[ChapterID]
    end

    if Type == AdventureDefine.RecommendTasks.Huge then
        return self.MazeRecommendTaskRedList[ChapterID]
    end
end

function AdventureRecommendTaskMgr:AddRedDot(Type, ChapterID, ParentRedDotID)
    local RedDotName = self:GetRedDotName(Type, ChapterID)
    if RedDotName == nil then
        RedDotName = RedDotMgr:AddRedDotByParentRedDotID(ParentRedDotID, nil, false)
        self:InsertRedDotDataList(Type, ChapterID, RedDotName)
    end
end

function AdventureRecommendTaskMgr:DelRedDot(Type, ChapterID)
    local RedDotName = self:GetRedDotName(Type, ChapterID)
    if RedDotName ~= nil then
        RedDotMgr:DelRedDotByName(RedDotName)
        self:DelRedDotDataList(Type, ChapterID)
    end
end

function AdventureRecommendTaskMgr:GetNewStateTable()
    local JsonStr = USaveMgr.GetString(SaveKey.RecommendTaskNewState, "", true)
    local RecommendTaskNewStateTable = string.isnilorempty(JsonStr) and {} or Json.decode(JsonStr)
    return RecommendTaskNewStateTable
end

function AdventureRecommendTaskMgr:SaveNewStateTable(NewStateTable)
    local SaveRecommendTaskNewTable = Json.encode(NewStateTable)
    USaveMgr.SetString(SaveKey.RecommendTaskNewState, SaveRecommendTaskNewTable, true)
end

function AdventureRecommendTaskMgr:DoGM()
    local Json = require("Core/Json")
    local SaveKey = require("Define/SaveKey")
    local JsonStr = _G.UE.USaveMgr.GetString(SaveKey.RecommendTaskNewState, "", true)
    local RecommendTaskNewStateTable = string.isnilorempty(JsonStr) and {} or Json.decode(JsonStr)
    for chapterID, item in pairs(RecommendTaskNewStateTable) do
        RecommendTaskNewStateTable[chapterID] = true
        local Type = self:GetRecommendTaskType(tonumber(chapterID))
        local ParentRedDotID =  AdventureRecommendTaskMgr:GetParentRedDotIDByType(Type)
        self:AddRedDot(Type, tonumber(chapterID), ParentRedDotID)
        self:SetTabRedDot(Type, true)
    end

    local SaveRecommendTaskNewTable = Json.encode(RecommendTaskNewStateTable)
    _G.UE.USaveMgr.SetString(SaveKey.RecommendTaskNewState, SaveRecommendTaskNewTable, true)
end

--要返回当前类
return AdventureRecommendTaskMgr