---
--- Author: lydianwang
--- DateTime: 2022-04-01
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local EventID = require("Define/EventID")
local QuestHelper = require("Game/Quest/QuestHelper")

---@class TargetActivateCrystal
local TargetActivateCrystal = LuaClass(TargetBase, true)

function TargetActivateCrystal:Ctor(_, Properties)
    self.IndexID = tonumber(Properties[1])
    self.AuxiliaryEObjID = tonumber(Properties[2]) or 0  --辅助eobj id,用来显示任务标识
end

function TargetActivateCrystal:DoStartTarget()
    self:RegisterEvent(EventID.MajorProfSwitch, self.OnMajorProfSwitch)
    self:CheckAndFinish()
end

function TargetActivateCrystal:GetEObjID()
    return self.AuxiliaryEObjID
end

function TargetActivateCrystal:OnMajorProfSwitch()
    self:CheckAndFinish()
end

function TargetActivateCrystal:CheckAndFinish()
    -- 如果水晶已经激活,通知服务器完成任务
    if _G.PWorldMgr:GetCrystalPortalMgr():IsExistActiveCrystal(self.IndexID) then
        if QuestHelper.CheckCanAccept(self.QuestID) then
            _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
        end
    end
end

return TargetActivateCrystal