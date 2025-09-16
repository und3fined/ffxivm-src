---
--- Author: sammrli
--- DateTime: 2024-02-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")

local TravelLogTaskItemVM = require("Game/TravelLog/VM/TravelLogTaskItemVM")
local TravelLogTaskItemItemVM = require("Game/TravelLog/VM/TravelLogTaskItemItemVM")
--local TravelLogTaskTitleItneVM = require("Game/TravelLog/VM/TravelLogTaskTitleItneVM")

local TravelLogCfg = require("TableCfg/TravelLogCfg")
local TravelLogGenreCfg = require("TableCfg/TravelLogGenreCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")

local QuestHelper = require("Game/Quest/QuestHelper")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local PathMgr = require("Path/PathMgr")

local DialogueUtil = require("Utils/DialogueUtil")
local QuestDefine = require("Game/Quest/QuestDefine")
local CommonUtil = require("Utils/CommonUtil")

local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =    ProtoCS.CS_QUEST_STATUS
local CHAPTER_STATUS =  QuestDefine.CHAPTER_STATUS
local LSTR = _G.LSTR
local QuestMgr = _G.QuestMgr
local ObjectPoolMgr = _G.ObjectPoolMgr

---@class TravelLogMainPanelVM : UIViewModel
local TravelLogMainPanelVM = LuaClass(UIViewModel)

function TravelLogMainPanelVM:Ctor()
    self.LogVMList = UIBindableList.New(TravelLogTaskItemVM)
    self.TaskTitle = ""
    self.IconTaskPath = ""
    self.Content = ""
    self.GenreTitle = ""
    self.FilterText = ""
    self.TextNull = ""
    self.IsRightContentVisible = true
    self.IsEmptyVisible = true
    self.CurrJournaltGenreID = 0
    self.CacheDropDownDataList = {}
    self.TaskLogDict = {}
end

function TravelLogMainPanelVM:GetAllGenreCfg()
    if self.AllGenreCfg then
       return self.AllGenreCfg
    end
    self.AllGenreCfg = TravelLogGenreCfg:FindAllCfg()
    return self.AllGenreCfg
end

function TravelLogMainPanelVM:GetAllLogCfg()
    if self.AllLogCfg then
        return self.AllLogCfg
     end
     self.AllLogCfg = TravelLogCfg:FindAllCfg()
     return self.AllLogCfg
end

function TravelLogMainPanelVM:GetDropDownListData(MainGenreIndex)
    if self.CacheDropDownDataList[MainGenreIndex] then
        return self.CacheDropDownDataList[MainGenreIndex]
    end
    local AllGenreCfg = self:GetAllGenreCfg()
    local Data = {}
    local InsertList = {}
    for _,GenreCfg in pairs(AllGenreCfg) do
        local JournaltGenreID = GenreCfg.JournaltGenreID
        local Genre = math.floor(JournaltGenreID / 10000)
        if Genre == MainGenreIndex then
            local SubGenre = math.floor(JournaltGenreID / 100)
            if not InsertList[SubGenre] then
                InsertList[SubGenre] = true
                local RedDotData = {RedDotName=_G.TravelLogMgr:GetSubGenreRedDotName(JournaltGenreID)}
                table.insert(Data, {Type=JournaltGenreID, Name=GenreCfg.SubGenre, RedDotData=RedDotData})
            end
        end
    end
    self.CacheDropDownDataList[MainGenreIndex] = Data
    return Data
end

function TravelLogMainPanelVM:SetFilterText(FilterText)
    self.FilterText = FilterText
    self:ChangeGenre(self.CurrJournaltGenreID)
end

function TravelLogMainPanelVM:ClearPageTaskRedDot()
    local LogVMList = self.LogVMList
    if LogVMList then
        for i=1, LogVMList:Length() do
            local LogVM = LogVMList:Get(i)
            if LogVM.ItemVM1 then
                if LogVM.ItemVM1.ChapterID then
                    _G.TravelLogMgr:DeleteChildRedDot(LogVM.ItemVM1.ChapterID)
                end
                if LogVM.ItemVM1.PWorldID then
                    _G.TravelLogMgr:DeleteChildRedDot(LogVM.ItemVM1.PWorldID)
                end
            end
            if LogVM.ItemVM2 then
                if LogVM.ItemVM2.ChapterID then
                    _G.TravelLogMgr:DeleteChildRedDot(LogVM.ItemVM2.ChapterID)
                end
                if LogVM.ItemVM2.PWorldID then
                    _G.TravelLogMgr:DeleteChildRedDot(LogVM.ItemVM2.PWorldID)
                end
            end
        end
    end
end

function TravelLogMainPanelVM:ChangeGenre(JournaltGenreID)
    self.CurrJournaltGenreID = JournaltGenreID
    self.LogVMList:FreeAllItems()
    local GenreTitle = nil
    local IsEmpty = true
    local IsFirstSelected = true
    local LastGenreTitle = nil
    local FilterText = self.FilterText

    local AllLogCfg = self:GetAllLogCfg()
    local IsFilterMode = false
    local SubGenre = math.floor(JournaltGenreID / 100)
    local LogCfgList = {}
    if string.isnilorempty(FilterText) then
        for i=1, #AllLogCfg do
            local LogCfg = AllLogCfg[i]
            if math.floor(LogCfg.JournaltGenreID / 100) == SubGenre then
                table.insert(LogCfgList, LogCfg)
            end
        end
    else
        for i=1, #AllLogCfg do
            local LogCfg = AllLogCfg[i]
            table.insert(LogCfgList, LogCfg)
        end
        IsFilterMode = true
    end

    for _, List in pairs(self.TaskLogDict) do
        for _, ItemVM in pairs(List) do
            ObjectPoolMgr:FreeObject(TravelLogTaskItemItemVM, ItemVM)
        end
    end
    table.clear(self.TaskLogDict)
    local GenreCfg = TravelLogGenreCfg:FindCfgByKey(JournaltGenreID)
    for _,LogCfg in pairs(LogCfgList) do
        local IsShow = _G.TravelLogMgr.IsTempTest or self:IsCanShow(LogCfg)           -- 条件过滤
        if IsShow then
            local LogGenreCfg = TravelLogGenreCfg:FindCfgByKey(LogCfg.JournaltGenreID)
            if LogGenreCfg and LogGenreCfg.SubGenre then
                if not self.TaskLogDict[LogGenreCfg.SubGenre] then
                    self.TaskLogDict[LogGenreCfg.SubGenre] = {}
                end
                if LogCfg.QuestID > 0 then
                    local ChapterCfg = QuestHelper.GetChapterCfgItem(LogCfg.QuestID)
                    if ChapterCfg then
                        local IsAdd = true
                        if IsFilterMode then
                            IsAdd = string.find(ChapterCfg.QuestName, FilterText, 1, true)
                        end

                        if IsAdd then
                            local VM = ObjectPoolMgr:AllocObject(TravelLogTaskItemItemVM) --TravelLogTaskItemItemVM.New()
                            VM.LogID = LogCfg.id
                            VM.ChapterID = LogCfg.QuestID
                            VM.GenreID = LogCfg.JournaltGenreID
                            VM.TextLevel = string.format("%d%s", ChapterCfg.MinLevel, LSTR(530003)) --530003("级")
                            VM.ImgTask = ChapterCfg.LogImage
                            VM.IconTaskPath = QuestMgr:GetQuestIconAtLog(nil, ChapterCfg.QuestType)
                            VM.TextTask = ChapterCfg.QuestName
                            VM.DetailedGenre = IsFilterMode and "" or LogGenreCfg.DetailedGenre --搜索不分组
                            VM.IsPrefixVisible = LogCfg.PlotBranchMarkShowCondition > 0
                            VM.IsPrefixFinish = self:GetPrefix(LogCfg)
                            VM.IsSelected = IsFirstSelected
                            table.insert(self.TaskLogDict[LogGenreCfg.SubGenre], VM)

                            IsEmpty = false
                            IsFirstSelected = false
                            LastGenreTitle = LogGenreCfg.SubGenre
                        end
                    end
                elseif LogCfg.PWorldID > 0 then
                    local PworldCfgItem = PworldCfg:FindCfgByKey(LogCfg.PWorldID)
                    local SceneEnterCfgItem = SceneEnterCfg:FindCfgByKey(LogCfg.PWorldID)
                    if PworldCfgItem and SceneEnterCfgItem then
                        local IsAdd = true
                        if IsFilterMode then
                            IsAdd = string.find(PworldCfgItem.PWorldName, FilterText, 1, true)
                        end

                        if IsAdd then
                            local VM = ObjectPoolMgr:AllocObject(TravelLogTaskItemItemVM)--TravelLogTaskItemItemVM.New()
                            VM.LogID = LogCfg.id
                            VM.PWorldID = LogCfg.PWorldID
                            VM.GenreID = LogCfg.JournaltGenreID
                            VM.TextLevel = string.format("%d%s", PworldCfgItem.PlayerLevel, LSTR(530003))--530003("级")
                            VM.ImgTask = self:GetPWordThumbnail(SceneEnterCfgItem.BG) --直接取缩略图,不作兼容,强制策划使用缩略图
                            VM.IconTaskPath = QuestMgr:GetQuestIconAtLog(nil, 0)
                            VM.TextTask = PworldCfgItem.PWorldName
                            VM.DetailedGenre = IsFilterMode and "" or LogGenreCfg.DetailedGenre --搜索不分组
                            VM.IsPrefixVisible = LogCfg.PlotBranchMarkShowCondition > 0
                            VM.IsPrefixFinish = self:GetPrefix(LogCfg)
                            VM.IsSelected = IsFirstSelected
                            table.insert(self.TaskLogDict[LogGenreCfg.SubGenre], VM)

                            IsEmpty = false
                            IsFirstSelected = false
                            LastGenreTitle = LogGenreCfg.SubGenre
                        end
                    end
                end
            end
        end
    end
    if not GenreTitle then
        GenreTitle = GenreCfg.MainGenre
    end

    local TaskLogSortList = {}
    for _, TaskItemList in pairs(self.TaskLogDict) do
        if #TaskItemList > 0 then
            table.insert(TaskLogSortList, TaskItemList)
        end
    end

    table.sort(TaskLogSortList, function(Left, Right)
        return Left[1].GenreID < Right[1].GenreID
    end)

    local LastGenreID = nil
    local VMArray = {}
    --两两一组
    for _, TaskItemList in pairs(TaskLogSortList) do
        for i=1, #TaskItemList do
            local ItemVM = TaskItemList[i]
            if not LastGenreID then
                LastGenreID = ItemVM.GenreID
            else
                if LastGenreID ~= ItemVM.GenreID and not string.isnilorempty(ItemVM.DetailedGenre) then
                    --如果还有ItemVM未填充，先填入
                    if VMArray.ItemVM1 then
                        self.LogVMList:AddByValue(VMArray)
                        VMArray = {}
                    end
                    --插入空白行
                    local VMEmpty = {
                        ItemVM1 = { GenreID = LastGenreID, DetailedGenre = ItemVM.DetailedGenre},
                        IsEmpty = true,
                    }
                    self.LogVMList:AddByValue(VMEmpty)
                    --替换新值
                    LastGenreID = ItemVM.GenreID
                end
            end
            if not VMArray.ItemVM1 then
                VMArray.ItemVM1 = ItemVM
            else
                VMArray.ItemVM2 = ItemVM
            end
            if (i==#TaskItemList and VMArray.ItemVM1) or VMArray.ItemVM2 then
                self.LogVMList:AddByValue(VMArray)
                VMArray = {}
            end
        end
    end

    --补满一页,视觉说为了好看
    local Hight = string.isnilorempty(LastGenreTitle) and 0 or 0.5
    local Length = self.LogVMList:Length()
    for i=1, Length do
        local VM = self.LogVMList:Get(i)
        if VM.IsEmpty then
            Hight = Hight + 0.5
        else
            Hight = Hight + 1
        end
    end
    if Hight < 4.5 then
        for i=Hight, 4.5 do
            local VMArray = {
                ItemVM1 = { DetailedGenre = LastGenreTitle },
            }
            self.LogVMList:AddByValue(VMArray)
        end
    end

    self.LogVMList:OnUpdateList()

    self.GenreTitle = GenreTitle
    self.IsRightContentVisible = not IsEmpty
    self.IsEmptyVisible = IsEmpty
    if IsEmpty then
        if IsFilterMode then
            self.TextNull = LSTR(530004) --530004("未搜索到该任务")
        else
            self.TextNull = LSTR(530005) --530005("暂无内容，快去冒险吧~")
        end
    end
end

---是否显示
function TravelLogMainPanelVM:IsCanShow(TravelLogCfgItem)
    local IsShow = false
    if TravelLogCfgItem.ShowCondition1 == 0 then
        IsShow = true
    elseif TravelLogCfgItem.ShowCondition1 == 1 then -- 任务状态
        --这里特殊的处理是因为使用gm完成任务，会出现任务加入到EndChapterMap但是status不为CHAPTER_STATUS.FINISHED的情况
        if TravelLogCfgItem.ShowCondition2 == CHAPTER_STATUS.FINISHED then
            IsShow = QuestMgr.EndChapterMap[TravelLogCfgItem.QuestID] ~= nil
        else
            local Chapter = QuestMgr.EndChapterMap[TravelLogCfgItem.QuestID]
            if Chapter then
                IsShow = Chapter.Status == TravelLogCfgItem.ShowCondition2
            end
        end
    elseif TravelLogCfgItem.ShowCondition1 == 2 then -- 过场动画类型
    elseif TravelLogCfgItem.ShowCondition1 == 3 then -- 完成副本
        IsShow = _G.PWorldMatchMgr:HasPassRewardRecv(TravelLogCfgItem.PWorldID)
    elseif TravelLogCfgItem.ShowCondition1 == 4 then -- 前置任务
        local Status = QuestMgr:GetQuestStatus(TravelLogCfgItem.ShowCondition2)
        if Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            IsShow = true
        end
    end
    return IsShow
end

---获取前置标记高亮状态
---@return boolean
function TravelLogMainPanelVM:GetPrefix(TravelLogCfgItem)
    if TravelLogCfgItem.PlotBranchMarkShowCondition == 1 then
        if TravelLogCfgItem.PlotBranchMarkLightingCondition > 0 then
            return ConditionMgr:CheckConditionByID(TravelLogCfgItem.PlotBranchMarkLightingCondition)
        end
    end
    return true
end

---获取副本缩略图
function TravelLogMainPanelVM:GetPWordThumbnail(Path)
    local Array = string.split(Path, '_')
    local Num = #Array
    local FileName = string.gsub(Array[Num], "'", "")
    local ThumPath = string.format("Texture2D'/Game/UI/Texture/TravelLog/UI_TravelLog_PWorld_Details_%s_P.UI_TravelLog_PWorld_Details_%s_P'",FileName,FileName)
    return ThumPath
end

function TravelLogMainPanelVM.SortListPredicate(Left, Right)
    return Left.MinLevel > Right.MinLevel
end

function TravelLogMainPanelVM:SetSelectedTaskItne(LogID)
    local Length = self.LogVMList:Length()
    for i=1, Length do
        local VM = self.LogVMList:Get(i)
        VM:SetSelectedTaskItne(LogID)
    end
end

function TravelLogMainPanelVM:UpdateTaskContent(LogID)
    local Content = ""
    local Title = ""
    local IconPath = ""
    local FirstLine = true
    local TravelLogCfgItem = TravelLogCfg:FindCfgByKey(LogID)
    if not TravelLogCfgItem then
        return
    end
    if TravelLogCfgItem.QuestID > 0 then
        local ChapterCfg = QuestHelper.GetChapterCfgItem(TravelLogCfgItem.QuestID)
        if ChapterCfg then
            Title = ChapterCfg.QuestName
            IconPath = QuestMgr:GetQuestIconAtLog(nil, ChapterCfg.QuestType)
            for _, QuestID in pairs(ChapterCfg.ChapterQuests) do
                local QuestCfg = QuestHelper.GetQuestCfgItem(QuestID)
                if QuestCfg then
                    if not string.isnilorempty(QuestCfg.AcceptDesc) then
                        if FirstLine then
                            Content = QuestCfg.AcceptDesc
                        else
                            Content = string.format("%s\n%s", Content, QuestCfg.AcceptDesc)
                        end
                        FirstLine = false
                    end
                    if not string.isnilorempty(QuestCfg.TaskDesc) then
                        if FirstLine then
                            Content = QuestCfg.TaskDesc
                        else
                            Content = string.format("%s\n%s", Content, QuestCfg.TaskDesc)
                        end
                        FirstLine = false
                    end
                end
            end
        end
    end

    if TravelLogCfgItem.PWorldID > 0 then
        local PworldCfgItem = PworldCfg:FindCfgByKey(TravelLogCfgItem.PWorldID)
        if PworldCfgItem then
            Title = PworldCfgItem.PWorldName
        end
        local SceneEnterCfgItem = SceneEnterCfg:FindCfgByKey(TravelLogCfgItem.PWorldID)
        if SceneEnterCfgItem then
            Content = SceneEnterCfgItem.Summary
        end
        IconPath = QuestMgr:GetQuestIconAtLog(nil, 0)
    end

    if string.isnilorempty(Content) then
        self.Content = Content
    else
        Content = DialogueUtil.ParseLabel(Content)
        Content = CommonUtil.GetTextFromStringWithSpecialCharacter(Content)
        self.Content = Content
    end
    self.TaskTitle = Title
    self.IconTaskPath = IconPath
end

return TravelLogMainPanelVM