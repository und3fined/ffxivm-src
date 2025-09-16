--
-- Author: sammrli
-- Date: 2024-01-17
-- Description:任务layerset
--

local LuaClass = require("Core/LuaClass")

local PworldCfg = require("TableCfg/PworldCfg")
local QuestStoryCfg = require("TableCfg/QuestStoryCfg")
local QuestStorySequenceCfg = require("TableCfg/QuestStorySequenceCfg")

---@class QuestLayerset
local QuestLayerset = LuaClass()

function QuestLayerset:Ctor()
    ---@type table<QuestLayersetData>
    self.AcceptedTaskList = {}

    ---@type table<QuestLayersetData>
    self.CompletedTaskList = {}

    self.AllDefaultMapID = {}
    self.StoryIDToMapID = {}
    self.ChangeMapToDefaultMap = {}

    self.IsInitData = false

    local AllQuestStoryCfg = QuestStoryCfg:FindAllCfg() -- 数据量少，FindAllCfg耗时不长 20240613
    for _,Cfg in pairs(AllQuestStoryCfg) do
        self.AllDefaultMapID[Cfg.DefaultMapID] = true
        self.StoryIDToMapID[Cfg.StoryID] = Cfg.DefaultMapID
    end
end

function QuestLayerset:InitData()
    local LastMapID = 0
    local Cfgs = QuestStorySequenceCfg:FindAllCfg()
    for _,Cfg in pairs(Cfgs) do
        if Cfg.MapID > 0 then
            LastMapID = Cfg.MapID
            self.ChangeMapToDefaultMap[Cfg.MapID] = self.StoryIDToMapID[Cfg.StoryID]
        end
        if LastMapID > 0 then
            if #Cfg.CompletedTaskID > 0 then
                for _,ID in pairs(Cfg.CompletedTaskID) do
                    ---@class QuestLayersetData
                    ---@field DefaultMapID number
                    ---@field MapID number
                    ---@field Priority number
                    local Data = {}
                    Data.DefaultMapID = self.StoryIDToMapID[Cfg.StoryID]
                    Data.MapID = LastMapID
                    Data.Priority = Cfg.ID
                    self.CompletedTaskList[ID] = Data
                end
            end
            if #Cfg.AcceptedTaskID > 0 then
                for _,ID in pairs(Cfg.AcceptedTaskID) do
                    ---@type QuestLayersetData
                    local Data = {}
                    Data.DefaultMapID = self.StoryIDToMapID[Cfg.StoryID]
                    Data.MapID = LastMapID
                    Data.Priority = Cfg.ID
                    self.AcceptedTaskList[ID] = Data
                end
            end
        end
    end
    self.IsInitData = true
end

function QuestLayerset:GetDefaultMapID(ChangeMapID)
    if self.AllDefaultMapID[ChangeMapID] then
        return 0
    end
    if self.ChangeMapToDefaultMap[ChangeMapID] == nil then
        local Cfg = QuestStorySequenceCfg:FindCfg(string.format("MapID == %d", ChangeMapID))
        local StoryID = (Cfg ~= nil) and Cfg.StoryID or 0
        self.ChangeMapToDefaultMap[ChangeMapID] = self.StoryIDToMapID[StoryID] or 0
    end
    return self.ChangeMapToDefaultMap[ChangeMapID]
end

---根据任务节点转换传送的副本id和地图id
function QuestLayerset:ConvertMapID(WorldID, MapID)
    if not self.IsInitData then
        local _ <close> = CommonUtil.MakeProfileTag("[QuestLayerset] InitData")
        self:InitData()
    end

    if not MapID then
        if WorldID then
            local Cfg = PworldCfg:FindCfgByKey(WorldID)
            if Cfg then
                MapID = Cfg.MapList[1]
            else
                return WorldID, MapID
            end
        end
    end
    local ChangeMap = 0
    FLOG_INFO("[QuestLayerset]Before WorldID="..tostring(WorldID).." ,MapID="..tostring(MapID))

    local Priority = 0
    for QuestID,_ in pairs(_G.QuestMgr.QuestMap) do
        local Data = self.AcceptedTaskList[QuestID]
        if Data then
            if Data.DefaultMapID == MapID and Data.Priority > Priority then
                Priority = Data.Priority
                ChangeMap = Data.MapID
            end
        end
    end

    for QuestID,_ in pairs(_G.QuestMgr.EndQuestToChapterIDMap) do
        local Data = self.CompletedTaskList[QuestID]
        if Data then
            if Data.DefaultMapID == MapID and Data.Priority > Priority then
                Priority = Data.Priority
                ChangeMap = Data.MapID
            end
        end
    end
    if ChangeMap > 0 then
        local WorldCfgItem = self:FindPworldCfg(ChangeMap)
        if WorldCfgItem then
            FLOG_INFO("[QuestLayerset]Change WorldID="..tostring(WorldCfgItem.ID).." ,MapID="..tostring(ChangeMap))
            return WorldCfgItem.ID, ChangeMap
        end
    end

    FLOG_INFO("[QuestLayerset]After WorldID="..tostring(WorldID).." ,MapID="..tostring(MapID))
    return WorldID, MapID
end

function QuestLayerset:FindPworldCfg(MapID)
    local AllPworldCfg = _G.PWorldMgr:GetAllPworldTableCfg()
    for _, Cfg in pairs(AllPworldCfg) do
        if Cfg.MapList[1] == MapID then
            return Cfg
        end
    end
    return nil
end


return QuestLayerset
