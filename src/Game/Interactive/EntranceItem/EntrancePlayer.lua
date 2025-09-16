
local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local ActorUtil = require("Utils/ActorUtil")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")

local EntrancePlayer = LuaClass(EntranceBase)
function EntrancePlayer:Ctor()
    self.TargetType = _G.UE.EActorType.Player
end

--计算Distance、入口的显示字符串
function EntrancePlayer:OnInit()
    local ActorName = ActorUtil.GetActorName(self.EntityID)
    self.DisplayName = ActorName

    if not self.Distance or self.Distance <= 0 then
        self.Distance = self:DistanceToMajor()
    end
end

function EntrancePlayer:OnUpdateDistance()
    if self.EntityID > 0 then
        local actor = ActorUtil.GetActorByEntityID(self.EntityID)

        if actor then
            self.Distance = self:DistanceToMajor()
            if _G.UE.USelectEffectMgr:TargetIsOutLockRange(self.EntityID) then
                local EventParams = _G.EventMgr:GetEventParams()
                EventParams.IntParam1 = self.TargetType
                EventParams.ULongParam1 = self.EntityID
                EventMgr:SendEvent(EventID.LeaveInteractionRange, EventParams)
            end
        else
            self.EntityID = 0
        end
    end
end

function EntrancePlayer:DistanceToMajor()
    local Res = 0
    local MajorLoc = MajorUtil.GetMajor():FGetActorLocation()
    local Player = ActorUtil.GetActorByEntityID(self.EntityID)

    if Player ~= nil then
        Res =  (Player:FGetActorLocation() - MajorLoc):Size()
    end
    return Res
end

function EntrancePlayer:CheckInterative(EnableCheckLog)
    return true
end

--Entrance的响应逻辑
function EntrancePlayer:OnClick()
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = self.EntityID
    EventMgr:SendCppEvent(EventID.ManualSelectTarget,EventParams)
    return true
end

function EntrancePlayer:OnGenFunctionList()
    local FunctionList = {}

    return FunctionList
end

return EntrancePlayer
