--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2024-07-22 17:04:06
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2024-07-22 17:06:29
FilePath: \Script\Game\Adventure\AdventureCareerMgr.lua
Description: 冒险系统职业生涯引导
--]]

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProfMgr = require("Game/Profession/ProfMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProfCareerCfg = require("TableCfg/ProfCareerCfg")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local QuestCfg = require("TableCfg/QuestCfg")
local QuestMgr = require("Game/Quest/QuestMgr")
local AdventureMgr = require("Game/Adventure/AdventureMgr")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local Json = require("Core/Json")
local SaveKey = require("Define/SaveKey")
local MapUtil = require("Game/Map/MapUtil")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local ModuleOpenMgr
local USaveMgr

local CareerTaskData = {}
local CareerTaskIDMap = {}

local CareerChapterCfg = {}
local CareerQuestCfg = {}

local TaskStateIcon = {
    [QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED] = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Plus_Missed_png.UI_Icon_Hud_Plus_Missed_png'",
    [QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS] = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Plus_Go_png.UI_Icon_Hud_Plus_Go_png'",
    [QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT] = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Plus_Go_png.UI_Icon_Hud_Plus_Go_png'",
    [QUEST_STATUS.CS_QUEST_STATUS_FINISHED] = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Plus_Remain_png.UI_Icon_Hud_Plus_Remain_png'",
}

local AdventureCareerMgr = LuaClass(MgrBase)

function AdventureCareerMgr:OnInit()
    self.ChildList = {}
    self.AllRedRecordData = {}
    self.IsNeedForceUpdataStatus = true
    self.ClassTypeData = {}
end

function AdventureCareerMgr:OnBegin()
    ModuleOpenMgr = _G.ModuleOpenMgr
    USaveMgr = _G.UE.USaveMgr
    self:ReadCareerGuideTaskRed()
end

function AdventureCareerMgr:OnEnd()
    self.ChildList = {}
    self.AllRedRecordData = {}
end

function AdventureCareerMgr:OnShutdown()
    self.ChildList = {}
    self.AllRedRecordData = {}
end

function AdventureCareerMgr:OnGameEventLoginRes(Params)
    if not Params.bReconnect then 
        self.IsNeedForceUpdataStatus = true
        self:ReadCareerGuideTaskRed()
    end
end

function AdventureCareerMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnLevelUpEvent)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function AdventureCareerMgr:OnUpdateQuest(Params)
    local IsInLevelSyncBefore = MajorUtil.IsInLevelSync()
    if not IsInLevelSyncBefore then
        self:InitTaskData()
        self:FillTaskStatus()
        self:UpdateAdventureCareerRed()
    end
end

function AdventureCareerMgr:GetChapterCfgData(ChapterID)
    if not CareerChapterCfg[ChapterID] then
        local Cfg = QuestChapterCfg:FindCfgByKey(ChapterID) 
        CareerChapterCfg[ChapterID] = Cfg or {}
    end

    return CareerChapterCfg[ChapterID] 
end

function AdventureCareerMgr:GetQuestCfgData(QuestID)
    if not CareerQuestCfg[QuestID] then
        local Cfg = QuestCfg:FindCfgByKey(QuestID)
        CareerQuestCfg[QuestID] = Cfg or {}
    end

    return CareerQuestCfg[QuestID] 
end

function AdventureCareerMgr:InitTaskData()
    if not next(CareerTaskData) then
        for _, v in pairs(ProfCareerCfg:FindAllCfg()) do
            if not CareerTaskData[v.Prof] then
                CareerTaskData[v.Prof] = {}
            end

            local Data = {
                ID = v.ID,
                ChapterID = v.ChapterID,
                Prof = v.Prof,
                RewardType = v.RewardType,
                RegisterProf = v.RegisterProf
            }

            local Cfg = self:GetChapterCfgData(v.ChapterID)
            local FinisihedQuestCfg = self:GetQuestCfgData(Cfg.EndQuest)
            local StartQuestCfg = self:GetQuestCfgData(Cfg.StartQuest)
            local TaskDetail = {
                Title = string.format(LSTR(520001), Cfg.MinLevel, Cfg.QuestName),
                Icon =  QuestMgr:GetChapterIconAtLog(v.ChapterID, Cfg.QuestType, false),
                FinishLootID = FinisihedQuestCfg.LootID,
                RewardType = v.RewardType,
                Prof = v.Prof,
                ChapterID = v.ChapterID,
                QuestType = Cfg.QuestType,
                StartQuestID = StartQuestCfg.id,
                FinishQuestID = FinisihedQuestCfg.id,
                AcceptMinLevel = Cfg.MinLevel,
            }

            CareerTaskIDMap[v.ChapterID] = TaskDetail
            table.insert(CareerTaskData[v.Prof], Data)
        end
    end
end

function AdventureCareerMgr:GetCurProfChangeProfData(Prof, IsAdvenTureJob)
    local Conditon = IsAdvenTureJob and ProtoRes.ProfCareerRewardType.ChangeProf or ProtoRes.ProfCareerRewardType.UnlockProf
    if next(CareerTaskData) and CareerTaskData[Prof] then
        local CurProfTaskData = CareerTaskData[Prof]
        for i, v in ipairs(CurProfTaskData) do
            if v.RewardType and v.RewardType == Conditon then
                local ChapterCfg = self:GetChapterCfgData(v.ChapterID)
                local StartQuestCfg = self:GetQuestCfgData(ChapterCfg.StartQuest)
                local Data = {
                    Level = ChapterCfg.MinLevel,
                    AcceptMapID = StartQuestCfg.AcceptMapID,
                    AcceptUIMapID = StartQuestCfg.AcceptUIMapID,
                    StartQuestID = StartQuestCfg.id,
                }

                return Data
            end
        end
    end
end

--- 对应职业TaskIDList
function AdventureCareerMgr:GetCurProfTaskData(Prof)
    if not CareerTaskData[Prof] or not next(CareerTaskData[Prof]) then
        self:InitTaskData()
    end

    return CareerTaskData[Prof] or {}
end

--- 章节任务详细信息
function AdventureCareerMgr:GetTaskDetailData(ChapterID)
    if not CareerTaskIDMap[ChapterID] or not CareerTaskIDMap[ChapterID].Status then
        self:FillTaskStatus()
    end

    return CareerTaskIDMap[ChapterID] or {}
end

function AdventureCareerMgr:CheckTaskActivate(StartQuestID, ChapterID, TaskData)
    local ChapterCfg = self:GetChapterCfgData(ChapterID)
    if not ChapterCfg then return false end
    local QuestCfgItem = self:GetQuestCfgData(StartQuestID)
    if not QuestCfgItem then return false end

    local MajorRoleData = _G.ActorMgr:GetMajorRoleDetail() or {}
    local ProfDetailList = MajorRoleData.Prof and MajorRoleData.Prof.ProfList or {}
    local ProfData = ProfDetailList[TaskData.Prof] or {}
    local CurLevel = ProfData and ProfData.Level or 0
    if CurLevel < (TaskData.AcceptMinLevel or 1) then return false end

    if QuestCfgItem.Profession ~= 0 and not ProfDetailList[QuestCfgItem.Profession] then
        return false
    end

    --- 前置任务是否完成
    local PreQuestNotFinished = (QuestCfgItem.OneofPreTask == 1)
    local PrevQuestsIDs = QuestCfgItem.PreTaskID
    if type(PrevQuestsIDs) == "table" and next(PrevQuestsIDs) then
        for _, PreQuestID in ipairs(PrevQuestsIDs) do
            if PreQuestNotFinished == (QuestMgr.EndQuestToChapterIDMap[PreQuestID] ~= nil) then
                PreQuestNotFinished = not PreQuestNotFinished
                break
            end
        end
    else
        PreQuestNotFinished = false
    end

    if PreQuestNotFinished then return false end

    -- 互斥任务
    local bAnyExclusiveAcceptedOrEnd = false
    local ExQuestsIDs = QuestCfgItem.ExclusiveTasks
    if type(ExQuestsIDs) == "table" and not next(ExQuestsIDs) then
        for _, ExQuestID in ipairs(ExQuestsIDs) do
            if not QuestMgr.QuestMap[ExQuestID] or not QuestMgr.EndQuestToChapterIDMap[ExQuestID] then
                bAnyExclusiveAcceptedOrEnd = true
                break
            end
        end
    end

    if bAnyExclusiveAcceptedOrEnd then return false end

    -- 相同任务完成状况
    local bAnySameAccepted = false
    local SmQuestsIDs = QuestCfgItem.SameTasks
    if type(SmQuestsIDs) == "table" and not next(SmQuestsIDs) then
        for _, SmQuestsID in ipairs(SmQuestsIDs) do
            if not QuestMgr.QuestMap[SmQuestsID] then
                bAnySameAccepted = true
                break
            end
        end
    end

    if bAnySameAccepted then return false end

    return true
end

local function MakeTaskStatusData(ChapterID, TaskData)
    local StartStatus = QuestMgr:GetQuestStatus(TaskData.StartQuestID)
    local EndStatus = QuestMgr:GetQuestStatus(TaskData.FinishQuestID)
    local Data = {
        Activate = AdventureCareerMgr:CheckTaskActivate(TaskData.StartQuestID, ChapterID, TaskData),
        ChangeProfTaskRed = false,
        Status = StartStatus == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and 0 or 1
    }

    if EndStatus == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
        Data.Status = QUEST_STATUS.CS_QUEST_STATUS_FINISHED
    end

    local ServerTime = TimeUtil.GetServerTime()
    local CurDayZeroTime = TimeUtil.GetCurTimeStampZero(ServerTime)
    if TaskData.RewardType == ProtoRes.ProfCareerRewardType.ChangeProf and Data.Activate and Data.Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
        local AdventureRedData = AdventureMgr:GetAdventureTaskSaveData()
        if AdventureRedData[string.format("SeenProf%dTime", TaskData.Prof)] then
            local LastSeenZero = TimeUtil.GetCurTimeStampZero(tonumber(AdventureRedData[string.format("SeenProf%dTime", TaskData.Prof)]))
            if CurDayZeroTime ~= LastSeenZero then
                Data.ChangeProfTaskRed = true
            end
        else
            Data.ChangeProfTaskRed = true
        end
    end

   return Data
end

function AdventureCareerMgr:UpdateQuestStatusByProf(Prof)
    local TaskData = CareerTaskData[Prof] or {}
    for i, v in ipairs(TaskData) do
        local TaskDetail = CareerTaskIDMap[v.ChapterID]
        if TaskDetail and TaskDetail.Status ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            self:FillOneTaskStatus(v.ChapterID, Prof)
        end
    end
end

--- 全量更新Status
function AdventureCareerMgr:FillTaskStatus()
    if self.IsNeedForceUpdataStatus then
        for k, v in pairs(CareerTaskIDMap) do
            self:FillOneTaskStatus(k, v.Prof)
        end

        self.IsNeedForceUpdataStatus = false
    else
        local MajorProfID = MajorUtil.GetMajorProfID()
        if MajorProfID then
            self:UpdateQuestStatusByProf(MajorProfID)
            local ProfCfg = MajorProfID and RoleInitCfg:FindProfForPAdvance(MajorProfID) or {}
            if ProfCfg and ProfCfg.Prof then
                self:UpdateQuestStatusByProf(ProfCfg.Prof)
            end
        end
    end
end

--- 单独更新TaskStatus
function AdventureCareerMgr:FillOneTaskStatus(ChapterID, ProfID)
    if CareerTaskIDMap[ChapterID] then
        local Status = MakeTaskStatusData(ChapterID, CareerTaskIDMap[ChapterID])
        CareerTaskIDMap[ChapterID].Status = Status.Status
        CareerTaskIDMap[ChapterID].Activate = Status.Activate
        CareerTaskIDMap[ChapterID].ChangeProfTaskRed = Status.ChangeProfTaskRed
        CareerTaskIDMap[ChapterID].Icon =  TaskStateIcon[Status.Status] or TaskStateIcon[QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED]
        if Status.ChangeProfTaskRed then
            self:AddAllRedRecordDataByProf(ProfID)
        end
    end
end

local function InsertListCond(v, RegProf, IsBaseProf, BaseProf)
    local CurTaskProf = IsBaseProf and v.Prof or BaseProf
    if v.RegisterProf == 2 then
        return true
    elseif v.RegisterProf == 0 and CurTaskProf ~= RegProf then
        return true
    elseif v.RegisterProf == 1 and CurTaskProf == RegProf then
        return true
    end

    return false
end

---ChildTab对应的TasKList
function AdventureCareerMgr:GetAdventureCareerTaskDataByProf(ProfDetail)
    local FinalTaskData = {}
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    local RegProf = RoleSimple.RegProf

    if ProfDetail then
        local TaskData = self:GetCurProfTaskData(ProfDetail.Prof)
        for i, v in ipairs(TaskData) do
            if InsertListCond(v, RegProf, ProfDetail.IsBaseProf) then
                table.insert(FinalTaskData, v)
            end
        end

        if ProfDetail.BaseProfTaskKey then
            local ProfCfg = RoleInitCfg:FindProfForPAdvance(ProfDetail.Prof)
            local BaseProfTaskData = self:GetCurProfTaskData(ProfDetail.BaseProfTaskKey)
            for i, v in ipairs(BaseProfTaskData) do
                if InsertListCond(v, RegProf, ProfDetail.IsBaseProf, ProfCfg.Prof) then
                    table.insert(FinalTaskData, v)
                end
            end
        end
    end
   
    return FinalTaskData
end

--- 构建ChildTabList
function AdventureCareerMgr:InitProfCareerChildList()
    self.ClassTypeData = {}
    self:InitTaskData()
    local ChildTab = {}
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail() or {}
    local ProfDetailList = RoleDetail.Prof and RoleDetail.Prof.ProfList or {}
    local HasUnlockSpecial = {}     -- 已经解锁了特职的基职集合
    if not next(ProfDetailList) then return {} end

    local ProfSortData = ProfMgr.GenProfTypeSortData(ProfDetailList)
    for i, SectionData in ipairs(ProfSortData) do
        if SectionData.lst and next(SectionData.lst) then
            for _, ItemData in ipairs(SectionData.lst) do
                local BaseProfData = RoleInitCfg:FindProfForPAdvance(ItemData.Prof)
                local IsCanInsert = CareerTaskData[ItemData.Prof] or (BaseProfData and CareerTaskData[BaseProfData.Prof])
                if IsCanInsert then
                    local ProfInfo = RoleInitCfg:FindCfgByKey(ItemData.Prof)
				    local ProfType = ProfInfo.Specialization
                    local IsBaseProf = true
                    if BaseProfData and next(BaseProfData) then
                        IsBaseProf = false
                    end

                    local BaseData = {
                        ClassType = SectionData.ProfClass,
                        IsUnLock = ItemData.bActive,
                        Prof = ItemData.Prof, 
                        ProfType = ProfType,
                        ProfFunType = ProfInfo.Function,
                        IsBaseProf = IsBaseProf,
                        Name = RoleInitCfg:FindRoleInitProfName(ItemData.Prof),
                        Icon = ProfInfo.SimpleIcon2,
                        ProfAssetAbbr = ProfInfo.ProfAssetAbbr,
                        ProfLevel = ItemData.Data and ItemData.Data.Level or 0,
                        RedDotName = string.format("%s%d/Prof%d", AdventureDefine.ProfTabRedDefine, SectionData.ProfClass, ItemData.Prof),
                    }

                    local ProfLevel = ProfInfo.ProfLevel
				    local ProfCfg = RoleInitCfg:FindProfForPAdvance(ItemData.Prof)
				    if ProfType == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
                        table.insert(ChildTab, BaseData)
				    else
                        if ProfLevel > 0 and not ItemData.bActive and ProfCfg then
                        --未解锁的有基职的特职不显示
                        elseif ItemData.AdvancedProf ~= 0 and EquipmentVM.lstProfDetail and EquipmentVM.lstProfDetail[ItemData.AdvancedProf] then
                        --解锁特职的基职不显示
                            HasUnlockSpecial[ItemData.AdvancedProf] = ItemData.Prof
                        else
                            table.insert(ChildTab, BaseData)
                        end
				    end
                end
            end
        end
    end

    table.sort(ChildTab, ProfMgr.SortComparisonType)
    for i, v in ipairs(ChildTab) do
        v.Key = AdventureDefine.MainTabIndex.ProfCareer * 10 + i
        if HasUnlockSpecial[v.Prof] then
            ChildTab[i].BaseProfTaskKey = HasUnlockSpecial[v.Prof]
        end
    end

    self.ChildList = ChildTab

    return ChildTab
end

function AdventureCareerMgr:GetCurClassTypeData(ClassType)
    if not next(self.ClassTypeData) then
        local ChildProfList = self:GetCacheChildData()
        for i, v in ipairs(ChildProfList) do
            for _, Type in ipairs(AdventureDefine.ProfClassType) do
                if v.ClassType == Type then
                    if not self.ClassTypeData[Type] then
                        self.ClassTypeData[Type] = {}
                    end

                    table.insert(self.ClassTypeData[Type], v)
                end
            end
        end
    end

    return self.ClassTypeData[ClassType]
end

function AdventureCareerMgr:GetCurClassDropDownData(ClassType, ProfID)
    local CurClassData = self:GetCurClassTypeData(ClassType) or {}
    local DropDownData = {}
	local MajorProfID = MajorUtil.GetMajorProfID()
    local FirstSelectProfID = ProfID or MajorProfID
	local FistSelectDropIndex
    local HaveMajorProf = false
	for i, v in ipairs(CurClassData) do
        local DropDataItem = 
        {
            Type = v.Prof, 
            Name = v.Name, 
            ClassType = ClassType,
            RedDotData = {
                RedDotName = v.RedDotName,
                IsStrongReminder = true,
            },
            bTextQuantityShow = v.ProfLevel ~= 0,
            TextQuantityStr = string.format(_G.LSTR(520002), v.ProfLevel),
            ImgIconColorbSameasText = true
        }

        if not v.IsUnLock then
            DropDataItem.IconPath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Lock2_png.UI_Comm_Img_Lock2_png'"
        end

		table.insert(DropDownData, DropDataItem)

        if FirstSelectProfID == v.Prof then
            FistSelectDropIndex = i
            HaveMajorProf = true
        end

        if not HaveMajorProf and v.IsUnLock and not FistSelectDropIndex then
            FistSelectDropIndex = i
        end
	end

    return DropDownData, FistSelectDropIndex or 1
end

function AdventureCareerMgr:GetCareerProfMenuChildTab()
    if not next(AdventureDefine.ProfMenuChildData) then
        for i, v in ipairs(AdventureDefine.ProfClassType) do
            local ChildData = {
                Key = i + AdventureDefine.MainTabIndex.ProfCareer * 10,
                ClassType = v,
                Name = ProfMgr.GetProfClassName(v),
                Icon = AdventureDefine.ProfClassTabIcon[v],
                RedDotName = string.format("%s%d", AdventureDefine.ProfTabRedDefine, v)
            }

            table.insert(AdventureDefine.ProfMenuChildData, ChildData)
        end
    end

    return AdventureDefine.ProfMenuChildData
end

function AdventureCareerMgr:GetCacheChildData()
    if not next(self.ChildList) then
        self:InitProfCareerChildList()
    end

    return self.ChildList
end

function AdventureCareerMgr:JumpToTargetProf(Prof)
    if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDJobQuest) then
        return
    end

    local Params = {
        JumpData = {
            [1] = AdventureDefine.MainTabIndex.ProfCareer,
            [2] = Prof,
        }
	}

    local UIViewMgr = require("UI/UIViewMgr")
    local UIViewID = require("Define/UIViewID")
	UIViewMgr:ShowView(UIViewID.AdventruePanel, Params)
end

function AdventureCareerMgr:GetCareerFirstSelectKey(JumpProf)
    local ProfID = JumpProf or MajorUtil.GetMajorProfID()
    local ChildTab = self:GetCareerProfMenuChildTab()
    local ProfClass = RoleInitCfg:FindProfClass(ProfID)
    for i, v in ipairs(ChildTab) do
        if v.ClassType == ProfClass then
			return v.Key
		end
    end

    return AdventureDefine.MainTabIndex.ProfCareer * 10 + 1
end

--- 解锁特职时 特职基职任务合并 红点按照特职prof处理增删
function AdventureCareerMgr:GetRealProfByTabProf(Prof)
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail() or {}
    local ProfDetailList = RoleDetail.Prof and RoleDetail.Prof.ProfList or {}
    local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(Prof) or 0
    if AdvanceProf ~= 0 and ProfDetailList[AdvanceProf] then
        return AdvanceProf
    end

    return Prof
end

function AdventureCareerMgr:UpdateAdventureCareerRed()
    local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
    for Prof, TaskData in pairs(CareerTaskData) do
        local RedName = string.format("%s%d/Prof%d", AdventureDefine.ProfTabRedDefine, RoleInitCfg:FindProfClass(Prof), Prof)
        if self:GetRealProfByTabProf(Prof) == Prof and self.AllRedRecordData[Prof] and self.AllRedRecordData[Prof] == 1 then
            local NeedAdd = false
            for i, v in ipairs(TaskData) do
                local TaskDetail = AdventureCareerMgr:GetTaskDetailData(v.ChapterID)
                if TaskDetail.Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and TaskDetail.Activate then
                    NeedAdd = true
                    break
                end
            end

            if NeedAdd then
                RedDotMgr:AddRedDotByName(RedName)
            else
                self:DelAllRedRecordDataByProf(Prof)
                RedDotMgr:DelRedDotByName(RedName)
            end
        else
            self:DelAllRedRecordDataByProf(Prof)
            RedDotMgr:DelRedDotByName(RedName)
        end
    end
end

function AdventureCareerMgr:OnLevelUpEvent(RoleDetail)
    if RoleDetail.Reason ~= ProtoCS.LevelUpReason.LevelUpReasonProf then return end

    if self.LevelUpCheckTimer then
        self:UnRegisterTimer(self.LevelUpCheckTimer)
    end

    local function CheckLevelUpRed()
        if not next(CareerTaskIDMap) then return end
        local Data = CareerTaskData[RoleDetail.ProfID] or {}
        for _, v in ipairs(Data) do
            self:FillOneTaskStatus(v.ChapterID, RoleDetail.ProfID)
        end

        for i, v in ipairs(Data) do
            local TaskData = CareerTaskIDMap[v.ChapterID]
            if TaskData.RewardType and TaskData.RewardType ~= ProtoRes.ProfCareerRewardType.ChangeProf then
                if TaskData.Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and TaskData.Activate then
                    if not self.AllRedRecordData[v.Prof] or self.AllRedRecordData[v.Prof] ~= 1 then
                        self:AddAllRedRecordDataByProf(v.Prof)
                    end
                end
            end
        end

        self:SaveCareerGuideTaskRed()
        self:UpdateAdventureCareerRed()
        for i, v in pairs(self.AllRedRecordData) do
            if v == 1 then
                _G.EventMgr:SendEvent(EventID.AdvenCareerTaskGuide)
                break
            end
        end

        self:UnRegisterTimer(self.LevelUpCheckTimer)
    end

    self.LevelUpCheckTimer = self:RegisterTimer(CheckLevelUpRed, 2, 0, 1)
end

function AdventureCareerMgr:IsCurTaskNeedRemindRed(ChapterID, Prof)
    if not ChapterID or not Prof then return false end
    local RealProf = self:GetRealProfByTabProf(Prof)
    if self.AllRedRecordData[RealProf] and self.AllRedRecordData[RealProf] == 1 then
        local CurTaskDetail = AdventureCareerMgr:GetTaskDetailData(ChapterID)
        if CurTaskDetail.Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and CurTaskDetail.Activate then
            return true
        end
    end

    return false
end

function AdventureCareerMgr:SaveTaskNotStartSeen(Prof, ChapterID)
    if not Prof or not ChapterID then
        return 
    end

    local AdventureRedData = AdventureMgr:GetAdventureTaskSaveData()
    if CareerTaskIDMap[ChapterID] and CareerTaskIDMap[ChapterID].ChangeProfTaskRed then
        CareerTaskIDMap[ChapterID].ChangeProfTaskRed = false
        self:DelAllRedRecordDataByProf(Prof)
    end

    local ServerTime = TimeUtil.GetServerTime()
    AdventureRedData[string.format("SeenProf%dTime", Prof)] = ServerTime
    local SaveJsonStr = Json.encode(AdventureRedData)
    USaveMgr.SetString(SaveKey.AdventureReadTime, SaveJsonStr, true)
end

function AdventureCareerMgr:AddAllRedRecordDataByProf(Prof)
    if not Prof then return end

    local RealProf = self:GetRealProfByTabProf(Prof)
    if RealProf ~= Prof then
        self.AllRedRecordData[Prof] = 0
    end

    self.AllRedRecordData[RealProf] = 1
    self:SaveCareerGuideTaskRed()
end

function AdventureCareerMgr:DelAllRedRecordDataByProf(Prof)
    if not Prof then return end
    if self.AllRedRecordData[Prof] then
        self.AllRedRecordData[Prof] = 0
    end

    local RealProf = self:GetRealProfByTabProf(Prof)
    if self.AllRedRecordData[RealProf] then
        self.AllRedRecordData[RealProf] = 0
    end 

    self:SaveCareerGuideTaskRed()
end

function AdventureCareerMgr:ReadCareerGuideTaskRed()
    self.AllRedRecordData = {}
    local AdventureRedData = AdventureMgr:GetAdventureTaskSaveData()
    local CareerGuideTaskRed = AdventureRedData.CareerGuideTaskRed or ""
    local SplitStr = string.split(CareerGuideTaskRed or "",";")
    for i, v in ipairs(SplitStr) do
        self.AllRedRecordData[tonumber(v)] = 1
    end
end

function AdventureCareerMgr:SaveCareerGuideTaskRed()
    local AdventureRedData = AdventureMgr:GetAdventureTaskSaveData()
    local RedDotStr = ""
    for Key, Value in pairs(self.AllRedRecordData) do
        if Value == 1 then
            if string.isnilorempty(RedDotStr) then
                RedDotStr = string.format("%d;", Key)
            else
                RedDotStr = string.format("%s%d;", RedDotStr, Key)
            end
        end
    end

    AdventureRedData.CareerGuideTaskRed = RedDotStr
    local SaveJsonStr = Json.encode(AdventureRedData)
    USaveMgr.SetString(SaveKey.AdventureReadTime, SaveJsonStr, true)
end

function AdventureCareerMgr:ClearAdventureCareerRed()
    local AdventureRedData = AdventureMgr:GetAdventureTaskSaveData()
    AdventureRedData = {}
    local SaveJsonStr = Json.encode(AdventureRedData)
    USaveMgr.SetString(SaveKey.AdventureReadTime, SaveJsonStr, true)
    self:InitTaskData()
    self:FillTaskStatus()
    self:UpdateAdventureCareerRed()
end

function AdventureCareerMgr:JumpChapterOnMap(ChapterID)
    if not ChapterID then return end
        
    local ChapterCfg = AdventureCareerMgr:GetChapterCfgData(ChapterID)
	local StartQuestCfg = AdventureCareerMgr:GetQuestCfgData(ChapterCfg.StartQuest)
	local Status = QuestMgr:GetQuestStatus(StartQuestCfg.id)
	local TargetQuestID = StartQuestCfg.id

    if Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
		_G.WorldMapMgr:ShowWorldMapQuest(StartQuestCfg.AcceptMapID, StartQuestCfg.AcceptUIMapID, StartQuestCfg.id)
		local WorldMapPanel = _G.UIViewMgr:FindView(_G.UIViewID.WorldMapPanel)
		local MarkerView = WorldMapPanel.MapContent:GetMapMarkerByID(StartQuestCfg.id)
		self:RegisterTimer(function()
			if MarkerView then
				MarkerView:playAnimation(MarkerView.AnimNew)
			end
		end, 0, 2.97, 3)
	else
		local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
		local AllVMs = QuestMainVM.QuestLogVM:GetAllChapterVMs()
		for i = 1, AllVMs:Length() do
			local VM = AllVMs:Get(i)
			if VM.ChapterID == ChapterID then
				local MapID = VM.TargetMapID
				TargetQuestID = VM.QuestID
				if (MapID == nil) or (MapID == 0) then return end
				local UIMapID = MapUtil.GetUIMapID(MapID)
				_G.WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID, TargetQuestID)
				break
			end
		end
	end
end

return AdventureCareerMgr