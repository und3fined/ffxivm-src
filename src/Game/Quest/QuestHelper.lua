--
-- Author: lydianwang
-- Date: 2022-05-30
-- Description:
--

local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local QuestDefine = require("Game/Quest/QuestDefine")
local CounterMgr = require("Game/Counter/CounterMgr")
local EventID = require("Define/EventID")
local StorySetting = require("Game/Story/StorySetting")
local TimeUtil = require("Utils/TimeUtil")
local UIViewID = require("Define/UIViewID")

-- Proto
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

-- DB
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local QuestCfg = require("TableCfg/QuestCfg")
local TargetCfg = require("TableCfg/QuestTargetCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local DialogueBranchCfg = require("TableCfg/DialogueBranchCfg")
local QuestGenreCfg = require("TableCfg/QuestGenreCfg")
local DialogCfg = require("TableCfg/DialogCfg")
local DefaultDialogCfg = require("TableCfg/DefaultDialogCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local QuestServerActionCfg = require("TableCfg/QuestServerActionCfg")

local TARGET_STATUS =   ProtoCS.CS_QUEST_NODE_STATUS
local ACCEPT_TYPE =     ProtoRes.QUEST_ACCEPT_TYPE
local TARGET_TYPE =     ProtoRes.QUEST_TARGET_TYPE
local SERVER_TYPE =     ProtoRes.QUEST_SERVER_TYPE
local QUEST_TYPE =      ProtoRes.QUEST_TYPE
local ModuleType = ProtoRes.module_type
local CONNECT_TYPE = ProtoRes.target_connect_type

local LSTR = _G.LSTR
local EActorType = _G.UE.EActorType
local RDType = QuestDefine.RestrictedDialogType
local RDID = QuestDefine.RestrictedDialogID

local QuestHelper = {}

local QuestMgr = nil
local QuestRegister = nil
local MapEditDataMgr = nil
local ProfMgr = nil
local StoryMgr = nil
local QuestTrackMgr = nil
local EventMgr = nil
local QuestCondMgr = nil

local QuestNumLimit = 99
local QuestCondBit = QuestDefine.CondBit

function QuestHelper.Init()
    QuestMgr = _G.QuestMgr
    QuestRegister = QuestMgr.QuestRegister
    MapEditDataMgr = _G.MapEditDataMgr
    ProfMgr = _G.ProfMgr
    StoryMgr = _G.StoryMgr
    QuestTrackMgr = _G.QuestTrackMgr
    EventMgr = _G.EventMgr
    QuestCondMgr = _G.QuestCondMgr

    local Value = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_NUM_ACTIVE_QUEST, "Value")
    if Value ~= nil then
        QuestNumLimit = Value[1]
    end
end

-- ==================================================
-- 判断条件
-- ==================================================

---@param QuestID int32
---@param ChapterCfgItem luatable
---@return boolean
function QuestHelper.CheckChapterFirstQuest(QuestID, ChapterCfgItem)
    if ChapterCfgItem == nil then return false end
    return QuestID == ChapterCfgItem.StartQuest
end

---@param QuestID int32
---@param ChapterCfgItem luatable
---@return boolean
function QuestHelper.CheckChapterLastQuest(QuestID, ChapterCfgItem)
    if ChapterCfgItem == nil then return false end
    return QuestID == ChapterCfgItem.EndQuest
end

---@param QuestID int32
---@param QuestCfgItem luatable
---@param ChapterCfgItem luatable
---@param bForceNotCheckAccept boolean
---@return boolean
function QuestHelper.CheckCanActivate(QuestID, QuestCfgItem, ChapterCfgItem, bForceNotCheckAccept)
    QuestCfgItem = QuestCfgItem or QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return false end
    ChapterCfgItem = ChapterCfgItem or QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return false end

    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.QuestUpdate) then
        --任务已接取
        local Quest = QuestMgr.QuestMap[QuestID]
        if Quest ~= nil then return false end

        -- 前置任务完成状况
        local PreQuestNotFinished = (QuestCfgItem.OneofPreTask == 1) -- “任一前置”勾选项
        local PrevQuestsIDs = QuestCfgItem.PreTaskID
        if type(PrevQuestsIDs) == "table" and next(PrevQuestsIDs) ~= nil then
            for _, PreQuestID in ipairs(PrevQuestsIDs) do
                if PreQuestNotFinished == (QuestMgr.EndQuestToChapterIDMap[PreQuestID] ~= nil) then
                    PreQuestNotFinished = not PreQuestNotFinished
                    break
                end
            end
        else
            PreQuestNotFinished = false
        end
        if PreQuestNotFinished then return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.QuestUpdate, false) end

        -- 任务已完成（含计数）
        local bQuestEnd
        if QuestCfgItem.AcceptCounterID ~= 0 and QuestCfgItem.AcceptCountLimitAccept == 1 then
            bQuestEnd = (QuestMgr.QuestMap[QuestID] ~= nil)
                and QuestRegister:CheckQuestCounterToLimit(QuestCfgItem.AcceptCounterID)
        elseif QuestCfgItem.SubmitCounterID ~= 0 and QuestCfgItem.SubmitCountLimitAccept == 1 then
            bQuestEnd = QuestRegister:CheckQuestCounterToLimit(QuestCfgItem.SubmitCounterID)
        else
            bQuestEnd = (QuestMgr.EndQuestToChapterIDMap[QuestID] ~= nil)
        end
        if bQuestEnd then return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.QuestUpdate, false) end

        -- 互斥任务完成状况
        local bAnyExclusiveAcceptedOrEnd = false
        local ExQuestsIDs = QuestCfgItem.ExclusiveTasks
        if type(ExQuestsIDs) == "table" and next(ExQuestsIDs) ~= nil then
            for _, ExQuestID in ipairs(ExQuestsIDs) do
                if QuestMgr.QuestMap[ExQuestID] ~= nil
                or QuestMgr.EndQuestToChapterIDMap[ExQuestID] ~= nil then
                    bAnyExclusiveAcceptedOrEnd = true
                    break
                end
            end
        end
        if bAnyExclusiveAcceptedOrEnd then return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.QuestUpdate, false) end

        -- 相同任务完成状况
        local bAnySameAccepted = false
        local SmQuestsIDs = QuestCfgItem.SameTasks
        if type(SmQuestsIDs) == "table" and next(SmQuestsIDs) ~= nil then
            for _, SmQuestsID in ipairs(SmQuestsIDs) do
                if QuestMgr.QuestMap[SmQuestsID] ~= nil then
                    bAnySameAccepted = true
                    break
                end
            end
        end
        if bAnySameAccepted then return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.QuestUpdate, false) end

        QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.QuestUpdate, true)
    end

    if bForceNotCheckAccept ~= true then -- 特殊情况的优化选项
        if (ChapterCfgItem.HideWhenCannotAccept == 1)
        and (not QuestHelper.CheckCanAccept(QuestID, QuestCfgItem, ChapterCfgItem)) then
            return false
        end
    end

    return QuestCondMgr:IsQuestCondPass(QuestID, QuestCondBit.QuestUpdate)
end

local AcceptBits = QuestCondBit.ProfSwitch | QuestCondBit.ProfActivate
    | QuestCondBit.RegisterProf | QuestCondBit.Counter | QuestCondBit.GrandCompany
    | QuestCondBit.Activity | QuestCondBit.Score | QuestCondBit.ChocoboLevel

---@param QuestID int32
---@param QuestCfgItem luatable
---@param ChapterCfgItem luatable
---@return boolean
function QuestHelper.CheckCanAccept(QuestID, QuestCfgItem, ChapterCfgItem)
    QuestCfgItem = QuestCfgItem or QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return false end
    ChapterCfgItem = ChapterCfgItem or QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return false end

    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if RoleSimple == nil then return false end

    -- 等级限制（接取和提交才限制等级）
    if ChapterCfgItem.StartQuest == QuestID or ChapterCfgItem.EndQuest == QuestID then
        local TrueLevel = MajorUtil.GetTrueMajorLevel()
        if TrueLevel < (ChapterCfgItem.MinLevel or 1) then
            QuestMgr:LogQuestCheckInfo(nil, "low TrueLevel "..TrueLevel)
            return false
        end
    end

    -- 时间限制
    local OpenDayLimit = ChapterCfgItem.OpenDayLimit
    if OpenDayLimit and OpenDayLimit ~= 0 then
        local LimitTime = TimeUtil.GetOpenServerOffsetTS(OpenDayLimit, ChapterCfgItem.OpenHourLimit)
        if LimitTime > TimeUtil.GetServerLogicTime() then
            QuestMgr:LogQuestCheckInfo(nil, "over LimitTime "..LimitTime)
            if QuestCfgItem.QuestType ~= QUEST_TYPE.QUEST_TYPE_MAIN then --主线不在这里处理
                QuestRegister:RegisterTimeLimit(QuestID, LimitTime)
            end
            return false
        else
            if QuestCfgItem.QuestType ~= QUEST_TYPE.QUEST_TYPE_MAIN then
                QuestRegister:UnRegisterTimeLimit(QuestID)
            end
        end
    end

    -- 职业(类)限制
    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.ProfSwitch) then
        local bProfNotMatched = false
        local CurrProf = RoleSimple.Prof
        if QuestCfgItem.Profession ~= 0 then
            bProfNotMatched = (CurrProf ~= QuestCfgItem.Profession)
        elseif QuestCfgItem.ProfessionClass ~= 0 then
            bProfNotMatched = not ProfMgr.CheckProfClass(CurrProf, QuestCfgItem.ProfessionClass)
        end
        if bProfNotMatched then
            QuestMgr:LogQuestCheckInfo(QuestCondBit.ProfSwitch)
            return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.ProfSwitch, false)
        else
            QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.ProfSwitch, true)
        end
    end

    -- 拥有职业(类)限制
    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.ProfActivate) then
        local bOwnProfNotMatched = false
        local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
        local RoleProfList = {}
        if MajorRoleDetail and MajorRoleDetail.Prof and  MajorRoleDetail.Prof.ProfList then
            RoleProfList = MajorRoleDetail.Prof.ProfList
        end
        local RequiredProfData = nil
        if QuestCfgItem.OwnProfession and (QuestCfgItem.OwnProfession ~= 0) then
            for OwnProfID, ProfData in pairs(RoleProfList) do
                if OwnProfID == QuestCfgItem.OwnProfession then
                    RequiredProfData = ProfData
                    break
                end
            end
            if (RequiredProfData == nil) or (RequiredProfData.Level < QuestCfgItem.OwnProfessionLevel) then
                bOwnProfNotMatched = true
            end
        elseif QuestCfgItem.OwnProfessionClass and (QuestCfgItem.OwnProfessionClass ~= 0) then
            for OwnProfID, ProfData in pairs(RoleProfList) do
                if ProfMgr.CheckProfClass(OwnProfID, QuestCfgItem.OwnProfessionClass) then
                    RequiredProfData = ProfData
                    break
                end
            end
            if (RequiredProfData == nil) or (RequiredProfData.Level < QuestCfgItem.OwnProfessionLevel) then
                bOwnProfNotMatched = true
            end
        end
        if bOwnProfNotMatched then
            QuestMgr:LogQuestCheckInfo(QuestCondBit.ProfActivate)
            return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.ProfActivate, false)
        else
            QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.ProfActivate, true)
        end
    end

    -- 首发职业限制
    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.RegisterProf) then
        local bRegProfRestriction = false
        local bNotRegProfRestriction = false
        local RegProf = RoleSimple.RegProf
        if (QuestCfgItem.RegisterProfession or 0) ~= 0 then
            bRegProfRestriction = (RegProf ~= QuestCfgItem.RegisterProfession)
        end
        if (QuestCfgItem.RegisterProfessionNot or 0) ~= 0 then
            bNotRegProfRestriction = (RegProf == QuestCfgItem.RegisterProfessionNot)
        end
        if bRegProfRestriction or bNotRegProfRestriction then
            QuestMgr:LogQuestCheckInfo(QuestCondBit.RegisterProf)
            return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.RegisterProf, false)
        else
            QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.RegisterProf, true)
        end
    end

    -- 副本完成次数限制
    local PWorldRestriction = QuestCfgItem.SceneFinish or {}
    if next(PWorldRestriction) and QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.Counter) then
        for _, PWorldID in ipairs(PWorldRestriction) do
            local SucceedCounterID = PworldCfg:FindValue(PWorldID, "SucceedCounterID")
            if (SucceedCounterID == nil) or (SucceedCounterID == 0)
            or (CounterMgr:GetCounterCurrValue(SucceedCounterID) == 0) then
                QuestMgr:LogQuestCheckInfo(QuestCondBit.Counter)
                return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.Counter, false)
            else
                QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.Counter, true)
            end
        end
    end

    -- 军队限制
    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.GrandCompany) then
        local bNotMatched = false
        local NeedGrandCompany = QuestCfgItem.GrandCompany or 0
        if NeedGrandCompany > 0 then
            local NeedMilitaryRank = QuestCfgItem.GrandCompanyMilitaryRank or 0
            local CompoanySealInfo = _G.CompanySealMgr:GetCompanySealInfo()
            if CompoanySealInfo then
                bNotMatched = (NeedGrandCompany ~= CompoanySealInfo.GrandCompanyID) or
                (NeedMilitaryRank > _G.CompanySealMgr:GetGrandCompanyRank())
            end
        end

        if bNotMatched then
            QuestMgr:LogQuestCheckInfo(QuestCondBit.GrandCompany)
            return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.GrandCompany, false)
        else
            QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.GrandCompany, true)
        end
    end

    -- 活动限制
    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.Activity) then
        local bNotMatched = false
        local NeedActivity = ChapterCfgItem.Activity or 0
        if NeedActivity > 0 then
            bNotMatched = not QuestRegister:IsActivityOpen(NeedActivity)
            QuestMgr.QuestRegister:RegisterActivityQuest(QuestID, NeedActivity)
        end
        if bNotMatched then
            QuestMgr:LogQuestCheckInfo(QuestCondBit.Activity)
            return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.Activity, false)
        else
            QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.Activity, true)
        end
    end

    -- 积分限制
    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.Score) then
        local bNotMatched = false
        local NeedScoreType = ChapterCfgItem.ScoreType or 0
        if NeedScoreType > 0 then
            local NeedScoreNum = ChapterCfgItem.ScoreNum or 0
            local CurScoreNum = _G.ScoreMgr:GetScoreValueByID(NeedScoreType)
            bNotMatched = NeedScoreNum > CurScoreNum
        end
        if bNotMatched then
            QuestMgr:LogQuestCheckInfo(QuestCondBit.Score)
            return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.Score, false)
        else
            QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.Score, true)
        end
    end

    -- 陆行鸟等级限制
    if QuestCondMgr:IsCondChanged(QuestID, QuestCondBit.ChocoboLevel) then
        local bNotMatched = false
        local NeedLevel = ChapterCfgItem.BuddyLevel or 0
        if NeedLevel > 0 then
            local HighestLevel = _G.ChocoboMgr:GetChocoboMaxLevel()
            bNotMatched = (HighestLevel < NeedLevel)
        end
        if bNotMatched then
            QuestMgr:LogQuestCheckInfo(QuestCondBit.ChocoboLevel)
            return QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.ChocoboLevel, false)
        else
            QuestCondMgr:SetQuestCond(QuestID, QuestCondBit.ChocoboLevel, true)
        end
    end

    local Result = QuestCondMgr:IsQuestCondPass(QuestID, AcceptBits)
    if not Result then
        local TempCondPassed = QuestCondMgr.CondPassedMap[QuestID]
        QuestMgr:LogQuestCheckInfo(nil, "IsQuestCondPass "..TempCondPassed)
    end
    return Result
end

---@param FixedProf int32
---@param CurrProf int32
---@return boolean
function QuestHelper.CheckFixedProf(FixedProf, CurrProf)
    if FixedProf == nil then
        return true
    end
    local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(FixedProf)
    return CurrProf == FixedProf or CurrProf == AdvanceProf
end

---@param Targets table
---@param TargetID int32
---@param TargetRecord table
---@param LootItemInfo table
function QuestHelper.GetTargetLootInfo(Targets, TargetID, TargetRecord, LootItemInfo)
    local Target = Targets[TargetID]
    if Target == nil or TargetRecord[TargetID] then
        return
    end
    if Target.LootIDs ~= nil then
        for _, LootID in ipairs(Target.LootIDs) do
            QuestHelper.GetLootItemInfo(LootID, LootItemInfo)
        end
    end
    if Target.Cfg.ConnectType == CONNECT_TYPE.COMBINED and ((Target.Cfg.NextTarget or 0) > 0) then
        QuestHelper.GetTargetLootInfo(Targets, Target.Cfg.NextTarget, TargetRecord, LootItemInfo)
    end
    TargetRecord[TargetID] = true
end

---@param LootMapID int32
function QuestHelper.GetLootItemInfo(LootMapID, LootItemInfo)
    local LootMappingCfgItem = LootMappingCfg:FindCfg(string.format("ID = %d", LootMapID))
	if (LootMappingCfgItem == nil) then
		return
	end

	local LootID = LootMappingCfgItem.Programs[1].ID -- 任务奖励规定只有一种掉落方案
	local LootItemList = ItemUtil.GetLootItems(LootID)
    if LootItemList == nil then
        return
    end
    for _, Item in pairs(LootItemList) do
        if Item.IsScore == false then
            local Value = LootItemInfo[Item.ResID] or 0
            LootItemInfo[Item.ResID] = Value + Item.Num
        end
    end
end

---@param QuestID int32
---@param TargetID int32
---@return int32
function QuestHelper.GetLootItemsCount(QuestID, TargetID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then 
        return -1
    end
    -- 收集任务奖励物品信息
    local LootItemInfo = {}
    if QuestCfgItem.LootID ~= 0 then
        QuestHelper.GetLootItemInfo(QuestCfgItem.LootID, LootItemInfo)
    else
        local Quest = QuestMgr.QuestMap[QuestID]
        if Quest ~= nil then
            -- 记录一下已经处理过的目标节点, 防止组合目标被重复处理
            local TargetRecord = {}
            for _, Target in pairs(Quest.Targets) do
                if Target.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS then
                    local bIsNotRecord = (TargetRecord[Target.TargetID] == nil)
                    local bIsMatchTarget = (TargetID == nil) or (TargetID == Target.TargetID)
                    if bIsNotRecord and bIsMatchTarget then
                        QuestHelper.GetTargetLootInfo(Quest.Targets, Target.TargetID, TargetRecord, LootItemInfo)
                    end
                end
            end
        end
    end
    if table.length(LootItemInfo) == 0 then
        return -1
    end
    local BagSlotCount = _G.BagMgr:CheckLootItemInfo(LootItemInfo)
    return BagSlotCount > 0 and BagSlotCount or -1
end

---@param QuestID int32
---@param TargetID int32
---@return boolean
function QuestHelper.CheckLootItems(QuestID, TargetID)
    return _G.BagMgr:GetBagLeftNum() >= QuestHelper.GetLootItemsCount(QuestID, TargetID)
end

---@param QuestID int32
---@param QuestCfgItem luatable
---@param ChapterCfgItem luatable
---@param TargetID int32
---@return boolean
function QuestHelper.CheckCanProceedWithLoot(QuestID, QuestCfgItem, ChapterCfgItem, TargetID)
    return QuestHelper.CheckLootItems(QuestID, TargetID) and QuestHelper.CheckCanProceed(QuestID, QuestCfgItem, ChapterCfgItem)
end

---任务不受限（目标条件不满足也能推进任务）
function QuestHelper.CheckUnrestricted(QuestID, QuestCfgItem, ChapterCfgItem)
    QuestCfgItem = QuestCfgItem or QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return false end
    ChapterCfgItem = ChapterCfgItem or QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return false end

    -- 先检查是否可接取（后续可能会各自独立检查）
    if not QuestHelper.CheckCanAccept(QuestID, QuestCfgItem, ChapterCfgItem) then return false end

    -- 还未接取时，直接返回true
    local Quest = QuestMgr.QuestMap[QuestID]
    if Quest == nil then return true end

    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if RoleSimple == nil then return false end

    -- 职业固定任务
    local CurrProf = RoleSimple.Prof
    local FixedProf = QuestRegister.FixedProfOnAccept[ChapterCfgItem.id]
    if not QuestHelper.CheckFixedProf(FixedProf, CurrProf) then
        QuestMgr:LogQuestCheckInfo(nil, "not FixedProf "..CurrProf)
        return false
    end

    -- 玩家状态限制
    if Quest.StateRestrictions ~= nil then
        local bPassRestriction = true
        for _, Restriction in pairs(Quest.StateRestrictions) do
            if not Restriction:CheckPassRestriction() then
                QuestMgr:LogQuestCheckInfo(nil, "Restriction "..(Restriction.LogicID or 0))
                bPassRestriction = false
                break
            end
        end
        if not bPassRestriction then return false end
    end

    local bQuestEnd = false
    if QuestCfgItem.SubmitCounterID ~= 0 and QuestCfgItem.SubmitCountLimitSubmit == 1 then
        bQuestEnd = QuestRegister:CheckQuestCounterToLimit(QuestCfgItem.SubmitCounterID)
    end
    if bQuestEnd then QuestMgr:LogQuestCheckInfo(nil, "CounterToLimit") end
    if bQuestEnd then return false end

    return true
end

---是否能推进（需要目标条件满足）
---@param QuestID int32
---@param QuestCfgItem luatable
---@param ChapterCfgItem luatable
---@return boolean
function QuestHelper.CheckCanProceed(QuestID, QuestCfgItem, ChapterCfgItem)
    return QuestHelper.CheckUnrestricted(QuestID, QuestCfgItem, ChapterCfgItem) and QuestHelper.CheckCanFinishTargets(QuestID)
end

---@param QuestID int32
---@return boolean
function QuestHelper.CheckCanFinishTargets(QuestID)
    if not QuestID then
        return false
    end
    local Quest = QuestMgr.QuestMap[QuestID]
    if Quest and Quest.Targets then
        for _, Target in pairs(Quest.Targets) do
            if Target.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS
            and not Target:CheckCanFinish() then
                QuestMgr:LogQuestCheckInfo(nil, "Target "..(Target.TargetID))
                return false
            end
        end
    end
    return true
end

---@param Cfg luatable
---@return boolean
function QuestHelper.CheckAutoDialogSubmit(Cfg)
    if Cfg == nil then return false end

    return Cfg.AutoDialog == 1 and Cfg.IsAutoFinish == 0
        and Cfg.FinishNpc ~= 0 and Cfg.FinishDialogID ~= 0
end

---尝试重新激活任务（如日常、周常等）
---@param QuestID int32
---@param Cfg luatable
---@return boolean
function QuestHelper.CheckCanReactivate(QuestID, QuestCfgItem, ChapterCfgItem)
    QuestCfgItem = QuestCfgItem or QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return false end

    if QuestCfgItem.SubmitCounterID == 0 and QuestCfgItem.AcceptCounterID == 0 then return false end

    return QuestHelper.CheckCanActivate(QuestID, QuestCfgItem, ChapterCfgItem)
end

---@return boolean
function QuestHelper.CheckQuestNumReachLimit()
    local QuestNum = QuestRegister.QuestNum
    if QuestNum >= QuestNumLimit then
		MsgTipsUtil.ShowTips("任务数量已经达到上限，先去完成手上的任务吧")
        return true
    end
    return false
end

---@param QuestID int32
---@param TargetID int32
---@param TargetType TARGET_TYPE
---@return boolean
function QuestHelper.CheckAutoDoTarget(QuestID, TargetID, TargetType)
    TargetType = TargetType or TargetCfg:FindValue(TargetID, "m_iTargetType")
    if TargetType == nil then return false end

    local TargetClassParams = QuestDefine.TargetClassParams[TargetType]

    return TargetClassParams and TargetClassParams.bCanAutoDoTarget
        and QuestCfg:FindValue(QuestID, "AutoDoTarget") == 1
end

---@param QuestID int32
---@param TargetID int32
------@return boolean
function QuestHelper.CheckIsInteractTarget(QuestID, TargetID)
    if not QuestID or not TargetID then
        return false
    end
    local TargetCfgItem = QuestHelper.GetTargetCfgItem(QuestID, TargetID)
    if TargetCfgItem then
        return TargetCfgItem.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_INTERACT
    end
    return false
end

---@param QuestID int32
---@param TargetID int32
---@param ItemID int32
------@return boolean
function QuestHelper.CheckIsUseItemTarget(QuestID, TargetID, ItemID)
    if not QuestID or not TargetID then
        return false
    end
    local TargetCfgItem = QuestHelper.GetTargetCfgItem(QuestID, TargetID)
    if not TargetCfgItem then
        return false
    end

    if TargetCfgItem.m_iTargetType ~= TARGET_TYPE.QUEST_TARGET_TYPE_USE_QUEST_ITEM then
        return false
    end

    local Quest = QuestMgr.QuestMap[QuestID]
    if Quest then
        local Target = Quest.Targets[TargetID]
        if Target then
            return Target.ItemID == ItemID
        end
    end
    return false
end


---@param Target TargetBase
---@return boolean
function QuestHelper.CheckTargetPlaySeq(Target)
    if not (Target and Target.Cfg) then
        return false
    end
    local bRet = false
    local TargetType = Target.Cfg.m_iTargetType

    if TargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_SEQUENCE then
        bRet = true
    elseif TargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_DIALOG then
        local DialogID = Target:GetDialogID()
        local DialogueType = QuestDefine.GetDialogueType(DialogID)
        if DialogueType == QuestDefine.DialogueType.DialogueSequence
        or DialogueType == QuestDefine.DialogueType.CutSceneSequence then
            bRet = true
        end
    end

    return bRet
end

---@param Target TargetBase
---@return bool
function QuestHelper.CheckTeleportAfterTarget(Target)
    if not (Target and Target.Cfg) then
        return false
    end
    local SvrBehaviors = Target.Cfg.m_aiTaskTargetFinishLogic
    if not SvrBehaviors then
        return false
    end

    for _, ID in ipairs(SvrBehaviors) do
        local Cfg = QuestServerActionCfg:FindCfgByKey(ID)
        if Cfg and Cfg.m_iServerTaskExpressionType == SERVER_TYPE.QUEST_SERVER_TYPE_TELEPORT then
            return true
        end
    end

    return false
end

---@param Target TargetBase
---@return bool
function QuestHelper.CheckTeleportAfterContinuousSequence(Target)
    while (Target ~= nil) and QuestHelper.CheckTargetPlaySeq(Target) do
        if Target.bTeleportAfterTarget then
            return true
        end
        Target = Target:GetNextTarget()
    end
    return false
end

---@return boolean
function QuestHelper.CheckIsMainline(ChapterOrQuestID, CfgItem, bUseQuestIDAndCfg)
    if ChapterOrQuestID == nil then return false end

    local ChapterID, ChapterCfgItem
    if bUseQuestIDAndCfg then
        local QuestCfgItem = CfgItem or QuestHelper.GetQuestCfgItem(ChapterOrQuestID)
        ChapterID = QuestCfgItem and QuestCfgItem.ChapterID or 0
        ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
    else
        ChapterID = ChapterOrQuestID
        ChapterCfgItem = CfgItem or QuestHelper.GetChapterCfgItem(ChapterID)
    end

    if ChapterCfgItem == nil then return false end

    local GenreID = ChapterCfgItem.QuestGenreID
    return (GenreID >= 10000) and (GenreID < 20000) -- R任务分类表
end

-- ==================================================
-- NPC任务列表
-- ==================================================

local function CheckAcceptNpcValid(Cfg)
    return (Cfg ~= nil) and (Cfg.StartNpc ~= 0)
        and (Cfg.AcceptType == ACCEPT_TYPE.QUEST_ACCEPT_TYPE_DIALOG)
end

local function CheckSubmitNpcValid(Cfg)
    return (Cfg ~= nil) and (Cfg.FinishNpc ~= 0) and (Cfg.IsAutoFinish == 0)
end

---更新NPC身上已激活的任务
---@param QuestID int32
function QuestHelper.AddNpcActivatedQuest(QuestCfgItem, ChapterCfgItem)
    if QuestCfgItem == nil or ChapterCfgItem == nil then return end
    if not CheckAcceptNpcValid(QuestCfgItem) then return end

    local bRegSuccess = QuestRegister:RegisterQuestOnNpc(QuestCfgItem.StartNpc, QuestCfgItem.id,
        ChapterCfgItem.QuestType, QuestCfgItem.AcceptDialogID, ChapterCfgItem.QuestName)
    if bRegSuccess then
        QuestTrackMgr:AddMapQuestParam(QuestCfgItem.AcceptMapID, QuestCfgItem.id, nil,
            QuestDefine.NaviType.NpcResID, QuestCfgItem.StartNpc, nil, QuestCfgItem.AcceptUIMapID)
    end
end

---移除NPC身上已激活的任务
---@param QuestID int32
function QuestHelper.RemoveNpcActivatedQuest(QuestCfgItem)
    if QuestCfgItem == nil then return end
    if not CheckAcceptNpcValid(QuestCfgItem) then return end

    local bUnRegSuccess = QuestRegister:UnRegisterQuestOnNpc(QuestCfgItem.StartNpc, QuestCfgItem.id)
    if bUnRegSuccess then
        QuestTrackMgr:RemoveMapQuestParam(QuestCfgItem.AcceptMapID, QuestCfgItem.id, nil)
    end
end

---更新NPC身上的目标
---@param QuestID int32
---@param Target TargetBase
function QuestHelper.AddNpcQuestTarget(QuestID, Target)
    if (Target == nil) then return end
    local bGetNpcID = (Target:GetNpcID() ~= 0)
    local bGetNpcIDList = (next(Target:GetNpcIDList()) ~= nil)
    if not (bGetNpcID or bGetNpcIDList) then return end

    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return end

    if Target.Cfg.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_EQUIP
    and QuestCfgItem.IsAutoFinish == 1 then
        return
    end

    if bGetNpcID then
        QuestRegister:RegisterQuestOnNpc(Target:GetNpcID(), QuestID,
            ChapterCfgItem.QuestType, Target:GetDialogID(), ChapterCfgItem.QuestName, Target)

    elseif bGetNpcIDList then
        for _, NpcID in ipairs(Target:GetNpcIDList()) do
            QuestRegister:RegisterQuestOnNpc(NpcID, QuestID,
                ChapterCfgItem.QuestType, Target:GetDialogID(), ChapterCfgItem.QuestName, Target)
        end
    end
end

---移除NPC身上的任务目标
---@param QuestID int32
---@param Target TargetBase
function QuestHelper.RemoveNpcQuestTarget(QuestID, Target)
    if (Target == nil) then return end
    local bGetNpcID = (Target:GetNpcID() ~= 0)
    local bGetNpcIDList = (next(Target:GetNpcIDList()) ~= nil)
    if not (bGetNpcID or bGetNpcIDList) then return end

    if bGetNpcID then
        QuestRegister:UnRegisterQuestOnNpc(Target:GetNpcID(), QuestID, Target.TargetID)

    elseif bGetNpcIDList then
        for _, NpcID in ipairs(Target:GetNpcIDList()) do
            QuestRegister:UnRegisterQuestOnNpc(NpcID, QuestID, Target.TargetID)
        end
    end
end

---更新NPC身上可提交的任务
---@param QuestID int32
function QuestHelper.AddNpcCanSubmitQuest(QuestCfgItem)
    if QuestCfgItem == nil then return end
    if not CheckSubmitNpcValid(QuestCfgItem) then return end
    QuestHelper.RemoveNpcActivatedQuest(QuestCfgItem)

    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if nil == ChapterCfgItem then return end

    local bRegSuccess = QuestRegister:RegisterQuestOnNpc(QuestCfgItem.FinishNpc, QuestCfgItem.id,
        ChapterCfgItem.QuestType, QuestCfgItem.FinishDialogID, ChapterCfgItem.QuestName)
    if bRegSuccess then
        QuestTrackMgr:AddMapQuestParam(QuestCfgItem.SubmitMapID, QuestCfgItem.id, nil,
            QuestDefine.NaviType.NpcResID, QuestCfgItem.FinishNpc, nil, QuestCfgItem.AcceptUIMapID)
    end
end

---移除NPC身上可提交的任务
---@param QuestID int32
function QuestHelper.RemoveNpcCanSubmitQuest(QuestCfgItem)
    if QuestCfgItem == nil then return end
    if not CheckSubmitNpcValid(QuestCfgItem) then return end

    local bUnRegSuccess = QuestRegister:UnRegisterQuestOnNpc(QuestCfgItem.FinishNpc, QuestCfgItem.id)
    if bUnRegSuccess then
        QuestTrackMgr:RemoveMapQuestParam(QuestCfgItem.SubmitMapID, QuestCfgItem.id, nil)
    end
end

---更新NPC身上容错任务
---@param NpcResID number
---@param FaultQuestID number
---@param FaultTarget TargetBase
---@param MapID number
---@param QuestType ProtoRes.QUEST_TYPE
---@param DialogOrSequenceID number
---@param QuestName string
---@param UIMapID number
function QuestHelper.AddNpcFaultTolerantQuest(NpcResID, FaultQuestID, FaultTarget, MapID, QuestType, DialogOrSequenceID, QuestName, UIMapID)
    local bRegSuccess = QuestRegister:RegisterQuestOnNpc(NpcResID, FaultQuestID, QuestType, DialogOrSequenceID, QuestName, FaultTarget)
    if bRegSuccess then
        QuestTrackMgr:AddMapQuestParam(MapID, FaultQuestID, FaultTarget.TargetID, QuestDefine.NaviType.NpcResID, NpcResID, UIMapID)
    end
end

---移除NPC身上容错任务
---@param NpcResID number
---@param FaultQuestID number
---@param FaultTargetID number
---@param MapID number
function QuestHelper.RemoveNpcFaultTolerantQuest(NpcResID, FaultQuestID, FaultTargetID, MapID)
    local bUnRegSuccess = QuestRegister:UnRegisterQuestOnNpc(NpcResID, FaultQuestID, FaultTargetID)
    if bUnRegSuccess then
        QuestTrackMgr:RemoveMapQuestParam(MapID, FaultQuestID, FaultTargetID)
    end
end

---更新怪物身上的目标
---@param QuestID int32
---@param Target TargetBase
function QuestHelper.AddMonsterQuestTarget(QuestID, Target)
    if (Target == nil) then return end
    local bGetMonsterID = (Target:GetMonsterID() ~= 0)
    local bGetMonsterIDList = (next(Target:GetMonsterIDList()) ~= nil)
    if not (bGetMonsterID or bGetMonsterIDList) then return end

    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return end

    if bGetMonsterID then
        QuestRegister:RegisterQuestOnMonster(Target:GetMonsterID(), QuestID,
            ChapterCfgItem.QuestType, Target)

    elseif bGetMonsterIDList then
        for _, MonsterID in ipairs(Target:GetMonsterIDList()) do
            QuestRegister:RegisterQuestOnMonster(MonsterID, QuestID,
                ChapterCfgItem.QuestType, Target)
        end
    end
end

---移除怪物身上的目标
---@param QuestID int32
---@param Target TargetBase
function QuestHelper.RemoveMonsterQuestTarget(QuestID, Target)
    if (Target == nil) then return end
    local bGetMonsterID = (Target:GetMonsterID() ~= 0)
    local bGetMonsterIDList = (next(Target:GetMonsterIDList()) ~= nil)
    if not (bGetMonsterID or bGetMonsterIDList) then return end

    if bGetMonsterID then
        QuestRegister:UnRegisterQuestOnMonster(Target:GetMonsterID(), QuestID, Target.TargetID)

    elseif bGetMonsterIDList then
        for _, MonsterID in ipairs(Target:GetMonsterIDList()) do
            QuestRegister:UnRegisterQuestOnMonster(MonsterID, QuestID, Target.TargetID)
        end
    end
end

---更新EObj身上的目标
---@param QuestID int32
---@param Target TargetBase
function QuestHelper.AddEObjQuestTarget(QuestID, Target)
    if (Target == nil) then return end
    local bGetEObjID = (Target:GetEObjID() ~= 0)
    local bGetEObjIDList = (next(Target:GetEObjIDList()) ~= nil)
    if not (bGetEObjID or bGetEObjIDList) then return end

    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return end

    if bGetEObjID then
        QuestRegister:RegisterQuestOnEObj(Target:GetEObjID(), QuestID,
            ChapterCfgItem.QuestType, ChapterCfgItem.QuestName, Target)

    elseif bGetEObjIDList then
        for _, EObjID in ipairs(Target:GetEObjIDList()) do
            QuestRegister:RegisterQuestOnEObj(EObjID, QuestID,
                ChapterCfgItem.QuestType, ChapterCfgItem.QuestName, Target)
        end
    end
end

---移除EObj身上的目标
---@param QuestID int32
---@param Target TargetBase
function QuestHelper.RemoveEObjQuestTarget(QuestID, Target)
    if (Target == nil) then return end
    local bGetEObjID = (Target:GetEObjID() ~= 0)
    local bGetEObjIDList = (next(Target:GetEObjIDList()) ~= nil)
    if not (bGetEObjID or bGetEObjIDList) then return end

    if bGetEObjID then
        QuestRegister:UnRegisterQuestOnEObj(Target:GetEObjID(), QuestID, Target.TargetID)

    elseif bGetEObjIDList then
        for _, EObjID in ipairs(Target:GetEObjIDList()) do
            QuestRegister:UnRegisterQuestOnEObj(EObjID, QuestID, Target.TargetID)
        end
    end
end

---更新EObj身上容错目标
---@param EObjID number
---@param FaultQuestID number
---@param FaultTarget TargetBase
---@param MapID number
---@param QuestType ProtoRes.QUEST_TYPE
---@param QuestName string
---@param UIMapID number
function QuestHelper.AddEObjFaultTolerantQuest(EObjID, FaultQuestID, FaultTarget, MapID, QuestType, QuestName, UIMapID)
    QuestRegister:RegisterQuestOnActor(EActorType.EObj, QuestRegister.QuestParamsListOnEObj,
		EObjID, FaultQuestID, QuestType,
		nil, QuestName,
		true, FaultTarget)
end


---移除NPC身上容错任务
---@param EObjID number
---@param FaultQuestID number
---@param FaultTargetID number
---@param MapID number
function QuestHelper.RemoveEObjFaultTolerantQuest(EObjID, FaultQuestID, FaultTargetID, MapID)
    QuestRegister:UnRegisterQuestOnEObj(EObjID, FaultQuestID)
end

-- ==================================================
-- 其他功能
-- ==================================================

---@param ChapterID int32
---@return table|nil
function QuestHelper.GetChapterCfgItem(ChapterID)
    if ChapterID == nil then return nil end

	local Chapter = QuestMgr.ChapterMap[ChapterID]
    if Chapter and Chapter.Cfg then
        return Chapter.Cfg
    end

	local EndChapter = QuestMgr.EndChapterMap[ChapterID]
    if EndChapter and EndChapter.Cfg then
        return EndChapter.Cfg
    end

	local Cfg = QuestChapterCfg:FindCfgByKey(ChapterID)
	return Cfg
end

---@param QuestID int32
---@return table|nil
function QuestHelper.GetQuestCfgItem(QuestID)
    if QuestID == nil then return nil end

	local Quest = QuestMgr.QuestMap[QuestID]
    if Quest and Quest.Cfg then
        return Quest.Cfg
    end

	local Cfg = QuestCfg:FindCfgByKey(QuestID)
	return Cfg
end

---@param QuestID int32
---@param TargetID int32
---@return table|nil
function QuestHelper.GetTargetCfgItem(QuestID, TargetID)
	local Quest = QuestMgr.QuestMap[QuestID]
    if Quest then
        local Target = Quest.Targets[TargetID]
        if Target and Target.Cfg then
            return Target.Cfg
        end
    end

	local Cfg = TargetCfg:FindCfgByKey(TargetID)
	return Cfg
end

---@param ChapterID int32
---@return ProtoRes.QUEST_TYPE|nil
function QuestHelper.GetQuestTypeByChapterID(ChapterID)
	local Cfg = QuestHelper.GetChapterCfgItem(ChapterID)
	if Cfg == nil then return nil end
	return Cfg.QuestType
end

---@param QuestID int32
---@return ProtoRes.QUEST_TYPE|nil
function QuestHelper.GetQuestTypeByQuestID(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return nil end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return nil end
	return ChapterCfgItem.QuestType
end

---@param QuestCfgItem luatable
---@param ChapterCfgItem luatable
function QuestHelper.ActivateQuest(QuestCfgItem, ChapterCfgItem)
    QuestHelper.AddNpcActivatedQuest(QuestCfgItem, ChapterCfgItem)

    local AcceptCounterID = QuestCfgItem.AcceptCounterID or 0
    local SubmitCounterID = QuestCfgItem.SubmitCounterID or 0
    local QuestID = QuestCfgItem.id
    if AcceptCounterID ~= 0 then
        QuestRegister:RegisterQuestOnCounter(AcceptCounterID, QuestID)
    end
    if SubmitCounterID ~= 0 then
        QuestRegister:RegisterQuestOnCounter(SubmitCounterID, QuestID)
    end
end

---构造发给后台的交互NPC数据
---@param ResID int32
---@return table | nil
function QuestHelper.MakeInteractActor(ResID, ActorType)
    if ResID == nil or ResID == 0 then return nil end

    if (ActorType == nil) or (ActorType == EActorType.Npc) then
        local NpcData = MapEditDataMgr:GetNpc(ResID)
        if NpcData ~= nil then
            return { ListID = NpcData.ListId }
        end

    elseif (ActorType == EActorType.EObj) then
        local EObjData = MapEditDataMgr:GetEObjByResID(ResID)
        if EObjData ~= nil then
            return { ListID = EObjData.ID }
        end
    end

    local Actor =  ActorUtil.GetActorByResID(ResID)
    if Actor == nil then
        QuestHelper.PrintQuestError("MakeInteractActor() actor %d not found", ResID)
        return {}
    end

    local AttrComp = Actor:GetAttributeComponent()
    if AttrComp == nil then
        QuestHelper.PrintQuestError("MakeInteractActor() AttrComp of actor %d not found", ResID)
        return {}
    end

    return { EntityID = AttrComp.EntityID }
end

-- 通过SequenceID获取Sequence具体路径
-- 特殊处理参考QuestHelper.QuestPlaySequence
function QuestHelper.GetSequencePath(SequenceID)
    if SequenceID < 1000000 then
        return nil
    end
    -- 设置跳过任务剧情动画
    if StorySetting.GetAutoSkipQuestSequence() then
        return nil
    end
    local DialogueType = QuestDefine.GetDialogueType(SequenceID)
    if DialogueType == QuestDefine.DialogueType.DialogueSequence then
	    return StoryMgr:GetDialogueSequencePath(SequenceID)
    elseif DialogueType == QuestDefine.DialogueType.CutSceneSequence then
        return StoryMgr:GetCutSceneSequencePath(SequenceID)
    end
    return nil
end

function QuestHelper.QuestPlaySequence(SequenceID,
	SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)

    local DialogueType = QuestDefine.GetDialogueType(SequenceID)

    -- npc对话临时处理，等策划提单撤销
    if SequenceID < 1000000 then
        SequenceStopCallback()
        return
    end

    -- 如果传送期间要播sequence，等传送完再播放
    if QuestMgr.bSeqWaitLoading then
        QuestRegister:RegisterSeqWaitLoading(SequenceID, SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)
        return
    end

    -- 设置跳过任务剧情动画
    if StorySetting.GetAutoSkipQuestSequence() then
        if SequenceFinishedCallback then
            SequenceFinishedCallback()
        end
        if SequenceStopCallback then
            SequenceStopCallback()
        end
        return
    end

    QuestMgr:SetInQuestSequence(true)

    if DialogueType == QuestDefine.DialogueType.DialogueSequence then
        StoryMgr:PlayDialogueSequence(SequenceID,
            SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)

    elseif DialogueType == QuestDefine.DialogueType.CutSceneSequence then
        StoryMgr:PlayCutSceneSequenceByID(SequenceID,
            SequenceStopCallback, SequencePauseCallback, SequenceFinishedCallback, PlaybackSettings)
    end
    -- print("test QuestPlaySequence", SequenceID)

    -- 开发期逻辑，保证没播出sequence也能继续任务流程
    -- StoryMgr内部也可能因为异常情况销毁SequencePlayer并执行callback，故这里有可能重复执行，进而导致问题
    -- 但应该播sequence没播出来，本身就需要修复，重复执行的问题只是副产物，影响不大
    if not (StoryMgr.SequencePlayer or StoryMgr:SequenceIsPlaying()) then
        if _G.StoryMgr:IsSequenceInSkipGroup(SequenceID) then
            return -- 分组跳过是正常情况
        end
        QuestHelper.PrintQuestError("Play sequence failed: %d", SequenceID)
        StoryMgr:ClearWaitingSequenceCache()
        SequenceStopCallback()
    end
end

---@param BranchUniqueID int32
function QuestHelper.IsBranchChoiceQuestInvalid(BranchUniqueID)
    if BranchUniqueID == 0 then return false end
    local BranchCfgItem = DialogueBranchCfg:FindCfgByKey(BranchUniqueID)
    if (BranchCfgItem == nil) then return false end

    local ChoiceData = BranchCfgItem.ChoiceList[QuestRegister.DialogChoiceIndex]
    return (ChoiceData == nil) or (ChoiceData.Quest == nil) or (ChoiceData.Quest == 0)
end

---@param QuestID int32
---@param ShowPlace string
---@return string
function QuestHelper.GetQuestIconInternal(QuestID, QuestType, bMonster, ShowPlace)
    if QuestID == nil then -- 只按照任务类型获取图标
        if QuestType == nil then return "" end
        return QuestDefine.MakeIconPath(QuestType, QuestDefine.CHAPTER_STATUS.NOT_STARTED,
            true, bMonster, false, ShowPlace)
    end

    local Quest = QuestMgr.QuestMap[QuestID]
    local Chapter = QuestMgr.ChapterMap[Quest and Quest.ChapterID or 0]

    if Quest == nil or Chapter == nil then
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
        if QuestCfgItem == nil then
            return ""
        end
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
        if ChapterCfgItem == nil then return "" end

        -- 判断未接取or已完成
        local ChapterStatus = QuestDefine.CHAPTER_STATUS.NOT_STARTED
        Chapter = QuestMgr.EndChapterMap[QuestCfgItem.ChapterID]
        if Chapter ~= nil then
            ChapterStatus = Chapter.Status
        end

        QuestType = QuestType or ChapterCfgItem.QuestType
        local bCanProceed = QuestHelper.CheckCanAccept(QuestID, QuestCfgItem, ChapterCfgItem)
        return QuestDefine.MakeIconPath(QuestType, ChapterStatus,
            bCanProceed, bMonster, false, ShowPlace)

    else
        QuestType = QuestType or Chapter.Cfg.QuestType
        local bCanProceed = false
        local ChapterStatus = Chapter.Status
        if ShowPlace == "LOG" then
            bCanProceed = QuestHelper.CheckUnrestricted(QuestID, Quest.Cfg, Chapter.Cfg)
            if not QuestHelper.CheckCanFinishTargets(QuestID) then
                ChapterStatus = QuestDefine.CHAPTER_STATUS.IN_PROGRESS
            end
        else
            bCanProceed = QuestHelper.CheckCanProceed(QuestID, Quest.Cfg, Chapter.Cfg)
        end
        return QuestDefine.MakeIconPath(QuestType, ChapterStatus,
            bCanProceed, bMonster, false, ShowPlace)
    end
end

---获取任务追踪图标
---@param QuestID number@任务ID
---@param SourceType QuestDefine.SOURCE_TYPE@来源类型
---@return string | nil
function QuestHelper.GetTrackingIconInternal(QuestID, SourceType)
    if not QuestID then
        return nil
    end
    local bCanProceed = QuestHelper.CheckCanAccept(QuestID)
    return QuestDefine.MakeTrackingIconPath(SourceType, bCanProceed)
end

---对话完会返回任务系统OnQuestInteractionFinished接口
---@param NPCQuestParams ActorQuestParamsClass
---@param DialogID int32
---@param EntityID uint64
function QuestHelper.PlayDialogWithQuestParams(NPCQuestParams, DialogID, EntityID)
    if NPCQuestParams == nil then
        QuestHelper.PrintQuestWarning("PlayDialogWithQuestParams get NPCQuestParams=nil")
        return
    end
    local NpcDialogMgr = _G.NpcDialogMgr
    NpcDialogMgr.QuestDialogParams = NPCQuestParams
    NpcDialogMgr.bAutoPlayDialog = true
    local CameraData = {EntityID = EntityID, ResID = ActorUtil.GetActorResID(EntityID)}
    local CallBack = function()
        local bCanMoveInteraction = false -- 如果当前TargetID的上一个目标是触发器，则增加参数无视跳跃
        if NPCQuestParams.TargetID ~= nil then
            local TargetCfgItem = QuestHelper.GetTargetCfgItem(NPCQuestParams.QuestID, NPCQuestParams.TargetID)
            if TargetCfgItem and TargetCfgItem.PrevTarget ~= nil then
                local PrevTargetCfgItem = QuestHelper.GetTargetCfgItem(NPCQuestParams.QuestID, TargetCfgItem.PrevTarget)
                if PrevTargetCfgItem then
                    bCanMoveInteraction = PrevTargetCfgItem.m_iTargetType == TARGET_TYPE.QUEST_TARGET_TYPE_TRIGGER
                end
            end
        end
        NpcDialogMgr:PlayDialogLib(DialogID, EntityID, nil, nil, nil, nil, true, bCanMoveInteraction)
    end
    
    --Eobj不进镜头处理了
    if EntityID then
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        local ActorType = ActorUtil.GetActorType(EntityID)
        if ActorType and  ActorType == EActorType.Npc and not Actor:IsInInteraction() then
            _G.NpcDialogMgr:OnlySwitchCameraOrTurn(CameraData, false, CallBack)
        else
            CallBack()
        end
    else
        CallBack()
    end
end

---@param DialogOrSeqID int32
---@param PlayDialogFunc function
---@param PlaySeqFunc function
---@param PlayFailedFunc function
function QuestHelper.PlayDialogOrSequence(DialogOrSeqID, PlayDialogFunc, PlaySeqFunc, PlayFailedFunc)
    local DType = QuestDefine.GetDialogueType(DialogOrSeqID)

    if DType == QuestDefine.DialogueType.NpcDialog then
        if PlayDialogFunc then PlayDialogFunc() end

    elseif DType == QuestDefine.DialogueType.DialogueSequence
    or DType == QuestDefine.DialogueType.CutSceneSequence then
        if PlaySeqFunc then PlaySeqFunc() end

    else
        QuestHelper.PrintQuestError("DialogOrSequenceID %d digit invalid", DialogOrSeqID or 0)
        -- QuestHelper.PrintQuestWarning("PlayDialogOrSequence meets ID = %d, called by %s",
        --     DialogOrSeqID or 0, debug.getinfo(2,"n").name)
        if PlayFailedFunc then PlayFailedFunc() end
    end
end

---自动进行对话
---@param QuestID int32
---@param ResID int32
---@param DialogOrSequenceID int32
---@param GetQuestParams function<table QuestList>
function QuestHelper.AutoDialog(QuestID, TargetID, ResID, DialogOrSequenceID, GetQuestParams)
    DialogOrSequenceID = DialogOrSequenceID or 0

    local function PlayDialogFunc()
        local EntityID = nil
        local Actor = ActorUtil.GetActorByResID(ResID)
        if Actor then
            local AttrComp = Actor:GetAttributeComponent()
            if AttrComp then EntityID = AttrComp.EntityID end
        end

        if EntityID then
            QuestHelper.PlayDialogWithQuestParams(GetQuestParams(), DialogOrSequenceID, EntityID)
        end
    end

    local function PlaySeqFunc()
        QuestHelper.QuestPlaySequence(DialogOrSequenceID, function(_)
            _G.NpcDialogMgr:CheckNeedEndInteraction()
            local QuestParams = GetQuestParams()
            if QuestParams ~= nil then
                QuestMgr:OnQuestInteractionFinished(QuestParams)
            end
        end)
    end

    QuestHelper.PlayDialogOrSequence(DialogOrSequenceID,
        PlayDialogFunc, PlaySeqFunc)
end

---自动进行NPC对话
---@param QuestID int32
---@param NpcID int32
---@param DialogOrSequenceID int32
function QuestHelper.AutoNPCDialog(QuestID, TargetID, NpcID, DialogOrSequenceID)
    local function GetNPCQuestParams()
        local NPCQuestParamsList = QuestMgr:GetNPCQuestParamsList(NpcID)
        for _, NPCQuestParams in ipairs(NPCQuestParamsList) do
            if (QuestID == NPCQuestParams.QuestID)
            and ((TargetID == nil) or (TargetID == NPCQuestParams.TargetID)) then
                return NPCQuestParams
            end
        end
        return nil
    end
    QuestHelper.AutoDialog(QuestID, TargetID, NpcID, DialogOrSequenceID, GetNPCQuestParams)
end

---自动进行EObj对话
---@param QuestID int32
---@param EObjID int32
---@param DialogOrSequenceID int32
function QuestHelper.AutoEObjDialog(QuestID, TargetID, EObjID, DialogOrSequenceID)
    local function GetEObjQuestParams()
        local EObjQuestParamsList = QuestMgr:GetEObjQuestParamsList(EObjID)
        for _, EObjQuestParams in ipairs(EObjQuestParamsList) do
            if (QuestID == EObjQuestParams.QuestID)
            and ((TargetID == nil) or (TargetID == EObjQuestParams.TargetID)) then
                return EObjQuestParams
            end
        end
        return nil
    end
    QuestHelper.AutoDialog(QuestID, TargetID, EObjID, DialogOrSequenceID, GetEObjQuestParams)
end

---@param QuestID int32
---@param TargetID int32|nil
---@param bPlayCustomDialog boolean
function QuestHelper.PlayRestrictedDialog(QuestID, TargetID, bPlayCustomDialog)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then return end

    local ChapterStatus = QuestDefine.CHAPTER_STATUS.NOT_STARTED
    if ChapterCfgItem and QuestMgr.ChapterMap[ChapterCfgItem.id] then
        ChapterStatus = QuestMgr.ChapterMap[ChapterCfgItem.id].Status
    end

    local RestrictedDialogID = 0
    local Quest = QuestMgr.QuestMap[QuestID]
    if (TargetID ~= nil) and (Quest ~= nil) and (Quest.Targets[TargetID] ~= nil) then
        RestrictedDialogID = Quest.Targets[TargetID].Cfg.RestrictedDialogID or 0
    end
    if (RestrictedDialogID == 0) and (QuestCfgItem.RestrictedDialogID ~= 0) then
        RestrictedDialogID = QuestCfgItem.RestrictedDialogID
    end
    EventMgr:SendEvent(EventID.QuestPlayRestrictedDialog, {QuestID = QuestID})

    local NpcDialogMgr = _G.NpcDialogMgr

    local function PlayLootItemDialog()
        local Quest = QuestMgr.QuestMap[QuestID]
        if Quest and next(Quest.StateRestrictions) then
            for _, Restriction in pairs(Quest.StateRestrictions) do
                local Type = Restriction.RestrictedDialogType
                if Type == RDType.BagSlot and Restriction:MakeRestrictedDialog() then
                    return false
                end
            end
        end
        local LootItemsCount = QuestHelper.GetLootItemsCount(QuestID, TargetID)
        local RestrictedDialog = nil
        if LootItemsCount > _G.BagMgr:GetBagLeftNum() then
            RestrictedDialog = QuestHelper.MakeRestrictedDialogLootCount(LootItemsCount)
        end
        if RestrictedDialog == nil then
            return false
        end
        NpcDialogMgr:OverrideStateEnd()
        NpcDialogMgr:PushDialog(RestrictedDialog, 8, LSTR(10004), nil, function()
                if _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_BAG, true) then
                    _G.UIViewMgr:ShowView(UIViewID.BagMain)
                end
            end)
        return true
    end

    local function PlayTemplateDialog()
        local RestrictedDialogList = QuestHelper.MakeRestrictedDialog(ChapterStatus, ChapterCfgItem, QuestCfgItem, false, TargetID)

        -- [chunfengluo] 不满足对话的特殊处理，设置状态为播放对话完毕后就结束交互
        NpcDialogMgr:OverrideStateEnd()

        if next(RestrictedDialogList) ~= nil then
            local TemplateDialog = QuestDefine.RestrictedDialogForStatus[ChapterStatus] or ""
            local OpenBag = false
            local OpenPromote = false
            local OpenProf = false
            local OpenActivity = false
            if RestrictedDialogList[RDType.LootCount] then
                OpenBag = true
                TemplateDialog = RestrictedDialogList[RDType.LootCount]
            elseif RestrictedDialogList[RDType.Prof] then
                OpenProf = true
                TemplateDialog = RestrictedDialogList[RDType.Prof]
            elseif RestrictedDialogList[RDType.FixedProf] then
                OpenProf = true
                TemplateDialog = RestrictedDialogList[RDType.FixedProf]
            elseif RestrictedDialogList[RDType.LowLevel] then
                OpenPromote = true
                TemplateDialog = RestrictedDialogList[RDType.LowLevel]
            elseif RestrictedDialogList[RDType.TimeLimit] then
                OpenActivity = true
                TemplateDialog = RestrictedDialogList[RDType.TimeLimit]
            else
                OpenBag = (RestrictedDialogList[RDType.BagSlot] ~= nil)
                -- 配置了对话的四种通用限制都满足, 按旧方式显示其他限制的对话
                for i = 1, RDType.MAX do
                    if RestrictedDialogList[i] ~= nil then
                        TemplateDialog = string.format("%s\n%s", TemplateDialog, RestrictedDialogList[i])
                    end
                end
            end
           
            NpcDialogMgr:PushDialog(TemplateDialog, 8, LSTR(10004), nil, function()
                if OpenBag and _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_BAG, true) then
                    _G.UIViewMgr:ShowView(UIViewID.BagMain)
                elseif OpenProf and QuestMgr:IsExistProfessionMeetCondition(QuestID) then
                    -- 先判断是否有满足条件的职业，如果没有不打开切职业界面
                    -- 打开切职业界面（假设【需要切职业的限制】都会在生成【模板提示对话】时判定
                    ProfMgr.ShowProfSwitchTab()
                elseif OpenPromote then
                    -- 当等级不满足要求时 打开推荐升级界面
                    local Prof, TypeNum = QuestMgr:IsOpenPromoteLevelUp(QuestID)
                    print(" 【QuestHelper】当等级不满足要求时 打开推荐升级界面",Prof,TypeNum)
                    if nil ~= Prof and Prof ~= 0 and TypeNum then
                        local Params = {Prof = Prof, TypeNum = TypeNum}
                        EventMgr:SendEvent(EventID.ShowPromoteMainPanel, Params)
                    end
                elseif OpenActivity then
                    -- 打开活动页
                    _G.UIViewMgr:ShowView(UIViewID.OpsActivityMainPanel)
                end
            end)

        elseif (RestrictedDialogID == 0) then
            NpcDialogMgr:PushDialog(LSTR(596301), 8, LSTR(10004)) --596301("未满足任务条件，同时未配置定制对话，也不支持生成对话")
        end
    end

    if bPlayCustomDialog == false then
        PlayTemplateDialog()
    else
        local function PlayDialogFunc()
            -- 部分未满足条件的定制对话和生成对话冲突
            -- 这里先处理一下, 把任务奖励物品溢出的生成对话单独分出来
            if not PlayLootItemDialog(QuestID, TargetID) then
                NpcDialogMgr:PlayDialogLib(RestrictedDialogID, nil)
                PlayTemplateDialog()
            end
        end

        local function PlaySeqFunc()
            QuestHelper.QuestPlaySequence(RestrictedDialogID, function(_)
                _G.NpcDialogMgr:CheckNeedEndInteraction()
                PlayTemplateDialog()
            end)
        end

        local function PlayFailedFunc()
            PlayTemplateDialog()
        end

        QuestHelper.PlayDialogOrSequence(RestrictedDialogID,
            PlayDialogFunc, PlaySeqFunc, PlayFailedFunc)
    end
end


---@param MinLevel number
---@return string
function QuestHelper.MakeRestrictedDialogLowLevel(MinLevel)
    local SearchConditions = string.format("DialogLibID==%d", RDID.LowLevel)
    local DialogCfg = DefaultDialogCfg:FindCfg(SearchConditions)
    if DialogCfg ~= nil then
        return string.format(DialogCfg.DialogContent, MinLevel)
    end
    return ""
end

---@param RequiredProfName string
---@return string
function QuestHelper.MakeRestrictedDialogProf(RequiredProfName)
    local SearchConditions = string.format("DialogLibID==%d", RDID.Prof)
    local DialogCfg = DefaultDialogCfg:FindCfg(SearchConditions)
    if DialogCfg ~= nil then
        return string.format(DialogCfg.DialogContent, RequiredProfName)
    end
    return ""
end

---@param OwnProfessionLevel number
---@param RequiredOwnProfName string
---@return string
function QuestHelper.MakeRestrictedDialogOwnProf(OwnProfessionLevel, RequiredOwnProfName)
    -- local SearchConditions = string.format("DialogLibID==%d", RDID.OwnProf)
    -- local DialogCfg = DialogCfg:FindCfg(SearchConditions)
    -- if DialogCfg ~= nil then
    --     return DialogCfg.DialogContent
    -- end
    return string.format(LSTR(596302), (OwnProfessionLevel or -1), RequiredOwnProfName) --596302("拥有%d级以上的%s")
end

---@param FixedProfName string
---@return string
function QuestHelper.MakeRestrictedDialogFixedProf(FixedProfName)
    local SearchConditions = string.format("DialogLibID==%d", RDID.FixedProf)
    local DialogCfg = DefaultDialogCfg:FindCfg(SearchConditions)
    if DialogCfg ~= nil then
        return string.format(DialogCfg.DialogContent, FixedProfName)
    end
    return ""
end

---@param LootCount int32
---@return string
function QuestHelper.MakeRestrictedDialogLootCount(LootCount)
    local SearchConditions = string.format("DialogLibID==%d", RDID.LootCount)
    local DialogCfg = DefaultDialogCfg:FindCfg(SearchConditions)
    if DialogCfg ~= nil then
        return string.format(DialogCfg.DialogContent, LootCount)
    end
    return ""
end

---@param Reason int32
---@param ParamName string
---@return string
function QuestHelper.MakeRestrictedDialogGrandCompany(Reason, ParamName)
    local SearchConditions = string.format("DialogLibID==%d", Reason)
    local DialogCfgItem = DialogCfg:FindCfg(SearchConditions)
    if DialogCfgItem ~= nil then
        return string.format(DialogCfgItem.DialogContent, ParamName)
    end
    return ""
end

function QuestHelper.MakeRestrictedDialogTimeLimit(QuestName, Second)
    local RawText = ""
    if Second >= 3600 then
        RawText = string.format(LSTR(593010), math.ceil(Second / 3600))
    else
        RawText = string.format(LSTR(593011), math.ceil(Second / 60))
    end
    return string.format(LSTR(596306), QuestName, RawText) --596306("下一章节主线任务《%s》，%s，敬请期待。")
end

---@param ChapterStatus CHAPTER_STATUS
---@param ChapterCfgItem table
---@param QuestCfgItem table
---@param bNoGenDialog boolean
---@param TargetID int32
---@return table
function QuestHelper.MakeRestrictedDialog(ChapterStatus, ChapterCfgItem, QuestCfgItem, bNoGenDialog, TargetID)
    if (ChapterStatus == nil) or (ChapterCfgItem == nil) or (QuestCfgItem == nil) then return {} end
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    local RoleDetail = MajorUtil.GetMajorRoleDetail()
    if (RoleSimple == nil) or (RoleDetail == nil) then
        local ErrorParts = ""
        if (RoleSimple == nil) then
            ErrorParts = " RoleSimple"
        end
        if (RoleDetail == nil) then
            ErrorParts = ErrorParts .. " RoleDetail"
        end
        QuestHelper.PrintQuestError("Failed to get%s", ErrorParts)
        return {}
    end

    local RestrictedDialogList = {}

    -- 等级限制
    local bLowLevel = RoleSimple.Level < (ChapterCfgItem.MinLevel or 1)
    if bLowLevel then
        RestrictedDialogList[RDType.LowLevel] =
            bNoGenDialog and "" or QuestHelper.MakeRestrictedDialogLowLevel(ChapterCfgItem.MinLevel)
    end

    -- 时间限制
    local OpenDayLimit = ChapterCfgItem.OpenDayLimit
    if OpenDayLimit and OpenDayLimit ~= 0 then
        local LimitTime = TimeUtil.GetOpenServerOffsetTS(OpenDayLimit, ChapterCfgItem.OpenHourLimit)
        if LimitTime > TimeUtil.GetServerLogicTime() then
            local Second = LimitTime - TimeUtil.GetServerLogicTime()
            RestrictedDialogList[RDType.TimeLimit] =
                bNoGenDialog and "" or QuestHelper.MakeRestrictedDialogTimeLimit(ChapterCfgItem.QuestName, Second)
        end
    end

    -- 职业(类)限制
    local CurrProf = RoleSimple.Prof
    local RequiredProfName = nil
    if QuestCfgItem.Profession ~= 0 then
        if (CurrProf ~= QuestCfgItem.Profession) then
            RequiredProfName = RoleInitCfg:FindRoleInitProfName(QuestCfgItem.Profession)
        end
    elseif QuestCfgItem.ProfessionClass ~= 0 then
        if not ProfMgr.CheckProfClass(CurrProf, QuestCfgItem.ProfessionClass) then
            RequiredProfName = ProfMgr.GetProfClassName(QuestCfgItem.ProfessionClass)
        end
    end
    if RequiredProfName then
        RestrictedDialogList[RDType.Prof] =
            bNoGenDialog and "" or QuestHelper.MakeRestrictedDialogProf(RequiredProfName)
    end

    -- 拥有职业(类)限制
    local OwnProfList = RoleDetail.Prof.ProfList or {}
    local RequiredOwnProfName = nil
    local RequiredProfData = nil
    if QuestCfgItem.OwnProfession and (QuestCfgItem.OwnProfession ~= 0) then
        for OwnProfID, ProfData in pairs(OwnProfList) do
            if OwnProfID == QuestCfgItem.OwnProfession then
                RequiredProfData = ProfData
                break
            end
        end
        if (RequiredProfData == nil) or (RequiredProfData.Level < QuestCfgItem.OwnProfessionLevel) then
            RequiredOwnProfName = RoleInitCfg:FindRoleInitProfName(QuestCfgItem.OwnProfession)
        end
    elseif QuestCfgItem.OwnProfessionClass and (QuestCfgItem.OwnProfessionClass ~= 0) then
        for OwnProfID, ProfData in pairs(OwnProfList) do
            if ProfMgr.CheckProfClass(OwnProfID, QuestCfgItem.OwnProfessionClass) then
                RequiredProfData = ProfData
                break
            end
        end
        if (RequiredProfData == nil) or (RequiredProfData.Level < QuestCfgItem.OwnProfessionLevel) then
            RequiredOwnProfName = ProfMgr.GetProfClassName(QuestCfgItem.ProfessionClass)
        end
    end
    if RequiredOwnProfName then
        RestrictedDialogList[RDType.OwnProf] = bNoGenDialog and ""
            or QuestHelper.MakeRestrictedDialogOwnProf(QuestCfgItem.OwnProfessionLevel, RequiredOwnProfName)
    end

    -- 职业固定任务
    local FixedProf = QuestRegister.FixedProfOnAccept[ChapterCfgItem.id]
    if (FixedProf ~= nil) and (FixedProf ~= CurrProf) then
        local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(FixedProf)
        local IsMatchProf = (AdvanceProf == CurrProf)
        if not IsMatchProf then
            for OwnProfID, ProfData in pairs(OwnProfList) do
                if OwnProfID == AdvanceProf then
                    -- 显示特职
                    FixedProf = AdvanceProf
                    break
                end
            end
            local FixedProfName = RoleInitCfg:FindRoleInitProfName(FixedProf)
            RestrictedDialogList[RDType.FixedProf] =
                bNoGenDialog and "" or QuestHelper.MakeRestrictedDialogFixedProf(FixedProfName)
        end
    end

    -- 条件限制节点
    local Quest = QuestMgr.QuestMap[QuestCfgItem.id]
    if Quest and next(Quest.StateRestrictions) then
        for _, Restriction in pairs(Quest.StateRestrictions) do
            local Type = Restriction.RestrictedDialogType
            if Type ~= nil then
                RestrictedDialogList[Type] = Restriction:MakeRestrictedDialog()
            end
        end
    end

    -- 检查背包, 条件限制节点可能已经配置了背包检查
    -- 任务界面的时候不用检查背包
    if RestrictedDialogList[RDType.BagSlot] == nil and not bNoGenDialog then
        local LootItemsCount = QuestHelper.GetLootItemsCount(QuestCfgItem.id, TargetID)
        if LootItemsCount > _G.BagMgr:GetBagLeftNum() then
            RestrictedDialogList[RDType.LootCount] = QuestHelper.MakeRestrictedDialogLootCount(LootItemsCount)
        end
    end

    -- 军队限制
    if QuestCfgItem.GrandCompany and QuestCfgItem.GrandCompany ~= 0 then
        local CompoanySealInfo = _G.CompanySealMgr:GetCompanySealInfo()
        if CompoanySealInfo then
            local GrandCompanyName = ""
            local GrandCompanyCfgItem = GrandCompanyCfg:FindCfgByKey(QuestCfgItem.GrandCompany)
            if GrandCompanyCfgItem then
                GrandCompanyName = GrandCompanyCfgItem.Name
            end

            if CompoanySealInfo.GrandCompanyID ~= QuestCfgItem.GrandCompany then
                if ChapterStatus == QuestDefine.CHAPTER_STATUS.NOT_STARTED then
                    RestrictedDialogList[RDType.GrandCompany] = QuestHelper.MakeRestrictedDialogGrandCompany(RDID.JoinGrandCompany, GrandCompanyName)
                else
                    RestrictedDialogList[RDType.GrandCompany] = QuestHelper.MakeRestrictedDialogGrandCompany(RDID.ChangeGrandCompany, GrandCompanyName)
                end
            else
                if QuestCfgItem.GrandCompanyMilitaryRank and QuestCfgItem.GrandCompanyMilitaryRank > _G.CompanySealMgr:GetGrandCompanyRank() then
                    RestrictedDialogList[RDType.GrandCompany] = QuestHelper.MakeRestrictedDialogGrandCompany(RDID.UpGrandCompanyLevel, tostring(QuestCfgItem.GrandCompanyMilitaryRank))
                end
            end
        end
    end

    if next(RestrictedDialogList) == nil then return {} end

    return RestrictedDialogList
end

---@param QuestID int32
---@param ResID int32
function QuestHelper.PreFinish(QuestID, ResID)
    -- local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    -- if QuestCfgItem == nil then
    --     QuestMgr:SendSubmitQuest(QuestID, ResID)
    --     return
    -- end

	-- local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    -- if QuestID ~= ChapterCfgItem.EndQuest then -- 中间的任务节点无需额外处理
        QuestMgr:SendSubmitQuest(QuestID, ResID)

    -- else -- 完成最后一个任务节点时，先播UI再上报
    --     QuestHelper.ShowQuestTip(ChapterCfgItem.id, false, function()
    --         QuestMgr:SendSubmitQuest(QuestID, ResID)
    --     end)
    -- end
end

---完成任务或者任务目标后, 检查背包的空位
---@param QuestCfgItem luatable
---@param Target luatable
function QuestHelper.CheckBagLeftNum(QuestCfgItem, Target)
    local LootItemInfo = {}
    if QuestCfgItem and QuestCfgItem.LootID ~= 0 then
        QuestHelper.GetLootItemInfo(QuestCfgItem.LootID, LootItemInfo)
    elseif Target and Target.LootIDs then
        for _, LootID in ipairs(Target.LootIDs) do
            QuestHelper.GetLootItemInfo(LootID, LootItemInfo)
        end
    end
    local BagSlotCount = _G.BagMgr:CheckLootItemInfo(LootItemInfo)
    if BagSlotCount > 0 then
        local BagLeftNum = _G.BagMgr:GetBagLeftNum()
        if BagLeftNum <= 5 then
            local TipsFMT = LSTR(596305) --背包中还剩下%d格空位
            _G.MsgTipsUtil.ShowErrorTips(string.format(TipsFMT, BagLeftNum))
        end
    end
end

---@param ChapterID int32
---@param bShowAccept boolean
---@param Callback function
function QuestHelper.ShowQuestTip(ChapterID, bShowAccept, Callback)
	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfgItem == nil then return end

	local Content = bShowAccept and LSTR(596005) or LSTR(596006) --596005("接受任务") 596006("任务完成")
	local SoundName = nil
	local TypeInfo = QuestDefine.QuestTypeInfo[ChapterCfgItem.QuestType]
    local MajorVersionInt = tonumber(string.sub(ChapterCfgItem.VersionName, 1, 1)) or 0

	if TypeInfo and (MajorVersionInt > 0) then
		SoundName = bShowAccept
			and TypeInfo.AcceptSound[MajorVersionInt]
			or TypeInfo.FinishSound[MajorVersionInt]
	end

    local MainGenre = LSTR(592004) --592004("支线任务")
    local GenreCfgItem = QuestGenreCfg:FindCfgByKey(ChapterCfgItem.QuestGenreID)
	if GenreCfgItem then
		MainGenre = GenreCfgItem.MainGenre
	end

    MsgTipsUtil.ShowQuestTips(Content, MainGenre, 3, SoundName, ChapterID, Callback)
	--MsgTipsUtil.ShowMissionTips(Content, 2, SoundName, 10002, Callback)
end

function QuestHelper.RegisterWaitingSequenceWithChangeMap(PreSequenceID, SequenceID)
    if StoryMgr then
        StoryMgr:RegisterWaitingSequenceWithChangeMap(PreSequenceID, SequenceID)
    end
end

function QuestHelper.UnRegisterWaitingSequenceWithChangeMap(SequenceID)
    if StoryMgr then
        StoryMgr:UnRegisterWaitingSequenceWithChangeMap(SequenceID)
    end
end

-- ==================================================
-- 打印信息
-- ==================================================

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

function QuestHelper.PrintQuestInfo(Msg, ...)
    FLOG_INFO("QuestMgr: %s", string.format(Msg, ...))
end

function QuestHelper.PrintQuestWarning(Msg, ...)
    FLOG_WARNING("QuestMgr: %s", string.format(Msg, ...))
end

function QuestHelper.PrintQuestError(Msg, ...)
    FLOG_ERROR("QuestMgr: %s", string.format(Msg, ...))
end

return QuestHelper
