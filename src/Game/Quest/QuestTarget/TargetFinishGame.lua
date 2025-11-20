---
--- Author: sammrli
--- DateTime: 2025-06-03
--- 目标：完成玩法
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local ProtoRes = require("Protocol/ProtoRes")

local CommonUtil = require("Utils/CommonUtil")

local EventID = require("Define/EventID")

---@class FinishGameParam
---@field GameID number

---@class TargetFinishGame
local TargetFinishGame = LuaClass(TargetBase, true)

function TargetFinishGame:Ctor(_, Properties)
    ---@type ProtoRes.Game.GameID
    self.GameID = tonumber(Properties[1]) or 0
    self.NpcID = tonumber(Properties[2]) or 0
    self.EObjID = tonumber(Properties[3]) or 0
end

function TargetFinishGame:DoStartTarget()
    --self:RegisterEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    --self:RegisterEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterEvent(EventID.QuestFinishGameplay, self.OnGameEventQuestFinishGameplay)
end

function TargetFinishGame:DoClearTarget()
end

---@param Param FinishGameParam
function TargetFinishGame:OnGameEventQuestFinishGameplay(Param)
    if not Param then
        if not CommonUtil.IsShipping() then
            FLOG_INFO("[TargetFinishGame] OnEvent Param is nil")
        end
        return
    end
    local GameID = Param.GameID
    if GameID == self.GameID then
        _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
    end
    if not CommonUtil.IsShipping() then
        FLOG_INFO("[TargetFinishGame] OnEvent self=%s , GameID=%s",tostring(self.GameID), tostring(GameID))
    end
end

function TargetFinishGame:OnGameEventLoginRes(Params)
    if Params.bReconnect then --断线重连
    end
end

function TargetFinishGame:OnGameEventEnterWorld()
end

function TargetFinishGame:GetNpcID()
    return self.NpcID
end

function TargetFinishGame:GetEObjID()
    return self.EObjID
end

return TargetFinishGame