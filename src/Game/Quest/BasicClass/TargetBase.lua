---
--- Author: lydianwang
--- DateTime: 2022-05-30
---

local LuaClass = require("Core/LuaClass")
local GameEventRegister = require("Register/GameEventRegister")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")

local ProtoCS = require("Protocol/ProtoCS")
-- local ProtoRes = require("Protocol/ProtoRes")

local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS
local STATUS_NOT_STARTED    = TARGET_STATUS.CS_QUEST_NODE_STATUS_NOT_STARTED
local STATUS_IN_PROGRESS    = TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS
local STATUS_FINISHED       = TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED
-- local STATUS_FAILED         = TARGET_STATUS.CS_QUEST_NODE_STATUS_FAILED

local CommonUtil = require("Utils/CommonUtil")
local QuestMgr = nil

local StatusChangeFunc = {}
local function AddStatusChangeFunc(OldStatus, NewStatus, Func)
    StatusChangeFunc[OldStatus + 1][NewStatus + 1] = Func
end

for _, OldStatus in pairs(TARGET_STATUS) do
    StatusChangeFunc[OldStatus + 1] = {} -- QUEST_STATUS从0起，此处改为从1起，避免table保留哈希表
end

-- ==================================================
--
-- ==================================================

---@class TargetBase
local TargetBase = LuaClass()

function TargetBase:Ctor(CtorParams, _)
    self.QuestID = CtorParams.QuestID
    self.TargetID = CtorParams.TargetID
    self.Cfg = CtorParams.Cfg

    self.Status = STATUS_NOT_STARTED
    self.Count = nil
    self.MaxCount = nil

    self.FinishClientBehavior = {}
    self.bTeleportAfterTarget = QuestHelper.CheckTeleportAfterTarget(self)

    QuestMgr = _G.QuestMgr
end

function TargetBase:UpdateTargetInfo(NewStatus, Count)
    local Func = StatusChangeFunc[self.Status + 1][NewStatus + 1]

    if self.Status ~= NewStatus or self.Count ~= Count then
        self:AddStatusChange(NewStatus)
    end

    self.Status = NewStatus
    self.Count = Count

    if Func then Func(self) end
end

function TargetBase:AddStatusChange(NewStatus)
    local StChangeParams = {
        OldStatus = self.Status,
        NewStatus = NewStatus,
    }
    QuestMgr:AddTargetStatusChange(self.QuestID, self.TargetID, StChangeParams)
end

function TargetBase:StartTarget(bRevert)
    if self:ValidNaviConfig() then
        _G.QuestTrackMgr:AddMapQuestParam(self.Cfg.MapID, self.QuestID, self.TargetID,
            self.Cfg.NaviType, self.Cfg.NaviObjID, self.Cfg.AssistNaviPoint, self.Cfg.UIMapID)
    end

    do
        local _ <close> = CommonUtil.MakeProfileTag("StartTarget_DoStartTarget")
        self:DoStartTarget(bRevert)
    end

    QuestHelper.AddNpcQuestTarget(self.QuestID, self)
    QuestHelper.AddMonsterQuestTarget(self.QuestID, self)
    QuestHelper.AddEObjQuestTarget(self.QuestID, self)

    do
        local _ <close> = CommonUtil.MakeProfileTag("StartTarget_PostStartTarget")
        self:PostStartTarget()
    end
end

function TargetBase:ClearTarget()
    QuestHelper.RemoveNpcQuestTarget(self.QuestID, self)
    QuestHelper.RemoveMonsterQuestTarget(self.QuestID, self)
    QuestHelper.RemoveEObjQuestTarget(self.QuestID, self)

    self:DoClearTarget()

	if nil ~= self.GameEventRegister then
        self.GameEventRegister:UnRegisterAll()
	end

    if self:ValidNaviConfig() then
        _G.QuestTrackMgr:RemoveMapQuestParam(self.Cfg.MapID, self.QuestID, self.TargetID)
    end
end

function TargetBase:ValidNaviConfig()
    return (self.Cfg.NaviType > QuestDefine.NaviType.MIN)
        and (self.Cfg.NaviType < QuestDefine.NaviType.MAX)
        and (self.Cfg.NaviType ~= QuestDefine.NaviType.None)
        and (self.Cfg.MapID > 0) and (self.Cfg.NaviObjID > 0)
end

---@return int32
function TargetBase:GetMapIDList()
    return self:ValidNaviConfig() and { [self.Cfg.MapID] = true } or {}
end

---@return TargetBase
function TargetBase:GetNextTarget()
    local Quest = QuestMgr.QuestMap[self.QuestID]
    local NextTarget = nil
    if Quest then
        NextTarget = Quest.Targets[self.Cfg.NextTarget]
    end
    return NextTarget
end

-- ==================================================
-- 目标状态变化逻辑
-- ==================================================

function TargetBase:Start()
    -- QuestHelper.PrintQuestInfo("Start target #%d", self.TargetID)
    self:StartTarget()

    if QuestHelper.CheckAutoDoTarget(self.QuestID, self.TargetID, self.Cfg.m_iTargetType) then
        self:AutoDoTarget()
    end
end

function TargetBase:UpdateProgress()
    -- QuestHelper.PrintQuestInfo("Update target #%d", self.TargetID)
end

function TargetBase:Finish()
    -- QuestHelper.PrintQuestInfo("Finish target #%d", self.TargetID)
    for _, Behavior in pairs(self.FinishClientBehavior) do
        Behavior:StartBehavior()
    end
    self:ClearTarget()
    QuestHelper.CheckBagLeftNum(nil, self)
end

function TargetBase:DirectFinish()
    QuestHelper.PrintQuestInfo("DirectFinish target #%d", self.TargetID)
    for _, Behavior in pairs(self.FinishClientBehavior) do
        local Params = QuestDefine.BehaviorClassParams[Behavior.BehaviorType]
        if (Params ~= nil) and (not Params.bIgnoreWhenDirectFinish) then
            Behavior:StartBehavior()
        else
            QuestHelper.PrintQuestInfo("DirectFinish jump behavior #%d", Behavior.BehaviorID)
        end
    end
    self:ClearTarget()
    QuestHelper.CheckBagLeftNum(nil, self)
end

function TargetBase:RevertStart()
    QuestHelper.PrintQuestInfo("Revert start target #%d", self.TargetID)
    self:ClearTarget()
    self:StartTarget(true)
end

function TargetBase:Revert()
    QuestHelper.PrintQuestInfo("Revert target #%d", self.TargetID)
    self:ClearTarget()
end

AddStatusChangeFunc(STATUS_NOT_STARTED, STATUS_IN_PROGRESS, TargetBase.Start)
AddStatusChangeFunc(STATUS_NOT_STARTED, STATUS_FINISHED, TargetBase.DirectFinish)

AddStatusChangeFunc(STATUS_IN_PROGRESS, STATUS_NOT_STARTED, TargetBase.Revert)
AddStatusChangeFunc(STATUS_IN_PROGRESS, STATUS_IN_PROGRESS, TargetBase.UpdateProgress)
AddStatusChangeFunc(STATUS_IN_PROGRESS, STATUS_FINISHED, TargetBase.Finish)

AddStatusChangeFunc(STATUS_FINISHED, STATUS_IN_PROGRESS, TargetBase.RevertStart)
AddStatusChangeFunc(STATUS_FINISHED, STATUS_NOT_STARTED, TargetBase.Revert)

-- ==================================================
-- 事件注册
-- ==================================================

function TargetBase:RegisterEvent(QuestEventID, Callback)
	if nil == self.GameEventRegister then
		self.GameEventRegister = GameEventRegister.New()
	end
	self.GameEventRegister:Register(QuestEventID, self, Callback)
end

-- ==================================================
-- 子类接口
-- ==================================================

function TargetBase:DoStartTarget() end

function TargetBase:PostStartTarget() end

function TargetBase:DoClearTarget() end

---@return int32
function TargetBase:GetNpcID() return 0 end

---@return table
function TargetBase:GetNpcIDList() return {} end

---@return int32
function TargetBase:GetDialogID() return 0 end

---@return int32
function TargetBase:GetMonsterID() return 0 end

---@return table
function TargetBase:GetMonsterIDList() return {} end

---@return int32
function TargetBase:GetEObjID() return 0 end

---@return table
function TargetBase:GetEObjIDList() return {} end

function TargetBase:AutoDoTarget() end

---主要用于图标显示
---@return boolean
function TargetBase:CheckCanFinish() return true end

---任务便捷推进
---@return boolean
function TargetBase:PushTrack() return false end

return TargetBase