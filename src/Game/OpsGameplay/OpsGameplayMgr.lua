--
-- Author: sammrli
-- Date: 2025-5-28 15:14
-- Description: 活动玩法管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local EventID = require("Define/EventID")

local OpsGameplayDefine = require("Game/OpsGameplay/OpsGameplayDefine")

local OpsGameplayCfg = require("TableCfg/OpsGameplayCfg")

---@class OpsGameplayMgr : MgrBase
local OpsGameplayMgr = LuaClass(MgrBase)

function OpsGameplayMgr:OnInit()
end

function OpsGameplayMgr:OnBegin()
    self.GameplayMap = {} --<PWorldID, OpsGameplayBase>
end

function OpsGameplayMgr:OnRegisterNetMsg()
end

function OpsGameplayMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
end

function OpsGameplayMgr:OnRegisterTimer()
end

function OpsGameplayMgr:OnEnd()
    self:EndAllGame()
end

function OpsGameplayMgr:OnShutdown()
end

function OpsGameplayMgr:EndAllGame()
    local GameplayMap = self.GameplayMap
    if GameplayMap then
        for _, GamePlayInstance in pairs(GameplayMap) do
            GamePlayInstance:End()
        end
    end
    self.GameplayMap = {}
end

function OpsGameplayMgr:OnGameEventEnterWorld()
    local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local OpsGameplayCfgItem = OpsGameplayCfg:FindCfgByKey(PWorldResID)
    if not OpsGameplayCfgItem then
        return
    end
    local GameplayMap = self.GameplayMap
    if GameplayMap[PWorldResID] then
        return
    end

    local ClassParam = OpsGameplayDefine.ClassParams[OpsGameplayCfgItem.GameplayType]
    if ClassParam then
        local Class = require(ClassParam.Class)
        local GamePlayInstance = Class.New()
        GamePlayInstance:Init()
        GamePlayInstance:Begin()
        GameplayMap[PWorldResID] = GamePlayInstance
    end
end

function OpsGameplayMgr:OnGameEventExitWorld()
    self:EndAllGame()
end

return OpsGameplayMgr