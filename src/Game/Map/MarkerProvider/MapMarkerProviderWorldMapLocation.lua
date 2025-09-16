--
-- Author: peterxie
-- Date:
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerWorldMapLocation = require("Game/Map/Marker/MapMarkerWorldMapLocation")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")


---@class MapMarkerProviderWorldMapLocation : MapMarkerProvider
local MapMarkerProviderWorldMapLocation = LuaClass(MapMarkerProvider)

function MapMarkerProviderWorldMapLocation:Ctor()

end

function MapMarkerProviderWorldMapLocation:GetMarkerType()
	return MapDefine.MapMarkerType.WorldMapLocation
end

function MapMarkerProviderWorldMapLocation:OnGetMarkers(UIMapID, MapID)
	local MapMarkers = {}

	if self.ContentType == MapDefine.MapContentType.WorldMapLocation then
		local LocationParams = _G.WorldMapMgr.WorldMapLocationParams
		if LocationParams == nil then
			return
		end
		if MapID ~= LocationParams.MapID then
			return
		end

		local Marker = self:CreateLocationMarker()
		if Marker then
            table.insert(MapMarkers, Marker)
        end
	else
		local FollowMarker = self:GetFollowMarker()
        if FollowMarker then
            table.insert(MapMarkers, FollowMarker)
        end
	end

	return MapMarkers
end

function MapMarkerProviderWorldMapLocation:OnCreateMarker(Params)
	local Marker = self:CreateMarker(MapMarkerWorldMapLocation, Params.MarkerID, Params)
	if nil == Marker then
		return
	end

	local X, Y = MapUtil.GetUIPosByLocation(Params.Location, self.UIMapID)
	Marker:SetAreaMapPos(X, Y)

	return Marker
end

function MapMarkerProviderWorldMapLocation:CreateLocationMarker()
	local LocationParams = _G.WorldMapMgr.WorldMapLocationParams
	if LocationParams == nil then
		return
	end
	local MapID = LocationParams.MapID
	local MarkerID = LocationParams.MarkerID
	local LocationType = LocationParams.LocationType

	local Location = self:GetLocation(MapID, MarkerID, LocationType)
	if Location == nil then
		return
	end

	local Params = { MarkerID = MarkerID, LocationType = LocationType, Location = Location }
	local Marker = self:OnCreateMarker(Params)
	return Marker
end

function MapMarkerProviderWorldMapLocation:GetLocation(MapID, MarkerID, LocationType)
	local Location
	if LocationType == MapDefine.MapLocationType.Npc then
		Location = MapUtil.GetMapNpcPosByResID(MapID, MarkerID)
	elseif LocationType == MapDefine.MapLocationType.EObj then
		Location = MapUtil.GetMapEObjPosByResID(MapID, MarkerID)
	end

	return Location
end

function MapMarkerProviderWorldMapLocation:GetFollowMarker()
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return
	end
    local FollowMarkerID = FollowInfo.FollowID
    local FollowMapID = FollowInfo.FollowMapID
	local FollowSubType = FollowInfo.FollowSubType

	if self.MapID ~= FollowMapID then
		return
	end

	local Location = self:GetLocation(FollowMapID, FollowMarkerID, FollowSubType)
	if Location == nil then
		return
	end

	local Params = { MarkerID = FollowMarkerID, LocationType = FollowSubType, Location = Location }
	local Marker = self:OnCreateMarker(Params)
	return Marker
end

function MapMarkerProviderWorldMapLocation:FindMarker(Params)
	local MarkerID = Params.ID
	local LocationType = Params.SubType

	local Marker = table.find_by_predicate(self.MapMarkers, function(Marker)
		return Marker:GetSubType() == LocationType and Marker:GetID() == MarkerID
	end)
	return Marker
end

function MapMarkerProviderWorldMapLocation:UpdateFollowMarker(FollowInfo)
	if FollowInfo == nil then
		return
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		local Params = { ID = FollowInfo.FollowID, SubType = FollowInfo.FollowSubType }
		local Marker = self:FindMarker(Params)
		if Marker then
			Marker:UpdateFollow()
			self:SendUpdateMarkerEvent(Marker)
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.WorldMapUpdateAllMarker)
	end
end


return MapMarkerProviderWorldMapLocation