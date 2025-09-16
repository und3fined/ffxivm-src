---
--- Author: sammrli
--- DateTime: 2024-09-13
--- 目标：完成相位副本
--- 

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

local EventID = require("Define/EventID")

---@class TargetFinishPhaseSpace
local TargetFinishPhaseSpace = LuaClass(TargetBase, true)

function TargetFinishPhaseSpace:Ctor(_, Properties)
   self.PWorldID = tonumber(Properties[1])
   self.ReturnToPWorldID = tonumber(Properties[2])
   self.ReturnAreaID = tonumber(Properties[3])
end

function TargetFinishPhaseSpace:DoStartTarget()
    self:RegisterEvent(EventID.AreaTriggerEndOverlap, self.OnEventAreaTriggerEndOverlap)
end

function TargetFinishPhaseSpace:OnEventAreaTriggerEndOverlap(EventParam)
    if EventParam then
        if EventParam.AreaID == self.ReturnAreaID then
            _G.QuestMgr:SendTargetRevert(self.TargetID)
        end
    end
end

return TargetFinishPhaseSpace