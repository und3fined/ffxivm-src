--
-- Author: haialexzhou
-- Date: 2020-10-16
-- Description:地图区域进出
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require ("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require ("Protocol/ProtoRes")
local AsyncViewHelper = require("UI/AsyncViewHelper")

local ActorManager = _G.UE.UActorManager

local CS_CMD = ProtoCS.CS_CMD
local CS_MAP_AREA_CMD = ProtoCS.CS_MAP_AREA_CMD

local function Rotate(Point, Center, Angle)
    local AngleRad = math.rad(Angle)
    local CosTheta = math.cos(AngleRad)
    local SinTheta = math.sin(AngleRad)

    local TranslatedX = Point.X - Center.X
    local TranslatedY = Point.Y - Center.Y

    local RotatedX = TranslatedX * CosTheta - TranslatedY * SinTheta
    local RotatedY = TranslatedX * SinTheta + TranslatedY * CosTheta

    local RotatePoint = _G.UE.FVector(RotatedX + Center.X, RotatedY + Center.Y, Point.Z)

    return RotatePoint
end

---@class MapAreaMgr : MgrBase
local MapAreaMgr = LuaClass(MgrBase)

function MapAreaMgr:OnInit()
    self.OldAreaID = 0
    self.OldAreaPriority = 0
    self.CurrAreaID = 0
    self.CurrAreaPriority = 0

    self.CurrBlock = 0
    self.CurrSpot = 0
    ---@type table<DynDataMapArea>
    self.DynDataMapAreaList = {}
    ---@type table<DynDataMapArea>
    self.OverlapMapAreaList = {}
end

function MapAreaMgr:Reset()
    self.OldAreaID = 0
    self.OldAreaPriority = 0
    self.CurrAreaID = 0
    self.CurrAreaPriority = 0
end

function MapAreaMgr:OnRegisterNetMsg()
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_MAP_AREA, CS_MAP_AREA_CMD.CS_MAP_AREA_CMD_ENTER, self.OnEnterMapAreaRespEnter)
end

function MapAreaMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
    self:RegisterGameEvent(EventID.PWorldBegin, self.OnGameEventCheckUIMap)
    self:RegisterGameEvent(EventID.PWorldMapMovieSequenceEnd, self.OnGameEventCheckUIMap)
end

--进入区域
function MapAreaMgr:SendEnterArea(NewAreaID, Priority)
    if NewAreaID == nil then
        return
    end

    local Area = self.DynDataMapAreaList[NewAreaID]
    if Area then
        self.OverlapMapAreaList[NewAreaID] = Area
    end

    if NewAreaID == self.CurrAreaID then
        return
    end

    if (Priority == nil) then
        Priority = 0
    end

    --这里比较依赖于配置，没有重叠的区域优先级需要一致
    if (Priority < self.CurrAreaPriority) then
        return
    end

    --print("SendEnterArea NewAreaID=" .. NewAreaID .. ", Priority=" .. Priority)

    local MsgID = CS_CMD.CS_CMD_MAP_AREA

    local MapAreaReq = {}
    MapAreaReq.OldAreaID = self.CurrAreaID
    MapAreaReq.NewAreaID = NewAreaID
    local Position = {}
    local Major = ActorManager:Get():GetMajor()
    if (Major ~= nil) then
        local WorldOriginPos = _G.PWorldMgr:GetWorldOriginLocation()
        local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc) + WorldOriginPos
        Position.X = math.floor(MajorPos.X)
        Position.Y = math.floor(MajorPos.Y)
        Position.Z = math.floor(MajorPos.Z)
    end
    MapAreaReq.Pos = Position

    local MsgBody = {}
    local SubMsgID = CS_MAP_AREA_CMD.CS_MAP_AREA_CMD_ENTER
    MsgBody.Cmd = SubMsgID
    MsgBody.Enter  = MapAreaReq
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

    --这里也赋值，后台不回包
    self.OldAreaID = self.CurrAreaID
    self.OldAreaPriority = self.CurrAreaPriority
    self.CurrAreaID = NewAreaID
    self.CurrAreaPriority = Priority
end

---退出区域
function MapAreaMgr:SendExitArea(AreaID)
    self.OverlapMapAreaList[AreaID] = nil

    --处理区域上面叠加小区域的情况, 出了小区域后恢复到大区域
    if (self.CurrAreaPriority ~= self.OldAreaPriority) then
        self.CurrAreaID = self.OldAreaID
        self.CurrAreaPriority = self.OldAreaPriority
        self.OldAreaID = 0
        self.OldAreaPriority = 0
    end

    if (self.CurrAreaID == 0) then
        self.CurrAreaPriority = 0
    end

    --print("SendExitArea NewAreaID=" .. self.CurrAreaID .. ", Priority=" .. self.CurrAreaPriority)
end

-- function MapAreaMgr:OnEnterMapAreaRespEnter(MsgBody)
--     if (MsgBody.Cmd == CS_MAP_AREA_CMD.CS_MAP_AREA_CMD_ENTER) then
--         local EnterMapAreaRsp = MsgBody.Enter
--         self.CurrAreaID = EnterMapAreaRsp.NewAreaID
--         print("OnEnterMapAreaRespEnter NewAreaID=" .. self.CurrAreaID)
--     end
-- end

---@type 添加动态地图区域
---@param DynDataMapArea DynDataMapArea
function MapAreaMgr:Add(ID, DynDataMapArea)
    if DynDataMapArea then
        self.DynDataMapAreaList[ID] = DynDataMapArea
    end
end

---@type 获取DynDataMapArea
---@return DynDataMapArea
function MapAreaMgr:GetMapArea(ID)
    return self.DynDataMapAreaList[ID]
end

---@type 获取MapID
---@return number (返回0表示无效)
function MapAreaMgr:GetMapID()
    local MapID = 0
    local Major = MajorUtil.GetMajor()
    if Major then
        if self.DynDataMapAreaList then
            local Priority = 0
            local ID = 0
            for _, Data in pairs(self.DynDataMapAreaList) do
                if Data.FuncData.MapID > 0 then
                    if Data.Priority > Priority or (Data.Priority == Priority and Data.ID < ID) then
                        if Data.TriggerActor and CommonUtil.IsObjectValid(Data.TriggerActor) then
                            if Data.TriggerActor:IsOverlappingActor(Major) then
                                Priority = Data.Priority
                                MapID = Data.FuncData.MapID
                                ID = Data.ID
                            end
                        end
                    end
                end
            end
        end
    end
    return MapID
end

---@type 获取DiscoveryID
---@return number (返回0表示无效)
function MapAreaMgr:GetDiscoveryID()
    local DiscoveryID = 0
    local Priority = 0
    local ID = 0
    local Major = MajorUtil.GetMajor()
    if Major then
        if self.DynDataMapAreaList then
            for _, Data in pairs(self.DynDataMapAreaList) do
                if Data.FuncData.IsDiscoveryEnabled then
                    if Data.Priority > Priority or (Data.Priority == Priority and Data.ID < ID) then
                        if Data.TriggerActor and CommonUtil.IsObjectValid(Data.TriggerActor) then
                            if Data.TriggerActor:IsOverlappingActor(Major) then
                                Priority = Data.Priority
                                DiscoveryID = Data.FuncData.DiscoveryId
                                ID = Data.ID
                            end
                        end
                    end
                end
            end
        end
    end
    return DiscoveryID, ID
end

---@type 获取DiscoveryID
---@return number (返回0表示无效)
function MapAreaMgr:GetDiscoveryIDByActor(Actor)
    local DiscoveryID = 0
    local Priority = 0
    local ID = 0
    if Actor then
        if self.DynDataMapAreaList then
            for _, Data in pairs(self.DynDataMapAreaList) do
                if Data.FuncData.IsDiscoveryEnabled then
                    if Data.Priority > Priority or (Data.Priority == Priority and Data.ID < ID) then
                        if Data.TriggerActor and CommonUtil.IsObjectValid(Data.TriggerActor) then
                            if Data.TriggerActor:IsOverlappingActor(Actor) then
                                Priority = Data.Priority
                                DiscoveryID = Data.FuncData.DiscoveryId
                                ID = Data.ID
                            end
                        end
                    end
                end
            end
        end
    end
    return DiscoveryID, ID
end

---@type 获取DiscoveryID
---@param X number@X坐标
---@param Y number@Y坐标
---@param Z number@Z坐标
---@param MapID number@地图ID(为nil则取当前地图)
---@return number, number@迷雾id(返回0表示无效),MapRange id
function MapAreaMgr:GetDiscoveryIDByLocation(X, Y, Z, MapID)
    local DiscoveryID = 0
    local ID = 0
    local Location = _G.UE.FVector(X, Y, Z)

    local MapEditData = nil
    if not MapID or MapID == _G.PWorldMgr:GetCurrMapResID() then
        MapEditData = _G.MapEditDataMgr:GetMapEditCfg()
    else
        MapEditData = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    end
    if not MapEditData then
        return 0, 0
    end

    for _, Area in ipairs(MapEditData.AreaList) do
        if Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP then
            if Area.Map.IsDiscoveryEnabled  then
                if Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX then
                    local Box = Area.Box
                    local Extent = _G.UE.FVector(Box.Extent.X, Box.Extent.Y, Box.Extent.Z)
                    local Center = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
                    local Min = Center - Extent
                    local Max = Center + Extent
                    if Box.Rotator.Z == 0 then
                        if Location.X > Min.X and Location.X < Max.X and Location.Y > Min.Y and Location.Y < Max.Y and Location.Z > Min.Z and Location.Z < Max.Z then
                            DiscoveryID = Area.Map.DiscoveryId
                            ID = Area.ID 
                            break
                        end
                    else
                        --用目标位置反方向旋转
                        local RotatedPoint = Rotate(Location, Center, Box.Rotator.Z * -1)
                        if RotatedPoint.X > Min.X and RotatedPoint.X < Max.X and RotatedPoint.Y > Min.Y and RotatedPoint.Y < Max.Y and RotatedPoint.Z > Min.Z and RotatedPoint.Z < Max.Z then
                            DiscoveryID = Area.Map.DiscoveryId
                            ID = Area.ID
                            break
                        end
                    end
                elseif Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER then
                    local Cylinder = Area.Cylinder
                    local Radius = Cylinder.Radius
                    local Height = Cylinder.Height
                    local Center = _G.UE.FVector(Cylinder.Start.X, Cylinder.Start.Y, Cylinder.Start.Z - Height)
                    local PointOnCylinder = _G.UE.FVector(Location.X, Location.Y, Center.Z)
                    local DistanceToCenter = _G.UE.FVector.Dist(PointOnCylinder, Center)
                    if DistanceToCenter <= Radius and Location.Z >= Center.Z and Location.Z <= Center.Z + Height then
                        DiscoveryID = Area.Map.DiscoveryId
                        ID = Area.ID
                        break
                    end
                end
            end
        end
    end
    return DiscoveryID, ID
end

---@type 判断坐标是否在电梯内，返回获取电梯顶部高度
---@param X number@X坐标
---@param Y number@Y坐标
---@param Z number@Z坐标
---@param MapID number@地图ID(为nil则取当前地图)
---@return bool, number, number@是否在电梯内，电梯顶部的Z坐标，电梯高度
function MapAreaMgr:GetElevatorTopByPos(X, Y, Z, MapID)
    local InElevator = false
    local ElevatorTopZ = 0
    local ElevatorHeight = 0
    local Location = _G.UE.FVector(X, Y, Z)

    local MapEditData = nil
    if not MapID or MapID == _G.PWorldMgr:GetCurrMapResID() then
        MapEditData = _G.MapEditDataMgr:GetMapEditCfg()
    else
        MapEditData = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    end
    if not MapEditData then
        return false, 0, 0
    end

    for _, Area in ipairs(MapEditData.AreaList) do
        if Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP then
            if Area.Map.IsLiftEnabled  then
                if Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX then
                    local Box = Area.Box
                    local Extent = _G.UE.FVector(Box.Extent.X, Box.Extent.Y, Box.Extent.Z)
                    local Center = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
                    local Min = Center - Extent
                    local Max = Center + Extent
                    if Box.Rotator.Z == 0 then
                        if Location.X > Min.X and Location.X < Max.X and Location.Y > Min.Y and Location.Y < Max.Y and Location.Z > Min.Z and Location.Z < Max.Z then
                            InElevator = true
                            ElevatorTopZ = Max.Z
                            ElevatorHeight = Extent.Z * 2
                            break
                        end
                    else
                        --用目标位置反方向旋转
                        local RotatedPoint = Rotate(Location, Center, Box.Rotator.Z * -1)
                        if RotatedPoint.X > Min.X and RotatedPoint.X < Max.X and RotatedPoint.Y > Min.Y and RotatedPoint.Y < Max.Y and RotatedPoint.Z > Min.Z and RotatedPoint.Z < Max.Z then
                            InElevator = true
                            ElevatorTopZ = Max.Z
                            ElevatorHeight = Extent.Z * 2
                            break
                        end
                    end
                end
            end
        end
    end
    return InElevator, ElevatorTopZ, ElevatorHeight
end

---@type 获取uimapid
---@param Pos table@X,Y,Z坐标
---@param MapID number@地图ID(为nil则取当前地图)
---@return number@uimapid(返回0表示无效),MapRange id
function MapAreaMgr:GetUIMapIDByLocation(Pos, MapID)
    local Priority = 0
    local ID = 0
    local UIMapID = 0
    local Location = _G.UE.FVector(Pos.X, Pos.Y, Pos.Z)

    local MapEditData = nil
    if not MapID or MapID == _G.PWorldMgr:GetCurrMapResID() then
        MapEditData = _G.MapEditDataMgr:GetMapEditCfg()
    else
        MapEditData = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    end
    if not MapEditData then
        return 0
    end

    for _, Area in ipairs(MapEditData.AreaList) do
        if Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP then
            if Area.Map.IsMapEnabled  then
                if  Area.Priority > Priority or (Area.Priority == Priority and Area.ID < ID) then
                    if Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX then
                        local Box = Area.Box
                        local Extent = _G.UE.FVector(Box.Extent.X, Box.Extent.Y, Box.Extent.Z)
                        local Center = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
                        local Min = Center - Extent
                        local Max = Center + Extent
                        if Box.Rotator.Z == 0 then
                            if Location.X > Min.X and Location.X < Max.X and Location.Y > Min.Y and Location.Y < Max.Y and Location.Z > Min.Z and Location.Z < Max.Z then
                                Priority = Area.Priority
                                ID = Area.ID
                                UIMapID = Area.Map.MapID
                            end
                        else
                            --用目标位置反方向旋转
                            local RotatedPoint = Rotate(Location, Center, Box.Rotator.Z * -1)
                            if RotatedPoint.X > Min.X and RotatedPoint.X < Max.X and RotatedPoint.Y > Min.Y and RotatedPoint.Y < Max.Y and RotatedPoint.Z > Min.Z and RotatedPoint.Z < Max.Z then
                                Priority = Area.Priority
                                ID = Area.ID
                                UIMapID = Area.Map.MapID
                            end
                        end
                    elseif Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER then
                        local Cylinder = Area.Cylinder
                        local Radius = Cylinder.Radius
                        local Height = Cylinder.Height
                        local Center = _G.UE.FVector(Cylinder.Start.X, Cylinder.Start.Y, Cylinder.Start.Z - Height)
                        local PointOnCylinder = _G.UE.FVector(Location.X, Location.Y, Center.Z)
                        local DistanceToCenter = _G.UE.FVector.Dist(PointOnCylinder, Center)
                        if DistanceToCenter <= Radius and Location.Z >= Center.Z and Location.Z <= Center.Z + Height then
                            Priority = Area.Priority
                            ID = Area.ID
                            UIMapID = Area.Map.MapID
                        end
                    end
                end
            end
        end
    end
    if UIMapID == 0 then
        UIMapID = MapUtil.GetUIMapID(MapID) or 0
    end
    return UIMapID
end

---@type 设置地名
---@param Block number@街道id
---@param Spot number@地点ID
---@param IsLateShow boolean@是否延迟显示
function MapAreaMgr:SetPlaceName(Block, Spot , IsLateShow)
    if self.CurrBlock ~= Block or self.CurrSpot ~= Spot then
        -- 2.0之前的地图,地名提示和解锁迷雾提示会互斥,这里简单排斥
        if UIViewMgr:FindView(UIViewID.InfoMistTips) then
            return
        end
        
        local SysView = UIViewMgr:FindView(UIViewID.ActiveSystemErrorTips)
        if SysView then --正在加载
            if SysView:ExistSysTipDisplayedOrQueueing() then
                return
            end
        end
        if Spot > 0 then
            if self.TimerShowAreaTipsID then
                self:UnRegisterTimer(self.TimerShowAreaTipsID)
            end
            if IsLateShow then
                self.TimerShowAreaTipsID = self:RegisterTimer(self.OnLateShowAreaTips, 3, 0, 1, MapUtil.GetPlaceName(Spot))
            else
                MsgTipsUtil.ShowAreaTips(MapUtil.GetPlaceName(Spot), 5)
            end
        else
            if Block > 0 then
                if self.TimerShowAreaTipsID then
                    self:UnRegisterTimer(self.TimerShowAreaTipsID)
                end
                if IsLateShow then
                    self.TimerShowAreaTipsID = self:RegisterTimer(self.OnLateShowAreaTips, 3, 0, 1, MapUtil.GetPlaceName(Block))
                else
                    MsgTipsUtil.ShowAreaTips(MapUtil.GetPlaceName(Block), 5)
                end
            end
        end
        self.CurrBlock = Block
        self.CurrSpot = Spot
    end
end

function MapAreaMgr:InMapArea(AreaID)
    if self.OverlapMapAreaList then
        return self.OverlapMapAreaList[AreaID] ~= nil
    end
    return false
end

function MapAreaMgr:OnLateShowAreaTips(PlaceName)
    self.TimerShowAreaTipsID = nil
    if UIViewMgr:FindView(UIViewID.InfoMistTips) then
        return
    end
    MsgTipsUtil.ShowAreaTips(PlaceName, 5)
end

function MapAreaMgr:OnWorldPreLoad(CurrMapResID, CurrPWorldResID)
    self.CurrAreaID = 0
    self.CurrBlock = 0
    self.CurrSpot = 0
    self.DynDataMapAreaList = {}
    self.OverlapMapAreaList = {}
end

function MapAreaMgr:OnGameEventCheckUIMap()
    local Major = MajorUtil.GetMajor()
    if Major then
        local Location = Major:FGetActorLocation()
        local UIMapID = self:GetUIMapIDByLocation(Location)
        if UIMapID and UIMapID  > 0 then
            _G.EventMgr:SendEvent(EventID.MapRangeChanged, {MapID = UIMapID})
        end
    end
end

return MapAreaMgr