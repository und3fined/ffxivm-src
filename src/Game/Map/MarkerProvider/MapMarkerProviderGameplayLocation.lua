--
-- Author:
-- Date:
-- Description: 地图中各玩法位置是否可见(透过GM展示，正常不显示)
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerGameplayLocation = require("Game/Map/Marker/MapMarkerGameplayLocation")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")

local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")
local WildBoxMoundCfg = require("TableCfg/WildBoxMoundCfg")
local TouringBandTimelineCfg = require("TableCfg/TouringBandTimelineCfg")
local MysteryMerchantMapPointCfg = require("TableCfg/MysteryMerchantMapPointCfgCfg")
local MysteryMerchantTaskCfg = require("TableCfg/MysteryMerchantTaskCfgCfg")
local FateGeneratorCfg = require("TableCfg/FateGeneratorCfg")
local FateMainCfg = require("TableCfg/FateMainCfg")
local AetherCurrentCfg = require("TableCfg/AetherCurrentCfg")


---@class MapMarkerProviderGameplayLocation : MapMarkerProvider
local MapMarkerProviderGameplayLocation = LuaClass(MapMarkerProvider)

function MapMarkerProviderGameplayLocation:Ctor()
end

function MapMarkerProviderGameplayLocation:OnGetMarkers(UIMapID, MapID)
    if UIMapID ~= _G.MapMgr:GetUIMapID() then return end

    local IsOpenMarkerVisible = _G.MapMgr:GetGameplayLocationVisible()
    if not IsOpenMarkerVisible then return end

    local Markers = {}

    local SearchCondition = string.format("MapID = %d", MapID)

    -- 探索笔记
    local DiscoverNoteFindCfgs = DiscoverNoteCfg:FindAllCfg(SearchCondition)
    for _, Cfg in ipairs(DiscoverNoteFindCfgs) do
        local Param = {
            ID = Cfg.EobjID,
            BirthPoint = { X = Cfg.PositionX, Y = Cfg.PositionY },
            Type = 1,
        }

        local Marker = self:OnCreateMarker(Param)
        table.insert(Markers, Marker)
    end

    -- 野外宝箱
    local WildBoxMoundFindCfgs = WildBoxMoundCfg:FindAllCfg(SearchCondition)
    for _, Cfg in ipairs(WildBoxMoundFindCfgs) do
        local EObj = _G.MapEditDataMgr:GetEObjByListID(Cfg.EmptyListID)
        if EObj then
            local Param = {
                ID = Cfg.EmptyListID,
                BirthPoint = EObj.Point,
                Type = 2,
            }

            local Marker = self:OnCreateMarker(Param)
            table.insert(Markers, Marker)
        end
    end

    -- 巡回乐团
    local TouringBandTimelineFindCfgs = TouringBandTimelineCfg:FindAllCfg(SearchCondition)
    for _, Cfg in ipairs(TouringBandTimelineFindCfgs) do
        local Param = {
            ID = Cfg.ID,
            BirthPoint = { X = Cfg.Pos.X, Y = Cfg.Pos.Y },
            Type = 3,
        }

        local Marker = self:OnCreateMarker(Param)
        table.insert(Markers, Marker)
    end

    -- 神秘商人
    local MerchantMapFindCfgs = MysteryMerchantMapPointCfg:FindAllCfg(SearchCondition)
    for _, MapCfg in pairs(MerchantMapFindCfgs) do
        local TaskCfg = MysteryMerchantTaskCfg:FindCfgByKey(MapCfg.TasksID[1])
        local MapPoint = _G.MapEditDataMgr:GetMapPoint(MapCfg.BirthID)
        if MapPoint then
            local Param = {
                ID = MapCfg.BirthID,
                BirthPoint = { X = MapPoint.Point.X, Y = MapPoint.Point.Y },
                Radius = TaskCfg and TaskCfg.AwakenDistance or 0,
                Type = 4,
            }

            local Marker = self:OnCreateMarker(Param)
            table.insert(Markers, Marker)
        end
    end

    -- Fate
    local FateIDs = FateGeneratorCfg:FindAllCfg(SearchCondition)
	local FateMainFindCfgs = {}
	for i = 1, #FateIDs do
		local Cfg = FateMainCfg:FindCfgByKey(FateIDs[i].ID)
		if Cfg then
			table.insert(FateMainFindCfgs, Cfg)
		end
	end
    for _, Cfg in ipairs(FateMainFindCfgs) do
        local RangeString = Cfg.Range
        if RangeString ~= '' then
            local RangeInfo = string.split(RangeString, ',')

            local Param = {
                ID = Cfg.ID,
                BirthPoint = { X = RangeInfo[1], Y = RangeInfo[2] },
                Radius = RangeInfo[5],
                Type = 5,
            }

            local Marker = self:OnCreateMarker(Param)
            table.insert(Markers, Marker)
        end
    end

    -- 风脉泉
    local AetherCurrentFindCfgs = AetherCurrentCfg:FindAllCfg(SearchCondition)
    for _, Cfg in ipairs(AetherCurrentFindCfgs) do
        local EObj = _G.MapEditDataMgr:GetEObjByListID(Cfg.ListID)
        if EObj then
            local Param = {
                ID = Cfg.PointID,
                BirthPoint = EObj.Point,
                Type = 6,
            }

            local Marker = self:OnCreateMarker(Param)
            table.insert(Markers, Marker)
        end
    end

    return Markers
end

function MapMarkerProviderGameplayLocation:OnCreateMarker(Params)
    local Point = Params.BirthPoint
    local Marker = self:CreateMarker(MapMarkerGameplayLocation, Params.ID, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Point, self.UIMapID)
    Marker:SetAreaMapPos(X, Y)

    return Marker
end

function MapMarkerProviderGameplayLocation:GetMarkerType()
    return MapDefine.MapMarkerType.GameplayLocation
end

return MapMarkerProviderGameplayLocation
