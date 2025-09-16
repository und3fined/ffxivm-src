
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")

local QuestDefine = require("Game/Quest/QuestDefine")

local CommonUtil = require("Utils/CommonUtil")
local QuestCondBit = QuestDefine.CondBit

local QuestMgr = nil

-- 每个任务记录不满足哪个条件，以及哪个条件未更新
-- 每次事件，给所有任务做标记，对应条件未更新
-- 需要查询任务条件时，碰到未更新的就更新，记录是否满足

---@class QuestCondMgr : MgrBase
local QuestCondMgr = LuaClass(MgrBase)

function QuestCondMgr:OnInit()
    self.CondPassedMap = {} -- map< QuestID, BitMask > -- 0代表两种状态：未检查过、通过检查。两种状态都判断为通过
    self.CondChangedMap = {} -- map< QuestID, BitMask >

    QuestMgr = _G.QuestMgr
end

-- function QuestCondMgr:OnBegin()
-- end

-- function QuestCondMgr:OnEnd()
-- end

-- function QuestMgr:OnShutdown()
-- end

-- function QuestCondMgr:OnRegisterNetMsg()
-- end

---条件管理器监听事件要注意其他地方会不会也监听同样的事件，如果其他地方也有并且有调用QuestCondMgr，要保证执行顺序
function QuestCondMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorProfActivate, self.OnGameEventMajorProfActivate)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnGameEventMajorProfSwitch)
    self:RegisterGameEvent(EventID.CounterInit, self.OnGameEventCounter)
    --[sammrli] 移除监听,由QuestMgr那边调用 OnGameEventCounter
    --self:RegisterGameEvent(EventID.CounterUpdate, self.OnGameEventCounter)
    --self:RegisterGameEvent(EventID.CounterClear, self.OnGameEventCounter)
    self:RegisterGameEvent(EventID.CompanySealRankUp, self.OnGameEventCompany)
    self:RegisterGameEvent(EventID.CompanySealJionGrandCompany, self.OnGameEventCompany)
    self:RegisterGameEvent(EventID.OpsActivityUpdate, self.OnGameEventActivityUpdate)
    self:RegisterGameEvent(EventID.ChocoboMaxLevelChange, self.OnGameEventChocoboMaxLevelChange)
end

function QuestCondMgr:OnQuestMsgUpdate()
    self:OnConditionUpdate(QuestCondBit.QuestUpdate)
end

function QuestCondMgr:OnGameEventMajorProfActivate()
    self:OnConditionUpdate(QuestCondBit.ProfActivate)
    if self.LastTaskID then
        _G.SlicingMgr:StopTask(self.LastTaskID)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("QuestCondMgr:OnGameEventMajorProfActivate")
        local co = coroutine.create(QuestMgr.OnQuestConditionUpdate)
        self.LastTaskID = _G.SlicingMgr:EnqueueCoroutineAndExecOnce(co, QuestMgr, false, true)
    end
    QuestMgr:SendEventOnConditionUpdate()
end

function QuestCondMgr:OnGameEventMajorProfSwitch()
    self:OnConditionUpdate(QuestCondBit.ProfSwitch)
    if self.LastTaskID then
        _G.SlicingMgr:StopTask(self.LastTaskID)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("QuestCondMgr:OnGameEventMajorProfSwitch")
        local co = coroutine.create(QuestMgr.OnQuestConditionUpdate)
        self.LastTaskID = _G.SlicingMgr:EnqueueCoroutineAndExecOnce(co, QuestMgr, false, true)
    end
    QuestMgr:SendEventOnConditionUpdate()
end

function QuestCondMgr:OnGameEventCounter()
    self:OnConditionUpdate(QuestCondBit.Counter)
end

function QuestCondMgr:OnGameEventCompany()
    self:OnConditionUpdate(QuestCondBit.GrandCompany)
    if self.LastTaskID then
        _G.SlicingMgr:StopTask(self.LastTaskID)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("QuestCondMgr:OnGameEventCompany")
        local co = coroutine.create(QuestMgr.OnQuestConditionUpdate)
        self.LastTaskID = _G.SlicingMgr:EnqueueCoroutineAndExecOnce(co, QuestMgr, false, true)
    end
    QuestMgr:SendEventOnConditionUpdate()
end

function QuestCondMgr:OnGameEventActivityUpdate()
    local QuestRegister = QuestMgr.QuestRegister
    local NeedSendQuestUpdate = false
    local ActivityQuestMap = QuestRegister.ActivityQuestMap
    for QuestID, ActID in pairs(ActivityQuestMap) do
        local OldPass = self:IsQuestCondPass(QuestID, QuestCondBit.Activity)
        local NewPass = QuestRegister:IsActivityOpen(ActID)
        if not CommonUtil.IsShipping() then
            FLOG_INFO("[QuestCondMgr] OnGameEventActivityUpdate "..tostring(QuestID).." "..tostring(ActID).." OldPass="..tostring(OldPass).." NewPass="..tostring(NewPass))
        end
        if OldPass ~= NewPass then
            NeedSendQuestUpdate = true
            break
        end
    end
    self:OnConditionUpdate(QuestCondBit.Activity)
    if not NeedSendQuestUpdate then
        return
    end
    if self.LastTaskID then
        _G.SlicingMgr:StopTask(self.LastTaskID)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("QuestCondMgr:OnGameEventActivityUpdate")
        local co = coroutine.create(QuestMgr.OnQuestConditionUpdate)
        self.LastTaskID = _G.SlicingMgr:EnqueueCoroutineAndExecOnce(co, QuestMgr, false, true)
    end
end

function QuestCondMgr:OnGameEventChocoboMaxLevelChange()
    self:OnConditionUpdate(QuestCondBit.ChocoboLevel)
    if self.LastTaskID then
        _G.SlicingMgr:StopTask(self.LastTaskID)
    end
    do
        local _ <close> = CommonUtil.MakeProfileTag("QuestCondMgr:OnGameEventChocoboMaxLevelChange")
        local co = coroutine.create(QuestMgr.OnQuestConditionUpdate)
        self.LastTaskID = _G.SlicingMgr:EnqueueCoroutineAndExecOnce(co, QuestMgr, false, true)
    end
    QuestMgr:SendEventOnConditionUpdate()
end

function QuestCondMgr:OnConditionUpdate(ContidionBit)
    local _ <close> = CommonUtil.MakeProfileTag("QuestCondMgr:OnConditionUpdate")
    local CCMap = self.CondChangedMap
    for QuestID, CondChanged in pairs(CCMap) do
        CCMap[QuestID] = CondChanged | ContidionBit
    end
end

---@return int32
function QuestCondMgr:IsCondChanged(QuestID, ContidionBit)
    local CCMap = self.CondChangedMap
    if CCMap[QuestID] == nil then
        CCMap[QuestID] = QuestDefine.AllCondBitMask
    end

    local CPMap = self.CondPassedMap
    if CPMap[QuestID] == nil then
        CPMap[QuestID] = 0
    end

    local CondChange = CCMap[QuestID]
    local bCondChanged = (CondChange & ContidionBit) ~= 0
    CCMap[QuestID] = CondChange & ~ContidionBit

    return bCondChanged
end

---@return boolean
function QuestCondMgr:SetQuestCond(QuestID, ContidionBit, bPassed)
    local CPMap = self.CondPassedMap
    if CPMap[QuestID] == nil then
        CPMap[QuestID] = 0
    end

    local CondPassed = CPMap[QuestID]
    CPMap[QuestID] = bPassed
        and CondPassed & ~ContidionBit
        or CondPassed | ContidionBit

    local CondPassedNew = CPMap[QuestID]
    return (CondPassedNew == 0)
end

---@return boolean
function QuestCondMgr:IsQuestCondPass(QuestID, ContidionBit)
    local CondPassed = self.CondPassedMap[QuestID]
    if ContidionBit == nil then
        return CondPassed == 0
    else
        return (CondPassed & ContidionBit) == 0
    end
end

function QuestCondMgr:RemoveQuestCond(QuestID)
    self.CondPassedMap[QuestID] = nil
    self.CondChangedMap[QuestID] = nil
end

function QuestCondMgr:ClearQuestCond()
    self.CondPassedMap = {}
    self.CondChangedMap = {}
end

return QuestCondMgr
