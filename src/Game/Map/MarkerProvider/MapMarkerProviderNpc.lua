local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerNpc = require("Game/Map/Marker/MapMarkerNpc")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapNpcIconCfg = require("TableCfg/MapNpcIconCfg")

local MapMarkerType = MapDefine.MapMarkerType


---@class MapMarkerProviderNpc : MapMarkerProvider
local MapMarkerProviderNpc = LuaClass(MapMarkerProvider)

function MapMarkerProviderNpc:Ctor()

end

function MapMarkerProviderNpc:GetMarkerType()
	return MapMarkerType.Npc
end

function MapMarkerProviderNpc:OnGetMarkers(UIMapID, MapID)
   return self:CreateNpcMarkers()
end

function MapMarkerProviderNpc:OnCreateMarker(Params)
    local Marker = self:CreateMarker(MapMarkerNpc, Params.NpcID, Params)

    local X, Y = MapUtil.GetUIPosByLocation(Params.BirthPoint, Params.UIMapID)
	Marker:SetAreaMapPos(X, Y)

    return Marker
end

function MapMarkerProviderNpc:CreateNpcMarkers()
    local MapMarkers = {}

    if MapUtil.IsAreaMap(self.UIMapID) then
        MapMarkers = self:GetNpcMarkers()
    else
        local FollowMarker = self:GetFollowMarker()
        if FollowMarker then
            table.insert(MapMarkers, FollowMarker)
        end
    end

	return MapMarkers
end

-- 获取当前UIMapID的Npc标记
function MapMarkerProviderNpc:GetNpcMarkers()
    local MapID = self.MapID
    if nil == MapID or 0 == MapID then
        return
    end
    local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if MapEditCfg == nil then
		return
	end

    local MapMarkers = {}

    -- 获取给定地图里的Npc，看哪些配置了需要在地图上显示
    for _, NpcData in pairs(MapEditCfg.NpcList) do
        local CfgMapNpcIcon = MapNpcIconCfg:FindCfgByKey(NpcData.NpcID)
        if CfgMapNpcIcon then
            local BelongUIMapID = _G.MapAreaMgr:GetUIMapIDByLocation(NpcData.BirthPoint, MapID)
            -- 要求Npc所属的UIMapID和当前UIMapID一致
            if BelongUIMapID == self.UIMapID then
                local Params = {}
                Params.NpcID = NpcData.NpcID
                Params.BirthPoint = NpcData.BirthPoint
                Params.UIMapID = self.UIMapID
                Params.MapID = MapID
                local Marker = self:OnCreateMarker(Params)
                table.insert(MapMarkers, Marker)
            end
        end
    end

    return MapMarkers
end

-- 获取当前UIMapID的Npc追踪标记
function MapMarkerProviderNpc:GetFollowMarker()
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return
	end
    local FollowNpcResID = FollowInfo.FollowID
	local FollowUIMapID = FollowInfo.FollowUIMapID
    local FollowMapID = FollowInfo.FollowMapID

	if MapUtil.IsAreaMap(self.UIMapID) then
		-- 三级地图的追踪标记已处理
        return

	elseif MapUtil.IsRegionMap(self.UIMapID) then
		-- 二级地图的追踪标记
        if MapUtil.IsSpecialUIMap(FollowUIMapID) then
			return
		end
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		if RegionUIMapID == self.UIMapID then
            local Point = MapUtil.GetMapNpcPosByResID(FollowMapID, FollowNpcResID)
            if Point == nil then
                return
            end
            local Params = {}
            Params.NpcID = FollowNpcResID
            Params.BirthPoint = Point
            Params.UIMapID = FollowUIMapID
            Params.MapID = FollowMapID
            local Marker = self:OnCreateMarker(Params)
            local SetPosResult = MapUtil.SetRegionUIPos(Marker, self.UIMapID, FollowUIMapID)
            if not SetPosResult then
                return
            end
            return Marker
		end

	elseif MapUtil.IsWorldMap(self.UIMapID) then
		-- 一级地图的追踪标记
        local Params = {}
        Params.NpcID = FollowNpcResID
        Params.UIMapID = FollowUIMapID
        Params.MapID = FollowMapID
		local Marker = self:OnCreateMarker(Params)
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		MapUtil.SetWorldUIPos(Marker, self.UIMapID, RegionUIMapID)
		return Marker
	end
end

return MapMarkerProviderNpc