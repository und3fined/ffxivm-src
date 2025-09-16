---
--- Author: sammrli
--- DateTime: 2025-2-21
--- 开启Fate
---

local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local FaultTolerantBase = require("Game/Quest/BasicClass/FaultTolerantBase")
local ProtoCS = require("Protocol/ProtoCS")

---@class FaultTolerantFate
local FaultTolerantFate = LuaClass(FaultTolerantBase)

function FaultTolerantFate:OnInit(Params)
    self.FateID = Params[1] or 0

    self:CheckFateActive()
end

function FaultTolerantFate:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.FateUpdate, self.OnFateUpdate)
    self:RegisterGameEvent(EventID.FateEnd, self.OnFateEnd)
    self:RegisterGameEvent(EventID.InitQuest, self.OnInitQuest)
    --self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
end

function FaultTolerantFate:OnDestroy()
end

function FaultTolerantFate:OnInitQuest()
    self:CheckFateActive()
end

function FaultTolerantFate:OnUpdateQuest(Params)
    if not Params then
        return
    end

    if Params.QuestID then
        if self.QuestID == Params.QuestID then
            self:CheckFateActive()
            return
        end
    end

    local UpdatedRspQuests = Params.UpdatedRspQuests
    if UpdatedRspQuests then
        for _, RspQuest in pairs(UpdatedRspQuests) do
            if self.QuestID == RspQuest.QuestID then
                self:CheckFateActive()
                break
            end
        end
    end
end

function FaultTolerantFate:OnFateUpdate(Param)
    if Param then
        if Param.ID ~= self.FateID then
            return
        end
    end
    self:CheckFateActive()
end

function FaultTolerantFate:OnFateEnd(Param)
    if Param then
        if Param.ID ~= self.FateID then
            return
        end
    end
    self:CheckFateActive()
end

function FaultTolerantFate:CheckFateActive()
    local FateInfo = _G.FateMgr:GetActiveFate(self.FateID)
    if FateInfo and FateInfo.State and FateInfo.State >= ProtoCS.FateState.FateState_InProgress then
        self:EndFaultTolerant(self.QuestID, self.FaultTolerantID)
    else
        self:StartFaultTolerant(self.QuestID, self.FaultTolerantID)
    end
end

return FaultTolerantFate