--
-- Author: haialexzhou
-- Date: 2021-9-23
-- Description:Trigger触发器
--
local LuaClass = require("Core/LuaClass")
local DynDataBase = require("Game/PWorld/DynData/DynDataBase")
local DynDataCommon = require("Game/PWorld/DynData/DynDataCommon")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")

local EDynDataTriggerShapeType = DynDataCommon.EDynDataTriggerShapeType

local AMajorCharacter = _G.UE.AMajorCharacter

---@class DynDataTriggerBase
local DynDataTriggerBase = LuaClass(DynDataBase, true)

function DynDataTriggerBase:Ctor()
    self.TriggerActor = nil
    self.Extent = _G.UE.FVector(100.0, 100.0, 100.0)
    self.Radius = 0.0
    self.Height = 0.0
    self.bIsTriggering = false
    self.ShapeType = EDynDataTriggerShapeType.TriggerShapeType_Box
    self.bTriggeredOnCreate = false
    self.bEnableComponentOverlapEvent = true -- 是否需要细分角色身上的碰撞
end

function DynDataTriggerBase:Destroy()
    self.Super:Destroy()
    self.State = 0 --被销毁后不上报离开区域，否则会触发执行OnTriggerEndOverlap
    if (self.TriggerActor ~= nil) then
        _G.CommonUtil.DestroyActor(self.TriggerActor)
        self.TriggerActor = nil
    end
end

function DynDataTriggerBase:CreateTrigger(ShapeType)
    self.ShapeType = ShapeType

    local NewLocation = self.Location - self:GetWorldOriginLocation()

    if (self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Box) then
        local function SpawnTriggerBoxCallback(_, NewActor)
            self.TriggerActor = NewActor
            if (self.TriggerActor == nil) then
                return
            end
            local CollisionComponent = self.TriggerActor:GetComponentByClass(_G.UE.UBoxComponent)
            if (CollisionComponent == nil) then
                return
            end
            CollisionComponent:SetCollisionProfileName("OnlyTriggerPawn")
            local BoxComponent = CollisionComponent:Cast(_G.UE.UBoxComponent)
            if (BoxComponent == nil) then
                return
            end
            self:InitTrigger()
            --这里会触发Overlap事件,所以要放在InitTrigger后面
            self.bTriggeredOnCreate = true
            BoxComponent:SetBoxExtent(self.Extent)
            self.bTriggeredOnCreate = false
        end
        _G.CommonUtil.SpawnActorAsync(_G.UE.ATriggerBox.StaticClass(), NewLocation, self.Rotator, SpawnTriggerBoxCallback)
        
    elseif (self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Cylinder) then
        local function SpawnTriggerCapsuleCallback(_, NewActor)
            self.TriggerActor = NewActor
            if (self.TriggerActor == nil) then
                return
            end
            local CollisionComponent = self.TriggerActor:GetComponentByClass(_G.UE.UCapsuleComponent)
            if (CollisionComponent == nil) then
                return
            end
            CollisionComponent:SetCollisionProfileName("OnlyTriggerPawn")
            local CapsuleComponent = CollisionComponent:Cast(_G.UE.UCapsuleComponent)
            if (CapsuleComponent == nil) then
                return
            end
            --physix不支持圆状，这里用胶囊体代替，注意创建胶囊体的时候：CapsuleHalfHeight = FMath::Max3(0.f, NewHalfHeight, NewRadius);
            self:InitTrigger()
            --这里会触发Overlap事件,所以要放在InitTrigger后面
            self.bTriggeredOnCreate = true
            CapsuleComponent:SetCapsuleSize(self.Radius, self.Height / 2)
            self.bTriggeredOnCreate = false
        end
        _G.CommonUtil.SpawnActorAsync(_G.UE.ATriggerCapsule.StaticClass(), NewLocation, nil, SpawnTriggerCapsuleCallback)
    end
end

function DynDataTriggerBase:IsExternalComponent(Actor, Component)
    if Actor == nil or Component == nil then
        return false
    end
    local RootComponent = Actor:K2_GetRootComponent()
    if RootComponent == nil then
        return false
    end
    local PrimitiveComp = RootComponent:Cast(_G.UE.UPrimitiveComponent)
    if PrimitiveComp == nil then
        return false
    end
    return PrimitiveComp ~= Component
end

function DynDataTriggerBase:BindActorOverlapEvent()
    local function OnActorBeginOverlap(_, Trigger, Target)
        self:OnTriggerBeginOverlap(Trigger, Target)
    end
    self.TriggerActor.OnActorBeginOverlap:Add(self.TriggerActor, OnActorBeginOverlap)

    local function OnActorEndOverlap(_, Trigger, Target)
        self:OnTriggerEndOverlap(Trigger, Target)
    end
    self.TriggerActor.OnActorEndOverlap:Add(self.TriggerActor, OnActorEndOverlap)
end

---主角身上有两个胶囊体, 某些坐骑可能会导致两个胶囊体距离相差较大
---通过绑定Component的Overlap事件区分主胶囊体和额外的胶囊体
function DynDataTriggerBase:BindComponentOverlapEvent()
    local RootComponent = self.TriggerActor:K2_GetRootComponent()
    if RootComponent == nil then
        return false
    end
    local PrimitiveComp = RootComponent:Cast(_G.UE.UPrimitiveComponent)
    if PrimitiveComp == nil then
        return false
    end
    local function OnCompBeginOverlap(Trigger, TriggerComp, OtherActor, OtherComp)
        if self:IsExternalComponent(OtherActor, OtherComp) then
            return
        end
        self:OnTriggerBeginOverlap(Trigger, OtherActor)
    end
    PrimitiveComp.OnComponentBeginOverlap:Add(self.TriggerActor, OnCompBeginOverlap)
    local function OnCompEndOverlap(Trigger, TriggerComp, OtherActor, OtherComp)
        if self:IsExternalComponent(OtherActor, OtherComp) then
            return
        end
        self:OnTriggerEndOverlap(Trigger, OtherActor)
    end
    PrimitiveComp.OnComponentEndOverlap:Add(self.TriggerActor, OnCompEndOverlap)
    return true
end

function DynDataTriggerBase:InitTrigger()
    if (self.TriggerActor == nil) then
        return
    end

    if (_G.CommonUtil.IsWithEditor()) then
        local TriggerName = string.format("DynTrigger-%d", self.ID)
        self.TriggerActor:SetActorLabel(TriggerName)
        self.TriggerActor:SetFolderPath("DynamicTriggers")
    end
    if self.bEnableComponentOverlapEvent and self:BindComponentOverlapEvent() then
        return
    end
    self:BindActorOverlapEvent()
end

function DynDataTriggerBase:CreateBoxTrigger(Box)
    self.Extent = _G.UE.FVector(Box.Extent.X, Box.Extent.Y, Box.Extent.Z)
    self.Location = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
    self.Rotator = _G.UE.FRotator(Box.Rotator.Y, Box.Rotator.Z, Box.Rotator.X)
    self:CreateTrigger(EDynDataTriggerShapeType.TriggerShapeType_Box)
end

function DynDataTriggerBase:CreateCylinderTrigger(Cylinder)
    self.Location = _G.UE.FVector(Cylinder.Start.X, Cylinder.Start.Y, Cylinder.Start.Z)
    self.Radius = Cylinder.Radius
    self.Height = Cylinder.Height
    self:CreateTrigger(EDynDataTriggerShapeType.TriggerShapeType_Cylinder)
end

function DynDataTriggerBase:IsForbidUse()
    return self.State == 0
end

function DynDataTriggerBase:IsNeedTrigger(Trigger, Target, IsExit)
    if (_G.StoryMgr:SequenceIsPlaying()) then
        return false
    end

    if (self.bIsTriggering or self:IsForbidUse() or Target == nil) then
        return false
    end

    -- 如果Major第一次创建, 此时ActorType可能还没有初始化出来, 直接通过Cast判断是否为Major
    local Character = Target:Cast(AMajorCharacter)
    if (Character == nil) then
        return false
    end

    --创建胶囊体的时候，默认会使用半径和高度大的一方来设置高度，跟策划配置的高度不一致
    if not IsExit and self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Cylinder then
        local TriggerZ = Trigger:K2_GetActorLocation().Z
        local TargetZ =  Target:FGetLocation(_G.UE.EXLocationType.ServerLoc).Z
        if (math.abs(TargetZ - TriggerZ) > self.Height) then
            ActorUtil.RemoveComponentOverlap(Trigger, Target)
            local bRideFlying = Character:IsRideFlying()
            return bRideFlying
        end
    end

    return true
end

function DynDataTriggerBase:OnTriggerBeginOverlap(Trigger, Target)

end

function DynDataTriggerBase:OnTriggerEndOverlap(Trigger, Target)

end

return DynDataTriggerBase