--
-- Author: sammrli
-- Date: 2023-9-5
-- Description:地图区域
--

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require ("Protocol/ProtoRes")
local LuaClass = require("Core/LuaClass")

local DynDataArea = require("Game/PWorld/DynData/DynDataArea")
local DynDataCommon = require("Game/PWorld/DynData/DynDataCommon")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local EDynDataTriggerShapeType = DynDataCommon.EDynDataTriggerShapeType

---@class DynDataMapArea
local DynDataMapArea = LuaClass(DynDataArea, true)

function DynDataMapArea:Ctor()
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA
    self.AreaFuncType = ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP
end

-- 是否需要将区域变化上报给服务器
function DynDataMapArea:ShouldNotifyServer()
    local FuncData = self.FuncData or {}
    if FuncData.IsBGMEnable then
        return false
    end
    return true
end

-- 覆盖父类CreateTrigger方法,区别初始化创建触发的碰撞事件
function DynDataMapArea:CreateTrigger(ShapeType)
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
            -- 忽略点选胶囊体
            local Major = MajorUtil.GetMajor()
            if Major then
                if Major.FacadeCapsule then
                    Major.FacadeCapsule:IgnoreComponentWhenMoving(CollisionComponent, true)
                end
            end
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
            self:InitTrigger()
            -- 忽略点选胶囊体
            local Major = MajorUtil.GetMajor()
            if Major then
                if Major.FacadeCapsule then
                    Major.FacadeCapsule:IgnoreComponentWhenMoving(CollisionComponent, true)
                end
            end
            self.bTriggeredOnCreate = true
            CapsuleComponent:SetCapsuleSize(self.Radius, self.Height)
            self.bTriggeredOnCreate = false
        end
        _G.CommonUtil.SpawnActorAsync(_G.UE.ATriggerCapsule.StaticClass(), NewLocation, nil, SpawnTriggerCapsuleCallback)
    end
end


function DynDataMapArea:CreateCylinderTrigger(Cylinder)
    self.Location = _G.UE.FVector(Cylinder.Start.X, Cylinder.Start.Y, Cylinder.Start.Z)
    self.Radius = Cylinder.Radius
    self.Height = Cylinder.Radius * 2 + Cylinder.Height --还原端游圆柱体
    self:CreateTrigger(EDynDataTriggerShapeType.TriggerShapeType_Cylinder)
end

function DynDataMapArea:OnTriggerBeginOverlap(Trigger, Target)
    if not self:IsNeedTrigger(Trigger, Target) then
        return
    end

    if _G.StoryMgr.SequencePlayer then --双重保险
        return
    end

    if self:ShouldNotifyServer() then
        _G.MapAreaMgr:SendEnterArea(self.ID, self.Priority)
    end

    local MapOverlay, PlacenameOverlay = self:GetOverlayData()

    -- 通知更改地图UI
    if MapOverlay.ID > 0 then
        _G.EventMgr:SendEvent(_G.EventID.MapRangeChanged, {MapID = MapOverlay.MapUIID})
    end

    -- 通知解锁迷雾
    if self.FuncData and self.FuncData.IsDiscoveryEnabled and self.FuncData.DiscoveryId then
        if self.FuncData.DiscoveryId > 0 then
            local MapResID = _G.PWorldMgr:GetCurrMapResID()
            if _G.FogMgr:IsFlagInit(MapResID) then
                if not _G.FogMgr:IsAllActivate(MapResID) then
                    if not _G.FogMgr:IsInFlag(MapResID, self.FuncData.DiscoveryId) then
                        _G.FogMgr:SendActivateArea(self.ID)
                    end
                end
            end
        end
    end

    -- 地名显示
    if PlacenameOverlay.ID > 0 then
        local OverlayArea = _G.MapAreaMgr:GetMapArea(PlacenameOverlay.ID)
        if OverlayArea and OverlayArea.FuncData then
            _G.MapAreaMgr:SetPlaceName(OverlayArea.FuncData.PlaceNameBlockID, OverlayArea.FuncData.PlaceNameSpotID, self.bTriggeredOnCreate)
        end
    else
        _G.MapAreaMgr:SetPlaceName(0, 0)
    end

    -- BGM相关
    local FuncData = self.FuncData or {}
    if FuncData.IsBGMEnable and FuncData.BGM then
        _G.UE.UBGMAreaMgr:Get():EnterArea(self.Priority, self.ID, FuncData.BGM, FuncData.IsBGMPlayZoneInOnly)
    end
end

function DynDataMapArea:OnTriggerEndOverlap(Trigger, Target)
    if not self:IsNeedTrigger(Trigger, Target, true) then
        return
    end

    if _G.StoryMgr.SequencePlayer then --双重保险
        return
    end

    if self:ShouldNotifyServer() then
        _G.MapAreaMgr:SendExitArea(self.ID)
    end

    local MapOverlay, PlacenameOverlay = self:GetOverlayData()
    -- 地名显示
    if PlacenameOverlay.ID > 0 then
        local OverlayArea = _G.MapAreaMgr:GetMapArea(PlacenameOverlay.ID)
        if OverlayArea and OverlayArea.FuncData then
            _G.MapAreaMgr:SetPlaceName(OverlayArea.FuncData.PlaceNameBlockID, OverlayArea.FuncData.PlaceNameSpotID)
        end
    else
        _G.MapAreaMgr:SetPlaceName(0, 0)
    end

    -- 通知更改地图UI
    if MapOverlay.ID > 0 then
        _G.EventMgr:SendEvent(_G.EventID.MapRangeChanged, {MapID = MapOverlay.MapUIID})
    end

    -- BGM相关
    local FuncData = self.FuncData or {}
    if FuncData.IsBGMEnable and FuncData.BGM then
        _G.UE.UBGMAreaMgr:Get():ExitArea(self.ID)
    end
end

function DynDataMapArea:IsForbidUse()
    return self.FuncData == nil
end

function DynDataMapArea:IsNeedTrigger(Trigger, Target, IsExit)
    if (_G.StoryMgr:SequenceIsPlaying()) then
        return false
    end

    if (self.bIsTriggering or self:IsForbidUse() or Target == nil) then
        return false
    end

    -- 如果Major第一次创建, 此时ActorType可能还没有初始化出来, 直接通过Cast判断是否为Major
    local Character = Target:Cast(_G.UE.AMajorCharacter)
    if (Character == nil) then
        return false
    end

    --创建胶囊体的时候，默认会使用半径和高度大的一方来设置高度，跟策划配置的高度不一致
    if not IsExit and self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Cylinder then
        local TriggerZ = Trigger:K2_GetActorLocation().Z
        local TargetZ =  Target:FGetLocation(_G.UE.EXLocationType.ServerLoc).Z
        if (math.abs(TargetZ - TriggerZ) > (self.Height - self.Radius * 2)) then --高度只取圆柱体部分
            ActorUtil.RemoveComponentOverlap(Trigger, Target)
            return false
        end
    end

    return true
end

---@type 获取重叠数据
---@return MapOverlay, PlacenameOverlay
function DynDataMapArea:GetOverlayData()
    ---@class MapOverlay
    ---@field Priority number
    ---@field ID number
    ---@field MapUIID numnber
    local MapOverlay = {Priority = 0, ID = 0, MapUIID = 0}
    ---@class PlacenameOverlay
    ---@field Priority number
    ---@field ID number
    local PlacenameOverlay = {Priority = 0, ID = 0}
    for _,Area in pairs(_G.MapAreaMgr.OverlapMapAreaList) do
        if Area and Area.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP then
            if Area.FuncData.IsMapEnabled then
                if Area.Priority > MapOverlay.Priority or (Area.Priority == MapOverlay.Priority and Area.ID < MapOverlay.ID) then
                    MapOverlay.Priority = Area.Priority
                    MapOverlay.ID = Area.ID
                    MapOverlay.MapUIID = Area.FuncData.MapID
                end
            end
            if Area.FuncData.IsPlaceNameEnabled then
                if Area.Priority > PlacenameOverlay.Priority then
                    PlacenameOverlay.Priority = Area.Priority
                    PlacenameOverlay.ID = Area.ID
                end
            end
        end
    end
    return MapOverlay, PlacenameOverlay
end

return DynDataMapArea
