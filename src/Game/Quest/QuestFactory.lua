--
-- Author: lydianwang
-- Date: 2022-05-30
-- Description:
--

local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")

-- BasicClass
local ChapterClass = require("Game/Quest/BasicClass/Chapter")
local QuestClass = require("Game/Quest/BasicClass/Quest")

-- DB
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local QuestCfg = require("TableCfg/QuestCfg")
local TargetCfg = require("TableCfg/QuestTargetCfg")
local ClientBehaviorCfg = require("TableCfg/QuestClientActionCfg")
local LogicCfg = require("TableCfg/QuestLogicCfg")
local QuestFaultTolerantCfg = require("TableCfg/QuestFaultTolerantCfg")

-- Proto
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")

local LOGIC_TYPE =   ProtoRes.QUEST_LOGIC_TYPE
local CommonUtil = require("Utils/CommonUtil")

local QuestMgr = nil

local TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE
local BEHAVIOR_TYPE = ProtoRes.QUEST_CLIENT_ACTION_TYPE
local RESTRICTION_TYPE = ProtoRes.QUEST_RESTRICTION_TYPE
local FAULT_TOLERANT_TYPE = ProtoRes.QUEST_FAULT_TOLERANT_TYPE
local TargetLuaClass = {}
local BehaviorLuaClass = {}
local LogicLuaClass = {}
local FaultTolerantLuaClass = {}

local QuestFactory = {}

function QuestFactory.Init()
    QuestMgr = _G.QuestMgr

    local profile_tag
    local _ <close> = CommonUtil.MakeProfileTag("QuestFactory.Init")

    local function RequireQuestLuaClass(QuestLuaClass, TypeEnumClass, QuestClassParams)
        for _, Type in pairs(TypeEnumClass) do
            local ClassParams = QuestClassParams[Type]
            if nil ~= ClassParams then
                QuestLuaClass[Type] = require(ClassParams.Class)
            end
        end
    end

    RequireQuestLuaClass(TargetLuaClass, TARGET_TYPE, QuestDefine.TargetClassParams)
    RequireQuestLuaClass(BehaviorLuaClass, BEHAVIOR_TYPE, QuestDefine.BehaviorClassParams)
    RequireQuestLuaClass(LogicLuaClass, RESTRICTION_TYPE, QuestDefine.StateRestriction)
    RequireQuestLuaClass(FaultTolerantLuaClass, FAULT_TOLERANT_TYPE, QuestDefine.FaultTolerant)
end

function QuestFactory.CreateChapter(ChapterID, Cfg, bAsEndChapter)
    if nil == ChapterID then return nil end
    Cfg = Cfg or QuestChapterCfg:FindCfgByKey(ChapterID)
    if Cfg == nil then
        QuestHelper.PrintQuestError("QuestFactory didn't find chapter #%d in client database", ChapterID)
        return nil
    end

    local profile_tag
    local _ <close> = CommonUtil.MakeProfileTag("QuestFactory.CreateChapter")
    local NewChapter = ChapterClass.New(ChapterID, Cfg)

    if bAsEndChapter then
        QuestMgr.EndChapterMap[ChapterID] = NewChapter
    else
        QuestMgr.ChapterMap[ChapterID] = NewChapter
        QuestMgr.QuestRegister:OnAddQuest(Cfg.QuestGenreID)
    end
    return NewChapter
end

function QuestFactory.CreateQuest(QuestID, RspQuest, Cfg, bInitCreate)
    if (nil == QuestID) or (nil == RspQuest) then return nil end
    Cfg = Cfg or QuestCfg:FindCfgByKey(QuestID)
    if Cfg == nil then
        QuestHelper.PrintQuestError("QuestFactory didn't find quest #%d in client database", QuestID)
        return nil
    end

    local profile_tag
    local _ <close> = CommonUtil.MakeProfileTag("QuestFactory.CreateQuest")
    local NewQuest = QuestClass.New(QuestID, Cfg)

    NewQuest.AcceptTimeMS = RspQuest.AcceptTimeMS
    if bInitCreate then
        NewQuest.Status = RspQuest.Status
    end

    QuestMgr.QuestMap[QuestID] = NewQuest

    for TargetID, RspTarget in pairs(RspQuest.TargetNodes) do
        local Target = QuestFactory.CreateTarget(QuestID, TargetID, RspTarget, nil)
        if Target then
            NewQuest.Targets[TargetID] = Target
        end
    end

    for _, BehaviorID in ipairs(Cfg.TaskAcceptExpression) do
        local AcceptBehavior = QuestFactory.CreateBehavior(QuestID, BehaviorID)
        if AcceptBehavior then
            NewQuest.AcceptClientBehavior[BehaviorID] = AcceptBehavior
        end
    end

    for _, BehaviorID in ipairs(Cfg.TaskFinishExpression) do
        local FinishBehavior = QuestFactory.CreateBehavior(QuestID, BehaviorID)
        if FinishBehavior then
            NewQuest.FinishClientBehavior[BehaviorID] = FinishBehavior
        end
    end

    for _, LogicID in ipairs(Cfg.Logics) do
        local Logic, LogicType = QuestFactory.CreateLogic(QuestID, LogicID)
        if Logic then
            if LogicType == LOGIC_TYPE.QUEST_LOGIC_TYPE_STATE_RESTRICTION then
                NewQuest.StateRestrictions[LogicID] = Logic
            end
        end
    end

    if type(Cfg.FaultTolerantNodeID) == "table" then
        for _, FaultTolerantID in ipairs(Cfg.FaultTolerantNodeID) do
            local FaultTolerant = QuestFactory.CreateFaultTolerant(QuestID, FaultTolerantID)
            if FaultTolerant then
                NewQuest.FaultTolerants[FaultTolerantID] = FaultTolerant
            end
        end
    end
    return NewQuest
end

function QuestFactory.CreateTarget(QuestID, TargetID, RspTarget, Cfg, bCreatePlain)
    if (nil == TargetID) or (nil == RspTarget) then return nil end
    Cfg = Cfg or TargetCfg:FindCfgByKey(TargetID)
    if Cfg == nil then
        QuestHelper.PrintQuestError("QuestFactory didn't find target #%d in client database", TargetID)
        return nil
    end

    local TargetChildClass = TargetLuaClass[Cfg.m_iTargetType]
    if nil == TargetChildClass then
        QuestHelper.PrintQuestError("QuestFactory didn't find target type %d", Cfg.m_iTargetType)
        return nil
    end

    local profile_tag
    local _ <close> = CommonUtil.MakeProfileTag("QuestFactory.CreateTarget")

    local CtorParams = { QuestID = QuestID, TargetID = TargetID, Cfg = Cfg }
    local NewTarget = TargetChildClass.New(CtorParams, Cfg.Properties)

    -- 这里只创建，不能改Status，在外部更新Status以执行对应行为
    NewTarget.Count = RspTarget.count

    if (not bCreatePlain) and Cfg.m_aiTaskTargetFinishExpression then
        for _, BehaviorID in ipairs(Cfg.m_aiTaskTargetFinishExpression) do
            local Behavior = QuestFactory.CreateBehavior(QuestID, BehaviorID, TargetID)
            if Behavior then
                NewTarget.FinishClientBehavior[BehaviorID] = Behavior
            end
        end
    end
    NewTarget.LootIDs = {}
    if Cfg.m_aiTaskTargetFinishReward then
        for _, RewardID in ipairs(Cfg.m_aiTaskTargetFinishReward) do
            table.insert(NewTarget.LootIDs, RewardID)
        end
    end
    return NewTarget
end

function QuestFactory.CreateBehavior(QuestID, BehaviorID, TargetID)
    if nil == BehaviorID then return nil end
    local Cfg = ClientBehaviorCfg:FindCfgByKey(BehaviorID)
    if Cfg == nil then
        QuestHelper.PrintQuestError("QuestFactory didn't find client behavior #%d in client database", BehaviorID)
        return nil
    end

    local BehaviorChildClass = BehaviorLuaClass[Cfg.m_bExpressionType]
    if nil == BehaviorChildClass then
        QuestHelper.PrintQuestError("QuestFactory didn't find behavior type %d", Cfg.m_bExpressionType)
        return nil
    end

    local profile_tag
    local _ <close> = CommonUtil.MakeProfileTag("QuestFactory.CreateBehavior")

    local CtorParams = { BehaviorID = BehaviorID, TargetID = TargetID, BehaviorType = Cfg.m_bExpressionType }
    local ExtraParams = { QuestID = QuestID, EndCliBehavior = Cfg.EndCliBehavior, EndSvrBehavior = Cfg.EndSvrBehavior } -- 少数客户端行为需要
    local NewBehavior = BehaviorChildClass.New(CtorParams, Cfg.Properties, ExtraParams)
    return NewBehavior
end

function QuestFactory.CreateLogic(QuestID, LogicID, Cfg)
    if nil == LogicID then return nil end
    Cfg = Cfg or LogicCfg:FindCfgByKey(LogicID)
    if Cfg == nil then
        QuestHelper.PrintQuestError("QuestFactory didn't find logic #%d in client database", LogicID)
        return nil
    end

    local LogicChildClass = nil

    local CondBit = nil

    if Cfg.LogicType == LOGIC_TYPE.QUEST_LOGIC_TYPE_STATE_RESTRICTION then
        local Type = Cfg.StateRestrictionType
        LogicChildClass = LogicLuaClass[Type]

        if nil == LogicChildClass then
            QuestHelper.PrintQuestError("QuestFactory didn't find StateRestriction type %d", Type)
            return nil
        end
        CondBit = QuestDefine.StateRestriction[Type].CondBit

    else
        return nil
    end

    local CtorParams = { QuestID = QuestID, LogicID = LogicID, CondBit = CondBit }
    local NewLogic = LogicChildClass.New(CtorParams, Cfg.Properties)

    return NewLogic, Cfg.LogicType
end

function QuestFactory.CreateFaultTolerant(QuestID, FaultTolerantID)
    if not FaultTolerantID then
        return nil
    end
    local Cfg = QuestFaultTolerantCfg:FindCfgByKey(FaultTolerantID)
    if not Cfg then
        return nil
    end
    local LuaClass = FaultTolerantLuaClass[Cfg.Type]
    if not LuaClass then
        return nil
    end
    local FaultTolerant = LuaClass.New(QuestID, FaultTolerantID, Cfg.Params)
    return FaultTolerant
end

return QuestFactory

