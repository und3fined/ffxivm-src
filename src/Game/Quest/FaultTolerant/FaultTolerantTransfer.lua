---
--- Author: sammrli
--- DateTime: 2024-12-17
--- 传送补救
---

local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local FaultTolerantBase = require("Game/Quest/BasicClass/FaultTolerantBase")

---@class FaultTolerantTransfer
local FaultTolerantTransfer = LuaClass(FaultTolerantBase)

function FaultTolerantTransfer:OnInit(Params)
    self.PWorldID = Params[1] or 0
    self.MapID = Params[2] or 0
    self.PointID = Params[3] or 0
end

function FaultTolerantTransfer:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.InitQuest, self.OnInitQuest)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
end

function FaultTolerantTransfer:OnDestroy()
end

function FaultTolerantTransfer:CheckMap(MapResID)
    if self.MapID ~= MapResID then
        self:StartFaultTolerant(self.QuestID, self.FaultTolerantID)
    else
        self:EndFaultTolerant(self.QuestID, self.FaultTolerantID)
    end
end

function FaultTolerantTransfer:OnInitQuest()
    self:CheckMap(_G.PWorldMgr:GetCurrMapResID())
end

function FaultTolerantTransfer:OnUpdateQuest(Params)
    if not Params then
        return
    end

    if Params.QuestID then
        if self.QuestID == Params.QuestID then
            self:CheckMap(_G.PWorldMgr:GetCurrMapResID())
            return
        end
    end

    local UpdatedRspQuests = Params.UpdatedRspQuests
    if UpdatedRspQuests then
        for _, RspQuest in pairs(UpdatedRspQuests) do
            if self.QuestID == RspQuest.QuestID then
                self:CheckMap(_G.PWorldMgr:GetCurrMapResID())
                break
            end
        end
    end
end

function FaultTolerantTransfer:OnGameEventEnterWorld(Param)
    if not Param then
        return
    end
    if Param.bFromCutScene then --ncut切地图不判断
        return
    end
    self:CheckMap(Param.CurrMapResID)
end

return FaultTolerantTransfer