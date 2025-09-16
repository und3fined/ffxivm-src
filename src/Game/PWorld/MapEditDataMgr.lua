--
-- Author: haialexzhou
-- Date: 2021-12-23
-- Description:地图编辑数据管理器

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require ("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")


TargetLocationMapType = TargetLocationMapType or {
    CurMap = 1,         --本地图内查找到
    AdjacentMap = 2,    --相邻地图内查找到
    MoreThanOne = 3,    --相隔地图：跨1个地图以上
    None = 4,           --没有找到
}


---@class MapEditDataMgr : MgrBase
local MapEditDataMgr = LuaClass(MgrBase)

function MapEditDataMgr:OnInit()
    self.MapEditCfg = nil -- 当前关卡编辑器地图数据
    self.AdjacentMapEditCfgMap = {} -- 相邻地图的关卡编辑器地图数据
    self.OtherMapEditCfgMap = {}
    self.FestivalCfgMap = {}
end

function MapEditDataMgr:InitMapEditCfg(CurrMapEditCfg)
    self.MapEditCfg = CurrMapEditCfg
end

function MapEditDataMgr:GetMapEditCfg()
    return self.MapEditCfg
end

function MapEditDataMgr:InitAdjacentMapEditCfg(InAdjacentMapEditCfg)
    if InAdjacentMapEditCfg and InAdjacentMapEditCfg.MapID then
        self.AdjacentMapEditCfgMap[InAdjacentMapEditCfg.MapID] = InAdjacentMapEditCfg
    end
end

function MapEditDataMgr:ClearAdjacentMapEditCfg()
    self.AdjacentMapEditCfgMap = {}
end

function MapEditDataMgr:InitFestivalMapEditCfg(InFestivalMapEditCfg)
    if InFestivalMapEditCfg then
        self.FestivalCfgMap[InFestivalMapEditCfg.MapID] = InFestivalMapEditCfg
    end
end

function MapEditDataMgr:ClearFestivalMapEditCfg()
    self.FestivalCfgMap = {}
end

function MapEditDataMgr:InitOtherMapEditCfg(InOtherMapEditCfg)
    self:ClearOtherMapEditCfg() -- 只缓存最新加载的一个MapEditCfg，其他都清理，节省内存

    if InOtherMapEditCfg and InOtherMapEditCfg.MapID then
        self.OtherMapEditCfgMap[InOtherMapEditCfg.MapID] = InOtherMapEditCfg
    end
end

function MapEditDataMgr:ClearOtherMapEditCfg()
    self.OtherMapEditCfgMap = {}
end

function MapEditDataMgr:ClearOtherMapEditCfgByMapID(MapID)
    self.OtherMapEditCfgMap[MapID] = nil
end

function MapEditDataMgr:IsCurrOrAdjacentMap(MapID)
    if not self.MapEditCfg then return false end

    if MapID == self.MapEditCfg.MapID then return true end

    for AdjacentMapID, _ in pairs(self.AdjacentMapEditCfgMap) do
        if MapID == AdjacentMapID then
            return true
        end
    end

    return false
end

--获取传送点对应的目标副本ID
function MapEditDataMgr:GetPWorldIDByTransID(TransPointID)
    local TargetPWorldID = 0
    if (self.MapEditCfg == nil) then
        return TargetPWorldID
    end
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (TransPoint.ID == TransPointID) then
            if (#TransPoint.TransTargetList > 0) then
                local TransTarget = TransPoint.TransTargetList[1]
                if (TransTarget ~= nil) then
                    TargetPWorldID = TransTarget.TargetPWorldID
                end
            end

            break
        end
    end

    return TargetPWorldID
end


--获取绑定仇恨的怪物列表
function MapEditDataMgr:GetMonstersInSameTaunt(ListID)
    local MonsterList = {}
    if (self.MapEditCfg == nil) then
        return MonsterList
    end

    local MonGroupList = self.MapEditCfg.MonGroupList
    for _, MonGroup in ipairs(MonGroupList) do
        if (MonGroup.IsBindTaunt) then
            local bIsFound = false
            for _, Monster in ipairs(MonGroup.Monsters) do
                if (Monster.ListID == ListID) then
                    bIsFound = true
                    break
                end
            end

            if (bIsFound) then
                for _, Monster in ipairs(MonGroup.Monsters) do
                    if (Monster.ListID ~= ListID) then
                        table.insert(MonsterList, Monster.ListID)
                    end
                end
            end
        end
    end

    return MonsterList
end

--获取预警
function MapEditDataMgr:GetMapEarlyWarningGroup(WarningID)
    if (self.MapEditCfg == nil) then
        return nil
    end

    local EarlyWarningList = self.MapEditCfg.EarlyWarningList

    for _, EarlyWarningGroup in ipairs(EarlyWarningList) do
        if EarlyWarningGroup.ID == WarningID then
            return EarlyWarningGroup
        end
    end

    return nil
end

--获取怪物是否贴地
function MapEditDataMgr:GetMonsterIsAdjustFloor(ListID)
    if (self.MapEditCfg == nil) then
        return true
    end

    local MonsterList = self.MapEditCfg.MonsterList
    for _, Monster in ipairs(MonsterList) do
        if (Monster.ListID == ListID) then
            return Monster.IsAdjustFloor
        end
    end

    local MonGroupList = self.MapEditCfg.MonGroupList
    for _, MonGroup in ipairs(MonGroupList) do
        for _, Monster in ipairs(MonGroup.Monsters) do
            if (Monster.ListID == ListID) then
                return Monster.IsAdjustFloor
            end
        end
    end

    return true
end

function MapEditDataMgr:GetMonsterIsFindFloorBySweep(ListID)
    if (self.MapEditCfg == nil) then
        return false
    end

    local MonsterList = self.MapEditCfg.MonsterList
    for _, Monster in ipairs(MonsterList) do
        if (Monster.ListID == ListID) then
            return Monster.IsFindFloorBySweep
        end
    end

    local MonGroupList = self.MapEditCfg.MonGroupList
    for _, MonGroup in ipairs(MonGroupList) do
        for _, Monster in ipairs(MonGroup.Monsters) do
            if (Monster.ListID == ListID) then
                return Monster.IsFindFloorBySweep
            end
        end
    end

    return false
end

---通过ListID获取地图怪物
---@return MapMonster
function MapEditDataMgr:GetMonsterByListID(ListID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local MonsterList = MapEditCfg.MonsterList
    for _, Monster in ipairs(MonsterList) do
        if (Monster.ListID == ListID) then
            return Monster
        end
    end

    local MonGroupList = MapEditCfg.MonGroupList
    for _, MonGroup in ipairs(MonGroupList) do
        for _, Monster in ipairs(MonGroup.Monsters) do
            if (Monster.ListID == ListID) then
                return Monster
            end
        end
    end

    return nil
end

--通过ListID获取怪物组
function MapEditDataMgr:GetMonsterGroupByListID(ListID)
    if (self.MapEditCfg == nil) then
        return nil
    end

    local MonGroupList = self.MapEditCfg.MonGroupList
    for _, MonGroup in ipairs(MonGroupList) do
        if (MonGroup.ID == ListID) then
            return MonGroup
        end
    end

    return nil
end

function MapEditDataMgr:GetTriggerAction(ActionID)
    if (self.MapEditCfg == nil) then
        return nil
    end
    local EventGroupList = self.MapEditCfg.EventGroupList
    for _, EventGroup in ipairs(EventGroupList) do
        for _, Event in ipairs(EventGroup.EventList) do
            for _, Action in ipairs(Event.ActionList) do
               if (Action.ID == ActionID) then
                    return Action
               end
            end
        end
    end
    return nil
end

function MapEditDataMgr:GetMapMin()
    local MapMin = _G.UE.FVector(0.0, 0.0, 0.0)
    if (self.MapEditCfg == nil) then
        return MapMin
    end
    MapMin.X = self.MapEditCfg.MapMin.X
    MapMin.Y = self.MapEditCfg.MapMin.Y
    MapMin.Z = self.MapEditCfg.MapMin.Z
    return MapMin
end

function MapEditDataMgr:GetMapMax()
    local MapMax = _G.UE.FVector(0.0, 0.0, 0.0)
    if (self.MapEditCfg == nil) then
        return MapMax
    end
    MapMax.X = self.MapEditCfg.MapMax.X
    MapMax.Y = self.MapEditCfg.MapMax.Y
    MapMax.Z = self.MapEditCfg.MapMax.Z
    return MapMax
end

---@return MapPoint
function MapEditDataMgr:GetMapPoint(PointID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (PointID > 0 and MapEditCfg ~= nil) then
        local PointList = MapEditCfg.PointList
        for _, MapPoint in ipairs(PointList) do
            if (MapPoint.ID == PointID) then
                return MapPoint
            end
        end

        local PointGroupList = MapEditCfg.PointGroupList
        for _, MapPointGroup in ipairs(PointGroupList) do
            for _, MapPoint in ipairs(MapPointGroup.PointList) do
                if (MapPoint.ID == PointID) then
                    return MapPoint
                end
            end
        end
    end

    return nil
end

---根据ResID获取地图NPC
---@return MapNPC
function MapEditDataMgr:GetNpc(NpcID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local NpcList = MapEditCfg.NpcList
    for _, Npc in ipairs(NpcList) do
        if (Npc.NpcID == NpcID) then
            return Npc
        end
    end

    for _, EditCfg in pairs(self.FestivalCfgMap) do
        NpcList = EditCfg.NpcList
        for k,Npc in ipairs(NpcList) do
            if (Npc.NpcID == NpcID) then
                return Npc
            end
        end
    end

    return nil
end

---根据ListID获取地图NPC
---@return MapNPC
function MapEditDataMgr:GetNpcByListID(ListID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local NpcList = MapEditCfg.NpcList
    for _, Npc in ipairs(NpcList) do
        if (Npc.ListId == ListID) then
            return Npc
        end
    end
    return nil
end

---根据ResID获取地图采集物
---@return MapPickItem
function MapEditDataMgr:GetGatherByResID(ResID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local PickItemList = MapEditCfg.PickItemList
    for _, MapPickItem in ipairs(PickItemList) do
        if MapPickItem.ResID == ResID then
            return MapPickItem
        end
    end
    return nil
end

---根据ResID获取有效的地图采集物
---@return MapPickItem
function MapEditDataMgr:GetValidGatherByResID(ResID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local MapID = MapEditCfg.MapID
    local PickItemList = MapEditCfg.PickItemList
    for _, MapPickItem in ipairs(PickItemList) do
        if MapPickItem.ResID == ResID and _G.GatherMgr:IsRefreshed(MapPickItem.ListId, MapID) then
            return MapPickItem
        end
    end
    return nil
end

---@return MapArea
function MapEditDataMgr:GetArea(AreaID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local AreaList = MapEditCfg.AreaList
    for _, Area in ipairs(AreaList) do
        if (Area.ID == AreaID) then
            return Area
        end
    end
    return nil
end

function MapEditDataMgr:GetAreaPos(MapArea)
	if MapArea then
		local Box = MapArea.Box
		local Cylinder = MapArea.Cylinder
		local AreaLoc = nil
		if Box ~= nil and Cylinder == nil then
			AreaLoc = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
		elseif  Box == nil and Cylinder ~= nil then
			AreaLoc = _G.UE.FVector(Cylinder.Start.X, Cylinder.Start.Y, Cylinder.Start.Z)
		end

		return AreaLoc
	end

    return nil
end

function MapEditDataMgr:GetAreaSize(MapArea)
    if MapArea then
        local Box = MapArea.Box
        local Cylinder = MapArea.Cylinder
        if Box then
            return Box.Extent.X, Box.Extent.Y, Box.Extent.Z
        elseif Cylinder then
            return Cylinder.Radius, Cylinder.Radius, Cylinder.Height
        end
    end
    return 0,0,0
end

function MapEditDataMgr:GetAutoPlaySequencePath()
    if (self.MapEditCfg == nil) then
        return nil
    end
    local SequenceList = self.MapEditCfg.MapMovieSequenceList
    for _, CutSceneSequence in ipairs(SequenceList) do
        --每个地图只能有一个自动播放的sequence
        if (CutSceneSequence.IsAutoPlay) then
            return CutSceneSequence.SequencePath
        end
    end
    return nil
end

function MapEditDataMgr:GetPath(PathID)
    if (self.MapEditCfg == nil) then
        return nil
    end
    local PathList = self.MapEditCfg.PatrolPathList
    for _, Path in ipairs(PathList) do
        if (Path.ID == PathID) then
            return Path
        end
    end
    return nil
end

---根据ResID获取地图EObj
---@return MapEObj
function MapEditDataMgr:GetEObjByResID(ResID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local EObjList = MapEditCfg.EObjList
    for _, EObjData in ipairs(EObjList) do
        if EObjData.ResID == ResID then
            return EObjData
        end
    end
    return nil
end

---根据ListID获取地图EObj
---@return MapEObj
function MapEditDataMgr:GetEObjByListID(ListID, InMapEditCfg)
    local MapEditCfg = InMapEditCfg or self.MapEditCfg
    if (MapEditCfg == nil) then
        return nil
    end

    local EObjList = MapEditCfg.EObjList
    for _, EObjData in ipairs(EObjList) do
        if EObjData.ID == ListID then
            return EObjData
        end
    end
    return nil
end

--获取怪物列表
function MapEditDataMgr:GetMonsterResIDList(MonSubType, bClassify)
    local MonsterList = _G.UE.TArray(_G.UE.uint32)

    if (self.MapEditCfg == nil) then
        return MonsterList
    end
    local MonsterMapCounter = {}
    local MonsterCfg = require("TableCfg/MonsterCfg")

    if (bClassify == nil) then
        bClassify = true
    end

    local function SetMonsterResIDFlag(MonResID)
        if (MonsterMapCounter[MonResID] == nil) then
            local SubType = MonsterCfg:FindValue(MonResID, "SubType")
            if (MonSubType == SubType) then
                MonsterMapCounter[MonResID] = 1
            end
        elseif (not bClassify) then
            local Count = MonsterMapCounter[MonResID]
            Count = Count + 1
            MonsterMapCounter[MonResID] = Count
        end
    end

    local MonGroupList = self.MapEditCfg.MonGroupList
    for _, MonGroup in ipairs(MonGroupList) do
        for _, Monster in ipairs(MonGroup.Monsters) do
            SetMonsterResIDFlag(Monster.ID)
        end
    end
    local MonList = self.MapEditCfg.MonsterList
    for _, Monster in ipairs(MonList) do
        SetMonsterResIDFlag(Monster.ID)
    end

    if (ProtoRes.monster_sub_type.MONSTER_SUB_TYPE_BOSS == MonSubType) then
        local EventGroupList = self.MapEditCfg.EventGroupList
        for _, EventGroup in ipairs(EventGroupList) do
            local EventList = EventGroup.EventList
            for _, Event in ipairs(EventList) do
                local ActionList = Event.ActionList
                for _, Action in ipairs(ActionList) do
                    if (ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_SET_MONSTER_FACADE == Action.Type) then
                        local MonResIDStr = tostring(Action.Param2)
                        if (#MonResIDStr == 8) then
                            SetMonsterResIDFlag(Action.Param2)
                        end
                    end
                end
            end
        end
    end

    for MonResID, Count in pairs(MonsterMapCounter) do
        for i = 1, Count do
            MonsterList:Add(MonResID)
        end
    end

    return MonsterList
end

--获取场景中的npc列表，包括客户端npc
function MapEditDataMgr:GetNpcResIDList()
    local NpcList = {}

    if (self.MapEditCfg == nil) then
        return NpcList
    end

    for _, Npc in ipairs(self.MapEditCfg.NpcList) do
        table.insert(NpcList, Npc.NpcID)
    end

    return NpcList
end

function MapEditDataMgr:GetNpcCfgList()
    local NpcList = {}

    if (self.MapEditCfg == nil) then
        return NpcList
    end

    for _, Npc in ipairs(self.MapEditCfg.NpcList) do
        NpcList[Npc.NpcID] = Npc
    end

    return NpcList
end


--region 导航和浮标

function MapEditDataMgr:GetTransPointPos(TransPoint)
    if TransPoint then
        if TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_BOX then
            local Box = TransPoint.Box
            return _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
        elseif TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_CYLINDER then
            local Cylinder = TransPoint.Cylinder
            local Pos = Cylinder.Start
            return _G.UE.FVector(Pos.X, Pos.Y, Pos.Z)
        end
    end

    return nil
end

function MapEditDataMgr:GetAdjacentMapInfo(MapID)
    return self.AdjacentMapEditCfgMap[MapID]
end

function MapEditDataMgr:GetMapEditCfgByMapID(MapID)
    if self.MapEditCfg and self.MapEditCfg.MapID == MapID then
        return self.MapEditCfg

    elseif self.AdjacentMapEditCfgMap[MapID] then
        return self.AdjacentMapEditCfgMap[MapID]

    elseif self.OtherMapEditCfgMap[MapID] then
        return self.OtherMapEditCfgMap[MapID]

    else
        return nil
    end
end

---获取给定地图的关卡编辑数据，如果未找到就加载一次，扩展接口以简化外部使用
function MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapID == nil or MapID == 0 then
		return
	end

	local MapEditCfg = self:GetMapEditCfgByMapID(MapID)

    if (MapEditCfg == nil) then
        local _ <close> = CommonUtil.MakeProfileTag(string.format("LoadMapEditCfgByMapID_MapID_%d", MapID))
        _G.PWorldMgr:LoadMapEditCfgByMapID(MapID, "OnLoadOtherMapEditCfg")
        MapEditCfg = self:GetMapEditCfgByMapID(MapID)
    end

    if (MapEditCfg == nil) then
        _G.FLOG_ERROR("[MapEditDataMgr:GetMapEditCfgByMapIDEx] MapEditCfg nil, MapID=%d", MapID)
    end

	return MapEditCfg
end

function MapEditDataMgr:GetNearestTransPoint(MapID)
	local Major = MajorUtil.GetMajor()
    if Major == nil then return nil end
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	MajorPos = MajorPos + _G.PWorldMgr:GetWorldOriginLocation()

	local MinDist = 1999999999
    local NearestTransPoint = nil

    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        local TransPointNum = #TransPoint.TransTargetList
        if (TransPointNum > 0) then
            for index = 1, TransPointNum do
                local TransTarget = TransPoint.TransTargetList[index]
                if (TransTarget ~= nil) then
                    local TargetMapID = TransTarget.TargetMapID
                    if TargetMapID == MapID then
                        local TransPointPos = self:GetTransPointPos(TransPoint)
                        local Dist = _G.UE.FVector.Dist(MajorPos, TransPointPos)
                        if Dist < MinDist then
                            MinDist = Dist
                            NearestTransPoint = TransPoint
                        end
                    end
                end
            end
        end
    end

    return NearestTransPoint
end

function MapEditDataMgr:GetSelfExecuteActions()
    local ActionList = {}
    if (self.MapEditCfg == nil) then
        return ActionList
    end
    ActionList = self.MapEditCfg.InitActionList
    return ActionList
end

--从包括相邻地图中查找Map
function MapEditDataMgr:GetMapByAdjacentMap(MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
        return TargetLocationMapType.CurMap, true
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local TransPos = self:GetTransPointPos(NearestTransPoint)
            return TargetLocationMapType.AdjacentMap, true, TransPos
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

--从包括相邻地图中查找Npc
function MapEditDataMgr:GetNpcIncludeAdjacentMap(NpcID, MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
        local NpcInfo = self:GetNpc(NpcID)
        if NpcInfo then
            FLOG_INFO("GetNpc:%d in curmap", NpcID)
            return TargetLocationMapType.CurMap, NpcInfo
        end
    end

    local function ExecFun(ParamNpcID, ParamMapID)
        local MapEditCfg = self.AdjacentMapEditCfgMap[ParamMapID]
        if MapEditCfg then
            local NpcList = MapEditCfg.NpcList
            for _, Npc in ipairs(NpcList) do
                if (Npc.NpcID == ParamNpcID) then
                    FLOG_INFO("GetNpc:%d in AdjacentMap:%d", NpcID, ParamMapID)
                    return Npc
                end
            end
        else
            FLOG_ERROR("AdjacentMap %d dont Preloaded!", ParamMapID)
        end

        return nil
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local Npc = ExecFun(NpcID, MapID)
            if Npc then
                local TransPos = self:GetTransPointPos(NearestTransPoint)
                return TargetLocationMapType.AdjacentMap, Npc, TransPos
            end
        end
    end

    --没传地图id，找到后就return
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local TargetMapID = TransTarget.TargetMapID
                local Npc = ExecFun(NpcID, TargetMapID)
                if Npc then
                    local TransPos = self:GetTransPointPos(TransPoint)
                    return TargetLocationMapType.AdjacentMap, Npc, TransPos, TargetMapID
                end
            end
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

--从包括相邻地图中查找Area
function MapEditDataMgr:GetAreaByAdjacentMap(AreaID, MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
        local AreaInfo = self:GetArea(AreaID)
        if AreaInfo then
            FLOG_INFO("GetArea:%d in curmap", AreaID)
            return TargetLocationMapType.CurMap, AreaInfo
        end
    end

    local function ExecFun(ParamAreaID, ParamMapID)
        local MapEditCfg = self.AdjacentMapEditCfgMap[ParamMapID]
        if MapEditCfg then
            local AreaList = MapEditCfg.AreaList
            for _, Area in ipairs(AreaList) do
                if (Area.ID == ParamAreaID) then
                    FLOG_INFO("GetArea:%d in AdjacentMap:%d", ParamAreaID, ParamMapID)
                    return Area
                end
            end
        else
            FLOG_ERROR("AdjacentMap %d dont Preloaded!", ParamMapID)
        end

        return nil
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local Area = ExecFun(AreaID, MapID)
            if Area then
                local TransPos = self:GetTransPointPos(NearestTransPoint)
                return TargetLocationMapType.AdjacentMap, Area, TransPos
            end
        end
    end

    --没传地图id，找到后就return
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local TargetMapID = TransTarget.TargetMapID
                local Area = ExecFun(AreaID, TargetMapID)
                if Area then
                    local TransPos = self:GetTransPointPos(TransPoint)
                    return TargetLocationMapType.AdjacentMap, Area, TransPos, TargetMapID
                end
            end
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

--从包括相邻地图中查找点
function MapEditDataMgr:GetPointByAdjacentMap(PointID, MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
        local PointInfo = self:GetMapPoint(PointID)
        if PointInfo then
            FLOG_INFO("GetPoint:%d in curmap", PointID)
            return TargetLocationMapType.CurMap, PointInfo
        end
    end

    local function ExecFun(ParamPointID, ParamMapID)
        local MapEditCfg = self.AdjacentMapEditCfgMap[ParamMapID]
        if MapEditCfg then
            local PointList = MapEditCfg.PointList
            for _, MapPoint in ipairs(PointList) do
                if (MapPoint.ID == ParamPointID) then
                    FLOG_INFO("GetPoint:%d in AdjacentMap:%d", ParamPointID, ParamMapID)
                    return MapPoint
                end
            end

            local PointGroupList = MapEditCfg.PointGroupList
            for _, MapPointGroup in ipairs(PointGroupList) do
                for _, MapPoint in ipairs(MapPointGroup.PointList) do
                    if (MapPoint.ID == ParamPointID) then
                        FLOG_INFO("GetPoint:%d in AdjacentMap:%d", ParamPointID, ParamMapID)
                        return MapPoint
                    end
                end
            end
        else
            FLOG_ERROR("AdjacentMap %d dont Preloaded!", ParamMapID)
        end

        return nil
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local MapPoint = ExecFun(PointID, MapID)
            if MapPoint then
                local TransPos = self:GetTransPointPos(NearestTransPoint)
                return TargetLocationMapType.AdjacentMap, MapPoint, TransPos
            end
        end
    end

    --没传地图id，找到后就return
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local TargetMapID = TransTarget.TargetMapID
                local MapPoint = ExecFun(PointID, TargetMapID)
                if MapPoint then
                    local TransPos = self:GetTransPointPos(TransPoint)
                    return TargetLocationMapType.AdjacentMap, MapPoint, TransPos, TargetMapID
                end
            end
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

--从包括相邻地图中查找怪物
function MapEditDataMgr:GetMonsterByAdjacentMap(ListID, MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
        local MonsterInfo = self:GetMonsterByListID(ListID)
        if MonsterInfo then
            FLOG_INFO("GetMonster:%d in curmap", ListID)
            return TargetLocationMapType.CurMap, MonsterInfo
        end
    end

    local function ExecFun(ParamMonsterListID, ParamMapID)
        local MapEditCfg = self.AdjacentMapEditCfgMap[ParamMapID]
        if not MapEditCfg then
            FLOG_ERROR("AdjacentMap %d dont Preloaded!", ParamMapID)
            return nil
        end

        local MonsterList = MapEditCfg.MonsterList
        for _, Monster in ipairs(MonsterList) do
            if (Monster.ListID == ParamMonsterListID) then
                FLOG_INFO("GetMonster:%d in AdjacentMap:%d", ParamMonsterListID, ParamMapID)
                return Monster
            end
        end

        local MonGroupList = MapEditCfg.MonGroupList
        for _, MonGroup in ipairs(MonGroupList) do
            for _, Monster in ipairs(MonGroup.Monsters) do
                if (Monster.ListID == ParamMonsterListID) then
                    FLOG_INFO("GetMonster:%d in AdjacentMap:%d", ParamMonsterListID, ParamMapID)
                    return Monster
                end
            end
        end

        return nil
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local Monster = ExecFun(ListID, MapID)
            if Monster then
                local TransPos = self:GetTransPointPos(NearestTransPoint)
                return TargetLocationMapType.AdjacentMap, Monster, TransPos
            end
        end
    end

    --没传地图id，找到后就return
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local TargetMapID = TransTarget.TargetMapID
                local Monster = ExecFun(ListID, TargetMapID)
                if Monster then
                    local TransPos = self:GetTransPointPos(TransPoint)
                    return TargetLocationMapType.AdjacentMap, Monster, TransPos, TargetMapID
                end
            end
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

--从包括相邻地图中查找怪物组
function MapEditDataMgr:GetMonsterGroupByAdjacentMap(ListID, MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
        local MonGroupInfo = self:GetMonsterGroupByListID(ListID)
        if MonGroupInfo then
            FLOG_INFO("GetMonsterGroup:%d in curmap", ListID)
            return TargetLocationMapType.CurMap, MonGroupInfo
        end
    end

    local function ExecFun(ParamMonGroupListID, ParamMapID)
        local MapEditCfg = self.AdjacentMapEditCfgMap[ParamMapID]
        if not MapEditCfg then
            FLOG_ERROR("AdjacentMap %d dont Preloaded!", ParamMapID)
            return nil
        end

        local MonGroupList = MapEditCfg.MonGroupList
        for _, MonGroup in ipairs(MonGroupList) do
            if (MonGroup.ID == ParamMonGroupListID) then
                FLOG_INFO("GetMonsterGroup:%d in AdjacentMap:%d", ParamMonGroupListID, ParamMapID)
                return MonGroup
            end
        end

        return nil
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local MonGroup = ExecFun(ListID, MapID)
            if MonGroup then
                local TransPos = self:GetTransPointPos(NearestTransPoint)
                return TargetLocationMapType.AdjacentMap, MonGroup, TransPos
            end
        end
    end

    --没传地图id，找到后就return
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local TargetMapID = TransTarget.TargetMapID
                local MonGroup = ExecFun(ListID, TargetMapID)
                if MonGroup then
                    local TransPos = self:GetTransPointPos(TransPoint)
                    return TargetLocationMapType.AdjacentMap, MonGroup, TransPos, TargetMapID
                end
            end
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

--从包括相邻地图中查找EObj
function MapEditDataMgr:GetEObjIncludeAdjacentMap(EObjID, MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
        local EObjInfo = self:GetEObjByResID(EObjID)
        if EObjInfo then
            FLOG_INFO("GetEObj:%d in curmap", EObjID)
            return TargetLocationMapType.CurMap, EObjInfo
        end
    end

    local function ExecFun(ParamEObjID, ParamMapID)
        local MapEditCfg = self.AdjacentMapEditCfgMap[ParamMapID]
        if MapEditCfg then
            local EObjList = MapEditCfg.EObjList
            for _, EObj in ipairs(EObjList) do
                if (EObj.ResID == ParamEObjID) then
                    FLOG_INFO("GetEObj:%d in AdjacentMap:%d", EObjID, ParamMapID)
                    return EObj
                end
            end
        else
            FLOG_ERROR("AdjacentMap %d dont Preloaded!", ParamMapID)
        end

        return nil
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local EObj = ExecFun(EObjID, MapID)
            if EObj then
                local TransPos = self:GetTransPointPos(NearestTransPoint)
                return TargetLocationMapType.AdjacentMap, EObj, TransPos
            end
        end
    end

    --没传地图id，找到后就return
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local TargetMapID = TransTarget.TargetMapID
                local EObj = ExecFun(EObjID, TargetMapID)
                if EObj then
                    local TransPos = self:GetTransPointPos(TransPoint)
                    return TargetLocationMapType.AdjacentMap, EObj, TransPos, TargetMapID
                end
            end
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")

--从包括相邻地图中查找水晶
function MapEditDataMgr:GetCrystalIncludeAdjacentMap(CrystalID, MapID)
    if (self.MapEditCfg == nil) then
        return TargetLocationMapType.None, nil
    end

    if not MapID or MapID == self.MapEditCfg.MapID then
		local Crystal = CrystalPortalMgr:GetCrystalByEntityId(CrystalID)
		if Crystal ~= nil then
            FLOG_INFO("GetCrystal:%d in curmap", CrystalID)
            return TargetLocationMapType.CurMap, Crystal
		end
	end

    local function ExecFun(ParamCrystalID, ParamMapID)
		local TCCfg = TeleportCrystalCfg:FindCfgByKey(ParamCrystalID)
		if TCCfg == nil then return nil end

        local MapEditCfg = self.AdjacentMapEditCfgMap[ParamMapID]
        if MapEditCfg then
            if TCCfg.MapID == MapEditCfg.MapID then
                FLOG_INFO("GetCrystal:%d in AdjacentMap:%d", ParamCrystalID, ParamMapID)
                return TCCfg
            end
        else
            FLOG_ERROR("AdjacentMap %d dont Preloaded!", ParamMapID)
        end

        return nil
    end

    --传地图id，就找最近一个
    if MapID and MapID > 0 then
        local NearestTransPoint = self:GetNearestTransPoint(MapID)
        if NearestTransPoint then
            local CrystalCfg = ExecFun(CrystalID, MapID)
            if CrystalCfg then
                local TransPos = self:GetTransPointPos(NearestTransPoint)
                return TargetLocationMapType.AdjacentMap, CrystalCfg, TransPos
            end
        end
    end

    --没传地图id，找到后就return
    local TransPointList = self.MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local TargetMapID = TransTarget.TargetMapID
                local CrystalCfg = ExecFun(CrystalID, TargetMapID)
                if CrystalCfg then
                    local TransPos = self:GetTransPointPos(TransPoint)
                    return TargetLocationMapType.AdjacentMap, CrystalCfg, TransPos, TargetMapID
                end
            end
        end
    end

    return TargetLocationMapType.MoreThanOne, nil
end

--endregion 导航和浮标


-- 关卡数据内存测试
function MapEditDataMgr:TestMapEditCfgMemory()
    local TotalMemory = 0
    local MaxMemoryOneCfg = 0
    local MaxMemoryOneCfgMapID = 0
    local MaxDeltaMemory = 0
    local MaxDeltaMemoryMapID = 0

    local MapEditCfgKeepFieldList =
    {
        ["MonsterList"] = 1,
        ["MonGroupList"] = 1,
        ["NpcList"] = 1,
        ["PickItemList"] = 1,
        ["EObjList"] = 1,
        ["PointList"] = 1,
        ["PointGroupList"] = 1,
        ["AreaList"] = 1,
    }

    local PositionFieldList =
    {
        ["id"] = 1,
        ["listid"] = 1,
        ["resid"] = 1,
        ["npcid"] = 1,
        ["BirthPoint"] = 1,
        ["BirthDir"] = 1,
        ["point"] = 1,
        ["dir"] = 1,
        --["Box"] = 1,
        --["Cylinder"] = 1,
    }

    local MapCfg = require("TableCfg/MapCfg")
    local AllMapCfg = MapCfg:FindAllCfg()
    for _, MapInfo in pairs(AllMapCfg) do
        local MapID = MapInfo.ID
        if MapID >= 11001 and MapID <= 15004 then
            collectgarbage("collect")
            collectgarbage("collect")
            collectgarbage("collect")
            local LuaMem1 = collectgarbage("count")

            self:GetMapEditCfgByMapIDEx(MapID)

            local LuaMem2 = collectgarbage("count")
            local LoadMemory = (LuaMem2 - LuaMem1)
            if LoadMemory > 0 then
                TotalMemory = TotalMemory + LoadMemory
            end
            if LoadMemory > MaxMemoryOneCfg then
                MaxMemoryOneCfg = LoadMemory
                MaxMemoryOneCfgMapID = MapID
            end

            collectgarbage("collect")
            collectgarbage("collect")
            collectgarbage("collect")
            local LuaMem3 = collectgarbage("count")

            local MapEditCfg = self.OtherMapEditCfgMap[MapID]
            for CfgField, MapItemList in pairs(MapEditCfg or {}) do
                if MapEditCfgKeepFieldList[CfgField] == nil then
                    MapEditCfg[CfgField] = nil
                else
                    if CfgField == "AreaList" or CfgField == "MonGroupList" or CfgField == "PointGroupList" then
                        -- Area的字段都保留
                    else
                        for _, MapItem in pairs(MapItemList) do
                            for ItemField, value2 in pairs(MapItem) do
                                if PositionFieldList[ItemField] ~= nil or PositionFieldList[string.lower(ItemField)] ~= nil then
                                    -- 保留字段
                                else
                                    MapItem[ItemField] = nil
                                end
                            end
                        end
                    end
                end
            end

            collectgarbage("collect")
            collectgarbage("collect")
            collectgarbage("collect")
            local LuaMem4 = collectgarbage("count")
            local DeltaMemory = LuaMem3 - LuaMem4
            if DeltaMemory > MaxDeltaMemory then
                MaxDeltaMemory = DeltaMemory
                MaxDeltaMemoryMapID = MapID
            end

            print("memory: ", MapID, MapInfo.MapEditFile, MapInfo.DisplayName, LoadMemory, DeltaMemory)
        end
    end

    print("TotalMemory xxM: ", TotalMemory / 1024)
    print("MaxMemoryOneCfg", MaxMemoryOneCfg, MaxMemoryOneCfgMapID)
    print("MaxDeltaMemory", MaxDeltaMemory, MaxDeltaMemoryMapID)
end


return MapEditDataMgr