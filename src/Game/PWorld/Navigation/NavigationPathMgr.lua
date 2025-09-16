--
-- Author: zerodeng
-- Date: 2024-5-14
-- Description:导航路径生成
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local TransGraphCfg = require("TableCfg/TransGraphCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local DynamicMapGroupCfg = require("TableCfg/DynamicMapGroupCfg")
local NavigationConfigCfg = require("TableCfg/NavigationConfigCfg")
local FestivalLayersetCfg = require("TableCfg/FestivalLayersetCfg")

local NavigationConfigType = ProtoRes.navigation_config_type

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local TransitionType = ProtoRes.transition_type

---@class NavigationPathMgr : MgrBase
---@field MapPathTreeList 场景路径链表
---@field MapBlockCfgList 地图块配置信息{MapID, OneBlockCfg}
---@field MapBlockTreeList 地图块路径链表
---@field FindPathSeqIDList
---@field MapPathsCache 路径缓存
local NavigationPathMgr = LuaClass(MgrBase)

--地图路径类型
NavigationPathMgr.EMapPathType = {
    MapInside = 0,
    MapLink = 1
}

--相等判断
local function PosEqual(Pos1, Pos2)
    return Pos1.X == Pos2.X and Pos1.Y == Pos2.Y and Pos1.Z == Pos2.Z
end

local function TwoMapsKey(SrcMapID, DstMapID)
    return string.format("%d_%d", SrcMapID, DstMapID)
end

local GCacheNPCNavigationPos = {}
local GCacheNPCOriginPos = {}
local GCacheGraphCfgNpcData = {}
local GNpcInteractionOffset = 0

function NavigationPathMgr.GetNpcOriginPos(NavigationPos)
    return GCacheNPCOriginPos[NavigationPos]
end

--获取NPC对应的导航目标点：NPC_Pos + NPC朝向*交互距离
---@param TargetMapID 目标地图ID
---@param NpcID NPC表对应ID
---@return Pos(X,Y,Z) | nil
function NavigationPathMgr.GetNavigationPosByNpcID(TargetMapID, NpcID)
    local KeyStr = string.format("%d_%d", TargetMapID, NpcID)
    local RetValue = GCacheNPCNavigationPos[KeyStr]
    if (RetValue ~= nil) then
        return RetValue[1]
    end

    local InteractionRange = NpcCfg:FindValue(NpcID, "InteractionRange")
    local NavigationDir = NpcCfg:FindValue(NpcID, "NavigationDir")
    if InteractionRange == nil or NavigationDir == nil then
        FLOG_ERROR("NavigationPathMgr:NpcCfg no InteractionRange or NavigationDir!")
        return nil
    end

    --FLOG_INFO("NavigationPathMgr NPCID=%d, NavigationDir=%d, TargetMapID=%d", NpcID, NavigationDir, TargetMapID)

    --获取NPC坐标以及朝向
    local NpcData = NavigationPathMgr.GetNPCDataFromGraphCfg(TargetMapID, NpcID)
    if (NpcData == nil) then
        --不在寻路表里，查找地图数据
        local MapEditData = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(TargetMapID)
        if (MapEditData == nil) then
            FLOG_ERROR("MapEditCfg fild can't load by Mapid=%d", TargetMapID)
            return nil
        end
    
        local NpcDataTemp = _G.MapEditDataMgr:GetNpc(NpcID, MapEditData)
        if NpcDataTemp == nil then
            --没有找到，可能在活动edit数据
            local LayerIDs = _G.OpsActivityMgr.CacheLayerIDs
            if (LayerIDs ~= nil and #LayerIDs > 0) then
                for _, LayerID in ipairs(LayerIDs) do
                    local FestivalLayersetCfgItem = FestivalLayersetCfg:FindCfgByKey(LayerID)
                    if FestivalLayersetCfgItem then
                        local PWorldMgrInstance = _G.UE.UPWorldMgr:Get()
                        PWorldMgrInstance:LoadFestivalMapEditCfg(FestivalLayersetCfgItem.HolidayEditFile)      

                        --再次获取
                        NpcDataTemp = _G.MapEditDataMgr:GetNpc(NpcID, MapEditData)
                        if (NpcDataTemp ~= nil) then
                            break
                        end
                    end
                end
            end

            if (NpcDataTemp == nil) then
                FLOG_ERROR("NavigationPathMgr: Map=(%d) no npc=(%d)", TargetMapID, NpcID)
                return nil
            end
        end

        NpcData = {Pos = NpcDataTemp.BirthPoint, Dir=NpcDataTemp.BirthDir}
    end
    
    local NPCPos = _G.UE.FVector(NpcData.Pos.X, NpcData.Pos.Y, NpcData.Pos.Z)
    local Dir = NpcData.Dir + NavigationDir

    --交互距离再减40保证触发NPC交互
    
    if (GNpcInteractionOffset == 0) then
        local cfg = NavigationConfigCfg:FindCfgByKey(NavigationConfigType.NPC_INTERACTION_DIST)
        if (cfg ~= nil) then
            GNpcInteractionOffset = cfg.Value      
        else
            GNpcInteractionOffset = 20  
        end
    end

    local RejustInteractionRange = InteractionRange - GNpcInteractionOffset
    local Director = _G.UE.FVector(RejustInteractionRange, 0, 0)
    Director = Director:RotateAngleAxis(Dir, _G.UE.FVector(0, 0, 1))
    local NavigationPos = NPCPos + Director

    FLOG_INFO("NavigationPathMgr: NPCID=%d, BirthPoint=%s, NavigationPos=%s", 
    NpcID, table.tostring(NpcData.Pos), table.tostring(NavigationPos))

    --缓存
    GCacheNPCNavigationPos[KeyStr] = {NavigationPos, NPCPos, RejustInteractionRange}
    GCacheNPCOriginPos[NavigationPos] = NPCPos

    return NavigationPos
end

function NavigationPathMgr.IsNPCPosition(Position)
    for _, Value in pairs(GCacheNPCNavigationPos) do
        if (PosEqual(Position, Value[1])) then
            return true, Value[2], Value[3]
        end
    end

    return false
end

--获取NPC坐标以及朝向
function NavigationPathMgr.GetNPCDataFromGraphCfg(SrcMapID, NpcID)
    if (SrcMapID == 0 or NpcID == 0) then
        FLOG_ERROR("NavigationPathMgr:SrcMapID or NpcID is 0")
        return nil
    end

    --缓存中获取
    local Key = string.format("%d_%d", SrcMapID, NpcID)
    local Data = GCacheGraphCfgNpcData[Key]
    if (Data ~= nil) then
        return Data
    end

    local FindAllCfg = TransGraphCfg:FindAllCfg(string.format("MapID = %d and ActorResID=%d", SrcMapID, NpcID))    

    if (FindAllCfg == nil or #FindAllCfg == 0) then
        FLOG_WARNING("NavigationPathMgr:TransGraphCfg can'f find data by SrcID=%d, ActorResID=%d", SrcMapID, NpcID)
        return nil
    end

    Data = {Pos = FindAllCfg[1].Position, Dir=FindAllCfg[1].NPCDir}
    GCacheGraphCfgNpcData[Key] = Data
    return Data
end


function NavigationPathMgr:OnInit()
    FLOG_INFO("NavigationPathMgr:OnInit")

    self.MapPathTreeList = {}
    self.MapPathParentTreeList = {}         --倒树，记录所有父节点
    self.MapBlockCfgList = {}
    self.MapBlockTreeList = {}
    self.FindPathSeqIDList = {}
    self.ConditionEnableDict = {} --交互条件是否满足
    self.MapPathsCache = {}
    setmetatable(self.MapPathsCache, {__mode = "kv"})    

    self:BuildMapPathTree()

    self.MultiBlockMapIDList = {} --add by sammrli 存储有多个地块的地图ID,方便做优化
end

function NavigationPathMgr:OnShutdown()
    self.MapPathTreeList = nil
    self.MapPathParentTreeList = nil
    self.MapBlockCfgList = nil
    self.MapBlockTreeList = nil
    self.FindPathSeqIDList = nil
    self.MapPathsCache = nil
    self.ConditionEnableDict = nil

    self.SuccessPaths = nil
    self.MultiBlockMapIDList = nil
    self:CacheOneFrameDataClear()
end

function NavigationPathMgr:OnBegin()
    local AllCfg = TransGraphCfg:FindAllCfg()
    for _, OneTransGraphCfg in ipairs(AllCfg) do
        --1，获取所有交互条件
        local InteractiveID = OneTransGraphCfg.InteractiveID
        if (InteractiveID > 0) then
            local Cfg = InteractivedescCfg:FindCfgByKey(InteractiveID)
            if (Cfg ~= nil and Cfg.ConditionID > 0 and self.ConditionEnableDict[Cfg.ConditionID] == nil) then
                --默认-1
                self.ConditionEnableDict[Cfg.ConditionID] = -1
            end
        end

        if OneTransGraphCfg.MapID == OneTransGraphCfg.DstMapID then
            self.MultiBlockMapIDList[OneTransGraphCfg.MapID] = true
        end
    end
end

function NavigationPathMgr:OnRegisterNetMsg()
    FLOG_INFO("NavigationPathMgr:OnRegisterNetMsg")

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NAVMESH, 0, self.OnFindPathNotify)
end

function NavigationPathMgr:OnFindPathNotify(MsgBody)
    local FindPathRsp = MsgBody
    if not FindPathRsp then
        return
    end

    local FindItem, _ = table.find_item(self.FindPathSeqIDList, FindPathRsp.id)
    if (FindItem == nil) then
        return
    end
    table.remove_item(self.FindPathSeqIDList, FindItem)

    local PointNum = #FindPathRsp.NavPoints
    if PointNum <= 1 then
        FLOG_WARNING("NavigationPath OnFindPathNotify Error Points Num:%d", PointNum)
        return
    end

    FLOG_INFO("NavigationPath OnFindPathNotify Seq:%d, pointNum:%d", FindPathRsp.id, PointNum)

    --show
    local PointList = self:ConvertFindPathRsp(FindPathRsp)
    self:ShowFindPath(PointList)
end

--对外接口，获取路径
--[[
    实例如下：从1001地图(1,1,1)点到1003地图（13,13,13）点；返回路径如下
    table={
        {
            Type = MapInside                                                                --地图内数据
            MapID = 1001,
            Paths = {
                {StartPos=(1,1,1), EndPos=(3,4,5), TransType= TRANSITION_NONE, OriginEndPos=(4,4,5)},   --源点到NPC传送点,OriginEndPos是NPC源点坐标，EndPos是NPC偏移坐标
                {StartPos=(3,4,5), EndPos=(6,7,8), TransType= TRANSITION_NPC ActorResID=1009823},       --俩区块通过NPC传送
                {StartPos=(6,7,8), EndPos=(9,9,9)},                                    --NPC传送点到传送带坐标
            }
        },
        {
            Type = MapInside                                                                   --地图内数据
            MapID = 1002,
            Paths = {
                {StartPos=(10,10,10), EndPos=(11,11,11)},            --1001NPC传送在1002的落点
            }
        },
        {
            Type = MapInside                                                                   --地图内数据
            MapID = 1003,
            Paths = {
                {StartPos=(12,12,12), EndPos=(13,13,13)},             --1002传动带在1003的落点
            }
        },
        {
            Type = MapLink
            FromMapID = 1001
            ToMapID = 1002
            FromMapPos = (9,9,9)
            ToMapPos = (10,10,10)
            LinkType = TRANSITION_NPC
            LinkData = {ActorResID=100387, InteractiveID=90}
        },
        {
            Type = MapLink
            FromMapID = 1002
            ToMapID = 1003
            FromMapPos = (11,11,11)
        ToMapPos = (12,12,12)
            LinkType = TransEdge
        },
    }
]]
function NavigationPathMgr:FindMapPaths(SrcMapID, SrcPos, TargetMapID, TargetPos)
    if (SrcPos == nil or TargetPos == nil) then
        FLOG_ERROR("NavigationPathMgr:FindMapPaths SrcPos or TargetPos is nil!")
        return
    end

    --条件变化（任务完成会解锁NPC传送）
    local IsConditionChanged = self:CheckConditionChanged()

    local CacheKey = string.format("%d-%d-(%d,%d,%d)-(%d,%d,%d)", SrcMapID, TargetMapID,
    math.ceil(SrcPos.X), math.ceil(SrcPos.Y), math.ceil(SrcPos.Z),
    math.ceil(TargetPos.X), math.ceil(TargetPos.Y), math.ceil(TargetPos.Z))

    local CacheItem = self.MapPathsCache[CacheKey]
    if (CacheItem ~= nil and (not IsConditionChanged)) then
        return CacheItem
    end

    --动态地图
    local DynamicSrcMapID = self:RejustDynamicMap(SrcMapID)
    local DynamicTargetMapID = self:RejustDynamicMap(TargetMapID)

    --有改变，才处理
    if (IsConditionChanged) then
        self:CacheOneFrameDataClear()
    end

    --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:FindMapPaths")
    local NavigationPaths = {}
    --中间处理，使用动态地图
    if (DynamicSrcMapID == DynamicTargetMapID) then
        local MapPaths = self:DoSameMapNavigate(DynamicSrcMapID, SrcPos, TargetPos)
        if (MapPaths ~= nil) then
            table.insert(NavigationPaths, MapPaths)
        end
    else
        NavigationPaths = self:DoDifferentMapNavigate(DynamicSrcMapID, SrcPos, DynamicTargetMapID, TargetPos)
    end

    if (NavigationPaths == nil or #NavigationPaths == 0) then
        FLOG_WARNING("无法找到路径从地图%d(%s), 到地图%d(%s)", SrcMapID, tostring(SrcPos), TargetMapID, tostring(TargetPos))
    else
        --MapID切换回来
        --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:FindMapPaths 1")
        if (DynamicSrcMapID ~= SrcMapID or DynamicTargetMapID ~= TargetMapID) then
            for _, ItemValue in ipairs(NavigationPaths) do
                if (ItemValue.MapID ~= nil) then
                    --地图路径
                    if (ItemValue.MapID == DynamicSrcMapID) then
                        ItemValue.MapID = SrcMapID
                    elseif (ItemValue.MapID == DynamicTargetMapID) then
                        ItemValue.MapID = TargetMapID
                    end
                elseif (ItemValue.FromMapID ~= nil) then
                    --链接信息
                    if (ItemValue.FromMapID == DynamicSrcMapID) then
                        ItemValue.FromMapID = SrcMapID
                    elseif (ItemValue.ToMapID == DynamicTargetMapID) then
                        ItemValue.ToMapID = TargetMapID
                    end
                end
            end
        end

        --add originpos
        for _, ItemValue in pairs(NavigationPaths) do
            if (ItemValue.Type == self.EMapPathType.MapInside) then
                for _, OnePath in pairs(ItemValue.Paths) do
                    OnePath.OriginEndPos = GCacheNPCOriginPos[OnePath.EndPos]
                end
            end
        end

        self.MapPathsCache[CacheKey] = NavigationPaths

    end

    --_G.UE.FProfileTag.StaticEnd()

    return NavigationPaths
end

---@param NpcID NPC表对应ID
---@return MapPath, Pos | nil
function NavigationPathMgr:FindMapPathsForNpcID(SrcMapID, SrcPos, TargetMapID, NpcID)
    local TargetPos = self.GetNavigationPosByNpcID(TargetMapID, NpcID)
    if (TargetPos == nil) then
        FLOG_ERROR("NavigationPathMgr MapID(%d) not exist NPCID(%d)", TargetMapID, NpcID)
        return nil
    end

    return self:FindMapPaths(SrcMapID, SrcPos, TargetMapID, TargetPos), TargetPos
end

--单帧缓存数据，
function NavigationPathMgr:CacheOneFrameDataClear()
    self.CacheOnceEnableTransGraphCfgList = nil
    self.CacheOnceEnableTransGraphCfgList = {}

    self.CacheOnceInteractiveCond = nil
    self.CacheOnceInteractiveCond = {}

    self.CacheOnceChrildrenMaps = nil
    self.CacheOnceChrildrenMaps = {}

    self.CacheOnceParentMaps = nil
    self.CacheOnceParentMaps = {}

    self.CacheOnceShortestMaps = nil
    self.CacheOnceShortestMaps = {}
end

--内部使用，不对外
function NavigationPathMgr:FindPathsTest(SrcMapID, SrcPos, TargetMapID, TargetPos)
    local NavigationPaths = self:FindMapPaths(SrcMapID, SrcPos, TargetMapID, TargetPos)

    if (NavigationPaths == nil) then
        return
    end

    --TODO:向服务器发送路点请求
    local CurMapID = _G.PWorldMgr:GetCurrMapResID()
    local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()

    for _, MapPath in ipairs(NavigationPaths) do
        if (MapPath.MapID == CurMapID) then
            for _, PathInfo in ipairs(MapPath.Paths) do
                if (PathInfo.TransType == TransitionType.TRANSITION_INVALID) then
                    FLOG_INFO(
                        "UMoveSyncMgr-FindPath StartPos:%s, EndPos:%s",
                        tostring(PathInfo.StartPos),
                        table.tostring(PathInfo.EndPos)
                    )

                    local UEStartPos = _G.UE.FVector(PathInfo.StartPos.X, PathInfo.StartPos.Y, PathInfo.StartPos.Z)
                    local UEEndPos = _G.UE.FVector(PathInfo.EndPos.X, PathInfo.EndPos.Y, PathInfo.EndPos.Z)

                    local FindPathSeqID = UMoveSyncMgr:FindPath(UEStartPos, UEEndPos)
                    table.insert(self.FindPathSeqIDList, FindPathSeqID)
                    break
                end
            end
            break
        end
    end
end

function NavigationPathMgr:FindPathsByNpcIDTest(SrcMapID, SrcPos, TargetMapID, NpcID)
    local Pos = self.GetNavigationPosByNpcID(TargetMapID, NpcID)

    self:FindPathsTest(SrcMapID, SrcPos, TargetMapID, Pos)
end

function NavigationPathMgr:ConvertFindPathRsp(FindPathRsp)
    local PointListRsp = {}

    local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()
    local PointNum = #FindPathRsp.NavPoints
    for index = 1, PointNum do
        local Pos = FindPathRsp.NavPoints[index].point_data
        local FVectorPos = _G.UE.FVector(Pos.X, Pos.Y, Pos.Z) - WorldOriginLoc
        table.insert(PointListRsp, FVectorPos)
    end

    return PointListRsp
end

function NavigationPathMgr:ShowFindPath(PointList)
    local PosTable = _G.UE.TArray(_G.UE.FVector)

    for _, Point in ipairs(PointList) do
        PosTable:Add(Point)
    end

    _G.UE.UPWorldMgr:Get():ShowRoadGraph(PosTable, 1000)
end

--构建场景路径图
--[[
    MapPathTreeList = {
        {MapID= 1001,ChildrenMaps={1002,1003,1004}}
        {MapID= 1003,ChildrenMaps={1004,1005}}
        {MapID= 1004,ChildrenMaps={1005,1006}}
    }
]]
function NavigationPathMgr:BuildMapPathTree()
    --path graph build, parent graph
    local AllCfg = TransGraphCfg:FindAllCfg() or {}
    for i = 1, #AllCfg do
        local MapID = AllCfg[i].MapID
        local DstMapID = AllCfg[i].DstMapID
        if (MapID ~= DstMapID) then
            --1，保存叶子节点（正树）            
            local ChildrenMaps = nil
            for _, MapData in ipairs(self.MapPathTreeList) do
                if MapData.MapID == MapID then
                    ChildrenMaps = MapData.ChildrenMaps
                end
            end

            if (ChildrenMaps == nil) then
                --new one
                local NodeInfo = {}
                NodeInfo.MapID = MapID
                NodeInfo.ChildrenMaps = {}
                table.insert(NodeInfo.ChildrenMaps, DstMapID)
                table.insert(self.MapPathTreeList, NodeInfo)
            else
                --存在就不添加
                local FindItem, _ = table.find_item(ChildrenMaps, DstMapID)
                if (FindItem == nil) then
                    table.insert(ChildrenMaps, DstMapID)
                end
            end

            --2，保存父节点（倒树）
            local ParentMaps = nil
            for _, MapData in ipairs(self.MapPathParentTreeList) do
                if MapData.DstMapID == DstMapID then
                    ParentMaps = MapData.ParentMaps
                end
            end

            if (ParentMaps == nil) then
                --new one
                local NodeInfo = {}
                NodeInfo.DstMapID = DstMapID
                NodeInfo.ParentMaps = {}
                table.insert(NodeInfo.ParentMaps, MapID)
                table.insert(self.MapPathParentTreeList, NodeInfo)
            else
                --存在就不添加
                local FindItem, _ = table.find_item(ParentMaps, MapID)
                if (FindItem == nil) then
                    table.insert(ParentMaps, MapID)
                end
            end            
        end
    end

    FLOG_INFO("MapTree: %s, ParentMapTree:%s", table.tostring(self.MapPathTreeList), 
    table.tostring(self.MapPathParentTreeList))
end

--同地图寻路
---@field MapPaths 返回当前地图的路径信息{MapID, Paths}
---@field EndPosActorResID 终点对应的ActorID
---@field EndPosInteractiveID 终点对应的交互ID
function NavigationPathMgr:DoSameMapNavigate(MapID, SrcPos, TargetPos, EndPosActorResID, EndPosInteractiveID)
    local Paths = {}

    local MapPaths = {}
    MapPaths.Type = self.EMapPathType.MapInside
    MapPaths.MapID = MapID
    MapPaths.Paths = Paths

    --1,源点到目标点是否在同一区块
    local SrcBlockID = -1
    local TargetBlockID = -1
     --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:GetBlockID")
    if self.MultiBlockMapIDList[MapID] then --地图有多个块才处理
        SrcBlockID = self:GetBlockID(MapID, SrcPos)
        TargetBlockID = self:GetBlockID(MapID, TargetPos)
    end
    --_G.UE.FProfileTag.StaticEnd()
    if (SrcBlockID == TargetBlockID) then
        --可直接到达
        local OnePath = {}
        OnePath.StartPos = SrcPos
        OnePath.EndPos = TargetPos
        OnePath.TransType = TransitionType.TRANSITION_INVALID
        OnePath.EndPosActorResID = EndPosActorResID
        OnePath.EndPosInteractiveID = EndPosInteractiveID

        table.insert(Paths, OnePath)

        return MapPaths
    end

    --2,源点，目标点在同地图不同区域
    local TransGraphList = self:GetEnableTransGraphCfgList(MapID, MapID)
    if (TransGraphList == nil or #TransGraphList == 0) then
        FLOG_ERROR("TransGraphCfg table no item in same Map:%d", MapID)
        return nil
    end

    --2.1 递归获取源地块到目标地块
    self.SuccessBlockPaths = {}
    local FindingPath = {}

    self:FindBlockPath(MapID, SrcBlockID, TargetBlockID, FindingPath)

    if (table.length(self.SuccessBlockPaths) <= 0) then
        FLOG_ERROR("Map Block error, in Map:%d", MapID)
        return nil
    end

    --2.2 存在多条路径，找到跨最少地块路径
    local MinLength = 1000
    local ShortestPath = {}
    for _, BlockPath in ipairs(self.SuccessBlockPaths) do
        local len = table.length(BlockPath)
        if (len < MinLength) then
            MinLength = len
            ShortestPath = BlockPath
        end
    end

    --2.3 俩地块之间存在多个联通，获取联通路点
    local BlockPathPosList = self:GetMapBlockPathPosList(MapID)

    local AllPathPos = {}
    --起始点
    table.insert(AllPathPos, {Pos=SrcPos})

    --遍历路径，获取路点位置信息
    for i = 1, #ShortestPath - 1 do
        local BlockIDFrom = ShortestPath[i]
        local BlockIDTo = ShortestPath[i + 1]
        local AllBlockPathPos =
            table.find_all_by_predicate(
            BlockPathPosList,
            function(A)
                return A.SrcBlockID == BlockIDFrom and A.DstBlockID == BlockIDTo
            end
        )

        local MinDistance = 100000000
        local SelectPathPos = nil

        for _, PathPos in ipairs(AllBlockPathPos) do
            if (i == 1) then
                --起始地块，选择离源点最近
                local Pos = PathPos.Position[1]
                local Distance =
                    _G.UE.FVector.Dist(_G.UE.FVector(SrcPos.X, SrcPos.Y, SrcPos.Z), _G.UE.FVector(Pos.X, Pos.Y, Pos.Z))
                if (Distance < MinDistance) then
                    MinDistance = Distance
                    SelectPathPos = PathPos
                end
            else
                --选择任意一条
                SelectPathPos = PathPos
                break
            end
        end

        table.insert(AllPathPos, {Pos=SelectPathPos.Position[1],
                ActorResID=SelectPathPos.ActorResID, InteractiveID=SelectPathPos.InteractiveID,
                TransType=SelectPathPos.TransType})
        table.insert(AllPathPos, {Pos=SelectPathPos.Position[2]})
    end

    --目标点
    table.insert(AllPathPos, {Pos=TargetPos})

    --遍历所有路点，生成路径
    for i = 1, #AllPathPos - 1 do
        local OnePath = {}
        OnePath.TransType = AllPathPos[i].TransType or 0
        OnePath.StartPos = AllPathPos[i].Pos
        OnePath.EndPos = AllPathPos[i + 1].Pos
        OnePath.ActorResID = AllPathPos[i].ActorResID
        OnePath.InteractiveID = AllPathPos[i].InteractiveID
        OnePath.EndPosActorResID = AllPathPos[i + 1].ActorResID
        OnePath.EndPosInteractiveID = AllPathPos[i + 1].InteractiveID

        table.insert(Paths, OnePath)
    end    

    return MapPaths
end

--同地图内找到块连接路径
function NavigationPathMgr:FindBlockPath(MapID, SrcBlockID, DstBlockID, FindingPath)
    table.insert(FindingPath, SrcBlockID)

    --1,是否在孩子节点
    local BlockChildren = self:GetMapBlockChildren(MapID, SrcBlockID)
    if (BlockChildren ~= nil and table.length(BlockChildren) > 0) then
        local FindItem, _ = table.find_item(BlockChildren, DstBlockID)
        if (FindItem ~= nil) then
            --找到目标
            table.insert(FindingPath, DstBlockID)

            --添加成功路径
            table.insert(self.SuccessBlockPaths, FindingPath)
            return
        end

        --没找到，下一层继续查找
        for _, ChildrenBlockID in ipairs(BlockChildren) do
            local FindItem, _ =
                table.find_by_predicate(
                FindingPath,
                function(A)
                    return A == ChildrenBlockID
                end
            )

            if (FindItem == nil) then
                --已经找过的不再查找，避免死循环
                local PathClone = table.clone(FindingPath)
                self:FindBlockPath(MapID, ChildrenBlockID, DstBlockID, PathClone)
            end
        end
    else
        --叶子节点
        if (SrcBlockID == DstBlockID) then
            --添加成功路径
            table.insert(self.SuccessBlockPaths, FindingPath)
        else
            FindingPath = nil
        end
    end
end

--地图块连接树
--[[
    MapBlockTreeList =
    {
        {
            MapID = 1004,
            BlockTrees =
                {
                    {BlockID = 1 Children = {2, 3}}
                    {BlockID = 2 Children = {3}}
                    {BlockID = 3 Children = {4}}
                },
            BlockPathPosList={
                {
                    SrcBlockID=1,DstBlockID=2,ActorResID=1002
                    Position={(100.4, 1005.5, 1006.4), (103.4, 1015.5, 1106.4)}
                },
                {
                    SrcBlockID=2,DstBlockID=3,ActorResID=1003
                    Position={(100.4, 1005.5, 1006.4), (103.4, 1015.5, 1106.4)}
                },
                {
                    SrcBlockID=3,DstBlockID=4,ActorResID=1004
                    Position={(100.4, 1005.5, 1006.4), (103.4, 1015.5, 1106.4)}
                }
            }
        },
        //每个地图一个数据
    }
]]
function NavigationPathMgr:BuildMapBlockTree(MapID)
    local TransGraphList = TransGraphCfg:FindAllCfg(string.format("MapID = %d and DstMapID=%d", MapID, MapID))

    if (TransGraphList == nil) then
        FLOG_ERROR("TransGraphCfg table no item in same Map:%d", MapID)
        return
    end

    local MapBlockTree = {}
    local BlockTreeList = {}
    local BlockPathPosList = {}

    MapBlockTree.MapID = MapID
    MapBlockTree.BlockTreeList = BlockTreeList
    MapBlockTree.BlockPathPosList = BlockPathPosList

    for _, TransGraphInfo in ipairs(TransGraphList) do
        --返回的是导航点，存在偏移
        local Position = self:GetTransGraphCfgPosition(TransGraphInfo)

        --NPC需要使用原点
        if (TransGraphInfo.TransType == TransitionType.TRANSITION_NPC) then
            Position = self.GetNpcOriginPos(Position)
        end

        local TempSrcBlockID = self:GetBlockID(MapID, Position)
        local TempDstBlockID = self:GetBlockID(MapID, TransGraphInfo.DstPosition)

        if (TempSrcBlockID ~= TempDstBlockID) then
            local OneBlockPos = {}
            OneBlockPos.SrcBlockID = TempSrcBlockID
            OneBlockPos.DstBlockID = TempDstBlockID
            OneBlockPos.ActorResID = TransGraphInfo.ActorResID
            OneBlockPos.InteractiveID = TransGraphInfo.InteractiveID
            OneBlockPos.TransType = TransGraphInfo.TransType
            OneBlockPos.Position = {Position, TransGraphInfo.DstPosition}
            table.insert(BlockPathPosList, OneBlockPos)

            local BlockTree, _ =
                table.find_by_predicate(
                BlockTreeList,
                function(A)
                    return A.BlockID == TempSrcBlockID
                end
            )

            if (BlockTree ~= nil) then
                local item, _ = table.find_item(BlockTree.Children, TempDstBlockID)
                if (item == nil) then
                    table.insert(BlockTree.Children, TempDstBlockID)
                end
            else
                BlockTree = {}
                local Children = {}
                BlockTree.BlockID = TempSrcBlockID
                BlockTree.Children = Children

                table.insert(Children, TempDstBlockID)
                table.insert(BlockTreeList, BlockTree)
            end
        else
            FLOG_ERROR(
                "TransGraphCfg 错误，存在同地图同区域联通点. MapID=%d, SrcPos=%s, DstPos=%s",
                MapID,
                table.tostring(Position),
                table.tostring(TransGraphInfo.DstPosition)
            )
        end
    end

    table.insert(self.MapBlockTreeList, MapBlockTree)

    return MapBlockTree, MapBlockTree.BlockTreeList
end

function NavigationPathMgr:GetMapBlockPathPosList(MapID)
    local MapBlockTree, _ =
        table.find_by_predicate(
        self.MapBlockTreeList,
        function(A)
            return A.MapID == MapID
        end
    )

    if (MapBlockTree ~= nil) then
        return MapBlockTree.BlockPathPosList
    end

    return nil
end

function NavigationPathMgr:GetMapBlockChildren(MapID, BlockID)
    local MapBlockTree, _ =
        table.find_by_predicate(
        self.MapBlockTreeList,
        function(A)
            return A.MapID == MapID
        end
    )

    if (MapBlockTree == nil) then
        --不存在，新创建
        MapBlockTree, _ = self:BuildMapBlockTree(MapID)
    end

    local BlockTreeList = MapBlockTree.BlockTreeList
    local BlockPathPosList = MapBlockTree.BlockPathPosList

    local BlockTree, _ =
        table.find_by_predicate(
        BlockTreeList,
        function(A)
            return A.BlockID == BlockID
        end
    )

    if (BlockTree == nil) then
        return nil
    end

    --检查是否满足条件
    local RetBlockChildrenTable = {}
    for _, ChildrenBlockID in ipairs(BlockTree.Children) do
        local NeedAdd = true

        --两个区块之间存在多条连接
        for _, PathPosInfo in ipairs(BlockPathPosList) do
            if (PathPosInfo.SrcBlockID == BlockID and PathPosInfo.DstBlockID == ChildrenBlockID) then
                if (PathPosInfo.InteractiveID > 0) then
                    NeedAdd = self:CheckInteractiveCond(PathPosInfo.InteractiveID)
                    if (NeedAdd) then
                        --有一个成功了，表示联通了
                        break
                    end
                end
            end
        end

        if (NeedAdd) then
            table.insert(RetBlockChildrenTable, ChildrenBlockID)
        end
    end

    return RetBlockChildrenTable
end

--获取两个地图的最短地图路径
function NavigationPathMgr:GetShortestMaps(SrcMapID, TargetMapID)
    --缓存中数据
    local Key = TwoMapsKey(SrcMapID, TargetMapID)

    local Value = self.CacheOnceShortestMaps[Key]
    if (Value ~= nil) then
        return Value
    end

    local ShortestMapsTable = {}

    local AllFullPaths = self:GetAllFullPaths(SrcMapID, TargetMapID)

    --[[找到最短路径,地图间
        1:A->B->C->D,
        2:A->B->D   ----->多条最短路径，还需继续判断路径最少
        3:A->c->D   ----->
    --]]
    local MaxPathLen = 100000
    for _, SuccessPath in ipairs(AllFullPaths) do
        local PathLen = table.length(SuccessPath)
        if (PathLen < MaxPathLen) then
            MaxPathLen = PathLen

            _G.TableTools.ClearTable(ShortestMapsTable)

            table.insert(ShortestMapsTable, SuccessPath)
        elseif (PathLen == MaxPathLen) then
            table.insert(ShortestMapsTable, SuccessPath)
        end
    end

    local Num = table.length(ShortestMapsTable)
    if (Num < 0) then
        return nil
    end

    --cache
    self.CacheOnceShortestMaps[Key] = ShortestMapsTable

    return ShortestMapsTable
end


function NavigationPathMgr:GetAllFullPaths(SrcMapID, TargetMapID)
    self.SuccessPaths = {}
    self.MinSuccessPathLength = 100000

    local ParentMapPath = {}
    
    self:FindAllMapPaths(SrcMapID, TargetMapID, ParentMapPath)
    
    local RetPaths = table.deepcopy(self.SuccessPaths)

    return RetPaths
end

--跨地图寻路
function NavigationPathMgr:DoDifferentMapNavigate(SrcMapID, SrcPos, TargetMapID, TargetPos)
    --1,获取最短地图路径
    local ShortestMapsTable = self:GetShortestMaps(SrcMapID, TargetMapID)
    if (ShortestMapsTable == nil) then
        return nil
    end

    --2,获取跨地图最短路径    
    local ShortestMapPaths = nil
    local MinDistance = 100000000
    local MinPathLen = 100000

    --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:GeneratedDiffMapShortestPath")

    for _, ShortestMapsValue in ipairs(ShortestMapsTable) do
        local ShortestPaths, Length, Distance = self:GeneratedDiffMapShortestPath(ShortestMapsValue, SrcPos, TargetPos)
        if (ShortestPaths ~= nil and #ShortestPaths > 0) then
            if (Length < MinPathLen) then
                MinPathLen = Length
                MinDistance = Distance
                ShortestMapPaths = ShortestPaths                
            elseif (Length == MinPathLen and Distance < MinDistance) then
                MinPathLen = Length
                MinDistance = Distance
                ShortestMapPaths = ShortestPaths                
            end
        end
    end
    --_G.UE.FProfileTag.StaticEnd()

    if (ShortestMapPaths == nil) then
        FLOG_WARNING("DoDifferentMapNavigate no path find!")
        return nil
    end

    --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:Generated MapLink")

    local RetMapPaths = table.clone(ShortestMapPaths)

    --地图间传送数据
    for i = 1, #ShortestMapPaths - 1 do
        local CurMapPaths = ShortestMapPaths[i]
        local NextMapPaths = ShortestMapPaths[i + 1]

        local MapLinkSrcMapID = CurMapPaths.MapID
        local MapLinkDstMapID = NextMapPaths.MapID
        local MapLinkSrcPos = CurMapPaths.Paths[#CurMapPaths.Paths].EndPos
        local MapLinkDstPos = NextMapPaths.Paths[1].StartPos

        --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:GetTransGraphCfg()")
        local FindItem = self:GetTransGraphCfg(MapLinkSrcMapID, MapLinkDstMapID, MapLinkSrcPos, MapLinkDstPos)
        --_G.UE.FProfileTag.StaticEnd()

        if (FindItem ~= nil) then
            local MapLinkData = {}
            MapLinkData.Type = self.EMapPathType.MapLink
            MapLinkData.FromMapID = MapLinkSrcMapID
            MapLinkData.FromMapPos = MapLinkSrcPos
            MapLinkData.ToMapID = MapLinkDstMapID
            MapLinkData.ToMapPos = MapLinkDstPos
            MapLinkData.LinkType = FindItem.TransType

            if
                (FindItem.TransType == TransitionType.TRANSITION_NPC or
                    FindItem.TransType == TransitionType.TRANSITION_EOBJ)
             then
                MapLinkData.LinkData = {ActorResID = FindItem.ActorResID, InteractiveID = FindItem.InteractiveID}
            end

            table.insert(RetMapPaths, MapLinkData)
        end
    end

    --_G.UE.FProfileTag.StaticEnd()

    return RetMapPaths
end

--返回跨地图最短路径
function NavigationPathMgr:GeneratedDiffMapShortestPath(DifferentMaps, SrcPos, DstPos)
    local Num = table.length(DifferentMaps)
    if (Num < 1) then
        return nil
    end

    --1,遍历地图，找到所有的路径
    local NavigatePaths = {}

    local OneNavigatePath = {}
    OneNavigatePath.SrcPos = SrcPos
    OneNavigatePath.MapPaths = {}
    table.insert(NavigatePaths, OneNavigatePath)

    --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:allshortestpath-----")

    for i = 1, Num - 1 do
        local TempSrcMapID = DifferentMaps[i]
        local TempDstMapID = DifferentMaps[i + 1]

        local TransGraphList = self:GetEnableTransGraphCfgList(TempSrcMapID, TempDstMapID)
        if (TransGraphList == nil or #TransGraphList == 0) then
            FLOG_ERROR("GeneratedDiffMap failed! no trans graph!")
            return nil
        end

        --获取当前地图到下一地图的链接点，作为当前地图的目标点
        local TempNavigatePaths = {}
        for _, TransGraphInfo in ipairs(TransGraphList) do
            local PathDstPos = self:GetTransGraphCfgPosition(TransGraphInfo)
            if (PathDstPos == nil) then
                FLOG_ERROR("NavigationPathMgr: failed! no find pos!")
                return nil
            end

            local NextPathSrcPos = TransGraphInfo.DstPosition

            --遍历上一个地图的所有路径，生成新的路径
            for _, ItemValue in ipairs(NavigatePaths) do
                local TempValue = {}
                --修正源点
                TempValue.SrcPos = NextPathSrcPos
                TempValue.MapPaths = table.clone(ItemValue.MapPaths)

                --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:DoSameMapNavigate-----")
                local MapPahts = self:DoSameMapNavigate(TempSrcMapID, ItemValue.SrcPos, PathDstPos,
                    TransGraphInfo.ActorResID, TransGraphInfo.InteractiveID)
                --_G.UE.FProfileTag.StaticEnd()

                if (MapPahts == nil) then
                    FLOG_ERROR("No Path in SameMap:%d", TempSrcMapID)
                    return nil
                end

                table.insert(TempValue.MapPaths, MapPahts)

                --新的路径
                table.insert(TempNavigatePaths, TempValue)
            end
        end

        --替换原来的
        _G.TableTools.ClearTable(NavigatePaths)

        NavigatePaths = table.clone(TempNavigatePaths)

        TempNavigatePaths = nil
    end

    --最后一个地图
    local TempNavigatePaths = {}
    for _, ItemValue in ipairs(NavigatePaths) do
        local TargetMapID = DifferentMaps[Num]

        local TempValue = {}
        --修正源点
        TempValue.SrcPos = DstPos
        TempValue.MapPaths = table.clone(ItemValue.MapPaths)

        local MapPahts = self:DoSameMapNavigate(TargetMapID, ItemValue.SrcPos, DstPos)
        if (MapPahts == nil) then
            FLOG_ERROR("No Path in SameMap:%d", TargetMapID)
            return nil
        end

        table.insert(TempValue.MapPaths, MapPahts)

        --新的路径
        table.insert(TempNavigatePaths, TempValue)
    end

    --_G.UE.FProfileTag.StaticEnd()

    _G.TableTools.ClearTable(NavigatePaths)
    NavigatePaths = table.clone(TempNavigatePaths)

    TempNavigatePaths = nil

    --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:FindShortestPath-----")

    --2，找到最短路径
    local ShortestBlockPath = {}
    local MinPathLen = 100000
    local MinDistance = 10000000
    for _, NavigatePath in ipairs(NavigatePaths) do
        local AllMapBlockPaths = NavigatePath.MapPaths

        local AllLen = 0
        local AllDistance = 0
        for _, MapPath in ipairs(AllMapBlockPaths) do
            local length = table.length(MapPath.Paths)
            AllLen = AllLen + length

            AllDistance = AllDistance + self:GetMapPathsDistance(MapPath)
        end

        --数量一致，比较路径长度
        if (AllLen < MinPathLen or (AllLen == MinPathLen and AllDistance < MinDistance)) then
            ShortestBlockPath = AllMapBlockPaths
            MinDistance = AllDistance
            MinPathLen = AllLen
        end
    end
    --_G.UE.FProfileTag.StaticEnd()

    return ShortestBlockPath, MinPathLen, MinDistance
end

function NavigationPathMgr:GetMapPathsDistance(MapPath)
    --[[table=
    --
        {
            MapID,
            Paths={{StartPos,EndPos, TransType == TransitionType.TRANSITION_INVALID}
        }
    --]]
    local Distance = 0
    for _, Path in ipairs(MapPath.Paths) do
        if (Path.TransType == TransitionType.TRANSITION_INVALID) then
            --跨区域的路径通过传送到达，忽略
            local UEStartPos = _G.UE.FVector(Path.StartPos.X, Path.StartPos.Y, Path.StartPos.Z)
            local UEEndPos = _G.UE.FVector(Path.EndPos.X, Path.EndPos.Y, Path.EndPos.Z)
            Distance = Distance + _G.UE.FVector.Dist(UEStartPos, UEEndPos)
        end
    end

    return Distance
end

function NavigationPathMgr:GetMapTreeChildrenMaps(MapID)
    local FindItem = self.CacheOnceChrildrenMaps[MapID]

    if (FindItem ~= nil) then
        return FindItem
    end

    for _, MapData in ipairs(self.MapPathTreeList) do
        if MapData.MapID == MapID then
            --NPC,EBOJ的地图有开启条件，所以这里需要判断俩地图之间是否联通
            local RetChildrenMapTable = {}
            for _, ChildrenMapID in ipairs(MapData.ChildrenMaps) do
                local TransList = self:GetEnableTransGraphCfgList(MapID, ChildrenMapID)
                if (TransList ~= nil and #TransList > 0) then
                    table.insert(RetChildrenMapTable, ChildrenMapID)
                end
            end

            self.CacheOnceChrildrenMaps[MapID] = RetChildrenMapTable

            return RetChildrenMapTable
        end
    end

    return nil
end

--获取parent地图
function NavigationPathMgr:GetMapTreeParentMaps(DstMapID)
    if (self.CacheOnceParentMaps == nil) then
        self.CacheOnceParentMaps = {}
    end

    local FindItem = self.CacheOnceParentMaps[DstMapID]

    if (FindItem ~= nil) then
        return FindItem
    end

    for _, MapData in ipairs(self.MapPathParentTreeList) do
        if MapData.DstMapID == DstMapID then
            --NPC,EBOJ的地图有开启条件，所以这里需要判断俩地图之间是否联通
            local RetParentMapTable = {}
            for _, MapID in ipairs(MapData.ParentMaps) do
                local TransList = self:GetEnableTransGraphCfgList(MapID, DstMapID)
                if (TransList ~= nil and #TransList > 0) then
                    table.insert(RetParentMapTable, MapID)
                end
            end

            self.CacheOnceParentMaps[DstMapID] = RetParentMapTable

            return RetParentMapTable
        end
    end

    return nil
end

--获取联通点坐标：NPC需要重新计算，其他使用设置值
function NavigationPathMgr:GetTransGraphCfgPosition(OneTransGraphCfg)
    if (OneTransGraphCfg.TransType ~= TransitionType.TRANSITION_NPC) then
        return OneTransGraphCfg.Position
    end

    --NPC获取偏移坐标
    return self.GetNavigationPosByNpcID(OneTransGraphCfg.MapID, OneTransGraphCfg.ActorResID)
end

--获取地图间的可用连接信息
function NavigationPathMgr:GetEnableTransGraphCfgList(SrcMapID, DstMapID)
    --缓存中获取
    local Key = TwoMapsKey(SrcMapID, DstMapID)
    local Value = self.CacheOnceEnableTransGraphCfgList[Key]
    if (Value ~= nil) then
        return Value
    end

    --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:FindAllCfg")
    local FindAllCfg = TransGraphCfg:FindAllCfg(string.format("MapID = %d and DstMapID=%d", SrcMapID, DstMapID))
    --_G.UE.FProfileTag.StaticEnd()

    if (FindAllCfg == nil or #FindAllCfg == 0) then
        FLOG_ERROR("GetEnableTransGraphCfgList can'f find data by SrcID=%d, DstID=%d", SrcMapID, DstMapID)
        return nil
    end
    
    local RetCfgList = {}
    --增加交互开启条件判断，NPC,EOBJ需要处理
    for _, ItemValue in ipairs(FindAllCfg) do
        local NeedAdd = true
        if (ItemValue.InteractiveID > 0) then
            NeedAdd = self:CheckInteractiveCond(ItemValue.InteractiveID)
        end

        if (NeedAdd) then
            local CloneValue = table.clone(ItemValue)

            --Position矫正（NPC）
            CloneValue.Position = self:GetTransGraphCfgPosition(CloneValue)

            table.insert(RetCfgList, CloneValue)
        else
            FLOG_INFO("NavigationPathMgr:InteractiveCond fail, InteractiveID=%d, (%d -> %d)", ItemValue.InteractiveID, SrcMapID, DstMapID)
        end
    end
    
    if (#RetCfgList == 0) then        
        FLOG_WARNING("NavigationPathMgr: SrcMapID=%d, DstMapID=%d no transition", SrcMapID, DstMapID)
    end

    --cache
    self.CacheOnceEnableTransGraphCfgList[Key] = RetCfgList

    return RetCfgList
end

function NavigationPathMgr:CheckInteractiveCond(InteractiveID)
    local Value = self.CacheOnceInteractiveCond[InteractiveID]
    if (Value ~= nil) then
        return Value
    end

    local Success = true
    local Cfg = InteractivedescCfg:FindCfgByKey(InteractiveID)
    if (Cfg ~= nil) then
        if (Cfg.ConditionID > 0) then
            --有条件才判断是否满足条件
            Success = ConditionMgr:CheckConditionByID(Cfg.ConditionID, nil, true)
        end
    else
        FLOG_ERROR("InteractivedescCfg no find item by ID:%d", InteractiveID)
        Success = false
    end
    self.CacheOnceInteractiveCond[InteractiveID] = Success

    return Success
end

function NavigationPathMgr:GetTransGraphCfg(SrcMapID, DstMapID, SrcPos, DstPos)
    local AllCfg = self:GetEnableTransGraphCfgList(SrcMapID, DstMapID)
    if (AllCfg == nil or #AllCfg == 0) then
        return nil
    end

    local FindCfg =
        table.find_by_predicate(
        AllCfg,
        function(A)
            return PosEqual(A.Position, SrcPos) and PosEqual(A.DstPosition, DstPos)
        end
    )

    if (FindCfg == nil) then
        FLOG_WARNING(
            "TransGraphCfg can'f find data by SrcID=%d, DstID=%d, SrcPos=%s, DstPos=%s",
            SrcMapID,
            DstMapID,
            table.tostring(SrcPos),
            table.tostring(DstPos)
        )
        return nil
    end

    return FindCfg
end

--graph find
function NavigationPathMgr:FindAllMapPaths(SrcMapID, TargetMapID, ParentMapPath)
    table.insert(ParentMapPath, SrcMapID)
    --_G.UE.FProfileTag.StaticBegin("NavigationPathMgr:GetMapTreeChildrenMaps")
    local ChildrenMaps = self:GetMapTreeChildrenMaps(SrcMapID)
    --_G.UE.FProfileTag.StaticEnd()

    if (ChildrenMaps ~= nil and #ChildrenMaps > 0) then
        --是否找到目标地图
        for _, ChildrenMapID in ipairs(ChildrenMaps) do
            if (ChildrenMapID == TargetMapID) then
                table.insert(ParentMapPath, TargetMapID)

                if (#ParentMapPath <= self.MinSuccessPathLength) then
                    self.MinSuccessPathLength = #ParentMapPath

                    --add path
                    table.insert(self.SuccessPaths, ParentMapPath)
                else
                    --FLOG_INFO("NavigationPath FindAllPaths: more length! 1")
                    ParentMapPath = nil
                end

                return
            end
        end

        --递归遍历:当前路径小于最小路径才需要做
        if (#ParentMapPath < self.MinSuccessPathLength) then
            for _, ChildMapID in ipairs(ChildrenMaps) do
                --剔除已经找过的地图，避免死循环
                local FindItem, _ = table.find_item(ParentMapPath, ChildMapID)

                if (FindItem == nil) then
                    local ChildPath = table.clone(ParentMapPath)
                    self:FindAllMapPaths(ChildMapID, TargetMapID, ChildPath)
                --else
                    --FLOG_INFO("NavigationPathMgr: path find stop! %s break by : %d", table.tostring(ParentMapPath), ChildMapID)
                end
            end
        else
            --FLOG_INFO("NavigationPath FindAllPaths: more length! 2")
            ParentMapPath = nil
        end
    else
        --叶子节点
        if (SrcMapID == TargetMapID) then
            --是否最短路径
            if (#ParentMapPath <= self.MinSuccessPathLength) then
                self.MinSuccessPathLength = #ParentMapPath

                --add path
                table.insert(self.SuccessPaths, ParentMapPath)
            else
                --FLOG_INFO("NavigationPath FindAllPaths: more length! 0")
                ParentMapPath = nil
            end
        else
            --delete
            --FLOG_WARNING("NavigationPathMgr: path find stop! %s", table.tostring(ParentMapPath))

            ParentMapPath = nil
        end
    end
end

----------------地图块区域begin-----------------

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

function NavigationPathMgr:GetBlockID(MapID, Pos)
    --默认值
    local RetBlockID = -1
    local RetLevel = -1
    local BlockCfgList = self:TryGetMapBlockCfgList(MapID)
    local UEPos = _G.UE.FVector(Pos.X, Pos.Y, Pos.Z)

    if (BlockCfgList ~= nil) then
        for _, BlockCfg in ipairs(BlockCfgList) do
            local BlockID = BlockCfg.BlockID
            local MapRange = BlockCfg.MapRange

            local RejustPos = UEPos
            if (BlockCfg.RotatorZ ~= 0) then                
                RejustPos = Rotate(UEPos, BlockCfg.Center, BlockCfg.RotatorZ * -1)
                --FLOG_INFO("NPC MapID=%d, Pos=%s, RejustPos=%s", MapID, table.tostring(Pos), table.tostring(RejustPos))
            end

            if RejustPos.X >= MapRange.Min.X and RejustPos.Y >= MapRange.Min.Y and RejustPos.X <= MapRange.Max.X and
                RejustPos.Y <= MapRange.Max.Y
             then
                if (BlockCfg.IsXYPlane or (RejustPos.Z >= MapRange.Min.Z and RejustPos.Z <= MapRange.Max.Z)) then
                    if (RetLevel <= BlockCfg.Level) then
                        RetBlockID = BlockID
                        RetLevel = BlockCfg.Level
                    end                                    
                end
            end
        end
    end

    return RetBlockID
end



--解析地图块区域
function NavigationPathMgr:BuildMapBlockCfg(CurrMapEditCfg)
    local MapId = CurrMapEditCfg.MapID
    local AreaList = CurrMapEditCfg.AreaList
    local BlockCfgList = {}
    local OneMapBlockCfg = {}
    OneMapBlockCfg.MapID = MapId
    OneMapBlockCfg.BlockCfgList = BlockCfgList

    table.insert(self.MapBlockCfgList, OneMapBlockCfg)

    for _, Area in ipairs(AreaList) do
        --地图区块处理
        if Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAPBLOCK then
            local BlockID = Area.MapBlock.BlockID
            local IsXYPlane = Area.MapBlock.IsXYPlane
            local Level = Area.MapBlock.Level

            local MapMin = {X = 0, Y = 0, Z = 0}
            local MapMax = {X = 0, Y = 0, Z = 0}
            local Center = nil
            local RotatorZ = 0

            if Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX then
                local Box = Area.Box
                local Extent = Box.Extent
                local Location = Box.Center                

                MapMin = {X = Location.X - Extent.X, Y = Location.Y - Extent.Y, Z = Location.Z - Extent.Z}
                MapMax = {X = Location.X + Extent.X, Y = Location.Y + Extent.Y, Z = Location.Z + Extent.Z}
                Center = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
                RotatorZ = Box.Rotator.Z
            else
                --error
                FLOG_ERROR("PWorldMgr:LoadMapBlock shape is not Box")
            end

            local MapRange = {}
            MapRange.Min = MapMin
            MapRange.Max = MapMax

            local BlockCfg = {}
            BlockCfg.BlockID = BlockID
            BlockCfg.IsXYPlane = IsXYPlane
            BlockCfg.MapRange = MapRange
            BlockCfg.Level = Level
            BlockCfg.Center = Center
            BlockCfg.RotatorZ = RotatorZ

            table.insert(BlockCfgList, BlockCfg)
        end
    end

    return BlockCfgList
end

function NavigationPathMgr:TryGetMapBlockCfgList(MapID)
    for _, MapBlockData in ipairs(self.MapBlockCfgList) do
        if (MapBlockData.MapID == MapID) then
            return MapBlockData.BlockCfgList
        end
    end

    --未找到，构建
    local MapEditData = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if (MapEditData == nil) then
        FLOG_ERROR("MapEditCfg fild can't load by Mapid=%d", MapID)
        return nil
    end

    local BlockCfgList = self:BuildMapBlockCfg(MapEditData)
    return BlockCfgList
end

----------------地图块区域end-----------------

----------------动态地图bengin----------------
---校正动态地图ID，比如1071->1065
function NavigationPathMgr:RejustDynamicMap(MapID)
    local AllCfg = DynamicMapGroupCfg:FindAllCfg()
    if (#AllCfg == 0) then
        return MapID
    end

    local RejustMapID = MapID
    for _, ItemVale in ipairs(AllCfg) do
        if (table.contain(ItemVale.DMapList, MapID)) then
            RejustMapID = ItemVale.MapID
            break
        end
    end

    return RejustMapID
end

----------------动态地图end----------------

function NavigationPathMgr:GMTestRoadGraph(DstMapID, DstPos)
    if (DstMapID == 0) then
        DstMapID = 12001
        DstPos = {X = -2447, Y = -3004, Z = 8380}

        --DstMapID = 13002
        --DstPos = {X=-33325, Y=4532, Z=1262}

        --13002 -33325 4532 1262
    end

    --获取主角位置
    local Major = _G.UE.UActorManager:Get():GetMajor()
    if (Major ~= nil) then
        local MajorPos = Major:FGetActorLocation()
        local MapID = _G.PWorldMgr:GetCurrMapResID()

        FLOG_INFO(
            "GM TestRoadGraph: SrcMapID:%d, SrcPos:%s; DstMapID:%d, DstPos:%s",
            MapID,
            tostring(MajorPos),
            DstMapID,
            table.tostring(DstPos)
        )

        --self:GetTargetPosForTask(MapID, MajorPos, DstMapID, DstPos)

        self:FindPathsTest(MapID, MajorPos, DstMapID, DstPos)

        --self:FindPathsByNpcIDTest(MapID, MajorPos, 12001, 1001285)
    end
end

--条件是否有变化，有变化，缓存数据不可用
function NavigationPathMgr:CheckConditionChanged()
    local IsChanged = false

    for Key, Value in pairs(self.ConditionEnableDict) do
        local Result = ConditionMgr:CheckConditionByID(Key, nil, true)
        local IntReult = 0
        if (Result) then
            IntReult = 1
        end

        if (IntReult ~= Value) then
            IsChanged = true
            self.ConditionEnableDict[Key] = IntReult
        end
    end

    return IsChanged
end

------------------各系统提供接口-----------------
--任务系统
---@return Pos={X,Y,Z} or nil
function NavigationPathMgr:GetTargetPosForTask(SrcMapID, SrcPos, DstMapID, DstPos)
    local MapPaths = self:FindMapPaths(SrcMapID, SrcPos, DstMapID, DstPos)
    if (MapPaths == nil or #MapPaths == 0) then
        return nil
    end

    FLOG_INFO("NavigationPathMgr MapPath[1] is %s", table.tostring(MapPaths[1]))

    if (MapPaths[1].MapID == SrcMapID) then
        FLOG_INFO("NavigationPathMgr TargetPos=%s", table.tostring(MapPaths[1].Paths[1].EndPos))
        return MapPaths[1].Paths[1].EndPos
    end

    return nil
end

return NavigationPathMgr
