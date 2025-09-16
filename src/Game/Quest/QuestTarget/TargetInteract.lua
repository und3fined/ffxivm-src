---
--- Author: lydianwang
--- DateTime: 2021-12-30
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local InteractionIconCfg = require("TableCfg/InteractionIconCfg")
local InteractionButtonTextCfg = require("TableCfg/InteractionButtonTextCfg")

local QuestMgr = nil

---@class TargetInteract
local TargetInteract = LuaClass(TargetBase, true)

function TargetInteract:Ctor(_, Properties)
    self.NpcID = tonumber(Properties[1])
    self.InteractID = tonumber(Properties[2])
    -- self.MaxCount = tonumber(Properties[3]) -- 这个没有用到
    self.EObjID = tonumber(Properties[4])
    self.IconID = tonumber(Properties[5])
    self.ButtonTextID = tonumber(Properties[6]) or 0
    self.bFollowTargetInteract = (tonumber(Properties[7]) == 1) -- 按目标进度显示交互

    local Cfg = InteractionIconCfg:FindCfgByKey(self.IconID)
    self.IconPath = (Cfg ~= nil) and Cfg.IconPath or ""

    self.DisplayName = nil
    local ButtonTextCfg = InteractionButtonTextCfg:FindCfgByKey(self.ButtonTextID)
    if ButtonTextCfg then
        self.DisplayName = ButtonTextCfg.Text
    else
        QuestHelper.PrintQuestWarning("TargetInteract #%d ButtonTextID %d cfg not found",
            self.TargetID, self.ButtonTextID)
    end

    QuestMgr = _G.QuestMgr
end

function TargetInteract:DoStartTarget()
    self:RegisterEvent(_G.EventID.ClientInteraction, self.OnClientInteraction)
    if self.IconPath or self.DisplayName then
        QuestMgr.QuestRegister:RegisterOverwriteInteract(self.InteractID, self)
    end
    if self.bFollowTargetInteract then
        QuestMgr.QuestRegister:RegisterFollowTargetInteract(self.InteractID, self)
    end
end

function TargetInteract:DoClearTarget()
    if self.IconPath or self.DisplayName then
        QuestMgr.QuestRegister:UnRegisterOverwriteInteract(self.InteractID, self)
    end
    if self.bFollowTargetInteract then
        QuestMgr.QuestRegister:UnRegisterFollowTargetInteract(self.InteractID, self)
    end
end

function TargetInteract:OnClientInteraction(ResID, InteractID)
    if ResID == self.NpcID and (InteractID == self.InteractID or self.InteractID == 0) then
        QuestMgr:SendFinishTarget(self.QuestID, self.TargetID, self.NpcID)
    end
end

function TargetInteract:GetNpcID()
    return self.NpcID or 0
end

function TargetInteract:GetEObjID()
    return self.EObjID or 0
end

return TargetInteract