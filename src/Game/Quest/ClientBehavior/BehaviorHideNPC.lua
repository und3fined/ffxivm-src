---
--- Author: lydianwang
--- DateTime: 2021-12-14
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local ActorUtil = require("Utils/ActorUtil")

local TArray = _G.UE.TArray
local FVector = _G.UE.FVector

local WALK_SPEED = 200
local RUN_SPEED = 500

---@class BehaviorHideNPC
local BehaviorHideNPC = LuaClass(BehaviorBase, true)

function BehaviorHideNPC:Ctor(_, Properties)
    self.NpcID = tonumber(Properties[1])
    self.bLeaveBehavior = (tonumber(Properties[2]) == 1)
    self.LeaveType = (tonumber(Properties[3]) or 0) + 1 -- BP ENpcLeaveType
    self.LeaveDir = tonumber(Properties[4]) or 0
    self.LeaveTime = tonumber(Properties[5]) or 1

    FLOG_INFO("[QuestTrack] BehaviorHideNPC:Ctor, NpcID="..tostring(self.NpcID))
end

function BehaviorHideNPC:DoStartBehavior()
    FLOG_INFO("[QuestTrack] BehaviorHideNPC:DoStartBehavior , bLeaveBehavior="..tostring(self.bLeaveBehavior))
    if self.bLeaveBehavior then
        self:LeaveMove()
        FLOG_INFO("[QuestTrack] BehaviorHideNPC:DoStartBehavior , StartTimer LeaveTime="..tostring(self.LeaveTime))
        _G.TimerMgr:AddTimer(nil, function()
            FLOG_INFO("[QuestTrack] BehaviorHideNPC:DoStartBehavior , OnTimer NpcID="..tostring(self.NpcID))
            _G.QuestMgr.QuestRegister:UnRegisterClientNpc(self.NpcID)
        end, self.LeaveTime)
    else
        FLOG_INFO("[QuestTrack] BehaviorHideNPC:DoStartBehavior , UnRegister Immediately")
        _G.QuestMgr.QuestRegister:UnRegisterClientNpc(self.NpcID)
    end
end

local ZAxis = FVector(0, 0, 1)
function BehaviorHideNPC:LeaveMove()
    local NpcData = _G.MapEditDataMgr:GetNpc(self.NpcID)
    if NpcData == nil then return end
	local EntityID = ActorUtil.GetActorEntityIDByResID(self.NpcID)
    if EntityID == nil then return end
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor then
        local AnimComp = Actor:GetAnimationComponent()
        if AnimComp then
            AnimComp:StopAnimation()
        end
    end

    local PathPoints = TArray(FVector)
    local P = NpcData.BirthPoint
    local NpcPos = FVector(P.X, P.Y, P.Z)

    local bRunning = (self.LeaveType == 2)
    local Speed = bRunning and RUN_SPEED or WALK_SPEED

    local ForwardVec = FVector(Speed * (self.LeaveTime + 1), 0, 0)
    local WalkVec = ForwardVec:RotateAngleAxis(NpcData.BirthDir + self.LeaveDir, ZAxis)
    local HalfPos = NpcPos + WalkVec / 2
    PathPoints:Add(HalfPos) -- 为适配FClientLocalMoveStrategy和FShadowTracer加的一个点，后续可优化
    local EndPos = NpcPos + WalkVec
    PathPoints:Add(EndPos)

    local NpcActor = ActorUtil.GetActorByEntityID(EntityID)
    if NpcActor ~= nil and NpcActor.ForceAbortTurning ~= nil then
        NpcActor:ForceAbortTurning()
        local StateComp = NpcActor:GetStateComponent()
        if StateComp then
            StateComp:SetRunningState(bRunning)
        end
    end
    _G.UE.UMoveSyncMgr:Get():StartClientMove(EntityID, PathPoints, Speed)
end

return BehaviorHideNPC