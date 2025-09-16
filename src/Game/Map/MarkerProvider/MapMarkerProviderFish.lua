--
-- Author: anypkvcai
-- Date: 2023-07-03 23:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerFish = require("Game/Map/Marker/MapMarkerFish")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")

local MapMarkerType = MapDefine.MapMarkerType


---@class MapMarkerProviderFish : MapMarkerProvider
local MapMarkerProviderFish = LuaClass(MapMarkerProvider)

function MapMarkerProviderFish:Ctor()

end

function MapMarkerProviderFish:GetMarkerType()
	return MapMarkerType.Fish
end

function MapMarkerProviderFish:OnGetMarkers(UIMapID)
	local MapMarkers = {}
	if self.ContentType == MapDefine.MapContentType.FishMap then
		local MapInfos = FishIngholeVM:GetSelectLocationMapInfo()
		if nil == MapInfos then
			return
		end
		for k, v in pairs(MapInfos) do
			local Marker = self:OnCreateMarker(v, k)
			table.insert(MapMarkers, Marker)
		end
	else
		-- 大地图，只显示追踪中的
		local FollowMarker = self:GetFollowMarker()
		if FollowMarker then
			table.insert(MapMarkers, FollowMarker)
		end
	end

	return MapMarkers
end

function MapMarkerProviderFish:OnCreateMarker(Params, ID)
	if nil == Params or nil == Params.FishIngholeX or nil == Params.FishIngholeY then
		return
	end
	local Marker = self:CreateMarker(MapMarkerFish, ID, Params)
	Marker:SetAreaMapPos( -Params.FishIngholeY, Params.FishIngholeX)
	return Marker
end

function MapMarkerProviderFish:UpdateSelected(LocationID)
	local MapMarkers = self.MapMarkers

	local Marker
	for i = 1, #MapMarkers do
		Marker = MapMarkers[i]
		if Marker:GetID() == LocationID and not Marker:GetIsSelected() then
			Marker:SetIsSelected(true)
			self:SendUpdateMarkerEvent(Marker)
		elseif Marker:GetID() ~= LocationID and Marker:GetIsSelected() then
			Marker:SetIsSelected(false)
			self:SendUpdateMarkerEvent(Marker)
		end
	end
end

function MapMarkerProviderFish:UpdateFollowMarker(FollowInfo)
	if FollowInfo == nil then
		return
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		local FollowMarkerID = FollowInfo.FollowID
		local Marker = self:FindMarker(FollowMarkerID)
		if Marker then
			Marker:UpdateFollow()
			self:SendUpdateMarkerEvent(Marker)
		end

		if self.ContentType ~= MapDefine.MapContentType.FishMap then
			-- 钓鱼标记：在钓鱼地图里追踪后，要在大地图、小地图增加；在大地图里取消追踪后，要在大地图、小地图移除
			self:ClearAndUpdateMarkers()
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.WorldMapUpdateAllMarker)
	end
end

function MapMarkerProviderFish:GetFollowMarker()
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return
	end
    local FollowMapID = FollowInfo.FollowMapID
	if self.MapID and self.MapID ~= FollowMapID then
		return
	end
	local FollowID = FollowInfo.FollowID
	if FollowID == nil then
		return
	end
	local Params = FishIngholeVM:GetLocationMapInfoByID(FollowID)
	if Params and Params[FollowID] then
		local Marker = self:OnCreateMarker(Params[FollowID], FollowID)
		return Marker
	end
end

return MapMarkerProviderFish