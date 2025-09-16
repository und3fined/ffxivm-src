---
--- Author: lydianwang
--- DateTime: 2021-12-14
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local AudioUtil = require("Utils/AudioUtil")

local UE = _G.UE

---@class BehaviorPlaySound
local BehaviorPlaySound = LuaClass(BehaviorBase, true)

function BehaviorPlaySound:Ctor(_, Properties)
    self.SoundPath = Properties[1] or ""
    self.PointID = tonumber(Properties[2]) or 0
    self.MapID = tonumber(Properties[3]) or 0
end

function BehaviorPlaySound:DoStartBehavior()
    if (self.PointID == 0) or (self.MapID == 0) then
        self:Play2D()
    else
        self:Play3D()
    end
end

function BehaviorPlaySound:Play2D()
    local PlayResult = AudioUtil.SyncLoadAndPlay2DSound(self.SoundPath)

    if PlayResult == 0 then -- 调用C++，但没成功播放
        QuestHelper.PrintQuestWarning("Play 2D Sound %s failed for client behavior %d",
            self.SoundPath, self.BehaviorID)

    elseif PlayResult == nil then -- lua打断
        QuestHelper.PrintQuestError("Invalid 2D SoundPath for client behavior %d", self.BehaviorID)
    end
end

function BehaviorPlaySound:Play3D()
    local PWorldMgr = _G.PWorldMgr
    local CurrMapID = PWorldMgr:GetCurrMapResID()
    if (CurrMapID ~= self.MapID) then
        QuestHelper.PrintQuestWarning("Play 3D Sound in wrong map for client behavior %d", self.BehaviorID)
        return
    end

    local MapPoint = _G.MapEditDataMgr:GetMapPoint(self.PointID)
    if (MapPoint == nil) then
        QuestHelper.PrintQuestWarning("PointID %d not found when playing 3D Sound for client behavior %d",
            self.PointID, self.BehaviorID)
        return
    end

    local WorldOrigin = PWorldMgr:GetWorldOriginLocation()
    local P = MapPoint.Point
    local Loc = UE.FVector(P.X, P.Y, P.Z) - WorldOrigin
    local Rot = UE.FRotator(0.0, MapPoint.Dir, 0.0)

    local SoundID = AudioUtil.SyncLoadAndPlaySoundAtLocation(self.SoundPath, Loc, Rot)
    -- 这里需要确认功能和需求，判断是否考虑StopSound

    if SoundID == 0 then -- 调用C++，但没成功播放
        QuestHelper.PrintQuestWarning("Play 3D Sound %s failed for client behavior %d",
            self.SoundPath, self.BehaviorID)
    end
end

return BehaviorPlaySound