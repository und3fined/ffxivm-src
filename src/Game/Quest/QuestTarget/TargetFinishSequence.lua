---
--- Author: lydianwang
--- DateTime: 2021-10-22
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local ObjectGCType = require("Define/ObjectGCType")

local QuestMgr = nil
local QuestRegister = nil

---@class TargetFinishSequence
local TargetFinishSequence = LuaClass(TargetBase, true)

function TargetFinishSequence:Ctor(_, Properties)
    self.SequenceID = tonumber(Properties[1])
    self.bMapAutoPlay = (tonumber(Properties[2]) == 1)
    self.MapID = tonumber(Properties[3])

    self.bSequenceStopped = true
    QuestMgr = _G.QuestMgr
    QuestRegister = QuestMgr.QuestRegister
end

function TargetFinishSequence:DoStartTarget()
    self.bSequenceStopped = false

    local NextTarget = self:GetNextTarget()
    local bContinuousSequence = NextTarget and QuestHelper.CheckTargetPlaySeq(NextTarget)
    if bContinuousSequence or self.bTeleportAfterTarget then
        QuestRegister:RegisterBlackScreenOnStopDialogOrSeq(self.SequenceID)
    end
    if QuestHelper.CheckTeleportAfterContinuousSequence(self) then
        QuestRegister:RegisterTeleportAfterSequence(self.SequenceID)
    end
    if self.bNeedChangeMap then
        QuestHelper.UnRegisterWaitingSequenceWithChangeMap(self.SequenceID)
    end

    local function OnPrePlaySequence()
        if self.SequenceID > 0 and bContinuousSequence then
            NextTarget:PreprocessTarget(self.SequenceID)
        end
    end

    -- 对于进地图触发的Sequence, 可能出现登录的时候已经在对应地图了, 这种情况下触发Target的时候其实已经在播放Sequence了, 不需要再等待进入对应地图
    if (not self.bMapAutoPlay) or (_G.StoryMgr:GetCurrentSequenceID() == self.SequenceID) then
        OnPrePlaySequence()
    end

    if self.bMapAutoPlay then
        QuestRegister:RegisterMapAutoPlaySequence(
            self.MapID, self.SequenceID, self.QuestID, self.TargetID, OnPrePlaySequence)
    else
        self:PlaySequence()
    end
end

function TargetFinishSequence:DoClearTarget()
    QuestRegister:UnRegisterBlackScreenOnStopDialogOrSeq(self.SequenceID)
    QuestRegister:UnRegisterTeleportAfterSequence(self.SequenceID)
    if self.bMapAutoPlay then
        QuestRegister:UnRegisterMapAutoPlaySequence(self.MapID)
    end
    if self.bNeedChangeMap then
        QuestHelper.UnRegisterWaitingSequenceWithChangeMap(self.SequenceID)
    end
    self.bSequenceStopped = true
end

function TargetFinishSequence:PlaySequence()
    if self.SequenceID > 0 then
        local function SequenceStoppedCallback(_)
            _G.NpcDialogMgr:CheckNeedEndInteraction()
            self:SendFinishSequence()
        end
        QuestHelper.QuestPlaySequence(self.SequenceID, SequenceStoppedCallback)
    end
end

function TargetFinishSequence:SendFinishSequence()
    if self.bSequenceStopped then return end
    QuestMgr:SendFinishTargetWithBranchCheck(self.QuestID, self.TargetID)
    self.bSequenceStopped = true
end

function TargetFinishSequence:PreprocessTarget(PreSequenceID)
    self.bNeedChangeMap = false
    if self.SequenceID <= 0 then
        return
    end
    -- 如果是bMapAutoPlay的目标节点会在进入对应场景的时候自动播放, 需要保证该目标触发的时候的场景正确
    if self.bMapAutoPlay then
        return
    end
    local SequencePath = QuestHelper.GetSequencePath(self.SequenceID)
    if not SequencePath then
        return
    end
    local function OnLoadSequenceComplete()
        -- 通过加载完成后的Sequence确定是否需要进行切场景操作
        local StoryMgrInstance = _G.UE.UStoryMgr:Get()
        if StoryMgrInstance == nil then
            return
        end
        local SequenceObject = _G.ObjectMgr:GetObject(SequencePath)
        local ChangeMapInfo = StoryMgrInstance:GetChangeMapInfoCustom(SequenceObject)
        -- Sequence在一开始就会切地图的话, 上一个播放的Sequence结束的时候就不需要切回地图了
        if (ChangeMapInfo.bExecuteImmediately and ChangeMapInfo.MapPath ~= "") then
            self.bNeedChangeMap = true
            QuestHelper.RegisterWaitingSequenceWithChangeMap(PreSequenceID, self.SequenceID)
        end
    end

    local function OnLoadSequenceFailed()
        -- 加载失败的Sequence不需要处理
    end

    _G.ObjectMgr:LoadObjectAsync(SequencePath, OnLoadSequenceComplete, ObjectGCType.LRU, OnLoadSequenceFailed)
end

return TargetFinishSequence