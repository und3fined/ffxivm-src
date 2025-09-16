--
-- Author: haialexzhou
-- Date: 2021-9-16
-- Description:地图副本动态数据管理
--

local LuaClass = require("Core/LuaClass")
local ProtoCommon = require("Protocol/ProtoCommon")
local MapElevator = require("Game/PWorld/InteractObj/MapElevator")

local MapElevatorCache = LuaClass()
function MapElevatorCache:Ctor()
    self.ID = 0
    self.StartTime = nil
    self.StartPointIndex = nil
    self.EndPointIndex = nil
    self.Status = ProtoCommon.ELEVATOR_STATUS.ELEVATOR_STATUS_STOP
end

---@class PWorldElevatorMgr
local PWorldElevatorMgr = {}

function PWorldElevatorMgr:Init()
    self.MapCachedElevators = {}
    self.MapElevators = {}

    self:LoadElevator()
end

function PWorldElevatorMgr:Reset()
    if (self.MapElevators ~= nil) then
        for _, ElevatorObj in ipairs(self.MapElevators) do
            ElevatorObj:Destroy()
        end
    end

    self.MapElevators = {}
    self.MapCachedElevators = {}
end

function PWorldElevatorMgr:LoadElevator()
    local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if (CurrMapEditCfg == nil) then
        return
    end

    local ElevatorList = CurrMapEditCfg.ElevatorList
    local ElevatorCnt = #ElevatorList
    if (ElevatorCnt == 0) then
        return
    end

    local AllDynamicAssets = _G.UE.TArray(_G.UE.AMapDynamicAssetBase)
    _G.UE.UGameplayStatics.GetAllActorsOfClass(FWORLD(), _G.UE.AMapDynamicAssetBase.StaticClass(), AllDynamicAssets)
    local DynamicAssetCnt = AllDynamicAssets:Length()
    local EDynamicAssetType = _G.UE.EMapDynamicAssetType
    for i = 1, DynamicAssetCnt, 1 do
        local DynamicAsset = AllDynamicAssets:Get(i)
        if (EDynamicAssetType.MapDynamicAssetType_Elevator == DynamicAsset.DynamicAssetType) then
            for _, Elevator in ipairs(ElevatorList) do
                if (Elevator.ID == DynamicAsset.ID) then
                    local MapElevatorObj = self:CreateElevatorObj(Elevator, DynamicAsset)
                    table.insert(self.MapElevators, MapElevatorObj)
                    break
                end
            end
        end
    end

    if (#self.MapElevators > 0) then
        _G.PWorldMgr:SendGetMapElevatorData()
    end
end

function PWorldElevatorMgr:UpdateElevatorList(ElevatorObjList)
    for _, ElevatorObj in ipairs(ElevatorObjList.ObjList) do
        self:UpdateElevator(ElevatorObj)
    end
end

function PWorldElevatorMgr:UpdateElevator(MapElevatorData)
    local ElevatorObj = self:GetElevatorObject(MapElevatorData.ID)
    if (ElevatorObj ~= nil) then
        ElevatorObj:UpdateElevator(MapElevatorData.Status, MapElevatorData.StartPointIndex, MapElevatorData.EndPointIndex, MapElevatorData.StartTime)
    else
        if (MapElevatorData.ID > 0) then
            local CachedElevatorObject = self:GetCachedElevatorObject(MapElevatorData.ID)
            if (CachedElevatorObject == nil) then
                CachedElevatorObject = MapElevatorCache.New()
                CachedElevatorObject.ID = MapElevatorData.ID
                CachedElevatorObject.Status = MapElevatorData.Status
                CachedElevatorObject.StartPointIndex = MapElevatorData.StartPointIndex
                CachedElevatorObject.EndPointIndex = MapElevatorData.EndPointIndex
                CachedElevatorObject.StartTime = MapElevatorData.StartTime
                table.insert(self.MapCachedElevators, CachedElevatorObject)
            else
                CachedElevatorObject.Status = MapElevatorData.Status
                CachedElevatorObject.StartPointIndex = MapElevatorData.StartPointIndex
                CachedElevatorObject.EndPointIndex = MapElevatorData.EndPointIndex
                CachedElevatorObject.StartTime = MapElevatorData.StartTime
            end
        end
        print("Elevator asset was not loaded ", MapElevatorData.ID)
    end
end

function PWorldElevatorMgr:GetElevatorObject(ID)
    if (self.MapElevators == nil) then
        return nil
    end
    for _, ElevatorObject in ipairs(self.MapElevators) do
        if (ElevatorObject.ID == ID) then
            return ElevatorObject
        end
    end

    return nil
end

function PWorldElevatorMgr:GetCachedElevatorObject(ID)
    if (self.MapCachedElevators == nil) then
        return nil
    end
    for _, CachedElevatorObject in ipairs(self.MapCachedElevators) do
        if (CachedElevatorObject.ID == ID) then
            return CachedElevatorObject
        end
    end

    return nil
end

function PWorldElevatorMgr:RemoveCachedElevator(ID)
    if (self.MapCachedElevators == nil) then
        return
    end
    for i = #self.MapCachedElevators, 1, -1 do
        local CachedElevator = self.MapCachedElevators[i]
        if (CachedElevator.ID == ID) then
            table.remove(self.MapCachedElevators, i)
        end
    end
end


function PWorldElevatorMgr:OnDynamicAssetLoadInLand(DynamicAssetActor)
    if (DynamicAssetActor.ID <= 0) then
        print("OnDynamicAssetLoadInLand dynamic asset id is error", DynamicAssetActor.ID, DynamicAssetActor.DynamicAssetType)
        return
    end

    local EDynamicAssetType = _G.UE.EMapDynamicAssetType
    if (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Elevator) then
        self:OnElevatorLoadInLand(DynamicAssetActor)
    end
end


function PWorldElevatorMgr:CreateElevatorObj(ElevatorCfg, ElevatorModel)
    local MapElevatorObj = MapElevator.New()
    MapElevatorObj.ID = ElevatorCfg.ID
    MapElevatorObj:CreateElevatorController()
    if (MapElevatorObj.MapElevatorController ~= nil) then
        local PathPoints = _G.UE.TArray(_G.UE.FVector)
        for _, Point in ipairs(ElevatorCfg.PathPoints) do
            PathPoints:Add(_G.UE.FVector(Point.X, Point.Y, Point.Z))
        end
        MapElevatorObj.MapElevatorController:InitFromConfig(ElevatorModel, ElevatorCfg.Duration, ElevatorCfg.StartAcc, ElevatorCfg.StartAccDuration, ElevatorCfg.EndAcc, ElevatorCfg.EndAccDuration, PathPoints)
    end
    return MapElevatorObj
end

function PWorldElevatorMgr:OnElevatorLoadInLand(DynamicAssetActor)
    local ElevatorObj = self:GetElevatorObject(DynamicAssetActor.ID)
    if (ElevatorObj == nil) then
        local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
        if (CurrMapEditCfg == nil) then
            return
        end

        local ElevatorList = CurrMapEditCfg.ElevatorList
        local ElevatorCnt = #ElevatorList
        if (ElevatorCnt == 0) then
            return
        end
        for _, Elevator in ipairs(ElevatorList) do
            if (Elevator.ID == DynamicAssetActor.ID) then
                ElevatorObj = self:CreateElevatorObj(Elevator, DynamicAssetActor)
                table.insert(self.MapElevators, ElevatorObj)
                break
            end
        end
    end

    local CachedElevatorObj = self:GetCachedElevatorObject(DynamicAssetActor.ID)
    if (CachedElevatorObj ~= nil) then
        ElevatorObj = self:GetElevatorObject(DynamicAssetActor.ID)
        if (ElevatorObj ~= nil) then
            ElevatorObj:UpdateElevator(CachedElevatorObj.Status, CachedElevatorObj.StartPointIndex, CachedElevatorObj.EndPointIndex, CachedElevatorObj.StartTime)
        end
        self:RemoveCachedElevator(CachedElevatorObj.ID)
    end
end

function PWorldElevatorMgr:OnDynamicAssetUnLoadInLand(DynamicAssetActor)
    if (DynamicAssetActor.ID <= 0) then
        print("OnDynamicAssetLoadInLand dynamic asset id is error", DynamicAssetActor.ID, DynamicAssetActor.DynamicAssetType)
        return
    end
    local EDynamicAssetType = _G.UE.EMapDynamicAssetType
    if (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Elevator) then
        self:OnElevatorUnLoadInLand(DynamicAssetActor)
    end
end

function PWorldElevatorMgr:OnElevatorUnLoadInLand(DynamicAssetActor)
    self:RemoveCachedElevator(DynamicAssetActor.ID)
end

return PWorldElevatorMgr