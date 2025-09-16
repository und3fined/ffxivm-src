--
-- Author: haialexzhou
-- Date: 2021-9-16
-- Description:地图副本动态数据管理
--需要后台存储状态的数据，比如玩家中途进入游戏，需要读取最新状态

local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local ProtoRes = require ("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local MapDyneffectCfg = require("TableCfg/MapDyneffectCfg")
local DynDataObstacleBox = require("Game/PWorld/DynData/DynDataObstacleBox")
local DynDataObstacleRing = require("Game/PWorld/DynData/DynDataObstacleRing")
local DynDataEffect = require("Game/PWorld/DynData/DynDataEffect")
local DynDataArea = require("Game/PWorld/DynData/DynDataArea")
local DynDataLineVfx = require("Game/PWorld/DynData/DynDataLineVfx")
local DynDataTransDoor = require("Game/PWorld/DynData/DynDataTransDoor")
local DynDataTransArea = require("Game/PWorld/DynData/DynDataTransArea")
local DynDataTransArray = require("Game/PWorld/DynData/DynDataTransArray")
local DynDataMapSequence = require("Game/PWorld/DynData/DynDataMapSequence")
local DynDataCutSceneSequence = require("Game/PWorld/DynData/DynDataCutSceneSequence")
local DynDataFactory = require("Game/PWorld/DynData/DynDataFactory")
local AudioUtil = require("Utils/AudioUtil")
local NaviDecalMgr = require("Game/Navi/NaviDecalMgr")

local WeatherMgr = _G.WeatherMgr

local DynObstacleBoxParam = LuaClass()

local Cache_Map = _G.UE.EObjectGC.Cache_Map
local EBGMChannel = _G.UE.EBGMChannel
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local ContentSgMgr = _G.UE.UContentSgMgr

function DynObstacleBoxParam:Ctor()
    self.ID = 0
    self.Location = nil
    self.Extent = nil
    self.Rotator = nil
end

local DynDataCache = LuaClass()
function DynDataCache:Ctor()
    self.ID = 0
    self.State = nil
    self.DataType = nil
end

---@class PWorldDynDataMgr
---@field MapDynDatas DynDataBase[]
local PWorldDynDataMgr = {}

function PWorldDynDataMgr:Init()
    self.MapDynDatas = {}
    self.MapCachedDynDatas = {}
    self.DefaultWeatherName = nil
    self.WeatherSequenceControllerActors = nil

    self:LoadDynData()

    self.bDynDataLoaded = true
    self:PostLoadDynData()
end

function PWorldDynDataMgr:Reset()
    if (self.MapDynDatas ~= nil) then
        for _, DynData in ipairs(self.MapDynDatas) do
            DynData:Destroy()
        end
    end

    self.bDynDataLoaded = false

    self.MapDynDatas = {}
    self.MapCachedDynDatas = {}
    self.WeatherSequenceControllerActors = nil
    
    _G.MapAreaMgr:Reset()
end

function PWorldDynDataMgr:IsInited()
    if (self.MapDynDatas ~= nil and next(self.MapDynDatas) ~= nil) then
        return true
    end

    return false
end

function PWorldDynDataMgr:LoadDynData()
    local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if (CurrMapEditCfg == nil) then
        return
    end

    --传送门
    self:LoadTransDoor(CurrMapEditCfg)
    self:LoadTransArea(CurrMapEditCfg)
    --区域
    self:LoadMapArea(CurrMapEditCfg)
    --动态阻挡
    self:LoadObstacle(CurrMapEditCfg)
    --蓝图动态物件
    self:LoadEffect(CurrMapEditCfg)
    --LevelSequencer
    self:LoadMapSequence(CurrMapEditCfg)
    self:LoadBGMusic(CurrMapEditCfg)
    self:LoadDefaultWeather(CurrMapEditCfg)
    self:LoadCutSceneSequence(CurrMapEditCfg)   
end

function PWorldDynDataMgr:PostLoadDynData()
    if self.bCheckReconnectAutoPlay then
        _G.PWorldMgr:CheckReconnectAutoPlayBeforeReady()
        self.bCheckReconnectAutoPlay = false
    end
end

function PWorldDynDataMgr:LoadDynDataAfterLoadWorldFinish()
    local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if (CurrMapEditCfg == nil) then
        return
    end
    self:LoadMapAreaRange(CurrMapEditCfg)
end

function PWorldDynDataMgr:LoadTransDoor(CurrMapEditCfg)
    local TransPointList = CurrMapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        local MapDynEffect = nil
        if (TransPoint.EffectID > 0) then
            MapDynEffect = MapDyneffectCfg:FindCfgByKey(TransPoint.EffectID)
        end
        local TransDoorObj = nil
        if (TransPoint.Type == ProtoRes.trans_type.TRANS_TYPE_DOOR or TransPoint.Type == ProtoRes.trans_type.TRANS_TYPE_LEAVE) then
            TransDoorObj = DynDataTransDoor.New()
            if (TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_BOX) then
                TransDoorObj:CreateBoxTrigger(TransPoint.Box)

            elseif (TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_CYLINDER) then
                TransDoorObj:CreateCylinderTrigger(TransPoint.Cylinder)
            end
            TransDoorObj.TransType = TransPoint.Type

        elseif (TransPoint.Type == ProtoRes.trans_type.TRANS_TYPE_ARRAY) then
            TransDoorObj = DynDataTransArray.New()
            --传送阵都是圆柱
            if (TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_CYLINDER) then
                local Cylinder = TransPoint.Cylinder
                local Pos = Cylinder.Start
                TransDoorObj.Location = _G.UE.FVector(Pos.X, Pos.Y, Pos.Z)
            end
        end

        if (MapDynEffect == nil and TransDoorObj ~= nil and TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_CYLINDER) then
            MapDynEffect = MapDyneffectCfg:FindCfgByKey(TransDoorObj.DefaultEffectID)
        end

        if (TransDoorObj ~= nil) then
            if (MapDynEffect ~= nil and (MapDynEffect.EffectPath ~= "" or TransPoint.EffectID == 11)) then
                TransDoorObj.EffectPath = MapDynEffect.EffectPath
                TransDoorObj.EffectID = TransPoint.EffectID
                
                if (TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_CYLINDER) then
                    local Scale = 1.0
                    if (MapDynEffect.Size > 0) then
                        Scale = TransPoint.Cylinder.Radius / (MapDynEffect.Size / 2)
                    end
                    TransDoorObj.EffectScale = _G.UE.FVector(Scale, Scale, 1.0)
    
                elseif (TransPoint.ShapeType == ProtoRes.trans_shape_type.TRANS_SHAPE_TYPE_BOX) then
                    local Scale = 1.0
                    if (MapDynEffect.Size > 0) then
                        Scale = (TransPoint.Box.Extent.X * 2) / MapDynEffect.Size
                    end
                    TransDoorObj.EffectScale = _G.UE.FVector(Scale, 1.0, 1.0)
                end
            end

            TransDoorObj.ID = TransPoint.ID
            TransDoorObj.State = TransPoint.IsHide and 0 or 1

            table.insert(self.MapDynDatas, TransDoorObj)
        end
    end
end

function PWorldDynDataMgr:LoadTransArea(CurrMapEditCfg)
    --加载传送区域
    local AreaList = CurrMapEditCfg.AreaList
    for _, Area in ipairs(AreaList) do
        if Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_EXIT then
            local TransDoorArea = DynDataTransArea.New()
            if (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX) then
                TransDoorArea:CreateBoxTrigger(Area.Box)
            elseif (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER) then
                TransDoorArea:CreateCylinderTrigger(Area.Cylinder)
            end

            if (TransDoorArea ~= nil) then
                TransDoorArea.ID = Area.ID
                TransDoorArea.State = 1
                TransDoorArea:UpdateState()
                table.insert(self.MapDynDatas, TransDoorArea)
            end
        end
    end
    --加载特效线
    local LineVfxList = CurrMapEditCfg.LineVfxList
    if LineVfxList ~= nil then
        for _, LineVfx in ipairs(LineVfxList) do
            local TransLineVfx = DynDataLineVfx.New()
    
            if (TransLineVfx ~= nil) then
                TransLineVfx.ID = LineVfx.ID
                TransLineVfx:CreateBox(LineVfx.Box)
    
                TransLineVfx.State = 1
                TransLineVfx:UpdateState()
                table.insert(self.MapDynDatas, TransLineVfx)
            end
        end
    end
end

function PWorldDynDataMgr:LoadMapArea(CurrMapEditCfg)
    local AreaList = CurrMapEditCfg.AreaList
    for _, Area in ipairs(AreaList) do
        if Area.FuncType ~= ProtoRes.area_func_type.AREA_FUNC_TYPE_QUEST and    -- 任务相关由任务事件触发创建
           Area.FuncType ~= ProtoRes.area_func_type.AREA_FUNC_TYPE_EXIT  and    -- 退出区域通过传送门创建
           Area.FuncType ~= ProtoRes.area_func_type.AREA_FUNC_TYPE_POP and      -- 弹出区域客户端目前用不到
           Area.FuncType ~= ProtoRes.area_func_type.AREA_FUNC_TYPE_MAPBLOCK and    -- 地图区块单独处理
           Area.FuncType ~= ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP then     -- MapRange等major create后创建
            local DynArea = self:LoadSingleMapArea(Area)
            if (DynArea ~= nil) then
                table.insert(self.MapDynDatas, DynArea)
            end
        end
    end
end

function PWorldDynDataMgr:LoadMapAreaRange(CurrMapEditCfg)
    local AreaList = CurrMapEditCfg.AreaList
    for _, Area in ipairs(AreaList) do
        if Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP then
            local DynArea = self:LoadSingleMapArea(Area)
            if (DynArea ~= nil) then
                table.insert(self.MapDynDatas, DynArea)
            end
        end
    end
end

function PWorldDynDataMgr:LoadSingleMapArea(Area)
    --其他形状的区域客户端暂不处理
    if (Area.ShapeType ~= ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX and Area.ShapeType ~= ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER) then
        return nil
    end

    local DynArea = DynDataFactory:CreateArea(Area.ID, Area.FuncType)
    DynArea.ID = Area.ID
    DynArea.Priority = Area.Priority
    if (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX) then
        DynArea:CreateBoxTrigger(Area.Box)
    elseif (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER) then
        DynArea:CreateCylinderTrigger(Area.Cylinder)
    end
    DynArea.State = Area.IsHide and 0 or 1
    DynArea.AreaFuncType = Area.FuncType
    if (DynArea.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_QUEST) then
        DynArea.FuncData = Area.Quest

        if DynArea.FuncData ~= nil and DynArea.FuncData.ShowQuestFX
           and (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER) and (DynArea.Radius > 0) then
            DynArea:PlayQuestAreaEffect()
        end

    elseif (DynArea.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP) then
        DynArea.FuncData = Area.Map
    elseif (DynArea.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_GIMMICK) then
        DynArea.FuncData = Area.Gimmick
    elseif (DynArea.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_NORMAL) then
        DynArea.FuncData = Area.Normal        
    end

    return DynArea
end

function PWorldDynDataMgr:LoadObstacle(CurrMapEditCfg)
    local ObstacleList = CurrMapEditCfg.ObstacleList
    for _, Obstacle in ipairs(ObstacleList) do
        local MapDynEffect = nil
        local MapDynNoBlockEffect = nil
        if (Obstacle.EffectID > 0) then
            MapDynEffect = MapDyneffectCfg:FindCfgByKey(Obstacle.EffectID)
        end
        if (Obstacle.NoBlockEffectID ~= nil and Obstacle.NoBlockEffectID > 0) then
            MapDynNoBlockEffect = MapDyneffectCfg:FindCfgByKey(Obstacle.NoBlockEffectID)
        end

        if (Obstacle.Type == ProtoRes.dyn_obstacle_type.OBSTACLE_TYPE_BOX) then
            local ObstacleBox = DynDataObstacleBox.New()
            ObstacleBox.ID = Obstacle.ID
            if (MapDynEffect == nil) then
                MapDynEffect = MapDyneffectCfg:FindCfgByKey(ObstacleBox.DefaultEffectID)
            end

            if (MapDynNoBlockEffect == nil) then
                MapDynNoBlockEffect = MapDyneffectCfg:FindCfgByKey(ObstacleBox.DefaultNoBlockEffectID)
            end

            if (MapDynEffect ~= nil and MapDynEffect.EffectPath ~= "") then
                ObstacleBox.EffectPath = MapDynEffect.EffectPath
                ObstacleBox.EffectBaseSize = MapDynEffect.Size
            end

            if (MapDynNoBlockEffect ~= nil and MapDynNoBlockEffect.EffectPath ~= "") then
                ObstacleBox.EffectPathNoBlock = MapDynNoBlockEffect.EffectPath
                ObstacleBox.EffectNoBlockBaseSize = MapDynNoBlockEffect.Size
            end

            for j, Box in ipairs(Obstacle.ObstacleBoxs) do
                local Center = Box.Center
                local Extent = Box.Extent
                local Rotator = Box.Rotator
                local ObstacleBoxParam = DynObstacleBoxParam.New()
                ObstacleBoxParam.ID = j + 1
                ObstacleBoxParam.Extent = _G.UE.FVector(Extent.X, Extent.Y, Extent.Z)
                ObstacleBoxParam.Location = _G.UE.FVector(Center.X, Center.Y, Center.Z)
                ObstacleBoxParam.Rotator = _G.UE.FRotator(Rotator.Y, Rotator.Z, Rotator.X)
                table.insert(ObstacleBox.ObstacleBoxList, ObstacleBoxParam)
            end
            ObstacleBox.bIsHideEffect = Obstacle.IsHideEffect
            ObstacleBox.State = Obstacle.IsHide and 0 or 1
            table.insert(self.MapDynDatas, ObstacleBox)

        elseif (Obstacle.Type == ProtoRes.dyn_obstacle_type.OBSTACLE_TYPE_RING) then
            local ObstacleRing = DynDataObstacleRing.New()
            ObstacleRing.ID = Obstacle.ID
            if (MapDynEffect ~= nil and MapDynEffect.EffectPath ~= "") then
                ObstacleRing.EffectPath = MapDynEffect.EffectPath
                ObstacleRing.EffectBaseSize = MapDynEffect.Size
            end
            local Ring = Obstacle.ObstacleRing
            ObstacleRing.OuterRadius = Ring.OuterRadius
            ObstacleRing.InnerRadius = Ring.InnerRadius
            ObstacleRing.Height = Ring.Height
            local Center = Ring.Start
            ObstacleRing.Location = _G.UE.FVector(Center.X, Center.Y, Center.Z)
            ObstacleRing.bIsHideEffect = Obstacle.IsHideEffect
            ObstacleRing.State = Obstacle.IsHide and 0 or 1
            table.insert(self.MapDynDatas, ObstacleRing)
        end

    end
end

function PWorldDynDataMgr:LoadEffect(CurrMapEditCfg)
    local AllDynamicAssets = _G.UE.TArray(_G.UE.AMapDynamicAssetBase)
    _G.UE.UGameplayStatics.GetAllActorsOfClass(FWORLD(), _G.UE.AMapDynamicAssetBase.StaticClass(), AllDynamicAssets)
    local DynamicAssetCnt = AllDynamicAssets:Length()
    local EDynamicAssetType = _G.UE.EMapDynamicAssetType
    local EMapDynamicAssetFuncType = _G.UE.EMapDynamicAssetFuncType
    for i = 1, DynamicAssetCnt, 1 do
        local DynamicAsset = AllDynamicAssets:Get(i)
        if (EDynamicAssetType.MapDynamicAssetType_Effect == DynamicAsset.DynamicAssetType
            or EMapDynamicAssetFuncType.MapDynamicAssetFuncType_Effect == DynamicAsset.DynamicAssetFuncType) then
            local DynEffectObj = DynDataEffect.New()
            DynEffectObj.ID = DynamicAsset.ID
            DynEffectObj.MapDynamicAssetModel = DynamicAsset
            table.insert(self.MapDynDatas, DynEffectObj)
        end
    end

    local AllSgActors = _G.UE.TArray(_G.UE.ASgLayoutActorBase)
    _G.UE.UGameplayStatics.GetAllActorsOfClass(FWORLD(), _G.UE.ASgLayoutActorBase.StaticClass(), AllSgActors)
    local AllSgCnt = AllSgActors:Length()
    for i = 1, AllSgCnt, 1 do
        local SgActor = AllSgActors:Get(i)
        local DynEffectObj = DynDataEffect.New()
        DynEffectObj.ID = SgActor.ID
        DynEffectObj.MapDynamicAssetModel = SgActor
        table.insert(self.MapDynDatas, DynEffectObj)
    end
end

function PWorldDynDataMgr:LoadMapSequence(CurrMapEditCfg)
    local SequenceList = CurrMapEditCfg.SequenceList
    local World = FWORLD()
    local SegConfig = _G.UE.TMap(_G.UE.int32, _G.UE.int32)
    for _, Sequence in ipairs(SequenceList) do
        local MapSequenceObj = DynDataMapSequence.New()
        MapSequenceObj.ID = Sequence.ID
        MapSequenceObj:CreateSequenceController(World)
        if (MapSequenceObj.MapSequenceController ~= nil) then
            SegConfig:Clear()
            for _, Value in ipairs(Sequence.SegmentConfig) do
                SegConfig:Add(Value.Segment, Value.LoopCount)
            end
            MapSequenceObj.MapSequenceController:InitFromConfig(World,
                Sequence.SequencePath, SegConfig)
            MapSequenceObj:ReadyToPlay()
        end

        table.insert(self.MapDynDatas, MapSequenceObj)
    end
end

function PWorldDynDataMgr:StopCurrBGMusic()
    local UAudioMgr = _G.UE.UAudioMgr.Get()
    if self.CurrBGMSceneID then
        self.CurrBGMSceneID = nil
        self.CurrBGMName = nil
        UAudioMgr:StopSceneBGM()
    end
end

function PWorldDynDataMgr:LoadBGMusic(CurrMapEditCfg)
    local MapID = CurrMapEditCfg.MapID
    if (MapID == 0) then
		return
	end
    local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(MapID)
	if (MapTableCfg == nil) then
		return
	end

    self:LoadBGSound(MapTableCfg)

    self.MapBGMusic = MapTableCfg.BGMusic

    local QuestRequiredMapBGM = _G.QuestMgr:GetQuestRequiredMapBGM(MapID)
    if QuestRequiredMapBGM then
        self.MapBGMusic = QuestRequiredMapBGM
    end

	if (self.MapBGMusic == nil or self.MapBGMusic == "") then
        self:StopCurrBGMusic()
        return
    end
end

function PWorldDynDataMgr:StopCurrBGSound()
    if (self.CurrBGSoundPath ~= nil and self.CurrBGSoundPath ~= "") then
        local EventPath = string.gsub(self.CurrBGSoundPath, "Play_", "Stop_", 1)
        AudioUtil.LoadAndPlay2DSound(EventPath, Cache_Map)
        self.CurrBGSoundPath = nil
    end
end

--在场景内持续播放的风声、雨声等2D音效
function PWorldDynDataMgr:LoadBGSound(MapTableCfg)
	if (MapTableCfg == nil) then
		return
	end

    self:StopCurrBGSound()

    if (MapTableCfg.BGSound == nil or MapTableCfg.BGSound == "") then
        return
    end
    AudioUtil.LoadAndPlay2DSound(MapTableCfg.BGSound, Cache_Map)
    self.CurrBGSoundPath = MapTableCfg.BGSound
end

function PWorldDynDataMgr:LoadDefaultWeather(CurrMapEditCfg)
    local MapID = CurrMapEditCfg.MapID
    if (MapID == 0) then
		return
	end
    local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(MapID)
	if (MapTableCfg == nil) then
		return
	end

    if (MapTableCfg.DefaultWeatherName == nil or MapTableCfg.DefaultWeatherName == "") then
        return
    end
    self.DefaultWeatherName = MapTableCfg.DefaultWeatherName
    self:PlayWeatherSequence(self.DefaultWeatherName)
end

function PWorldDynDataMgr:LoadCutSceneSequence(CurrMapEditCfg)
    local MovieSequenceList = CurrMapEditCfg.MapMovieSequenceList
    for _, MovieSequence in ipairs(MovieSequenceList) do
        local CutSceneSequenceObj = DynDataCutSceneSequence.New()
        CutSceneSequenceObj:OnLoadData(MovieSequence)
        table.insert(self.MapDynDatas, CutSceneSequenceObj)
    end
end

function PWorldDynDataMgr:UpdateDynDataList(MapDynDataList, bInit)
    for _, MapDynData in ipairs(MapDynDataList.DynList) do
        self:UpdateDynData(MapDynData, bInit)
    end
end

function PWorldDynDataMgr:UpdateDynData(MapDynData, bInit)
    if (MapDynData.Type == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MUSIC) then
        local Extra = MapDynData.Extra
        local BGMusicPlayingID = self.BGMusicPlayingID
        if Extra ~= nil and Extra ~= "" and self.CurrBGMName ~= Extra then
            if Extra == "None" then
                if BGMusicPlayingID then
                    _G.UE.UAudioMgr.Get():StopBGM(BGMusicPlayingID)
                end
            else
                self.CacheDungeonBGMID = nil
                self.CacheDungeonBGMChannel = nil
                -- 只有在副本中, 会播放DynData中的BGM
                if _G.PWorldMgr:CurrIsInDungeon() then
                    local ID
                    local Channel = EBGMChannel.Content
                    if (string.find(Extra, "/")) then
                        local MusicNameArray = string.split(Extra, "/")
                        ID = tonumber(MusicNameArray[1])
                        Channel = tonumber(MusicNameArray[2])
                    else
                        ID = tonumber(Extra)
                    end
                   
                    --做个缓存，等地图加载完成或者开场动画播放完成再播放副本BGM
                    self.CacheDungeonBGMID = ID
                    self.CacheDungeonBGMChannel = Channel

                     --副本过程中网络重连或者动态数据更新，此时不用考虑开场动画, 直接播
                     if (_G.PWorldMgr:IsEnterMapFinish()) then
                        self:PlayDungeonBGM()
                     end
                end
            end
        end

    elseif (MapDynData.Type == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_WEATHER) then
        local WeatherPlanID = MapDynData.Status

        if WeatherMgr == nil then
            WeatherMgr = _G.WeatherMgr
        end

        WeatherMgr:SetClientWeatherPlanWithFindParams(WeatherPlanID)
        ---self:PlayWeatherSequence(WeatherMarkName)

    elseif (MapDynData.Type == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_WAY_POINT) then
        local MapPointID = MapDynData.Status
        --print("PWorldDynDataMgr:UpdateDynData MapPointID", MapPointID)
        local MapPoint = _G.MapEditDataMgr:GetMapPoint(MapPointID)
        if (MapPoint ~= nil) then
            local Point = _G.UE.FVector(MapPoint.Point.X, MapPoint.Point.Y, MapPoint.Point.Z)
            NaviDecalMgr:SetNaviType(NaviDecalMgr.EGuideType.MapWay)
            NaviDecalMgr:NaviPathToPos(Point, _G.NaviDecalMgr.EGuideType.MapWay)
        else
            NaviDecalMgr:CancelNaviType(NaviDecalMgr.EGuideType.MapWay)
        end

    elseif (MapDynData.Type ~= ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_NONE) then
        local DynData = self:GetDynData(MapDynData.Type, MapDynData.ID)
        if (DynData ~= nil) then
            if (MapDynData.Type == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE) then
                if (MapDynData.Extra ~= nil and MapDynData.Extra ~= "") then
                    local PlayRate = tonumber(MapDynData.Extra)
                    if (PlayRate == nil or PlayRate <= 0) then
                        PlayRate = 100
                    end 
                    DynData:SetPlayRate(PlayRate)
                end
                DynData:SetIsInit(bInit)

            elseif (MapDynData.Type == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_MOVIE_SEQUENCE) then
                DynData:SetIsInit(bInit)
                DynData:UpdateMajorPlaying(MapDynData.Status, MapDynData.Extra)
            end

            DynData:UpdateState(MapDynData.Status)
        else
            if (MapDynData.ID > 0) then
                local CachedDynData = self:GetCachedDynData(MapDynData.Type, MapDynData.ID)
                if (CachedDynData == nil) then
                    local CacheDynData = DynDataCache.New()
                    CacheDynData.ID = MapDynData.ID
                    CacheDynData.DataType = MapDynData.Type
                    CacheDynData.State = MapDynData.Status
                    if (self.MapCachedDynDatas == nil) then
                        self.MapCachedDynDatas = {}
                    end
                    table.insert(self.MapCachedDynDatas, CacheDynData)
                else
                    CachedDynData.State = MapDynData.Status
                end
            end
            --print("dyndata asset was not loaded ", MapDynData.Type, MapDynData.ID)
        end
    end

    if (self.EventParams == nil) then
        self.EventParams = {}
    end
    self.EventParams.Type = MapDynData.Type
    self.EventParams.Extra = MapDynData.Extra
    self.EventParams.ID = MapDynData.ID
    self.EventParams.State = MapDynData.Status

    _G.EventMgr:SendEvent(EventID.PWorldUpdateDynData, self.EventParams)
end

function PWorldDynDataMgr:ExecMovieSequenceAutoPlay()
    for _, DynData in ipairs(self.MapDynDatas) do
        if (DynData.DataType == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_MOVIE_SEQUENCE) then
            local bResult = DynData:ExecAutoPlay()
            if (bResult) then
                return true
            end
        end
    end

    return false
end

function PWorldDynDataMgr:GetAutoPlaySequence()
    for _, DynData in ipairs(self.MapDynDatas) do
        if (DynData.DataType == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_MOVIE_SEQUENCE) then
            local CutSceneSequence = DynData:GetAutoPlaySequence()
            if (CutSceneSequence ~= nil and CutSceneSequence.ID > 0) then
                return CutSceneSequence
            end
        end
    end

    return nil
end

function PWorldDynDataMgr:PlaySound(SoundName, Intensity)
    local EventName = ""
	local RTPCName = ""
    if (string.find(SoundName, "/")) then
        local SoundNameArray = string.split("/")
        EventName = SoundNameArray[1]
        RTPCName = SoundNameArray[2]
    else
        EventName = SoundName
    end

    local UAudioMgr = _G.UE.UAudioMgr.Get()
    local ActorProxy = UAudioMgr:GetAudioProxy()
	UAudioMgr:PostEventByName(EventName, ActorProxy, true)
	if (RTPCName ~= "") then
        UAudioMgr:SetRTPCValue(RTPCName, Intensity, 500, ActorProxy)
    end
end

function PWorldDynDataMgr:SwitchMapDefaultBGMusic(MusicName)
    if (MusicName ~= nil and MusicName ~= "") then
        self.MapBGMusic = MusicName
        self:PlayMusicBySceneID(MusicName)
    end
end

function PWorldDynDataMgr:PlayMusicBySceneID(SceneID)
    local UAudioMgr = _G.UE.UAudioMgr.Get()
    SceneID = tonumber(SceneID)
    if SceneID then
        UAudioMgr:PlaySceneBGM(SceneID)
        self.CurrBGMSceneID = SceneID
    end
end

function PWorldDynDataMgr:PlayMusicAtChannel(ID, Channel)
    local UAudioMgr = _G.UE.UAudioMgr.Get()

    local BGMID = tonumber(ID)
    Channel = tonumber(Channel) or EBGMChannel.BaseZone
    if BGMID then
        return UAudioMgr:PlayBGM(BGMID, Channel)
    end
end

function PWorldDynDataMgr:PlayDungeonBGM()
    if (self.CacheDungeonBGMID ~= nil and self.CacheDungeonBGMChannel ~= nil) then
        self.BGMusicPlayingID = self:PlayMusicAtChannel(self.CacheDungeonBGMID, self.CacheDungeonBGMChannel)
    end
end

function PWorldDynDataMgr:PlayWeatherSequence(WeatherMarkParam)
    if (WeatherMarkParam == nil or WeatherMarkParam == "") then
        return
    end

    local WeatherNameList = string.split(WeatherMarkParam, ',')
    local WeatherName = ""
    local WeatherMarkName = ""
    if (#WeatherNameList == 2) then
        WeatherName = string.lower(WeatherNameList[1])
        WeatherMarkName = WeatherNameList[2]
    else
        WeatherMarkName = WeatherMarkParam
    end
    if ( self.WeatherSequenceControllerActors == nil) then
        self.WeatherSequenceControllerActors = {}
    end
    local WeatherSequenceControllerActor = self.WeatherSequenceControllerActors[WeatherName]
    if (WeatherSequenceControllerActor == nil) then
        local AllSequenceControllers = _G.UE.TArray(_G.UE.ADungeonSequenceController)
        _G.UE.UGameplayStatics.GetAllActorsOfClass(FWORLD(), _G.UE.ADungeonSequenceController.StaticClass(), AllSequenceControllers)
        local SequenceControllerCnt = AllSequenceControllers:Length()
        if (SequenceControllerCnt > 0) then
            if (WeatherName ~= "") then
                for i = 1, SequenceControllerCnt, 1 do
                    local SequenceControllerActor = AllSequenceControllers:Get(i)
                    if (SequenceControllerActor ~= nil) then
                        local ControllerActorName = string.lower(SequenceControllerActor:GetName())
                        print("ControllerActorName=" .. ControllerActorName .. ", WeatherName=" .. WeatherName)
                        if nil ~= string.find(ControllerActorName, WeatherName) then
                            WeatherSequenceControllerActor = SequenceControllerActor
                            self.WeatherSequenceControllerActors[WeatherName] = WeatherSequenceControllerActor
                            break
                        end
                    end
                end
            else
                WeatherSequenceControllerActor = AllSequenceControllers:Get(1)
            end
        end
    end

    if (WeatherSequenceControllerActor ~= nil) then
        WeatherSequenceControllerActor:PlayToMark(WeatherMarkName)
    end
end

function PWorldDynDataMgr:GetDynData(DataType, ID)
    if (self.MapDynDatas ~= nil) then
        for _, DynData in ipairs(self.MapDynDatas) do
            if (DynData.DataType == DataType and DynData.ID == ID) then
                return DynData
            end
        end
    end

    return nil
end


function PWorldDynDataMgr:RemoveDynData(InDynData)
    if (self.MapDynDatas ~= nil) then
        for i = #self.MapDynDatas, 1, -1 do
            local DynData = self.MapDynDatas[i]
            if (DynData.DataType == InDynData.DataType and DynData.ID == InDynData.ID) then
                table.remove(self.MapDynDatas, i)
                break
            end
        end
    end
end

function PWorldDynDataMgr:GetCachedDynData(DataType, ID)
    if (self.MapCachedDynDatas ~= nil) then
        for _, CachedDynData in ipairs(self.MapCachedDynDatas) do
            if (CachedDynData.DataType == DataType and CachedDynData.ID == ID) then
                return CachedDynData
            end
        end
    end


    return nil
end

function PWorldDynDataMgr:RemoveCachedDynData(InCachedDynData)
    if (self.MapCachedDynDatas ~= nil) then
        for i = #self.MapCachedDynDatas, 1, -1 do
            local CachedDynData = self.MapCachedDynDatas[i]
            if (CachedDynData.DataType == InCachedDynData.DataType and CachedDynData.ID == InCachedDynData.ID) then
                table.remove(self.MapCachedDynDatas, i)
                break
            end
        end
    end
end

function PWorldDynDataMgr:HasAnyValidDynObstacles()
    if (self.MapDynDatas ~= nil) then
        for _, DynData in ipairs(self.MapDynDatas) do
            if (DynData.DataType == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_OBSTACLE and DynData.State == 1) then
                return true
            end
        end
    end

    return false
end

function PWorldDynDataMgr:GetCutSceneSequence(SequenceID)
    if (self.MapDynDatas ~= nil) then
        for _, DynData in ipairs(self.MapDynDatas) do
            if (DynData.DataType == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_MAP_MOVIE_SEQUENCE and DynData.ID == SequenceID) then
                return DynData
            end
        end
    end

    return nil
end

function PWorldDynDataMgr:OnDynamicAssetLoadInLand(DynamicAssetActor)
    if (DynamicAssetActor.ID <= 0) then
        print("OnDynamicAssetLoadInLand dynamic asset id is error", DynamicAssetActor.ID, DynamicAssetActor.DynamicAssetType)
        return
    end
    if (self.MapDynDatas == nil) then
        self.MapDynDatas = {}
    end

    local DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_NONE
    local EDynamicAssetType = _G.UE.EMapDynamicAssetType
    if (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Effect) then
        DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
        local DynData = self:GetDynData(DataType, DynamicAssetActor.ID)
        if (DynData == nil) then
            local DynEffectObj = DynDataEffect.New()
            DynEffectObj.ID = DynamicAssetActor.ID
            DynEffectObj.MapDynamicAssetModel = DynamicAssetActor
            table.insert(self.MapDynDatas, DynEffectObj)
        end
    end

    if (DataType == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_NONE) then
        return
    end

    local CachedDynData = self:GetCachedDynData(DataType, DynamicAssetActor.ID)
    if (CachedDynData ~= nil and CachedDynData.ID > 0) then
        local DynData = self:GetDynData(DataType, DynamicAssetActor.ID)
        if (DynData ~= nil) then
            DynData:UpdateState(CachedDynData.State)
        end

        self:RemoveCachedDynData(CachedDynData)
    end
end

function PWorldDynDataMgr:OnDynamicAssetUnLoadInLand(DynamicAssetActor)
    if (DynamicAssetActor.ID <= 0) then
        print("OnDynamicAssetLoadInLand dynamic asset id is error", DynamicAssetActor.ID, DynamicAssetActor.DynamicAssetType)
        return
    end
    if (self.MapDynDatas == nil) then
        self.MapDynDatas = {}
    end
    local DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_NONE
    local EDynamicAssetType = _G.UE.EMapDynamicAssetType
    if (DynamicAssetActor.DynamicAssetType == EDynamicAssetType.MapDynamicAssetType_Effect) then
        DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
    end

    if (DataType == ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_NONE) then
        return
    end

    local CachedDynData = self:GetCachedDynData(DataType, DynamicAssetActor.ID)
    if (CachedDynData ~= nil and CachedDynData.ID > 0) then
        self:RemoveCachedDynData(CachedDynData)
    end

    local DynData = self:GetDynData(DataType, DynamicAssetActor.ID)
    if (DynData ~= nil and DynData.ID > 0) then
        self:RemoveDynData(DynData)
    end
end

function PWorldDynDataMgr:OnSgActorLoadInLand(SgActor)
    if (SgActor.ID <= 0) then
        FLOG_ERROR("OnSgActorLoadInLand dynamic asset id [%d] is error", SgActor.ID)
        return
    end
    if (self.MapDynDatas == nil) then
        self.MapDynDatas = {}
    end

    FLOG_INFO("OnSgActorLoadInLand: sg [%d] loaded", SgActor.ID)
    local DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
    local DynData = self:GetDynData(DataType, SgActor.ID)
    if (DynData == nil) then
        DynData = DynDataEffect.New()
        DynData.ID = SgActor.ID
        DynData.MapDynamicAssetModel = SgActor
        table.insert(self.MapDynDatas, DynData)
    end

    local CachedDynData = self:GetCachedDynData(DataType, SgActor.ID)
    if (CachedDynData ~= nil and CachedDynData.ID > 0) then
        DynData:UpdateState(CachedDynData.State)
        self:RemoveCachedDynData(CachedDynData)
    end
end

---@param SgActor SgLayoutActorBase
function PWorldDynDataMgr:OnSgActorUnLoadInLand(SgActor)
    if (SgActor.ID <= 0) then
        print("OnSgActorUnLoadInLand dynamic asset id is error", SgActor.ID)
        return
    end
    if (self.MapDynDatas == nil) then
        self.MapDynDatas = {}
    end
    local DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
    local CachedDynData = self:GetCachedDynData(DataType, SgActor.ID)
    if (CachedDynData ~= nil and CachedDynData.ID > 0) then
        self:RemoveCachedDynData(CachedDynData)
    end

    local DynData = self:GetDynData(DataType, SgActor.ID)
    if (DynData ~= nil and DynData.ID > 0) then
        self:RemoveDynData(DynData)
    end
end

return PWorldDynDataMgr