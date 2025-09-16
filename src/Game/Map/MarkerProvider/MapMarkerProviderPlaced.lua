--
-- Author: anypkvcai
-- Date: 2023-03-08 15:48
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
--local MapMarkerPlaced = require("Game/Map/Marker/MapMarkerPlaced")
--local MapPlacedMarkerCfg = require("TableCfg/MapPlacedMarkerCfg")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")

local MapMarkerType = MapDefine.MapMarkerType


---@class MapMarkerProviderPlaced : MapMarkerProvider
local MapMarkerProviderPlaced = LuaClass(MapMarkerProvider)

function MapMarkerProviderPlaced:Ctor()

end

function MapMarkerProviderPlaced:GetMarkerType()
	return MapMarkerType.Placed
end

function MapMarkerProviderPlaced:OnGetMarkers(UIMapID)
	self:GetFollowMarker()

	local MapMarkers = _G.WorldMapMgr:GetPlacedMarkers(UIMapID)
	return MapMarkers
end

-- 获取当前UIMapID的标记点追踪标记
function MapMarkerProviderPlaced:GetFollowMarker()
	_G.WorldMapMgr:ResetPlacedMarkerUIMapInfo()

	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return
	end
	local PlacedMarker = _G.WorldMapMgr:FindPlacedMarkerByID(FollowInfo.FollowID)
	if PlacedMarker == nil then
		return
	end
	local FollowUIMapID = FollowInfo.FollowUIMapID

	if MapUtil.IsAreaMap(self.UIMapID) then
		-- 三级地图的追踪标记在GetPlacedMarkers已处理
		return

	elseif MapUtil.IsRegionMap(self.UIMapID) then
		-- 二级地图的追踪标记
		if MapUtil.IsSpecialUIMap(FollowUIMapID) then
			return
		end
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		if RegionUIMapID == self.UIMapID then
			PlacedMarker:SetUIMapID(self.UIMapID)
			local SetPosResult = MapUtil.SetRegionUIPos(PlacedMarker, self.UIMapID, FollowUIMapID)
			if not SetPosResult then
				return
			end
			return PlacedMarker
		end

	elseif MapUtil.IsWorldMap(self.UIMapID) then
		-- 一级地图的追踪标记
		PlacedMarker:SetUIMapID(self.UIMapID)
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		MapUtil.SetWorldUIPos(PlacedMarker, self.UIMapID, RegionUIMapID)
		return PlacedMarker
	end
end

function MapMarkerProviderPlaced:UpdateFollowMarker(FollowInfo)
	if FollowInfo == nil then
		return
	end

	local FollowMarkerID = FollowInfo.FollowID
	local Marker = _G.WorldMapMgr:FindPlacedMarkerByID(FollowMarkerID)
	if Marker then
		Marker:UpdateFollow()
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		self:UpdatePlacedMaker(Marker)
	else
		_G.EventMgr:SendEvent(_G.EventID.WorldMapUpdateAllMarker)
	end
end

---@param Params MapMarkerPlaced @默认是通过ID查找, 如果是其他条件查找，子类要重写FindMarker函数
function MapMarkerProviderPlaced:FindMarker(Params)
	return table.find_item(self.MapMarkers, Params)
end

function MapMarkerProviderPlaced:UpdatePlacedMaker(InMaker)
	if nil ~= self:FindMarker(InMaker) then
		self:SendUpdateMarkerEvent(InMaker)
	end
end

function MapMarkerProviderPlaced:AddPlacedMakers(InMakers)
	local Markers = {}
	local Marker

	for i = 1, #InMakers do
		Marker = InMakers[i]
		if Marker:GetUIMapID() == self.UIMapID then
			table.insert(self.MapMarkers, Marker)
			table.insert(Markers, Marker)
		end
	end

	if #Markers > 0 then
		self:SendAddMarkerListEvent(Markers)
	end
end

function MapMarkerProviderPlaced:RemovePlacedMakers(InMakers)
	local Marker

	for i = 1, #InMakers do
		Marker = InMakers[i]
		table.remove_item(self.MapMarkers, Marker)
	end

	if #InMakers > 0 then
		self:SendRemoveMarkerListEvent(InMakers)
	end
end

return MapMarkerProviderPlaced