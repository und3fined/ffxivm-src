local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local DirectUpgradeQuestCfg = require("TableCfg/DirectUpgradeQuestCfg")
local DirectUpgradeCfg = require("TableCfg/DirectUpgradeCfg")
local DirectUpgradeProfquestCfg = require("TableCfg/DirectUpgradeProfquestCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UpgradeTabItemVM = require("Game/Upgrade/VM/UpgradeTabItemVM")
local UpgradeTaskItemVM = require("Game/Upgrade/VM/UpgradeTaskItemVM")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActorMgr = require("Game/Actor/ActorMgr")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local MajorUtil = require("Utils/MajorUtil")
local QuestMgr = require("Game/Quest/QuestMgr")

local LSTR = _G.LSTR
local UpgradeMgr = _G.UpgradeMgr

---@class UpgradeMainVM : UIViewModel
local UpgradeMainVM = LuaClass(UIViewModel)
---Ctor
function UpgradeMainVM:Ctor()
    self.TextJob1 = nil
    self.TextLevel1 = nil
    self.TextJob2 = nil
    self.TextLevel2 = nil
    self.ImgJob = nil
    self.IconJob1 = nil
    self.IconJob2 = nil
    self.IsTextLockVisiable = false
    self.TabVMList = UIBindableList.New(UpgradeTabItemVM)
    self.TaskVMList = UIBindableList.New(UpgradeTaskItemVM)
end

function UpgradeMainVM:Update(Params)
    local ProfID = Params.Prof
    local Exp = Params.Exp
    local QuestID2Finish = Params.QuestID2Finish
    if ProfID == 0 then
       ProfID = MajorUtil.GetMajorAttributeComponent().ProfID
       self.IsTextLockVisiable = false
    else
        self.IsTextLockVisiable = true
    end
    local StartTimeStamp, EndTimeStamp = UpgradeMgr:GetUpgradeTimeStamp()
    local ServerTimeStamp = TimeUtil.GetServerLogicTime()
    self.EndTimeStamp = EndTimeStamp

    local CurrentDay = math.floor((ServerTimeStamp - StartTimeStamp)/ (24 * 3600)) + 1
    if CurrentDay > 4 then
        self.CurrentSelectDay = 4
    else
        self.CurrentSelectDay = CurrentDay
    end
    local CostItemIDCfg = DirectUpgradeCfg:FindCfgByKey(ProtoRes.DirectUpgradeCfgID.DirectUpgradeCfgIDCostItemID)
    self.ItemID = CostItemIDCfg.Value
    local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(ProfID)
    if AdvanceProf == 0 then
        AdvanceProf = ProfID
    end
    if ProfID == MajorUtil.GetMajorAttributeComponent().ProfID or AdvanceProf == MajorUtil.GetMajorAttributeComponent().ProfID then
        self.IsCanUpgrade = true 
    else
        self.IsCanUpgrade = false 
    end
    self.TextJob2 = RoleInitCfg:FindRoleInitProfName(AdvanceProf)
    local Cfg = RoleInitCfg:FindCfgByKey(AdvanceProf)
	if nil ~= Cfg then
        self.IconJob2 = Cfg.SimpleIcon3
    end
    self.CurDayTextJob2 = self.TextJob2
    self.CurDayIconJob2 = self.IconJob2
    local Prof = ActorMgr:GetMajorRoleDetail().Prof
    local ProfList = Prof.ProfList

    local ProfIDTable = {}
    for _, ProfData in pairs(ProfList) do
        table.insert(ProfIDTable, ProfData.ProfID)
    end
    for _, ProfData in pairs(ProfList) do
        if ProfData.ProfID == AdvanceProf or (ProfData.ProfID == ProfID and not table.contain(ProfIDTable, AdvanceProf)) then
            local CurrentExp = ProfData.Exp
            local CurrentLevel = ProfData.Level
            self.Level1 = CurrentLevel
            ProfID = ProfData.ProfID
            self.TextJob1 = RoleInitCfg:FindRoleInitProfName(ProfData.ProfID)
            local Cfg = RoleInitCfg:FindCfgByKey(ProfData.ProfID)
            if nil ~= Cfg then
                self.IconJob1 = Cfg.SimpleIcon3
            end
            self.TextLevel1 = string.format(LSTR(990109), CurrentLevel) --当前等级：%s级
            local Level2 = self:CalculateNewLevel(CurrentLevel, CurrentExp, Exp)
            self.TextLevel2 = string.format(LSTR(990110), Level2) --提升后：%s级
            self.CurDayTextLevel2 = self.TextLevel2
            self.BeforeDayTextLevel2 = string.format(LSTR(990110), CurrentLevel)
            self.BeforeDayTextJob2 = self.TextJob1
            self.BeforeDayIconJob2 = self.IconJob1
            break
        end
    end

    local TabData = {}
    self.TaskData = {}
    self.QuestCostData = {}
    self.IsFinishAllTask = true
    for i = 0, 3 do
        local data = {}
        local Task = {}
        local FutureTimeStamp = StartTimeStamp + (i * 24 * 3600)
        local FutureTimeTable = os.date("*t", FutureTimeStamp)
        local TextTime = string.format(LSTR(990111), FutureTimeTable.month, FutureTimeTable.day)  --%d月%d号
        local UpgradeQuestCfg = DirectUpgradeQuestCfg:FindCfgByKey(i+1)
        table.insert(self.QuestCostData, {MainQuestID = UpgradeQuestCfg.MainQuestID,  IsCostItem = UpgradeQuestCfg.IsCostItem})
        data.TextTime = TextTime
        if CurrentDay >= i + 1 then
            data.IsLock = false
            local ProfTaskName = self:GetProfTaskName(ProfID, i+1, QuestID2Finish)
            local MainTaskName = QuestMgr:GetQuestName(UpgradeQuestCfg.MainQuestID)
            self.IsMainTaskFinished = self:GetQuestFinishedState(QuestID2Finish, UpgradeQuestCfg.MainQuestID)
            local MainTaskImageColor = self:GetImageColor(self.IsMainTaskFinished)
            local ProfTaskImageColor = self:GetImageColor(self.IsProfTaskFinished)
            if not self.IsMainTaskFinished or not self.IsProfTaskFinished then
               self.IsFinishAllTask = false
            end
            local MainTaskIcon = "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071201.UI_Icon_071201'"
            local ProTaskIcon = "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071341.UI_Icon_071341'"
            Task = {{Index = 0, TaskTitle = LSTR(990112)},{Index = 1, TaskText = MainTaskName, IsTaskCompleted = self.IsMainTaskFinished, ImageColor = MainTaskImageColor, IconTask = MainTaskIcon},
                    {Index = 0, TaskTitle = LSTR(990113)},{Index = 1, TaskText = ProfTaskName, IsTaskCompleted = self.IsProfTaskFinished, ImageColor = ProfTaskImageColor, IconTask = ProTaskIcon}}
        else
            data.IsLock = true
        end
        table.insert(TabData, data)
        table.insert(self.TaskData, Task)
    end
    self.TabVMList:UpdateByValues(TabData)
end

function UpgradeMainVM:SetTaskInfo(Index)
    local Task = self.TaskData[Index]
    self.TaskVMList:UpdateByValues(Task)
end

function UpgradeMainVM:GetProfTaskName(Prof, Day, QuestID2Finish)
    local ProfLevel = RoleInitCfg:FindProfLevel(Prof)
    if ProfLevel == ProtoRes.prof_level.PROF_LEVEL_ADVANCED then
        local Cfg = RoleInitCfg:FindCfg(string.format("AdvancedProf == %d", Prof))
        if nil ~= Cfg then
            Prof = Cfg.Prof
        end
    end

    local ProfquestCfg = DirectUpgradeProfquestCfg:FindCfg(string.format("Profession == %d AND Day == %d",Prof, Day))
    if ProfquestCfg ~= nil and not table.empty(ProfquestCfg) then
        local QuestName = QuestMgr:GetQuestName(ProfquestCfg.AdvanceProfQuestID)
        self.ImgJob = ProfquestCfg.Icon
        self.IsProfTaskFinished = self:GetQuestFinishedState(QuestID2Finish, ProfquestCfg.AdvanceProfQuestID)
		return QuestName
	end
end

function UpgradeMainVM:GetQuestFinishedState(table, key)
    for QuestID, QuestState in pairs(table) do
        if QuestID == key then
            return QuestState
        end
    end
end

function UpgradeMainVM:CalculateNewLevel(CurretnLevel, CurrentExp, Exp)
    if CurretnLevel >= 50 then
       return CurretnLevel
    end
    local LevelCfg = LevelExpCfg:FindCfgByKey(CurretnLevel)
    local MaxLevel = LevelCfg.MaxLevel
    local TotalExp = CurrentExp + Exp
    local NewLevel = CurretnLevel

    while NewLevel < MaxLevel do
        local ExpCfg = LevelExpCfg:FindCfgByKey(NewLevel)
        if TotalExp >= ExpCfg.NextExp then
            TotalExp = TotalExp - ExpCfg.NextExp
            NewLevel = NewLevel + 1
        else
            break
        end
    end

    return NewLevel
end

function UpgradeMainVM:GetImageColor(IsTaskCompleted)
    if IsTaskCompleted then
        return "332C229A"
    else
       return "33312F9A"
    end
end





return UpgradeMainVM