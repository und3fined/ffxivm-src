---
---@Author: ZhengJanChuan
---@Date: 2023-07-18 14:30:02
---@Description: 推荐任务VM
---

local LuaClass = require("Core/LuaClass")
local AdventureRecommendTaskMgr = require("Game/Adventure/AdventureRecommendTaskMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local QuestMgr = require("Game/Quest/QuestMgr")
local QuestHelper = require("Game/Quest/QuestHelper")
local RecommendQuestCfg = require("TableCfg/RecommendQuestCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local AdventureRecommendTaskNewItemVM = require("Game/Adventure/ItemVM/AdventureRecommendTaskNewItemVM")
local AdventureBaseVM = require("Game/Adventure/AdventureBaseVM")
local ProtoCS = require("Protocol/ProtoCS")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local UIBindableList = require("UI/UIBindableList")

local LSTR = _G.LSTR

---@class AdventureRecommendTaskNewVM : AdventureBaseVM
local AdventureRecommendTaskNewVM = LuaClass(AdventureBaseVM)

---Ctor
function AdventureRecommendTaskNewVM:Ctor()
    self.PanelEmptyStateVisible = false
    self.CurType = nil
    self.EmptyText = ""
    self.ItemList = UIBindableList.New(AdventureRecommendTaskNewItemVM)
end

function AdventureRecommendTaskNewVM:SetCurType(Type)
    self.CurType = Type
end

function AdventureRecommendTaskNewVM:GetCurTypeListData()
    local Type = self.CurType
    local TaskList = {}
    local QuestList = AdventureRecommendTaskMgr:GetRecommendTaskByType(Type) or {}
    local NewStateList = AdventureRecommendTaskMgr:GetNewStateTable()
    --local ParentRedDotID =  AdventureRecommendTaskMgr:GetParentRedDotIDByType(Type)
    for _, QuestID in pairs(QuestList) do
        local Cfg = QuestHelper.GetChapterCfgItem(QuestID)
        if Cfg ~= nil then
            local ChapterID = QuestID
            local StartQuestCfg = QuestHelper.GetQuestCfgItem(Cfg.StartQuest)
            local FinisihedQuestCfg =  QuestHelper.GetQuestCfgItem(Cfg.EndQuest)
            local Status = QuestMgr:GetQuestStatus(StartQuestCfg.id)
            local FinishedStatus = QuestMgr:GetQuestStatus(FinisihedQuestCfg.id)
            local RecommendCfgs = RecommendQuestCfg:FindAllCfg(string.format("ChapterID = %d", ChapterID))
            if not table.is_nil_empty(RecommendCfgs) and FinishedStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            local RecommendCfg = RecommendCfgs[1]
            local Params = {
                ID = QuestID,
                ChapterID = ChapterID,
                MinLevel = Cfg.MinLevel,
                Top = RecommendCfg.Top,
                Priority = RecommendCfg.Priority,
                Status = Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and 1 or 0,
                TextTitle = string.format("%d%s %s",Cfg.MinLevel, LSTR(520043), Cfg.QuestName),
                TextDescribe = string.format("%s:%s", LSTR(520049), RecommendCfg.UnlockTip),
                UnlockIconPath = RecommendCfg.UnlockIconPath,
                ImgTaskIcon = QuestMgr:GetChapterIconAtLog(ChapterID, Cfg.QuestType, false), -- 任务图标

                ImgTask = Cfg.LogImage,
                -- ViewModel.StartVisible = Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED
                StartVisible = true,
                GoText = Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and _G.LSTR(860012) or _G.LSTR(860013),
                GoBtnStyle =  Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and  CommBtnColorType.Normal or CommBtnColorType.Recommend,
            }
                
                if NewStateList[tostring(ChapterID)] == nil then
                    NewStateList[tostring(ChapterID)] = Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED
                end

                --奖励列表
                local LootMappingCfgItem = LootMappingCfg:FindCfg(string.format("ID = %d", FinisihedQuestCfg.LootID))
                local ItemList = {}
                if LootMappingCfgItem ~= nil then
                    local LootID = LootMappingCfgItem.Programs[1].ID
                    local RewardItemList = ItemUtil.GetLootItems(LootID)
                    for _, v in ipairs(RewardItemList) do
                        local Data = {}
                        Data.ResID = v.ResID
                        Data.IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(v.ResID))
                        Data.NumText = _G.ScoreMgr.FormatScore(v.Num)
                        Data.Num = v.Num
                        Data.IsMaskVisible = false
                        Data.IsVisible = true
                        table.insert(ItemList, Data)
                    end
                end
                Params.RewardList = ItemList

                table.insert(TaskList, Params)
            end
        end
    end

    AdventureRecommendTaskMgr:SaveNewStateTable(NewStateList)
    table.sort(TaskList, self.SortListPredicate)

    self.PanelEmptyStateVisible = #TaskList == 0
    if self.PanelEmptyStateVisible then
        self.EmptyText = AdventureRecommendTaskMgr:GetAllAdventureRecommendFinished() and _G.LSTR(520020) or _G.LSTR(520033)
    end

    return TaskList
end

function AdventureRecommendTaskNewVM.SortListPredicate(Left, Right)
	if Left.Top ~= Right.Top then
		return Left.Top > Right.Top
	end

    if Left.Status ~= Right.Status then
        return Left.Status > Right.Status
    end

    if Left.MinLevel ~= Right.MinLevel then
        return Left.MinLevel < Right.MinLevel
    end

    if Left.Priority ~= Right.Priority then
        return Left.Priority < Right.Priority
    end

    return Left.ChapterID < Right.ChapterID
end

function AdventureRecommendTaskNewVM:SetNewState(ChapterID, NewState)
    local NewStateTable = AdventureRecommendTaskMgr:GetNewStateTable()
    NewStateTable[ChapterID] = NewState
    AdventureRecommendTaskMgr:SaveNewStateTable(NewStateTable)
end

function AdventureRecommendTaskNewVM:SetTypeAllNewState(Type)
    local StateTable = AdventureRecommendTaskMgr:GetNewStateTable()
    for chapterID, item in pairs(StateTable) do
        local TaskType = AdventureRecommendTaskMgr:GetRecommendTaskType(chapterID)
        if Type == TaskType and Type ~= nil and TaskType ~= nil then
            AdventureRecommendTaskMgr:DelRedDot(Type, tonumber(chapterID))
            StateTable[chapterID] = false
        end
    end

    AdventureRecommendTaskMgr:SaveNewStateTable(StateTable)
end

--要返回当前类
return AdventureRecommendTaskNewVM